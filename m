From: David Teigland <teigland@fedoraproject.org>
Date: Wed, 15 Apr 2015 15:58:25 +0000 (UTC)
Subject: master - dumpconfig: add --withfullcomments option
Message-ID: <20150415155825.7D0EA609C4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5f6ac1c81274de2a3162764d7c4b14a80b3a5ae2
Commit:        5f6ac1c81274de2a3162764d7c4b14a80b3a5ae2
Parent:        9ce52430de8c8920e191aca8fd27be4dc8e2c96a
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Apr 15 10:56:42 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Apr 15 10:56:42 2015 -0500

dumpconfig: add --withfullcomments option

--withfullcomments prints all comment lines for each config option.
--withcomments prints only the first comment line, which should be
a short one-line summary of the option.
---
 WHATS_NEW               |    1 +
 lib/config/config.c     |    8 ++++++--
 lib/config/config.h     |    3 ++-
 man/lvm-dumpconfig.8.in |    7 ++++++-
 tools/args.h            |    1 +
 tools/commands.h        |    3 ++-
 tools/dumpconfig.c      |    2 ++
 7 files changed, 20 insertions(+), 5 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 9313ffb..29e461c 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.119 - 
 ==================================
+  Add --withfullcomments option to dumpconfig to print full comment.
   Check for lvm binary in blkdeactivate and skip LVM processing if not present.
   Add --enable-halvm and --disable-halvm options to lvmconf script.
   Add --services, --mirrorservice and --startstopservices option to lvmconf.
diff --git a/lib/config/config.c b/lib/config/config.c
index b28472b..8f116cd 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -1541,15 +1541,19 @@ static int _out_prefix_fn(const struct dm_config_node *cn, const char *line, voi
 
 	cfg_def = cfg_def_get_item_p(cn->id);
 
-	if (out->tree_spec->withcomments) {
+	if (out->tree_spec->withcomments || out->tree_spec->withfullcomments) {
 		_cfg_def_make_path(path, sizeof(path), cfg_def->id, cfg_def, 1);
 		fprintf(out->fp, "\n");
 		fprintf(out->fp, "%s# Configuration %s %s.\n", line, node_type_name, path);
 
 		if (cfg_def->comment) {
 			int pos = 0;
-			while (_copy_one_line(cfg_def->comment, commentline, &pos, strlen(cfg_def->comment)))
+			while (_copy_one_line(cfg_def->comment, commentline, &pos, strlen(cfg_def->comment))) {
 				fprintf(out->fp, "%s# %s\n", line, commentline);
+				/* withcomments prints only the first comment line. */
+				if (!out->tree_spec->withfullcomments)
+					break;
+			}
 		}
 
 		if (cfg_def->flags & CFG_ADVANCED)
diff --git a/lib/config/config.h b/lib/config/config.h
index 5fe6a9f..72c7606 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -144,7 +144,8 @@ struct config_def_tree_spec {
 	uint16_t version;		/* tree at this LVM2 version */
 	unsigned ignoreadvanced:1;		/* do not include advanced configs */
 	unsigned ignoreunsupported:1;	/* do not include unsupported configs */
-	unsigned withcomments:1;		/* include comments */
+	unsigned withcomments:1;		/* include first line of comment */
+	unsigned withfullcomments:1;		/* include all comment lines */
 	unsigned withversions:1;		/* include versions */
 	uint8_t *check_status;		/* status of last tree check (currently needed for CFG_DEF_TREE_MISSING only) */
 };
diff --git a/man/lvm-dumpconfig.8.in b/man/lvm-dumpconfig.8.in
index 04afce9..a4289d9 100644
--- a/man/lvm-dumpconfig.8.in
+++ b/man/lvm-dumpconfig.8.in
@@ -22,6 +22,7 @@ lvm-dumpconfig \(em dump LVM configuration
 .RB [ \-\-mergedconfig ]
 .RB [ \-\-validate ]
 .RB [ \-\-withcomments ]
+.RB [ \-\-withfullcomments ]
 .RB [ \-\-withversions ]
 .RB [ ConfigurationNode... ]
 
@@ -140,7 +141,11 @@ option is disabled.
 
 .TP
 .B \-\-withcomments
-Also dump comments for each configuration node.
+Dump a one line comment for each configuration node.
+
+.TP
+.B \-\-withfullcomments
+Dump a full comment for each configuration node.
 
 .TP
 .B \-\-withversions
diff --git a/tools/args.h b/tools/args.h
index a40cfb0..4a43457 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -117,6 +117,7 @@ arg(version_ARG, '\0', "version", NULL, 0)
 arg(vgmetadatacopies_ARG, '\0', "vgmetadatacopies", metadatacopies_arg, 0)
 arg(virtualoriginsize_ARG, '\0', "virtualoriginsize", size_mb_arg, 0)
 arg(withcomments_ARG, '\0', "withcomments", NULL, 0)
+arg(withfullcomments_ARG, '\0', "withfullcomments", NULL, 0)
 arg(withversions_ARG, '\0', "withversions", NULL, 0)
 arg(writebehind_ARG, '\0', "writebehind", int_arg, 0)
 arg(writemostly_ARG, '\0', "writemostly", string_arg, ARG_GROUPABLE)
diff --git a/tools/commands.h b/tools/commands.h
index 719c507..b9c7a8b 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -70,11 +70,12 @@ xx(dumpconfig,
    "\t[--mergedconfig]\n"
    "\t[--validate]\n"
    "\t[--withcomments]\n"
+   "\t[--withfullcomments]\n"
    "\t[--withversions]\n"
    "\t[ConfigurationNode...]\n",
    atversion_ARG, configtype_ARG, file_ARG, ignoreadvanced_ARG,
    ignoreunsupported_ARG, mergedconfig_ARG, metadataprofile_ARG,
-   validate_ARG, withcomments_ARG, withversions_ARG)
+   validate_ARG, withcomments_ARG, withfullcomments_ARG, withversions_ARG)
 
 xx(formats,
    "List available metadata formats",
diff --git a/tools/dumpconfig.c b/tools/dumpconfig.c
index 09f2119..6d2108f 100644
--- a/tools/dumpconfig.c
+++ b/tools/dumpconfig.c
@@ -219,6 +219,8 @@ int dumpconfig(struct cmd_context *cmd, int argc, char **argv)
 
 	if (arg_count(cmd, withcomments_ARG))
 		tree_spec.withcomments = 1;
+	if (arg_count(cmd, withfullcomments_ARG))
+		tree_spec.withfullcomments = 1;
 
 	if (arg_count(cmd, withversions_ARG))
 		tree_spec.withversions = 1;


