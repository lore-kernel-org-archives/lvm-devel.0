From: agk@sourceware.org <agk@sourceware.org>
Date: 24 Jan 2007 16:51:25 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/activate.c lib/m ...
Message-ID: <20070124165125.22681.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-01-24 16:51:24

Modified files:
	.              : WHATS_NEW 
	lib/activate   : activate.c 
	lib/metadata   : segtype.h 
	lib/mirror     : mirrored.c 
	lib/report     : columns.h report.c 

Log message:
	Add field definitions to report help text.
	Remove unnecessary cmd arg from target_*monitor_events().

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.554&r2=1.555
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.117&r2=1.118
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/segtype.h.diff?cvsroot=lvm2&r1=1.16&r2=1.17
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mirror/mirrored.c.diff?cvsroot=lvm2&r1=1.44&r2=1.45
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/columns.h.diff?cvsroot=lvm2&r1=1.18&r2=1.19
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.53&r2=1.54

--- LVM2/WHATS_NEW	2007/01/23 17:40:40	1.554
+++ LVM2/WHATS_NEW	2007/01/24 16:51:23	1.555
@@ -1,5 +1,7 @@
 Version 2.02.20 -
 ===================================
+  Add field definitions to report help text.
+  Remove unnecessary cmd arg from target_*monitor_events().
   Add private variable to dmeventd shared library interface.
   Long-lived processes write out persistent dev cache in refresh_toolcontext().
   Fix refresh_toolcontext() always to wipe persistent device filter cache.
--- LVM2/lib/activate/activate.c	2007/01/19 22:21:45	1.117
+++ LVM2/lib/activate/activate.c	2007/01/24 16:51:23	1.118
@@ -697,7 +697,7 @@
 		log_verbose("%sonitoring %s/%s", monitor ? "M" : "Not m", lv->vg->name, lv->name);
 
 		/* FIXME specify events */
-		if (!monitor_fn(cmd, seg, 0)) {
+		if (!monitor_fn(seg, 0)) {
 			log_error("%s/%s: %s segment monitoring function failed.",
 				  lv->vg->name, lv->name, seg->segtype->name);
 			return 0;
--- LVM2/lib/metadata/segtype.h	2007/01/19 22:21:45	1.16
+++ LVM2/lib/metadata/segtype.h	2007/01/24 16:51:24	1.17
@@ -84,10 +84,8 @@
 			       struct list *modules);
 	void (*destroy) (const struct segment_type * segtype);
 	int (*target_monitored) (struct lv_segment *seg, int *pending);
-	int (*target_monitor_events) (struct cmd_context *cmd,
-				       struct lv_segment *seg, int events);
-	int (*target_unmonitor_events) (struct cmd_context *cmd,
-					 struct lv_segment *seg, int events);
+	int (*target_monitor_events) (struct lv_segment *seg, int events);
+	int (*target_unmonitor_events) (struct lv_segment *seg, int events);
 };
 
 struct segment_type *get_segtype_from_string(struct cmd_context *cmd,
--- LVM2/lib/mirror/mirrored.c	2007/01/19 22:21:45	1.44
+++ LVM2/lib/mirror/mirrored.c	2007/01/24 16:51:24	1.45
@@ -449,9 +449,7 @@
 }
 
 /* FIXME This gets run while suspended and performs banned operations. */
-static int _target_set_events(struct cmd_context *cmd,
-				   struct lv_segment *seg,
-				   int evmask, int set)
+static int _target_set_events(struct lv_segment *seg, int evmask, int set)
 {
 	char *dso, *name;
 	struct logical_volume *lv;
@@ -462,10 +460,10 @@
 	lv = seg->lv;
 	vg = lv->vg;
 
-	if (!_get_mirror_dso_path(cmd, &dso))
+	if (!_get_mirror_dso_path(vg->cmd, &dso))
 		return_0;
 
-	if (!(name = build_dm_name(cmd->mem, vg->name, lv->name, NULL)))
+	if (!(name = build_dm_name(vg->cmd->mem, vg->name, lv->name, NULL)))
 		return_0;
 
 	if (!(dmevh = _create_dm_event_handler(name, dso, DM_EVENT_ALL_ERRORS)))
@@ -481,18 +479,14 @@
 	return 1;
 }
 
