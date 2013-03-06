From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed,  6 Mar 2013 11:15:49 +0000 (UTC)
Subject: master - dumpconfig: add --ignoreadvanced and --ignoreunsupported switch
Message-ID: <20130306111549.8F947A0C29@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7d6991e900cbd5959e73285af81079bc22eadccb
Commit:        7d6991e900cbd5959e73285af81079bc22eadccb
Parent:        7fd04bd93a1ea3e86c90c396151424719f3e1b63
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Mar 6 09:35:33 2013 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Mar 6 10:46:36 2013 +0100

dumpconfig: add --ignoreadvanced and --ignoreunsupported switch

lvm dumpconfig [--ignoreadvanced] [--ignoreunsupported]

--ignoreadvanced causes the advanced configuration options to be left
out on dumpconfig output

--ignoreunsupported causes the options that are not officially supported
to be lef out on dumpconfig output
---
 lib/config/config.c |    4 +++-
 tools/args.h        |    2 ++
 tools/commands.h    |    5 ++++-
 tools/dumpconfig.c  |   12 ++++++++++++
 4 files changed, 21 insertions(+), 2 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index 1960b00..009eb5f 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -1080,7 +1080,9 @@ static struct dm_config_node *_add_def_node(struct dm_config_tree *cft,
 
 static int _should_skip_def_node(struct config_def_tree_spec *spec, int section_id, cfg_def_item_t *def)
 {
-	if (def->parent != section_id)
+	if ((def->parent != section_id) ||
+	    (spec->ignoreadvanced && def->flags & CFG_ADVANCED) ||
+	    (spec->ignoreunsupported && def->flags & CFG_UNSUPPORTED))
 		return 1;
 
 	switch (spec->type) {
diff --git a/tools/args.h b/tools/args.h
index 1e85096..49ddcd2 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -82,6 +82,8 @@ arg(thinpool_ARG, '\0', "thinpool", string_arg, 0)
 arg(configtype_ARG, '\0', "type", string_arg, 0)
 arg(withcomments_ARG, '\0', "withcomments", NULL, 0)
 arg(withversions_ARG, '\0', "withversions", NULL, 0)
+arg(ignoreadvanced_ARG, '\0', "ignoreadvanced", NULL, 0)
+arg(ignoreunsupported_ARG, '\0', "ignoreunsupported", NULL, 0)
 arg(atversion_ARG, '\0', "atversion", string_arg, 0)
 arg(validate_ARG, '\0', "validate", NULL, 0)
 
diff --git a/tools/commands.h b/tools/commands.h
index 36928c0..9aed9e7 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -36,11 +36,14 @@ xx(dumpconfig,
    "\t[--type {current|default|missing|new} \n"
    "\t[--withcomments] \n"
    "\t[--withversions] \n"
+   "\t[--ignoreadvanced] \n"
+   "\t[--ignoreunsupported] \n"
    "\t[--atversion version]] \n"
    "\t[--validate]\n"
    "\t[ConfigurationNode...]\n",
    file_ARG, configtype_ARG, withcomments_ARG, atversion_ARG,
-   withversions_ARG, validate_ARG)
+   withversions_ARG, ignoreadvanced_ARG, ignoreunsupported_ARG,
+   validate_ARG)
 
 xx(formats,
    "List available metadata formats",
diff --git a/tools/dumpconfig.c b/tools/dumpconfig.c
index 384f52d..a340eb0 100644
--- a/tools/dumpconfig.c
+++ b/tools/dumpconfig.c
@@ -50,6 +50,12 @@ int dumpconfig(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
+	if (arg_count(cmd, ignoreadvanced_ARG))
+		tree_spec.ignoreadvanced = 1;
+
+	if (arg_count(cmd, ignoreunsupported_ARG))
+		tree_spec.ignoreunsupported = 1;
+
 	if (arg_count(cmd, validate_ARG)) {
 		if (config_def_check(cmd, 1, 1, 0)) {
 			log_print("LVM configuration valid.");
@@ -82,6 +88,12 @@ int dumpconfig(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
+	if ((tree_spec.ignoreadvanced || tree_spec.ignoreunsupported) &&
+	    (tree_spec.type == CFG_DEF_TREE_CURRENT)) {
+		log_error("--ignoreadvanced and --ignoreunsupported has no effect with --type current");
+		return EINVALID_CMD_LINE;
+	}
+
 	if (tree_spec.type != CFG_DEF_TREE_CURRENT) {
 		if (!_get_vsn(cmd, &major, &minor, &patchlevel))
 			return EINVALID_CMD_LINE;


