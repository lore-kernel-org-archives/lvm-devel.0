From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 23 Feb 2015 17:49:02 +0000 (UTC)
Subject: master - config: Reinstate recursive tags setting.
Message-ID: <20150223174902.0E7726032D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2a1189ebc34d640396b87be410642cc394d01f27
Commit:        2a1189ebc34d640396b87be410642cc394d01f27
Parent:        36a6c0df46a09657cb92908d41d272bc6b8a722d
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Feb 23 17:40:58 2015 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Feb 23 17:40:58 2015 +0000

config: Reinstate recursive tags setting.

In 2.02.99, _init_tags() inadvertently began to ignore the
dm_config_tree struct passed to it.  "tags" sections are not
merged together, so the "tags" section in the main config file was
being processed repeatedly and other "tags" sections were ignored.
---
 WHATS_NEW                  |    1 +
 lib/commands/toolcontext.c |    5 +++--
 lib/config/config.c        |   33 +++++++++++++++++++++++++++++++--
 lib/config/config.h        |    6 ++++++
 4 files changed, 41 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index fa4e2b0..92bb1aa 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.117 - 
 ====================================
+  Reinstate recursive config file tag section processing. (2.02.99)
   Add 'lvm systemid' to display the current system ID.
   Fix configure to properly recognize --with-default-raid10-segtype option.
   Do not refresh filters/rescan if no signature is wiped during pvcreate.
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index f984f70..2e15086 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -623,11 +623,12 @@ static int _init_tags(struct cmd_context *cmd, struct dm_config_tree *cft)
 	const char *tag;
 	int passes;
 
-	if (!(tn = find_config_tree_node(cmd, tags_CFG_SECTION, NULL)) || !tn->child)
+	/* Access tags section directly */
+	if (!(tn = find_config_node(cmd, cft, tags_CFG_SECTION)) || !tn->child)
 		return 1;
 
 	/* NB hosttags 0 when already 1 intentionally does not delete the tag */
-	if (!cmd->hosttags && find_config_tree_bool(cmd, tags_hosttags_CFG, NULL)) {
+	if (!cmd->hosttags && find_config_bool(cmd, cft, tags_hosttags_CFG)) {
 		/* FIXME Strip out invalid chars: only A-Za-z0-9_+.- */
 		if (!_set_tag(cmd, cmd->hostname))
 			return_0;
diff --git a/lib/config/config.c b/lib/config/config.c
index b47984f..d7b11c3 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -649,8 +649,8 @@ static void _log_type_error(const char *path, cfg_def_type_t actual,
 	_get_type_name(actual_type_name, sizeof(actual_type_name), actual);
 	_get_type_name(expected_type_name, sizeof(expected_type_name), expected);
 
-	log_warn_suppress(suppress_messages, "Configuration setting \"%s\" has invalid type. "
-					     "Found%s, expected%s.", path,
+	log_warn_suppress(suppress_messages, "WARNING: Configuration setting \"%s\" has invalid type. "
+					     "Found%s but expected%s.", path,
 					     actual_type_name, expected_type_name);
 }
 
@@ -1145,6 +1145,19 @@ static int _apply_local_profile(struct cmd_context *cmd, struct profile *profile
 	return override_config_tree_from_profile(cmd, profile);
 }
 
+const struct dm_config_node *find_config_node(struct cmd_context *cmd, struct dm_config_tree *cft, int id)
+{
+	cfg_def_item_t *item = cfg_def_get_item_p(id);
+	char path[CFG_PATH_MAX_LEN];
+	const struct dm_config_node *cn;
+
+	_cfg_def_make_path(path, sizeof(path), item->id, item, 0);
+
+	cn = dm_config_tree_find_node(cft, path);
+
+	return cn;
+}
+
 const struct dm_config_node *find_config_tree_node(struct cmd_context *cmd, int id, struct profile *profile)
 {
 	cfg_def_item_t *item = cfg_def_get_item_p(id);
@@ -1270,6 +1283,22 @@ float find_config_tree_float(struct cmd_context *cmd, int id, struct profile *pr
 	return f;
 }
 
+int find_config_bool(struct cmd_context *cmd, struct dm_config_tree *cft, int id)
+{
+	cfg_def_item_t *item = cfg_def_get_item_p(id);
+	char path[CFG_PATH_MAX_LEN];
+	int b;
+
+	_cfg_def_make_path(path, sizeof(path), item->id, item, 0);
+
+	if (item->type != CFG_TYPE_BOOL)
+		log_error(INTERNAL_ERROR "%s cfg tree element not declared as boolean.", path);
+
+	b = dm_config_tree_find_bool(cft, path, cfg_def_get_default_value(cmd, item, CFG_TYPE_BOOL, NULL));
+
+	return b;
+}
+
 int find_config_tree_bool(struct cmd_context *cmd, int id, struct profile *profile)
 {
 	cfg_def_item_t *item = cfg_def_get_item_p(id);
diff --git a/lib/config/config.h b/lib/config/config.h
index d095519..965214e 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -231,6 +231,12 @@ int merge_config_tree(struct cmd_context *cmd, struct dm_config_tree *cft,
 		      struct dm_config_tree *newdata, config_merge_t);
 
 /*
+ * The next two do not check config overrides and must only be used for the tags section.
+ */
+const struct dm_config_node *find_config_node(struct cmd_context *cmd, struct dm_config_tree *cft, int id);
+int find_config_bool(struct cmd_context *cmd, struct dm_config_tree *cft, int id);
+
+/*
  * These versions check an override tree, if present, first.
  */
 const struct dm_config_node *find_config_tree_node(struct cmd_context *cmd, int id, struct profile *profile);


