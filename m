From: David Teigland <teigland@sourceware.org>
Date: Tue, 25 Apr 2017 16:50:40 -0400
Subject: master - commands: improve error messages for rules
Message-ID: <201704252050.v3PKoe6B014666@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a3fdc966b51336fa7b77a26890539c26a0427199
Commit:        a3fdc966b51336fa7b77a26890539c26a0427199
Parent:        c534a7bcc98e936a456601e4be749a828d978e9e
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Apr 25 12:19:11 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Apr 25 15:49:58 2017 -0500

commands: improve error messages for rules

Make the error messages more consistent,
and use less code-centric wording.
---
 tools/lvmcmdline.c |   12 ++++++------
 tools/toollib.c    |   20 +++++++++++---------
 2 files changed, 17 insertions(+), 15 deletions(-)

diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 4f66f7e..37e9ef8 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1700,7 +1700,7 @@ static struct command *_find_command(struct cmd_context *cmd, const char *path,
 
 	if (!best_required) {
 		/* cmd did not have all the required opt/pos args of any command */
-		log_error("Incorrect syntax. Run '%s --help' for more information.", name);
+		log_error("No command with matching syntax recognised.  Run '%s --help' for more information.", name);
 		if (close_ro) {
 			log_warn("Nearest similar command has syntax:");
 			print_usage(&_cmdline.commands[close_i], 0, 0);
@@ -1722,7 +1722,7 @@ static struct command *_find_command(struct cmd_context *cmd, const char *path,
 			opt_enum = best_unused_options[i];
 			opt_val = arg_value(cmd, opt_enum);
 
-			log_error("Invalid option for command: %s%s%s.",
+			log_error("Command does not accept option: %s%s%s.",
 				  arg_long_option_name(opt_enum),
 				  opt_val ? " " : "", opt_val ?: "");
 		}
@@ -1753,7 +1753,7 @@ static struct command *_find_command(struct cmd_context *cmd, const char *path,
 			break;
 
 		if (count >= (commands[best_i].rp_count + commands[best_i].op_count)) {
-			log_error("Invalid positional argument for command: %s.", argv[count]);
+			log_error("Command does not accept argument: %s.", argv[count]);
 
 			/* FIXME: to warn/ignore, clear so it can't be used when processing. */
 			/*
@@ -1803,16 +1803,16 @@ out:
 				opt_array_to_str(cmd, rule->check_opts, rule->check_opts_count, check_opts_msg, sizeof(check_opts_msg));
 
 				if (rule->opts_count)
-					log_error("Invalid option combination: %s with %s", opts_msg, check_opts_msg);
+					log_error("Command does not accept option combination: %s with %s", opts_msg, check_opts_msg);
 				else
-					log_error("Invalid options: %s", check_opts_msg);
+					log_error("Command does not accept options: %s", check_opts_msg);
 				return NULL;
 			}
 
 			if (opts_unmatch_count && (rule->rule == RULE_REQUIRE)) {
 				memset(check_opts_msg, 0, sizeof(check_opts_msg));
 				opt_array_to_str(cmd, rule->check_opts, rule->check_opts_count, check_opts_msg, sizeof(check_opts_msg));
-				log_error("Required options for command: %s", check_opts_msg);
+				log_error("Command requires options: %s", check_opts_msg);
 				return NULL;
 			}
 		}
diff --git a/tools/toollib.c b/tools/toollib.c
index 1d7b01d..838765b 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -2701,7 +2701,7 @@ static int _check_lv_types(struct cmd_context *cmd, struct logical_volume *lv, i
 	if (!ret) {
 		int lvt_enum = get_lvt_enum(lv);
 		struct lv_type *type = get_lv_type(lvt_enum);
-		log_warn("Operation on LV %s which has invalid type %s.",
+		log_warn("Command on LV %s does not accept LV type %s.",
 			 display_lvname(lv), type ? type->name : "unknown");
 	}
 
@@ -2811,7 +2811,8 @@ static int _check_lv_rules(struct cmd_context *cmd, struct logical_volume *lv)
 		if (rule->check_opts && (rule->rule == RULE_INVALID) && opts_match_count) {
 			memset(buf, 0, sizeof(buf));
 			opt_array_to_str(cmd, rule->check_opts, rule->check_opts_count, buf, sizeof(buf));
-			log_warn("An invalid option is set: %s", buf);
+			log_warn("Command on LV %s does not accept option %s.",
+				 display_lvname(lv), buf);
 			ret = 0;
 		}
 
@@ -2820,14 +2821,15 @@ static int _check_lv_rules(struct cmd_context *cmd, struct logical_volume *lv)
 		if (rule->check_opts && (rule->rule == RULE_REQUIRE) && opts_unmatch_count)  {
 			memset(buf, 0, sizeof(buf));
 			opt_array_to_str(cmd, rule->check_opts, rule->check_opts_count, buf, sizeof(buf));
-			log_warn("A required option is not set: %s", buf);
+			log_warn("Command on LV %s requires option %s.",
+				 display_lvname(lv), buf);
 			ret = 0;
 		}
 
 		/* Fail if the LV matches any of the invalid LV types. */
 
 		if (rule->check_lvt_bits && (rule->rule == RULE_INVALID) && lv_types_match_bits) {
-			log_warn("Command on LV %s with invalid type: %s",
+			log_warn("Command on LV %s does not accept LV type %s.",
 				 display_lvname(lv), lvtype ? lvtype->name : "unknown");
 			ret = 0;
 		}
@@ -2837,7 +2839,7 @@ static int _check_lv_rules(struct cmd_context *cmd, struct logical_volume *lv)
 		if (rule->check_lvt_bits && (rule->rule == RULE_REQUIRE) && !lv_types_match_bits) {
 			memset(buf, 0, sizeof(buf));
 			lvt_bits_to_str(rule->check_lvt_bits, buf, sizeof(buf));
-			log_warn("Command on LV %s with type %s does not match required type: %s",
+			log_warn("Command on LV %s does not accept LV type %s. Required LV types are %s.",
 				 display_lvname(lv), lvtype ? lvtype->name : "unknown", buf);
 			ret = 0;
 		}
@@ -2847,7 +2849,7 @@ static int _check_lv_rules(struct cmd_context *cmd, struct logical_volume *lv)
 		if (rule->check_lvp_bits && (rule->rule == RULE_INVALID) && lv_props_match_bits) {
 			memset(buf, 0, sizeof(buf));
 			lvp_bits_to_str(lv_props_match_bits, buf, sizeof(buf));
-			log_warn("Command on LV %s with invalid properties: %s",
+			log_warn("Command on LV %s does not accept LV with properties: %s.",
 				 display_lvname(lv), buf);
 			ret = 0;
 		}
@@ -2857,7 +2859,7 @@ static int _check_lv_rules(struct cmd_context *cmd, struct logical_volume *lv)
 		if (rule->check_lvp_bits && (rule->rule == RULE_REQUIRE) && lv_props_unmatch_bits) {
 			memset(buf, 0, sizeof(buf));
 			lvp_bits_to_str(lv_props_unmatch_bits, buf, sizeof(buf));
-			log_warn("Command on LV %s requires properties: %s",
+			log_warn("Command on LV %s requires LV with properties: %s.",
 				 display_lvname(lv), buf);
 			ret = 0;
 		}
@@ -3108,7 +3110,7 @@ int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 		if (!_check_lv_types(cmd, lvl->lv, lv_arg_pos)) {
 			/* FIXME: include this result in report log? */
 			if (lv_is_named_arg) {
-				log_error("Operation not permitted on LV %s.", display_lvname(lvl->lv));
+				log_error("Command not permitted on LV %s.", display_lvname(lvl->lv));
 				ret_max = ECMD_FAILED;
 			}
 			continue;
@@ -3117,7 +3119,7 @@ int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 		if (!_check_lv_rules(cmd, lvl->lv)) {
 			/* FIXME: include this result in report log? */
 			if (lv_is_named_arg) {
-				log_error("Operation not permitted on LV %s.", display_lvname(lvl->lv));
+				log_error("Command not permitted on LV %s.", display_lvname(lvl->lv));
 				ret_max = ECMD_FAILED;
 			} 
 			continue;


