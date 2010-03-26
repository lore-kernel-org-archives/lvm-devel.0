From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 26 Mar 2010 22:15:48 -0000
Subject: LVM2 ./WHATS_NEW daemons/dmeventd/plugins/mirr ...
Message-ID: <20100326221548.15893.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2010-03-26 22:15:44

Modified files:
	.              : WHATS_NEW 
	daemons/dmeventd/plugins/mirror: dmeventd_mirror.c 
	lib/activate   : activate.c 
	lib/metadata   : lv_alloc.h lv_manip.c mirror.c 
	man            : lvconvert.8.in lvcreate.8.in 
	test           : t-lvconvert-repair-policy.sh 
	                 t-lvconvert-repair.sh t-lvcreate-operation.sh 
	                 t-mirror-lvconvert.sh t-snapshots-of-mirrors.sh 
	tools          : commands.h lvconvert.c lvcreate.c 

Log message:
	Add ability to create mirrored logs for mirror LVs.
	
	This check-in enables the 'mirrored' log type.  It can be specified
	by using the '--mirrorlog' option as follows:
	#> lvcreate -m1 --mirrorlog mirrored -L 5G -n lv vg
	
	I've also included a couple updates to the testsuite.  These updates
	include tests for the new log type, and some fixes to some of the
	*lvconvert* tests.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1484&r2=1.1485
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c.diff?cvsroot=lvm2&r1=1.31&r2=1.32
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.167&r2=1.168
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_alloc.h.diff?cvsroot=lvm2&r1=1.26&r2=1.27
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.216&r2=1.217
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.108&r2=1.109
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvconvert.8.in.diff?cvsroot=lvm2&r1=1.14&r2=1.15
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvcreate.8.in.diff?cvsroot=lvm2&r1=1.16&r2=1.17
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvconvert-repair-policy.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvconvert-repair.sh.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvcreate-operation.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-mirror-lvconvert.sh.diff?cvsroot=lvm2&r1=1.16&r2=1.17
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-snapshots-of-mirrors.sh.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/commands.h.diff?cvsroot=lvm2&r1=1.142&r2=1.143
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.122&r2=1.123
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.216&r2=1.217

--- LVM2/WHATS_NEW	2010/03/26 15:45:36	1.1484
+++ LVM2/WHATS_NEW	2010/03/26 22:15:43	1.1485
@@ -1,5 +1,6 @@
 Version 2.02.63 -  
 ================================
+  Add ability to create mirrored logs for mirror LVs.
   Use a real socket for singlenode clvmd to fix clvmd's high cpu load.
   Fix clvmd cluster propagation of dmeventd monitoring mode.
   Allow ALLOC_ANYWHERE to split contiguous areas.
--- LVM2/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c	2010/01/22 12:48:58	1.31
+++ LVM2/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c	2010/03/26 22:15:43	1.32
@@ -148,6 +148,11 @@
 		return -ENOMEM;	/* FIXME Replace with generic error return - reason for failure has already got logged */
 	}
 
+	/* strip off the mirror component designations */
+	layer = strstr(lv, "_mlog");
+	if (layer)
+		*layer = '\0';
+
 	/* FIXME Is any sanity-checking required on %s? */
 	if (CMD_SIZE <= snprintf(cmd_str, CMD_SIZE, "lvconvert --config devices{ignore_suspended_devices=1} --repair --use-policies %s/%s", vg, lv)) {
 		/* this error should be caught above, but doesn't hurt to check again */
--- LVM2/lib/activate/activate.c	2010/03/05 14:48:34	1.167
+++ LVM2/lib/activate/activate.c	2010/03/26 22:15:43	1.168
@@ -703,6 +703,7 @@
 	int r = 1;
 	struct dm_list *tmp, *snh, *snht;
 	struct lv_segment *seg;
+	struct lv_segment *log_seg;
 	int (*monitor_fn) (struct lv_segment *s, int e);
 	uint32_t s;
 
@@ -738,6 +739,16 @@
 		return r;
 	}
 
+	/*
+	 * If the volume is mirrored and its log is also mirrored, monitor
+	 * the log volume as well.
+	 */
+	if ((seg = first_seg(lv)) != NULL && seg->log_lv != NULL &&
+	    (log_seg = first_seg(seg->log_lv)) != NULL &&
+	    seg_is_mirrored(log_seg))
+		if (!monitor_dev_for_events(cmd, seg->log_lv, monitor))
+			r = 0;
+
 	dm_list_iterate(tmp, &lv->segments) {
 		seg = dm_list_item(tmp, struct lv_segment);
 
--- LVM2/lib/metadata/lv_alloc.h	2010/03/01 20:00:21	1.26
+++ LVM2/lib/metadata/lv_alloc.h	2010/03/26 22:15:43	1.27
@@ -68,7 +68,8 @@
 		      uint32_t num_extra_areas,
 		      uint64_t status, uint32_t region_size);
 
-int lv_add_log_segment(struct alloc_handle *ah, struct logical_volume *log_lv);
+int lv_add_log_segment(struct alloc_handle *ah, uint32_t first_area,
+		       struct logical_volume *log_lv, uint64_t status);
 int lv_add_virtual_segment(struct logical_volume *lv, uint64_t status,
                            uint32_t extents, const struct segment_type *segtype);
 
--- LVM2/lib/metadata/lv_manip.c	2010/03/25 21:19:27	1.216
+++ LVM2/lib/metadata/lv_manip.c	2010/03/26 22:15:43	1.217
@@ -1635,14 +1635,32 @@
 
 /*
  * Turn an empty LV into a mirror log.
+ *
+ * FIXME: Mirrored logs are built inefficiently.
+ * A mirrored log currently uses the same layout that a mirror
+ * LV uses.  The mirror layer sits on top of AREA_LVs which form the
+ * legs, rather on AREA_PVs.  This is done to allow re-use of the
+ * various mirror functions to also handle the mirrored LV that makes
+ * up the log.
+ *
+ * If we used AREA_PVs under the mirror layer of a log, we could
+ * assemble it all at once by calling 'lv_add_segment' with the
+ * appropriate segtype (mirror/stripe), like this:
+ * 	lv_add_segment(ah, ah->area_count, ah->log_area_count,
+ *		       log_lv, segtype, 0, MIRROR_LOG, 0);
+ *
+ * For now, we use the same mechanism to build a mirrored log as we
+ * do for building a mirrored LV: 1) create initial LV, 2) add a
+ * mirror layer, and 3) add the remaining copy LVs
  */
