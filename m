From: agk@sourceware.org <agk@sourceware.org>
Date: 2 Mar 2011 02:44:57 -0000
Subject: LVM2 ./WHATS_NEW_DM tools/dmsetup.c
Message-ID: <20110302024457.5477.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-03-02 02:44:56

Modified files:
	.              : WHATS_NEW_DM 
	tools          : dmsetup.c 

Log message:
	Accept multiple mapped device names on many dmsetup command lines.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.451&r2=1.452
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/dmsetup.c.diff?cvsroot=lvm2&r1=1.155&r2=1.156

--- LVM2/WHATS_NEW_DM	2011/03/02 00:29:57	1.451
+++ LVM2/WHATS_NEW_DM	2011/03/02 02:44:56	1.452
@@ -1,5 +1,6 @@
 Version 1.02.64 - 
 ===================================
+  Accept multiple mapped device names on many dmsetup command lines.
   Fix dm_udev_wait calls in dmsetup to occur before readahead display not after.
   Include an implicit dm_task_update_nodes() within dm_udev_wait().
   Fix _create_and_load_v4 not to lose the --addnodeoncreate setting (1.02.62).
--- LVM2/tools/dmsetup.c	2011/03/02 00:29:58	1.155
+++ LVM2/tools/dmsetup.c	2011/03/02 02:44:56	1.156
@@ -185,13 +185,16 @@
  * Commands
  */
 
-typedef int (*command_fn) (int argc, char **argv, void *data);
+struct command;
+#define CMD_ARGS const struct command *cmd, int argc, char **argv, struct dm_names *names, int multiple_devices
+typedef int (*command_fn) (CMD_ARGS);
 
 struct command {
 	const char *name;
 	const char *help;
 	int min_args;
 	int max_args;
+	int repeatable_cmd;	/* Repeat to process device list? */
 	command_fn fn;
 };
 
@@ -523,7 +526,7 @@
 	return 1;
 }
 
-static int _load(int argc, char **argv, void *data __attribute__((unused)))
+static int _load(CMD_ARGS)
 {
 	int r = 0;
 	struct dm_task *dmt;
@@ -583,7 +586,7 @@
 	return r;
 }
 
-static int _create(int argc, char **argv, void *data __attribute__((unused)))
+static int _create(CMD_ARGS)
 {
 	int r = 0;
 	struct dm_task *dmt;
@@ -670,7 +673,7 @@
 	return r;
 }
 
-static int _rename(int argc, char **argv, void *data __attribute__((unused)))
+static int _rename(CMD_ARGS)
 {
 	int r = 0;
 	struct dm_task *dmt;
@@ -721,7 +724,7 @@
 	return r;
 }
 
-static int _message(int argc, char **argv, void *data __attribute__((unused)))
+static int _message(CMD_ARGS)
 {
 	int r = 0, i;
 	size_t sz = 1;
@@ -786,7 +789,7 @@
 	return r;
 }
 
-static int _setgeometry(int argc, char **argv, void *data __attribute__((unused)))
+static int _setgeometry(CMD_ARGS)
 {
 	int r = 0;
 	struct dm_task *dmt;
@@ -825,7 +828,7 @@
 	return r;
 }
 
-static int _splitname(int argc, char **argv, void *data __attribute__((unused)))
+static int _splitname(CMD_ARGS)
 {
 	struct dmsetup_report_obj obj;
 	int r = 1;
@@ -859,7 +862,7 @@
 		return (uint32_t) value;
 }
 
-static int _udevflags(int args, char **argv, void *data __attribute__((unused)))
+static int _udevflags(CMD_ARGS)
 {
 	uint32_t cookie;
 	uint16_t flags;
@@ -901,7 +904,7 @@
 	return 1;
 }
 
