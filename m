From: agk@sourceware.org <agk@sourceware.org>
Date: 6 Nov 2009 00:43:15 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/.exported_symbols li ...
Message-ID: <20091106004315.19041.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-11-06 00:43:10

Modified files:
	.              : WHATS_NEW_DM 
	libdm          : .exported_symbols libdevmapper.h libdm-common.c 
	libdm/ioctl    : libdm-iface.c libdm-targets.h 
	libdm/misc     : dm-ioctl.h 
	man            : dmsetup.8.in 
	tools          : dmsetup.c 

Log message:
	Add support for querying a device's inactive table.
	Currently this data is invisible to userspace.
	Requires dm >= 4.16 (likely to be in linux 2.6.33).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.311&r2=1.312
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/.exported_symbols.diff?cvsroot=lvm2&r1=1.44&r2=1.45
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.100&r2=1.101
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.89&r2=1.90
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.64&r2=1.65
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-targets.h.diff?cvsroot=lvm2&r1=1.25&r2=1.26
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/misc/dm-ioctl.h.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/dmsetup.8.in.diff?cvsroot=lvm2&r1=1.27&r2=1.28
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/dmsetup.c.diff?cvsroot=lvm2&r1=1.126&r2=1.127

--- LVM2/WHATS_NEW_DM	2009/11/03 15:50:42	1.311
+++ LVM2/WHATS_NEW_DM	2009/11/06 00:43:08	1.312
@@ -1,5 +1,7 @@
 Version 1.02.40 - 
 ===================================
+  Add dmsetup --inactive support.
+  Add dm_task_query_inactive_table to libdevmapper for kernel driver >= 4.16.
   Fix hash lookup segfault when keys compared are different lengths.
 
 Version 1.02.39 - 26th October 2009
--- LVM2/libdm/.exported_symbols	2009/10/22 13:00:07	1.44
+++ LVM2/libdm/.exported_symbols	2009/11/06 00:43:08	1.45
@@ -40,6 +40,7 @@
 dm_task_no_flush
 dm_task_no_open_count
 dm_task_skip_lockfs
+dm_task_query_inactive_table
 dm_task_update_nodes
 dm_task_run
 dm_get_next_target
--- LVM2/libdm/libdevmapper.h	2009/10/26 14:29:33	1.100
+++ LVM2/libdm/libdevmapper.h	2009/11/06 00:43:08	1.101
@@ -172,6 +172,7 @@
 int dm_task_no_flush(struct dm_task *dmt);
 int dm_task_no_open_count(struct dm_task *dmt);
 int dm_task_skip_lockfs(struct dm_task *dmt);
+int dm_task_query_inactive_table(struct dm_task *dmt);
 int dm_task_suppress_identical_reload(struct dm_task *dmt);
 
 /*
--- LVM2/libdm/libdm-common.c	2009/10/26 21:38:35	1.89
+++ LVM2/libdm/libdm-common.c	2009/11/06 00:43:09	1.90
@@ -181,6 +181,7 @@
 	dmt->read_ahead_flags = 0;
 	dmt->event_nr = 0;
 	dmt->cookie_set = 0;
+	dmt->query_inactive_table = 0;
 
 	return dmt;
 }
--- LVM2/libdm/ioctl/libdm-iface.c	2009/10/26 14:29:34	1.64
+++ LVM2/libdm/ioctl/libdm-iface.c	2009/11/06 00:43:09	1.65
@@ -1135,6 +1135,13 @@
 	return 1;
 }
 
+int dm_task_query_inactive_table(struct dm_task *dmt)
+{
+	dmt->query_inactive_table = 1;
+
+	return 1;
+}
+
 int dm_task_set_event_nr(struct dm_task *dmt, uint32_t event_nr)
 {
 	dmt->event_nr = event_nr;
@@ -1382,6 +1389,12 @@
 		dmi->flags |= DM_READONLY_FLAG;
 	if (dmt->skip_lockfs)
 		dmi->flags |= DM_SKIP_LOCKFS_FLAG;
+	if (dmt->query_inactive_table) {
+		if (_dm_version_minor < 16)
+			log_warn("WARNING: Inactive table query unsupported "
+				 "by kernel.  It will use live table.");
+		dmi->flags |= DM_QUERY_INACTIVE_TABLE_FLAG;
+	}
 
 	dmi->target_count = count;
 	dmi->event_nr = dmt->event_nr;
@@ -1723,7 +1736,7 @@
 	}
 
 	log_debug("dm %s %s %s%s%s %s%.0d%s%.0d%s"
-		  "%s%c%c%s %.0" PRIu64 " %s [%u]",
+		  "%s%c%c%s%s %.0" PRIu64 " %s [%u]",
 		  _cmd_data_v4[dmt->type].name,
 		  dmi->name, dmi->uuid, dmt->newname ? " " : "",
 		  dmt->newname ? dmt->newname : "",
@@ -1736,6 +1749,7 @@
 		  dmt->no_open_count ? 'N' : 'O',
 		  dmt->no_flush ? 'N' : 'F',
 		  dmt->skip_lockfs ? "S " : "",
+		  dmt->query_inactive_table ? "I " : "",
 		  dmt->sector, dmt->message ? dmt->message : "",
 		  dmi->data_size);
 #ifdef DM_IOCTLS
--- LVM2/libdm/ioctl/libdm-targets.h	2009/08/03 18:01:48	1.25
+++ LVM2/libdm/ioctl/libdm-targets.h	2009/11/06 00:43:09	1.26
@@ -58,6 +58,7 @@
 	int no_flush;
 	int no_open_count;
 	int skip_lockfs;
+	int query_inactive_table;
 	int suppress_identical_reload;
 	uint64_t existing_table_size;
 	int cookie_set;
--- LVM2/libdm/misc/dm-ioctl.h	2009/08/03 18:44:54	1.2
+++ LVM2/libdm/misc/dm-ioctl.h	2009/11/06 00:43:09	1.3
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001 - 2003 Sistina Software (UK) Limited.
- * Copyright (C) 2004 - 2005 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004 - 2009 Red Hat, Inc. All rights reserved.
  *
  * This file is released under the LGPL.
  */
