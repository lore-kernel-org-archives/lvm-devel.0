From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed,  6 Mar 2013 11:15:39 +0000 (UTC)
Subject: master - dumpconfig: add --type, --atversion and --validate arg
Message-ID: <20130306111539.842B3A0C29@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=34350963d1b02d54205b1bdaa0c7778f4c5601fe
Commit:        34350963d1b02d54205b1bdaa0c7778f4c5601fe
Parent:        245b85692ec9f30153c1aa7216d81e65bb132792
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Mar 5 17:48:29 2013 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Mar 6 10:46:36 2013 +0100

dumpconfig: add --type, --atversion and --validate arg

lvm dumpconfig [--type {current|default|missing|new}] [--atversion] [--validate]

This patch adds above-mentioned args to lvm dumpconfig and it maps them
to creation and writing out a configuration tree of a specific type
(see also previous commit):

  - current maps to CFG_TYPE_CURRENT
  - default maps to CFG_TYPE_DEFAULT
  - missing maps to CFG_TYPE_MISSING
  - new maps to CFG_TYPE_NEW

If --type is not defined, dumpconfig defaults to "--type current"
which is the original behaviour of dumpconfig before all these changes.

The --validate option just validates current configuration tree
(lvm.conf/--config) and it writes a simple status message:

  "LVM configuration valid" or "LVM configuration invalid"
