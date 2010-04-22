From: agk@sourceware.org <agk@sourceware.org>
Date: 22 Apr 2010 13:18:29 -0000
Subject: LVM2/libdm/regex parse_rx.c
Message-ID: <20100422131829.14207.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-04-22 13:18:27

Modified files:
	libdm/regex    : parse_rx.c 

Log message:
	fix leftmost rotation

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/regex/parse_rx.c.diff?cvsroot=lvm2&r1=1.5&r2=1.6

--- LVM2/libdm/regex/parse_rx.c	2010/04/22 03:24:24	1.5
+++ LVM2/libdm/regex/parse_rx.c	2010/04/22 13:18:27	1.6
@@ -16,6 +16,8 @@
 #include "dmlib.h"
 #include "parse_rx.h"
 
+#include <ctype.h>
+
 struct parse_sp {		/* scratch pad for the parsing process */
 	struct dm_pool *mem;
 	int type;		/* token type, 0 indicates a charset */
@@ -413,24 +415,36 @@
 	return 0;
 }
 
-static struct rx_node *_exchange_nodes(struct dm_pool *mem, struct rx_node *r, struct rx_node *left_cat, struct rx_node *right_cat, unsigned leftmost)
+/* If top node is OR, rotate from ((ab)|((ac)|d)) to (((ab)|(ac))|d) */
+static int _rotate_ors(struct rx_node *r)
+{
+	struct rx_node *old_r_right;
+
+	if (r->type == OR && r->right->type == OR) {
+		old_r_right = r->right;
+		r->right = old_r_right->right;
+		old_r_right->right = old_r_right->left;
+		old_r_right->left = r->left;
+		r->left = old_r_right;
+		return 1;
+	}
+
+	return 0;
+}
+
+static struct rx_node *_exchange_nodes(struct dm_pool *mem, struct rx_node *r,
+				       struct rx_node *left_cat, struct rx_node *right_cat,
+				       unsigned leftmost)
 {
-	struct rx_node *new_r, *new_cat;
+	struct rx_node *new_r;
 
-	/* FIXME Clean up leftmost */
 	if (leftmost) {
-		new_r = r->right;
-		new_cat = _node(mem, CAT, left_cat->left, r);
-		if (!new_cat)
+		new_r = _node(mem, CAT, left_cat->left, r);
+		if (!new_r)
 			return_NULL;
-		new_r->left = new_cat;
 
 		memcpy(left_cat, left_cat->right, sizeof(*left_cat));
-		r->right = right_cat->right;
-
-		/* FIXME Avoid this */
-		if (new_r->right == right_cat->right)
-			new_r = new_r->left;
+		memcpy(right_cat, right_cat->right, sizeof(*right_cat));
 	} else {
 		new_r = _node(mem, CAT, r, right_cat->right);
 		if (!new_r)
@@ -447,6 +461,8 @@
                              struct rx_node *r,
                              int *changed)
 {
+	struct rx_node *left, *right;
+
 	/*
 	 * walk the tree, optimising every 'or' node.
 	 */
@@ -475,18 +491,17 @@
 		if (!(r->right = _pass(mem, r->right, changed)))
 			return_NULL;
 
-		{
-			struct rx_node *left, *right;
-
-			if (_find_leftmost_common(r, &left, &right, 1)) {
+		if (_find_leftmost_common(r, &left, &right, 1)) {
+			/*
+			 * If rotate_ors changes the tree, left and right are stale,
+			 * so just set 'changed' to repeat the search.
+			 */
+			if (!_rotate_ors(r))
 				r = _exchange_nodes(mem, r, left, right, 1);
-
-				*changed = 1;
-			} else if (_find_leftmost_common(r, &left, &right, 0)) {
-				r = _exchange_nodes(mem, r, left, right, 0);
-
-				*changed = 1;
-			}
+			*changed = 1;
+		} else if (_find_leftmost_common(r, &left, &right, 0)) {
+			r = _exchange_nodes(mem, r, left, right, 0);
+			*changed = 1;
 		}
 		break;
 


