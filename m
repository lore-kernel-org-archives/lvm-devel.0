From: agk@sourceware.org <agk@sourceware.org>
Date: 22 Apr 2010 03:24:27 -0000
Subject: LVM2/libdm/regex parse_rx.c
Message-ID: <20100422032427.31640.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-04-22 03:24:25

Modified files:
	libdm/regex    : parse_rx.c 

Log message:
	Still not satisfactory...

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/regex/parse_rx.c.diff?cvsroot=lvm2&r1=1.4&r2=1.5

--- LVM2/libdm/regex/parse_rx.c	2010/04/20 22:31:22	1.4
+++ LVM2/libdm/regex/parse_rx.c	2010/04/22 03:24:24	1.5
@@ -331,17 +331,19 @@
 
 /*----------------------------------------------------------------*/
 
+#define L_OR_R(a) (leftmost ? (a)->left : (a)->right)
+
 /*
  * The optimiser spots common prefixes on either side of an 'or' node, and
  * lifts them outside the 'or' with a 'cat'.
  */
-static unsigned _leftmost_depth(struct rx_node *r)
+static unsigned _depth(struct rx_node *r, unsigned leftmost)
 {
 	int count = 1;
 
 	while (r->type != CHARSET) {
 		count++;
-		r = r->left;
+		r = L_OR_R(r);
 	}
 
 	return count;
@@ -378,38 +380,69 @@
 
 static int _find_leftmost_common(struct rx_node *or,
                                  struct rx_node **l,
-                                 struct rx_node **r)
+                                 struct rx_node **r,
+				 unsigned leftmost)
 {
 	struct rx_node *left = or->left, *right = or->right;
-	unsigned left_depth = _leftmost_depth(left);
-	unsigned right_depth = _leftmost_depth(right);
+	unsigned left_depth = _depth(left, leftmost);
+	unsigned right_depth = _depth(right, leftmost);
 
 	while (left_depth > right_depth) {
-		left = left->left;
+		left = L_OR_R(left);
 		left_depth--;
 	}
 
 	while (right_depth > left_depth) {
-		right = right->left;
+		right = L_OR_R(right);
 		right_depth--;
 	}
 
 	while (left_depth) {
 		if (left->type == CAT && right->type == CAT) {
-			if (_nodes_equal(left->left, right->left)) {
+			if (_nodes_equal(L_OR_R(left), L_OR_R(right))) {
 				*l = left;
 				*r = right;
 				return 1;
 			}
 		}
-		left = left->left;
-		right = right->left;
+		left = L_OR_R(left);
+		right = L_OR_R(right);
 		left_depth--;
 	}
 
 	return 0;
 }
 
+static struct rx_node *_exchange_nodes(struct dm_pool *mem, struct rx_node *r, struct rx_node *left_cat, struct rx_node *right_cat, unsigned leftmost)
+{
+	struct rx_node *new_r, *new_cat;
+
+	/* FIXME Clean up leftmost */
+	if (leftmost) {
+		new_r = r->right;
+		new_cat = _node(mem, CAT, left_cat->left, r);
+		if (!new_cat)
+			return_NULL;
+		new_r->left = new_cat;
+
+		memcpy(left_cat, left_cat->right, sizeof(*left_cat));
+		r->right = right_cat->right;
+
+		/* FIXME Avoid this */
+		if (new_r->right == right_cat->right)
+			new_r = new_r->left;
+	} else {
+		new_r = _node(mem, CAT, r, right_cat->right);
+		if (!new_r)
+			return_NULL;
+
+		memcpy(left_cat, left_cat->left, sizeof(*left_cat));
+		memcpy(right_cat, right_cat->left, sizeof(*right_cat));
+	}
+
+	return new_r;
+}
+
 static struct rx_node *_pass(struct dm_pool *mem,
                              struct rx_node *r,
                              int *changed)
@@ -445,16 +478,12 @@
 		{
 			struct rx_node *left, *right;
 
-			if (_find_leftmost_common(r, &left, &right)) {
-				struct rx_node *new_r = _node(mem, CAT, left->left, r);
+			if (_find_leftmost_common(r, &left, &right, 1)) {
+				r = _exchange_nodes(mem, r, left, right, 1);
 
-				if (!new_r)
-					return_NULL;
-
-				memcpy(left, left->right, sizeof(*left));
-				memcpy(right, right->right, sizeof(*right));
-
-				r = new_r;
+				*changed = 1;
+			} else if (_find_leftmost_common(r, &left, &right, 0)) {
+				r = _exchange_nodes(mem, r, left, right, 0);
 
 				*changed = 1;
 			}
@@ -473,6 +502,8 @@
 	/*
 	 * We're looking for (or (... (cat <foo> a)) (... (cat <foo> b)))
 	 * and want to turn it into (cat <foo> (or (... a) (... b)))
+	 *
+	 * (fa)|(fb) becomes f(a|b)
 	 */
 
 	/*


