From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 22 Jan 2021 15:10:00 +0000 (GMT)
Subject: main - pools: fix removal of spare volume
Message-ID: <20210122151000.45A54398D000@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4b8e5ad595aefb6e3e389051b9a374cc0d1a02a5
Commit:        4b8e5ad595aefb6e3e389051b9a374cc0d1a02a5
Parent:        9ae1935b74cc2336a19bcaee8703f6d22d1ee837
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jan 22 14:31:12 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jan 22 15:30:37 2021 +0100

pools: fix removal of spare volume

When removing pool LV from a stacked LV setup, it's been possible
to leak _pmspare and such hidden LV then required manual
user removal.

Fix it by moving automatic removal into _lv_reduce().
---
 lib/metadata/lv_manip.c | 48 ++++++++++++++++++++++++------------------------
 1 file changed, 24 insertions(+), 24 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 443d32c57..c740ba2bd 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1470,6 +1470,8 @@ static int _lv_reduce(struct logical_volume *lv, uint32_t extents, int delete)
 	struct logical_volume *external_lv = NULL;
 	int is_raid10 = 0;
 	uint32_t data_copies = 0;
+	struct lv_list *lvl;
+	int is_last_pool = lv_is_pool(lv);
 
 	if (!dm_list_empty(&lv->segments)) {
 		seg = first_seg(lv);
@@ -1581,6 +1583,28 @@ static int _lv_reduce(struct logical_volume *lv, uint32_t extents, int delete)
 	    !lv_update_and_reload(external_lv))
 		return_0;
 
+	/* When removing last pool, automatically drop the spare volume */
+	if (is_last_pool && lv->vg->pool_metadata_spare_lv) {
+		/* TODO: maybe use a list of pools or a counter to avoid linear search through VG */
+		dm_list_iterate_items(lvl, &lv->vg->lvs)
+			if (lv_is_thin_type(lvl->lv) ||
+			    lv_is_cache_type(lvl->lv)) {
+				is_last_pool = 0;
+				break;
+			}
+
+		if (is_last_pool) {
+			/* This is purely internal LV volume, no question */
+			if (!deactivate_lv(lv->vg->cmd, lv->vg->pool_metadata_spare_lv)) {
+				log_error("Unable to deactivate spare logical volume %s.",
+					  display_lvname(lv->vg->pool_metadata_spare_lv));
+				return 0;
+			}
+			if (!lv_remove(lv->vg->pool_metadata_spare_lv))
+				return_0;
+		}
+	}
+
 	return 1;
 }
 
@@ -6433,10 +6457,8 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 	struct logical_volume *lock_lv = lv;
 	struct lv_segment *cache_seg = NULL;
 	int ask_discard;
-	struct lv_list *lvl;
 	struct seg_list *sl;
 	struct lv_segment *seg = first_seg(lv);
-	int is_last_pool = lv_is_pool(lv);
 
 	vg = lv->vg;
 
@@ -6558,9 +6580,6 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 		 */
 		struct logical_volume *cachevol_lv = first_seg(lv)->pool_lv;
 
-		if (lv_is_cache_pool(cachevol_lv))
-			is_last_pool = 1;
-
 		if (!archive(vg))
 			return_0;
 
@@ -6667,25 +6686,6 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 		return 0;
 	}
 
-	if (is_last_pool && vg->pool_metadata_spare_lv) {
-		/* When removed last pool, also remove the spare */
-		dm_list_iterate_items(lvl, &vg->lvs)
-			if (lv_is_pool_metadata(lvl->lv)) {
-				is_last_pool = 0;
-				break;
-			}
-		if (is_last_pool) {
-			/* This is purely internal LV volume, no question */
-			if (!deactivate_lv(cmd, vg->pool_metadata_spare_lv)) {
-				log_error("Unable to deactivate spare logical volume %s.",
-					  display_lvname(vg->pool_metadata_spare_lv));
-				return 0;
-			}
-			if (!lv_remove(vg->pool_metadata_spare_lv))
-				return_0;
-		}
-	}
-
 	/* store it on disks */
 	if (!vg_write(vg) || !vg_commit(vg))
 		return_0;


