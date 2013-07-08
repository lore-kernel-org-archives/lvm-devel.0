From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon,  8 Jul 2013 14:06:27 +0000 (UTC)
Subject: master - config: fix use of last config check status if creating CFG_DEF_TREE_MISSING tree
Message-ID: <20130708140627.8A7C66073F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=661406a417e3cbf2170ba7c3debd767d50e99cae
Commit:        661406a417e3cbf2170ba7c3debd767d50e99cae
Parent:        f5584d420356c8ca0b797952b07f5b5387957c17
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Jul 8 14:13:09 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jul 8 15:57:49 2013 +0200

config: fix use of last config check status if creating CFG_DEF_TREE_MISSING tree

When CFG_DEF_TREE_MISSING is created, it needs to know the status
of the check done on the tree used (the CFG_USED flag).

This bug was introduced with f1c292cc38f4ba2e8d9b7272bc1a1ce17bd729a5
"make it possible to run several instances of configuration check at
once". This patch separated the CFG_USED and CFG_VALID flags in
a separate 'status' field in struct cft_check_handle.

However, when creating some trees, like CFG_DEF_TREE_MISSING,
we need this status to do a comparison with full config definition
to determine which items are missing and for which default values
were used. Otherwise, all items would be considered missing.

So, pass this status in a new field called 'check_status' in
struct config_def_tree_spec that defines how the (dumpconfig) tree
should be constructed (and this struct is passed to
config_def_create_tree fn then).
---
 lib/config/config.c |   15 +++++++++++----
 lib/config/config.h |    1 +
 tools/dumpconfig.c  |   47 +++++++++++++++++++++++++++++++++--------------
 3 files changed, 45 insertions(+), 18 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index 61e92cf..26b2aa8 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -1336,8 +1336,10 @@ static struct dm_config_node *_add_def_node(struct dm_config_tree *cft,
 	return cn;
 }
 
-static int _should_skip_def_node(struct config_def_tree_spec *spec, int section_id, cfg_def_item_t *def)
+static int _should_skip_def_node(struct config_def_tree_spec *spec, int section_id, int id)
 {
+	cfg_def_item_t *def = cfg_def_get_item_p(id);
+
 	if ((def->parent != section_id) ||
 	    (spec->ignoreadvanced && def->flags & CFG_ADVANCED) ||
 	    (spec->ignoreunsupported && def->flags & CFG_UNSUPPORTED))
@@ -1345,7 +1347,12 @@ static int _should_skip_def_node(struct config_def_tree_spec *spec, int section_
 
 	switch (spec->type) {
 		case CFG_DEF_TREE_MISSING:
-			if ((def->flags & CFG_USED) ||
+			if (!spec->check_status) {
+				log_error_once(INTERNAL_ERROR "couldn't determine missing "
+				       "config nodes - unknown status of last config check.");
+				return 1;
+			}
+			if ((spec->check_status[id] & CFG_USED) ||
 			    (def->flags & CFG_NAME_VARIABLE) ||
 			    (def->since_version > spec->version))
 				return 1;
@@ -1374,13 +1381,13 @@ static struct dm_config_node *_add_def_section_subtree(struct dm_config_tree *cf
 	int id;
 
 	for (id = 0; id < CFG_COUNT; id++) {
-		def = cfg_def_get_item_p(id);
-		if (_should_skip_def_node(spec, section_id, def))
+		if (_should_skip_def_node(spec, section_id, id))
 			continue;
 
 		if (!cn && !(cn = _add_def_node(cft, spec, parent, relay, cfg_def_get_item_p(section_id))))
 				goto bad;
 
+		def = cfg_def_get_item_p(id);
 		if ((tmp = def->type == CFG_TYPE_SECTION ? _add_def_section_subtree(cft, spec, cn, relay_sub, id)
 							 : _add_def_node(cft, spec, cn, relay_sub, def)))
 			relay_sub = tmp;
diff --git a/lib/config/config.h b/lib/config/config.h
index 5109a23..9f54af6 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -110,6 +110,7 @@ struct config_def_tree_spec {
 	uint16_t version;		/* tree at this LVM2 version */
 	int ignoreadvanced;		/* do not include advanced configs */
 	int ignoreunsupported;		/* do not include unsupported configs */
+	uint8_t *check_status;		/* status of last tree check (currently needed for CFG_DEF_TREE_MISSING only) */
 };
 
 
diff --git a/tools/dumpconfig.c b/tools/dumpconfig.c
index ebee786..3839def 100644
--- a/tools/dumpconfig.c
+++ b/tools/dumpconfig.c
@@ -45,13 +45,30 @@ static struct cft_check_handle *_get_cft_check_handle(struct cmd_context *cmd)
 	return handle;
 }
 
+static int _do_def_check(struct cmd_context *cmd, struct cft_check_handle **cft_check_handle)
+{
+	struct cft_check_handle *handle;
+
+	if (!(handle = _get_cft_check_handle(cmd)))
+		return 0;
+
+	handle->force_check = 1;
+	handle->skip_if_checked = 1;
+	handle->suppress_messages = 1;
+
+	config_def_check(cmd, handle);
+	*cft_check_handle = handle;
+
+	return 1;
+}
+
 int dumpconfig(struct cmd_context *cmd, int argc, char **argv)
 {
 	const char *file = arg_str_value(cmd, file_ARG, NULL);
 	const char *type = arg_str_value(cmd, configtype_ARG, "current");
 	struct config_def_tree_spec tree_spec = {0};
 	struct dm_config_tree *cft = NULL;
-	struct cft_check_handle *cft_check_handle;
+	struct cft_check_handle *cft_check_handle = NULL;
 	int r = ECMD_PROCESSED;
 
 	if (arg_count(cmd, configtype_ARG) && arg_count(cmd, validate_ARG)) {
@@ -105,29 +122,31 @@ int dumpconfig(struct cmd_context *cmd, int argc, char **argv)
 
 	if (!strcmp(type, "current")) {
 		tree_spec.type = CFG_DEF_TREE_CURRENT;
-
-		if (!(cft_check_handle = _get_cft_check_handle(cmd)))
+		if (!_do_def_check(cmd, &cft_check_handle))
 			return ECMD_FAILED;
-
-		cft_check_handle->force_check = 1;
-		cft_check_handle->skip_if_checked = 1;
-		cft_check_handle->suppress_messages = 1;
-
-		config_def_check(cmd, cft_check_handle);
 	}
-
-	else if (!strcmp(type, "default"))
-		tree_spec.type = CFG_DEF_TREE_DEFAULT;
-	else if (!strcmp(type, "missing"))
+	else if (!strcmp(type, "missing")) {
 		tree_spec.type = CFG_DEF_TREE_MISSING;
-	else if (!strcmp(type, "new"))
+		if (!_do_def_check(cmd, &cft_check_handle))
+			return ECMD_FAILED;
+	}
+	else if (!strcmp(type, "default")) {
+		tree_spec.type = CFG_DEF_TREE_DEFAULT;
+		/* default type does not require check status */
+	}
+	else if (!strcmp(type, "new")) {
 		tree_spec.type = CFG_DEF_TREE_NEW;
+		/* new type does not require check status */
+	}
 	else {
 		log_error("Incorrect type of configuration specified. "
 			  "Expected one of: current, default, missing, new.");
 		return EINVALID_CMD_LINE;
 	}
 
+	if (cft_check_handle)
+		tree_spec.check_status = cft_check_handle->status;
+
 	if (tree_spec.type == CFG_DEF_TREE_CURRENT)
 		cft = cmd->cft;
 	else