-static int _udevcomplete(int argc, char **argv, void *data __attribute__((unused)))
+static int _udevcomplete(CMD_ARGS)
 {
 	uint32_t cookie;
 
@@ -926,30 +929,28 @@
 #ifndef UDEV_SYNC_SUPPORT
 static const char _cmd_not_supported[] = "Command not supported. Recompile with \"--enable-udev-sync\" to enable.";
 
-static int _udevcreatecookie(int argc, char **argv,
-				  void *data __attribute__((unused)))
+static int _udevcreatecookie(CMD_ARGS)
 {
 	log_error(_cmd_not_supported);
 
 	return 0;
 }
 
-static int _udevreleasecookie(int argc, char **argv,
-				void *data __attribute__((unused)))
+static int _udevreleasecookie(CMD_ARGS)
 {
 	log_error(_cmd_not_supported);
 
 	return 0;
 }
 
-static int _udevcomplete_all(int argc __attribute__((unused)), char **argv __attribute__((unused)), void *data __attribute__((unused)))
+static int _udevcomplete_all(CMD_ARGS)
 {
 	log_error(_cmd_not_supported);
 
 	return 0;
 }
 
-static int _udevcookies(int argc __attribute__((unused)), char **argv __attribute__((unused)), void *data __attribute__((unused)))
+static int _udevcookies(CMD_ARGS)
 {
 	log_error(_cmd_not_supported);
 
@@ -1023,8 +1024,7 @@
 	return 1;
 }
 
-static int _udevcreatecookie(int argc, char **argv,
-				  void *data __attribute__((unused)))
+static int _udevcreatecookie(CMD_ARGS)
 {
 	uint32_t cookie;
 
@@ -1037,8 +1037,7 @@
 	return 1;
 }
 
-static int _udevreleasecookie(int argc, char **argv,
-				void *data __attribute__((unused)))
+static int _udevreleasecookie(CMD_ARGS)
 {
 	if (argv[1] && !(_udev_cookie = _get_cookie_value(argv[1])))
 		return 0;
@@ -1079,7 +1078,7 @@
 	return ret;
 }
 
-static int _udevcomplete_all(int argc __attribute__((unused)), char **argv __attribute__((unused)), void *data __attribute__((unused)))
+static int _udevcomplete_all(CMD_ARGS)
 {
 	int max_id, id, sid;
 	struct seminfo sinfo;
@@ -1128,7 +1127,7 @@
 	return 1;
 }
 
-static int _udevcookies(int argc __attribute__((unused)), char **argv __attribute__((unused)), void *data __attribute__((unused)))
+static int _udevcookies(CMD_ARGS)
 {
 	int max_id, id, sid;
 	struct seminfo sinfo;
@@ -1167,7 +1166,7 @@
 }
 #endif	/* UDEV_SYNC_SUPPORT */
 
-static int _version(int argc __attribute__((unused)), char **argv __attribute__((unused)), void *data __attribute__((unused)))
+static int _version(CMD_ARGS)
 {
 	char version[80];
 
@@ -1249,22 +1248,22 @@
 	return r;
 }
 
-static int _suspend(int argc, char **argv, void *data __attribute__((unused)))
+static int _suspend(CMD_ARGS)
 {
 	return _simple(DM_DEVICE_SUSPEND, argc > 1 ? argv[1] : NULL, 0, 1);
 }
 
-static int _resume(int argc, char **argv, void *data __attribute__((unused)))
+static int _resume(CMD_ARGS)
 {
 	return _simple(DM_DEVICE_RESUME, argc > 1 ? argv[1] : NULL, 0, 1);
 }
 
-static int _clear(int argc, char **argv, void *data __attribute__((unused)))
+static int _clear(CMD_ARGS)
 {
 	return _simple(DM_DEVICE_CLEAR, argc > 1 ? argv[1] : NULL, 0, 1);
 }
 
-static int _wait(int argc, char **argv, void *data __attribute__((unused)))
+static int _wait(CMD_ARGS)
 {
 	const char *name = NULL;
 
@@ -1281,8 +1280,8 @@
 		       (argc > 1) ? (uint32_t) atoi(argv[argc - 1]) : 0, 1);
 }
 
