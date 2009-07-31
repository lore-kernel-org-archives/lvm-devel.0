From: agk@sourceware.org <agk@sourceware.org>
Date: 31 Jul 2009 17:51:47 -0000
Subject: LVM2 ./WHATS_NEW libdm/.exported_symbols libdm ...
Message-ID: <20090731175147.2018.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-07-31 17:51:46

Modified files:
	.              : WHATS_NEW 
	libdm          : .exported_symbols libdevmapper.h libdm-common.c 
	man            : dmsetup.8.in 
	tools          : dmsetup.c 

Log message:
	Add udevcomplete and --noudevwait to dmsetup.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1221&r2=1.1222
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/.exported_symbols.diff?cvsroot=lvm2&r1=1.39&r2=1.40
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.92&r2=1.93
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.68&r2=1.69
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/dmsetup.8.in.diff?cvsroot=lvm2&r1=1.23&r2=1.24
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/dmsetup.c.diff?cvsroot=lvm2&r1=1.117&r2=1.118

--- LVM2/WHATS_NEW	2009/07/31 15:53:11	1.1221
+++ LVM2/WHATS_NEW	2009/07/31 17:51:45	1.1222
@@ -1,5 +1,6 @@
 Version 2.02.51 - 
 ================================
+  Add udevcomplete and --noudevwait to dmsetup.
   Add libdevmapper functions to support synchronisation with udev.
   Added configure --enable-udev_rules --enable-udev_sync.
   Added configure --with-udev-prefix --with-udevdir.
--- LVM2/libdm/.exported_symbols	2009/07/31 15:53:12	1.39
+++ LVM2/libdm/.exported_symbols	2009/07/31 17:51:46	1.40
@@ -157,6 +157,6 @@
 dm_list_size
 dm_udev_set_sync_support
 dm_udev_get_sync_support
-dm_udev_notify
+dm_udev_complete
 dm_udev_wait
 dm_udev_cleanup
--- LVM2/libdm/libdevmapper.h	2009/07/31 15:53:12	1.92
+++ LVM2/libdm/libdevmapper.h	2009/07/31 17:51:46	1.93
@@ -1018,7 +1018,7 @@
  */
 void dm_udev_set_sync_support(int sync_with_udev);
 int dm_udev_get_sync_support(void);
-int dm_udev_notify(uint32_t cookie);
+int dm_udev_complete(uint32_t cookie);
 int dm_udev_wait(uint32_t cookie);
 int dm_udev_cleanup(uint32_t cookie);
 
--- LVM2/libdm/libdm-common.c	2009/07/31 16:57:06	1.68
+++ LVM2/libdm/libdm-common.c	2009/07/31 17:51:46	1.69
@@ -789,7 +789,7 @@
 	return 1;
 }
 
-int dm_udev_notify(uint32_t cookie)
+int dm_udev_complete(uint32_t cookie)
 {
 	return 1;
 }
@@ -983,7 +983,7 @@
 	return 0;
 }
 
-int dm_udev_notify(uint32_t cookie)
+int dm_udev_complete(uint32_t cookie)
 {
 	int semid;
 
--- LVM2/man/dmsetup.8.in	2009/04/23 12:20:15	1.23
+++ LVM2/man/dmsetup.8.in	2009/07/31 17:51:46	1.24
@@ -64,6 +64,9 @@
 .B dmsetup mknodes
 .I [device_name]
 .br
+.B dmsetup udevcomplete
+.I cookie
+.br
 .B dmsetup targets
 .br
 .B dmsetup version
@@ -108,6 +111,9 @@
 .IP \fB--notable
 .br
 When creating a device, don't load any table.
+.IP \fB--noudevsync
+Do not synchronise with udev when creating, renaming or removing devices.
+.br
 .IP \fB-o|--options
 .br
 Specify which fields to display.
@@ -280,6 +286,11 @@
 .IP \fBtargets
 .br
 Displays the names and versions of the currently-loaded targets.
+.IP \fBudevcomplete
+.I cookie
+.br
+Wake any processes that are waiting for udev to complete processing the specified cookie.
+.br
 .IP \fBversion
 .br
 Outputs version information.
--- LVM2/tools/dmsetup.c	2009/07/13 21:26:42	1.117
+++ LVM2/tools/dmsetup.c	2009/07/31 17:51:46	1.118
@@ -119,6 +119,7 @@
 	NOLOCKFS_ARG,
 	NOOPENCOUNT_ARG,
 	NOTABLE_ARG,
+	NOUDEVSYNC_ARG,
 	OPTIONS_ARG,
 	READAHEAD_ARG,
 	ROWS_ARG,
@@ -540,6 +541,7 @@
 	int r = 0;
 	struct dm_task *dmt;
 	const char *file = NULL;
+	uint32_t cookie = 0;
 
 	if (argc == 3)
 		file = argv[2];
@@ -582,8 +584,16 @@
 				    _read_ahead_flags))
 		goto out;
 
