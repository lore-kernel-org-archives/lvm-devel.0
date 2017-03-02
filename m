From: David Teigland <teigland@sourceware.org>
Date: Thu, 2 Mar 2017 17:58:46 -0500
Subject: master - help: print info about special options and variables
Message-ID: <201703022258.v22MwkwV009227@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9b23d9bfe40428b4f0b744eea1a346f6234bfd83
Commit:        9b23d9bfe40428b4f0b744eea1a346f6234bfd83
Parent:        f35028339830330ef331ff15a7e5f1274bfd63a2
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Mar 2 16:10:40 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Mar 2 16:58:19 2017 -0600

help: print info about special options and variables

when --longhelp is used
---
 tools/command.c    |   57 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 tools/command.h    |    1 +
 tools/lvmcmdline.c |   15 +++++++++----
 3 files changed, 68 insertions(+), 5 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index f55b2ef..e82fdea 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -1817,6 +1817,63 @@ void print_usage_common_cmd(struct command_name *cname, struct command *cmd)
 	printf("\n\n");
 }
 
+void print_usage_notes(struct command_name *cname, struct command *cmd)
+{
+
+	if (!strcmp(cname->name, "lvcreate")) {
+		printf("  Special options for command:\n");
+		printf("        [ --extents NumberExtents ]\n"
+		       "        The --extents option can be used in place of --size in each case.\n");
+		printf("\n");
+		printf("        [ --name String ]\n"
+		       "        The --name option is not required but is typically used.\n"
+		       "        When a name is not specified, a new LV name is generated\n"
+		       "        with the \"lvol\" prefix and a unique numeric suffix.\n");
+		printf("\n");
+	}
+
+	printf("  Common variables for lvm:\n"
+	       "        Variables in option or position args are capitalized,\n"
+	       "        e.g. PV, VG, LV, Size, Number, String, Tag.\n");
+	printf("\n");
+
+	printf("        PV\n"
+	       "        Physical Volume name, a device path under /dev.\n"
+	       "        For commands managing physical extents, a PV positional\n"
+	       "        arg generally accepts a suffix indicating a range of PEs:\n"
+	       "        PV[:PE[-PE]] is start and end range (inclusive),\n"
+	       "        PV[:PE[+PE]] is start and length range (counting from 0).\n");
+	printf("\n");
+
+	printf("        LV\n"
+	       "        Logical Volume name. See lvm(8) for valid names. An LV positional\n"
+	       "        arg generally includes the VG name and LV name, e.g. VG/LV.\n"
+	       "        LV followed by _<type> indicates that an LV of the given type is\n"
+	       "        required. (raid represents raid<N> type).\n"
+	       "        The _new suffix indicates that the LV name is new.\n");
+	printf("\n");
+
+	printf("        Tag\n"
+	       "        Tag name. See lvm(8) for information about tag names and using\n"
+	       "        tags in place of a VG, LV or PV.\n");
+	printf("\n");
+
+	printf("        Select\n"
+	       "        Select indicates that a required positional arg can be omitted\n"
+	       "        if the --select option is used. No arg appears in this position.\n");
+	printf("\n");
+
+	printf("        Size[UNIT]\n"
+	       "        Size is an input number that accepts an optional unit.\n"
+               "        Input units are always treated as base two values, regardless of\n"
+               "        capitalization, e.g. 'k' and 'K' both refer to 1024.\n"
+               "        The default input unit is specified by letter, followed by |UNIT.\n"
+               "        UNIT represents other possible input units: BbBsSkKmMgGtTpPeE.\n"
+               "        (This should not be confused with the output control --units, where\n"
+               "        capital letters mean multiple of 1000.)\n");
+	printf("\n");
+}
+
 #ifdef MAN_PAGE_GENERATOR
 
 static void print_val_man(struct command_name *cname, const char *str)
diff --git a/tools/command.h b/tools/command.h
index 36554a3..33f083b 100644
--- a/tools/command.h
+++ b/tools/command.h
@@ -216,6 +216,7 @@ int command_id_to_enum(const char *str);
 void print_usage(struct command *cmd, int longhelp, int desc_first);
 void print_usage_common_cmd(struct command_name *cname, struct command *cmd);
 void print_usage_common_lvm(struct command_name *cname, struct command *cmd);
+void print_usage_notes(struct command_name *cname, struct command *cmd);
 void factor_common_options(void);
 
 #endif
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 5410a1f..4a109a6 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1702,6 +1702,7 @@ static int _usage(const char *name, int longhelp)
 {
 	struct command_name *cname = find_command_name(name);
 	struct command *cmd;
+	int show_full = longhelp;
 	int i;
 
 	if (!cname) {
@@ -1720,7 +1721,7 @@ static int _usage(const char *name, int longhelp)
 	/* Reduce the default output when there are several variants. */
 
 	if (cname->variants < 3)
-		longhelp = 1;
+		show_full = 1;
 
 	for (i = 0; i < COMMAND_COUNT; i++) {
 		if (strcmp(_cmdline.commands[i].name, name))
@@ -1729,18 +1730,22 @@ static int _usage(const char *name, int longhelp)
 		if (_cmdline.commands[i].cmd_flags & CMD_FLAG_PREVIOUS_SYNTAX)
 			continue;
 
-		if ((_cmdline.commands[i].cmd_flags & CMD_FLAG_SECONDARY_SYNTAX) && !longhelp)
+		if ((_cmdline.commands[i].cmd_flags & CMD_FLAG_SECONDARY_SYNTAX) && !show_full)
 			continue;
 
-		print_usage(&_cmdline.commands[i], longhelp, 1);
+		print_usage(&_cmdline.commands[i], show_full, 1);
 		cmd = &_cmdline.commands[i];
 	}
 
 	/* Common options are printed once for all variants of a command name. */
-	if (longhelp) {
+	if (show_full) {
 		print_usage_common_cmd(cname, cmd);
 		print_usage_common_lvm(cname, cmd);
-	} else
+	}
+
+	if (longhelp)
+		print_usage_notes(cname, cmd);
+	else
 		log_print("Use --longhelp to show all options and advanced commands.");
 
 	return 1;


