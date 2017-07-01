From: Alasdair Kergon <agk@sourceware.org>
Date: Fri, 30 Jun 2017 21:00:35 -0400
Subject: master - clvmd: add client id to debug log messages
Message-ID: <201707010100.v6110Zuj029605@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=af789fd6d0cba45cc4897772bae3ca73a3f15b38
Commit:        af789fd6d0cba45cc4897772bae3ca73a3f15b38
Parent:        17ed25409136162d091809d412596a45e0a30fd4
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Sat Jul 1 01:17:40 2017 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Sat Jul 1 01:17:40 2017 +0100

clvmd: add client id to debug log messages

Use standard format to make it easier to find the client to which each
debug log message refers.
---
 WHATS_NEW                     |    2 +-
 daemons/clvmd/clvmd-command.c |    6 +-
 daemons/clvmd/clvmd.c         |  120 +++++++++++++++++++++--------------------
 3 files changed, 65 insertions(+), 63 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 3f496fe..29f07b8 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,6 +1,6 @@
 Version 2.02.173 - 
 =================================
-  Protect clvmd debug log messages with mutex.
+  Protect clvmd debug log messages with mutex and add client id.
   Fix shellcheck reported issues for script files.
 
 Version 2.02.172 - 28th June 2017
diff --git a/daemons/clvmd/clvmd-command.c b/daemons/clvmd/clvmd-command.c
index 0593f6f..cf19dc2 100644
--- a/daemons/clvmd/clvmd-command.c
+++ b/daemons/clvmd/clvmd-command.c
@@ -206,7 +206,7 @@ static int lock_vg(struct local_client *client)
 	lock_mode = ((int) lock_cmd & LCK_TYPE_MASK);
 	/* lock_flags = args[1]; */
 	lockname = &args[2];
