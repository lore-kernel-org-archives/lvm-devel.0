From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 13 Jan 2010 01:49:53 -0000
Subject: LVM2/tools lvconvert.c
Message-ID: <20100113014953.28111.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2010-01-13 01:49:52

Modified files:
	tools          : lvconvert.c 

Log message:
	Background poll for lvconvert --merge command.
	The merging snapshot is removed when the merge finishes.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.111&r2=1.112

--- LVM2/tools/lvconvert.c	2010/01/13 01:47:18	1.111
+++ LVM2/tools/lvconvert.c	2010/01/13 01:49:52	1.112
@@ -44,6 +44,8 @@
 	char **pvs;
 	struct dm_list *pvh;
 	struct dm_list *failed_pvs;
+
+	struct logical_volume *lv_to_poll;
 };
 
 static int _lvconvert_name_params(struct lvconvert_params *lp,
@@ -370,6 +372,54 @@
 	return r;
 }
 
+static int _finish_lvconvert_merge(struct cmd_context *cmd,
+				   struct volume_group *vg,
+				   struct logical_volume *lv,
+				   struct dm_list *lvs_changed __attribute((unused)))
+{
+	struct lv_segment *snap_seg = lv->merging_snapshot;
+	if (!snap_seg) {
+		log_error("Logical volume %s has no merging snapshot.", lv->name);
+		return 0;
+	}
+
+	log_print("Merge of snapshot into logical volume %s has finished.", lv->name);
+	if (!lv_remove_single(cmd, snap_seg->cow, DONT_PROMPT)) {
+		log_error("Could not remove snapshot %s merged into %s.",
+			  snap_seg->cow->name, lv->name);
+		return 0;
+	}
+
+	return 1;
+}
+
+static progress_t _poll_merge_progress(struct cmd_context *cmd,
+				       struct logical_volume *lv,
+				       const char *name __attribute((unused)),
+				       struct daemon_parms *parms)
+{
+	float percent = 0.0;
+	percent_range_t percent_range;
+
+	if (!lv_snapshot_percent(lv, &percent, &percent_range)) {
+		log_error("%s: Failed query for merging percentage", lv->name);
+		return PROGRESS_CHECK_FAILED;
+	} else if (percent_range == PERCENT_INVALID) {
+		log_error("%s: Merging snapshot invalidated. Aborting merge.", lv->name);
+		return PROGRESS_CHECK_FAILED;
+	}
+
+	if (parms->progress_display)
+		log_print("%s: %s: %.1f%%", lv->name, parms->progress_title, percent);
+	else
+		log_verbose("%s: %s: %.1f%%", lv->name, parms->progress_title, percent);
+
+	if (percent_range == PERCENT_0)
+		return PROGRESS_FINISHED_ALL;
+
+	return PROGRESS_UNFINISHED;
+}
+
 static struct poll_functions _lvconvert_mirror_fns = {
 	.get_copy_vg = _get_lvconvert_vg,
 	.get_copy_lv = _get_lvconvert_lv,
@@ -377,6 +427,13 @@
 	.finish_copy = _finish_lvconvert_mirror,
 };
 
+static struct poll_functions _lvconvert_merge_fns = {
+	.get_copy_vg = _get_lvconvert_vg,
+	.get_copy_lv = _get_lvconvert_lv,
+	.poll_progress = _poll_merge_progress,
+	.finish_copy = _finish_lvconvert_merge,
+};
+
 int lvconvert_poll(struct cmd_context *cmd, struct logical_volume *lv,
 		   unsigned background)
 {
@@ -393,8 +450,12 @@
 
 	memcpy(uuid, &lv->lvid, sizeof(lv->lvid));
 
-	return poll_daemon(cmd, lv_full_name, uuid, background, 0,
-			   &_lvconvert_mirror_fns, "Converted");
+	if (!lv->merging_snapshot)
+		return poll_daemon(cmd, lv_full_name, uuid, background, 0,
+				   &_lvconvert_mirror_fns, "Converted");
+	else
+		return poll_daemon(cmd, lv_full_name, uuid, background, 0,
+				   &_lvconvert_merge_fns, "Merged");
 }
 
 static int _insert_lvconvert_layer(struct cmd_context *cmd,
@@ -1121,6 +1182,9 @@
 		/* merge is running regardless of this deactivation failure */
 	}
 
+	lp->need_polling = 1;
+	lp->lv_to_poll = origin;
+
 	r = 1;
 	log_print("Merging of volume %s started.", lv->name);
 out:
@@ -1237,17 +1301,18 @@
 	} else
 		lp.pvh = &vg->pvs;
 
+	lp.lv_to_poll = lvl->lv;
 	ret = lvconvert_single(cmd, lvl->lv, &lp);
 
 bad:
 	unlock_vg(cmd, lp.vg_name);
 
 	if (ret == ECMD_PROCESSED && lp.need_polling) {
-		if (!lv_info(cmd, lvl->lv, &info, 1, 0) || !info.exists) {
+		if (!lv_info(cmd, lp.lv_to_poll, &info, 1, 0) || !info.exists) {
 			log_print("Conversion starts after activation");
 			goto out;
 		}
-		ret = lvconvert_poll(cmd, lvl->lv,
+		ret = lvconvert_poll(cmd, lp.lv_to_poll,
 				     lp.wait_completion ? 0 : 1U);
 	}
 out:


