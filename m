From: Alasdair Kergon <agk@sourceware.org>
Date: Sat, 5 Aug 2017 11:23:46 -0400
Subject: master - lvmconfig: Add options to produce file preamble
Message-ID: <201708051523.v75FNkIR029973@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fe423ef583a48ca0f780156ec5f1fe33716318ad
Commit:        fe423ef583a48ca0f780156ec5f1fe33716318ad
Parent:        827be01758ec5adb7b9d5ea75b658092adc65534
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Sat Aug 5 16:18:36 2017 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Sat Aug 5 16:23:34 2017 +0100

lvmconfig: Add options to produce file preamble

Use --withgeneralpreamble and --withlocalpreamble instead of
concatenating files.
---
 WHATS_NEW                    |    3 +-
 conf/Makefile.in             |    4 +-
 conf/example.conf.base       |   23 ---------------------
 conf/lvmlocal.conf.base      |   19 ------------------
 lib/config/config.c          |    6 +++++
 lib/config/config.h          |    3 ++
 lib/config/config_settings.h |   44 ++++++++++++++++++++++++++++++++++++++++++
 man/lvmconfig.8_pregen       |   20 +++++++++++++++++++
 tools/args.h                 |    6 +++++
 tools/command-lines.in       |    2 +-
 tools/dumpconfig.c           |   16 +++++++++++++++
 11 files changed, 100 insertions(+), 46 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 46a944b..ebbc7d1 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,6 +1,7 @@
 Version 2.02.174 - 
 =================================
-  Imporove makefiles' linking.
+  Add --withgeneralpreamble and --withlocalpreamble to lvmconfig.
+  Improve makefiles' linking.
   Fix some paths in generated makefiles to respected configured settings.
   Add warning when creating thin-pool with zeroing and chunk size >= 512KiB.
   Introduce exit code 4 EINIT_FAILED to replace -1 when initialisation fails.
diff --git a/conf/Makefile.in b/conf/Makefile.in
index c8fee3e..5330c07 100644
--- a/conf/Makefile.in
+++ b/conf/Makefile.in
@@ -32,8 +32,8 @@ include $(top_builddir)/make.tmpl
 .PHONY: install_conf install_localconf install_profiles
 
 generate:
-	(cat $(top_srcdir)/conf/example.conf.base && LD_LIBRARY_PATH=$(top_builddir)/libdm:$(LD_LIBRARY_PATH) $(top_builddir)/tools/lvm dumpconfig --type default --unconfigured --withcomments --ignorelocal --withspaces) > example.conf.in
-	(cat $(top_srcdir)/conf/lvmlocal.conf.base && LD_LIBRARY_PATH=$(top_builddir)/libdm:$(LD_LIBRARY_PATH) $(top_builddir)/tools/lvm dumpconfig --type default --unconfigured --withcomments --withspaces local) > lvmlocal.conf.in
+	LD_LIBRARY_PATH=$(top_builddir)/libdm:$(LD_LIBRARY_PATH) $(top_builddir)/tools/lvm dumpconfig --type default --unconfigured --withgeneralpreamble --withcomments --ignorelocal --withspaces > example.conf.in
+	LD_LIBRARY_PATH=$(top_builddir)/libdm:$(LD_LIBRARY_PATH) $(top_builddir)/tools/lvm dumpconfig --type default --unconfigured --withlocalpreamble --withcomments --withspaces local > lvmlocal.conf.in
 
 install_conf: $(CONFSRC)
 	@if [ ! -e $(confdir)/$(CONFDEST) ]; then \
