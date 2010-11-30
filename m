From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 30 Nov 2010 11:53:36 -0000
Subject: LVM2 include/.symlinks.in lib/Makefile.in lib/ ...
Message-ID: <20101130115336.28589.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-11-30 11:53:33

Modified files:
	include        : .symlinks.in 
	lib            : Makefile.in 
	lib/activate   : activate.c activate.h dev_manager.c 
	                 dev_manager.h 
	lib/display    : display.c 
	lib/metadata   : lv.c metadata-exported.h mirror.c segtype.h 
	lib/mirror     : mirrored.c 
	lib/replicator : replicator.c 
	lib/report     : report.c 
	lib/snapshot   : snapshot.c 
	tools          : lvconvert.c lvcreate.c lvmcmdline.c lvresize.c 
	                 lvscan.c polldaemon.c tools.h 
Added files:
	lib/misc       : lvm-percent.c lvm-percent.h 

Log message:
	Refactor the percent (mirror sync, snapshot usage) handling code to use
	fixed-point values instead of a combination of a float value and an enum.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/include/.symlinks.in.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/Makefile.in.diff?cvsroot=lvm2&r1=1.108&r2=1.109
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.180&r2=1.181
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.h.diff?cvsroot=lvm2&r1=1.71&r2=1.72
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.205&r2=1.206
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.h.diff?cvsroot=lvm2&r1=1.34&r2=1.35
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/display/display.c.diff?cvsroot=lvm2&r1=1.114&r2=1.115
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv.c.diff?cvsroot=lvm2&r1=1.19&r2=1.20
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.171&r2=1.172
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.137&r2=1.138
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/segtype.h.diff?cvsroot=lvm2&r1=1.31&r2=1.32
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mirror/mirrored.c.diff?cvsroot=lvm2&r1=1.78&r2=1.79
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-percent.c.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-percent.h.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/replicator/replicator.c.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.140&r2=1.141
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/snapshot/snapshot.c.diff?cvsroot=lvm2&r1=1.50&r2=1.51
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.150&r2=1.151
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.225&r2=1.226
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.133&r2=1.134
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvresize.c.diff?cvsroot=lvm2&r1=1.125&r2=1.126
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvscan.c.diff?cvsroot=lvm2&r1=1.42&r2=1.43
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/polldaemon.c.diff?cvsroot=lvm2&r1=1.37&r2=1.38
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/tools.h.diff?cvsroot=lvm2&r1=1.73&r2=1.74

--- LVM2/include/.symlinks.in	2010/09/30 13:05:45	1.6
+++ LVM2/include/.symlinks.in	2010/11/30 11:53:31	1.7
@@ -52,6 +52,7 @@
 @top_srcdir@/lib/misc/lvm-string.h
 @top_builddir@/lib/misc/lvm-version.h
 @top_srcdir@/lib/misc/lvm-wrappers.h
+ at top_srcdir@/lib/misc/lvm-percent.h
 @top_srcdir@/lib/misc/sharedlib.h
 @top_srcdir@/lib/report/properties.h
 @top_srcdir@/lib/report/report.h
--- LVM2/lib/Makefile.in	2010/09/30 13:05:45	1.108
+++ LVM2/lib/Makefile.in	2010/11/30 11:53:31	1.109
@@ -91,6 +91,7 @@
 	misc/lvm-globals.c \
 	misc/lvm-string.c \
 	misc/lvm-wrappers.c \
+	misc/lvm-percent.c \
 	misc/util.c \
 	mm/memlock.c \
 	report/properties.c \
--- LVM2/lib/activate/activate.c	2010/11/09 12:34:41	1.180
+++ LVM2/lib/activate/activate.c	2010/11/30 11:53:31	1.181
@@ -158,14 +158,12 @@
 {
 	return 0;
 }
-int lv_snapshot_percent(const struct logical_volume *lv, float *percent,
-			percent_range_t *percent_range)
+int lv_snapshot_percent(const struct logical_volume *lv, percent_t *percent)
 {
 	return 0;
 }
 int lv_mirror_percent(struct cmd_context *cmd, struct logical_volume *lv,
-		      int wait, float *percent, percent_range_t *percent_range,
-		      uint32_t *event_nr)
+		      int wait, percent_t *percent, uint32_t *event_nr)
 {
 	return 0;
 }
@@ -523,8 +521,7 @@
 /*
  * Returns 1 if percent set, else 0 on failure.
  */
-int lv_snapshot_percent(const struct logical_volume *lv, float *percent,
-			percent_range_t *percent_range)
+int lv_snapshot_percent(const struct logical_volume *lv, percent_t *percent)
 {
 	int r;
 	struct dev_manager *dm;
@@ -535,7 +532,7 @@
 	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name)))
 		return_0;
 
-	if (!(r = dev_manager_snapshot_percent(dm, lv, percent, percent_range)))
+	if (!(r = dev_manager_snapshot_percent(dm, lv, percent)))
 		stack;
 
 	dev_manager_destroy(dm);
