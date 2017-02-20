From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 20 Feb 2017 23:06:34 +0000 (UTC)
Subject: master - man: add variables descriptions
Message-ID: <20170220230634.099466134D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2396c506890e62da5d13c4f3bcd1f715272ab382
Commit:        2396c506890e62da5d13c4f3bcd1f715272ab382
Parent:        4d29d9afb21a4571b45fe18d16cc4b57cd7ec187
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Feb 20 15:09:02 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Feb 20 15:36:10 2017 -0600

man: add variables descriptions

Add a section describing variables.

In the full options list, include common
options in the alphabetical listing instead
of at the end.
---
 tools/command.c |  172 ++++++++++++++++++++++++++++++++++++++++++++++++-------
 1 files changed, 152 insertions(+), 20 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index 06dcc77..b1fdc1b 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -2484,35 +2484,20 @@ void print_man_all_options_list(struct command_name *cname)
 /*
  * All options used for a given command name, along with descriptions.
  * listed in order of:
- * 1. options that are not common to all lvm commands, alphabetically
- * 2. options common to all lvm commands, alphabetically
  */
 
 void print_man_all_options_desc(struct command_name *cname)
 {
 	int opt_enum, val_enum;
-	int print_common = 0;
 	int sep = 0;
 	int i;
 
- again:
-	/*
-	 * Loop 1: print options that are not common to all lvm commands.
-	 * Loop 2: print options common to all lvm commands (lvm_all)
-	 */
-
 	for (i = 0; i < ARG_COUNT; i++) {
 		opt_enum = opt_names_alpha[i]->opt_enum;
 
 		if (!cname->all_options[opt_enum])
 			continue;
 
-		if (!print_common && is_lvm_all_opt(opt_enum))
-			continue;
-
-		if (print_common && !is_lvm_all_opt(opt_enum))
-			continue;
-
 		printf("\n.TP\n");
 
 		if (opt_names[opt_enum].short_opt) {
@@ -2545,11 +2530,153 @@ void print_man_all_options_desc(struct command_name *cname)
 
 		sep = 1;
 	}
+}
 
-	if (!print_common) {
-		print_common = 1;
-		goto again;
+void print_man_all_positions_desc(struct command_name *cname)
+{
+	struct command *cmd;
+	int ci, rp, op;
+	int has_vg_val = 0;
+	int has_lv_val = 0;
+	int has_pv_val = 0;
+	int has_tag_val = 0;
+	int has_select_val = 0;
+	int has_lv_type = 0;
+
+	for (ci = 0; ci < COMMAND_COUNT; ci++) {
+		cmd = &commands[ci];
+
+		if (strcmp(cmd->name, cname->name))
+			continue;
+
+		for (rp = 0; rp < cmd->rp_count; rp++) {
+			if (cmd->required_pos_args[rp].def.val_bits & val_enum_to_bit(vg_VAL))
+				has_vg_val = 1;
+
+			if (cmd->required_pos_args[rp].def.val_bits & val_enum_to_bit(lv_VAL)) {
+				has_lv_val = 1;
+				if (cmd->required_pos_args[rp].def.lvt_bits)
+					has_lv_type = 1;
+			}
+
+			if (cmd->required_pos_args[rp].def.val_bits & val_enum_to_bit(pv_VAL))
+				has_pv_val = 1;
+
+			if (cmd->required_pos_args[rp].def.val_bits & val_enum_to_bit(tag_VAL))
+				has_tag_val = 1;
+
+			if (cmd->required_pos_args[rp].def.val_bits & val_enum_to_bit(select_VAL))
+				has_select_val = 1;
+		}
+
+		for (op = 0; op < cmd->op_count; op++) {
+			if (cmd->optional_pos_args[op].def.val_bits & val_enum_to_bit(vg_VAL))
+				has_vg_val = 1;
+
+			if (cmd->optional_pos_args[op].def.val_bits & val_enum_to_bit(lv_VAL)) {
+				has_lv_val = 1;
+				if (cmd->optional_pos_args[op].def.lvt_bits)
+					has_lv_type = 1;
+			}
+
+			if (cmd->optional_pos_args[op].def.val_bits & val_enum_to_bit(pv_VAL))
+				has_pv_val = 1;
+
+			if (cmd->optional_pos_args[op].def.val_bits & val_enum_to_bit(tag_VAL))
+				has_tag_val = 1;
+
+			if (cmd->optional_pos_args[op].def.val_bits & val_enum_to_bit(select_VAL))
+				has_select_val = 1;
+		}
+	}
+
+	if (has_vg_val) {
+		printf("\n.TP\n");
+
+		printf("\\fI%s\\fP", val_names[vg_VAL].name);
+		printf("\n");
+		printf(".br\n");
+		printf("Volume Group name.  See \\fBlvm\\fP(8) for valid names.\n");
+
+		if (!strcmp(cname->name, "lvcreate"))
+			printf("For lvcreate, the required VG positional arg may be\n"
+			       "omitted when the VG name is included in another option,\n"
+			       "e.g. --name VG/LV.\n");
 	}
+
+	if (has_lv_val) {
+		printf("\n.TP\n");
+
+		printf("\\fI%s\\fP", val_names[lv_VAL].name);
+		printf("\n");
+		printf(".br\n");
+		printf("Logical Volume name.  See \\fBlvm\\fP(8) for valid names.\n"
+		       "An LV positional arg generally includes the VG name and LV name, e.g. VG/LV.\n");
+
+		if (has_lv_type)
+			printf("LV followed by _<type> indicates that an LV of the\n"
+			       "given type is required. (raid represents raid<N> type)\n");
+	}
+
+	if (has_pv_val) {
+		printf("\n.TP\n");
+
+		printf("\\fI%s\\fP", val_names[pv_VAL].name);
+		printf("\n");
+		printf(".br\n");
+		printf("Physical Volume name, a device path under /dev.\n"
+		       "For commands managing physical extents, a PV positional arg\n"
+		       "generally accepts a suffix indicating a range of physical extents.\n"
+		       "Start and end range (inclusive): \\fIPV\\fP[:\\fIPE\\fP[-\\fIPE\\fP].\n"
+		       "Start and length range (counting from 0): \\fIPV\\fP[:\\fIPE\\fP[+\\fIPE\\fP].\n");
+	}
+
+	if (has_tag_val) {
+		printf("\n.TP\n");
+
+		printf("\\fI%s\\fP", val_names[tag_VAL].name);
+		printf("\n");
+		printf(".br\n");
+		printf("Tag name.  See \\fBlvm\\fP(8) for information about tag names and using tags\n"
+		       "in place of a VG, LV or PV.\n");
+	}
+
+	if (has_select_val) {
+		printf("\n.TP\n");
+
+		printf("\\fI%s\\fP", val_names[select_VAL].name);
+		printf("\n");
+		printf(".br\n");
+		printf("Select indicates that a required positional parameter can\n"
+		       "be omitted if the \\fB--select\\fP option is used.\n"
+		       "No arg appears in this position.\n");
+	}
+
+	/* Every command uses a string arg somewhere. */
+
+	printf("\n.TP\n");
+	printf("\\fI%s\\fP", val_names[string_VAL].name);
+	printf("\n");
+	printf(".br\n");
+	printf("See the option description for information about the string content.\n");
+
+	/* Nearly every command uses a number arg somewhere. */
+
+	printf("\n.TP\n");
+	printf("\\fINumber\\fP, \\fISize\\fP");
+	printf("\n");
+	printf(".br\n");
+	printf("Input units are always treated as base two values, regardless of unit\n"
+	       "capitalization, e.g. 'k' and 'K' both refer to 1024.\n"
+	       "The default input unit is specified by letter, followed by |unit which\n"
+	       "represents other possible input units: bBsSkKmMgGtTpPeE.\n");
+
+	printf("\n.TP\n");
+	printf("Environment");
+	printf("\n");
+	printf(".br\n");
+	printf("See \\fBlvm\\fP(8) for information about environment variables used by lvm.\n"
+	       "For example, LVM_VG_NAME can generally be substituted for a required VG parameter.\n");
 }
 
 void print_desc_man(const char *desc)
@@ -2641,7 +2768,7 @@ void print_man(char *name, char *des_file, int include_primary, int include_seco
 
 	cname = find_command_name(name);
 
-	printf(".TH %s 8 \"LVM TOOLS #VERSION#\" \"Sistina Software UK\"\n",
+	printf(".TH %s 8 \"LVM TOOLS #VERSION#\" \"Red Hat, Inc.\"\n",
 		upper_command_name(lvmname));
 
 	for (i = 0; i < COMMAND_COUNT; i++) {
@@ -2657,6 +2784,9 @@ void print_man(char *name, char *des_file, int include_primary, int include_seco
 			printf(".SH OPTIONS\n");
 			printf(".br\n");
 			print_man_all_options_desc(cname);
+			printf(".SH VARIABLES\n");
+			printf(".br\n");
+			print_man_all_positions_desc(cname);
 
 			prev_cmd = NULL;
 		}
@@ -2752,7 +2882,9 @@ void print_man(char *name, char *des_file, int include_primary, int include_seco
 			printf(".SH OPTIONS\n");
 			printf(".br\n");
 			print_man_all_options_desc(cname);
-
+			printf(".SH VARIABLES\n");
+			printf(".br\n");
+			print_man_all_positions_desc(cname);
 		}
 
 		printf("\n");


