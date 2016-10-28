From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Fri, 28 Oct 2016 13:55:58 +0000 (UTC)
Subject: master - lvconvert: prevent non-synced raid1 primary leg repair
Message-ID: <20161028135558.2159960CE0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8270ff5702e0fa846714ac7366aade84b3e85209
Commit:        8270ff5702e0fa846714ac7366aade84b3e85209
Parent:        e118b65d651d921390d3e8bbcac7170c3894d048
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Oct 28 15:54:27 2016 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Oct 28 15:55:10 2016 +0200

lvconvert: prevent non-synced raid1 primary leg repair

(Automatic) repair may not be allowed during the initial sync of an upconverted
linear LV, because the data on the failing, primary leg hasn't been completely
synchronized to the N-1 other legs of the raid1 LV (replacing failed legs during
repair involves discontinuing access to any replaced legs data, thus preventing
data recovery on the primary leg e.g. via dd_rescue).

Even though repair would not cause data loss when adding legs to a fully synced
raid1 LV, we don't have information yet defining this state yet (e.g. a raid1
LV flag telling the fully synchronized status before any legs were added),
hence can't automatically decide to allow to repair.

If nonetheless a repair on a non-synced raid1 LVs is intended, the "--force"
option has to be provided.

Resolves: rhbz1311765
---
 WHATS_NEW                        |    1 +
 lib/metadata/metadata-exported.h |    4 +-
 lib/metadata/raid_manip.c        |   60 ++++++++++++++++++++++++++-----------
 tools/lvconvert.c                |    4 +-
 4 files changed, 47 insertions(+), 22 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 1d0d6dc..49af38a 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.167 - 
 ======================================
+  Prevent non-synced raid1 repair unless --force
   Prevent raid4 creation/conversion on non-supporting kernels
   Add direct striped -> raid4 conversion
   Fix raid4 parity image pair position on conversions from striped/raid0*
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 37db89c..cdd4984 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1208,8 +1208,8 @@ int lv_raid_convert(struct logical_volume *lv,
 		    const uint32_t new_region_size,
 		    struct dm_list *allocate_pvs);
 int lv_raid_rebuild(struct logical_volume *lv, struct dm_list *rebuild_pvs);
