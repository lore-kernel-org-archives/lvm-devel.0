From: Takahiro Yasui <takahiro.yasui@hds.com>
Date: Mon, 19 Jul 2010 18:09:43 -0400
Subject: [PATCH] Handle a failure of all mirror devices but one mirror leg
Message-ID: <5C30BE7ED8B03E448B2E104602D4848A5922886542@USINDEVS02.corp.hds.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hello,

To handle a double failure of a mirrored log, Jon's two patches are
commited, however, lvconvert command can't still handle an error
when mirror leg and mirrored log got failure at the same time.

  [Patch]: Handle both devices of a mirrored log failing (bug 607347)
  posted: https://www.redhat.com/archives/lvm-devel/2010-July/msg00009.html
  commit: https://www.redhat.com/archives/lvm-devel/2010-July/msg00027.html

  [Patch]: Handle both devices of a mirrored log failing (bug 607347) -
           additional fix
  posted: https://www.redhat.com/archives/lvm-devel/2010-July/msg00093.html
  commit: https://www.redhat.com/archives/lvm-devel/2010-July/msg00101.html

In the second patch, the target type of mirrored log is replaced with                                                        
error target when remove_log is set to 1, but this procedure should be                                                       
also used in other cases such as the number of mirror leg is 1. This                                                         
patch relocates the procedure to the main path.

In addition, I added following three changes.

- Removed tmp_orphan_lvs handling procedure
  It seems that _delete_lv() can handle detached_log_lv properly
  without adding mirror legs in mirrored log to tmp_orphan_lvs.
  Therefore, I removed the procedure.

- Removed vg_write()/vg_commit()
  Metadata is saved by vg_write()/vg_commit() just after detached_log_lv
  is handled. Therefore, I removed vg_write()/vg_commit().

- With Jon's second patch, we think that we don't have to call
  remove_mirror_log() in _lv_update_mirrored_log() because will be
  handled remove_mirror_images() in _lvconvert_mirrors_repaire().

Appreciate your reviews and comments.

Thanks,
Taka


Signed-off-by: Takahiro Yasui <takahiro.yasui@hds.com>
---
 lib/metadata/mirror.c |   96 ++++++++++++++++++--------------------------------
 tools/lvconvert.c     |   16 +++++---
 2 files changed, 46 insertions(+), 66 deletions(-)

Index: LVM2-2.02.71-20100714/lib/metadata/mirror.c
===================================================================
--- LVM2-2.02.71-20100714.orig/lib/metadata/mirror.c
+++ LVM2-2.02.71-20100714/lib/metadata/mirror.c
@@ -872,71 +872,47 @@ static int _remove_mirror_images(struct 
 		lv->status &= ~MIRROR_NOTSYNCED;
 		if (!replace_lv_with_error_segment(lv))
 			return_0;
-	} else if (remove_log) {
+	} else if (remove_log)
 		detached_log_lv = detach_mirror_log(mirrored_seg);
 