-static int _target_monitor_events(struct cmd_context *cmd,
-				     struct lv_segment *seg,
-				     int events)
+static int _target_monitor_events(struct lv_segment *seg, int events)
 {
-	return _target_set_events(cmd, seg, events, 1);
+	return _target_set_events(seg, events, 1);
 }
 
-static int _target_unmonitor_events(struct cmd_context *cmd,
-				     struct lv_segment *seg,
-				     int events)
+static int _target_unmonitor_events(struct lv_segment *seg, int events)
 {
-	return _target_set_events(cmd, seg, events, 0);
+	return _target_set_events(seg, events, 0);
 }
 
 #endif /* DMEVENTD */
--- LVM2/lib/report/columns.h	2006/10/07 10:42:27	1.18
+++ LVM2/lib/report/columns.h	2007/01/24 16:51:24	1.19
@@ -18,67 +18,67 @@
  * Display Fn, Unique format identifier */
 
 /* *INDENT-OFF* */
-FIELD(LVS, lv, STR, "LV UUID", lvid.id[1], 38, uuid, "lv_uuid")
-FIELD(LVS, lv, STR, "LV", lvid, 4, lvname, "lv_name")
-FIELD(LVS, lv, STR, "Attr", lvid, 4, lvstatus, "lv_attr")
-FIELD(LVS, lv, NUM, "Maj", major, 3, int32, "lv_major")
-FIELD(LVS, lv, NUM, "Min", minor, 3, int32, "lv_minor")
-FIELD(LVS, lv, STR, "KMaj", lvid, 4, lvkmaj, "lv_kernel_major")
-FIELD(LVS, lv, STR, "KMin", lvid, 4, lvkmin, "lv_kernel_minor")
-FIELD(LVS, lv, NUM, "LSize", size, 5, size64, "lv_size")
-FIELD(LVS, lv, NUM, "#Seg", lvid, 4, lvsegcount, "seg_count")
-FIELD(LVS, lv, STR, "Origin", lvid, 6, origin, "origin")
-FIELD(LVS, lv, NUM, "Snap%", lvid, 6, snpercent, "snap_percent")
-FIELD(LVS, lv, NUM, "Copy%", lvid, 6, copypercent, "copy_percent")
-FIELD(LVS, lv, STR, "Move", lvid, 4, movepv, "move_pv")
-FIELD(LVS, lv, STR, "LV Tags", tags, 7, tags, "lv_tags")
-FIELD(LVS, lv, STR, "Log", lvid, 3, loglv, "mirror_log")
-FIELD(LVS, lv, STR, "Modules", lvid, 7, modules, "modules")
+FIELD(LVS, lv, STR, "LV UUID", lvid.id[1], 38, uuid, "lv_uuid", "Unique identifier")
+FIELD(LVS, lv, STR, "LV", lvid, 4, lvname, "lv_name", "Name.  LVs created for internal use are enclosed in brackets.")
+FIELD(LVS, lv, STR, "Attr", lvid, 4, lvstatus, "lv_attr", "Various attributes - see man page.")
+FIELD(LVS, lv, NUM, "Maj", major, 3, int32, "lv_major", "Persistent major number or -1 if not persistent.")
+FIELD(LVS, lv, NUM, "Min", minor, 3, int32, "lv_minor", "Persistent minor number or -1 if not persistent.")
+FIELD(LVS, lv, STR, "KMaj", lvid, 4, lvkmaj, "lv_kernel_major", "Currently assigned major number or -1 if LV is not active.")
+FIELD(LVS, lv, STR, "KMin", lvid, 4, lvkmin, "lv_kernel_minor", "Currently assigned minor number or -1 if LV is not active.")
+FIELD(LVS, lv, NUM, "LSize", size, 5, size64, "lv_size", "Size of LV in current units.")
+FIELD(LVS, lv, NUM, "#Seg", lvid, 4, lvsegcount, "seg_count", "Number of segments in LV.")
+FIELD(LVS, lv, STR, "Origin", lvid, 6, origin, "origin", "For snapshots, the origin device of this LV")
+FIELD(LVS, lv, NUM, "Snap%", lvid, 6, snpercent, "snap_percent", "For snapshots, the percentage full if LV is active.")
+FIELD(LVS, lv, NUM, "Copy%", lvid, 6, copypercent, "copy_percent", "For mirrors and pvmove, current percentage in-sync.")
+FIELD(LVS, lv, STR, "Move", lvid, 4, movepv, "move_pv", "For pvmove, Source PV of temporary LV created by pvmove")
+FIELD(LVS, lv, STR, "LV Tags", tags, 7, tags, "lv_tags", "Tags, if any.")
+FIELD(LVS, lv, STR, "Log", lvid, 3, loglv, "mirror_log", "For mirrors, the LV holding the synchronisation log.")
+FIELD(LVS, lv, STR, "Modules", lvid, 7, modules, "modules", "Kernel device-mapper modules required for this LV.")
 
