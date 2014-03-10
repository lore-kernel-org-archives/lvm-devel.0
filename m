From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 10 Mar 2014 11:26:54 +0000 (UTC)
Subject: master - clvmd: use dm_zalloc for socket allocation
Message-ID: <20140310112654.49BC060CD3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=38ce06e448d54b21c214c174b08b45a18de2ac88
Commit:        38ce06e448d54b21c214c174b08b45a18de2ac88
Parent:        bfffccca948a526ad907c9d7d1b7de7850a48628
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Mar 8 22:55:47 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 10 12:20:49 2014 +0100

clvmd: use dm_zalloc for socket allocation

Instead of doing individual settings for struct members,
ensure whole struct is in defined state.
---
 WHATS_NEW             |    1 +
 daemons/clvmd/clvmd.c |   21 +++------------------
 2 files changed, 4 insertions(+), 18 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index f72587a..379117c 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.106 - 
 ====================================
+  Use dm_zalloc to clear members of clvmd client struct.
   Use BLKID_CFLAGS when compiling with blkid support.
   Use correct rl_completion_func_t typedef for new readline.
   Make lvm 'dumpconfig --type default' complete for it to be consumed by lvm.
diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index fc8cf6e..3d9bce7 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -578,14 +578,12 @@ int main(int argc, char *argv[])
 	local_client_head.callback = clops->cluster_fd_callback;
 
 	/* Add the local socket to the list */
-	newfd = malloc(sizeof(struct local_client));
-	if (!newfd) {
+	if (!(newfd = dm_zalloc(sizeof(struct local_client)))) {
 		child_init_signal_and_exit(DFAIL_MALLOC);
 		/* NOTREACHED */
 	}
 
 	newfd->fd = local_sock;
-	newfd->removeme = 0;
 	newfd->type = LOCAL_RENDEZVOUS;
 	newfd->callback = local_rendezvous_callback;
 	newfd->next = local_client_head.next;
@@ -635,7 +633,7 @@ int main(int argc, char *argv[])
 		 * break of 'clvmd' may access already free memory here.
 		 */
 		safe_close(&(delfd->fd));
-		free(delfd);
+		dm_free(delfd);
 	}
 
 	ret = 0;
@@ -677,8 +675,7 @@ static int local_rendezvous_callback(struct local_client *thisfd, char *buf,
 		return 1;
 
 	if (client_fd >= 0) {
-		newfd = malloc(sizeof(struct local_client));
-		if (!newfd) {
+		if (!(newfd = dm_zalloc(sizeof(struct local_client)))) {
 			if (close(client_fd))
                                 log_sys_error("close", "socket");
 			return 1;
@@ -689,19 +686,7 @@ static int local_rendezvous_callback(struct local_client *thisfd, char *buf,
 
 		newfd->fd = client_fd;
 		newfd->type = LOCAL_SOCK;
-		newfd->xid = 0;
-		newfd->removeme = 0;
 		newfd->callback = local_sock_callback;
-		newfd->bits.localsock.replies = NULL;
-		newfd->bits.localsock.expected_replies = 0;
-		newfd->bits.localsock.cmd = NULL;
-		newfd->bits.localsock.in_progress = FALSE;
-		newfd->bits.localsock.sent_out = FALSE;
-		newfd->bits.localsock.threadid = 0;
-		newfd->bits.localsock.finished = 0;
-		newfd->bits.localsock.cleanup_needed = 0;
-		newfd->bits.localsock.pipe_client = NULL;
-		newfd->bits.localsock.private = NULL;
 		newfd->bits.localsock.all_success = 1;
 		DEBUGLOG("Got new connection on fd %d\n", newfd->fd);
 		*new_client = newfd;


