From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 21 Sep 2016 16:18:50 +0000 (UTC)
Subject: master - libdm: add dm_config_parse_without_dup_node_check
Message-ID: <20160921161850.0A50A60F23@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7563e69cf13126af5889de147c092b9d2e490648
Commit:        7563e69cf13126af5889de147c092b9d2e490648
Parent:        094488ffab4837fa14069b81a15e0a6bdaca8a73
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Sep 21 14:25:24 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 21 18:15:18 2016 +0200

libdm: add dm_config_parse_without_dup_node_check

Introduce function for config parsing tree without checking
for duplicate nodes.
---
 WHATS_NEW_DM                        |    1 +
 libdm/.exported_symbols.DM_1_02_135 |    1 +
 libdm/libdevmapper.h                |    1 +
 libdm/libdm-config.c                |   47 +++++++++++++++++++++++------------
 4 files changed, 34 insertions(+), 16 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index edb1e70..7d32dff 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.135 - 
 =====================================
+  Introduce new dm_config_parse_without_dup_node_check().
 
 Version 1.02.134 - 7th September 2016
 =====================================
diff --git a/libdm/.exported_symbols.DM_1_02_135 b/libdm/.exported_symbols.DM_1_02_135
new file mode 100644
index 0000000..dceeb4e
--- /dev/null
+++ b/libdm/.exported_symbols.DM_1_02_135
@@ -0,0 +1 @@
+dm_config_parse_without_dup_node_check
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 5790486..97c3e51 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -3333,6 +3333,7 @@ struct dm_config_tree {
 struct dm_config_tree *dm_config_create(void);
 struct dm_config_tree *dm_config_from_string(const char *config_settings);
 int dm_config_parse(struct dm_config_tree *cft, const char *start, const char *end);
+int dm_config_parse_without_dup_node_check(struct dm_config_tree *cft, const char *start, const char *end);
 
 void *dm_config_get_custom(struct dm_config_tree *cft);
 void dm_config_set_custom(struct dm_config_tree *cft, void *custom);
diff --git a/libdm/libdm-config.c b/libdm/libdm-config.c
index dcb7c3f..90e3405 100644
--- a/libdm/libdm-config.c
+++ b/libdm/libdm-config.c
@@ -50,6 +50,7 @@ struct parser {
 	int line;		/* line number we are on */
 
 	struct dm_pool *mem;
+	int no_dup_node_check;	/* whether to disable dup node checking */
 };
 
 struct config_output {
@@ -170,7 +171,7 @@ static struct dm_config_node *_config_reverse(struct dm_config_node *head)
 	return middle;
 }
 
-int dm_config_parse(struct dm_config_tree *cft, const char *start, const char *end)
+static int _do_dm_config_parse(struct dm_config_tree *cft, const char *start, const char *end, int no_dup_node_check)
 {
 	/* TODO? if (start == end) return 1; */
 
@@ -183,6 +184,7 @@ int dm_config_parse(struct dm_config_tree *cft, const char *start, const char *e
 	p->fe = end;
 	p->tb = p->te = p->fb;
 	p->line = 1;
+	p->no_dup_node_check = no_dup_node_check;
 
 	_get_token(p, TOK_SECTION_E);
 	if (!(cft->root = _file(p)))
@@ -193,6 +195,16 @@ int dm_config_parse(struct dm_config_tree *cft, const char *start, const char *e
 	return 1;
 }
 
+int dm_config_parse(struct dm_config_tree *cft, const char *start, const char *end)
+{
+	return _do_dm_config_parse(cft, start, end, 0);
+}
+
+int dm_config_parse_without_dup_node_check(struct dm_config_tree *cft, const char *start, const char *end)
+{
+	return _do_dm_config_parse(cft, start, end, 1);
+}
+
 struct dm_config_tree *dm_config_from_string(const char *config_settings)
 {
 	struct dm_config_tree *cft;
@@ -509,7 +521,8 @@ static struct dm_config_node *_make_node(struct dm_pool *mem,
 /* when mem is not NULL, we create the path if it doesn't exist yet */
 static struct dm_config_node *_find_or_make_node(struct dm_pool *mem,
 						 struct dm_config_node *parent,
-						 const char *path)
+						 const char *path,
+						 int no_dup_node_check)
 {
 	const char *e;
 	struct dm_config_node *cn = parent ? parent->child : NULL;
@@ -526,18 +539,20 @@ static struct dm_config_node *_find_or_make_node(struct dm_pool *mem,
 		/* hunt for the node */
 		cn_found = NULL;
 
-		while (cn) {
-			if (_tok_match(cn->key, path, e)) {
-				/* Inefficient */
-				if (!cn_found)
-					cn_found = cn;
-				else
-					log_warn("WARNING: Ignoring duplicate"
-						 " config node: %s ("
-						 "seeking %s)", cn->key, path);
-			}
+		if (!no_dup_node_check) {
+			while (cn) {
+				if (_tok_match(cn->key, path, e)) {
+					/* Inefficient */
+					if (!cn_found)
+						cn_found = cn;
+					else
+						log_warn("WARNING: Ignoring duplicate"
+							 " config node: %s ("
+							 "seeking %s)", cn->key, path);
+				}
 
-			cn = cn->sib;
+				cn = cn->sib;
+			}
 		}
 
 		if (!cn_found && mem) {
@@ -588,7 +603,7 @@ static struct dm_config_node *_section(struct parser *p, struct dm_config_node *
 		return NULL;
 	}
 
-	if (!(root = _find_or_make_node(p->mem, parent, str)))
+	if (!(root = _find_or_make_node(p->mem, parent, str, p->no_dup_node_check)))
 		return_NULL;
 
 	if (p->t == TOK_SECTION_B) {
@@ -912,7 +927,7 @@ typedef const struct dm_config_node *node_lookup_fn(const void *start, const cha
 
 static const struct dm_config_node *_find_config_node(const void *start, const char *path) {
 	struct dm_config_node dummy = { .child = (void *) start };
-	return _find_or_make_node(NULL, &dummy, path);
+	return _find_or_make_node(NULL, &dummy, path, 0);
 }
 
 static const struct dm_config_node *_find_first_config_node(const void *start, const char *path)
@@ -1395,7 +1410,7 @@ static int _override_path(const char *path, struct dm_config_node *node, void *b
 	struct dm_config_tree *cft = baton;
 	struct dm_config_node dummy, *target;
 	dummy.child = cft->root;
-	if (!(target = _find_or_make_node(cft->mem, &dummy, path)))
+	if (!(target = _find_or_make_node(cft->mem, &dummy, path, 0)))
 		return_0;
 	if (!(target->v = _clone_config_value(cft->mem, node->v)))
 		return_0;


