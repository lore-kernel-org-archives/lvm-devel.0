From: David Teigland <teigland@sourceware.org>
Date: Wed, 8 Mar 2017 12:04:29 -0500
Subject: master - help: avoid end notes repetition in lvm help all
Message-ID: <201703081704.v28H4Tvq027876@int-mx14.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f48e6b2690c43120ec87e4fa913b2bd952a53511
Commit:        f48e6b2690c43120ec87e4fa913b2bd952a53511
Parent:        ed58672029567858709113b67337e4dfaf31d210
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Mar 7 12:01:06 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Mar 8 11:03:02 2017 -0600

help: avoid end notes repetition in lvm help all

---
 tools/command.c    |    6 +++---
 tools/command.h    |    2 +-
 tools/lvmcmdline.c |   15 ++++++++++-----
 3 files changed, 14 insertions(+), 9 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index 5fc5ff3..d184208 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -1989,9 +1989,9 @@ void print_usage_common_cmd(struct command_name *cname, struct command *cmd)
 	printf("\n\n");
 }
 
-void print_usage_notes(struct command_name *cname, struct command *cmd)
+void print_usage_notes(struct command_name *cname)
 {
-	if (command_has_alternate_extents(cname->name)) {
+	if (cname && command_has_alternate_extents(cname->name)) {
 		printf("  Special options for command:\n");
 		printf("        [ --extents Number[PERCENT] ]\n"
 		       "        The --extents option can be used in place of --size.\n"
@@ -1999,7 +1999,7 @@ void print_usage_notes(struct command_name *cname, struct command *cmd)
 		printf("\n");
 	}
 
-	if (!strcmp(cname->name, "lvcreate")) {
+	if (cname && !strcmp(cname->name, "lvcreate")) {
 		printf("        [ --name String ]\n"
 		       "        The --name option is not required but is typically used.\n"
 		       "        When a name is not specified, a new LV name is generated\n"
diff --git a/tools/command.h b/tools/command.h
index 0109853..2e4dba3 100644
--- a/tools/command.h
+++ b/tools/command.h
@@ -216,7 +216,7 @@ int command_id_to_enum(const char *str);
 void print_usage(struct command *cmd, int longhelp, int desc_first);
 void print_usage_common_cmd(struct command_name *cname, struct command *cmd);
 void print_usage_common_lvm(struct command_name *cname, struct command *cmd);
-void print_usage_notes(struct command_name *cname, struct command *cmd);
+void print_usage_notes(struct command_name *cname);
 void factor_common_options(void);
 int command_has_alternate_extents(const char *name);
 
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 53856ce..ad638af 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1694,7 +1694,7 @@ static void _short_usage(const char *name)
 	log_error("Run `%s --help' for more information.", name);
 }
 
-static int _usage(const char *name, int longhelp)
+static int _usage(const char *name, int longhelp, int skip_notes)
 {
 	struct command_name *cname = find_command_name(name);
 	struct command *cmd;
@@ -1739,8 +1739,11 @@ static int _usage(const char *name, int longhelp)
 		print_usage_common_lvm(cname, cmd);
 	}
 
+	if (skip_notes)
+		return 1;
+
 	if (longhelp)
-		print_usage_notes(cname, cmd);
+		print_usage_notes(cname);
 	else
 		log_print("Use --longhelp to show all options and advanced commands.");
 
@@ -1754,8 +1757,10 @@ static void _usage_all(void)
 	for (i = 0; i < MAX_COMMAND_NAMES; i++) {
 		if (!command_names[i].name)
 			break;
-		_usage(command_names[i].name, 1);
+		_usage(command_names[i].name, 1, 1);
 	}
+
+	print_usage_notes(NULL);
 }
 
 /*
@@ -2202,7 +2207,7 @@ static int _process_common_commands(struct cmd_context *cmd)
 	if (arg_is_set(cmd, help_ARG) ||
 	    arg_is_set(cmd, longhelp_ARG) ||
 	    arg_is_set(cmd, help2_ARG)) {
-		_usage(cmd->name, arg_is_set(cmd, longhelp_ARG));
+		_usage(cmd->name, arg_is_set(cmd, longhelp_ARG), 0);
 		return ECMD_PROCESSED;
 	}
 
@@ -2240,7 +2245,7 @@ int help(struct cmd_context *cmd __attribute__((unused)), int argc, char **argv)
 	else {
 		int i;
 		for (i = 0; i < argc; i++)
-			if (!_usage(argv[i], 0))
+			if (!_usage(argv[i], 0, 0))
 				ret = EINVALID_CMD_LINE;
 	}
 


