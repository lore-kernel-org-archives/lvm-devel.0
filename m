From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed,  6 Mar 2013 11:15:41 +0000 (UTC)
Subject: master - config: add support for enhanced config node output
Message-ID: <20130306111541.EB708A0C29@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e29cd366a24859195f92b874d4bf260a3cc63bc2
Commit:        e29cd366a24859195f92b874d4bf260a3cc63bc2
Parent:        34350963d1b02d54205b1bdaa0c7778f4c5601fe
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Mar 5 18:02:13 2013 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Mar 6 10:46:36 2013 +0100

config: add support for enhanced config node output

There's a possibility to interconnect the dm_config_node with an
ID, which in our case is used to reference the configuration
definition ID from config_settings.h. So simply interconnecting
struct dm_config_node with struct cfg_def_item.

This patch also adds support for enhanced config node output besides
existing "output line by line". This patch adds a possibility to
register a callback that gets called *before* the config node is
processed line by line (for example to include any headers on output)
and *after* the config node is processed line by line (to include any
footers on output). Also, it adds the config node reference itself
as the callback arg in addition to have a possibility to extract more
information from the config node itself if needed when processing the
output callback (e.g. the key name, the id, or whether this is a
section or a value etc...).

If the config node from lvm.conf/--config tree is recognized and valid,
it's always coupled with the config node definition ID from
config_settings.h:

 struct dm_config_node {
   int id;
   const char *key;
   struct dm_config_node *parent, *sib, *child;
   struct dm_config_value *v;
 }

For example if the dm_config_node *cn holds "devices/dev" configuration,
then the cn->id holds "devices_dev_CFG" ID from config_settings.h, -1 if
not found in config_settings.h and 0 if matching has not yet been done.

To support the enhanced config node output, a new structure has been
defined in libdevmapper to register it:

  struct dm_config_node_out_spec {
    dm_config_node_out_fn prefix_fn; /* called before processing config node lines */
    dm_config_node_out_fn line_fn; /* called for each config node line */
    dm_config_node_out_fn suffix_fn; /* called after processing config node lines */
  };

Where dm_config_node_out_fn is:

  typedef int (*dm_config_node_out_fn)(const struct dm_config_node *cn, const char *line, void *baton);

(so in comparison to existing callbacks for config node output, it has
an extra dm_config_node *cn arg in addition)

This patch also adds these functions to libdevmapper:
  - dm_config_write_node_out
  - dm_config_write_one_node_out

...which have exactly the same functionality as their counterparts
without the "out" suffix. The "*_out" functions adds the extra hooks
for enhanced config output (prefix_fn and suffix_fn mentioned above).