@@ -545,8 +542,7 @@
 
 /* FIXME Merge with snapshot_percent */
 int lv_mirror_percent(struct cmd_context *cmd, struct logical_volume *lv,
-		      int wait, float *percent, percent_range_t *percent_range,
-		      uint32_t *event_nr)
+		      int wait, percent_t *percent, uint32_t *event_nr)
 {
 	int r;
 	struct dev_manager *dm;
@@ -555,7 +551,7 @@
 	/* If mirrored LV is temporarily shrinked to 1 area (= linear),
 	 * it should be considered in-sync. */
 	if (dm_list_size(&lv->segments) == 1 && first_seg(lv)->area_count == 1) {
-		*percent = 100.0;
+		*percent = PERCENT_100;
 		return 1;
 	}
 
@@ -571,8 +567,7 @@
 	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name)))
 		return_0;
 
-	if (!(r = dev_manager_mirror_percent(dm, lv, wait, percent,
-					     percent_range, event_nr)))
+	if (!(r = dev_manager_mirror_percent(dm, lv, wait, percent, event_nr)))
 		stack;
 
 	dev_manager_destroy(dm);
--- LVM2/lib/activate/activate.h	2010/08/17 16:25:32	1.71
+++ LVM2/lib/activate/activate.h	2010/11/30 11:53:31	1.72
@@ -83,11 +83,9 @@
 /*
  * Returns 1 if percent has been set, else 0.
  */
-int lv_snapshot_percent(const struct logical_volume *lv, float *percent,
-			percent_range_t *percent_range);
+int lv_snapshot_percent(const struct logical_volume *lv, percent_t *percent);
 int lv_mirror_percent(struct cmd_context *cmd, struct logical_volume *lv,
-		      int wait, float *percent, percent_range_t *percent_range,
-		      uint32_t *event_nr);
+		      int wait, percent_t *percent, uint32_t *event_nr);
 
 /*
  * Return number of LVs in the VG that are active.
--- LVM2/lib/activate/dev_manager.c	2010/10/25 10:37:35	1.205
+++ LVM2/lib/activate/dev_manager.c	2010/11/30 11:53:31	1.206
@@ -428,8 +428,8 @@
 	return r;
 }
 
-static percent_range_t _combine_percent_ranges(percent_range_t a,
-					       percent_range_t b)
+static percent_range_t _combine_percent(percent_t a, percent_t b,
+                                        uint32_t numerator, uint32_t denominator)
 {
 	if (a == PERCENT_INVALID || b == PERCENT_INVALID)
 		return PERCENT_INVALID;
@@ -440,14 +440,13 @@
 	if (a == PERCENT_0 && b == PERCENT_0)
 		return PERCENT_0;
 
-	return PERCENT_0_TO_100;
+	return make_percent(numerator, denominator);
 }
 
 static int _percent_run(struct dev_manager *dm, const char *name,
 			const char *dlid,
 			const char *target_type, int wait,
-			const struct logical_volume *lv, float *percent,
-			percent_range_t *overall_percent_range,
+			const struct logical_volume *lv, percent_t *overall_percent,
 			uint32_t *event_nr, int fail_if_percent_unsupported)
 {
 	int r = 0;
@@ -460,13 +459,12 @@
 	const struct dm_list *segh = &lv->segments;
 	struct lv_segment *seg = NULL;
 	struct segment_type *segtype;
-	percent_range_t percent_range = 0, combined_percent_range = 0;
 	int first_time = 1;
+	percent_t percent;
 
 	uint64_t total_numerator = 0, total_denominator = 0;
 
-	*percent = -1;
-	*overall_percent_range = PERCENT_INVALID;
+	*overall_percent = PERCENT_INVALID;
 
 	if (!(dmt = _setup_task(name, dlid, event_nr,
 				wait ? DM_DEVICE_WAITEVENT : DM_DEVICE_STATUS, 0, 0)))
@@ -511,19 +509,19 @@
 
 		if (segtype->ops->target_percent &&
 		    !segtype->ops->target_percent(&dm->target_state,
-						  &percent_range, dm->mem,
+						  &percent, dm->mem,
 						  dm->cmd, seg, params,
 						  &total_numerator,
 						  &total_denominator))
 			goto_out;
 
 		if (first_time) {
-			combined_percent_range = percent_range;
+			*overall_percent = percent;
 			first_time = 0;
 		} else
-			combined_percent_range =
-			    _combine_percent_ranges(combined_percent_range,
-						    percent_range);
+			*overall_percent =
+				_combine_percent(*overall_percent, percent,
+						 total_numerator, total_denominator);
 	} while (next);
 
 	if (lv && (segh = dm_list_next(&lv->segments, segh))) {
@@ -532,22 +530,15 @@
 		goto out;
 	}
 
-	if (total_denominator) {
-		*percent = (float) total_numerator *100 / total_denominator;
-		*overall_percent_range = combined_percent_range;
-	} else {
-		*percent = 100;
-		if (first_time) {
-			/* above ->target_percent() was not executed! */
-			/* FIXME why return PERCENT_100 et. al. in this case? */
-			*overall_percent_range = PERCENT_100;
-			if (fail_if_percent_unsupported)
-				goto_out;
-		} else
-			*overall_percent_range = combined_percent_range;
+	if (first_time) {
+		/* above ->target_percent() was not executed! */
+		/* FIXME why return PERCENT_100 et. al. in this case? */
+		*overall_percent = PERCENT_100;
+		if (fail_if_percent_unsupported)
+			goto_out;
 	}
 
