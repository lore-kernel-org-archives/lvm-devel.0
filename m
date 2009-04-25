From: agk@sourceware.org <agk@sourceware.org>
Date: 25 Apr 2009 01:18:02 -0000
Subject: LVM2 ./WHATS_NEW lib/format_text/flags.c lib/m ...
Message-ID: <20090425011802.13191.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-04-25 01:18:00

Modified files:
	.              : WHATS_NEW 
	lib/format_text: flags.c 
	lib/metadata   : metadata-exported.h metadata.h snapshot_manip.c 
	lib/report     : columns.h report.c 
	man            : lvcreate.8.in lvs.8.in 
	tools          : args.h commands.h lvchange.c lvcreate.c 
	                 lvremove.c toollib.c 

Log message:
	Add sparse devices: lvcreate -s --virtualoriginsize (hidden zero origin).
	Add lvs origin_size field.
	Fix linux configure --enable-debug to exclude -O2.
	
	Still a few rough edges, but hopefully usable now:
	lvcreate -s vg1 -L 100M --virtualoriginsize 1T

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1095&r2=1.1096
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/flags.c.diff?cvsroot=lvm2&r1=1.35&r2=1.36
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.64&r2=1.65
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.191&r2=1.192
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/snapshot_manip.c.diff?cvsroot=lvm2&r1=1.34&r2=1.35
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/columns.h.diff?cvsroot=lvm2&r1=1.33&r2=1.34
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.96&r2=1.97
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvcreate.8.in.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvs.8.in.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/args.h.diff?cvsroot=lvm2&r1=1.62&r2=1.63
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/commands.h.diff?cvsroot=lvm2&r1=1.124&r2=1.125
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvchange.c.diff?cvsroot=lvm2&r1=1.98&r2=1.99
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.182&r2=1.183
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvremove.c.diff?cvsroot=lvm2&r1=1.56&r2=1.57
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.151&r2=1.152

--- LVM2/WHATS_NEW	2009/04/23 16:56:22	1.1095
+++ LVM2/WHATS_NEW	2009/04/25 01:17:59	1.1096
@@ -1,5 +1,8 @@
 Version 2.02.46 - 
 ================================
+  Add sparse devices: lvcreate -s --virtualoriginsize (hidden zero origin).
+  Add lvs origin_size field.
+  Fix linux configure --enable-debug to exclude -O2.
   Implement lvconvert --repair, for repairing partially failed mirrors.
   Fix vgreduce --removemissing failure exit code.
   Fix remote metadata backup for clvmd.
--- LVM2/lib/format_text/flags.c	2008/09/19 06:41:58	1.35
+++ LVM2/lib/format_text/flags.c	2009/04/25 01:17:59	1.36
@@ -65,6 +65,7 @@
 	{CONVERTING, NULL, 0},
 	{PARTIAL_LV, NULL, 0},
 	{POSTORDER_FLAG, NULL, 0},
+	{VIRTUAL_ORIGIN, NULL, 0},
 	{0, NULL, 0}
 };
 
--- LVM2/lib/metadata/metadata-exported.h	2009/04/10 09:59:19	1.64
+++ LVM2/lib/metadata/metadata-exported.h	2009/04/25 01:17:59	1.65
@@ -77,6 +77,7 @@
 
 //#define POSTORDER_FLAG	0x02000000U /* Not real flags, reserved for
 //#define POSTORDER_OPEN_FLAG	0x04000000U    temporary use inside vg_read_internal. */
+//#define VIRTUAL_ORIGIN	0x08000000U	/* LV - internal use only */
 
 #define LVM_READ              	0x00000100U	/* LV VG */
 #define LVM_WRITE             	0x00000200U	/* LV VG */
@@ -531,6 +532,7 @@
 * Useful functions for managing snapshots.
 */
 int lv_is_origin(const struct logical_volume *lv);
+int lv_is_virtual_origin(const struct logical_volume *lv);
 int lv_is_cow(const struct logical_volume *lv);
 int lv_is_visible(const struct logical_volume *lv);
 
