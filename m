From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 26 Jun 2013 14:56:00 +0000 (UTC)
Subject: dev-peter-config-profiles - config: add profile arg to find_config_tree_int64
Message-ID: <20130626145600.EDA0660DEE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=01debc1f005b32798ea695fe1c9c078b4ba5d33b
Commit:        01debc1f005b32798ea695fe1c9c078b4ba5d33b
Parent:        754ac268a789dcc30ec1f5809e142f877ed2ea04
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jun 25 12:31:24 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jun 26 16:53:50 2013 +0200

config: add profile arg to find_config_tree_int64

---
 lib/commands/toolcontext.c |    2 +-
 lib/config/config.c        |   14 ++++++++++++--
 lib/config/config.h        |    2 +-
 3 files changed, 14 insertions(+), 4 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index e7623c4..f5e0541 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -401,7 +401,7 @@ static int _process_config(struct cmd_context *cmd)
 
 	cmd->metadata_read_only = find_config_tree_bool(cmd, global_metadata_read_only_CFG);
 
-	pv_min_kb = find_config_tree_int64(cmd, devices_pv_min_size_CFG);
+	pv_min_kb = find_config_tree_int64(cmd, devices_pv_min_size_CFG, NULL);
 	if (pv_min_kb < PV_MIN_SIZE_KB) {
 		log_warn("Ignoring too small pv_min_size %" PRId64 "KB, using default %dKB.",
 			 pv_min_kb, PV_MIN_SIZE_KB);
diff --git a/lib/config/config.c b/lib/config/config.c
index aad0e91..fff883b 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -824,15 +824,25 @@ int find_config_tree_int(struct cmd_context *cmd, int id, struct profile *profil
 	return i;
 }
 
-int64_t find_config_tree_int64(struct cmd_context *cmd, int id)
+int64_t find_config_tree_int64(struct cmd_context *cmd, int id, struct profile *profile)
 {
 	cfg_def_item_t *item = cfg_def_get_item_p(id);
 	const char *path = cfg_def_get_path(item);
+	int profile_applied = 0;
+	int i64;
 
 	if (item->type != CFG_TYPE_INT)
 		log_error(INTERNAL_ERROR "%s cfg tree element not declared as integer.", path);
 
-	return dm_config_tree_find_int64(cmd->cft, path, cfg_def_get_default_value(item, CFG_TYPE_INT));
+	if (profile && !cmd->profile_params->global_profile)
+		profile_applied = override_config_tree_from_profile(cmd, profile);
+
+	i64 = dm_config_tree_find_int64(cmd->cft, path, cfg_def_get_default_value(item, CFG_TYPE_INT));
+
+	if (profile_applied)
+		remove_config_tree_by_source(cmd, CONFIG_PROFILE);
+
+	return i64;
 }
 
 float find_config_tree_float(struct cmd_context *cmd, int id)
diff --git a/lib/config/config.h b/lib/config/config.h
index 95bae36..700075c 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -164,7 +164,7 @@ const struct dm_config_node *find_config_tree_node(struct cmd_context *cmd, int
 const char *find_config_tree_str(struct cmd_context *cmd, int id, struct profile *profile);
 const char *find_config_tree_str_allow_empty(struct cmd_context *cmd, int id, struct profile *profile);
 int find_config_tree_int(struct cmd_context *cmd, int id, struct profile *profile);
-int64_t find_config_tree_int64(struct cmd_context *cmd, int id);
+int64_t find_config_tree_int64(struct cmd_context *cmd, int id, struct profile *profile);
 float find_config_tree_float(struct cmd_context *cmd, int id);
 int find_config_tree_bool(struct cmd_context *cmd, int id);
 


