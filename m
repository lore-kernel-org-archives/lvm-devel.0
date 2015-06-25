From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 25 Jun 2015 11:55:07 +0000 (UTC)
Subject: master - lvmconfig: add --type full to display full tree of settings
Message-ID: <20150625115507.2104960FDE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c794c163b5800625a116ee53711f4d8db786ff30
Commit:        c794c163b5800625a116ee53711f4d8db786ff30
Parent:        f6de196c21a193db5400220f3636fad0875f6d5a
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Jun 25 10:51:30 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Jun 25 13:33:52 2015 +0200

lvmconfig: add --type full to display full tree of settings

The lvmconfig --type full is actually a combination of --type current
and --type missing together with --mergedconfig options used.

The overall outcome is a configuration tree with settings as LVM sees
it when it looks for the values - that means, if the setting is defined
in some config source (lvm.conf, --config, lvmlocal.conf or any profile
that is used), the setting is used. Otherwise, if the setting is not
defined in any part of the config cascade, the defaults are used.

The --type full displays exactly this final tree with all the values
defined, either coming from configuration tree or from defaults.
---
 WHATS_NEW           |    1 +
 lib/config/config.c |   42 ++++++++++++++++++++++++++++++++++++++----
 lib/config/config.h |   29 +++++++++++++++--------------
 man/lvmconfig.8.in  |   10 ++++++++--
 tools/commands.h    |    6 +++---
 tools/dumpconfig.c  |   35 ++++++++++++++++++++++++++---------
 6 files changed, 91 insertions(+), 32 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 41e5cc4..8f14bef 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.123 - 
 =================================
+  Add --type full to lvmconfig for full configuration tree view.
   Add undocumented environment variables to lvm man page. (2.02.119)
   Add device synchronization point before activating a new snapshot.
   Add --withspaces to lvmconfig to add spaces in output for better readability.
