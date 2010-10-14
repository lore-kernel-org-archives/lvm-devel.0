From: Jonathan Brassow <jbrassow@redhat.com>
Date: Thu, 14 Oct 2010 14:07:22 -0500
Subject: [patch] Fix for handling simultaneous failure of mirrored-log devices
Message-ID: <1287083242.3762.3.camel@hydrogen.msp.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

There is a test we could add to the testsuite, but if it actually finds
the bug, it will hang indefinitely.  I'm not sure we want that.

 brassow

Fix for bug 637936: killing both redundant logs causes deadlock

Problem:
When both legs of a mirrored log fail, neither the log nor the parent
mirror can proceed.  The repair code must be careful to replace the
log with an error target before operating on the parent - otherwise,
the parent can get stuck trying to suspend because it can't push through
any writes.  The steps to replace the log device with an error target
were incomplete and resulted in the replacement not happening at all!

The code originally had all the necessary logic to complete the
replacement task, but was pulled out in a effort to clean-up that
section of code, while fixing another bug:
<offending commit msg>
In addition, I added following three changes.

- Removed tmp_orphan_lvs handling procedure
  It seems that _delete_lv() can handle detached_log_lv properly
  without adding mirror legs in mirrored log to tmp_orphan_lvs.
  Therefore, I removed the procedure.

- Removed vg_write()/vg_commit()
  Metadata is saved by vg_write()/vg_commit() just after detached_log_lv
  is handled. Therefore, I removed vg_write()/vg_commit().
</offending commit msg>

http://sources.redhat.com/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c?cvsroot=lvm2&f=h#rev1.130

I've reverted the "clean-up" changes associated with that fix, but not what
that commit was actually fixing.

Signed-off-by: Jonathan Brassow <jbrassow@redhat.com>

Index: LVM2/lib/metadata/lv_manip.c
===================================================================
--- LVM2.orig/lib/metadata/lv_manip.c
+++ LVM2/lib/metadata/lv_manip.c
@@ -462,6 +462,15 @@ int replace_lv_with_error_segment(struct
 	if (!lv_empty(lv))
 		return_0;
 
+	/*
+	 * Since we are replacing the whatever-was-there with
+	 * an error segment, we should also clear any flags
+	 * that suggest it is anything other than "error".
+	 */
+	lv->status &= ~MIRRORED;
+
+	/* FIXME: Should we bug if we find a log_lv attached? */
+
 	if (!lv_add_virtual_segment(lv, 0, len,
 				    get_segtype_from_string(lv->vg->cmd,
 							    "error")))
Index: LVM2/lib/metadata/mirror.c
===================================================================
--- LVM2.orig/lib/metadata/mirror.c
+++ LVM2/lib/metadata/mirror.c
@@ -896,18 +896,40 @@ static int _remove_mirror_images(struct 
 	 */
 	if (detached_log_lv && lv_is_mirrored(detached_log_lv) &&
 	    (detached_log_lv->status & PARTIAL_LV)) {
+		struct lv_segment *seg = first_seg(detached_log_lv);
+
 		log_very_verbose("%s being removed due to failures",
 				 detached_log_lv->name);
 
+		/*
+		 * We are going to replace the mirror with an
+		 * error segment, but before we do, we must remember
+		 * all of the LVs that must be deleted later (i.e.
+		 * the sub-lv's)
+		 */
+		for (m = 0; m < seg->area_count; m++) {
+			seg_lv(seg, m)->status &= ~MIRROR_IMAGE;
+			lv_set_visible(seg_lv(seg, m));
+			if (!(lvl = dm_pool_alloc(lv->vg->cmd->mem,
+						  sizeof(*lvl)))) {
+				log_error("dm_pool_alloc failed");
+				return 0;
+			}
+			lvl->lv = seg_lv(seg, m);
+			dm_list_add(&tmp_orphan_lvs, &lvl->list);
+		}
+
 		if (!replace_lv_with_error_segment(detached_log_lv)) {
 			log_error("Failed error target substitution for %s",
 				  detached_log_lv->name);
 			return 0;
 		}
 
-		/*
-		 * Flush all I/Os held by mirrored log.
-		 */
+		if (!vg_write(detached_log_lv->vg)) {
+			log_error("intermediate VG write failed.");
+			return 0;
+		}
+
 		if (!suspend_lv(detached_log_lv->vg->cmd,
 				detached_log_lv)) {
 			log_error("Failed to suspend %s",
@@ -915,8 +937,14 @@ static int _remove_mirror_images(struct 
 			return 0;
  		}
 
-		if (!resume_lv(detached_log_lv->vg->cmd,
-			       detached_log_lv)) {
+		if (!vg_commit(detached_log_lv->vg)) {
+			if (!resume_lv(detached_log_lv->vg->cmd,
+				       detached_log_lv))
+				stack;
+			return_0;
+		}
+
+		if (!resume_lv(detached_log_lv->vg->cmd, detached_log_lv)) {
 			log_error("Failed to resume %s",
 				  detached_log_lv->name);
 			return_0;