-	log_debug("LV percent: %f", *percent);
+	log_debug("LV percent: %f", percent_to_float(*overall_percent));
 	r = 1;
 
       out:
@@ -557,25 +548,21 @@
 
 static int _percent(struct dev_manager *dm, const char *name, const char *dlid,
 		    const char *target_type, int wait,
-		    const struct logical_volume *lv, float *percent,
-		    percent_range_t *overall_percent_range, uint32_t *event_nr,
-		    int fail_if_percent_unsupported)
+		    const struct logical_volume *lv, percent_t *percent,
+		    uint32_t *event_nr, int fail_if_percent_unsupported)
 {
 	if (dlid && *dlid) {
 		if (_percent_run(dm, NULL, dlid, target_type, wait, lv, percent,
-				 overall_percent_range, event_nr,
-				 fail_if_percent_unsupported))
+				 event_nr, fail_if_percent_unsupported))
 			return 1;
 		else if (_percent_run(dm, NULL, dlid + sizeof(UUID_PREFIX) - 1,
 				      target_type, wait, lv, percent,
-				      overall_percent_range, event_nr,
-				      fail_if_percent_unsupported))
+				      event_nr, fail_if_percent_unsupported))
 			return 1;
 	}
 
 	if (name && _percent_run(dm, name, NULL, target_type, wait, lv, percent,
-				 overall_percent_range, event_nr,
-				 fail_if_percent_unsupported))
+				 event_nr, fail_if_percent_unsupported))
 		return 1;
 
 	return 0;
@@ -694,7 +681,7 @@
 
 int dev_manager_snapshot_percent(struct dev_manager *dm,
 				 const struct logical_volume *lv,
-				 float *percent, percent_range_t *percent_range)
+				 percent_t *percent)
 {
 	char *name;
 	const char *dlid;
@@ -729,7 +716,7 @@
 	 */
 	log_debug("Getting device status percentage for %s", name);
 	if (!(_percent(dm, name, dlid, "snapshot", 0, NULL, percent,
-		       percent_range, NULL, fail_if_percent_unsupported)))
+		       NULL, fail_if_percent_unsupported)))
 		return_0;
 
 	/* FIXME dm_pool_free ? */
@@ -742,8 +729,7 @@
 /* FIXME Cope with more than one target */
 int dev_manager_mirror_percent(struct dev_manager *dm,
 			       const struct logical_volume *lv, int wait,
-			       float *percent, percent_range_t *percent_range,
-			       uint32_t *event_nr)
+			       percent_t *percent, uint32_t *event_nr)
 {
 	char *name;
 	const char *dlid;
@@ -764,7 +750,7 @@
 
 	log_debug("Getting device mirror status percentage for %s", name);
 	if (!(_percent(dm, name, dlid, "mirror", wait, lv, percent,
-		       percent_range, event_nr, 0)))
+		       event_nr, 0)))
 		return_0;
 
 	return 1;
--- LVM2/lib/activate/dev_manager.h	2010/08/17 16:25:33	1.34
+++ LVM2/lib/activate/dev_manager.h	2010/11/30 11:53:31	1.35
@@ -46,12 +46,10 @@
 		     struct dm_info *info, uint32_t *read_ahead);
 int dev_manager_snapshot_percent(struct dev_manager *dm,
 				 const struct logical_volume *lv,
-				 float *percent,
-				 percent_range_t *percent_range);
+				 percent_t *percent);
 int dev_manager_mirror_percent(struct dev_manager *dm,
 			       const struct logical_volume *lv, int wait,
-			       float *percent, percent_range_t *percent_range,
-			       uint32_t *event_nr);
+			       percent_t *percent, uint32_t *event_nr);
 int dev_manager_suspend(struct dev_manager *dm, struct logical_volume *lv,
 			unsigned origin_only, int lockfs, int flush_required);
 int dev_manager_activate(struct dev_manager *dm, struct logical_volume *lv, unsigned origin_only);
--- LVM2/lib/display/display.c	2010/11/09 12:34:42	1.114
+++ LVM2/lib/display/display.c	2010/11/30 11:53:31	1.115
@@ -492,8 +492,7 @@
 	int inkernel, snap_active = 0;
 	char uuid[64] __attribute__((aligned(8)));
 	struct lv_segment *snap_seg = NULL, *mirror_seg = NULL;
-	float snap_percent;	/* fused, fsize; */
-	percent_range_t percent_range;
+	percent_t snap_percent;
 
 	if (!id_write_format(&lv->lvid.id[1], uuid, sizeof(uuid)))
 		return_0;
