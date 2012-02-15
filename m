From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 15 Feb 2012 12:08:58 -0000
Subject: LVM2 ./WHATS_NEW_DM tools/dmsetup.c
Message-ID: <20120215120858.13680.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2012-02-15 12:08:57

Modified files:
	.              : WHATS_NEW_DM 
	tools          : dmsetup.c 

Log message:
	Add mangle command to dmsetup to provide renaming to correct mangled form.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.562&r2=1.563
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/dmsetup.c.diff?cvsroot=lvm2&r1=1.178&r2=1.179

--- LVM2/WHATS_NEW_DM	2012/02/15 12:06:17	1.562
+++ LVM2/WHATS_NEW_DM	2012/02/15 12:08:57	1.563
@@ -1,5 +1,6 @@
 Version 1.02.71 - 
 ====================================
+  Add mangle command to dmsetup to provide renaming to correct mangled form.
   Add 'mangled_name' and 'unmangled_name' fields to dmsetup info -c -o.
   Add --manglename option to dmsetup to select the name mangling mode.
   Add dm_task_get_name_mangled/unmangled to libdevmapper.
--- LVM2/tools/dmsetup.c	2012/02/15 12:06:17	1.178
+++ LVM2/tools/dmsetup.c	2012/02/15 12:08:57	1.179
@@ -699,8 +699,7 @@
 	return r;
 }
 
-static int _rename(CMD_ARGS)
-{
+static int _do_rename(const char *name, const char *new_name, const char *new_uuid) {
 	int r = 0;
 	struct dm_task *dmt;
 	uint32_t cookie = 0;
@@ -710,13 +709,13 @@
 		return 0;
 
 	/* FIXME Kernel doesn't support uuid or device number here yet */
-	if (!_set_task_device(dmt, (argc == 3) ? argv[1] : NULL, 0))
+	if (!_set_task_device(dmt, name, 0))
 		goto out;
 
-	if (_switches[SETUUID_ARG]) {
-		if  (!dm_task_set_newuuid(dmt, argv[argc - 1]))
+	if (new_uuid) {
+		if (!dm_task_set_newuuid(dmt, new_uuid))
 			goto out;
-	} else if (!dm_task_set_newname(dmt, argv[argc - 1]))
+	} else if (!dm_task_set_newname(dmt, new_name))
 		goto out;
 
 	if (_switches[NOOPENCOUNT_ARG] && !dm_task_no_open_count(dmt))
@@ -753,6 +752,15 @@
 	return r;
 }
 
+static int _rename(CMD_ARGS)
+{
+	const char *name = (argc == 3) ? argv[1] : NULL;
+
+	return _switches[SETUUID_ARG] ? _do_rename(name, NULL, argv[argc - 1]) :
+					_do_rename(name, argv[argc - 1], NULL);
+
+}
+
 static int _message(CMD_ARGS)
 {
 	int r = 0, i;
@@ -2895,6 +2903,66 @@
 		return _process_all(cmd, argc, argv, 0, _display_name);
 }
 
+static int _mangle(CMD_ARGS)
+{
+	char *name;
+	char *new_name = NULL;
+	struct dm_task *dmt;
+	struct dm_info info;
+	int r = 0;
+	int target_format;
+
+	if (names)
+		name = names->name;
+	else {
+		if (argc == 1 && !_switches[UUID_ARG] && !_switches[MAJOR_ARG])
+			return _process_all(cmd, argc, argv, 0, _mangle);
+		name = argv[1];
+	}
+
+	if (!(dmt = dm_task_create(DM_DEVICE_STATUS)))
+		return 0;
+
+	if (!(_set_task_device(dmt, name, 0)))
+		goto out;
+
+	if (!_switches[CHECKS_ARG] && !dm_task_enable_checks(dmt))
+		goto out;
+
+	if (!dm_task_run(dmt))
+		goto out;
+
+	if (!dm_task_get_info(dmt, &info) || !info.exists)
+		goto out;
+
+	target_format = _switches[MANGLENAME_ARG] ? _int_args[MANGLENAME_ARG]
+						  : DEFAULT_DM_NAME_MANGLING;
+
+	if (target_format == DM_STRING_MANGLING_NONE) {
+		if (!(new_name = dm_task_get_name_unmangled(dmt)))
+			goto out;
+	}
+	else if (!(new_name = dm_task_get_name_mangled(dmt)))
+		goto out;
+
+	/* Nothing to do if the name is in correct form already. */
+	if (!strcmp(name, new_name)) {
+		log_print("%s: name already in correct form", name);
+		r = 1;
+		goto out;
+	}
+	else
+		log_print("%s: renaming to %s", name, new_name);
+
+	/* Rename to correct form of the name. */
+	r = _do_rename(name, new_name, NULL);
+
+out:
+	dm_free(new_name);
+	dm_task_destroy(dmt);
+	return r;
+}
+
 static int _help(CMD_ARGS);
 
 /*
@@ -2924,6 +2992,7 @@
 	{"table", "[<device>] [--target <target_type>] [--showkeys]", 0, -1, 1, _status},
 	{"wait", "<device> [<event_nr>]", 0, 2, 0, _wait},
 	{"mknodes", "[<device>]", 0, -1, 1, _mknodes},
+	{"mangle", "[<device>]", 0, -1, 1, _mangle},
 	{"udevcreatecookie", "", 0, 0, 0, _udevcreatecookie},
 	{"udevreleasecookie", "[<cookie>]", 0, 1, 0, _udevreleasecookie},
 	{"udevflags", "<cookie>", 1, 1, 0, _udevflags},
@@ -3677,6 +3746,9 @@
 	if (!_switches[COLS_ARG] && !strcmp(cmd->name, "splitname"))
 		_switches[COLS_ARG]++;
 
+	if (!strcmp(cmd->name, "mangle"))
+		dm_set_name_mangling_mode(DM_STRING_MANGLING_NONE);
+
 	if (_switches[COLS_ARG]) {
 		if (!_report_init(cmd))
 			goto out;


