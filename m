From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 2 Aug 2010 21:07:42 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/mirror.c tools/l ...
Message-ID: <20100802210742.27320.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2010-08-02 21:07:41

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : mirror.c 
	tools          : lvconvert.c 

Log message:
	Taka's fix for handling failure of all mirrored log devices and
	all but one mirror leg.
	
	<patch header>
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
	</patch header>
	
	Signed-off-by: Takahiro Yasui <takahiro.yasui@hds.com>
	Reviewed-by: Petr Rockai <prockai@redhat.com>
	Signed-off-by: Jonathan Brassow <jbrassow@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1687&r2=1.1688
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.129&r2=1.130
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.142&r2=1.143

--- LVM2/WHATS_NEW	2010/08/02 19:03:45	1.1687
+++ LVM2/WHATS_NEW	2010/08/02 21:07:40	1.1688
@@ -1,5 +1,6 @@
 Version 2.02.73 - 
 ================================
+  Handle failure of all mirrored log devices and all but one mirror leg. 
   Disallow 'mirrored' log type for cluster mirrors.
   Do not use VPATH in include/Makefile.
   Fix exported_symbols generation to use standard compiler arguments.
--- LVM2/lib/metadata/mirror.c	2010/08/02 19:03:45	1.129
+++ LVM2/lib/metadata/mirror.c	2010/08/02 21:07:41	1.130
@@ -902,71 +902,47 @@
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
+		 * Flush all I/Os held by mirrored log.
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
 
--- LVM2/tools/lvconvert.c	2010/08/02 19:03:45	1.142
+++ LVM2/tools/lvconvert.c	2010/08/02 21:07:41	1.143
@@ -696,6 +696,13 @@
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
@@ -705,12 +712,9 @@
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


