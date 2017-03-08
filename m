From: David Teigland <teigland@sourceware.org>
Date: Wed, 8 Mar 2017 12:04:46 -0500
Subject: master - commands: combine duplicate arrays for lv types and props
Message-ID: <201703081704.v28H4klC031188@int-mx09.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=11f1556d5dbfb843f894b64d1e0cd2ff6197851a
Commit:        11f1556d5dbfb843f894b64d1e0cd2ff6197851a
Parent:        690f60473352e9909df95fae96a5d99b8b0c9db7
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Mar 7 12:08:23 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Mar 8 11:03:02 2017 -0600

commands: combine duplicate arrays for lv types and props

Like opt and val arrays in previous commit, combine duplicate
arrays for lv types and props in command.c and lvmcmdline.c.
Also move the command_names array to be defined in command.c
so it's consistent with the others.
---
 tools/command.c    |   48 ++++++++++++++++++++----------------------------
 tools/command.h    |   19 +++++++++++++++++++
 tools/lvconvert.c  |    8 ++++----
 tools/lvmcmdline.c |   26 +++++++-------------------
 tools/toollib.c    |   12 ++++++------
 tools/tools.h      |   19 ++-----------------
 6 files changed, 58 insertions(+), 74 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index 71056bf..bfd3d7d 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -167,22 +167,6 @@ enum {
 #include "command.h"       /* defines struct command */
 #include "command-count.h" /* defines COMMAND_COUNT */
 
-/* see lvp_names[] below, also see lv_props[] in tools.h and lv_props.h */
-
-struct lvp_name {
-	const char *enum_name; /* "is_foo_LVP" */
-	int lvp_enum;          /* is_foo_LVP */
-	const char *name;      /* "lv_is_foo" */
-};
-
-/* see lvt_names[] below, also see lv_types[] in tools.h and lv_types.h */
-
-struct lvt_name {
-	const char *enum_name; /* "foo_LVT" */
-	int lvt_enum;          /* foo_LVT */
-	const char *name;      /* "foo" */
-};
-
 /* see cmd_names[] below, one for each unique "ID" in command-lines.in */
 
 struct cmd_name {
@@ -209,16 +193,16 @@ struct opt_name opt_names[ARG_COUNT + 1] = {
 
 /* create table of lv property names, e.g. lv_is_foo, and corresponding enum from lv_props.h */
 
-struct lvp_name lvp_names[LVP_COUNT + 1] = {
-#define lvp(a, b, c) { # a, a, b },
+struct lv_prop lv_props[LVP_COUNT + 1] = {
+#define lvp(a, b, c) { # a, a, b, c },
 #include "lv_props.h"
 #undef lvp
 };
 
 /* create table of lv type names, e.g. linear and corresponding enum from lv_types.h */
 
-struct lvt_name lvt_names[LVT_COUNT + 1] = {
-#define lvt(a, b, c) { # a, a, b },
+struct lv_type lv_types[LVT_COUNT + 1] = {
+#define lvt(a, b, c) { # a, a, b, c },
 #include "lv_types.h"
 #undef lvt
 };
@@ -237,16 +221,24 @@ struct cmd_name cmd_names[CMD_COUNT + 1] = {
  */
 
 #ifdef MAN_PAGE_GENERATOR
+
 struct command_name command_names[MAX_COMMAND_NAMES] = {
 #define xx(a, b, c...) { # a, b, c },
 #include "commands.h"
 #undef xx
 };
 struct command commands[COMMAND_COUNT];
-#else
-extern struct command_name command_names[MAX_COMMAND_NAMES]; /* defined in lvmcmdline.c */
+
+#else /* MAN_PAGE_GENERATOR */
+
+struct command_name command_names[MAX_COMMAND_NAMES] = {
+#define xx(a, b, c...) { # a, b, c, a},
+#include "commands.h"
+#undef xx
+};
 extern struct command commands[COMMAND_COUNT]; /* defined in lvmcmdline.c */
-#endif
+
+#endif /* MAN_PAGE_GENERATOR */
 
 /* array of pointers into opt_names[] that is sorted alphabetically (by long opt name) */
 
@@ -422,8 +414,8 @@ static int lvp_name_to_enum(struct command *cmd, char *str)
 	int i;
 
 	for (i = 1; i < LVP_COUNT; i++) {
-		if (!strcmp(str, lvp_names[i].name))
-			return lvp_names[i].lvp_enum;
+		if (!strcmp(str, lv_props[i].name))
+			return lv_props[i].lvp_enum;
 	}
 
 	log_error("Parsing command defs: unknown lv property %s", str);
@@ -438,8 +430,8 @@ static int lvt_name_to_enum(struct command *cmd, char *str)
 	int i;
 
 	for (i = 1; i < LVT_COUNT; i++) {
-		if (!strcmp(str, lvt_names[i].name))
-			return lvt_names[i].lvt_enum;
+		if (!strcmp(str, lv_types[i].name))
+			return lv_types[i].lvt_enum;
 	}
 
 	log_error("Parsing command defs: unknown lv type %s", str);
@@ -1525,7 +1517,7 @@ int define_commands(char *run_name)
 
 static const char *lvt_enum_to_name(int lvt_enum)
 {
-	return lvt_names[lvt_enum].name;
+	return lv_types[lvt_enum].name;
 }
 
 static void _print_usage_description(struct command *cmd)
diff --git a/tools/command.h b/tools/command.h
index 7652d74..891349a 100644
--- a/tools/command.h
+++ b/tools/command.h
@@ -235,6 +235,25 @@ struct val_name {
 	const char *usage;
 };
 
+/* see global lv_props[] */
+
+struct lv_prop {
+	const char *enum_name; /* "is_foo_LVP" */
+	int lvp_enum;          /* is_foo_LVP */
+	const char *name;      /* "lv_is_foo" */
+	int (*fn) (struct cmd_context *cmd, struct logical_volume *lv); /* lv_is_foo() */
+};
+
+/* see global lv_types[] */
+
+struct lv_type {
+	const char *enum_name; /* "foo_LVT" */
+	int lvt_enum;          /* foo_LVT */
+	const char *name;      /* "foo" */
+	int (*fn) (struct cmd_context *cmd, struct logical_volume *lv); /* lv_is_foo() */
+};
+
+
 int define_commands(char *run_name);
 int command_id_to_enum(const char *str);
 void print_usage(struct command *cmd, int longhelp, int desc_first);
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index c82dab2..97d17e4 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2523,7 +2523,7 @@ static int _lvconvert_swap_pool_metadata(struct cmd_context *cmd,
 	struct volume_group *vg = lv->vg;
 	struct logical_volume *prev_metadata_lv;
 	struct lv_segment *seg;
-	struct lv_types *lvtype;
+	struct lv_type *lvtype;
 	char meta_name[NAME_LEN];
 	const char *swap_name;
 	uint32_t chunk_size;
@@ -3841,7 +3841,7 @@ static int _lvconvert_to_cache_vol_single(struct cmd_context *cmd,
 
 	if (!lv_is_cache_pool(cachepool_lv)) {
 		int lvt_enum = get_lvt_enum(cachepool_lv);
-		struct lv_types *lvtype = get_lv_type(lvt_enum);
+		struct lv_type *lvtype = get_lv_type(lvt_enum);
 
 		if (lvt_enum != striped_LVT && lvt_enum != linear_LVT && lvt_enum != raid_LVT) {
 			log_error("LV %s with type %s cannot be converted to a cache pool.",
@@ -3950,7 +3950,7 @@ static int _lvconvert_to_thin_with_external_single(struct cmd_context *cmd,
 
 	if (!lv_is_thin_pool(thinpool_lv)) {
 		int lvt_enum = get_lvt_enum(thinpool_lv);
-		struct lv_types *lvtype = get_lv_type(lvt_enum);
+		struct lv_type *lvtype = get_lv_type(lvt_enum);
 
 		if (lvt_enum != striped_LVT && lvt_enum != linear_LVT && lvt_enum != raid_LVT) {
 			log_error("LV %s with type %s cannot be converted to a thin pool.",
@@ -4274,7 +4274,7 @@ static int _lvconvert_raid_types_check(struct cmd_context *cmd, struct logical_v
 			int lv_is_named_arg)
 {
 	int lvt_enum = get_lvt_enum(lv);
-	struct lv_types *lvtype = get_lv_type(lvt_enum);
+	struct lv_type *lvtype = get_lv_type(lvt_enum);
 
 	if (!lv_is_visible(lv)) {
 		if (!lv_is_cache_pool_metadata(lv) &&
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 404641f..f46e283 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -63,29 +63,17 @@ extern struct opt_name opt_names[ARG_COUNT + 1];
 /*
  * Table of LV properties
  */
-static struct lv_props _lv_props[LVP_COUNT + 1] = {
-#define lvp(a, b, c) {a, b, c},
-#include "lv_props.h"
-#undef lvp
-};
+extern struct lv_prop lv_props[LVP_COUNT + 1];
 
 /*
  * Table of LV types
  */
-static struct lv_types _lv_types[LVT_COUNT + 1] = {
-#define lvt(a, b, c) {a, b, c},
-#include "lv_types.h"
-#undef lvt
-};
+extern struct lv_type lv_types[LVT_COUNT + 1];
 
 /*
  * Table of command names
  */
-struct command_name command_names[MAX_COMMAND_NAMES] = {
-#define xx(a, b, c...) { # a, b, c, a},
-#include "commands.h"
-#undef xx
-};
+extern struct command_name command_names[MAX_COMMAND_NAMES];
 
 /*
  * Table of commands (as defined in command-lines.in)
@@ -1197,18 +1185,18 @@ int lvm_register_commands(char *name)
 	return 1;
 }
 
-struct lv_props *get_lv_prop(int lvp_enum)
+struct lv_prop *get_lv_prop(int lvp_enum)
 {
 	if (!lvp_enum)
 		return NULL;
-	return &_lv_props[lvp_enum];
+	return &lv_props[lvp_enum];
 }
 
-struct lv_types *get_lv_type(int lvt_enum)
+struct lv_type *get_lv_type(int lvt_enum)
 {
 	if (!lvt_enum)
 		return NULL;
-	return &_lv_types[lvt_enum];
+	return &lv_types[lvt_enum];
 }
 
 struct command *get_command(int cmd_enum)
diff --git a/tools/toollib.c b/tools/toollib.c
index 0e45d80..f2951a7 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -2366,7 +2366,7 @@ void opt_array_to_str(struct cmd_context *cmd, int *opts, int count,
 
 static void lvp_bits_to_str(uint64_t bits, char *buf, int len)
 {
-	struct lv_props *prop;
+	struct lv_prop *prop;
 	int lvp_enum;
 	int pos = 0;
 	int ret;
@@ -2387,7 +2387,7 @@ static void lvp_bits_to_str(uint64_t bits, char *buf, int len)
 
 static void lvt_bits_to_str(uint64_t bits, char *buf, int len)
 {
-	struct lv_types *type;
+	struct lv_type *type;
 	int lvt_enum;
 	int pos = 0;
 	int ret;
@@ -2593,7 +2593,7 @@ int get_lvt_enum(struct logical_volume *lv)
 static int _lv_types_match(struct cmd_context *cmd, struct logical_volume *lv, uint64_t lvt_bits,
 			   uint64_t *match_bits, uint64_t *unmatch_bits)
 {
-	struct lv_types *type;
+	struct lv_type *type;
 	int lvt_enum;
 	int found_a_match = 0;
 	int match;
@@ -2642,7 +2642,7 @@ static int _lv_types_match(struct cmd_context *cmd, struct logical_volume *lv, u
 static int _lv_props_match(struct cmd_context *cmd, struct logical_volume *lv, uint64_t lvp_bits,
 			   uint64_t *match_bits, uint64_t *unmatch_bits)
 {
-	struct lv_props *prop;
+	struct lv_prop *prop;
 	int lvp_enum;
 	int found_a_mismatch = 0;
 	int match;
@@ -2697,7 +2697,7 @@ static int _check_lv_types(struct cmd_context *cmd, struct logical_volume *lv, i
 	ret = _lv_types_match(cmd, lv, cmd->command->required_pos_args[pos-1].def.lvt_bits, NULL, NULL);
 	if (!ret) {
 		int lvt_enum = get_lvt_enum(lv);
-		struct lv_types *type = get_lv_type(lvt_enum);
+		struct lv_type *type = get_lv_type(lvt_enum);
 		log_warn("Operation on LV %s which has invalid type %s.",
 			 display_lvname(lv), type ? type->name : "unknown");
 	}
@@ -2711,7 +2711,7 @@ static int _check_lv_rules(struct cmd_context *cmd, struct logical_volume *lv)
 {
 	char buf[64];
 	struct cmd_rule *rule;
-	struct lv_types *lvtype = NULL;
+	struct lv_type *lvtype = NULL;
 	uint64_t lv_props_match_bits, lv_props_unmatch_bits;
 	uint64_t lv_types_match_bits, lv_types_unmatch_bits;
 	int opts_match_count, opts_unmatch_count;
diff --git a/tools/tools.h b/tools/tools.h
index cb3ffa0..fe3699e 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -114,21 +114,6 @@ struct arg_value_group_list {
 	uint32_t prio;
 };
 
-/* a global table of possible LV properties */
-struct lv_props {
-	int lvp_enum; /* is_foo_LVP from lv_props.h */
-	const char *name; /* "lv_is_foo" used in command-lines.in */
-	int (*fn) (struct cmd_context *cmd, struct logical_volume *lv); /* lv_is_foo() */
-};
-
-/* a global table of possible LV types */
-/* (as exposed externally in command line interface, not exactly as internal segtype is used) */
-struct lv_types {
-	int lvt_enum; /* is_foo_LVT from lv_types.h */
-	const char *name; /* "foo" used in command-lines.in, i.e. LV_foo */
-	int (*fn) (struct cmd_context *cmd, struct logical_volume *lv); /* lv_is_foo() */
-};
-
 #define CACHE_VGMETADATA	0x00000001
 #define PERMITTED_READ_ONLY 	0x00000002
 /* Process all VGs if none specified on the command line. */
@@ -232,8 +217,8 @@ int vgchange_activate(struct cmd_context *cmd, struct volume_group *vg,
 
 int vgchange_background_polling(struct cmd_context *cmd, struct volume_group *vg);
 
-struct lv_props *get_lv_prop(int lvp_enum);
-struct lv_types *get_lv_type(int lvt_enum);
+struct lv_prop *get_lv_prop(int lvp_enum);
+struct lv_type *get_lv_type(int lvt_enum);
 struct command *get_command(int cmd_enum);
 
 int lvchange_properties_cmd(struct cmd_context *cmd, int argc, char **argv);


