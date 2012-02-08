From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 8 Feb 2012 11:12:18 -0000
Subject: LVM2 ./WHATS_NEW lib/label/label.c
Message-ID: <20120208111218.29797.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-08 11:12:18

Modified files:
	.              : WHATS_NEW 
	lib/label      : label.c 

Log message:
	Use dm_list_iterate_items_safe
	
	And avoid direct access to list member variables.
	Inline _free_li().

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2263&r2=1.2264
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/label/label.c.diff?cvsroot=lvm2&r1=1.54&r2=1.55

--- LVM2/WHATS_NEW	2012/02/08 11:05:04	1.2263
+++ LVM2/WHATS_NEW	2012/02/08 11:12:18	1.2264
@@ -1,5 +1,6 @@
 Version 2.02.91 -
 ===================================
+  Use list functions for label_exit().
   Ensure strncpy() function always ends with '\0'.
   Set status in _fsadm_cmd() for error path.
   Add missing deps for lvm2api for rebuild when lvm-internal is changed.
--- LVM2/lib/label/label.c	2011/06/01 15:30:36	1.54
+++ LVM2/lib/label/label.c	2012/02/08 11:12:18	1.55
@@ -56,11 +56,6 @@
 	return li;
 }
 
-static void _free_li(struct labeller_i *li)
-{
-	dm_free(li);
-}
-
 int label_init(void)
 {
 	dm_list_init(&_labellers);
@@ -69,14 +64,12 @@
 
 void label_exit(void)
 {
-	struct dm_list *c, *n;
-	struct labeller_i *li;
+	struct labeller_i *li, *tli;
 
-	for (c = _labellers.n; c && c != &_labellers; c = n) {
-		n = c->n;
-		li = dm_list_item(c, struct labeller_i);
+	dm_list_iterate_items_safe(li, tli, &_labellers) {
+		dm_list_del(&li->list);
 		li->l->ops->destroy(li->l);
-		_free_li(li);
+		dm_free(li);
 	}
 
 	dm_list_init(&_labellers);


