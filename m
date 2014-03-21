From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 21 Mar 2014 21:32:11 +0000 (UTC)
Subject: master - cleanup: clvmd add more info debug message
Message-ID: <20140321213211.6810B60F05@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=01efb20bdb78a2f49c72951cedca6ffa11a6ba09
Commit:        01efb20bdb78a2f49c72951cedca6ffa11a6ba09
Parent:        0d449fe183936be5790e7c59d157fe6c8334a914
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 20 14:24:06 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 21 22:29:27 2014 +0100

cleanup: clvmd add more info debug message

---
 daemons/clvmd/clvmd.c |   46 +++++++++++++++++++++++++++-------------------
 1 files changed, 27 insertions(+), 19 deletions(-)

diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index ac570b6..4648450 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -686,7 +686,7 @@ static int local_rendezvous_callback(struct local_client *thisfd, char *buf,
 		}
 
 		if (fcntl(client_fd, F_SETFD, 1))
-			DEBUGLOG("setting CLOEXEC on client fd failed: %s\n", strerror(errno));
+			DEBUGLOG("Setting CLOEXEC on client fd failed: %s\n", strerror(errno));
 
 		newfd->fd = client_fd;
 		newfd->type = LOCAL_SOCK;
@@ -714,7 +714,7 @@ static int local_pipe_callback(struct local_client *thisfd, char *buf,
 	if (len == sizeof(int))
 		memcpy(&status, buffer, sizeof(int));
 
-	DEBUGLOG("read on PIPE %d: %d bytes: status: %d\n",
+	DEBUGLOG("Read on pipe %d, %d bytes, status %d\n",
 		 thisfd->fd, len, status);
 
 	/* EOF on pipe or an error, close it */
@@ -738,11 +738,11 @@ static int local_pipe_callback(struct local_client *thisfd, char *buf,
 		}
 		return -1;
 	} else {
-		DEBUGLOG("background routine status was %d, sock_client=%p\n",
+		DEBUGLOG("Background routine status was %d, sock_client (%p)\n",
 			 status, sock_client);
 		/* But has the client gone away ?? */
 		if (!sock_client) {
-			DEBUGLOG("Got PIPE response for dead client, ignoring it\n");
+			DEBUGLOG("Got pipe response for dead client, ignoring it\n");
 		} else {
 			/* If error then just return that code */
 			if (status)
@@ -1134,6 +1134,7 @@ static void dump_message(char *buf, int len)
 static int cleanup_zombie(struct local_client *thisfd)
 {
 	int *status;
+	struct local_client *pipe_client;
 
 	if (thisfd->type != LOCAL_SOCK)
 		return 0;
@@ -1146,8 +1147,12 @@ static int cleanup_zombie(struct local_client *thisfd)
 
 	thisfd->bits.localsock.finished = 1;
 
+	if ((pipe_client = thisfd->bits.localsock.pipe_client))
+		pipe_client = pipe_client->bits.pipe.client;
+
 	/* If the client went away in mid command then tidy up */
 	if (thisfd->bits.localsock.in_progress) {
+		DEBUGLOG("Sending SIGUSR2 to pre&post thread (%p in-progress)\n", pipe_client);
 		pthread_kill(thisfd->bits.localsock.threadid, SIGUSR2);
 		if (pthread_mutex_trylock(&thisfd->bits.localsock.mutex))
 			return 1;
@@ -1161,7 +1166,7 @@ static int cleanup_zombie(struct local_client *thisfd)
 
 	/* Kill the subthread & free resources */
 	if (thisfd->bits.localsock.threadid) {
-		DEBUGLOG("Waiting for child thread\n");
+		DEBUGLOG("Waiting for pre&post thread (%p)\n", pipe_client);
 		pthread_mutex_lock(&thisfd->bits.localsock.mutex);
 		thisfd->bits.localsock.state = PRE_COMMAND;
 		pthread_cond_signal(&thisfd->bits.localsock.cond);
@@ -1171,7 +1176,7 @@ static int cleanup_zombie(struct local_client *thisfd)
 					  (void **) &status)))
 			log_sys_error("pthread_join", "");
 
-		DEBUGLOG("Joined child thread\n");
+		DEBUGLOG("Joined pre&post thread\n");
 
 		thisfd->bits.localsock.threadid = 0;
 		pthread_cond_destroy(&thisfd->bits.localsock.cond);
@@ -1389,7 +1394,7 @@ static int read_from_local_sock(struct local_client *thisfd)
 		return len;
 	}
 
-	DEBUGLOG("creating pipe, [%d, %d]\n", comms_pipe[0], comms_pipe[1]);
+	DEBUGLOG("Creating pipe, [%d, %d]\n", comms_pipe[0], comms_pipe[1]);
 
 	if (fcntl(comms_pipe[0], F_SETFD, 1))
 		DEBUGLOG("setting CLOEXEC on pipe[0] failed: %s\n", strerror(errno));
@@ -1499,6 +1504,7 @@ static int distribute_command(struct local_client *thisfd)
 		thisfd->bits.localsock.in_progress = TRUE;
 		thisfd->bits.localsock.expected_replies = 1;
 		thisfd->bits.localsock.num_replies = 0;
+		DEBUGLOG("Doing command explicitly on local node only\n");
 		add_to_lvmqueue(thisfd, inheader, len, NULL);
 	}
 
@@ -1665,7 +1671,7 @@ static __attribute__ ((noreturn)) void *pre_and_post_thread(void *arg)
 	sigset_t ss;
 	int pipe_fd = client->bits.localsock.pipe;
 
-	DEBUGLOG("in sub thread: client = %p\n", client);
+	DEBUGLOG("Pre&post thread (%p), pipe %d\n", client, pipe_fd);
 	pthread_mutex_lock(&client->bits.localsock.mutex);
 
 	/* Ignore SIGUSR1 (handled by master process) but enable
@@ -1685,7 +1691,8 @@ static __attribute__ ((noreturn)) void *pre_and_post_thread(void *arg)
 		if ((status = do_pre_command(client)))
 			client->bits.localsock.all_success = 0;
 
-		DEBUGLOG("Writing status %d down pipe %d\n", status, pipe_fd);
+		DEBUGLOG("Pre&post thread (%p) writes status %d down to pipe %d\n",
+			 client, status, pipe_fd);
 
 		/* Tell the parent process we have finished this bit */
 		while ((write_status = write(pipe_fd, &status, sizeof(int))) != sizeof(int))
@@ -1700,15 +1707,15 @@ static __attribute__ ((noreturn)) void *pre_and_post_thread(void *arg)
 		}
 
 		/* We may need to wait for the condition variable before running the post command */
-		DEBUGLOG("Waiting to do post command - state = %d\n",
-			 client->bits.localsock.state);
-
 		if (client->bits.localsock.state != POST_COMMAND &&
-		    !client->bits.localsock.finished)
+		    !client->bits.localsock.finished) {
+			DEBUGLOG("Pre&post thread (%p) waiting to do post command, state = %d\n",
+				 client, client->bits.localsock.state);
 			pthread_cond_wait(&client->bits.localsock.cond,
 					  &client->bits.localsock.mutex);
+		}
 