diff --git a/conf/example.conf.base b/conf/example.conf.base
deleted file mode 100644
index 5c49899..0000000
--- a/conf/example.conf.base
+++ /dev/null
@@ -1,23 +0,0 @@
-# This is an example configuration file for the LVM2 system.
-# It contains the default settings that would be used if there was no
-# @DEFAULT_SYS_DIR@/lvm.conf file.
-#
-# Refer to 'man lvm.conf' for further information including the file layout.
-#
-# Refer to 'man lvm.conf' for information about how settings configured in
-# this file are combined with built-in values and command line options to
-# arrive at the final values used by LVM.
-#
-# Refer to 'man lvmconfig' for information about displaying the built-in
-# and configured values used by LVM.
-#
-# If a default value is set in this file (not commented out), then a
-# new version of LVM using this file will continue using that value,
-# even if the new version of LVM changes the built-in default value.
-#
-# To put this file in a different directory and override @DEFAULT_SYS_DIR@ set
-# the environment variable LVM_SYSTEM_DIR before running the tools.
-#
-# N.B. Take care that each setting only appears once if uncommenting
-# example settings in this file.
-
diff --git a/conf/lvmlocal.conf.base b/conf/lvmlocal.conf.base
deleted file mode 100644
index e2a9e2f..0000000
--- a/conf/lvmlocal.conf.base
+++ /dev/null
@@ -1,19 +0,0 @@
-# This is a local configuration file template for the LVM2 system
-# which should be installed as @DEFAULT_SYS_DIR@/lvmlocal.conf .
-#
-# Refer to 'man lvm.conf' for information about the file layout.
-#
-# To put this file in a different directory and override
-# @DEFAULT_SYS_DIR@ set the environment variable LVM_SYSTEM_DIR before
-# running the tools.
-#
-# The lvmlocal.conf file is normally expected to contain only the
-# "local" section which contains settings that should not be shared or
-# repeated among different hosts.  (But if other sections are present,
-# they *will* get processed.  Settings in this file override equivalent
-# ones in lvm.conf and are in turn overridden by ones in any enabled
-# lvm_<tag>.conf files.)
-#
-# Please take care that each setting only appears once if uncommenting
-# example settings in this file and never copy this file between hosts.
-
diff --git a/lib/config/config.c b/lib/config/config.c
index 04dded7..1f18969 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -1880,6 +1880,12 @@ int config_write(struct dm_config_tree *cft,
 	}
 
 	log_verbose("Dumping configuration to %s", file);
