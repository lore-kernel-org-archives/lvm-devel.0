From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 10 Mar 2014 11:27:08 +0000 (UTC)
Subject: master - cleanup: clvmd indent changes
Message-ID: <20140310112708.E5FEA603FB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c824369fbdd93011a1daccbb7159d16f365dce50
Commit:        c824369fbdd93011a1daccbb7159d16f365dce50
Parent:        109564d6a50eaf3ece1bf38a6422dc2d2f642cf7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 10 12:15:26 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 10 12:24:09 2014 +0100

cleanup: clvmd indent changes

Improve readbility of clvmd code.
Remove some unneeded braces.
---
 daemons/clvmd/clvmd-command.c |    1 -
 daemons/clvmd/clvmd.c         |   80 ++++++++++++++++++----------------------
 2 files changed, 36 insertions(+), 45 deletions(-)

diff --git a/daemons/clvmd/clvmd-command.c b/daemons/clvmd/clvmd-command.c
index 1ed1513..96eec92 100644
--- a/daemons/clvmd/clvmd-command.c
+++ b/daemons/clvmd/clvmd-command.c
@@ -183,7 +183,6 @@ int do_command(struct local_client *client, struct clvm_header *msg, int msglen,
 	}
 
 	return status;
-
 }
 
 static int lock_vg(struct local_client *client)
diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index 9ee5998..c319013 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -526,7 +526,8 @@ int main(int argc, char *argv[])
 		cluster_iface = get_cluster_type();
 
 #ifdef USE_CMAN
