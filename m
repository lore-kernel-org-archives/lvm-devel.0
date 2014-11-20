From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu, 20 Nov 2014 15:52:56 +0000 (UTC)
Subject: master - libdm-config: Allow paths (section/key = value) in config files.
Message-ID: <20141120155256.BA5AD60E97@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=687029cbbd5b97d545363b4f7448b5a1fe71f3c5
Commit:        687029cbbd5b97d545363b4f7448b5a1fe71f3c5
Parent:        9f2961f259ff990d3a21e8edac5f7caa564b0e2e
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon Nov 10 07:38:19 2014 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Nov 20 16:47:30 2014 +0100

libdm-config: Allow paths (section/key = value) in config files.

The order of the resulting tree is based on the first appearance of
sections. With no section repeats, the sections stay as listed in the
config file. Sections using the brace syntax 'section { key = value }' are
treated the same way: 'section { x = 1 } section { y = 2 }' is the same as
'section/x = 1 section/y = 2' is the same as 'section { x = 1 y = 2 }'
---
 libdm/libdm-config.c |  165 ++++++++++++++++++++++++++++----------------------
 1 files changed, 92 insertions(+), 73 deletions(-)

diff --git a/libdm/libdm-config.c b/libdm/libdm-config.c
index f8d6b1b..4965e32 100644
--- a/libdm/libdm-config.c
+++ b/libdm/libdm-config.c
@@ -61,13 +61,14 @@ struct config_output {
 static void _get_token(struct parser *p, int tok_prev);
 static void _eat_space(struct parser *p);
 static struct dm_config_node *_file(struct parser *p);
-static struct dm_config_node *_section(struct parser *p);
+static struct dm_config_node *_section(struct parser *p, struct dm_config_node *parent);
 static struct dm_config_value *_value(struct parser *p);
 static struct dm_config_value *_type(struct parser *p);
 static int _match_aux(struct parser *p, int t);
 static struct dm_config_value *_create_value(struct dm_pool *mem);
 static struct dm_config_node *_create_node(struct dm_pool *mem);
 static char *_dup_tok(struct parser *p);
+static char *_dup_token(struct dm_pool *mem, const char *b, const char *e);
 
 static const int sep = '/';
 
@@ -419,71 +420,121 @@ static char *_dup_string_tok(struct parser *p)
 
 static struct dm_config_node *_file(struct parser *p)
 {
-	struct dm_config_node *root = NULL, *n, *l = NULL;
-	while (p->t != TOK_EOF) {
-		if (!(n = _section(p)))
+	struct dm_config_node root = { 0 };
+	root.key = "<root>";
+
+	while (p->t != TOK_EOF)
+		if (!_section(p, &root))
 			return_NULL;
+	return root.child;
+}
+
+static struct dm_config_node *_make_node(struct dm_pool *mem,
+					 const char *key_b, const char *key_e,
+					 struct dm_config_node *parent)
+{
+	struct dm_config_node *n;
+
+	if (!(n = _create_node(mem)))
+		return_NULL;
 
-		if (!root)
-			root = n;
-		else
-			l->sib = n;
-		n->parent = root;
-		l = n;
+	n->key = _dup_token(mem, key_b, key_e);
+	if (parent) {
+		n->parent = parent;
+		n->sib = parent->child;
+		parent->child = n;
 	}
-	return root;
+	return n;
+}
+
+/* when mem is not NULL, we create the path if it doesn't exist yet */
+static struct dm_config_node *_find_or_make_node(struct dm_pool *mem,
+						 struct dm_config_node *parent,
+						 const char *path)
+{
+	const char *e;
+	struct dm_config_node *cn = parent ? parent->child : NULL;
+	struct dm_config_node *cn_found = NULL;
+
+	while (cn || mem) {
+		/* trim any leading slashes */
+		while (*path && (*path == sep))
+			path++;
+
+		/* find the end of this segment */
+		for (e = path; *e && (*e != sep); e++) ;
+
+		/* hunt for the node */
+		cn_found = NULL;
+
+		while (cn) {
+			if (_tok_match(cn->key, path, e)) {
+				/* Inefficient */
+				if (!cn_found)
+					cn_found = cn;
+				else
+					log_warn("WARNING: Ignoring duplicate"
+						 " config node: %s ("
+						 "seeking %s)", cn->key, path);
+			}
+
+			cn = cn->sib;
+		}
+
+		if (!cn_found && mem) {
+			if (!(cn_found = _make_node(mem, path, e, parent)))
+				return_NULL;
+		}
+
+		if (cn_found && *e) {
+			parent = cn_found;
+			cn = cn_found->child;
+		} else
+			return cn_found;
+		path = e;
+	}
+
+	return NULL;
 }
 
-static struct dm_config_node *_section(struct parser *p)
+static struct dm_config_node *_section(struct parser *p, struct dm_config_node *parent)
 {
 	/* IDENTIFIER SECTION_B_CHAR VALUE* SECTION_E_CHAR */
 
 	struct dm_config_node *root, *n, *l = NULL;
 	char *str;
 
-	if (!(root = _create_node(p->mem))) {
-		log_error("Failed to allocate section node");
-		return NULL;
-	}
-
 	if (p->t == TOK_STRING_ESCAPED) {
 		if (!(str = _dup_string_tok(p)))
 			return_NULL;
 		dm_unescape_double_quotes(str);
-		root->key = str;
 
 		match(TOK_STRING_ESCAPED);
 	} else if (p->t == TOK_STRING) {
 		if (!(str = _dup_string_tok(p)))
 			return_NULL;
-		root->key = str;
 
 		match(TOK_STRING);
 	} else {
-		if (!(root->key = _dup_tok(p)))
+		if (!(str = _dup_tok(p)))
 			return_NULL;
 
 		match(TOK_IDENTIFIER);
 	}
 
-	if (!strlen(root->key)) {
+	if (!strlen(str)) {
 		log_error("Parse error at byte %" PRIptrdiff_t " (line %d): empty section identifier",
 			  p->tb - p->fb + 1, p->line);
 		return NULL;
 	}
 
+	root = _find_or_make_node(p->mem, parent, str);
+
 	if (p->t == TOK_SECTION_B) {
 		match(TOK_SECTION_B);
 		while (p->t != TOK_SECTION_E) {
-			if (!(n = _section(p)))
+			if (!(n = _section(p, root)))
 				return_NULL;
-
-			if (!l)
-				root->child = n;
-			else
-				l->sib = n;
-			n->parent = root;
-			l = n;
 		}
 		match(TOK_SECTION_E);
 	} else {
@@ -751,19 +802,24 @@ static struct dm_config_node *_create_node(struct dm_pool *mem)
 	return dm_pool_zalloc(mem, sizeof(struct dm_config_node));
 }
 
-static char *_dup_tok(struct parser *p)
+static char *_dup_token(struct dm_pool *mem, const char *b, const char *e)
 {
-	size_t len = p->te - p->tb;
-	char *str = dm_pool_alloc(p->mem, len + 1);
+	size_t len = e - b;
+	char *str = dm_pool_alloc(mem, len + 1);
 	if (!str) {
 		log_error("Failed to duplicate token.");
 		return 0;
 	}
-	memcpy(str, p->tb, len);
+	memcpy(str, b, len);
 	str[len] = '\0';
 	return str;
 }
 
+static char *_dup_tok(struct parser *p)
+{
+	return _dup_token(p->mem, p->tb, p->te);
+}
+
 /*
  * Utility functions
  */
@@ -778,46 +834,9 @@ static char *_dup_tok(struct parser *p)
  */
 typedef const struct dm_config_node *node_lookup_fn(const void *start, const char *path);
 
-static const struct dm_config_node *_find_config_node(const void *start,
-						      const char *path)
-{
-	const char *e;
-	const struct dm_config_node *cn = start;
-	const struct dm_config_node *cn_found = NULL;
-
-	while (cn) {
-		/* trim any leading slashes */
-		while (*path && (*path == sep))
-			path++;
-
-		/* find the end of this segment */
-		for (e = path; *e && (*e != sep); e++) ;
-
-		/* hunt for the node */
-		cn_found = NULL;
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
-
-			cn = cn->sib;
-		}
-
-		if (cn_found && *e)
-			cn = cn_found->child;
-		else
-			return cn_found;
-
-		path = e;
-	}
-
-	return NULL;
+static const struct dm_config_node *_find_config_node(const void *start, const char *path) {
+	struct dm_config_node dummy = { .child = (void *) start };
+	return _find_or_make_node(NULL, &dummy, path);
 }
 
 static const struct dm_config_node *_find_first_config_node(const void *start, const char *path)


