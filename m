From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon,  8 Jul 2013 14:06:25 +0000 (UTC)
Subject: master - cleanup: cleanup dumpconfig code
Message-ID: <20130708140625.72B82613D6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f5584d420356c8ca0b797952b07f5b5387957c17
Commit:        f5584d420356c8ca0b797952b07f5b5387957c17
Parent:        985251c8f385d2611dde44d1bf6824223f073749
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Jul 8 13:45:37 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jul 8 15:46:19 2013 +0200

cleanup: cleanup dumpconfig code

---
 tools/dumpconfig.c |   57 ++++++++++++++++++++++++++++-----------------------
 1 files changed, 31 insertions(+), 26 deletions(-)

diff --git a/tools/dumpconfig.c b/tools/dumpconfig.c
index 2d6cbe3..ebee786 100644
--- a/tools/dumpconfig.c
+++ b/tools/dumpconfig.c
@@ -15,19 +15,17 @@
 
 #include "tools.h"
 
-static int _get_vsn(struct cmd_context *cmd, unsigned int *major,
-		    unsigned int *minor, unsigned int *patchlevel)
+static int _get_vsn(struct cmd_context *cmd, uint16_t *version)
 {
-	const char *atversion = arg_str_value(cmd, atversion_ARG, NULL);
-
-	if (!atversion)
-		atversion = LVM_VERSION;
+	const char *atversion = arg_str_value(cmd, atversion_ARG, LVM_VERSION);
+	unsigned int major, minor, patchlevel;
 
-	if (sscanf(atversion, "%u.%u.%u", major, minor, patchlevel) != 3) {
+	if (sscanf(atversion, "%u.%u.%u", &major, &minor, &patchlevel) != 3) {
 		log_error("Incorrect version format.");
 		return 0;
 	}
 
+	*version = vsn(major, minor, patchlevel);
 	return 1;
 }
 
@@ -51,9 +49,8 @@ int dumpconfig(struct cmd_context *cmd, int argc, char **argv)
 {
 	const char *file = arg_str_value(cmd, file_ARG, NULL);
 	const char *type = arg_str_value(cmd, configtype_ARG, "current");
-	unsigned int major, minor, patchlevel;
 	struct config_def_tree_spec tree_spec = {0};
-	struct dm_config_tree *cft = cmd->cft;
+	struct dm_config_tree *cft = NULL;
 	struct cft_check_handle *cft_check_handle;
 	int r = ECMD_PROCESSED;
 
@@ -73,6 +70,22 @@ int dumpconfig(struct cmd_context *cmd, int argc, char **argv)
 	if (arg_count(cmd, ignoreunsupported_ARG))
 		tree_spec.ignoreunsupported = 1;
 
+	if (!strcmp(type, "current")) {
+		if (arg_count(cmd, atversion_ARG)) {
+			log_error("--atversion has no effect with --type current");
+			return EINVALID_CMD_LINE;
+		}
+
+		if ((tree_spec.ignoreadvanced || tree_spec.ignoreunsupported)) {
+			log_error("--ignoreadvanced and --ignoreunsupported has "
+				  "no effect with --type current");
+			return EINVALID_CMD_LINE;
+		}
+	}
+
+	if (!_get_vsn(cmd, &tree_spec.version))
+		return EINVALID_CMD_LINE;
+
 	if (arg_count(cmd, validate_ARG)) {
 		if (!(cft_check_handle = _get_cft_check_handle(cmd)))
 			return ECMD_FAILED;
@@ -91,10 +104,6 @@ int dumpconfig(struct cmd_context *cmd, int argc, char **argv)
 	}
 
 	if (!strcmp(type, "current")) {
-		if (arg_count(cmd, atversion_ARG)) {
-			log_error("--atversion has no effect with --type current");
-			return EINVALID_CMD_LINE;
-		}
 		tree_spec.type = CFG_DEF_TREE_CURRENT;
 
 		if (!(cft_check_handle = _get_cft_check_handle(cmd)))
@@ -119,18 +128,10 @@ int dumpconfig(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
-	if ((tree_spec.ignoreadvanced || tree_spec.ignoreunsupported) &&
-	    (tree_spec.type == CFG_DEF_TREE_CURRENT)) {
-		log_error("--ignoreadvanced and --ignoreunsupported has no effect with --type current");
-		return EINVALID_CMD_LINE;
-	}
-
-	if (tree_spec.type != CFG_DEF_TREE_CURRENT) {
-		if (!_get_vsn(cmd, &major, &minor, &patchlevel))
-			return EINVALID_CMD_LINE;
-		tree_spec.version = vsn(major, minor, patchlevel);
+	if (tree_spec.type == CFG_DEF_TREE_CURRENT)
+		cft = cmd->cft;
+	else
 		cft = config_def_create_tree(&tree_spec);
-	}
 
 	if (!config_write(cft, arg_count(cmd, withcomments_ARG),
 			  arg_count(cmd, withversions_ARG),
@@ -139,9 +140,13 @@ int dumpconfig(struct cmd_context *cmd, int argc, char **argv)
 		r = ECMD_FAILED;
 	}
 
-	/* cmd->cft (the "current" tree) is destroyed with cmd context destroy! */
-	if (tree_spec.type != CFG_DEF_TREE_CURRENT && cft)
+	if (cft != cmd->cft)
 		dm_pool_destroy(cft->mem);
 
+	/*
+	 * The cmd->cft (the "current" tree) is destroyed
+	 * together with cmd context destroy...
+	 */
+
 	return r;
 }


