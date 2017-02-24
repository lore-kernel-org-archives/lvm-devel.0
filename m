From: David Teigland <teigland@fedoraproject.org>
Date: Fri, 24 Feb 2017 19:45:09 +0000 (UTC)
Subject: master - man: use Size variable for a number with unit
Message-ID: <20170224194509.AF40960228@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=74ba326007205ebbb5afca7c8f74a8b19e9dcb50
Commit:        74ba326007205ebbb5afca7c8f74a8b19e9dcb50
Parent:        189fa647931834b0d9cb30c20d16785b8e8923c9
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Feb 24 13:44:05 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Feb 24 13:44:05 2017 -0600

man: use Size variable for a number with unit

Define a separate variable type Size to represent
a number that takes an optional UNIT.
---
 tools/args.h       |    2 +-
 tools/command.c    |   25 +++++++++++++++----------
 tools/lvmcmdline.c |    4 ++--
 tools/tools.h      |    2 +-
 tools/vals.h       |   22 +++++++++++-----------
 5 files changed, 30 insertions(+), 25 deletions(-)

diff --git a/tools/args.h b/tools/args.h
index 036aa87..dd25007 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -987,7 +987,7 @@ arg(logicalvolume_ARG, 'l', "logicalvolume", uint32_VAL, 0, 0,
 arg(maxlogicalvolumes_ARG, 'l', "maxlogicalvolumes", uint32_VAL, 0, 0,
     "Sets the maximum number of LVs allowed in a VG.\n")
 
-arg(extents_ARG, 'l', "extents", numsignedper_VAL, 0, 0,
+arg(extents_ARG, 'l', "extents", extents_VAL, 0, 0,
     "#lvcreate\n"
     "Specifies the size of the new LV in logical extents.\n"
     "The --size and --extents options are alternate methods of specifying size.\n"
diff --git a/tools/command.c b/tools/command.c
index 8d5a96b..4e7c009 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -79,7 +79,7 @@ static inline int size_mb_arg_with_percent(struct cmd_context *cmd, struct arg_v
 static inline int int_arg(struct cmd_context *cmd, struct arg_values *av) { return 0; }
 static inline int uint32_arg(struct cmd_context *cmd, struct arg_values *av) { return 0; }
 static inline int int_arg_with_sign(struct cmd_context *cmd, struct arg_values *av) { return 0; }
-static inline int int_arg_with_sign_and_percent(struct cmd_context *cmd, struct arg_values *av) { return 0; }
+static inline int extents_arg(struct cmd_context *cmd, struct arg_values *av) { return 0; }
 static inline int major_arg(struct cmd_context *cmd, struct arg_values *av) { return 0; }
 static inline int minor_arg(struct cmd_context *cmd, struct arg_values *av) { return 0; }
 static inline int string_arg(struct cmd_context *cmd, struct arg_values *av) { return 0; }
@@ -1792,13 +1792,13 @@ static void print_val_man(const char *str)
 	 * that isn't already obvious.
 	 */
 
-	if (!strcmp(str, "Number[k|UNIT]")) {
-		printf("\\fINumber\\fP[k|UNIT]");
+	if (!strcmp(str, "Size[k|UNIT]")) {
+		printf("\\fISize\\fP[k|UNIT]");
 		return;
 	}
 
-	if (!strcmp(str, "Number[m|UNIT]")) {
-		printf("\\fINumber\\fP[m|UNIT]");
+	if (!strcmp(str, "Size[m|UNIT]")) {
+		printf("\\fISize\\fP[m|UNIT]");
 		return;
 	}
 
@@ -2807,16 +2807,21 @@ void print_man_all_positions_desc(struct command_name *cname)
 	printf(".br\n");
 	printf("See the option description for information about the string content.\n");
 
-	/* Nearly every command uses a number arg somewhere. */
+	/*
+	 * We could possibly check if the command accepts any option that
+	 * uses Size, and only print this in those cases, but this seems
+	 * so common that we should probably always print it.
+	 */
 
 	printf("\n.HP\n");
-	printf("\\fINumber\\fP, UNIT");
+	printf("\\fISize\\fP[UNIT]");
 	printf("\n");
 	printf(".br\n");
-	printf("Input units are always treated as base two values, regardless of unit\n"
+	printf("Size is an input number that accepts an optional unit.\n"
+	       "Input units are always treated as base two values, regardless of\n"
 	       "capitalization, e.g. 'k' and 'K' both refer to 1024.\n"
-	       "The default input unit is specified by letter, followed by |UNIT\n"
-	       "which represents other possible input units: \\fBbBsSkKmMgGtTpPeE\\fP.\n"
+	       "The default input unit is specified by letter, followed by |UNIT.\n"
+	       "UNIT represents other possible input units: \\fBbBsSkKmMgGtTpPeE\\fP.\n"
 	       "(This should not be confused with the output control --units, where\n"
 	       "capital letters mean multiple of 1000.)\n");
 
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 02266c9..9b20d9f 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -672,8 +672,8 @@ int int_arg_with_sign(struct cmd_context *cmd __attribute__((unused)), struct ar
 	return 1;
 }
 
-int int_arg_with_sign_and_percent(struct cmd_context *cmd __attribute__((unused)),
-				  struct arg_values *av)
+int extents_arg(struct cmd_context *cmd __attribute__((unused)),
+		struct arg_values *av)
 {
 	char *ptr;
 
diff --git a/tools/tools.h b/tools/tools.h
index 62db506..1e1e7f1 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -188,7 +188,7 @@ int size_mb_arg_with_percent(struct cmd_context *cmd, struct arg_values *av);
 int int_arg(struct cmd_context *cmd, struct arg_values *av);
 int uint32_arg(struct cmd_context *cmd, struct arg_values *av);
 int int_arg_with_sign(struct cmd_context *cmd, struct arg_values *av);
-int int_arg_with_sign_and_percent(struct cmd_context *cmd, struct arg_values *av);
+int extents_arg(struct cmd_context *cmd, struct arg_values *av);
 int major_arg(struct cmd_context *cmd, struct arg_values *av);
 int minor_arg(struct cmd_context *cmd, struct arg_values *av);
 int string_arg(struct cmd_context *cmd, struct arg_values *av);
diff --git a/tools/vals.h b/tools/vals.h
index a94f81b..d485926 100644
--- a/tools/vals.h
+++ b/tools/vals.h
@@ -79,13 +79,13 @@
  * options included in the usage text below that should
  * be removed?  Should "lvm1" be removed?
  *
- * For Number args that take optional units, a full usage
- * could be "Number[bBsSkKmMgGtTpPeE]" (with implied |),
- * but repeating this full specification produces cluttered
- * output, and doesn't indicate which unit is the default.
- * "Number[Units]" would be cleaner, as would a subset of
- * common units, e.g. "Number[kmg...]", but neither helps
- * with default.  "Number[k|UNIT]" and "Number[m|UNIT]" show
+ * Size is a Number that takes an optional unit.
+ * A full usage could be "Size[b|B|s|S|k|K|m|M|g|G|t|T|p|P|e|E]"
+ * but repeating this full specification produces long and
+ * cluttered output, and doesn't indicate which unit is the default.
+ * "Size[Units]" would be cleaner, as would a subset of
+ * common units, e.g. "Size[kmg...]", but neither helps
+ * with default.  "Size[k|UNIT]" and "Size[m|UNIT]" show
  * the default, and "UNIT" indicates that other units
  * are possible without listing them all.  This also
  * suggests using the preferred lower case letters, because
@@ -115,11 +115,11 @@ val(activation_VAL, activation_arg, "Active", "y|n|ay")
 val(cachemode_VAL, cachemode_arg, "CacheMode", "writethrough|writeback")
 val(discards_VAL, discards_arg, "Discards", "passdown|nopassdown|ignore")
 val(mirrorlog_VAL, mirrorlog_arg, "MirrorLog", "core|disk")
-val(sizekb_VAL, size_kb_arg, "SizeKB", "Number[k|UNIT]")
-val(sizemb_VAL, size_mb_arg, "SizeMB", "Number[m|UNIT]")
-val(regionsize_VAL, regionsize_arg, "RegionSize", "Number[m|UNIT]")
+val(sizekb_VAL, size_kb_arg, "SizeKB", "Size[k|UNIT]")
+val(sizemb_VAL, size_mb_arg, "SizeMB", "Size[m|UNIT]")
+val(regionsize_VAL, regionsize_arg, "RegionSize", "Size[m|UNIT]")
 val(numsigned_VAL, int_arg_with_sign, "SNumber", "[+|-]Number")
-val(numsignedper_VAL, int_arg_with_sign_and_percent, "SNumberP", "[+|-]Number[%VG|%PVS|%FREE]")
+val(extents_VAL, extents_arg, "Extents", "[+|-]Number[%VG|%PVS|%FREE]")
 val(permission_VAL, permission_arg, "Permission", "rw|r")
 val(metadatatype_VAL, metadatatype_arg, "MetadataType", "lvm2|lvm1")
 val(units_VAL, string_arg, "Units", "r|R|h|H|b|B|s|S|k|K|m|M|g|G|t|T|p|P|e|E")


