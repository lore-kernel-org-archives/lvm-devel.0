From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 17 Jun 2011 14:55:52 -0000
Subject: LVM2 ./WHATS_NEW_DM tools/dmsetup.c
Message-ID: <20110617145552.11785.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2011-06-17 14:55:51

Modified files:
	.              : WHATS_NEW_DM 
	tools          : dmsetup.c 

Log message:
	Disable udev fallback and add --udevfallback option to dmsetup.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.472&r2=1.473
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/dmsetup.c.diff?cvsroot=lvm2&r1=1.160&r2=1.161

--- LVM2/WHATS_NEW_DM	2011/06/13 03:32:45	1.472
+++ LVM2/WHATS_NEW_DM	2011/06/17 14:55:51	1.473
@@ -1,5 +1,6 @@
 Version 1.02.65 - 
 ==================================
+  Disable udev fallback by default and add --udevfallback option to dmsetup.
   Warn if a table is loaded while a device is known to be in suspended state.
   Add dm_get_suspended_counter() for number of devs in suspended state by lib.
   Fix "all" report field prefix matching to include label fields with pv_all.
--- LVM2/tools/dmsetup.c	2011/04/22 11:56:41	1.160
+++ LVM2/tools/dmsetup.c	2011/06/17 14:55:51	1.161
@@ -135,6 +135,7 @@
 	UDEVCOOKIE_ARG,
 	NOUDEVRULES_ARG,
 	NOUDEVSYNC_ARG,
+	UDEVFALLBACK_ARG,
 	OPTIONS_ARG,
 	READAHEAD_ARG,
 	ROWS_ARG,
@@ -648,11 +649,11 @@
 	if (!_set_task_add_node(dmt))
                 goto out;
 
-	if (_udev_cookie) {
+	if (_udev_cookie)
 		cookie = _udev_cookie;
-		if (_udev_only)
-			udev_flags |= DM_UDEV_DISABLE_LIBRARY_FALLBACK;
-	}
+
+	if (_udev_only)
+		udev_flags |= DM_UDEV_DISABLE_LIBRARY_FALLBACK;
 
 	if (!dm_task_set_cookie(dmt, &cookie, udev_flags) ||
 	    !dm_task_run(dmt))
@@ -702,11 +703,11 @@
 		udev_flags |= DM_UDEV_DISABLE_DM_RULES_FLAG |
 			      DM_UDEV_DISABLE_SUBSYSTEM_RULES_FLAG;
 
-	if (_udev_cookie) {
+	if (_udev_cookie)
 		cookie = _udev_cookie;
-		if (_udev_only)
-			udev_flags |= DM_UDEV_DISABLE_LIBRARY_FALLBACK;
-	}
+
+	if (_udev_only)
+		udev_flags |= DM_UDEV_DISABLE_LIBRARY_FALLBACK;
 
 	if (!dm_task_set_cookie(dmt, &cookie, udev_flags) ||
 	    !dm_task_run(dmt))
@@ -1006,7 +1007,7 @@
 	else
 		dirs_diff = strcmp(dev_dir, udev_dev_dir);
 
-	_udev_only = _udev_cookie && !dirs_diff;
+	_udev_only = !dirs_diff && (_udev_cookie || !_switches[UDEVFALLBACK_ARG]);
 
 	if (dirs_diff) {
 		log_debug("The path %s used for creating device nodes that is "
@@ -1225,11 +1226,11 @@
 		udev_flags |= DM_UDEV_DISABLE_DM_RULES_FLAG |
 			      DM_UDEV_DISABLE_SUBSYSTEM_RULES_FLAG;
 
-	if (_udev_cookie) {
+	if (_udev_cookie)
 		cookie = _udev_cookie;
-		if (_udev_only)
-			udev_flags |= DM_UDEV_DISABLE_LIBRARY_FALLBACK;
-	}
+
+	if (_udev_only)
+		udev_flags |= DM_UDEV_DISABLE_LIBRARY_FALLBACK;
 
 	if (udev_wait_flag && !dm_task_set_cookie(dmt, &cookie, udev_flags))
 		goto out;
@@ -2744,8 +2745,8 @@
 	fprintf(out, "dmsetup [--version] [-h|--help [-c|-C|--columns]]\n"
 		"        [-v|--verbose [-v|--verbose ...]]\n"
 		"        [-r|--readonly] [--noopencount] [--nolockfs] [--inactive]\n"
-		"        [--udevcookie] [--noudevrules] [--noudevsync] [-y|--yes]\n"
-		"        [--readahead [+]<sectors>|auto|none]\n"
+		"        [--udevcookie] [--noudevrules] [--noudevsync] [--udevfallback]\n"
+		"        [-y|--yes] [--readahead [+]<sectors>|auto|none]\n"
 		"        [-c|-C|--columns] [-o <fields>] [-O|--sort <sort_fields>]\n"
 		"        [--nameprefixes] [--noheadings] [--separator <separator>]\n\n");
 	for (i = 0; _commands[i].name; i++)
@@ -3115,6 +3116,7 @@
 		{"udevcookie", 1, &ind, UDEVCOOKIE_ARG},
 		{"noudevrules", 0, &ind, NOUDEVRULES_ARG},
 		{"noudevsync", 0, &ind, NOUDEVSYNC_ARG},
+		{"udevfallback", 0, &ind, UDEVFALLBACK_ARG},
 		{"options", 1, &ind, OPTIONS_ARG},
 		{"readahead", 1, &ind, READAHEAD_ARG},
 		{"rows", 0, &ind, ROWS_ARG},
@@ -3243,6 +3245,8 @@
 			_switches[NOUDEVRULES_ARG]++;
 		if (ind == NOUDEVSYNC_ARG)
 			_switches[NOUDEVSYNC_ARG]++;
+		if (ind == UDEVFALLBACK_ARG)
+			_switches[UDEVFALLBACK_ARG]++;
 		if (c == 'G' || ind == GID_ARG) {
 			_switches[GID_ARG]++;
 			_int_args[GID_ARG] = atoi(optarg);


