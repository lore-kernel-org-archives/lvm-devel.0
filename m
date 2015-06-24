From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 24 Jun 2015 09:27:37 +0000 (UTC)
Subject: master - config: add support for config value formatting flags
Message-ID: <20150624092737.3B97E610D1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9465963faf485dc5ae58b1c5aafa02a615411572
Commit:        9465963faf485dc5ae58b1c5aafa02a615411572
Parent:        c5ba60827ea720679c70f51b6ee7e999750e44e3
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jun 23 13:02:45 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jun 24 11:13:37 2015 +0200

config: add support for config value formatting flags

There are two basic groups of formatting flags (32 bits):
  - common ones applicable for all config value types (lower 16 bits)
  - type-related formatting flags (higher 16 bits)

With this patch, we initially support four new flags that
modify the the way the config value is displayed:

  Common flags:
  =============

  DM_CONFIG_VALUE_FMT_COMMON_ARRAY - causes array config values
    to be enclosed in "[ ]" even if there's only one item
    (previously, there was no way to recognize an array with one
     item and scalar value, hence array values with one member
     were always displayed without "[ ]" which libdm accepted
     when reading, but it may have been misleading for users)

  DM_CONFIG_VALUE_FMT_COMMON_EXTRA_SPACE - causes extra spaces to
    be inserted in "key = value" (or key = [ value, value, ... ] in
    case of arrays), compared to "key=value" seen on output before.
    This makes the output more readable for users.

  Type-related flags:
  ===================

  DM_CONFIG_VALUE_FMT_INT_OCTAL - prints integers in octal form with
    "0" as a prefix (libdm's config reading code can handle this via
    strtol just fine so it's properly recognized as number in octal
    form already if there's "0" used as prefix)

  DM_CONFIG_VALUE_FMT_STRING_NO_QUOTES - makes it possible to print
    strings without enclosing " "

This patch also adds dm_config_value_set_format_flags and
dm_config_value_get_format_flags functions to set and get
these formatting flags.
---
 lib/config/config.c                 |   32 ++++++++++++++++++-----
 lib/config/config.h                 |    2 +
 lib/config/config_settings.h        |    1 +
 libdm/.exported_symbols.DM_1_02_100 |    2 +
 libdm/libdevmapper.h                |   19 ++++++++++++++
 libdm/libdm-config.c                |   48 +++++++++++++++++++++++++++++------
 6 files changed, 89 insertions(+), 15 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index 32b3c66..6f9d413 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -667,7 +667,8 @@ static void _log_type_error(const char *path, cfg_def_type_t actual,
 }
 
 static struct dm_config_value *_get_def_array_values(struct dm_config_tree *cft,
-						     const cfg_def_item_t *def)
+						     const cfg_def_item_t *def,
+						     uint32_t format_flags)
 {
 	char *enc_value, *token, *p, *r;
 	struct dm_config_value *array = NULL, *v = NULL, *oldv = NULL;
@@ -678,6 +679,7 @@ static struct dm_config_value *_get_def_array_values(struct dm_config_tree *cft,
 			return NULL;
 		}
 		array->type = DM_CFG_EMPTY_ARRAY;
+		dm_config_value_set_format_flags(array, format_flags);
 		return array;
 	}
 
@@ -710,6 +712,9 @@ static struct dm_config_value *_get_def_array_values(struct dm_config_tree *cft,
 			dm_free(enc_value);
 			return NULL;
 		}
+
+		dm_config_value_set_format_flags(v, format_flags);
+
 		if (oldv)
 			oldv->next = v;
 		if (!array)
