From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 13 Nov 2015 10:19:21 +0000 (UTC)
Subject: master - coverity: hint
Message-ID: <20151113101921.74A3160FDC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8d258c7df487d59a524643b71adba602696c5287
Commit:        8d258c7df487d59a524643b71adba602696c5287
Parent:        ea1814cea8fe45c7f9dd861642e65701a00f8c03
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 13 09:47:14 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 13 11:18:27 2015 +0100

coverity: hint

Here Coverity cannot see the pointer cannot be NULL in this
code path - opened coverity case #00531860.

We could make a model to avoid seeing related reports,
but then we loose coverage for modeled function.

So decided to add minor hint for this case.
---
 lib/config/config.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index ac1049d..1298b40 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -1215,7 +1215,7 @@ const struct dm_config_node *find_config_tree_node(struct cmd_context *cmd, int
 
 	cn = dm_config_tree_find_node(cmd->cft, path);
 
-	if (profile_applied)
+	if (profile_applied && profile)
 		remove_config_tree_by_source(cmd, profile->source);
 
 	return cn;
@@ -1237,7 +1237,7 @@ const char *find_config_tree_str(struct cmd_context *cmd, int id, struct profile
 	str = _config_disabled(cmd, item, path) ? cfg_def_get_default_value(cmd, item, CFG_TYPE_STRING, profile)
 						: dm_config_tree_find_str(cmd->cft, path, cfg_def_get_default_value(cmd, item, CFG_TYPE_STRING, profile));
 
-	if (profile_applied)
+	if (profile_applied && profile)
 		remove_config_tree_by_source(cmd, profile->source);
 
 	return str;
@@ -1261,7 +1261,7 @@ const char *find_config_tree_str_allow_empty(struct cmd_context *cmd, int id, st
 	str = _config_disabled(cmd, item, path) ? cfg_def_get_default_value(cmd, item, CFG_TYPE_STRING, profile)
 						: dm_config_tree_find_str_allow_empty(cmd->cft, path, cfg_def_get_default_value(cmd, item, CFG_TYPE_STRING, profile));
 
-	if (profile_applied)
+	if (profile_applied && profile)
 		remove_config_tree_by_source(cmd, profile->source);
 
 	return str;
@@ -1283,7 +1283,7 @@ int find_config_tree_int(struct cmd_context *cmd, int id, struct profile *profil
 	i = _config_disabled(cmd, item, path) ? cfg_def_get_default_value(cmd, item, CFG_TYPE_INT, profile)
 					      : dm_config_tree_find_int(cmd->cft, path, cfg_def_get_default_value(cmd, item, CFG_TYPE_INT, profile));
 
-	if (profile_applied)
+	if (profile_applied && profile)
 		remove_config_tree_by_source(cmd, profile->source);
 
 	return i;
@@ -1305,7 +1305,7 @@ int64_t find_config_tree_int64(struct cmd_context *cmd, int id, struct profile *
 	i64 = _config_disabled(cmd, item, path) ? cfg_def_get_default_value(cmd, item, CFG_TYPE_INT, profile)
 						: dm_config_tree_find_int64(cmd->cft, path, cfg_def_get_default_value(cmd, item, CFG_TYPE_INT, profile));
 
-	if (profile_applied)
+	if (profile_applied && profile)
 		remove_config_tree_by_source(cmd, profile->source);
 
 	return i64;
@@ -1327,7 +1327,7 @@ float find_config_tree_float(struct cmd_context *cmd, int id, struct profile *pr
 	f = _config_disabled(cmd, item, path) ? cfg_def_get_default_value(cmd, item, CFG_TYPE_FLOAT, profile)
 					      : dm_config_tree_find_float(cmd->cft, path, cfg_def_get_default_value(cmd, item, CFG_TYPE_FLOAT, profile));
 
-	if (profile_applied)
+	if (profile_applied && profile)
 		remove_config_tree_by_source(cmd, profile->source);
 
 	return f;
@@ -1366,7 +1366,7 @@ int find_config_tree_bool(struct cmd_context *cmd, int id, struct profile *profi
 	b = _config_disabled(cmd, item, path) ? cfg_def_get_default_value(cmd, item, CFG_TYPE_BOOL, profile)
 					      : dm_config_tree_find_bool(cmd->cft, path, cfg_def_get_default_value(cmd, item, CFG_TYPE_BOOL, profile));
 
-	if (profile_applied)
+	if (profile_applied && profile)
 		remove_config_tree_by_source(cmd, profile->source);
 
 	return b;
@@ -1466,7 +1466,7 @@ const struct dm_config_node *find_config_tree_array(struct cmd_context *cmd, int
 		cn = cn_def;
 	}
 
-	if (profile_applied)
+	if (profile_applied && profile)
 		remove_config_tree_by_source(cmd, profile->source);
 
 	return cn;