-		DEBUGLOG("Got post command condition...\n");
+		DEBUGLOG("Pre&post thread (%p) got post command condition...\n", client);
 
 		/* POST function must always run, even if the client aborts */
 		status = 0;
@@ -1720,18 +1727,18 @@ static __attribute__ ((noreturn)) void *pre_and_post_thread(void *arg)
 				break;
 			}
 next_pre:
-		DEBUGLOG("Waiting for next pre command\n");
-
 		if (client->bits.localsock.state != PRE_COMMAND &&
 		    !client->bits.localsock.finished) {
+			DEBUGLOG("Pre&post thread (%p) waiting for next pre command\n", client);
 			pthread_cond_wait(&client->bits.localsock.cond,
 					  &client->bits.localsock.mutex);
 		}
 
-		DEBUGLOG("Got pre command condition...\n");
+		DEBUGLOG("Pre&post thread (%p) got pre command condition...\n", client);
 	}
 	pthread_mutex_unlock(&client->bits.localsock.mutex);
-	DEBUGLOG("Subthread finished\n");
+	DEBUGLOG("Pre&post thread (%p) finished\n", client);
+
 	pthread_exit(NULL);
 }
 
@@ -2008,7 +2015,7 @@ static void *lvm_thread_fn(void *arg)
 
 	/* Allow others to get moving */
 	pthread_barrier_wait(&lvm_start_barrier);
-	DEBUGLOG("Sub thread ready for work.\n");
+	DEBUGLOG("LVM thread ready for work.\n");
 
 	/* Now wait for some actual work */
 	pthread_mutex_lock(&lvm_thread_mutex);
@@ -2031,6 +2038,7 @@ static void *lvm_thread_fn(void *arg)
 		}
 
 	pthread_mutex_unlock(&lvm_thread_mutex);
+	DEBUGLOG("LVM thread exits\n");
 
 	destroy_lvm();
 