-FIELD(PVS, pv, STR, "Fmt", id, 3, pvfmt, "pv_fmt")
-FIELD(PVS, pv, STR, "PV UUID", id, 38, uuid, "pv_uuid")
-FIELD(PVS, pv, NUM, "PSize", id, 5, pvsize, "pv_size")
-FIELD(PVS, pv, NUM, "DevSize", dev, 7, devsize, "dev_size")
-FIELD(PVS, pv, NUM, "1st PE", pe_start, 7, size64, "pe_start")
-FIELD(PVS, pv, NUM, "PFree", id, 5, pvfree, "pv_free")
-FIELD(PVS, pv, NUM, "Used", id, 4, pvused, "pv_used")
-FIELD(PVS, pv, STR, "PV", dev, 10, dev_name, "pv_name")
-FIELD(PVS, pv, STR, "Attr", status, 4, pvstatus, "pv_attr")
-FIELD(PVS, pv, NUM, "PE", pe_count, 3, uint32, "pv_pe_count")
-FIELD(PVS, pv, NUM, "Alloc", pe_alloc_count, 5, uint32, "pv_pe_alloc_count")
-FIELD(PVS, pv, STR, "PV Tags", tags, 7, tags, "pv_tags")
+FIELD(PVS, pv, STR, "Fmt", id, 3, pvfmt, "pv_fmt", "Type of metadata.")
+FIELD(PVS, pv, STR, "PV UUID", id, 38, uuid, "pv_uuid", "Unique identifier.")
+FIELD(PVS, pv, NUM, "PSize", id, 5, pvsize, "pv_size", "Size of PV in current units.")
+FIELD(PVS, pv, NUM, "DevSize", dev, 7, devsize, "dev_size", "Size of underlying device in current units.")
+FIELD(PVS, pv, NUM, "1st PE", pe_start, 7, size64, "pe_start", "Offset to the start of data on the underlying device.")
+FIELD(PVS, pv, NUM, "PFree", id, 5, pvfree, "pv_free", "Total amount of unallocated space in current units.")
+FIELD(PVS, pv, NUM, "Used", id, 4, pvused, "pv_used", "Total amount of allocated space in current units.")
+FIELD(PVS, pv, STR, "PV", dev, 10, dev_name, "pv_name", "Name.")
+FIELD(PVS, pv, STR, "Attr", status, 4, pvstatus, "pv_attr", "Various attributes - see man page.")
+FIELD(PVS, pv, NUM, "PE", pe_count, 3, uint32, "pv_pe_count", "Total number of Physical Extents.")
+FIELD(PVS, pv, NUM, "Alloc", pe_alloc_count, 5, uint32, "pv_pe_alloc_count", "Total number of allocated Physical Extents.")
+FIELD(PVS, pv, STR, "PV Tags", tags, 7, tags, "pv_tags", "Tags, if any.")
 
