From: agk@sourceware.org <agk@sourceware.org>
Date: 9 Nov 2007 16:51:57 -0000
Subject: LVM2 ./WHATS_NEW doc/example.conf lib/commands ...
Message-ID: <20071109165157.2555.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-11-09 16:51:54

Modified files:
	.              : WHATS_NEW 
	doc            : example.conf 
	lib/commands   : toolcontext.c toolcontext.h 
	lib/config     : defaults.h 
	lib/format1    : format1.c import-export.c 
	lib/format_pool: import_export.c 
	lib/format_text: export.c import_vsn1.c 
	lib/metadata   : lv_manip.c metadata-exported.h 
	lib/report     : columns.h report.c 
	man            : lvchange.8 lvcreate.8 lvm.conf.5 
	tools          : args.h commands.h lvchange.c lvcreate.c 
	                 lvmcmdline.c tools.h 

Log message:
	Enhance the management of readahead settings.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.730&r2=1.731
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/example.conf.diff?cvsroot=lvm2&r1=1.31&r2=1.32
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.54&r2=1.55
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.h.diff?cvsroot=lvm2&r1=1.20&r2=1.21
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/defaults.h.diff?cvsroot=lvm2&r1=1.33&r2=1.34
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/format1.c.diff?cvsroot=lvm2&r1=1.102&r2=1.103
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/import-export.c.diff?cvsroot=lvm2&r1=1.90&r2=1.91
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/import_export.c.diff?cvsroot=lvm2&r1=1.17&r2=1.18
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/export.c.diff?cvsroot=lvm2&r1=1.58&r2=1.59
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import_vsn1.c.diff?cvsroot=lvm2&r1=1.44&r2=1.45
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.132&r2=1.133
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.22&r2=1.23
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/columns.h.diff?cvsroot=lvm2&r1=1.24&r2=1.25
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.64&r2=1.65
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvchange.8.diff?cvsroot=lvm2&r1=1.13&r2=1.14
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvcreate.8.diff?cvsroot=lvm2&r1=1.19&r2=1.20
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvm.conf.5.diff?cvsroot=lvm2&r1=1.19&r2=1.20
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/args.h.diff?cvsroot=lvm2&r1=1.55&r2=1.56
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/commands.h.diff?cvsroot=lvm2&r1=1.103&r2=1.104
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvchange.c.diff?cvsroot=lvm2&r1=1.81&r2=1.82
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.153&r2=1.154
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.53&r2=1.54
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/tools.h.diff?cvsroot=lvm2&r1=1.58&r2=1.59

--- LVM2/WHATS_NEW	2007/11/07 16:33:11	1.730
+++ LVM2/WHATS_NEW	2007/11/09 16:51:53	1.731
@@ -1,5 +1,8 @@
 Version 2.02.29 -
 ==================================
+  Add activation/readahead configuration option and FMT_RESTRICTED_READAHEAD.
+  Extend readahead arg to accept "auto" and "none".
+  Add lv_read_ahead and lv_kernel_read_ahead fields to reports.
   Prevent lvconvert -s from using same LV as origin and snapshot.
   Fix human-readable output of odd numbers of sectors.
   Add pv_mda_free and vg_mda_free fields to reports for raw text format.
--- LVM2/doc/example.conf	2007/04/26 16:44:57	1.31
+++ LVM2/doc/example.conf	2007/11/09 16:51:53	1.32
@@ -291,6 +291,12 @@
     # Size (in KB) of each copy operation when mirroring
     mirror_region_size = 512
 
+    # Setting to use when there is no readahead value stored in the metadata.
+    #
+    # "none" - Disable readahead.
+    # "auto" - Use default value chosen by kernel.
+    readahead = "auto"
+
     # 'mirror_image_fault_policy' and 'mirror_log_fault_policy' define
     # how a device failure affecting a mirror is handled.
     # A mirror is composed of mirror images (copies) and a log.
--- LVM2/lib/commands/toolcontext.c	2007/08/20 20:55:24	1.54
+++ LVM2/lib/commands/toolcontext.c	2007/11/09 16:51:53	1.55
@@ -153,6 +153,7 @@
 static int _process_config(struct cmd_context *cmd)
 {
 	mode_t old_umask;
+	const char *read_ahead;
 
 	/* umask */
 	cmd->default_settings.umask = find_config_tree_int(cmd,
@@ -207,6 +208,16 @@
 		return 0;
 	}
 
+	read_ahead = find_config_tree_str(cmd, "activation/readahead", DEFAULT_READ_AHEAD);
+	if (!strcasecmp(read_ahead, "auto"))
+		cmd->default_settings.read_ahead = DM_READ_AHEAD_AUTO;
+	else if (!strcasecmp(read_ahead, "none"))
+		cmd->default_settings.read_ahead = DM_READ_AHEAD_NONE;
+	else {
+		log_error("Invalid readahead specification");
+		return 0;
+	}
+
 	return 1;
 }
 
