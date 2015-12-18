From: Andrew Elble <aweits@rit.edu>
Date: Fri, 18 Dec 2015 13:35:42 -0000
Subject: [PATCH] clvmd: fix memory corruption
Message-ID: <1450445723-61447-1-git-send-email-aweits@rit.edu>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

We've observed memory corruption and crashing of clvmd. This would
usually happen during a node failure/STONITH and clvmd was
crashing on the node that was the survivor. Further inspection
with valgrind indicated that use-after-free conditions exist for
the call to cleanup_zombie() from the cleanup part of the main_loop().

Simple fix is to switch to using the dm_list functions.

Signed-off-by: Andrew Elble <aweits@rit.edu>
---
 daemons/clvmd/clvmd.c | 74 +++++++++++++++++++++++----------------------------
 daemons/clvmd/clvmd.h |  1 +
 2 files changed, 35 insertions(+), 40 deletions(-)

diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index 3f21aba6b61a..13f80ef9e8db 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -57,7 +57,7 @@
 
 /* Head of the fd list. Also contains
    the cluster_socket details */
-static struct local_client local_client_head;
+static struct dm_list local_client_head;
 
 static unsigned short global_xid = 0;	/* Last transaction ID issued */
 
@@ -348,7 +348,7 @@ static void check_permissions(void)
 int main(int argc, char *argv[])
 {
 	int local_sock;
-	struct local_client *newfd, *delfd;
+	struct local_client *newfd, *clusterfd, *delfd;
 	struct lvm_startup_params lvm_params;
 	int opt;
 	int cmd_timeout = DEFAULT_CMD_TIMEOUT;
@@ -581,9 +581,18 @@ int main(int argc, char *argv[])
 	clops->get_our_csid(our_csid);
 
 	/* Initialise the FD list head */
-	local_client_head.fd = clops->get_main_cluster_fd();
-	local_client_head.type = CLUSTER_MAIN_SOCK;
-	local_client_head.callback = clops->cluster_fd_callback;
+	dm_list_init(&local_client_head);
+
+	/* Add the cluster socket to the list */
+	if (!(clusterfd = dm_zalloc(sizeof(struct local_client)))) {
+		child_init_signal_and_exit(DFAIL_MALLOC);
+		/* NOTREACHED */
+	}
+
+	clusterfd->fd = clops->get_main_cluster_fd();
+	clusterfd->type = CLUSTER_MAIN_SOCK;
+	clusterfd->callback = clops->cluster_fd_callback;
+	dm_list_add(&local_client_head, &clusterfd->list);
 
 	/* Add the local socket to the list */
 	if (!(newfd = dm_zalloc(sizeof(struct local_client)))) {
@@ -594,14 +603,13 @@ int main(int argc, char *argv[])
 	newfd->fd = local_sock;
 	newfd->type = LOCAL_RENDEZVOUS;
 	newfd->callback = local_rendezvous_callback;
-	newfd->next = local_client_head.next;
-	local_client_head.next = newfd;
+	dm_list_add(&local_client_head, &newfd->list);
 
 	/* This needs to be started after cluster initialisation
 	   as it may need to take out locks */
 	DEBUGLOG("Starting LVM thread\n");
 	DEBUGLOG("Main cluster socket fd %d (%p) with local socket %d (%p)\n",
-		 local_client_head.fd, &local_client_head, newfd->fd, newfd);
+		 clusterfd->fd, clusterfd, newfd->fd, newfd);
 
 	/* Don't let anyone else to do work until we are started */
 	if (pthread_create(&lvm_thread, &stack_attr, lvm_thread_fn, &lvm_params)) {
@@ -635,8 +643,7 @@ int main(int argc, char *argv[])
 
 	close_local_sock(local_sock);
 
-	while ((delfd = local_client_head.next)) {
-		local_client_head.next = delfd->next;
+	dm_list_iterate_items(delfd, &local_client_head) {
 		/* Failing cleanup_zombie leaks... */
 		if (delfd->type == LOCAL_SOCK && !cleanup_zombie(delfd))
 			cmd_client_cleanup(delfd); /* calls sync_unlock */
@@ -858,16 +865,15 @@ static void main_loop(int cmd_timeout)
 		int quorate = clops->is_quorate();
 		int client_count = 0;
 		int max_fd = 0;
-		struct local_client *lastfd = &local_client_head;
-		struct local_client *nextfd = local_client_head.next;
 
 		/* Wait on the cluster FD and all local sockets/pipes */
-		local_client_head.fd = clops->get_main_cluster_fd();
 		FD_ZERO(&in);
 
-		for (thisfd = &local_client_head; thisfd; thisfd = thisfd->next) {
-			client_count++;
-			max_fd = max(max_fd, thisfd->fd);
+		dm_list_iterate_items(thisfd, &local_client_head) {
+		  if (thisfd->type == CLUSTER_MAIN_SOCK)
+			  thisfd->fd = clops->get_main_cluster_fd();
+		  client_count++;
+		  max_fd = max(max_fd, thisfd->fd);
 		}
 
 		if (max_fd > FD_SETSIZE - 32) {
@@ -875,11 +881,10 @@ static void main_loop(int cmd_timeout)
  			fprintf(stderr, "WARNING: Your cluster may freeze up if the number of clvmd file descriptors (%d) exceeds %d.\n", max_fd + 1, FD_SETSIZE);
 		}
 
-		for (thisfd = &local_client_head; thisfd; thisfd = nextfd, nextfd = thisfd ? thisfd->next : NULL) {
-
+		dm_list_iterate_items(thisfd, &local_client_head) {
 			if (thisfd->removeme && !cleanup_zombie(thisfd)) {
 				struct local_client *free_fd = thisfd;
-				lastfd->next = nextfd;
+				dm_list_del(&thisfd->list);
 				DEBUGLOG("removeme set for %p with %d monitored fds remaining\n", free_fd, client_count - 1);
 
 				/* Queue cleanup, this also frees the client struct */
@@ -888,8 +893,6 @@ static void main_loop(int cmd_timeout)
 				continue;
 			}
 
-			lastfd = thisfd;
-
 			if (thisfd->removeme)
 				continue;
 
@@ -916,7 +919,7 @@ static void main_loop(int cmd_timeout)
 			char csid[MAX_CSID_LEN];
 			char buf[max_cluster_message];
 
-			for (thisfd = &local_client_head; thisfd; thisfd = thisfd->next) {
+			dm_list_iterate_items(thisfd, &local_client_head) {
 				if (thisfd->fd < FD_SETSIZE && FD_ISSET(thisfd->fd, &in)) {
 					struct local_client *newfd = NULL;
 					int ret;
@@ -947,9 +950,7 @@ static void main_loop(int cmd_timeout)
 
 					/* New client...simply add it to the list */
 					if (newfd) {
-						newfd->next = thisfd->next;
-						thisfd->next = newfd;
-						thisfd = newfd;
+						dm_list_add(&local_client_head, &newfd->list);
 					}
 				}
 			}
@@ -959,7 +960,7 @@ static void main_loop(int cmd_timeout)
 		if (select_status == 0) {
 			time_t the_time = time(NULL);
 
-			for (thisfd = &local_client_head; thisfd; thisfd = thisfd->next) {
+			dm_list_iterate_items(thisfd, &local_client_head) {
 				if (thisfd->type == LOCAL_SOCK &&
 				    thisfd->bits.localsock.sent_out &&
 				    (thisfd->bits.localsock.sent_time + cmd_timeout) < the_time &&
@@ -1220,19 +1221,15 @@ static int cleanup_zombie(struct local_client *thisfd)
 		/* Remove the pipe client */
 		if (thisfd->bits.localsock.pipe_client) {
 			struct local_client *delfd;
-			struct local_client *lastfd;
 
 			(void) close(thisfd->bits.localsock.pipe_client->fd);	/* Close pipe */
 			(void) close(thisfd->bits.localsock.pipe);
 
 			/* Remove pipe client */
-			for (lastfd = &local_client_head; (delfd = lastfd->next); lastfd = delfd)
-				if (thisfd->bits.localsock.pipe_client == delfd) {
-					thisfd->bits.localsock.pipe_client = NULL;
-					lastfd->next = delfd->next;
-					dm_free(delfd);
-					break;
-				}
+			delfd = thisfd->bits.localsock.pipe_client;
+			dm_list_del(&delfd->list);
+			dm_free(delfd);
+			thisfd->bits.localsock.pipe_client = NULL;
 		}
 	}
 
@@ -1430,8 +1427,7 @@ static int read_from_local_sock(struct local_client *thisfd)
 	newfd->type = THREAD_PIPE;
 	newfd->callback = local_pipe_callback;
 	newfd->bits.pipe.client = thisfd;
-	newfd->next = thisfd->next;
-	thisfd->next = newfd;
+	dm_list_add_h(&thisfd->list, &newfd->list);
 
 	/* Store a cross link to the pipe */
 	thisfd->bits.localsock.pipe_client = newfd;
@@ -1457,9 +1453,7 @@ static int read_from_local_sock(struct local_client *thisfd)
 */
 int add_client(struct local_client *new_client)
 {
-	new_client->next = local_client_head.next;
-	local_client_head.next = new_client;
-
+	dm_list_add(&local_client_head, &new_client->list);
 	return 0;
 }
 
@@ -2254,7 +2248,7 @@ static struct local_client *find_client(int clientid)
 {
 	struct local_client *thisfd;
 
-	for (thisfd = &local_client_head; thisfd; thisfd = thisfd->next)
+	dm_list_iterate_items(thisfd, &local_client_head)
 		if (thisfd->fd == (int)ntohl(clientid))
 			return thisfd;
 
diff --git a/daemons/clvmd/clvmd.h b/daemons/clvmd/clvmd.h
index f11c033d8cfc..6e977d9bb111 100644
--- a/daemons/clvmd/clvmd.h
+++ b/daemons/clvmd/clvmd.h
@@ -79,6 +79,7 @@ typedef int (*fd_callback_t) (struct local_client * fd, char *buf, int len,
 
 /* One of these for each fd we are listening on */
 struct local_client {
+	struct dm_list list;
 	int fd;
 	enum { CLUSTER_MAIN_SOCK, CLUSTER_DATA_SOCK, LOCAL_RENDEZVOUS,
 		    LOCAL_SOCK, THREAD_PIPE, CLUSTER_INTERNAL } type;
-- 
2.6.3


