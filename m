From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 28 Apr 2015 13:44:18 +0000 (UTC)
Subject: master - refactor: rename struct cfg_def_item's 'unconfigured_path' to 'unconfigured_value'
Message-ID: <20150428134418.30FA26108B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=de6deec3b8a981d8d1ebb7ada826d2e661735a30
Commit:        de6deec3b8a981d8d1ebb7ada826d2e661735a30
Parent:        d0c46c9ed5247732e46fcb9ca4ad5be9f77a64a0
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Apr 28 13:29:18 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Apr 28 15:30:48 2015 +0200

refactor: rename struct cfg_def_item's 'unconfigured_path' to 'unconfigured_value'

It's not only path that can be used for setting's default value
in unconfigured form as @something at .
---
 lib/config/config.c |   14 +++++++-------
 lib/config/config.h |   12 ++++++------
 2 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index 4051fa4..bf1edcf 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -65,11 +65,11 @@ struct config_source {
  * Map each ID to respective definition of the configuration item.
  */
 static struct cfg_def_item _cfg_def_items[CFG_COUNT + 1] = {
-#define cfg_section(id, name, parent, flags, since_version, unconfigured_path, comment) {id, parent, name, CFG_TYPE_SECTION, {0}, flags, since_version, unconfigured_path, comment},
-#define cfg(id, name, parent, flags, type, default_value, since_version, unconfigured_path, comment) {id, parent, name, type, {.v_##type = default_value}, flags, since_version, unconfigured_path, comment},
-#define cfg_runtime(id, name, parent, flags, type, since_version, unconfigured_path, comment) {id, parent, name, type, {.fn_##type = get_default_##id}, flags | CFG_DEFAULT_RUN_TIME, since_version, unconfigured_path, comment},
-#define cfg_array(id, name, parent, flags, types, default_value, since_version, unconfigured_path, comment) {id, parent, name, CFG_TYPE_ARRAY | types, {.v_CFG_TYPE_STRING = default_value}, flags, since_version, unconfigured_path, comment},
-#define cfg_array_runtime(id, name, parent, flags, types, since_version, unconfigured_path, comment) {id, parent, name, CFG_TYPE_ARRAY | types, {.fn_CFG_TYPE_STRING = get_default_##id}, flags | CFG_DEFAULT_RUN_TIME, since_version, unconfigured_path, comment},
+#define cfg_section(id, name, parent, flags, since_version, unconfigured_value, comment) {id, parent, name, CFG_TYPE_SECTION, {0}, flags, since_version, unconfigured_value, comment},
+#define cfg(id, name, parent, flags, type, default_value, since_version, unconfigured_value, comment) {id, parent, name, type, {.v_##type = default_value}, flags, since_version, unconfigured_value, comment},
+#define cfg_runtime(id, name, parent, flags, type, since_version, unconfigured_value, comment) {id, parent, name, type, {.fn_##type = get_default_##id}, flags | CFG_DEFAULT_RUN_TIME, since_version, unconfigured_value, comment},
+#define cfg_array(id, name, parent, flags, types, default_value, since_version, unconfigured_value, comment) {id, parent, name, CFG_TYPE_ARRAY | types, {.v_CFG_TYPE_STRING = default_value}, flags, since_version, unconfigured_value, comment},
+#define cfg_array_runtime(id, name, parent, flags, types, since_version, unconfigured_value, comment) {id, parent, name, CFG_TYPE_ARRAY | types, {.fn_CFG_TYPE_STRING = get_default_##id}, flags | CFG_DEFAULT_RUN_TIME, since_version, unconfigured_value, comment},
 #include "config_settings.h"
 #undef cfg_section
 #undef cfg
@@ -1698,8 +1698,8 @@ static struct dm_config_node *_add_def_node(struct dm_config_tree *cft,
 					str = "";
 				cn->v->v.str = str;
 
-				if (spec->unconfigured && def->unconfigured_path)
-					cn->v->v.str = def->unconfigured_path;
+				if (spec->unconfigured && def->unconfigured_value)
+					cn->v->v.str = def->unconfigured_value;
 				break;
 			default:
 				log_error(INTERNAL_ERROR "_add_def_node: unknown type");
diff --git a/lib/config/config.h b/lib/config/config.h
index cc5681c..1c367bd 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -121,7 +121,7 @@ typedef struct cfg_def_item {
 	cfg_def_value_t default_value;	/* default value (only for settings) */
 	uint16_t flags;			/* configuration item definition flags */
 	uint16_t since_version;		/* version this item appeared in */
-	const char *unconfigured_path;	/* path in terms of @FOO@, pre-configured */
+	const char *unconfigured_value;	/* value in terms of @FOO@, pre-configured */
 	const char *comment;		/* brief comment */
 } cfg_def_item_t;
 
@@ -165,11 +165,11 @@ struct config_def_tree_spec {
  * Register ID for each possible item in the configuration tree.
  */
 enum {
-#define cfg_section(id, name, parent, flags, since_version, unconfigured_path, comment) id,
-#define cfg(id, name, parent, flags, type, default_value, since_version, unconfigured_path, comment) id,
-#define cfg_runtime(id, name, parent, flags, type, since_version, unconfigured_path, comment) id,
-#define cfg_array(id, name, parent, flags, types, default_value, since_version, unconfigured_path, comment) id,
-#define cfg_array_runtime(id, name, parent, flags, types, since_version, unconfigured_path, comment) id,
+#define cfg_section(id, name, parent, flags, since_version, unconfigured_value, comment) id,
+#define cfg(id, name, parent, flags, type, default_value, since_version, unconfigured_value, comment) id,
+#define cfg_runtime(id, name, parent, flags, type, since_version, unconfigured_value, comment) id,
+#define cfg_array(id, name, parent, flags, types, default_value, since_version, unconfigured_value, comment) id,
+#define cfg_array_runtime(id, name, parent, flags, types, since_version, unconfigured_value, comment) id,
 #include "config_settings.h"
 #undef cfg_section
 #undef cfg


