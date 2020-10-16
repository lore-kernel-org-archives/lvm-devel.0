From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Oct 2020 19:11:06 +0000 (GMT)
Subject: stable-2.02 - lvconvert: flip return value of _raid_split_image_conversion
Message-ID: <20201016191106.7103C396EC72@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d063ea27b46f2c3e2575a55576ea15e5957657c6
Commit:        d063ea27b46f2c3e2575a55576ea15e5957657c6
Parent:        0bd9eb80c9037da729891ab1bee4d6026ac4a5ac
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 4 20:55:02 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 16 17:07:58 2020 +0200

lvconvert: flip return value of _raid_split_image_conversion

Use '0' for error and '1' as success.
Also drop INTERNAL_ERROR from path - as this error
is ATM used for invalid devices.
(i.e. test lvconvert-raid1-split-trackchanges.sh)
---
 tools/lvconvert.c | 30 +++++++++++++++---------------
 1 file changed, 15 insertions(+), 15 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 014163f49..4da9655e8 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1179,7 +1179,7 @@ static int _raid_split_image_conversion(struct logical_volume *lv)
 	if (lv_is_raid_with_tracking(lv)) {
 		log_error("Conversion of tracking raid1 LV %s is not supported.",
 			  display_lvname(lv));
-		return 1;
+		return 0;
 	}
 
 	if (lv_is_raid_image(lv) &&
@@ -1187,19 +1187,19 @@ static int _raid_split_image_conversion(struct logical_volume *lv)
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
@@ -1217,8 +1217,8 @@ static int _lvconvert_mirrors(struct cmd_context *cmd,
 	uint32_t new_mimage_count = 0;
 	uint32_t new_log_count = 0;
 
-	if (_raid_split_image_conversion(lv))
-		return 0;
+	if (!_raid_split_image_conversion(lv))
+		return_0;
 
 	if ((lp->corelog || lp->mirrorlog) && *lp->type_str && strcmp(lp->type_str, SEG_TYPE_NAME_MIRROR)) {
 		log_error("--corelog and --mirrorlog are only compatible with mirror devices.");
@@ -1337,8 +1337,8 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 	struct cmd_context *cmd = lv->vg->cmd;
 	struct lv_segment *seg = first_seg(lv);
 
-	if (_raid_split_image_conversion(lv))
-		return 0;
+	if (!_raid_split_image_conversion(lv))
+		return_0;
 
 	if (_linear_type_requested(lp->type_str)) {
 		if (arg_is_set(cmd, mirrors_ARG) && (arg_uint_value(cmd, mirrors_ARG, 0) != 0)) {
@@ -2633,8 +2633,8 @@ static int _lvconvert_to_thin_with_external(struct cmd_context *cmd,
 		.virtual_extents = lv->le_count,
 	};
 
-	if (_raid_split_image_conversion(lv))
-		return 0;
+	if (!_raid_split_image_conversion(lv))
+		return_0;
 
 	if (lv == thinpool_lv) {
 		log_error("Can't use same LV %s for thin pool and thin volume.",
@@ -2945,8 +2945,8 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 	struct id lockd_meta_id;
 	const char *str_seg_type = to_cachepool ? SEG_TYPE_NAME_CACHE_POOL : SEG_TYPE_NAME_THIN_POOL;
 
-	if (_raid_split_image_conversion(lv))
-		return 0;
+	if (!_raid_split_image_conversion(lv))
+		return_0;
 
 	if (lv_is_thin_pool(lv) || lv_is_cache_pool(lv)) {
 		log_error(INTERNAL_ERROR "LV %s is already a pool.", display_lvname(lv));
@@ -3399,8 +3399,8 @@ static int _lvconvert_to_cache_vol(struct cmd_context *cmd,
 	struct dm_config_tree *policy_settings = NULL;
 	int r = 0;
 
-	if (_raid_split_image_conversion(lv))
-		return 0;
+	if (!_raid_split_image_conversion(lv))
+		return_0;
 
 	/* If LV is inactive here, ensure it's not active elsewhere. */
 	if (!lockd_lv(cmd, lv, "ex", 0))


