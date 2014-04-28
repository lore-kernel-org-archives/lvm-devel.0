From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 28 Apr 2014 08:27:15 +0000 (UTC)
Subject: master - libdevmapper: add dm_units_to_factor for size unit parsing
Message-ID: <20140428082715.89CD860CFC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4360fdf89c7f38c5de0d3e6d612f67ee915cba15
Commit:        4360fdf89c7f38c5de0d3e6d612f67ee915cba15
Parent:        75d399800ab60264d1201ad3fa1f9283542459f6
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Apr 28 10:25:43 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Apr 28 10:25:43 2014 +0200

libdevmapper: add dm_units_to_factor for size unit parsing

Actually moving the existing code from LVM to libdm for reuse.
---
 WHATS_NEW_DM               |    1 +
 lib/commands/toolcontext.c |    4 +-
 lib/display/display.c      |   99 -----------------------------------------
 lib/display/display.h      |    2 -
 libdm/libdevmapper.h       |   44 ++++++++++++++++++
 libdm/libdm-string.c       |  106 ++++++++++++++++++++++++++++++++++++++++++++
 tools/lvmcmdline.c         |    4 +-
 7 files changed, 155 insertions(+), 105 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 6a983a7..c81d354 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.88 - 
 =================================
+  Add dm_units_to_factor for size unit parsing.
   Increase bitset size for minors for thin dmeventd plugin.
 
 Version 1.02.85 - 10th April 2014
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index d62fb8a..b2f8293 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -282,8 +282,8 @@ static int _check_config(struct cmd_context *cmd)
 
 int process_profilable_config(struct cmd_context *cmd) {
 	if (!(cmd->default_settings.unit_factor =
-	      units_to_bytes(find_config_tree_str(cmd, global_units_CFG, NULL),
-			     &cmd->default_settings.unit_type))) {
+	      dm_units_to_factor(find_config_tree_str(cmd, global_units_CFG, NULL),
+				 &cmd->default_settings.unit_type, 1, NULL))) {
 		log_error("Invalid units specification");
 		return 0;
 	}
diff --git a/lib/display/display.c b/lib/display/display.c
index b7fbf1a..c93b2b3 100644
--- a/lib/display/display.c
+++ b/lib/display/display.c
@@ -20,8 +20,6 @@
 #include "toolcontext.h"
 #include "segtype.h"
 #include "defaults.h"
-#include <math.h>  /* fabs() */
-#include <float.h> /* DBL_EPSILON */
 #include <stdarg.h>
 
 #define SIZE_BUF 128
