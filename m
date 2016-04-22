From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 22 Apr 2016 12:16:20 +0000 (UTC)
Subject: master - coverity: ignore some dm_strncpy results
Message-ID: <20160422121620.E67BF60DFC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bc239f15eb935f7962def5b8fde22b64b0b86b4f
Commit:        bc239f15eb935f7962def5b8fde22b64b0b86b4f
Parent:        d12ba022c8082de2d804010992c6ee1076b9f571
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 22 14:06:15 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 22 14:15:36 2016 +0200

coverity: ignore some dm_strncpy results

Using them only for debug so ignorable.
Also don't mark stack char buffer alignment, compiler already knows
what's the best here.
---
 lib/cache/lvmetad.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 8d13a59..8a1a2c5 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -2028,8 +2028,8 @@ static void _update_changed_pvs_in_udev(struct cmd_context *cmd,
 {
 	struct pv_cache_list *before;
 	struct pv_cache_list *after;
-	char id_before[ID_LEN + 1]  __attribute__((aligned(8)));
-	char id_after[ID_LEN + 1]  __attribute__((aligned(8)));
+	char id_before[ID_LEN + 1];
+	char id_after[ID_LEN + 1];
 	int found;
 
 	dm_list_iterate_items(before, pvc_before) {
@@ -2043,8 +2043,8 @@ static void _update_changed_pvs_in_udev(struct cmd_context *cmd,
 				continue;
 
 			if (!id_equal(&before->pvid, &after->pvid)) {
-				dm_strncpy(id_before, (char *) &before->pvid, sizeof(id_before));
-				dm_strncpy(id_after, (char *) &after->pvid, sizeof(id_after));
+				(void) dm_strncpy(id_before, (char *) &before->pvid, sizeof(id_before));
+				(void) dm_strncpy(id_after, (char *) &after->pvid, sizeof(id_after));
 
 				log_debug_devs("device %d:%d changed pvid from %s to %s",
 					       (int)MAJOR(before->devt), (int)MINOR(before->devt),
@@ -2070,7 +2070,7 @@ static void _update_changed_pvs_in_udev(struct cmd_context *cmd,
 		}
 
 		if (!found) {
-			dm_strncpy(id_before, (char *) &before->pvid, sizeof(id_before));
+			(void) dm_strncpy(id_before, (char *) &before->pvid, sizeof(id_before));
 
 			log_debug_devs("device %d:%d pvid %s vg %s is gone",
 				       (int)MAJOR(before->devt), (int)MINOR(before->devt),


