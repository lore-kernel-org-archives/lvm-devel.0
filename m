From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 31 Jul 2015 18:13:49 +0000 (UTC)
Subject: master - dmsetup: Allow commands to have subcommands.
Message-ID: <20150731181349.26E0C60DF2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=649c9d47199feddf7f5b65b5dbe12918ba2b383b
Commit:        649c9d47199feddf7f5b65b5dbe12918ba2b383b
Parent:        51f89f2fbdabc3b1800a1fd5ba4c7136ada0f9d3
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Jul 31 19:09:31 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Jul 31 19:09:31 2015 +0100

dmsetup: Allow commands to have subcommands.

No commands set has_subcommands yet.

Move multiple device loop to separate function because we'll
soon want to call it repeatedly.

(Based on patch from bmr.)
---
 tools/dmsetup.c |   94 ++++++++++++++++++++++++++++++++----------------------
 1 files changed, 56 insertions(+), 38 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 10bf3c6..f36119f 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -197,6 +197,7 @@ struct command {
 	int min_args;
 	int max_args;
 	int repeatable_cmd;	/* Repeat to process device list? */
+	int has_subcommands;	/* Command implements sub-commands. */
 	command_fn fn;
 };
 
@@ -3058,42 +3059,42 @@ static int _dmsetup_help(CMD_ARGS);
  * Dispatch table
  */
 static struct command _dmsetup_commands[] = {
-	{"help", "[-c|-C|--columns]", 0, 0, 0, _dmsetup_help},
+	{"help", "[-c|-C|--columns]", 0, 0, 0, 0, _dmsetup_help},
 	{"create", "<dev_name>\n"
 	  "\t    [-j|--major <major> -m|--minor <minor>]\n"
 	  "\t    [-U|--uid <uid>] [-G|--gid <gid>] [-M|--mode <octal_mode>]\n"
 	  "\t    [-u|uuid <uuid>] [{--addnodeonresume|--addnodeoncreate}]\n"
 	  "\t    [--notable | --table <table> | <table_file>]",
-	 1, 2,0,  _create},
-	{"remove", "[-f|--force] [--deferred] <device>", 0, -1, 1, _remove},
-	{"remove_all", "[-f|--force]", 0, 0, 0,  _remove_all},
-	{"suspend", "[--noflush] <device>", 0, -1, 1, _suspend},
-	{"resume", "<device> [{--addnodeonresume|--addnodeoncreate}]", 0, -1, 1, _resume},
-	{"load", "<device> [<table_file>]", 0, 2, 0, _load},
-	{"clear", "<device>", 0, -1, 1, _clear},
-	{"reload", "<device> [<table_file>]", 0, 2, 0, _load},
-	{"wipe_table", "<device>", 0, -1, 1, _error_device},
-	{"rename", "<device> [--setuuid] <new_name_or_uuid>", 1, 2, 0, _rename},
-	{"message", "<device> <sector> <message>", 2, -1, 0, _message},
-	{"ls", "[--target <target_type>] [--exec <command>] [-o options] [--tree]", 0, 0, 0, _ls},
-	{"info", "[<device>]", 0, -1, 1, _info},
-	{"deps", "[-o options] [<device>]", 0, -1, 1, _deps},
-	{"status", "[<device>] [--noflush] [--target <target_type>]", 0, -1, 1, _status},
-	{"table", "[<device>] [--target <target_type>] [--showkeys]", 0, -1, 1, _status},
-	{"wait", "<device> [<event_nr>] [--noflush]", 0, 2, 0, _wait},
-	{"mknodes", "[<device>]", 0, -1, 1, _mknodes},
-	{"mangle", "[<device>]", 0, -1, 1, _mangle},
-	{"udevcreatecookie", "", 0, 0, 0, _udevcreatecookie},
-	{"udevreleasecookie", "[<cookie>]", 0, 1, 0, _udevreleasecookie},
-	{"udevflags", "<cookie>", 1, 1, 0, _udevflags},
-	{"udevcomplete", "<cookie>", 1, 1, 0, _udevcomplete},
-	{"udevcomplete_all", "<age_in_minutes>", 0, 1, 0, _udevcomplete_all},
-	{"udevcookies", "", 0, 0, 0, _udevcookies},
-	{"targets", "", 0, 0, 0, _targets},
-	{"version", "", 0, 0, 0, _version},
-	{"setgeometry", "<device> <cyl> <head> <sect> <start>", 5, 5, 0, _setgeometry},
-	{"splitname", "<device> [<subsystem>]", 1, 2, 0, _splitname},
-	{NULL, NULL, 0, 0, 0, NULL}
+	 1, 2,0,  0, _create},
+	{"remove", "[-f|--force] [--deferred] <device>", 0, -1, 1, 0, _remove},
+	{"remove_all", "[-f|--force]", 0, 0, 0,  0, _remove_all},
+	{"suspend", "[--noflush] <device>", 0, -1, 1, 0, _suspend},
+	{"resume", "<device> [{--addnodeonresume|--addnodeoncreate}]", 0, -1, 1, 0, _resume},
+	{"load", "<device> [<table_file>]", 0, 2, 0, 0, _load},
+	{"clear", "<device>", 0, -1, 1, 0, _clear},
+	{"reload", "<device> [<table_file>]", 0, 2, 0, 0, _load},
+	{"wipe_table", "<device>", 0, -1, 1, 0, _error_device},
+	{"rename", "<device> [--setuuid] <new_name_or_uuid>", 1, 2, 0, 0, _rename},
+	{"message", "<device> <sector> <message>", 2, -1, 0, 0, _message},
+	{"ls", "[--target <target_type>] [--exec <command>] [-o options] [--tree]", 0, 0, 0, 0, _ls},
+	{"info", "[<device>]", 0, -1, 1, 0, _info},
+	{"deps", "[-o options] [<device>]", 0, -1, 1, 0, _deps},
+	{"status", "[<device>] [--noflush] [--target <target_type>]", 0, -1, 1, 0, _status},
+	{"table", "[<device>] [--target <target_type>] [--showkeys]", 0, -1, 1, 0, _status},
+	{"wait", "<device> [<event_nr>] [--noflush]", 0, 2, 0, 0, _wait},
+	{"mknodes", "[<device>]", 0, -1, 1, 0, _mknodes},
+	{"mangle", "[<device>]", 0, -1, 1, 0, _mangle},
+	{"udevcreatecookie", "", 0, 0, 0, 0, _udevcreatecookie},
+	{"udevreleasecookie", "[<cookie>]", 0, 1, 0, 0, _udevreleasecookie},
+	{"udevflags", "<cookie>", 1, 1, 0, 0, _udevflags},
+	{"udevcomplete", "<cookie>", 1, 1, 0, 0, _udevcomplete},
+	{"udevcomplete_all", "<age_in_minutes>", 0, 1, 0, 0, _udevcomplete_all},
+	{"udevcookies", "", 0, 0, 0, 0, _udevcookies},
+	{"targets", "", 0, 0, 0, 0, _targets},
+	{"version", "", 0, 0, 0, 0, _version},
+	{"setgeometry", "<device> <cyl> <head> <sect> <start>", 5, 5, 0, 0, _setgeometry},
+	{"splitname", "<device> [<subsystem>]", 1, 2, 0, 0, _splitname},
+	{NULL, NULL, 0, 0, 0, 0, NULL}
 };
 
 static void _dmsetup_usage(FILE *out)