--- LVM2/lib/commands/toolcontext.h	2007/08/20 20:55:24	1.20
+++ LVM2/lib/commands/toolcontext.h	2007/11/09 16:51:53	1.21
@@ -33,6 +33,7 @@
 	int suffix;
 	int archive;		/* should we archive ? */
 	int backup;		/* should we backup ? */
+	int read_ahead;		/* DM_READ_AHEAD_NONE or _AUTO */
 	const char *msg_prefix;
 	struct format_type *fmt;
 	uint64_t unit_factor;
--- LVM2/lib/config/defaults.h	2007/08/21 19:46:35	1.33
+++ LVM2/lib/config/defaults.h	2007/11/09 16:51:53	1.34
@@ -63,6 +63,7 @@
 #define DEFAULT_PVMETADATASIZE 255
 #define DEFAULT_PVMETADATACOPIES 1
 #define DEFAULT_LABELSECTOR UINT64_C(1)
+#define DEFAULT_READ_AHEAD "auto"
 
 #define DEFAULT_MSG_PREFIX "  "
 #define DEFAULT_CMD_NAME 0
--- LVM2/lib/format1/format1.c	2007/08/22 14:38:16	1.102
+++ LVM2/lib/format1/format1.c	2007/11/09 16:51:53	1.103
@@ -556,7 +556,8 @@
 	fmt->ops = &_format1_ops;
 	fmt->name = FMT_LVM1_NAME;
 	fmt->alias = NULL;
-	fmt->features = FMT_RESTRICTED_LVIDS | FMT_ORPHAN_ALLOCATABLE;
+	fmt->features = FMT_RESTRICTED_LVIDS | FMT_ORPHAN_ALLOCATABLE |
+			FMT_RESTRICTED_READAHEAD;
 	fmt->private = NULL;
 
 	if (!(fmt->labeller = lvm1_labeller_create(fmt))) {
--- LVM2/lib/format1/import-export.c	2007/11/05 01:47:48	1.90
+++ LVM2/lib/format1/import-export.c	2007/11/09 16:51:53	1.91
@@ -349,7 +349,11 @@
 	else
 		lv->alloc = ALLOC_NORMAL;
 
-	lv->read_ahead = lvd->lv_read_ahead;
+	if (!lvd->lv_read_ahead)
+		lv->read_ahead = lv->vg->cmd->default_settings.read_ahead;
+	else
+		lv->read_ahead = lvd->lv_read_ahead;
+
 	lv->size = lvd->lv_size;
 	lv->le_count = lvd->lv_allocated_le;
 
@@ -386,7 +390,12 @@
 		lvd->lv_dev = MKDEV(LVM_BLK_MAJOR, lvnum_from_lvid(&lv->lvid));
 	}
 
-	lvd->lv_read_ahead = lv->read_ahead;
+	if (lv->read_ahead == DM_READ_AHEAD_AUTO ||
+	    lv->read_ahead == DM_READ_AHEAD_NONE)
+		lvd->lv_read_ahead = 0;
+	else
+		lvd->lv_read_ahead = lv->read_ahead;
+
 	lvd->lv_stripes =
 	    list_item(lv->segments.n, struct lv_segment)->area_count;
 	lvd->lv_stripesize =
--- LVM2/lib/format_pool/import_export.c	2007/08/20 20:55:25	1.17
+++ LVM2/lib/format_pool/import_export.c	2007/11/09 16:51:53	1.18
@@ -24,6 +24,7 @@
 #include "str_list.h"
 #include "display.h"
 #include "segtype.h"
+#include "toolcontext.h"
 
 /* This file contains only imports at the moment... */
 
@@ -77,7 +78,7 @@
 	lv->size = 0;
 	lv->name = NULL;
 	lv->le_count = 0;
-	lv->read_ahead = 0;
+	lv->read_ahead = vg->cmd->default_settings.read_ahead;
 	lv->snapshot = NULL;
 	list_init(&lv->snapshot_segs);
 	list_init(&lv->segments);
