From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 21 Mar 2014 21:31:40 +0000 (UTC)
Subject: master - clvmd: use dm_malloc
Message-ID: <20140321213140.2CF7860F20@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=28479946249611f7f103c1caa33033a92ea0ce49
Commit:        28479946249611f7f103c1caa33033a92ea0ce49
Parent:        c45cd6eb8d0272b6700d0b0c6f2baa82fe67f37d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 20 09:24:45 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 21 22:29:24 2014 +0100

clvmd: use dm_malloc

Use libdm malloc wrapper functions.
---
 daemons/clvmd/clvmd-openais.c |    4 +--
 daemons/clvmd/clvmd.c         |   72 +++++++++++++++++-----------------------
 2 files changed, 32 insertions(+), 44 deletions(-)

diff --git a/daemons/clvmd/clvmd-openais.c b/daemons/clvmd/clvmd-openais.c
index 9ce73d6..77c0482 100644
--- a/daemons/clvmd/clvmd-openais.c
+++ b/daemons/clvmd/clvmd-openais.c
@@ -197,9 +197,7 @@ static int add_internal_client(int fd, fd_callback_t callback)
 
 	DEBUGLOG("Add_internal_client, fd = %d\n", fd);
 
-	client = calloc(1, sizeof(struct local_client));
-	if (!client)
-	{
+	if (!(client = dm_zalloc(sizeof(*client)))) {
 		DEBUGLOG("malloc failed\n");
 		return -1;
 	}
diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index 3890347..ba3fc84 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -677,7 +677,7 @@ static int local_rendezvous_callback(struct local_client *thisfd, char *buf,
 		return 1;
 
 	if (client_fd >= 0) {
-		if (!(newfd = dm_zalloc(sizeof(struct local_client)))) {
+		if (!(newfd = dm_zalloc(sizeof(*newfd)))) {
 			if (close(client_fd))
                                 log_sys_error("close", "socket");
 			return 1;
@@ -1212,7 +1212,7 @@ static int cleanup_zombie(struct local_client *thisfd)
 					lastfd->next = newfd->next;
 					free_fd = newfd;
 					newfd->next = lastfd;
-					free(free_fd);
+					dm_free(free_fd);
 					break;
 				}
 				lastfd = newfd;
@@ -1221,7 +1221,7 @@ static int cleanup_zombie(struct local_client *thisfd)
 	}
 
 	/* Free the command buffer */
-	free(thisfd->bits.localsock.cmd);
+	dm_free(thisfd->bits.localsock.cmd);
 
 	/* Clear out the cross-link */
 	if (thisfd->bits.localsock.pipe_client != NULL)
@@ -1312,12 +1312,10 @@ static int read_from_local_sock(struct local_client *thisfd)
 		}
 
 		/* Free any old buffer space */
-		free(thisfd->bits.localsock.cmd);
+		dm_free(thisfd->bits.localsock.cmd);
 
 		/* Save the message */
-		thisfd->bits.localsock.cmd = malloc(len + missing_len);
-
-		if (!thisfd->bits.localsock.cmd) {
+		if (!(thisfd->bits.localsock.cmd = dm_malloc(len + missing_len))) {
 			struct clvm_header reply = {
 				.cmd = CLVMD_CMD_REPLY,
 				.status = ENOMEM
@@ -1349,7 +1347,7 @@ static int read_from_local_sock(struct local_client *thisfd)
 				} else {
 					/* EOF or error on socket */
 					DEBUGLOG("EOF on local socket\n");
-					free(thisfd->bits.localsock.cmd);
+					dm_free(thisfd->bits.localsock.cmd);
 					thisfd->bits.localsock.cmd = NULL;
 					return 0;
 				}
@@ -1415,8 +1413,7 @@ static int read_from_local_sock(struct local_client *thisfd)
 			return len;
 		}
 
-		newfd = malloc(sizeof(struct local_client));
-		if (!newfd) {
+		if (!(newfd = dm_malloc(sizeof(*newfd)))) {
 			struct clvm_header reply = {
 				.cmd = CLVMD_CMD_REPLY,
 				.status = ENOMEM
@@ -1616,14 +1613,12 @@ static void process_remote_command(struct clvm_header *msg, int msglen, int fd,
 	}
 
 	/* Allocate a default reply buffer */
-	replyargs = malloc(max_cluster_message - sizeof(struct clvm_header));
-
-	if (replyargs != NULL) {
+	if ((replyargs = dm_malloc(max_cluster_message - sizeof(struct clvm_header))))
 		/* Run the command */
 		/* FIXME: usage of init_test() is unprotected */
 		status = do_command(NULL, msg, msglen, &replyargs,
 				    buflen, &replylen);
-	} else {
+	else {
 		status = ENOMEM;
 	}
 
@@ -1631,8 +1626,7 @@ static void process_remote_command(struct clvm_header *msg, int msglen, int fd,
 	if (msg->cmd != CLVMD_CMD_REPLY) {
 		char *aggreply;
 
-		aggreply =
-		    realloc(replyargs, replylen + sizeof(struct clvm_header));
+		aggreply = dm_realloc(replyargs, replylen + sizeof(struct clvm_header));
 		if (aggreply) {
 			struct clvm_header *agghead =
 			    (struct clvm_header *) aggreply;
@@ -1670,7 +1664,7 @@ static void process_remote_command(struct clvm_header *msg, int msglen, int fd,
 		}
 	}
 
-	free(replyargs);
+	dm_free(replyargs);
 }
 
 /* Add a reply to a command to the list of replies for this client.
@@ -1684,17 +1678,15 @@ static void add_reply_to_list(struct local_client *client, int status,
 	pthread_mutex_lock(&client->bits.localsock.reply_mutex);
 
 	/* Add it to the list of replies */
-	reply = malloc(sizeof(struct node_reply));
-	if (reply) {
+	if ((reply = dm_malloc(sizeof(*reply)))) {
 		reply->status = status;
 		clops->name_from_csid(csid, reply->node);
 		DEBUGLOG("Reply from node %s: %d bytes\n", reply->node, len);
 
 		if (len > 0) {
-			reply->replymsg = malloc(len);
-			if (!reply->replymsg) {
+			if (!(reply->replymsg = dm_malloc(len)))
 				reply->status = ENOMEM;
-			} else {
+			else {
 				memcpy(reply->replymsg, buf, len);
 			}
 		} else {
@@ -1811,17 +1803,17 @@ static int process_local_command(struct clvm_header *msg, int msglen,
 				 struct local_client *client,
 				 unsigned short xid)
 {
-	char *replybuf = malloc(max_cluster_message);
+	char *replybuf;
 	int buflen = max_cluster_message - sizeof(struct clvm_header) - 1;
 	int replylen = 0;
 	int status;
 
+	if (!(replybuf = dm_malloc(max_cluster_message)))
+		return -1;
+
 	DEBUGLOG("process_local_command: %s msg=%p, msglen =%d, client=%p\n",
 		 decode_cmd(msg->cmd), msg, msglen, client);
 
-	if (!replybuf)
-		return -1;
-
 	/* If remote flag is set, just set a successful status code. */
 	if (msg->flags & CLVMD_FLAG_REMOTE)
 		status = 0;
@@ -1839,7 +1831,7 @@ static int process_local_command(struct clvm_header *msg, int msglen,
 		DEBUGLOG("Local command took too long, discarding xid %d, current is %d\n",
 			 xid, client->xid);
 
-	free(replybuf);
+	dm_free(replybuf);
 
 	return status;
 }
@@ -1895,7 +1887,7 @@ static void send_local_reply(struct local_client *client, int status, int fd)
 
 	/* Add in the size of our header */
 	message_len = message_len + sizeof(struct clvm_header);
-	if (!(replybuf = malloc(message_len))) {
+	if (!(replybuf = dm_malloc(message_len))) {
 		DEBUGLOG("Memory allocation fails\n");
 		return;
 	}
@@ -1933,8 +1925,8 @@ static void send_local_reply(struct local_client *client, int status, int fd)
 		}
 		thisreply = thisreply->next;
 
-		free(tempreply->replymsg);
-		free(tempreply);
+		dm_free(tempreply->replymsg);
+		dm_free(tempreply);
 	}
 
 	/* Terminate with an empty node name */
@@ -1945,7 +1937,7 @@ static void send_local_reply(struct local_client *client, int status, int fd)
 	/* And send it */
 	send_message(replybuf, message_len, our_csid, fd,
 		     "Error sending REPLY to client");
-	free(replybuf);
+	dm_free(replybuf);
 
 	/* Reset comms variables */
 	client->bits.localsock.replies = NULL;
@@ -1964,8 +1956,8 @@ static void free_reply(struct local_client *client)
 
 		thisreply = thisreply->next;
 
-		free(tempreply->replymsg);
-		free(tempreply);
+		dm_free(tempreply->replymsg);
+		dm_free(tempreply);
 	}
 	client->bits.localsock.replies = NULL;
 }
@@ -2040,7 +2032,7 @@ static int process_work_item(struct lvm_thread_cmd *cmd)
 	if (cmd->msg == NULL) {
 		DEBUGLOG("process_work_item: free fd %d\n", cmd->client->fd);
 		cmd_client_cleanup(cmd->client);
-		free(cmd->client);
+		dm_free(cmd->client);
 		return 0;
 	}
 
@@ -2094,8 +2086,8 @@ static void *lvm_thread_fn(void *arg)
 			pthread_mutex_unlock(&lvm_thread_mutex);
 
 			process_work_item(cmd);
-			free(cmd->msg);
-			free(cmd);
+			dm_free(cmd->msg);
+			dm_free(cmd);
 
 			pthread_mutex_lock(&lvm_thread_mutex);
 		}
@@ -2116,15 +2108,13 @@ static int add_to_lvmqueue(struct local_client *client, struct clvm_header *msg,
 	if (lvm_thread_exit)
 		return -1; /* We are about to exit */
 
-	cmd = malloc(sizeof(struct lvm_thread_cmd));
-	if (!cmd)
+	if (!(cmd = dm_malloc(sizeof(*cmd))))
 		return ENOMEM;
 
 	if (msglen) {
-		cmd->msg = malloc(msglen);
-		if (!cmd->msg) {
+		if (!(cmd->msg = dm_malloc(msglen))) {
 			log_error("Unable to allocate buffer space\n");
-			free(cmd);
+			dm_free(cmd);
 			return -1;
 		}
 		memcpy(cmd->msg, msg, msglen);


