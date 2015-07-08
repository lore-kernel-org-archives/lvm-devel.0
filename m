From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed,  8 Jul 2015 11:08:20 +0000 (UTC)
Subject: master - config: add find_config_tree_array
Message-ID: <20150708110820.1D28B60DD3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=67a61cce1b26e91eb765a682f66be67bd997f09f
Commit:        67a61cce1b26e91eb765a682f66be67bd997f09f
Parent:        d9d47b7b88b47719ff972f27a448f9cdf6982c4a
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jul 8 10:43:59 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jul 8 12:59:22 2015 +0200

config: add find_config_tree_array

Before, we used general find_config_tree_node function to retrieve
array values. This had a downside where if the node was not found,
we had to insert default values directly in-situ after the
find_config_tree_node call. This way, we had two copies of default
values - one in config_settings.h and the other one directly in the
code where we found out that find_config_tree_node returned NULL and
hence we needed to fall back to defaults.

With separate find_config_tree_array used for array config values,
we keep all the defaults centrally in config_settings.h because
the new find_config_tree_array automatically returns these defaults
if it can't find any value set in the configuration.

This patch just makes the behaviour exactly the same for arrays as
for any other non-array type where we call find_config_tree_<type>
already, hence making the internal interface for handling array
values consistent with the rest of the config types.
---
 lib/commands/toolcontext.c |    2 +
 lib/config/config.c        |   59 ++++++++++++++++++++++++++++++++++++++++---
 lib/config/config.h        |    1 +
 3 files changed, 57 insertions(+), 5 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 4265954..00db078 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1235,6 +1235,8 @@ static int _init_filters(struct cmd_context *cmd, unsigned load_persistent_cache
 		cmd->lvmetad_filter = NULL;
 	}
 
+	cn = find_config_tree_array(cmd, devices_filter_CFG, NULL);
+
 	/* filter component 1 */
 	if ((cn = find_config_tree_node(cmd, devices_filter_CFG, NULL))) {
 		if (!(filter_components[1] = regex_filter_create(cn->v)))
diff --git a/lib/config/config.c b/lib/config/config.c
index 53987f8..9458107 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -666,14 +666,18 @@ static void _log_type_error(const char *path, cfg_def_type_t actual,
 					     actual_type_name, expected_type_name);
 }
 
-static struct dm_config_value *_get_def_array_values(struct dm_config_tree *cft,
+static struct dm_config_value *_get_def_array_values(struct cmd_context *cmd,
+						     struct dm_config_tree *cft,
 						     const cfg_def_item_t *def,
 						     uint32_t format_flags)
 {
+	const char *def_enc_value;
 	char *enc_value, *token, *p, *r;
 	struct dm_config_value *array = NULL, *v = NULL, *oldv = NULL;
 
-	if (!def->default_value.v_CFG_TYPE_STRING) {
+	def_enc_value = cfg_def_get_default_value(cmd, def, CFG_TYPE_ARRAY, NULL);
+
+	if (!def_enc_value) {
 		if (!(array = dm_config_create_value(cft))) {
 			log_error("Failed to create default empty array for %s.", def->name);
 			return NULL;
@@ -683,7 +687,7 @@ static struct dm_config_value *_get_def_array_values(struct dm_config_tree *cft,
 		return array;
 	}
 
-	if (!(p = token = enc_value = dm_strdup(def->default_value.v_CFG_TYPE_STRING))) {
+	if (!(p = token = enc_value = dm_strdup(def_enc_value))) {
 		log_error("_get_def_array_values: dm_strdup failed");
 		return NULL;
 	}
@@ -844,7 +848,7 @@ static int _check_value_differs_from_default(struct cft_check_handle *handle,
 	}
 
 	if (!v_def && (def->type & CFG_TYPE_ARRAY)) {
-		if (!(v_def_array = v_def_iter = _get_def_array_values(handle->cft, def, 0)))
+		if (!(v_def_array = v_def_iter = _get_def_array_values(handle->cmd, handle->cft, def, 0)))
 			return_0;
 		do {
 			/* iterate over each element of the array and check its value */
@@ -1360,6 +1364,51 @@ int find_config_tree_bool(struct cmd_context *cmd, int id, struct profile *profi
 	return b;
 }
 
+static struct dm_config_node *_get_array_def_node(struct cmd_context *cmd,
+						  cfg_def_item_t *def,
+						  struct profile *profile)
+{
+	struct dm_config_node *cn;
+
+	if (def->flags & CFG_DEFAULT_UNDEFINED)
+		return NULL;
+
+	if (!(cn = dm_config_create_node(cmd->cft, def->name))) {
+		log_error("Failed to create default array node for %s.", def->name);
+		return NULL;
+	}
+
+	if (!(cn->v = _get_def_array_values(cmd, cmd->cft, def, 0))) {
+		dm_pool_free(cmd->cft->mem, cn);
+		return_NULL;
+	}
+
+	return cn;
+}
+
+struct dm_config_node *find_config_tree_array(struct cmd_context *cmd, int id, struct profile *profile)
+{
+	cfg_def_item_t *item = cfg_def_get_item_p(id);
+	char path[CFG_PATH_MAX_LEN];
+	int profile_applied;
+	struct dm_config_node *cn;
+
+	profile_applied = _apply_local_profile(cmd, profile);
+	_cfg_def_make_path(path, sizeof(path), item->id, item, 0);
+
+	if (!(item->type & CFG_TYPE_ARRAY))
+		log_error(INTERNAL_ERROR "%s cfg tree element not declared as array.", path);
+
+	if (_config_disabled(cmd, item, path) ||
+	    !(cn = dm_config_find_node(cmd->cft->root, path)))
+		cn = _get_array_def_node(cmd, item, profile);
+
+	if (profile_applied)
+		remove_config_tree_by_source(cmd, profile->source);
+
+	return cn;
+}
+
 /* Insert cn2 after cn1 */
 static void _insert_config_node(struct dm_config_node **cn1,
 				struct dm_config_node *cn2)
@@ -1826,7 +1875,7 @@ static struct dm_config_node *_add_def_node(struct dm_config_tree *cft,
 		if (spec->withspaces)
 			format_flags |= DM_CONFIG_VALUE_FMT_COMMON_EXTRA_SPACES;
 		format_flags |= DM_CONFIG_VALUE_FMT_COMMON_ARRAY;
-		cn->v = _get_def_array_values(cft, def, format_flags);
+		cn->v = _get_def_array_values(spec->cmd, cft, def, format_flags);
 	}
 
 	cn->child = NULL;
diff --git a/lib/config/config.h b/lib/config/config.h
index 24d1f3f..a20fd8f 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -272,6 +272,7 @@ int find_config_tree_int(struct cmd_context *cmd, int id, struct profile *profil
 int64_t find_config_tree_int64(struct cmd_context *cmd, int id, struct profile *profile);
 float find_config_tree_float(struct cmd_context *cmd, int id, struct profile *profile);
 int find_config_tree_bool(struct cmd_context *cmd, int id, struct profile *profile);
+struct dm_config_node *find_config_tree_array(struct cmd_context *cmd, int id, struct profile *profile);
 
 /*
  * Functions for configuration settings for which the default


