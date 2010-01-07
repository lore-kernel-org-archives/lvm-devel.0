From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 7 Jan 2010 19:45:13 -0000
Subject: LVM2 ./WHATS_NEW_DM man/dmsetup.8.in tools/dms ...
Message-ID: <20100107194513.16308.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2010-01-07 19:45:12

Modified files:
	.              : WHATS_NEW_DM 
	man            : dmsetup.8.in 
	tools          : dmsetup.c 

Log message:
	Add --noudevrules option for dmsetup to disable /dev node management by udev.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.324&r2=1.325
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/dmsetup.8.in.diff?cvsroot=lvm2&r1=1.29&r2=1.30
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/dmsetup.c.diff?cvsroot=lvm2&r1=1.130&r2=1.131

--- LVM2/WHATS_NEW_DM	2010/01/07 14:30:47	1.324
+++ LVM2/WHATS_NEW_DM	2010/01/07 19:45:12	1.325
@@ -1,5 +1,6 @@
 Version 1.02.41 -
 ====================================
+  Add --noudevrules option for dmsetup to disable /dev node management by udev.
   Update code to show all fields for 'dmsetup info -c -o all'.
   Return error from dm_tree_deactivate_children().
   Return error from dm_tree_suspend_children().
--- LVM2/man/dmsetup.8.in	2009/11/06 01:40:59	1.29
+++ LVM2/man/dmsetup.8.in	2010/01/07 19:45:12	1.30
@@ -127,6 +127,9 @@
 .IP \fB--notable
 .br
 When creating a device, don't load any table.
+.IP \fB--noudevrules
+Do not allow udev to manage nodes for devices in device-mapper directory.
+.br
 .IP \fB--noudevsync
 Do not synchronise with udev when creating, renaming or removing devices.
 .br
--- LVM2/tools/dmsetup.c	2009/12/11 13:16:39	1.130
+++ LVM2/tools/dmsetup.c	2010/01/07 19:45:12	1.131
@@ -127,6 +127,7 @@
 	NOLOCKFS_ARG,
 	NOOPENCOUNT_ARG,
 	NOTABLE_ARG,
+	NOUDEVRULES_ARG,
 	NOUDEVSYNC_ARG,
 	OPTIONS_ARG,
 	READAHEAD_ARG,
@@ -557,6 +558,7 @@
 	struct dm_task *dmt;
 	const char *file = NULL;
 	uint32_t cookie = 0;
+	uint16_t udev_flags = 0;
 
 	if (argc == 3)
 		file = argv[2];
@@ -605,7 +607,11 @@
 	if (_switches[NOTABLE_ARG])
 		dm_udev_set_sync_support(0);
 
-	if (!dm_task_set_cookie(dmt, &cookie, 0) ||
+	if (_switches[NOUDEVRULES_ARG])
+		udev_flags |= DM_UDEV_DISABLE_DM_RULES_FLAG |
+			      DM_UDEV_DISABLE_SUBSYSTEM_RULES_FLAG;
+
+	if (!dm_task_set_cookie(dmt, &cookie, udev_flags) ||
 	    !dm_task_run(dmt))
 		goto out;
 
@@ -626,6 +632,7 @@
 	int r = 0;
 	struct dm_task *dmt;
 	uint32_t cookie = 0;
+	uint16_t udev_flags = 0;
 
 	if (!(dmt = dm_task_create(DM_DEVICE_RENAME)))
 		return 0;
@@ -643,7 +650,11 @@
 	if (_switches[INACTIVE_ARG] && !dm_task_query_inactive_table(dmt))
 		goto out;
 
-	if (!dm_task_set_cookie(dmt, &cookie, 0) ||
+	if (_switches[NOUDEVRULES_ARG])
+		udev_flags |= DM_UDEV_DISABLE_DM_RULES_FLAG |
+			      DM_UDEV_DISABLE_SUBSYSTEM_RULES_FLAG;
+
+	if (!dm_task_set_cookie(dmt, &cookie, udev_flags) ||
 	    !dm_task_run(dmt))
 		goto out;
 
@@ -1011,6 +1022,7 @@
 static int _simple(int task, const char *name, uint32_t event_nr, int display)
 {
 	uint32_t cookie = 0;
+	uint16_t udev_flags = 0;
 	int udev_wait_flag = task == DM_DEVICE_RESUME ||
 			     task == DM_DEVICE_REMOVE;
 	int r = 0;
@@ -1043,7 +1055,11 @@
 				    _read_ahead_flags))
 		goto out;
 
-	if (udev_wait_flag && !dm_task_set_cookie(dmt, &cookie, 0))
+	if (_switches[NOUDEVRULES_ARG])
+		udev_flags |= DM_UDEV_DISABLE_DM_RULES_FLAG |
+			      DM_UDEV_DISABLE_SUBSYSTEM_RULES_FLAG;
+
+	if (udev_wait_flag && !dm_task_set_cookie(dmt, &cookie, udev_flags))
 		goto out;
 
 	r = dm_task_run(dmt);
@@ -2559,7 +2575,8 @@
 	fprintf(out, "Usage:\n\n");
 	fprintf(out, "dmsetup [--version] [-v|--verbose [-v|--verbose ...]]\n"
 		"        [-r|--readonly] [--noopencount] [--nolockfs] [--inactive]\n"
-		"        [--noudevsync] [-y|--yes] [--readahead [+]<sectors>|auto|none]\n"
+		"        [--noudevrules] [--noudevsync] [-y|--yes]\n"
+		"        [--readahead [+]<sectors>|auto|none]\n"
 		"        [-c|-C|--columns] [-o <fields>] [-O|--sort <sort_fields>]\n"
 		"        [--nameprefixes] [--noheadings] [--separator <separator>]\n\n");
 	for (i = 0; _commands[i].name; i++)
@@ -2927,6 +2944,7 @@
 		{"nolockfs", 0, &ind, NOLOCKFS_ARG},
 		{"noopencount", 0, &ind, NOOPENCOUNT_ARG},
 		{"notable", 0, &ind, NOTABLE_ARG},
+		{"noudevrules", 0, &ind, NOUDEVRULES_ARG},
 		{"noudevsync", 0, &ind, NOUDEVSYNC_ARG},
 		{"options", 1, &ind, OPTIONS_ARG},
 		{"readahead", 1, &ind, READAHEAD_ARG},
@@ -3039,6 +3057,8 @@
 		}
 		if (c == 'y' || ind == YES_ARG)
 			_switches[YES_ARG]++;
+		if (ind == NOUDEVRULES_ARG)
+			_switches[NOUDEVRULES_ARG]++;
 		if (ind == NOUDEVSYNC_ARG)
 			_switches[NOUDEVSYNC_ARG]++;
 		if (c == 'G' || ind == GID_ARG) {