---
 lib/config/config.c |    2 +-
 tools/args.h        |    3 ++
 tools/commands.h    |   13 +++++---
 tools/dumpconfig.c  |   80 +++++++++++++++++++++++++++++++++++++++++++++++++--
 tools/tools.h       |    1 +
 5 files changed, 90 insertions(+), 9 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index 43f9d21..a02f478 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -488,7 +488,7 @@ static int _config_def_check_node(const char *vp, char *pvp, char *rp, char *prp
 
 	def->flags |= CFG_USED;
 	if (!_config_def_check_node_value(rp, cn->v, def, suppress_messages))
-		return 0;
+	return 0;
 
 	def->flags |= CFG_VALID;
 	return 1;
diff --git a/tools/args.h b/tools/args.h
index 08ace69..8d9abd5 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -79,6 +79,9 @@ arg(force_long_ARG, '\0', "force", NULL, ARG_COUNTABLE)
 arg(stripes_long_ARG, '\0', "stripes", int_arg, 0)
 arg(sysinit_ARG, '\0', "sysinit", NULL, 0)
 arg(thinpool_ARG, '\0', "thinpool", string_arg, 0)
+arg(configtype_ARG, '\0', "type", string_arg, 0)
+arg(atversion_ARG, '\0', "atversion", string_arg, 0)
+arg(validate_ARG, '\0', "validate", NULL, 0)
 
 /* Allow some variations */
 arg(resizable_ARG, '\0', "resizable", yes_no_arg, 0)
diff --git a/tools/commands.h b/tools/commands.h
index dedba54..dc245b9 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -29,12 +29,15 @@ xx(e2fsadm,
 *********/
 
 xx(dumpconfig,
-   "Dump active configuration",
+   "Dump configuration",
    PERMITTED_READ_ONLY,
-   "dumpconfig "
-   "\t[-f|--file filename] " "\n"
-   "[ConfigurationVariable...]\n",
-   file_ARG)
+   "dumpconfig\n"
+   "\t[-f|--file filename] \n"
+   "\t[--type {current|default|missing|new} \n"
+   "\t[--atversion version]] \n"
+   "\t[--validate]\n"
+   "\t[ConfigurationNode...]\n",
+   file_ARG, configtype_ARG, atversion_ARG, validate_ARG)
 
 xx(formats,
    "List available metadata formats",
diff --git a/tools/dumpconfig.c b/tools/dumpconfig.c
index c5f5226..ac90a95 100644
--- a/tools/dumpconfig.c
+++ b/tools/dumpconfig.c
@@ -15,14 +15,88 @@
 
 #include "tools.h"
 
+static int _get_vsn(struct cmd_context *cmd, unsigned int *major,
+		    unsigned int *minor, unsigned int *patchlevel)
+{
+	const char *atversion = arg_str_value(cmd, atversion_ARG, NULL);
+
+	if (!atversion)
+		atversion = LVM_VERSION;
+
+	if (sscanf(atversion, "%u.%u.%u", major, minor, patchlevel) != 3) {
+		log_error("Incorrect version format.");
+		return 0;
+	}
+
+	return 1;
+}
+
 int dumpconfig(struct cmd_context *cmd, int argc, char **argv)
 {
 	const char *file = arg_str_value(cmd, file_ARG, NULL);
+	const char *type = arg_str_value(cmd, configtype_ARG, "current");
+	unsigned int major, minor, patchlevel;
+	struct config_def_tree_spec tree_spec = {0};
+	struct dm_config_tree *cft;
+	int r = ECMD_PROCESSED;
+
+	if (arg_count(cmd, configtype_ARG) && arg_count(cmd, validate_ARG)) {
+		log_error("Only one of --type and --validate permitted.");
+		return EINVALID_CMD_LINE;
+	}
+
+	if (arg_count(cmd, atversion_ARG) && !arg_count(cmd, configtype_ARG)) {
+		log_error("--atversion requires --type");
+		return EINVALID_CMD_LINE;
+	}
+
+	if (arg_count(cmd, validate_ARG)) {
+		if (config_def_check(cmd, 1, 1, 0)) {
+			log_print("LVM configuration valid.");
+			return ECMD_PROCESSED;
+		} else {
+			log_error("LVM configuration invalid.");
+			return ECMD_FAILED;
+		}
+	}
+
+	if (!strcmp(type, "current")) {
+		if (arg_count(cmd, atversion_ARG)) {
+			log_error("--atversion has no effect with --type current");
+			return EINVALID_CMD_LINE;
+		}
+		cft = cmd->cft;
+		tree_spec.type = CFG_DEF_TREE_CURRENT;
+		config_def_check(cmd, 1, 1, 1);
+	}
 
-	if (!config_write(cmd->cft, file, argc, argv)) {
+	else if (!strcmp(type, "default"))
+		tree_spec.type = CFG_DEF_TREE_DEFAULT;
+	else if (!strcmp(type, "missing"))
+		tree_spec.type = CFG_DEF_TREE_MISSING;
+	else if (!strcmp(type, "new"))
+		tree_spec.type = CFG_DEF_TREE_NEW;
+	else {
+		log_error("Incorrect type of configuration specified. "
+			  "Expected one of: current, default, missing, new.");
+		return EINVALID_CMD_LINE;
+	}
+
+	if (tree_spec.type != CFG_DEF_TREE_CURRENT) {
+		if (!_get_vsn(cmd, &major, &minor, &patchlevel))
+			return EINVALID_CMD_LINE;
+		tree_spec.version = vsn(major, minor, patchlevel);
+		cft = config_def_create_tree(&tree_spec);
+	}
+
+	if (!config_write(cft, file, argc, argv)) {
 		stack;
-		return ECMD_FAILED;
+		r = ECMD_FAILED;
 	}
 
-	return ECMD_PROCESSED;
+	/* cmd->cft (the "current" tree) is destroyed with cmd context destroy! */
+	if (tree_spec.type != CFG_DEF_TREE_CURRENT && cft)
+		dm_pool_destroy(cft->mem);
+
+	return r;
 }
diff --git a/tools/tools.h b/tools/tools.h
index a3ad9fd..673e40b 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -29,6 +29,7 @@
 #include "archiver.h"
 #include "lvmcache.h"
 #include "lvmetad.h"
+#include "lvm-version.h"
 #include "config.h"
 #include "defaults.h"
 #include "dev-cache.h"


