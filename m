From: David Teigland <teigland@sourceware.org>
Date: Tue, 11 Apr 2017 11:22:05 -0400
Subject: master - commands: check required option value when matching command
Message-ID: <201704111522.v3BFM5pE029564@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a4f07b701a009aba2ceca7fdb4ef880505ad54c3
Commit:        a4f07b701a009aba2ceca7fdb4ef880505ad54c3
Parent:        a14a8cef2ff1ae5c9c946bde5a885667288e24d3
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Apr 10 13:41:47 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Apr 10 13:41:47 2017 -0500

commands: check required option value when matching command

A command def can include a specific constant option value,
but the value was not being checked for optional opts.

e.g. this is an incorrect command and does not match any
command defs:

lvconvert --type cache --cachepool vg/lv

However, it was mistakely being matched to this cmd def,
where the required options match, but the optional options
do not:

lonvert --cachepool LV_linear_striped_raid_cachepool
OO: --type cache-pool, ...

The optional options were mistakely considered matching
because 'cache' and 'cache-pool' were not being compared.
---
 tools/lvmcmdline.c |   31 ++++++++++++++++++++++++++++---
 1 files changed, 28 insertions(+), 3 deletions(-)

diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 280a052..3626b1b 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1338,6 +1338,25 @@ static int _opt_synonym_is_set(struct cmd_context *cmd, int opt_std)
 	return opt_syn && arg_is_set(cmd, opt_syn);
 }
 
+static int _command_optional_opt_matches(struct cmd_context *cmd, int ci, int oo)
+{
+	int opt_enum = commands[ci].optional_opt_args[oo].opt;
+
+	if (val_bit_is_set(commands[ci].optional_opt_args[oo].def.val_bits, conststr_VAL)) {
+		if (!strcmp(commands[ci].optional_opt_args[oo].def.str, arg_str_value(cmd, opt_enum, "")))
+			return 1;
+		return 0;
+	}
+
+	if (val_bit_is_set(commands[ci].optional_opt_args[oo].def.val_bits, constnum_VAL)) {
+		if (commands[ci].optional_opt_args[oo].def.num == arg_int_value(cmd, opt_enum, 0))
+			return 1;
+		return 0;
+	}
+
+	return 1;
+}
+
 static int _command_ignore_opt_matches(struct cmd_context *cmd, int ci, int io)
 {
 	int opt_enum = commands[ci].ignore_opt_args[io].opt;
@@ -1625,7 +1644,8 @@ static struct command *_find_command(struct cmd_context *cmd, const char *path,
 				continue;
 
 			for (j = 0; j < commands[i].oo_count; j++) {
-				if (commands[i].optional_opt_args[j].opt == opt_enum) {
+				if ((commands[i].optional_opt_args[j].opt == opt_enum) &&
+				    _command_optional_opt_matches(cmd, i, j)) {
 					accepted = 1;
 					break;
 				}
@@ -1695,8 +1715,13 @@ static struct command *_find_command(struct cmd_context *cmd, const char *path,
 
 	if (best_unused_count) {
 		for (i = 0; i < best_unused_count; i++) {
-			log_error("Invalid option for command: %s.",
-				  arg_long_option_name(best_unused_options[i]));
+			const char *opt_val = NULL;
+			opt_enum = best_unused_options[i];
+			opt_val = arg_value(cmd, opt_enum);
+
+			log_error("Invalid option for command: %s%s%s.",
+				  arg_long_option_name(opt_enum),
+				  opt_val ? " " : "", opt_val ?: "");
 		}
 		return NULL;
 	}


