From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu,  6 Oct 2011 11:43:01 +0200
Subject: [PATCH 2/3] Add find_config_tree_str_allow_empty
In-Reply-To: <cover.1317893838.git.zkabelac@redhat.com>
References: <cover.1317893838.git.zkabelac@redhat.com>
Message-ID: <292d94bd113c0246856e80bff4152958b28339cc.1317893838.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add function to allow read of empty strings as valid arguments.
Add a warning message if string argument has ignored value.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/commands/toolcontext.c |    7 ++++---
 lib/config/config.c        |    6 ++++++
 lib/config/config.h        |    2 ++
 libdm/libdevmapper.h       |    2 ++
 libdm/libdm-config.c       |   19 ++++++++++++++-----
 5 files changed, 28 insertions(+), 8 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 6c554b2..5ab2c83 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -127,6 +127,7 @@ static void _init_logging(struct cmd_context *cmd)
 
 	const char *log_file;
 	char timebuf[26];
+	const struct dm_config_node *cn;
 
 	/* Syslog */
 	cmd->default_settings.syslog =
@@ -153,9 +154,9 @@ static void _init_logging(struct cmd_context *cmd)
 	init_abort_on_internal_errors(find_config_tree_int(cmd, "global/abort_on_internal_errors",
 							   DEFAULT_ABORT_ON_INTERNAL_ERRORS));
 
-	cmd->default_settings.msg_prefix = find_config_tree_str(cmd,
-							   "log/prefix",
-							   DEFAULT_MSG_PREFIX);
+	cmd->default_settings.msg_prefix =
+		find_config_tree_str_allow_empty(cmd, "log/prefix", DEFAULT_MSG_PREFIX);
+
 	init_msg_prefix(cmd->default_settings.msg_prefix);
 
 	cmd->default_settings.cmd_name = find_config_tree_int(cmd,
diff --git a/lib/config/config.c b/lib/config/config.c
index c62e959..d82fee4 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -182,6 +182,12 @@ const char *find_config_tree_str(struct cmd_context *cmd,
 	return dm_config_tree_find_str(cmd->cft, path, fail);
 }
 
+const char *find_config_tree_str_allow_empty(struct cmd_context *cmd,
+					     const char *path, const char *fail)
+{
+	return dm_config_tree_find_str_allow_empty(cmd->cft, path, fail);
+}
+
 int find_config_tree_int(struct cmd_context *cmd, const char *path,
 			 int fail)
 {
diff --git a/lib/config/config.h b/lib/config/config.h
index 5edc6cc..dd6daeb 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -44,6 +44,8 @@ const struct dm_config_node *find_config_tree_node(struct cmd_context *cmd,
 						   const char *path);
 const char *find_config_tree_str(struct cmd_context *cmd,
 				 const char *path, const char *fail);
+const char *find_config_tree_str_allow_empty(struct cmd_context *cmd,
+					     const char *path, const char *fail);
 int find_config_tree_int(struct cmd_context *cmd, const char *path,
 			 int fail);
 int64_t find_config_tree_int64(struct cmd_context *cmd, const char *path,
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 223a0fe..84b586b 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -1350,6 +1350,8 @@ float dm_config_find_float(const struct dm_config_node *cn, const char *path, fl
 const struct dm_config_node *dm_config_tree_find_node(const struct dm_config_tree *cft, const char *path);
 const char *dm_config_tree_find_str(const struct dm_config_tree *cft,
 				    const char *path, const char *fail);
+const char *dm_config_tree_find_str_allow_empty(const struct dm_config_tree *cft,
+						const char *path, const char *fail);
 int dm_config_tree_find_int(const struct dm_config_tree *cft,
 			    const char *path, int fail);
 int64_t dm_config_tree_find_int64(const struct dm_config_tree *cft,
diff --git a/libdm/libdm-config.c b/libdm/libdm-config.c
index b9ce7a3..3ece3d3 100644
--- a/libdm/libdm-config.c
+++ b/libdm/libdm-config.c
@@ -923,15 +923,18 @@ static const struct dm_config_node *_find_first_config_node(const void *start, c
 }
 
 static const char *_find_config_str(const void *start, node_lookup_fn find_fn,
-				    const char *path, const char *fail)
+				    const char *path, const char *fail, int allow_empty)
 {
 	const struct dm_config_node *n = find_fn(start, path);
 
 	/* Empty strings are ignored */
-	if ((n && n->v && n->v->type == DM_CFG_STRING) && (*n->v->v.str)) {
+	if ((n && n->v && n->v->type == DM_CFG_STRING) &&
+	    (allow_empty || (*n->v->v.str))) {
 		log_very_verbose("Setting %s to %s", path, n->v->v.str);
 		return n->v->v.str;
-	}
+	} else if (n && (!n->v || (n->v->type != DM_CFG_STRING) ||
+			 (!allow_empty && fail)))
+		log_warn("WARNING: Ignoring unsupported value for %s.", path);
 
 	if (fail)
 		log_very_verbose("%s not found in config: defaulting to %s",
@@ -942,7 +945,7 @@ static const char *_find_config_str(const void *start, node_lookup_fn find_fn,
 const char *dm_config_find_str(const struct dm_config_node *cn,
 			       const char *path, const char *fail)
 {
-	return _find_config_str(cn, _find_config_node, path, fail);
+	return _find_config_str(cn, _find_config_node, path, fail, 0);
 }
 
 static int64_t _find_config_int64(const void *start, node_lookup_fn find,
@@ -1064,7 +1067,13 @@ const struct dm_config_node *dm_config_tree_find_node(const struct dm_config_tre
 const char *dm_config_tree_find_str(const struct dm_config_tree *cft, const char *path,
 				    const char *fail)
 {
-	return _find_config_str(cft, _find_first_config_node, path, fail);
+	return _find_config_str(cft, _find_first_config_node, path, fail, 0);
+}
+
+const char *dm_config_tree_find_str_allow_empty(const struct dm_config_tree *cft, const char *path,
+						const char *fail)
+{
+	return _find_config_str(cft, _find_first_config_node, path, fail, 1);
 }
 
 int dm_config_tree_find_int(const struct dm_config_tree *cft, const char *path, int fail)
-- 
1.7.6.4


