From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 30 Apr 2015 15:56:00 +0000 (UTC)
Subject: master - lvmconfig: add supporting code for handling deprecated settings
Message-ID: <20150430155600.A49C061047@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fc65269d682cb7bcaf14c94ec4541e7af4c27165
Commit:        fc65269d682cb7bcaf14c94ec4541e7af4c27165
Parent:        5a0197121b07b8a2318000872d4b6916c2176ef9
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Apr 30 17:40:24 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Apr 30 17:55:04 2015 +0200

lvmconfig: add supporting code for handling deprecated settings

This patch adds supporting code for handling deprecated settings.

Deprecated settings are not displayed by default in lvmconfig output
(except for --type current and --type diff). There's a new
"--showdeprecated" lvmconfig option to display them if needed.

Also, when using lvmconfig --withcomments, the comments with info
about deprecation are displayed for deprecated settings and with
lvmconfig --withversions, the version in which the setting was
deprecated is displayed in addition to the version of introduction.

If using --atversion with a version that is lower than the one
in which the setting was deprecated, the setting is then considered
as not deprecated (simply because at that version it was not
deprecated).

For example:

$ lvmconfig --type default activation
activation {
        ...
	raid_region_size=512
        ...
}

$ lvmconfig --type default activation --showdeprecated
activation {
        ...
	mirror_region_size=512
	raid_region_size=512
        ...
}

$ lvmconfig --type default activation --showdeprecated --withversions
activation {
        ...
	# Available since version 1.0.0.
	# Deprecated since version 2.2.99.
	mirror_region_size=512
	# Available since version 2.2.99.
	raid_region_size=512
        ...
}

$ lvmconfig --type default activation --showdeprecated --withcomments
activation {
        ...
	# Configuration option activation/mirror_region_size.
	# This has been replaced by the activation/raid_region_size
	# setting.
	# Size (in KB) of each copy operation when mirroring.
	# This configuration option is deprecated.
	mirror_region_size=512

	# Configuration option activation/raid_region_size.
	# Size in KiB of each raid or mirror synchronization region.
	# For raid or mirror segment types, this is the amount of
	# data that is copied at once when initializing, or moved
	# at once by pvmove.
	raid_region_size=512
        ...
}

$ lvmconfig --type default activation --withcomments --atversion 2.2.98
activation {
       ...
       # Configuration option activation/mirror_region_size.
       # Size (in KB) of each copy operation when mirroring.
       mirror_region_size=512
       ...
}
---
 WHATS_NEW           |    4 ++++
 lib/config/config.c |   50 +++++++++++++++++++++++++++++++++++++++-----------
 lib/config/config.h |    1 +
 man/lvmconfig.8.in  |   16 ++++++++++++++--
 tools/args.h        |    1 +
 tools/commands.h    |   15 +++++++++------
 tools/dumpconfig.c  |   15 +++++++++++++++
 7 files changed, 83 insertions(+), 19 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 49b2bad..79ef842 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,9 @@
 Version 2.02.119 - 
 ==================================
+  Also display deprecation info for deprecated config in lvmconfig --withcomments.
+  Display version since which config is deprecated in lvmconfig --withversions.
+  Add --showdeprecated to lvmconfig to also display deprecated settings.
+  Hide deprecated settings in lvmconfig output for all types except current,diff.
   Introduce support for exit on idle feature in libdaemon
   Add --showunsupported to lvmconfig to also display unsupported settings.
   Display unsupported settings for lvmconfig --type current,diff only by default.
diff --git a/lib/config/config.c b/lib/config/config.c
index 41f13a0..084f3f2 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -1525,12 +1525,12 @@ static int _copy_one_line(const char *comment, char *line, int *pos, int len)
 	return i;
 }
 
-static int _get_config_node_version(char *version, struct cfg_def_item *cfg_def)
+static int _get_config_node_version(uint16_t version_enc, char *version)
 {
 	if (dm_snprintf(version, 9, "%u.%u.%u",
-			(cfg_def->since_version & 0xE000) >> 13,
-			(cfg_def->since_version & 0x1E00) >> 9,
-			(cfg_def->since_version & 0x1FF)) == -1) {
+			(version_enc & 0xE000) >> 13,
+			(version_enc & 0x1E00) >> 9,
+			(version_enc & 0x1FF)) == -1) {
 		log_error("_get_config_node_version: couldn't create version string");
 		return 0;
 	}
