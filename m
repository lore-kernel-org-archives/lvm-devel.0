From: Alasdair Kergon <agk@fedoraproject.org>
Date: Thu, 13 Aug 2015 21:39:43 +0000 (UTC)
Subject: master - dmsetup: Restructure arg handling.
Message-ID: <20150813213943.275B26034F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=043fb32c4b67d1456a77ab7caf0d077f419fae88
Commit:        043fb32c4b67d1456a77ab7caf0d077f419fae88
Parent:        b3cd5d294503fcfa4b826456e17071a909d739e1
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Aug 13 22:30:39 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Aug 13 22:30:39 2015 +0100

dmsetup: Restructure arg handling.

Introduce enums and global variables to record cleanly which command we
are processing and eliminate the historically inconsistent use of the
shifted argv[0] and fix assorted bugs discovered along the way.

Add dm_report_is_empty() to indicate there is no data awaiting output
and use this to suppress dmsetup report headings when no data is output
so we don't get a stray line saying 'Help' at the end of reporting help.

Define a report type (as the interface requires) so -o all selects
the right fields in splitname.  (A fix for stats list will follow.)

Exit immediately if no device is supplied to dmsetup wipe_table instead
of hitting errors later and failing.

Adjust the command name printed in usage/help output to match command
invoked (most of the time).
---
 WHATS_NEW_DM                        |    6 +
 libdm/.exported_symbols.DM_1_02_105 |    1 +
 libdm/libdevmapper.h                |    5 +
 libdm/libdm-report.c                |    5 +
 tools/dmsetup.c                     |  400 +++++++++++++++++++++--------------
 5 files changed, 256 insertions(+), 161 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 45db0e4..f3b62b1 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,11 @@
 Version 1.02.105 - 
 ===================================
+  Exit immediately if no device is supplied to dmsetup wipe_table.
+  Suppress dmsetup report headings when no data is output. (1.02.104)
+  Adjust dmsetup usage/help output selection to match command invoked.
+  Fix dmsetup -o all to select correct fields in splitname report.
+  Restructure internal dmsetup argument handling across all commands.
+  Add dm_report_is_empty() to indicate there is no data awaiting output.
   Add more arg validation for dm_tree_node_add_cache_target().
   Add --alldevices switch to replace use of --force for stats create / delete.
 
diff --git a/libdm/.exported_symbols.DM_1_02_105 b/libdm/.exported_symbols.DM_1_02_105
new file mode 100644
index 0000000..9b701f1
--- /dev/null
+++ b/libdm/.exported_symbols.DM_1_02_105
@@ -0,0 +1 @@
+dm_report_is_empty
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 192fd0f..303ed67 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -2396,6 +2396,11 @@ int dm_report_object_is_selected(struct dm_report *rh, void *object, int do_outp
  */
 int dm_report_compact_fields(struct dm_report *rh);
 
+/*
+ * Returns 1 if there is no data waiting to be output.
+ */
+int dm_report_is_empty(struct dm_report *rh);
+
 int dm_report_output(struct dm_report *rh);
 
 /*
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 17a7e13..84b1294 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -4305,6 +4305,11 @@ static int _output_as_columns(struct dm_report *rh)
 	return 0;
 }
 
+int dm_report_is_empty(struct dm_report *rh)
+{
+	return dm_list_empty(&rh->rows) ? 1 : 0;
+}
+
 int dm_report_output(struct dm_report *rh)
 {
 	if (dm_list_empty(&rh->rows))
diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 1dcc7e3..b3820fe 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -108,10 +108,46 @@ extern char *optarg;
 /* program_id used for dmstats-managed statistics regions */
 #define DM_STATS_PROGRAM_ID "dmstats"
 
+/*
+ * Basic commands this code implments.
+ */
+typedef enum {
+	DMSETUP_CMD = 0,
+	LOSETUP_CMD = 1,
+	DMLOSETUP_CMD = 2,
+	DMSTATS_CMD = 3,
+	DMSETUP_STATS_CMD = 4,
+	DEVMAP_NAME_CMD = 5
+} cmd_name_t;
+
+typedef enum {
+	DMSETUP_TYPE = 0,
+	LOSETUP_TYPE = 1,
+	STATS_TYPE = 2,
+	DEVMAP_NAME_TYPE = 3
+} cmd_type_t;
+
 #define DMSETUP_CMD_NAME "dmsetup"
 #define LOSETUP_CMD_NAME "losetup"
 #define DMLOSETUP_CMD_NAME "dmlosetup"
 #define DMSTATS_CMD_NAME "dmstats"
+#define DMSETUP_STATS_CMD_NAME "dmsetup stats"
+#define DEVMAP_NAME_CMD_NAME "devmap_name"
+
+static const struct {
+	cmd_name_t command;
+	const char name[14];
+	cmd_type_t type;
+} _base_commands[] = {
+	{ DMSETUP_CMD, DMSETUP_CMD_NAME, DMSETUP_TYPE },
+	{ LOSETUP_CMD, LOSETUP_CMD_NAME, LOSETUP_TYPE },
+	{ DMLOSETUP_CMD, DMLOSETUP_CMD_NAME, LOSETUP_TYPE },
+	{ DMSTATS_CMD, DMSTATS_CMD_NAME, STATS_TYPE },
+	{ DMSETUP_STATS_CMD, DMSETUP_STATS_CMD_NAME, STATS_TYPE },
+	{ DEVMAP_NAME_CMD, DEVMAP_NAME_CMD_NAME, DEVMAP_NAME_TYPE },
+};
+
+static const int _num_base_commands = DM_ARRAY_SIZE(_base_commands);
 
 /*
  * We have only very simple switches ATM.
@@ -195,6 +231,8 @@ typedef enum {
 	DN_MAP		/* Map name (for dm devices only, equal to DN_BLK otherwise) */
 } dev_name_t;
 