--- LVM2/lib/format_text/export.c	2007/11/04 19:16:34	1.58
+++ LVM2/lib/format_text/export.c	2007/11/09 16:51:53	1.59
@@ -272,6 +272,19 @@
 }
 
 /*
+ * Appends a comment
+ */
+static int _out_comment(struct formatter *f, const char *comment, const char *fmt, ...)
+{
+	va_list ap;
+	int r;
+
+	_out_with_comment(f, comment, fmt, ap);
+
+	return r;
+}
+
+/*
  * The normal output function.
  */
 int out_text(struct formatter *f, const char *fmt, ...)
@@ -546,8 +559,17 @@
 		outf(f, "allocation_policy = \"%s\"",
 		     get_alloc_string(lv->alloc));
 
-	if (lv->read_ahead)
+	switch (lv->read_ahead) {
+	case DM_READ_AHEAD_NONE:
+		_out_comment(f, "# None", "read_ahead = -1");
+		break;
+	case DM_READ_AHEAD_AUTO:
+		/* No output - use default */
+		break;
+	default:
 		outf(f, "read_ahead = %u", lv->read_ahead);
+	}
+
 	if (lv->major >= 0)
 		outf(f, "major = %d", lv->major);
 	if (lv->minor >= 0)
--- LVM2/lib/format_text/import_vsn1.c	2007/11/05 01:47:49	1.44
+++ LVM2/lib/format_text/import_vsn1.c	2007/11/09 16:51:53	1.45
@@ -523,9 +523,21 @@
 		}
 	}
 
-	/* read_ahead defaults to 0 */
 	if (!_read_int32(lvn, "read_ahead", &lv->read_ahead))
-		lv->read_ahead = 0;
+		/* If not present, choice of auto or none is configurable */
+		lv->read_ahead = vg->cmd->default_settings.read_ahead;
+	else {
+		switch (lv->read_ahead) {
+		case 0:
+			lv->read_ahead = DM_READ_AHEAD_AUTO;
+			break;
+		case -1:
+			lv->read_ahead = DM_READ_AHEAD_NONE;
+			break;
+		default:
+			;
+		}
+	}
 
 	lv->snapshot = NULL;
 	list_init(&lv->snapshot_segs);
--- LVM2/lib/metadata/lv_manip.c	2007/11/04 16:28:57	1.132
+++ LVM2/lib/metadata/lv_manip.c	2007/11/09 16:51:54	1.133
@@ -1705,7 +1705,7 @@
 
 	lv->status = status;
 	lv->alloc = alloc;
-	lv->read_ahead = 0;
+	lv->read_ahead = vg->cmd->default_settings.read_ahead;
 	lv->major = -1;
 	lv->minor = -1;
 	lv->size = UINT64_C(0);
--- LVM2/lib/metadata/metadata-exported.h	2007/11/02 20:40:04	1.22
+++ LVM2/lib/metadata/metadata-exported.h	2007/11/09 16:51:54	1.23
@@ -82,6 +82,7 @@
 //#define FMT_PRECOMMIT		0x00000040U	/* Supports pre-commit? */
 #define FMT_RESIZE_PV		0x00000080U	/* Supports pvresize? */
 #define FMT_UNLIMITED_STRIPESIZE 0x00000100U	/* Unlimited stripe size? */
+#define FMT_RESTRICTED_READAHEAD 0x00000200U	/* Readahead restricted to 2-120? */
 
 /* LVM2 external library flags */
 #define CORRECT_INCONSISTENT    0x00000001U /* Correct inconsistent metadata */
--- LVM2/lib/report/columns.h	2007/11/05 17:17:55	1.24
+++ LVM2/lib/report/columns.h	2007/11/09 16:51:54	1.25
@@ -23,8 +23,10 @@
 FIELD(LVS, lv, STR, "Attr", lvid, 4, lvstatus, "lv_attr", "Various attributes - see man page.")
 FIELD(LVS, lv, NUM, "Maj", major, 3, int32, "lv_major", "Persistent major number or -1 if not persistent.")
 FIELD(LVS, lv, NUM, "Min", minor, 3, int32, "lv_minor", "Persistent minor number or -1 if not persistent.")
