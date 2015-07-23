From: Alasdair Kergon <agk@fedoraproject.org>
Date: Thu, 23 Jul 2015 22:26:26 +0000 (UTC)
Subject: master - clvmd: Fix freeze if client dies holding locks.
Message-ID: <20150723222626.8A47A61043@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=be662439331abf6ccb16dd996bfe15eb613b4e53
Commit:        be662439331abf6ccb16dd996bfe15eb613b4e53
Parent:        57534733b7750f17f5ffa115306dcb650d8015b9
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Jul 23 23:10:16 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Jul 23 23:10:16 2015 +0100

clvmd: Fix freeze if client dies holding locks.

Simply running concurrent copies of 'pvscan | true' is enough to make
clvmd freeze: pvscan exits on the EPIPE without first releasing the
global lock.

clvmd notices the client disappear but because the cleanup code that
releases the locks is triggered from within some processing after the
next select() returns, and that processing can 'break' after doing just
one action, it sometimes never releases the locks to other clients.

Move the cleanup code before the select.
Check all fds after select().
Improve some debug messages and warn in the unlikely event that
select() capacity could soon be exceeded.
---
 WHATS_NEW                     |    1 +
 daemons/clvmd/clvmd-command.c |    4 +-
 daemons/clvmd/clvmd.c         |   67 +++++++++++++++++++++++++++--------------
 3 files changed, 47 insertions(+), 25 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index adf8eb7..03e76c7 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.126 -
 ================================
+  Fix clvmd freeze if client disappears without first releasing its locks.
   Fix lvconvert segfaults while performing snapshots merge.
   Ignore errors during detection if use_blkid_wiping=1 and --force is used.
   Recognise DM_ABORT_ON_INTERNAL_ERRORS env var override in lvm logging fn.
diff --git a/daemons/clvmd/clvmd-command.c b/daemons/clvmd/clvmd-command.c
index 9e59e51..ff068b0 100644
--- a/daemons/clvmd/clvmd-command.c
+++ b/daemons/clvmd/clvmd-command.c
@@ -323,6 +323,7 @@ void cmd_client_cleanup(struct local_client *client)
 	int lkid;
 	char *lockname;
 
+	DEBUGLOG("Client thread cleanup (%p)\n", client);
 	if (!client->bits.localsock.private)
 		return;
 
@@ -331,7 +332,7 @@ void cmd_client_cleanup(struct local_client *client)
 	dm_hash_iterate(v, lock_hash) {
 		lkid = (int)(long)dm_hash_get_data(lock_hash, v);
 		lockname = dm_hash_get_key(lock_hash, v);
-		DEBUGLOG("cleanup: Unlocking lock %s %x\n", lockname, lkid);
+		DEBUGLOG("Cleanup (%p): Unlocking lock %s %x\n", client, lockname, lkid);
 		(void) sync_unlock(lockname, lkid);
 	}
 
@@ -339,7 +340,6 @@ void cmd_client_cleanup(struct local_client *client)
 	client->bits.localsock.private = NULL;
 }
 
