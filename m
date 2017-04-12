From: David Teigland <teigland@sourceware.org>
Date: Wed, 12 Apr 2017 15:07:41 -0400
Subject: master - commands: improve error message for option rules
Message-ID: <201704121907.v3CJ7fDA007994@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6c342abb7f4fd13126467f6ab2cdf5013f074695
Commit:        6c342abb7f4fd13126467f6ab2cdf5013f074695
Parent:        4b121a1f6ff5dafc860f60d351284bd917e6042f
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Apr 12 14:05:36 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Apr 12 14:05:36 2017 -0500

commands: improve error message for option rules

When a cmd def RULE fails because of a disallowed
combination of options, improve the error message
to show the option combination, not just the options
that broke the rule.
---
 tools/lvmcmdline.c |   25 ++++++++++++++++++-------
 1 files changed, 18 insertions(+), 7 deletions(-)

diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 3626b1b..4d20d08 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1506,10 +1506,13 @@ static int _command_required_pos_matches(struct cmd_context *cmd, int ci, int rp
 /* The max number of unused options we keep track of to warn about */
 #define MAX_UNUSED_COUNT 8
 
+#define MAX_OPTS_MSG 64
+
 static struct command *_find_command(struct cmd_context *cmd, const char *path, int *argc, char **argv)
 {
 	const char *name;
-	char buf[64];
+	char opts_msg[MAX_OPTS_MSG];
+	char check_opts_msg[MAX_OPTS_MSG];
 	int match_required, match_ro, match_rp, match_type, match_unused, mismatch_required;
 	int best_i = 0, best_required = 0, best_type = 0, best_unused = 0;
 	int close_i = 0, close_ro = 0, close_type = 0;
@@ -1792,16 +1795,24 @@ out:
 					   &opts_match_count, &opts_unmatch_count);
 
 			if (opts_match_count && (rule->rule == RULE_INVALID)) {
-				memset(buf, 0, sizeof(buf));
-				opt_array_to_str(cmd, rule->check_opts, rule->check_opts_count, buf, sizeof(buf));
-				log_error("Invalid options for command: %s", buf);
+				memset(opts_msg, 0, sizeof(opts_msg));
+				memset(check_opts_msg, 0, sizeof(check_opts_msg));
+
+				if (rule->opts_count)
+					opt_array_to_str(cmd, rule->opts, rule->opts_count, opts_msg, sizeof(opts_msg));
+				opt_array_to_str(cmd, rule->check_opts, rule->check_opts_count, check_opts_msg, sizeof(check_opts_msg));
+
+				if (rule->opts_count)
+					log_error("Invalid option combination: %s with %s", opts_msg, check_opts_msg);
+				else
+					log_error("Invalid options: %s", check_opts_msg);
 				return NULL;
 			}
 
 			if (opts_unmatch_count && (rule->rule == RULE_REQUIRE)) {
-				memset(buf, 0, sizeof(buf));
-				opt_array_to_str(cmd, rule->check_opts, rule->check_opts_count, buf, sizeof(buf));
-				log_error("Required options for command: %s", buf);
+				memset(check_opts_msg, 0, sizeof(check_opts_msg));
+				opt_array_to_str(cmd, rule->check_opts, rule->check_opts_count, check_opts_msg, sizeof(check_opts_msg));
+				log_error("Required options for command: %s", check_opts_msg);
 				return NULL;
 			}
 		}


