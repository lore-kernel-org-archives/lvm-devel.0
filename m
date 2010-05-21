From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 21 May 2010 12:43:07 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/merge.c lib/meta ...
Message-ID: <20100521124307.15132.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-05-21 12:43:02

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : merge.c metadata.h replicator_manip.c 

Log message:
	Replicator: check replicator segment
	
	Check for possible problems within replicator structures.
	Used also by vg_validate.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1580&r2=1.1581
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/merge.c.diff?cvsroot=lvm2&r1=1.42&r2=1.43
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.203&r2=1.204
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/replicator_manip.c.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/WHATS_NEW	2010/05/21 12:36:30	1.1580
+++ LVM2/WHATS_NEW	2010/05/21 12:43:02	1.1581
@@ -1,5 +1,6 @@
 Version 2.02.67 -
 ===============================
+  Add check_replicator_segment() for catching internal replicator errors.
   Initial lvm2 support for Replicator metadata handling.
   Checking open_count in all parents of presuspend_node.
   Added dm_tree_node_set_presuspend_node() to presuspend child in deactivate.
--- LVM2/lib/metadata/merge.c	2010/05/21 12:36:31	1.42
+++ LVM2/lib/metadata/merge.c	2010/05/21 12:43:02	1.43
@@ -137,6 +137,9 @@
 			}
 		}
 
