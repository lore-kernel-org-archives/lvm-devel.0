From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed,  6 Mar 2013 11:15:44 +0000 (UTC)
Subject: master - dumpconfig: add --withcomments and --withversions switch
Message-ID: <20130306111544.7E148A0C29@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=088d88cfe27ba6f5f78812af778cde54d4aed9c1
Commit:        088d88cfe27ba6f5f78812af778cde54d4aed9c1
Parent:        e29cd366a24859195f92b874d4bf260a3cc63bc2
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Mar 5 18:21:13 2013 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Mar 6 10:46:36 2013 +0100

dumpconfig: add --withcomments and --withversions switch

lvm dumpconfig [--withcomments] [--withversions]

The --withcomments causes the comments to appear on output before each
config node (if they were defined in config_settings.h).

The --withversions causes a one line extra comment to appear on output
before each config node with the version information in which the
configuration setting first appeared.
---
 lib/config/config.c |   83 +++++++++++++++++++++++++++++++++++++++++++-------
 lib/config/config.h |    4 ++-
 tools/args.h        |    2 +
 tools/commands.h    |    5 ++-
 tools/dumpconfig.c  |    4 ++-
 5 files changed, 83 insertions(+), 15 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index 5a51a29..e8e0379 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -808,36 +808,95 @@ int merge_config_tree(struct cmd_context *cmd, struct dm_config_tree *cft,
 	return 1;
 }
 
