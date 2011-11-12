From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 12 Nov 2011 22:52:18 -0000
Subject: LVM2/lib/metadata lv_manip.c
Message-ID: <20111112225218.28794.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-11-12 22:52:18

Modified files:
	lib/metadata   : lv_manip.c 

Log message:
	Thin use items iterator and stack reporting

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.331&r2=1.332

--- LVM2/lib/metadata/lv_manip.c	2011/11/12 22:51:20	1.331
+++ LVM2/lib/metadata/lv_manip.c	2011/11/12 22:52:18	1.332
@@ -3235,6 +3235,7 @@
 				const force_t force, unsigned level)
 {
 	struct dm_list *snh, *snht;
+	struct seg_list *sl, *tsl;
 
 	if (lv_is_cow(lv)) {
 		/* A merging snapshot cannot be removed directly */
@@ -3263,12 +3264,11 @@
 			log_error("Logical volume %s not removed.", lv->name);
 			return 0;
 		}
-		dm_list_iterate_safe(snh, snht, &lv->segs_using_this_lv) {
-			if (!lv_remove_with_dependencies(cmd,
-							 dm_list_item(snh, struct seg_list)->seg->lv,
+
+		dm_list_iterate_items_safe(sl, tsl, &lv->segs_using_this_lv)
+			if (!lv_remove_with_dependencies(cmd, sl->seg->lv,
 							 force, level + 1))
-				return 0;
-		}
+				return_0;
 	}
 
 	return lv_remove_single(cmd, lv, force);