--- LVM2/lib/metadata/metadata.h	2009/04/10 09:59:19	1.191
+++ LVM2/lib/metadata/metadata.h	2009/04/25 01:18:00	1.192
@@ -81,6 +81,7 @@
 
 #define POSTORDER_FLAG		0x02000000U /* Not real flags, reserved for  */
 #define POSTORDER_OPEN_FLAG	0x04000000U /* temporary use inside vg_read_internal. */
+#define VIRTUAL_ORIGIN		0x08000000U	/* LV - internal use only */
 
 //#define LVM_READ              	0x00000100U	/* LV VG */
 //#define LVM_WRITE             	0x00000200U	/* LV VG */
--- LVM2/lib/metadata/snapshot_manip.c	2009/03/16 14:34:58	1.34
+++ LVM2/lib/metadata/snapshot_manip.c	2009/04/25 01:18:00	1.35
@@ -44,6 +44,12 @@
 	return (lv->status & VISIBLE_LV) || lv_is_cow(lv) ? 1 : 0;
 }
 
+int lv_is_virtual_origin(const struct logical_volume *lv)
+{
+	return (lv->status & VIRTUAL_ORIGIN) ? 1 : 0;
+}
+
+
 /* Given a cow LV, return the snapshot lv_segment that uses it */
 struct lv_segment *find_cow(const struct logical_volume *lv)
 {
@@ -105,6 +111,10 @@
 
 	cow->status &= ~VISIBLE_LV;
 
+        /* FIXME Assumes an invisible origin belongs to a sparse device */
+        if (!lv_is_visible(origin))
+                origin->status |= VIRTUAL_ORIGIN;
+
 	dm_list_add(&origin->snapshot_segs, &seg->origin_list);
 
 	return 1;
--- LVM2/lib/report/columns.h	2009/04/23 16:27:58	1.33
+++ LVM2/lib/report/columns.h	2009/04/25 01:18:00	1.34
@@ -53,7 +53,7 @@
  */
 
 /* *INDENT-OFF* */
-FIELD(LVS, lv, STR, "LV UUID", lvid.id[1], 38, uuid, "lv_uuid", "Unique identifier")
+FIELD(LVS, lv, STR, "LV UUID", lvid.id[1], 38, uuid, "lv_uuid", "Unique identifier.")
 FIELD(LVS, lv, STR, "LV", lvid, 4, lvname, "lv_name", "Name.  LVs created for internal use are enclosed in brackets.")
 FIELD(LVS, lv, STR, "Attr", lvid, 4, lvstatus, "lv_attr", "Various attributes - see man page.")
 FIELD(LVS, lv, NUM, "Maj", major, 3, int32, "lv_major", "Persistent major number or -1 if not persistent.")
@@ -64,11 +64,12 @@
 FIELD(LVS, lv, NUM, "KRahead", lvid, 7, lvkreadahead, "lv_kernel_read_ahead", "Currently-in-use read ahead setting in current units.")
 FIELD(LVS, lv, NUM, "LSize", size, 5, size64, "lv_size", "Size of LV in current units.")
 FIELD(LVS, lv, NUM, "#Seg", lvid, 4, lvsegcount, "seg_count", "Number of segments in LV.")
-FIELD(LVS, lv, STR, "Origin", lvid, 6, origin, "origin", "For snapshots, the origin device of this LV")
+FIELD(LVS, lv, STR, "Origin", lvid, 6, origin, "origin", "For snapshots, the origin device of this LV.")
+FIELD(LVS, lv, NUM, "OSize", lvid, 5, originsize, "origin_size", "For snapshots, the size of the origin device of this LV.")
 FIELD(LVS, lv, NUM, "Snap%", lvid, 6, snpercent, "snap_percent", "For snapshots, the percentage full if LV is active.")
 FIELD(LVS, lv, NUM, "Copy%", lvid, 6, copypercent, "copy_percent", "For mirrors and pvmove, current percentage in-sync.")
-FIELD(LVS, lv, STR, "Move", lvid, 4, movepv, "move_pv", "For pvmove, Source PV of temporary LV created by pvmove")
-FIELD(LVS, lv, STR, "Convert", lvid, 7, convertlv, "convert_lv", "For lvconvert, Name of temporary LV created by lvconvert")
+FIELD(LVS, lv, STR, "Move", lvid, 4, movepv, "move_pv", "For pvmove, Source PV of temporary LV created by pvmove.")
+FIELD(LVS, lv, STR, "Convert", lvid, 7, convertlv, "convert_lv", "For lvconvert, Name of temporary LV created by lvconvert.")
 FIELD(LVS, lv, STR, "LV Tags", tags, 7, tags, "lv_tags", "Tags, if any.")
 FIELD(LVS, lv, STR, "Log", lvid, 3, loglv, "mirror_log", "For mirrors, the LV holding the synchronisation log.")
 FIELD(LVS, lv, STR, "Modules", lvid, 7, modules, "modules", "Kernel device-mapper modules required for this LV.")
@@ -111,7 +112,7 @@
 FIELD(VGS, vg, NUM, "VMdaFree", cmd, 9, vgmdafree, "vg_mda_free", "Free metadata area space for this VG in current units.")
 FIELD(VGS, vg, NUM, "VMdaSize", cmd, 9, vgmdasize, "vg_mda_size", "Size of smallest metadata area for this VG in current units.")
 
-FIELD(SEGS, seg, STR, "Type", list, 4, segtype, "segtype", "Type of LV segment")
+FIELD(SEGS, seg, STR, "Type", list, 4, segtype, "segtype", "Type of LV segment.")
 FIELD(SEGS, seg, NUM, "#Str", area_count, 4, uint32, "stripes", "Number of stripes or mirror legs.")
 FIELD(SEGS, seg, NUM, "Stripe", stripe_size, 6, size32, "stripesize", "For stripes, amount of data placed on one device before switching to the next.")
 FIELD(SEGS, seg, NUM, "Stripe", stripe_size, 6, size32, "stripe_size", "For stripes, amount of data placed on one device before switching to the next.")
--- LVM2/lib/report/report.c	2009/02/09 09:45:49	1.96
+++ LVM2/lib/report/report.c	2009/04/25 01:18:00	1.97
@@ -471,20 +471,6 @@
 	return 1;
 }
 
