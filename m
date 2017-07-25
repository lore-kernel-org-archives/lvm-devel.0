From: Alasdair Kergon <agk@sourceware.org>
Date: Mon, 24 Jul 2017 20:27:21 -0400
Subject: master - dmsetup: Add concise table output format.
Message-ID: <201707250027.v6P0RLhb010658@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5fd7c0aa3340a58318d0bcfb0ae5aeb9924881f6
Commit:        5fd7c0aa3340a58318d0bcfb0ae5aeb9924881f6
Parent:        ca71ad0d5025d2d01eb9666368c1da7db3c9c7ce
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Jul 25 01:13:14 2017 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Jul 25 01:13:14 2017 +0100

dmsetup: Add concise table output format.

Create a new table output format that concisely shows multiple devices
on one line.

dmsetup table --concise [device...]

<dev_name>,<uuid>,<flags>[,<table>]*[;<dev_name>,<uuid>,<flags>[,<table>]*]*

Table lines are separated by commas.
Devices are separated by semi-colons.
Flags is currently 'ro' or 'rw' (and might be extended in a
yet-to-be-defined way in future).
Any comma, semi-colon or backslash within a field is quoted by a
preceding backslash.

The format can later be supplied as input to dmsetup or even to the
booting kernel as an alternative way to set up devices.

Based on patches submitted by
Enric Balletbo i Serra <enric.balletbo@collabora.com>.
---
 WHATS_NEW_DM       |    1 +
 man/dmsetup.8_main |    5 +++
 tools/dmsetup.c    |   74 ++++++++++++++++++++++++++++++++++++++++++++-------
 3 files changed, 69 insertions(+), 11 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 7007c95..c41bcfd 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.143 - 
 =================================
+  Introduce single-line concise table output format: dmsetup table --concise
 
 Version 1.02.142 - 20th July 2017
 =================================
