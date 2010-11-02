From: agk@sourceware.org <agk@sourceware.org>
Date: 2 Nov 2010 19:56:34 -0000
Subject: LVM2 ./WHATS_NEW libdm/regex/parse_rx.c
Message-ID: <20101102195634.18032.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-11-02 19:56:33

Modified files:
	.              : WHATS_NEW 
	libdm/regex    : parse_rx.c 

Log message:
	Fix regex optimiser not to ignore RHS of OR nodes in _find_leftmost_common.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1786&r2=1.1787
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/regex/parse_rx.c.diff?cvsroot=lvm2&r1=1.13&r2=1.14

--- LVM2/WHATS_NEW	2010/11/01 14:17:35	1.1786
+++ LVM2/WHATS_NEW	2010/11/02 19:56:33	1.1787
@@ -1,5 +1,6 @@
 Version 2.02.76 - 
 ===================================
+  Fix regex optimiser not to ignore RHS of OR nodes in _find_leftmost_common.
   Fix handling of online filesystem resize (using new fsadm return code).
   Add DIAGNOSTICS section to fsadm man page.
   Modify fsadm to return different status code for check of mounted filesystem.
--- LVM2/libdm/regex/parse_rx.c	2010/08/09 10:29:42	1.13
+++ LVM2/libdm/regex/parse_rx.c	2010/11/02 19:56:33	1.14
@@ -473,16 +473,19 @@
 	unsigned left_depth = _depth(left, leftmost);
 	unsigned right_depth = _depth(right, leftmost);
 
-	while (left_depth > right_depth) {
+	while (left_depth > right_depth && left->type != OR) {
 		left = LEFT(left);
 		left_depth--;
 	}
 
-	while (right_depth > left_depth) {
+	while (right_depth > left_depth && right->type != OR) {
 		right = LEFT(right);
 		right_depth--;
 	}
 
+	if (left_depth != right_depth)
+		return 0;
+
 	while (left_depth) {
 		if (left->type == CAT && right->type == CAT) {
 			if (_nodes_equal(LEFT(left), LEFT(right))) {
@@ -491,6 +494,8 @@
 				return 1;
 			}
 		}
+		if (left->type == OR || right->type == OR)
+			break;
 		left = LEFT(left);
 		right = LEFT(right);
 		left_depth--;
@@ -568,7 +573,6 @@
 	case QUEST:
 		if (!(r->left = _pass(mem, r->left, changed)))
 			return_NULL;
-		break;
 
 	case OR:
 		/* It's important we optimise sub nodes first */
@@ -577,7 +581,6 @@
 
 		if (!(r->right = _pass(mem, r->right, changed)))
 			return_NULL;
-
 		/*
 		 * If rotate_ors changes the tree, left and right are stale,
 		 * so just set 'changed' to repeat the search.