-static int _process_all(int argc, char **argv, int silent,
-			int (*fn) (int argc, char **argv, void *data))
+static int _process_all(const struct command *cmd, int argc, char **argv, int silent,
+			int (*fn) (CMD_ARGS))
 {
 	int r = 1;
 	struct dm_names *names;
@@ -1311,7 +1310,7 @@
 
 	do {
 		names = (struct dm_names *)((char *) names + next);
-		if (!fn(argc, argv, names))
+		if (!fn(cmd, argc, argv, names, 1))
 			r = 0;
 		next = names->next;
 	} while (next);
@@ -1358,15 +1357,14 @@
 	return size;
 }
 
-static int _error_device(int argc __attribute__((unused)), char **argv __attribute__((unused)), void *data)
+static int _error_device(CMD_ARGS)
 {
-	struct dm_names *names = (struct dm_names *) data;
 	struct dm_task *dmt;
 	const char *name;
 	uint64_t size;
 	int r = 0;
 
-	if (data)
+	if (names)
 		name = names->name;
 	else
 		name = argv[1];
@@ -1406,22 +1404,22 @@
 	return r;
 }
 
-static int _remove(int argc, char **argv, void *data __attribute__((unused)))
+static int _remove(CMD_ARGS)
 {
 	if (_switches[FORCE_ARG] && argc > 1)
-		(void) _error_device(argc, argv, NULL);
+		(void) _error_device(cmd, argc, argv, NULL, 0);
 
 	return _simple(DM_DEVICE_REMOVE, argc > 1 ? argv[1] : NULL, 0, 0);
 }
 
-static int _count_devices(int argc __attribute__((unused)), char **argv __attribute__((unused)), void *data __attribute__((unused)))
+static int _count_devices(CMD_ARGS)
 {
 	_num_devices++;
 
 	return 1;
 }
 
-static int _remove_all(int argc __attribute__((unused)), char **argv __attribute__((unused)), void *data __attribute__((unused)))
+static int _remove_all(CMD_ARGS)
 {
 	int r;
 
@@ -1432,17 +1430,17 @@
 		return r;
 
 	_num_devices = 0;
-	r |= _process_all(argc, argv, 1, _count_devices);
+	r |= _process_all(cmd, argc, argv, 1, _count_devices);
 
 	/* No devices left? */
 	if (!_num_devices)
 		return r;
 
-	r |= _process_all(argc, argv, 1, _error_device);
+	r |= _process_all(cmd, argc, argv, 1, _error_device);
 	r |= _simple(DM_DEVICE_REMOVE_ALL, "", 0, 0) | dm_mknodes(NULL);
 
 	_num_devices = 0;
-	r |= _process_all(argc, argv, 1, _count_devices);
+	r |= _process_all(cmd, argc, argv, 1, _count_devices);
 	if (!_num_devices)
 		return r;
 
@@ -1459,7 +1457,7 @@
 		printf("%s\t(%u, %u)\n", name, info.major, info.minor);
 }
 
-static int _mknodes(int argc, char **argv, void *data __attribute__((unused)))
+static int _mknodes(CMD_ARGS)
 {
 	return dm_mknodes(argc > 1 ? argv[1] : NULL);
 }
@@ -1523,7 +1521,7 @@
 	return 1;
 }
 
