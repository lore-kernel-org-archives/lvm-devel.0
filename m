From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 31 Jul 2015 15:28:06 +0000 (UTC)
Subject: master - dmsetup: Add _dmsetup to help and usage fns.
Message-ID: <20150731152806.249D860DAE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fef3cb3f21cba9e88add8ffd1aad8d6691c77109
Commit:        fef3cb3f21cba9e88add8ffd1aad8d6691c77109
Parent:        027fe112ecb75e46c671658e233ff353523e9ec3
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Jul 31 16:26:38 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Jul 31 16:26:38 2015 +0100

dmsetup: Add _dmsetup to help and usage fns.

Prepare for dmstats.
Adjust some text to avoid 80-char wrap.
---
 tools/dmsetup.c |   28 +++++++++++++++-------------
 1 files changed, 15 insertions(+), 13 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 6481288..b803e44 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -3052,17 +3052,18 @@ out:
 	return r;
 }
 
-static int _help(CMD_ARGS);
+static int _dmsetup_help(CMD_ARGS);
 
 /*
  * Dispatch table
  */
 static struct command _dmsetup_commands[] = {
-	{"help", "[-c|-C|--columns]", 0, 0, 0, _help},
-	{"create", "<dev_name> [-j|--major <major> -m|--minor <minor>]\n"
-	  "\t                  [-U|--uid <uid>] [-G|--gid <gid>] [-M|--mode <octal_mode>]\n"
-	  "\t                  [-u|uuid <uuid>] [{--addnodeonresume|--addnodeoncreate}]\n"
-	  "\t                  [--notable | --table <table> | <table_file>]",
+	{"help", "[-c|-C|--columns]", 0, 0, 0, _dmsetup_help},
+	{"create", "<dev_name>\n"
+	  "\t    [-j|--major <major> -m|--minor <minor>]\n"
+	  "\t    [-U|--uid <uid>] [-G|--gid <gid>] [-M|--mode <octal_mode>]\n"
+	  "\t    [-u|uuid <uuid>] [{--addnodeonresume|--addnodeoncreate}]\n"
+	  "\t    [--notable | --table <table> | <table_file>]",
 	 1, 2,0,  _create},
 	{"remove", "[-f|--force] [--deferred] <device>", 0, -1, 1, _remove},
 	{"remove_all", "[-f|--force]", 0, 0, 0,  _remove_all},
@@ -3095,13 +3096,14 @@ static struct command _dmsetup_commands[] = {
 	{NULL, NULL, 0, 0, 0, NULL}
 };
 
-static void _usage(FILE *out)
+static void _dmsetup_usage(FILE *out)
 {
 	int i;
 
 	fprintf(out, "Usage:\n\n");
 	fprintf(out, "dmsetup [--version] [-h|--help [-c|-C|--columns]]\n"
-		"        [--checks] [--manglename <mangling_mode>] [-v|--verbose [-v|--verbose ...]]\n"
+		"        [-v|--verbose [-v|--verbose ...]]\n"
+		"        [--checks] [--manglename <mangling_mode>]\n"
 		"        [-r|--readonly] [--noopencount] [--nolockfs] [--inactive]\n"
 		"        [--udevcookie [cookie]] [--noudevrules] [--noudevsync] [--verifyudev]\n"
 		"        [-y|--yes] [--readahead [+]<sectors>|auto|none] [--retry]\n"
@@ -3128,9 +3130,9 @@ static void _losetup_usage(FILE *out)
 		     "[-o offset] [-f|loop_device] [file]\n\n");
 }
 
-static int _help(CMD_ARGS)
+static int _dmsetup_help(CMD_ARGS)
 {
-	_usage(stderr);
+	_dmsetup_usage(stderr);
 
 	if (_switches[COLS_ARG]) {
 		_switches[OPTIONS_ARG] = 1;
@@ -3834,21 +3836,21 @@ int main(int argc, char **argv)
 	}
 
 	if (argc == 0) {
-		_usage(stderr);
+		_dmsetup_usage(stderr);
 		goto out;
 	}
 
 	if (!(cmd = _find_dmsetup_command(argv[0]))) {
 unknown:
 		fprintf(stderr, "Unknown command\n");
-		_usage(stderr);
+		_dmsetup_usage(stderr);
 		goto out;
 	}
 
 	if (argc < cmd->min_args + 1 ||
 	    (cmd->max_args >= 0 && argc > cmd->max_args + 1)) {
 		fprintf(stderr, "Incorrect number of arguments\n");
-		_usage(stderr);
+		_dmsetup_usage(stderr);
 		goto out;
 	}
 


