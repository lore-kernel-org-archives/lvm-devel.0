From: Milan Broz <mbroz@redhat.com>
Date: Wed, 01 Jul 2009 18:08:42 +0200
Subject: [PATCH] Fix confusing metadta syntax error messages.
Message-ID: <4A4B8A0A.9080205@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Fix confusing metadta syntax error messages.

If there is syntax error in metadata, it now prints messages
like:
  Couldn't read 'start_extent' for segment 'extent_count'.
  Couldn't read all logical volumes for volume group vg_test.

The segment specification is wrong and confusing.

To provide better information to user, we should print at least
proper section name or, if possible, even LV section where is
the syntax problem.

Patch fixes it by introducing "parent" member in config_node which
points to parent section and config_node_name function, which
provides pointer to node section name.

Also it adds several LV refernces where possible.

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/config/config.c           |    9 +++++++++
 lib/config/config.h           |    4 +++-
 lib/format_text/import_vsn1.c |   34 +++++++++++-----------------------
 lib/mirror/mirrored.c         |   23 ++++++++++++++---------
 lib/striped/striped.c         |   10 +++++-----
 5 files changed, 42 insertions(+), 38 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index 224f2ce..a14beac 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -546,6 +546,7 @@ static struct config_node *_file(struct parser *p)
 			root = n;
 		else
 			l->sib = n;
+		n->parent = root;
 		l = n;
 	}
 	return root;
@@ -573,6 +574,7 @@ static struct config_node *_section(struct parser *p)
 				root->child = n;
 			else
 				l->sib = n;
+			n->parent = root;
 			l = n;
 		}
 		match(TOK_SECTION_E);
@@ -1251,6 +1253,13 @@ static unsigned _count_tokens(const char *str, unsigned len, int type)
 	return count_chars(str, len, c);
 }
 
+const char *config_node_name(const struct config_node *n)
+{
+	if (n->parent)
+		return n->parent->key;
+
+	return n->key;
+}
 /*
  * Heuristic function to make a quick guess as to whether a text
  * region probably contains a valid config "section".  (Useful for
diff --git a/lib/config/config.h b/lib/config/config.h
index 57f6c32..7da4600 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -40,7 +40,7 @@ struct config_value {
 
 struct config_node {
 	char *key;
-	struct config_node *sib, *child;
+	struct config_node *parent, *sib, *child;
 	struct config_value *v;
 };
 
@@ -110,4 +110,6 @@ int get_config_str(const struct config_node *cn, const char *path,
 
 unsigned maybe_config_section(const char *str, unsigned len);
 
+const char *config_node_name(const struct config_node *n);
+
 #endif
diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index d8d8fcb..35253e5 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -305,14 +305,14 @@ static int _read_segment(struct dm_pool *mem, struct volume_group *vg,
 	}
 
 	if (!_read_int32(sn, "start_extent", &start_extent)) {
-		log_error("Couldn't read 'start_extent' for segment '%s'.",
-			  sn->key);
+		log_error("Couldn't read 'start_extent' for segment '%s' "
+			  "of logical volume %s.", config_node_name(sn), lv->name);
 		return 0;
 	}
 
 	if (!_read_int32(sn, "extent_count", &extent_count)) {
-		log_error("Couldn't read 'extent_count' for segment '%s'.",
-			  sn->key);
+		log_error("Couldn't read 'extent_count' for segment '%s' "
+			  "of logical volume %s.", config_node_name(sn), lv->name);
 		return 0;
 	}
 
@@ -377,32 +377,19 @@ int text_import_areas(struct lv_segment *seg, const struct config_node *sn,
 	unsigned int s;
 	struct config_value *cv;
 	struct logical_volume *lv1;
-	const char *seg_name = sn->key;
+	struct physical_volume *pv;
+	const char *seg_name = config_node_name(sn);
 
 	if (!seg->area_count) {
-		log_error("Zero areas not allowed for segment '%s'", sn->key);
+		log_error("Zero areas not allowed for segment '%s'", seg_name);
 		return 0;
 	}
 
 	for (cv = cn->v, s = 0; cv && s < seg->area_count; s++, cv = cv->next) {
 
 		/* first we read the pv */