One can still use the old interface for config node output, this is
just an enhancement for those who'd like to modify the output more
extensively.
---
 lib/config/config.c  |    6 +++
 libdm/libdevmapper.h |   17 +++++++++
 libdm/libdm-config.c |   91 +++++++++++++++++++++++++++++++++-----------------
 3 files changed, 83 insertions(+), 31 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index a02f478..5a51a29 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -472,6 +472,7 @@ static int _config_def_check_node(const char *vp, char *pvp, char *rp, char *prp
 		if (cn->v) {
 			log_warn_suppress(suppress_messages,
 				"Configuration setting \"%s\" unknown.", rp);
+			cn->id = -1;
 			return 0;
 		}
 
@@ -482,11 +483,14 @@ static int _config_def_check_node(const char *vp, char *pvp, char *rp, char *prp
 		if (!(def = (cfg_def_item_t *) dm_hash_lookup(ht, vp))) {
 			log_warn_suppress(suppress_messages,
 				"Configuration section \"%s\" unknown.", rp);
+			cn->id = -1;
 			return 0;
 		}
 	}
 
 	def->flags |= CFG_USED;
+	cn->id = def->id;
+
 	if (!_config_def_check_node_value(rp, cn->v, def, suppress_messages))
 	return 0;
 
@@ -962,6 +966,8 @@ static struct dm_config_node *_add_def_node(struct dm_config_tree *cft,
 		return NULL;
 	}
 
+	cn->id = def->id;
+
 	if (!(def->type & CFG_TYPE_ARRAY)) {
 		switch (def->type) {
 			case CFG_TYPE_SECTION:
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 8c349c5..0460afa 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -1496,6 +1496,7 @@ struct dm_config_value {
 };
 
 struct dm_config_node {
+	int id;
 	const char *key;
 	struct dm_config_node *parent, *sib, *child;
 	struct dm_config_value *v;
@@ -1528,11 +1529,27 @@ struct dm_config_tree *dm_config_remove_cascaded_tree(struct dm_config_tree *cft
 
 void dm_config_destroy(struct dm_config_tree *cft);
 
+/* Simple output line by line. */
 typedef int (*dm_putline_fn)(const char *line, void *baton);
+/* More advaced output with config node reference. */
+typedef int (*dm_config_node_out_fn)(const struct dm_config_node *cn, const char *line, void *baton);
+
+/*
+ * Specification for advanced config node output.
+ */
+struct dm_config_node_out_spec {
+	dm_config_node_out_fn prefix_fn; /* called before processing config node lines */
+	dm_config_node_out_fn line_fn; /* called for each config node line */
+	dm_config_node_out_fn suffix_fn; /* called after processing config node lines */
+};
+
 /* Write the node and any subsequent siblings it has. */
 int dm_config_write_node(const struct dm_config_node *cn, dm_putline_fn putline, void *baton);
+int dm_config_write_node_out(const struct dm_config_node *cn, const struct dm_config_node_out_spec *out_spec, void *baton);
+
 /* Write given node only without subsequent siblings. */
 int dm_config_write_one_node(const struct dm_config_node *cn, dm_putline_fn putline, void *baton);
+int dm_config_write_one_node_out(const struct dm_config_node *cn, const struct dm_config_node_out_spec *out_spec, void *baton);
 
 struct dm_config_node *dm_config_find_node(const struct dm_config_node *cn, const char *path);
 int dm_config_has_node(const struct dm_config_node *cn, const char *path);
diff --git a/libdm/libdm-config.c b/libdm/libdm-config.c
index 4705a1c..368f9e3 100644
--- a/libdm/libdm-config.c
+++ b/libdm/libdm-config.c
@@ -50,10 +50,11 @@ struct parser {
 	struct dm_pool *mem;
 };
 
-struct output_line {
+struct config_output {
 	struct dm_pool *mem;
 	dm_putline_fn putline;
-	void *putline_baton;
+	const struct dm_config_node_out_spec *spec;
+	void *baton;
 };
 
 static void _get_token(struct parser *p, int tok_prev);
@@ -189,9 +190,9 @@ struct dm_config_tree *dm_config_from_string(const char *config_settings)
 	return cft;
 }
 
-static int _line_start(struct output_line *outline)
+static int _line_start(struct config_output *out)
 {
-	if (!dm_pool_begin_object(outline->mem, 128)) {
+	if (!dm_pool_begin_object(out->mem, 128)) {
 		log_error("dm_pool_begin_object failed for config line");
 		return 0;
 	}
@@ -200,7 +201,7 @@ static int _line_start(struct output_line *outline)
 }
 
 __attribute__ ((format(printf, 2, 3)))
-static int _line_append(struct output_line *outline, const char *fmt, ...)
+static int _line_append(struct config_output *out, const char *fmt, ...)
 {
 	char buf[4096];
 	va_list ap;
@@ -215,7 +216,7 @@ static int _line_append(struct output_line *outline, const char *fmt, ...)
 		return 0;
 	}
 
-	if (!dm_pool_grow_object(outline->mem, &buf[0], strlen(buf))) {
+	if (!dm_pool_grow_object(out->mem, &buf[0], strlen(buf))) {
 		log_error("dm_pool_grow_object failed for config line");
 		return 0;
 	}
@@ -223,28 +224,32 @@ static int _line_append(struct output_line *outline, const char *fmt, ...)
 	return 1;
 }
 
-#define line_append(args...) do {if (!_line_append(outline, args)) {return_0;}} while (0)
+#define line_append(args...) do {if (!_line_append(out, args)) {return_0;}} while (0)
 
-static int _line_end(struct output_line *outline)
+static int _line_end(const struct dm_config_node *cn, struct config_output *out)
 {
 	const char *line;
 
-	if (!dm_pool_grow_object(outline->mem, "\0", 1)) {
+	if (!dm_pool_grow_object(out->mem, "\0", 1)) {
 		log_error("dm_pool_grow_object failed for config line");
 		return 0;
 	}
 
-	line = dm_pool_end_object(outline->mem);
+	line = dm_pool_end_object(out->mem);
 
-	if (!outline->putline)
+	if (!out->putline && !out->spec)
 		return 0;
 
-	outline->putline(line, outline->putline_baton);
+	if (out->putline)
+		out->putline(line, out->baton);
+
+	if (out->spec && out->spec->line_fn)
+		out->spec->line_fn(cn, line, out->baton);
 
 	return 1;
 }
 
-static int _write_value(struct output_line *outline, const struct dm_config_value *v)
+static int _write_value(struct config_output *out, const struct dm_config_value *v)
 {
 	char *buf;
 
@@ -279,7 +284,7 @@ static int _write_value(struct output_line *outline, const struct dm_config_valu
 }
 
 static int _write_config(const struct dm_config_node *n, int only_one,
-			 struct output_line *outline, int level)
+			 struct config_output *out, int level)
 {
 	char space[MAX_INDENT + 1];
 	int l = (level < MAX_INDENT) ? level : MAX_INDENT;
@@ -293,16 +298,19 @@ static int _write_config(const struct dm_config_node *n, int only_one,
 	space[i] = '\0';
 
 	do {
-		if (!_line_start(outline))
+		if (out->spec && out->spec->prefix_fn)
+			out->spec->prefix_fn(n, space, out->baton);
+
+		if (!_line_start(out))
 			return_0;
 		line_append("%s%s", space, n->key);
 		if (!n->v) {
 			/* it's a sub section */
 			line_append(" {");
-			if (!_line_end(outline))
+			if (!_line_end(n, out))
 				return_0;
-			_write_config(n->child, 0, outline, level + 1);
-			if (!_line_start(outline))
+			_write_config(n->child, 0, out, level + 1);
+			if (!_line_start(out))
 				return_0;
 			line_append("%s}", space);
 		} else {
@@ -312,7 +320,7 @@ static int _write_config(const struct dm_config_node *n, int only_one,
 			if (v->next) {
 				line_append("[");
 				while (v && v->type != DM_CFG_EMPTY_ARRAY) {
-					if (!_write_value(outline, v))
+					if (!_write_value(out, v))
 						return_0;
 					v = v->next;
 					if (v && v->type != DM_CFG_EMPTY_ARRAY)
@@ -320,11 +328,15 @@ static int _write_config(const struct dm_config_node *n, int only_one,
 				}
 				line_append("]");
 			} else
-				if (!_write_value(outline, v))
+				if (!_write_value(out, v))
 					return_0;
 		}
-		if (!_line_end(outline))
+		if (!_line_end(n, out))
 			return_0;
+
+		if (out->spec && out->spec->suffix_fn)
+			out->spec->suffix_fn(n, space, out->baton);
+
 		n = n->sib;
 	} while (n && !only_one);
 	/* FIXME: add error checking */
@@ -332,29 +344,46 @@ static int _write_config(const struct dm_config_node *n, int only_one,
 }
 
 static int _write_node(const struct dm_config_node *cn, int only_one,
-		       dm_putline_fn putline, void *baton)
+		       dm_putline_fn putline,
+		       const struct dm_config_node_out_spec *out_spec,
+		       void *baton)
 {
-	struct output_line outline;
-	if (!(outline.mem = dm_pool_create("config_line", 1024)))
+	struct config_output out;
+	if (!(out.mem = dm_pool_create("config_output", 1024)))
 		return_0;
-	outline.putline = putline;
-	outline.putline_baton = baton;
-	if (!_write_config(cn, only_one, &outline, 0)) {
-		dm_pool_destroy(outline.mem);
+	out.putline = putline;
+	out.spec = out_spec;
+	out.baton = baton;
+	if (!_write_config(cn, only_one, &out, 0)) {
+		dm_pool_destroy(out.mem);
 		return_0;
 	}
-	dm_pool_destroy(outline.mem);
+	dm_pool_destroy(out.mem);
 	return 1;
 }
 
 int dm_config_write_one_node(const struct dm_config_node *cn, dm_putline_fn putline, void *baton)
 {
-	return _write_node(cn, 1, putline, baton);
+	return _write_node(cn, 1, putline, NULL, baton);
 }
 
 int dm_config_write_node(const struct dm_config_node *cn, dm_putline_fn putline, void *baton)
 {
-	return _write_node(cn, 0, putline, baton);
+	return _write_node(cn, 0, putline, NULL, baton);
+}
+
+int dm_config_write_one_node_out(const struct dm_config_node *cn,
+				 const struct dm_config_node_out_spec *out_spec,
+				 void *baton)
+{
+	return _write_node(cn, 1, NULL, out_spec, baton);
+}
+
+int dm_config_write_node_out(const struct dm_config_node *cn,
+			     const struct dm_config_node_out_spec *out_spec,
+			     void *baton)
+{
+	return _write_node(cn, 0, NULL, out_spec, baton);
 }
 
 /*


