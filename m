From: Alasdair Kergon <agk@sourceware.org>
Date: Fri, 30 Jun 2017 21:00:39 -0400
Subject: master - clvmd: Fix client list corruption
Message-ID: <201707010100.v6110dOc029619@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f2eda36cfa9baf3f7e132dbc3a3f34c908cb36d4
Commit:        f2eda36cfa9baf3f7e132dbc3a3f34c908cb36d4
Parent:        af789fd6d0cba45cc4897772bae3ca73a3f15b38
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Sat Jul 1 01:34:38 2017 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Sat Jul 1 01:34:38 2017 +0100

clvmd: Fix client list corruption

Centralise editing of the client list into _add_client() and
_del_client().  Introduce _local_client_count to track the size of the
list for debugging purposes.  Simplify and standardise the various ways
the list gets walked.

While processing one element of the list in main_loop(),
cleanup_zombie() may be called and remove a different element, so make
sure main_loop() refreshes its list state on return.  Prior to this
patch, the list edits for clients disappearing could race against the
list edits for new clients connecting and corrupt the list and cause a
variety of segfaults.

An easy way to trigger such failures was by repeatedly running shell
commands such as:
  lvs &; lvs &; lvs &;...;killall -9 lvs; lvs &; lvs &;...

Situations that occasionally lead to the failures can be spotted by
looking for 'EOF' with 'inprogress=1' in the clvmd debug logs.
---
 WHATS_NEW             |    1 +
 daemons/clvmd/clvmd.c |   90 ++++++++++++++++++++++++++++++-------------------
 2 files changed, 56 insertions(+), 35 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 29f07b8..3e72d83 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.173 - 
 =================================
+  Tidy clvmd client list processing and fix segfaults.
   Protect clvmd debug log messages with mutex and add client id.
   Fix shellcheck reported issues for script files.
 
diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index a8a121c..881a931 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -58,6 +58,7 @@
 /* Head of the fd list. Also contains
    the cluster_socket details */
 static struct local_client local_client_head;
+static int _local_client_count = 0;
 
 static unsigned short global_xid = 0;	/* Last transaction ID issued */
 
@@ -68,6 +69,37 @@ static unsigned max_csid_len;
 static unsigned max_cluster_message;
 static unsigned max_cluster_member_name_len;
 