+
+	if (tree_spec->withgeneralpreamble)
+		fprintf(baton.fp, CFG_PREAMBLE_GENERAL);
+	if (tree_spec->withlocalpreamble)
+		fprintf(baton.fp, CFG_PREAMBLE_LOCAL);
+
 	if (!argc) {
 		if (!dm_config_write_node_out(cft->root, &_out_spec, &baton)) {
 			log_error("Failure while writing to %s", file);
diff --git a/lib/config/config.h b/lib/config/config.h
index 8a7d6c3..901994a 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -141,6 +141,7 @@ typedef struct cfg_def_item {
 	uint16_t deprecated_since_version;				/* version since this item is deprecated */
 	const char *deprecation_comment;				/* comment about reasons for deprecation and settings that supersede this one */
 	const char *comment;						/* comment */
+	const char *file_premable;					/* comment text to use at the start of the file */
 } cfg_def_item_t;
 
 /* configuration definition tree types */
@@ -173,6 +174,8 @@ struct config_def_tree_spec {
 	unsigned withversions:1;		/* include versions */
 	unsigned withspaces:1;			/* add more spaces in output for better readability */
 	unsigned unconfigured:1;		/* use unconfigured path strings */
+	unsigned withgeneralpreamble:1;		/* include preamble for a general config file */
+	unsigned withlocalpreamble:1;		/* include preamble for a local config file */
 	uint8_t *check_status;			/* status of last tree check (currently needed for CFG_DEF_TREE_MISSING only) */
 };
 
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 40b64ab..7d800b3 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -121,6 +121,30 @@
 
 cfg_section(root_CFG_SECTION, "(root)", root_CFG_SECTION, 0, vsn(0, 0, 0), 0, NULL, NULL)
 
+#define CFG_PREAMBLE_GENERAL \
+	"# This is an example configuration file for the LVM2 system.\n" \
+	"# It contains the default settings that would be used if there was no\n" \
+	"# @DEFAULT_SYS_DIR@/lvm.conf file.\n" \
+	"#\n" \
+	"# Refer to 'man lvm.conf' for further information including the file layout.\n" \
+	"#\n" \
+	"# Refer to 'man lvm.conf' for information about how settings configured in\n" \
+	"# this file are combined with built-in values and command line options to\n" \
+	"# arrive at the final values used by LVM.\n" \
+	"#\n" \
+	"# Refer to 'man lvmconfig' for information about displaying the built-in\n" \
+	"# and configured values used by LVM.\n" \
+	"#\n" \
+	"# If a default value is set in this file (not commented out), then a\n" \
+	"# new version of LVM using this file will continue using that value,\n" \
+	"# even if the new version of LVM changes the built-in default value.\n" \
+	"#\n" \
+	"# To put this file in a different directory and override @DEFAULT_SYS_DIR@ set\n" \
+	"# the environment variable LVM_SYSTEM_DIR before running the tools.\n" \
+	"#\n" \
+	"# N.B. Take care that each setting only appears once if uncommenting\n" \
+	"# example settings in this file.\n\n"
+
 cfg_section(config_CFG_SECTION, "config", root_CFG_SECTION, 0, vsn(2, 2, 99), 0, NULL,
 	"How LVM configuration settings are handled.\n")
 
@@ -161,6 +185,26 @@ cfg_section(tags_CFG_SECTION, "tags", root_CFG_SECTION, CFG_DEFAULT_COMMENTED, v
 cfg_section(local_CFG_SECTION, "local", root_CFG_SECTION, 0, vsn(2, 2, 117), 0, NULL,
 	"LVM settings that are specific to the local host.\n")
 
+#define CFG_PREAMBLE_LOCAL \
+	"# This is a local configuration file template for the LVM2 system\n" \
+	"# which should be installed as @DEFAULT_SYS_DIR@/lvmlocal.conf .\n" \
+	"#\n" \
+	"# Refer to 'man lvm.conf' for information about the file layout.\n" \
+	"#\n" \
+	"# To put this file in a different directory and override\n" \
+	"# @DEFAULT_SYS_DIR@ set the environment variable LVM_SYSTEM_DIR before\n" \
+	"# running the tools.\n" \
+	"#\n" \
+	"# The lvmlocal.conf file is normally expected to contain only the\n" \
+	"# \"local\" section which contains settings that should not be shared or\n" \
+	"# repeated among different hosts.  (But if other sections are present,\n" \
+	"# they *will* get processed.  Settings in this file override equivalent\n" \
+	"# ones in lvm.conf and are in turn overridden by ones in any enabled\n" \
+	"# lvm_<tag>.conf files.)\n" \
+	"#\n" \
+	"# Please take care that each setting only appears once if uncommenting\n" \
+	"# example settings in this file and never copy this file between hosts.\n\n"
+
 cfg(config_checks_CFG, "checks", config_CFG_SECTION, 0, CFG_TYPE_BOOL, 1, vsn(2, 2, 99), NULL, 0, NULL,
 	"If enabled, any LVM configuration mismatch is reported.\n"
 	"This implies checking that the configuration key is understood by\n"
diff --git a/man/lvmconfig.8_pregen b/man/lvmconfig.8_pregen
index 3c3e25f..c60f899 100644
--- a/man/lvmconfig.8_pregen
+++ b/man/lvmconfig.8_pregen
@@ -79,6 +79,14 @@ line settings from --config.
 .ad b
 .br
 .ad l
+[    \fB--withgeneralpreamble\fP ]
+.ad b
+.br
+.ad l
+[    \fB--withlocalpreamble\fP ]
+.ad b
+.br
+.ad l
 [    \fB--withspaces\fP ]
 .ad b
 .br
@@ -389,6 +397,18 @@ settings, also display comments about deprecation.
 .ad b
 .HP
 .ad l
+\fB--withgeneralpreamble\fP
+.br
+Display general file preamble at start of output.
+.ad b
+.HP
+.ad l
+\fB--withlocalpreamble\fP
+.br
+Display local file preamble at start of output.
+.ad b
+.HP
+.ad l
 \fB--withspaces\fP
 .br
 Where appropriate, add more spaces in output for better readability.
diff --git a/tools/args.h b/tools/args.h
index f5e864f..89d84b4 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -783,6 +783,12 @@ arg(withcomments_ARG, '\0', "withcomments", 0, 0, 0,
     "Display a full comment for each configuration node. For deprecated\n"
     "settings, also display comments about deprecation.\n")
 
+arg(withgeneralpreamble_ARG, '\0', "withgeneralpreamble", 0, 0, 0,
+    "Include general config file preamble.\n")
+
+arg(withlocalpreamble_ARG, '\0', "withlocalpreamble", 0, 0, 0,
+    "Include local config file preamble.\n")
+
 arg(withspaces_ARG, '\0', "withspaces", 0, 0, 0,
     "Where appropriate, add more spaces in output for better readability.\n")
 
diff --git a/tools/command-lines.in b/tools/command-lines.in
index 6e9192e..1ef234e 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -206,7 +206,7 @@ OO_REPORT: --aligned, --all, --binary, --configreport ConfigReport, --foreign,
 OO_CONFIG: --atversion String, --typeconfig ConfigType, --file String, --ignoreadvanced,
 --ignoreunsupported, --ignorelocal, --list, --mergedconfig, --metadataprofile String,
 --sinceversion String, --showdeprecated, --showunsupported, --validate, --withsummary,
---withcomments, --withspaces, --unconfigured, --withversions
+--withcomments, --withgeneralpreamble, --withlocalpreamble, --withspaces, --unconfigured, --withversions
 
 ---
 
diff --git a/tools/dumpconfig.c b/tools/dumpconfig.c
index e387e60..9e4408e 100644
--- a/tools/dumpconfig.c
+++ b/tools/dumpconfig.c
@@ -234,6 +234,14 @@ int dumpconfig(struct cmd_context *cmd, int argc, char **argv)
 			log_error("--withcomments has no effect with --type list");
 			return EINVALID_CMD_LINE;
 		}
+		if (arg_is_set(cmd, withlocalpreamble_ARG)) {
+			log_error("--withlocalpreamble has no effect with --type list");
+			return EINVALID_CMD_LINE;
+		}
+		if (arg_is_set(cmd, withgeneralpreamble_ARG)) {
+			log_error("--withgeneralpreamble has no effect with --type list");
+			return EINVALID_CMD_LINE;
+		}
 		/* list type does not require status check */
 	} else if (!strcmp(type, "full")) {
 		tree_spec.type = CFG_DEF_TREE_FULL;
@@ -293,14 +301,22 @@ int dumpconfig(struct cmd_context *cmd, int argc, char **argv)
 
 	if (arg_is_set(cmd, withsummary_ARG) || arg_is_set(cmd, list_ARG))
 		tree_spec.withsummary = 1;
+
 	if (arg_is_set(cmd, withcomments_ARG))
 		tree_spec.withcomments = 1;
+
 	if (arg_is_set(cmd, unconfigured_ARG))
 		tree_spec.unconfigured = 1;
 
 	if (arg_is_set(cmd, withversions_ARG))
 		tree_spec.withversions = 1;
 
+	if (arg_is_set(cmd, withgeneralpreamble_ARG))
+		tree_spec.withgeneralpreamble = 1;
+
+	if (arg_is_set(cmd, withlocalpreamble_ARG))
+		tree_spec.withlocalpreamble = 1;
+
 	if (arg_is_set(cmd, withspaces_ARG))
 		tree_spec.withspaces = 1;
 