-static int _origin_disp(struct dm_report *rh, struct dm_pool *mem __attribute((unused)),
-			struct dm_report_field *field,
-			const void *data, void *private __attribute((unused)))
-{
-	const struct logical_volume *lv = (const struct logical_volume *) data;
-
-	if (lv_is_cow(lv))
-		return dm_report_field_string(rh, field,
-					      (const char **) &origin_from_cow(lv)->name);
-
-	dm_report_field_set_value(field, "", NULL);
-	return 1;
-}
-
 static int _loglv_disp(struct dm_report *rh, struct dm_pool *mem __attribute((unused)),
 		       struct dm_report_field *field,
 		       const void *data, void *private __attribute((unused)))
@@ -537,6 +523,19 @@
 	return 1;
 }
 
+static int _origin_disp(struct dm_report *rh, struct dm_pool *mem,
+			struct dm_report_field *field,
+			const void *data, void *private)
+{
+	const struct logical_volume *lv = (const struct logical_volume *) data;
+
+	if (lv_is_cow(lv))
+		return _lvname_disp(rh, mem, field, origin_from_cow(lv), private);
+
+	dm_report_field_set_value(field, "", NULL);
+	return 1;
+}
+
 static int _movepv_disp(struct dm_report *rh, struct dm_pool *mem __attribute((unused)),
 			struct dm_report_field *field,
 			const void *data, void *private __attribute((unused)))
@@ -723,7 +722,24 @@
 	if (lv_is_cow(seg->lv))
 		size = (uint64_t) find_cow(seg->lv)->chunk_size;
 	else
