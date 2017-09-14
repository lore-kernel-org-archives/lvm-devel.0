From: Alasdair Kergon <agk@sourceware.org>
Date: Thu, 14 Sep 2017 18:41:45 -0400
Subject: master - dmsetup: Process -S to filter input device lists.
Message-ID: <201709142241.v8EMfjcJ012886@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d73eddcdc02420793c2287b6aa184dc8eb2dcef4
Commit:        d73eddcdc02420793c2287b6aa184dc8eb2dcef4
Parent:        8e8755319c8a8848b8bcd830a6341eccf750f798
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Sep 14 23:41:17 2017 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Sep 14 23:41:17 2017 +0100

dmsetup: Process -S to filter input device lists.

The following commands now pass the device list through a
--select|-S filter before processing:

suspend resume clear wipe_table remove deps status table
---
 WHATS_NEW_DM       |    1 +
 man/dmsetup.8_main |   16 ++++++++--------
 tools/dmsetup.c    |   48 ++++++++++++++++++++++++++++++++++++++----------
 3 files changed, 47 insertions(+), 18 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index a100689..5f71327 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.144 - 
 ======================================
+  Take -S with dmsetup suspend/resume/clear/wipe_table/remove/deps/status/table.
 
 Version 1.02.143 - 13th September 2017
 ======================================
diff --git a/man/dmsetup.8_main b/man/dmsetup.8_main
index 1e778ad..054746c 100644
--- a/man/dmsetup.8_main
+++ b/man/dmsetup.8_main
@@ -559,14 +559,14 @@ Set the table being loaded read-only.
 .BR -S | --select
 .IR selection
 .br
-Display only rows that match \fIselection\fP criteria. All rows are displayed
-with the additional "selected" column (\fB-o selected\fP) showing 1 if the row
-matches the \fIselection\fP and 0 otherwise. The selection criteria are defined
-by specifying column names and their valid values while making use of
-supported comparison operators. As a quick help and to see full list of
-column names that can be used in selection and the set of supported
-selection operators, check the output of \fBdmsetup\ info\ -c\ -S\ help\fP
-command.
+Process only items that match \fIselection\fP criteria.  If the command is
+producing report output, adding the "selected" column (\fB-o
+selected\fP) displays all rows and shows 1 if the row matches the
+\fIselection\fP and 0 otherwise. The selection criteria are defined by
+specifying column names and their valid values while making use of supported
+comparison operators. As a quick help and to see full list of column names that
+can be used in selection and the set of supported selection operators, check
+the output of \fBdmsetup\ info\ -c\ -S\ help\fP command.
 .
 .HP
 .BR --table
diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index d9532fb..5a9f006 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -275,6 +275,8 @@ static char _disp_units = 's';
 const char *_program_id = DM_STATS_PROGRAM_ID; /* program_id used for reports. */
 static uint64_t _statstype = 0; /* stats objects to report */
 static int _concise_output_produced = 0; /* Was any concise output already printed? */
