From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 20 Dec 2010 13:13:01 -0000
Subject: LVM2 lib/activate/activate.c lib/commands/tool ...
Message-ID: <20101220131301.9989.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-12-20 13:12:58

Modified files:
	lib/activate   : activate.c 
	lib/commands   : toolcontext.c 
	lib/config     : config.c config.h 
	lib/device     : dev-cache.c 
	lib/filters    : filter-persistent.c filter-regex.c 
	                 filter-regex.h filter.c 
	lib/format_text: flags.c format-text.c import-export.h 
	                 import_vsn1.c tags.c 
	lib/metadata   : lv_manip.c segtype.h 
	lib/mirror     : mirrored.c 
	lib/mm         : memlock.c 
	lib/replicator : replicator.c 
	lib/striped    : striped.c 
	.              : WHATS_NEW 

Log message:
	Add more strict const pointers around config tree
	
	To have better control were the config tree could be modified use more
	const pointers and very carefully downcast them back to non-const
	(for config tree merge).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.182&r2=1.183
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.111&r2=1.112
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/config.c.diff?cvsroot=lvm2&r1=1.84&r2=1.85
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/config.h.diff?cvsroot=lvm2&r1=1.31&r2=1.32
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-cache.c.diff?cvsroot=lvm2&r1=1.60&r2=1.61
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter-persistent.c.diff?cvsroot=lvm2&r1=1.46&r2=1.47
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter-regex.c.diff?cvsroot=lvm2&r1=1.28&r2=1.29
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter-regex.h.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter.c.diff?cvsroot=lvm2&r1=1.57&r2=1.58
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/flags.c.diff?cvsroot=lvm2&r1=1.42&r2=1.43
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.151&r2=1.152
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import-export.h.diff?cvsroot=lvm2&r1=1.25&r2=1.26
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import_vsn1.c.diff?cvsroot=lvm2&r1=1.78&r2=1.79
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/tags.c.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.239&r2=1.240
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/segtype.h.diff?cvsroot=lvm2&r1=1.32&r2=1.33
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mirror/mirrored.c.diff?cvsroot=lvm2&r1=1.80&r2=1.81
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mm/memlock.c.diff?cvsroot=lvm2&r1=1.32&r2=1.33
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/replicator/replicator.c.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/striped/striped.c.diff?cvsroot=lvm2&r1=1.33&r2=1.34
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1839&r2=1.1840