-FIELD(VGS, vg, STR, "Fmt", cmd, 3, vgfmt, "vg_fmt")
-FIELD(VGS, vg, STR, "VG UUID", id, 38, uuid, "vg_uuid")
-FIELD(VGS, vg, STR, "VG", name, 4, string, "vg_name")
-FIELD(VGS, vg, STR, "Attr", cmd, 5, vgstatus, "vg_attr")
-FIELD(VGS, vg, NUM, "VSize", cmd, 5, vgsize, "vg_size")
-FIELD(VGS, vg, NUM, "VFree", cmd, 5, vgfree, "vg_free")
-FIELD(VGS, vg, STR, "SYS ID", system_id, 6, string, "vg_sysid")
-FIELD(VGS, vg, NUM, "Ext", extent_size, 3, size32, "vg_extent_size")
-FIELD(VGS, vg, NUM, "#Ext", extent_count, 4, uint32, "vg_extent_count")
-FIELD(VGS, vg, NUM, "Free", free_count, 4, uint32, "vg_free_count")
-FIELD(VGS, vg, NUM, "MaxLV", max_lv, 5, uint32, "max_lv")
-FIELD(VGS, vg, NUM, "MaxPV", max_pv, 5, uint32, "max_pv")
-FIELD(VGS, vg, NUM, "#PV", pv_count, 3, uint32, "pv_count")
-FIELD(VGS, vg, NUM, "#LV", lv_count, 3, uint32, "lv_count")
-FIELD(VGS, vg, NUM, "#SN", snapshot_count, 3, uint32, "snap_count")
-FIELD(VGS, vg, NUM, "Seq", seqno, 3, uint32, "vg_seqno")
-FIELD(VGS, vg, STR, "VG Tags", tags, 7, tags, "vg_tags")
+FIELD(VGS, vg, STR, "Fmt", cmd, 3, vgfmt, "vg_fmt", "Type of metadata.")
+FIELD(VGS, vg, STR, "VG UUID", id, 38, uuid, "vg_uuid", "Unique identifier.")
+FIELD(VGS, vg, STR, "VG", name, 4, string, "vg_name", "Name.")
+FIELD(VGS, vg, STR, "Attr", cmd, 5, vgstatus, "vg_attr", "Various attributes - see man page.")
+FIELD(VGS, vg, NUM, "VSize", cmd, 5, vgsize, "vg_size", "Total size of VG in current units.")
+FIELD(VGS, vg, NUM, "VFree", cmd, 5, vgfree, "vg_free", "Total amount of free space in current units.")
+FIELD(VGS, vg, STR, "SYS ID", system_id, 6, string, "vg_sysid", "System ID indicating when and where it was created.")
+FIELD(VGS, vg, NUM, "Ext", extent_size, 3, size32, "vg_extent_size", "Size of Physical Extents in current units.")
+FIELD(VGS, vg, NUM, "#Ext", extent_count, 4, uint32, "vg_extent_count", "Total number of Physical Extents.")
+FIELD(VGS, vg, NUM, "Free", free_count, 4, uint32, "vg_free_count", "Total number of unallocated Physical Extents.")
+FIELD(VGS, vg, NUM, "MaxLV", max_lv, 5, uint32, "max_lv", "Maximum number of LVs allowed in VG or 0 if unlimited.")
+FIELD(VGS, vg, NUM, "MaxPV", max_pv, 5, uint32, "max_pv", "Maximum number of PVs allowed in VG or 0 if unlimited.")
+FIELD(VGS, vg, NUM, "#PV", pv_count, 3, uint32, "pv_count", "Number of PVs.")
+FIELD(VGS, vg, NUM, "#LV", lv_count, 3, uint32, "lv_count", "Number of LVs.")
+FIELD(VGS, vg, NUM, "#SN", snapshot_count, 3, uint32, "snap_count", "Number of snapshots.")
+FIELD(VGS, vg, NUM, "Seq", seqno, 3, uint32, "vg_seqno", "Revision number of internal metadata.  Incremented whenever it changes.")
+FIELD(VGS, vg, STR, "VG Tags", tags, 7, tags, "vg_tags", "Tags, if any.")
 
