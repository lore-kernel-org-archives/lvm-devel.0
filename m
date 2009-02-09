From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 9 Feb 2009 09:45:50 -0000
Subject: LVM2 ./WHATS_NEW lib/report/columns.h lib/repo ...
Message-ID: <20090209094550.27102.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-02-09 09:45:49

Modified files:
	.              : WHATS_NEW 
	lib/report     : columns.h report.c report.h 
	libdm          : libdm-report.c 
	tools          : pvdisplay.c pvresize.c reporter.c toollib.c 
	                 toollib.h vgreduce.c 

Log message:
	Separate PV label attributes which do not need parse metadata when reporting.
	
	When reporting explicitly label attributes (pv_uuid for example), we do not
	need to read metadata.
	
	This patch separate the label fileds and removes scan_vgs_for_pvs
	in process_each_pv() if not needed.
	
	(There should be no user visible change in output.)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1037&r2=1.1038
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/columns.h.diff?cvsroot=lvm2&r1=1.29&r2=1.30
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.95&r2=1.96
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.h.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-report.c.diff?cvsroot=lvm2&r1=1.29&r2=1.30
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvdisplay.c.diff?cvsroot=lvm2&r1=1.47&r2=1.48
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvresize.c.diff?cvsroot=lvm2&r1=1.24&r2=1.25
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/reporter.c.diff?cvsroot=lvm2&r1=1.44&r2=1.45
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.142&r2=1.143
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.h.diff?cvsroot=lvm2&r1=1.60&r2=1.61
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgreduce.c.diff?cvsroot=lvm2&r1=1.86&r2=1.87

--- LVM2/WHATS_NEW	2009/02/06 14:28:07	1.1037
+++ LVM2/WHATS_NEW	2009/02/09 09:45:49	1.1038
@@ -1,5 +1,6 @@
 Version 2.02.45 - 
 ===================================
+  Separate PV label attributes which do not need parse metadata when reporting.
   Remove external dependency on the 'cut' command in fsadm.
   Fix pvs segfault when pv mda attributes requested for not available PV.
   Add support for ext4 resize in fsadm.
--- LVM2/lib/report/columns.h	2009/01/09 22:44:34	1.29
+++ LVM2/lib/report/columns.h	2009/02/09 09:45:49	1.30
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -38,21 +38,22 @@
 FIELD(LVS, lv, STR, "Log", lvid, 3, loglv, "mirror_log", "For mirrors, the LV holding the synchronisation log.")
 FIELD(LVS, lv, STR, "Modules", lvid, 7, modules, "modules", "Kernel device-mapper modules required for this LV.")
 
-FIELD(PVS, pv, STR, "Fmt", id, 3, pvfmt, "pv_fmt", "Type of metadata.")
-FIELD(PVS, pv, STR, "PV UUID", id, 38, uuid, "pv_uuid", "Unique identifier.")
+FIELD(LABEL, pv, STR, "Fmt", id, 3, pvfmt, "pv_fmt", "Type of metadata.")
+FIELD(LABEL, pv, STR, "PV UUID", id, 38, uuid, "pv_uuid", "Unique identifier.")
+FIELD(LABEL, pv, NUM, "DevSize", dev, 7, devsize, "dev_size", "Size of underlying device in current units.")
+FIELD(LABEL, pv, NUM, "1st PE", pe_start, 7, size64, "pe_start", "Offset to the start of data on the underlying device.")
+FIELD(LABEL, pv, STR, "PV", dev, 10, dev_name, "pv_name", "Name.")
+FIELD(LABEL, pv, NUM, "PMdaFree", id, 9, pvmdafree, "pv_mda_free", "Free metadata area space on this device in current units.")
+FIELD(LABEL, pv, NUM, "PMdaSize", id, 9, pvmdasize, "pv_mda_size", "Size of smallest metadata area on this device in current units.")
+
 FIELD(PVS, pv, NUM, "PSize", id, 5, pvsize, "pv_size", "Size of PV in current units.")
