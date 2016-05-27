From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 27 May 2016 13:47:58 +0000 (UTC)
Subject: master - debug: use display_lvname
Message-ID: <20160527134758.372E4607A7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=090ecaabed9df1ead8781c6d504e1fe38ebcf7a4
Commit:        090ecaabed9df1ead8781c6d504e1fe38ebcf7a4
Parent:        04003cf1ff1c4d00c0d155de6387cdd83478f812
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri May 20 11:28:23 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 27 15:47:24 2016 +0200

debug: use display_lvname

---
 lib/metadata/cache_manip.c |    5 ++++-
 lib/metadata/lv_manip.c    |   34 +++++++++++++++++-----------------
 2 files changed, 21 insertions(+), 18 deletions(-)

diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index 4d84fe1..275696e 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -340,6 +340,7 @@ int lv_cache_wait_for_clean(struct logical_volume *cache_lv, int *is_clean)
 	for (;;) {
 		if (!lv_cache_status(cache_lv, &status))
 			return_0;
+
 		if (status->cache->fail) {
 			dm_pool_destroy(status->mem);
 			log_warn("WARNING: Skippping flush for failed cache %s.",
@@ -422,7 +423,8 @@ int lv_cache_remove(struct logical_volume *cache_lv)
 	if (!lv_is_active_locally(cache_lv)) {
 		/* Give up any remote locks */
 		if (!deactivate_lv(cache_lv->vg->cmd, cache_lv)) {
-			log_error("Cannot deactivate remotely active cache lv.");
+			log_error("Cannot deactivate remotely active cache volume %s.",
+				  display_lvname(cache_lv));
 			return 0;
 		}
 
@@ -497,6 +499,7 @@ int lv_cache_remove(struct logical_volume *cache_lv)
 
 	if (!(cache_seg->areas = dm_pool_zalloc(cache_lv->vg->vgmem, sizeof(*cache_seg->areas))))
 		return_0;
+
 	if (!set_lv_segment_area_lv(cache_seg, 0, cache_lv, 0, 0))
 		return_0;
 
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index fdf0c86..b31676d 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5771,39 +5771,39 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 		return_0;
 
 	if (lv_is_origin(lv)) {
-		log_error("Can't remove logical volume \"%s\" under snapshot",
-			  lv->name);
+		log_error("Can't remove logical volume %s under snapshot.",
+			  display_lvname(lv));
 		return 0;
 	}
 
 	if (lv_is_external_origin(lv)) {
-		log_error("Can't remove external origin logical volume \"%s\".",
-			  lv->name);
+		log_error("Can't remove external origin logical volume %s.",
+			  display_lvname(lv));
 		return 0;
 	}
 
 	if (lv_is_mirror_image(lv)) {
-		log_error("Can't remove logical volume %s used by a mirror",
-			  lv->name);
+		log_error("Can't remove logical volume %s used by a mirror.",
+			  display_lvname(lv));
 		return 0;
 	}
 
 	if (lv_is_mirror_log(lv)) {
-		log_error("Can't remove logical volume %s used as mirror log",
-			  lv->name);
+		log_error("Can't remove logical volume %s used as mirror log.",
+			  display_lvname(lv));
 		return 0;
 	}
 
 	if (lv_is_raid_metadata(lv) || lv_is_raid_image(lv)) {
-		log_error("Can't remove logical volume %s used as RAID device",
-			  lv->name);
+		log_error("Can't remove logical volume %s used as RAID device.",
+			  display_lvname(lv));
 		return 0;
 	}
 
 	if (lv_is_thin_pool_data(lv) || lv_is_thin_pool_metadata(lv) ||
 	    lv_is_cache_pool_data(lv) || lv_is_cache_pool_metadata(lv)) {
 		log_error("Can't remove logical volume %s used by a pool.",
-			  lv->name);
+			  display_lvname(lv));
 		return 0;
 	} else if (lv_is_thin_volume(lv)) {
 		if (!(pool_lv = first_seg(lv)->pool_lv)) {
@@ -5815,7 +5815,7 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 	}
 
 	if (lv_is_locked(lv)) {
-		log_error("Can't remove locked LV %s", lv->name);
+		log_error("Can't remove locked logical volume %s.", display_lvname(lv));
 		return 0;
 	}
 
@@ -5838,8 +5838,8 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 					  "%slogical volume %s? [y/n]: ",
 					  ask_discard ? " and DISCARD" : "",
 					  vg_is_clustered(vg) ? "clustered " : "",
-					  lv->name) == 'n') {
-				log_error("Logical volume %s not removed", lv->name);
+					  display_lvname(lv)) == 'n') {
+				log_error("Logical volume %s not removed.", display_lvname(lv));
 				return 0;
 			} else {
 				ask_discard = 0;
@@ -5850,8 +5850,8 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 	if (!lv_is_historical(lv) && (force == PROMPT) && ask_discard &&
 	    yes_no_prompt("Do you really want to remove and DISCARD "
 			  "logical volume %s? [y/n]: ",
-			  lv->name) == 'n') {
-		log_error("Logical volume %s not removed", lv->name);
+			  display_lvname(lv)) == 'n') {
+		log_error("Logical volume %s not removed.", display_lvname(lv));
 		return 0;
 	}
 
@@ -5907,7 +5907,7 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 		if (!(lv->vg->fid->fmt->features & FMT_MDAS))
 			format1_origin = origin_from_cow(lv);
 
-		log_verbose("Removing snapshot %s", lv->name);
+		log_verbose("Removing snapshot volume %s.", display_lvname(lv));
 		/* vg_remove_snapshot() will preload origin/former snapshots */
 		if (!vg_remove_snapshot(lv))
 			return_0;


