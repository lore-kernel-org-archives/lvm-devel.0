From: David Teigland <teigland@fedoraproject.org>
Date: Thu, 20 Aug 2015 19:07:55 +0000 (UTC)
Subject: master - lvmlockd: fix sending debug info to lvmlockctl
Message-ID: <20150820190755.1462960256@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1fae121b222927584a7a88cd3f4f1ba2aadb4931
Commit:        1fae121b222927584a7a88cd3f4f1ba2aadb4931
Parent:        180f92d3dc9891d4536a69de25dcb285979cd9e4
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Aug 20 14:00:12 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Aug 20 14:07:11 2015 -0500

lvmlockd: fix sending debug info to lvmlockctl

Single messages sent over unix sockets are limited in
size to /proc/sys/net/core/wmem_max, so send the 1MB
debug buffer in smaller chunks to avoid EMSGSIZE.

Also look for EAGAIN and retry sending for a limited
time when the reader is slower than the writer.

Also shift the location of that code so it's the same
as other requests.
---
 daemons/lvmlockd/lvmlockctl.c    |    9 +++-
 daemons/lvmlockd/lvmlockd-core.c |  114 ++++++++++++++++++++++++++------------
 2 files changed, 86 insertions(+), 37 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockctl.c b/daemons/lvmlockd/lvmlockctl.c
