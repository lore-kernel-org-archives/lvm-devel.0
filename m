From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 1 Dec 2011 00:21:05 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/raid_manip.c
Message-ID: <20111201002105.27148.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2011-12-01 00:21:04

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : raid_manip.c 

Log message:
	Don't allow two images to be split and tracked from a RAID LV at one time
	
	Also, don't allow a splitmirror operation on a RAID LV that is already tracking
	a split, unless the operation is to stop the tracking and complete the split.
	Example:
	~> lvconvert --splitmirrors 1 --trackchanges vg/lv /dev/sdc1
	# Now tracking changes - image can be merged back or split-off for good
	~> lvconvert --splitmirrors 1 -n new_name vg/lv /dev/sdc1
	# ^ Completes split ^
	
	If a split is performed on a RAID that is tracking an already split image and
	PVs are provided, we must ensure that
	1) the already split LV is represented in the PVs
	2) we are careful to split only the tracked image

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2202&r2=1.2203
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/raid_manip.c.diff?cvsroot=lvm2&r1=1.19&r2=1.20

--- LVM2/WHATS_NEW	2011/12/01 00:13:16	1.2202
+++ LVM2/WHATS_NEW	2011/12/01 00:21:04	1.2203
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Don't allow two images to be split and tracked from a RAID LV at one time
   Don't allow size change of RAID LV that is tracking changes for a split image
   Don't allow size change of RAID sub-LVs independently
   Don't allow name change of RAID LV that is tracking changes for a split image
--- LVM2/lib/metadata/raid_manip.c	2011/12/01 00:09:35	1.19
+++ LVM2/lib/metadata/raid_manip.c	2011/12/01 00:21:04	1.20
@@ -26,20 +26,32 @@
 
 #define RAID_REGION_SIZE 1024
 
-int lv_is_raid_with_tracking(const struct logical_volume *lv)
+static int _lv_is_raid_with_tracking(const struct logical_volume *lv,
+				     struct logical_volume **tracking)
 {
 	uint32_t s;
 	struct lv_segment *seg;
 
-	if (lv->status & RAID) {
-		seg = first_seg(lv);
+	*tracking = NULL;
+	seg = first_seg(lv);
 
-		for (s = 0; s < seg->area_count; s++)
-			if (lv_is_visible(seg_lv(seg, s)) &&
-			    !(seg_lv(seg, s)->status & LVM_WRITE))
-				return 1;
-	}
-	return 0;
+	if (!(lv->status & RAID))
+		return 0;
+
+	for (s = 0; s < seg->area_count; s++)
+		if (lv_is_visible(seg_lv(seg, s)) &&
+		    !(seg_lv(seg, s)->status & LVM_WRITE))
+			*tracking = seg_lv(seg, s);
+
+
+	return *tracking ? 1 : 0;
+}
+
+int lv_is_raid_with_tracking(const struct logical_volume *lv)
+{
+	struct logical_volume *tracking;
+
+	return _lv_is_raid_with_tracking(lv, &tracking);
 }
 
 uint32_t lv_raid_image_count(const struct logical_volume *lv)
@@ -1051,6 +1063,8 @@
 	struct dm_list removal_list, data_list;
 	struct cmd_context *cmd = lv->vg->cmd;
 	uint32_t old_count = lv_raid_image_count(lv);
+	struct logical_volume *tracking;
+	struct dm_list tracking_pvs;
 
 	dm_list_init(&removal_list);
 	dm_list_init(&data_list);
@@ -1079,6 +1093,25 @@
 		return 0;
 	}
 
+	/*
+	 * We only allow a split while there is tracking if it is to
+	 * complete the split of the tracking sub-LV
+	 */
+	if (_lv_is_raid_with_tracking(lv, &tracking)) {
+		if (!_lv_is_on_pvs(tracking, splittable_pvs)) {
+			log_error("Unable to split additional image from %s "
+				  "while tracking changes for %s",
+				  lv->name, tracking->name);
+			return 0;
+		} else {
+			/* Ensure we only split the tracking image */
+			dm_list_init(&tracking_pvs);
+			splittable_pvs = &tracking_pvs;
+			if (!_get_pv_list_for_lv(tracking, splittable_pvs))
+				return_0;
+		}
+	}
+
 	if (!_raid_extract_images(lv, new_count, splittable_pvs, 1,
 				 &removal_list, &data_list)) {
 		log_error("Failed to extract images from %s/%s",
@@ -1181,6 +1214,12 @@
 		return 0;
 	}
 
+	/* Cannot track two split images at once */
+	if (lv_is_raid_with_tracking(lv)) {
+		log_error("Cannot track more than one split image at a time");
+		return 0;
+	}
+
 	for (s = seg->area_count - 1; s >= 0; s--) {
 		if (!_lv_is_on_pvs(seg_lv(seg, s), splittable_pvs))
 			continue;


