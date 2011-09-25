From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 25 Sep 2011 19:43:44 -0000
Subject: LVM2/libdm libdm-config.c
Message-ID: <20110925194344.18116.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-09-25 19:43:43

Modified files:
	libdm          : libdm-config.c 

Log message:
	Add missing log_error messages

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-config.c.diff?cvsroot=lvm2&r1=1.11&r2=1.12

--- LVM2/libdm/libdm-config.c	2011/09/25 19:42:45	1.11
+++ LVM2/libdm/libdm-config.c	2011/09/25 19:43:43	1.12
@@ -543,8 +543,10 @@
 {
 	/* IDENTIFIER SECTION_B_CHAR VALUE* SECTION_E_CHAR */
 	struct dm_config_node *root, *n, *l = NULL;
-	if (!(root = _create_node(p->mem)))
-		return_NULL;
+	if (!(root = _create_node(p->mem))) {
+		log_error("Failed to allocate section node");
+		return NULL;
+	}
 
 	if (!(root->key = _dup_tok(p)))
 		return_NULL;
@@ -598,8 +600,10 @@
 		 * Special case for an empty array.
 		 */
 		if (!h) {
-			if (!(h = _create_value(p->mem)))
-				return_NULL;
+			if (!(h = _create_value(p->mem))) {
+				log_error("Failed to allocate value");
+				return NULL;
+			}
 
 			h->type = DM_CFG_EMPTY_ARRAY;
 		}
@@ -617,8 +621,10 @@
 	struct dm_config_value *v = _create_value(p->mem);
 	char *str;
 
-	if (!v)
+	if (!v) {
+		log_error("Failed to allocate type value");
 		return NULL;
+	}
 
 	switch (p->t) {
 	case TOK_INT:
@@ -1251,8 +1257,10 @@
 {
 	struct dm_config_node *new_cn;
 
-	if (!cn)
+	if (!cn) {
+		log_error("Cannot clone NULL config node.");
 		return NULL;
+	}
 
 	if (!(new_cn = _create_node(mem))) {
 		log_error("Failed to clone config node.");


