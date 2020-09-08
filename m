From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  8 Sep 2020 22:03:39 +0000 (GMT)
Subject: master - lvconvert: flip return value of _raid_split_image_conversion
Message-ID: <20200908220339.4D7CB386F038@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8d6f1f9768da5a66b8f5153d13c96f50f411155f
Commit:        8d6f1f9768da5a66b8f5153d13c96f50f411155f
Parent:        dddf63ebc397705dc04a548c7a80ad9cad5ce4c2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 4 20:55:02 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 8 21:23:03 2020 +0200

lvconvert: flip return value of _raid_split_image_conversion

Use '0' for error and '1' as success.
Also drop INTERNAL_ERROR from path - as this error
is ATM used for invalid devices.
(i.e. test lvconvert-raid1-split-trackchanges.sh)
---
 tools/lvconvert.c | 30 +++++++++++++++---------------
 1 file changed, 15 insertions(+), 15 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 0adc61e36..d420eb52f 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1167,7 +1167,7 @@ static int _raid_split_image_conversion(struct logical_volume *lv)
 	if (lv_is_raid_with_tracking(lv)) {
 		log_error("Conversion of tracking raid1 LV %s is not supported.",
 			  display_lvname(lv));
-		return 1;
+		return 0;
 	}
 
 	if (lv_is_raid_image(lv) &&
@@ -1175,19 +1175,19 @@ static int _raid_split_image_conversion(struct logical_volume *lv)
 		(void) dm_strncpy(raidlv_name, lv->name, s - lv->name);
 
 		if (!(tmp_lv = find_lv(lv->vg, raidlv_name))) {
-			log_error(INTERNAL_ERROR "Failed to find RaidLV of RAID subvolume %s.",
+			log_error("Failed to find RaidLV of RAID subvolume %s.",
 				  display_lvname(lv));
-			return 1;
+			return 0;
 		}
 
 		if (lv_is_raid_with_tracking(tmp_lv)) {
 			log_error("Conversion of tracked raid1 subvolume %s is not supported.",
 				  display_lvname(lv));
-			return 1;
+			return 0;
 		}
 	}
 
-	return 0;
+	return 1;
 }
 
 /*
@@ -1205,8 +1205,8 @@ static int _lvconvert_mirrors(struct cmd_context *cmd,
 	uint32_t new_mimage_count = 0;
 	uint32_t new_log_count = 0;
 
-	if (_raid_split_image_conversion(lv))
-		return 0;
+	if (!_raid_split_image_conversion(lv))
+		return_0;
 
 	if ((lp->corelog || lp->mirrorlog) && *lp->type_str && strcmp(lp->type_str, SEG_TYPE_NAME_MIRROR)) {
 		log_error("--corelog and --mirrorlog are only compatible with mirror devices.");
@@ -1321,8 +1321,8 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 	struct cmd_context *cmd = lv->vg->cmd;
 	struct lv_segment *seg = first_seg(lv);
 
-	if (_raid_split_image_conversion(lv))
-		return 0;
+	if (!_raid_split_image_conversion(lv))
+		return_0;
 
 	if (_linear_type_requested(lp->type_str)) {
 		if (arg_is_set(cmd, mirrors_ARG) && (arg_uint_value(cmd, mirrors_ARG, 0) != 0)) {
@@ -2725,8 +2725,8 @@ static int _lvconvert_to_thin_with_external(struct cmd_context *cmd,
 		.virtual_extents = lv->le_count,
 	};
 
-	if (_raid_split_image_conversion(lv))
-		return 0;
+	if (!_raid_split_image_conversion(lv))
+		return_0;
 
 	if (lv == thinpool_lv) {
 		log_error("Can't use same LV %s for thin pool and thin volume.",
@@ -3037,8 +3037,8 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 	struct id lockd_meta_id;
 	const char *str_seg_type = to_cachepool ? SEG_TYPE_NAME_CACHE_POOL : SEG_TYPE_NAME_THIN_POOL;
 
-	if (_raid_split_image_conversion(lv))
-		return 0;
+	if (!_raid_split_image_conversion(lv))
+		return_0;
 
 	if (lv_is_thin_pool(lv) || lv_is_cache_pool(lv)) {
 		log_error(INTERNAL_ERROR "LV %s is already a pool.", display_lvname(lv));
@@ -4463,7 +4463,7 @@ int lvconvert_cachevol_attach_single(struct cmd_context *cmd,
 		log_verbose("Redirecting operation to data sub LV %s.", display_lvname(lv));
 	}
 
-	if (_raid_split_image_conversion(lv))
+	if (!_raid_split_image_conversion(lv))
 		goto_bad;
 
 	/* Attach the cache to the main LV. */
@@ -4580,7 +4580,7 @@ static int _lvconvert_cachepool_attach_single(struct cmd_context *cmd,
 		log_verbose("Redirecting operation to data sub LV %s.", display_lvname(lv));
 	}
 
-	if (_raid_split_image_conversion(lv))
+	if (!_raid_split_image_conversion(lv))
 		goto_out;
 
 	/* Attach the cache to the main LV. */