@@ -518,9 +517,8 @@
 				       origin_list) {
 			if (inkernel &&
 			    (snap_active = lv_snapshot_percent(snap_seg->cow,
-							       &snap_percent,
-							       &percent_range)))
-				if (percent_range == PERCENT_INVALID)
+							       &snap_percent)))
+				if (snap_percent == PERCENT_INVALID)
 					snap_active = 0;
 			log_print("                       %s%s/%s [%s]",
 				  lv->vg->cmd->dev_dir, lv->vg->name,
@@ -531,9 +529,8 @@
 	} else if ((snap_seg = find_cow(lv))) {
 		if (inkernel &&
 		    (snap_active = lv_snapshot_percent(snap_seg->cow,
-						       &snap_percent,
-						       &percent_range)))
-			if (percent_range == PERCENT_INVALID)
+						       &snap_percent)))
+			if (snap_percent == PERCENT_INVALID)
 				snap_active = 0;
 
 		log_print("LV snapshot status     %s destination for %s%s/%s",
@@ -568,7 +565,8 @@
 		log_print("COW-table LE           %u", lv->le_count);
 
 		if (snap_active)
-			log_print("Allocated to snapshot  %.2f%% ", snap_percent);	
+			log_print("Allocated to snapshot  %.2f%% ",
+				  percent_to_float(snap_percent));
 
 		log_print("Snapshot chunk size    %s",
 			  display_size(cmd, (uint64_t) snap_seg->chunk_size));
--- LVM2/lib/metadata/lv.c	2010/11/17 20:08:14	1.19
+++ LVM2/lib/metadata/lv.c	2010/11/30 11:53:32	1.20
@@ -193,24 +193,22 @@
 
 static int _lv_mimage_in_sync(const struct logical_volume *lv)
 {
-	float percent;
-	percent_range_t percent_range;
+	percent_t percent;
 	struct lv_segment *mirror_seg = find_mirror_seg(first_seg(lv));
 
 	if (!(lv->status & MIRROR_IMAGE) || !mirror_seg)
 		return_0;
 
 	if (!lv_mirror_percent(lv->vg->cmd, mirror_seg->lv, 0, &percent,
-			       &percent_range, NULL))
+			       NULL))
 		return_0;
 
-	return (percent_range == PERCENT_100) ? 1 : 0;
+	return (percent == PERCENT_100) ? 1 : 0;
 }
 
 char *lv_attr_dup(struct dm_pool *mem, const struct logical_volume *lv)
 {
-	float snap_percent;
-	percent_range_t percent_range;
+	percent_t snap_percent;
 	struct lvinfo info;
 	char *repstr;
 
@@ -272,8 +270,8 @@
 
 		/* Snapshot dropped? */
 		if (info.live_table && lv_is_cow(lv) &&
-		    (!lv_snapshot_percent(lv, &snap_percent, &percent_range) ||
-		     percent_range == PERCENT_INVALID)) {
+		    (!lv_snapshot_percent(lv, &snap_percent) ||
+		     snap_percent == PERCENT_INVALID)) {
 			repstr[0] = toupper(repstr[0]);
 			if (info.suspended)
 				repstr[4] = 'S'; /* Susp Inv snapshot */
--- LVM2/lib/metadata/metadata-exported.h	2010/11/23 01:55:59	1.171
+++ LVM2/lib/metadata/metadata-exported.h	2010/11/30 11:53:32	1.172
@@ -25,6 +25,7 @@
 #include "pv.h"
 #include "vg.h"
 #include "lv.h"
+#include "lvm-percent.h"
 
 #define MAX_STRIPES 128U
 #define SECTOR_SHIFT 9L
@@ -139,13 +140,6 @@
 	DONT_PROMPT_OVERRIDE = 2 /* Skip prompt + override a second condition */
 } force_t;
 
-typedef enum {
-	PERCENT_0 = 0,
-	PERCENT_0_TO_100 = 1,
-	PERCENT_100 = 2,
-	PERCENT_INVALID = 3
-} percent_range_t;
-
 struct cmd_context;
 struct format_handler;
 struct labeller;
@@ -704,8 +698,7 @@
 						  uint32_t lv_type);
 const char *get_pvmove_pvname_from_lv(struct logical_volume *lv);
 const char *get_pvmove_pvname_from_lv_mirr(struct logical_volume *lv_mirr);
-float copy_percent(struct logical_volume *lv_mirr,
-		   percent_range_t *percent_range);
+percent_t copy_percent(struct logical_volume *lv_mirr);
 struct dm_list *lvs_using_lv(struct cmd_context *cmd, struct volume_group *vg,
 			  struct logical_volume *lv);
 
--- LVM2/lib/metadata/mirror.c	2010/11/09 12:34:43	1.137
+++ LVM2/lib/metadata/mirror.c	2010/11/30 11:53:32	1.138
@@ -547,17 +547,16 @@
 
 static int _mirrored_lv_in_sync(struct logical_volume *lv)
 {
-	float sync_percent;
-	percent_range_t percent_range;
+	percent_t sync_percent;
 
 	if (!lv_mirror_percent(lv->vg->cmd, lv, 0, &sync_percent,
-			       &percent_range, NULL)) {
+			       NULL)) {
 		log_error("Unable to determine mirror sync status of %s/%s.",
 			  lv->vg->name, lv->name);
 		return 0;
 	}
 