-static int _status(int argc, char **argv, void *data)
+static int _status(CMD_ARGS)
 {
 	int r = 0;
 	struct dm_task *dmt;
@@ -1531,31 +1529,30 @@
 	uint64_t start, length;
 	char *target_type = NULL;
 	char *params, *c;
-	int cmd;
-	struct dm_names *names = (struct dm_names *) data;
+	int cmdno;
 	const char *name = NULL;
 	int matched = 0;
 	int ls_only = 0;
 	struct dm_info info;
 
-	if (data)
+	if (names)
 		name = names->name;
 	else {
 		if (argc == 1 && !_switches[UUID_ARG] && !_switches[MAJOR_ARG])
-			return _process_all(argc, argv, 0, _status);
-		if (argc == 2)
+			return _process_all(cmd, argc, argv, 0, _status);
+		if (multiple_devices)
 			name = argv[1];
 	}
 
-	if (!strcmp(argv[0], "table"))
-		cmd = DM_DEVICE_TABLE;
+	if (!strcmp(cmd->name, "table"))
+		cmdno = DM_DEVICE_TABLE;
 	else
-		cmd = DM_DEVICE_STATUS;
+		cmdno = DM_DEVICE_STATUS;
 
-	if (!strcmp(argv[0], "ls"))
+	if (!strcmp(cmd->name, "ls"))
 		ls_only = 1;
 
-	if (!(dmt = dm_task_create(cmd)))
+	if (!(dmt = dm_task_create(cmdno)))
 		return 0;
 
 	if (!_set_task_device(dmt, name, 0))
@@ -1593,12 +1590,12 @@
 			   _switches[VERBOSE_ARG]) {
 			if (!matched && _switches[VERBOSE_ARG])
 				_display_info(dmt);
-			if (data && !_switches[VERBOSE_ARG])
+			if (multiple_devices && !_switches[VERBOSE_ARG])
 				printf("%s: ", name);
 			if (target_type) {
 				/* Suppress encryption key */
 				if (!_switches[SHOWKEYS_ARG] &&
-				    cmd == DM_DEVICE_TABLE &&
+				    cmdno == DM_DEVICE_TABLE &&
 				    !strcmp(target_type, "crypt")) {
 					c = params;
 					while (*c && *c != ' ')
@@ -1616,7 +1613,7 @@
 		matched = 1;
 	} while (next);
 
-	if (data && _switches[VERBOSE_ARG] && matched && !ls_only)
+	if (multiple_devices && _switches[VERBOSE_ARG] && matched && !ls_only)
 		printf("\n");
 
 	if (matched && _switches[EXEC_ARG] && _command && !_exec_command(name))
@@ -1630,7 +1627,7 @@
 }
 
 /* Show target names and their version numbers */
-static int _targets(int argc __attribute__((unused)), char **argv __attribute__((unused)), void *data __attribute__((unused)))
+static int _targets(CMD_ARGS)
 {
 	int r = 0;
 	struct dm_task *dmt;
@@ -1662,20 +1659,19 @@
 	return r;
 }
 
-static int _info(int argc, char **argv, void *data)
+static int _info(CMD_ARGS)
 {
 	int r = 0;
 
 	struct dm_task *dmt;
-	struct dm_names *names = (struct dm_names *) data;
 	char *name = NULL;
 
-	if (data)
+	if (names)
 		name = names->name;
 	else {
 		if (argc == 1 && !_switches[UUID_ARG] && !_switches[MAJOR_ARG])
-			return _process_all(argc, argv, 0, _info);
-		if (argc == 2)
+			return _process_all(cmd, argc, argv, 0, _info);
+		if (multiple_devices)
 			name = argv[1];
 	}
 
@@ -1701,22 +1697,21 @@
 	return r;
 }
 
-static int _deps(int argc, char **argv, void *data)
+static int _deps(CMD_ARGS)
 {
 	int r = 0;
 	uint32_t i;
 	struct dm_deps *deps;
 	struct dm_task *dmt;
 	struct dm_info info;
-	struct dm_names *names = (struct dm_names *) data;
 	char *name = NULL;
 
-	if (data)
+	if (names)
 		name = names->name;
 	else {
 		if (argc == 1 && !_switches[UUID_ARG] && !_switches[MAJOR_ARG])
-			return _process_all(argc, argv, 0, _deps);
-		if (argc == 2)
+			return _process_all(cmd, argc, argv, 0, _deps);
+		if (multiple_devices)
 			name = argv[1];
 	}
 
@@ -1750,7 +1745,7 @@
 	if (_switches[VERBOSE_ARG])
 		_display_info(dmt);
 
-	if (data && !_switches[VERBOSE_ARG])
+	if (multiple_devices && !_switches[VERBOSE_ARG])
 		printf("%s: ", name);
 	printf("%d dependencies\t:", deps->count);
 
@@ -1760,7 +1755,7 @@
 		       (int) MINOR(deps->device[i]));
 	printf("\n");
 
-	if (data && _switches[VERBOSE_ARG])
+	if (multiple_devices && _switches[VERBOSE_ARG])
 		printf("\n");
 
 	r = 1;
@@ -1770,10 +1765,8 @@
 	return r;
 }
 
