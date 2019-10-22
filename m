From: David Teigland <teigland@sourceware.org>
Date: Tue, 22 Oct 2019 10:35:25 -0400
Subject: master - improve command definition matching using type
Message-ID: <201910221435.x9MEZP95005849@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=570676488516b60ea3132b5010e7aef5d5cb1549
Commit:        570676488516b60ea3132b5010e7aef5d5cb1549
Parent:        80ae7206a80277f3e01ba92725c209ea82a0bde6
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Oct 21 16:42:06 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Oct 22 09:35:10 2019 -0500

improve command definition matching using type

When a user includes "--type foo" in a command, only
look at command definitions with matching type, as
opposed to using matching/mismatching --type as a
vote for/against a given command def.  This means a
command with --type foo will prioritize a command def
with --type foo over other command defs that have
more matching options but an unmatching type.  This
makes it more likely that a closely matching command
def will be recommended.
---
 tools/lvmcmdline.c |   73 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 73 insertions(+), 0 deletions(-)

diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 7d29b6f..860e6de 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1520,6 +1520,65 @@ static int _command_required_pos_matches(struct cmd_context *cmd, int ci, int rp
 }
 
 /*
+ * Return 1 if we should skip this command from consideration.
+ * This would happen if the command does not include a --type
+ * option that does not match type_arg.
+ */
+
+static int _command_skip_for_type_arg(struct cmd_context *cmd, int ci, const char *type_arg)
+{
+	int ro, oo, opt_enum;
+
+	for (ro = 0; ro < (commands[ci].ro_count + commands[ci].any_ro_count); ro++) {
+		opt_enum = commands[ci].required_opt_args[ro].opt;
+
+		if (opt_enum != type_ARG)
+			continue;
+
+		/* SegType keyword in command def matches any type_arg */
+		if (val_bit_is_set(commands[ci].required_opt_args[ro].def.val_bits, segtype_VAL))
+			return 0;
+
+		if (!commands[ci].required_opt_args[ro].def.str)
+			return 0;
+
+		if (!strcmp(commands[ci].required_opt_args[ro].def.str, type_arg))
+			return 0;
+
+		if (!strncmp(commands[ci].required_opt_args[ro].def.str, "raid", 4) &&
+		    !strncmp(type_arg, "raid", 4))
+			return 0;
+
+		return 1;
+	}
+
+	for (oo = 0; oo < commands[ci].oo_count; oo++) {
+		opt_enum = commands[ci].optional_opt_args[oo].opt;
+
+		if (opt_enum != type_ARG)
+			continue;
+
+		/* SegType keyword in command def matches any type_arg */
+		if (val_bit_is_set(commands[ci].optional_opt_args[oo].def.val_bits, segtype_VAL))
+			return 0;
+
+		if (!commands[ci].optional_opt_args[oo].def.str)
+			return 0;
+
+		if (!strcmp(commands[ci].optional_opt_args[oo].def.str, type_arg))
+			return 0;
+
+		if (!strncmp(commands[ci].optional_opt_args[oo].def.str, "raid", 4) &&
+		    !strncmp(type_arg, "raid", 4))
+			return 0;
+
+		return 1;
+	}
+
+	return 1;
+}
+
+/*
  * Match what the user typed with a one specific command definition/prototype
  * from commands[].  If nothing matches, it's not a valid command.  The match
  * is based on command name, required opt args and required pos args.
@@ -1549,6 +1608,7 @@ static int _command_required_pos_matches(struct cmd_context *cmd, int ci, int rp
 static struct command *_find_command(struct cmd_context *cmd, const char *path, int *argc, char **argv)
 {
 	const char *name;
+	const char *type_arg = NULL;
 	char opts_msg[MAX_OPTS_MSG];
 	char check_opts_msg[MAX_OPTS_MSG];
 	int match_required, match_ro, match_rp, match_any_ro, match_type, match_unused, mismatch_required;
@@ -1575,6 +1635,9 @@ static struct command *_find_command(struct cmd_context *cmd, const char *path,
 		variants++;
 	}
 
+	if (arg_is_set(cmd, type_ARG))
+		type_arg = arg_str_value(cmd, type_ARG, "");
+
 	for (i = 0; i < COMMAND_COUNT; i++) {
 		if (strcmp(name, commands[i].name))
 			continue;
@@ -1597,6 +1660,16 @@ static struct command *_find_command(struct cmd_context *cmd, const char *path,
 				continue;
 		}
 
+		/*
+		 * '--type foo' is special.  If the user has set --type foo, then
+		 * we will only look at command defs that include the same --type foo
+		 * (as required or optional).  We'll never match some command based
+		 * on *other* (non-type) options, and then@the end complain that
+		 * the user's --type is not accepted.
+		 */
+		if (type_arg && _command_skip_for_type_arg(cmd, i, type_arg))
+			continue;
+
 		match_required = 0;	/* required parameters that match */
 		match_ro = 0;		/* required opt_args that match */
 		match_rp = 0;		/* required pos_args that match */


