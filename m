From: agk@sourceware.org <agk@sourceware.org>
Date: 20 Apr 2010 22:31:23 -0000
Subject: LVM2/libdm/regex parse_rx.c
Message-ID: <20100420223123.5775.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-04-20 22:31:22

Modified files:
	libdm/regex    : parse_rx.c 

Log message:
	Add a regex optimisation pass for shared character prefixes.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/regex/parse_rx.c.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/libdm/regex/parse_rx.c	2008/11/03 18:59:59	1.3
+++ LVM2/libdm/regex/parse_rx.c	2010/04/20 22:31:22	1.4
@@ -329,19 +329,182 @@
 	return n;
 }
 
+/*----------------------------------------------------------------*/
+
+/*
+ * The optimiser spots common prefixes on either side of an 'or' node, and
+ * lifts them outside the 'or' with a 'cat'.
+ */
+static unsigned _leftmost_depth(struct rx_node *r)
+{
+	int count = 1;
+
+	while (r->type != CHARSET) {
+		count++;
+		r = r->left;
+	}
+
+	return count;
+}
+
+/*
+ * FIXME: a unique key could be built up as part of the parse, to make the
+ * comparison quick.  Alternatively we could use cons-hashing, and then
+ * this would simply be a pointer comparison.
+ */
+static int _nodes_equal(struct rx_node *l, struct rx_node *r)
+{
+	if (l->type != r->type)
+		return 0;
+
+	switch (l->type) {
+	case CAT:
+	case OR:
+		return _nodes_equal(l->left, r->left) &&
+			_nodes_equal(l->right, r->right);
+
+	case STAR:
+	case PLUS:
+	case QUEST:
+		return _nodes_equal(l->left, r->left);
+
+	case CHARSET:
+		return dm_bitset_equal(l->charset, r->charset);
+	}
+
+	/* NOTREACHED */
+	return_0;
+}
+
+static int _find_leftmost_common(struct rx_node *or,
+                                 struct rx_node **l,
+                                 struct rx_node **r)
+{
+	struct rx_node *left = or->left, *right = or->right;
+	unsigned left_depth = _leftmost_depth(left);
+	unsigned right_depth = _leftmost_depth(right);
+
+	while (left_depth > right_depth) {
+		left = left->left;
+		left_depth--;
+	}
+
+	while (right_depth > left_depth) {
+		right = right->left;
+		right_depth--;
+	}
+
+	while (left_depth) {
+		if (left->type == CAT && right->type == CAT) {
+			if (_nodes_equal(left->left, right->left)) {
+				*l = left;
+				*r = right;
+				return 1;
+			}
+		}
+		left = left->left;
+		right = right->left;
+		left_depth--;
+	}
+
+	return 0;
+}
+
+static struct rx_node *_pass(struct dm_pool *mem,
+                             struct rx_node *r,
+                             int *changed)
+{
+	/*
+	 * walk the tree, optimising every 'or' node.
+	 */
+	switch (r->type) {
+	case CAT:
+		if (!(r->left = _pass(mem, r->left, changed)))
+			return_NULL;
+
+		if (!(r->right = _pass(mem, r->right, changed)))
+			return_NULL;
+
+		break;
+
+	case STAR:
+	case PLUS:
+	case QUEST:
+		if (!(r->left = _pass(mem, r->left, changed)))
+			return_NULL;
+		break;
+
+	case OR:
+		/* It's important we optimise sub nodes first */
+		if (!(r->left = _pass(mem, r->left, changed)))
+			return_NULL;
+
+		if (!(r->right = _pass(mem, r->right, changed)))
+			return_NULL;
+
+		{
+			struct rx_node *left, *right;
+
+			if (_find_leftmost_common(r, &left, &right)) {
+				struct rx_node *new_r = _node(mem, CAT, left->left, r);
+
+				if (!new_r)
+					return_NULL;
+
+				memcpy(left, left->right, sizeof(*left));
+				memcpy(right, right->right, sizeof(*right));
+
+				r = new_r;
+
+				*changed = 1;
+			}
+		}
+		break;
+
+	case CHARSET:
+		break;
+	}
+
+	return r;
+}
+
+static struct rx_node *_optimise(struct dm_pool *mem, struct rx_node *r)
+{
+	/*
+	 * We're looking for (or (... (cat <foo> a)) (... (cat <foo> b)))
+	 * and want to turn it into (cat <foo> (or (... a) (... b)))
+	 */
+
+	/*
+	 * Initially done as an inefficient multipass algorithm.
+	 */
+	int changed;
+
+	do {
+		changed = 0;
+		r = _pass(mem, r, &changed);
+	} while (r && changed);
+
+	return r;
+}
+
+/*----------------------------------------------------------------*/
+
 struct rx_node *rx_parse_tok(struct dm_pool *mem,
 			     const char *begin, const char *end)
 {
 	struct rx_node *r;
 	struct parse_sp *ps = dm_pool_zalloc(mem, sizeof(*ps));
 
-	if (!ps) {
-		stack;
-		return NULL;
-	}
+	if (!ps)
+		return_NULL;
 
 	ps->mem = mem;
-	ps->charset = dm_bitset_create(mem, 256);
+	if (!(ps->charset = dm_bitset_create(mem, 256))) {
+		log_error("Regex charset allocation failed");
+		dm_pool_free(mem, ps);
+		return NULL;
+	}
 	ps->cursor = begin;
 	ps->rx_end = end;
 	_rx_get_token(ps);		/* load the first token */
@@ -349,6 +512,13 @@
 	if (!(r = _or_term(ps))) {
 		log_error("Parse error in regex");
 		dm_pool_free(mem, ps);
+		return NULL;
+	}
+
+	if (!(r = _optimise(mem, r))) {
+		log_error("Regex optimisation error");
+		dm_pool_free(mem, ps);
+		return NULL;
 	}
 
 	return r;


