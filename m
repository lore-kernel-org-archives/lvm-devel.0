From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 25 Nov 2015 13:12:19 +0000 (UTC)
Subject: master - lvmconfig: add --sinceversion for --type new
Message-ID: <20151125131219.3809A60BAE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1ea8afd3caa54259e58d8e3443389c819281c8c0
Commit:        1ea8afd3caa54259e58d8e3443389c819281c8c0
Parent:        66c7fa4a44e322720ff67f0e46ed91d4d8113c72
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Nov 25 14:09:20 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Nov 25 14:12:12 2015 +0100

lvmconfig: add --sinceversion for --type new

Just for convenience to display all new configuration settings
introduced since given version (before, there was only --atversion
to display settings introduced in concrete version).

For example:
	$ lvmconfig --type new --sinceversion 2.2.120
	allocation {
		# cache_mode="writethrough"
		# cache_settings {
		# }
	}
	global {
		use_lvmlockd=0
		# lvmlockd_lock_retries=3
		# sanlock_lv_extend=256
		use_lvmpolld=1
	}
	activation {
	}
	# report {
		# compact_output_cols=""
		# time_format="%Y-%m-%d %T %z"
	# }
	local {
		# host_id=0
	}
---
 WHATS_NEW           |    1 +
 lib/config/config.c |    5 +++++
 lib/config/config.h |    1 +
 man/lvmconfig.8.in  |    9 +++++++++
 tools/args.h        |    1 +
 tools/commands.h    |   27 +++++++++++++++------------
 tools/dumpconfig.c  |   33 ++++++++++++++++++++++++++-------
 7 files changed, 58 insertions(+), 19 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index a4eeebf..c3afac3 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.136 - 
 =====================================
+  Add new --sinceversion option for lvmconfig --type new.
   Fix inactive table loaded for wrapping thin-pool when resizing it.
   Extend the list of ignored libraries when locking memory.
 
diff --git a/lib/config/config.c b/lib/config/config.c
index d69f1f7..5551a7f 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -1996,6 +1996,11 @@ static int _should_skip_def_node(struct config_def_tree_spec *spec, int section_
 			    _should_skip_deprecated_def_node(def, spec))
 				return 1;
 			break;
+		case CFG_DEF_TREE_NEW_SINCE:
+			if ((def->since_version < spec->version) ||
+			    _should_skip_deprecated_def_node(def, spec))
+				return 1;
+			break;
 		case CFG_DEF_TREE_PROFILABLE:
 			/* fall through */
 		case CFG_DEF_TREE_PROFILABLE_CMD:
diff --git a/lib/config/config.h b/lib/config/config.h
index e112223..95d252c 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -146,6 +146,7 @@ typedef enum {
 	CFG_DEF_TREE_FULL,		/* CURRENT + MISSING, the tree actually used within execution */
 	CFG_DEF_TREE_DEFAULT,		/* tree of all possible config nodes with default values */
 	CFG_DEF_TREE_NEW,		/* tree of all new nodes that appeared in given version */
+	CFG_DEF_TREE_NEW_SINCE,		/* tree of all new nodes that appeared since given version */
 	CFG_DEF_TREE_PROFILABLE,	/* tree of all nodes that are customizable by profiles */
 	CFG_DEF_TREE_PROFILABLE_CMD,	/* tree of all nodes that are customizable by command profiles (subset of PROFILABLE) */
 	CFG_DEF_TREE_PROFILABLE_MDA,	/* tree of all nodes that are customizable by metadata profiles (subset of PROFILABLE) */
diff --git a/man/lvmconfig.8.in b/man/lvmconfig.8.in
index bbbeb6d..0e9e7c5 100644
--- a/man/lvmconfig.8.in
+++ b/man/lvmconfig.8.in
@@ -9,6 +9,8 @@ lvmconfig, lvm dumpconfig, lvm config \(em Display LVM configuration
 .RI { current | default | diff | full | list | missing | new | profilable | profilable-command | profilable-metadata }
 .RB [ \-\-atversion
 .IR version ]
+.RB [ \-\---sinceversion
+.IR version ]
 .RB [ \-\-ignoreadvanced ]
 .RB [ \-\-ignoreunsupported ]
 .RB [ \-\-ignorelocal ]
@@ -109,6 +111,13 @@ which does not contain any newer settings for which LVM would
 issue a warning message when checking the configuration.
 
 .TP
+.BI \-\-sinceversion " version"
+Specify an LVM version in x.y.z format where x is the major version,
+the y is the minor version and z is the patchlevel (e.g. 2.2.106).
+This option is currently applicable only with \fB\-\-type new\fP
+to display all configuration settings introduced since given version.
+
+.TP
 .B \-\-ignoreadvanced
 Exclude advanced configuration settings from the output.
 
diff --git a/tools/args.h b/tools/args.h
index 210545e..f6b10a6 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -101,6 +101,7 @@ arg(rows_ARG, '\0', "rows", NULL, 0)
 arg(segments_ARG, '\0', "segments", NULL, 0)
 arg(separator_ARG, '\0', "separator", string_arg, 0)
 arg(shared_ARG, '\0', "shared", NULL, 0)
+arg(sinceversion_ARG, '\0', "sinceversion", string_arg, 0)
 arg(split_ARG, '\0', "split", NULL, 0)
 arg(splitcache_ARG, '\0', "splitcache", NULL, 0)
 arg(splitmirrors_ARG, '\0', "splitmirrors", int_arg, 0)
diff --git a/tools/commands.h b/tools/commands.h
index a141135..b232a7d 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -33,8 +33,8 @@ xx(config,
    PERMITTED_READ_ONLY | NO_METADATA_PROCESSING,
    "config\n"
    "\t[-f|--file filename]\n"
-   "\t[--type {current|default|diff|full|list|missing|new|profilable|profilable-command|profilable-metadata}\n"
-   "\t[--atversion version]]\n"
+   "\t[--type {current|default|diff|full|list|missing|new|profilable|profilable-command|profilable-metadata}]\n"
+   "\t[--atversion version]\n"
    "\t[--ignoreadvanced]\n"
    "\t[--ignoreunsupported]\n"
    "\t[--ignorelocal]\n"
@@ -44,6 +44,7 @@ xx(config,
    "\t[--profile ProfileName]\n"
    "\t[--metadataprofile ProfileName]\n"
    "\t[--mergedconfig]\n"
+   "\t[--sinceversion version]\n"
    "\t[--showdeprecated]\n"
    "\t[--showunsupported]\n"
    "\t[--validate]\n"
@@ -55,8 +56,8 @@ xx(config,
    "\t[ConfigurationNode...]\n",
    atversion_ARG, configtype_ARG, file_ARG, ignoreadvanced_ARG,
    ignoreunsupported_ARG, ignorelocal_ARG, list_ARG, mergedconfig_ARG, metadataprofile_ARG,
-   showdeprecated_ARG, showunsupported_ARG, validate_ARG, withsummary_ARG, withcomments_ARG,
-   withspaces_ARG, unconfigured_ARG, withversions_ARG)
+   sinceversion_ARG, showdeprecated_ARG, showunsupported_ARG, validate_ARG, withsummary_ARG,
+   withcomments_ARG, withspaces_ARG, unconfigured_ARG, withversions_ARG)
 
 xx(devtypes,
    "Display recognised built-in block device types",
@@ -89,8 +90,8 @@ xx(dumpconfig,
    PERMITTED_READ_ONLY | NO_METADATA_PROCESSING,
    "dumpconfig\n"
    "\t[-f|--file filename]\n"
-   "\t[--type {current|default|diff|full|list|missing|new|profilable|profilable-command|profilable-metadata}\n"
-   "\t[--atversion version]]\n"
+   "\t[--type {current|default|diff|full|list|missing|new|profilable|profilable-command|profilable-metadata}]\n"
+   "\t[--atversion version]\n"
    "\t[--ignoreadvanced]\n"
    "\t[--ignoreunsupported]\n"
    "\t[--ignorelocal]\n"
@@ -100,6 +101,7 @@ xx(dumpconfig,
    "\t[--profile ProfileName]\n"
    "\t[--metadataprofile ProfileName]\n"
    "\t[--mergedconfig]\n"
+   "\t[--sinceversion version]\n"
    "\t[--showdeprecated]\n"
    "\t[--showunsupported]\n"
    "\t[--validate]\n"
@@ -111,8 +113,8 @@ xx(dumpconfig,
    "\t[ConfigurationNode...]\n",
    atversion_ARG, configtype_ARG, file_ARG, ignoreadvanced_ARG,
    ignoreunsupported_ARG, ignorelocal_ARG, list_ARG, mergedconfig_ARG, metadataprofile_ARG,
-   showdeprecated_ARG, showunsupported_ARG, validate_ARG, withsummary_ARG, withcomments_ARG,
-   withspaces_ARG, unconfigured_ARG, withversions_ARG)
+   sinceversion_ARG, showdeprecated_ARG, showunsupported_ARG, validate_ARG, withsummary_ARG,
+   withcomments_ARG, withspaces_ARG, unconfigured_ARG, withversions_ARG)
 
 xx(formats,
    "List available metadata formats",
@@ -499,8 +501,8 @@ xx(lvmconfig,
    PERMITTED_READ_ONLY | NO_METADATA_PROCESSING,
    "lvmconfig\n"
    "\t[-f|--file filename]\n"
-   "\t[--type {current|default|diff|full|list|missing|new|profilable|profilable-command|profilable-metadata}\n"
-   "\t[--atversion version]]\n"
+   "\t[--type {current|default|diff|full|list|missing|new|profilable|profilable-command|profilable-metadata}]\n"
+   "\t[--atversion version]\n"
    "\t[--ignoreadvanced]\n"
    "\t[--ignoreunsupported]\n"
    "\t[--ignorelocal]\n"
@@ -510,6 +512,7 @@ xx(lvmconfig,
    "\t[--profile ProfileName]\n"
    "\t[--metadataprofile ProfileName]\n"
    "\t[--mergedconfig]\n"
+   "\t[--sinceversion version]\n"
    "\t[--showdeprecated]\n"
    "\t[--showunsupported]\n"
    "\t[--validate]\n"
@@ -521,8 +524,8 @@ xx(lvmconfig,
    "\t[ConfigurationNode...]\n",
    atversion_ARG, configtype_ARG, file_ARG, ignoreadvanced_ARG,
    ignoreunsupported_ARG, ignorelocal_ARG, list_ARG, mergedconfig_ARG, metadataprofile_ARG,
-   showdeprecated_ARG, showunsupported_ARG, validate_ARG, withsummary_ARG, withcomments_ARG,
-   withspaces_ARG, unconfigured_ARG, withversions_ARG)
+   sinceversion_ARG, showdeprecated_ARG, showunsupported_ARG, validate_ARG, withsummary_ARG,
+   withcomments_ARG, withspaces_ARG, unconfigured_ARG, withversions_ARG)
 
 xx(lvmdiskscan,
    "List devices that may be used as physical volumes",
diff --git a/tools/dumpconfig.c b/tools/dumpconfig.c
index c9c5bf9..72129c2 100644
--- a/tools/dumpconfig.c
+++ b/tools/dumpconfig.c
@@ -17,10 +17,17 @@
 
 static int _get_vsn(struct cmd_context *cmd, uint16_t *version_int)
 {
-	const char *atversion = arg_str_value(cmd, atversion_ARG, LVM_VERSION);
+	const char *version;
 	unsigned int major, minor, patchlevel;
 
-	if (sscanf(atversion, "%u.%u.%u", &major, &minor, &patchlevel) != 3) {
+	if (arg_count(cmd, atversion_ARG))
+		version = arg_str_value(cmd, atversion_ARG, NULL);
+	else if (arg_count(cmd, sinceversion_ARG))
+		version = arg_str_value(cmd, sinceversion_ARG, NULL);
+	else
+		version = LVM_VERSION;
+
+	if (sscanf(version, "%u.%u.%u", &major, &minor, &patchlevel) != 3) {
 		log_error("Incorrect version format.");
 		return 0;
 	}
@@ -110,10 +117,21 @@ int dumpconfig(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
-	if (arg_count(cmd, atversion_ARG) && !arg_count(cmd, configtype_ARG) &&
-	    !arg_count(cmd, list_ARG)) {
-		log_error("--atversion requires --type or --list");
-		return EINVALID_CMD_LINE;
+	if (arg_count(cmd, atversion_ARG)) {
+		if (arg_count(cmd, sinceversion_ARG)) {
+			log_error("Only one of --atversion and --sinceversion permitted.");
+			return EINVALID_CMD_LINE;
+		}
+
+		if (!arg_count(cmd, configtype_ARG) && !arg_count(cmd, list_ARG)) {
+			log_error("--atversion requires --type or --list");
+			return EINVALID_CMD_LINE;
+		}
+	} else if (arg_count(cmd, sinceversion_ARG)) {
+		if (!arg_count(cmd, configtype_ARG) || strcmp(type, "new")) {
+			log_error("--sinceversion requires --type new");
+			return EINVALID_CMD_LINE;
+		}
 	}
 
 	if (arg_count(cmd, ignoreadvanced_ARG))
@@ -252,7 +270,8 @@ int dumpconfig(struct cmd_context *cmd, int argc, char **argv)
 		}
 	}
 	else if (!strcmp(type, "new")) {
-		tree_spec.type = CFG_DEF_TREE_NEW;
+		tree_spec.type = arg_count(cmd, sinceversion_ARG) ? CFG_DEF_TREE_NEW_SINCE
+								  : CFG_DEF_TREE_NEW;
 		/* new type does not require check status */
 	}
 	else if (!strcmp(type, "profilable")) {


