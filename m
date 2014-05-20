From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 20 May 2014 14:28:54 +0000 (UTC)
Subject: master - dumpconfig: add --type profilable-command/profilable-metadata, --metadataprofile/--commandprofile
Message-ID: <20140520142854.156406145B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9c937e7d54221a783d294768efbaad12473a0265
Commit:        9c937e7d54221a783d294768efbaad12473a0265
Parent:        9e3e4d69944f072742fd13c5ac74d68e41a3db55
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue May 20 14:45:20 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue May 20 16:27:07 2014 +0200

dumpconfig: add --type profilable-command/profilable-metadata, --metadataprofile/--commandprofile

The dumpconfig now understands --commandprofile/--profile/--metadataprofile

The --commandprofile and --profile functionality is almost the same
with only one difference and that is that the --profile is just used
for dumping the content, it's not applied for the command itself
(while the --commandprofile profile is applied like it is done for
any other LVM command).

We also allow --metadataprofile for dumpconfig - dumpconfig *does not*
touch VG/LV and metadata in any way so it's OK to use it here (just for
dumping the content, checking the profile validity etc.).

The validity of the profile can be checked with:
      dumpconfig --commandprofile/--profile/--metadataprofile --validate

...depending on the profile type.

Also, mention --config in the dumpconfig help string so users know
that  dumpconfig handles this too (it did even before, but it was not
documented in the help string).
---
 WHATS_NEW           |    1 +
 lib/config/config.c |   11 +++++++++++
 lib/config/config.h |    2 ++
 tools/commands.h    |   10 +++++++---
 tools/dumpconfig.c  |   26 +++++++++++++++++++++++++-
 5 files changed, 46 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index b57a1c3..51249ed 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.107 - 
 ==================================
+  Add dumpconfig --type profilable-{metadata,command} to select profile type.
   Exit immediately with error if command profile is found invalid.
   Separate --profile cmd line arg into --commandprofile and --metadataprofile.
   Strictly separate command profiles and per-VG/LV profiles referenced in mda.