+FIELD(LVS, lv, NUM, "Rahead", lvid, 6, lvreadahead, "lv_read_ahead", "Read ahead setting in current units.")
 FIELD(LVS, lv, STR, "KMaj", lvid, 4, lvkmaj, "lv_kernel_major", "Currently assigned major number or -1 if LV is not active.")
 FIELD(LVS, lv, STR, "KMin", lvid, 4, lvkmin, "lv_kernel_minor", "Currently assigned minor number or -1 if LV is not active.")
+FIELD(LVS, lv, NUM, "KRahead", lvid, 7, lvkreadahead, "lv_kernel_read_ahead", "Currently-in-use read ahead setting in current units.")
 FIELD(LVS, lv, NUM, "LSize", size, 5, size64, "lv_size", "Size of LV in current units.")
 FIELD(LVS, lv, NUM, "#Seg", lvid, 4, lvsegcount, "seg_count", "Number of segments in LV.")
 FIELD(LVS, lv, STR, "Origin", lvid, 6, origin, "origin", "For snapshots, the origin device of this LV")
--- LVM2/lib/report/report.c	2007/11/05 17:17:55	1.64
+++ LVM2/lib/report/report.c	2007/11/09 16:51:54	1.65
@@ -59,6 +59,8 @@
 	}
 }
 
+static const uint64_t _minusone = UINT64_C(-1);
+
 /*
  * Data-munging functions to prepare each data type for display and sorting
  */
@@ -224,12 +226,11 @@
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 	struct lvinfo info;
-	uint64_t minusone = UINT64_C(-1);
 
 	if (lv_info(lv->vg->cmd, lv, &info, 0) && info.exists)
 		return dm_report_field_int(rh, field, &info.major);
 
-	return dm_report_field_uint64(rh, field, &minusone);
+	return dm_report_field_uint64(rh, field, &_minusone);
 }
 
 static int _lvkmin_disp(struct dm_report *rh, struct dm_pool *mem __attribute((unused)),
@@ -238,12 +239,11 @@
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 	struct lvinfo info;
-	uint64_t minusone = UINT64_C(-1);
 
 	if (lv_info(lv->vg->cmd, lv, &info, 0) && info.exists)
 		return dm_report_field_int(rh, field, &info.minor);
 
-	return dm_report_field_uint64(rh, field, &minusone);
+	return dm_report_field_uint64(rh, field, &_minusone);
 }
 
 static int _lvstatus_disp(struct dm_report *rh __attribute((unused)), struct dm_pool *mem,
@@ -561,6 +561,32 @@
 	return 1;
 }
 
+static int _lvreadahead_disp(struct dm_report *rh, struct dm_pool *mem,
+			     struct dm_report_field *field,
+			     const void *data, void *private __attribute((unused)))
+{
+	const struct logical_volume *lv = (const struct logical_volume *) data;
+	uint64_t size;
+
+	if (lv->read_ahead == DM_READ_AHEAD_AUTO) {
+		dm_report_field_set_value(field, "auto", &_minusone);
+		return 1;
+	}
+
+	size = (uint64_t) lv->read_ahead;
+
+	return _size64_disp(rh, mem, field, &size, private);
+}
+
+static int _lvkreadahead_disp(struct dm_report *rh, struct dm_pool *mem,
+			      struct dm_report_field *field,
+			      const void *data,
+			      void *private __attribute((unused)))
+{
+	// FIXME after dm support is added
+	return dm_report_field_uint64(rh, field, &_minusone);
+}
+
 static int _vgsize_disp(struct dm_report *rh, struct dm_pool *mem,
 			struct dm_report_field *field,
 			const void *data, void *private)
--- LVM2/man/lvchange.8	2007/06/18 14:14:33	1.13
+++ LVM2/man/lvchange.8	2007/11/09 16:51:54	1.14
@@ -14,7 +14,7 @@
 [\-\-monitor {y|n}]
 [\-M/\-\-persistent y/n] [\-\-minor minor]
 [\-P/\-\-partial]
-[\-p/\-\-permission r/w] [\-r/\-\-readahead ReadAheadSectors]
+[\-p/\-\-permission r/w] [\-r/\-\-readahead ReadAheadSectors|auto|none]
 [\-\-refresh]
 [\-t/\-\-test]
 [\-v/\-\-verbose] LogicalVolumePath [LogicalVolumePath...]
@@ -72,9 +72,14 @@
 .I \-p, \-\-permission r/w
 Change access permission to read-only or read/write.
 .TP
