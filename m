From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 16 Dec 2010 11:36:09 +0100
Subject: [PATCH 01/20] Add more strict const pointers around config tree
In-Reply-To: <cover.1292495195.git.zkabelac@redhat.com>
References: <cover.1292495195.git.zkabelac@redhat.com>
Message-ID: <ddca5dd0f22e47f9106df87fde49c72998bbc5f9.1292495195.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

To have better control were config tree could be modified use more
const pointers and very carefully downcast them back to non-const.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/activate/activate.c         |    4 +-
 lib/commands/toolcontext.c      |   14 ++++----
 lib/config/config.c             |   49 +++++++++++++++-------------
 lib/config/config.h             |   14 ++++----
 lib/device/dev-cache.c          |    2 +-
 lib/filters/filter-persistent.c |    2 +-
 lib/filters/filter-regex.c      |    6 ++--
 lib/filters/filter-regex.h      |    2 +-
 lib/filters/filter.c            |    4 +-
 lib/format_text/flags.c         |    2 +-
 lib/format_text/format-text.c   |    8 ++--
 lib/format_text/import-export.h |   12 +++---
 lib/format_text/import_vsn1.c   |   67 ++++++++++++++++++++-------------------
 lib/format_text/tags.c          |    2 +-
 lib/metadata/lv_manip.c         |    4 +-
 lib/metadata/segtype.h          |    2 +-
 lib/mirror/mirrored.c           |    4 +-
 lib/mm/memlock.c                |    2 +-
 lib/replicator/replicator.c     |    4 +-
 lib/striped/striped.c           |    2 +-
 20 files changed, 105 insertions(+), 101 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 8f4953b..8e7a22f 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -260,8 +260,8 @@ static int _passes_activation_filter(struct cmd_context *cmd,
 				     struct logical_volume *lv)
 {
 	const struct config_node *cn;
-	struct config_value *cv;
-	char *str;
+	const struct config_value *cv;
+	const char *str;
 	char path[PATH_MAX];
 
 	if (!(cn = find_config_tree_node(cmd, "activation/volume_list"))) {
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index c59238d..c5fc057 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -204,7 +204,7 @@ static int _process_config(struct cmd_context *cmd)
 	const char *read_ahead;
 	struct stat st;
 	const struct config_node *cn;
-	struct config_value *cv;
+	const struct config_value *cv;
 
 	/* umask */
 	cmd->default_settings.umask = find_config_tree_int(cmd,
@@ -332,11 +332,11 @@ static int _set_tag(struct cmd_context *cmd, const char *tag)
 	return 1;
 }
 
-static int _check_host_filters(struct cmd_context *cmd, struct config_node *hn,
+static int _check_host_filters(struct cmd_context *cmd, const struct config_node *hn,
 			       int *passes)
 {
-	struct config_node *cn;
-	struct config_value *cv;
+	const struct config_node *cn;
+	const struct config_value *cv;
 
 	*passes = 1;
 
@@ -561,7 +561,7 @@ static void _destroy_tag_configs(struct cmd_context *cmd)
 static int _init_dev_cache(struct cmd_context *cmd)
 {
 	const struct config_node *cn;
-	struct config_value *cv;
+	const struct config_value *cv;
 
 	init_dev_disable_after_error_count(
 		find_config_tree_int(cmd, "devices/disable_after_error_count",
@@ -793,7 +793,7 @@ static int _init_formats(struct cmd_context *cmd)
 	if (!is_static() &&
 	    (cn = find_config_tree_node(cmd, "global/format_libraries"))) {
 
-		struct config_value *cv;
+		const struct config_value *cv;
 		struct format_type *(*init_format_fn) (struct cmd_context *);
 		void *lib;
 
@@ -959,7 +959,7 @@ static int _init_segtypes(struct cmd_context *cmd)
 	if (!is_static() &&
 	    (cn = find_config_tree_node(cmd, "global/segment_libraries"))) {
 
-		struct config_value *cv;
+		const struct config_value *cv;
 		int (*init_multiple_segtypes_fn) (struct cmd_context *,
 						  struct segtype_library *);
 
diff --git a/lib/config/config.c b/lib/config/config.c
index 07c1f1c..6477877 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -420,7 +420,7 @@ static int _line_end(struct output_line *outline)
 	return 1;
 }
 
-static int _write_value(struct output_line *outline, struct config_value *v)
+static int _write_value(struct output_line *outline, const struct config_value *v)
 {
 	char *buf;
 
@@ -483,7 +483,7 @@ static int _write_config(const struct config_node *n, int only_one,
 			line_append("%s}", space);
 		} else {
 			/* it's a value */
-			struct config_value *v = n->v;
+			const struct config_value *v = n->v;
 			line_append("=");
 			if (v->next) {
 				line_append("[");
@@ -526,7 +526,7 @@ int write_config_node(const struct config_node *cn, putline_fn putline, void *ba
 int write_config_file(struct config_tree *cft, const char *file,
 		      int argc, char **argv)
 {
-	struct config_node *cn;
+	const struct config_node *cn;
 	int r = 1;
 	struct output_line outline;
 	outline.fp = NULL;
@@ -669,6 +669,7 @@ static struct config_value *_type(struct parser *p)
 {
 	/* [+-]{0,1}[0-9]+ | [0-9]*\.[0-9]* | ".*" */
 	struct config_value *v = _create_value(p->mem);
+	char *str;
 
 	if (!v)
 		return NULL;
@@ -700,9 +701,10 @@ static struct config_value *_type(struct parser *p)
 		v->type = CFG_STRING;
 
 		p->tb++, p->te--;	/* strip "'s */
-		if (!(v->v.str = _dup_tok(p)))
+		if (!(str = _dup_tok(p)))
 			return_0;
-		unescape_double_quotes(v->v.str);
+		unescape_double_quotes(str);
+		v->v.str = str;
 		p->te++;
 		match(TOK_STRING_ESCAPED);
 		break;
@@ -894,8 +896,8 @@ static char *_dup_tok(struct parser *p)
 /*
  * utility functions
  */
-static struct config_node *_find_config_node(const struct config_node *cn,
-					     const char *path)
+static const struct config_node *_find_config_node(const struct config_node *cn,
+						   const char *path)
 {
 	const char *e;
 	const struct config_node *cn_found = NULL;
@@ -932,14 +934,14 @@ static struct config_node *_find_config_node(const struct config_node *cn,
 		path = e;
 	}
 
-	return (struct config_node *) cn_found;
+	return cn_found;
 }
 
-static struct config_node *_find_first_config_node(const struct config_node *cn1,
-						   const struct config_node *cn2,
-						   const char *path)
+static const struct config_node *_find_first_config_node(const struct config_node *cn1,
+							 const struct config_node *cn2,
+							 const char *path)
 {
-	struct config_node *cn;
+	const struct config_node *cn;
 
 	if (cn1 && (cn = _find_config_node(cn1, path)))
 		return cn;
@@ -950,8 +952,8 @@ static struct config_node *_find_first_config_node(const struct config_node *cn1
 	return NULL;
 }
 
-struct config_node *find_config_node(const struct config_node *cn,
-				     const char *path)
+const struct config_node *find_config_node(const struct config_node *cn,
+					   const char *path)
 {
 	return _find_config_node(cn, path);
 }
@@ -1026,7 +1028,7 @@ float find_config_float(const struct config_node *cn, const char *path,
 	return _find_config_float(cn, NULL, path, fail);
 }
 
-struct config_node *find_config_tree_node(struct cmd_context *cmd,
+const struct config_node *find_config_tree_node(struct cmd_context *cmd,
 					  const char *path)
 {
 	return _find_first_config_node(cmd->cft_override ? cmd->cft_override->root : NULL, cmd->cft->root, path);
@@ -1081,7 +1083,7 @@ static int _find_config_bool(const struct config_node *cn1,
 			     const char *path, int fail)
 {
 	const struct config_node *n = _find_first_config_node(cn1, cn2, path);
-	struct config_value *v;
+	const struct config_value *v;
 
 	if (!n)
 		return fail;
@@ -1138,7 +1140,7 @@ int get_config_uint64(const struct config_node *cn, const char *path,
 }
 
 int get_config_str(const struct config_node *cn, const char *path,
-		   char **result)
+		   const char **result)
 {
 	const struct config_node *n;
 
@@ -1185,7 +1187,7 @@ static void _merge_section(struct config_node *cn1, struct config_node *cn2)
 			/* Ignore - we don't have any of these yet */
 			continue;
 		/* Not already present? */
-		if (!(oldn = find_config_node(cn1->child, cn->key))) {
+		if (!(oldn = (struct config_node*)find_config_node(cn1->child, cn->key))) {
 			_insert_config_node(&cn1->child, cn);
 			continue;
 		}
@@ -1205,9 +1207,9 @@ static void _merge_section(struct config_node *cn1, struct config_node *cn2)
 	}
 }
 
-static int _match_host_tags(struct dm_list *tags, struct config_node *tn)
+static int _match_host_tags(struct dm_list *tags, const struct config_node *tn)
 {
-	struct config_value *tv;
+	const struct config_value *tv;
 	const char *str;
 
 	for (tv = tn->v; tv; tv = tv->next) {
@@ -1229,8 +1231,9 @@ static int _match_host_tags(struct dm_list *tags, struct config_node *tn)
 int merge_config_tree(struct cmd_context *cmd, struct config_tree *cft,
 		      struct config_tree *newdata)
 {
-	struct config_node *root = cft->root;
-	struct config_node *cn, *nextn, *oldn, *tn, *cn2;
+	const struct config_node *root = cft->root;
+	struct config_node *cn, *nextn, *oldn, *cn2;
+	const struct config_node *tn;
 
 	for (cn = newdata->root; cn; cn = nextn) {
 		nextn = cn->sib;
@@ -1242,7 +1245,7 @@ int merge_config_tree(struct cmd_context *cmd, struct config_tree *cft,
 			if (!_match_host_tags(&cmd->tags, tn))
 				continue;
 		}
-		if (!(oldn = find_config_node(root, cn->key))) {
+		if (!(oldn = (struct config_node *)find_config_node(root, cn->key))) {
 			_insert_config_node(&cft->root, cn);
 			/* Remove any "tags" nodes */
 			for (cn2 = cn->child; cn2; cn2 = cn2->sib) {
diff --git a/lib/config/config.h b/lib/config/config.h
index 2d16abd..f70deb0 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -33,13 +33,13 @@ struct config_value {
 	union {
 		int64_t i;
 		float r;
-		char *str;
+		const char *str;
 	} v;
 	struct config_value *next;	/* for arrays */
 };
 
 struct config_node {
-	char *key;
+	const char *key;
 	struct config_node *parent, *sib, *child;
 	struct config_value *v;
 };
@@ -78,8 +78,8 @@ int config_file_changed(struct config_tree *cft);
 int merge_config_tree(struct cmd_context *cmd, struct config_tree *cft,
 		      struct config_tree *newdata);
 
-struct config_node *find_config_node(const struct config_node *cn,
-				     const char *path);
+const struct config_node *find_config_node(const struct config_node *cn,
+					   const char *path);
 const char *find_config_str(const struct config_node *cn, const char *path,
 			    const char *fail);
 int find_config_int(const struct config_node *cn, const char *path, int fail);
@@ -89,8 +89,8 @@ float find_config_float(const struct config_node *cn, const char *path,
 /*
  * These versions check an override tree, if present, first.
  */
-struct config_node *find_config_tree_node(struct cmd_context *cmd,
-					  const char *path);
+const struct config_node *find_config_tree_node(struct cmd_context *cmd,
+						const char *path);
 const char *find_config_tree_str(struct cmd_context *cmd,
 				 const char *path, const char *fail);
 int find_config_tree_int(struct cmd_context *cmd, const char *path,
@@ -112,7 +112,7 @@ int get_config_uint64(const struct config_node *cn, const char *path,
 		      uint64_t *result);
 
 int get_config_str(const struct config_node *cn, const char *path,
-		   char **result);
+		   const char **result);
 
 unsigned maybe_config_section(const char *str, unsigned len);
 
diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index ef93f4d..e4d0a76 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -541,7 +541,7 @@ void dev_cache_scan(int do_scan)
 static int _init_preferred_names(struct cmd_context *cmd)
 {
 	const struct config_node *cn;
-	struct config_value *v;
+	const struct config_value *v;
 	struct dm_pool *scratch = NULL;
 	char **regex;
 	unsigned count = 0;
diff --git a/lib/filters/filter-persistent.c b/lib/filters/filter-persistent.c
index 2ed9400..f3b1e05 100644
--- a/lib/filters/filter-persistent.c
+++ b/lib/filters/filter-persistent.c
@@ -68,7 +68,7 @@ static int _read_array(struct pfilter *pf, struct config_tree *cft,
 		       const char *path, void *data)
 {
 	const struct config_node *cn;
-	struct config_value *cv;
+	const struct config_value *cv;
 
 	if (!(cn = find_config_node(cft->root, path))) {
 		log_very_verbose("Couldn't find %s array in '%s'",
diff --git a/lib/filters/filter-regex.c b/lib/filters/filter-regex.c
index 7bc0a73..d7c079e 100644
--- a/lib/filters/filter-regex.c
+++ b/lib/filters/filter-regex.c
@@ -87,10 +87,10 @@ static int _extract_pattern(struct dm_pool *mem, const char *pat,
 	return 1;
 }
 
-static int _build_matcher(struct rfilter *rf, struct config_value *val)
+static int _build_matcher(struct rfilter *rf, const struct config_value *val)
 {
 	struct dm_pool *scratch;
-	struct config_value *v;
+	const struct config_value *v;
 	char **regex;
 	unsigned count = 0;
 	int i, r = 0;
@@ -188,7 +188,7 @@ static void _regex_destroy(struct dev_filter *f)
 	dm_pool_destroy(rf->mem);
 }
 
-struct dev_filter *regex_filter_create(struct config_value *patterns)
+struct dev_filter *regex_filter_create(const struct config_value *patterns)
 {
 	struct dm_pool *mem = dm_pool_create("filter regex", 10 * 1024);
 	struct rfilter *rf;
diff --git a/lib/filters/filter-regex.h b/lib/filters/filter-regex.h
index 834145f..a009c91 100644
--- a/lib/filters/filter-regex.h
+++ b/lib/filters/filter-regex.h
@@ -27,6 +27,6 @@
  * r|.*|             - reject everything else
  */
 
-struct dev_filter *regex_filter_create(struct config_value *patterns);
+struct dev_filter *regex_filter_create(const struct config_value *patterns);
 
 #endif
diff --git a/lib/filters/filter.c b/lib/filters/filter.c
index d570f79..c623d2a 100644
--- a/lib/filters/filter.c
+++ b/lib/filters/filter.c
@@ -185,8 +185,8 @@ static int _scan_proc_dev(const char *proc, const struct config_node *cn)
 	int line_maj = 0;
 	int blocksection = 0;
 	size_t dev_len = 0;
-	struct config_value *cv;
-	char *name;
+	const struct config_value *cv;
+	const char *name;
 
 
 	if (!*proc) {
diff --git a/lib/format_text/flags.c b/lib/format_text/flags.c
index 994adf2..1d2a611 100644
--- a/lib/format_text/flags.c
+++ b/lib/format_text/flags.c
@@ -138,7 +138,7 @@ int print_flags(uint64_t status, int type, char *buffer, size_t size)
 	return 1;
 }
 
-int read_flags(uint64_t *status, int type, struct config_value *cv)
+int read_flags(uint64_t *status, int type, const struct config_value *cv)
 {
 	int f;
 	uint64_t s = UINT64_C(0);
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 4828e21..caab923 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -2078,10 +2078,10 @@ static int _add_dir(const char *dir, struct dm_list *dir_list)
 }
 
 static int _get_config_disk_area(struct cmd_context *cmd,
-				 struct config_node *cn, struct dm_list *raw_list)
+				 const struct config_node *cn, struct dm_list *raw_list)
 {
 	struct device_area dev_area;
-	char *id_str;
+	const char *id_str;
 	struct id id;
 
 	if (!(cn = cn->child)) {
@@ -2133,8 +2133,8 @@ static int _get_config_disk_area(struct cmd_context *cmd,
 struct format_type *create_text_format(struct cmd_context *cmd)
 {
 	struct format_type *fmt;
-	struct config_node *cn;
-	struct config_value *cv;
+	const struct config_node *cn;
+	const struct config_value *cv;
 	struct mda_lists *mda_lists;
 
 	if (!(fmt = dm_malloc(sizeof(*fmt))))
diff --git a/lib/format_text/import-export.h b/lib/format_text/import-export.h
index e59a3c2..3b56f08 100644
--- a/lib/format_text/import-export.h
+++ b/lib/format_text/import-export.h
@@ -44,14 +44,14 @@ enum {
 };
 
 struct text_vg_version_ops {
-	int (*check_version) (struct config_tree * cf);
+	int (*check_version) (const struct config_tree * cf);
 	struct volume_group *(*read_vg) (struct format_instance * fid,
-					 struct config_tree * cf,
+					 const struct config_tree *cf,
 					 unsigned use_cached_pvs);
-	void (*read_desc) (struct dm_pool * mem, struct config_tree * cf,
+	void (*read_desc) (struct dm_pool * mem, const struct config_tree *cf,
 			   time_t *when, char **desc);
 	const char *(*read_vgname) (const struct format_type *fmt,
-				    struct config_tree *cft,
+				    const struct config_tree *cft,
 				    struct id *vgid, uint64_t *vgstatus,
 				    char **creation_host);
 };
@@ -59,10 +59,10 @@ struct text_vg_version_ops {
 struct text_vg_version_ops *text_vg_vsn1_init(void);
 
 int print_flags(uint64_t status, int type, char *buffer, size_t size);
-int read_flags(uint64_t *status, int type, struct config_value *cv);
+int read_flags(uint64_t *status, int type, const struct config_value *cv);
 
 char *alloc_printed_tags(struct dm_list *tags);
-int read_tags(struct dm_pool *mem, struct dm_list *tags, struct config_value *cv);
+int read_tags(struct dm_pool *mem, struct dm_list *tags, const struct config_value *cv);
 
 int text_vg_export_file(struct volume_group *vg, const char *desc, FILE *fp);
 int text_vg_export_raw(struct volume_group *vg, const char *desc, char **buf);
diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index afeb239..e5e83d4 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -26,8 +26,8 @@
 #include "defaults.h"
 
 typedef int (*section_fn) (struct format_instance * fid, struct dm_pool * mem,
-			   struct volume_group * vg, struct config_node * pvn,
-			   struct config_node * vgn,
+			   struct volume_group * vg, const struct config_node * pvn,
+			   const struct config_node * vgn,
 			   struct dm_hash_table * pv_hash,
 			   struct dm_hash_table * lv_hash,
 			   unsigned *scan_done_once,
@@ -54,10 +54,10 @@ static void _invalid_format(const char *str)
  * Checks that the config file contains vg metadata, and that it
  * we recognise the version number,
  */
-static int _check_version(struct config_tree *cft)
+static int _check_version(const struct config_tree *cft)
 {
-	struct config_node *cn;
-	struct config_value *cv;
+	const struct config_node *cn;
+	const struct config_value *cv;
 
 	/*
 	 * Check the contents field.
@@ -106,9 +106,9 @@ static int _is_converting(struct logical_volume *lv)
 	return 0;
 }
 
-static int _read_id(struct id *id, struct config_node *cn, const char *path)
+static int _read_id(struct id *id, const struct config_node *cn, const char *path)
 {
-	struct config_value *cv;
+	const struct config_value *cv;
 
 	if (!(cn = find_config_node(cn, path))) {
 		log_error("Couldn't find uuid.");
@@ -129,9 +129,9 @@ static int _read_id(struct id *id, struct config_node *cn, const char *path)
 	return 1;
 }
 
-static int _read_flag_config(struct config_node *n, uint64_t *status, int type)
+static int _read_flag_config(const struct config_node *n, uint64_t *status, int type)
 {
-	struct config_node *cn;
+	const struct config_node *cn;
 	*status = 0;
 
 	if (!(cn = find_config_node(n, "status"))) {
@@ -155,8 +155,8 @@ static int _read_flag_config(struct config_node *n, uint64_t *status, int type)
 }
 
 static int _read_pv(struct format_instance *fid, struct dm_pool *mem,
-		    struct volume_group *vg, struct config_node *pvn,
-		    struct config_node *vgn __attribute__((unused)),
+		    struct volume_group *vg, const struct config_node *pvn,
+		    const struct config_node *vgn __attribute__((unused)),
 		    struct dm_hash_table *pv_hash,
 		    struct dm_hash_table *lv_hash __attribute__((unused)),
 		    unsigned *scan_done_once,
@@ -164,7 +164,7 @@ static int _read_pv(struct format_instance *fid, struct dm_pool *mem,
 {
 	struct physical_volume *pv;
 	struct pv_list *pvl;
-	struct config_node *cn;
+	const struct config_node *cn;
 	uint64_t size;
 
 	if (!(pvl = dm_pool_zalloc(mem, sizeof(*pvl))) ||
@@ -293,13 +293,13 @@ static void _insert_segment(struct logical_volume *lv, struct lv_segment *seg)
 }
 
 static int _read_segment(struct dm_pool *mem, struct volume_group *vg,
-			 struct logical_volume *lv, struct config_node *sn,
+			 struct logical_volume *lv, const struct config_node *sn,
 			 struct dm_hash_table *pv_hash)
 {
 	uint32_t area_count = 0u;
 	struct lv_segment *seg;
-	struct config_node *cn, *sn_child = sn->child;
-	struct config_value *cv;
+	const struct config_node *cn, *sn_child = sn->child;
+	const struct config_value *cv;
 	uint32_t start_extent, extent_count;
 	struct segment_type *segtype;
 	const char *segtype_str;
@@ -380,7 +380,7 @@ int text_import_areas(struct lv_segment *seg, const struct config_node *sn,
 		      uint64_t status)
 {
 	unsigned int s;
-	struct config_value *cv;
+	const struct config_value *cv;
 	struct logical_volume *lv1;
 	struct physical_volume *pv;
 	const char *seg_name = config_parent_name(sn);
@@ -440,10 +440,10 @@ int text_import_areas(struct lv_segment *seg, const struct config_node *sn,
 }
 
 static int _read_segments(struct dm_pool *mem, struct volume_group *vg,
-			  struct logical_volume *lv, struct config_node *lvn,
+			  struct logical_volume *lv, const struct config_node *lvn,
 			  struct dm_hash_table *pv_hash)
 {
-	struct config_node *sn;
+	const struct config_node *sn;
 	int count = 0, seg_count;
 
 	for (sn = lvn; sn; sn = sn->sib) {
@@ -493,15 +493,15 @@ static int _read_segments(struct dm_pool *mem, struct volume_group *vg,
 
 static int _read_lvnames(struct format_instance *fid __attribute__((unused)),
 			 struct dm_pool *mem,
-			 struct volume_group *vg, struct config_node *lvn,
-			 struct config_node *vgn __attribute__((unused)),
+			 struct volume_group *vg, const struct config_node *lvn,
+			 const struct config_node *vgn __attribute__((unused)),
 			 struct dm_hash_table *pv_hash __attribute__((unused)),
 			 struct dm_hash_table *lv_hash,
 			 unsigned *scan_done_once __attribute__((unused)),
 			 unsigned report_missing_devices __attribute__((unused)))
 {
 	struct logical_volume *lv;
-	struct config_node *cn;
+	const struct config_node *cn;
 
 	if (!(lv = alloc_lv(mem)))
 		return_0;
@@ -522,7 +522,7 @@ static int _read_lvnames(struct format_instance *fid __attribute__((unused)),
 
 	lv->alloc = ALLOC_INHERIT;
 	if ((cn = find_config_node(lvn, "allocation_policy"))) {
-		struct config_value *cv = cn->v;
+		const struct config_value *cv = cn->v;
 		if (!cv || !cv->v.str) {
 			log_error("allocation_policy must be a string.");
 			return 0;
@@ -567,8 +567,8 @@ static int _read_lvnames(struct format_instance *fid __attribute__((unused)),
 
 static int _read_lvsegs(struct format_instance *fid __attribute__((unused)),
 			struct dm_pool *mem,
-			struct volume_group *vg, struct config_node *lvn,
-			struct config_node *vgn __attribute__((unused)),
+			struct volume_group *vg, const struct config_node *lvn,
+			const struct config_node *vgn __attribute__((unused)),
 			struct dm_hash_table *pv_hash,
 			struct dm_hash_table *lv_hash,
 			unsigned *scan_done_once __attribute__((unused)),
@@ -621,13 +621,13 @@ static int _read_lvsegs(struct format_instance *fid __attribute__((unused)),
 static int _read_sections(struct format_instance *fid,
 			  const char *section, section_fn fn,
 			  struct dm_pool *mem,
-			  struct volume_group *vg, struct config_node *vgn,
+			  struct volume_group *vg, const struct config_node *vgn,
 			  struct dm_hash_table *pv_hash,
 			  struct dm_hash_table *lv_hash,
 			  int optional,
 			  unsigned *scan_done_once)
 {
-	struct config_node *n;
+	const struct config_node *n;
 	/* Only report missing devices when doing a scan */
 	unsigned report_missing_devices = scan_done_once ? !*scan_done_once : 1;
 
@@ -641,7 +641,8 @@ static int _read_sections(struct format_instance *fid,
 	}
 
 	for (n = n->child; n; n = n->sib) {
-		if (!fn(fid, mem, vg, n, vgn, pv_hash, lv_hash, scan_done_once, report_missing_devices))
+		if (!fn(fid, mem, vg, n, vgn, pv_hash, lv_hash,
+			scan_done_once, report_missing_devices))
 			return_0;
 	}
 
@@ -649,10 +650,10 @@ static int _read_sections(struct format_instance *fid,
 }
 
 static struct volume_group *_read_vg(struct format_instance *fid,
-				     struct config_tree *cft,
+				     const struct config_tree *cft,
 				     unsigned use_cached_pvs)
 {
-	struct config_node *vgn, *cn;
+	const struct config_node *vgn, *cn;
 	struct volume_group *vg;
 	struct dm_hash_table *pv_hash = NULL, *lv_hash = NULL;
 	struct dm_pool *mem = dm_pool_create("lvm2 vg_read", VG_MEMPOOL_CHUNK);
@@ -738,7 +739,7 @@ static struct volume_group *_read_vg(struct format_instance *fid,
 
 	vg->alloc = ALLOC_NORMAL;
 	if ((cn = find_config_node(vgn, "allocation_policy"))) {
-		struct config_value *cv = cn->v;
+		const struct config_value *cv = cn->v;
 		if (!cv || !cv->v.str) {
 			log_error("allocation_policy must be a string.");
 			goto bad;
@@ -832,7 +833,7 @@ static struct volume_group *_read_vg(struct format_instance *fid,
 }
 
 static void _read_desc(struct dm_pool *mem,
-		       struct config_tree *cft, time_t *when, char **desc)
+		       const struct config_tree *cft, time_t *when, char **desc)
 {
 	const char *d;
 	unsigned int u = 0u;
@@ -848,10 +849,10 @@ static void _read_desc(struct dm_pool *mem,
 }
 
 static const char *_read_vgname(const struct format_type *fmt,
-				struct config_tree *cft, struct id *vgid,
+				const struct config_tree *cft, struct id *vgid,
 				uint64_t *vgstatus, char **creation_host)
 {
-	struct config_node *vgn;
+	const struct config_node *vgn;
 	struct dm_pool *mem = fmt->cmd->mem;
 	char *vgname;
 	int old_suppress;
diff --git a/lib/format_text/tags.c b/lib/format_text/tags.c
index 1a8c254..76d42db 100644
--- a/lib/format_text/tags.c
+++ b/lib/format_text/tags.c
@@ -61,7 +61,7 @@ bad:
 	return_NULL;
 }
 
-int read_tags(struct dm_pool *mem, struct dm_list *tags, struct config_value *cv)
+int read_tags(struct dm_pool *mem, struct dm_list *tags, const struct config_value *cv)
 {
 	if (cv->type == CFG_EMPTY_ARRAY)
 		return 1;
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 0de4ec3..7ecddb4 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -958,8 +958,8 @@ static int _is_same_pv(struct pv_match *pvmatch __attribute((unused)), struct pv
  */
 static int _has_matching_pv_tag(struct pv_match *pvmatch, struct pv_segment *pvseg, struct pv_area *pva)
 {
-	struct config_value *cv;
-	char *str;
+	const struct config_value *cv;
+	const char *str;
 	const char *tag_matched;
 
 	for (cv = pvmatch->cling_tag_list_cn->v; cv; cv = cv->next) {
diff --git a/lib/metadata/segtype.h b/lib/metadata/segtype.h
index 6ac2f96..8bf16d7 100644
--- a/lib/metadata/segtype.h
+++ b/lib/metadata/segtype.h
@@ -70,7 +70,7 @@ struct segtype_handler {
 	void (*display) (const struct lv_segment * seg);
 	int (*text_export) (const struct lv_segment * seg,
 			    struct formatter * f);
-	int (*text_import_area_count) (struct config_node * sn,
+	int (*text_import_area_count) (const struct config_node * sn,
 				       uint32_t *area_count);
 	int (*text_import) (struct lv_segment * seg,
 			    const struct config_node * sn,
diff --git a/lib/mirror/mirrored.c b/lib/mirror/mirrored.c
index dbb6fc7..a02ccb5 100644
--- a/lib/mirror/mirrored.c
+++ b/lib/mirror/mirrored.c
@@ -72,7 +72,7 @@ static void _mirrored_display(const struct lv_segment *seg)
 	log_print(" ");
 }
 
-static int _mirrored_text_import_area_count(struct config_node *sn, uint32_t *area_count)
+static int _mirrored_text_import_area_count(const struct config_node *sn, uint32_t *area_count)
 {
 	if (!get_config_uint32(sn, "mirror_count", area_count)) {
 		log_error("Couldn't read 'mirror_count' for "
@@ -87,7 +87,7 @@ static int _mirrored_text_import(struct lv_segment *seg, const struct config_nod
 			struct dm_hash_table *pv_hash)
 {
 	const struct config_node *cn;
-	char *logname = NULL;
+	const char *logname = NULL;
 
 	if (find_config_node(sn, "extents_moved")) {
 		if (get_config_uint32(sn, "extents_moved",
diff --git a/lib/mm/memlock.c b/lib/mm/memlock.c
index 1e3065c..062b765 100644
--- a/lib/mm/memlock.c
+++ b/lib/mm/memlock.c
@@ -124,7 +124,7 @@ static void _release_memory(void)
 static int _maps_line(const struct config_node *cn, lvmlock_t lock,
 		      const char* line, size_t* mstats)
 {
-	struct config_value *cv;
+	const struct config_value *cv;
 	long from, to;
 	int pos, i;
 	char fr, fw, fx, fp;
diff --git a/lib/replicator/replicator.c b/lib/replicator/replicator.c
index 1036c0d..1753bca 100644
--- a/lib/replicator/replicator.c
+++ b/lib/replicator/replicator.c
@@ -89,7 +89,7 @@ static const char _state_txt[NUM_REPLICATOR_STATE][8] = {
 static replicator_state_t _get_state(const struct config_node *sn,
 				     const char *path, replicator_state_t def)
 {
-	char *str;
+	const char *str;
 	unsigned i;
 
 	if (get_config_str(sn, path, &str)) {
@@ -118,7 +118,7 @@ static const char _op_mode_txt[NUM_DM_REPLICATOR_MODES][8] = {
 static dm_replicator_mode_t _get_op_mode(const struct config_node *sn,
 					 const char *path, dm_replicator_mode_t def)
 {
-	char *str;
+	const char *str;
 	unsigned i;
 
 	if (get_config_str(sn, path, &str)) {
diff --git a/lib/striped/striped.c b/lib/striped/striped.c
index 44f9774..7ba963b 100644
--- a/lib/striped/striped.c
+++ b/lib/striped/striped.c
@@ -57,7 +57,7 @@ static void _striped_display(const struct lv_segment *seg)
 	log_print(" ");
 }
 
-static int _striped_text_import_area_count(struct config_node *sn, uint32_t *area_count)
+static int _striped_text_import_area_count(const struct config_node *sn, uint32_t *area_count)
 {
 	if (!get_config_uint32(sn, "stripe_count", area_count)) {
 		log_error("Couldn't read 'stripe_count' for "
-- 
1.7.3.3


