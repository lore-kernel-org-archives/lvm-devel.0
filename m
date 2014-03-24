From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 24 Mar 2014 14:36:29 +0000 (UTC)
Subject: master - dumpconfig: add dumpconfig --type diff to show differences from defaults
Message-ID: <20140324143629.ABE4460DA4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5dcec1734e653ca137975bdfd4556e93447f10a0
Commit:        5dcec1734e653ca137975bdfd4556e93447f10a0
Parent:        76ff38fa5cdec332750452c2ed209d4beac261eb
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Mar 24 13:19:15 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Mar 24 15:35:54 2014 +0100

dumpconfig: add dumpconfig --type diff to show differences from defaults

---
 WHATS_NEW           |    1 +
 lib/config/config.c |    9 +++++++++
 lib/config/config.h |    3 ++-
 tools/commands.h    |    2 +-
 tools/dumpconfig.c  |   23 ++++++++++++++++++-----
 5 files changed, 31 insertions(+), 7 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 3fd6a8a..4ac1fa2 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.106 - 
 ====================================
+  Add 'lvm dumpconfig --type diff' to show differences from defaults.
   Fix swap signature detection for devices smaller then 2MB.
   Reindent some clvmd.c code.
   Use dm_malloc function in clvmd.c.
diff --git a/lib/config/config.c b/lib/config/config.c
index 46e0cc1..161241e 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -1283,6 +1283,10 @@ static int _out_prefix_fn(const struct dm_config_node *cn, const char *line, voi
 		return 0;
 	}
 
+	if ((out->tree_spec->type == CFG_DEF_TREE_DIFF) &&
+	    (!(out->tree_spec->check_status[cn->id] & CFG_DIFF)))
+		return 1;
+
 	cfg_def = cfg_def_get_item_p(cn->id);
 
 	if (out->tree_spec->withcomments) {
@@ -1324,7 +1328,12 @@ static int _out_line_fn(const struct dm_config_node *cn, const char *line, void
 	struct out_baton *out = baton;
 	struct cfg_def_item *cfg_def = cfg_def_get_item_p(cn->id);
 
+	if ((out->tree_spec->type == CFG_DEF_TREE_DIFF) &&
+	    (!(out->tree_spec->check_status[cn->id] & CFG_DIFF)))
+		return 1;
+
 	fprintf(out->fp, "%s%s\n", (out->tree_spec->type != CFG_DEF_TREE_CURRENT) &&
+				   (out->tree_spec->type != CFG_DEF_TREE_DIFF) &&
 				   (cfg_def->flags & CFG_DEFAULT_UNDEFINED) ? "#" : "", line);
 	return 1;
 }
diff --git a/lib/config/config.h b/lib/config/config.h
index 5d67e85..a61d285 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -121,7 +121,8 @@ typedef enum {
 	CFG_DEF_TREE_COMPLETE,		/* CURRENT + MISSING, the tree actually used within execution, not implemented yet */
 	CFG_DEF_TREE_DEFAULT,		/* tree of all possible config nodes with default values */
 	CFG_DEF_TREE_NEW,		/* tree of all new nodes that appeared in given version */
-	CFG_DEF_TREE_PROFILABLE		/* tree of all nodes that are customizable by profiles */
+	CFG_DEF_TREE_PROFILABLE,	/* tree of all nodes that are customizable by profiles */
+	CFG_DEF_TREE_DIFF,		/* tree of all nodes that differ from defaults */
 } cfg_def_tree_t;
 
 /* configuration definition tree specification */
diff --git a/tools/commands.h b/tools/commands.h
index b0d608b..c047cb9 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -57,7 +57,7 @@ xx(dumpconfig,
    PERMITTED_READ_ONLY,
    "dumpconfig\n"
    "\t[-f|--file filename] \n"
-   "\t[--type {current|default|missing|new|profilable} \n"
+   "\t[--type {current|default|diff|missing|new|profilable} \n"
    "\t[--atversion version]] \n"
    "\t[--ignoreadvanced] \n"
    "\t[--ignoreunsupported] \n"
diff --git a/tools/dumpconfig.c b/tools/dumpconfig.c
index 7404462..97863be 100644
--- a/tools/dumpconfig.c
+++ b/tools/dumpconfig.c
@@ -56,18 +56,23 @@ static struct cft_check_handle *_get_cft_check_handle(struct cmd_context *cmd, s
 	return handle;
 }
 
-static int _do_def_check(struct cmd_context *cmd, struct dm_config_tree *cft,
+static int _do_def_check(struct config_def_tree_spec *spec,
+			 struct dm_config_tree *cft,
 			 struct cft_check_handle **cft_check_handle)
 {
 	struct cft_check_handle *handle;
 
-	if (!(handle = _get_cft_check_handle(cmd, cft)))
+	if (!(handle = _get_cft_check_handle(spec->cmd, cft)))
 		return 0;
 
 	handle->force_check = 1;
-	handle->skip_if_checked = 1;
 	handle->suppress_messages = 1;
 
+	if (spec->type == CFG_DEF_TREE_DIFF)
+		handle->check_diff = 1;
+	else
+		handle->skip_if_checked = 1;
+
 	config_def_check(handle);
 	*cft_check_handle = handle;
 
@@ -168,14 +173,14 @@ int dumpconfig(struct cmd_context *cmd, int argc, char **argv)
 
 	if (!strcmp(type, "current")) {
 		tree_spec.type = CFG_DEF_TREE_CURRENT;
-		if (!_do_def_check(cmd, cft, &cft_check_handle)) {
+		if (!_do_def_check(&tree_spec, cft, &cft_check_handle)) {
 			r = ECMD_FAILED;
 			goto_out;
 		}
 	}
 	else if (!strcmp(type, "missing")) {
 		tree_spec.type = CFG_DEF_TREE_MISSING;
-		if (!_do_def_check(cmd, cft, &cft_check_handle)) {
+		if (!_do_def_check(&tree_spec, cft, &cft_check_handle)) {
 			r = ECMD_FAILED;
 			goto_out;
 		}
@@ -184,6 +189,13 @@ int dumpconfig(struct cmd_context *cmd, int argc, char **argv)
 		tree_spec.type = CFG_DEF_TREE_DEFAULT;
 		/* default type does not require check status */
 	}
+	else if (!strcmp(type, "diff")) {
+		tree_spec.type = CFG_DEF_TREE_DIFF;
+		if (!_do_def_check(&tree_spec, cft, &cft_check_handle)) {
+			r = ECMD_FAILED;
+			goto_out;
+		}
+	}
 	else if (!strcmp(type, "new")) {
 		tree_spec.type = CFG_DEF_TREE_NEW;
 		/* new type does not require check status */
@@ -209,6 +221,7 @@ int dumpconfig(struct cmd_context *cmd, int argc, char **argv)
 		tree_spec.check_status = cft_check_handle->status;
 
 	if ((tree_spec.type != CFG_DEF_TREE_CURRENT) &&
+	    (tree_spec.type != CFG_DEF_TREE_DIFF) &&
 	    !(cft = config_def_create_tree(&tree_spec))) {
 		r = ECMD_FAILED;
 		goto_out;