-		size = 0;
+		size = UINT64_C(0);
+
+	return _size64_disp(rh, mem, field, &size, private);
+}
+
+static int _originsize_disp(struct dm_report *rh, struct dm_pool *mem,
+			    struct dm_report_field *field,
+			    const void *data, void *private)
+{
+	const struct logical_volume *lv = (const struct logical_volume *) data;
+	uint64_t size;
+
+	if (lv_is_cow(lv))
+		size = (uint64_t) find_cow(lv)->len * lv->vg->extent_size;
+	else if (lv_is_origin(lv))
+		size = lv->size;
+	else
+		size = UINT64_C(0);
 
 	return _size64_disp(rh, mem, field, &size, private);
 }
--- LVM2/man/lvcreate.8.in	2008/11/12 15:01:36	1.3
+++ LVM2/man/lvcreate.8.in	2009/04/25 01:18:00	1.4
@@ -25,7 +25,9 @@
 {\-l|\-\-extents LogicalExtentsNumber[%{VG|FREE}] |
  \-L|\-\-size LogicalVolumeSize[kKmMgGtT]}
 [\-c|\-\-chunksize ChunkSize]
-\-s|\-\-snapshot \-n|\-\-name SnapshotLogicalVolumeName OriginalLogicalVolumePath
+\-n|\-\-name SnapshotLogicalVolumeName 
+\-s|\-\-snapshot
+[OriginalLogicalVolumePath | VolumeGroupName \-\-virtualoriginsize VirtualOriginSize]
 .SH DESCRIPTION
 lvcreate creates a new logical volume in a volume group ( see
 .B vgcreate(8), vgchange(8)
@@ -144,6 +146,19 @@
 as well. Run
 .B lvdisplay(8)
 on the snapshot in order to check how much data is allocated to it.
+Note that a small amount of the space you allocate to the snapshot is
+used to track the locations of the chunks of data, so you should 
+allocate slightly more space than you actually need and monitor the
+rate at which the snapshot data is growing so you can avoid running out
+of space.
+.TP
+.I \-\-virtualoriginsize VirtualOriginSize
+In conjunction with \-\-snapshot, create a sparse device of the given size
+(in MB by default).  Anything written to the device will be returned when
+reading from it.  Reading from other areas of the device will return
+blocks of zeros.  It is implemented by creating a hidden virtual device of the
+requested size using the zero target.  A suffix of _vorigin is used for
+this device.
 .TP
 .I \-Z, \-\-zero y|n
 Controls zeroing of the first KB of data in the new logical volume.
@@ -180,6 +195,11 @@
 arbitrary directory in order to access the contents of the filesystem to run
 a backup while the original filesystem continues to get updated.
 
+"lvcreate --virtualoriginsize 1T --size 100M --snapshot --name sparse vg1"
+.br
+creates a sparse device named /dev/vg1/sparse of size 1TB with space for just
+under 100MB of actual data on it.
+
 .SH SEE ALSO
 .BR lvm (8), 
 .BR vgcreate (8), 
--- LVM2/man/lvs.8.in	2009/01/20 17:39:08	1.6
+++ LVM2/man/lvs.8.in	2009/04/25 01:18:00	1.7
@@ -39,7 +39,7 @@
 to the default selection of columns instead of replacing it.  Column names are: 
 lv_uuid, lv_name, lv_attr, lv_major, lv_minor, lv_kernel_major, lv_kernel_minor,
 lv_size, seg_count, origin, snap_percent,
-copy_percent, move_pv, lv_tags,
+copy_percent, move_pv, lv_tags, origin_size,
 segtype, stripes,
 stripesize, chunksize, seg_start, seg_size, seg_tags, devices,
 regionsize, mirror_log, modules.
--- LVM2/tools/args.h	2009/04/23 16:56:22	1.62
+++ LVM2/tools/args.h	2009/04/25 01:18:00	1.63
@@ -58,6 +58,7 @@
 arg(unquoted_ARG, '\0', "unquoted", NULL, 0)
 arg(rows_ARG, '\0', "rows", NULL, 0)
 arg(dataalignment_ARG, '\0', "dataalignment", size_kb_arg, 0)
+arg(virtualoriginsize_ARG, '\0', "virtualoriginsize", size_mb_arg, 0)
 
 /* Allow some variations */
 arg(resizable_ARG, '\0', "resizable", yes_no_arg, 0)
--- LVM2/tools/commands.h	2009/04/23 16:56:22	1.124
+++ LVM2/tools/commands.h	2009/04/25 01:18:00	1.125
@@ -163,13 +163,15 @@
    "\t[-t|--test]\n"
    "\t[-v|--verbose]\n"
    "\t[--version]\n"
-   "\tOriginalLogicalVolume[Path] [PhysicalVolumePath...]\n\n",
+   "\t[OriginalLogicalVolume[Path] |\n"
+   "\t VolumeGroupName[Path] --virtualoriginsize VirtualOriginSize]]\n"
+   "\t[PhysicalVolumePath...]\n\n",
 
    addtag_ARG, alloc_ARG, autobackup_ARG, chunksize_ARG, contiguous_ARG,
    corelog_ARG, extents_ARG, major_ARG, minor_ARG, mirrorlog_ARG, mirrors_ARG,
    name_ARG, nosync_ARG, permission_ARG, persistent_ARG, readahead_ARG,
    regionsize_ARG, size_ARG, snapshot_ARG, stripes_ARG, stripesize_ARG,
-   test_ARG, type_ARG, zero_ARG)
+   test_ARG, type_ARG, virtualoriginsize_ARG, zero_ARG)
 
 xx(lvdisplay,
    "Display information about a logical volume",
--- LVM2/tools/lvchange.c	2009/04/22 12:46:25	1.98
+++ LVM2/tools/lvchange.c	2009/04/25 01:18:00	1.99
@@ -559,7 +559,8 @@
 		return ECMD_FAILED;
 	}
 