-FIELD(PVS, pv, NUM, "DevSize", dev, 7, devsize, "dev_size", "Size of underlying device in current units.")
-FIELD(PVS, pv, NUM, "1st PE", pe_start, 7, size64, "pe_start", "Offset to the start of data on the underlying device.")
 FIELD(PVS, pv, NUM, "PFree", id, 5, pvfree, "pv_free", "Total amount of unallocated space in current units.")
 FIELD(PVS, pv, NUM, "Used", id, 4, pvused, "pv_used", "Total amount of allocated space in current units.")
-FIELD(PVS, pv, STR, "PV", dev, 10, dev_name, "pv_name", "Name.")
 FIELD(PVS, pv, STR, "Attr", status, 4, pvstatus, "pv_attr", "Various attributes - see man page.")
 FIELD(PVS, pv, NUM, "PE", pe_count, 3, uint32, "pv_pe_count", "Total number of Physical Extents.")
 FIELD(PVS, pv, NUM, "Alloc", pe_alloc_count, 5, uint32, "pv_pe_alloc_count", "Total number of allocated Physical Extents.")
 FIELD(PVS, pv, STR, "PV Tags", tags, 7, tags, "pv_tags", "Tags, if any.")
 FIELD(PVS, pv, NUM, "#PMda", id, 5, pvmdas, "pv_mda_count", "Number of metadata areas on this device.")
-FIELD(PVS, pv, NUM, "PMdaFree", id, 9, pvmdafree, "pv_mda_free", "Free metadata area space on this device in current units.")
-FIELD(PVS, pv, NUM, "PMdaSize", id, 9, pvmdasize, "pv_mda_size", "Size of smallest metadata area on this device in current units.")
 
 FIELD(VGS, vg, STR, "Fmt", cmd, 3, vgfmt, "vg_fmt", "Type of metadata.")
 FIELD(VGS, vg, STR, "VG UUID", id, 38, uuid, "vg_uuid", "Unique identifier.")
--- LVM2/lib/report/report.c	2009/02/06 12:41:51	1.95
+++ LVM2/lib/report/report.c	2009/02/09 09:45:49	1.96
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -1111,6 +1111,7 @@
 	{ VGS, "Volume Group", "vg_", _obj_get_vg },
 	{ LVS, "Logical Volume", "lv_", _obj_get_lv },
 	{ PVS, "Physical Volume", "pv_", _obj_get_pv },
+	{ LABEL, "Physical Volume Label", "pv_", _obj_get_pv },
 	{ SEGS, "Logical Volume Segment", "seg_", _obj_get_seg },
 	{ PVSEGS, "Physical Volume Segment", "pvseg_", _obj_get_pvseg },
 	{ 0, "", "", NULL },
--- LVM2/lib/report/report.h	2008/06/24 22:48:53	1.8
+++ LVM2/lib/report/report.h	2009/02/09 09:45:49	1.9
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2005 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -18,7 +18,14 @@
 
 #include "metadata-exported.h"
 
-typedef enum { LVS = 1, PVS = 2, VGS = 4, SEGS = 8, PVSEGS = 16 } report_type_t;
+typedef enum {
+	LVS	= 1,
+	PVS	= 2,
+	VGS	= 4,
+	SEGS	= 8,
+	PVSEGS	= 16,
+	LABEL	= 32
+} report_type_t;
 
 struct field;
 struct report_handle;
