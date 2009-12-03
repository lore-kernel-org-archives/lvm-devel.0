From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 3 Dec 2009 10:01:30 -0000
Subject: LVM2/lib/activate dev_manager.c
Message-ID: <20091203100130.15396.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2009-12-03 10:01:30

Modified files:
	lib/activate   : dev_manager.c 

Log message:
	minor indent change

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.165&r2=1.166

--- LVM2/lib/activate/dev_manager.c	2009/12/03 09:59:54	1.165
+++ LVM2/lib/activate/dev_manager.c	2009/12/03 10:01:30	1.166
@@ -971,7 +971,8 @@
 		/* Add any LVs used by this segment */
 		for (s = 0; s < seg->area_count; s++)
 			if ((seg_type(seg, s) == AREA_LV) &&
-			    (!_add_new_lv_to_dtree(dm, dtree, seg_lv(seg, s), NULL)))
+			    (!_add_new_lv_to_dtree(dm, dtree, seg_lv(seg, s),
+						   NULL)))
 				return_0;
 	}
 
@@ -1018,7 +1019,8 @@
 		return 1;
 
 	if (!(lvlayer = dm_pool_alloc(dm->mem, sizeof(*lvlayer)))) {
-		log_error("_add_new_lv_to_dtree: pool alloc failed for %s %s.", lv->name, layer);
+		log_error("_add_new_lv_to_dtree: pool alloc failed for %s %s.",
+			  lv->name, layer);
 		return 0;
 	}
 