-	if (lv_is_cow(lv)) {
+	if (lv_is_cow(lv) && !lv_is_virtual_origin(origin_from_cow(lv)) &&
+	    arg_count(cmd, available_ARG)) {
 		log_error("Can't change snapshot logical volume \"%s\"",
 			  lv->name);
 		return ECMD_FAILED;
--- LVM2/tools/lvcreate.c	2009/04/21 14:31:58	1.182
+++ LVM2/tools/lvcreate.c	2009/04/25 01:18:00	1.183
@@ -43,6 +43,8 @@
 	/* size */
 	uint32_t extents;
 	uint64_t size;
+	uint32_t voriginextents;
+	uint64_t voriginsize;
 	percent_t percent;
 
 	uint32_t permission;
@@ -64,7 +66,7 @@
 	if (arg_count(cmd, name_ARG))
 		lp->lv_name = arg_value(cmd, name_ARG);
 
-	if (lp->snapshot) {
+	if (lp->snapshot && !arg_count(cmd, virtualoriginsize_ARG)) {
 		if (!argc) {
 			log_err("Please specify a logical volume to act as "
 				"the snapshot origin.");
@@ -175,6 +177,20 @@
 		lp->percent = PERCENT_NONE;
 	}
 
+	/* Size returned in kilobyte units; held in sectors */
+	if (arg_count(cmd, virtualoriginsize_ARG)) {
+		if (arg_sign_value(cmd, virtualoriginsize_ARG, 0) == SIGN_MINUS) {
+			log_error("Negative virtual origin size is invalid");
+			return 0;
+		}
+		lp->voriginsize = arg_uint64_value(cmd, virtualoriginsize_ARG,
+						   UINT64_C(0));
+		if (!lp->voriginsize) {
+			log_error("Virtual origin size may not be zero");
+			return 0;
+		}
+	}
+
 	return 1;
 }
 
@@ -390,6 +406,10 @@
 			log_error("-c is only available with snapshots");
 			return 0;
 		}
+		if (arg_count(cmd, virtualoriginsize_ARG)) {
+			log_error("--virtualoriginsize is only available with snapshots");
+			return 0;
+		}
 	}
 
 	if (lp->mirrors > 1) {
@@ -511,12 +531,73 @@
 	return 1;
 }
 
+static uint64_t _extents_from_size(struct cmd_context *cmd, uint64_t size,
+				   uint32_t extent_size)
+{
+	if (size % extent_size) {
+		size += extent_size - size % extent_size;
+		log_print("Rounding up size to full physical extent %s",
+			  display_size(cmd, size));
+	}
+
+	if (size > (uint64_t) UINT32_MAX * extent_size) {
+		log_error("Volume too large (%s) for extent size %s. "
+			  "Upper limit is %s.",
+			  display_size(cmd, size),
+			  display_size(cmd, (uint64_t) extent_size),
+			  display_size(cmd, (uint64_t) UINT32_MAX *
+				       extent_size));
+		return 0;
+	}
+
+	return (uint64_t) size / extent_size;
+}
+
+static struct logical_volume *_create_virtual_origin(struct cmd_context *cmd,
+						     struct volume_group *vg,
+						     const char *lv_name,
+						     uint32_t permission,
+						     uint64_t voriginextents)
+{
+	const struct segment_type *segtype;
+	size_t len;
+	char *vorigin_name;
+	struct logical_volume *lv;
+	
+	if (!(segtype = get_segtype_from_string(cmd, "zero"))) {
+		log_error("Zero segment type for virtual origin not found");
+		return 0;
+	}
+
+	len = strlen(lv_name) + 32;
+	if (!(vorigin_name = alloca(len)) ||
+	    dm_snprintf(vorigin_name, len, "%s_vorigin", lv_name) < 0) {
+		log_error("Virtual origin name allocation failed.");
+		return 0;
+	}
+
+	if (!(lv = lv_create_empty(vorigin_name, NULL, permission,
+				   ALLOC_INHERIT, 0, vg)))
+		return_0;
+
+	if (!lv_extend(lv, segtype, 1, 0, 1, voriginextents, NULL, 0u, 0u,
+		       NULL, ALLOC_INHERIT))
+		return_0;
+
+	/* store vg on disk(s) */
+	if (!vg_write(vg) || !vg_commit(vg))
+		return_0;
+
+	backup(vg);
+
+	return lv;
+}
+
 static int _lvcreate(struct cmd_context *cmd, struct volume_group *vg,
 		     struct lvcreate_params *lp)
 {
 	uint32_t size_rest;
 	uint32_t status = 0;
-	uint64_t tmp_size;
 	struct logical_volume *lv, *org = NULL;
 	struct dm_list *pvh;
 	const char *tag = NULL;
@@ -562,28 +643,14 @@
 		return 0;
 	}
 
-	if (lp->size) {
-		/* No of 512-byte sectors */
-		tmp_size = lp->size;
-
-		if (tmp_size % vg->extent_size) {
-			tmp_size += vg->extent_size - tmp_size %
-			    vg->extent_size;
-			log_print("Rounding up size to full physical extent %s",
-				  display_size(cmd, tmp_size));
-		}
-
-		if (tmp_size > (uint64_t) UINT32_MAX * vg->extent_size) {
-			log_error("Volume too large (%s) for extent size %s. "
-				  "Upper limit is %s.",
-				  display_size(cmd, tmp_size),
-				  display_size(cmd, (uint64_t) vg->extent_size),
-				  display_size(cmd, (uint64_t) UINT32_MAX *
-						   vg->extent_size));
-			return 0;
-		}
-		lp->extents = (uint64_t) tmp_size / vg->extent_size;
-	}
+	if (lp->size &&
+	    !(lp->extents = _extents_from_size(cmd, lp->size, vg->extent_size)))
+		return_0;
+
+	if (lp->voriginsize &&
+	    !(lp->voriginextents = _extents_from_size(cmd, lp->voriginsize,
+						      vg->extent_size)))
+		return_0;
 
 	/*
 	 * Create the pv list.
@@ -645,37 +712,49 @@
 			log_error("Clustered snapshots are not yet supported.");
 			return 0;
 		}
-		if (!(org = find_lv(vg, lp->origin))) {
-			log_err("Couldn't find origin volume '%s'.",
-				lp->origin);
-			return 0;
-		}
-		if (lv_is_cow(org)) {
-			log_error("Snapshots of snapshots are not supported "
-				  "yet.");
-			return 0;
-		}
-		if (org->status & LOCKED) {
-			log_error("Snapshots of locked devices are not "
-				  "supported yet");
-			return 0;
-		}
-		if (org->status & MIRROR_IMAGE ||
-		    org->status & MIRROR_LOG ||
-		    org->status & MIRRORED) {
-			log_error("Snapshots and mirrors may not yet be mixed.");
-			return 0;
-		}
 
 		/* Must zero cow */
 		status |= LVM_WRITE;
 
-		if (!lv_info(cmd, org, &info, 0, 0)) {
-			log_error("Check for existence of snapshot origin "
-				  "'%s' failed.", org->name);
-			return 0;
+		if (arg_count(cmd, virtualoriginsize_ARG))
+			origin_active = 1;
+		else {
+
+			if (!(org = find_lv(vg, lp->origin))) {
+				log_error("Couldn't find origin volume '%s'.",
+					  lp->origin);
+				return 0;
+			}
+			if (lv_is_virtual_origin(lv)) {
+				log_error("Can't share virtual origins. "
+					  "Use --virtualoriginsize.");
+				return 0;
+			}
+			if (lv_is_cow(org)) {
+				log_error("Snapshots of snapshots are not "
+					  "supported yet.");
+				return 0;
+			}
+			if (org->status & LOCKED) {
+				log_error("Snapshots of locked devices are not "
+					  "supported yet");
+				return 0;
+			}
+			if (org->status & MIRROR_IMAGE ||
+			    org->status & MIRROR_LOG ||
+			    org->status & MIRRORED) {
+				log_error("Snapshots and mirrors may not yet "
+					  "be mixed.");
+				return 0;
+			}
+	
+			if (!lv_info(cmd, org, &info, 0, 0)) {
+				log_error("Check for existence of snapshot "
+					  "origin '%s' failed.", org->name);
+				return 0;
+			}
+			origin_active = info.exists;
 		}
-		origin_active = info.exists;
 	}
 
 	if (!lp->extents) {
@@ -828,6 +907,15 @@
 			return 0;
 		}
 
+		if (lp->voriginsize &&
+		    !(org = _create_virtual_origin(cmd, vg, lv->name,
+						   lp->permission,
+						   lp->voriginextents))) {
+			log_error("Couldn't create virtual origin for LV %s",
+				  lv->name);
+			goto deactivate_and_revert_new_lv;
+		}
+
 		/* cow LV remains active and becomes snapshot LV */
 
 		if (!vg_add_snapshot(NULL, org, lv, NULL,
--- LVM2/tools/lvremove.c	2008/11/17 18:20:14	1.56
+++ LVM2/tools/lvremove.c	2009/04/25 01:18:00	1.57
@@ -18,6 +18,14 @@
 static int lvremove_single(struct cmd_context *cmd, struct logical_volume *lv,
 			   void *handle __attribute((unused)))
 {
+	struct logical_volume *origin;
+
+	/*
+	 * If this is a sparse device, remove its origin too.
+	 */
+        if (lv_is_cow(lv) && lv_is_virtual_origin(origin = origin_from_cow(lv)))
+                lv = origin;
+
 	if (!lv_remove_with_dependencies(cmd, lv, arg_count(cmd, force_ARG)))
 		return ECMD_FAILED;
 
--- LVM2/tools/toollib.c	2009/04/23 16:45:30	1.151
+++ LVM2/tools/toollib.c	2009/04/25 01:18:00	1.152
@@ -1229,6 +1229,12 @@
 		return 0;
 	}
 
+	if (strstr(name, "_vorigin")) {
+		log_error("Names including \"_vorigin\" are reserved. "
+			  "Please choose a different LV name.");
+		return 0;
+	}
+
 	return 1;
 }
 