-.I \-r, \-\-readahead ReadAheadSectors
-Change read ahead sector count per logical between 2 and 120.
-For compatability with LVM1 only. Ignored by LVM2.
+.I \-r, \-\-readahead ReadAheadSectors|auto|none
+Set read ahead sector count of this logical volume.
+For volume groups with metadata in lvm1 format, this must
+be a value between 2 and 120.
+The default value is "auto" which allows the kernel to choose
+a suitable value automatically.
+"None" is equivalent to specifying zero.
+N.B. This setting is currently disregarded and "auto" is always used.
 .TP
 .I \-\-refresh
 If the logical volume is active, reload its metadata.
--- LVM2/man/lvcreate.8	2007/09/20 21:39:08	1.19
+++ LVM2/man/lvcreate.8	2007/11/09 16:51:54	1.20
@@ -14,7 +14,7 @@
 [\-m/\-\-mirrors Mirrors [\-\-nosync] [\-\-mirrorlog {disk|log}] [\-\-corelog]
 [\-R/\-\-regionsize MirrorLogRegionSize]]
 [\-n/\-\-name LogicalVolumeName]
-[\-p/\-\-permission r/rw] [\-r/\-\-readahead ReadAheadSectors]
+[\-p/\-\-permission r/rw] [\-r/\-\-readahead ReadAheadSectors|auto|none]
 [\-t/\-\-test]
 [\-v/\-\-verbose] [\-Z/\-\-zero y/n]
 VolumeGroupName [PhysicalVolumePath...]
@@ -118,9 +118,14 @@
 .br
 Default is read and write.
 .TP
-.I \-r, \-\-readahead ReadAheadSectors
-Set read ahead sector count of this logical volume to a value between 2 and 120.
-Ignored by device-mapper.
+.I \-r, \-\-readahead ReadAheadSectors|auto|none
+Set read ahead sector count of this logical volume.
+For volume groups with metadata in lvm1 format, this must
+be a value between 2 and 120.
+The default value is "auto" which allows the kernel to choose
+a suitable value automatically.
+"None" is equivalent to specifying zero.
+N.B. This setting is currently disregarded and "auto" is always used.
 .TP
 .I \-R, \-\-regionsize MirrorLogRegionSize
 A mirror is divided into regions of this size (in MB), and the mirror log 
