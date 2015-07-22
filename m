From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 22 Jul 2015 12:26:40 +0000 (UTC)
Subject: master - config: add CFG_SECTION_NO_CHECK flag
Message-ID: <20150722122640.444B461078@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8bfcefe11a2ce594d1f6e8ef5a1b17e80786ceab
Commit:        8bfcefe11a2ce594d1f6e8ef5a1b17e80786ceab
Parent:        00d24511bc5e1ae446867f65b5adfe3e7d404398
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jul 22 14:19:07 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jul 22 14:25:42 2015 +0200

config: add CFG_SECTION_NO_CHECK flag

The CFG_SECTION_NO_CHECK flag can be used to mark a section
and its whole subtree as containing settings where checks
won't be made (lvmconfig --validate).

These are setting where we don't know the names and and type
in advance and they're recognized in runtime. As we don't know
the type and name in advance, we can't do any checks here
of course.

Use this flag with great care as it disables config checks
for the whole config subtree found under such section.

This flag is going to be used by subsequent patches from
Zdenek to support some cache settings...
---
 lib/config/config.c          |   12 ++++++------
 lib/config/config.h          |    2 ++
 lib/config/config_settings.h |    1 +
 3 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index 35ee3ac..eb8880e 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -1040,9 +1040,14 @@ static int _config_def_check_tree(struct cft_check_handle *handle,
 				  size_t buf_size, struct dm_config_node *root)
 {
 	struct dm_config_node *cn;
+	cfg_def_item_t *def;
 	int valid, r = 1;
 	size_t len;
 
+	def = cfg_def_get_item_p(root->id);
+	if (def->flags & CFG_SECTION_NO_CHECK)
+		return 1;
+
 	for (cn = root->child; cn; cn = cn->sib) {
 		if ((valid = _config_def_check_node(handle, vp, pvp, rp, prp,
 						    buf_size, cn)) && !cn->v) {
@@ -1662,14 +1667,9 @@ static int _out_prefix_fn(const struct dm_config_node *cn, const char *line, voi
 	char path[CFG_PATH_MAX_LEN];
 	char commentline[MAX_COMMENT_LINE+1];
 
-	if (cn->id < 0)
+	if (cn->id <= 0)
 		return 1;
 
-	if (!cn->id) {
-		log_error(INTERNAL_ERROR "Configuration node %s has invalid id.", cn->key);
-		return 0;
-	}
-
 	if (out->tree_spec->type == CFG_DEF_TREE_LIST)
 		return 1;
 
diff --git a/lib/config/config.h b/lib/config/config.h
index 03319bf..7520fc0 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -121,6 +121,8 @@ typedef union {
 #define CFG_DISABLED		0x200
 /* whether to print integers in octal form (prefixed by "0") */
 #define CFG_FORMAT_INT_OCTAL	0x400
+/* whether to disable checks for the whole config section subtree */
+#define CFG_SECTION_NO_CHECK	0x800
 
 /* configuration definition item structure */
 typedef struct cfg_def_item {
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index ce03b36..5209531 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -51,6 +51,7 @@
  *                                 CFG_DEFAULT_COMMENTED - node's default value is commented out on output
  *                                 CFG_DISABLED - configuration is disabled (defaults always used)
  *                                 CFG_FORMAT_INT_OCTAL - print integer number in octal form (also prefixed by "0")
+ *                                 CFG_SECTION_NO_CHECK - do not check content of the section at all - use with care!!!
  *
  * type:		       Allowed type for the value of simple configuation setting, one of:
  *                                 CFG_TYPE_BOOL