-static int _display_name(int argc __attribute__((unused)), char **argv __attribute__((unused)), void *data)
+static int _display_name(CMD_ARGS)
 {
-	struct dm_names *names = (struct dm_names *) data;
-
 	printf("%s\t(%d, %d)\n", names->name,
 	       (int) MAJOR(names->dev), (int) MINOR(names->dev));
 
@@ -2085,10 +2078,8 @@
 	}
 }
 
-static int _add_dep(int argc __attribute__((unused)), char **argv __attribute__((unused)), void *data)
+static int _add_dep(CMD_ARGS)
 {
-	struct dm_names *names = (struct dm_names *) data;
-
 	if (!dm_tree_add_dev(_dtree, (unsigned) MAJOR(names->dev), (unsigned) MINOR(names->dev)))
 		return 0;
 
@@ -2098,7 +2089,7 @@
 /*
  * Create and walk dependency tree
  */
-static int _build_whole_deptree(void)
+static int _build_whole_deptree(const struct command *cmd)
 {
 	if (_dtree)
 		return 1;
@@ -2106,17 +2097,15 @@
 	if (!(_dtree = dm_tree_create()))
 		return 0;
 
-	if (!_process_all(0, NULL, 0, _add_dep))
+	if (!_process_all(cmd, 0, NULL, 0, _add_dep))
 		return 0;
 
 	return 1;
 }
 
-static int _display_tree(int argc __attribute__((unused)),
-			 char **argv __attribute__((unused)),
-			 void *data __attribute__((unused)))
+static int _display_tree(CMD_ARGS)
 {
-	if (!_build_whole_deptree())
+	if (!_build_whole_deptree(cmd))
 		return 0;
 
 	_display_tree_walk_children(dm_tree_find_node(_dtree, 0, 0), 0);
@@ -2581,7 +2570,7 @@
 static const char *default_report_options = "name,major,minor,attr,open,segments,events,uuid";
 static const char *splitname_report_options = "vg_name,lv_name,lv_layer";
 
-static int _report_init(struct command *c)
+static int _report_init(const struct command *cmd)
 {
 	char *options = (char *) default_report_options;
 	const char *keys = "";
@@ -2592,7 +2581,7 @@
 	size_t len = 0;
 	int r = 0;
 
-	if (c && !strcmp(c->name, "splitname"))
+	if (cmd && !strcmp(cmd->name, "splitname"))
 		options = (char *) splitname_report_options;
 
 	/* emulate old dmsetup behaviour */
@@ -2638,7 +2627,7 @@
 	if (_switches[SORT_ARG] && _string_args[SORT_ARG]) {
 		keys = _string_args[SORT_ARG];
 		buffered = 1;
-		if (c && (!strcmp(c->name, "status") || !strcmp(c->name, "table"))) {
+		if (cmd && (!strcmp(cmd->name, "status") || !strcmp(cmd->name, "table"))) {
 			err("--sort is not yet supported with status and table");
 			goto out;
 		}
@@ -2672,7 +2661,7 @@
 				       options, separator, flags, keys, NULL)))
 		goto out;
 
-	if ((_report_type & DR_TREE) && !_build_whole_deptree()) {
+	if ((_report_type & DR_TREE) && !_build_whole_deptree(cmd)) {
 		err("Internal device dependency tree creation failed.");
 		goto out;
 	}
@@ -2695,56 +2684,56 @@
 /*
  * List devices
  */
-static int _ls(int argc, char **argv, void *data)
+static int _ls(CMD_ARGS)
 {
 	if ((_switches[TARGET_ARG] && _target) ||
 	    (_switches[EXEC_ARG] && _command))
-		return _status(argc, argv, data);
+		return _status(cmd, argc, argv, NULL, 0);
 	else if ((_switches[TREE_ARG]))
-		return _display_tree(argc, argv, data);
+		return _display_tree(cmd, 0, NULL, NULL, 0);
 	else
-		return _process_all(argc, argv, 0, _display_name);
+		return _process_all(cmd, argc, argv, 0, _display_name);
 }
 
-static int _help(int argc, char **argv, void *data);
+static int _help(CMD_ARGS);
 
 /*
  * Dispatch table
  */
 static struct command _commands[] = {
-	{"help", "[-c|-C|--columns]", 0, 0, _help},
+	{"help", "[-c|-C|--columns]", 0, 0, 0, _help},
 	{"create", "<dev_name> [-j|--major <major> -m|--minor <minor>]\n"
 	  "\t                  [-U|--uid <uid>] [-G|--gid <gid>] [-M|--mode <octal_mode>]\n"
 	  "\t                  [-u|uuid <uuid>] [{--addnodeonresume|--addnodeoncreate}]\n"
 	  "\t                  [--notable | --table <table> | <table_file>]",
-	 1, 2, _create},
-	{"remove", "[-f|--force] <device>", 0, 1, _remove},
-	{"remove_all", "[-f|--force]", 0, 0, _remove_all},
-	{"suspend", "[--noflush] <device>", 0, 1, _suspend},
-	{"resume", "<device> [{--addnodeonresume|--addnodeoncreate}]", 0, 1, _resume},
-	{"load", "<device> [<table_file>]", 0, 2, _load},
-	{"clear", "<device>", 0, 1, _clear},
-	{"reload", "<device> [<table_file>]", 0, 2, _load},
-	{"rename", "<device> [--setuuid] <new_name_or_uuid>", 1, 2, _rename},
-	{"message", "<device> <sector> <message>", 2, -1, _message},
-	{"ls", "[--target <target_type>] [--exec <command>] [--tree [-o options]]", 0, 0, _ls},
-	{"info", "[<device>]", 0, 1, _info},
-	{"deps", "[<device>]", 0, 1, _deps},
-	{"status", "[<device>] [--target <target_type>]", 0, 1, _status},
-	{"table", "[<device>] [--target <target_type>] [--showkeys]", 0, 1, _status},
-	{"wait", "<device> [<event_nr>]", 0, 2, _wait},
-	{"mknodes", "[<device>]", 0, 1, _mknodes},
-	{"udevcreatecookie", "", 0, 0, _udevcreatecookie},
-	{"udevreleasecookie", "[<cookie>]", 0, 1, _udevreleasecookie},
-	{"udevflags", "<cookie>", 1, 1, _udevflags},
-	{"udevcomplete", "<cookie>", 1, 1, _udevcomplete},
-	{"udevcomplete_all", "", 0, 0, _udevcomplete_all},
-	{"udevcookies", "", 0, 0, _udevcookies},
-	{"targets", "", 0, 0, _targets},
-	{"version", "", 0, 0, _version},
-	{"setgeometry", "<device> <cyl> <head> <sect> <start>", 5, 5, _setgeometry},
-	{"splitname", "<device> [<subsystem>]", 1, 2, _splitname},
-	{NULL, NULL, 0, 0, NULL}
+	 1, 2,0,  _create},
+	{"remove", "[-f|--force] <device>", 0, -1, 1, _remove},
+	{"remove_all", "[-f|--force]", 0, 0, 0,  _remove_all},
+	{"suspend", "[--noflush] <device>", 0, -1, 1, _suspend},
+	{"resume", "<device> [{--addnodeonresume|--addnodeoncreate}]", 0, -1, 1, _resume},
+	{"load", "<device> [<table_file>]", 0, 2, 0, _load},
+	{"clear", "<device>", 0, -1, 1, _clear},
+	{"reload", "<device> [<table_file>]", 0, 2, 0, _load},
+	{"rename", "<device> [--setuuid] <new_name_or_uuid>", 1, 2, 0, _rename},
+	{"message", "<device> <sector> <message>", 2, -1, 0, _message},
+	{"ls", "[--target <target_type>] [--exec <command>] [--tree [-o options]]", 0, 0, 0, _ls},
+	{"info", "[<device>]", 0, -1, 1, _info},
+	{"deps", "[<device>]", 0, -1, 1, _deps},
+	{"status", "[<device>] [--target <target_type>]", 0, -1, 1, _status},
+	{"table", "[<device>] [--target <target_type>] [--showkeys]", 0, -1, 1, _status},
+	{"wait", "<device> [<event_nr>]", 0, 2, 0, _wait},
+	{"mknodes", "[<device>]", 0, -1, 1, _mknodes},
+	{"udevcreatecookie", "", 0, 0, 0, _udevcreatecookie},
+	{"udevreleasecookie", "[<cookie>]", 0, 1, 0, _udevreleasecookie},
+	{"udevflags", "<cookie>", 1, 1, 0, _udevflags},
+	{"udevcomplete", "<cookie>", 1, 1, 0, _udevcomplete},
+	{"udevcomplete_all", "", 0, 0, 0, _udevcomplete_all},
+	{"udevcookies", "", 0, 0, 0, _udevcookies},
+	{"targets", "", 0, 0, 0, _targets},
+	{"version", "", 0, 0, 0, _version},
+	{"setgeometry", "<device> <cyl> <head> <sect> <start>", 5, 5, 0, _setgeometry},
+	{"splitname", "<device> [<subsystem>]", 1, 2, 0, _splitname},
+	{NULL, NULL, 0, 0, 0, NULL}
 };
 
 static void _usage(FILE *out)
@@ -2777,9 +2766,7 @@
 		     "[-o offset] [-f|loop_device] [file]\n\n");
 }
 
