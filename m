From: agk@sourceware.org <agk@sourceware.org>
Date: 1 Oct 2009 00:35:32 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/activate.c lib/a ...
Message-ID: <20091001003532.11284.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-10-01 00:35:30

Modified files:
	.              : WHATS_NEW 
	lib/activate   : activate.c activate.h dev_manager.c 
	                 dev_manager.h 
	lib/display    : display.c 
	lib/metadata   : metadata-exported.h mirror.c segtype.h 
	lib/mirror     : mirrored.c 
	lib/report     : report.c 
	lib/snapshot   : snapshot.c 
	tools          : lvscan.c polldaemon.c 

Log message:
	Introduce percent_range_t and centralise snapshot full/mirror in-sync checks.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1284&r2=1.1285
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.155&r2=1.156
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.h.diff?cvsroot=lvm2&r1=1.63&r2=1.64
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.158&r2=1.159
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.h.diff?cvsroot=lvm2&r1=1.29&r2=1.30
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/display/display.c.diff?cvsroot=lvm2&r1=1.104&r2=1.105
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.112&r2=1.113
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.89&r2=1.90
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/segtype.h.diff?cvsroot=lvm2&r1=1.24&r2=1.25
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mirror/mirrored.c.diff?cvsroot=lvm2&r1=1.63&r2=1.64
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.102&r2=1.103
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/snapshot/snapshot.c.diff?cvsroot=lvm2&r1=1.37&r2=1.38
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvscan.c.diff?cvsroot=lvm2&r1=1.39&r2=1.40
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/polldaemon.c.diff?cvsroot=lvm2&r1=1.26&r2=1.27

--- LVM2/WHATS_NEW	2009/09/30 17:43:51	1.1284
+++ LVM2/WHATS_NEW	2009/10/01 00:35:29	1.1285
@@ -1,5 +1,6 @@
 Version 2.02.54 -
 =====================================
+  Introduce percent_range_t and centralise snapshot full/mirror in-sync checks.
   Factor out poll_mirror_progress and introduce progress_t.
   Distinguish between powers of 1000 and powers of 1024 in unit suffixes.
   Restart lvconverts in vgchange by sharing lv_spawn_background_polling.
--- LVM2/lib/activate/activate.c	2009/09/29 18:50:28	1.155
+++ LVM2/lib/activate/activate.c	2009/10/01 00:35:29	1.156
@@ -156,12 +156,14 @@
 {
 	return 0;
 }
-int lv_snapshot_percent(const struct logical_volume *lv, float *percent)
+int lv_snapshot_percent(const struct logical_volume *lv, float *percent,
+			percent_range_t *percent_range)
 {
 	return 0;
 }
 int lv_mirror_percent(struct cmd_context *cmd, struct logical_volume *lv,
-		      int wait, float *percent, uint32_t *event_nr)
+		      int wait, float *percent, percent_range_t *percent_range,
+		      uint32_t *event_nr)
 {
 	return 0;
 }
@@ -495,7 +497,8 @@
 /*
  * Returns 1 if percent set, else 0 on failure.
  */
-int lv_snapshot_percent(const struct logical_volume *lv, float *percent)
+int lv_snapshot_percent(const struct logical_volume *lv, float *percent,
+			percent_range_t *percent_range)
 {
 	int r;
 	struct dev_manager *dm;
@@ -506,7 +509,7 @@
 	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name)))
 		return_0;
 
-	if (!(r = dev_manager_snapshot_percent(dm, lv, percent)))
+	if (!(r = dev_manager_snapshot_percent(dm, lv, percent, percent_range)))
 		stack;
 
 	dev_manager_destroy(dm);
@@ -516,7 +519,8 @@
 
 /* FIXME Merge with snapshot_percent */
 int lv_mirror_percent(struct cmd_context *cmd, struct logical_volume *lv,
-		      int wait, float *percent, uint32_t *event_nr)
+		      int wait, float *percent, percent_range_t *percent_range,
+		      uint32_t *event_nr)
 {
 	int r;
 	struct dev_manager *dm;
@@ -541,7 +545,8 @@
 	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name)))
 		return_0;
 
-	if (!(r = dev_manager_mirror_percent(dm, lv, wait, percent, event_nr)))
+	if (!(r = dev_manager_mirror_percent(dm, lv, wait, percent,
+					     percent_range, event_nr)))
 		stack;
 
 	dev_manager_destroy(dm);
