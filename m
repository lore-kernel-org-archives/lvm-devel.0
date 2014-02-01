From: Jonathan Brassow <jbrassow@redhat.com>
Date: Fri, 31 Jan 2014 18:03:10 -0600
Subject: [LVM PATCH 4/6] cache: Code changes to allow removal of cachepool LVs
In-Reply-To: <1391212992-3439-1-git-send-email-jbrassow@redhat.com>
References: <1391212992-3439-1-git-send-email-jbrassow@redhat.com>
Message-ID: <1391212992-3439-5-git-send-email-jbrassow@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

---
 lib/metadata/lv_manip.c |   27 +++++++++++++++++++--------
 1 files changed, 19 insertions(+), 8 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 7659c3d..abb7c6e 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -559,7 +559,8 @@ static int _release_and_discard_lv_segment_area(struct lv_segment *seg, uint32_t
 	}
 
 	if ((seg_lv(seg, s)->status & MIRROR_IMAGE) ||
-	    (seg_lv(seg, s)->status & THIN_POOL_DATA)) {
+	    (seg_lv(seg, s)->status & THIN_POOL_DATA) ||
+	    (seg_lv(seg, s)->status & CACHE_POOL_DATA)) {
 		if (!lv_reduce(seg_lv(seg, s), area_reduction))
 			return_0; /* FIXME: any upper level reporting */
 		return 1;
@@ -4552,6 +4553,7 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 	int format1_reload_required = 0;
 	int visible;
 	struct logical_volume *pool_lv = NULL;
+	struct lv_segment *cache_seg = NULL;
 	int ask_discard;
 
 	vg = lv->vg;
@@ -4596,6 +4598,12 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 	} else if (lv_is_thin_volume(lv))
 		pool_lv = first_seg(lv)->pool_lv;
 
+	if (lv_is_cache_pool_data(lv) || lv_is_cache_pool_metadata(lv)) {
+		log_error("Can't remove logical volume %s used by a cache_pool.",
+			  lv->name);
+		return 0;
+	}
+
 	if (lv->status & LOCKED) {
 		log_error("Can't remove locked LV %s", lv->name);
 		return 0;
@@ -4824,12 +4832,14 @@ int lv_remove_with_dependencies(struct cmd_context *cmd, struct logical_volume *
 	if (lv_is_used_thin_pool(lv) &&
 	    !_lv_remove_segs_using_this_lv(cmd, lv, force, level, "pool"))
 		return_0;
-
-	if (lv_is_thin_pool(lv) && lv->vg->pool_metadata_spare_lv) {
-		/* When removing last thin pool, remove also spare */
+	if ((lv_is_thin_pool(lv) || lv_is_cache_pool(lv)) &&
+	    lv->vg->pool_metadata_spare_lv) {
+		/* When removing last pool, also remove the spare */
 		is_last_pool = 1;
 		dm_list_iterate_items(lvl, &lv->vg->lvs)
-			if (lv_is_thin_pool(lvl->lv) && lvl->lv != lv) {
+			if ((lv_is_thin_pool(lvl->lv) ||
+			     lv_is_cache_pool(lvl->lv)) &&
+			    lvl->lv != lv) {
 				is_last_pool = 0;
 				break;
 			}
@@ -4842,9 +4852,10 @@ int lv_remove_with_dependencies(struct cmd_context *cmd, struct logical_volume *
 
 	if (lv_is_pool_metadata_spare(lv) &&
 	    (force == PROMPT) &&
-	    (yes_no_prompt("Removal of pool metadata spare logical volume \"%s\" "
-			   "disables automatic recovery attempts after damage "
-			   "to a thin pool. Proceed? [y/n]: ", lv->name) == 'n'))
+	    (yes_no_prompt("Removal of pool metadata spare logical volume"
+			   " \"%s\" disables automatic recovery attempts"
+			   " after damage to a thin or cache pool."
+			   " Proceed? [y/n]: ", lv->name) == 'n'))
 		goto no_remove;
 
 	return lv_remove_single(cmd, lv, force, 0);
-- 
1.7.7.6