-static int _help(int argc __attribute__((unused)),
-		 char **argv __attribute__((unused)),
-		 void *data __attribute__((unused)))
+static int _help(CMD_ARGS)
 {
 	_usage(stderr);
 
@@ -2792,7 +2779,7 @@
 			dm_report_free(_report);
 			_report = NULL;
 		}
-		(void) _report_init(NULL);
+		(void) _report_init(cmd);
 	}
 
 	return 1;
@@ -3357,9 +3344,10 @@
 
 int main(int argc, char **argv)
 {
-	struct command *c;
 	int r = 1;
 	const char *dev_dir;
+	const struct command *cmd;
+	int multiple_devices;
 
 	(void) setlocale(LC_ALL, "");
 
@@ -3378,12 +3366,12 @@
 	}
 
 	if (_switches[HELP_ARG]) {
-		c = _find_command("help");
+		cmd = _find_command("help");
 		goto doit;
 	}
 
 	if (_switches[VERSION_ARG]) {
-		c = _find_command("version");
+		cmd = _find_command("version");
 		goto doit;
 	}
 
@@ -3392,27 +3380,27 @@
 		goto out;
 	}
 
-	if (!(c = _find_command(argv[0]))) {
+	if (!(cmd = _find_command(argv[0]))) {
 		fprintf(stderr, "Unknown command\n");
 		_usage(stderr);
 		goto out;
 	}
 
-	if (argc < c->min_args + 1 ||
-	    (c->max_args >= 0 && argc > c->max_args + 1)) {
+	if (argc < cmd->min_args + 1 ||
+	    (cmd->max_args >= 0 && argc > cmd->max_args + 1)) {
 		fprintf(stderr, "Incorrect number of arguments\n");
 		_usage(stderr);
 		goto out;
 	}
 
-	if (!_switches[COLS_ARG] && !strcmp(c->name, "splitname"))
+	if (!_switches[COLS_ARG] && !strcmp(cmd->name, "splitname"))
 		_switches[COLS_ARG]++;
 
 	if (_switches[COLS_ARG]) {
-		if (!_report_init(c))
+		if (!_report_init(cmd))
 			goto out;
 		if (!_report) {
-			if (!strcmp(c->name, "info"))
+			if (!strcmp(cmd->name, "info"))
 				r = 0;  /* info -c -o help */
 			goto out;
 		}
@@ -3424,10 +3412,13 @@
 	#endif
 
       doit:
-	if (!c->fn(argc, argv, NULL)) {
-		fprintf(stderr, "Command failed\n");
-		goto out;
-	}
+	multiple_devices = (argc > 1);
+	do {
+		if (!cmd->fn(cmd, argc--, argv++, NULL, multiple_devices)) {
+			fprintf(stderr, "Command failed\n");
+			goto out;
+		}
+	} while (cmd->repeatable_cmd && argc > 1);
 
 	r = 0;
 