-	DEBUGLOG("doing PRE command LOCK_VG '%s' at %x (client=%p)\n", lockname, lock_cmd, client);
+	DEBUGLOG("(%p) doing PRE command LOCK_VG '%s' at %x\n", client, lockname, lock_cmd);
 
 	if (lock_mode == LCK_UNLOCK) {
 		if (!(lkid = (int) (long) dm_hash_lookup(lock_hash, lockname)))
@@ -323,7 +323,7 @@ void cmd_client_cleanup(struct local_client *client)
 	int lkid;
 	char *lockname;
 
-	DEBUGLOG("Client thread cleanup (%p)\n", client);
+	DEBUGLOG("(%p) Client thread cleanup\n", client);
 	if (!client->bits.localsock.private)
 		return;
 
@@ -332,7 +332,7 @@ void cmd_client_cleanup(struct local_client *client)
 	dm_hash_iterate(v, lock_hash) {
 		lkid = (int)(long)dm_hash_get_data(lock_hash, v);
 		lockname = dm_hash_get_key(lock_hash, v);
-		DEBUGLOG("Cleanup (%p): Unlocking lock %s %x\n", client, lockname, lkid);
+		DEBUGLOG("(%p) Cleanup: Unlocking lock %s %x\n", client, lockname, lkid);
 		(void) sync_unlock(lockname, lkid);
 	}
 
diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index 0f96356..a8a121c 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -606,8 +606,8 @@ int main(int argc, char *argv[])
 	/* This needs to be started after cluster initialisation
 	   as it may need to take out locks */
 	DEBUGLOG("Starting LVM thread\n");
-	DEBUGLOG("Main cluster socket fd %d (%p) with local socket %d (%p)\n",
-		 local_client_head.fd, &local_client_head, newfd->fd, newfd);
+	DEBUGLOG("(%p) Main cluster socket fd %d with local socket %d (%p)\n",
+		 &local_client_head, local_client_head.fd, newfd->fd, newfd);
 
 	/* Don't let anyone else to do work until we are started */
 	if (pthread_create(&lvm_thread, &stack_attr, lvm_thread_fn, &lvm_params)) {
@@ -704,13 +704,13 @@ static int local_rendezvous_callback(struct local_client *thisfd, char *buf,
 		pthread_mutex_init(&newfd->bits.localsock.mutex, NULL);
 
 		if (fcntl(client_fd, F_SETFD, 1))
-			DEBUGLOG("Setting CLOEXEC on client fd failed: %s\n", strerror(errno));
+			DEBUGLOG("(%p) Setting CLOEXEC on client fd %d failed: %s\n", thisfd, client_fd, strerror(errno));
 
 		newfd->fd = client_fd;
 		newfd->type = LOCAL_SOCK;
 		newfd->callback = local_sock_callback;
 		newfd->bits.localsock.all_success = 1;
-		DEBUGLOG("Got new connection on fd %d (%p)\n", newfd->fd, newfd);
+		DEBUGLOG("(%p) Got new connection on fd %d\n", newfd, newfd->fd);
 		*new_client = newfd;
 	}
 	return 1;
@@ -732,8 +732,8 @@ static int local_pipe_callback(struct local_client *thisfd, char *buf,
 	if (len == sizeof(int))
 		memcpy(&status, buffer, sizeof(int));
 
-	DEBUGLOG("Read on pipe %d, %d bytes, status %d\n",
-		 thisfd->fd, len, status);
+	DEBUGLOG("(%p) Read on pipe %d, %d bytes, status %d\n",
+		 thisfd, thisfd->fd, len, status);
 
 	/* EOF on pipe or an error, close it */
 	if (len <= 0) {
@@ -756,11 +756,11 @@ static int local_pipe_callback(struct local_client *thisfd, char *buf,
 		}
 		return -1;
 	} else {
-		DEBUGLOG("Background routine status was %d, sock_client (%p)\n",
-			 status, sock_client);
+		DEBUGLOG("(%p) Background routine status was %d, sock_client %p\n",
+			 thisfd, status, sock_client);
 		/* But has the client gone away ?? */
 		if (!sock_client) {
-			DEBUGLOG("Got pipe response for dead client, ignoring it\n");
+			DEBUGLOG("(%p) Got pipe response for dead client, ignoring it\n", thisfd);
 		} else {
 			/* If error then just return that code */
 			if (status)
@@ -800,7 +800,7 @@ static void timedout_callback(struct local_client *client, const char *csid,
 		return;
 
 	clops->name_from_csid(csid, nodename);
-	DEBUGLOG("Checking for a reply from %s\n", nodename);
+	DEBUGLOG("(%p) Checking for a reply from %s\n", client, nodename);
 	pthread_mutex_lock(&client->bits.localsock.mutex);
 
 	reply = client->bits.localsock.replies;
@@ -810,7 +810,7 @@ static void timedout_callback(struct local_client *client, const char *csid,
 	pthread_mutex_unlock(&client->bits.localsock.mutex);
 
 	if (!reply) {
-		DEBUGLOG("Node %s timed-out\n", nodename);
+		DEBUGLOG("(%p) Node %s timed-out\n", client, nodename);
 		add_reply_to_list(client, ETIMEDOUT, csid,
 				  "Command timed out", 18);
 	}
@@ -825,7 +825,7 @@ static void timedout_callback(struct local_client *client, const char *csid,
 */
 static void request_timed_out(struct local_client *client)
 {
-	DEBUGLOG("Request timed-out. padding\n");
+	DEBUGLOG("(%p) Request timed-out. padding\n", client);
 	clops->cluster_do_node_callback(client, timedout_callback);
 
 	if (!client->bits.localsock.threadid)
@@ -886,7 +886,7 @@ static void main_loop(int cmd_timeout)
 			if (thisfd->removeme && !cleanup_zombie(thisfd)) {
 				struct local_client *free_fd = thisfd;
 				lastfd->next = nextfd;
-				DEBUGLOG("removeme set for %p with %d monitored fds remaining\n", free_fd, client_count - 1);
+				DEBUGLOG("(%p) removeme set with %d monitored fds remaining\n", thisfd, client_count - 1);
 
 				/* Queue cleanup, this also frees the client struct */
 				add_to_lvmqueue(free_fd, NULL, 0, NULL);
@@ -945,8 +945,8 @@ static void main_loop(int cmd_timeout)
 						    type == CLUSTER_INTERNAL)
 							goto closedown;
 
-						DEBUGLOG("ret == %d, errno = %d. removing client\n",
-							 ret, errno);
+						DEBUGLOG("(%p) ret == %d, errno = %d. removing client\n",
+							 thisfd, ret, errno);
 						thisfd->removeme = 1;
 						continue;
 					}
@@ -972,8 +972,8 @@ static void main_loop(int cmd_timeout)
 				    thisfd->bits.localsock.expected_replies !=
 				    thisfd->bits.localsock.num_replies) {
 					/* Send timed out message + replies we already have */
-					DEBUGLOG("Request timed-out (send: %ld, now: %ld)\n",
-						 thisfd->bits.localsock.sent_time, the_time);
+					DEBUGLOG("Request to client %p timed-out (send: %ld, now: %ld)\n",
+						 thisfd, thisfd->bits.localsock.sent_time, the_time);
 
 					thisfd->bits.localsock.all_success = 0;
 
@@ -1185,8 +1185,8 @@ static int cleanup_zombie(struct local_client *thisfd)
 	if (!thisfd->bits.localsock.cleanup_needed)
 		return 0;
 
-	DEBUGLOG("EOF on local socket: inprogress=%d\n",
-		 thisfd->bits.localsock.in_progress);
+	DEBUGLOG("(%p) EOF on local socket %d: inprogress=%d\n",
+		 thisfd, thisfd->fd, thisfd->bits.localsock.in_progress);
 
 	if ((pipe_client = thisfd->bits.localsock.pipe_client))
 		pipe_client = pipe_client->bits.pipe.client;
@@ -1208,7 +1208,7 @@ static int cleanup_zombie(struct local_client *thisfd)
 
 	/* Kill the subthread & free resources */
 	if (thisfd->bits.localsock.threadid) {
-		DEBUGLOG("Waiting for pre&post thread (%p)\n", pipe_client);
+		DEBUGLOG("(%p) Waiting for pre&post thread\n", pipe_client);
 		pthread_mutex_lock(&thisfd->bits.localsock.mutex);
 		thisfd->bits.localsock.state = PRE_COMMAND;
 		thisfd->bits.localsock.finished = 1;
@@ -1219,7 +1219,7 @@ static int cleanup_zombie(struct local_client *thisfd)
 					  (void **) &status)))
 			log_sys_error("pthread_join", "");
 
-		DEBUGLOG("Joined pre&post thread\n");
+		DEBUGLOG("(%p) Joined pre&post thread\n", pipe_client);
 
 		thisfd->bits.localsock.threadid = 0;
 
@@ -1269,7 +1269,7 @@ static int read_from_local_sock(struct local_client *thisfd)
 	if (len == -1 && errno == EINTR)
 		return 1;
 
-	DEBUGLOG("Read on local socket %d, len = %d\n", thisfd->fd, len);
+	DEBUGLOG("(%p) Read on local socket %d, len = %d\n", thisfd, thisfd->fd, len);
 
 	if (len && verify_message(buffer, len) < 0) {
 		log_error("read_from_local_sock from %d len %d bad verify.",
@@ -1343,15 +1343,15 @@ static int read_from_local_sock(struct local_client *thisfd)
 		char *argptr = inheader->node + strlen(inheader->node) + 1;
 
 		while (missing_len > 0) {
-			DEBUGLOG("got %d bytes, need another %d (total %d)\n",
-				 argslen, missing_len, inheader->arglen);
+			DEBUGLOG("(%p) got %d bytes, need another %d (total %d)\n",
+				 thisfd, argslen, missing_len, inheader->arglen);
 			len = read(thisfd->fd, argptr + argslen, missing_len);
 			if (len == -1 && errno == EINTR)
 				continue;
 
 			if (len <= 0) {
 				/* EOF or error on socket */
-				DEBUGLOG("EOF on local socket\n");
+				DEBUGLOG("(%p) EOF on local socket\n", thisfd);
 				dm_free(thisfd->bits.localsock.cmd);
 				thisfd->bits.localsock.cmd = NULL;
 				return 0;
@@ -1379,7 +1379,7 @@ static int read_from_local_sock(struct local_client *thisfd)
 			.status = ENOENT
 		};
 
-		DEBUGLOG("Unknown node: '%s'\n", inheader->node);
+		DEBUGLOG("(%p) Unknown node: '%s'\n", thisfd, inheader->node);
 		send_message(&reply, sizeof(reply), our_csid, thisfd->fd,
 			     "Error sending ENOENT reply to local user");
 		thisfd->bits.localsock.expected_replies = 0;
@@ -1405,7 +1405,7 @@ static int read_from_local_sock(struct local_client *thisfd)
 			.status = EBUSY
 		};
 
-		DEBUGLOG("Creating pipe failed: %s\n", strerror(errno));
+		DEBUGLOG("(%p) Creating pipe failed: %s\n", thisfd, strerror(errno));
 		send_message(&reply, sizeof(reply), our_csid, thisfd->fd,
 			     "Error sending EBUSY reply to local user");
 		return len;
@@ -1425,7 +1425,7 @@ static int read_from_local_sock(struct local_client *thisfd)
 		return len;
 	}
 
-	DEBUGLOG("Creating pipe, [%d, %d]\n", comms_pipe[0], comms_pipe[1]);
+	DEBUGLOG("(%p) Creating pipe, [%d, %d]\n", thisfd, comms_pipe[0], comms_pipe[1]);
 
 	if (fcntl(comms_pipe[0], F_SETFD, 1))
 		DEBUGLOG("setting CLOEXEC on pipe[0] failed: %s\n", strerror(errno));
@@ -1450,10 +1450,10 @@ static int read_from_local_sock(struct local_client *thisfd)
 	thisfd->bits.localsock.in_progress = TRUE;
 	thisfd->bits.localsock.state = PRE_COMMAND;
 	thisfd->bits.localsock.cleanup_needed = 1;
-	DEBUGLOG("Creating pre&post thread for pipe fd %d (%p)\n", newfd->fd, newfd);
+	DEBUGLOG("(%p) Creating pre&post thread for pipe fd %d\n", newfd, newfd->fd);
 	status = pthread_create(&thisfd->bits.localsock.threadid,
 				&stack_attr, pre_and_post_thread, thisfd);
-	DEBUGLOG("Created pre&post thread, state = %d\n", status);
+	DEBUGLOG("(%p) Created pre&post thread, state = %d\n", newfd, status);
 
 	return len;
 }
@@ -1478,8 +1478,8 @@ static int distribute_command(struct local_client *thisfd)
 	int len = thisfd->bits.localsock.cmd_len;
 
 	thisfd->xid = global_xid++;
-	DEBUGLOG("distribute command: XID = %d, flags=0x%x (%s%s)\n",
-		 thisfd->xid, inheader->flags,
+	DEBUGLOG("(%p) distribute command: XID = %d, flags=0x%x (%s%s)\n",
+		 thisfd, thisfd->xid, inheader->flags,
 		(inheader->flags & CLVMD_FLAG_LOCAL) ? "LOCAL" : "",
 		(inheader->flags & CLVMD_FLAG_REMOTE) ? "REMOTE" : "");
 
@@ -1501,7 +1501,7 @@ static int distribute_command(struct local_client *thisfd)
 			 */
 			add_to_lvmqueue(thisfd, inheader, len, NULL);
 
-			DEBUGLOG("Sending message to all cluster nodes\n");
+			DEBUGLOG("(%p) Sending message to all cluster nodes\n", thisfd);
 			inheader->xid = thisfd->xid;
 			send_message(inheader, len, NULL, -1,
 				     "Error forwarding message to cluster");
@@ -1520,11 +1520,11 @@ static int distribute_command(struct local_client *thisfd)
 
 			/* Are we the requested node ?? */
 			if (memcmp(csid, our_csid, max_csid_len) == 0) {
-				DEBUGLOG("Doing command on local node only\n");
+				DEBUGLOG("(%p) Doing command on local node only\n", thisfd);
 				add_to_lvmqueue(thisfd, inheader, len, NULL);
 			} else {
-				DEBUGLOG("Sending message to single node: %s\n",
-					 inheader->node);
+				DEBUGLOG("(%p) Sending message to single node: %s\n",
+					 thisfd, inheader->node);
 				inheader->xid = thisfd->xid;
 				send_message(inheader, len, csid, -1,
 					     "Error forwarding message to cluster node");
@@ -1535,7 +1535,7 @@ static int distribute_command(struct local_client *thisfd)
 		thisfd->bits.localsock.in_progress = TRUE;
 		thisfd->bits.localsock.expected_replies = 1;
 		thisfd->bits.localsock.num_replies = 0;
-		DEBUGLOG("Doing command explicitly on local node only\n");
+		DEBUGLOG("(%p) Doing command explicitly on local node only\n", thisfd);
 		add_to_lvmqueue(thisfd, inheader, len, NULL);
 	}
 
@@ -1661,7 +1661,7 @@ static void add_reply_to_list(struct local_client *client, int status,
 
 	reply->status = status;
 	clops->name_from_csid(csid, reply->node);
-	DEBUGLOG("Reply from node %s: %d bytes\n", reply->node, len);
+	DEBUGLOG("(%p) Reply from node %s: %d bytes\n", client, reply->node, len);
 
 	if (len > 0) {
 		if (!(reply->replymsg = dm_malloc(len)))
@@ -1688,8 +1688,8 @@ static void add_reply_to_list(struct local_client *client, int status,
 			client->bits.localsock.state = POST_COMMAND;
 			pthread_cond_signal(&client->bits.localsock.cond);
 		}
-		DEBUGLOG("Got %d replies, expecting: %d\n",
-			 client->bits.localsock.num_replies,
+		DEBUGLOG("(%p) Got %d replies, expecting: %d\n",
+			 client, client->bits.localsock.num_replies,
 			 client->bits.localsock.expected_replies);
 	}
 	pthread_mutex_unlock(&client->bits.localsock.mutex);
@@ -1704,7 +1704,7 @@ static __attribute__ ((noreturn)) void *pre_and_post_thread(void *arg)
 	sigset_t ss;
 	int pipe_fd = client->bits.localsock.pipe;
 
-	DEBUGLOG("Pre&post thread (%p), pipe fd %d\n", client, pipe_fd);
+	DEBUGLOG("(%p) Pre&post thread pipe fd %d\n", client, pipe_fd);
 	pthread_mutex_lock(&client->bits.localsock.mutex);
 
 	/* Ignore SIGUSR1 (handled by master process) but enable
@@ -1724,7 +1724,7 @@ static __attribute__ ((noreturn)) void *pre_and_post_thread(void *arg)
 		if ((status = do_pre_command(client)))
 			client->bits.localsock.all_success = 0;
 
-		DEBUGLOG("Pre&post thread (%p) writes status %d down to pipe fd %d\n",
+		DEBUGLOG("(%p) Pre&post thread writes status %d down to pipe fd %d\n",
 			 client, status, pipe_fd);
 
 		/* Tell the parent process we have finished this bit */
@@ -1742,13 +1742,13 @@ static __attribute__ ((noreturn)) void *pre_and_post_thread(void *arg)
 		/* We may need to wait for the condition variable before running the post command */
 		if (client->bits.localsock.state != POST_COMMAND &&
 		    !client->bits.localsock.finished) {
-			DEBUGLOG("Pre&post thread (%p) waiting to do post command, state = %d\n",
+			DEBUGLOG("(%p) Pre&post thread waiting to do post command, state = %d\n",
 				 client, client->bits.localsock.state);
 			pthread_cond_wait(&client->bits.localsock.cond,
 					  &client->bits.localsock.mutex);
 		}
 
-		DEBUGLOG("Pre&post thread (%p) got post command condition...\n", client);
+		DEBUGLOG("(%p) Pre&post thread got post command condition...\n", client);
 
 		/* POST function must always run, even if the client aborts */
 		status = 0;
@@ -1762,15 +1762,15 @@ static __attribute__ ((noreturn)) void *pre_and_post_thread(void *arg)
 next_pre:
 		if (client->bits.localsock.state != PRE_COMMAND &&
 		    !client->bits.localsock.finished) {
-			DEBUGLOG("Pre&post thread (%p) waiting for next pre command\n", client);
+			DEBUGLOG("(%p) Pre&post thread waiting for next pre command\n", client);
 			pthread_cond_wait(&client->bits.localsock.cond,
 					  &client->bits.localsock.mutex);
 		}
 
-		DEBUGLOG("Pre&post thread (%p) got pre command condition...\n", client);
+		DEBUGLOG("(%p) Pre&post thread got pre command condition...\n", client);
 	}
 	pthread_mutex_unlock(&client->bits.localsock.mutex);
-	DEBUGLOG("Pre&post thread (%p) finished\n", client);
+	DEBUGLOG("(%p) Pre&post thread finished\n", client);
 
 	pthread_exit(NULL);
 }
@@ -1788,8 +1788,8 @@ static int process_local_command(struct clvm_header *msg, int msglen,
 	if (!(replybuf = dm_malloc(max_cluster_message)))
 		return -1;
 
-	DEBUGLOG("process_local_command: %s msg=%p, msglen =%d, client=%p\n",
-		 decode_cmd(msg->cmd), msg, msglen, client);
+	DEBUGLOG("(%p) process_local_command: %s msg=%p, msglen =%d\n",
+		 client, decode_cmd(msg->cmd), msg, msglen);
 
 	/* If remote flag is set, just set a successful status code. */
 	if (msg->flags & CLVMD_FLAG_REMOTE)
@@ -1804,8 +1804,8 @@ static int process_local_command(struct clvm_header *msg, int msglen,
 	if (xid == client->xid)
 		add_reply_to_list(client, status, our_csid, replybuf, replylen);
 	else
-		DEBUGLOG("Local command took too long, discarding xid %d, current is %d\n",
-			 xid, client->xid);
+		DEBUGLOG("(%p) Local command took too long, discarding xid %d, current is %d\n",
+			 client, xid, client->xid);
 
 	dm_free(replybuf);
 
@@ -1847,7 +1847,7 @@ static void send_local_reply(struct local_client *client, int status, int fd)
 	char *ptr;
 	int message_len = 0;
 
-	DEBUGLOG("Send local reply\n");
+	DEBUGLOG("(%p) Send local reply\n", client);
 
 	/* Work out the total size of the reply */
 	while (thisreply) {
@@ -1864,7 +1864,7 @@ static void send_local_reply(struct local_client *client, int status, int fd)
 	/* Add in the size of our header */
 	message_len = message_len + sizeof(struct clvm_header);
 	if (!(replybuf = dm_malloc(message_len))) {
-		DEBUGLOG("Memory allocation fails\n");
+		DEBUGLOG("(%p) Memory allocation fails\n", client);
 		return;
 	}
 
@@ -1993,6 +1993,7 @@ static int send_message(void *buf, int msglen, const char *csid, int fd,
 				(void) nanosleep (&delay, &remtime);
 				continue;
 			}
+			DEBUGLOG("%s", errtext);
 			log_error("%s", errtext);
 			break;
 		}
@@ -2006,7 +2007,7 @@ static int process_work_item(struct lvm_thread_cmd *cmd)
 {
 	/* If msg is NULL then this is a cleanup request */
 	if (cmd->msg == NULL) {
-		DEBUGLOG("process_work_item: free %p\n", cmd->client);
+		DEBUGLOG("(%p) process_work_item: free\n", cmd->client);
 		cmd_client_cleanup(cmd->client);
 		pthread_mutex_destroy(&cmd->client->bits.localsock.mutex);
 		pthread_cond_destroy(&cmd->client->bits.localsock.cond);
@@ -2015,11 +2016,11 @@ static int process_work_item(struct lvm_thread_cmd *cmd)
 	}
 
 	if (!cmd->remote) {
-		DEBUGLOG("process_work_item: local\n");
+		DEBUGLOG("(%p) process_work_item: local\n", cmd->client);
 		process_local_command(cmd->msg, cmd->msglen, cmd->client,
 				      cmd->xid);
 	} else {
-		DEBUGLOG("process_work_item: remote\n");
+		DEBUGLOG("(%p) process_work_item: remote\n", cmd->client);
 		process_remote_command(cmd->msg, cmd->msglen, cmd->client->fd,
 				       cmd->csid);
 	}
@@ -2113,8 +2114,8 @@ static int add_to_lvmqueue(struct local_client *client, struct clvm_header *msg,
 	} else
 		cmd->remote = 0;
 
-	DEBUGLOG("add_to_lvmqueue: cmd=%p. client=%p, msg=%p, len=%d, csid=%p, xid=%d\n",
-		 cmd, client, msg, msglen, csid, cmd->xid);
+	DEBUGLOG("(%p) add_to_lvmqueue: cmd=%p, msg=%p, len=%d, csid=%p, xid=%d\n",
+		 client, cmd, msg, msglen, csid, cmd->xid);
 	pthread_mutex_lock(&lvm_thread_mutex);
 	if (lvm_thread_exit) {
 		pthread_mutex_unlock(&lvm_thread_mutex);
@@ -2250,7 +2251,8 @@ static void check_all_callback(struct local_client *client, const char *csid,
    If not, returns -1 and prints out a list of errant nodes */
 static int check_all_clvmds_running(struct local_client *client)
 {
-	DEBUGLOG("check_all_clvmds_running\n");
+	DEBUGLOG("(%p) check_all_clvmds_running\n", client);
+
 	return clops->cluster_do_node_callback(client, check_all_callback);
 }
 


