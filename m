From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 11 Aug 2011 19:38:01 -0000
Subject: LVM2/lib activate/dev_manager.c metadata/lv_ma ...
Message-ID: <20110811193801.19792.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2011-08-11 19:38:01

Modified files:
	lib/activate   : dev_manager.c 
	lib/metadata   : lv_manip.c 

Log message:
	Add missing checks for function return codes.
	
	Some functions were being called without having their return values checked.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.228&r2=1.229
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.272&r2=1.273

--- LVM2/lib/activate/dev_manager.c	2011/08/11 04:18:17	1.228
+++ LVM2/lib/activate/dev_manager.c	2011/08/11 19:38:00	1.229
@@ -1233,8 +1233,9 @@
 						     NULL);
 				if (!dlid)
 					return_0;
-				dm_tree_node_add_target_area(node, NULL, dlid,
-							     extent_size * seg_metale(seg, s));
+				if (!dm_tree_node_add_target_area(node, NULL, dlid,
+								  extent_size * seg_metale(seg, s)))
+					return_0;
 			}
 			if (!(dlid = build_dm_uuid(dm->mem, seg_lv(seg, s)->lvid.s, NULL)))
 				return_0;
--- LVM2/lib/metadata/lv_manip.c	2011/08/11 03:29:52	1.272
+++ LVM2/lib/metadata/lv_manip.c	2011/08/11 19:38:00	1.273
@@ -312,13 +312,22 @@
 		if (area_reduction != seg->area_len) {
 			log_error("Unable to reduce RAID LV - operation not implemented.");
 			return;
-		} else
-			lv_remove(seg_lv(seg, s));
+		} else {
+			if (!lv_remove(seg_lv(seg, s))) {
+				log_error("Failed to remove RAID image %s",
+					  seg_lv(seg, s)->name);
+				return;
+			}
+		}
 
 		/* Remove metadata area if image has been removed */
 		if (area_reduction == seg->area_len) {
-			lv_reduce(seg_metalv(seg, s),
-				  seg_metalv(seg, s)->le_count);
+			if (!lv_reduce(seg_metalv(seg, s),
+				       seg_metalv(seg, s)->le_count)) {
+				log_error("Failed to remove RAID meta-device %s",
+					  seg_metalv(seg, s)->name);
+				return;
+			}
 		}
 		return;
 	}


