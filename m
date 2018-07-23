From: David Teigland <teigland@sourceware.org>
Date: Mon, 23 Jul 2018 12:13:29 -0400
Subject: master - lvconvert: restrict command matching for no option variant
Message-ID: <201807231613.w6NGDTr9024156@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8a66c81b9beb87f2f381e7e2aa76e4e54fd19934
Commit:        8a66c81b9beb87f2f381e7e2aa76e4e54fd19934
Parent:        63ec42f428e010dcc638d887a5089d491b36b0e9
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Jul 23 11:08:12 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Jul 23 11:12:38 2018 -0500

lvconvert: restrict command matching for no option variant

The 'lvconvert LV' command def has caused multiple problems
for command matching because it matches the required options
of any lvconvert command.  Any lvconvert with incorrect options
ends up matching 'lvconvert LV', which then produces an error
about incorrect options being used for 'lvconvert LV'.  This
prevents suggestions from nearest-command partial command matches.

Add a special case for 'lvconvert LV' so that it won't be used
as a partial match for a command that has options specified.
---
 lib/commands/toolcontext.h |    1 +
 tools/command-lines.in     |    2 +-
 tools/lvmcmdline.c         |   14 ++++++++++++++
 3 files changed, 16 insertions(+), 1 deletions(-)

diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index 3c7ef54..2ac7a1e 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -95,6 +95,7 @@ struct cmd_context {
 	char **argv;
 	struct arg_values *opt_arg_values;
 	struct dm_list arg_value_groups;
+	int opt_count; /* total number of options (beginning with - or --) */
 
 	/*
 	 * Position args remaining after command name
diff --git a/tools/command-lines.in b/tools/command-lines.in
index 6192b03..d6cd04e 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -727,7 +727,7 @@ RULE: all and lv_is_converting
 # for compat since this was how it used to be done.
 lvconvert LV_mirror_raid
 OO: OO_LVCONVERT
-ID: lvconvert_start_poll
+ID: lvconvert_plain
 DESC: Poll LV to continue conversion (also see --startpoll)
 DESC: or waits till conversion/mirror syncing is finished
 FLAGS: SECONDARY_SYNTAX
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index cb1753d..84825af 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -117,6 +117,7 @@ static const struct command_function _command_functions[CMD_COUNT] = {
 
 	/* lvconvert utility to trigger polling on an LV. */
 	{ lvconvert_start_poll_CMD, lvconvert_start_poll_cmd },
+	{ lvconvert_plain_CMD, lvconvert_start_poll_cmd },
 
 	/* lvconvert utilities for creating/maintaining thin and cache objects. */
 	{ lvconvert_to_thinpool_CMD,			lvconvert_to_pool_cmd },
@@ -1583,6 +1584,17 @@ static struct command *_find_command(struct cmd_context *cmd, const char *path,
 		if (arg_is_set(cmd, help_ARG) || arg_is_set(cmd, help2_ARG) || arg_is_set(cmd, longhelp_ARG) || arg_is_set(cmd, version_ARG))
 			return &commands[i];
 
+		/*
+		 * The 'lvconvert LV' cmd def matches any lvconvert cmd which throws off
+		 * nearest-command partial-match suggestions.  Make it a special case so
+		 * that it won't be used as a close match.  If the command has any option
+		 * set (other than -v), don't attempt to match it to 'lvconvert LV'.
+		 */
+		if (commands[i].command_enum == lvconvert_plain_CMD) {
+			if (cmd->opt_count - cmd->opt_arg_values[verbose_ARG].count)
+				continue;
+		}
+
 		match_required = 0;	/* required parameters that match */
 		match_ro = 0;		/* required opt_args that match */
 		match_rp = 0;		/* required pos_args that match */
@@ -2101,6 +2113,8 @@ static int _process_command_line(struct cmd_context *cmd, int *argc, char ***arg
 		if (goval == '?')
 			return 0;
 
+		cmd->opt_count++;
+
 		/*
 		 * translate the option value used by getopt into the enum
 		 * value (e.g. foo_ARG) from the args array.