-	return (percent_range == PERCENT_100) ? 1 : 0;
+	return (sync_percent == PERCENT_100) ? 1 : 0;
 }
 
 /*
@@ -1508,8 +1507,7 @@
 	return lvs;
 }
 
-float copy_percent(struct logical_volume *lv_mirr,
-		   percent_range_t *percent_range)
+percent_t copy_percent(struct logical_volume *lv_mirr)
 {
 	uint32_t numerator = 0u, denominator = 0u;
 	struct lv_segment *seg;
@@ -1523,14 +1521,7 @@
 			numerator += seg->area_len;
 	}
 
-	if (!denominator || (numerator == denominator))
-		*percent_range = PERCENT_100;
-	else if (numerator == 0)
-		*percent_range = PERCENT_0;
-	else
-		*percent_range = PERCENT_0_TO_100;
-		
-	return denominator ? (float) numerator *100 / denominator : 100.0;
+	return denominator ? make_percent( numerator, denominator ) : 100.0;
 }
 
 /*
@@ -1604,8 +1595,7 @@
 		      struct dm_list *removable_pvs,
 		      int force)
 {
-	float sync_percent;
-	percent_range_t percent_range = PERCENT_0;
+	percent_t sync_percent;
 	struct lvinfo info;
 	struct volume_group *vg = lv->vg;
 
@@ -1618,7 +1608,7 @@
 	/* Had disk log, switch to core. */
 	if (lv_info(cmd, lv, 0, &info, 0, 0) && info.exists) {
 		if (!lv_mirror_percent(cmd, lv, 0, &sync_percent,
-				       &percent_range, NULL)) {
+				       NULL)) {
 			log_error("Unable to determine mirror sync status.");
 			return 0;
 		}
@@ -1633,7 +1623,7 @@
 	else
 		return 0;
 
-	if (percent_range == PERCENT_100)
+	if (sync_percent == PERCENT_100)
 		init_mirror_in_sync(1);
 	else {
 		/* A full resync will take place */
@@ -1798,8 +1788,7 @@
 	struct alloc_handle *ah;
 	const struct segment_type *segtype;
 	struct dm_list *parallel_areas;
-	float sync_percent;
-	percent_range_t percent_range;
+	percent_t sync_percent;
 	int in_sync;
 	struct logical_volume *log_lv;
 	struct lvinfo info;
@@ -1845,9 +1834,8 @@
 	}
 
 	/* check sync status */
-	if (lv_mirror_percent(cmd, lv, 0, &sync_percent, &percent_range,
-			      NULL) &&
-	    (percent_range == PERCENT_100))
+	if (lv_mirror_percent(cmd, lv, 0, &sync_percent, NULL) &&
+	    (sync_percent == PERCENT_100))
 		in_sync = 1;
 	else
 		in_sync = 0;
--- LVM2/lib/metadata/segtype.h	2010/10/13 21:26:37	1.31
+++ LVM2/lib/metadata/segtype.h	2010/11/30 11:53:32	1.32
@@ -85,7 +85,7 @@
 	int (*target_status_compatible) (const char *type);
 	int (*check_transient_status) (struct lv_segment *seg, char *params);
 	int (*target_percent) (void **target_state,
-			       percent_range_t *percent_range,
+			       percent_t *percent,
 			       struct dm_pool * mem,
 			       struct cmd_context *cmd,
 			       struct lv_segment *seg, char *params,
--- LVM2/lib/mirror/mirrored.c	2010/08/17 16:25:35	1.78
+++ LVM2/lib/mirror/mirrored.c	2010/11/30 11:53:32	1.79
@@ -177,7 +177,7 @@
 }
 
 static int _mirrored_target_percent(void **target_state,
-				    percent_range_t *percent_range,
+				    percent_t *percent,
 				    struct dm_pool *mem,
 				    struct cmd_context *cmd,
 				    struct lv_segment *seg, char *params,
@@ -227,12 +227,7 @@
 	if (seg)
 		seg->extents_copied = seg->area_len * numerator / denominator;
 
-	if (numerator == denominator)
-		*percent_range = PERCENT_100;
-	else if (numerator == 0)
-		*percent_range = PERCENT_0;
-	else
-		*percent_range = PERCENT_0_TO_100;
+        *percent = make_percent(numerator, denominator);
 
 	return 1;
 }
