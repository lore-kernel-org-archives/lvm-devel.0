From: David Teigland <teigland@sourceware.org>
Date: Thu, 27 Apr 2017 15:25:06 -0400
Subject: master - commands: improve syntax suggestion when no command is found
Message-ID: <201704271925.v3RJP6cN016351@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=86b9c23dbe4a5033eea6667c0274655e7c0c8e68
Commit:        86b9c23dbe4a5033eea6667c0274655e7c0c8e68
Parent:        4f9ff14508084789c731e99d8921c052da694319
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Apr 27 14:21:01 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Apr 27 14:21:01 2017 -0500

commands: improve syntax suggestion when no command is found

The logic for suggesting the nearest valid command syntax
was missing the simplest case.  If a command has only one
valid syntax, that is the one we should suggest.  (We were
suggesting nothing in this case.)
---
 tools/lvmcmdline.c |   18 +++++++++++++++++-
 1 files changed, 17 insertions(+), 1 deletions(-)

diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 37e9ef8..c0c81ba 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1516,6 +1516,7 @@ static struct command *_find_command(struct cmd_context *cmd, const char *path,
 	int match_required, match_ro, match_rp, match_type, match_unused, mismatch_required;
 	int best_i = 0, best_required = 0, best_type = 0, best_unused = 0;
 	int close_i = 0, close_ro = 0, close_type = 0;
+	int only_i = 0;
 	int temp_unused_options[MAX_UNUSED_COUNT];
 	int temp_unused_count;
 	int best_unused_options[MAX_UNUSED_COUNT] = { 0 };
@@ -1525,12 +1526,23 @@ static struct command *_find_command(struct cmd_context *cmd, const char *path,
 	int i, j;
 	int opt_enum, opt_i;
 	int accepted, count;
+	int variants = 0;
 
 	name = last_path_component(path);
 
+	/* factor_common_options() is only for usage, so cname->variants is not set. */
 	for (i = 0; i < COMMAND_COUNT; i++) {
 		if (strcmp(name, commands[i].name))
 			continue;
+		variants++;
+	}
+
+	for (i = 0; i < COMMAND_COUNT; i++) {
+		if (strcmp(name, commands[i].name))
+			continue;
+
+		if (variants == 1)
+			only_i = i;
 
 		/* For help and version just return the first entry with matching name. */
 		if (arg_is_set(cmd, help_ARG) || arg_is_set(cmd, help2_ARG) || arg_is_set(cmd, longhelp_ARG) || arg_is_set(cmd, version_ARG))
@@ -1701,7 +1713,11 @@ static struct command *_find_command(struct cmd_context *cmd, const char *path,
 	if (!best_required) {
 		/* cmd did not have all the required opt/pos args of any command */
 		log_error("No command with matching syntax recognised.  Run '%s --help' for more information.", name);
-		if (close_ro) {
+
+		if (only_i) {
+			log_warn("Correct command syntax is:");
+			print_usage(&_cmdline.commands[only_i], 0, 0);
+		} else if (close_ro) {
 			log_warn("Nearest similar command has syntax:");
 			print_usage(&_cmdline.commands[close_i], 0, 0);
 		}