diff --git a/lib/config/config.c b/lib/config/config.c
index 22b8f09..fffaace 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -1669,6 +1669,7 @@ static int _out_line_fn(const struct dm_config_node *cn, const char *line, void
 	/* Usual tree view with nodes and their values. */
 	if ((out->tree_spec->type != CFG_DEF_TREE_CURRENT) &&
 	    (out->tree_spec->type != CFG_DEF_TREE_DIFF) &&
+	    (out->tree_spec->type != CFG_DEF_TREE_FULL) &&
 	    (cfg_def->flags & (CFG_DEFAULT_UNDEFINED | CFG_DEFAULT_COMMENTED))) {
 		space_prefix = ((len = strspn(line, "\t "))) ? dm_pool_strndup(out->mem, line, len) : NULL;
 		fprintf(out->fp, "%s%s%s\n", space_prefix ? : "", "# ", line + len);
@@ -1836,6 +1837,8 @@ static int _should_skip_def_node(struct config_def_tree_spec *spec, int section_
 		return 1;
 
 	switch (spec->type) {
+		case CFG_DEF_TREE_FULL:
+			/* fall through */
 		case CFG_DEF_TREE_MISSING:
 			if (!spec->check_status) {
 				log_error_once(INTERNAL_ERROR "couldn't determine missing "
@@ -1843,9 +1846,12 @@ static int _should_skip_def_node(struct config_def_tree_spec *spec, int section_
 				return 1;
 			}
 			if ((spec->check_status[id] & CFG_USED) ||
-			    (def->flags & CFG_NAME_VARIABLE) ||
-			    (def->since_version > spec->version) ||
-			    _should_skip_deprecated_def_node(def, spec))
+			    (def->flags & CFG_NAME_VARIABLE))
+				return 1;
+
+			if ((spec->type == CFG_DEF_TREE_MISSING) &&
+			    ((def->since_version > spec->version) ||
+			     _should_skip_deprecated_def_node(def, spec)))
 				return 1;
 			break;
 		case CFG_DEF_TREE_NEW:
@@ -1854,7 +1860,9 @@ static int _should_skip_def_node(struct config_def_tree_spec *spec, int section_
 				return 1;
 			break;
 		case CFG_DEF_TREE_PROFILABLE:
+			/* fall through */
 		case CFG_DEF_TREE_PROFILABLE_CMD:
+			/* fall through */
 		case CFG_DEF_TREE_PROFILABLE_MDA:
 			if (!(def->flags & CFG_PROFILABLE) ||
 			    (def->since_version > spec->version) ||
@@ -1910,7 +1918,7 @@ bad:
 
 struct dm_config_tree *config_def_create_tree(struct config_def_tree_spec *spec)
 {
-	struct dm_config_tree *cft;
+	struct dm_config_tree *cft = NULL, *tmp_cft = NULL;
 	struct dm_config_node *root = NULL, *relay = NULL, *tmp;
 	int id;
 
@@ -1934,7 +1942,33 @@ struct dm_config_tree *config_def_create_tree(struct config_def_tree_spec *spec)
 	}
 
 	cft->root = root;
+
+	if (spec->type == CFG_DEF_TREE_FULL) {
+		if (!(tmp_cft = dm_config_create())) {
+			log_error("Failed to create temporary config tree while creating full tree.");
+			goto bad;
+		}
+
+		if (!(tmp_cft->root = dm_config_clone_node_with_mem(cft->mem, spec->current_cft->root, 1))) {
+			log_error("Failed to clone current config tree.");
+			goto bad;
+		}
+
+		if (!merge_config_tree(spec->cmd, cft, tmp_cft, CONFIG_MERGE_TYPE_RAW)) {
+			log_error("Failed to merge default and current config tree.");
+			goto bad;
+		}
+
+		dm_config_destroy(tmp_cft);
+	}
+
 	return cft;
+bad:
+	if (cft)
+		dm_config_destroy(cft);
+	if (tmp_cft)
+		dm_config_destroy(tmp_cft);
+	return NULL;
 }
 
 static int _check_profile(struct cmd_context *cmd, struct profile *profile)
diff --git a/lib/config/config.h b/lib/config/config.h
index 9601dc1..24d1f3f 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -141,7 +141,7 @@ typedef struct cfg_def_item {
 typedef enum {
 	CFG_DEF_TREE_CURRENT,		/* tree of nodes with values currently set in the config */
 	CFG_DEF_TREE_MISSING,		/* tree of nodes missing in current config using default values */
-	CFG_DEF_TREE_COMPLETE,		/* CURRENT + MISSING, the tree actually used within execution, not implemented yet */
+	CFG_DEF_TREE_FULL,		/* CURRENT + MISSING, the tree actually used within execution */
 	CFG_DEF_TREE_DEFAULT,		/* tree of all possible config nodes with default values */
 	CFG_DEF_TREE_NEW,		/* tree of all new nodes that appeared in given version */
 	CFG_DEF_TREE_PROFILABLE,	/* tree of all nodes that are customizable by profiles */
@@ -153,19 +153,20 @@ typedef enum {
 
 /* configuration definition tree specification */
 struct config_def_tree_spec {
-	struct cmd_context *cmd;	/* command context (for run-time defaults */
-	cfg_def_tree_t type;		/* tree type */
-	uint16_t version;		/* tree at this LVM2 version */
-	unsigned ignoreadvanced:1;	/* do not include advanced configs */
-	unsigned ignoreunsupported:1;	/* do not include unsupported configs */
-	unsigned ignoredeprecated:1;	/* do not include deprecated configs */
-	unsigned ignorelocal:1;		/* do not include the local section */
-	unsigned withsummary:1;		/* include first line of comments - a summary */
-	unsigned withcomments:1;	/* include all comment lines */
-	unsigned withversions:1;	/* include versions */
-	unsigned withspaces:1;		/* add more spaces in output for better readability */
-	unsigned unconfigured:1;	/* use unconfigured path strings */
-	uint8_t *check_status;		/* status of last tree check (currently needed for CFG_DEF_TREE_MISSING only) */
+	struct cmd_context *cmd;		/* command context (for run-time defaults */
+	struct dm_config_tree *current_cft;	/* current config tree which is defined explicitly - defaults are not used */
+	cfg_def_tree_t type;			/* tree type */
+	uint16_t version;			/* tree at this LVM2 version */
+	unsigned ignoreadvanced:1;		/* do not include advanced configs */
+	unsigned ignoreunsupported:1;		/* do not include unsupported configs */
+	unsigned ignoredeprecated:1;		/* do not include deprecated configs */
+	unsigned ignorelocal:1;			/* do not include the local section */
+	unsigned withsummary:1;			/* include first line of comments - a summary */
+	unsigned withcomments:1;		/* include all comment lines */
+	unsigned withversions:1;		/* include versions */
+	unsigned withspaces:1;			/* add more spaces in output for better readability */
+	unsigned unconfigured:1;		/* use unconfigured path strings */
+	uint8_t *check_status;			/* status of last tree check (currently needed for CFG_DEF_TREE_MISSING only) */
 };
 
 
diff --git a/man/lvmconfig.8.in b/man/lvmconfig.8.in
index 761b1e9..6d1b3fc 100644
--- a/man/lvmconfig.8.in
+++ b/man/lvmconfig.8.in
@@ -6,7 +6,7 @@ lvmconfig, lvm dumpconfig, lvm config \(em Display LVM configuration
 .RB [ \-f | \-\-file
 .IR filename ]
 .RB [ \-\-type
-.RI { current | default | diff | list | missing | new | profilable | profilable-command | profilable-metadata }
+.RI { current | default | diff | full | list | missing | new | profilable | profilable-command | profilable-metadata }
 .RB [ \-\-atversion
 .IR version ]
 .RB [ \-\-ignoreadvanced ]
@@ -47,7 +47,7 @@ List configuration settings with summarizing comment. This is the same as using
 \fBlvmconfig --type list --withsummary\fP.
 
 .TP
-.IR \fB\-\-type " {" current | default | diff | missing | new | profilable }
+.IR \fB\-\-type " {" current | default | diff | full | missing | new | profilable | profilable-command | profilable-metadata }
 Select the type of configuration to display. The configuration settings
 displayed have either default values or currently-used values assigned based on
 the type selected. If no type is selected, \fB\-\-type current\fP is used
@@ -67,6 +67,12 @@ Display all configuration settings for which the values used differ from default
 The value assigned for each configuration setting is the value currently used.
 This is actually minimal LVM configuration which can be used without
 a change to current configured behaviour.
+.IP full 3
+Display full configuration tree - a combination of current configuration tree
+(\fB\-\-type current\fP) and tree of settings for which default values are
+used (\fB\-\-type missing\fP). This is exactly the configuration tree that
+LVM2 uses during command execution. Using this type also implies
+the use of \fB\-\-mergedconfig\fP option.
 .IP list 3
 Display plain list of configuration settings.
 .IP missing 3
diff --git a/tools/commands.h b/tools/commands.h
index d89b214..9fe4db1 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -33,7 +33,7 @@ xx(config,
    PERMITTED_READ_ONLY,
    "config\n"
    "\t[-f|--file filename]\n"
-   "\t[--type {current|default|diff|list|missing|new|profilable|profilable-command|profilable-metadata}\n"
+   "\t[--type {current|default|diff|full|list|missing|new|profilable|profilable-command|profilable-metadata}\n"
    "\t[--atversion version]]\n"
    "\t[--ignoreadvanced]\n"
    "\t[--ignoreunsupported]\n"
@@ -89,7 +89,7 @@ xx(dumpconfig,
    PERMITTED_READ_ONLY,
    "dumpconfig\n"
    "\t[-f|--file filename]\n"
-   "\t[--type {current|default|diff|list|missing|new|profilable|profilable-command|profilable-metadata}\n"
+   "\t[--type {current|default|diff|full|list|missing|new|profilable|profilable-command|profilable-metadata}\n"
    "\t[--atversion version]]\n"
    "\t[--ignoreadvanced]\n"
    "\t[--ignoreunsupported]\n"
@@ -494,7 +494,7 @@ xx(lvmconfig,
    PERMITTED_READ_ONLY,
    "lvmconfig\n"
    "\t[-f|--file filename]\n"
-   "\t[--type {current|default|diff|list|missing|new|profilable|profilable-command|profilable-metadata}\n"
+   "\t[--type {current|default|diff|full|list|missing|new|profilable|profilable-command|profilable-metadata}\n"
    "\t[--atversion version]]\n"
    "\t[--ignoreadvanced]\n"
    "\t[--ignoreunsupported]\n"
diff --git a/tools/dumpconfig.c b/tools/dumpconfig.c
index f6a6217..c9c5bf9 100644
--- a/tools/dumpconfig.c
+++ b/tools/dumpconfig.c
@@ -154,21 +154,22 @@ int dumpconfig(struct cmd_context *cmd, int argc, char **argv)
 	if (arg_count(cmd, ignorelocal_ARG))
 		tree_spec.ignorelocal = 1;
 
-	if (!strcmp(type, "current")) {
+	if (!strcmp(type, "current") || !strcmp(type, "full")) {
 		if (arg_count(cmd, atversion_ARG)) {
-			log_error("--atversion has no effect with --type current");
+			log_error("--atversion has no effect with --type %s", type);
 			return EINVALID_CMD_LINE;
 		}
 
-		if (arg_count(cmd, ignoreunsupported_ARG) ||
-		    arg_count(cmd, ignoreadvanced_ARG)) {
+		if ((arg_count(cmd, ignoreunsupported_ARG) ||
+		    arg_count(cmd, ignoreadvanced_ARG)) &&
+		    !strcmp(type, "current")) {
 			/* FIXME: allow these even for --type current */
 			log_error("--ignoreadvanced and --ignoreunsupported has "
 				  "no effect with --type current");
 			return EINVALID_CMD_LINE;
 		}
 	} else if (arg_count(cmd, mergedconfig_ARG)) {
-		log_error("--mergedconfig has no effect without --type current");
+		log_error("--mergedconfig has no effect without --type current or --type full");
 		return EINVALID_CMD_LINE;
 	}
 
@@ -191,7 +192,7 @@ int dumpconfig(struct cmd_context *cmd, int argc, char **argv)
 	 * Set the 'cft' to work with based on whether we need the plain
 	 * config tree or merged config tree cascade if --mergedconfig is used.
 	 */
-	if (arg_count(cmd, mergedconfig_ARG) && cmd->cft->cascade) {
+	if ((arg_count(cmd, mergedconfig_ARG) || !strcmp(type, "full")) && cmd->cft->cascade) {
 		if (!_merge_config_cascade(cmd, cmd->cft, &cft)) {
 			log_error("Failed to merge configuration.");
 			r = ECMD_FAILED;
@@ -199,6 +200,7 @@ int dumpconfig(struct cmd_context *cmd, int argc, char **argv)
 		}
 	} else
 		cft = cmd->cft;
+	tree_spec.current_cft = cft;
 
 	if (arg_count(cmd, validate_ARG)) {
 		if (_config_validate(cmd, cft)) {
@@ -218,6 +220,12 @@ int dumpconfig(struct cmd_context *cmd, int argc, char **argv)
 			return EINVALID_CMD_LINE;
 		}
 		/* list type does not require status check */
+	} else if (!strcmp(type, "full")) {
+		tree_spec.type = CFG_DEF_TREE_FULL;
+		if (!_do_def_check(&tree_spec, cft, &cft_check_handle)) {
+			r = ECMD_FAILED;
+			goto_out;
+		}
 	} else if (!strcmp(type, "current")) {
 		tree_spec.type = CFG_DEF_TREE_CURRENT;
 		if (!_do_def_check(&tree_spec, cft, &cft_check_handle)) {
@@ -261,8 +269,8 @@ int dumpconfig(struct cmd_context *cmd, int argc, char **argv)
 	}
 	else {
 		log_error("Incorrect type of configuration specified. "
-			  "Expected one of: current, default, list, missing, new, "
-			  "profilable, profilable-command, profilable-metadata.");
+			  "Expected one of: current, default, diff, full, list, missing, "
+			  "new, profilable, profilable-command, profilable-metadata.");
 		r = EINVALID_CMD_LINE;
 		goto out;
 	}
@@ -295,8 +303,17 @@ int dumpconfig(struct cmd_context *cmd, int argc, char **argv)
 		r = ECMD_FAILED;
 	}
 out:
+	if (tree_spec.current_cft && (tree_spec.current_cft != cft) &&
+	    (tree_spec.current_cft != cmd->cft))
+		/*
+		 * This happens in case of CFG_DEF_TREE_FULL where we
+		 * have merged explicitly defined config trees and also
+		 * we have used default tree.
+		 */
+		dm_config_destroy(tree_spec.current_cft);
+
 	if (cft && (cft != cmd->cft))
-		dm_pool_destroy(cft->mem);
+		dm_config_destroy(cft);
 	else if (profile)
 		remove_config_tree_by_source(cmd, CONFIG_PROFILE_COMMAND);
 


