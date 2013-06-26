From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 26 Jun 2013 14:56:03 +0000 (UTC)
Subject: dev-peter-config-profiles - config: add profile arg to find_config_tree_float
Message-ID: <20130626145603.1887660D8F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9f80cc1b92f1ac038f3eba11e85522621f413dc5
Commit:        9f80cc1b92f1ac038f3eba11e85522621f413dc5
Parent:        01debc1f005b32798ea695fe1c9c078b4ba5d33b
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jun 25 12:31:36 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jun 26 16:53:50 2013 +0200

config: add profile arg to find_config_tree_float

---
 lib/config/config.c |   14 ++++++++++++--
 lib/config/config.h |    2 +-
 2 files changed, 13 insertions(+), 3 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index fff883b..731de1f 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -845,15 +845,25 @@ int64_t find_config_tree_int64(struct cmd_context *cmd, int id, struct profile *
 	return i64;
 }
 
-float find_config_tree_float(struct cmd_context *cmd, int id)
+float find_config_tree_float(struct cmd_context *cmd, int id, struct profile *profile)
 {
 	cfg_def_item_t *item = cfg_def_get_item_p(id);
 	const char *path = cfg_def_get_path(item);
+	int profile_applied = 0;
+	float f;
 
 	if (item->type != CFG_TYPE_FLOAT)
 		log_error(INTERNAL_ERROR "%s cfg tree element not declared as float.", path);
 
-	return dm_config_tree_find_float(cmd->cft, path, cfg_def_get_default_value(item, CFG_TYPE_FLOAT));
+	if (profile && !cmd->profile_params->global_profile)
+		profile_applied = override_config_tree_from_profile(cmd, profile);
+
+	f = dm_config_tree_find_float(cmd->cft, path, cfg_def_get_default_value(item, CFG_TYPE_FLOAT));
+
+	if (profile_applied)
+		remove_config_tree_by_source(cmd, CONFIG_PROFILE);
+
+	return f;
 }
 
 int find_config_tree_bool(struct cmd_context *cmd, int id)
diff --git a/lib/config/config.h b/lib/config/config.h
index 700075c..8ec4e75 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -165,7 +165,7 @@ const char *find_config_tree_str(struct cmd_context *cmd, int id, struct profile
 const char *find_config_tree_str_allow_empty(struct cmd_context *cmd, int id, struct profile *profile);
 int find_config_tree_int(struct cmd_context *cmd, int id, struct profile *profile);
 int64_t find_config_tree_int64(struct cmd_context *cmd, int id, struct profile *profile);
-float find_config_tree_float(struct cmd_context *cmd, int id);
+float find_config_tree_float(struct cmd_context *cmd, int id, struct profile *profile);
 int find_config_tree_bool(struct cmd_context *cmd, int id);
 
 #endif