@@ -3800,11 +3801,25 @@ static int _process_switches(int *argc, char ***argv, const char *dev_dir)
 	return 1;
 }
 
+static int _perform_command_for_all_repeatable_args(CMD_ARGS)
+{
+	/* FIXME Shift args to remove argv[0] that fn is not allowed to access? */
+	do {
+		if (!cmd->fn(cmd, subcommand, argc--, argv++, NULL, multiple_devices)) {
+			fprintf(stderr, "Command failed\n");
+			return 1;
+		}
+	} while (cmd->repeatable_cmd && argc > 1);
+
+	return 0;
+}
+
 int main(int argc, char **argv)
 {
 	int r = 1;
 	const char *dev_dir;
 	const struct command *cmd;
+	const char *subcommand = NULL;
 	int multiple_devices;
 
 	(void) setlocale(LC_ALL, "");
@@ -3873,17 +3888,20 @@ unknown:
 		goto out;
 	#endif
 
+	/*
+	 * Extract subcommand?
+	 * dmsetup <command> <subcommand> [args...]
+	 */
+	if (cmd->has_subcommands) {
+		subcommand = argv[1];
+		argc--, argv++;
+	}
+
       doit:
 	multiple_devices = (cmd->repeatable_cmd && argc != 2 &&
 			    (argc != 1 || (!_switches[UUID_ARG] && !_switches[MAJOR_ARG])));
-	do {
-		if (!cmd->fn(cmd, NULL, argc--, argv++, NULL, multiple_devices)) {
-			fprintf(stderr, "Command failed\n");
-			goto out;
-		}
-	} while (cmd->repeatable_cmd && argc > 1);
 
-	r = 0;
+	r = _perform_command_for_all_repeatable_args(cmd, subcommand, argc, argv, NULL, multiple_devices);
 
 out:
 	if (_report) {