diff --git a/man/dmsetup.8_main b/man/dmsetup.8_main
index 4421882..1d0219f 100644
--- a/man/dmsetup.8_main
+++ b/man/dmsetup.8_main
@@ -269,6 +269,7 @@ dmsetup \(em low level logical volume management
 .de CMD_TABLE
 .  ad l
 .  BR table
+.  RB [ --concise ]
 .  RB [ --target
 .  IR target_type ]
 .  RB [ --showkeys ]
@@ -824,6 +825,10 @@ Real encryption keys are suppressed in the table output for the crypt
 target unless the \fB--showkeys\fP parameter is supplied. Kernel key
 references prefixed with \fB:\fP are not affected by the parameter and get
 displayed always.
+With \fB--concise\fP, the output is presented concisely on a single line.
+Commas then separate the name, uuid, flags ('ro' or 'rw') and the table
+(if present). Semi-colons separate devices. Backslashes escape any commas,
+semi-colons or backslashes.
 .
 .HP
 .CMD_TARGETS
diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 803ae56..3514fc5 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -163,6 +163,7 @@ enum {
 	AREA_ARG,
 	AREAS_ARG,
 	AREA_SIZE_ARG,
+	CONCISE_ARG,
 	BOUNDS_ARG,
 	CHECKS_ARG,
 	CLEAR_ARG,
@@ -273,6 +274,7 @@ static uint64_t _disp_factor = 512; /* display sizes in sectors */
 static char _disp_units = 's';
 const char *_program_id = DM_STATS_PROGRAM_ID; /* program_id used for reports. */
 static uint64_t _statstype = 0; /* stats objects to report */
+static int _concise_output_produced = 0; /* Was any concise output already printed? */
 
 /* string names for stats object types */
 const char *_stats_types[] = {
@@ -2114,6 +2116,19 @@ static int _exec_command(const char *name)
 	return 1;
 }
 
+/*
+ * Print string s using a backslash to quote each character that has a special
+ * meaning in the concise format - comma, semi-colon and backslash.
+ */
+static void _print_string_quoted(const char *s)
+{
+	while (*s) {
+		if (strchr(",;\\", *s))
+			putchar('\\');
+		putchar(*s++);
+	}
+}
+
 static int _status(CMD_ARGS)
 {
 	int r = 0;
@@ -2126,6 +2141,7 @@ static int _status(CMD_ARGS)
 	const char *name = NULL;
 	int matched = 0;
 	int ls_only = 0;
+	int use_concise = 0;
 	struct dm_info info;
 
 	if (names)
@@ -2136,9 +2152,12 @@ static int _status(CMD_ARGS)
 		name = argv[0];
 	}
 
-	if (!strcmp(cmd->name, "table"))
+	if (!strcmp(cmd->name, "table")) {
 		cmdno = DM_DEVICE_TABLE;
-	else
+		/* --concise only applies to 'table' */
+		if (_switches[CONCISE_ARG])
+			use_concise = 1;
+	} else
 		cmdno = DM_DEVICE_STATUS;
 
 	if (!strcmp(cmd->name, "ls"))
@@ -2179,6 +2198,7 @@ static int _status(CMD_ARGS)
 		if (_switches[TARGET_ARG] &&
 		    (!target_type || strcmp(target_type, _target)))
 			continue;
+
 		if (ls_only) {
 			if (!_switches[EXEC_ARG] || !_command_to_exec ||
 			    _switches[VERBOSE_ARG])
@@ -2186,10 +2206,28 @@ static int _status(CMD_ARGS)
 			next = NULL;
 		} else if (!_switches[EXEC_ARG] || !_command_to_exec ||
 			   _switches[VERBOSE_ARG]) {
-			if (!matched && _switches[VERBOSE_ARG])
-				_display_info(dmt);
-			if (multiple_devices && !_switches[VERBOSE_ARG])
-				printf("%s: ", name);
+			if (!use_concise) {
+				if (!matched && _switches[VERBOSE_ARG])
+					_display_info(dmt);
+				if (multiple_devices && !_switches[VERBOSE_ARG])
+					printf("%s: ", name);
+			} else if (!matched) {
+				/*
+ 				 * Before first target of device in concise output,
+				 * print basic device information in the appropriate format.
+				 * Separate devices by a semi-colon.
+				 */
+				if (_concise_output_produced)
+					putchar(';');
+				_concise_output_produced = 1;
+
+				_print_string_quoted(name);
+				putchar(',');
+				_print_string_quoted(dm_task_get_uuid(dmt));
+				putchar(',');
+				printf("%s", info.read_only ? "ro" : "rw");
+			}
+			/* Next print any target-specific information */
 			if (target_type) {
 				/* Suppress encryption key */
 				if (!_switches[SHOWKEYS_ARG] &&
@@ -2210,15 +2248,22 @@ static int _status(CMD_ARGS)
 						while (*c && *c != ' ')
 							*c++ = '0';
 				}
-				printf(FMTu64 " " FMTu64 " %s %s",
-				       start, length, target_type, params);
+				if (use_concise)
+					putchar(',');
+				printf(FMTu64 " " FMTu64 " %s ", start, length, target_type);
+				if (use_concise)
+					_print_string_quoted(params);
+				else
+					printf("%s", params);
 			}
-			putchar('\n');
+			/* --concise places all devices on a single output line */
+			if (!use_concise)
+				putchar('\n');
 		}
 		matched = 1;
 	} while (next);
 
-	if (multiple_devices && _switches[VERBOSE_ARG] && matched && !ls_only)
+	if (multiple_devices && _switches[VERBOSE_ARG] && matched && !ls_only && (!use_concise || _switches[VERBOSE_ARG] > 1))
 		putchar('\n');
 
 	if (matched && _switches[EXEC_ARG] && _command_to_exec && !_exec_command(name))
@@ -5904,7 +5949,7 @@ static struct command _dmsetup_commands[] = {
 	{"deps", "[-o <options>] [<device>...]", 0, -1, 1, 0, _deps},
 	{"stats", "<command> [<options>] [<device>...]", 1, -1, 1, 1, _stats},
 	{"status", "[<device>...] [--noflush] [--target <target_type>]", 0, -1, 1, 0, _status},
-	{"table", "[<device>...] [--target <target_type>] [--showkeys]", 0, -1, 1, 0, _status},
+	{"table", "[<device>...] [--concise] [--target <target_type>] [--showkeys]", 0, -1, 1, 0, _status},
 	{"wait", "<device> [<event_nr>] [--noflush]", 0, 2, 0, 0, _wait},
 	{"mknodes", "[<device>...]", 0, -1, 1, 0, _mknodes},
 	{"mangle", "[<device>...]", 0, -1, 1, 0, _mangle},
@@ -6473,6 +6518,7 @@ static int _process_switches(int *argcp, char ***argvp, const char *dev_dir)
 		{"checks", 0, &ind, CHECKS_ARG},
 		{"clear", 0, &ind, CLEAR_ARG},
 		{"columns", 0, &ind, COLS_ARG},
+		{"concise", 0, &ind, CONCISE_ARG},
 		{"count", 1, &ind, COUNT_ARG},
 		{"deferred", 0, &ind, DEFERRED_ARG},
 		{"select", 1, &ind, SELECT_ARG},
@@ -6637,6 +6683,8 @@ static int _process_switches(int *argcp, char ***argvp, const char *dev_dir)
 			return_0;
 		if (c == 'h' || ind == HELP_ARG)
 			_switches[HELP_ARG]++;
+		if (ind == CONCISE_ARG)
+			_switches[CONCISE_ARG]++;
 		if (ind == BOUNDS_ARG) {
 			_switches[BOUNDS_ARG]++;
 			_string_args[BOUNDS_ARG] = optarg;
@@ -7073,6 +7121,10 @@ doit:
 
 	do {
 		r = _perform_command_for_all_repeatable_args(cmd, subcommand, argc, argv, NULL, multiple_devices);
+		if (_concise_output_produced) {
+			putchar('\n');
+			fflush(stdout);
+		}
 		if (_report) {
 			/* only output headings for repeating reports */
 			if (_int_args[COUNT_ARG] != 1 && !dm_report_is_empty(_report))


