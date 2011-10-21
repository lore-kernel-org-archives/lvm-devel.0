From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 21 Oct 2011 09:55:51 -0000
Subject: LVM2/lib/metadata lv_manip.c
Message-ID: <20111021095551.24350.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-21 09:55:50

Modified files:
	lib/metadata   : lv_manip.c 

Log message:
	Remove double-hack for setting metadata size
	
	Drop the second lv_extend and set 128MB directly in the first hack place.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.298&r2=1.299

--- LVM2/lib/metadata/lv_manip.c	2011/10/21 09:55:07	1.298
+++ LVM2/lib/metadata/lv_manip.c	2011/10/21 09:55:50	1.299
@@ -800,8 +800,8 @@
 		}
 	} else if (segtype_is_thin_pool(segtype)) {
 		ah->log_area_count = metadata_area_count;
-// FIXME Calculate thin metadata area size
-		ah->log_len = 1;
+// FIXME Calculate thin metadata area size (--metadatasize, or reuse --regionsize??)
+		ah->log_len = 128 * 1024 * 1024 / (512 * extent_size); /* Fixed 128MB */
 	} else {
 		ah->log_area_count = metadata_area_count;
 		ah->log_len = !metadata_area_count ? 0 :
@@ -2605,17 +2605,12 @@
 						stripes, stripe_size)))
 			goto out;
 
-		if (segtype_is_thin_pool(segtype)) {
-			/* FIXME: resize metadata size here for now */
-			struct logical_volume *tmeta = first_seg(lv)->pool_metadata_lv;
-			if ((r = lv_add_segment(ah, ah->area_count, 1, tmeta,
-						get_segtype_from_string(lv->vg->cmd, "striped"), 0, 0, 0))) {
-				if (!(r = lv_extend(tmeta, first_seg(tmeta)->segtype,
-						    1, 0, 1, 0, 10, NULL, allocatable_pvs, ALLOC_INHERIT)))
-					stack;
-			} else
-				stack;
-		}
+		if (segtype_is_thin_pool(segtype) &&
+		    !(r = lv_add_segment(ah, ah->area_count, 1,
+					 first_seg(lv)->pool_metadata_lv,
+					 get_segtype_from_string(lv->vg->cmd,
+								 "striped"), 0, 0, 0)))
+			goto_out;
 
 		/*
 		 * If we are expanding an existing mirror, we can skip the


