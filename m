From: Peter Rajnoha <prajnoha@sourceware.org>
Date: Wed, 17 Aug 2022 08:48:14 +0000 (GMT)
Subject: main - lvmconfig: add --valuesonly option
Message-ID: <20220817084814.490763858D1E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b4cc28c2ef72ee022c1a03819927e31775c18676
Commit:        b4cc28c2ef72ee022c1a03819927e31775c18676
Parent:        81839cc4ebf566ea9f3e6d819c7338b98cdec374
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Aug 16 16:56:06 2022 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Aug 17 10:47:24 2022 +0200

lvmconfig: add --valuesonly option

The new --valuesonly option causes the lvmconfig output to contain only
values without keys for each config node. This is practical mainly in
case where we use lvmconfig in scripts and we want to assign the value
to a different custom key or simply output the value itself without the
key.

For example:

  # lvmconfig --type full activation/raid_fault_policy
  raid_fault_policy="warn"

  # lvmconfig --type full activation/raid_fault_policy --valuesonly
  "warn"

  # my_var=$(lvmconfig --type full activation/raid_fault_policy --valuesonly)

  # echo $my_var
  "warn"
---
 WHATS_NEW              |  1 +
 lib/config/config.c    | 22 +++++++++++++++++++++-
 lib/config/config.h    |  1 +
 man/lvmconfig.8_pregen |  7 +++++++
 tools/args.h           |  3 +++
 tools/command-lines.in |  5 +++--
 tools/dumpconfig.c     |  7 +++++++
 7 files changed, 43 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 6cd53553b..6e9a3fa1d 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.17 - 
 ===============================
+  Add --valuesonly option to lvmconfig to print only values without keys.
   Updates configure with recent autoconf tooling.
   Fix lvconvert --test --type vdo-pool execution.
   Add json_std output format for more JSON standard compliant version of output.
