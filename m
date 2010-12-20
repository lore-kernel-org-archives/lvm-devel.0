From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 20 Dec 2010 13:19:15 -0000
Subject: LVM2/lib config/config.c datastruct/btree.c fo ...
Message-ID: <20101220131915.12405.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-12-20 13:19:14

Modified files:
	lib/config     : config.c 
	lib/datastruct : btree.c 
	lib/format_pool: format_pool.c 
	lib/format_text: import.c 
	lib/metadata   : metadata.h 

Log message:
	Some const cleanups
	
	Minor const warning fixes and internal API updates.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/config.c.diff?cvsroot=lvm2&r1=1.85&r2=1.86
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/datastruct/btree.c.diff?cvsroot=lvm2&r1=1.13&r2=1.14
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/format_pool.c.diff?cvsroot=lvm2&r1=1.33&r2=1.34
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import.c.diff?cvsroot=lvm2&r1=1.51&r2=1.52
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.225&r2=1.226

--- LVM2/lib/config/config.c	2010/12/20 13:12:56	1.85
+++ LVM2/lib/config/config.c	2010/12/20 13:19:13	1.86
@@ -239,8 +239,8 @@
 	}
 
 	if (checksum_fn && checksum !=
-	    (checksum_fn(checksum_fn(INITIAL_CRC, (uint8_t *)p->fb, size),
-			 (uint8_t *)(p->fb + size), size2))) {
+	    (checksum_fn(checksum_fn(INITIAL_CRC, (const uint8_t *)p->fb, size),
+			 (const uint8_t *)(p->fb + size), size2))) {
 		log_error("%s: Checksum error", dev_name(dev));
 		goto out;
 	}
--- LVM2/lib/datastruct/btree.c	2008/01/30 13:59:58	1.13
+++ LVM2/lib/datastruct/btree.c	2010/12/20 13:19:13	1.14
@@ -103,7 +103,7 @@
 
 void *btree_get_data(const struct btree_iter *it)
 {
-	return ((struct node *) it)->data;
+	return ((const struct node *) it)->data;
 }
 
 static struct node *_left(struct node *n)
--- LVM2/lib/format_pool/format_pool.c	2010/10/05 17:34:06	1.33
+++ LVM2/lib/format_pool/format_pool.c	2010/12/20 13:19:14	1.34
@@ -75,7 +75,7 @@
 	return usp;
 }
 
-static int _check_usp(char *vgname, struct user_subpool *usp, int sp_count)
+static int _check_usp(const char *vgname, struct user_subpool *usp, int sp_count)
 {
 	int i;
 	unsigned j;
--- LVM2/lib/format_text/import.c	2010/08/03 13:06:35	1.51
+++ LVM2/lib/format_text/import.c	2010/12/20 13:19:14	1.52
@@ -131,7 +131,7 @@
 				 when, desc);
 }
 
-struct volume_group *import_vg_from_buffer(char *buf,
+struct volume_group *import_vg_from_buffer(const char *buf,
                                            struct format_instance *fid)
 {
 	struct volume_group *vg = NULL;
--- LVM2/lib/metadata/metadata.h	2010/12/10 22:39:55	1.225
+++ LVM2/lib/metadata/metadata.h	2010/12/20 13:19:14	1.226
@@ -386,7 +386,7 @@
  * For internal metadata caching.
  */
 int export_vg_to_buffer(struct volume_group *vg, char **buf);
-struct volume_group *import_vg_from_buffer(char *buf,
+struct volume_group *import_vg_from_buffer(const char *buf,
 					   struct format_instance *fid);
 
 /*


