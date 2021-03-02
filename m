From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  2 Mar 2021 21:58:27 +0000 (GMT)
Subject: main - cmdline: drop MAX and check NULL
Message-ID: <20210302215827.E8B203950405@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=589c6545627cdc5a90bf4c2e4640c42d9623bb47
Commit:        589c6545627cdc5a90bf4c2e4640c42d9623bb47
Parent:        e946a5e6904455284ae4eeaa1d149a9324b0f00e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Feb 25 18:09:33 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 2 22:54:40 2021 +0100

cmdline: drop MAX and check NULL

Remove MAX_COMMAND_NAMES and check for the last element as NULL pointer.
---
 tools/command.c    | 16 ++++++----------
 tools/command.h    |  2 --
 tools/lvmcmdline.c | 27 ++++++++++-----------------
 3 files changed, 16 insertions(+), 29 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index dd1f94194..131d2d3d3 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -246,19 +246,21 @@ struct cmd_name cmd_names[CMD_COUNT + 1] = {
 
 #ifdef MAN_PAGE_GENERATOR
 
-struct command_name command_names[MAX_COMMAND_NAMES] = {
+struct command_name command_names[] = {
 #define xx(a, b, c...) { # a, b, c },
 #include "commands.h"
 #undef xx
+	{ .name = NULL }
 };
 struct command commands[COMMAND_COUNT];
 
 #else /* MAN_PAGE_GENERATOR */
 
-struct command_name command_names[MAX_COMMAND_NAMES] = {
+struct command_name command_names[] = {
 #define xx(a, b, c...) { # a, b, c, a},
 #include "commands.h"
 #undef xx
+	{ .name = NULL }
 };
 extern struct command commands[COMMAND_COUNT]; /* defined in lvmcmdline.c */
 
@@ -514,12 +516,9 @@ static struct command_name *_find_command_name(const char *name)
 	if (!islower(name[0]))
 		return NULL; /* Commands starts with lower-case */
 
-	for (i = 0; i < MAX_COMMAND_NAMES; i++) {
-		if (!command_names[i].name)
-			break;
+	for (i = 0; command_names[i].name; i++)
 		if (!strcmp(command_names[i].name, name))
 			return &command_names[i];
-	}
 
 	return NULL;
 }
@@ -1270,10 +1269,7 @@ void factor_common_options(void)
 	int cn, opt_enum, ci, oo, ro, found;
 	struct command *cmd;
 
-	for (cn = 0; cn < MAX_COMMAND_NAMES; cn++) {
-		if (!command_names[cn].name)
-			break;
-
+	for (cn = 0; command_names[cn].name; cn++) {
 		/* already factored */
 		if (command_names[cn].variants)
 			continue;
diff --git a/tools/command.h b/tools/command.h
index dae3d0570..c0d7977dc 100644
--- a/tools/command.h
+++ b/tools/command.h
@@ -30,8 +30,6 @@ struct command_function {
 	command_id_fn fn;
 };
 
-#define MAX_COMMAND_NAMES 64
-
 struct command_name {
 	const char *name;
 	const char *desc; /* general command description from commands.h */
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index b6ad66d62..8ad1f5e99 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -74,7 +74,7 @@ extern struct lv_type lv_types[LVT_COUNT + 1];
 /*
  * Table of command names
  */
-extern struct command_name command_names[MAX_COMMAND_NAMES];
+extern struct command_name command_names[];
 
 /*
  * Table of commands (as defined in command-lines.in)
@@ -1278,13 +1278,11 @@ static void _set_valid_args_for_command_name(int ci)
 static struct command_name *_find_command_name(const char *name)
 {
 	int i;
-	
-	for (i = 0; i < MAX_COMMAND_NAMES; i++) {
-		if (!command_names[i].name)
-			break;
+
+	for (i = 0; command_names[i].name; i++)
 		if (!strcmp(command_names[i].name, name))
 			return &command_names[i];
-	}
+
 	return NULL;
 }
 
@@ -1354,14 +1352,12 @@ int lvm_register_commands(struct cmd_context *cmd, const char *run_name)
 		}
 	}
 
-	_cmdline.command_names = command_names;
-	_cmdline.num_command_names = 0;
+	/* Check how many command entries we have */
+	for (i = 0; command_names[i].name; i++)
+		;
 
-	for (i = 0; i < MAX_COMMAND_NAMES; i++) {
-		if (!command_names[i].name)
-			break;
-		_cmdline.num_command_names++;
-	}
+	_cmdline.num_command_names = i;
+	_cmdline.command_names = command_names;
 
 	for (i = 0; i < _cmdline.num_command_names; i++)
 		_set_valid_args_for_command_name(i);
@@ -2074,11 +2070,8 @@ static void _usage_all(void)
 {
 	int i;
 
-	for (i = 0; i < MAX_COMMAND_NAMES; i++) {
-		if (!command_names[i].name)
-			break;
+	for (i = 0; command_names[i].name; i++)
 		_usage(command_names[i].name, 1, 1);
-	}
 
 	print_usage_notes(NULL);
 }