diff --git a/lib/config/config.c b/lib/config/config.c
index f9614779a..1142ed345 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -1830,8 +1830,10 @@ static int _out_line_fn(const struct dm_config_node *cn, const char *line, void
 	char summary[MAX_COMMENT_LINE+1];
 	char version[9];
 	int pos = 0;
-	size_t len;
+	int space_prefix_len;
 	char *space_prefix;
+	const char *p;
+	size_t len;
 
 	if ((out->tree_spec->type == CFG_DEF_TREE_DIFF) &&
 	    (!(out->tree_spec->check_status[cn->id] & CFG_DIFF)))
@@ -1865,9 +1867,24 @@ static int _out_line_fn(const struct dm_config_node *cn, const char *line, void
 
 	/* Usual tree view with nodes and their values. */
 
+	if (out->tree_spec->valuesonly && !(cfg_def->type & CFG_TYPE_SECTION)) {
+		if ((space_prefix_len = strspn(line, "\t "))) {
+			len = strlen(line);
+			p = line + space_prefix_len;
+
+			/* copy space_prefix, skip key and '=', copy value */
+			dm_pool_begin_object(out->mem, len);
+			dm_pool_grow_object(out->mem, line, space_prefix_len);
+			dm_pool_grow_object(out->mem, p + strcspn(p, "=") + 1, len + 1);
+			line = dm_pool_end_object(out->mem);
+		} else
+			line = strchr(line, '=') + 1;
+	}
+
 	if ((out->tree_spec->type != CFG_DEF_TREE_CURRENT) &&
 	    (out->tree_spec->type != CFG_DEF_TREE_DIFF) &&
 	    (out->tree_spec->type != CFG_DEF_TREE_FULL) &&
+	    !out->tree_spec->valuesonly &&
 	    (cfg_def->flags & (CFG_DEFAULT_UNDEFINED | CFG_DEFAULT_COMMENTED))) {
 		/* print with # at the front to comment out the line */
 		if (_should_print_cfg_with_undef_def_val(out, cfg_def, cn)) {
@@ -1883,6 +1900,9 @@ static int _out_line_fn(const struct dm_config_node *cn, const char *line, void
 	if (_should_print_cfg_with_undef_def_val(out, cfg_def, cn))
 		fprintf(out->fp, "%s\n", line);
 
+	if (out->tree_spec->valuesonly && !(cfg_def->type & CFG_TYPE_SECTION) && space_prefix_len)
+		dm_pool_free(out->mem, (char *) line);
+
 	return 1;
 }
 
diff --git a/lib/config/config.h b/lib/config/config.h
index c62ea20a5..3926b12f5 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -176,6 +176,7 @@ struct config_def_tree_spec {
 	unsigned unconfigured:1;		/* use unconfigured path strings */
 	unsigned withgeneralpreamble:1;		/* include preamble for a general config file */
 	unsigned withlocalpreamble:1;		/* include preamble for a local config file */
+	unsigned valuesonly:1;                  /* print only values without keys */
 	uint8_t *check_status;			/* status of last tree check (currently needed for CFG_DEF_TREE_MISSING only) */
 };
 
diff --git a/man/lvmconfig.8_pregen b/man/lvmconfig.8_pregen
index a29255cf4..5279fa4dc 100644
--- a/man/lvmconfig.8_pregen
+++ b/man/lvmconfig.8_pregen
@@ -56,6 +56,8 @@ line settings from --config.
 .br
 [    \fB--validate\fP ]
 .br
+[    \fB--valuesonly\fP ]
+.br
 [    \fB--withsummary\fP ]
 .br
 [    \fB--withcomments\fP ]
@@ -369,6 +371,11 @@ merged configuration tree, also use --mergedconfig.
 The validation is done even if \fBlvm.conf\fP(5) \fBconfig/checks\fP is disabled.
 .
 .HP
+\fB--valuesonly\fP
+.br
+When printing config settings, print only values without keys.
+.
+.HP
 \fB-v\fP|\fB--verbose\fP ...
 .br
 Set verbose level. Repeat from 1 to 4 times to increase the detail
diff --git a/tools/args.h b/tools/args.h
index 9229b8764..bdeefca7d 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -905,6 +905,9 @@ arg(validate_ARG, '\0', "validate", 0, 0, 0,
     "merged configuration tree, also use --mergedconfig.\n"
     "The validation is done even if \\fBlvm.conf\\fP(5) \\fBconfig/checks\\fP is disabled.\n")
 
+arg(valuesonly_ARG, '\0', "valuesonly", 0, 0, 0,
+    "When printing config settings, print only values without keys.\n")
+
 arg(vdo_ARG, '\0', "vdo", 0, 0, 0,
     "Specifies the command is handling VDO LV.\n"
     "See --type vdo.\n"
diff --git a/tools/command-lines.in b/tools/command-lines.in
index b6a03d158..6e9e7bdea 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -221,8 +221,9 @@ OO_REPORT: --aligned, --all, --binary, --configreport ConfigReport, --foreign,
 #
 OO_CONFIG: --atversion String, --typeconfig ConfigType, --file String, --ignoreadvanced,
 --ignoreunsupported, --ignorelocal, --list, --mergedconfig, --metadataprofile String,
---sinceversion String, --showdeprecated, --showunsupported, --validate, --withsummary,
---withcomments, --withgeneralpreamble, --withlocalpreamble, --withspaces, --unconfigured, --withversions
+--sinceversion String, --showdeprecated, --showunsupported, --validate, --valuesonly,
+--withsummary, --withcomments, --withgeneralpreamble, --withlocalpreamble, --withspaces,
+--unconfigured, --withversions
 
 ---
 
diff --git a/tools/dumpconfig.c b/tools/dumpconfig.c
index 9e4408e16..4a0f193c4 100644
--- a/tools/dumpconfig.c
+++ b/tools/dumpconfig.c
@@ -242,6 +242,10 @@ int dumpconfig(struct cmd_context *cmd, int argc, char **argv)
 			log_error("--withgeneralpreamble has no effect with --type list");
 			return EINVALID_CMD_LINE;
 		}
+		if (arg_is_set(cmd, valuesonly_ARG)) {
+			log_err("--valuesonly has no effect with --type list");
+			return EINVALID_CMD_LINE;
+		}
 		/* list type does not require status check */
 	} else if (!strcmp(type, "full")) {
 		tree_spec.type = CFG_DEF_TREE_FULL;
@@ -320,6 +324,9 @@ int dumpconfig(struct cmd_context *cmd, int argc, char **argv)
 	if (arg_is_set(cmd, withspaces_ARG))
 		tree_spec.withspaces = 1;
 
+	if (arg_is_set(cmd, valuesonly_ARG))
+		tree_spec.valuesonly = 1;
+
 	if (cft_check_handle)
 		tree_spec.check_status = cft_check_handle->status;
 