-int lv_add_log_segment(struct alloc_handle *ah, struct logical_volume *log_lv)
+int lv_add_log_segment(struct alloc_handle *ah, uint32_t first_area,
+		       struct logical_volume *log_lv, uint64_t status)
 {
-	const char *segtype_name = ah->log_area_count > 1 ? "mirror" : "striped";
 
-	return lv_add_segment(ah, ah->area_count, ah->log_area_count, log_lv,
-			      get_segtype_from_string(log_lv->vg->cmd, segtype_name),
-			      0, MIRROR_LOG, 0);
+	return lv_add_segment(ah, ah->area_count + first_area, 1, log_lv,
+			      get_segtype_from_string(log_lv->vg->cmd,
+						      "striped"),
+			      0, status, 0);
 }
 
 static int _lv_extend_mirror(struct alloc_handle *ah,
--- LVM2/lib/metadata/mirror.c	2010/03/01 20:00:21	1.108
+++ LVM2/lib/metadata/mirror.c	2010/03/26 22:15:43	1.109
@@ -709,8 +709,8 @@
  *
  * Arguments:
  *   num_removed:   the requested (maximum) number of mirrors to be removed
- *   removable_pvs: if not NULL, only mirrors using PVs in this list
- *                  will be removed
+ *   removable_pvs: if not NULL and list not empty, only mirrors using PVs
+ *                  in this list will be removed
  *   remove_log:    if non-zero, log_lv will be removed
  *                  (even if it's 0, log_lv will be removed if there is no
  *                   mirror remaining after the removal)
@@ -737,6 +737,7 @@
 {
 	uint32_t m;
 	uint32_t s;
+	int removable_pvs_specified;
 	struct logical_volume *sub_lv;
 	struct logical_volume *detached_log_lv = NULL;
 	struct logical_volume *temp_layer_lv = NULL;
@@ -746,6 +747,9 @@
 	struct lv_list *lvl;
 	struct dm_list tmp_orphan_lvs;
 
+	removable_pvs_specified = (removable_pvs &&
+				   !dm_list_empty(removable_pvs)) ? 1 : 0;
+
 	if (removed)
 		*removed = 0;
 
@@ -755,13 +759,13 @@
 			 remove_log ? " and no log volume" : "");
 
 	if (collapse &&
-	    (removable_pvs || (old_area_count - num_removed != 1))) {
+	    (removable_pvs_specified || (old_area_count - num_removed != 1))) {
 		log_error("Incompatible parameters to _remove_mirror_images");
 		return 0;
 	}
 
 	/* Move removable_pvs to end of array */
-	if (removable_pvs) {
+	if (removable_pvs_specified) {
 		for (s = 0; s < mirrored_seg->area_count &&
 			    old_area_count - new_area_count < num_removed; s++) {
 			sub_lv = seg_lv(mirrored_seg, s);
@@ -1171,7 +1175,8 @@
 static int _create_mimage_lvs(struct alloc_handle *ah,
 			      uint32_t num_mirrors,
 			      struct logical_volume *lv,
-			      struct logical_volume **img_lvs)
+			      struct logical_volume **img_lvs,
+			      int log)
 {
 	uint32_t m;
 	char *img_name;
@@ -1199,14 +1204,23 @@
 			return 0;
 		}
 
-		if (!lv_add_segment(ah, m, 1, img_lvs[m],
-				    get_segtype_from_string(lv->vg->cmd,
-							    "striped"),
-				    0, 0, 0)) {
-			log_error("Aborting. Failed to add mirror image segment "
-				  "to %s. Remove new LV and retry.",
-				  img_lvs[m]->name);
-			return 0;
+		if (log) {
+			if (!lv_add_log_segment(ah, m + 1, img_lvs[m], 0)) {
+				log_error("Aborting. Failed to add mirror image segment "
+					  "to %s. Remove new LV and retry.",
+					  img_lvs[m]->name);
+				return 0;
+			}
+		} else {
+			if (!lv_add_segment(ah, m, 1, img_lvs[m],
+					    get_segtype_from_string(lv->vg->cmd,
+								    "striped"),
+					    0, 0, 0)) {
+				log_error("Aborting. Failed to add mirror image segment "
+					  "to %s. Remove new LV and retry.",
+					  img_lvs[m]->name);
+				return 0;
+			}
 		}
 	}
 
@@ -1541,17 +1555,57 @@
 				       alloc, lv->vg)))
 		return_NULL;
 
-	if (!lv_add_log_segment(ah, log_lv))
+	if (!lv_add_log_segment(ah, 0, log_lv, MIRROR_LOG))
 		return_NULL;
 
 	return log_lv;
 }
 
