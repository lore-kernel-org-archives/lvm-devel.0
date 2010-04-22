From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 22 Apr 2010 15:29:02 +0200
Subject: [PATCH 1/3] Revert "Still not satisfactory..."
In-Reply-To: <cover.1271942633.git.zkabelac@redhat.com>
References: <cover.1271942633.git.zkabelac@redhat.com>
Message-ID: <dbe2653c17de9f4b533ff4847cd34987b4ce08b7.1271942633.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This reverts commit 4c952f0af4d742492cdf4f026072d597ff24919a.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 libdm/regex/parse_rx.c |   69 +++++++++++++----------------------------------
 1 files changed, 19 insertions(+), 50 deletions(-)

diff --git a/libdm/regex/parse_rx.c b/libdm/regex/parse_rx.c
index fb9406d..fb8b886 100644
--- a/libdm/regex/parse_rx.c
+++ b/libdm/regex/parse_rx.c
@@ -331,19 +331,17 @@ static struct rx_node *_or_term(struct parse_sp *ps)
 
 /*----------------------------------------------------------------*/
 
-#define L_OR_R(a) (leftmost ? (a)->left : (a)->right)
-
 /*
  * The optimiser spots common prefixes on either side of an 'or' node, and
  * lifts them outside the 'or' with a 'cat'.
  */
-static unsigned _depth(struct rx_node *r, unsigned leftmost)
+static unsigned _leftmost_depth(struct rx_node *r)
 {
 	int count = 1;
 
 	while (r->type != CHARSET) {
 		count++;
-		r = L_OR_R(r);
+		r = r->left;
 	}
 
 	return count;
@@ -380,69 +378,38 @@ static int _nodes_equal(struct rx_node *l, struct rx_node *r)
 
 static int _find_leftmost_common(struct rx_node *or,
                                  struct rx_node **l,
-                                 struct rx_node **r,
-				 unsigned leftmost)
+                                 struct rx_node **r)
 {
 	struct rx_node *left = or->left, *right = or->right;
-	unsigned left_depth = _depth(left, leftmost);
-	unsigned right_depth = _depth(right, leftmost);
+	unsigned left_depth = _leftmost_depth(left);
+	unsigned right_depth = _leftmost_depth(right);
 
 	while (left_depth > right_depth) {
-		left = L_OR_R(left);
+		left = left->left;
 		left_depth--;
 	}
 
 	while (right_depth > left_depth) {
-		right = L_OR_R(right);
+		right = right->left;
 		right_depth--;
 	}
 
 	while (left_depth) {
 		if (left->type == CAT && right->type == CAT) {
-			if (_nodes_equal(L_OR_R(left), L_OR_R(right))) {
+			if (_nodes_equal(left->left, right->left)) {
 				*l = left;
 				*r = right;
 				return 1;
 			}
 		}
-		left = L_OR_R(left);
-		right = L_OR_R(right);
+		left = left->left;
+		right = right->left;
 		left_depth--;
 	}
 
 	return 0;
 }
 
-static struct rx_node *_exchange_nodes(struct dm_pool *mem, struct rx_node *r, struct rx_node *left_cat, struct rx_node *right_cat, unsigned leftmost)
-{
-	struct rx_node *new_r, *new_cat;
-
-	/* FIXME Clean up leftmost */
-	if (leftmost) {
-		new_r = r->right;
-		new_cat = _node(mem, CAT, left_cat->left, r);
-		if (!new_cat)
-			return_NULL;
-		new_r->left = new_cat;
-
-		memcpy(left_cat, left_cat->right, sizeof(*left_cat));
-		r->right = right_cat->right;
-
-		/* FIXME Avoid this */
-		if (new_r->right == right_cat->right)
-			new_r = new_r->left;
-	} else {
-		new_r = _node(mem, CAT, r, right_cat->right);
-		if (!new_r)
-			return_NULL;
-
-		memcpy(left_cat, left_cat->left, sizeof(*left_cat));
-		memcpy(right_cat, right_cat->left, sizeof(*right_cat));
-	}
-
-	return new_r;
-}
-
 static struct rx_node *_pass(struct dm_pool *mem,
                              struct rx_node *r,
                              int *changed)
@@ -478,12 +445,16 @@ static struct rx_node *_pass(struct dm_pool *mem,
 		{
 			struct rx_node *left, *right;
 
-			if (_find_leftmost_common(r, &left, &right, 1)) {
-				r = _exchange_nodes(mem, r, left, right, 1);
+			if (_find_leftmost_common(r, &left, &right)) {
+				struct rx_node *new_r = _node(mem, CAT, left->left, r);
 
-				*changed = 1;
-			} else if (_find_leftmost_common(r, &left, &right, 0)) {
-				r = _exchange_nodes(mem, r, left, right, 0);
+				if (!new_r)
+					return_NULL;
+
+				memcpy(left, left->right, sizeof(*left));
+				memcpy(right, right->right, sizeof(*right));
+
+				r = new_r;
 
 				*changed = 1;
 			}
@@ -502,8 +473,6 @@ static struct rx_node *_optimise(struct dm_pool *mem, struct rx_node *r)
 	/*
 	 * We're looking for (or (... (cat <foo> a)) (... (cat <foo> b)))
 	 * and want to turn it into (cat <foo> (or (... a) (... b)))
-	 *
-	 * (fa)|(fb) becomes f(a|b)
 	 */
 
 	/*
-- 
1.7.0.1