/cvs/lvm2/LVM2/lib/misc/lvm-percent.c,v  -->  standard output
revision 1.1
--- LVM2/lib/misc/lvm-percent.c
+++ -	2010-11-30 11:53:35.265706000 +0000
@@ -0,0 +1,40 @@
+/*
+ * Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+#include "lvm-percent.h"
+
+float percent_to_float(percent_t v)
+{
+    return (float)v / PERCENT_1;
+}
+
+percent_t make_percent(uint64_t numerator, uint64_t denominator)
+{
+    percent_t percent;
+    if (!denominator)
+        return PERCENT_100; /* FIXME? */
+    if (!numerator)
+        return PERCENT_0;
+    if (numerator == denominator)
+        return PERCENT_100;
+    switch (percent = PERCENT_100 * ((double) numerator / (double) denominator)) {
+    case PERCENT_100:
+        return PERCENT_100 - 1;
+    case PERCENT_0:
+        return PERCENT_0 + 1;
+    default:
+        return percent;
+    }
+}
+
/cvs/lvm2/LVM2/lib/misc/lvm-percent.h,v  -->  standard output
revision 1.1
--- LVM2/lib/misc/lvm-percent.h
+++ -	2010-11-30 11:53:35.390476000 +0000
@@ -0,0 +1,43 @@
+/*
+ * Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+#ifndef _LVM_PERCENT_H
+#define _LVM_PERCENT_H
+#include <stdint.h>
+
+/*
+ * A fixed-point representation of percent values. One percent equals to
+ * PERCENT_1 as defined below. Values that are not multiples of PERCENT_1
+ * represent fractions, with precision of 1/1000000 of a percent. See
+ * percent_to_float for a conversion to a floating-point representation.
+ *
+ * You should always use make_percent when building percent_t values. The
+ * implementation of make_percent is biased towards the middle: it ensures that
+ * the result is PERCENT_0 or PERCENT_100 if and only if this is the actual
+ * value -- it never rounds any intermediate value (> 0 or < 100) to either 0
+ * or 100.
+ */
+typedef int32_t percent_t;
+
+typedef enum {
+	PERCENT_0 = 0,
+	PERCENT_1 = 1000000,
+	PERCENT_100 = 100 * PERCENT_1,
+	PERCENT_INVALID = -1
+} percent_range_t;
+
+float percent_to_float(percent_t v);
+percent_t make_percent(uint64_t numerator, uint64_t denominator);
+
+#endif
--- LVM2/lib/replicator/replicator.c	2010/07/09 15:34:45	1.2
+++ LVM2/lib/replicator/replicator.c	2010/11/30 11:53:32	1.3
@@ -365,7 +365,7 @@
 
 /* FIXME: write something useful for replicator here */
 static int _replicator_target_percent(void **target_state,
-				      percent_range_t *percent_range,
+				      percent_t *percent,
 				      struct dm_pool *mem,
 				      struct cmd_context *cmd,
 				      struct lv_segment *seg,
@@ -708,7 +708,7 @@
 
 /* FIXME: write something useful for replicator-dev here */
 static int _replicator_dev_target_percent(void **target_state,
-					  percent_range_t *percent_range,
+					  percent_t *percent,
 					  struct dm_pool *mem,
 					  struct cmd_context *cmd,
 					  struct lv_segment *seg,
--- LVM2/lib/report/report.c	2010/11/17 20:08:14	1.140
+++ LVM2/lib/report/report.c	2010/11/30 11:53:32	1.141
@@ -795,8 +795,7 @@
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 	struct lvinfo info;
-	float snap_percent;
-	percent_range_t percent_range;
+	percent_t snap_percent;
 	uint64_t *sortval;
 	char *repstr;
 
@@ -818,8 +817,8 @@
 		return 1;
 	}
 
-	if (!lv_snapshot_percent(lv, &snap_percent, &percent_range) ||
-				 (percent_range == PERCENT_INVALID)) {
+	if (!lv_snapshot_percent(lv, &snap_percent) ||
+				 (snap_percent == PERCENT_INVALID)) {
 		if (!lv_is_merging_origin(lv)) {
 			*sortval = UINT64_C(100);
 			dm_report_field_set_value(field, "100.00", sortval);
@@ -838,7 +837,7 @@
 		return 0;
 	}
 
-	if (dm_snprintf(repstr, 7, "%.2f", snap_percent) < 0) {
+	if (dm_snprintf(repstr, 7, "%.2f", percent_to_float(snap_percent)) < 0) {
 		log_error("snapshot percentage too large");
 		return 0;
 	}
@@ -855,8 +854,7 @@
 			     const void *data, void *private __attribute__((unused)))
 {
 	struct logical_volume *lv = (struct logical_volume *) data;
-	float percent;
-	percent_range_t percent_range;
+	percent_t percent;
 	uint64_t *sortval;
 	char *repstr;
 
@@ -866,21 +864,21 @@
 	}
 
 	if ((!(lv->status & PVMOVE) && !(lv->status & MIRRORED)) ||
-	    !lv_mirror_percent(lv->vg->cmd, lv, 0, &percent, &percent_range,
-			       NULL) || (percent_range == PERCENT_INVALID)) {
+	    !lv_mirror_percent(lv->vg->cmd, lv, 0, &percent,
+			       NULL) || (percent == PERCENT_INVALID)) {
 		*sortval = UINT64_C(0);
 		dm_report_field_set_value(field, "", sortval);
 		return 1;
 	}
 
-	percent = copy_percent(lv, &percent_range);
+	percent = copy_percent(lv);
 
 	if (!(repstr = dm_pool_zalloc(mem, 8))) {
 		log_error("dm_pool_alloc failed");
 		return 0;
 	}
 
-	if (dm_snprintf(repstr, 7, "%.2f", percent) < 0) {
+	if (dm_snprintf(repstr, 7, "%.2f", percent_to_float(percent)) < 0) {
 		log_error("copy percentage too large");
 		return 0;
 	}
--- LVM2/lib/snapshot/snapshot.c	2010/10/13 21:26:37	1.50
+++ LVM2/lib/snapshot/snapshot.c	2010/11/30 11:53:32	1.51
@@ -109,7 +109,7 @@
 
 #ifdef DEVMAPPER_SUPPORT
 static int _snap_target_percent(void **target_state __attribute__((unused)),
-				percent_range_t *percent_range,
+				percent_t *percent,
 				struct dm_pool *mem __attribute__((unused)),
 				struct cmd_context *cmd __attribute__((unused)),
 				struct lv_segment *seg __attribute__((unused)),
@@ -130,14 +130,14 @@
 		*total_numerator += sectors_allocated;
 		*total_denominator += total_sectors;
 		if (r == 3 && sectors_allocated == metadata_sectors)
-			*percent_range = PERCENT_0;
+			*percent = PERCENT_0;
 		else if (sectors_allocated == total_sectors)
-			*percent_range = PERCENT_100;
+			*percent = PERCENT_100;
 		else
-			*percent_range = PERCENT_0_TO_100;
+			*percent = make_percent(*total_numerator, *total_denominator);
 	} else if (!strcmp(params, "Invalid") ||
 		   !strcmp(params, "Merge failed"))
-		*percent_range = PERCENT_INVALID;
+		*percent = PERCENT_INVALID;
 	else
 		return 0;
 
--- LVM2/tools/lvconvert.c	2010/11/28 18:37:33	1.150
+++ LVM2/tools/lvconvert.c	2010/11/30 11:53:33	1.151
@@ -425,23 +425,24 @@
 				       const char *name __attribute__((unused)),
 				       struct daemon_parms *parms)
 {
-	float percent = 0.0;
-	percent_range_t percent_range;
+	percent_t percent = PERCENT_0;
 
-	if (!lv_snapshot_percent(lv, &percent, &percent_range)) {
+	if (!lv_snapshot_percent(lv, &percent)) {
 		log_error("%s: Failed query for merging percentage. Aborting merge.", lv->name);
 		return PROGRESS_CHECK_FAILED;
-	} else if (percent_range == PERCENT_INVALID) {
+	} else if (percent == PERCENT_INVALID) {
 		log_error("%s: Merging snapshot invalidated. Aborting merge.", lv->name);
 		return PROGRESS_CHECK_FAILED;
 	}
 
 	if (parms->progress_display)
-		log_print("%s: %s: %.1f%%", lv->name, parms->progress_title, percent);
+		log_print("%s: %s: %.1f%%", lv->name, parms->progress_title,
+			  percent_to_float(percent));
 	else
-		log_verbose("%s: %s: %.1f%%", lv->name, parms->progress_title, percent);
+		log_verbose("%s: %s: %.1f%%", lv->name, parms->progress_title,
+			    percent_to_float(percent));
 
-	if (percent_range == PERCENT_0)
+	if (percent == PERCENT_0)
 		return PROGRESS_FINISHED_ALL;
 
 	return PROGRESS_UNFINISHED;
--- LVM2/tools/lvcreate.c	2010/11/11 17:29:06	1.225
+++ LVM2/tools/lvcreate.c	2010/11/30 11:53:33	1.226
@@ -19,7 +19,7 @@
 #include <fcntl.h>
 
 struct lvcreate_cmdline_params {
-	percent_t percent;
+	percent_type_t percent;
 	uint64_t size;
 	char **pvs;
 	int pv_count;
--- LVM2/tools/lvmcmdline.c	2010/11/29 11:14:33	1.133
+++ LVM2/tools/lvmcmdline.c	2010/11/30 11:53:33	1.134
@@ -126,7 +126,7 @@
 	return arg_count(cmd, a) ? cmd->arg_values[a].sign : def;
 }
 
-percent_t arg_percent_value(struct cmd_context *cmd, int a, const percent_t def)
+percent_type_t arg_percent_value(struct cmd_context *cmd, int a, const percent_type_t def)
 {
 	return arg_count(cmd, a) ? cmd->arg_values[a].percent : def;
 }
--- LVM2/tools/lvresize.c	2010/11/01 14:17:36	1.125
+++ LVM2/tools/lvresize.c	2010/11/30 11:53:33	1.126
@@ -31,7 +31,7 @@
 	uint32_t extents;
 	uint64_t size;
 	sign_t sign;
-	percent_t percent;
+	percent_type_t percent;
 
 	enum {
 		LV_ANY = 0,
@@ -282,24 +282,23 @@
 static int _adjust_policy_params(struct cmd_context *cmd,
 				 struct logical_volume *lv, struct lvresize_params *lp)
 {
-	float percent;
-	percent_range_t range;
+	percent_t percent;
 	int policy_threshold, policy_amount;
 
 	policy_threshold =
 		find_config_tree_int(cmd, "activation/snapshot_autoextend_threshold",
-				     DEFAULT_SNAPSHOT_AUTOEXTEND_THRESHOLD);
+				     DEFAULT_SNAPSHOT_AUTOEXTEND_THRESHOLD) * PERCENT_1;
 	policy_amount =
 		find_config_tree_int(cmd, "activation/snapshot_autoextend_percent",
 				     DEFAULT_SNAPSHOT_AUTOEXTEND_PERCENT);
 
-	if (policy_threshold >= 100)
+	if (policy_threshold >= PERCENT_100)
 		return 1; /* nothing to do */
 
-	if (!lv_snapshot_percent(lv, &percent, &range))
+	if (!lv_snapshot_percent(lv, &percent))
 		return_0;
 
-	if (range != PERCENT_0_TO_100 || percent <= policy_threshold)
+	if (!(PERCENT_0 < percent && percent < PERCENT_100) || percent <= policy_threshold)
 		return 1; /* nothing to do */
 
 	lp->extents = policy_amount;
--- LVM2/tools/lvscan.c	2010/08/17 16:25:35	1.42
+++ LVM2/tools/lvscan.c	2010/11/30 11:53:33	1.43
@@ -23,8 +23,7 @@
 	uint64_t lv_capacity_total = 0;
 	int inkernel, snap_active = 1;
 	struct lv_segment *snap_seg = NULL;
-	float snap_percent;     /* fused, fsize; */
-	percent_range_t percent_range;
+	percent_t snap_percent;     /* fused, fsize; */
 
 	const char *active_str, *snapshot_str;
 
@@ -37,17 +36,15 @@
 				       origin_list) {
 			if (inkernel &&
 			    (snap_active = lv_snapshot_percent(snap_seg->cow,
-							       &snap_percent,
-							       &percent_range)))
-				if (percent_range == PERCENT_INVALID)
+							       &snap_percent)))
+				if (snap_percent == PERCENT_INVALID)
 					snap_active = 0;
 		}
 		snap_seg = NULL;
 	} else if (lv_is_cow(lv)) {
 		if (inkernel &&
-		    (snap_active = lv_snapshot_percent(lv, &snap_percent,
-						       &percent_range)))
-			if (percent_range == PERCENT_INVALID)
+		    (snap_active = lv_snapshot_percent(lv, &snap_percent)))
+			if (snap_percent == PERCENT_INVALID)
 				snap_active = 0;
 	}
 