@@ -268,9 +268,9 @@
 #define DM_DEV_SET_GEOMETRY	_IOWR(DM_IOCTL, DM_DEV_SET_GEOMETRY_CMD, struct dm_ioctl)
 
 #define DM_VERSION_MAJOR	4
-#define DM_VERSION_MINOR	15
+#define DM_VERSION_MINOR	16
 #define DM_VERSION_PATCHLEVEL	0
-#define DM_VERSION_EXTRA	"-ioctl (2009-04-01)"
+#define DM_VERSION_EXTRA	"-ioctl (2009-11-05)"
 
 /* Status bits */
 #define DM_READONLY_FLAG	(1 << 0) /* In/Out */
@@ -311,4 +311,11 @@
  */
 #define DM_NOFLUSH_FLAG		(1 << 11) /* In */
 
+/*
+ * If set, any table information returned will relate to the inactive
+ * table instead of the live one.  Always check DM_INACTIVE_PRESENT_FLAG
+ * is set before using the data returned.
+ */
+#define DM_QUERY_INACTIVE_TABLE_FLAG	(1 << 12) /* In */
+
 #endif				/* _LINUX_DM_IOCTL_H */
--- LVM2/man/dmsetup.8.in	2009/10/22 13:12:20	1.27
+++ LVM2/man/dmsetup.8.in	2009/11/06 00:43:09	1.28
@@ -107,6 +107,11 @@
 .IP \fB-c|-C|--columns
 .br
 Display output in columns rather than as Field: Value lines.
+.IP \fB--inactive
+.br
+When returning any table information from the kernel report on the 
+inactive table instead of the live table.
+Requires kernel driver version 4.16.0 or above.
 .IP \fB-j|--major\ \fImajor
 .br
 Specify the major number.
@@ -277,7 +282,7 @@
 Splits given device name into subsystem constituents.
 Default subsystem is LVM.
 .IP \fBstatus
-.I [--target target_type]
+.I [--target target_type] [--inactive]
 .I [device_name]
 .br
 Outputs status information for each of the device's targets.
@@ -296,7 +301,7 @@
 the --noflush option.  This lets outstanding I/O that has not yet reached the
 device to remain unflushed.
 .IP \fBtable
-.I [--target target_type]
+.I [--target target_type] [--inactive]
 .I [device_name]
 .br
 Outputs the current table for the device in a format that can be fed
--- LVM2/tools/dmsetup.c	2009/10/26 14:29:34	1.126
+++ LVM2/tools/dmsetup.c	2009/11/06 00:43:10	1.127
@@ -117,6 +117,7 @@
 	EXEC_ARG,
 	FORCE_ARG,
 	GID_ARG,
+	INACTIVE_ARG,
 	MAJOR_ARG,
 	MINOR_ARG,
 	MODE_ARG,
@@ -296,6 +297,9 @@
 	if (_switches[NOOPENCOUNT_ARG] && !dm_task_no_open_count(dmt))
 		goto err;
 
+	if (_switches[INACTIVE_ARG] && !dm_task_query_inactive_table(dmt))
+		goto err;
+
 	if (!dm_task_run(dmt))
 		goto err;
 
@@ -530,6 +534,9 @@
 	if (_switches[NOOPENCOUNT_ARG] && !dm_task_no_open_count(dmt))
 		goto out;
 
+	if (_switches[INACTIVE_ARG] && !dm_task_query_inactive_table(dmt))
+		goto out;
+
 	if (!dm_task_run(dmt))
 		goto out;
 
@@ -587,6 +594,9 @@
 	if (_switches[NOOPENCOUNT_ARG] && !dm_task_no_open_count(dmt))
 		goto out;
 
+	if (_switches[INACTIVE_ARG] && !dm_task_query_inactive_table(dmt))
+		goto out;
+
 	if (_switches[READAHEAD_ARG] &&
 	    !dm_task_set_read_ahead(dmt, _int_args[READAHEAD_ARG],
 				    _read_ahead_flags))