--- LVM2/lib/activate/activate.c	2010/12/08 20:50:49	1.182
+++ LVM2/lib/activate/activate.c	2010/12/20 13:12:55	1.183
@@ -259,8 +259,8 @@
 				     struct logical_volume *lv)
 {
 	const struct config_node *cn;
-	struct config_value *cv;
-	char *str;
+	const struct config_value *cv;
+	const char *str;
 	char path[PATH_MAX];
 
 	if (!(cn = find_config_tree_node(cmd, "activation/volume_list"))) {
--- LVM2/lib/commands/toolcontext.c	2010/12/10 22:39:54	1.111
+++ LVM2/lib/commands/toolcontext.c	2010/12/20 13:12:56	1.112
@@ -204,7 +204,7 @@
 	const char *read_ahead;
 	struct stat st;
 	const struct config_node *cn;
-	struct config_value *cv;
+	const struct config_value *cv;
 
 	/* umask */
 	cmd->default_settings.umask = find_config_tree_int(cmd,
@@ -332,11 +332,11 @@
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
 
@@ -561,7 +561,7 @@
 static int _init_dev_cache(struct cmd_context *cmd)
 {
 	const struct config_node *cn;
-	struct config_value *cv;
+	const struct config_value *cv;
 
 	init_dev_disable_after_error_count(
 		find_config_tree_int(cmd, "devices/disable_after_error_count",
@@ -793,7 +793,7 @@
 	if (!is_static() &&
 	    (cn = find_config_tree_node(cmd, "global/format_libraries"))) {
 
-		struct config_value *cv;
+		const struct config_value *cv;
 		struct format_type *(*init_format_fn) (struct cmd_context *);
 		void *lib;
 
@@ -959,7 +959,7 @@
 	if (!is_static() &&
 	    (cn = find_config_tree_node(cmd, "global/segment_libraries"))) {
 
-		struct config_value *cv;
+		const struct config_value *cv;
 		int (*init_multiple_segtypes_fn) (struct cmd_context *,
 						  struct segtype_library *);
 
--- LVM2/lib/config/config.c	2010/11/30 22:23:35	1.84
+++ LVM2/lib/config/config.c	2010/12/20 13:12:56	1.85
@@ -420,7 +420,7 @@
 	return 1;
 }
 
-static int _write_value(struct output_line *outline, struct config_value *v)
+static int _write_value(struct output_line *outline, const struct config_value *v)
 {
 	char *buf;
 
@@ -483,7 +483,7 @@
 			line_append("%s}", space);
 		} else {
 			/* it's a value */
-			struct config_value *v = n->v;
+			const struct config_value *v = n->v;
 			line_append("=");
 			if (v->next) {
 				line_append("[");
@@ -526,7 +526,7 @@
 int write_config_file(struct config_tree *cft, const char *file,
 		      int argc, char **argv)
 {
-	struct config_node *cn;
+	const struct config_node *cn;
 	int r = 1;
 	struct output_line outline;
 	outline.fp = NULL;
@@ -669,6 +669,7 @@
 {
 	/* [+-]{0,1}[0-9]+ | [0-9]*\.[0-9]* | ".*" */
 	struct config_value *v = _create_value(p->mem);
+	char *str;
 
 	if (!v)
 		return NULL;
@@ -700,9 +701,10 @@
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
@@ -894,8 +896,8 @@
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
@@ -932,14 +934,14 @@
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
@@ -950,8 +952,8 @@
 	return NULL;
 }
 
-struct config_node *find_config_node(const struct config_node *cn,
-				     const char *path)
+const struct config_node *find_config_node(const struct config_node *cn,
+					   const char *path)
 {
 	return _find_config_node(cn, path);
 }
@@ -1026,7 +1028,7 @@
 	return _find_config_float(cn, NULL, path, fail);
 }
 
-struct config_node *find_config_tree_node(struct cmd_context *cmd,
+const struct config_node *find_config_tree_node(struct cmd_context *cmd,
 					  const char *path)
 {
 	return _find_first_config_node(cmd->cft_override ? cmd->cft_override->root : NULL, cmd->cft->root, path);
@@ -1081,7 +1083,7 @@
 			     const char *path, int fail)
 {
 	const struct config_node *n = _find_first_config_node(cn1, cn2, path);
-	struct config_value *v;
+	const struct config_value *v;
 
 	if (!n)
 		return fail;
@@ -1138,7 +1140,7 @@
 }
 
 int get_config_str(const struct config_node *cn, const char *path,
-		   char **result)
+		   const char **result)
 {
 	const struct config_node *n;
 
@@ -1185,7 +1187,7 @@
 			/* Ignore - we don't have any of these yet */
 			continue;
 		/* Not already present? */
-		if (!(oldn = find_config_node(cn1->child, cn->key))) {
+		if (!(oldn = (struct config_node*)find_config_node(cn1->child, cn->key))) {
 			_insert_config_node(&cn1->child, cn);
 			continue;
 		}
@@ -1205,9 +1207,9 @@
 	}
 }
 
-static int _match_host_tags(struct dm_list *tags, struct config_node *tn)
+static int _match_host_tags(struct dm_list *tags, const struct config_node *tn)
 {
-	struct config_value *tv;
+	const struct config_value *tv;
 	const char *str;
 
 	for (tv = tn->v; tv; tv = tv->next) {
@@ -1229,8 +1231,9 @@
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
@@ -1242,7 +1245,7 @@
 			if (!_match_host_tags(&cmd->tags, tn))
 				continue;
 		}
-		if (!(oldn = find_config_node(root, cn->key))) {
+		if (!(oldn = (struct config_node *)find_config_node(root, cn->key))) {
 			_insert_config_node(&cft->root, cn);
 			/* Remove any "tags" nodes */
 			for (cn2 = cn->child; cn2; cn2 = cn2->sib) {
--- LVM2/lib/config/config.h	2010/09/27 19:09:34	1.31
+++ LVM2/lib/config/config.h	2010/12/20 13:12:56	1.32
@@ -33,13 +33,13 @@
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
@@ -78,8 +78,8 @@
 int merge_config_tree(struct cmd_context *cmd, struct config_tree *cft,
 		      struct config_tree *newdata);
 
-struct config_node *find_config_node(const struct config_node *cn,
-				     const char *path);
+const struct config_node *find_config_node(const struct config_node *cn,
+					   const char *path);
 const char *find_config_str(const struct config_node *cn, const char *path,
 			    const char *fail);
 int find_config_int(const struct config_node *cn, const char *path, int fail);
@@ -89,8 +89,8 @@
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
@@ -112,7 +112,7 @@
 		      uint64_t *result);
 
 int get_config_str(const struct config_node *cn, const char *path,
-		   char **result);
+		   const char **result);
 
 unsigned maybe_config_section(const char *str, unsigned len);
 
--- LVM2/lib/device/dev-cache.c	2010/10/13 15:40:39	1.60
+++ LVM2/lib/device/dev-cache.c	2010/12/20 13:12:56	1.61
@@ -541,7 +541,7 @@
 static int _init_preferred_names(struct cmd_context *cmd)
 {
 	const struct config_node *cn;
-	struct config_value *v;
+	const struct config_value *v;
 	struct dm_pool *scratch = NULL;
 	char **regex;
 	unsigned count = 0;
--- LVM2/lib/filters/filter-persistent.c	2010/09/30 21:06:51	1.46
+++ LVM2/lib/filters/filter-persistent.c	2010/12/20 13:12:56	1.47
@@ -68,7 +68,7 @@
 		       const char *path, void *data)
 {
 	const struct config_node *cn;
-	struct config_value *cv;
+	const struct config_value *cv;
 
 	if (!(cn = find_config_node(cft->root, path))) {
 		log_very_verbose("Couldn't find %s array in '%s'",
--- LVM2/lib/filters/filter-regex.c	2010/09/22 01:36:14	1.28
+++ LVM2/lib/filters/filter-regex.c	2010/12/20 13:12:56	1.29
@@ -87,10 +87,10 @@
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
@@ -188,7 +188,7 @@
 	dm_pool_destroy(rf->mem);
 }
 
-struct dev_filter *regex_filter_create(struct config_value *patterns)
+struct dev_filter *regex_filter_create(const struct config_value *patterns)
 {
 	struct dm_pool *mem = dm_pool_create("filter regex", 10 * 1024);
 	struct rfilter *rf;
--- LVM2/lib/filters/filter-regex.h	2007/08/20 20:55:25	1.3
+++ LVM2/lib/filters/filter-regex.h	2010/12/20 13:12:56	1.4
@@ -27,6 +27,6 @@
  * r|.*|             - reject everything else
  */
 
-struct dev_filter *regex_filter_create(struct config_value *patterns);
+struct dev_filter *regex_filter_create(const struct config_value *patterns);
 
 #endif
--- LVM2/lib/filters/filter.c	2010/09/22 01:36:14	1.57
+++ LVM2/lib/filters/filter.c	2010/12/20 13:12:56	1.58
@@ -185,8 +185,8 @@
 	int line_maj = 0;
 	int blocksection = 0;
 	size_t dev_len = 0;
-	struct config_value *cv;
-	char *name;
+	const struct config_value *cv;
+	const char *name;
 
 
 	if (!*proc) {
--- LVM2/lib/format_text/flags.c	2010/05/21 12:36:31	1.42
+++ LVM2/lib/format_text/flags.c	2010/12/20 13:12:56	1.43
@@ -138,7 +138,7 @@
 	return 1;
 }
 
-int read_flags(uint64_t *status, int type, struct config_value *cv)
+int read_flags(uint64_t *status, int type, const struct config_value *cv)
 {
 	int f;
 	uint64_t s = UINT64_C(0);
--- LVM2/lib/format_text/format-text.c	2010/12/10 22:39:55	1.151
+++ LVM2/lib/format_text/format-text.c	2010/12/20 13:12:56	1.152
@@ -2078,10 +2078,10 @@
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
@@ -2133,8 +2133,8 @@
 struct format_type *create_text_format(struct cmd_context *cmd)
 {
 	struct format_type *fmt;
-	struct config_node *cn;
-	struct config_value *cv;
+	const struct config_node *cn;
+	const struct config_value *cv;
 	struct mda_lists *mda_lists;
 
 	if (!(fmt = dm_malloc(sizeof(*fmt))))
--- LVM2/lib/format_text/import-export.h	2010/09/20 14:23:20	1.25
+++ LVM2/lib/format_text/import-export.h	2010/12/20 13:12:56	1.26
@@ -44,14 +44,14 @@
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
@@ -59,10 +59,10 @@
 struct text_vg_version_ops *text_vg_vsn1_init(void);
 
 int print_flags(uint64_t status, int type, char *buffer, size_t size);
-int read_flags(uint64_t *status, int type, struct config_value *cv);
+int read_flags(uint64_t *status, int type, const struct config_value *cv);
 
 char *alloc_printed_tags(struct dm_list *tags);
-int read_tags(struct dm_pool *mem, struct dm_list *tags, struct config_value *cv);
+int read_tags(struct dm_pool *mem, struct dm_list *tags, const struct config_value *cv);
 
 int text_vg_export_file(struct volume_group *vg, const char *desc, FILE *fp);
 int text_vg_export_raw(struct volume_group *vg, const char *desc, char **buf);
--- LVM2/lib/format_text/import_vsn1.c	2010/11/29 18:35:37	1.78
+++ LVM2/lib/format_text/import_vsn1.c	2010/12/20 13:12:56	1.79
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
@@ -54,10 +54,10 @@
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
@@ -106,9 +106,9 @@
 	return 0;
 }
 
-static int _read_id(struct id *id, struct config_node *cn, const char *path)
+static int _read_id(struct id *id, const struct config_node *cn, const char *path)
 {
-	struct config_value *cv;
+	const struct config_value *cv;
 
 	if (!(cn = find_config_node(cn, path))) {
 		log_error("Couldn't find uuid.");
@@ -129,9 +129,9 @@
 	return 1;
 }
 
-static int _read_flag_config(struct config_node *n, uint64_t *status, int type)
+static int _read_flag_config(const struct config_node *n, uint64_t *status, int type)
 {
-	struct config_node *cn;
+	const struct config_node *cn;
 	*status = 0;
 
 	if (!(cn = find_config_node(n, "status"))) {
@@ -155,8 +155,8 @@
 }
 
 static int _read_pv(struct format_instance *fid, struct dm_pool *mem,
-		    struct volume_group *vg, struct config_node *pvn,
-		    struct config_node *vgn __attribute__((unused)),
+		    struct volume_group *vg, const struct config_node *pvn,
+		    const struct config_node *vgn __attribute__((unused)),
 		    struct dm_hash_table *pv_hash,
 		    struct dm_hash_table *lv_hash __attribute__((unused)),
 		    unsigned *scan_done_once,
@@ -164,7 +164,7 @@
 {
 	struct physical_volume *pv;
 	struct pv_list *pvl;
-	struct config_node *cn;
+	const struct config_node *cn;
 	uint64_t size;
 
 	if (!(pvl = dm_pool_zalloc(mem, sizeof(*pvl))) ||
@@ -293,13 +293,13 @@
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
@@ -380,7 +380,7 @@
 		      uint64_t status)
 {
 	unsigned int s;
-	struct config_value *cv;
+	const struct config_value *cv;
 	struct logical_volume *lv1;
 	struct physical_volume *pv;
 	const char *seg_name = config_parent_name(sn);
@@ -440,10 +440,10 @@
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
@@ -493,15 +493,15 @@
 
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
@@ -522,7 +522,7 @@
 
 	lv->alloc = ALLOC_INHERIT;
 	if ((cn = find_config_node(lvn, "allocation_policy"))) {
-		struct config_value *cv = cn->v;
+		const struct config_value *cv = cn->v;
 		if (!cv || !cv->v.str) {
 			log_error("allocation_policy must be a string.");
 			return 0;
@@ -567,8 +567,8 @@
 
 static int _read_lvsegs(struct format_instance *fid __attribute__((unused)),
 			struct dm_pool *mem,
-			struct volume_group *vg, struct config_node *lvn,
-			struct config_node *vgn __attribute__((unused)),
+			struct volume_group *vg, const struct config_node *lvn,
+			const struct config_node *vgn __attribute__((unused)),
 			struct dm_hash_table *pv_hash,
 			struct dm_hash_table *lv_hash,
 			unsigned *scan_done_once __attribute__((unused)),
@@ -621,13 +621,13 @@
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
 
@@ -641,7 +641,8 @@
 	}
 
 	for (n = n->child; n; n = n->sib) {
-		if (!fn(fid, mem, vg, n, vgn, pv_hash, lv_hash, scan_done_once, report_missing_devices))
+		if (!fn(fid, mem, vg, n, vgn, pv_hash, lv_hash,
+			scan_done_once, report_missing_devices))
 			return_0;
 	}
 
@@ -649,10 +650,10 @@
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
@@ -738,7 +739,7 @@
 
 	vg->alloc = ALLOC_NORMAL;
 	if ((cn = find_config_node(vgn, "allocation_policy"))) {
-		struct config_value *cv = cn->v;
+		const struct config_value *cv = cn->v;
 		if (!cv || !cv->v.str) {
 			log_error("allocation_policy must be a string.");
 			goto bad;
@@ -832,7 +833,7 @@
 }
 
 static void _read_desc(struct dm_pool *mem,
-		       struct config_tree *cft, time_t *when, char **desc)
+		       const struct config_tree *cft, time_t *when, char **desc)
 {
 	const char *d;
 	unsigned int u = 0u;
@@ -848,10 +849,10 @@
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
--- LVM2/lib/format_text/tags.c	2010/09/21 10:42:02	1.9
+++ LVM2/lib/format_text/tags.c	2010/12/20 13:12:56	1.10
@@ -61,7 +61,7 @@
 	return_NULL;
 }
 
-int read_tags(struct dm_pool *mem, struct dm_list *tags, struct config_value *cv)
+int read_tags(struct dm_pool *mem, struct dm_list *tags, const struct config_value *cv)
 {
 	if (cv->type == CFG_EMPTY_ARRAY)
 		return 1;
--- LVM2/lib/metadata/lv_manip.c	2010/12/01 12:56:39	1.239
+++ LVM2/lib/metadata/lv_manip.c	2010/12/20 13:12:56	1.240
@@ -957,8 +957,8 @@
  */
 static int _has_matching_pv_tag(struct pv_match *pvmatch, struct pv_segment *pvseg, struct pv_area *pva)
 {
-	struct config_value *cv;
-	char *str;
+	const struct config_value *cv;
+	const char *str;
 	const char *tag_matched;
 
 	for (cv = pvmatch->cling_tag_list_cn->v; cv; cv = cv->next) {
--- LVM2/lib/metadata/segtype.h	2010/11/30 11:53:32	1.32
+++ LVM2/lib/metadata/segtype.h	2010/12/20 13:12:57	1.33
@@ -70,7 +70,7 @@
 	void (*display) (const struct lv_segment * seg);
 	int (*text_export) (const struct lv_segment * seg,
 			    struct formatter * f);
-	int (*text_import_area_count) (struct config_node * sn,
+	int (*text_import_area_count) (const struct config_node * sn,
 				       uint32_t *area_count);
 	int (*text_import) (struct lv_segment * seg,
 			    const struct config_node * sn,
--- LVM2/lib/mirror/mirrored.c	2010/12/01 13:01:36	1.80
+++ LVM2/lib/mirror/mirrored.c	2010/12/20 13:12:57	1.81
@@ -72,7 +72,7 @@
 	log_print(" ");
 }
 
-static int _mirrored_text_import_area_count(struct config_node *sn, uint32_t *area_count)
+static int _mirrored_text_import_area_count(const struct config_node *sn, uint32_t *area_count)
 {
 	if (!get_config_uint32(sn, "mirror_count", area_count)) {
 		log_error("Couldn't read 'mirror_count' for "
@@ -87,7 +87,7 @@
 			struct dm_hash_table *pv_hash)
 {
 	const struct config_node *cn;
-	char *logname = NULL;
+	const char *logname = NULL;
 
 	if (find_config_node(sn, "extents_moved")) {
 		if (get_config_uint32(sn, "extents_moved",
--- LVM2/lib/mm/memlock.c	2010/10/25 13:00:35	1.32
+++ LVM2/lib/mm/memlock.c	2010/12/20 13:12:57	1.33
@@ -124,7 +124,7 @@
 static int _maps_line(const struct config_node *cn, lvmlock_t lock,
 		      const char* line, size_t* mstats)
 {
-	struct config_value *cv;
+	const struct config_value *cv;
 	long from, to;
 	int pos, i;
 	char fr, fw, fx, fp;
--- LVM2/lib/replicator/replicator.c	2010/11/30 11:53:32	1.3
+++ LVM2/lib/replicator/replicator.c	2010/12/20 13:12:57	1.4
@@ -89,7 +89,7 @@
 static replicator_state_t _get_state(const struct config_node *sn,
 				     const char *path, replicator_state_t def)
 {
-	char *str;
+	const char *str;
 	unsigned i;
 
 	if (get_config_str(sn, path, &str)) {
@@ -118,7 +118,7 @@
 static dm_replicator_mode_t _get_op_mode(const struct config_node *sn,
 					 const char *path, dm_replicator_mode_t def)
 {
-	char *str;
+	const char *str;
 	unsigned i;
 
 	if (get_config_str(sn, path, &str)) {
--- LVM2/lib/striped/striped.c	2010/10/25 13:38:11	1.33
+++ LVM2/lib/striped/striped.c	2010/12/20 13:12:57	1.34
@@ -57,7 +57,7 @@
 	log_print(" ");
 }
 
-static int _striped_text_import_area_count(struct config_node *sn, uint32_t *area_count)
+static int _striped_text_import_area_count(const struct config_node *sn, uint32_t *area_count)
 {
 	if (!get_config_uint32(sn, "stripe_count", area_count)) {
 		log_error("Couldn't read 'stripe_count' for "
--- LVM2/WHATS_NEW	2010/12/17 12:37:50	1.1839
+++ LVM2/WHATS_NEW	2010/12/20 13:12:58	1.1840
@@ -1,5 +1,6 @@
 Version 2.02.79 -  
 ===================================
+  Add const for struct config_node usage.
   Fix NULL pointer check in error path in clvmd do_command(). (2.02.78)
   Fix device.c #include to ensure 64-bit fopen64 use. (2.02.51)
   Create /var/run/lvm directory during clvmd initialisation if missing.