--- LVM2/lib/activate/activate.h	2009/02/28 00:54:06	1.63
+++ LVM2/lib/activate/activate.h	2009/10/01 00:35:29	1.64
@@ -81,9 +81,11 @@
 /*
  * Returns 1 if percent has been set, else 0.
  */
-int lv_snapshot_percent(const struct logical_volume *lv, float *percent);
+int lv_snapshot_percent(const struct logical_volume *lv, float *percent,
+			percent_range_t *percent_range);
 int lv_mirror_percent(struct cmd_context *cmd, struct logical_volume *lv,
-		      int wait, float *percent, uint32_t *event_nr);
+		      int wait, float *percent, percent_range_t *percent_range,
+		      uint32_t *event_nr);
 
 /*
  * Return number of LVs in the VG that are active.
--- LVM2/lib/activate/dev_manager.c	2009/08/04 15:36:14	1.158
+++ LVM2/lib/activate/dev_manager.c	2009/10/01 00:35:29	1.159
@@ -327,10 +327,26 @@
 	return 0;
 }
 
+static percent_range_t _combine_percent_ranges(percent_range_t a,
+					       percent_range_t b)
+{
+	if (a == PERCENT_INVALID || b == PERCENT_INVALID)
+		return PERCENT_INVALID;
+
+	if (a == PERCENT_100 && b == PERCENT_100)
+		return PERCENT_100;
+
+	if (a == PERCENT_0 && b == PERCENT_0)
+		return PERCENT_0;
+
+	return PERCENT_0_TO_100;
+}
+
 static int _percent_run(struct dev_manager *dm, const char *name,
 			const char *dlid,
 			const char *target_type, int wait,
 			struct logical_volume *lv, float *percent,
+			percent_range_t *overall_percent_range,
 			uint32_t *event_nr)
 {
 	int r = 0;
@@ -343,10 +359,13 @@
 	struct dm_list *segh = &lv->segments;
 	struct lv_segment *seg = NULL;
 	struct segment_type *segtype;
+	percent_range_t percent_range, combined_percent_range;
+	int first_time = 1;
 
 	uint64_t total_numerator = 0, total_denominator = 0;
 
 	*percent = -1;
+	*overall_percent_range = PERCENT_INVALID;
 
 	if (!(dmt = _setup_task(name, dlid, event_nr,
 				wait ? DM_DEVICE_WAITEVENT : DM_DEVICE_STATUS, 0, 0)))
@@ -383,12 +402,20 @@
 			continue;
 
 		if (segtype->ops->target_percent &&
-		    !segtype->ops->target_percent(&dm->target_state, dm->mem,
+		    !segtype->ops->target_percent(&dm->target_state,
+						  &percent_range, dm->mem,
 						  dm->cmd, seg, params,
 						  &total_numerator,
 						  &total_denominator))
 			goto_out;
 
+		if (first_time) {
+			combined_percent_range = percent_range;
+			first_time = 0;
+		} else
+			combined_percent_range =
+			    _combine_percent_ranges(combined_percent_range,
+						    percent_range);
 	} while (next);
 
 	if (lv && (segh = dm_list_next(&lv->segments, segh))) {
@@ -397,10 +424,16 @@
 		goto out;
 	}
 
-	if (total_denominator)
+	if (total_denominator) {
 		*percent = (float) total_numerator *100 / total_denominator;
-	else
+		*overall_percent_range = combined_percent_range;
+	} else {
 		*percent = 100;
+		if (first_time)
+			*overall_percent_range = PERCENT_100;
+		else
+			*overall_percent_range = combined_percent_range;
+	}
 
 	log_debug("LV percent: %f", *percent);
 	r = 1;
@@ -413,20 +446,20 @@
 static int _percent(struct dev_manager *dm, const char *name, const char *dlid,
 		    const char *target_type, int wait,
 		    struct logical_volume *lv, float *percent,
-		    uint32_t *event_nr)
+		    percent_range_t *overall_percent_range, uint32_t *event_nr)
 {
 	if (dlid && *dlid) {
 		if (_percent_run(dm, NULL, dlid, target_type, wait, lv, percent,
-				 event_nr))
+				 overall_percent_range, event_nr))
 			return 1;
 		else if (_percent_run(dm, NULL, dlid + sizeof(UUID_PREFIX) - 1,
 				      target_type, wait, lv, percent,
-				      event_nr))
+				      overall_percent_range, event_nr))
 			return 1;
 	}
 
 	if (name && _percent_run(dm, name, NULL, target_type, wait, lv, percent,
-				 event_nr))
+				 overall_percent_range, event_nr))
 		return 1;
 
 	return 0;
@@ -481,7 +514,7 @@
 
 int dev_manager_snapshot_percent(struct dev_manager *dm,
 				 const struct logical_volume *lv,
-				 float *percent)
+				 float *percent, percent_range_t *percent_range)
 {
 	char *name;
 	const char *dlid;
@@ -500,7 +533,7 @@
 	 */
 	log_debug("Getting device status percentage for %s", name);
 	if (!(_percent(dm, name, dlid, "snapshot", 0, NULL, percent,
-		       NULL)))
+		       percent_range, NULL)))
 		return_0;
 
 	/* FIXME dm_pool_free ? */