--- LVM2/tools/polldaemon.c	2010/08/26 16:29:12	1.37
+++ LVM2/tools/polldaemon.c	2010/11/30 11:53:33	1.38
@@ -74,30 +74,29 @@
 				struct logical_volume *lv, const char *name,
 				struct daemon_parms *parms)
 {
-	float segment_percent = 0.0, overall_percent = 0.0;
-	percent_range_t percent_range, overall_percent_range;
+	percent_t segment_percent = PERCENT_0, overall_percent = PERCENT_0;
 	uint32_t event_nr = 0;
 
 	if (!lv_is_mirrored(lv) ||
 	    !lv_mirror_percent(cmd, lv, !parms->interval, &segment_percent,
-			       &percent_range, &event_nr) ||
-	    (percent_range == PERCENT_INVALID)) {
+			       &event_nr) ||
+	    (segment_percent == PERCENT_INVALID)) {
 		log_error("ABORTING: Mirror percentage check failed.");
 		return PROGRESS_CHECK_FAILED;
 	}
 
-	overall_percent = copy_percent(lv, &overall_percent_range);
+	overall_percent = copy_percent(lv);
 	if (parms->progress_display)
 		log_print("%s: %s: %.1f%%", name, parms->progress_title,
-			  overall_percent);
+			  percent_to_float(overall_percent));
 	else
 		log_verbose("%s: %s: %.1f%%", name, parms->progress_title,
-			    overall_percent);
+			    percent_to_float(overall_percent));
 
