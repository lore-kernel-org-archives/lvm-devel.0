From: David Teigland <teigland@fedoraproject.org>
Date: Thu, 16 Feb 2017 15:38:10 +0000 (UTC)
Subject: master - commands: avoid factoring options until needed
Message-ID: <20170216153810.3E93360F99@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=15f51bc42113494bfb49fbc0d6a1913f68fb80a8
Commit:        15f51bc42113494bfb49fbc0d6a1913f68fb80a8
Parent:        22bee4fbdbf3cf52ac6a390b3c1ae983b5350760
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Feb 16 09:36:55 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Feb 16 09:37:28 2017 -0600

commands: avoid factoring options until needed

---
 tools/command.c |   21 +++++++++++++--------
 1 files changed, 13 insertions(+), 8 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index 9f2256b..6814a54 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -1197,6 +1197,10 @@ static void factor_common_options(void)
 		if (!command_names[cn].name)
 			break;
 
+		/* already factored */
+		if (command_names[cn].variants)
+			continue;
+
 		for (ci = 0; ci < COMMAND_COUNT; ci++) {
 			cmd = &commands[ci];
 
@@ -1457,17 +1461,10 @@ int define_commands(char *run_name)
 
 	/*
 	 * For usage.
-	 * Looks@all variants of each command name and figures out
-	 * which options are common to all variants (for compact output)
-	 */
-        factor_common_options();
-
-	/*
-	 * For usage.
 	 * Predefined string of options common to all commands
 	 * (for compact output)
 	 */
-        include_optional_opt_args(&lvm_all, "OO_USAGE_COMMON");
+	include_optional_opt_args(&lvm_all, "OO_USAGE_COMMON");
 
 	return 1;
 }
@@ -1564,6 +1561,12 @@ void print_usage(struct command *cmd)
 	int onereq = (cmd->cmd_flags & CMD_FLAG_ONE_REQUIRED_OPT) ? 1 : 0;
 	int ro, rp, oo, op, opt_enum, first;
 
+	/*
+	 * Looks at all variants of each command name and figures out
+	 * which options are common to all variants (for compact output)
+	 */
+	factor_common_options();
+
 	if (cmd->desc)
 		_print_usage_description(cmd);
 
@@ -2717,6 +2720,8 @@ int main(int argc, char *argv[])
 
 	define_commands(NULL);
 
+	factor_common_options();
+
 	print_man(argv[1], (argc > 2) ? argv[2] : NULL, 1, 1);
 
 	return 0;


