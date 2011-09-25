From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 25 Sep 2011 19:38:59 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/libdm-config.c
Message-ID: <20110925193859.17068.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-09-25 19:38:59

Modified files:
	.              : WHATS_NEW_DM 
	libdm          : libdm-config.c 

Log message:
	Use  NULL for pointers

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.506&r2=1.507
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-config.c.diff?cvsroot=lvm2&r1=1.6&r2=1.7

--- LVM2/WHATS_NEW_DM	2011/09/23 09:51:37	1.506
+++ LVM2/WHATS_NEW_DM	2011/09/25 19:38:59	1.507
@@ -1,5 +1,6 @@
 Version 1.02.68 -
 ==================================
+  Improve libdm-config error path reporting.
   Update dmsetup resume man with --addnodeonresume/create options.
   Add dependency for dm man pages to man subdirectory make target all:.
   Add dm_tree_retry_remove to use retry logic for device removal in a dm_tree.
--- LVM2/libdm/libdm-config.c	2011/09/02 01:32:09	1.6
+++ LVM2/libdm/libdm-config.c	2011/09/25 19:38:59	1.7
@@ -523,7 +523,7 @@
 	struct dm_config_node *root = NULL, *n, *l = NULL;
 	while (p->t != TOK_EOF) {
 		if (!(n = _section(p)))
-			return_0;
+			return_NULL;
 
 		if (!root)
 			root = n;
@@ -540,10 +540,10 @@
 	/* IDENTIFIER SECTION_B_CHAR VALUE* SECTION_E_CHAR */
 	struct dm_config_node *root, *n, *l = NULL;
 	if (!(root = _create_node(p->mem)))
-		return_0;
+		return_NULL;
 
 	if (!(root->key = _dup_tok(p)))
-		return_0;
+		return_NULL;
 
 	match(TOK_IDENTIFIER);
 
@@ -551,7 +551,7 @@
 		match(TOK_SECTION_B);
 		while (p->t != TOK_SECTION_E) {
 			if (!(n = _section(p)))
-				return_0;
+				return_NULL;
 
 			if (!root->child)
 				root->child = n;
@@ -564,7 +564,7 @@
 	} else {
 		match(TOK_EQ);
 		if (!(root->v = _value(p)))
-			return_0;
+			return_NULL;
 	}
 
 	return root;
@@ -578,7 +578,7 @@
 		match(TOK_ARRAY_B);
 		while (p->t != TOK_ARRAY_E) {
 			if (!(l = _type(p)))
-				return_0;
+				return_NULL;
 
 			if (!h)
 				h = l;
@@ -595,7 +595,7 @@
 		 */
 		if (!h) {
 			if (!(h = _create_value(p->mem)))
-				return NULL;
+				return_NULL;
 
 			h->type = DM_CFG_EMPTY_ARRAY;
 		}
@@ -633,7 +633,7 @@
 
 		p->tb++, p->te--;	/* strip "'s */
 		if (!(v->v.str = _dup_tok(p)))
-			return_0;
+			return_NULL;
 		p->te++;
 		match(TOK_STRING);
 		break;
@@ -643,7 +643,7 @@
 
 		p->tb++, p->te--;	/* strip "'s */
 		if (!(str = _dup_tok(p)))
-			return_0;
+			return_NULL;
 		dm_unescape_double_quotes(str);
 		v->v.str = str;
 		p->te++;
@@ -653,7 +653,7 @@
 	default:
 		log_error("Parse error at byte %" PRIptrdiff_t " (line %d): expected a value",
 			  p->tb - p->fb + 1, p->line);
-		return 0;
+		return NULL;
 	}
 	return v;
 }