@@ -839,7 +844,7 @@ static int _check_value_differs_from_default(struct cft_check_handle *handle,
 	}
 
 	if (!v_def && (def->type & CFG_TYPE_ARRAY)) {
-		if (!(v_def_array = v_def_iter = _get_def_array_values(handle->cft, def)))
+		if (!(v_def_array = v_def_iter = _get_def_array_values(handle->cft, def, 0)))
 			return_0;
 		do {
 			/* iterate over each element of the array and check its value */
@@ -1739,15 +1744,19 @@ static struct dm_config_node *_add_def_node(struct dm_config_tree *cft,
 {
 	struct dm_config_node *cn;
 	const char *str;
+	uint32_t format_flags = 0;
 
 	if (!(cn = dm_config_create_node(cft, def->name))) {
 		log_error("Failed to create default config setting node.");
 		return NULL;
 	}
 
-	if (!(def->type & CFG_TYPE_SECTION) && (!(cn->v = dm_config_create_value(cft)))) {
-		log_error("Failed to create default config setting node value.");
-		return NULL;
+	if (!(def->type & CFG_TYPE_SECTION) && !(def->type & CFG_TYPE_ARRAY)) {
+		if (!(cn->v = dm_config_create_value(cft))) {
+			log_error("Failed to create default config setting node value.");
+			return NULL;
+		}
+		format_flags |= DM_CONFIG_VALUE_FMT_COMMON_EXTRA_SPACES;
 	}
 
 	cn->id = def->id;
@@ -1755,6 +1764,9 @@ static struct dm_config_node *_add_def_node(struct dm_config_tree *cft,
 	if (spec->unconfigured && def->default_unconfigured_value.v_UNCONFIGURED) {
 		cn->v->type = DM_CFG_STRING;
 		cn->v->v.str = cfg_def_get_default_unconfigured_value_hint(spec->cmd, def);
+		if (def->type != CFG_TYPE_STRING)
+			format_flags |= DM_CONFIG_VALUE_FMT_STRING_NO_QUOTES;
+		dm_config_value_set_format_flags(cn->v, format_flags);
 	} else if (!(def->type & CFG_TYPE_ARRAY)) {
 		switch (def->type) {
 			case CFG_TYPE_SECTION:
@@ -1767,6 +1779,8 @@ static struct dm_config_node *_add_def_node(struct dm_config_tree *cft,
 			case CFG_TYPE_INT:
 				cn->v->type = DM_CFG_INT;
 				cn->v->v.i = cfg_def_get_default_value_hint(spec->cmd, def, CFG_TYPE_INT, NULL);
+				if (def->flags & CFG_FORMAT_INT_OCTAL)
+					format_flags |= DM_CONFIG_VALUE_FMT_INT_OCTAL;
 				break;
 			case CFG_TYPE_FLOAT:
 				cn->v->type = DM_CFG_FLOAT;
@@ -1783,8 +1797,12 @@ static struct dm_config_node *_add_def_node(struct dm_config_tree *cft,
 				return NULL;
 				break;
 		}
-	} else
-		cn->v = _get_def_array_values(cft, def);
+		dm_config_value_set_format_flags(cn->v, format_flags);
+	} else {
+		format_flags |= (DM_CONFIG_VALUE_FMT_COMMON_ARRAY |
+				 DM_CONFIG_VALUE_FMT_COMMON_EXTRA_SPACES);
+		cn->v = _get_def_array_values(cft, def, format_flags);
+	}
 
 	cn->child = NULL;
 	if (parent) {
diff --git a/lib/config/config.h b/lib/config/config.h
index 0b7221c..b03ad6b 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -119,6 +119,8 @@ typedef union {
 #define CFG_DEFAULT_RUN_TIME	0x100
 /* whether the configuration setting is disabled (and hence defaults always used) */
 #define CFG_DISABLED		0x200
+/* whether to print integers in octal form (prefixed by "0") */
+#define CFG_FORMAT_INT_OCTAL	0x400
 
 /* configuration definition item structure */
 typedef struct cfg_def_item {
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 5c7b132..f8ea579 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -50,6 +50,7 @@
  *                                 CFG_DEFAULT_UNDEFINED - node's default value is undefined (depends on other system/kernel values outside of lvm)
  *                                 CFG_DEFAULT_COMMENTED - node's default value is commented out on output
  *                                 CFG_DISABLED - configuration is disabled (defaults always used)
+ *                                 CFG_FORMAT_INT_OCTAL - print integer number in octal form (also prefixed by "0")
  *
  * type:		       Allowed type for the value of simple configuation setting, one of:
  *                                 CFG_TYPE_BOOL
diff --git a/libdm/.exported_symbols.DM_1_02_100 b/libdm/.exported_symbols.DM_1_02_100
new file mode 100644
index 0000000..00d7d5b
--- /dev/null
+++ b/libdm/.exported_symbols.DM_1_02_100
@@ -0,0 +1,2 @@
+dm_config_value_set_format_flags
+dm_config_value_get_format_flags
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index cbd4f3d..7476aef 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -1847,6 +1847,7 @@ struct dm_config_value {
 	} v;
 
 	struct dm_config_value *next;	/* For arrays */
+	uint32_t format_flags;
 };
 
 struct dm_config_node {
@@ -1949,6 +1950,24 @@ struct dm_config_node *dm_config_create_node(struct dm_config_tree *cft, const c
 struct dm_config_value *dm_config_create_value(struct dm_config_tree *cft);
 struct dm_config_node *dm_config_clone_node(struct dm_config_tree *cft, const struct dm_config_node *cn, int siblings);
 
+/*
+ * Common formatting flags applicable to all config node types (lower 16 bits).
+ */
+#define DM_CONFIG_VALUE_FMT_COMMON_ARRAY             0x00000001 /* value is array */
+#define DM_CONFIG_VALUE_FMT_COMMON_EXTRA_SPACES      0x00000002 /* add spaces in "key = value" pairs in constrast to "key=value" for better readability */
+
+/*
+ * Type-related config node formatting flags (higher 16 bits).
+ */
+/* int-related formatting flags */
+#define DM_CONFIG_VALUE_FMT_INT_OCTAL                0x00010000 /* print number in octal form */
+
+/* string-related formatting flags */
+#define DM_CONFIG_VALUE_FMT_STRING_NO_QUOTES         0x00010000 /* do not print quotes around string value */
+
+void dm_config_value_set_format_flags(struct dm_config_value *cv, uint32_t format_flags);
+uint32_t dm_config_value_get_format_flags(struct dm_config_value *cv);
+
 struct dm_pool *dm_config_memory(struct dm_config_tree *cft);
 
 /* Udev device directory. */
diff --git a/libdm/libdm-config.c b/libdm/libdm-config.c
index f7b07a5..7b28972 100644
--- a/libdm/libdm-config.c
+++ b/libdm/libdm-config.c
@@ -273,11 +273,13 @@ static int _line_end(const struct dm_config_node *cn, struct config_output *out)
 static int _write_value(struct config_output *out, const struct dm_config_value *v)
 {
 	char *buf;
+	const char *s;
 
 	switch (v->type) {
 	case DM_CFG_STRING:
 		buf = alloca(dm_escaped_len(v->v.str));
-		line_append("\"%s\"", dm_escape_double_quotes(buf, v->v.str));
+		s = (v->format_flags & DM_CONFIG_VALUE_FMT_STRING_NO_QUOTES) ? "" : "\"";
+		line_append("%s%s%s", s, dm_escape_double_quotes(buf, v->v.str), s);
 		break;
 
 	case DM_CFG_FLOAT:
@@ -285,11 +287,15 @@ static int _write_value(struct config_output *out, const struct dm_config_value
 		break;
 
 	case DM_CFG_INT:
-		line_append("%" PRId64, v->v.i);
+		if (v->format_flags & DM_CONFIG_VALUE_FMT_INT_OCTAL)
+			line_append("0%" PRIo64, v->v.i);
+		else
+			line_append("%" PRId64, v->v.i);
 		break;
 
 	case DM_CFG_EMPTY_ARRAY:
-		line_append("[]");
+		s = (v->format_flags & DM_CONFIG_VALUE_FMT_COMMON_EXTRA_SPACES) ? " " : "";
+		line_append("[%s]", s);
 		break;
 
 	default:
@@ -303,6 +309,8 @@ static int _write_value(struct config_output *out, const struct dm_config_value
 static int _write_config(const struct dm_config_node *n, int only_one,
 			 struct config_output *out, int level)
 {
+	const char *extra_space;
+	int format_array;
 	char space[MAX_INDENT + 1];
 	int l = (level < MAX_INDENT) ? level : MAX_INDENT;
 	int i;
@@ -316,6 +324,9 @@ static int _write_config(const struct dm_config_node *n, int only_one,
 	space[i] = '\0';
 
 	do {
+		extra_space = (n->v && (n->v->format_flags & DM_CONFIG_VALUE_FMT_COMMON_EXTRA_SPACES)) ? " " : "";
+		format_array = (n->v && (n->v->format_flags & DM_CONFIG_VALUE_FMT_COMMON_ARRAY));
+
 		if (out->spec && out->spec->prefix_fn)
 			out->spec->prefix_fn(n, space, out->baton);
 
@@ -341,20 +352,25 @@ static int _write_config(const struct dm_config_node *n, int only_one,
 		} else {
 			/* it's a value */
 			const struct dm_config_value *v = n->v;
-			line_append("=");
+			line_append("%s=%s", extra_space, extra_space);
 			if (v->next) {
-				line_append("[");
+				line_append("[%s", extra_space);
 				while (v && v->type != DM_CFG_EMPTY_ARRAY) {
 					if (!_write_value(out, v))
 						return_0;
 					v = v->next;
 					if (v && v->type != DM_CFG_EMPTY_ARRAY)
-						line_append(", ");
+						line_append(",%s", extra_space);
 				}
-				line_append("]");
-			} else
+				line_append("%s]", extra_space);
+			} else {
+				if (format_array && (v->type != DM_CFG_EMPTY_ARRAY))
+					line_append("[%s", extra_space);
 				if (!_write_value(out, v))
 					return_0;
+				if (format_array && (v->type != DM_CFG_EMPTY_ARRAY))
+					line_append("%s]", extra_space);
+			}
 		}
 		if (!_line_end(n, out))
 			return_0;
@@ -1328,6 +1344,22 @@ struct dm_config_value *dm_config_create_value(struct dm_config_tree *cft)
 	return _create_value(cft->mem);
 }
 
+void dm_config_value_set_format_flags(struct dm_config_value *cv, uint32_t format_flags)
+{
+	if (!cv)
+		return;
+
+	cv->format_flags = format_flags;
+}
+
+uint32_t dm_config_value_get_format_flags(struct dm_config_value *cv)
+{
+	if (!cv)
+		return 0;
+
+	return cv->format_flags;
+}
+
 struct dm_pool *dm_config_memory(struct dm_config_tree *cft)
 {
 	return cft->mem;


