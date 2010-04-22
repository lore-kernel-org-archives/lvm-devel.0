From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 22 Apr 2010 15:29:03 +0200
Subject: [PATCH 2/3] Revert "Add a regex optimisation pass for shared character prefixes."
In-Reply-To: <cover.1271942633.git.zkabelac@redhat.com>
References: <cover.1271942633.git.zkabelac@redhat.com>
Message-ID: <c1f0c855255df76722de56399926188c09bddad5.1271942633.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This reverts commit 23dd4773d4decbe564090430e8d82eea1198344c.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 WHATS_NEW_DM           |    1 -
 libdm/regex/parse_rx.c |  180 ++----------------------------------------------
 2 files changed, 5 insertions(+), 176 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index c96260c..60725a8 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,6 +1,5 @@
 Version 1.02.47 -
 =================================
-  Add a regex optimisation pass for shared character prefixes.
   Add dm_bit_and and dm_bitset_equal to libdevmapper.
   Simplify dm_bitset_create.
   Speed up dm_bit_get_next with ffs().
diff --git a/libdm/regex/parse_rx.c b/libdm/regex/parse_rx.c
index fb8b886..fdea1a3 100644
--- a/libdm/regex/parse_rx.c
+++ b/libdm/regex/parse_rx.c
@@ -329,182 +329,19 @@ static struct rx_node *_or_term(struct parse_sp *ps)
 	return n;
 }
 
-/*----------------------------------------------------------------*/
-
-/*
- * The optimiser spots common prefixes on either side of an 'or' node, and
- * lifts them outside the 'or' with a 'cat'.
- */
-static unsigned _leftmost_depth(struct rx_node *r)
-{
-	int count = 1;
-
-	while (r->type != CHARSET) {
-		count++;
-		r = r->left;
-	}
-
-	return count;
-}
-
-/*
- * FIXME: a unique key could be built up as part of the parse, to make the
- * comparison quick.  Alternatively we could use cons-hashing, and then
- * this would simply be a pointer comparison.
- */
-static int _nodes_equal(struct rx_node *l, struct rx_node *r)
-{
-	if (l->type != r->type)
-		return 0;
-
-	switch (l->type) {
-	case CAT:
-	case OR:
-		return _nodes_equal(l->left, r->left) &&
-			_nodes_equal(l->right, r->right);
-
-	case STAR:
-	case PLUS:
-	case QUEST:
-		return _nodes_equal(l->left, r->left);
-
-	case CHARSET:
-		return dm_bitset_equal(l->charset, r->charset);
-	}
-
-	/* NOTREACHED */
-	return_0;
-}
-
-static int _find_leftmost_common(struct rx_node *or,
-                                 struct rx_node **l,
-                                 struct rx_node **r)
-{
-	struct rx_node *left = or->left, *right = or->right;
-	unsigned left_depth = _leftmost_depth(left);
-	unsigned right_depth = _leftmost_depth(right);
-
-	while (left_depth > right_depth) {
-		left = left->left;
-		left_depth--;
-	}
-
-	while (right_depth > left_depth) {
-		right = right->left;
-		right_depth--;
-	}
-
-	while (left_depth) {
-		if (left->type == CAT && right->type == CAT) {
-			if (_nodes_equal(left->left, right->left)) {
-				*l = left;
-				*r = right;
-				return 1;
-			}
-		}
-		left = left->left;
-		right = right->left;
-		left_depth--;
-	}
-
-	return 0;
-}
-
-static struct rx_node *_pass(struct dm_pool *mem,
-                             struct rx_node *r,
-                             int *changed)
-{
-	/*
-	 * walk the tree, optimising every 'or' node.
-	 */
-	switch (r->type) {
-	case CAT:
-		if (!(r->left = _pass(mem, r->left, changed)))
-			return_NULL;
-
-		if (!(r->right = _pass(mem, r->right, changed)))
-			return_NULL;
-
-		break;
-
-	case STAR:
-	case PLUS:
-	case QUEST:
-		if (!(r->left = _pass(mem, r->left, changed)))
-			return_NULL;
-		break;
-
-	case OR:
-		/* It's important we optimise sub nodes first */
-		if (!(r->left = _pass(mem, r->left, changed)))
-			return_NULL;
-
-		if (!(r->right = _pass(mem, r->right, changed)))
-			return_NULL;
-
-		{
-			struct rx_node *left, *right;
-
-			if (_find_leftmost_common(r, &left, &right)) {
-				struct rx_node *new_r = _node(mem, CAT, left->left, r);
-
-				if (!new_r)
-					return_NULL;
-
-				memcpy(left, left->right, sizeof(*left));
-				memcpy(right, right->right, sizeof(*right));
-
-				r = new_r;
-
-				*changed = 1;
-			}
-		}
-		break;
-
-	case CHARSET:
-		break;
-	}
-
-	return r;
-}
-
-static struct rx_node *_optimise(struct dm_pool *mem, struct rx_node *r)
-{
-	/*
-	 * We're looking for (or (... (cat <foo> a)) (... (cat <foo> b)))
-	 * and want to turn it into (cat <foo> (or (... a) (... b)))
-	 */
-
-	/*
-	 * Initially done as an inefficient multipass algorithm.
-	 */
-	int changed;
-
-	do {
-		changed = 0;
-		r = _pass(mem, r, &changed);
-	} while (r && changed);
-
-	return r;
-}
-
-/*----------------------------------------------------------------*/
-
 struct rx_node *rx_parse_tok(struct dm_pool *mem,
 			     const char *begin, const char *end)
 {
 	struct rx_node *r;
 	struct parse_sp *ps = dm_pool_zalloc(mem, sizeof(*ps));
 
-	if (!ps)
-		return_NULL;
-
-	ps->mem = mem;
-	if (!(ps->charset = dm_bitset_create(mem, 256))) {
-		log_error("Regex charset allocation failed");
-		dm_pool_free(mem, ps);
+	if (!ps) {
+		stack;
 		return NULL;
 	}
+
+	ps->mem = mem;
+	ps->charset = dm_bitset_create(mem, 256);
 	ps->cursor = begin;
 	ps->rx_end = end;
 	_rx_get_token(ps);		/* load the first token */
@@ -512,13 +349,6 @@ struct rx_node *rx_parse_tok(struct dm_pool *mem,
 	if (!(r = _or_term(ps))) {
 		log_error("Parse error in regex");
 		dm_pool_free(mem, ps);
-		return NULL;
-	}
-
-	if (!(r = _optimise(mem, r))) {
-		log_error("Regex optimisation error");
-		dm_pool_free(mem, ps);
-		return NULL;
 	}
 
 	return r;
-- 
1.7.0.1