diff --git a/lib/config/config.c b/lib/config/config.c
index 4fbee66..ecb674e 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -1622,6 +1622,7 @@ static struct dm_config_node *_add_def_node(struct dm_config_tree *cft,
 static int _should_skip_def_node(struct config_def_tree_spec *spec, int section_id, int id)
 {
 	cfg_def_item_t *def = cfg_def_get_item_p(id);
+	uint16_t flags;
 
 	if ((def->parent != section_id) ||
 	    (spec->ignoreadvanced && def->flags & CFG_ADVANCED) ||
@@ -1645,9 +1646,19 @@ static int _should_skip_def_node(struct config_def_tree_spec *spec, int section_
 				return 1;
 			break;
 		case CFG_DEF_TREE_PROFILABLE:
+		case CFG_DEF_TREE_PROFILABLE_CMD:
+		case CFG_DEF_TREE_PROFILABLE_MDA:
 			if (!(def->flags & CFG_PROFILABLE) ||
 			    (def->since_version > spec->version))
 				return 1;
+			flags = def->flags & ~CFG_PROFILABLE;
+			if (spec->type == CFG_DEF_TREE_PROFILABLE_CMD) {
+				if (flags & CFG_PROFILABLE_METADATA)
+					return 1;
+			} else if (spec->type == CFG_DEF_TREE_PROFILABLE_MDA) {
+				if (!(flags & CFG_PROFILABLE_METADATA))
+					return 1;
+			}
 			break;
 		default:
 			if (def->since_version > spec->version)
diff --git a/lib/config/config.h b/lib/config/config.h
index 0618045..7b1d5b6 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -129,6 +129,8 @@ typedef enum {
 	CFG_DEF_TREE_DEFAULT,		/* tree of all possible config nodes with default values */
 	CFG_DEF_TREE_NEW,		/* tree of all new nodes that appeared in given version */
 	CFG_DEF_TREE_PROFILABLE,	/* tree of all nodes that are customizable by profiles */
+	CFG_DEF_TREE_PROFILABLE_CMD,	/* tree of all nodes that are customizable by command profiles (subset of PROFILABLE) */
+	CFG_DEF_TREE_PROFILABLE_MDA,	/* tree of all nodes that are customizable by metadata profiles (subset of PROFILABLE) */
 	CFG_DEF_TREE_DIFF,		/* tree of all nodes that differ from defaults */
 } cfg_def_tree_t;
 
diff --git a/tools/commands.h b/tools/commands.h
index 6ed4f8d..50db8eb 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -59,18 +59,22 @@ xx(dumpconfig,
    "dumpconfig\n"
    "\t[--commandprofile ProfileName]\n"
    "\t[-f|--file filename] \n"
-   "\t[--type {current|default|diff|missing|new|profilable} \n"
+   "\t[--type {current|default|diff|missing|new|profilable|profilable-command|profilable-metadata} \n"
    "\t[--atversion version]] \n"
    "\t[--ignoreadvanced] \n"
    "\t[--ignoreunsupported] \n"
+   "\t[--config ConfigurationString] \n"
+   "\t[--commandprofile ProfileName] \n"
+   "\t[--profile ProfileName] \n"
+   "\t[--metadataprofile ProfileName] \n"
    "\t[--mergedconfig] \n"
    "\t[--validate]\n"
    "\t[--withcomments] \n"
    "\t[--withversions] \n"
    "\t[ConfigurationNode...]\n",
    atversion_ARG, configtype_ARG, file_ARG, ignoreadvanced_ARG,
-   ignoreunsupported_ARG, mergedconfig_ARG, validate_ARG,
-   withcomments_ARG, withversions_ARG)
+   ignoreunsupported_ARG, mergedconfig_ARG, metadataprofile_ARG,
+   validate_ARG, withcomments_ARG, withversions_ARG)
 
 xx(formats,
    "List available metadata formats",
diff --git a/tools/dumpconfig.c b/tools/dumpconfig.c
index 141a030..09f2119 100644
--- a/tools/dumpconfig.c
+++ b/tools/dumpconfig.c
@@ -92,6 +92,7 @@ int dumpconfig(struct cmd_context *cmd, int argc, char **argv)
 	struct config_def_tree_spec tree_spec = {0};
 	struct dm_config_tree *cft = NULL;
 	struct cft_check_handle *cft_check_handle = NULL;
+	struct profile *profile = NULL;
 	int r = ECMD_PROCESSED;
 
 	tree_spec.cmd = cmd;
@@ -132,6 +133,18 @@ int dumpconfig(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 
 	/*
+	 * The profile specified by --profile cmd arg is like --commandprofile,
+	 * but it is used just for dumping the profile content and not for
+	 * application.
+	 */
+	if (arg_count(cmd, profile_ARG) &&
+	    (!(profile = add_profile(cmd, arg_str_value(cmd, profile_ARG, NULL), CONFIG_PROFILE_COMMAND)) ||
+	    !override_config_tree_from_profile(cmd, profile))) {
+		log_error("Failed to load profile %s.", arg_str_value(cmd, profile_ARG, NULL));
+		return ECMD_FAILED;
+	}
+
+	/*
 	 * Set the 'cft' to work with based on whether we need the plain
 	 * config tree or merged config tree cascade if --mergedconfig is used.
 	 */
@@ -188,9 +201,18 @@ int dumpconfig(struct cmd_context *cmd, int argc, char **argv)
 		tree_spec.type = CFG_DEF_TREE_PROFILABLE;
 		/* profilable type does not require check status */
 	}
+	else if (!strcmp(type, "profilable-command")) {
+		tree_spec.type = CFG_DEF_TREE_PROFILABLE_CMD;
+		/* profilable-command type does not require check status */
+	}
+	else if (!strcmp(type, "profilable-metadata")) {
+		tree_spec.type = CFG_DEF_TREE_PROFILABLE_MDA;
+		/* profilable-metadata  type does not require check status */
+	}
 	else {
 		log_error("Incorrect type of configuration specified. "
-			  "Expected one of: current, default, missing, new, profilable.");
+			  "Expected one of: current, default, missing, new, "
+			  "profilable, profilable-command, profilable-metadata.");
 		r = EINVALID_CMD_LINE;
 		goto out;
 	}
@@ -218,6 +240,8 @@ int dumpconfig(struct cmd_context *cmd, int argc, char **argv)
 out:
 	if (cft && (cft != cmd->cft))
 		dm_pool_destroy(cft->mem);
+	else if (profile)
+		remove_config_tree_by_source(cmd, CONFIG_PROFILE_COMMAND);
 
 	/*
 	 * The cmd->cft (the "current" tree) is destroyed


