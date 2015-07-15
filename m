From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 15 Jul 2015 08:55:10 +0000 (UTC)
Subject: master - config: add "defaulting to" message in case we fall back to defaults in find_config_tree_array
Message-ID: <20150715085510.4BAAC602E8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7e728fe1a164cc5d4f64e46fcfcbb224c22b2457
Commit:        7e728fe1a164cc5d4f64e46fcfcbb224c22b2457
Parent:        96a883a4541211fc3af09f682854ed88e200c036
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jul 15 10:50:57 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jul 15 10:50:57 2015 +0200

config: add "defaulting to" message in case we fall back to defaults in find_config_tree_array

---
 lib/config/config.c |   38 ++++++++++++++++++++++++++++++++++++--
 1 files changed, 36 insertions(+), 2 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index 6aaeef1..a447de7 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -1386,12 +1386,31 @@ static struct dm_config_node *_get_array_def_node(struct cmd_context *cmd,
 	return cn;
 }
 
+struct _config_array_out_handle {
+	struct dm_pool *mem;
+	char *str;
+};
+
+static int _config_array_line(const struct dm_config_node *cn, const char *line, void *baton)
+{
+	struct _config_array_out_handle *handle = (struct _config_array_out_handle *) baton;
+
+	if (!(handle->str = dm_pool_strdup(handle->mem, line))) {
+		log_error("_config_array_line: dm_pool_strdup failed");
+		return 0;
+	}
+
+	return 1;
+}
+
 const struct dm_config_node *find_config_tree_array(struct cmd_context *cmd, int id, struct profile *profile)
 {
 	cfg_def_item_t *item = cfg_def_get_item_p(id);
 	char path[CFG_PATH_MAX_LEN];
 	int profile_applied;
-	const struct dm_config_node *cn;
+	const struct dm_config_node *cn, *cn_def = NULL;
+	struct _config_array_out_handle out_handle = { 0 };
+	struct dm_config_node_out_spec out_spec = { 0 };
 
 	profile_applied = _apply_local_profile(cmd, profile);
 	_cfg_def_make_path(path, sizeof(path), item->id, item, 0);
@@ -1401,7 +1420,22 @@ const struct dm_config_node *find_config_tree_array(struct cmd_context *cmd, int
 
 	if (_config_disabled(cmd, item, path) ||
 	    !(cn = find_config_tree_node(cmd, id, profile)))
-		cn = _get_array_def_node(cmd, item, profile);
+		cn_def = _get_array_def_node(cmd, item, profile);
+
+	if (cn_def) {
+		out_handle.mem = cmd->cft->mem;
+		out_spec.line_fn = _config_array_line;
+		dm_config_value_set_format_flags(cn_def->v,
+			DM_CONFIG_VALUE_FMT_COMMON_EXTRA_SPACES |
+			DM_CONFIG_VALUE_FMT_COMMON_ARRAY);
+		if (!dm_config_write_one_node_out(cn_def, &out_spec, &out_handle))
+			out_handle.mem = NULL;
+		log_very_verbose("%s not found in config: defaulting to %s",
+				 path, out_handle.mem ? out_handle.str : "<unknown>");
+		if (out_handle.mem)
+			dm_pool_free(out_handle.mem, out_handle.str);
+		cn = cn_def;
+	}
 
 	if (profile_applied)
 		remove_config_tree_by_source(cmd, profile->source);


