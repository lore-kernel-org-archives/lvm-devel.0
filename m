From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 29 Apr 2015 10:01:47 +0000 (UTC)
Subject: master - refactor: dumpconfig: keep --withcomments to display full comment and use --withsummary for one line summary
Message-ID: <20150429100147.D5C0860355@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0ba332e82a308415d715bf8a24ebf5d649f1c071
Commit:        0ba332e82a308415d715bf8a24ebf5d649f1c071
Parent:        15a563c376d5288f6ec61c20422c27352363f6e1
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Apr 29 10:53:25 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Apr 29 11:14:18 2015 +0200

refactor: dumpconfig: keep --withcomments to display full comment and use --withsummary for one line summary

---
 WHATS_NEW           |    2 +-
 conf/Makefile.in    |    4 ++--
 lib/config/config.c |    6 +++---
 lib/config/config.h |   10 +++++-----
 man/lvm.conf.5.in   |    4 ++--
 man/lvmconfig.8.in  |    6 +++---
 tools/args.h        |    2 +-
 tools/commands.h    |   12 ++++++------
 tools/dumpconfig.c  |    4 ++--
 9 files changed, 25 insertions(+), 25 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index f0c248c..ad1573e 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -8,7 +8,7 @@ Version 2.02.119 -
   Split pvmove update metadata fn in an initial one and a subsequent one.
   Refactor shared pvmove and lvconvert code into new _poll files.
   Add --unconfigured option to dumpconfig to print strings unconfigured.
-  Add --withfullcomments option to dumpconfig to print full comment.
+  Add --withsummary option to dumpconfig to print first line - summary comment.
   Check for lvm binary in blkdeactivate and skip LVM processing if not present.
   Add --enable-halvm and --disable-halvm options to lvmconf script.
   Add --services, --mirrorservice and --startstopservices option to lvmconf.
diff --git a/conf/Makefile.in b/conf/Makefile.in
index c427a2e..c98be88 100644
--- a/conf/Makefile.in
+++ b/conf/Makefile.in
@@ -27,8 +27,8 @@ include $(top_builddir)/make.tmpl
 .PHONY: install_conf install_localconf install_profiles
 
 generate:
-	(cat $(top_srcdir)/conf/example.conf.base && LD_LIBRARY_PATH=$(top_builddir)/libdm:$(LD_LIBRARY_PATH) $(top_builddir)/tools/lvm dumpconfig --type default --unconfigured --withfullcomments --ignorelocal) > example.conf.in
-	(cat $(top_srcdir)/conf/lvmlocal.conf.base && LD_LIBRARY_PATH=$(top_builddir)/libdm:$(LD_LIBRARY_PATH) $(top_builddir)/tools/lvm dumpconfig --type default --unconfigured --withfullcomments local) > lvmlocal.conf.in
+	(cat $(top_srcdir)/conf/example.conf.base && LD_LIBRARY_PATH=$(top_builddir)/libdm:$(LD_LIBRARY_PATH) $(top_builddir)/tools/lvm dumpconfig --type default --unconfigured --withcomments --ignorelocal) > example.conf.in
+	(cat $(top_srcdir)/conf/lvmlocal.conf.base && LD_LIBRARY_PATH=$(top_builddir)/libdm:$(LD_LIBRARY_PATH) $(top_builddir)/tools/lvm dumpconfig --type default --unconfigured --withcomments local) > lvmlocal.conf.in
 
 install_conf: $(CONFSRC)
 	@if [ ! -e $(confdir)/$(CONFDEST) ]; then \
