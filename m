From: agk@sourceware.org <agk@sourceware.org>
Date: 1 Sep 2011 21:04:15 -0000
Subject: LVM2 ./WHATS_NEW_DM lib/config/config.c libdm/ ...
Message-ID: <20110901210415.8884.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-09-01 21:04:15

Modified files:
	.              : WHATS_NEW_DM 
	lib/config     : config.c 
	libdm          : libdevmapper.h libdm-config.c 

Log message:
	Comments, FIXMEs, name changes.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.496&r2=1.497
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/config.c.diff?cvsroot=lvm2&r1=1.103&r2=1.104
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.147&r2=1.148
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-config.c.diff?cvsroot=lvm2&r1=1.4&r2=1.5

--- LVM2/WHATS_NEW_DM	2011/09/01 10:19:01	1.496
+++ LVM2/WHATS_NEW_DM	2011/09/01 21:04:14	1.497
@@ -1,5 +1,6 @@
 Version 1.02.68 -
 ==================================
+  Add dm_config and string character escaping functions to libdevmapper.
   Mark unreleased memory pools as internal error.
 
 Version 1.02.67 - 19th August 2011
--- LVM2/lib/config/config.c	2011/08/31 15:19:19	1.103
+++ LVM2/lib/config/config.c	2011/09/01 21:04:14	1.104
@@ -120,7 +120,7 @@
 	int r;
 
 	if (!dm_config_check_file(cft, &filename, &info))
-		return 0;
+		return_0;
 
 	if (!dev) {
 		if (!(dev = dev_create_file(filename, NULL, NULL, 1)))
@@ -142,16 +142,17 @@
 	return r;
 }
 
+// FIXME AGK Move to override_config_tree_from_string before next release
 static struct dm_config_tree *_setup_context_tree(struct cmd_context *cmd)
 {
-	struct dm_config_tree *r = cmd->cft_override;
+	struct dm_config_tree *cft = cmd->cft_override;
 
-	if (r)
-		r->cascade = cmd->cft;
+	if (cft)
+		cft->cascade = cmd->cft;
 	else
-		r = cmd->cft;
+		cft = cmd->cft;
 
-	return r;
+	return cft;
 }
 
 const struct dm_config_node *find_config_tree_node(struct cmd_context *cmd,
--- LVM2/libdm/libdevmapper.h	2011/08/31 15:19:20	1.147
+++ LVM2/libdm/libdevmapper.h	2011/09/01 21:04:14	1.148
@@ -1016,10 +1016,7 @@
 const char *dm_basename(const char *path);
 
 /*
- * Count occurences of 'c' in 'str' of length 'size'.
- *
- * Returns:
- *   Number of occurrences of 'c'
+ * Returns number of occurrences of 'c' in 'str' of length 'size'.
  */
 unsigned dm_count_chars(const char *str, size_t len, const int c);
 
@@ -1223,9 +1220,10 @@
 			       const void *sortvalue);
 
 