@@ -513,7 +546,8 @@
 /* FIXME Cope with more than one target */
 int dev_manager_mirror_percent(struct dev_manager *dm,
 			       struct logical_volume *lv, int wait,
-			       float *percent, uint32_t *event_nr)
+			       float *percent, percent_range_t *percent_range,
+			       uint32_t *event_nr)
 {
 	char *name;
 	const char *dlid;
@@ -533,7 +567,7 @@
 
 	log_debug("Getting device mirror status percentage for %s", name);
 	if (!(_percent(dm, name, dlid, "mirror", wait, lv, percent,
-		       event_nr)))
+		       percent_range, event_nr)))
 		return_0;
 
 	return 1;
--- LVM2/lib/activate/dev_manager.h	2009/05/20 09:52:37	1.29
+++ LVM2/lib/activate/dev_manager.h	2009/10/01 00:35:29	1.30
@@ -16,6 +16,8 @@
 #ifndef _LVM_DEV_MANAGER_H
 #define _LVM_DEV_MANAGER_H
 
+#include "metadata-exported.h"
+
 struct logical_volume;
 struct volume_group;
 struct cmd_context;
@@ -44,10 +46,12 @@
 		     struct dm_info *info, uint32_t *read_ahead);
 int dev_manager_snapshot_percent(struct dev_manager *dm,
 				 const struct logical_volume *lv,
-				 float *percent);
+				 float *percent,
+				 percent_range_t *percent_range);
 int dev_manager_mirror_percent(struct dev_manager *dm,
 			       struct logical_volume *lv, int wait,
-			       float *percent, uint32_t *event_nr);
+			       float *percent, percent_range_t *percent_range,
+			       uint32_t *event_nr);
 int dev_manager_suspend(struct dev_manager *dm, struct logical_volume *lv,
 			int lockfs, int flush_required);
 int dev_manager_activate(struct dev_manager *dm, struct logical_volume *lv);
--- LVM2/lib/display/display.c	2009/09/30 14:19:01	1.104
+++ LVM2/lib/display/display.c	2009/10/01 00:35:29	1.105
@@ -482,6 +482,7 @@
 	char uuid[64] __attribute((aligned(8)));
 	struct lv_segment *snap_seg = NULL;
 	float snap_percent;	/* fused, fsize; */
+	percent_range_t percent_range;
 
 	if (!id_write_format(&lv->lvid.id[1], uuid, sizeof(uuid)))
 		return_0;
@@ -506,24 +507,26 @@
 				       origin_list) {
 			if (inkernel &&
 			    (snap_active = lv_snapshot_percent(snap_seg->cow,
-							       &snap_percent)))
-				if (snap_percent < 0 || snap_percent >= 100)
+							       &snap_percent,
+							       &percent_range)))
+				if (percent_range == PERCENT_INVALID)
 					snap_active = 0;
 			log_print("                       %s%s/%s [%s]",
 				  lv->vg->cmd->dev_dir, lv->vg->name,
 				  snap_seg->cow->name,
-				  (snap_active > 0) ? "active" : "INACTIVE");
+				  snap_active ? "active" : "INACTIVE");
 		}
 		snap_seg = NULL;
 	} else if ((snap_seg = find_cow(lv))) {
 		if (inkernel &&
 		    (snap_active = lv_snapshot_percent(snap_seg->cow,
-						       &snap_percent)))
-			if (snap_percent < 0 || snap_percent >= 100)
+						       &snap_percent,
+						       &percent_range)))
+			if (percent_range == PERCENT_INVALID)
 				snap_active = 0;
 
 		log_print("LV snapshot status     %s destination for %s%s/%s",
-			  (snap_active > 0) ? "active" : "INACTIVE",
+			  snap_active ? "active" : "INACTIVE",
 			  lv->vg->cmd->dev_dir, lv->vg->name,
 			  snap_seg->origin->name);
 	}