+/*
+ * Returns: 1 on success, 0 on error
+ */
+static int _form_mirror(struct cmd_context *cmd, struct alloc_handle *ah,
+			struct logical_volume *lv,
+			uint32_t mirrors, uint32_t region_size, int log)
+{
+	struct logical_volume **img_lvs;
+
+	/*
+	 * insert a mirror layer
+	 */
+	if (dm_list_size(&lv->segments) != 1 ||
+	    seg_type(first_seg(lv), 0) != AREA_LV)
+		if (!insert_layer_for_lv(cmd, lv, 0, "_mimage_%d"))
+			return 0;
+
+	/*
+	 * create mirror image LVs
+	 */
+	if (!(img_lvs = alloca(sizeof(*img_lvs) * mirrors))) {
+		log_error("img_lvs allocation failed. "
+			  "Remove new LV and retry.");
+		return 0;
+	}
+
+	if (!_create_mimage_lvs(ah, mirrors, lv, img_lvs, log))
+		return 0;
+
+	if (!lv_add_mirror_lvs(lv, img_lvs, mirrors,
+			       MIRROR_IMAGE | (lv->status & LOCKED),
+			       region_size)) {
+		log_error("Aborting. Failed to add mirror segment. "
+			  "Remove new LV and retry.");
+		return 0;
+	}
+
+	return 1;
+}
+
 static struct logical_volume *_set_up_mirror_log(struct cmd_context *cmd,
 						 struct alloc_handle *ah,
 						 struct logical_volume *lv,
 						 uint32_t log_count,
-						 uint32_t region_size __attribute((unused)),
+						 uint32_t region_size,
 						 alloc_policy_t alloc,
 						 int in_sync)
 {
@@ -1563,11 +1617,6 @@
 
 	init_mirror_in_sync(in_sync);
 
-	if (log_count != 1) {
-		log_error("log_count != 1 is not supported.");
-		return NULL;
-	}
-
 	/* Mirror log name is lv_name + suffix, determined as the following:
 	 *   1. suffix is:
 	 *        o "_mlog" for the original mirror LV.
@@ -1600,6 +1649,12 @@
 		return NULL;
 	}
 
+	if ((log_count > 1) &&
+	    !_form_mirror(cmd, ah, log_lv, log_count-1, region_size, 1)) {
+		log_error("Failed to form mirrored log.");
+		return NULL;
+	}
+
 	if (!_init_mirror_log(cmd, log_lv, in_sync, &lv->tags, 1)) {
 		log_error("Failed to initialise mirror log.");
 		return NULL;
@@ -1630,12 +1685,6 @@
 	struct lvinfo info;
 	int r = 0;
 
-	/* Unimplemented features */
-	if (log_count > 1) {
-		log_error("log_count > 1 is not supported");
-		return 0;
-	}
-
 	if (dm_list_size(&lv->segments) != 1) {
 		log_error("Multiple-segment mirror is not supported");
 		return 0;
@@ -1707,7 +1756,6 @@
 	struct alloc_handle *ah;
 	const struct segment_type *segtype;
 	struct dm_list *parallel_areas;
-	struct logical_volume **img_lvs;
 	struct logical_volume *log_lv = NULL;
 
 	if (stripes > 1) {
@@ -1747,34 +1795,9 @@
 	   So from here on, if failure occurs, the log must be explicitly
 	   removed and the updated vg metadata should be committed. */
 
-	/*
-	 * insert a mirror layer
-	 */
-	if (dm_list_size(&lv->segments) != 1 ||
-	    seg_type(first_seg(lv), 0) != AREA_LV)
-		if (!insert_layer_for_lv(cmd, lv, 0, "_mimage_%d"))
-			goto out_remove_log;
-
-	/*
-	 * create mirror image LVs
-	 */
-	if (!(img_lvs = alloca(sizeof(*img_lvs) * mirrors))) {
-		log_error("img_lvs allocation failed. "
-			  "Remove new LV and retry.");
-		goto out_remove_log;
-	}
-
-	if (!_create_mimage_lvs(ah, mirrors, lv, img_lvs))
+	if (!_form_mirror(cmd, ah, lv, mirrors, region_size, 0))
 		goto out_remove_log;
 
-	if (!lv_add_mirror_lvs(lv, img_lvs, mirrors,
-			       MIRROR_IMAGE | (lv->status & LOCKED),
-			       region_size)) {
-		log_error("Aborting. Failed to add mirror segment. "
-			  "Remove new LV and retry.");
-		goto out_remove_images;
-	}
-
 	if (log_count && !attach_mirror_log(first_seg(lv), log_lv))
 		stack;
 
--- LVM2/man/lvconvert.8.in	2010/02/05 22:44:37	1.14
+++ LVM2/man/lvconvert.8.in	2010/03/26 22:15:43	1.15
@@ -3,7 +3,7 @@
 lvconvert \- convert a logical volume from linear to mirror or snapshot
 .SH SYNOPSIS
 .B lvconvert
-\-m|\-\-mirrors Mirrors [\-\-mirrorlog {disk|core}] [\-\-corelog] [\-R|\-\-regionsize MirrorLogRegionSize]
+\-m|\-\-mirrors Mirrors [\-\-mirrorlog {disk|core|mirrored}] [\-\-corelog] [\-R|\-\-regionsize MirrorLogRegionSize]
 [\-A|\-\-alloc AllocationPolicy]
 [\-b|\-\-background] [\-f|\-\-force] [\-i|\-\-interval Seconds]
 [\-h|\-?|\-\-help]
@@ -83,6 +83,7 @@
 Core may be useful for short-lived mirrors: It means the mirror is
 regenerated by copying the data from the first device again every
 time the device is activated - perhaps, for example, after every reboot.
+Using "mirrored" will create a persistent log that is itself mirrored.
 .TP
 .I \-\-corelog
 The optional argument "--corelog" is the same as specifying "--mirrorlog core".
--- LVM2/man/lvcreate.8.in	2010/03/23 22:30:20	1.16
+++ LVM2/man/lvcreate.8.in	2010/03/26 22:15:43	1.17
@@ -13,7 +13,7 @@
 {\-l|\-\-extents LogicalExtentsNumber[%{VG|PVS|FREE}] |
  \-L|\-\-size LogicalVolumeSize[bBsSkKmMgGtTpPeE]}
 [\-M|\-\-persistent y|n] [\-\-minor minor]
-[\-m|\-\-mirrors Mirrors [\-\-nosync] [\-\-mirrorlog {disk|core}] [\-\-corelog]
+[\-m|\-\-mirrors Mirrors [\-\-nosync] [\-\-mirrorlog {disk|core|mirrored}] [\-\-corelog]
 [\-R|\-\-regionsize MirrorLogRegionSize]]
 [\-n|\-\-name LogicalVolumeName]
 [\-p|\-\-permission r|rw] [\-r|\-\-readahead ReadAheadSectors|auto|none]
@@ -113,9 +113,10 @@
 The optional argument --mirrorlog specifies the type of log to be used.
 The default is disk, which is persistent and requires
 a small amount of storage space, usually on a separate device from the
-data being mirrored. Using core means the mirror is regenerated
+data being mirrored.  Using core means the mirror is regenerated
 by copying the data from the first device again each time the
-device is activated, for example, after every reboot.
+device is activated, for example, after every reboot.  Using "mirrored"
+will create a persistent log that is itself mirrored.
 
 The optional argument --corelog is equivalent to --mirrorlog core.
 
--- LVM2/test/t-lvconvert-repair-policy.sh	2010/01/08 13:04:10	1.1
+++ LVM2/test/t-lvconvert-repair-policy.sh	2010/03/26 22:15:44	1.2
@@ -13,12 +13,15 @@
 
 prepare_vg 4
 
+# Clean-up and create a 2-way mirror, where the the
+# leg devices are always on $dev[12] and the log
+# is always on $dev3.  ($dev4 behaves as a spare)
 cleanup() {
 	vgreduce --removemissing $vg
 	for d in "$@"; do enable_dev $d; done
 	for d in "$@"; do vgextend $vg $d; done
 	lvremove -ff $vg/mirror
-	lvcreate -m 1 -L 1 -n mirror $vg
+	lvcreate -m 1 -l 2 -n mirror $vg $dev1 $dev2 $dev3:0
 }
 
 repair() {
@@ -28,34 +31,42 @@
 lvcreate -m 1 -L 1 -n mirror $vg
 lvchange -a n $vg/mirror
 
+# Fail a leg of a mirror.
+# Expected result: linear
 disable_dev $dev1
 lvchange --partial -a y $vg/mirror
 repair 'activation { mirror_image_fault_policy = "remove" }'
 lvs | grep -- -wi-a- # non-mirror
 cleanup $dev1
 
+# Fail a leg of a mirror.
+# Expected result: Mirror (leg replaced)
 disable_dev $dev1
 repair 'activation { mirror_image_fault_policy = "replace" }'
 lvs | grep -- mwi-a- # mirror
 lvs | grep mirror_mlog
 cleanup $dev1
 
+# Fail a leg of a mirror (use old name for policy specification)
+# Expected result: Mirror (leg replaced)
 disable_dev $dev1
 repair 'activation { mirror_device_fault_policy = "replace" }'
 lvs | grep -- mwi-a- # mirror
 lvs | grep mirror_mlog
 cleanup $dev1
 
+# Fail a leg of a mirror w/ no available spare
+# Expected result: linear
 disable_dev $dev2 $dev4
-# no room for repair, downconversion should happen
 repair 'activation { mirror_image_fault_policy = "replace" }'
 lvs | grep -- -wi-a-
 cleanup $dev2 $dev4
 
-disable_dev $dev2 $dev4
-# no room for new log, corelog conversion should happen
+# Fail the log device of a mirror w/ no available spare
+# Expected result: mirror w/ corelog
+disable_dev $dev3 $dev4
 repair 'activation { mirror_image_fault_policy = "replace" }'
 lvs
 lvs | grep -- mwi-a-
 lvs | not grep mirror_mlog
-cleanup $dev2 $dev4
+cleanup $dev3 $dev4
--- LVM2/test/t-lvconvert-repair.sh	2009/12/28 18:33:04	1.4
+++ LVM2/test/t-lvconvert-repair.sh	2010/03/26 22:15:44	1.5
@@ -69,5 +69,5 @@
 lvcreate -m 2 -l 1 -n mirror2 $vg $dev1 $dev2 $dev3 $dev4
 vgchange -a n $vg
 pvremove -ff -y $dev4
-echo 'y' | not lvconvert -y -i 1 --repair $vg/mirror2
+echo 'y' | lvconvert -y -i 1 --repair $vg/mirror2
 vgs
--- LVM2/test/t-lvcreate-operation.sh	2009/12/28 18:33:04	1.2
+++ LVM2/test/t-lvcreate-operation.sh	2010/03/26 22:15:44	1.3
@@ -25,9 +25,18 @@
 aux pvcreate --metadatacopies 0 $dev1
 aux vgcreate -c n $vg $devs
 
-#COMM create snapshots of LVs on --metadatacopies 0 PV (bz450651)
+# ---
+# Create snapshots of LVs on --metadatacopies 0 PV (bz450651)
 lvcreate -n$lv1 -l4 $vg $dev1
 lvcreate -n$lv2 -l4 -s $vg/$lv1
-#lvremove -f $vg/$lv2
 cleanup_lvs
 
+# ---
+# Create mirror on two devices with mirrored log using --alloc anywhere
+lvcreate -m 1 -l4 -n $lv1 --mirrorlog mirrored $vg --alloc anywhere $dev1 $dev2
+cleanup_lvs
+
+# --
+# Create mirror on one dev with mirrored log using --alloc anywhere, should fail
+lvcreate -m 1 -l4 -n $lv1 --mirrorlog mirrored $vg --alloc anywhere $dev1
+cleanup_lvs
--- LVM2/test/t-mirror-lvconvert.sh	2010/03/25 12:14:14	1.16
+++ LVM2/test/t-mirror-lvconvert.sh	2010/03/26 22:15:44	1.17
@@ -281,6 +281,38 @@
 check_and_cleanup_lvs_
 
 # ---
+# core log to mirrored log
+
+# change the log type from 'core' to 'mirrored'
+prepare_lvs_
+lvcreate -l2 -m1 --mirrorlog core -n $lv1 $vg $dev1 $dev2
+check_mirror_count_ $vg/$lv1 2
+not_sh check_mirror_log_ $vg/$lv1
+lvconvert --mirrorlog mirrored -i1 $vg/$lv1 $dev3 $dev4
+check_no_tmplvs_ $vg/$lv1
+check_mirror_log_ $vg/$lv1
+mimages_are_redundant_ $vg $lv1
+
+# ---
+# mirrored log to core log
+
+# change the log type from 'mirrored' to 'core'
+lvconvert --mirrorlog core -i1 $vg/$lv1 $dev3 $dev4
+check_no_tmplvs_ $vg/$lv1
+not_sh check_mirror_log_ $vg/$lv1
+mimages_are_redundant_ $vg $lv1
+check_and_cleanup_lvs_
+
+# ---
+# Linear to mirror with mirrored log using --alloc anywhere
+prepare_lvs_
+lvcreate -l2 -n $lv1 $vg $dev1
+lvconvert -m +1 --mirrorlog mirrored $vg/$lv1 $dev1 $dev2 --alloc anywhere
+mimages_are_redundant_ $vg $lv1
+check_and_cleanup_lvs_
+
+
+# ---
 # check polldaemon restarts
 
 # convert inactive mirror and start polling
--- LVM2/test/t-snapshots-of-mirrors.sh	2010/01/12 14:19:46	1.3
+++ LVM2/test/t-snapshots-of-mirrors.sh	2010/03/26 22:15:44	1.4
@@ -21,11 +21,11 @@
 # Log conversion (disk -> core)
 lvconvert --mirrorlog core $vg/lv
 
-# Log conversion (core -> redundant)
-not lvconvert --mirrorlog redundant $vg/lv
+# Log conversion (core -> mirrored)
+lvconvert --mirrorlog mirrored $vg/lv
 
-# Log conversion (redundant -> core)
-# lvconvert --mirrorlog core $vg/lv
+# Log conversion (mirrored -> core)
+lvconvert --mirrorlog core $vg/lv
 
 # Log conversion (core -> disk)
 lvconvert --mirrorlog disk $vg/lv
--- LVM2/tools/commands.h	2010/03/23 22:30:20	1.142
+++ LVM2/tools/commands.h	2010/03/26 22:15:44	1.143
@@ -96,7 +96,7 @@
    "Change logical volume layout",
    0,
    "lvconvert "
-   "[-m|--mirrors Mirrors [{--mirrorlog {disk|core}|--corelog}]]\n"
+   "[-m|--mirrors Mirrors [{--mirrorlog {disk|core|mirrored}|--corelog}]]\n"
    "\t[--repair [--use-policies]]\n"
    "\t[-R|--regionsize MirrorLogRegionSize]\n"
    "\t[--alloc AllocationPolicy]\n"
@@ -156,7 +156,7 @@
    "\t{-l|--extents LogicalExtentsNumber[%{VG|PVS|FREE}] |\n"
    "\t -L|--size LogicalVolumeSize[bBsSkKmMgGtTpPeE]}\n"
    "\t[-M|--persistent {y|n}] [--major major] [--minor minor]\n"
-   "\t[-m|--mirrors Mirrors [--nosync] [{--mirrorlog {disk|core}|--corelog}]]\n"
+   "\t[-m|--mirrors Mirrors [--nosync] [{--mirrorlog {disk|core|mirrored}|--corelog}]]\n"
    "\t[-n|--name LogicalVolumeName]\n"
    "\t[--noudevsync]\n"
    "\t[-p|--permission {r|rw}]\n"
--- LVM2/tools/lvconvert.c	2010/03/16 14:37:39	1.122
+++ LVM2/tools/lvconvert.c	2010/03/26 22:15:44	1.123
@@ -647,31 +647,72 @@
 	}
 }
 
-static int _using_corelog(struct logical_volume *lv)
+/*
+ * _get_log_count
+ * @lv: the mirror LV
+ *
+ * Get the number of on-disk copies of the log.
+ *  0  = 'core'
+ *  1  = 'disk'
+ *  2+ = 'mirrored'
+ */
+static int _get_log_count(struct logical_volume *lv)
 {
-	return !first_seg(_original_lv(lv))->log_lv;
+	struct logical_volume *log_lv;
+
+	log_lv = first_seg(_original_lv(lv))->log_lv;
+	if (!log_lv)
+		return 0;
+
+	return lv_mirror_count(log_lv);
 }
 
 static int _lv_update_log_type(struct cmd_context *cmd,
 			       struct lvconvert_params *lp,
 			       struct logical_volume *lv,
+			       struct dm_list *operable_pvs,
 			       int log_count)
 {
-	struct logical_volume *original_lv = _original_lv(lv);
-	if (_using_corelog(lv) && log_count) {
+	uint32_t region_size;
+	int old_log_count;
+	struct logical_volume *original_lv;
+	struct logical_volume *log_lv;
+
+	old_log_count = _get_log_count(lv);
+	if (old_log_count == log_count)
+		return 1;
+
+	original_lv = _original_lv(lv);
+	region_size = adjusted_mirror_region_size(lv->vg->extent_size,
+						  lv->le_count,
+						  lp->region_size);
+
+	/* Add a log where there is none */
+	if (!old_log_count) {
 		if (!add_mirror_log(cmd, original_lv, log_count,
-				    adjusted_mirror_region_size(
-					lv->vg->extent_size,
-					lv->le_count,
-					lp->region_size),
-				    lp->pvh, lp->alloc))
+				    region_size, operable_pvs, lp->alloc))
 			return_0;
-	} else if (!_using_corelog(lv) && !log_count) {
-		if (!remove_mirror_log(cmd, original_lv,
-				       lp->pv_count ? lp->pvh : NULL))
+		return 1;
+	}
+
+	/* Remove an existing log completely */
+	if (!log_count) {
+		if (!remove_mirror_log(cmd, original_lv, operable_pvs))
 			return_0;
+		return 1;
 	}
-	return 1;
+
+	log_lv = first_seg(original_lv)->log_lv;
+
+	/* Adding redundancy to the log */
+	if (old_log_count < log_count) {
+		log_error("Adding log redundancy not supported yet.");
+		log_error("Try converting the log to 'core' first.");
+		return_0;
+	}
+
+	/* Reducing redundancy of the log */
+	return remove_mirror_images(log_lv, log_count, operable_pvs, 1U);
 }
 
 /*
@@ -712,138 +753,134 @@
 	}
 }
 
-static int _lvconvert_mirrors(struct cmd_context *cmd, struct logical_volume *lv,
-			      struct lvconvert_params *lp)
+/*
+ * _lvconvert_mirrors_parse_params
+ *
+ * This function performs the following:
+ *  1) Gets the old values of mimage and log counts
+ *  2) Parses the CLI args to find the new desired values
+ *  3) Adjusts 'lp->mirrors' to the appropriate absolute value.
+ *     (Remember, 'lp->mirrors' is specified in terms of the number of "copies"
+ *      vs. the number of mimages.  It can also be a relative value.)
+ *  4) Sets 'lp->need_polling' if collapsing
+ *  5) Validates other mirror params
+ *
+ * Returns: 1 on success, 0 on error
+ */
+static int _lvconvert_mirrors_parse_params(struct cmd_context *cmd,
+					   struct logical_volume *lv,
+					   struct lvconvert_params *lp,
+					   uint32_t *old_mimage_count,
+					   uint32_t *old_log_count,
+					   uint32_t *new_mimage_count,
+					   uint32_t *new_log_count)
 {
-	struct lv_segment *seg;
-	uint32_t existing_mirrors;
-	const char *mirrorlog;
-	unsigned log_count = 1;
-	int r = 0;
-	struct logical_volume *log_lv, *layer_lv;
-	int failed_mirrors = 0, failed_log = 0;
-	struct dm_list *old_pvh = NULL, *remove_pvs = NULL, *failed_pvs = NULL;
-
 	int repair = arg_count(cmd, repair_ARG);
-	int replace_log = 1, replace_mirrors = 1;
-	int failure_code = 0;
-
-	seg = first_seg(lv);
-	existing_mirrors = lv_mirror_count(lv);
+	const char *mirrorlog;
+	*old_mimage_count = lv_mirror_count(lv);
+	*old_log_count = _get_log_count(lv);
 
-	/* If called with no argument, try collapsing the resync layers */
+	/*
+	 * Collapsing a stack of mirrors:
+	 *
+	 * If called with no argument, try collapsing the resync layers
+	 */
 	if (!arg_count(cmd, mirrors_ARG) && !arg_count(cmd, mirrorlog_ARG) &&
 	    !arg_count(cmd, corelog_ARG) && !arg_count(cmd, regionsize_ARG) &&
 	    !arg_count(cmd, splitmirrors_ARG) && !repair) {
+		*new_mimage_count = *old_mimage_count;
+		*new_log_count = *old_log_count;
+
 		if (find_temporary_mirror(lv) || (lv->status & CONVERTING))
 			lp->need_polling = 1;
 		return 1;
 	}
 
-	if (arg_count(cmd, mirrors_ARG) && repair) {
-		log_error("You may only use one of --mirrors and --repair.");
+	if ((arg_count(cmd, mirrors_ARG) && repair) ||
+	    (arg_count(cmd, mirrorlog_ARG) && repair) ||
+	    (arg_count(cmd, corelog_ARG) && repair)) {
+		log_error("--repair cannot be used with --mirrors, --mirrorlog,"
+			  " or --corelog");
+		return 0;
+	}
+
+	if (arg_count(cmd, mirrorlog_ARG) && arg_count(cmd, corelog_ARG)) {
+		log_error("--mirrorlog and --corelog are incompatible");
 		return 0;
 	}
 
 	/*
-	 * Adjust required number of mirrors
-	 *
-	 * We check mirrors_ARG again to see if it
-	 * was supplied.  If not, they want the mirror
-	 * count to remain the same.  They may be changing
-	 * the logging type.
+	 * Adjusting mimage count?
 	 */
 	if (!arg_count(cmd, mirrors_ARG) && !arg_count(cmd, splitmirrors_ARG))
-		lp->mirrors = existing_mirrors;
+		lp->mirrors = *old_mimage_count;
 	else if (lp->mirrors_sign == SIGN_PLUS)
-		lp->mirrors = existing_mirrors + lp->mirrors;
+		lp->mirrors = *old_mimage_count + lp->mirrors;
 	else if (lp->mirrors_sign == SIGN_MINUS)
-		lp->mirrors = existing_mirrors - lp->mirrors;
+		lp->mirrors = *old_mimage_count - lp->mirrors;
 	else
 		lp->mirrors += 1;
 
+	*new_mimage_count = lp->mirrors;
+
+	/* Too many mimages? */
 	if (lp->mirrors > DEFAULT_MIRROR_MAX_IMAGES) {
 		log_error("Only up to %d images in mirror supported currently.",
 			  DEFAULT_MIRROR_MAX_IMAGES);
 		return 0;
 	}
 
-	/*
-	 * If we are converting from one type of mirror to another, and
-	 * the type of log wasn't specified, then let's keep the log type
-	 * the same.
-	 */
-	if ((existing_mirrors > 1) && (lp->mirrors > 1) &&
-	    (lp->mirrors != existing_mirrors) && !(lv->status & CONVERTING) &&
-	    !arg_count(cmd, mirrorlog_ARG) && !arg_count(cmd, corelog_ARG)) {
-		log_count = (first_seg(lv)->log_lv) ?
-			lv_mirror_count(first_seg(lv)->log_lv) : 0;
+	/* Did the user try to subtract more legs than available? */
+	if (lp->mirrors < 1) {
+		log_error("Logical volume %s only has %" PRIu32 " mirrors.",
+			  lv->name, *old_mimage_count);
+		return 0;
 	}
 
-	if (repair) {
-		cmd->handles_missing_pvs = 1;
-		cmd->partial_activation = 1;
-		lp->need_polling = 0;
-		if (!(lv->status & PARTIAL_LV)) {
-			log_error("The mirror is consistent. Nothing to repair.");
-			return 1;
-		}
-		if ((failed_mirrors = _failed_mirrors_count(lv)) < 0)
-			return_0;
-		lp->mirrors -= failed_mirrors;
-		log_error("Mirror status: %d of %d images failed.",
-			  failed_mirrors, existing_mirrors);
-		old_pvh = lp->pvh;
-		if (!(failed_pvs = _failed_pv_list(lv->vg)))
-			return_0;
-		lp->pvh = lp->failed_pvs = failed_pvs;
-		log_lv = first_seg(lv)->log_lv;
-		if (!log_lv || log_lv->status & PARTIAL_LV) {
-			failed_log = 1;
-			log_count = 0;
-		}
-	} else {
-		/*
-		 * Did the user try to subtract more legs than available?
-		 */
-		if (lp->mirrors < 1) {
-			log_error("Logical volume %s only has %" PRIu32 " mirrors.",
-				  lv->name, existing_mirrors);
-			return 0;
-		}
-
-		/*
-		 * Adjust log type
-		 */
-		if (arg_count(cmd, corelog_ARG))
-			log_count = 0;
+	/*
+	 * FIXME: It would be nice to say what we are adjusting to, but
+	 * I really don't know whether to specify the # of copies or mimages.
+	 */
+	if (*old_mimage_count != *new_mimage_count)
+		log_verbose("Adjusting mirror image count of %s", lv->name);
 
-		mirrorlog = arg_str_value(cmd, mirrorlog_ARG,
-					  !log_count ? "core" : DEFAULT_MIRRORLOG);
+	/*
+	 * Adjust log type
+	 *
+	 * If we are converting from a mirror to another mirror or simply
+	 * changing the log type, we start by assuming they want the log
+	 * type the same and then parse the given args.  OTOH, If we are
+	 * converting from linear to mirror, then we start from the default
+	 * position that the user would like a 'disk' log.
+	 */
+	*new_log_count = (*old_mimage_count > 1) ? *old_log_count : 1;
+	if (!arg_count(cmd, corelog_ARG) && !arg_count(cmd, mirrorlog_ARG))
+		return 1;
 
-		if (strcmp("core", mirrorlog) && !log_count) {
-			log_error("--mirrorlog disk and --corelog "
-				  "are incompatible");
-			return 0;
-		}
+	if (arg_count(cmd, corelog_ARG))
+		*new_log_count = 0;
 
-		if (!strcmp("disk", mirrorlog))
-			log_count = 1;
-		else if (!strcmp("core", mirrorlog))
-			log_count = 0;
-		else {
-			log_error("Unknown mirrorlog type: %s", mirrorlog);
-			return 0;
-		}
+	mirrorlog = arg_str_value(cmd, mirrorlog_ARG,
+				  !*new_log_count ? "core" : DEFAULT_MIRRORLOG);
 
-		log_verbose("Setting logging type to %s", mirrorlog);
+	if (!strcmp("mirrored", mirrorlog))
+		*new_log_count = 2;
+	else if (!strcmp("disk", mirrorlog))
+		*new_log_count = 1;
+	else if (!strcmp("core", mirrorlog))
+		*new_log_count = 0;
+	else {
+		log_error("Unknown mirrorlog type: %s", mirrorlog);
+		return 0;
 	}
 
+	log_verbose("Setting logging type to %s", mirrorlog);
+
 	/*
 	 * Region size must not change on existing mirrors
 	 */
 	if (arg_count(cmd, regionsize_ARG) && (lv->status & MIRRORED) &&
-	    (lp->region_size != seg->region_size)) {
+	    (lp->region_size != first_seg(lv)->region_size)) {
 		log_error("Mirror log region size cannot be changed on "
 			  "an existing mirror.");
 		return 0;
@@ -859,48 +896,54 @@
 		return 0;
 	}
 
-	if (repair)
-		_lvconvert_mirrors_repair_ask(cmd, failed_log, failed_mirrors,
-					      &replace_log, &replace_mirrors);
+	return 1;
+}
 
- restart:
-	/*
-	 * Converting from mirror to linear
-	 */
-	if ((lp->mirrors == 1)) {
-		if (!(lv->status & MIRRORED)) {
-			log_error("Logical volume %s is already not mirrored.",
-				  lv->name);
-			return 1;
-		}
+/*
+ * _lvconvert_mirrors_aux
+ *
+ * Add/remove mirror images and adjust log type.  'operable_pvs'
+ * are the set of PVs open to removal or allocation - depending
+ * on the operation being performed.
+ *
+ * If 'allocation_failures_ok' is set, and there is a failure to
+ * convert due to space, success will be returned.
+ */
+static int _lvconvert_mirrors_aux(struct cmd_context *cmd,
+				  struct logical_volume *lv,
+				  struct lvconvert_params *lp,
+				  struct dm_list *operable_pvs,
+				  uint32_t new_mimage_count,
+				  uint32_t new_log_count,
+				  int allocation_failures_ok)
+{
+	uint32_t region_size;
+	struct dm_list *tmp;
+	struct lv_segment *seg;
+	struct logical_volume *layer_lv;
+	uint32_t old_mimage_count = lv_mirror_count(lv);
+	uint32_t old_log_count = _get_log_count(lv);
+	int failure_code = (allocation_failures_ok) ? 1 : 0;
+
+	if ((lp->mirrors == 1) && !(lv->status & MIRRORED)) {
+		log_error("Logical volume %s is already not mirrored.",
+			  lv->name);
+		return 1;
 	}
 
-	/*
-	 * Downconversion.
-	 */
-	if (lp->mirrors < existing_mirrors) {
-		/* Reduce number of mirrors */
-		if (repair || lp->pv_count)
-			remove_pvs = lp->pvh;
+	region_size = adjusted_mirror_region_size(lv->vg->extent_size,
+						  lv->le_count,
+						  lp->region_size);
 
-		if (lp->keep_mimages) {
-			if (!lv_split_mirror_images(lv, lp->lv_split_name,
-						    existing_mirrors - lp->mirrors,
-						    remove_pvs))
-				return 0;
-		} else if (!lv_remove_mirrors(cmd, lv, existing_mirrors - lp->mirrors,
-					      (!log_count || lp->mirrors == 1) ? 1U : 0U,
-					      remove_pvs, 0))
-			return_0;
+	if (!operable_pvs)
+		operable_pvs = lp->pvh;
 
-		if (lp->mirrors > 1 &&
-		    !_lv_update_log_type(cmd, lp, lv, log_count))
-			return_0;
-	} else if (!(lv->status & MIRRORED)) {
-		/*
-		 * Converting from linear to mirror
-		 */
+	seg = first_seg(lv);
 
+	/*
+	 * Up-convert from linear to mirror
+	 */
+	if (!(lv->status & MIRRORED)) {
 		/* FIXME Share code with lvcreate */
 
 		/* FIXME Why is this restriction here?  Fix it! */
@@ -916,19 +959,22 @@
 		 * currently taken by the mirror? Would make more sense from
 		 * user perspective.
 		 */
-		if (!lv_add_mirrors(cmd, lv, lp->mirrors - 1, 1,
-				    adjusted_mirror_region_size(
-						lv->vg->extent_size,
-						lv->le_count,
-						lp->region_size),
-				    log_count, lp->pvh, lp->alloc,
-				    MIRROR_BY_LV)) {
+		if (!lv_add_mirrors(cmd, lv, new_mimage_count - 1, 1,
+				    region_size, new_log_count, operable_pvs,
+				    lp->alloc, MIRROR_BY_LV)) {
 			stack;
 			return failure_code;
 		}
 		if (lp->wait_completion)
 			lp->need_polling = 1;
-	} else if (lp->mirrors > existing_mirrors || failed_mirrors) {
+
+		goto out;
+	}
+
+	/*
+	 * Up-convert m-way mirror to n-way mirror
+	 */
+	if (new_mimage_count > old_mimage_count) {
 		if (lv->status & MIRROR_NOTSYNCED) {
 			log_error("Can't add mirror to out-of-sync mirrored "
 				  "LV: use lvchange --resync first.");
@@ -953,23 +999,23 @@
 		 * insertion to make the end result consistent with
 		 * linear-to-mirror conversion.
 		 */
-		if (!_lv_update_log_type(cmd, lp, lv, log_count)) {
+		if (!_lv_update_log_type(cmd, lp, lv,
+					 operable_pvs, new_log_count)) {
 			stack;
 			return failure_code;
 		}
+
 		/* Insert a temporary layer for syncing,
 		 * only if the original lv is using disk log. */
 		if (seg->log_lv && !_insert_lvconvert_layer(cmd, lv)) {
 			log_error("Failed to insert resync layer");
 			return 0;
 		}
+
 		/* FIXME: can't have multiple mlogs. force corelog. */
-		if (!lv_add_mirrors(cmd, lv, lp->mirrors - existing_mirrors, 1,
-				    adjusted_mirror_region_size(
-						lv->vg->extent_size,
-						lv->le_count,
-						lp->region_size),
-				    0U, lp->pvh, lp->alloc,
+		if (!lv_add_mirrors(cmd, lv,
+				    new_mimage_count - old_mimage_count, 1,
+				    region_size, 0U, operable_pvs, lp->alloc,
 				    MIRROR_BY_LV)) {
 			layer_lv = seg_lv(first_seg(lv), 0);
 			if (!remove_layer_from_lv(lv, layer_lv) ||
@@ -989,24 +1035,45 @@
 		if (seg->log_lv)
 			lv->status |= CONVERTING;
 		lp->need_polling = 1;
+
+		goto out_skip_log_convert;
 	}
 
-	if (lp->mirrors == existing_mirrors) {
-		if (_using_corelog(lv) != !log_count) {
-			if (!_lv_update_log_type(cmd, lp, lv, log_count)) {
-				stack;
-				return failure_code;
-			}
-		} else {
-			log_error("Logical volume %s already has %"
-				  PRIu32 " mirror(s).", lv->name,
-				  lp->mirrors - 1);
-			if (lv->status & CONVERTING)
-				lp->need_polling = 1;
-			return 1;
+	/*
+	 * Down-convert (reduce # of mimages).
+	 */
+	if (new_mimage_count < old_mimage_count) {
+		uint32_t nmc = old_mimage_count - new_mimage_count;
+		uint32_t nlc = (!new_log_count || lp->mirrors == 1) ? 1U : 0U;
+
+		/* FIXME: We did nlc used to be calculated that way? */
+
+		/* Reduce number of mirrors */
+		if (lp->keep_mimages) {
+			if (!lv_split_mirror_images(lv, lp->lv_split_name,
+						    nmc, operable_pvs))
+				return 0;
+		} else if (!lv_remove_mirrors(cmd, lv, nmc, nlc,
+					      operable_pvs, 0))
+			return_0;
+
+		goto out; /* Just in case someone puts code between */
+	}
+
+out:
+	/*
+	 * Converting the log type
+	 */
+	if (old_log_count != new_log_count) {
+		if (!_lv_update_log_type(cmd, lp, lv,
+					 operable_pvs, new_log_count)) {
+			stack;
+			return failure_code;
 		}
 	}
 
+out_skip_log_convert:
+
 	log_very_verbose("Updating logical volume \"%s\" on disk(s)", lv->name);
 
 	if (!vg_write(lv->vg))
@@ -1031,35 +1098,170 @@
 		goto out;
 	}
 
-	if (failed_log || failed_mirrors) {
-		lp->pvh = old_pvh;
-		if (failed_log && replace_log) {
-			failed_log = 0;
-			log_count = 1;
-		}
-		if (replace_mirrors)
-			lp->mirrors += failed_mirrors;
-		failed_mirrors = 0;
-		existing_mirrors = lv_mirror_count(lv);
+	return 1;
+}
+
+/*
+ * _lvconvert_mirrors_repair
+ *
+ * This function operates in two phases.  First, all of the bad
+ * devices are removed from the mirror.  Then, if desired by the
+ * user, the devices are replaced.
+ *
+ * 'old_mimage_count' and 'old_log_count' are there so we know
+ * what to convert to after the removal of devices.
+ */
+static int _lvconvert_mirrors_repair(struct cmd_context *cmd,
+				     struct logical_volume *lv,
+				     struct lvconvert_params *lp,
+				     uint32_t old_mimage_count,
+				     uint32_t old_log_count)
+{
+	int failed_log = 0;
+	int failed_mirrors = 0;
+	int replace_log = 0;
+	int replace_mirrors = 0;
+	uint32_t new_log_count;
+	struct dm_list *failed_pvs = NULL;
+	struct logical_volume *log_lv;
+
+	cmd->handles_missing_pvs = 1;
+	cmd->partial_activation = 1;
+	lp->need_polling = 0;
+
+	if (!(lv->status & PARTIAL_LV)) {
+		log_error("%s is consistent. Nothing to repair.", lv->name);
+		return 1;
+	}
+
+	/*
+	 * Count the failed mimages - negative if 'lv' is not a mirror
+	 */
+	if ((failed_mirrors = _failed_mirrors_count(lv)) < 0)
+		return_0;
+
+	lp->mirrors = old_mimage_count - failed_mirrors;
+
+	if (lp->mirrors != old_mimage_count)
+		log_error("Mirror status: %d of %d images failed.",
+			  failed_mirrors, old_mimage_count);
+
+	/*
+	 * Count the failed log devices
+	 */
+	new_log_count = old_log_count;
+	log_lv = first_seg(lv)->log_lv;
+	if (log_lv) {
+		new_log_count = lv_mirror_count(log_lv);
+		if (log_lv->status & PARTIAL_LV) {
+			failed_log = 1;
+			if (log_lv->status & MIRRORED)
+				new_log_count -= _failed_mirrors_count(log_lv);
+			else
+				new_log_count = 0;
+		}
+	}
+	if (old_log_count != new_log_count)
+		log_error("Mirror log status: %d of %d images failed%s",
+			  old_log_count - new_log_count, old_log_count,
+			  (!new_log_count) ? " - switching to core" : "");
+
+	/*
+	 * Find out our policies
+	 */
+	_lvconvert_mirrors_repair_ask(cmd, failed_log, failed_mirrors,
+				      &replace_log, &replace_mirrors);
+
+	/*
+	 * First phase - remove faulty devices
+	 */
+	if (!(failed_pvs = _failed_pv_list(lv->vg)))
+		return_0;
+
+	/*
+	 * We must adjust the log first, or the entire mirror
+	 * will get stuck during a suspend.
+	 */
+	if (!_lv_update_log_type(cmd, lp, lv, failed_pvs, new_log_count))
+		return 0;
+
+	if (!_lvconvert_mirrors_aux(cmd, lv, lp, failed_pvs,
+				    lp->mirrors, new_log_count, 0))
+		return 0;
+
+	/*
+	 * Second phase - replace faulty devices
+	 *
+	 * FIXME: It would be nice to do this all in one step, but
+	 *        for simplicity, we replace mimages first and then
+	 *        work on the log.
+	 */
+	if (replace_mirrors && (old_mimage_count != lp->mirrors)) {
+		lp->mirrors = old_mimage_count;
+		if (!_lvconvert_mirrors_aux(cmd, lv, lp, NULL,
+					    old_mimage_count, new_log_count, 1))
+			return 0;
+	}
+
+	log_lv = first_seg(lv)->log_lv;
+	if (replace_log && (old_log_count != new_log_count)) {
 		/*
-		 * Ignore failure in upconversion if this is a policy-driven
-		 * action. If we got this far, only unexpected failures are
-		 * reported.
+		 * If we are up-converting the log from linear to
+		 * mirrored, then we must use '_lvconvert_mirrors_aux'
 		 */
-		if (arg_count(cmd, use_policies_ARG))
-			failure_code = 1;
-		/* Now replace missing devices. */
-		if (replace_log || replace_mirrors)
-			goto restart;
+		if ((new_log_count == 1) && (old_log_count > 1)) {
+			if (!_lvconvert_mirrors_aux(cmd, log_lv, lp, NULL,
+						    old_log_count, 0, 1))
+				return 0;
+		} else if (!_lv_update_log_type(cmd, lp, lv,
+						lp->pvh, new_log_count))
+			return 0;
 	}
 
+	return 1;
+}
+
+/*
+ * _lvconvert_mirrors
+ *
+ * Determine what is being done.  Are we doing a conversion, repair, or
+ * collapsing a stack?  Once determined, call helper functions.
+ */
+static int _lvconvert_mirrors(struct cmd_context *cmd,
+			      struct logical_volume *lv,
+			      struct lvconvert_params *lp)
+{
+	int repair = arg_count(cmd, repair_ARG);
+	uint32_t old_mimage_count;
+	uint32_t old_log_count;
+	uint32_t new_mimage_count;
+	uint32_t new_log_count;
+
+	/* Adjust mimage and/or log count */
+	if (!_lvconvert_mirrors_parse_params(cmd, lv, lp,
+					     &old_mimage_count, &old_log_count,
+					     &new_mimage_count, &new_log_count))
+		return 0;
+
+	/* Nothing to do?  (Probably finishing collapse.) */
+	if ((old_mimage_count == new_mimage_count) &&
+	    (old_log_count == new_log_count) && !repair)
+		return 1;
+
+	if (repair)
+		return _lvconvert_mirrors_repair(cmd, lv, lp,
+						 old_mimage_count,
+						 old_log_count);
+
+	if (!_lvconvert_mirrors_aux(cmd, lv, lp, NULL,
+				    new_mimage_count, new_log_count, 0))
+		return 0;
+
 	if (!lp->need_polling)
 		log_print("Logical volume %s converted.", lv->name);
 
-	r = 1;
-out:
 	backup(lv->vg);
-	return r;
+	return 1;
 }
 
 static int lvconvert_snapshot(struct cmd_context *cmd,
--- LVM2/tools/lvcreate.c	2010/03/23 22:30:20	1.216
+++ LVM2/tools/lvcreate.c	2010/03/26 22:15:44	1.217
@@ -337,12 +337,14 @@
 	mirrorlog = arg_str_value(cmd, mirrorlog_ARG,
 				  corelog ? "core" : DEFAULT_MIRRORLOG);
 
-	if (!strcmp("disk", mirrorlog)) {
-		if (corelog) {
-			log_error("--mirrorlog disk and --corelog "
-				  "are incompatible");
-			return 0;
-		}
+	if (strcmp("core", mirrorlog) && corelog) {
+		log_error("Please use only one of --mirrorlog or --corelog");
+		return 0;
+	}
+
+	if (!strcmp("mirrored", mirrorlog)) {
+		lp->log_count = 2;
+	} else if (!strcmp("disk", mirrorlog)) {
 		lp->log_count = 1;
 	} else if (!strcmp("core", mirrorlog))
 		lp->log_count = 0;