-	if ((cluster_iface == IF_AUTO || cluster_iface == IF_CMAN) && (clops = init_cman_cluster())) {
+	if ((cluster_iface == IF_AUTO || cluster_iface == IF_CMAN) &&
+	    (clops = init_cman_cluster())) {
 		max_csid_len = CMAN_MAX_CSID_LEN;
 		max_cluster_message = CMAN_MAX_CLUSTER_MESSAGE;
 		max_cluster_member_name_len = CMAN_MAX_NODENAME_LEN;
@@ -535,7 +536,8 @@ int main(int argc, char *argv[])
 #endif
 #ifdef USE_COROSYNC
 	if (!clops)
-		if (((cluster_iface == IF_AUTO || cluster_iface == IF_COROSYNC) && (clops = init_corosync_cluster()))) {
+		if (((cluster_iface == IF_AUTO || cluster_iface == IF_COROSYNC) &&
+		     (clops = init_corosync_cluster()))) {
 			max_csid_len = COROSYNC_CSID_LEN;
 			max_cluster_message = COROSYNC_MAX_CLUSTER_MESSAGE;
 			max_cluster_member_name_len = COROSYNC_MAX_CLUSTER_MEMBER_NAME_LEN;
@@ -544,7 +546,8 @@ int main(int argc, char *argv[])
 #endif
 #ifdef USE_OPENAIS
 	if (!clops)
-		if ((cluster_iface == IF_AUTO || cluster_iface == IF_OPENAIS) && (clops = init_openais_cluster())) {
+		if ((cluster_iface == IF_AUTO || cluster_iface == IF_OPENAIS) &&
+		    (clops = init_openais_cluster())) {
 			max_csid_len = OPENAIS_CSID_LEN;
 			max_cluster_message = OPENAIS_MAX_CLUSTER_MESSAGE;
 			max_cluster_member_name_len = OPENAIS_MAX_CLUSTER_MEMBER_NAME_LEN;
@@ -708,9 +711,8 @@ static int local_pipe_callback(struct local_client *thisfd, char *buf,
 	if (len == -1 && errno == EINTR)
 		return 1;
 
-	if (len == sizeof(int)) {
+	if (len == sizeof(int))
 		memcpy(&status, buffer, sizeof(int));
-	}
 
 	DEBUGLOG("read on PIPE %d: %d bytes: status: %d\n",
 		 thisfd->fd, len, status);
@@ -728,21 +730,19 @@ static int local_pipe_callback(struct local_client *thisfd, char *buf,
 
 		/* Reap child thread */
 		if (thisfd->bits.pipe.threadid) {
-			if ((errno = pthread_join(thisfd->bits.pipe.threadid,
-						  &ret)))
+			if ((errno = pthread_join(thisfd->bits.pipe.threadid, &ret)))
 				log_sys_error("pthread_join", "");
 
 			thisfd->bits.pipe.threadid = 0;
-			if (thisfd->bits.pipe.client != NULL)
-				thisfd->bits.pipe.client->bits.localsock.
-				    threadid = 0;
+			if (thisfd->bits.pipe.client)
+				thisfd->bits.pipe.client->bits.localsock.threadid = 0;
 		}
 		return -1;
 	} else {
 		DEBUGLOG("background routine status was %d, sock_client=%p\n",
 			 status, sock_client);
 		/* But has the client gone away ?? */
-		if (sock_client == NULL) {
+		if (!sock_client) {
 			DEBUGLOG("Got PIPE response for dead client, ignoring it\n");
 		} else {
 			/* If error then just return that code */
@@ -785,9 +785,8 @@ static void timedout_callback(struct local_client *client, const char *csid,
 		pthread_mutex_lock(&client->bits.localsock.reply_mutex);
 
 		reply = client->bits.localsock.replies;
-		while (reply && strcmp(reply->node, nodename) != 0) {
+		while (reply && strcmp(reply->node, nodename) != 0)
 			reply = reply->next;
-		}
 
 		pthread_mutex_unlock(&client->bits.localsock.reply_mutex);
 
@@ -942,10 +941,8 @@ static void main_loop(int local_sock, int cmd_timeout)
 				    expected_replies !=
 				    thisfd->bits.localsock.num_replies) {
 					/* Send timed out message + replies we already have */
-					DEBUGLOG
-					    ("Request timed-out (send: %ld, now: %ld)\n",
-					     thisfd->bits.localsock.sent_time,
-					     the_time);
+					DEBUGLOG("Request timed-out (send: %ld, now: %ld)\n",
+						 thisfd->bits.localsock.sent_time, the_time);
 
 					thisfd->bits.localsock.all_success = 0;
 
@@ -1106,7 +1103,7 @@ static int verify_message(char *buf, int len)
 	default:
 		log_error("verify_message bad cmd %x", h->cmd);
 		return -1;
-	};
+	}
 
 	/* TODO: we may be able to narrow len/flags/clientid/arglen checks based on cmd */
 
@@ -1127,12 +1124,11 @@ static void dump_message(char *buf, int len)
 {
 	unsigned char row[8];
 	char str[9];
-	int i, j, pos;
+	int i, j, pos = 0;
 
 	if (len > 128)
 		len = 128;
 
-	pos = 0;
 	memset(row, 0, sizeof(row));
 
 	for (i = 0; i < len; i++) {
@@ -1476,6 +1472,7 @@ static int read_from_local_sock(struct local_client *thisfd)
 					&stack_attr, pre_and_post_thread, thisfd);
 		DEBUGLOG("Created pre&post thread, state = %d\n", status);
 	}
+
 	return len;
 }
 
@@ -1560,6 +1557,7 @@ static int distribute_command(struct local_client *thisfd)
 		thisfd->bits.localsock.num_replies = 0;
 		add_to_lvmqueue(thisfd, inheader, len, NULL);
 	}
+
 	return 0;
 }
 
@@ -1763,9 +1761,7 @@ static __attribute__ ((noreturn)) void *pre_and_post_thread(void *arg)
 	while (!client->bits.localsock.finished) {
 		/* Execute the code */
 		/* FIXME: usage of init_test() is unprotected as in do_command() */
-		status = do_pre_command(client);
-
-		if (status)
+		if ((status = do_pre_command(client)))
 			client->bits.localsock.all_success = 0;
 
 		DEBUGLOG("Writing status %d down pipe %d\n", status, pipe_fd);
@@ -1787,10 +1783,9 @@ static __attribute__ ((noreturn)) void *pre_and_post_thread(void *arg)
 			 client->bits.localsock.state);
 
 		if (client->bits.localsock.state != POST_COMMAND &&
-		    !client->bits.localsock.finished) {
+		    !client->bits.localsock.finished)
 			pthread_cond_wait(&client->bits.localsock.cond,
 					  &client->bits.localsock.mutex);
-		}
 
 		DEBUGLOG("Got post command condition...\n");
 
@@ -1832,7 +1827,7 @@ static int process_local_command(struct clvm_header *msg, int msglen,
 	DEBUGLOG("process_local_command: %s msg=%p, msglen =%d, client=%p\n",
 		 decode_cmd(msg->cmd), msg, msglen, client);
 
-	if (replybuf == NULL)
+	if (!replybuf)
 		return -1;
 
 	/* If remote flag is set, just set a successful status code. */
@@ -1846,24 +1841,22 @@ static int process_local_command(struct clvm_header *msg, int msglen,
 		client->bits.localsock.all_success = 0;
 
 	/* If we took too long then discard the reply */
-	if (xid == client->xid) {
+	if (xid == client->xid)
 		add_reply_to_list(client, status, our_csid, replybuf, replylen);
-	} else {
-		DEBUGLOG
-		    ("Local command took too long, discarding xid %d, current is %d\n",
-		     xid, client->xid);
-	}
+	else
+		DEBUGLOG("Local command took too long, discarding xid %d, current is %d\n",
+			 xid, client->xid);
 
 	free(replybuf);
+
 	return status;
 }
 
 static int process_reply(const struct clvm_header *msg, int msglen, const char *csid)
 {
-	struct local_client *client = NULL;
+	struct local_client *client;
 
-	client = find_client(msg->clientid);
-	if (!client) {
+	if (!(client = find_client(msg->clientid))) {
 		DEBUGLOG("Got message for unknown client 0x%x\n",
 			 msg->clientid);
 		log_error("Got message for unknown client 0x%x\n",
@@ -1875,13 +1868,13 @@ static int process_reply(const struct clvm_header *msg, int msglen, const char *
 		client->bits.localsock.all_success = 0;
 
 	/* Gather replies together for this client id */
-	if (msg->xid == client->xid) {
+	if (msg->xid == client->xid)
 		add_reply_to_list(client, msg->status, csid, msg->args,
 				  msg->arglen);
-	} else {
+	else
 		DEBUGLOG("Discarding reply with old XID %d, current = %d\n",
 			 msg->xid, client->xid);
-	}
+
 	return 0;
 }
 
@@ -2007,7 +2000,7 @@ static void send_version_message(void)
 	hton_clvm(msg);
 
 	clops->cluster_send_message(message, sizeof(message), NULL,
-			     "Error Sending version number");
+				    "Error Sending version number");
 }
 
 /* Send a message to either a local client or another server */
@@ -2018,11 +2011,10 @@ static int send_message(void *buf, int msglen, const char *csid, int fd,
 	int ptr;
 	struct timespec delay;
 	struct timespec remtime;
-
 	int retry_cnt = 0;
 
 	/* Send remote messages down the cluster socket */
-	if (csid == NULL || !ISLOCAL_CSID(csid)) {
+	if (!csid || !ISLOCAL_CSID(csid)) {
 		hton_clvm((struct clvm_header *) buf);
 		return clops->cluster_send_message(buf, msglen, csid, errtext);
 	}
@@ -2046,6 +2038,7 @@ static int send_message(void *buf, int msglen, const char *csid, int fd,
 		}
 		ptr += len;
 	}
+
 	return len;
 }
 
@@ -2154,9 +2147,8 @@ static int add_to_lvmqueue(struct local_client *client, struct clvm_header *msg,
 		cmd->remote = 0;
 	}
 
-	DEBUGLOG
-	    ("add_to_lvmqueue: cmd=%p. client=%p, msg=%p, len=%d, csid=%p, xid=%d\n",
-	     cmd, client, msg, msglen, csid, cmd->xid);
+	DEBUGLOG("add_to_lvmqueue: cmd=%p. client=%p, msg=%p, len=%d, csid=%p, xid=%d\n",
+		 cmd, client, msg, msglen, csid, cmd->xid);
 	pthread_mutex_lock(&lvm_thread_mutex);
 	dm_list_add(&lvm_cmd_head, &cmd->list);
 	pthread_cond_signal(&lvm_thread_cond);