--- LVM2/man/lvm.conf.5	2007/04/26 17:14:57	1.19
+++ LVM2/man/lvm.conf.5	2007/11/09 16:51:54	1.20
@@ -306,6 +306,11 @@
 \fBmirror_region_size\fP \(em Unit size in KB for copy operations
 when mirroring.
 .IP
+\fBreadahead\fP \(em Used when there is no readahead value stored 
+in the volume group metadata.  Set to \fBnone\fP to disable
+readahead in these circumstances or \fBauto\fP to use the default
+value chosen by the kernel.
+.IP
 \fBreserved_memory\fP, \fBreserved_stack\fP \(em How many KB to reserve 
 for LVM2 to use while logical volumes are suspended.  If insufficient 
 memory is reserved before suspension, there is a risk of machine deadlock.
--- LVM2/tools/args.h	2007/08/21 19:56:18	1.55
+++ LVM2/tools/args.h	2007/11/09 16:51:54	1.56
@@ -107,7 +107,7 @@
 arg(maxphysicalvolumes_ARG, 'p', "maxphysicalvolumes", int_arg, 0)
 arg(partial_ARG, 'P', "partial", NULL, 0)
 arg(physicalvolume_ARG, 'P', "physicalvolume", NULL, 0)
-arg(readahead_ARG, 'r', "readahead", int_arg, 0)
+arg(readahead_ARG, 'r', "readahead", readahead_arg, 0)
 arg(resizefs_ARG, 'r', "resizefs", NULL, 0)
 arg(reset_ARG, 'R', "reset", NULL, 0)
 arg(regionsize_ARG, 'R', "regionsize", size_mb_arg, 0)
--- LVM2/tools/commands.h	2007/09/20 21:39:08	1.103
+++ LVM2/tools/commands.h	2007/11/09 16:51:54	1.104
@@ -71,7 +71,7 @@
    "\t[-M|--persistent y|n] [--major major] [--minor minor]\n"
    "\t[-P|--partial] " "\n"
    "\t[-p|--permission r|rw]\n"
-   "\t[-r|--readahead ReadAheadSectors]\n"
+   "\t[-r|--readahead ReadAheadSectors|auto|none]\n"
    "\t[--refresh]\n"
    "\t[--resync]\n"
    "\t[-t|--test]\n"
@@ -126,7 +126,7 @@
    "\t[-m|--mirrors Mirrors [--nosync] [{--mirrorlog {disk|core}|--corelog}]]\n"
    "\t[-n|--name LogicalVolumeName]\n"
    "\t[-p|--permission {r|rw}]\n"
-   "\t[-r|--readahead ReadAheadSectors]\n"
+   "\t[-r|--readahead ReadAheadSectors|auto|none]\n"
    "\t[-R|--regionsize MirrorLogRegionSize]\n"
    "\t[-t|--test]\n"
    "\t[--type VolumeType]\n"
@@ -149,7 +149,7 @@
    "\t[-M|--persistent {y|n}] [--major major] [--minor minor]\n"
    "\t[-n|--name LogicalVolumeName]\n"
    "\t[-p|--permission {r|rw}]\n"
-   "\t[-r|--readahead ReadAheadSectors]\n"
+   "\t[-r|--readahead ReadAheadSectors|auto|none]\n"
    "\t[-t|--test]\n"
    "\t[-v|--verbose]\n"
    "\t[--version]\n"
--- LVM2/tools/lvchange.c	2007/08/20 20:55:30	1.81
+++ LVM2/tools/lvchange.c	2007/11/09 16:51:54	1.82
@@ -375,12 +375,12 @@
 
 	read_ahead = arg_uint_value(cmd, readahead_ARG, 0);
 
-/******* FIXME Ranges?
-	if (read_ahead < LVM_MIN_READ_AHEAD || read_ahead > LVM_MAX_READ_AHEAD) {
-		log_error("read ahead sector argument is invalid");
+	if (read_ahead != DM_READ_AHEAD_AUTO &&
+	    (lv->vg->fid->fmt->features & FMT_RESTRICTED_READAHEAD) &&
+	    (read_ahead < 2 || read_ahead > 120)) {
+		log_error("Metadata only supports readahead values between 2 and 120.");
 		return 0;
 	}
-********/
 
 	if (lv->read_ahead == read_ahead) {
 		log_error("Read ahead is already %u for \"%s\"",
--- LVM2/tools/lvcreate.c	2007/11/02 20:40:04	1.153
+++ LVM2/tools/lvcreate.c	2007/11/09 16:51:54	1.154
@@ -548,6 +548,13 @@
 		return 0;
 	}
 
+	if (lp->read_ahead != DM_READ_AHEAD_AUTO &&
+	    (vg->fid->fmt->features & FMT_RESTRICTED_READAHEAD) &&
+	    (lp->read_ahead < 2 || lp->read_ahead > 120)) {
+		log_error("Metadata only supports readahead values between 2 and 120.");
+		return 0;
+	}
+
 	/*
 	 * Create the pv list.
 	 */
--- LVM2/tools/lvmcmdline.c	2007/10/03 16:10:04	1.53
+++ LVM2/tools/lvmcmdline.c	2007/11/09 16:51:54	1.54
@@ -372,6 +372,27 @@
 	return 1;
 }
 
+/*
+ * Positive integer, zero or "auto".
+ */
+int readahead_arg(struct cmd_context *cmd __attribute((unused)), struct arg *a)
+{
+	if (int_arg(cmd, a))
+		return 1;
+
+	if (!strcasecmp(a->value, "auto")) {
+		a->ui_value = DM_READ_AHEAD_AUTO;
+		return 1;
+	}
+
+	if (!strcasecmp(a->value, "none")) {
+		a->ui_value = DM_READ_AHEAD_NONE;
+		return 1;
+	}
+
+	return 0;
+}
+
 static void __alloc(int size)
 {
 	if (!(_cmdline.commands = dm_realloc(_cmdline.commands, sizeof(*_cmdline.commands) * size))) {
--- LVM2/tools/tools.h	2007/09/20 21:39:08	1.58
+++ LVM2/tools/tools.h	2007/11/09 16:51:54	1.59
@@ -147,7 +147,7 @@
 int units_arg(struct cmd_context *cmd, struct arg *a);
 int segtype_arg(struct cmd_context *cmd, struct arg *a);
 int alloc_arg(struct cmd_context *cmd, struct arg *a);
-
+int readahead_arg(struct cmd_context *cmd, struct arg *a);
 
 /* we use the enums to access the switches */
 unsigned int arg_count(const struct cmd_context *cmd, int a);


