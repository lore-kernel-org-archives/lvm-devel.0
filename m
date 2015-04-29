From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 29 Apr 2015 10:01:50 +0000 (UTC)
Subject: master - lvmconfig: add --type list and -l|--list
Message-ID: <20150429100150.02A8360355@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3be3eb2995f83ab73a2a1419b1db5f1098fcb5a8
Commit:        3be3eb2995f83ab73a2a1419b1db5f1098fcb5a8
Parent:        0ba332e82a308415d715bf8a24ebf5d649f1c071
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Apr 29 11:11:58 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Apr 29 11:58:14 2015 +0200

lvmconfig: add --type list and -l|--list

lvmconfig --type list displays plain list of configuration settings.
Some of the existing decorations can be used (--withsummary and
--withversions) as well as existing options/switches (--ignoreadvanced,
--ignoreunsupported, --ignorelocal, --atversion).

For example (displaying only "config" section so the list is not long):

$lvmconfig --type list config
config/checks
config/abort_on_errors
config/profile_dir

$ lvmconfig --type list --withsummary config
config/checks - If enabled, any LVM configuration mismatch is reported.
config/abort_on_errors - Abort the LVM process if a configuration mismatch is found.
config/profile_dir - Directory where LVM looks for configuration profiles.

$ lvmconfig -l config
config/checks - If enabled, any LVM configuration mismatch is reported.
config/abort_on_errors - Abort the LVM process if a configuration mismatch is found.
config/profile_dir - Directory where LVM looks for configuration profiles.

$ lvmconfig --type list --withsummary --withversions config
config/checks - If enabled, any LVM configuration mismatch is reported. [2.2.99]
config/abort_on_errors - Abort the LVM process if a configuration mismatch is found. [2.2.99]
config/profile_dir - Directory where LVM looks for configuration profiles. [2.2.99]

Example with --atversion (displaying global section):

$ lvmconfig --type list global
global/umask
global/test
global/units
global/si_unit_consistency
global/suffix
global/activation
global/fallback_to_lvm1
global/format
global/format_libraries
global/segment_libraries
global/proc
global/etc
global/locking_type
global/wait_for_locks
global/fallback_to_clustered_locking
global/fallback_to_local_locking
global/locking_dir
global/prioritise_write_locks
global/library_dir
global/locking_library
global/abort_on_internal_errors
global/detect_internal_vg_cache_corruption
global/metadata_read_only
global/mirror_segtype_default
global/raid10_segtype_default
global/sparse_segtype_default
global/lvdisplay_shows_full_device_path
global/use_lvmetad
global/thin_check_executable
global/thin_dump_executable
global/thin_repair_executable
global/thin_check_options
global/thin_repair_options
global/thin_disabled_features
global/cache_check_executable
global/cache_dump_executable
global/cache_repair_executable
global/cache_check_options
global/cache_repair_options
global/system_id_source
global/system_id_file

$ lvmconfig --type list global --atversion 2.2.50
global/umask
global/test
global/units
global/suffix
global/activation
global/fallback_to_lvm1
global/format
global/format_libraries
global/segment_libraries
global/proc
global/locking_type
global/wait_for_locks
global/fallback_to_clustered_locking
global/fallback_to_local_locking
global/locking_dir
global/library_dir
global/locking_library
---
 WHATS_NEW           |    2 +
 lib/config/config.c |   53 ++++++++++++++++++++++++++++++++++++++++++++------
 lib/config/config.h |    1 +
 man/lvmconfig.8.in  |    8 +++++++
 tools/commands.h    |   15 ++++++++-----
 tools/dumpconfig.c  |   25 ++++++++++++++++++-----
 6 files changed, 85 insertions(+), 19 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index ad1573e..7873d37 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,7 @@
 Version 2.02.119 - 
 ==================================
+  Add lvmconfig -l|--list as shortcut for lvmconfig --type list --withsummary.
+  Add lvmconfig --type list to display plain list of configuration settings.
   Introduce lvmconfig as the preferred form of 'lvm dumpconfig'.
   Add lv_ancestors and lv_descendants reporting fields.
   Add --ignorelocal option to dumpconfig to ignore the local section.
diff --git a/lib/config/config.c b/lib/config/config.c
index 79e9de4..45a1d36 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -1519,6 +1519,19 @@ static int _copy_one_line(const char *comment, char *line, int *pos, int len)
 	return i;
 }
 
