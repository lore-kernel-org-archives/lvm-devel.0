From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 15 Nov 2011 17:25:06 -0000
Subject: LVM2/lib/activate dev_manager.c
Message-ID: <20111115172506.26101.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-11-15 17:25:05

Modified files:
	lib/activate   : dev_manager.c 

Log message:
	Thin clean
	
	Reuse seg pointer already set in _add_lv_to_dtree to have the
	value of first_seg(lv) (and is used in other parts of this function).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.250&r2=1.251

--- LVM2/lib/activate/dev_manager.c	2011/11/15 17:21:02	1.250
+++ LVM2/lib/activate/dev_manager.c	2011/11/15 17:25:05	1.251
@@ -1100,17 +1100,16 @@
 		return_0;
 
 	if (lv_is_thin_pool(lv)) {
-		if (!_add_dev_to_dtree(dm, dtree, lv, "tpool"))
-			return_0;
-		if (!_add_lv_to_dtree(dm, dtree, first_seg(lv)->pool_metadata_lv, origin_only))
+		if (!_add_lv_to_dtree(dm, dtree, seg->pool_metadata_lv, origin_only))
 			return_0;
 		/* FIXME code from _create_partial_dtree() should be moved here */
-		if (!_add_lv_to_dtree(dm, dtree, seg_lv(first_seg(lv), 0), origin_only))
+		if (!_add_lv_to_dtree(dm, dtree, seg_lv(seg, 0), origin_only))
 			return_0;
-	} else if (lv_is_thin_volume(lv)) {
-		if (!_add_lv_to_dtree(dm, dtree, first_seg(lv)->pool_lv, origin_only))
+		if (!_add_dev_to_dtree(dm, dtree, lv, "tpool"))
 			return_0;
-	}
+	} else if (lv_is_thin_volume(lv) &&
+		   !_add_lv_to_dtree(dm, dtree, seg->pool_lv, origin_only))
+		return_0;
 
 	return 1;
 }