index e2ad9c5..14be4fc 100644
--- a/daemons/lvmlockd/lvmlockctl.c
+++ b/daemons/lvmlockd/lvmlockctl.c
@@ -379,6 +379,7 @@ static int setup_dump_socket(void)
 
 	rv = bind(s, (struct sockaddr *) &dump_addr, dump_addrlen);
 	if (rv < 0) {
+		rv = -errno;
 		if (!close(s))
 			log_error("failed to close dump socket");
 		return rv;
@@ -392,6 +393,7 @@ static int do_dump(const char *req_name)
 	daemon_reply reply;
 	int result;
 	int fd, rv = 0;
+	int count = 0;
 
 	fd = setup_dump_socket();
 	if (fd < 0) {
@@ -422,13 +424,18 @@ static int do_dump(const char *req_name)
 
 	memset(dump_buf, 0, sizeof(dump_buf));
 
-	rv = recvfrom(fd, dump_buf, dump_len, MSG_WAITALL,
+retry:
+	rv = recvfrom(fd, dump_buf + count, dump_len - count, MSG_WAITALL,
 		      (struct sockaddr *)&dump_addr, &dump_addrlen);
 	if (rv < 0) {
 		log_error("recvfrom error %d %d", rv, errno);
 		rv = -errno;
 		goto out;
 	}
+	count += rv;
+
+	if (count < dump_len)
+		goto retry;
 
 	rv = 0;
 	if ((info && dump) || !strcmp(req_name, "dump"))
diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index 666f340..b99cb0b 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -265,6 +265,10 @@ static int alloc_new_structs; /* used for initializing in setup_structs */
 static int add_lock_action(struct action *act);
 static int str_to_lm(const char *str);
 static int clear_lockspace_inactive(char *name);
+static int setup_dump_socket(void);
+static void send_dump_buf(int fd, int dump_len);
+static int dump_info(int *dump_len);
+static int dump_log(int *dump_len);
 
 static int _syslog_name_to_num(const char *name)
 {
@@ -739,6 +743,10 @@ static const char *op_str(int x)
 		return "kill_vg";
 	case LD_OP_DROP_VG:
 		return "drop_vg";
+	case LD_OP_DUMP_LOG:
+		return "dump_log";
+	case LD_OP_DUMP_INFO:
+		return "dump_info";
 	default:
 		return "op_unknown";
 	};
@@ -3414,6 +3422,8 @@ static void client_send_result(struct client *cl, struct action *act)
 {
 	response res;
 	char result_flags[128];
+	int dump_len = 0;
+	int dump_fd = -1;
 
 	if (cl->dead) {
 		log_debug("client send %d skip dead", cl->id);
@@ -3498,6 +3508,33 @@ static void client_send_result(struct client *cl, struct action *act)
 					  "lv_lock_args = %s", lv_args,
 					  "result_flags = %s", result_flags[0] ? result_flags : "none",
 					  NULL);
+
+	} else if (act->op == LD_OP_DUMP_LOG || act->op == LD_OP_DUMP_INFO) {
+		/*
+		 * lvmlockctl creates the unix socket then asks us to write to it.
+		 * FIXME: move processing this to a new dedicated query thread to
+		 * avoid having a large data dump interfere with normal operation
+		 * of the client thread?
+		 */
+
+		dump_fd = setup_dump_socket();
+		if (dump_fd < 0)
+			act->result = dump_fd;
+		else if (act->op == LD_OP_DUMP_LOG)
+			act->result = dump_log(&dump_len);
+		else if (act->op == LD_OP_DUMP_INFO)
+			act->result = dump_info(&dump_len);
+		else
+			act->result = -EINVAL;
+
+		log_debug("send %s[%d.%u] dump result %d dump_len %d",
+			  cl->name[0] ? cl->name : "client", cl->pid, cl->id,
+			  act->result, dump_len);
+
+		res = daemon_reply_simple("OK",
+					  "result = %d", act->result,
+					  "dump_len = %d", dump_len,
+					  NULL);
 	} else {
 		/*
 		 * A normal reply.
@@ -3521,6 +3558,12 @@ static void client_send_result(struct client *cl, struct action *act)
 	buffer_destroy(&res.buffer);
 
 	client_resume(cl);
+
+	if (dump_fd >= 0) {
+		/* To avoid deadlock, send data here after the reply. */
+		send_dump_buf(dump_fd, dump_len);
+		close(dump_fd);
+	}
 }
 
 /* called from client_thread */
@@ -3894,23 +3937,43 @@ static int setup_dump_socket(void)
 	return s;
 }
 
-static int send_dump_buf(int fd, int dump_len)
+#define MAX_SEND_LEN 65536
+#define RESEND_DELAY_US 1000
+#define RESEND_DELAY_US_MAX 500000
+
+static void send_dump_buf(int fd, int dump_len)
 {
 	int pos = 0;
 	int ret;
+	int send_len;
+	int delay = 0;
 
-retry:
-	ret = sendto(fd, dump_buf + pos, dump_len - pos, MSG_DONTWAIT | MSG_NOSIGNAL,
+	if (!dump_len)
+		return;
+repeat:
+	if (dump_len - pos < MAX_SEND_LEN)
+		send_len = dump_len - pos;
+	else
+		send_len = MAX_SEND_LEN;
+
+	ret = sendto(fd, dump_buf + pos, send_len, MSG_NOSIGNAL | MSG_DONTWAIT,
 		     (struct sockaddr *)&dump_addr, dump_addrlen);
-	if (ret <= 0)
-		return ret;
+	if (ret < 0) {
+		if ((errno == EAGAIN || errno == EINTR) && (delay < RESEND_DELAY_US_MAX)) {
+			usleep(RESEND_DELAY_US);
+			delay += RESEND_DELAY_US;
+			goto repeat;
+		}
+		log_error("send_dump_buf delay %d errno %d", delay, errno);
+		return;
+	}
 
 	pos += ret;
 
 	if (pos < dump_len)
-		goto retry;
+		goto repeat;
 
-	return 0;
+	log_debug("send_dump_buf delay %d total %d", delay, pos);
 }
 
 static int print_structs(const char *prefix, int pos, int len)
@@ -4193,8 +4256,7 @@ static void client_recv_action(struct client *cl)
 		return;
 	}
 
-	if (op == LD_OP_HELLO || op == LD_OP_QUIT ||
-	    op == LD_OP_DUMP_INFO || op == LD_OP_DUMP_LOG) {
+	if (op == LD_OP_HELLO || op == LD_OP_QUIT) {
 
 		/*
 		 * FIXME: add the client command name to the hello messages
@@ -4215,37 +4277,11 @@ static void client_recv_action(struct client *cl)
 
 		buffer_init(&res.buffer);
 
-		if (op == LD_OP_DUMP_INFO || op == LD_OP_DUMP_LOG) {
-			int dump_len = 0;
-			int fd;
-
-			fd = setup_dump_socket();
-			if (fd < 0)
-				result = fd;
-			else if (op == LD_OP_DUMP_INFO)
-				result = dump_info(&dump_len);
-			else if (op == LD_OP_DUMP_LOG)
-				result = dump_log(&dump_len);
-			else
-				result = -EINVAL;
-
-			res = daemon_reply_simple("OK",
-					  "result = %d", result,
-					  "dump_len = %d", dump_len,
-					  NULL);
-			if (fd >= 0) {
-				send_dump_buf(fd, dump_len);
-				close(fd);
-			}
-
-		} else {
-			res = daemon_reply_simple("OK",
+		res = daemon_reply_simple("OK",
 					  "result = %d", result,
 					  "protocol = %s", lvmlockd_protocol,
 					  "version = %d", lvmlockd_protocol_version,
 					  NULL);
-		}
-
 		buffer_write(cl->fd, &res.buffer);
 		buffer_destroy(&res.buffer);
 		dm_config_destroy(req.cft);
@@ -4362,6 +4398,12 @@ static void client_recv_action(struct client *cl)
 	case LD_OP_STOP:
 		rv = rem_lockspace(act);
 		break;
+	case LD_OP_DUMP_LOG:
+	case LD_OP_DUMP_INFO:
+		/* The client thread reply will copy and send the dump. */
+		add_client_result(act);
+		rv = 0;
+		break;
 	case LD_OP_INIT:
 	case LD_OP_START_WAIT:
 	case LD_OP_STOP_ALL:


