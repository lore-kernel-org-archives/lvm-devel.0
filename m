From: Jonathan Brassow <jbrassow@redhat.com>
Date: Thu, 08 Jul 2010 16:48:16 -0500
Subject: [Patch]: Handle both devices of a mirrored log failing (bug 607347) - additional fix
In-Reply-To: <1278020872.7956.1.camel@hydrogen.msp.redhat.com>
References: <1278020872.7956.1.camel@hydrogen.msp.redhat.com>
Message-ID: <1278625696.16589.2.camel@hydrogen.msp.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

There was still potential for a hang after the last check-in to handle
the scenario where both images of a mirrored log fail.  Taka, this
should fix the hang you were seeing.

 brassow

Finish fix for bug 607347: failing both redundant mirror log legs...

A previous check-in added logic to handle the case where both images
of a mirrored log failed.  It solved the problem by simply removing
the log entirely - leaving the parent mirror with a 'core' log.  This
worked for most cases.  However, if there was a small delay between
the failures of the two mirrored log devices, the mirror would hang,
LVM would hang, and no additional LVM commands could be issued.

When the first leg of the log fails, it signals the need for repair.
Before 'lvconvert --repair' is run by dmeventd, the second leg fails.
'lvconvert' would see both devices as failed and try to remove the
log entirely.  When it came time to suspend the parent mirror to
update the configuration, the suspend would hang because it couldn't
get any I/O through the mirrored log, which was plugged waiting for
corrective action.  The solution is to replace the log with an error
target to clear any pending writes before removing it.  This allows
the parent mirror to suspend and make the proper changes.

Index: LVM2/lib/metadata/mirror.c
===================================================================
--- LVM2.orig/lib/metadata/mirror.c
+++ LVM2/lib/metadata/mirror.c
@@ -864,9 +864,72 @@ static int _remove_mirror_images(struct 
 		lv->status &= ~MIRROR_NOTSYNCED;
 		if (!replace_lv_with_error_segment(lv))
 			return_0;
-	} else if (remove_log)
+	} else if (remove_log) {
 		detached_log_lv = detach_mirror_log(mirrored_seg);
 
+		/*
+		 * The log may be removed due to repair.  If the log
+		 * happens to be a mirrored log, then there is a special
+		 * case we need to consider.  One of the images of a
+		 * mirrored log can fail followed shortly afterwards by
+		 * a failure of the second.  This means that the top-level
+		 * mirror is waiting for writes to the log to finish, but
+		 * they never will unless the mirrored log can be repaired
+		 * or replaced with an error target.  Since both the devices
+		 * have failed, we must replace with error target - it is
+		 * the only way to release the pending writes.
+		 */
+		if (lv_is_mirrored(detached_log_lv) &&
+		    (detached_log_lv->status & PARTIAL_LV)) {
+			struct lv_segment *seg = first_seg(detached_log_lv);
+
+			log_very_verbose("%s being removed due to failures",
+					 detached_log_lv->name);
+
+			/*
+			 * We are going to replace the mirror with an
+			 * error segment, but before we do, we must remember
+			 * all of the LVs that must be deleted later (i.e.
+			 * the sub-lv's)
+			 */
+			for (m = 0; m < seg->area_count; m++) {
+				seg_lv(seg, m)->status &= ~MIRROR_IMAGE;
+				lv_set_visible(seg_lv(seg, m));
+				if (!(lvl = dm_pool_alloc(lv->vg->cmd->mem,
+							  sizeof(*lvl))))
+					return 0;
+				lvl->lv = seg_lv(seg, m);
+				dm_list_add(&tmp_orphan_lvs, &lvl->list);
+			}
+
+			if (!replace_lv_with_error_segment(detached_log_lv)) {
+				log_error("Failed error target substitution for %s",
+					  detached_log_lv->name);
+				return_0;
+			}
+
+			if (!vg_write(detached_log_lv->vg)) {
+				log_error("intermediate VG write fail.");
+				return 0;
+			}
+
+			if (!suspend_lv(detached_log_lv->vg->cmd,
+					detached_log_lv)) {
+				log_error("Failed to suspend %s",
+					  detached_log_lv->name);
+				vg_revert(detached_log_lv->vg);
+				return 0;
+			}
+
+			if (!vg_commit(detached_log_lv->vg))
+				return_0;
+
+			if (!resume_lv(detached_log_lv->vg->cmd,
+				       detached_log_lv))
+					return 0;
+		}
+	}
+
 	/*
 	 * To successfully remove these unwanted LVs we need to
 	 * remove the LVs from the mirror set, commit that metadata