@@ -630,6 +640,9 @@
 	if (_switches[NOOPENCOUNT_ARG] && !dm_task_no_open_count(dmt))
 		goto out;
 
+	if (_switches[INACTIVE_ARG] && !dm_task_query_inactive_table(dmt))
+		goto out;
+
 	if (!dm_task_set_cookie(dmt, &cookie, 0) ||
 	    !dm_task_run(dmt))
 		goto out;
@@ -696,6 +709,9 @@
 	if (_switches[NOOPENCOUNT_ARG] && !dm_task_no_open_count(dmt))
 		goto out;
 
+	if (_switches[INACTIVE_ARG] && !dm_task_query_inactive_table(dmt))
+		goto out;
+
 	if (!dm_task_run(dmt))
 		goto out;
 
@@ -728,6 +744,12 @@
 	if (!dm_task_set_geometry(dmt, argv[1], argv[2], argv[3], argv[4]))
 		goto out;
 
+	if (_switches[NOOPENCOUNT_ARG] && !dm_task_no_open_count(dmt))
+		goto out;
+
+	if (_switches[INACTIVE_ARG] && !dm_task_query_inactive_table(dmt))
+		goto out;
+
 	/* run the task */
 	if (!dm_task_run(dmt))
 		goto out;
@@ -1002,6 +1024,9 @@
 	if (_switches[NOOPENCOUNT_ARG] && !dm_task_no_open_count(dmt))
 		goto out;
 
+	if (_switches[INACTIVE_ARG] && !dm_task_query_inactive_table(dmt))
+		goto out;
+
 	if (_switches[NOLOCKFS_ARG] && !dm_task_skip_lockfs(dmt))
 		goto out;
 
@@ -1115,6 +1140,9 @@
 	if (_switches[NOOPENCOUNT_ARG] && !dm_task_no_open_count(dmt))
 		goto out;
 
+	if (_switches[INACTIVE_ARG] && !dm_task_query_inactive_table(dmt))
+		goto out;
+
 	if (!dm_task_run(dmt))
 		goto out;
 
@@ -1162,6 +1190,9 @@
 	if (_switches[NOOPENCOUNT_ARG] && !dm_task_no_open_count(dmt))
 		goto error;
 
+	if (_switches[INACTIVE_ARG] && !dm_task_query_inactive_table(dmt))
+		goto error;
+
 	if (!dm_task_run(dmt))
 		goto error;
 
@@ -1337,6 +1368,9 @@
 	if (_switches[NOOPENCOUNT_ARG] && !dm_task_no_open_count(dmt))
 		goto out;
 
+	if (_switches[INACTIVE_ARG] && !dm_task_query_inactive_table(dmt))
+		goto out;
+
 	if (!dm_task_run(dmt))
 		goto out;
 
@@ -1458,6 +1492,9 @@
 	if (_switches[NOOPENCOUNT_ARG] && !dm_task_no_open_count(dmt))
 		goto out;
 
+	if (_switches[INACTIVE_ARG] && !dm_task_query_inactive_table(dmt))
+		goto out;
+
 	if (!dm_task_run(dmt))
 		goto out;
 
@@ -1496,6 +1533,9 @@
 	if (_switches[NOOPENCOUNT_ARG] && !dm_task_no_open_count(dmt))
 		goto out;
 
+	if (_switches[INACTIVE_ARG] && !dm_task_query_inactive_table(dmt))
+		goto out;
+
 	if (!dm_task_run(dmt))
 		goto out;
 
@@ -2510,7 +2550,7 @@
 
 	fprintf(out, "Usage:\n\n");
 	fprintf(out, "dmsetup [--version] [-v|--verbose [-v|--verbose ...]]\n"
-		"        [-r|--readonly] [--noopencount] [--nolockfs]\n"
+		"        [-r|--readonly] [--noopencount] [--nolockfs] [--inactive]\n"
 		"        [--noudevsync] [-y|--yes] [--readahead [+]<sectors>|auto|none]\n"
 		"        [-c|-C|--columns] [-o <fields>] [-O|--sort <sort_fields>]\n"
 		"        [--nameprefixes] [--noheadings] [--separator <separator>]\n\n");
@@ -2866,6 +2906,7 @@
 		{"exec", 1, &ind, EXEC_ARG},
 		{"force", 0, &ind, FORCE_ARG},
 		{"gid", 1, &ind, GID_ARG},
+		{"inactive", 0, &ind, INACTIVE_ARG},
 		{"major", 1, &ind, MAJOR_ARG},
 		{"minor", 1, &ind, MINOR_ARG},
 		{"mode", 1, &ind, MODE_ARG},
@@ -3010,6 +3051,8 @@
 			_switches[TARGET_ARG]++;
 			_target = optarg;
 		}
+		if ((ind == INACTIVE_ARG))
+			_switches[INACTIVE_ARG]++;
 		if ((ind == NAMEPREFIXES_ARG))
 			_switches[NAMEPREFIXES_ARG]++;
 		if ((ind == NOFLUSH_ARG))