-/*********************************
- * config file parse/prettyprint
- *********************************/
+/*************************
+ * config file parse/print
+ *************************/
+// FIXME AGK Review this interface before inclusion in a release.
 enum {
 	DM_CFG_STRING,
 	DM_CFG_FLOAT,
@@ -1237,10 +1235,11 @@
 	int type;
 	union {
 		int64_t i;
-		float r;
+		float f;
+		double d;	/* For completeness.  (Unused.) */
 		const char *str;
 	} v;
-	struct dm_config_value *next;	/* for arrays */
+	struct dm_config_value *next;	/* For arrays */
 };
 
 struct dm_config_node {
@@ -1281,8 +1280,7 @@
 int dm_config_find_int(const struct dm_config_node *cn, const char *path, int fail);
 float dm_config_find_float(const struct dm_config_node *cn, const char *path, float fail);
 
-const struct dm_config_node *dm_config_tree_find_node(
-	const struct dm_config_tree *cft, const char *path);
+const struct dm_config_node *dm_config_tree_find_node(const struct dm_config_tree *cft, const char *path);
 const char *dm_config_tree_find_str(const struct dm_config_tree *cft,
 				    const char *path, const char *fail);
 int dm_config_tree_find_int(const struct dm_config_tree *cft,
--- LVM2/libdm/libdm-config.c	2011/09/01 14:02:05	1.4
+++ LVM2/libdm/libdm-config.c	2011/09/01 21:04:14	1.5
@@ -57,7 +57,7 @@
 	off_t st_size;
 	char *filename;
 	int exists;
-	int keep_open;
+	int keep_open; // FIXME AGK Remove this before release
 	void *custom; /* LVM uses this for a device pointer */
 };
 
@@ -135,18 +135,21 @@
 void dm_config_set_custom(struct dm_config_tree *cft, void *custom)
 {
 	struct cs *c = (struct cs *) cft;
+
 	c->custom = custom;
 }
 
 void *dm_config_get_custom(struct dm_config_tree *cft)
 {
 	struct cs *c = (struct cs *) cft;
+
 	return c->custom;
 }
 
 int dm_config_keep_open(struct dm_config_tree *cft)
 {
 	struct cs *c = (struct cs *) cft;
+
 	return c->keep_open;
 }
 
@@ -228,6 +231,7 @@
 time_t dm_config_timestamp(struct dm_config_tree *cft)
 {
 	struct cs *c = (struct cs *) cft;
+
 	return c->timestamp;
 }
 
@@ -345,7 +349,7 @@
 		break;
 
 	case DM_CFG_FLOAT:
-		line_append("%f", v->v.r);
+		line_append("%f", v->v.f);
 		break;
 
 	case DM_CFG_INT:
@@ -442,6 +446,7 @@
 	outline.fp = NULL;
 	outline.putline = NULL;
 
+// FIXME AGK remove the fopen from libdm before release
 	if (!file)
 		file = "stdout";
 	else if (!(outline.fp = fopen(file, "w"))) {
@@ -593,7 +598,7 @@
 
 	case TOK_FLOAT:
 		v->type = DM_CFG_FLOAT;
-		v->v.r = strtod(p->tb, NULL);	/* FIXME: check error */
+		v->v.f = strtod(p->tb, NULL);	/* FIXME: check error */
 		match(TOK_FLOAT);
 		break;
 
@@ -807,8 +812,19 @@
 }
 
 /*
- * utility functions
+ * Utility functions
+ */
+
+/*
+ * node_lookup_fn is either:
+ *   _find_config_node to perform a lookup starting from a given config_node 
+ *   in a config_tree;
+ * or
+ *   _find_first_config_node to find the first config_node in a set of 
+ *   cascaded trees.
  */
+typedef const struct dm_config_node *node_lookup_fn(const void *start, const char *path);
+
 static const struct dm_config_node *_find_config_node(const void *start,
 						      const char *path)
 {
@@ -851,8 +867,6 @@
 	return cn_found;
 }
 
-typedef const struct dm_config_node *_node_lookup_fn(const void *start, const char *path);
-
 static const struct dm_config_node *_find_first_config_node(const void *start, const char *path)
 {
 	const struct dm_config_tree *cft = start;
@@ -867,10 +881,10 @@
 	return NULL;
 }
 
-static const char *_find_config_str(const void *start, _node_lookup_fn find,
+static const char *_find_config_str(const void *start, node_lookup_fn find_fn,
 				    const char *path, const char *fail)
 {
-	const struct dm_config_node *n = find(start, path);
+	const struct dm_config_node *n = find_fn(start, path);
 
 	/* Empty strings are ignored */
 	if ((n && n->v && n->v->type == DM_CFG_STRING) && (*n->v->v.str)) {
@@ -890,7 +904,7 @@
 	return _find_config_str(cn, _find_config_node, path, fail);
 }
 
-static int64_t _find_config_int64(const void *start, _node_lookup_fn find,
+static int64_t _find_config_int64(const void *start, node_lookup_fn find,
 				  const char *path, int64_t fail)
 {
 	const struct dm_config_node *n = find(start, path);
@@ -905,14 +919,14 @@
 	return fail;
 }
 
-static float _find_config_float(const void *start, _node_lookup_fn find,
+static float _find_config_float(const void *start, node_lookup_fn find,
 				const char *path, float fail)
 {
 	const struct dm_config_node *n = find(start, path);
 
 	if (n && n->v && n->v->type == DM_CFG_FLOAT) {
-		log_very_verbose("Setting %s to %f", path, n->v->v.r);
-		return n->v->v.r;
+		log_very_verbose("Setting %s to %f", path, n->v->v.f);
+		return n->v->v.f;
 	}
 
 	log_very_verbose("%s not found in config: defaulting to %f",
@@ -947,7 +961,7 @@
 	return fail;
 }
 
-static int _find_config_bool(const void *start, _node_lookup_fn find,
+static int _find_config_bool(const void *start, node_lookup_fn find,
 			     const char *path, int fail)
 {
 	const struct dm_config_node *n = find(start, path);


