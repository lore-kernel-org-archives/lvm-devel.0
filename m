From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 24 Jun 2015 11:21:41 +0000 (UTC)
Subject: master - lvmconfig: add --withspaces option
Message-ID: <20150624112141.5D9AB6098F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a4724350e4909dd1b74231f22c41434dbe02c14d
Commit:        a4724350e4909dd1b74231f22c41434dbe02c14d
Parent:        a25d92c88b034996667da3764ac5b1de15448174
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jun 24 13:14:30 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jun 24 13:19:23 2015 +0200

lvmconfig: add --withspaces option

We shouldn't be adding spaces by default in output as that
may be be used already in scripts and especially for the eval
in shell scripts where spaces are not allowed between key
and value!

Add --withspaces option to lvmconfig for pretty output with
more space in for readability.
---
 WHATS_NEW           |    1 +
 lib/config/config.c |    8 +++++---
 lib/config/config.h |    1 +
 man/lvmconfig.8.in  |    5 +++++
 tools/args.h        |    1 +
 tools/commands.h    |    3 ++-
 tools/dumpconfig.c  |    3 +++
 7 files changed, 18 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 7da2b51..94766af 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.123 - 
 =================================
+  Add --withspaces to lvmconfig to add spaces in output for better readability.
 
 Version 2.02.122 - 20th June 2015
 =================================
diff --git a/lib/config/config.c b/lib/config/config.c
index 6f9d413..22b8f09 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -1756,7 +1756,8 @@ static struct dm_config_node *_add_def_node(struct dm_config_tree *cft,
 			log_error("Failed to create default config setting node value.");
 			return NULL;
 		}
-		format_flags |= DM_CONFIG_VALUE_FMT_COMMON_EXTRA_SPACES;
+		if (spec->withspaces)
+			format_flags |= DM_CONFIG_VALUE_FMT_COMMON_EXTRA_SPACES;
 	}
 
 	cn->id = def->id;
@@ -1799,8 +1800,9 @@ static struct dm_config_node *_add_def_node(struct dm_config_tree *cft,
 		}
 		dm_config_value_set_format_flags(cn->v, format_flags);
 	} else {
-		format_flags |= (DM_CONFIG_VALUE_FMT_COMMON_ARRAY |
-				 DM_CONFIG_VALUE_FMT_COMMON_EXTRA_SPACES);
+		if (spec->withspaces)
+			format_flags |= DM_CONFIG_VALUE_FMT_COMMON_EXTRA_SPACES;
+		format_flags |= DM_CONFIG_VALUE_FMT_COMMON_ARRAY;
 		cn->v = _get_def_array_values(cft, def, format_flags);
 	}
 
diff --git a/lib/config/config.h b/lib/config/config.h
index b03ad6b..9601dc1 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -163,6 +163,7 @@ struct config_def_tree_spec {
 	unsigned withsummary:1;		/* include first line of comments - a summary */
 	unsigned withcomments:1;	/* include all comment lines */
 	unsigned withversions:1;	/* include versions */
+	unsigned withspaces:1;		/* add more spaces in output for better readability */
 	unsigned unconfigured:1;	/* use unconfigured path strings */
 	uint8_t *check_status;		/* status of last tree check (currently needed for CFG_DEF_TREE_MISSING only) */
 };
diff --git a/man/lvmconfig.8.in b/man/lvmconfig.8.in
index 4e61280..761b1e9 100644
--- a/man/lvmconfig.8.in
+++ b/man/lvmconfig.8.in
@@ -27,6 +27,7 @@ lvmconfig, lvm dumpconfig, lvm config \(em Display LVM configuration
 .RB [ \-\-validate ]
 .RB [ \-\-withsummary ]
 .RB [ \-\-withcomments ]
+.RB [ \-\-withspaces ]
 .RB [ \-\-withversions ]
 .RB [ ConfigurationNode... ]
 
@@ -186,6 +187,10 @@ Display a full comment for each configuration node. For deprecated
 settings, also display comments about deprecation in addition.
 
 .TP
+.B \-\-withspaces
+Where appropriate, add more spaces in output for better readability.
+
+.TP
 .B \-\-withversions
 Also display a comment containing the version of introduction for
 each configuration node. If the setting is deprecated, also display
diff --git a/tools/args.h b/tools/args.h
index b5c4243..7f7667d 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -124,6 +124,7 @@ arg(vgmetadatacopies_ARG, '\0', "vgmetadatacopies", metadatacopies_arg, 0)
 arg(virtualoriginsize_ARG, '\0', "virtualoriginsize", size_mb_arg, 0)
 arg(withsummary_ARG, '\0', "withsummary", NULL, 0)
 arg(withcomments_ARG, '\0', "withcomments", NULL, 0)
+arg(withspaces_ARG, '\0', "withspaces", NULL, 0)
 arg(withversions_ARG, '\0', "withversions", NULL, 0)
 arg(writebehind_ARG, '\0', "writebehind", int_arg, 0)
 arg(writemostly_ARG, '\0', "writemostly", string_arg, ARG_GROUPABLE)
diff --git a/tools/commands.h b/tools/commands.h
index 8e87681..9403951 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -104,13 +104,14 @@ xx(dumpconfig,
    "\t[--validate]\n"
    "\t[--withsummary]\n"
    "\t[--withcomments]\n"
+   "\t[--withspaces]\n"
    "\t[--unconfigured]\n"
    "\t[--withversions]\n"
    "\t[ConfigurationNode...]\n",
    atversion_ARG, configtype_ARG, file_ARG, ignoreadvanced_ARG,
    ignoreunsupported_ARG, ignorelocal_ARG, list_ARG, mergedconfig_ARG, metadataprofile_ARG,
    showdeprecated_ARG, showunsupported_ARG, validate_ARG, withsummary_ARG, withcomments_ARG,
-   unconfigured_ARG, withversions_ARG)
+   withspaces_ARG, unconfigured_ARG, withversions_ARG)
 
 xx(formats,
    "List available metadata formats",
diff --git a/tools/dumpconfig.c b/tools/dumpconfig.c
index 97de57a..f6a6217 100644
--- a/tools/dumpconfig.c
+++ b/tools/dumpconfig.c
@@ -277,6 +277,9 @@ int dumpconfig(struct cmd_context *cmd, int argc, char **argv)
 	if (arg_count(cmd, withversions_ARG))
 		tree_spec.withversions = 1;
 
+	if (arg_count(cmd, withspaces_ARG))
+		tree_spec.withspaces = 1;
+
 	if (cft_check_handle)
 		tree_spec.check_status = cft_check_handle->status;
 


