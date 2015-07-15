From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 15 Jul 2015 14:03:21 +0000 (UTC)
Subject: master - config: also log the value used if defined in config, not just defaults
Message-ID: <20150715140321.ECBFD60EDC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d10fb73f63649baec3cec28e1ee573c2ef6b95d6
Commit:        d10fb73f63649baec3cec28e1ee573c2ef6b95d6
Parent:        64c41062191e3bd487374837ff6d21a077129c98
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jul 15 15:57:29 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jul 15 16:02:20 2015 +0200

config: also log the value used if defined in config, not just defaults

Commit 7e728fe1a164cc5d4f64e46fcfcbb224c22b2457 added a log call
directly in find_config_tree_array when defaults are used.

This patch also adds the log for the value which is found in
existing configuration and for which defaults are not used.

For example:

Defaults used:
config/config.c:1428   devices/scan not found in config: defaulting to scan = [ "/dev" ]

Value defined in configuration used:
config/config.c:1431   Setting devices/scan to scan = [ "/dev", "/mydev", "/abc" ]

This makes the logging consistent with the other find_config_tree_* functions.
---
 lib/config/config.c |   53 +++++++++++++++++++++++++++++++++++---------------
 1 files changed, 37 insertions(+), 16 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index a447de7..35ee3ac 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -1403,15 +1403,44 @@ static int _config_array_line(const struct dm_config_node *cn, const char *line,
 	return 1;
 }
 
+static void _log_array_value_used(struct dm_pool *mem, const struct dm_config_node *cn,
+				  const char *path, int default_used)
+{
+	struct _config_array_out_handle out_handle = { 0 };
+	struct dm_config_node_out_spec out_spec = { 0 };
+	uint32_t old_format_flags;
+
+	out_handle.mem = mem;
+	out_spec.line_fn = _config_array_line;
+
+	old_format_flags = dm_config_value_get_format_flags(cn->v);
+	dm_config_value_set_format_flags(cn->v,
+		DM_CONFIG_VALUE_FMT_COMMON_EXTRA_SPACES |
+		DM_CONFIG_VALUE_FMT_COMMON_ARRAY);
+
+	if (!dm_config_write_one_node_out(cn, &out_spec, &out_handle)) {
+		log_error("_log_array_value_used: failed to write node value");
+		out_handle.mem = NULL;
+	}
+
+	if (default_used)
+		log_very_verbose("%s not found in config: defaulting to %s",
+				 path, out_handle.mem ? out_handle.str : "<unknown>");
+	else
+		log_very_verbose("Setting %s to %s",
+				 path, out_handle.mem ? out_handle.str : "<unknown>");
+
+	if (out_handle.mem)
+		dm_pool_free(out_handle.mem, out_handle.str);
+	dm_config_value_set_format_flags(cn->v, old_format_flags);
+}
+
 const struct dm_config_node *find_config_tree_array(struct cmd_context *cmd, int id, struct profile *profile)
 {
 	cfg_def_item_t *item = cfg_def_get_item_p(id);
 	char path[CFG_PATH_MAX_LEN];
 	int profile_applied;
-	const struct dm_config_node *cn, *cn_def = NULL;
-	struct _config_array_out_handle out_handle = { 0 };
-	struct dm_config_node_out_spec out_spec = { 0 };
-
+	const struct dm_config_node *cn = NULL, *cn_def = NULL;
 	profile_applied = _apply_local_profile(cmd, profile);
 	_cfg_def_make_path(path, sizeof(path), item->id, item, 0);
 
@@ -1422,18 +1451,10 @@ const struct dm_config_node *find_config_tree_array(struct cmd_context *cmd, int
 	    !(cn = find_config_tree_node(cmd, id, profile)))
 		cn_def = _get_array_def_node(cmd, item, profile);
 
-	if (cn_def) {
-		out_handle.mem = cmd->cft->mem;
-		out_spec.line_fn = _config_array_line;
-		dm_config_value_set_format_flags(cn_def->v,
-			DM_CONFIG_VALUE_FMT_COMMON_EXTRA_SPACES |
-			DM_CONFIG_VALUE_FMT_COMMON_ARRAY);
-		if (!dm_config_write_one_node_out(cn_def, &out_spec, &out_handle))
-			out_handle.mem = NULL;
-		log_very_verbose("%s not found in config: defaulting to %s",
-				 path, out_handle.mem ? out_handle.str : "<unknown>");
-		if (out_handle.mem)
-			dm_pool_free(out_handle.mem, out_handle.str);
+	if (cn)
+		_log_array_value_used(cmd->cft->mem, cn, path, 0);
+	else if (cn_def) {
+		_log_array_value_used(cmd->cft->mem, cn_def, path, 1);
 		cn = cn_def;
 	}
 


