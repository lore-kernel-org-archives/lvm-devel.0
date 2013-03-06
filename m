From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed,  6 Mar 2013 11:15:05 +0000 (UTC)
Subject: master - config: add structs to represent config definition and register config_settings.h content
Message-ID: <20130306111505.851AEA0C29@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a3d891a29042e51a0f43ed02273a6dce194d6569
Commit:        a3d891a29042e51a0f43ed02273a6dce194d6569
Parent:        e947c362dd0ae1da2d76925fe6b38244c5f46d25
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Mar 5 16:49:42 2013 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Mar 6 10:14:33 2013 +0100

config: add structs to represent config definition and register config_settings.h content

This patch adds basic structures that encapsulate the config_settings.h
content - it takes each item and puts it in structures:

  - cfg_def_type_t to define config item type

  - cfg_def_value_t to define config item (default) value

  - flags used to define the nature and use of the config item:
      - CFG_NAME_VARIABLE for items with variable names (e.g. tags)
      - CFG_ALLOW_EMPTY for items where empty value is allowed
      - CFG_ADVANCED for items which are considered as "advanced settings"
      - CFG_UNSUPPORTED for items which are not officially supported
        (config options mostly for internal use and testing/debugging)

  - cfg_def_item_t to encapsulate the whole definition of the config
    definition itself

Each config item is referenced by named ID, e.g. "devices_dir_CFG"
instead of directly typing the path "devices/dir" as it was before.

This patch also adds cfg_def_get_path helper function to get the
config setting path up to the root for given config ID
(it returns the path in form of "abc/def/.../xyz" where the "abc"
is the topmost element).
---
 lib/config/config.c |   45 +++++++++++++++++++++++++++++++++++++
 lib/config/config.h |   62 +++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 107 insertions(+), 0 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index 0820594..f2ee9e7 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -38,6 +38,21 @@ struct config_file {
 	struct device *dev;
 };
 
+static char _cfg_path[CFG_PATH_MAX_LEN];
+
+/*
+ * Map each ID to respective definition of the configuration item.
+ */
+static struct cfg_def_item _cfg_def_items[CFG_COUNT + 1] = {
+#define cfg_section(id, name, parent, flags, since_version, comment) {id, parent, name, CFG_TYPE_SECTION, {0}, flags, since_version, comment},
+#define cfg(id, name, parent, flags, type, default_value, since_version, comment) {id, parent, name, type, {.v_##type = default_value}, flags, since_version, comment},
+#define cfg_array(id, name, parent, flags, types, default_value, since_version, comment) {id, parent, name, CFG_TYPE_ARRAY | types, {.v_CFG_TYPE_STRING = default_value}, flags, since_version, comment},
+#include "config_settings.h"
+#undef cfg_section
+#undef cfg
+#undef cfg_array
+};
+
 /*
  * public interface
  */
@@ -289,6 +304,36 @@ time_t config_file_timestamp(struct dm_config_tree *cft)
 	return cf->timestamp;
 }
 
+#define cfg_def_get_item_p(id) (&_cfg_def_items[id])
+#define cfg_def_get_default_value(item,type) item->default_value.v_##type
+#define cfg_def_get_path(item) (_cfg_def_make_path(_cfg_path,CFG_PATH_MAX_LEN,item->id,item),_cfg_path)
+
+static int _cfg_def_make_path(char *buf, size_t buf_size, int id, cfg_def_item_t *item)
+{
+	int parent_id = item->parent;
+	int count, n;
+
+	if (id == parent_id)
+		return 0;
+
+	count = _cfg_def_make_path(buf, buf_size, parent_id, cfg_def_get_item_p(parent_id));
+	if ((n = dm_snprintf(buf + count, buf_size - count, "%s%s",
+			     count ? "/" : "",
+			     item->flags & CFG_NAME_VARIABLE ? "#" : item->name)) < 0) {
+		log_error(INTERNAL_ERROR "_cfg_def_make_path: supplied buffer too small for %s/%s",
+					  cfg_def_get_item_p(parent_id)->name, item->name);
+		buf[0] = '\0';
+		return 0;
+	}
+
+	return count + n;
+}
+
+int config_def_get_path(char *buf, size_t buf_size, int id)
+{
+	return _cfg_def_make_path(buf, buf_size, id, cfg_def_get_item_p(id));
+}
+
 const struct dm_config_node *find_config_tree_node(struct cmd_context *cmd,
 						   const char *path)
 {
diff --git a/lib/config/config.h b/lib/config/config.h
index 079e9d1..2317348 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -17,6 +17,7 @@
 #define _LVM_CONFIG_H
 
 #include "lvm-types.h"
+#include "defaults.h"
 
 /* 16 bits: 3 bits for major, 4 bits for minor, 9 bits for patchlevel */
 /* Max LVM version supported: 7.15.511. Just extend bits if ever needed. */
@@ -25,6 +26,67 @@
 struct device;
 struct cmd_context;
 
+#define CFG_PATH_MAX_LEN 64
+
+/*
+ * Structures used for definition of a configuration tree.
+ */
+
+/* configuration definition item type (for item's accepted types) */
+typedef enum {
+	CFG_TYPE_SECTION = 0,		/* section */
+	CFG_TYPE_ARRAY = 1,		/* setting */
+	CFG_TYPE_BOOL = 2,		/* setting */
+	CFG_TYPE_INT = 4,		/* setting */
+	CFG_TYPE_FLOAT = 8,		/* setting */
+	CFG_TYPE_STRING = 16		/* setting */
+} cfg_def_type_t;
+
+/* configuration definition item value (for item's default value) */
+typedef union {
+	const int v_CFG_TYPE_BOOL, v_CFG_TYPE_INT;
+	const float v_CFG_TYPE_FLOAT;
+	const char *v_CFG_TYPE_STRING, *v_CFG_TYPE_ARRAY;
+} cfg_def_value_t;
+
+/* configuration definition item flags: */
+
+/* whether the configuration item name is variable */
+#define CFG_NAME_VARIABLE	0x01
+/* whether empty value is allowed */
+#define CFG_ALLOW_EMPTY		0x02
+/* whether the configuration item is for advanced use only */
+#define CFG_ADVANCED		0x04
+/* whether the configuraton item is not officially supported */
+#define CFG_UNSUPPORTED		0x08
+
+/* configuration definition item structure */
+typedef struct cfg_def_item {
+	int id;				/* ID of this item */
+	int parent;			/* ID of parent item */
+	const char *name;		/* name of the item in configuration tree */
+	cfg_def_type_t type;		/* configuration item type */
+	cfg_def_value_t default_value;	/* default value (only for settings) */
+	uint16_t flags;			/* configuration item definition flags */
+	uint16_t since_version;		/* version this item appeared in */
+	const char *comment;		/* brief comment */
+} cfg_def_item_t;
+
+/*
+ * Register ID for each possible item in the configuration tree.
+ */
+enum {
+#define cfg_section(id, name, parent, flags, since_version, comment) id,
+#define cfg(id, name, parent, flags, type, default_value, since_version, comment) id,
+#define cfg_array(id, name, parent, flags, types, default_value, since_version, comment) id,
+#include "config_settings.h"
+#undef cfg_section
+#undef cfg
+#undef cfg_array
+};
+
+int config_def_get_path(char *buf, size_t buf_size, int id);
+
 int override_config_tree_from_string(struct cmd_context *cmd,
 				     const char *config_settings);
 struct dm_config_tree *remove_overridden_config_tree(struct cmd_context *cmd);