--- LVM2/lib/metadata/metadata-exported.h	2009/09/15 18:35:14	1.112
+++ LVM2/lib/metadata/metadata-exported.h	2009/10/01 00:35:29	1.113
@@ -136,6 +136,13 @@
 	DONT_PROMPT_OVERRIDE = 2 /* Skip prompt + override a second condition */
 } force_t;
 
+typedef enum {
+	PERCENT_0 = 0,
+	PERCENT_0_TO_100 = 1,
+	PERCENT_100 = 2,
+	PERCENT_INVALID = 3
+} percent_range_t;
+
 struct cmd_context;
 struct format_handler;
 struct labeller;
--- LVM2/lib/metadata/mirror.c	2009/06/01 14:43:28	1.89
+++ LVM2/lib/metadata/mirror.c	2009/10/01 00:35:29	1.90
@@ -701,17 +701,16 @@
 static int _mirrored_lv_in_sync(struct logical_volume *lv)
 {
 	float sync_percent;
+	percent_range_t percent_range;
 
-	if (!lv_mirror_percent(lv->vg->cmd, lv, 0, &sync_percent, NULL)) {
+	if (!lv_mirror_percent(lv->vg->cmd, lv, 0, &sync_percent,
+			       &percent_range, NULL)) {
 		log_error("Unable to determine mirror sync status of %s/%s.",
 			  lv->vg->name, lv->name);
 		return 0;
 	}
 
-	if (sync_percent >= 100.0)
-		return 1;
-
-	return 0;
+	return (percent_range == PERCENT_100) ? 1 : 0;
 }
 
 /*
@@ -1203,6 +1202,7 @@
 		      struct dm_list *removable_pvs)
 {
 	float sync_percent;
+	percent_range_t percent_range = PERCENT_0;
 	struct lvinfo info;
 	struct volume_group *vg = lv->vg;
 
@@ -1214,7 +1214,8 @@
 
 	/* Had disk log, switch to core. */
 	if (lv_info(cmd, lv, &info, 0, 0) && info.exists) {
-		if (!lv_mirror_percent(cmd, lv, 0, &sync_percent, NULL)) {
+		if (!lv_mirror_percent(cmd, lv, 0, &sync_percent,
+				       &percent_range, NULL)) {
 			log_error("Unable to determine mirror sync status.");
 			return 0;
 		}
@@ -1229,7 +1230,7 @@
 	else
 		return 0;
 
-	if (sync_percent >= 100.0)
+	if (percent_range == PERCENT_100)
 		init_mirror_in_sync(1);
 	else {
 		/* A full resync will take place */
@@ -1353,6 +1354,7 @@
 	const struct segment_type *segtype;
 	struct dm_list *parallel_areas;
 	float sync_percent;
+	percent_range_t percent_range;
 	int in_sync;
 	struct logical_volume *log_lv;
 	struct lvinfo info;
@@ -1404,8 +1406,9 @@
 	}
 
 	/* check sync status */
-	if (lv_mirror_percent(cmd, lv, 0, &sync_percent, NULL) &&
-	    sync_percent >= 100.0)
+	if (lv_mirror_percent(cmd, lv, 0, &sync_percent, &percent_range,
+			      NULL) &&
+	    (percent_range == PERCENT_100))
 		in_sync = 1;
 	else
 		in_sync = 0;
--- LVM2/lib/metadata/segtype.h	2009/07/08 12:36:01	1.24
+++ LVM2/lib/metadata/segtype.h	2009/10/01 00:35:29	1.25
@@ -16,6 +16,8 @@
 #ifndef _SEGTYPES_H
 #define _SEGTYPES_H
 
+#include "metadata-exported.h"
+
 struct segtype_handler;
 struct cmd_context;
 struct config_tree;
@@ -73,7 +75,9 @@
                                 struct lv_segment *seg,
                                 struct dm_tree_node *node, uint64_t len,
                                 uint32_t *pvmove_mirror_count);
-	int (*target_percent) (void **target_state, struct dm_pool * mem,
+	int (*target_percent) (void **target_state,
+			       percent_range_t *percent_range,
+			       struct dm_pool * mem,
 			       struct cmd_context *cmd,
 			       struct lv_segment *seg, char *params,
 			       uint64_t *total_numerator,
--- LVM2/lib/mirror/mirrored.c	2009/08/13 19:36:04	1.63
+++ LVM2/lib/mirror/mirrored.c	2009/10/01 00:35:30	1.64
@@ -178,10 +178,13 @@
 	return mirr_state;
 }
 
-static int _mirrored_target_percent(void **target_state, struct dm_pool *mem,
-			   struct cmd_context *cmd, struct lv_segment *seg,
-			   char *params, uint64_t *total_numerator,
-			   uint64_t *total_denominator)
+static int _mirrored_target_percent(void **target_state,
+				    percent_range_t *percent_range,
+				    struct dm_pool *mem,
+				    struct cmd_context *cmd,
+				    struct lv_segment *seg, char *params,
+				    uint64_t *total_numerator,
+				    uint64_t *total_denominator)
 {
 	struct mirror_state *mirr_state;
 	uint64_t numerator, denominator;
@@ -226,6 +229,13 @@
 	if (seg)
 		seg->extents_copied = seg->area_len * numerator / denominator;
 
+	if (numerator == denominator)
+		*percent_range = PERCENT_100;
+	else if (numerator == 0)
+		*percent_range = PERCENT_0;
+	else
+		*percent_range = PERCENT_0_TO_100;
+
 	return 1;
 }
 
--- LVM2/lib/report/report.c	2009/09/15 18:35:14	1.102
+++ LVM2/lib/report/report.c	2009/10/01 00:35:30	1.103
@@ -275,18 +275,17 @@
 static int _lv_mimage_in_sync(const struct logical_volume *lv)
 {
 	float percent;
+	percent_range_t percent_range;
 	struct lv_segment *mirror_seg = find_mirror_seg(first_seg(lv));
 
 	if (!(lv->status & MIRROR_IMAGE) || !mirror_seg)
 		return_0;
 
-	if (!lv_mirror_percent(lv->vg->cmd, mirror_seg->lv, 0, &percent, NULL))
+	if (!lv_mirror_percent(lv->vg->cmd, mirror_seg->lv, 0, &percent,
+			       &percent_range, NULL))
 		return_0;
 
-	if (percent >= 100.0)
-		return 1;
-
-	return 0;
+	return (percent_range == PERCENT_100) ? 1 : 0;
 }
 
 static int _lvstatus_disp(struct dm_report *rh __attribute((unused)), struct dm_pool *mem,
@@ -297,6 +296,7 @@
 	struct lvinfo info;
 	char *repstr;
 	float snap_percent;
+	percent_range_t percent_range;
 
 	if (!(repstr = dm_pool_zalloc(mem, 7))) {
 		log_error("dm_pool_alloc failed");
@@ -363,8 +363,8 @@
 
 		/* Snapshot dropped? */
 		if (info.live_table && lv_is_cow(lv) &&
-		    (!lv_snapshot_percent(lv, &snap_percent) ||
-		     snap_percent < 0 || snap_percent >= 100)) {
+		    (!lv_snapshot_percent(lv, &snap_percent, &percent_range) ||
+		     percent_range == PERCENT_INVALID)) {
 			repstr[0] = toupper(repstr[0]);
 			if (info.suspended)
 				repstr[4] = 'S'; /* Susp Inv snapshot */
@@ -1009,6 +1009,7 @@
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 	struct lvinfo info;
 	float snap_percent;
+	percent_range_t percent_range;
 	uint64_t *sortval;
 	char *repstr;
 
@@ -1030,7 +1031,8 @@
 		return 1;
 	}
 
-	if (!lv_snapshot_percent(lv, &snap_percent) || snap_percent < 0) {
+	if (!lv_snapshot_percent(lv, &snap_percent, &percent_range) ||
+				 (percent_range == PERCENT_INVALID)) {
 		*sortval = UINT64_C(100);
 		dm_report_field_set_value(field, "100.00", sortval);
 		return 1;
@@ -1058,6 +1060,7 @@
 {
 	struct logical_volume *lv = (struct logical_volume *) data;
 	float percent;
+	percent_range_t percent_range;
 	uint64_t *sortval;
 	char *repstr;
 
@@ -1067,7 +1070,8 @@
 	}
 
 	if ((!(lv->status & PVMOVE) && !(lv->status & MIRRORED)) ||
-	    !lv_mirror_percent(lv->vg->cmd, lv, 0, &percent, NULL)) {
+	    !lv_mirror_percent(lv->vg->cmd, lv, 0, &percent, &percent_range,
+			       NULL) || (percent_range == PERCENT_INVALID)) {
 		*sortval = UINT64_C(0);
 		dm_report_field_set_value(field, "", sortval);
 		return 1;
--- LVM2/lib/snapshot/snapshot.c	2009/05/13 21:21:58	1.37
+++ LVM2/lib/snapshot/snapshot.c	2009/10/01 00:35:30	1.38
@@ -88,11 +88,12 @@
 
 #ifdef DEVMAPPER_SUPPORT
 static int _snap_target_percent(void **target_state __attribute((unused)),
-			   struct dm_pool *mem __attribute((unused)),
-			   struct cmd_context *cmd __attribute((unused)),
-			   struct lv_segment *seg __attribute((unused)),
-			   char *params, uint64_t *total_numerator,
-			   uint64_t *total_denominator)
+				percent_range_t *percent_range,
+				struct dm_pool *mem __attribute((unused)),
+				struct cmd_context *cmd __attribute((unused)),
+				struct lv_segment *seg __attribute((unused)),
+				char *params, uint64_t *total_numerator,
+				uint64_t *total_denominator)
 {
 	uint64_t numerator, denominator;
 
@@ -100,7 +101,16 @@
 		   &numerator, &denominator) == 2) {
 		*total_numerator += numerator;
 		*total_denominator += denominator;
-	}
+		if (!numerator)
+			*percent_range = PERCENT_0;
+		else if (numerator == denominator)
+			*percent_range = PERCENT_100;
+		else
+			*percent_range = PERCENT_0_TO_100;
+	} else if (!strcmp(params, "Invalid"))
+		*percent_range = PERCENT_INVALID;
+	else
+		return 0;
 
 	return 1;
 }
--- LVM2/tools/lvscan.c	2009/07/01 17:00:52	1.39
+++ LVM2/tools/lvscan.c	2009/10/01 00:35:30	1.40
@@ -24,6 +24,7 @@
 	int inkernel, snap_active = 1;
 	struct lv_segment *snap_seg = NULL;
 	float snap_percent;     /* fused, fsize; */
+	percent_range_t percent_range;
 
 	const char *active_str, *snapshot_str;
 
@@ -36,15 +37,17 @@
 				       origin_list) {
 			if (inkernel &&
 			    (snap_active = lv_snapshot_percent(snap_seg->cow,
-							       &snap_percent)))
-				if (snap_percent < 0 || snap_percent >= 100)
+							       &snap_percent,
+							       &percent_range)))
+				if (percent_range == PERCENT_INVALID)
 					snap_active = 0;
 		}
 		snap_seg = NULL;
 	} else if (lv_is_cow(lv)) {
 		if (inkernel &&
-		    (snap_active = lv_snapshot_percent(lv, &snap_percent)))
-			if (snap_percent < 0 || snap_percent >= 100)
+		    (snap_active = lv_snapshot_percent(lv, &snap_percent,
+						       &percent_range)))
+			if (percent_range == PERCENT_INVALID)
 				snap_active = 0;
 	}
 
--- LVM2/tools/polldaemon.c	2009/09/30 18:15:06	1.26
+++ LVM2/tools/polldaemon.c	2009/10/01 00:35:30	1.27
@@ -68,10 +68,12 @@
 				struct daemon_parms *parms)
 {
 	float segment_percent = 0.0, overall_percent = 0.0;
+	percent_range_t percent_range;
 	uint32_t event_nr = 0;
 
 	if (!lv_mirror_percent(cmd, lv, !parms->interval, &segment_percent,
-			       &event_nr)) {
+			       &percent_range, &event_nr) ||
+	    (percent_range == PERCENT_INVALID)) {
 		log_error("ABORTING: Mirror percentage check failed.");
 		return PROGRESS_CHECK_FAILED;
 	}
@@ -84,7 +86,7 @@
 		log_verbose("%s: %s: %.1f%%", name, parms->progress_title,
 			    overall_percent);
 
-	if (segment_percent < 100.0)
+	if (percent_range != PERCENT_100)
 		return PROGRESS_UNFINISHED;
 
 	if (overall_percent >= 100.0)


