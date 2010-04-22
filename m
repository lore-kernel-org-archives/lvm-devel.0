From: agk@sourceware.org <agk@sourceware.org>
Date: 22 Apr 2010 13:42:35 -0000
Subject: LVM2/libdm/regex parse_rx.c
Message-ID: <20100422134235.17974.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-04-22 13:42:34

Modified files:
	libdm/regex    : parse_rx.c 

Log message:
	Fix rightmost rotation, and use LEFT and RIGHT to make symmetry more obvious.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/regex/parse_rx.c.diff?cvsroot=lvm2&r1=1.6&r2=1.7

--- LVM2/libdm/regex/parse_rx.c	2010/04/22 13:18:27	1.6
+++ LVM2/libdm/regex/parse_rx.c	2010/04/22 13:42:34	1.7
@@ -333,7 +333,9 @@
 
 /*----------------------------------------------------------------*/
 
-#define L_OR_R(a) (leftmost ? (a)->left : (a)->right)
+/* Macros for left and right nodes.  Inverted if 'leftmost' is set. */
+#define LEFT(a) (leftmost ? (a)->left : (a)->right)
+#define RIGHT(a) (leftmost ? (a)->right : (a)->left)
 
 /*
  * The optimiser spots common prefixes on either side of an 'or' node, and
@@ -345,7 +347,7 @@
 
 	while (r->type != CHARSET) {
 		count++;
-		r = L_OR_R(r);
+		r = LEFT(r);
 	}
 
 	return count;
@@ -390,46 +392,54 @@
 	unsigned right_depth = _depth(right, leftmost);
 
 	while (left_depth > right_depth) {
-		left = L_OR_R(left);
+		left = LEFT(left);
 		left_depth--;
 	}
 
 	while (right_depth > left_depth) {
-		right = L_OR_R(right);
+		right = LEFT(right);
 		right_depth--;
 	}
 
 	while (left_depth) {
 		if (left->type == CAT && right->type == CAT) {
-			if (_nodes_equal(L_OR_R(left), L_OR_R(right))) {
+			if (_nodes_equal(LEFT(left), LEFT(right))) {
 				*l = left;
 				*r = right;
 				return 1;
 			}
 		}
-		left = L_OR_R(left);
-		right = L_OR_R(right);
+		left = LEFT(left);
+		right = LEFT(right);
 		left_depth--;
 	}
 
 	return 0;
 }
 
-/* If top node is OR, rotate from ((ab)|((ac)|d)) to (((ab)|(ac))|d) */
-static int _rotate_ors(struct rx_node *r)
+/* If top node is OR, rotate (leftmost example) from ((ab)|((ac)|d)) to (((ab)|(ac))|d) */
+static int _rotate_ors(struct rx_node *r, unsigned leftmost)
 {
-	struct rx_node *old_r_right;
+	struct rx_node *old_node;
 
-	if (r->type == OR && r->right->type == OR) {
-		old_r_right = r->right;
-		r->right = old_r_right->right;
-		old_r_right->right = old_r_right->left;
-		old_r_right->left = r->left;
-		r->left = old_r_right;
-		return 1;
+	if (r->type != OR || RIGHT(r)->type != OR)
+		return 0;
+
+	old_node = RIGHT(r);
+
+	if (leftmost) {
+		r->right = RIGHT(old_node);
+		old_node->right = LEFT(old_node);
+		old_node->left = LEFT(r);
+		r->left = old_node;
+	} else {
+		r->left = RIGHT(old_node);
+		old_node->left = LEFT(old_node);
+		old_node->right = LEFT(r);
+		r->right = old_node;
 	}
 
-	return 0;
+	return 1;
 }
 
 static struct rx_node *_exchange_nodes(struct dm_pool *mem, struct rx_node *r,
@@ -438,21 +448,16 @@
 {
 	struct rx_node *new_r;
 
-	if (leftmost) {
-		new_r = _node(mem, CAT, left_cat->left, r);
-		if (!new_r)
-			return_NULL;
+	if (leftmost)
+		new_r = _node(mem, CAT, LEFT(left_cat), r);
+	else
+		new_r = _node(mem, CAT, r, LEFT(right_cat));
 
-		memcpy(left_cat, left_cat->right, sizeof(*left_cat));
-		memcpy(right_cat, right_cat->right, sizeof(*right_cat));
-	} else {
-		new_r = _node(mem, CAT, r, right_cat->right);
-		if (!new_r)
-			return_NULL;
+	if (!new_r)
+		return_NULL;
 
-		memcpy(left_cat, left_cat->left, sizeof(*left_cat));
-		memcpy(right_cat, right_cat->left, sizeof(*right_cat));
-	}
+	memcpy(left_cat, RIGHT(left_cat), sizeof(*left_cat));
+	memcpy(right_cat, RIGHT(right_cat), sizeof(*right_cat));
 
 	return new_r;
 }
@@ -491,16 +496,19 @@
 		if (!(r->right = _pass(mem, r->right, changed)))
 			return_NULL;
 
+		/*
+		 * If rotate_ors changes the tree, left and right are stale,
+		 * so just set 'changed' to repeat the search.
+		 *
+		 * FIXME Check we can't 'bounce' between left and right rotations here.
+		 */
 		if (_find_leftmost_common(r, &left, &right, 1)) {
-			/*
-			 * If rotate_ors changes the tree, left and right are stale,
-			 * so just set 'changed' to repeat the search.
-			 */
-			if (!_rotate_ors(r))
+			if (!_rotate_ors(r, 1))
 				r = _exchange_nodes(mem, r, left, right, 1);
 			*changed = 1;
 		} else if (_find_leftmost_common(r, &left, &right, 0)) {
-			r = _exchange_nodes(mem, r, left, right, 0);
+			if (!_rotate_ors(r, 0))
+				r = _exchange_nodes(mem, r, left, right, 0);
 			*changed = 1;
 		}
 		break;