@@ -1538,6 +1538,12 @@ static int _get_config_node_version(char *version, struct cfg_def_item *cfg_def)
 	return 1;
 }
 
+static int _def_node_is_deprecated(cfg_def_item_t *def, struct config_def_tree_spec *spec)
+{
+	return def->deprecated_since_version &&
+	       (spec->version >= def->deprecated_since_version);
+}
+
 static int _out_prefix_fn(const struct dm_config_node *cn, const char *line, void *baton)
 {
 	struct out_baton *out = baton;
@@ -1569,6 +1575,10 @@ static int _out_prefix_fn(const struct dm_config_node *cn, const char *line, voi
 		fprintf(out->fp, "\n");
 		fprintf(out->fp, "%s# Configuration %s %s.\n", line, node_type_name, path);
 
+		if (out->tree_spec->withcomments &&
+		    _def_node_is_deprecated(cfg_def, out->tree_spec))
+			fprintf(out->fp, "%s# %s", line, cfg_def->deprecation_comment);
+
 		if (cfg_def->comment) {
 			int pos = 0;
 			while (_copy_one_line(cfg_def->comment, commentline, &pos, strlen(cfg_def->comment))) {
@@ -1579,6 +1589,9 @@ static int _out_prefix_fn(const struct dm_config_node *cn, const char *line, voi
 			}
 		}
 
+		if (_def_node_is_deprecated(cfg_def, out->tree_spec))
+			fprintf(out->fp, "%s# This configuration %s is deprecated.\n", line, node_type_name);
+
 		if (cfg_def->flags & CFG_ADVANCED)
 			fprintf(out->fp, "%s# This configuration %s is advanced.\n", line, node_type_name);
 
@@ -1593,9 +1606,15 @@ static int _out_prefix_fn(const struct dm_config_node *cn, const char *line, voi
 	}
 
 	if (out->tree_spec->withversions) {
-		if (!_get_config_node_version(version, cfg_def))
+		if (!_get_config_node_version(cfg_def->since_version, version))
 			return_0;
-		fprintf(out->fp, "%s# Since version %s.\n", line, version);
+		fprintf(out->fp, "%s# Available since version %s.\n", line, version);
+
+		if (_def_node_is_deprecated(cfg_def, out->tree_spec)) {
+			if (!_get_config_node_version(cfg_def->deprecated_since_version, version))
+				return_0;
+			fprintf(out->fp, "%s# Deprecated since version %s.\n", line, version);
+		}
 	}
 
 	return 1;
@@ -1624,7 +1643,7 @@ static int _out_line_fn(const struct dm_config_node *cn, const char *line, void
 			return 1;
 		if (!_cfg_def_make_path(config_path, CFG_PATH_MAX_LEN, cfg_def->id, cfg_def, 1))
 			return_0;
-		if (out->tree_spec->withversions && !_get_config_node_version(version, cfg_def))
+		if (out->tree_spec->withversions && !_get_config_node_version(cfg_def->since_version, version))
 			return_0;
 
 		summary[0] = '\0';
@@ -1781,6 +1800,11 @@ static struct dm_config_node *_add_def_node(struct dm_config_tree *cft,
 	return cn;
 }
 
+static int _should_skip_deprecated_def_node(cfg_def_item_t *def, struct config_def_tree_spec *spec)
+{
+	return spec->ignoredeprecated && _def_node_is_deprecated(def, spec);
+}
+
 static int _should_skip_def_node(struct config_def_tree_spec *spec, int section_id, int id)
 {
 	cfg_def_item_t *def = cfg_def_get_item_p(id);
@@ -1800,18 +1824,21 @@ static int _should_skip_def_node(struct config_def_tree_spec *spec, int section_
 			}
 			if ((spec->check_status[id] & CFG_USED) ||
 			    (def->flags & CFG_NAME_VARIABLE) ||
-			    (def->since_version > spec->version))
+			    (def->since_version > spec->version) ||
+			    _should_skip_deprecated_def_node(def, spec))
 				return 1;
 			break;
 		case CFG_DEF_TREE_NEW:
-			if (def->since_version != spec->version)
+			if ((def->since_version != spec->version) ||
+			    _should_skip_deprecated_def_node(def, spec))
 				return 1;
 			break;
 		case CFG_DEF_TREE_PROFILABLE:
 		case CFG_DEF_TREE_PROFILABLE_CMD:
 		case CFG_DEF_TREE_PROFILABLE_MDA:
 			if (!(def->flags & CFG_PROFILABLE) ||
-			    (def->since_version > spec->version))
+			    (def->since_version > spec->version) ||
+			    _should_skip_deprecated_def_node(def, spec))
 				return 1;
 			flags = def->flags & ~CFG_PROFILABLE;
 			if (spec->type == CFG_DEF_TREE_PROFILABLE_CMD) {
@@ -1823,7 +1850,8 @@ static int _should_skip_def_node(struct config_def_tree_spec *spec, int section_
 			}
 			break;
 		default:
-			if (def->since_version > spec->version)
+			if ((def->since_version > spec->version) ||
+			    _should_skip_deprecated_def_node(def, spec))
 				return 1;
 			break;
 	}
diff --git a/lib/config/config.h b/lib/config/config.h
index c21a61b..ce31e50 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -154,6 +154,7 @@ struct config_def_tree_spec {
 	uint16_t version;		/* tree at this LVM2 version */
 	unsigned ignoreadvanced:1;	/* do not include advanced configs */
 	unsigned ignoreunsupported:1;	/* do not include unsupported configs */
+	unsigned ignoredeprecated:1;	/* do not include deprecated configs */
 	unsigned ignorelocal:1;		/* do not include the local section */
 	unsigned withsummary:1;		/* include first line of comments - a summary */
 	unsigned withcomments:1;	/* include all comment lines */
diff --git a/man/lvmconfig.8.in b/man/lvmconfig.8.in
index ff7c63b..1f70c86 100644
--- a/man/lvmconfig.8.in
+++ b/man/lvmconfig.8.in
@@ -22,6 +22,7 @@ lvmconfig, lvm dumpconfig, lvm config \(em Display LVM configuration
 .RB [ \-\-metadataprofile
 .IR ProfileName ]
 .RB [ \-\-mergedconfig ]
+.RB [ \-\-showdeprecated ]
 .RB [ \-\-showunsupported ]
 .RB [ \-\-validate ]
 .RB [ \-\-withsummary ]
@@ -150,6 +151,15 @@ the front of the cascade is displayed. See also \fBlvm.conf\fP(5) for more
 info about \fBconfig cascade\fP.
 
 .TP
+.B \-\-showdeprecated
+Include deprecated configuration settings in the output. These settings
+are always deprecated since certain version. If concrete version is specified
+with \fB--atversion\fP option, deprecated settings are automatically included
+if specified version is lower that the version in which the settings were
+deprecated. The \fBcurrent\fP and \fBdiff\fP types include deprecated settings
+int their output by default, all the other types ignore deprecated settings.
+
+.TP
 .B \-\-showunsupported
 Include unsupported configuration settings in the output. These settings
 are either used for debugging or development purposes only or their support
@@ -172,12 +182,14 @@ Display a one line comment for each configuration node.
 
 .TP
 .B \-\-withcomments
-Display a full comment for each configuration node.
+Display a full comment for each configuration node. For deprecated
+settings, also display comments about deprecation in addition.
 
 .TP
 .B \-\-withversions
 Also display a comment containing the version of introduction for
-each configuration node.
+each configuration node. If the setting is deprecated, also display
+the version since which it is deprecated.
 
 .SH SEE ALSO
 .BR lvm (8)
diff --git a/tools/args.h b/tools/args.h
index 2745699..791aa4e 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -98,6 +98,7 @@ arg(split_ARG, '\0', "split", NULL, 0)
 arg(splitcache_ARG, '\0', "splitcache", NULL, 0)
 arg(splitmirrors_ARG, '\0', "splitmirrors", int_arg, 0)
 arg(splitsnapshot_ARG, '\0', "splitsnapshot", NULL, 0)
+arg(showdeprecated_ARG, '\0', "showdeprecated", NULL, 0)
 arg(showunsupported_ARG, '\0', "showunsupported", NULL, 0)
 arg(stripes_long_ARG, '\0', "stripes", int_arg, 0)
 arg(syncaction_ARG, '\0', "syncaction", string_arg, 0)	/* FIXME Use custom validation fn */
diff --git a/tools/commands.h b/tools/commands.h
index b7f9844..f2878ab 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -44,6 +44,7 @@ xx(config,
    "\t[--profile ProfileName]\n"
    "\t[--metadataprofile ProfileName]\n"
    "\t[--mergedconfig]\n"
+   "\t[--showdeprecated]\n"
    "\t[--showunsupported]\n"
    "\t[--validate]\n"
    "\t[--withsummary]\n"
@@ -53,8 +54,8 @@ xx(config,
    "\t[ConfigurationNode...]\n",
    atversion_ARG, configtype_ARG, file_ARG, ignoreadvanced_ARG,
    ignoreunsupported_ARG, ignorelocal_ARG, list_ARG, mergedconfig_ARG, metadataprofile_ARG,
-   showunsupported_ARG, validate_ARG, withsummary_ARG, withcomments_ARG, unconfigured_ARG,
-   withversions_ARG)
+   showdeprecated_ARG, showunsupported_ARG, validate_ARG, withsummary_ARG, withcomments_ARG,
+   unconfigured_ARG, withversions_ARG)
 
 xx(devtypes,
    "Display recognised built-in block device types",
@@ -98,6 +99,7 @@ xx(dumpconfig,
    "\t[--profile ProfileName]\n"
    "\t[--metadataprofile ProfileName]\n"
    "\t[--mergedconfig]\n"
+   "\t[--showdeprecated]\n"
    "\t[--showunsupported]\n"
    "\t[--validate]\n"
    "\t[--withsummary]\n"
@@ -107,8 +109,8 @@ xx(dumpconfig,
    "\t[ConfigurationNode...]\n",
    atversion_ARG, configtype_ARG, file_ARG, ignoreadvanced_ARG,
    ignoreunsupported_ARG, ignorelocal_ARG, list_ARG, mergedconfig_ARG, metadataprofile_ARG,
-   showunsupported_ARG, validate_ARG, withsummary_ARG, withcomments_ARG, unconfigured_ARG,
-   withversions_ARG)
+   showdeprecated_ARG, showunsupported_ARG, validate_ARG, withsummary_ARG, withcomments_ARG,
+   unconfigured_ARG, withversions_ARG)
 
 xx(formats,
    "List available metadata formats",
@@ -501,6 +503,7 @@ xx(lvmconfig,
    "\t[--profile ProfileName]\n"
    "\t[--metadataprofile ProfileName]\n"
    "\t[--mergedconfig]\n"
+   "\t[--showdeprecated]\n"
    "\t[--showunsupported]\n"
    "\t[--validate]\n"
    "\t[--withsummary]\n"
@@ -510,8 +513,8 @@ xx(lvmconfig,
    "\t[ConfigurationNode...]\n",
    atversion_ARG, configtype_ARG, file_ARG, ignoreadvanced_ARG,
    ignoreunsupported_ARG, ignorelocal_ARG, list_ARG, mergedconfig_ARG, metadataprofile_ARG,
-   showunsupported_ARG, validate_ARG, withsummary_ARG, withcomments_ARG, unconfigured_ARG,
-   withversions_ARG)
+   showdeprecated_ARG, showunsupported_ARG, validate_ARG, withsummary_ARG, withcomments_ARG,
+   unconfigured_ARG, withversions_ARG)
 
 xx(lvmdiskscan,
    "List devices that may be used as physical volumes",
diff --git a/tools/dumpconfig.c b/tools/dumpconfig.c
index 6b8f7b0..97de57a 100644
--- a/tools/dumpconfig.c
+++ b/tools/dumpconfig.c
@@ -136,6 +136,21 @@ int dumpconfig(struct cmd_context *cmd, int argc, char **argv)
 		tree_spec.ignoreunsupported = 1;
 	}
 
+	if (strcmp(type, "current") && strcmp(type, "diff")) {
+		/*
+		 * By default hide deprecated settings
+		 * for all display types except "current"
+		 * and "diff" unless --showdeprecated is set.
+		 *
+		 * N.B. Deprecated settings are visible if
+		 * --atversion is used with a version that
+		 * is lower than the version in which the
+		 * setting was deprecated.
+		 */
+		if (!arg_count(cmd, showdeprecated_ARG))
+			tree_spec.ignoredeprecated = 1;
+	}
+
 	if (arg_count(cmd, ignorelocal_ARG))
 		tree_spec.ignorelocal = 1;
 