@@ -44,103 +42,6 @@ static const struct {
 
 static const int _num_policies = DM_ARRAY_SIZE(_policies);
 
-/* Test if the doubles are close enough to be considered equal */
-static int _close_enough(double d1, double d2)
-{
-	return fabs(d1 - d2) < DBL_EPSILON;
-}
-
-uint64_t units_to_bytes(const char *units, char *unit_type)
-{
-	char *ptr = NULL;
-	uint64_t v;
-	double custom_value = 0;
-	uint64_t multiplier;
-
-	if (isdigit(*units)) {
-		custom_value = strtod(units, &ptr);
-		if (ptr == units)
-			return 0;
-		v = (uint64_t) strtoull(units, NULL, 10);
-		if (_close_enough((double) v, custom_value))
-			custom_value = 0;	/* Use integer arithmetic */
-		units = ptr;
-	} else
-		v = 1;
-
-	/* Only one units char permitted. */
-	if (units[0] && units[1])
-		return 0;
-
-	if (v == 1)
-		*unit_type = *units;
-	else
-		*unit_type = 'U';
-
-	switch (*units) {
-	case 'h':
-	case 'H':
-		multiplier = v = UINT64_C(1);
-		*unit_type = *units;
-		break;
-	case 'b':
-	case 'B':
-		multiplier = UINT64_C(1);
-		break;
-#define KILO UINT64_C(1024)
-	case 's':
-	case 'S':
-		multiplier = (KILO/2);
-		break;
-	case 'k':
-		multiplier = KILO;
-		break;
-	case 'm':
-		multiplier = KILO * KILO;
-		break;
-	case 'g':
-		multiplier = KILO * KILO * KILO;
-		break;
-	case 't':
-		multiplier = KILO * KILO * KILO * KILO;
-		break;
-	case 'p':
-		multiplier = KILO * KILO * KILO * KILO * KILO;
-		break;
-	case 'e':
-		multiplier = KILO * KILO * KILO * KILO * KILO * KILO;
-		break;
-#undef KILO
-#define KILO UINT64_C(1000)
-	case 'K':
-		multiplier = KILO;
-		break;
-	case 'M':
-		multiplier = KILO * KILO;
-		break;
-	case 'G':
-		multiplier = KILO * KILO * KILO;
-		break;
-	case 'T':
-		multiplier = KILO * KILO * KILO * KILO;
-		break;
-	case 'P':
-		multiplier = KILO * KILO * KILO * KILO * KILO;
-		break;
-	case 'E':
-		multiplier = KILO * KILO * KILO * KILO * KILO * KILO;
-		break;
-#undef KILO
-	default:
-		return 0;
-	}
-
-	if (_close_enough(custom_value, 0.))
-		return v * multiplier; /* Use integer arithmetic */
-	else
-		return (uint64_t) (custom_value * multiplier);
-}
-
 char alloc_policy_char(alloc_policy_t alloc)
 {
 	int i;
diff --git a/lib/display/display.h b/lib/display/display.h
index 41fba03..d5c0efa 100644
--- a/lib/display/display.h
+++ b/lib/display/display.h
@@ -22,8 +22,6 @@
 
 #include <stdint.h>
 
-uint64_t units_to_bytes(const char *units, char *unit_type);
-
 /* Specify size in KB */
 const char *display_size(const struct cmd_context *cmd, uint64_t size);
 const char *display_size_long(const struct cmd_context *cmd, uint64_t size);
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 5f7b14c..8ffa145 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -1454,6 +1454,50 @@ void dm_unescape_colons_and_at_signs(char *src,
  */
 int dm_strncpy(char *dest, const char *src, size_t n);
 
+/*
+ * Recognize unit specifier in the 'units' arg and return a factor
+ * representing that unit. If the 'units' contains a prefix with digits,
+ * the 'units' is considered to be a custom unit.
+ *
+ * Also, set 'unit_type' output arg to the character that represents
+ * the unit specified. The 'unit_type' character equals to the unit
+ * character itself recognized in the 'units' arg for canonical units.
+ * Otherwise, the 'unit_type' character is set to 'U' for custom unit.
+ *
+ * An example for k/K canonical units and 8k/8K custom units:
+ *
+ *   units  unit_type  return value (factor)
+ *   k      k          1024
+ *   K      K          1000
+ *   8k     U          1024*8
+ *   8K     U          1000*8
+ *   etc...
+ *
+ * Recognized units:
+ *
+ *   h/H - human readable (returns 1 for both)
+ *   b/B - byte (returns 1 for both)
+ *   s/S - sector (returns 512 for both)
+ *   k/K - kilo (returns 1024/1000 respectively)
+ *   m/M - mega (returns 1024^2/1000^2 respectively)
+ *   g/G - giga (returns 1024^3/1000^3 respectively)
+ *   t/T - tera (returns 1024^4/1000^4 respectively)
+ *   p/P - peta (returns 1024^5/1000^5 respectively)
+ *   e/E - exa (returns 1024^6/1000^6 respectively)
+ *
+ * Only one units character is allowed in the 'units' arg
+ * if strict mode is enabled by 'strict' arg.
+ *
+ * The 'endptr' output arg, if not NULL, saves the pointer
+ * in the 'units' string which follows the unit specifier
+ * recognized (IOW the position where the parsing of the
+ * unit specifier stopped).
+ *
+ * Returns the unit factor or 0 if no unit is recognized.
+ */
+uint64_t dm_units_to_factor(const char *units, char *unit_type,
+			    int strict, char **endptr);
+
 /**************************
  * file/stream manipulation
  **************************/
diff --git a/libdm/libdm-string.c b/libdm/libdm-string.c
index 64a9792..7336e6b 100644
--- a/libdm/libdm-string.c
+++ b/libdm/libdm-string.c
@@ -16,6 +16,8 @@
 
 #include <ctype.h>
 #include <stdarg.h>
+#include <math.h>  /* fabs() */
+#include <float.h> /* DBL_EPSILON */
 
 /*
  * consume characters while they match the predicate function.
@@ -434,3 +436,107 @@ int dm_strncpy(char *dest, const char *src, size_t n)
 
 	return 0;
 }
+
+/* Test if the doubles are close enough to be considered equal */
+static int _close_enough(double d1, double d2)
+{
+	return fabs(d1 - d2) < DBL_EPSILON;
+}
+
+uint64_t dm_units_to_factor(const char *units, char *unit_type,
+			    int strict, char **endptr)
+{
+	char *ptr = NULL;
+	uint64_t v;
+	double custom_value = 0;
+	uint64_t multiplier;
+
+	if (endptr)
+		*endptr = (char *) units;
+
+	if (isdigit(*units)) {
+		custom_value = strtod(units, &ptr);
+		if (ptr == units)
+			return 0;
+		v = (uint64_t) strtoull(units, NULL, 10);
+		if (_close_enough((double) v, custom_value))
+			custom_value = 0;	/* Use integer arithmetic */
+		units = ptr;
+	} else
+		v = 1;
+
+	/* Only one units char permitted in strict mode. */
+	if (strict && units[0] && units[1])
+		return 0;
+
+	if (v == 1)
+		*unit_type = *units;
+	else
+		*unit_type = 'U';
+
+	switch (*units) {
+	case 'h':
+	case 'H':
+		multiplier = v = UINT64_C(1);
+		*unit_type = *units;
+		break;
+	case 'b':
+	case 'B':
+		multiplier = UINT64_C(1);
+		break;
+#define KILO UINT64_C(1024)
+	case 's':
+	case 'S':
+		multiplier = (KILO/2);
+		break;
+	case 'k':
+		multiplier = KILO;
+		break;
+	case 'm':
+		multiplier = KILO * KILO;
+		break;
+	case 'g':
+		multiplier = KILO * KILO * KILO;
+		break;
+	case 't':
+		multiplier = KILO * KILO * KILO * KILO;
+		break;
+	case 'p':
+		multiplier = KILO * KILO * KILO * KILO * KILO;
+		break;
+	case 'e':
+		multiplier = KILO * KILO * KILO * KILO * KILO * KILO;
+		break;
+#undef KILO
+#define KILO UINT64_C(1000)
+	case 'K':
+		multiplier = KILO;
+		break;
+	case 'M':
+		multiplier = KILO * KILO;
+		break;
+	case 'G':
+		multiplier = KILO * KILO * KILO;
+		break;
+	case 'T':
+		multiplier = KILO * KILO * KILO * KILO;
+		break;
+	case 'P':
+		multiplier = KILO * KILO * KILO * KILO * KILO;
+		break;
+	case 'E':
+		multiplier = KILO * KILO * KILO * KILO * KILO * KILO;
+		break;
+#undef KILO
+	default:
+		return 0;
+	}
+
+	if (endptr)
+		*endptr = (char *) units + 1;
+
+	if (_close_enough(custom_value, 0.))
+		return v * multiplier; /* Use integer arithmetic */
+	else
+		return (uint64_t) (custom_value * multiplier);
+}
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 758c429..7e4d9a6 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -923,8 +923,8 @@ static int _get_settings(struct cmd_context *cmd)
 
 	if (arg_count(cmd, units_ARG))
 		if (!(cmd->current_settings.unit_factor =
-		      units_to_bytes(arg_str_value(cmd, units_ARG, ""),
-				     &cmd->current_settings.unit_type))) {
+		      dm_units_to_factor(arg_str_value(cmd, units_ARG, ""),
+					 &cmd->current_settings.unit_type, 1, NULL))) {
 			log_error("Invalid units specification");
 			return EINVALID_CMD_LINE;
 		}