+		if (seg_is_replicator(seg) && !check_replicator_segment(seg))
+			inc_error_count;
+
 		for (s = 0; s < seg->area_count; s++) {
 			if (seg_type(seg, s) == AREA_UNASSIGNED) {
 				log_error("LV %s: segment %u has unassigned "
--- LVM2/lib/metadata/metadata.h	2010/04/13 17:25:45	1.203
+++ LVM2/lib/metadata/metadata.h	2010/05/21 12:43:02	1.204
@@ -321,6 +321,12 @@
  */
 int check_lv_segments(struct logical_volume *lv, int complete_vg);
 
+
+/*
+ * Checks that a replicator segment is correct.
+ */
+int check_replicator_segment(const struct lv_segment *replicator_seg);
+
 /*
  * Sometimes (eg, after an lvextend), it is possible to merge two
  * adjacent segments into a single segment.  This function trys
--- LVM2/lib/metadata/replicator_manip.c	2010/05/21 12:40:05	1.1
+++ LVM2/lib/metadata/replicator_manip.c	2010/05/21 12:43:02	1.2
@@ -252,6 +252,158 @@
 }
 #endif
 
+/*
+ * Check all replicator structures:
+ *  only non-clustered VG for Replicator
+ *  only one segment in replicator LV
+ *  site has correct combination of operation_mode parameters
+ *  site and related devices have correct index numbers
+ *  duplicate site names, site indexes, device names, device indexes
+ */
+int check_replicator_segment(const struct lv_segment *rseg)
+{
+	struct replicator_site *rsite, *rsiteb;
+	struct replicator_device *rdev, *rdevb;
+        struct logical_volume *lv = rseg->lv;
+	int r = 1;
+
+	if (vg_is_clustered(lv->vg)) {
+		log_error("Volume Group %s of replicator %s is clustered",
+			  lv->vg->name, lv->name);
+		return 0;
+	}
+
+	if (dm_list_size(&lv->segments) != 1) {
+		log_error("Replicator %s segment size %d != 1",
+			  lv->name, dm_list_size(&lv->segments));
+		return 0;
+	}
+
+	dm_list_iterate_items(rsite, &lv->rsites) {
+		if (rsite->op_mode == DM_REPLICATOR_SYNC) {
+			if (rsite->fall_behind_timeout) {
+				log_error("Defined fall_behind_timeout="
+					  "%d for sync replicator %s/%s.",
+					  rsite->fall_behind_timeout, lv->name,
+					  rsite->name);
+				r = 0;
+			}
+			if (rsite->fall_behind_ios) {
+				log_error("Defined fall_behind_ios="
+					  "%d for sync replicator %s/%s.",
+					  rsite->fall_behind_ios, lv->name, rsite->name);
+				r = 0;
+			}
+			if (rsite->fall_behind_data) {
+				log_error("Defined fall_behind_data="
+					  "%" PRIu64 " for sync replicator %s/%s.",
+					  rsite->fall_behind_data, lv->name, rsite->name);
+				r = 0;
+			}
+		} else {
+			if (rsite->fall_behind_timeout && rsite->fall_behind_ios) {
+				log_error("Defined fall_behind_timeout and"
+					  " fall_behind_ios for async replicator %s/%s.",
+					  lv->name, rsite->name);
+				r = 0;
+			}
+			if (rsite->fall_behind_timeout && rsite->fall_behind_data) {
+				log_error("Defined fall_behind_timeout and"
+					  " fall_behind_data for async replicator %s/%s.",
+					  lv->name, rsite->name);
+				r = 0;
+			}
+			if (rsite->fall_behind_ios && rsite->fall_behind_data) {
+				log_error("Defined fall_behind_ios and"
+					  " fall_behind_data for async replicator %s/%s.",
+					  lv->name, rsite->name);
+				r = 0;
+			}
+			if (!rsite->fall_behind_ios &&
+			    !rsite->fall_behind_data &&
+			    !rsite->fall_behind_timeout) {
+				log_error("fall_behind_timeout,"
+					  " fall_behind_ios and fall_behind_data are"
+					  " undefined for async replicator %s/%s.",
+					  lv->name, rsite->name);
+				r = 0;
+			}
+		}
+		dm_list_iterate_items(rsiteb, &lv->rsites) {
+			if (rsite == rsiteb)
+				break;
+			if (strcasecmp(rsite->name, rsiteb->name) == 0) {
+				log_error("Duplicate site name "
+					  "%s detected for replicator %s.",
+					  rsite->name, lv->name);
+				r = 0;
+			}
+			if ((rsite->vg_name && rsiteb->vg_name &&
+			     strcasecmp(rsite->vg_name, rsiteb->vg_name) == 0) ||
+			    (!rsite->vg_name && !rsiteb->vg_name)) {
+				log_error("Duplicate VG name "
+					  "%s detected for replicator %s.",
+					  (rsite->vg_name) ? rsite->vg_name : "<local>",
+					  lv->name);
+				r = 0;
+			}
+			if (rsite->site_index == rsiteb->site_index) {
+				log_error("Duplicate site index %d detected "
+					  "for replicator site %s/%s.",
+					  rsite->site_index, lv->name,
+					  rsite->name);
+				r = 0;
+			}
+			if (rsite->site_index > rseg->rsite_index_highest) {
+				log_error("Site index %d > %d (too high) "
+					  "for replicator site %s/%s.",
+					  rsite->site_index,
+					  rseg->rsite_index_highest,
+					  lv->name, rsite->name);
+				r = 0;
+			}
+		}
+
+		dm_list_iterate_items(rdev, &rsite->rdevices) {
+			dm_list_iterate_items(rdevb, &rsite->rdevices) {
+				if (rdev == rdevb)
+					break;
+				if (rdev->slog && (rdev->slog == rdevb->slog)) {
+					log_error("Duplicate sync log %s "
+						  "detected for replicator %s.",
+						  rdev->slog->name, lv->name);
+					r = 0;
+				}
+				if (strcasecmp(rdev->name, rdevb->name) == 0) {
+					log_error("Duplicate device name %s "
+						  "detected for replicator %s.",
+						  rdev->name, lv->name);
+					r = 0;
+				}
+				if (rdev->device_index == rdevb->device_index) {
+					log_error("Duplicate device index %"
+						  PRId64 " detected for "
+						  "replicator site %s/%s.",
+						  rdev->device_index,
+						  lv->name, rsite->name);
+					r = 0;
+				}
+				if (rdev->device_index > rseg->rdevice_index_highest) {
+					log_error("Device index %" PRIu64
+						  " > %" PRIu64 " (too high) "
+						  "for replicator site %s/%s.",
+						  rdev->device_index,
+						  rseg->rdevice_index_highest,
+						  lv->name, rsite->name);
+					r = 0;
+				}
+			}
+		}
+	}
+
+	return r;
+}
+
 /**
  * Is this segment part of active replicator
  */