diff --git a/lib/config/config.c b/lib/config/config.c
index fbe7cb9..79e9de4 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -1542,7 +1542,7 @@ static int _out_prefix_fn(const struct dm_config_node *cn, const char *line, voi
 
 	cfg_def = cfg_def_get_item_p(cn->id);
 
-	if (out->tree_spec->withcomments || out->tree_spec->withfullcomments) {
+	if (out->tree_spec->withsummary || out->tree_spec->withcomments) {
 		_cfg_def_make_path(path, sizeof(path), cfg_def->id, cfg_def, 1);
 		fprintf(out->fp, "\n");
 		fprintf(out->fp, "%s# Configuration %s %s.\n", line, node_type_name, path);
@@ -1551,8 +1551,8 @@ static int _out_prefix_fn(const struct dm_config_node *cn, const char *line, voi
 			int pos = 0;
 			while (_copy_one_line(cfg_def->comment, commentline, &pos, strlen(cfg_def->comment))) {
 				fprintf(out->fp, "%s# %s\n", line, commentline);
-				/* withcomments prints only the first comment line. */
-				if (!out->tree_spec->withfullcomments)
+				/* withsummary prints only the first comment line. */
+				if (!out->tree_spec->withcomments)
 					break;
 			}
 		}
diff --git a/lib/config/config.h b/lib/config/config.h
index 193f4e3..a316cd0 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -149,13 +149,13 @@ struct config_def_tree_spec {
 	struct cmd_context *cmd;	/* command context (for run-time defaults */
 	cfg_def_tree_t type;		/* tree type */
 	uint16_t version;		/* tree at this LVM2 version */
-	unsigned ignoreadvanced:1;		/* do not include advanced configs */
+	unsigned ignoreadvanced:1;	/* do not include advanced configs */
 	unsigned ignoreunsupported:1;	/* do not include unsupported configs */
 	unsigned ignorelocal:1;		/* do not include the local section */
-	unsigned withcomments:1;		/* include first line of comment */
-	unsigned withfullcomments:1;		/* include all comment lines */
-	unsigned withversions:1;		/* include versions */
-	unsigned unconfigured:1;		/* use unconfigured path strings */
+	unsigned withsummary:1;		/* include first line of comments - a summary */
+	unsigned withcomments:1;	/* include all comment lines */
+	unsigned withversions:1;	/* include versions */
+	unsigned unconfigured:1;	/* use unconfigured path strings */
 	uint8_t *check_status;		/* status of last tree check (currently needed for CFG_DEF_TREE_MISSING only) */
 };
 
diff --git a/man/lvm.conf.5.in b/man/lvm.conf.5.in
index 2c4effc..517c0f9 100644
--- a/man/lvm.conf.5.in
+++ b/man/lvm.conf.5.in
@@ -171,7 +171,7 @@ default values:
 Command to print a list of all possible config settings, with their
 default values, and a full description of each as a comment:
 .br
-.B lvmconfig \-\-type default --withfullcomments
+.B lvmconfig \-\-type default --withcomments
 
 Command to print a list of all possible config settings, with their
 current values (configured, non-default values are shown):
@@ -189,7 +189,7 @@ and a full description, where "Section" refers to the config section,
 e.g. global, and "Setting" refers to the name of the specific setting,
 e.g. umask:
 .br
-.B lvmconfig \-\-type default --withfullcomments Section/Setting
+.B lvmconfig \-\-type default --withcomments Section/Setting
 
 
 .SH FILES
diff --git a/man/lvmconfig.8.in b/man/lvmconfig.8.in
index 76f8ffe..ce59d52 100644
--- a/man/lvmconfig.8.in
+++ b/man/lvmconfig.8.in
@@ -22,8 +22,8 @@ lvmconfig, lvm dumpconfig, lvm config \(em Display LVM configuration
 .IR ProfileName ]
 .RB [ \-\-mergedconfig ]
 .RB [ \-\-validate ]
+.RB [ \-\-withsummary ]
 .RB [ \-\-withcomments ]
-.RB [ \-\-withfullcomments ]
 .RB [ \-\-withversions ]
 .RB [ ConfigurationNode... ]
 
@@ -148,11 +148,11 @@ The validation is done even if \fBconfig/checks\fP \fBlvm.conf\fP(5)
 option is disabled.
 
 .TP
-.B \-\-withcomments
+.B \-\-withsummary
 Display a one line comment for each configuration node.
 
 .TP
-.B \-\-withfullcomments
+.B \-\-withcomments
 Display a full comment for each configuration node.
 
 .TP
diff --git a/tools/args.h b/tools/args.h
index 9497223..465100d 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -118,8 +118,8 @@ arg(validate_ARG, '\0', "validate", NULL, 0)
 arg(version_ARG, '\0', "version", NULL, 0)
 arg(vgmetadatacopies_ARG, '\0', "vgmetadatacopies", metadatacopies_arg, 0)
 arg(virtualoriginsize_ARG, '\0', "virtualoriginsize", size_mb_arg, 0)
+arg(withsummary_ARG, '\0', "withsummary", NULL, 0)
 arg(withcomments_ARG, '\0', "withcomments", NULL, 0)
-arg(withfullcomments_ARG, '\0', "withfullcomments", NULL, 0)
 arg(withversions_ARG, '\0', "withversions", NULL, 0)
 arg(writebehind_ARG, '\0', "writebehind", int_arg, 0)
 arg(writemostly_ARG, '\0', "writemostly", string_arg, ARG_GROUPABLE)
diff --git a/tools/commands.h b/tools/commands.h
index df69c2a..ea70cc2 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -44,14 +44,14 @@ xx(config,
    "\t[--metadataprofile ProfileName]\n"
    "\t[--mergedconfig]\n"
    "\t[--validate]\n"
+   "\t[--withsummary]\n"
    "\t[--withcomments]\n"
-   "\t[--withfullcomments]\n"
    "\t[--unconfigured]\n"
    "\t[--withversions]\n"
    "\t[ConfigurationNode...]\n",
    atversion_ARG, configtype_ARG, file_ARG, ignoreadvanced_ARG,
    ignoreunsupported_ARG, ignorelocal_ARG, mergedconfig_ARG, metadataprofile_ARG,
-   validate_ARG, withcomments_ARG, withfullcomments_ARG, unconfigured_ARG, withversions_ARG)
+   validate_ARG, withsummary_ARG, withcomments_ARG, unconfigured_ARG, withversions_ARG)
 
 xx(devtypes,
    "Display recognised built-in block device types",
@@ -95,14 +95,14 @@ xx(dumpconfig,
    "\t[--metadataprofile ProfileName]\n"
    "\t[--mergedconfig]\n"
    "\t[--validate]\n"
+   "\t[--withsummary]\n"
    "\t[--withcomments]\n"
-   "\t[--withfullcomments]\n"
    "\t[--unconfigured]\n"
    "\t[--withversions]\n"
    "\t[ConfigurationNode...]\n",
    atversion_ARG, configtype_ARG, file_ARG, ignoreadvanced_ARG,
    ignoreunsupported_ARG, ignorelocal_ARG, mergedconfig_ARG, metadataprofile_ARG,
-   validate_ARG, withcomments_ARG, withfullcomments_ARG, unconfigured_ARG, withversions_ARG)
+   validate_ARG, withsummary_ARG, withcomments_ARG, unconfigured_ARG, withversions_ARG)
 
 xx(formats,
    "List available metadata formats",
@@ -495,14 +495,14 @@ xx(lvmconfig,
    "\t[--metadataprofile ProfileName]\n"
    "\t[--mergedconfig]\n"
    "\t[--validate]\n"
+   "\t[--withsummary]\n"
    "\t[--withcomments]\n"
-   "\t[--withfullcomments]\n"
    "\t[--unconfigured]\n"
    "\t[--withversions]\n"
    "\t[ConfigurationNode...]\n",
    atversion_ARG, configtype_ARG, file_ARG, ignoreadvanced_ARG,
    ignoreunsupported_ARG, ignorelocal_ARG, mergedconfig_ARG, metadataprofile_ARG,
-   validate_ARG, withcomments_ARG, withfullcomments_ARG, unconfigured_ARG, withversions_ARG)
+   validate_ARG, withsummary_ARG, withcomments_ARG, unconfigured_ARG, withversions_ARG)
 
 xx(lvmdiskscan,
    "List devices that may be used as physical volumes",
diff --git a/tools/dumpconfig.c b/tools/dumpconfig.c
index 341bffa..04d5df6 100644
--- a/tools/dumpconfig.c
+++ b/tools/dumpconfig.c
@@ -220,10 +220,10 @@ int dumpconfig(struct cmd_context *cmd, int argc, char **argv)
 		goto out;
 	}
 
+	if (arg_count(cmd, withsummary_ARG))
+		tree_spec.withsummary = 1;
 	if (arg_count(cmd, withcomments_ARG))
 		tree_spec.withcomments = 1;
-	if (arg_count(cmd, withfullcomments_ARG))
-		tree_spec.withfullcomments = 1;
 	if (arg_count(cmd, unconfigured_ARG))
 		tree_spec.unconfigured = 1;
 