--- LVM2/libdm/libdm-report.c	2009/01/19 20:53:35	1.29
+++ LVM2/libdm/libdm-report.c	2009/02/09 09:45:49	1.30
@@ -365,9 +365,22 @@
 {
 	size_t prefix_len;
 	const struct dm_report_object_type *t;
+	char prefixed_all[32];
 
-	if (!strncasecmp(field, "all", 3) && flen == 3)
-		return rh->report_types;
+	if (!strncasecmp(field, "all", 3) && flen == 3) {
+		if (strlen(rh->field_prefix)) {
+			strcpy(prefixed_all, rh->field_prefix);
+			strcat(prefixed_all, "all");
+			/*
+			 * Add also prefix to receive all attributes
+			 * (e.g.LABEL/PVS use the same prefix)
+			 */
+			return rh->report_types |
+			       _all_match(rh, prefixed_all,
+					  strlen(prefixed_all));
+		} else
+			return rh->report_types;
+	}
 
 	for (t = rh->types; t->data_fn; t++) {
 		prefix_len = strlen(t->prefix);
--- LVM2/tools/pvdisplay.c	2009/01/26 19:01:32	1.47
+++ LVM2/tools/pvdisplay.c	2009/02/09 09:45:49	1.48
@@ -110,6 +110,6 @@
 		return EINVALID_CMD_LINE;
 	}
 
-	return process_each_pv(cmd, argc, argv, NULL, LCK_VG_READ, NULL,
+	return process_each_pv(cmd, argc, argv, NULL, LCK_VG_READ, 0, NULL,
 			       _pvdisplay_single);
 }
--- LVM2/tools/pvresize.c	2009/01/26 19:01:32	1.24
+++ LVM2/tools/pvresize.c	2009/02/09 09:45:49	1.25
@@ -226,7 +226,7 @@
 	params.done = 0;
 	params.total = 0;
 
-	ret = process_each_pv(cmd, argc, argv, NULL, LCK_VG_WRITE, &params,
+	ret = process_each_pv(cmd, argc, argv, NULL, LCK_VG_WRITE, 0, &params,
 			      _pvresize_single);
 
 	log_print("%d physical volume(s) resized / %d physical volume(s) "
--- LVM2/tools/reporter.c	2009/01/26 19:01:32	1.44
+++ LVM2/tools/reporter.c	2009/02/09 09:45:49	1.45
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -158,6 +158,15 @@
 	return ret;
 }
 
+static int _label_single(struct cmd_context *cmd, struct volume_group *vg,
+		       struct physical_volume *pv, void *handle)
+{
+	if (!report_object(handle, vg, NULL, pv, NULL, NULL))
+		return ECMD_FAILED;
+
+	return ECMD_PROCESSED;
+}
+
 static int _pvs_in_vg(struct cmd_context *cmd, const char *vg_name,
 		      struct volume_group *vg,
 		      int consistent __attribute((unused)),
@@ -211,7 +220,9 @@
 	columns_as_rows = find_config_tree_int(cmd, "report/columns_as_rows",
 					       DEFAULT_REP_COLUMNS_AS_ROWS);
 
-	args_are_pvs = (report_type == PVS || report_type == PVSEGS) ? 1 : 0;
+	args_are_pvs = (report_type == PVS ||
+			report_type == LABEL ||
+			report_type == PVSEGS) ? 1 : 0;
 
 	switch (report_type) {
 	case LVS:
@@ -238,6 +249,7 @@
 						  "report/vgs_cols_verbose",
 						  DEFAULT_VGS_COLS_VERB);
 		break;
+	case LABEL:
 	case PVS:
 		keys = find_config_tree_str(cmd, "report/pvs_sort",
 				       DEFAULT_PVS_SORT);
@@ -333,7 +345,7 @@
 		report_type |= LVS;
 	if (report_type & PVSEGS)
 		report_type |= PVS;
-	if ((report_type & LVS) && (report_type & PVS) && !args_are_pvs) {
+	if ((report_type & LVS) && (report_type & (PVS | LABEL)) && !args_are_pvs) {
 		log_error("Can't report LV and PV fields at the same time");
 		dm_report_free(report_handle);
 		return ECMD_FAILED;
@@ -341,8 +353,10 @@
 
 	/* Change report type if fields specified makes this necessary */
 	if ((report_type & PVSEGS) ||
-	    ((report_type & PVS) && (report_type & LVS)))
+	    ((report_type & (PVS | LABEL)) && (report_type & LVS)))
 		report_type = PVSEGS;
+	else if ((report_type & LABEL) && (report_type & VGS))
+		report_type = PVS;
 	else if (report_type & PVS)
 		report_type = PVS;
 	else if (report_type & SEGS)
@@ -359,10 +373,14 @@
 		r = process_each_vg(cmd, argc, argv, LCK_VG_READ, 0,
 				    report_handle, &_vgs_single);
 		break;
+	case LABEL:
+		r = process_each_pv(cmd, argc, argv, NULL, LCK_NONE,
+				    1, report_handle, &_label_single);
+		break;
 	case PVS:
 		if (args_are_pvs)
 			r = process_each_pv(cmd, argc, argv, NULL, LCK_VG_READ,
-					    report_handle, &_pvs_single);
+					    0, report_handle, &_pvs_single);
 		else
 			r = process_each_vg(cmd, argc, argv, LCK_VG_READ, 0,
 					    report_handle, &_pvs_in_vg);
@@ -374,7 +392,7 @@
 	case PVSEGS:
 		if (args_are_pvs)
 			r = process_each_pv(cmd, argc, argv, NULL, LCK_VG_READ,
-					    report_handle, &_pvsegs_single);
+					    0, report_handle, &_pvsegs_single);
 		else
 			r = process_each_vg(cmd, argc, argv, LCK_VG_READ, 0,
 					    report_handle, &_pvsegs_in_vg);
@@ -411,7 +429,7 @@
 	if (arg_count(cmd, segments_ARG))
 		type = PVSEGS;
 	else
-		type = PVS;
+		type = LABEL;
 
 	return _report(cmd, argc, argv, type);
 }
--- LVM2/tools/toollib.c	2009/02/03 16:19:26	1.142
+++ LVM2/tools/toollib.c	2009/02/09 09:45:49	1.143
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2008 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -621,7 +621,8 @@
 }
 
 int process_each_pv(struct cmd_context *cmd, int argc, char **argv,
-		    struct volume_group *vg, uint32_t lock_type, void *handle,
+		    struct volume_group *vg, uint32_t lock_type,
+		    int scan_label_only, void *handle,
 		    int (*process_single) (struct cmd_context * cmd,
 					   struct volume_group * vg,
 					   struct physical_volume * pv,
@@ -690,7 +691,8 @@
 				 * PV on the system.
 				 */
 				if (!scanned && is_orphan(pv)) {
-					if (!scan_vgs_for_pvs(cmd)) {
+					if (!scan_label_only &&
+					    !scan_vgs_for_pvs(cmd)) {
 						stack;
 						ret_max = ECMD_FAILED;
 						continue;
--- LVM2/tools/toollib.h	2008/12/22 09:00:51	1.60
+++ LVM2/tools/toollib.h	2009/02/09 09:45:49	1.61
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved. 
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -34,11 +34,13 @@
 					   int consistent, void *handle));
 
 int process_each_pv(struct cmd_context *cmd, int argc, char **argv,
-		    struct volume_group *vg, uint32_t lock_type, void *handle,
+		    struct volume_group *vg, uint32_t lock_type,
+		    int scan_label_only, void *handle,
 		    int (*process_single) (struct cmd_context * cmd,
 					   struct volume_group * vg,
 					   struct physical_volume * pv,
 					   void *handle));
+
 int process_each_segment_in_pv(struct cmd_context *cmd,
 			       struct volume_group *vg,
 			       struct physical_volume *pv,
--- LVM2/tools/vgreduce.c	2009/01/26 19:01:32	1.86
+++ LVM2/tools/vgreduce.c	2009/02/09 09:45:49	1.87
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -584,7 +584,7 @@
 
 		/* FIXME: Pass private struct through to all these functions */
 		/* and update in batch here? */
-		ret = process_each_pv(cmd, argc, argv, vg, LCK_NONE, NULL,
+		ret = process_each_pv(cmd, argc, argv, vg, LCK_NONE, 0, NULL,
 				      _vgreduce_single);
 
 	}