+static void _add_client(struct local_client *new_client, struct local_client *existing_client)
+{
+	_local_client_count++;
+	DEBUGLOG("(%p) Adding listener for fd %d. (Now %d monitored fds.)\n", new_client, new_client->fd, _local_client_count);
+	new_client->next = existing_client->next;
+	existing_client->next = new_client;
+}
+
+int add_client(struct local_client *new_client)
+{
+	_add_client(new_client, &local_client_head);
+
+	return 0;
+}
+
+/* Returns 0 if delfd is found and removed from list */
+static int _del_client(struct local_client *delfd)
+{
+	struct local_client *lastfd, *thisfd;
+
+	for (lastfd = &local_client_head; (thisfd = lastfd->next); lastfd = thisfd)
+		if (thisfd == delfd) {
+			DEBUGLOG("(%p) Removing listener for fd %d\n", thisfd, thisfd->fd);
+			lastfd->next = delfd->next;
+			_local_client_count--;
+			return 0;
+		}
+
+	return 1;
+}
+
 /* Structure of items on the LVM thread list */
 struct lvm_thread_cmd {
 	struct dm_list list;
@@ -590,6 +622,7 @@ int main(int argc, char *argv[])
 	local_client_head.fd = clops->get_main_cluster_fd();
 	local_client_head.type = CLUSTER_MAIN_SOCK;
 	local_client_head.callback = clops->cluster_fd_callback;
+	_local_client_count++;
 
 	/* Add the local socket to the list */
 	if (!(newfd = dm_zalloc(sizeof(struct local_client)))) {
@@ -600,8 +633,8 @@ int main(int argc, char *argv[])
 	newfd->fd = local_sock;
 	newfd->type = LOCAL_RENDEZVOUS;
 	newfd->callback = local_rendezvous_callback;
-	newfd->next = local_client_head.next;
-	local_client_head.next = newfd;
+
+	(void) add_client(newfd);
 
 	/* This needs to be started after cluster initialisation
 	   as it may need to take out locks */
@@ -643,6 +676,7 @@ int main(int argc, char *argv[])
 
 	while ((delfd = local_client_head.next)) {
 		local_client_head.next = delfd->next;
+		_local_client_count--;
 		/* Failing cleanup_zombie leaks... */
 		if (delfd->type == LOCAL_SOCK && !cleanup_zombie(delfd))
 			cmd_client_cleanup(delfd); /* calls sync_unlock */
@@ -859,13 +893,11 @@ static void main_loop(int cmd_timeout)
 	while (!quit) {
 		fd_set in;
 		int select_status;
-		struct local_client *thisfd;
+		struct local_client *thisfd, *nextfd;
 		struct timeval tv = { cmd_timeout, 0 };
 		int quorate = clops->is_quorate();
 		int client_count = 0;
 		int max_fd = 0;
-		struct local_client *lastfd = &local_client_head;
-		struct local_client *nextfd = local_client_head.next;
 
 		/* Wait on the cluster FD and all local sockets/pipes */
 		local_client_head.fd = clops->get_main_cluster_fd();
@@ -881,20 +913,20 @@ static void main_loop(int cmd_timeout)
  			fprintf(stderr, "WARNING: Your cluster may freeze up if the number of clvmd file descriptors (%d) exceeds %d.\n", max_fd + 1, FD_SETSIZE);
 		}
 
-		for (thisfd = &local_client_head; thisfd; thisfd = nextfd, nextfd = thisfd ? thisfd->next : NULL) {
+		for (thisfd = &local_client_head; thisfd; thisfd = nextfd) {
+			nextfd = thisfd->next;
 
 			if (thisfd->removeme && !cleanup_zombie(thisfd)) {
-				struct local_client *free_fd = thisfd;
-				lastfd->next = nextfd;
-				DEBUGLOG("(%p) removeme set with %d monitored fds remaining\n", thisfd, client_count - 1);
+				/* cleanup_zombie might have removed the next list element */
+				nextfd = thisfd->next;
 
-				/* Queue cleanup, this also frees the client struct */
-				add_to_lvmqueue(free_fd, NULL, 0, NULL);
+				(void) _del_client(thisfd);
 
-				continue;
-			}
+				DEBUGLOG("(%p) removeme set with %d monitored fds remaining\n", thisfd, _local_client_count);
 
-			lastfd = thisfd;
+				/* Queue cleanup, this also frees the client struct */
+				add_to_lvmqueue(thisfd, NULL, 0, NULL);
+			}
 
 			if (thisfd->removeme)
 				continue;
@@ -953,8 +985,7 @@ static void main_loop(int cmd_timeout)
 
 					/* New client...simply add it to the list */
 					if (newfd) {
-						newfd->next = thisfd->next;
-						thisfd->next = newfd;
+						_add_client(newfd, thisfd);
 						thisfd = newfd;
 					}
 				}
@@ -1225,20 +1256,16 @@ static int cleanup_zombie(struct local_client *thisfd)
 
 		/* Remove the pipe client */
 		if (thisfd->bits.localsock.pipe_client) {
-			struct local_client *delfd;
-			struct local_client *lastfd;
+			struct local_client *delfd = thisfd->bits.localsock.pipe_client;
 
-			(void) close(thisfd->bits.localsock.pipe_client->fd);	/* Close pipe */
+			(void) close(delfd->fd);	/* Close pipe */
 			(void) close(thisfd->bits.localsock.pipe);
 
 			/* Remove pipe client */
-			for (lastfd = &local_client_head; (delfd = lastfd->next); lastfd = delfd)
-				if (thisfd->bits.localsock.pipe_client == delfd) {
-					thisfd->bits.localsock.pipe_client = NULL;
-					lastfd->next = delfd->next;
-					dm_free(delfd);
-					break;
-				}
+			if (!_del_client(delfd)) {
+				dm_free(delfd);
+				thisfd->bits.localsock.pipe_client = NULL;
+			}
 		}
 	}
 
@@ -1436,8 +1463,8 @@ static int read_from_local_sock(struct local_client *thisfd)
 	newfd->type = THREAD_PIPE;
 	newfd->callback = local_pipe_callback;
 	newfd->bits.pipe.client = thisfd;
-	newfd->next = thisfd->next;
-	thisfd->next = newfd;
+
+	_add_client(newfd, thisfd);
 
 	/* Store a cross link to the pipe */
 	thisfd->bits.localsock.pipe_client = newfd;
@@ -1461,13 +1488,6 @@ static int read_from_local_sock(struct local_client *thisfd)
 /* Add a file descriptor from the cluster or comms interface to
    our list of FDs for select
 */
-int add_client(struct local_client *new_client)
-{
-	new_client->next = local_client_head.next;
-	local_client_head.next = new_client;
-
-	return 0;
-}
 
 /* Called when the pre-command has completed successfully - we
    now execute the real command on all the requested nodes */


