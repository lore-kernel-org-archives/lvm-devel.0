From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 9 Jul 2010 17:57:52 -0000
Subject: LVM2/lib/metadata mirror.c
Message-ID: <20100709175752.32205.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2010-07-09 17:57:52

Modified files:
	lib/metadata   : mirror.c 

Log message:
	Failed to test for the case where a log was requested to be removed
	even though there was no log.  A simple run through the in-tree test
	suite would have caught this.  :(
	
	-               if (lv_is_mirrored(detached_log_lv) &&
	+               if (detached_log_lv && lv_is_mirrored(detached_log_lv) &&
	
	Also, made some cosmetic changes suggested by kabi after my last check-in
	(e.g. s/return 0/return_0/ and adding an error message).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.124&r2=1.125

--- LVM2/lib/metadata/mirror.c	2010/07/09 15:34:45	1.124
+++ LVM2/lib/metadata/mirror.c	2010/07/09 17:57:51	1.125
@@ -879,7 +879,7 @@
 		 * have failed, we must replace with error target - it is
 		 * the only way to release the pending writes.
 		 */
-		if (lv_is_mirrored(detached_log_lv) &&
+		if (detached_log_lv && lv_is_mirrored(detached_log_lv) &&
 		    (detached_log_lv->status & PARTIAL_LV)) {
 			struct lv_segment *seg = first_seg(detached_log_lv);
 
@@ -896,8 +896,10 @@
 				seg_lv(seg, m)->status &= ~MIRROR_IMAGE;
 				lv_set_visible(seg_lv(seg, m));
 				if (!(lvl = dm_pool_alloc(lv->vg->cmd->mem,
-							  sizeof(*lvl))))
+							  sizeof(*lvl)))) {
+					log_error("dm_pool_alloc failed");
 					return 0;
+				}
 				lvl->lv = seg_lv(seg, m);
 				dm_list_add(&tmp_orphan_lvs, &lvl->list);
 			}
@@ -905,7 +907,7 @@
 			if (!replace_lv_with_error_segment(detached_log_lv)) {
 				log_error("Failed error target substitution for %s",
 					  detached_log_lv->name);
-				return_0;
+				return 0;
 			}
 
 			if (!vg_write(detached_log_lv->vg)) {
@@ -926,7 +928,7 @@
 
 			if (!resume_lv(detached_log_lv->vg->cmd,
 				       detached_log_lv))
-					return 0;
+					return_0;
 		}
 	}
 