+struct command;
+static const struct command *_selection_cmd = NULL; /* Command to run against each device select with -S */
 
 /* string names for stats object types */
 const char *_stats_types[] = {
@@ -308,7 +310,6 @@ static uint64_t _last_interval = 0; /* approx. measured interval in nsecs */
  * Commands
  */
 
-struct command;
 #define CMD_ARGS const struct command *cmd, const char *subcommand, int argc, char **argv, struct dm_names *names, int multiple_devices
 typedef int (*command_fn) (CMD_ARGS);
 
@@ -318,6 +319,7 @@ struct command {
 	int min_args;
 	int max_args;
 	int repeatable_cmd;	/* Repeat to process device list? */
+				/* 2 means --select is also supported */
 	int has_subcommands;	/* Command implements sub-commands. */
 	command_fn fn;
 };
@@ -861,6 +863,8 @@ static int _display_info_cols(struct dm_task *dmt, struct dm_info *info)
 	struct dmsetup_report_obj obj;
 	uint64_t walk_flags = _statstype;
 	int r = 0;
+	int selected;
+	char *device_name;
 
 	if (!info->exists) {
 		fprintf(stderr, "Device does not exist.\n");
@@ -891,8 +895,17 @@ static int _display_info_cols(struct dm_task *dmt, struct dm_info *info)
 			goto_out;
 
 	if (!(_report_type & (DR_STATS | DR_STATS_META))) {
-		if (!dm_report_object(_report, &obj))
+		/*
+		 * If _selection_cmd is set we are applying -S to some other command, so suppress 
+		 * output and run that other command if the device matches the criteria.
+		 */
+		if (!dm_report_object_is_selected(_report, &obj, _selection_cmd ? 0 : 1, &selected))
 			goto_out;
+		if (_selection_cmd && selected) {
+			device_name = dm_task_get_name(dmt);
+			if (!_selection_cmd->fn(_selection_cmd, NULL, 1, &device_name, NULL, 1))
+				goto_out;
+		}
 		r = 1;
 		goto out;
 	}
@@ -2177,6 +2190,11 @@ static int _error_device(CMD_ARGS)
 
 	name = names ? names->name : argv[0];
 
+	if (!name || !*name) {
+		printf("No device specified\n");
+		return_0;
+	}
+		
 	size = _get_device_size(name);
 
 	if (!(dmt = dm_task_create(DM_DEVICE_RELOAD)))
@@ -6161,24 +6179,24 @@ static struct command _dmsetup_commands[] = {
 	  "\t    [--readahead {[+]<sectors>|auto|none}]\n"
 	  "\t    [-n|--notable|--table {<table>|<table_file>}]\n"
 	  "\tcreate --concise [<concise_device_spec_list>]", 0, 2, 0, 0, _create},
-	{"remove", "[--deferred] [-f|--force] [--retry] <device>...", 0, -1, 1, 0, _remove},
+	{"remove", "[--deferred] [-f|--force] [--retry] <device>...", 0, -1, 2, 0, _remove},
 	{"remove_all", "[-f|--force]", 0, 0, 0, 0, _remove_all},
-	{"suspend", "[--noflush] [--nolockfs] <device>...", 0, -1, 1, 0, _suspend},
+	{"suspend", "[--noflush] [--nolockfs] <device>...", 0, -1, 2, 0, _suspend},
 	{"resume", "[--noflush] [--nolockfs] <device>...\n"
 	  "\t       [--addnodeonresume|--addnodeoncreate]\n"
-	  "\t       [--readahead {[+]<sectors>|auto|none}]", 0, -1, 1, 0, _resume},
+	  "\t       [--readahead {[+]<sectors>|auto|none}]", 0, -1, 2, 0, _resume},
 	  {"load", "<device> [<table>|<table_file>]", 0, 2, 0, 0, _load},
-	{"clear", "<device>", 0, -1, 1, 0, _clear},
+	{"clear", "<device>", 0, -1, 2, 0, _clear},
 	{"reload", "<device> [<table>|<table_file>]", 0, 2, 0, 0, _load},
-	{"wipe_table", "[-f|--force] [--noflush] [--nolockfs] <device>...", 1, -1, 1, 0, _error_device},
+	{"wipe_table", "[-f|--force] [--noflush] [--nolockfs] <device>...", 0, -1, 2, 0, _error_device},
 	{"rename", "<device> [--setuuid] <new_name_or_uuid>", 1, 2, 0, 0, _rename},
 	{"message", "<device> <sector> <message>", 2, -1, 0, 0, _message},
 	{"ls", "[--target <target_type>] [--exec <command>] [-o <options>] [--tree]", 0, 0, 0, 0, _ls},
 	{"info", "[<device>...]", 0, -1, 1, 0, _info},
-	{"deps", "[-o <options>] [<device>...]", 0, -1, 1, 0, _deps},
+	{"deps", "[-o <options>] [<device>...]", 0, -1, 2, 0, _deps},
 	{"stats", "<command> [<options>] [<device>...]", 1, -1, 1, 1, _stats},
-	{"status", "[<device>...] [--noflush] [--target <target_type>]", 0, -1, 1, 0, _status},
-	{"table", "[<device>...] [--concise] [--target <target_type>] [--showkeys]", 0, -1, 1, 0, _status},
+	{"status", "[<device>...] [--noflush] [--target <target_type>]", 0, -1, 2, 0, _status},
+	{"table", "[<device>...] [--concise] [--target <target_type>] [--showkeys]", 0, -1, 2, 0, _status},
 	{"wait", "<device> [<event_nr>] [--noflush]", 0, 2, 0, 0, _wait},
 	{"mknodes", "[<device>...]", 0, -1, 1, 0, _mknodes},
 	{"mangle", "[<device>...]", 0, -1, 1, 0, _mangle},
@@ -7326,6 +7344,16 @@ unknown:
 	/* Default to success */
 	ret = 0;
 
+	/* When -S is given, store the real command for later and run "info -c" first */
+	if (_switches[SELECT_ARG] && (cmd->repeatable_cmd == 2)) {
+		_selection_cmd = cmd;
+		_switches[COLS_ARG] = 1;
+		if (!(cmd = _find_dmsetup_command("info"))) {
+			fprintf(stderr, "Internal error finding dmsetup info command struct.\n");
+			goto out;
+		}
+	}
+
 	if (_switches[COLS_ARG]) {
 		if (!_report_init(cmd, subcommand))
 			ret = 1;


