From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 3 Nov 2011 14:57:05 -0000
Subject: LVM2/lib/metadata metadata-exported.h thin_manip.c
Message-ID: <20111103145705.32691.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-11-03 14:57:04

Modified files:
	lib/metadata   : metadata-exported.h thin_manip.c 

Log message:
	Thin removing unused detach_pool_messages

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.220&r2=1.221
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/thin_manip.c.diff?cvsroot=lvm2&r1=1.20&r2=1.21

--- LVM2/lib/metadata/metadata-exported.h	2011/11/03 14:53:58	1.220
+++ LVM2/lib/metadata/metadata-exported.h	2011/11/03 14:57:04	1.221
@@ -558,8 +558,6 @@
 uint64_t extents_from_size(struct cmd_context *cmd, uint64_t size,
 			   uint32_t extent_size);
 
-int detach_pool_messages(struct logical_volume *pool_lv);
-
 int update_pool_lv(struct logical_volume *lv, int activate);
 
 /*
--- LVM2/lib/metadata/thin_manip.c	2011/11/03 14:53:58	1.20
+++ LVM2/lib/metadata/thin_manip.c	2011/11/03 14:57:04	1.21
@@ -148,26 +148,6 @@
 	return 1;
 }
 
-int detach_pool_messages(struct logical_volume *pool_lv)
-{
-	if (!lv_is_thin_pool(pool_lv)) {
-		log_error(INTERNAL_ERROR "LV %s is not a thin pool.",
-			  pool_lv->name);
-		return 0;
-	}
-
-	if (!dm_list_empty(&first_seg(pool_lv)->thin_messages)) {
-		dm_list_init(&first_seg(pool_lv)->thin_messages);
-
-		if (!vg_write(pool_lv->vg) || !vg_commit(pool_lv->vg))
-			return_0;
-
-		backup(pool_lv->vg);
-	}
-
-	return 1;
-}
-
 struct lv_segment *find_pool_seg(const struct lv_segment *seg)
 {
 	struct lv_segment *pool_seg;