+	/*
+	 * The log may be removed due to repair.  If the log
+	 * happens to be a mirrored log, then there is a special
+	 * case we need to consider.  One of the images of a
+	 * mirrored log can fail followed shortly afterwards by
+	 * a failure of the second.  This means that the top-level
+	 * mirror is waiting for writes to the log to finish, but
+	 * they never will unless the mirrored log can be repaired
+	 * or replaced with an error target.  Since both the devices
+	 * have failed, we must replace with error target - it is
+	 * the only way to release the pending writes.
+	 */
+	if (detached_log_lv && lv_is_mirrored(detached_log_lv) &&
+	    (detached_log_lv->status & PARTIAL_LV)) {
+		log_very_verbose("%s being removed due to failures",
+				 detached_log_lv->name);
+
+		if (!replace_lv_with_error_segment(detached_log_lv)) {
+			log_error("Failed error target substitution for %s",
+				  detached_log_lv->name);
+			return 0;
+		}
+
 		/*
-		 * The log may be removed due to repair.  If the log
-		 * happens to be a mirrored log, then there is a special
-		 * case we need to consider.  One of the images of a
-		 * mirrored log can fail followed shortly afterwards by
-		 * a failure of the second.  This means that the top-level
-		 * mirror is waiting for writes to the log to finish, but
-		 * they never will unless the mirrored log can be repaired
-		 * or replaced with an error target.  Since both the devices
-		 * have failed, we must replace with error target - it is
-		 * the only way to release the pending writes.
+		 * Flush all I/Os holded by mirrored log.
 		 */
-		if (detached_log_lv && lv_is_mirrored(detached_log_lv) &&
-		    (detached_log_lv->status & PARTIAL_LV)) {
-			struct lv_segment *seg = first_seg(detached_log_lv);
-
-			log_very_verbose("%s being removed due to failures",
-					 detached_log_lv->name);
-
-			/*
-			 * We are going to replace the mirror with an
-			 * error segment, but before we do, we must remember
-			 * all of the LVs that must be deleted later (i.e.
-			 * the sub-lv's)
-			 */
-			for (m = 0; m < seg->area_count; m++) {
-				seg_lv(seg, m)->status &= ~MIRROR_IMAGE;
-				lv_set_visible(seg_lv(seg, m));
-				if (!(lvl = dm_pool_alloc(lv->vg->cmd->mem,
-							  sizeof(*lvl)))) {
-					log_error("dm_pool_alloc failed");
-					return 0;
-				}
-				lvl->lv = seg_lv(seg, m);
-				dm_list_add(&tmp_orphan_lvs, &lvl->list);
-			}
-
-			if (!replace_lv_with_error_segment(detached_log_lv)) {
-				log_error("Failed error target substitution for %s",
-					  detached_log_lv->name);
-				return 0;
-			}
-
-			if (!vg_write(detached_log_lv->vg)) {
-				log_error("intermediate VG write fail.");
-				return 0;
-			}
-
-			if (!suspend_lv(detached_log_lv->vg->cmd,
-					detached_log_lv)) {
-				log_error("Failed to suspend %s",
-					  detached_log_lv->name);
-				vg_revert(detached_log_lv->vg);
-				return 0;
-			}
-
-			if (!vg_commit(detached_log_lv->vg))
-				return_0;
+		if (!suspend_lv(detached_log_lv->vg->cmd,
+				detached_log_lv)) {
+			log_error("Failed to suspend %s",
+				  detached_log_lv->name);
+			return 0;
+ 		}
 
-			if (!resume_lv(detached_log_lv->vg->cmd,
-				       detached_log_lv))
-					return_0;
+		if (!resume_lv(detached_log_lv->vg->cmd,
+			       detached_log_lv)) {
+			log_error("Failed to resume %s",
+				  detached_log_lv->name);
+			return_0;
 		}
 	}
 
Index: LVM2-2.02.71-20100714/tools/lvconvert.c
===================================================================
--- LVM2-2.02.71-20100714.orig/tools/lvconvert.c
+++ LVM2-2.02.71-20100714/tools/lvconvert.c
@@ -696,6 +696,13 @@ static int _lv_update_mirrored_log(struc
 	int old_log_count;
 	struct logical_volume *log_lv;
 
+	/*
+	 * When log_count is 0, mirrored log doesn't need to be
+	 * updated here but it will be removed later.
+	 */
+	if (!log_count)
+		return 1;
+
 	log_lv = first_seg(_original_lv(lv))->log_lv;
 	if (!log_lv || !(log_lv->status & MIRRORED))
 		return 1;
@@ -705,12 +712,9 @@ static int _lv_update_mirrored_log(struc
 		return 1;
 
 	/* Reducing redundancy of the log */
-	if (log_count)
-		return remove_mirror_images(log_lv, log_count,
-					    is_mirror_image_removable,
-					    operable_pvs, 0U);
-
-	return remove_mirror_log(lv->vg->cmd, lv, operable_pvs);
+	return remove_mirror_images(log_lv, log_count,
+				    is_mirror_image_removable,
+				    operable_pvs, 0U);
 }
 
 static int _lv_update_log_type(struct cmd_context *cmd,

-- 
Takahiro Yasui
Hitachi Data Systems