-FIELD(SEGS, seg, STR, "Type", list, 4, segtype, "segtype")
-FIELD(SEGS, seg, NUM, "#Str", area_count, 4, uint32, "stripes")
-FIELD(SEGS, seg, NUM, "Stripe", stripe_size, 6, size32, "stripesize")
-FIELD(SEGS, seg, NUM, "Stripe", stripe_size, 6, size32, "stripe_size")
-FIELD(SEGS, seg, NUM, "Chunk", list, 5, chunksize, "chunksize")
-FIELD(SEGS, seg, NUM, "Chunk", list, 5, chunksize, "chunk_size")
-FIELD(SEGS, seg, NUM, "Region", region_size, 6, size32, "regionsize")
-FIELD(SEGS, seg, NUM, "Region", region_size, 6, size32, "region_size")
-FIELD(SEGS, seg, NUM, "Start", list, 5, segstart, "seg_start")
-FIELD(SEGS, seg, NUM, "SSize", list, 5, segsize, "seg_size")
-FIELD(SEGS, seg, STR, "Seg Tags", tags, 8, tags, "seg_tags")
-FIELD(SEGS, seg, STR, "Devices", list, 5, devices, "devices")
+FIELD(SEGS, seg, STR, "Type", list, 4, segtype, "segtype", "Type of LV segment")
+FIELD(SEGS, seg, NUM, "#Str", area_count, 4, uint32, "stripes", "Number of stripes or mirror legs.")
+FIELD(SEGS, seg, NUM, "Stripe", stripe_size, 6, size32, "stripesize", "For stripes, amount of data placed on one device before switching to the next.")
+FIELD(SEGS, seg, NUM, "Stripe", stripe_size, 6, size32, "stripe_size", "For stripes, amount of data placed on one device before switching to the next.")
+FIELD(SEGS, seg, NUM, "Region", region_size, 6, size32, "regionsize", "For mirrors, the unit of data copied when synchronising devices.")
+FIELD(SEGS, seg, NUM, "Region", region_size, 6, size32, "region_size", "For mirrors, the unit of data copied when synchronising devices.")
+FIELD(SEGS, seg, NUM, "Chunk", list, 5, chunksize, "chunksize", "For snapshots, the unit of data used when tracking changes.")
+FIELD(SEGS, seg, NUM, "Chunk", list, 5, chunksize, "chunk_size", "For snapshots, the unit of data used when tracking changes.")
+FIELD(SEGS, seg, NUM, "Start", list, 5, segstart, "seg_start", "Offset within the LV to the start of the segment in current units.")
+FIELD(SEGS, seg, NUM, "SSize", list, 5, segsize, "seg_size", "Size of segment in current units.")
+FIELD(SEGS, seg, STR, "Seg Tags", tags, 8, tags, "seg_tags", "Tags, if any.")
+FIELD(SEGS, seg, STR, "Devices", list, 5, devices, "devices", "Underlying devices used with starting extent numbers.")
 
-FIELD(PVSEGS, pvseg, NUM, "Start", pe, 5, uint32, "pvseg_start")
-FIELD(PVSEGS, pvseg, NUM, "SSize", len, 5, uint32, "pvseg_size")
+FIELD(PVSEGS, pvseg, NUM, "Start", pe, 5, uint32, "pvseg_start", "Physical Extent number of start of segment.")
+FIELD(PVSEGS, pvseg, NUM, "SSize", len, 5, uint32, "pvseg_size", "Number of extents in segment.")
 /* *INDENT-ON* */
--- LVM2/lib/report/report.c	2007/01/22 15:07:21	1.53
+++ LVM2/lib/report/report.c	2007/01/24 16:51:24	1.54
@@ -868,11 +868,11 @@
 
 #define STR DM_REPORT_FIELD_TYPE_STRING
 #define NUM DM_REPORT_FIELD_TYPE_NUMBER
-#define FIELD(type, strct, sorttype, head, field, width, func, id) {type, id, (off_t)((void *)&_dummy._ ## strct.field - (void *)&_dummy._ ## strct), head, width, sorttype, &_ ## func ## _disp},
+#define FIELD(type, strct, sorttype, head, field, width, func, id, desc) {type, id, (off_t)((void *)&_dummy._ ## strct.field - (void *)&_dummy._ ## strct), head, width, sorttype, &_ ## func ## _disp, desc},
 
 static struct dm_report_field_type _fields[] = {
 #include "columns.h"
-{0, "", 0, "", 0, 0, NULL},
+{0, "", 0, "", 0, 0, NULL, NULL},
 };
 
 #undef STR