-	if (!dm_task_run(dmt))
+	if (_switches[NOTABLE_ARG])
+		dm_udev_set_sync_support(0);
+
+	if (!dm_task_set_cookie(dmt, &cookie) ||
+	    !dm_task_run(dmt)) {
+		(void) dm_udev_cleanup(cookie);
 		goto out;
+	}
+
+	dm_udev_wait(cookie);
 
 	r = 1;
 
@@ -600,6 +610,7 @@
 {
 	int r = 0;
 	struct dm_task *dmt;
+	uint32_t cookie = 0;
 
 	if (!(dmt = dm_task_create(DM_DEVICE_RENAME)))
 		return 0;
@@ -614,8 +625,13 @@
 	if (_switches[NOOPENCOUNT_ARG] && !dm_task_no_open_count(dmt))
 		goto out;
 
-	if (!dm_task_run(dmt))
+	if (!dm_task_set_cookie(dmt, &cookie) ||
+	    !dm_task_run(dmt)) {
+		(void) dm_udev_cleanup(cookie);
 		goto out;
+	}
+
+	dm_udev_wait(cookie);
 
 	r = 1;
 
@@ -740,6 +756,19 @@
 	return r;
 }
 
+static int _udevcomplete(int argc, char **argv, void *data __attribute((unused)))
+{
+	uint32_t cookie;
+	char *p;
+
+	if (!(cookie = (uint32_t) strtoul(argv[1], &p, 0)) || *p) {
+		err("Incorrect cookie value");
+		return 0;
+	}
+
+	return dm_udev_complete(cookie);
+}
+
 static int _version(int argc __attribute((unused)), char **argv __attribute((unused)), void *data __attribute((unused)))
 {
 	char version[80];
@@ -757,6 +786,9 @@
 
 static int _simple(int task, const char *name, uint32_t event_nr, int display)
 {
+	uint32_t cookie = 0;
+	int udev_wait_flag = task == DM_DEVICE_RESUME ||
+			     task == DM_DEVICE_REMOVE;
 	int r = 0;
 
 	struct dm_task *dmt;
@@ -784,8 +816,20 @@
 				    _read_ahead_flags))
 		goto out;
 
+	if (udev_wait_flag && !dm_task_set_cookie(dmt, &cookie)) {
+		(void) dm_udev_cleanup(cookie);
+		goto out;
+	}
+
 	r = dm_task_run(dmt);
 
+	if (udev_wait_flag) {
+		if (r)
+			(void) dm_udev_wait(cookie);
+		else
+			(void) dm_udev_cleanup(cookie);
+	}
+
 	if (r && display && _switches[VERBOSE_ARG])
 		r = _display_info(dmt);
 
@@ -2261,6 +2305,7 @@
 	{"table", "[<device>] [--target <target_type>] [--showkeys]", 0, 1, _status},
 	{"wait", "<device> [<event_nr>]", 0, 2, _wait},
 	{"mknodes", "[<device>]", 0, 1, _mknodes},
+	{"udevcomplete", "<cookie>", 1, 1, _udevcomplete},
 	{"targets", "", 0, 0, _targets},
 	{"version", "", 0, 0, _version},
 	{"setgeometry", "<device> <cyl> <head> <sect> <start>", 5, 5, _setgeometry},
@@ -2275,7 +2320,7 @@
 	fprintf(out, "Usage:\n\n");
 	fprintf(out, "dmsetup [--version] [-v|--verbose [-v|--verbose ...]]\n"
 		"        [-r|--readonly] [--noopencount] [--nolockfs]\n"
-		"        [--readahead [+]<sectors>|auto|none]\n"
+		"        [--noudevsync] [--readahead [+]<sectors>|auto|none]\n"
 		"        [-c|-C|--columns] [-o <fields>] [-O|--sort <sort_fields>]\n"
 		"        [--nameprefixes] [--noheadings] [--separator <separator>]\n\n");
 	for (i = 0; _commands[i].name; i++)
@@ -2639,6 +2684,7 @@
 		{"nolockfs", 0, &ind, NOLOCKFS_ARG},
 		{"noopencount", 0, &ind, NOOPENCOUNT_ARG},
 		{"notable", 0, &ind, NOTABLE_ARG},
+		{"noudevsync", 0, &ind, NOUDEVSYNC_ARG},
 		{"options", 1, &ind, OPTIONS_ARG},
 		{"readahead", 1, &ind, READAHEAD_ARG},
 		{"rows", 0, &ind, ROWS_ARG},
@@ -2747,6 +2793,8 @@
 			_switches[UUID_ARG]++;
 			_uuid = optarg;
 		}
+		if (ind == NOUDEVSYNC_ARG)
+			_switches[NOUDEVSYNC_ARG]++;
 		if (c == 'G' || ind == GID_ARG) {
 			_switches[GID_ARG]++;
 			_int_args[GID_ARG] = atoi(optarg);
@@ -2888,6 +2936,9 @@
 	if (_switches[COLS_ARG] && !_report_init(c))
 		goto out;
 
+	if (_switches[NOUDEVSYNC_ARG])
+		dm_udev_set_sync_support(0);
+
       doit:
 	if (!c->fn(argc, argv, NULL)) {
 		fprintf(stderr, "Command failed\n");