-static int _putline_fn(const char *line, void *baton) {
-	FILE *fp = baton;
-	fprintf(fp, "%s\n", line);
-	return 1;
+struct out_baton {
+	FILE *fp;
+	int withcomment;
+	int withversion;
 };
 
-int config_write(struct dm_config_tree *cft, const char *file,
-		 int argc, char **argv)
+static int _out_prefix_fn(const struct dm_config_node *cn, const char *line, void *baton)
+{
+	struct out_baton *out = baton;
+	struct cfg_def_item *cfg_def;
+	char version[9]; /* 8+1 chars for max version of 7.15.511 */
+	const char *path;
+	const char *node_type_name = cn->v ? "option" : "section";
+
+	if (cn->id < 0)
+		return 1;
+
+	if (!cn->id) {
+		log_error(INTERNAL_ERROR "Configuration node %s has invalid id.", cn->key);
+		return 0;
+	}
+
+	cfg_def = cfg_def_get_item_p(cn->id);
+
+	if (out->withcomment) {
+		path = cfg_def_get_path(cfg_def);
+		fprintf(out->fp, "%s# Configuration %s %s.\n", line, node_type_name, path);
+
+		if (cfg_def->comment)
+			fprintf(out->fp, "%s# %s\n", line, cfg_def->comment);
+	}
+
+	if (out->withversion) {
+		if (dm_snprintf(version, 9, "%u.%u.%u",
+				(cfg_def->since_version & 0xE000) >> 13,
+				(cfg_def->since_version & 0x1E00) >> 9,
+				(cfg_def->since_version & 0x1FF)) == -1) {
+			log_error("_out_prefix_fn: couldn't create version string");
+			return 0;
+		}
+		fprintf(out->fp, "%s# Since version %s.\n", line, version);
+	}
+
+	return 1;
+}
+
+static int _out_line_fn(const struct dm_config_node *cn, const char *line, void *baton)
+{
+	struct out_baton *out = baton;
+	fprintf(out->fp, "%s\n", line);
+	return 1;
+}
+
+static int _out_suffix_fn(const struct dm_config_node *cn, const char *line, void *baton)
 {
+	return 1;
+}
+
+int config_write(struct dm_config_tree *cft,
+		 int withcomment, int withversion,
+		 const char *file, int argc, char **argv)
+{
+	struct out_baton baton = {0, 0, 0};
 	const struct dm_config_node *cn;
+	const struct dm_config_node_out_spec out_spec = {.prefix_fn = _out_prefix_fn,
+							 .line_fn = _out_line_fn,
+							 .suffix_fn = _out_suffix_fn};
 	int r = 1;
-	FILE *fp = NULL;
+
+	baton.withcomment = withcomment;
+	baton.withversion = withversion;
 
 	if (!file) {
-		fp = stdout;
+		baton.fp = stdout;
 		file = "stdout";
-	} else if (!(fp = fopen(file, "w"))) {
+	} else if (!(baton.fp = fopen(file, "w"))) {
 		log_sys_error("open", file);
 		return 0;
 	}
 
 	log_verbose("Dumping configuration to %s", file);
 	if (!argc) {
-		if (!dm_config_write_node(cft->root, _putline_fn, fp)) {
+		if (!dm_config_write_node_out(cft->root, &out_spec, &baton)) {
 			log_error("Failure while writing to %s", file);
 			r = 0;
 		}
 	} else while (argc--) {
 		if ((cn = dm_config_find_node(cft->root, *argv))) {
-			if (!dm_config_write_one_node(cn, _putline_fn, fp)) {
+			if (!dm_config_write_one_node_out(cn, &out_spec, &baton)) {
 				log_error("Failure while writing to %s", file);
 				r = 0;
 			}
@@ -848,7 +907,7 @@ int config_write(struct dm_config_tree *cft, const char *file,
 		argv++;
 	}
 
-	if (fp && dm_fclose(fp)) {
+	if (baton.fp && dm_fclose(baton.fp)) {
 		stack;
 		r = 0;
 	}
diff --git a/lib/config/config.h b/lib/config/config.h
index fb4993a..7e40420 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -120,7 +120,9 @@ int config_file_read_fd(struct dm_config_tree *cft, struct device *dev,
 			off_t offset, size_t size, off_t offset2, size_t size2,
 			checksum_fn_t checksum_fn, uint32_t checksum);
 int config_file_read(struct dm_config_tree *cft);
-int config_write(struct dm_config_tree *cft, const char *file, int argc, char **argv);
+int config_write(struct dm_config_tree *cft,
+		 int withcomment, int withversion,
+		 const char *file, int argc, char **argv);
 struct dm_config_tree *config_def_create_tree(struct config_def_tree_spec *spec);
 void config_file_destroy(struct dm_config_tree *cft);
 
diff --git a/tools/args.h b/tools/args.h
index 8d9abd5..1e85096 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -80,6 +80,8 @@ arg(stripes_long_ARG, '\0', "stripes", int_arg, 0)
 arg(sysinit_ARG, '\0', "sysinit", NULL, 0)
 arg(thinpool_ARG, '\0', "thinpool", string_arg, 0)
 arg(configtype_ARG, '\0', "type", string_arg, 0)
+arg(withcomments_ARG, '\0', "withcomments", NULL, 0)
+arg(withversions_ARG, '\0', "withversions", NULL, 0)
 arg(atversion_ARG, '\0', "atversion", string_arg, 0)
 arg(validate_ARG, '\0', "validate", NULL, 0)
 
diff --git a/tools/commands.h b/tools/commands.h
index dc245b9..36928c0 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -34,10 +34,13 @@ xx(dumpconfig,
    "dumpconfig\n"
    "\t[-f|--file filename] \n"
    "\t[--type {current|default|missing|new} \n"
+   "\t[--withcomments] \n"
+   "\t[--withversions] \n"
    "\t[--atversion version]] \n"
    "\t[--validate]\n"
    "\t[ConfigurationNode...]\n",
-   file_ARG, configtype_ARG, atversion_ARG, validate_ARG)
+   file_ARG, configtype_ARG, withcomments_ARG, atversion_ARG,
+   withversions_ARG, validate_ARG)
 
 xx(formats,
    "List available metadata formats",
diff --git a/tools/dumpconfig.c b/tools/dumpconfig.c
index ac90a95..384f52d 100644
--- a/tools/dumpconfig.c
+++ b/tools/dumpconfig.c
@@ -89,7 +89,9 @@ int dumpconfig(struct cmd_context *cmd, int argc, char **argv)
 		cft = config_def_create_tree(&tree_spec);
 	}
 
-	if (!config_write(cft, file, argc, argv)) {
+	if (!config_write(cft, arg_count(cmd, withcomments_ARG),
+			  arg_count(cmd, withversions_ARG),
+			  file, argc, argv)) {
 		stack;
 		r = ECMD_FAILED;
 	}