-
 static int restart_clvmd(void)
 {
 	const char **argv;
diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index 6bab3d6..99d01d0 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -223,6 +223,7 @@ void debuglog(const char *fmt, ...)
 		fprintf(stderr, "CLVMD[%x]: %.15s ", (int)pthread_self(), ctime_r(&P, buf_ctime) + 4);
 		vfprintf(stderr, fmt, ap);
 		va_end(ap);
+		fflush(stderr);
 		break;
 	case DEBUG_SYSLOG:
 		if (!syslog_init) {
@@ -598,7 +599,9 @@ int main(int argc, char *argv[])
 
 	/* This needs to be started after cluster initialisation
 	   as it may need to take out locks */
-	DEBUGLOG("starting LVM thread\n");
+	DEBUGLOG("Starting LVM thread\n");
+	DEBUGLOG("Main cluster socket fd %d (%p) with local socket %d (%p)\n",
+		 local_client_head.fd, &local_client_head, newfd->fd, newfd);
 
 	/* Don't let anyone else to do work until we are started */
 	pthread_create(&lvm_thread, &stack_attr, lvm_thread_fn, &lvm_params);
@@ -698,7 +701,7 @@ static int local_rendezvous_callback(struct local_client *thisfd, char *buf,
 		newfd->type = LOCAL_SOCK;
 		newfd->callback = local_sock_callback;
 		newfd->bits.localsock.all_success = 1;
-		DEBUGLOG("Got new connection on fd %d\n", newfd->fd);
+		DEBUGLOG("Got new connection on fd %d (%p)\n", newfd->fd, newfd);
 		*new_client = newfd;
 	}
 	return 1;
@@ -850,18 +853,48 @@ static void main_loop(int cmd_timeout)
 		struct local_client *thisfd;
 		struct timeval tv = { cmd_timeout, 0 };
 		int quorate = clops->is_quorate();
+		int client_count = 0;
+		int max_fd = 0;
 
 		/* Wait on the cluster FD and all local sockets/pipes */
 		local_client_head.fd = clops->get_main_cluster_fd();
 		FD_ZERO(&in);
+		struct local_client *lastfd = &local_client_head;
+		struct local_client *nextfd = local_client_head.next;
+
 		for (thisfd = &local_client_head; thisfd; thisfd = thisfd->next) {
+			client_count++;
+			max_fd = max(max_fd, thisfd->fd);
+		}
+
+		if (max_fd > FD_SETSIZE - 32) {
+			fprintf(stderr, "WARNING: There are too many connections to clvmd.  Investigate and take action now!\n");
+ 			fprintf(stderr, "WARNING: Your cluster may freeze up if the number of clvmd file descriptors (%d) exceeds %d.\n", max_fd + 1, FD_SETSIZE);
+		}
+
+		for (thisfd = &local_client_head; thisfd; thisfd = nextfd, nextfd = thisfd ? thisfd->next : NULL) {
+
+			if (thisfd->removeme && !cleanup_zombie(thisfd)) {
+				struct local_client *free_fd = thisfd;
+				lastfd->next = nextfd;
+				DEBUGLOG("removeme set for %p with %d monitored fds remaining\n", free_fd, client_count - 1);
+
+				/* Queue cleanup, this also frees the client struct */
+				add_to_lvmqueue(free_fd, NULL, 0, NULL);
+
+				continue;
+			}
+
+			lastfd = thisfd;
+
 			if (thisfd->removeme)
 				continue;
 
 			/* if the cluster is not quorate then don't listen for new requests */
 			if ((thisfd->type != LOCAL_RENDEZVOUS &&
 			     thisfd->type != LOCAL_SOCK) || quorate)
-				FD_SET(thisfd->fd, &in);
+				if (thisfd->fd < FD_SETSIZE)
+					FD_SET(thisfd->fd, &in);
 		}
 
 		select_status = select(FD_SETSIZE, &in, NULL, NULL, &tv);
@@ -877,31 +910,20 @@ static void main_loop(int cmd_timeout)
 		}
 
 		if (select_status > 0) {
-			struct local_client *lastfd = NULL;
 			char csid[MAX_CSID_LEN];
 			char buf[max_cluster_message];
 
 			for (thisfd = &local_client_head; thisfd; thisfd = thisfd->next) {
-				if (thisfd->removeme && !cleanup_zombie(thisfd)) {
-					struct local_client *free_fd = thisfd;
-					lastfd->next = thisfd->next;
-					DEBUGLOG("removeme set for fd %d\n", free_fd->fd);
-
-					/* Queue cleanup, this also frees the client struct */
-					add_to_lvmqueue(free_fd, NULL, 0, NULL);
-					break;
-				}
-
-				if (FD_ISSET(thisfd->fd, &in)) {
+				if (thisfd->fd < FD_SETSIZE && FD_ISSET(thisfd->fd, &in)) {
 					struct local_client *newfd = NULL;
 					int ret;
 
+					/* FIXME Remove from main thread in case it blocks! */
 					/* Do callback */
 					ret = thisfd->callback(thisfd, buf, sizeof(buf),
 							       csid, &newfd);
 					/* Ignore EAGAIN */
 					if (ret < 0 && (errno == EAGAIN || errno == EINTR)) {
-						lastfd = thisfd;
 						continue;
                                         }
 
@@ -917,17 +939,16 @@ static void main_loop(int cmd_timeout)
 						DEBUGLOG("ret == %d, errno = %d. removing client\n",
 							 ret, errno);
 						thisfd->removeme = 1;
-						break;
+						continue;
 					}
 
 					/* New client...simply add it to the list */
 					if (newfd) {
 						newfd->next = thisfd->next;
 						thisfd->next = newfd;
-						break;
+						thisfd = newfd;
 					}
 				}
-				lastfd = thisfd;
 			}
 		}
 
@@ -1420,7 +1441,7 @@ static int read_from_local_sock(struct local_client *thisfd)
 	thisfd->bits.localsock.in_progress = TRUE;
 	thisfd->bits.localsock.state = PRE_COMMAND;
 	thisfd->bits.localsock.cleanup_needed = 1;
-	DEBUGLOG("Creating pre&post thread\n");
+	DEBUGLOG("Creating pre&post thread for pipe fd %d (%p)\n", newfd->fd, newfd);
 	status = pthread_create(&thisfd->bits.localsock.threadid,
 				&stack_attr, pre_and_post_thread, thisfd);
 	DEBUGLOG("Created pre&post thread, state = %d\n", status);
@@ -1674,7 +1695,7 @@ static __attribute__ ((noreturn)) void *pre_and_post_thread(void *arg)
 	sigset_t ss;
 	int pipe_fd = client->bits.localsock.pipe;
 
-	DEBUGLOG("Pre&post thread (%p), pipe %d\n", client, pipe_fd);
+	DEBUGLOG("Pre&post thread (%p), pipe fd %d\n", client, pipe_fd);
 	pthread_mutex_lock(&client->bits.localsock.mutex);
 
 	/* Ignore SIGUSR1 (handled by master process) but enable
@@ -1694,7 +1715,7 @@ static __attribute__ ((noreturn)) void *pre_and_post_thread(void *arg)
 		if ((status = do_pre_command(client)))
 			client->bits.localsock.all_success = 0;
 
-		DEBUGLOG("Pre&post thread (%p) writes status %d down to pipe %d\n",
+		DEBUGLOG("Pre&post thread (%p) writes status %d down to pipe fd %d\n",
 			 client, status, pipe_fd);
 
 		/* Tell the parent process we have finished this bit */
@@ -1976,7 +1997,7 @@ static int process_work_item(struct lvm_thread_cmd *cmd)
 {
 	/* If msg is NULL then this is a cleanup request */
 	if (cmd->msg == NULL) {
-		DEBUGLOG("process_work_item: free fd %d\n", cmd->client->fd);
+		DEBUGLOG("process_work_item: free %p\n", cmd->client);
 		cmd_client_cleanup(cmd->client);
 		pthread_mutex_destroy(&cmd->client->bits.localsock.mutex);
 		pthread_cond_destroy(&cmd->client->bits.localsock.cond);