-	if (percent_range != PERCENT_100)
+	if (segment_percent != PERCENT_100)
 		return PROGRESS_UNFINISHED;
 
-	if (overall_percent_range == PERCENT_100)
+	if (overall_percent == PERCENT_100)
 		return PROGRESS_FINISHED_ALL;
 
 	return PROGRESS_FINISHED_SEGMENT;
--- LVM2/tools/tools.h	2010/11/11 17:29:06	1.73
+++ LVM2/tools/tools.h	2010/11/30 11:53:33	1.74
@@ -85,7 +85,7 @@
 	PERCENT_LV,
 	PERCENT_PVS,
 	PERCENT_ORIGIN
-} percent_t;
+} percent_type_t;
 
 enum {
 	CHANGE_AY = 0,
@@ -106,7 +106,7 @@
 	int64_t i64_value;
 	uint64_t ui64_value;
 	sign_t sign;
-	percent_t percent;
+	percent_type_t percent;
 /*	void *ptr; // Currently not used. */
 };
 
@@ -174,7 +174,7 @@
 uint64_t arg_uint64_value(struct cmd_context *cmd, int a, const uint64_t def);
 const void *arg_ptr_value(struct cmd_context *cmd, int a, const void *def);
 sign_t arg_sign_value(struct cmd_context *cmd, int a, const sign_t def);
-percent_t arg_percent_value(struct cmd_context *cmd, int a, const percent_t def);
+percent_type_t arg_percent_value(struct cmd_context *cmd, int a, const percent_type_t def);
 int arg_count_increment(struct cmd_context *cmd, int a);
 
 unsigned grouped_arg_count(const struct arg_values *av, int a);


