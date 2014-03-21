From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 21 Mar 2014 21:31:58 +0000 (UTC)
Subject: master - cleanup: clvmd update log_error
Message-ID: <20140321213158.E087E60F05@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f8cd435cd83140e26d35e17f6fbccc1019f67aed
Commit:        f8cd435cd83140e26d35e17f6fbccc1019f67aed
Parent:        4c97ea2ce55134735896967e719db955c9e74161
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 20 09:21:34 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 21 22:29:26 2014 +0100

cleanup: clvmd update log_error

Drop \n from log_error() and add '.'
---
 daemons/clvmd/clvmd.c |   22 +++++++++++-----------
 1 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index 9af528c..bc831d0 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -567,7 +567,7 @@ int main(int argc, char *argv[])
 
 	if (!clops) {
 		DEBUGLOG("Can't initialise cluster interface\n");
-		log_error("Can't initialise cluster interface\n");
+		log_error("Can't initialise cluster interface.");
 		child_init_signal_and_exit(DFAIL_CLUSTER_IF);
 		/* NOTREACHED */
 	}
@@ -1077,7 +1077,7 @@ static int verify_message(char *buf, int len)
 	struct clvm_header *h = (struct clvm_header *)buf;
 
 	if (len < (int)sizeof(struct clvm_header)) {
-		log_error("verify_message short len %d", len);
+		log_error("verify_message short len %d.", len);
 		return -1;
 	}
 
@@ -1099,19 +1099,19 @@ static int verify_message(char *buf, int len)
 	case CLVMD_CMD_SYNC_NAMES:
 		break;
 	default:
-		log_error("verify_message bad cmd %x", h->cmd);
+		log_error("verify_message bad cmd %x.", h->cmd);
 		return -1;
 	}
 
 	/* TODO: we may be able to narrow len/flags/clientid/arglen checks based on cmd */
 
 	if (h->flags & ~(CLVMD_FLAG_LOCAL | CLVMD_FLAG_SYSTEMLV | CLVMD_FLAG_NODEERRS | CLVMD_FLAG_REMOTE)) {
-		log_error("verify_message bad flags %x", h->flags);
+		log_error("verify_message bad flags %x.", h->flags);
 		return -1;
 	}
 
 	if (h->arglen > max_cluster_message) {
-		log_error("verify_message bad arglen %x max %d", h->arglen, max_cluster_message);
+		log_error("verify_message bad arglen %x max %d.", h->arglen, max_cluster_message);
 		return -1;
 	}
 
@@ -1565,7 +1565,7 @@ static void process_remote_command(struct clvm_header *msg, int msglen, int fd,
 	if (msg->cmd == CLVMD_CMD_GOAWAY) {
 
 		DEBUGLOG("Told to go away by %s\n", nodename);
-		log_error("Told to go away by %s\n", nodename);
+		log_error("Told to go away by %s.", nodename);
 		exit(99);
 	}
 
@@ -1745,7 +1745,7 @@ static __attribute__ ((noreturn)) void *pre_and_post_thread(void *arg)
 		/* Tell the parent process we have finished this bit */
 		while ((write_status = write(pipe_fd, &status, sizeof(int))) != sizeof(int))
 			if (write_status >=0 || (errno != EINTR && errno != EAGAIN)) {
-				log_error("Error sending to pipe: %m\n");
+				log_error("Error sending to pipe: %m");
 				break;
 			}
 
@@ -1771,7 +1771,7 @@ static __attribute__ ((noreturn)) void *pre_and_post_thread(void *arg)
 
 		while ((write_status = write(pipe_fd, &status, sizeof(int))) != sizeof(int))
 			if (write_status >=0 || (errno != EINTR && errno != EAGAIN)) {
-				log_error("Error sending to pipe: %m\n");
+				log_error("Error sending to pipe: %m");
 				break;
 			}
 next_pre:
@@ -1835,7 +1835,7 @@ static int process_reply(const struct clvm_header *msg, int msglen, const char *
 	if (!(client = find_client(msg->clientid))) {
 		DEBUGLOG("Got message for unknown client 0x%x\n",
 			 msg->clientid);
-		log_error("Got message for unknown client 0x%x\n",
+		log_error("Got message for unknown client 0x%x.",
 			  msg->clientid);
 		return -1;
 	}
@@ -2105,7 +2105,7 @@ static int add_to_lvmqueue(struct local_client *client, struct clvm_header *msg,
 
 	if (msglen) {
 		if (!(cmd->msg = dm_malloc(msglen))) {
-			log_error("Unable to allocate buffer space\n");
+			log_error("Unable to allocate buffer space.");
 			dm_free(cmd);
 			return -1;
 		}
@@ -2238,7 +2238,7 @@ void process_message(struct local_client *client, char *buf, int len,
 	if (rv < 0) {
 		memset(nodename, 0, sizeof(nodename));
 		clops->name_from_csid(csid, nodename);
-		log_error("process_message from %s len %d bad verify", nodename, len);
+		log_error("process_message from %s len %d bad verify.", nodename, len);
 		dump_message(buf, len);
 		return;
 	}


