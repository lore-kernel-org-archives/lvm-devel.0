From: David Teigland <teigland@sourceware.org>
Date: Wed, 1 Mar 2017 11:23:26 -0500
Subject: master - man: put some commands into advanced usage section
Message-ID: <201703011623.v21GNQvm016349@int-mx13.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=62abae1525cec51279c39c5127afaced8f0463e2
Commit:        62abae1525cec51279c39c5127afaced8f0463e2
Parent:        eb9586bd3bc6741a3819147b35546ae35f363de1
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Feb 28 17:04:46 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Mar 1 10:22:48 2017 -0600

man: put some commands into advanced usage section

and separate commands with --
---
 man/Makefile.in    |    4 +-
 tools/command.c    |  106 ++++++++++++++++++++++++++++++++++++++++++++++++----
 tools/lvmcmdline.c |    2 +-
 3 files changed, 101 insertions(+), 11 deletions(-)

diff --git a/man/Makefile.in b/man/Makefile.in
index ca2249c..3ae00d9 100644
--- a/man/Makefile.in
+++ b/man/Makefile.in
@@ -144,12 +144,12 @@ Makefile: Makefile.in
 
 man-generator:
 	$(CC) -DMAN_PAGE_GENERATOR -I$(top_builddir)/tools $(CFLAGS) $(top_srcdir)/tools/command.c -o $@
