From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Fri, 17 Mar 2017 09:15:37 -0400
Subject: master - raid: cleanup
Message-ID: <201703171315.v2HDFbnI011230@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e0ea56904515e4c1a75256f4327d414b0d2506cc
Commit:        e0ea56904515e4c1a75256f4327d414b0d2506cc
Parent:        1520fec3e81147a86f98713bfc8dd27848ce74ff
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Mar 17 14:14:42 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Mar 17 14:14:42 2017 +0100

raid: cleanup

Move function _raid45_to_raid54_wrapper() to avoid superfluous declaration.
---
 lib/metadata/raid_manip.c |  147 ++++++++++++++++++++++-----------------------
 1 files changed, 73 insertions(+), 74 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 3b3ef19..808e3e1 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -4843,8 +4843,80 @@ static int _shift_parity_dev(struct lv_segment *seg)
 	return 1;
 }
 
+/*
+ * raid4 <-> raid5_n helper
+ *
+ * On conversions between raid4 and raid5_n, the parity SubLVs need
+ * to be switched between beginning and end of the segment areas.
+ *
+ * The metadata devices reflect the previous positions within the RaidLV,
+ * thus need to be cleared in order to allow the kernel to start the new
+ * mapping and recreate metadata with the proper new position stored.
+ */
+static int _raid45_to_raid54_wrapper(TAKEOVER_FN_ARGS)
+{
+	struct lv_segment *seg = first_seg(lv);
+	struct dm_list removal_lvs;
+	uint32_t region_size = seg->region_size;
+
+	dm_list_init(&removal_lvs);
+
+	if (!(seg_is_raid4(seg) && segtype_is_raid5_n(new_segtype)) &&
+	    !(seg_is_raid5_n(seg) && segtype_is_raid4(new_segtype))) {
+		log_error("LV %s has to be of type raid4 or raid5_n to allow for this conversion.",
+			  display_lvname(lv));
+		return 0;
+	}
+
+
+	/* Necessary when convering to raid0/striped w/o redundancy. */
+	if (!_raid_in_sync(lv)) {
+		log_error("Unable to convert %s while it is not in-sync.",
+			  display_lvname(lv));
+		return 0;
+	}
+
+	log_debug_metadata("Converting LV %s from %s to %s.", display_lvname(lv),
+			   (seg_is_raid4(seg) ? SEG_TYPE_NAME_RAID4 : SEG_TYPE_NAME_RAID5_N),
+			   (seg_is_raid4(seg) ? SEG_TYPE_NAME_RAID5_N : SEG_TYPE_NAME_RAID4));
+
+	/* Archive metadata */
+	if (!archive(lv->vg))
+		return_0;
+
+	if (!_rename_area_lvs(lv, "_")) {
+		log_error("Failed to rename %s LV %s MetaLVs.", lvseg_name(seg), display_lvname(lv));
+		return 0;
+	}
+
+	if (!_clear_meta_lvs(lv))
+		return_0;
+
+	/* Shift parity SubLV pair "PDD..." <-> "DD...P" on raid4 <-> raid5_n conversion */
+	if( !_shift_parity_dev(seg))
+		return 0;
+
+	/* Don't resync */
+	init_mirror_in_sync(1);
+	seg->region_size = new_region_size ?: region_size;
+	seg->segtype = new_segtype;
+
+	if (!_lv_update_reload_fns_reset_eliminate_lvs(lv, 0, &removal_lvs, NULL))
+		return_0;
+
+	init_mirror_in_sync(0);
+
+	if (!_rename_area_lvs(lv, NULL)) {
+		log_error("Failed to rename %s LV %s MetaLVs.", lvseg_name(seg), display_lvname(lv));
+		return 0;
+	}
+	if (!lv_update_and_reload(lv))
+		return_0;
+
+	return 1;
+}
+
 /* raid45610 -> raid0* / stripe, raid5_n -> raid4 */
-static int _raid45_to_raid54_wrapper(TAKEOVER_FN_ARGS);
 static int _takeover_downconvert_wrapper(TAKEOVER_FN_ARGS)
 {
 	int rename_sublvs = 0;
@@ -4990,79 +5062,6 @@ static int _takeover_downconvert_wrapper(TAKEOVER_FN_ARGS)
 	return 1;
 }
 
-/*
- * raid4 <-> raid5_n helper
- *
- * On conversions between raid4 and raid5_n, the parity SubLVs need
- * to be switched between beginning and end of the segment areas.
- *
- * The metadata devices reflect the previous positions within the RaidLV,
- * thus need to be cleared in order to allow the kernel to start the new
- * mapping and recreate metadata with the proper new position stored.
- */
-static int _raid45_to_raid54_wrapper(TAKEOVER_FN_ARGS)
-{
-	struct lv_segment *seg = first_seg(lv);
-	struct dm_list removal_lvs;
-	uint32_t region_size = seg->region_size;
-
-	dm_list_init(&removal_lvs);
-
-	if (!(seg_is_raid4(seg) && segtype_is_raid5_n(new_segtype)) &&
-	    !(seg_is_raid5_n(seg) && segtype_is_raid4(new_segtype))) {
-		log_error("LV %s has to be of type raid4 or raid5_n to allow for this conversion.",
-			  display_lvname(lv));
-		return 0;
-	}
-
-
-	/* Necessary when convering to raid0/striped w/o redundancy. */
-	if (!_raid_in_sync(lv)) {
-		log_error("Unable to convert %s while it is not in-sync.",
-			  display_lvname(lv));
-		return 0;
-	}
-
-	log_debug_metadata("Converting LV %s from %s to %s.", display_lvname(lv),
-			   (seg_is_raid4(seg) ? SEG_TYPE_NAME_RAID4 : SEG_TYPE_NAME_RAID5_N),
-			   (seg_is_raid4(seg) ? SEG_TYPE_NAME_RAID5_N : SEG_TYPE_NAME_RAID4));
-
-	/* Archive metadata */
-	if (!archive(lv->vg))
-		return_0;
-
-	if (!_rename_area_lvs(lv, "_")) {
-		log_error("Failed to rename %s LV %s MetaLVs.", lvseg_name(seg), display_lvname(lv));
-		return 0;
-	}
-
-	if (!_clear_meta_lvs(lv))
-		return_0;
-
-	/* Shift parity SubLV pair "PDD..." <-> "DD...P" on raid4 <-> raid5_n conversion */
-	if( !_shift_parity_dev(seg))
-		return 0;
-
-	/* Don't resync */
-	init_mirror_in_sync(1);
-	seg->region_size = new_region_size ?: region_size;
-	seg->segtype = new_segtype;
-
-	if (!_lv_update_reload_fns_reset_eliminate_lvs(lv, 0, &removal_lvs, NULL))
-		return_0;
-
-	init_mirror_in_sync(0);
-
-	if (!_rename_area_lvs(lv, NULL)) {
-		log_error("Failed to rename %s LV %s MetaLVs.", lvseg_name(seg), display_lvname(lv));
-		return 0;
-	}
-	if (!lv_update_and_reload(lv))
-		return_0;
-
-	return 1;
-}
-
 static int _striped_to_raid0_wrapper(struct logical_volume *lv,
 				     const struct segment_type *new_segtype,
 				     uint32_t new_stripes,


