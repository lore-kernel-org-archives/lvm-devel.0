From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 20 Apr 2018 07:02:02 -0400
Subject: master - mirror: properly reload table for log init
Message-ID: <201804201102.w3KB22JG031243@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1693fef529e7e1536d91956cfc4256c98cae58ab
Commit:        1693fef529e7e1536d91956cfc4256c98cae58ab
Parent:        55d83f9f6ee1892d419bdd9d50c3450ac41f6749
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 29 23:26:22 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 20 12:15:36 2018 +0200

mirror: properly reload table for log init

Since mirror can be stacked, we need to properly reload whole
table stack, otherwice we may mishandle devices in dm table.
---
 WHATS_NEW             |    2 ++
 lib/metadata/mirror.c |   14 ++++++++++----
 2 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 6affa13..434f4a0 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,7 @@
 Version 2.02.178 - 
 =====================================
+  Reload whole device stack when reinitilizing mirror log.
+  Mirrors without monitoring are WARNING and not blocking on error.
   Detect too big region_size with clustered mirrors.
   Fix evaluation of maximal region size for mirror log.
   Enhance mirror log size estimation and use smaller size when possible.
diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index 6c8732b..e09103d 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -315,6 +315,7 @@ static int _write_log_header(struct cmd_context *cmd, struct logical_volume *lv)
  * Initialize mirror log contents
  */
 static int _init_mirror_log(struct cmd_context *cmd,
+			    struct logical_volume *lock_holder,
 			    struct logical_volume *log_lv, int in_sync,
 			    struct dm_list *tagsl, int remove_on_failure)
 {
@@ -346,7 +347,10 @@ static int _init_mirror_log(struct cmd_context *cmd,
 		}
 
 	/* store mirror log on disk(s) */
-	if (!vg_write(log_lv->vg) || !vg_commit(log_lv->vg))
+	if (!lock_holder) {
+		if (!vg_write(log_lv->vg) || !vg_commit(log_lv->vg))
+			return_0;
+	} else if (!lv_update_and_reload((struct logical_volume*) lock_holder))
 		return_0;
 
 	if (!activate_lv_excl_local(cmd, log_lv)) {
@@ -1021,7 +1025,9 @@ static int _remove_mirror_images(struct logical_volume *lv,
 	/* Mirror with only 1 area is 'in sync'. */
 	if (new_area_count == 1 && is_temporary_mirror_layer(lv)) {
 		detached_log_lv = detach_mirror_log(mirrored_seg);
-		if (!_init_mirror_log(lv->vg->cmd, detached_log_lv,
+		if (!_init_mirror_log(lv->vg->cmd,
+				      (struct logical_volume*)lv_lock_holder(mirrored_seg->lv),
+				      detached_log_lv,
 				      1, &lv->tags, 0)) {
 			/* As a result, unnecessary sync may run after
 			 * collapsing. But safe.*/
@@ -1822,7 +1828,7 @@ static struct logical_volume *_set_up_mirror_log(struct cmd_context *cmd,
 		}
 	}
 
-	if (!_init_mirror_log(cmd, log_lv, in_sync, &lv->tags, 1)) {
+	if (!_init_mirror_log(cmd, NULL, log_lv, in_sync, &lv->tags, 1)) {
 		log_error("Failed to initialise mirror log.");
 		return NULL;
 	}
@@ -1870,7 +1876,7 @@ struct logical_volume *prepare_mirror_log(struct logical_volume *lv,
 		goto out;
 	}
 
-	if (!_init_mirror_log(cmd, log_lv, in_sync, &lv->tags, 1)) {
+	if (!_init_mirror_log(cmd, NULL, log_lv, in_sync, &lv->tags, 1)) {
 		log_error("Failed to initialise mirror log.");
 		log_lv = NULL;
 		goto out;