+static cmd_name_t _base_command = DMSETUP_CMD;	/* Default command is 'dmsetup' */
+static cmd_type_t _base_command_type = DMSETUP_TYPE;
 static int _switches[NUM_SWITCHES];
 static int _int_args[NUM_SWITCHES];
 static char *_string_args[NUM_SWITCHES];
@@ -202,7 +240,8 @@ static int _num_devices;
 static char *_uuid;
 static char *_table;
 static char *_target;
-static char *_command;
+static char *_command_to_exec;		/* --exec <command> */
+static const char *_command;		/* dmsetup <command> */
 static uint32_t _read_ahead_flags;
 static uint32_t _udev_cookie;
 static int _udev_only;
@@ -934,20 +973,20 @@ static int _load(CMD_ARGS)
 	}
 
 	if (!_switches[UUID_ARG] && !_switches[MAJOR_ARG]) {
-		if (argc == 1) {
+		if (!argc) {
 			err("Please specify device.\n");
 			return 0;
 		}
-		name = argv[1];
+		name = argv[0];
 		argc--;
 		argv++;
-	} else if (argc > 2) {
+	} else if (argc > 1) {
 		err("Too many command line arguments.\n");
 		return 0;
 	}
 
-	if (argc == 2)
-		file = argv[1];
+	if (argc == 1)
+		file = argv[0];
 
 	if (!(dmt = dm_task_create(DM_DEVICE_RELOAD)))
 		return 0;
@@ -992,13 +1031,13 @@ static int _create(CMD_ARGS)
 	uint32_t cookie = 0;
 	uint16_t udev_flags = 0;
 
-	if (argc == 3)
-		file = argv[2];
+	if (argc == 2)
+		file = argv[1];
 
 	if (!(dmt = dm_task_create(DM_DEVICE_CREATE)))
 		return 0;
 
-	if (!dm_task_set_name(dmt, argv[1]))
+	if (!dm_task_set_name(dmt, argv[0]))
 		goto out;
 
 	if (_switches[UUID_ARG] && !dm_task_set_uuid(dmt, _uuid))
@@ -1128,7 +1167,7 @@ static int _do_rename(const char *name, const char *new_name, const char *new_uu
 
 static int _rename(CMD_ARGS)
 {
-	const char *name = (argc == 3) ? argv[1] : NULL;
+	const char *name = (argc == 2) ? argv[0] : NULL;
 
 	return _switches[SETUUID_ARG] ? _do_rename(name, NULL, argv[argc - 1]) :
 					_do_rename(name, argv[argc - 1], NULL);
@@ -1152,22 +1191,22 @@ static int _message(CMD_ARGS)
 		if (!_set_task_device(dmt, NULL, 0))
 			goto out;
 	} else {
-		if (!_set_task_device(dmt, argv[1], 0))
+		if (!_set_task_device(dmt, argv[0], 0))
 			goto out;
 		argc--;
 		argv++;
 	}
 
-	sector = strtoull(argv[1], &endptr, 10);
-	if (*endptr || endptr == argv[1]) {
+	sector = strtoull(argv[0], &endptr, 10);
+	if (*endptr || endptr == argv[0]) {
 		err("invalid sector");
 		goto out;
 	}
 	if (!dm_task_set_sector(dmt, sector))
 		goto out;
 
-	argc -= 2;
-	argv += 2;
+	argc--;
+	argv++;
 
 	if (argc <= 0)
 		err("No message supplied.\n");
@@ -1232,13 +1271,13 @@ static int _setgeometry(CMD_ARGS)
 		if (!_set_task_device(dmt, NULL, 0))
 			goto out;
 	} else {
-		if (!_set_task_device(dmt, argv[1], 0))
+		if (!_set_task_device(dmt, argv[0], 0))
 			goto out;
 		argc--;
 		argv++;
 	}
 
-	if (!dm_task_set_geometry(dmt, argv[1], argv[2], argv[3], argv[4]))
+	if (!dm_task_set_geometry(dmt, argv[0], argv[1], argv[2], argv[3]))
 		goto out;
 
 	if (_switches[NOOPENCOUNT_ARG] && !dm_task_no_open_count(dmt))
@@ -1267,8 +1306,8 @@ static int _splitname(CMD_ARGS)
 	struct dmsetup_report_obj obj = { NULL };
 	int r;
 
-	if (!(obj.split_name = _get_split_name((argc == 3) ? argv[2] : "LVM",
-					       argv[1], '\0')))
+	if (!(obj.split_name = _get_split_name((argc == 2) ? argv[1] : "LVM",
+					       argv[0], '\0')))
 		return_0;
 
 	r = dm_report_object(_report, &obj);
@@ -1308,7 +1347,7 @@ static int _udevflags(CMD_ARGS)
 					      "PRIMARY_SOURCE",
 					       0};
 
-	if (!(cookie = _get_cookie_value(argv[1])))
+	if (!(cookie = _get_cookie_value(argv[0])))
 		return 0;
 
 	flags = cookie >> DM_UDEV_FLAGS_SHIFT;
@@ -1340,7 +1379,7 @@ static int _udevcomplete(CMD_ARGS)
 {
 	uint32_t cookie;
 
-	if (!(cookie = _get_cookie_value(argv[1])))
+	if (!(cookie = _get_cookie_value(argv[0])))
 		return 0;
 
 	/*
@@ -1465,7 +1504,7 @@ static int _udevcreatecookie(CMD_ARGS)
 
 static int _udevreleasecookie(CMD_ARGS)
 {
-	if (argv[1] && !(_udev_cookie = _get_cookie_value(argv[1])))
+	if (argv[0] && !(_udev_cookie = _get_cookie_value(argv[0])))
 		return 0;
 
 	if (!_udev_cookie) {
@@ -1515,7 +1554,7 @@ static int _udevcomplete_all(CMD_ARGS)
 	unsigned age = 0;
 	time_t t;
 
-	if (argc == 2 && (sscanf(argv[1], "%u", &age) != 1)) {
+	if (argc == 1 && (sscanf(argv[0], "%u", &age) != 1)) {
 		log_error("Failed to read age_in_minutes parameter.");
 		return 0;
 	}
@@ -1713,17 +1752,17 @@ static int _simple(int task, const char *name, uint32_t event_nr, int display)
 
 static int _suspend(CMD_ARGS)
 {
-	return _simple(DM_DEVICE_SUSPEND, argc > 1 ? argv[1] : NULL, 0, 1);
+	return _simple(DM_DEVICE_SUSPEND, argc ? argv[0] : NULL, 0, 1);
 }
 
 static int _resume(CMD_ARGS)
 {
-	return _simple(DM_DEVICE_RESUME, argc > 1 ? argv[1] : NULL, 0, 1);
+	return _simple(DM_DEVICE_RESUME, argc ? argv[0] : NULL, 0, 1);
 }
 
 static int _clear(CMD_ARGS)
 {
-	return _simple(DM_DEVICE_CLEAR, argc > 1 ? argv[1] : NULL, 0, 1);
+	return _simple(DM_DEVICE_CLEAR, argc ? argv[0] : NULL, 0, 1);
 }
 
 static int _wait(CMD_ARGS)
@@ -1731,16 +1770,16 @@ static int _wait(CMD_ARGS)
 	const char *name = NULL;
 
 	if (!_switches[UUID_ARG] && !_switches[MAJOR_ARG]) {
-		if (argc == 1) {
+		if (!argc) {
 			err("No device specified.");
 			return 0;
 		}
-		name = argv[1];
+		name = argv[0];
 		argc--, argv++;
 	}
 
 	return _simple(DM_DEVICE_WAITEVENT, name,
-		       (argc > 1) ? (uint32_t) atoi(argv[argc - 1]) : 0, 1);
+		       (argc) ? (uint32_t) atoi(argv[argc - 1]) : 0, 1);
 }
 
 static int _process_all(const struct command *cmd, const char *subcommand, int argc, char **argv, int silent,
@@ -1833,7 +1872,7 @@ static int _error_device(CMD_ARGS)
 	uint64_t size;
 	int r = 0;
 
-	name = names ? names->name : argv[1];
+	name = names ? names->name : argv[0];
 
 	size = _get_device_size(name);
 
@@ -1875,7 +1914,7 @@ error:
 
 static int _remove(CMD_ARGS)
 {
-	if (_switches[FORCE_ARG] && argc > 1) {
+	if (_switches[FORCE_ARG] && argc) {
 		/*
 		 * 'remove --force' option is doing 2 operations on the same device
 		 * this is not compatible with the use of --udevcookie/DM_UDEV_COOKIE.
@@ -1886,7 +1925,7 @@ static int _remove(CMD_ARGS)
 		(void) _error_device(cmd, NULL, argc, argv, NULL, 0);
 	}
 
-	return _simple(DM_DEVICE_REMOVE, argc > 1 ? argv[1] : NULL, 0, 0);
+	return _simple(DM_DEVICE_REMOVE, argc ? argv[0] : NULL, 0, 0);
 }
 
 static int _count_devices(CMD_ARGS)
@@ -1936,7 +1975,7 @@ static void _display_dev(struct dm_task *dmt, const char *name)
 
 static int _mknodes(CMD_ARGS)
 {
-	return dm_mknodes(argc > 1 ? argv[1] : NULL);
+	return dm_mknodes(argc ? argv[0] : NULL);
 }
 
 static int _exec_command(const char *name)
@@ -1959,7 +1998,7 @@ static int _exec_command(const char *name)
 		return 0;
 
 	if (!argc) {
-		c = _command;
+		c = _command_to_exec;
 		while (argc < ARGS_MAX) {
 			while (*c && isspace(*c))
 				c++;
@@ -2015,9 +2054,9 @@ static int _status(CMD_ARGS)
 	if (names)
 		name = names->name;
 	else {
-		if (argc == 1 && !_switches[UUID_ARG] && !_switches[MAJOR_ARG])
+		if (!argc && !_switches[UUID_ARG] && !_switches[MAJOR_ARG])
 			return _process_all(cmd, NULL, argc, argv, 0, _status);
-		name = argv[1];
+		name = argv[0];
 	}
 
 	if (!strcmp(cmd->name, "table"))
@@ -2064,11 +2103,11 @@ static int _status(CMD_ARGS)
 		    (!target_type || strcmp(target_type, _target)))
 			continue;
 		if (ls_only) {
-			if (!_switches[EXEC_ARG] || !_command ||
+			if (!_switches[EXEC_ARG] || !_command_to_exec ||
 			    _switches[VERBOSE_ARG])
 				_display_dev(dmt, name);
 			next = NULL;
-		} else if (!_switches[EXEC_ARG] || !_command ||
+		} else if (!_switches[EXEC_ARG] || !_command_to_exec ||
 			   _switches[VERBOSE_ARG]) {
 			if (!matched && _switches[VERBOSE_ARG])
 				_display_info(dmt);
@@ -2098,7 +2137,7 @@ static int _status(CMD_ARGS)
 	if (multiple_devices && _switches[VERBOSE_ARG] && matched && !ls_only)
 		printf("\n");
 
-	if (matched && _switches[EXEC_ARG] && _command && !_exec_command(name))
+	if (matched && _switches[EXEC_ARG] && _command_to_exec && !_exec_command(name))
 		goto out;
 
 	r = 1;
@@ -2154,9 +2193,9 @@ static int _info(CMD_ARGS)
 	if (names)
 		name = names->name;
 	else {
-		if (argc == 1 && !_switches[UUID_ARG] && !_switches[MAJOR_ARG])
+		if (!argc && !_switches[UUID_ARG] && !_switches[MAJOR_ARG])
 			return _process_all(cmd, NULL, argc, argv, 0, _info);
-		name = argv[1];
+		name = argv[0];
 	}
 
 	if (!(dmt = dm_task_create(DM_DEVICE_INFO)))
@@ -2198,9 +2237,9 @@ static int _deps(CMD_ARGS)
 	if (names)
 		name = names->name;
 	else {
-		if (argc == 1 && !_switches[UUID_ARG] && !_switches[MAJOR_ARG])
+		if (!argc && !_switches[UUID_ARG] && !_switches[MAJOR_ARG])
 			return _process_all(cmd, NULL, argc, argv, 0, _deps);
-		name = argv[1];
+		name = argv[0];
 	}
 
 	if (!(dmt = dm_task_create(DM_DEVICE_DEPS)))
@@ -3930,14 +3969,20 @@ static int _report_init(const struct command *cmd)
 	size_t len = 0;
 	int r = 0;
 
-	if (cmd && !strcmp(cmd->name, "splitname"))
+	if (cmd && !strcmp(cmd->name, "splitname")) {
 		options = (char *) splitname_report_options;
+		_report_type |= DR_NAME;
+	}
 
-	if (cmd && !strcmp(cmd->name, "stats"))
+	if (cmd && !strcmp(cmd->name, "stats")) {
 		options = (char *) _stats_default_report_options;
+		_report_type |= DR_STATS;
+	}
 
-	if (cmd && !strcmp(cmd->name, "list"))
+	if (cmd && !strcmp(cmd->name, "list")) {
 		options = (char *) _stats_list_options;
+		_report_type |= DR_STATS;
+	}
 
 	/* emulate old dmsetup behaviour */
 	if (_switches[NOHEADINGS_ARG]) {
@@ -3962,10 +4007,12 @@ static int _report_init(const struct command *cmd)
 
 	if (_switches[OPTIONS_ARG] && _string_args[OPTIONS_ARG]) {
 		/* Count & interval forbidden for help. */
+		/* FIXME Detect "help" correctly and exit */
 		if (strstr(_string_args[OPTIONS_ARG], "help")) {
 			_switches[COUNT_ARG] = 0;
 			_count = 1;
 			_switches[INTERVAL_ARG] = 0;
+			headings = 0;
 		}
 
 		if (*_string_args[OPTIONS_ARG] != '+')
@@ -4055,7 +4102,7 @@ out:
 static int _ls(CMD_ARGS)
 {
 	if ((_switches[TARGET_ARG] && _target) ||
-	    (_switches[EXEC_ARG] && _command))
+	    (_switches[EXEC_ARG] && _command_to_exec))
 		return _status(cmd, NULL, argc, argv, NULL, 0);
 	else if ((_switches[TREE_ARG]))
 		return _display_tree(cmd, NULL, 0, NULL, NULL, 0);
@@ -4075,9 +4122,9 @@ static int _mangle(CMD_ARGS)
 	if (names)
 		name = names->name;
 	else {
-		if (argc == 1 && !_switches[UUID_ARG] && !_switches[MAJOR_ARG])
+		if (!argc && !_switches[UUID_ARG] && !_switches[MAJOR_ARG])
 			return _process_all(cmd, NULL, argc, argv, 0, _mangle);
-		name = argv[1];
+		name = argv[0];
 	}
 
 	if (!(dmt = dm_task_create(DM_DEVICE_STATUS)))
@@ -4223,9 +4270,9 @@ static int _stats_clear(CMD_ARGS)
 	if (names)
 		name = names->name;
 	else {
-		if (argc == 1 && !_switches[UUID_ARG] && !_switches[MAJOR_ARG])
+		if (!argc && !_switches[UUID_ARG] && !_switches[MAJOR_ARG])
 			return _process_all(cmd, subcommand, argc, argv, 0, _stats_clear);
-		name = argv[1];
+		name = argv[0];
 	}
 
 	region_id = (allregions) ? DM_STATS_REGIONS_ALL
@@ -4418,7 +4465,7 @@ static int _stats_create(CMD_ARGS)
 	if (names)
 		name = names->name;
 	else {
-		if (argc == 1 && !_switches[UUID_ARG] && !_switches[MAJOR_ARG]) {
+		if (!argc && !_switches[UUID_ARG] && !_switches[MAJOR_ARG]) {
 			if (!_switches[ALL_DEVICES_ARG]) {
 				log_error("Please specify device(s) or use "
 					  "--alldevices.");
@@ -4426,7 +4473,7 @@ static int _stats_create(CMD_ARGS)
 			}
 			return _process_all(cmd, subcommand, argc, argv, 0, _stats_create);
 		}
-		name = argv[1];
+		name = argv[0];
 	}
 
 	if (_switches[AREAS_ARG])
@@ -4506,7 +4553,7 @@ static int _stats_delete(CMD_ARGS)
 	if (names)
 		name = names->name;
 	else {
-		if (argc == 1 && !_switches[UUID_ARG] && !_switches[MAJOR_ARG]) {
+		if (!argc && !_switches[UUID_ARG] && !_switches[MAJOR_ARG]) {
 			if (!_switches[ALL_DEVICES_ARG]) {
 				log_error("Please specify device(s) or use "
 					  "--alldevices.");
@@ -4514,7 +4561,7 @@ static int _stats_delete(CMD_ARGS)
 			}
 			return _process_all(cmd, subcommand, argc, argv, 0, _stats_delete);
 		}
-		name = argv[1];
+		name = argv[0];
 	}
 
 	if (_switches[ALL_PROGRAMS_ARG])
@@ -4565,9 +4612,9 @@ static int _stats_list(CMD_ARGS)
 	if (names)
 		name = names->name;
 	else {
-		if (argc == 1 && !_switches[UUID_ARG] && !_switches[MAJOR_ARG])
+		if (!argc && !_switches[UUID_ARG] && !_switches[MAJOR_ARG])
 			return _process_all(cmd, subcommand, argc, argv, 0, _stats_list);
-		name = argv[1];
+		name = argv[0];
 	}
 
 	if (_switches[PROGRAM_ID_ARG])
@@ -4661,9 +4708,9 @@ static int _stats_print(CMD_ARGS)
 	if (names)
 		name = names->name;
 	else {
-		if (argc == 1 && !_switches[UUID_ARG] && !_switches[MAJOR_ARG])
+		if (!argc && !_switches[UUID_ARG] && !_switches[MAJOR_ARG])
 			return _process_all(cmd, subcommand, argc, argv, 0, _stats_print);
-		name = argv[1];
+		name = argv[0];
 	}
 
 	region_id = (uint64_t) _int_args[REGION_ID_ARG];
@@ -4720,9 +4767,9 @@ static int _stats_report(CMD_ARGS)
 	if (names)
 		name = names->name;
 	else {
-		if (argc == 1 && !_switches[UUID_ARG] && !_switches[MAJOR_ARG])
+		if (!argc && !_switches[UUID_ARG] && !_switches[MAJOR_ARG])
 			return _process_all(cmd, subcommand, argc, argv, 0, _info);
-		name = argv[1];
+		name = argv[0];
 	}
 
 	if (!(dmt = dm_task_create(DM_DEVICE_INFO)))
@@ -4811,7 +4858,7 @@ static struct command _dmsetup_commands[] = {
 	{"load", "<device> [<table_file>]", 0, 2, 0, 0, _load},
 	{"clear", "<device>", 0, -1, 1, 0, _clear},
 	{"reload", "<device> [<table_file>]", 0, 2, 0, 0, _load},
-	{"wipe_table", "<device>", 0, -1, 1, 0, _error_device},
+	{"wipe_table", "<device>", 1, -1, 1, 0, _error_device},
 	{"rename", "<device> [--setuuid] <new_name_or_uuid>", 1, 2, 0, 0, _rename},
 	{"message", "<device> <sector> <message>", 2, -1, 0, 0, _message},
 	{"ls", "[--target <target_type>] [--exec <command>] [-o options] [--tree]", 0, 0, 0, 0, _ls},
@@ -4840,22 +4887,30 @@ static struct command _dmsetup_commands[] = {
  * Usage and help text.
  */
 
+static void _devmap_name_usage(FILE *out)
+{
+	fprintf(out, "Usage: " DEVMAP_NAME_CMD_NAME " <major> <minor>\n\n");
+}
+
 static void _stats_usage(FILE *out)
 {
 	int i;
 
-	fprintf(out, "Usage:\n");
-	fprintf(out, "stats [-h|--help]\n");
+	fprintf(out, "Usage:\n\n");
+	fprintf(out, "%s\n", _base_commands[_base_command].name);
+	fprintf(out, "        [-h|--help]\n");
 	fprintf(out, "        [-v|--verbose [-v|--verbose ...]]\n");
 	fprintf(out, "        [--areas <nr_areas>] [--areasize <size>]\n");
 	fprintf(out, "        [--auxdata <data>] [--clear]\n");
 	fprintf(out, "        [--count <count>] [--interval <seconds>]\n");
 	fprintf(out, "        [-o <fields>] [-O|--sort <sort_fields>]\n");
-	fprintf(out, "	   [--programid <id>]\n");
+	fprintf(out, "	      [--programid <id>]\n");
 	fprintf(out, "        [--start <start>] [--length <length>]\n");
 	fprintf(out, "        [--segments] [--units <units>]\n\n");
+
 	for (i = 0; _stats_subcommands[i].name; i++)
 		fprintf(out, "\t%s %s\n", _stats_subcommands[i].name, _stats_subcommands[i].help);
+
 	fprintf(out, "<device> may be device name or -u <uuid> or "
 		     "-j <major> -m <minor>\n");
 	fprintf(out, "<fields> are comma-separated.  Use 'help -c' for list.\n");
@@ -4867,7 +4922,8 @@ static void _dmsetup_usage(FILE *out)
 	int i;
 
 	fprintf(out, "Usage:\n\n");
-	fprintf(out, DMSETUP_CMD_NAME " [--version] [-h|--help [-c|-C|--columns]]\n"
+	fprintf(out, "%s\n"
+		"        [--version] [-h|--help [-c|-C|--columns]]\n"
 		"        [-v|--verbose [-v|--verbose ...]]\n"
 		"        [--checks] [--manglename <mangling_mode>]\n"
 		"        [-r|--readonly] [--noopencount] [--nolockfs] [--inactive]\n"
@@ -4875,9 +4931,12 @@ static void _dmsetup_usage(FILE *out)
 		"        [-y|--yes] [--readahead [+]<sectors>|auto|none] [--retry]\n"
 		"        [-c|-C|--columns] [-o <fields>] [-O|--sort <sort_fields>]\n"
 		"        [-S|--select <selection>] [--nameprefixes] [--noheadings]\n"
-		"        [--separator <separator>]\n\n");
+		"        [--separator <separator>]\n\n",
+		_base_commands[_base_command].name);
+
 	for (i = 0; _dmsetup_commands[i].name; i++)
 		fprintf(out, "\t%s %s\n", _dmsetup_commands[i].name, _dmsetup_commands[i].help);
+
 	fprintf(out, "\n<device> may be device name or -u <uuid> or "
 		     "-j <major> -m <minor>\n");
 	fprintf(out, "<mangling_mode> is one of 'none', 'auto' and 'hex'.\n");
@@ -4892,23 +4951,30 @@ static void _dmsetup_usage(FILE *out)
 static void _losetup_usage(FILE *out)
 {
 	fprintf(out, "Usage:\n\n");
-	fprintf(out, LOSETUP_CMD_NAME " [-d|-a] [-e encryption] "
-		     "[-o offset] [-f|loop_device] [file]\n\n");
+	fprintf(out, "%s [-d|-a] [-e encryption] "
+		     "[-o offset] [-f|loop_device] [file]\n\n",
+		     _base_commands[_base_command].name);
 }
 
-static int _stats_help(CMD_ARGS)
+static void _usage(FILE *out)
 {
-	_stats_usage(stderr);
+	switch (_base_commands[_base_command].type) {
+	case DMSETUP_TYPE:
+		return _dmsetup_usage(out);
+	case LOSETUP_TYPE:
+		return _losetup_usage(out);
+	case STATS_TYPE:
+		return _stats_usage(out);
+	case DEVMAP_NAME_TYPE:
+		return _devmap_name_usage(out);
+	}
+}
 
-	/**
-	 * main() increments this to ensure reports are set up for
-	 * stats use so decrement that count here; if the counter is
-	 * still non-zero then the user explicitly requested the
-	 * columns help output.
-	 */
-	_switches[COLS_ARG]--;
+static int _stats_help(CMD_ARGS)
+{
+	_usage(stderr);
 
-	if (_switches[COLS_ARG]) {
+	if (_switches[COLS_ARG] || (argc && !strcmp(argv[0], "report"))) {
 		_switches[OPTIONS_ARG] = 1;
 		_string_args[OPTIONS_ARG] = (char *) "help";
 		_switches[SORT_ARG] = 0;
@@ -4917,19 +4983,20 @@ static int _stats_help(CMD_ARGS)
 			dm_report_free(_report);
 			_report = NULL;
 		}
+
 		(void) _report_init(cmd);
+		if (_report) {
+			dm_report_free(_report);
+			_report = NULL;
+		}
 	}
 
-	/* help text already output: don't repeat from main */
-	dm_report_free(_report);
-	_report = NULL;
-
 	return 1;
 }
 
 static int _dmsetup_help(CMD_ARGS)
 {
-	_dmsetup_usage(stderr);
+	_usage(stderr);
 
 	if (_switches[COLS_ARG]) {
 		_switches[OPTIONS_ARG] = 1;
@@ -4941,6 +5008,10 @@ static int _dmsetup_help(CMD_ARGS)
 			_report = NULL;
 		}
 		(void) _report_init(cmd);
+		if (_report) {
+			dm_report_free(_report);
+			_report = NULL;
+		}
 	}
 
 	return 1;
@@ -4972,11 +5043,6 @@ static int _stats(CMD_ARGS)
 {
 	const struct command *stats_cmd;
 
-	if (_switches[HELP_ARG]) {
-		stats_cmd = _find_stats_subcommand("help");
-		goto doit;
-	}
-
 	if (!(stats_cmd = _find_stats_subcommand(subcommand))) {
 		log_error("Unknown stats command.");
 		_stats_help(stats_cmd, NULL, argc, argv, NULL, multiple_devices);
@@ -4993,7 +5059,6 @@ static int _stats(CMD_ARGS)
 		return 0;
 	}
 
-doit:
 	if (!stats_cmd->fn(stats_cmd, NULL, argc, argv, NULL, multiple_devices))
 		return 0;
 
@@ -5249,29 +5314,29 @@ static int _process_losetup_switches(const char *base, int *argcp, char ***argvp
 
 	if (!*argcp) {
 		fprintf(stderr, "%s: Please specify loop_device.\n", base);
-		_losetup_usage(stderr);
+		_usage(stderr);
 		return 0;
 	}
 
 	if (!(device_name = parse_loop_device_name((*argvp)[0], dev_dir))) {
 		fprintf(stderr, "%s: Could not parse loop_device %s\n",
 			base, (*argvp)[0]);
-		_losetup_usage(stderr);
+		_usage(stderr);
 		return 0;
 	}
 
 	if (delete) {
-		*argcp = 2;
+		*argcp = 1;
 
-		(*argvp)[1] = device_name;
-		(*argvp)[0] = (char *) "remove";
+		(*argvp)[0] = device_name;
+		_command = "remove";
 
 		return 1;
 	}
 
 	if (*argcp != 2) {
 		fprintf(stderr, "%s: Too few arguments\n", base);
-		_losetup_usage(stderr);
+		_usage(stderr);
 		dm_free(device_name);
 		return 0;
 	}
@@ -5280,7 +5345,7 @@ static int _process_losetup_switches(const char *base, int *argcp, char ***argvp
 	if (!(loop_file = _get_abspath((*argvp)[(find) ? 0 : 1]))) {
 		fprintf(stderr, "%s: Could not parse loop file name %s\n",
 			base, (*argvp)[1]);
-		_losetup_usage(stderr);
+		_usage(stderr);
 		dm_free(device_name);
 		return 0;
 	}
@@ -5294,8 +5359,9 @@ static int _process_losetup_switches(const char *base, int *argcp, char ***argvp
 	}
 	_switches[TABLE_ARG]++;
 
-	(*argvp)[0] = (char *) "create";
-	(*argvp)[1] = device_name ;
+	_command = "create";
+	(*argvp)[0] = device_name ;
+	*argcp = 1;
 
 	return 1;
 }
@@ -5349,9 +5415,7 @@ static int _process_switches(int *argcp, char ***argvp, const char *dev_dir)
 	const char *base;
 	char *namebase, *s;
 	static int ind;
-	int c, r;
-	/* "stats" command and sub-command when run as 'dmstats'. */
-	char *stats_p = NULL, *stats_c = NULL;
+	int c, r, i;
 
 #ifdef HAVE_GETOPTLONG
 	static struct option long_options[] = {
@@ -5432,10 +5496,21 @@ static int _process_switches(int *argcp, char ***argvp, const char *dev_dir)
 		fprintf(stderr, "Failed to duplicate name.\n");
 		return 0;
 	}
+
 	base = dm_basename(namebase);
 
-	if (!strcmp(base, "devmap_name")) {
-		free(namebase);
+	i = 0;
+	do {
+		if (!strcmp(base, _base_commands[i].name)) {
+			_base_command = _base_commands[i].command;
+			_base_command_type = _base_commands[i].type;
+			break;
+		}
+	} while (++i < _num_base_commands);
+
+	free(namebase);
+
+	if (_base_command_type == DEVMAP_NAME_TYPE) {
 		_switches[COLS_ARG]++;
 		_switches[NOHEADINGS_ARG]++;
 		_switches[OPTIONS_ARG]++;
@@ -5455,28 +5530,22 @@ static int _process_switches(int *argcp, char ***argvp, const char *dev_dir)
 			*argcp -= 1;
 			*argvp += 1;
 		} else {
-			fprintf(stderr, "Usage: devmap_name <major> <minor>\n");
+			_usage(stderr);
 			return 0;
 		}
 
-		(*argvp)[0] = (char *) "info";
+		_command = "info";
+		(*argvp)++;
+		(*argcp)--;
+
 		return 1;
 	}
 
-	if (!strcmp(base, LOSETUP_CMD_NAME) || !strcmp(base, DMLOSETUP_CMD_NAME)){
-		r = _process_losetup_switches(base, argcp, argvp, dev_dir);
-		free(namebase);
+	if (_base_command_type == LOSETUP_TYPE) {
+		r = _process_losetup_switches(_base_commands[_base_command].name, argcp, argvp, dev_dir);
 		return r;
 	}
 
-	if (!strcmp(base, DMSTATS_CMD_NAME)) {
-		/* save the offset to the 'stats' in 'dmstats' */
-		stats_p = (*argvp)[0] + strlen(namebase) - strlen(base) + 2;
-		stats_c = (*argvp)[1]; /* stats command */
-	}
-
-	free(namebase);
-
 	optarg = 0;
 	optind = OPTIND_INIT;
 	while ((ind = -1, c = GETOPTLONG_FN(*argcp, *argvp, "cCfG:hj:m:M:no:O:rS:u:U:vy",
@@ -5608,7 +5677,7 @@ static int _process_switches(int *argcp, char ***argvp, const char *dev_dir)
 			_switches[DEFERRED_ARG]++;
 		if (ind == EXEC_ARG) {
 			_switches[EXEC_ARG]++;
-			_command = optarg;
+			_command_to_exec = optarg;
 		}
 		if (ind == TARGET_ARG) {
 			_switches[TARGET_ARG]++;
@@ -5725,12 +5794,20 @@ static int _process_switches(int *argcp, char ***argvp, const char *dev_dir)
 	*argvp += optind;
 	*argcp -= optind;
 
-	/* preserve sub-command in argv[0] */
-	if (stats_p) {
-		(*argvp)--;
-		(*argcp)++;
-		(*argvp)[0] = stats_p;
-		(*argvp)[1] = stats_c;
+	if (!*argcp)
+		_command = NULL;
+	else if (!strcmp((*argvp)[0], "stats")) {
+		_base_command = DMSETUP_STATS_CMD;
+		_base_command_type = STATS_TYPE;
+		_command = "stats";
+		(*argvp)++;
+		(*argcp)--;
+	} else if (_base_command == DMSTATS_CMD) {
+		_command = "stats";
+	} else if (*argcp) {
+		_command = (*argvp)[0];
+		(*argvp)++;
+		(*argcp)--;
 	}
 
 	return 1;
@@ -5738,15 +5815,14 @@ static int _process_switches(int *argcp, char ***argvp, const char *dev_dir)
 
 static int _perform_command_for_all_repeatable_args(CMD_ARGS)
 {
-	/* FIXME Shift args to remove argv[0] that fn is not allowed to access? */
 	do {
-		if (!cmd->fn(cmd, subcommand, argc--, argv++, NULL, multiple_devices)) {
+		if (!cmd->fn(cmd, subcommand, argc, argv++, NULL, multiple_devices)) {
 			fprintf(stderr, "Command failed\n");
-			return 1;
+			return 0;
 		}
-	} while (cmd->repeatable_cmd && argc > 1);
+	} while (cmd->repeatable_cmd && argc-- > 1);
 
-	return 0;
+	return 1;
 }
 
 static int _do_report_wait(void)
@@ -5778,50 +5854,54 @@ int main(int argc, char **argv)
 		goto out;
 	}
 
-	/* let stats do its own --help handling. */
-	if (_switches[HELP_ARG] && strcmp("stats", argv[0])) {
-		if ((cmd = _find_dmsetup_command("help")))
-			goto doit;
-		goto unknown;
+	if (_switches[HELP_ARG]) {
+		switch (_base_command_type) {
+		case STATS_TYPE:
+			if ((cmd = _find_stats_subcommand("help")))
+				goto doit;
+			goto unknown;
+		default:
+			if ((cmd = _find_dmsetup_command("help")))
+				goto doit;
+			goto unknown;
+		}
 	}
 
 	if (_switches[VERSION_ARG]) {
-		if ((cmd = _find_dmsetup_command("version")))
-			goto doit;
-		goto unknown;
+		switch (_base_command_type) {
+		case STATS_TYPE:
+			if ((cmd = _find_stats_subcommand("version")))
+				goto doit;
+			goto unknown;
+		default:
+			if ((cmd = _find_dmsetup_command("version")))
+				goto doit;
+			goto unknown;
+		}
 	}
 
-	if (argc == 0) {
-		_dmsetup_usage(stderr);
+	if (!_command) {
+		_usage(stderr);
 		goto out;
 	}
 
-	if (!(cmd = _find_dmsetup_command(argv[0]))) {
+	if (!(cmd = _find_dmsetup_command(_command))) {
 unknown:
 		fprintf(stderr, "Unknown command\n");
-		_dmsetup_usage(stderr);
+		_usage(stderr);
 		goto out;
 	}
 
-	if (argc < cmd->min_args + 1 ||
-	    (cmd->max_args >= 0 && argc > cmd->max_args + 1)) {
+	if (argc < cmd->min_args ||
+	    (cmd->max_args >= 0 && argc > cmd->max_args)) {
 		fprintf(stderr, "Incorrect number of arguments\n");
-		if (!strcmp(cmd->name, "stats"))
-			_stats_usage(stderr);
-		else
-			_dmsetup_usage(stderr);
+		_usage(stderr);
 		goto out;
 	}
 
 	if (!_switches[COLS_ARG] && !strcmp(cmd->name, "splitname"))
 		_switches[COLS_ARG]++;
 
-	/**
-	 * Unconditionally increment for "stats" commands; the only
-	 * command to not require this is non-columns "stats help".
-	 * In that case _stats_help will remove the extra count
-	 * before displaying the help message.
-	 */
 	if (!strcmp(cmd->name, "stats")) {
 		_switches[COLS_ARG]++;
 		if (!_switches[UNITS_ARG]) {
@@ -5865,7 +5945,7 @@ unknown:
 	 * dmsetup <command> <subcommand> [args...]
 	 */
 	if (cmd->has_subcommands) {
-		subcommand = argv[1];
+		subcommand = argv[0];
 		argc--, argv++;
 	}
 
@@ -5875,19 +5955,18 @@ unknown:
 			goto_out;
 
 doit:
-	multiple_devices = (cmd->repeatable_cmd && argc != 2 &&
-			    (argc != 1 || (!_switches[UUID_ARG] && !_switches[MAJOR_ARG])));
+	multiple_devices = (cmd->repeatable_cmd && argc != 1 &&
+			    (argc || (!_switches[UUID_ARG] && !_switches[MAJOR_ARG])));
 
 	do {
 		r = _perform_command_for_all_repeatable_args(cmd, subcommand, argc, argv, NULL, multiple_devices);
-
 		if (_report) {
 			/* only output headings for repeating reports */
-			if (_int_args[COUNT_ARG] != 1)
+			if (_int_args[COUNT_ARG] != 1 && !dm_report_is_empty(_report))
 				dm_report_column_headings(_report);
 			dm_report_output(_report);
 
-			if (_count > 1) {
+			if (_count > 1 && r) {
 				printf("\n");
 				/* wait for --interval and update timestamps */
 				if (!_do_report_wait())
@@ -5895,12 +5974,11 @@ doit:
 			}
 		}
 
-		if (r)
+		if (!r)
 			break;
 	} while (--_count);
 
 out:
-
 	if (_report)
 		dm_report_free(_report);
 


