From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 25 Feb 2014 10:33:21 +0000 (UTC)
Subject: master - dumpconfig: add a comment to each config with variable name, use '<name>' to denote that for config paths
Message-ID: <20140225103321.75E806126A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f8bf4d7dfbd0ab44ec035bc61a286388a263fc48
Commit:        f8bf4d7dfbd0ab44ec035bc61a286388a263fc48
Parent:        558c932444fb4058e1db99147b286bfed72e94d0
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Feb 25 11:08:00 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Feb 25 11:32:54 2014 +0100

dumpconfig: add a comment to each config with variable name, use '<name>' to denote that for config paths

Just to make the dumpconfig output (the comments) more readable
when we hit configuration lines that have variable names (e.g. tags).
---
 lib/config/config.c |   21 ++++++++++++++-------
 1 files changed, 14 insertions(+), 7 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index 69e357b..e51c26f 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -477,20 +477,24 @@ time_t config_file_timestamp(struct dm_config_tree *cft)
 
 #define cfg_def_get_item_p(id) (&_cfg_def_items[id])
 #define cfg_def_get_default_value(item,type) item->default_value.v_##type
-#define cfg_def_get_path(item) (_cfg_def_make_path(_cfg_path,CFG_PATH_MAX_LEN,item->id,item),_cfg_path)
+#define cfg_def_get_path(item) (_cfg_def_make_path(_cfg_path,CFG_PATH_MAX_LEN,item->id,item, 0),_cfg_path)
+#define cfg_def_get_path_xlated(item) (_cfg_def_make_path(_cfg_path,CFG_PATH_MAX_LEN,item->id,item, 1),_cfg_path)
 
-static int _cfg_def_make_path(char *buf, size_t buf_size, int id, cfg_def_item_t *item)
+static int _cfg_def_make_path(char *buf, size_t buf_size, int id, cfg_def_item_t *item, int xlate)
 {
+	int variable = item->flags & CFG_NAME_VARIABLE;
 	int parent_id = item->parent;
 	int count, n;
 
 	if (id == parent_id)
 		return 0;
 
-	count = _cfg_def_make_path(buf, buf_size, parent_id, cfg_def_get_item_p(parent_id));
-	if ((n = dm_snprintf(buf + count, buf_size - count, "%s%s",
+	count = _cfg_def_make_path(buf, buf_size, parent_id, cfg_def_get_item_p(parent_id), xlate);
+	if ((n = dm_snprintf(buf + count, buf_size - count, "%s%s%s%s",
 			     count ? "/" : "",
-			     item->flags & CFG_NAME_VARIABLE ? "#" : item->name)) < 0) {
+			     xlate && variable ? "<" : "",
+			     !xlate && variable ? "#" : item->name,
+			     xlate && variable ? ">" : "")) < 0) {
 		log_error(INTERNAL_ERROR "_cfg_def_make_path: supplied buffer too small for %s/%s",
 					  cfg_def_get_item_p(parent_id)->name, item->name);
 		buf[0] = '\0';
@@ -502,7 +506,7 @@ static int _cfg_def_make_path(char *buf, size_t buf_size, int id, cfg_def_item_t
 
 int config_def_get_path(char *buf, size_t buf_size, int id)
 {
-	return _cfg_def_make_path(buf, buf_size, id, cfg_def_get_item_p(id));
+	return _cfg_def_make_path(buf, buf_size, id, cfg_def_get_item_p(id), 0);
 }
 
 static void _get_type_name(char *buf, size_t buf_size, cfg_def_type_t type)
@@ -1108,7 +1112,7 @@ static int _out_prefix_fn(const struct dm_config_node *cn, const char *line, voi
 	cfg_def = cfg_def_get_item_p(cn->id);
 
 	if (out->tree_spec->withcomments) {
-		path = cfg_def_get_path(cfg_def);
+		path = cfg_def_get_path_xlated(cfg_def);
 		fprintf(out->fp, "%s# Configuration %s %s.\n", line, node_type_name, path);
 
 		if (cfg_def->comment)
@@ -1120,6 +1124,9 @@ static int _out_prefix_fn(const struct dm_config_node *cn, const char *line, voi
 		if (cfg_def->flags & CFG_UNSUPPORTED)
 			fprintf(out->fp, "%s# This configuration %s is not officially supported.\n", line, node_type_name);
 
+		if (cfg_def->flags & CFG_NAME_VARIABLE)
+			fprintf(out->fp, "%s# This configuration %s has variable name.\n", line, node_type_name);
+
 		if (cfg_def->flags & CFG_DEFAULT_UNDEFINED)
 			fprintf(out->fp, "%s# This configuration %s does not have a default value defined.\n", line, node_type_name);
 	}


