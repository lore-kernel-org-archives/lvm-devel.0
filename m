From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed, 18 Sep 2013 19:18:34 +0000 (UTC)
Subject: master - clvmd: Avoid a 3-way deadlock in dead-client cleanup.
Message-ID: <20130918191834.9C31C61133@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=25bed9968155f43ef0b8832383ef711e7ae1685d
Commit:        25bed9968155f43ef0b8832383ef711e7ae1685d
Parent:        3df50d822b8064c5536968556c466c50a9a3ace5
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon Sep 9 00:01:44 2013 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Sep 18 21:17:48 2013 +0200

clvmd: Avoid a 3-way deadlock in dead-client cleanup.

---
 daemons/clvmd/clvmd.c |  177 ++++++++++++++++++++++++++-----------------------
 daemons/clvmd/clvmd.h |    1 +
 2 files changed, 96 insertions(+), 82 deletions(-)

diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index a52b39d..bed8e68 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -119,6 +119,7 @@ static void *pre_and_post_thread(void *arg);
 static int send_message(void *buf, int msglen, const char *csid, int fd,
 			const char *errtext);
 static int read_from_local_sock(struct local_client *thisfd);
+static int cleanup_zombie(struct local_client *thisfd);
 static int process_local_command(struct clvm_header *msg, int msglen,
 				 struct local_client *client,
 				 unsigned short xid);
