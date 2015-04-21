From: David Teigland <teigland@fedoraproject.org>
Date: Tue, 21 Apr 2015 20:10:47 +0000 (UTC)
Subject: master - dumpconfig: add --ignorelocal
Message-ID: <20150421201047.63DA160B34@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9b86e8e8f4a3c429f8e5632103fbef6eb1f8dc7d
Commit:        9b86e8e8f4a3c429f8e5632103fbef6eb1f8dc7d
Parent:        0d0d50182d1bf6b11b80fe8fe701f654b953f2fa
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Apr 21 14:53:54 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Apr 21 14:55:03 2015 -0500

dumpconfig: add --ignorelocal

When generating a sample lvm.conf file, we don't want to
include the "local" section, which is kept in lvmlocal.conf.
---
 WHATS_NEW               |    1 +
 lib/config/config.c     |    3 +++
 lib/config/config.h     |    1 +
 man/lvm-dumpconfig.8.in |    5 +++++
 tools/args.h            |    1 +
 tools/commands.h        |    3 ++-
 tools/dumpconfig.c      |    3 +++
 7 files changed, 16 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 987a7c9..23c70eb 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.119 - 
 ==================================
+  Add --ignorelocal option to dumpconfig to ignore the local section.
   Close connection to lvmetad after fork.
   Make lvchange able to resume background pvmove polling again.
   Split pvmove update metadata fn in an initial one and a subsequent one.
diff --git a/lib/config/config.c b/lib/config/config.c
index 57e7cb9..4051fa4 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -1817,6 +1817,9 @@ struct dm_config_tree *config_def_create_tree(struct config_def_tree_spec *spec)
 		if (cfg_def_get_item_p(id)->parent != root_CFG_SECTION)
 			continue;
 
+		if (spec->ignorelocal && (id == local_CFG_SECTION))
+			continue;
+
 		if ((tmp = _add_def_section_subtree(cft, spec, root, relay, id))) {
 			relay = tmp;
 			if (!root)
diff --git a/lib/config/config.h b/lib/config/config.h
index 54bd183..cc5681c 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -145,6 +145,7 @@ struct config_def_tree_spec {
 	uint16_t version;		/* tree at this LVM2 version */
 	unsigned ignoreadvanced:1;		/* do not include advanced configs */
 	unsigned ignoreunsupported:1;	/* do not include unsupported configs */
+	unsigned ignorelocal:1;		/* do not include the local section */
 	unsigned withcomments:1;		/* include first line of comment */
 	unsigned withfullcomments:1;		/* include all comment lines */
 	unsigned withversions:1;		/* include versions */
diff --git a/man/lvm-dumpconfig.8.in b/man/lvm-dumpconfig.8.in
index a4289d9..b16afb4 100644
--- a/man/lvm-dumpconfig.8.in
+++ b/man/lvm-dumpconfig.8.in
@@ -11,6 +11,7 @@ lvm-dumpconfig \(em dump LVM configuration
 .IR version ]
 .RB [ \-\-ignoreadvanced ]
 .RB [ \-\-ignoreunsupported ]
+.RB [ \-\-ignorelocal ]
 .RB [ \-\-config
 .IR ConfigurationString ]
 .RB [ \-\-commandprofile
@@ -95,6 +96,10 @@ either used for debugging purposes only or their support is not yet
 complete and they are not meant to be used in production.
 
 .TP
+.B \-\-ignorelocal
+Ignore local section.
+
+.TP
 .BI \-\-config " ConfigurationString"
 Use \fBConfigurationString\fP to override existing configuration.
 This configuration is then applied for dumpconfig command itself.
diff --git a/tools/args.h b/tools/args.h
index 201a2ef..9497223 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -43,6 +43,7 @@ arg(errorwhenfull_ARG, '\0', "errorwhenfull", yes_no_arg, 0)
 arg(force_long_ARG, '\0', "force", NULL, ARG_COUNTABLE)
 arg(foreign_ARG, '\0', "foreign", NULL, 0)
 arg(ignoreadvanced_ARG, '\0', "ignoreadvanced", NULL, 0)
+arg(ignorelocal_ARG, '\0', "ignorelocal", NULL, 0)
 arg(ignorelockingfailure_ARG, '\0', "ignorelockingfailure", NULL, 0)
 arg(ignoremonitoring_ARG, '\0', "ignoremonitoring", NULL, 0)
 arg(ignoreskippedcluster_ARG, '\0', "ignoreskippedcluster", NULL, 0)
diff --git a/tools/commands.h b/tools/commands.h
index 10916bf..64c8bf2 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -63,6 +63,7 @@ xx(dumpconfig,
    "\t[--atversion version]]\n"
    "\t[--ignoreadvanced]\n"
    "\t[--ignoreunsupported]\n"
+   "\t[--ignorelocal]\n"
    "\t[--config ConfigurationString]\n"
    "\t[--commandprofile ProfileName]\n"
    "\t[--profile ProfileName]\n"
@@ -75,7 +76,7 @@ xx(dumpconfig,
    "\t[--withversions]\n"
    "\t[ConfigurationNode...]\n",
    atversion_ARG, configtype_ARG, file_ARG, ignoreadvanced_ARG,
-   ignoreunsupported_ARG, mergedconfig_ARG, metadataprofile_ARG,
+   ignoreunsupported_ARG, ignorelocal_ARG, mergedconfig_ARG, metadataprofile_ARG,
    validate_ARG, withcomments_ARG, withfullcomments_ARG, unconfigured_ARG, withversions_ARG)
 
 xx(formats,
diff --git a/tools/dumpconfig.c b/tools/dumpconfig.c
index 2d1cd9c..d1b4acc 100644
--- a/tools/dumpconfig.c
+++ b/tools/dumpconfig.c
@@ -113,6 +113,9 @@ int dumpconfig(struct cmd_context *cmd, int argc, char **argv)
 	if (arg_count(cmd, ignoreunsupported_ARG))
 		tree_spec.ignoreunsupported = 1;
 
+	if (arg_count(cmd, ignorelocal_ARG))
+		tree_spec.ignorelocal = 1;
+
 	if (!strcmp(type, "current")) {
 		if (arg_count(cmd, atversion_ARG)) {
 			log_error("--atversion has no effect with --type current");