-		const char *bad = "Badly formed areas array for "
-		    "segment '%s'.";
-		struct physical_volume *pv;
-
-		if (cv->type != CFG_STRING) {
-			log_error(bad, sn->key);
-			return 0;
-		}
-
-		if (!cv->next) {
-			log_error(bad, sn->key);
-			return 0;
-		}
-
-		if (cv->next->type != CFG_INT) {
-			log_error(bad, sn->key);
+		if (cv->type != CFG_STRING || !cv->next || cv->next->type != CFG_INT) {
+			log_error("Badly formed areas array for segment '%s'.", seg_name);
 			return 0;
 		}
 
@@ -463,7 +450,8 @@ static int _read_segments(struct dm_pool *mem, struct volume_group *vg,
 	}
 
 	if (!_read_int32(lvn, "segment_count", &seg_count)) {
-		log_error("Couldn't read segment count for logical volume.");
+		log_error("Couldn't read segment count for logical volume %s.",
+			  lv->name);
 		return 0;
 	}
 
diff --git a/lib/mirror/mirrored.c b/lib/mirror/mirrored.c
index b243ebb..4d0fc63 100644
--- a/lib/mirror/mirrored.c
+++ b/lib/mirror/mirrored.c
@@ -78,7 +78,7 @@ static int _mirrored_text_import_area_count(struct config_node *sn, uint32_t *ar
 {
 	if (!get_config_uint32(sn, "mirror_count", area_count)) {
 		log_error("Couldn't read 'mirror_count' for "
-			  "segment '%s'.", sn->key);
+			  "segment '%s'.", config_node_name(sn));
 		return 0;
 	}
 
@@ -97,7 +97,8 @@ static int _mirrored_text_import(struct lv_segment *seg, const struct config_nod
 			seg->status |= PVMOVE;
 		else {
 			log_error("Couldn't read 'extents_moved' for "
-				  "segment '%s'.", sn->key);
+				  "segment %s of logical volume %s.",
+				  config_node_name(sn), seg->lv->name);
 			return 0;
 		}
 	}
@@ -106,7 +107,8 @@ static int _mirrored_text_import(struct lv_segment *seg, const struct config_nod
 		if (!get_config_uint32(sn, "region_size",
 				      &seg->region_size)) {
 			log_error("Couldn't read 'region_size' for "
-				  "segment '%s'.", sn->key);
+				  "segment %s of logical volume %s.",
+				  config_node_name(sn), seg->lv->name);
 			return 0;
 		}
 	}
@@ -118,22 +120,25 @@ static int _mirrored_text_import(struct lv_segment *seg, const struct config_nod
 		}
 		logname = cn->v->v.str;
 		if (!(seg->log_lv = find_lv(seg->lv->vg, logname))) {
-			log_error("Unrecognised mirror log in segment %s.",
-				  sn->key);
+			log_error("Unrecognised mirror log in "
+				  "segment %s of logical volume %s.",
+				  config_node_name(sn), seg->lv->name);
 			return 0;
 		}
 		seg->log_lv->status |= MIRROR_LOG;
 	}
 
 	if (logname && !seg->region_size) {
-		log_error("Missing region size for mirror log for segment "
-			  "'%s'.", sn->key);
+		log_error("Missing region size for mirror log for "
+			  "segment %s of logical volume %s.",
+			  config_node_name(sn), seg->lv->name);
 		return 0;
 	}
 
 	if (!(cn = find_config_node(sn, "mirrors"))) {
-		log_error("Couldn't find mirrors array for segment "
-			  "'%s'.", sn->key);
+		log_error("Couldn't find mirrors array for "
+			  "segment %s of logical volume %s.",
+			  config_node_name(sn), seg->lv->name);
 		return 0;
 	}
 
diff --git a/lib/striped/striped.c b/lib/striped/striped.c
index 78129af..6dda69b 100644
--- a/lib/striped/striped.c
+++ b/lib/striped/striped.c
@@ -54,7 +54,7 @@ static int _striped_text_import_area_count(struct config_node *sn, uint32_t *are
 {
 	if (!get_config_uint32(sn, "stripe_count", area_count)) {
 		log_error("Couldn't read 'stripe_count' for "
-			  "segment '%s'.", sn->key);
+			  "segment '%s'.", config_node_name(sn));
 		return 0;
 	}
 
@@ -68,14 +68,14 @@ static int _striped_text_import(struct lv_segment *seg, const struct config_node
 
 	if ((seg->area_count != 1) &&
 	    !get_config_uint32(sn, "stripe_size", &seg->stripe_size)) {
-		log_error("Couldn't read stripe_size for segment '%s'.",
-			  sn->key);
+		log_error("Couldn't read stripe_size for segment %s "
+			  "of logical volume %s.", config_node_name(sn), seg->lv->name);
 		return 0;
 	}
 
 	if (!(cn = find_config_node(sn, "stripes"))) {
-		log_error("Couldn't find stripes array for segment "
-			  "'%s'.", sn->key);
+		log_error("Couldn't find stripes array for segment %s "
+			  "of logical volume %s.", config_node_name(sn), seg->lv->name);
 		return 0;
 	}
 