@@ -698,6 +699,7 @@ static int local_rendezvous_callback(struct local_client *thisfd, char *buf,
 		newfd->bits.localsock.sent_out = FALSE;
 		newfd->bits.localsock.threadid = 0;
 		newfd->bits.localsock.finished = 0;
+		newfd->bits.localsock.cleanup_needed = 0;
 		newfd->bits.localsock.pipe_client = NULL;
 		newfd->bits.localsock.private = NULL;
 		newfd->bits.localsock.all_success = 1;
@@ -889,7 +891,7 @@ static void main_loop(int local_sock, int cmd_timeout)
 			for (thisfd = &local_client_head; thisfd != NULL;
 			     thisfd = thisfd->next) {
 
-				if (thisfd->removeme) {
+				if (thisfd->removeme && !cleanup_zombie(thisfd)) {
 					struct local_client *free_fd;
 					lastfd->next = thisfd->next;
 					free_fd = thisfd;
@@ -916,7 +918,6 @@ static void main_loop(int local_sock, int cmd_timeout)
 
 					/* Got error or EOF: Remove it from the list safely */
 					if (ret <= 0) {
-						struct local_client *free_fd;
 						int type = thisfd->type;
 
 						/* If the cluster socket shuts down, so do we */
@@ -926,12 +927,7 @@ static void main_loop(int local_sock, int cmd_timeout)
 
 						DEBUGLOG("ret == %d, errno = %d. removing client\n",
 							 ret, errno);
-						lastfd->next = thisfd->next;
-						free_fd = thisfd;
-						safe_close(&(free_fd->fd));
-
-						/* Queue cleanup, this also frees the client struct */
-						add_to_lvmqueue(free_fd, NULL, 0, NULL);
+						thisfd->removeme = 1;
 						break;
 					}
 
@@ -1174,6 +1170,95 @@ static void dump_message(char *buf, int len)
 	}
 }
 
+static int cleanup_zombie(struct local_client *thisfd)
+{
+	int *status;
+
+	if (thisfd->type != LOCAL_SOCK)
+		return 0;
+
+	if (!thisfd->bits.localsock.cleanup_needed)
+		return 0;
+
+	DEBUGLOG("EOF on local socket: inprogress=%d\n",
+		 thisfd->bits.localsock.in_progress);
+
+	thisfd->bits.localsock.finished = 1;
+
+	/* If the client went away in mid command then tidy up */
+	if (thisfd->bits.localsock.in_progress) {
+		pthread_kill(thisfd->bits.localsock.threadid, SIGUSR2);
+		if (pthread_mutex_trylock(&thisfd->bits.localsock.mutex))
+			goto bail;
+		thisfd->bits.localsock.state = POST_COMMAND;
+		pthread_cond_signal(&thisfd->bits.localsock.cond);
+		pthread_mutex_unlock(&thisfd->bits.localsock.mutex);
+
+		/* Free any unsent buffers */
+		free_reply(thisfd);
+	}
+
+	/* Kill the subthread & free resources */
+	if (thisfd->bits.localsock.threadid) {
+		DEBUGLOG("Waiting for child thread\n");
+		pthread_mutex_lock(&thisfd->bits.localsock.mutex);
+		thisfd->bits.localsock.state = PRE_COMMAND;
+		pthread_cond_signal(&thisfd->bits.localsock.cond);
+		pthread_mutex_unlock(&thisfd->bits.localsock.mutex);
+
+		if ((errno = pthread_join(thisfd->bits.localsock.threadid,
+					  (void **) &status)))
+			log_sys_error("pthread_join", "");
+
+		DEBUGLOG("Joined child thread\n");
+
+		thisfd->bits.localsock.threadid = 0;
+		pthread_cond_destroy(&thisfd->bits.localsock.cond);
+		pthread_mutex_destroy(&thisfd->bits.localsock.mutex);
+
+		/* Remove the pipe client */
+		if (thisfd->bits.localsock.pipe_client != NULL) {
+			struct local_client *newfd;
+			struct local_client *lastfd = NULL;
+			struct local_client *free_fd = NULL;
+
+			(void) close(thisfd->bits.localsock.pipe_client->fd);	/* Close pipe */
+			(void) close(thisfd->bits.localsock.pipe);
+
+			/* Remove pipe client */
+			for (newfd = &local_client_head; newfd != NULL;
+			     newfd = newfd->next) {
+				if (thisfd->bits.localsock.
+				    pipe_client == newfd) {
+					thisfd->bits.localsock.
+					    pipe_client = NULL;
+
+					lastfd->next = newfd->next;
+					free_fd = newfd;
+					newfd->next = lastfd;
+					free(free_fd);
+					break;
+				}
+				lastfd = newfd;
+			}
+		}
+	}
+
+	/* Free the command buffer */
+	free(thisfd->bits.localsock.cmd);
+
+	/* Clear out the cross-link */
+	if (thisfd->bits.localsock.pipe_client != NULL)
+		thisfd->bits.localsock.pipe_client->bits.pipe.client =
+		    NULL;
+
+	safe_close(&(thisfd->fd));
+	thisfd->bits.localsock.cleanup_needed = 0;
+	return 0;
+bail:
+	return 1;
+}
+
 /* Called when we have a read from the local socket.
    was in the main loop but it's grown up and is a big girl now */
 static int read_from_local_sock(struct local_client *thisfd)
@@ -1204,80 +1289,8 @@ static int read_from_local_sock(struct local_client *thisfd)
 
 	/* EOF or error on socket */
 	if (len <= 0) {
-		int *status;
-
-		DEBUGLOG("EOF on local socket: inprogress=%d\n",
-			 thisfd->bits.localsock.in_progress);
-
-		thisfd->bits.localsock.finished = 1;
-
-		/* If the client went away in mid command then tidy up */
-		if (thisfd->bits.localsock.in_progress) {
-			pthread_kill(thisfd->bits.localsock.threadid, SIGUSR2);
-			pthread_mutex_lock(&thisfd->bits.localsock.mutex);
-			thisfd->bits.localsock.state = POST_COMMAND;
-			pthread_cond_signal(&thisfd->bits.localsock.cond);
-			pthread_mutex_unlock(&thisfd->bits.localsock.mutex);
-
-			/* Free any unsent buffers */
-			free_reply(thisfd);
-		}
-
-		/* Kill the subthread & free resources */
-		if (thisfd->bits.localsock.threadid) {
-			DEBUGLOG("Waiting for child thread\n");
-			pthread_mutex_lock(&thisfd->bits.localsock.mutex);
-			thisfd->bits.localsock.state = PRE_COMMAND;
-			pthread_cond_signal(&thisfd->bits.localsock.cond);
-			pthread_mutex_unlock(&thisfd->bits.localsock.mutex);
-
-			if ((errno = pthread_join(thisfd->bits.localsock.threadid,
-						  (void **) &status)))
-				log_sys_error("pthread_join", "");
-
-			DEBUGLOG("Joined child thread\n");
-
-			thisfd->bits.localsock.threadid = 0;
-			pthread_cond_destroy(&thisfd->bits.localsock.cond);
-			pthread_mutex_destroy(&thisfd->bits.localsock.mutex);
-
-			/* Remove the pipe client */
-			if (thisfd->bits.localsock.pipe_client != NULL) {
-				struct local_client *newfd;
-				struct local_client *lastfd = NULL;
-				struct local_client *free_fd = NULL;
-
-				(void) close(thisfd->bits.localsock.pipe_client->fd);	/* Close pipe */
-				(void) close(thisfd->bits.localsock.pipe);
-
-				/* Remove pipe client */
-				for (newfd = &local_client_head; newfd != NULL;
-				     newfd = newfd->next) {
-					if (thisfd->bits.localsock.
-					    pipe_client == newfd) {
-						thisfd->bits.localsock.
-						    pipe_client = NULL;
-
-						lastfd->next = newfd->next;
-						free_fd = newfd;
-						newfd->next = lastfd;
-						free(free_fd);
-						break;
-					}
-					lastfd = newfd;
-				}
-			}
-		}
-
-		/* Free the command buffer */
-		free(thisfd->bits.localsock.cmd);
-
-		/* Clear out the cross-link */
-		if (thisfd->bits.localsock.pipe_client != NULL)
-			thisfd->bits.localsock.pipe_client->bits.pipe.client =
-			    NULL;
-
-		safe_close(&(thisfd->fd));
+		thisfd->bits.localsock.cleanup_needed = 1;
+		cleanup_zombie(thisfd); /* we ignore errors here */
 		return 0;
 	} else {
 		int comms_pipe[2];
diff --git a/daemons/clvmd/clvmd.h b/daemons/clvmd/clvmd.h
index fb0589d..0f837dd 100644
--- a/daemons/clvmd/clvmd.h
+++ b/daemons/clvmd/clvmd.h
@@ -53,6 +53,7 @@ struct localsock_bits {
 	int finished;		/* Flag to tell subthread to exit */
 	int all_success;	/* Set to 0 if any node (or the pre_command)
 				   failed */
+	int cleanup_needed;     /* helper for cleanup_zombie */
 	struct local_client *pipe_client;
 	pthread_t threadid;
 	enum { PRE_COMMAND, POST_COMMAND, QUIT } state;