+static int _get_config_node_version(char *version, struct cfg_def_item *cfg_def)
+{
+	if (dm_snprintf(version, 9, "%u.%u.%u",
+			(cfg_def->since_version & 0xE000) >> 13,
+			(cfg_def->since_version & 0x1E00) >> 9,
+			(cfg_def->since_version & 0x1FF)) == -1) {
+		log_error("_get_config_node_version: couldn't create version string");
+		return 0;
+	}
+
+	return 1;
+}
+
 static int _out_prefix_fn(const struct dm_config_node *cn, const char *line, void *baton)
 {
 	struct out_baton *out = baton;
@@ -1536,6 +1549,9 @@ static int _out_prefix_fn(const struct dm_config_node *cn, const char *line, voi
 		return 0;
 	}
 
+	if (out->tree_spec->type == CFG_DEF_TREE_LIST)
+		return 1;
+
 	if ((out->tree_spec->type == CFG_DEF_TREE_DIFF) &&
 	    (!(out->tree_spec->check_status[cn->id] & CFG_DIFF)))
 		return 1;
@@ -1571,13 +1587,8 @@ static int _out_prefix_fn(const struct dm_config_node *cn, const char *line, voi
 	}
 
 	if (out->tree_spec->withversions) {
-		if (dm_snprintf(version, 9, "%u.%u.%u",
-				(cfg_def->since_version & 0xE000) >> 13,
-				(cfg_def->since_version & 0x1E00) >> 9,
-				(cfg_def->since_version & 0x1FF)) == -1) {
-			log_error("_out_prefix_fn: couldn't create version string");
-			return 0;
-		}
+		if (!_get_config_node_version(version, cfg_def))
+			return_0;
 		fprintf(out->fp, "%s# Since version %s.\n", line, version);
 	}
 
@@ -1588,14 +1599,42 @@ static int _out_line_fn(const struct dm_config_node *cn, const char *line, void
 {
 	struct out_baton *out = baton;
 	struct cfg_def_item *cfg_def = cfg_def_get_item_p(cn->id);
+	char config_path[CFG_PATH_MAX_LEN];
+	char summary[MAX_COMMENT_LINE+1];
+	char version[9];
+	int pos = 0;
 
 	if ((out->tree_spec->type == CFG_DEF_TREE_DIFF) &&
 	    (!(out->tree_spec->check_status[cn->id] & CFG_DIFF)))
 		return 1;
 
+	if (out->tree_spec->type == CFG_DEF_TREE_LIST) {
+		/* List view with node paths and summary. */
+		if (cfg_def->type & CFG_TYPE_SECTION)
+			return 1;
+		if (!_cfg_def_make_path(config_path, CFG_PATH_MAX_LEN, cfg_def->id, cfg_def, 1))
+			return_0;
+		if (out->tree_spec->withsummary) {
+			summary[0] = '\0';
+			if (cfg_def->comment)
+				_copy_one_line(cfg_def->comment, summary, &pos, strlen(cfg_def->comment));
+			if (out->tree_spec->withversions && !_get_config_node_version(version, cfg_def))
+				return_0;
+			fprintf(out->fp, "%s - %s%s%s%s\n", config_path, summary,
+				out->tree_spec->withversions ? " [" : "",
+				out->tree_spec->withversions ? version : "",
+				out->tree_spec->withversions ? "]" : "");
+		} else
+			fprintf(out->fp, "%s\n", config_path);
+
+		return 1;
+	}
+
+	/* Usual tree view with nodes and their values. */
 	fprintf(out->fp, "%s%s\n", (out->tree_spec->type != CFG_DEF_TREE_CURRENT) &&
 				   (out->tree_spec->type != CFG_DEF_TREE_DIFF) &&
 				   (cfg_def->flags & CFG_DEFAULT_UNDEFINED) ? "#" : "", line);
+
 	return 1;
 }
 
diff --git a/lib/config/config.h b/lib/config/config.h
index a316cd0..1e9f0f8 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -142,6 +142,7 @@ typedef enum {
 	CFG_DEF_TREE_PROFILABLE_CMD,	/* tree of all nodes that are customizable by command profiles (subset of PROFILABLE) */
 	CFG_DEF_TREE_PROFILABLE_MDA,	/* tree of all nodes that are customizable by metadata profiles (subset of PROFILABLE) */
 	CFG_DEF_TREE_DIFF,		/* tree of all nodes that differ from defaults */
+	CFG_DEF_TREE_LIST,		/* list all nodes */
 } cfg_def_tree_t;
 
 /* configuration definition tree specification */
diff --git a/man/lvmconfig.8.in b/man/lvmconfig.8.in
index ce59d52..798e2bb 100644
--- a/man/lvmconfig.8.in
+++ b/man/lvmconfig.8.in
@@ -12,6 +12,7 @@ lvmconfig, lvm dumpconfig, lvm config \(em Display LVM configuration
 .RB [ \-\-ignoreadvanced ]
 .RB [ \-\-ignoreunsupported ]
 .RB [ \-\-ignorelocal ]
+.RB [ \-l | \-\-list ]
 .RB [ \-\-config
 .IR ConfigurationString ]
 .RB [ \-\-commandprofile
@@ -38,6 +39,11 @@ The command was added in release 2.02.119 and has an identical longer form
 Send output to a file named 'filename'.
 
 .TP
+.BR \-l ", " \-\-list
+List configuration settings with summarizing comment. This is the same as using
+\fBlvmconfig --type list --withsummary\fP.
+
+.TP
 .IR \fB\-\-type " {" current | default | diff | missing | new | profilable }
 Select the type of configuration to display. The configuration settings
 displayed have either default values or currently-used values assigned based on
@@ -58,6 +64,8 @@ Display all configuration settings for which the values used differ from default
 The value assigned for each configuration setting is the value currently used.
 This is actually minimal LVM configuration which can be used without
 a change to current configured behaviour.
+.IP list 3
+Display plain list of configuration settings.
 .IP missing 3
 Display all configuration settings with default values assigned which are
 missing in the configuration currently used and for which LVM automatically
diff --git a/tools/commands.h b/tools/commands.h
index ea70cc2..f7b6e98 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -33,11 +33,12 @@ xx(config,
    PERMITTED_READ_ONLY,
    "config\n"
    "\t[-f|--file filename]\n"
-   "\t[--type {current|default|diff|missing|new|profilable|profilable-command|profilable-metadata}\n"
+   "\t[--type {current|default|diff|list|missing|new|profilable|profilable-command|profilable-metadata}\n"
    "\t[--atversion version]]\n"
    "\t[--ignoreadvanced]\n"
    "\t[--ignoreunsupported]\n"
    "\t[--ignorelocal]\n"
+   "\t[-l|--list]\n"
    "\t[--config ConfigurationString]\n"
    "\t[--commandprofile ProfileName]\n"
    "\t[--profile ProfileName]\n"
@@ -50,7 +51,7 @@ xx(config,
    "\t[--withversions]\n"
    "\t[ConfigurationNode...]\n",
    atversion_ARG, configtype_ARG, file_ARG, ignoreadvanced_ARG,
-   ignoreunsupported_ARG, ignorelocal_ARG, mergedconfig_ARG, metadataprofile_ARG,
+   ignoreunsupported_ARG, ignorelocal_ARG, list_ARG, mergedconfig_ARG, metadataprofile_ARG,
    validate_ARG, withsummary_ARG, withcomments_ARG, unconfigured_ARG, withversions_ARG)
 
 xx(devtypes,
@@ -84,11 +85,12 @@ xx(dumpconfig,
    PERMITTED_READ_ONLY,
    "dumpconfig\n"
    "\t[-f|--file filename]\n"
-   "\t[--type {current|default|diff|missing|new|profilable|profilable-command|profilable-metadata}\n"
+   "\t[--type {current|default|diff|list|missing|new|profilable|profilable-command|profilable-metadata}\n"
    "\t[--atversion version]]\n"
    "\t[--ignoreadvanced]\n"
    "\t[--ignoreunsupported]\n"
    "\t[--ignorelocal]\n"
+   "\t[-l|--list]\n"
    "\t[--config ConfigurationString]\n"
    "\t[--commandprofile ProfileName]\n"
    "\t[--profile ProfileName]\n"
@@ -101,7 +103,7 @@ xx(dumpconfig,
    "\t[--withversions]\n"
    "\t[ConfigurationNode...]\n",
    atversion_ARG, configtype_ARG, file_ARG, ignoreadvanced_ARG,
-   ignoreunsupported_ARG, ignorelocal_ARG, mergedconfig_ARG, metadataprofile_ARG,
+   ignoreunsupported_ARG, ignorelocal_ARG, list_ARG, mergedconfig_ARG, metadataprofile_ARG,
    validate_ARG, withsummary_ARG, withcomments_ARG, unconfigured_ARG, withversions_ARG)
 
 xx(formats,
@@ -484,11 +486,12 @@ xx(lvmconfig,
    PERMITTED_READ_ONLY,
    "lvmconfig\n"
    "\t[-f|--file filename]\n"
-   "\t[--type {current|default|diff|missing|new|profilable|profilable-command|profilable-metadata}\n"
+   "\t[--type {current|default|diff|list|missing|new|profilable|profilable-command|profilable-metadata}\n"
    "\t[--atversion version]]\n"
    "\t[--ignoreadvanced]\n"
    "\t[--ignoreunsupported]\n"
    "\t[--ignorelocal]\n"
+   "\t[-l|--list]\n"
    "\t[--config ConfigurationString]\n"
    "\t[--commandprofile ProfileName]\n"
    "\t[--profile ProfileName]\n"
@@ -501,7 +504,7 @@ xx(lvmconfig,
    "\t[--withversions]\n"
    "\t[ConfigurationNode...]\n",
    atversion_ARG, configtype_ARG, file_ARG, ignoreadvanced_ARG,
-   ignoreunsupported_ARG, ignorelocal_ARG, mergedconfig_ARG, metadataprofile_ARG,
+   ignoreunsupported_ARG, ignorelocal_ARG, list_ARG, mergedconfig_ARG, metadataprofile_ARG,
    validate_ARG, withsummary_ARG, withcomments_ARG, unconfigured_ARG, withversions_ARG)
 
 xx(lvmdiskscan,
diff --git a/tools/dumpconfig.c b/tools/dumpconfig.c
index 04d5df6..50057a1 100644
--- a/tools/dumpconfig.c
+++ b/tools/dumpconfig.c
@@ -88,7 +88,7 @@ static int _config_validate(struct cmd_context *cmd, struct dm_config_tree *cft)
 int dumpconfig(struct cmd_context *cmd, int argc, char **argv)
 {
 	const char *file = arg_str_value(cmd, file_ARG, NULL);
-	const char *type = arg_str_value(cmd, configtype_ARG, "current");
+	const char *type = arg_str_value(cmd, configtype_ARG, arg_count(cmd, list_ARG) ? "list" : "current");
 	struct config_def_tree_spec tree_spec = {0};
 	struct dm_config_tree *cft = NULL;
 	struct cft_check_handle *cft_check_handle = NULL;
@@ -102,8 +102,14 @@ int dumpconfig(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
-	if (arg_count(cmd, atversion_ARG) && !arg_count(cmd, configtype_ARG)) {
-		log_error("--atversion requires --type");
+	if (arg_count(cmd, configtype_ARG) && arg_count(cmd, list_ARG)) {
+		log_error("Only one of --type and --list permitted.");
+		return EINVALID_CMD_LINE;
+	}
+
+	if (arg_count(cmd, atversion_ARG) && !arg_count(cmd, configtype_ARG) &&
+	    !arg_count(cmd, list_ARG)) {
+		log_error("--atversion requires --type or --list");
 		return EINVALID_CMD_LINE;
 	}
 
@@ -171,7 +177,14 @@ int dumpconfig(struct cmd_context *cmd, int argc, char **argv)
 		}
 	}
 
-	if (!strcmp(type, "current")) {
+	if (!strcmp(type, "list") || arg_count(cmd, list_ARG)) {
+		tree_spec.type = CFG_DEF_TREE_LIST;
+		if (arg_count(cmd, withcomments_ARG)) {
+			log_error("--withcomments has no effect with --type list");
+			return EINVALID_CMD_LINE;
+		}
+		/* list type does not require status check */
+	} else if (!strcmp(type, "current")) {
 		tree_spec.type = CFG_DEF_TREE_CURRENT;
 		if (!_do_def_check(&tree_spec, cft, &cft_check_handle)) {
 			r = ECMD_FAILED;
@@ -214,13 +227,13 @@ int dumpconfig(struct cmd_context *cmd, int argc, char **argv)
 	}
 	else {
 		log_error("Incorrect type of configuration specified. "
-			  "Expected one of: current, default, missing, new, "
+			  "Expected one of: current, default, list, missing, new, "
 			  "profilable, profilable-command, profilable-metadata.");
 		r = EINVALID_CMD_LINE;
 		goto out;
 	}
 
-	if (arg_count(cmd, withsummary_ARG))
+	if (arg_count(cmd, withsummary_ARG) || arg_count(cmd, list_ARG))
 		tree_spec.withsummary = 1;
 	if (arg_count(cmd, withcomments_ARG))
 		tree_spec.withcomments = 1;


