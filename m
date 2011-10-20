From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 20 Oct 2011 10:31:28 -0000
Subject: LVM2 lib/thin/thin.c libdm/libdevmapper.h libd ...
Message-ID: <20111020103128.29721.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-20 10:31:27

Modified files:
	lib/thin       : thin.c 
	libdm          : libdevmapper.h libdm-deptree.c 

Log message:
	Use const pointers in thin API were appropriate

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/thin/thin.c.diff?cvsroot=lvm2&r1=1.20&r2=1.21
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.162&r2=1.163
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.134&r2=1.135

--- LVM2/lib/thin/thin.c	2011/10/20 10:30:39	1.20
+++ LVM2/lib/thin/thin.c	2011/10/20 10:31:27	1.21
@@ -150,7 +150,7 @@
 static int _thin_pool_text_export(const struct lv_segment *seg, struct formatter *f)
 {
 	unsigned cnt = 0;
-	struct lv_thin_message *tmsg;
+	const struct lv_thin_message *tmsg;
 
 	outf(f, "pool = \"%s\"", seg_lv(seg, 0)->name);
 	outf(f, "metadata = \"%s\"", seg->pool_metadata_lv->name);
@@ -220,7 +220,7 @@
 				      uint32_t *pvmove_mirror_count __attribute__((unused)))
 {
 	char *metadata_dlid, *pool_dlid;
-	struct lv_thin_message *lmsg;
+	const struct lv_thin_message *lmsg;
 	struct dm_thin_message dmsg;
 
 	if (!(metadata_dlid = build_dm_uuid(mem, seg->pool_metadata_lv->lvid.s, NULL))) {
--- LVM2/libdm/libdevmapper.h	2011/10/20 10:28:42	1.162
+++ LVM2/libdm/libdevmapper.h	2011/10/20 10:31:27	1.163
@@ -589,7 +589,7 @@
 };
 
 int dm_tree_node_add_thin_pool_message(struct dm_tree_node *node,
-                                       struct dm_thin_message *message);
+                                       const struct dm_thin_message *message);
 
 int dm_tree_node_add_thin_target(struct dm_tree_node *node,
 				 uint64_t size,
--- LVM2/libdm/libdm-deptree.c	2011/10/20 10:28:42	1.134
+++ LVM2/libdm/libdm-deptree.c	2011/10/20 10:31:27	1.135
@@ -2874,7 +2874,7 @@
 }
 
 int dm_tree_node_add_thin_pool_message(struct dm_tree_node *node,
-				       struct dm_thin_message *message)
+				       const struct dm_thin_message *message)
 {
 	struct load_segment *seg;
 	struct thin_message *tm;