-	- ./man-generator lvmconfig > test.gen
+	- ./man-generator --primary lvmconfig > test.gen
 	if [ ! -s test.gen ] ; then cp genfiles/*.gen $(top_builddir)/man; fi;
 
 $(MAN8GEN): man-generator
 	echo "Generating $@" ;
-	if [ ! -e $@.gen ]; then ./man-generator $(basename $@) $(top_srcdir)/man/$@.des > $@.gen; fi
+	if [ ! -e $@.gen ]; then ./man-generator --primary $(basename $@) $(top_srcdir)/man/$@.des > $@.gen; ./man-generator --secondary $(basename $@) >> $@.gen; fi
 	if [ -f $(top_srcdir)/man/$@.end ]; then cat $(top_srcdir)/man/$@.end >> $@.gen; fi;
 	cat $(top_srcdir)/man/see_also.end >> $@.gen
 	$(SED) -e "s+#VERSION#+$(LVM_VERSION)+;s+#DEFAULT_SYS_DIR#+$(DEFAULT_SYS_DIR)+;s+#DEFAULT_ARCHIVE_DIR#+$(DEFAULT_ARCHIVE_DIR)+;s+#DEFAULT_BACKUP_DIR#+$(DEFAULT_BACKUP_DIR)+;s+#DEFAULT_PROFILE_DIR#+$(DEFAULT_PROFILE_DIR)+;s+#DEFAULT_CACHE_DIR#+$(DEFAULT_CACHE_DIR)+;s+#DEFAULT_LOCK_DIR#+$(DEFAULT_LOCK_DIR)+;s+#CLVMD_PATH#+ at CLVMD_PATH@+;s+#LVM_PATH#+ at LVM_PATH@+;s+#DEFAULT_RUN_DIR#+ at DEFAULT_RUN_DIR@+;s+#DEFAULT_PID_DIR#+ at DEFAULT_PID_DIR@+;s+#SYSTEMD_GENERATOR_DIR#+$(SYSTEMD_GENERATOR_DIR)+;s+#DEFAULT_MANGLING#+$(DEFAULT_MANGLING)+;" $@.gen > $@
diff --git a/tools/command.c b/tools/command.c
index a8c38ba..7c5bf7c 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -2866,7 +2866,7 @@ static void include_description_file(char *name, char *des_file)
 	close(fd);
 }
 
-void print_man(char *name, char *des_file, int include_primary, int include_secondary)
+void print_man(char *name, char *des_file, int secondary)
 {
 	struct command_name *cname;
 	struct command *cmd, *prev_cmd = NULL;
@@ -2905,10 +2905,7 @@ void print_man(char *name, char *des_file, int include_primary, int include_seco
 		if (cmd->cmd_flags & CMD_FLAG_PREVIOUS_SYNTAX)
 			continue;
 
-		if ((cmd->cmd_flags & CMD_FLAG_SECONDARY_SYNTAX) && !include_secondary)
-			continue;
-
-		if (!(cmd->cmd_flags & CMD_FLAG_SECONDARY_SYNTAX) && !include_primary)
+		if ((cmd->cmd_flags & CMD_FLAG_SECONDARY_SYNTAX) && !secondary)
 			continue;
 
 		if (strcmp(name, cmd->name))
@@ -2995,6 +2992,12 @@ void print_man(char *name, char *des_file, int include_primary, int include_seco
 			printf(".SH VARIABLES\n");
 			printf(".br\n");
 			print_man_all_positions_desc(cname);
+		} else {
+			if (cname->variants > 2) {
+				printf("--\n");
+				printf("\n");
+				printf(".br\n");
+			}
 		}
 
 		printf("\n");
@@ -3002,20 +3005,107 @@ void print_man(char *name, char *des_file, int include_primary, int include_seco
 	}
 }
 
+void print_man_secondary(char *name)
+{
+	struct command *cmd;
+	char *lvmname = name;
+	int header = 0;
+	int i;
+
+	if (!strncmp(name, "lvm-", 4)) {
+		name[3] = ' ';
+		name += 4;
+	}
+
+	for (i = 0; i < COMMAND_COUNT; i++) {
+
+		cmd = &commands[i];
+
+		if (cmd->cmd_flags & CMD_FLAG_PREVIOUS_SYNTAX)
+			continue;
+
+		if (!(cmd->cmd_flags & CMD_FLAG_SECONDARY_SYNTAX))
+			continue;
+
+		if (strcmp(name, cmd->name))
+			continue;
+
+		if (!header) {
+			printf(".SH ADVANCED USAGE\n");
+			printf("Alternate command forms, advanced command usage, and listing of all valid syntax for completeness.\n");
+			printf(".P\n");
+			header = 1;
+		}
+
+		if (cmd->desc) {
+			print_desc_man(cmd->desc);
+			printf(".P\n");
+		}
+
+		print_man_usage(lvmname, cmd);
+
+		printf("--\n");
+		printf("\n");
+		printf(".br\n");
+
+		printf("\n");
+	}
+}
+
 int main(int argc, char *argv[])
 {
+	char *cmdname = NULL;
+	char *desfile = NULL;
+	int primary = 0;
+	int secondary = 0;
+
 	memset(&commands, 0, sizeof(commands));
 
-	if (argc < 2) {
-		log_error("Usage: %s <command> [/path/to/description-file]", argv[0]);
+	static struct option long_options[] = {
+		{"primary", no_argument, 0, 'p' },
+		{"secondary", no_argument, 0, 's' },
+		{0, 0, 0, 0 }
+	};
+
+	while (1) {
+		int c;
+		int option_index = 0;
+
+		c = getopt_long(argc, argv, "ps", long_options, &option_index);
+		if (c == -1)
+			break;
+
+		switch (c) {
+		case '0':
+			break;
+		case 'p':
+			primary = 1;
+			break;
+		case 's':
+			secondary = 1;
+			break;
+		}
+	}
+
+	if (!primary && !secondary) {
+		log_error("Usage: %s --primary|--secondary <command> [/path/to/description-file]", argv[0]);
 		exit(EXIT_FAILURE);
 	}
 
+	if (optind < argc)
+		cmdname = strdup(argv[optind++]);
+
+	if (optind < argc)
+		desfile = argv[optind++];
+
 	define_commands(NULL);
 
 	factor_common_options();
 
-	print_man(argv[1], (argc > 2) ? argv[2] : NULL, 1, 1);
+	if (primary)
+		print_man(cmdname, desfile, secondary);
+	else if (secondary)
+		print_man_secondary(cmdname);
 
 	return 0;
 }
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index d440987..e2be7c7 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1720,7 +1720,7 @@ static int _usage(const char *name, int longhelp)
 		print_usage_common_cmd(cname, cmd);
 		print_usage_common_lvm(cname, cmd);
 	} else
-		log_print("Use --longhelp to show all options.");
+		log_print("Use --longhelp to show all options and advanced commands.");
 
 	return 1;
 }


