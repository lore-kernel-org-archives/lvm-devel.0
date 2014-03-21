From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 21 Mar 2014 21:31:29 +0000 (UTC)
Subject: master - clvmd: fix clean memory on exit
Message-ID: <20140321213129.BC91160919@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5bea2b5c8208db7c0277d7bd8672a4db26fbf6d6
Commit:        5bea2b5c8208db7c0277d7bd8672a4db26fbf6d6
Parent:        486b15d36ce672f78a35143ce6bb12c48552fbf8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 21 17:07:57 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 21 22:29:22 2014 +0100

clvmd: fix clean memory on exit

Properly clean 'client' structure only for LOCAL_SOCK type.
(Fixes bug from commit 460c19df621d35260caceec7f598da1566263cd4)
(in release fix)

Also cleanup-up associated pthreads by using cleanup_zombie() function.
Since this function may change the list, restart scanning always from
the list header.

Note: couple following patches are necessary to make this working properly.
---
 daemons/clvmd/clvmd.c |   19 +++++++------------
 1 files changed, 7 insertions(+), 12 deletions(-)

diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index ddebc15..00945da 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -625,18 +625,13 @@ int main(int argc, char *argv[])
 	close_local_sock(local_sock);
 	destroy_lvm();
 
-	for (newfd = local_client_head.next; newfd != NULL;) {
-		delfd = newfd;
-		newfd = newfd->next;
-		if (delfd->fd == local_sock)
-			delfd->fd = -1;
-		/*
-		 * FIXME:
-		 * needs cleanup code from read_from_local_sock() for now
-		 * break of 'clvmd' may access already free memory here.
-		 */
-		safe_close(&(delfd->fd));
-		cmd_client_cleanup(delfd);
+	while ((delfd = local_client_head.next)) {
+		local_client_head.next = delfd->next;
+		/* Failing cleanup_zombie leaks... */
+		if (delfd->type == LOCAL_SOCK && !cleanup_zombie(delfd))
+			cmd_client_cleanup(delfd); /* calls sync_unlock */
+		if (delfd->fd != local_sock)
+			safe_close(&(delfd->fd));
 		dm_free(delfd);
 	}
 


