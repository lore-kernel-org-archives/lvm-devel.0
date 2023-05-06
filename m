From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat,  6 May 2023 20:46:02 +0000 (GMT)
Subject: main - cov: simplier code
Message-ID: <20230506204602.E23B13858D28@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=662020c221fdb3e23c66947f6c81f99a0950744a
Commit:        662020c221fdb3e23c66947f6c81f99a0950744a
Parent:        d7e922480e04ecfb7c4d8b2d42533699ddef5c34
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 26 13:20:56 2023 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat May 6 19:22:05 2023 +0200

cov: simplier code

Avoid coverity to contruct some abstract scenarions of 'cft'
modification and simplify the code at the same time.
---
 lib/config/config.c | 35 +++++++++++++++++++++--------------
 1 file changed, 21 insertions(+), 14 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index 5986e64b1..5531e431d 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -1300,8 +1300,9 @@ const char *find_config_tree_str(struct cmd_context *cmd, int id, struct profile
 	if (item->type != CFG_TYPE_STRING)
 		log_error(INTERNAL_ERROR "%s cfg tree element not declared as string.", path);
 
-	str = _config_disabled(cmd, item, path) ? cfg_def_get_default_value(cmd, item, CFG_TYPE_STRING, profile)
-						: dm_config_tree_find_str(cmd->cft, path, cfg_def_get_default_value(cmd, item, CFG_TYPE_STRING, profile));
+	str = cfg_def_get_default_value(cmd, item, CFG_TYPE_STRING, profile);
+	if (!_config_disabled(cmd, item, path))
+		str = dm_config_tree_find_str(cmd->cft, path, str);
 
 	if (profile_applied && profile)
 		remove_config_tree_by_source(cmd, profile->source);
@@ -1324,8 +1325,9 @@ const char *find_config_tree_str_allow_empty(struct cmd_context *cmd, int id, st
 	if (!(item->flags & CFG_ALLOW_EMPTY))
 		log_error(INTERNAL_ERROR "%s cfg tree element not declared to allow empty values.", path);
 
-	str = _config_disabled(cmd, item, path) ? cfg_def_get_default_value(cmd, item, CFG_TYPE_STRING, profile)
-						: dm_config_tree_find_str_allow_empty(cmd->cft, path, cfg_def_get_default_value(cmd, item, CFG_TYPE_STRING, profile));
+	str = cfg_def_get_default_value(cmd, item, CFG_TYPE_STRING, profile);
+	if (!_config_disabled(cmd, item, path))
+		str = dm_config_tree_find_str_allow_empty(cmd->cft, path, str);
 
 	if (profile_applied && profile)
 		remove_config_tree_by_source(cmd, profile->source);
@@ -1346,8 +1348,9 @@ int find_config_tree_int(struct cmd_context *cmd, int id, struct profile *profil
 	if (item->type != CFG_TYPE_INT)
 		log_error(INTERNAL_ERROR "%s cfg tree element not declared as integer.", path);
 
-	i = _config_disabled(cmd, item, path) ? cfg_def_get_default_value(cmd, item, CFG_TYPE_INT, profile)
-					      : dm_config_tree_find_int(cmd->cft, path, cfg_def_get_default_value(cmd, item, CFG_TYPE_INT, profile));
+	i = cfg_def_get_default_value(cmd, item, CFG_TYPE_INT, profile);
+	if (!_config_disabled(cmd, item, path))
+		i = dm_config_tree_find_int(cmd->cft, path, i);
 
 	if (profile_applied && profile)
 		remove_config_tree_by_source(cmd, profile->source);
@@ -1368,8 +1371,9 @@ int64_t find_config_tree_int64(struct cmd_context *cmd, int id, struct profile *
 	if (item->type != CFG_TYPE_INT)
 		log_error(INTERNAL_ERROR "%s cfg tree element not declared as integer.", path);
 
-	i64 = _config_disabled(cmd, item, path) ? cfg_def_get_default_value(cmd, item, CFG_TYPE_INT, profile)
-						: dm_config_tree_find_int64(cmd->cft, path, cfg_def_get_default_value(cmd, item, CFG_TYPE_INT, profile));
+	i64 = cfg_def_get_default_value(cmd, item, CFG_TYPE_INT, profile);
+	if (!_config_disabled(cmd, item, path))
+		i64 = dm_config_tree_find_int64(cmd->cft, path, i64);
 
 	if (profile_applied && profile)
 		remove_config_tree_by_source(cmd, profile->source);
@@ -1390,8 +1394,9 @@ float find_config_tree_float(struct cmd_context *cmd, int id, struct profile *pr
 	if (item->type != CFG_TYPE_FLOAT)
 		log_error(INTERNAL_ERROR "%s cfg tree element not declared as float.", path);
 
-	f = _config_disabled(cmd, item, path) ? cfg_def_get_default_value(cmd, item, CFG_TYPE_FLOAT, profile)
-					      : dm_config_tree_find_float(cmd->cft, path, cfg_def_get_default_value(cmd, item, CFG_TYPE_FLOAT, profile));
+	f = cfg_def_get_default_value(cmd, item, CFG_TYPE_FLOAT, profile);
+	if (!_config_disabled(cmd, item, path))
+		f = dm_config_tree_find_float(cmd->cft, path, f);
 
 	if (profile_applied && profile)
 		remove_config_tree_by_source(cmd, profile->source);
@@ -1410,8 +1415,9 @@ int find_config_bool(struct cmd_context *cmd, struct dm_config_tree *cft, int id
 	if (item->type != CFG_TYPE_BOOL)
 		log_error(INTERNAL_ERROR "%s cfg tree element not declared as boolean.", path);
 
-	b = _config_disabled(cmd, item, path) ? cfg_def_get_default_value(cmd, item, CFG_TYPE_BOOL, NULL)
-					      : dm_config_tree_find_bool(cft, path, cfg_def_get_default_value(cmd, item, CFG_TYPE_BOOL, NULL));
+	b = cfg_def_get_default_value(cmd, item, CFG_TYPE_BOOL, NULL);
+	if (!_config_disabled(cmd, item, path))
+		b = dm_config_tree_find_bool(cft, path, b);
 
 	return b;
 }
@@ -1429,8 +1435,9 @@ int find_config_tree_bool(struct cmd_context *cmd, int id, struct profile *profi
 	if (item->type != CFG_TYPE_BOOL)
 		log_error(INTERNAL_ERROR "%s cfg tree element not declared as boolean.", path);
 
-	b = _config_disabled(cmd, item, path) ? cfg_def_get_default_value(cmd, item, CFG_TYPE_BOOL, profile)
-					      : dm_config_tree_find_bool(cmd->cft, path, cfg_def_get_default_value(cmd, item, CFG_TYPE_BOOL, profile));
+	b = cfg_def_get_default_value(cmd, item, CFG_TYPE_BOOL, profile);
+	if (!_config_disabled(cmd, item, path))
+		b = dm_config_tree_find_bool(cmd->cft, path, b);
 
 	if (profile_applied && profile)
 		remove_config_tree_by_source(cmd, profile->source);