-int lv_raid_replace(struct logical_volume *lv, struct dm_list *remove_pvs,
-		    struct dm_list *allocate_pvs);
+int lv_raid_replace(struct logical_volume *lv, int force,
+		    struct dm_list *remove_pvs, struct dm_list *allocate_pvs);
 int lv_raid_remove_missing(struct logical_volume *lv);
 int partial_raid_lv_supports_degraded_activation(const struct logical_volume *lv);
 /* --  metadata/raid_manip.c */
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 25547c4..d15baf6 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -266,19 +266,16 @@ static int _deactivate_and_remove_lvs(struct volume_group *vg, struct dm_list *r
  *
  * Returns: 1 if in-sync, 0 otherwise.
  */
+#define _RAID_IN_SYNC_RETRIES  6
 static int _raid_in_sync(struct logical_volume *lv)
 {
+	int retries = _RAID_IN_SYNC_RETRIES;
 	dm_percent_t sync_percent;
 
 	if (seg_is_striped(first_seg(lv)))
 		return 1;
 
-	if (!lv_raid_percent(lv, &sync_percent)) {
-		log_error("Unable to determine sync status of %s/%s.",
-			  lv->vg->name, lv->name);
-		return 0;
-	}
-	if (sync_percent == DM_PERCENT_0) {
+	do {
 		/*
 		 * FIXME We repeat the status read here to workaround an
 		 * unresolved kernel bug when we see 0 even though the
@@ -290,14 +287,31 @@ static int _raid_in_sync(struct logical_volume *lv)
 				  lv->vg->name, lv->name);
 			return 0;
 		}
-		if (sync_percent == DM_PERCENT_100)
+		if (sync_percent > DM_PERCENT_0)
+			break;
+		if (retries == _RAID_IN_SYNC_RETRIES)
 			log_warn("WARNING: Sync status for %s is inconsistent.",
 				 display_lvname(lv));
-	}
+		usleep(500000);
+	} while (--retries);
 
 	return (sync_percent == DM_PERCENT_100) ? 1 : 0;
 }
 
+/* Check if RaidLV @lv is synced or any raid legs of @lv are not synced */
+static int _raid_devs_sync_healthy(struct logical_volume *lv)
+{
+	char *raid_health;
+
+	if (!_raid_in_sync(lv))
+		return 0;
+
+	if (!lv_raid_dev_health(lv, &raid_health))
+		return_0;
+
+	return (strchr(raid_health, 'a') || strchr(raid_health, 'D')) ? 0 : 1;
+}
+
 /*
  * _raid_remove_top_layer
  * @lv
@@ -1054,6 +1068,7 @@ static int _extract_image_components(struct lv_segment *seg, uint32_t idx,
 /*
  * _raid_extract_images
  * @lv
+ * @force: force a replacement in case of primary mirror leg
  * @new_count:  The absolute count of images (e.g. '2' for a 2-way mirror)
  * @target_pvs:  The list of PVs that are candidates for removal
  * @shift:  If set, use _shift_and_rename_image_components().
@@ -1068,7 +1083,8 @@ static int _extract_image_components(struct lv_segment *seg, uint32_t idx,
  *
  * Returns: 1 on success, 0 on failure
  */
-static int _raid_extract_images(struct logical_volume *lv, uint32_t new_count,
+static int _raid_extract_images(struct logical_volume *lv,
+				int force, uint32_t new_count,
 				struct dm_list *target_pvs, int shift,
 				struct dm_list *extracted_meta_lvs,
 				struct dm_list *extracted_data_lvs)
@@ -1136,11 +1152,16 @@ static int _raid_extract_images(struct logical_volume *lv, uint32_t new_count,
 			    !lv_is_on_pvs(seg_metalv(seg, s), target_pvs))
 				continue;
 
-			if (!_raid_in_sync(lv) &&
-			    (!seg_is_mirrored(seg) || (s == 0))) {
+			/*
+			 * Kernel may report raid LV in-sync but still
+			 * image devices may not be in-sync or faulty.
+			 */
+			if (!_raid_devs_sync_healthy(lv) &&
+			    (!seg_is_mirrored(seg) || (s == 0 && !force))) {
 				log_error("Unable to extract %sRAID image"
-					  " while RAID array is not in-sync",
-					  seg_is_mirrored(seg) ? "primary " : "");
+					  " while RAID array is not in-sync%s",
+					  seg_is_mirrored(seg) ? "primary " : "",
+					  seg_is_mirrored(seg) ? " (use --force option to replace)" : "");
 				return 0;
 			}
 		}
@@ -1185,7 +1206,7 @@ static int _raid_remove_images(struct logical_volume *lv,
 	if (!removal_lvs)
 		removal_lvs = &removed_lvs;
 
-	if (!_raid_extract_images(lv, new_count, allocate_pvs, 1,
+	if (!_raid_extract_images(lv, 0, new_count, allocate_pvs, 1,
 				 removal_lvs, removal_lvs)) {
 		log_error("Failed to extract images from %s/%s",
 			  lv->vg->name, lv->name);
@@ -1375,7 +1396,7 @@ int lv_raid_split(struct logical_volume *lv, const char *split_name,
 			return_0;
 	}
 
-	if (!_raid_extract_images(lv, new_count, splittable_pvs, 1,
+	if (!_raid_extract_images(lv, 0, new_count, splittable_pvs, 1,
 				 &removal_lvs, &data_list)) {
 		log_error("Failed to extract images from %s/%s",
 			  lv->vg->name, lv->name);
@@ -3869,6 +3890,7 @@ has_enough_space:
  * new SubLVS are allocated on PVs on list @allocate_pvs.
  */
 static int _lv_raid_rebuild_or_replace(struct logical_volume *lv,
+				       int force,
 				       struct dm_list *remove_pvs,
 				       struct dm_list *allocate_pvs,
 				       int rebuild)
@@ -4043,7 +4065,8 @@ try_again:
 	 *   supplied - knowing that only the image with the error target
 	 *   will be affected.
 	 */
-	if (!_raid_extract_images(lv, raid_seg->area_count - match_count,
+	if (!_raid_extract_images(lv, force,
+				  raid_seg->area_count - match_count,
 				  partial_segment_removed ?
 				  &lv->vg->pvs : remove_pvs, 0,
 				  &old_lvs, &old_lvs)) {
@@ -4148,7 +4171,7 @@ skip_alloc:
 int lv_raid_rebuild(struct logical_volume *lv,
 		    struct dm_list *rebuild_pvs)
 {
-	return _lv_raid_rebuild_or_replace(lv, rebuild_pvs, NULL, 1);
+	return _lv_raid_rebuild_or_replace(lv, 0, rebuild_pvs, NULL, 1);
 }
 
 /*
@@ -4161,10 +4184,11 @@ int lv_raid_rebuild(struct logical_volume *lv,
  * allocating new SubLVs from PVs on list @allocate_pvs.
  */
 int lv_raid_replace(struct logical_volume *lv,
+		    int force,
 		    struct dm_list *remove_pvs,
 		    struct dm_list *allocate_pvs)
 {
-	return _lv_raid_rebuild_or_replace(lv, remove_pvs, allocate_pvs, 0);
+	return _lv_raid_rebuild_or_replace(lv, force, remove_pvs, allocate_pvs, 0);
 }
 
 int lv_raid_remove_missing(struct logical_volume *lv)
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 23b5906..8376565 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1994,7 +1994,7 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 	}
 
 	if (lp->replace)
-		return lv_raid_replace(lv, lp->replace_pvh, lp->pvh);
+		return lv_raid_replace(lv, lp->force, lp->replace_pvh, lp->pvh);
 
 	if (lp->repair) {
 		if (!lv_is_active_exclusive_locally(lv_lock_holder(lv))) {
@@ -2017,7 +2017,7 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 			if (!(failed_pvs = _failed_pv_list(lv->vg)))
 				return_0;
 
-			if (!lv_raid_replace(lv, failed_pvs, lp->pvh)) {
+			if (!lv_raid_replace(lv, lp->force, failed_pvs, lp->pvh)) {
 				log_error("Failed to replace faulty devices in %s.",
 					  display_lvname(lv));
 				return 0;


