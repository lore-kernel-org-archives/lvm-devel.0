From: agk@sourceware.org <agk@sourceware.org>
Date: 27 Sep 2011 17:09:45 -0000
Subject: LVM2 ./WHATS_NEW lib/locking/locking.c lib/loc ...
Message-ID: <20110927170945.16826.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-09-27 17:09:44

Modified files:
	.              : WHATS_NEW 
	lib/locking    : locking.c locking.h 
	lib/metadata   : lv_manip.c metadata-exported.h metadata.c 
	tools          : pvmove.c 

Log message:
	Abort if _finish_pvmove suspend_lvs fails instead of cleaning up incompletely.
	Change suspend_lvs to call vg_revert internally.
	Change vg_revert to void and remove superfluous calls after failed vg_commit.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2140&r2=1.2141
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.c.diff?cvsroot=lvm2&r1=1.98&r2=1.99
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.h.diff?cvsroot=lvm2&r1=1.67&r2=1.68
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.290&r2=1.291
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.211&r2=1.212
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.467&r2=1.468
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvmove.c.diff?cvsroot=lvm2&r1=1.87&r2=1.88

--- LVM2/WHATS_NEW	2011/09/26 07:51:23	1.2140
+++ LVM2/WHATS_NEW	2011/09/27 17:09:42	1.2141
@@ -1,5 +1,8 @@
 Version 2.02.89 - 
 ==================================
+  Abort if _finish_pvmove suspend_lvs fails instead of cleaning up incompletely.
+  Change suspend_lvs to call vg_revert internally.
+  Change vg_revert to void and remove superfluous calls after failed vg_commit.
   Use execvp for CLVMD restart to preserve environment settings.
   Restart CLVMD with same cluster manager.
   Fix log_error() usage in raid and unknown segtype initialisation.
--- LVM2/lib/locking/locking.c	2011/08/11 15:27:46	1.98
+++ LVM2/lib/locking/locking.c	2011/09/27 17:09:43	1.99
@@ -493,8 +493,13 @@
 	return r;
 }
 
-/* Lock a list of LVs */
-int suspend_lvs(struct cmd_context *cmd, struct dm_list *lvs)
+/*
+ * Lock a list of LVs.
+ * On failure to lock any LV, calls vg_revert() if vg_to_revert is set and 
+ * then unlocks any LVs on the list already successfully locked.
+ */
+int suspend_lvs(struct cmd_context *cmd, struct dm_list *lvs,
+		struct volume_group *vg_to_revert)
 {
 	struct dm_list *lvh;
 	struct lv_list *lvl;
@@ -502,6 +507,8 @@
 	dm_list_iterate_items(lvl, lvs) {
 		if (!suspend_lv(cmd, lvl->lv)) {
 			log_error("Failed to suspend %s", lvl->lv->name);
+			if (vg_to_revert)
+				vg_revert(vg_to_revert);
 			dm_list_uniterate(lvh, lvs, &lvl->list) {
 				lvl = dm_list_item(lvh, struct lv_list);
 				if (!resume_lv(cmd, lvl->lv))
--- LVM2/lib/locking/locking.h	2011/08/10 20:25:30	1.67
+++ LVM2/lib/locking/locking.h	2011/09/27 17:09:43	1.68
@@ -187,7 +187,9 @@
 int sync_dev_names(struct cmd_context* cmd);
 
 /* Process list of LVs */
-int suspend_lvs(struct cmd_context *cmd, struct dm_list *lvs);
+struct volume_group;
+int suspend_lvs(struct cmd_context *cmd, struct dm_list *lvs,
+		struct volume_group *vg_to_revert);
 int resume_lvs(struct cmd_context *cmd, struct dm_list *lvs);
 int activate_lvs(struct cmd_context *cmd, struct dm_list *lvs, unsigned exclusive);
 
--- LVM2/lib/metadata/lv_manip.c	2011/09/22 17:33:51	1.290
+++ LVM2/lib/metadata/lv_manip.c	2011/09/27 17:09:43	1.291
@@ -2793,11 +2793,8 @@
 	if (!vg_write(vg))
 		return 0;
 
-
-	if (!suspend_lvs(cmd, &lvs_changed)) {
-		vg_revert(vg);
+	if (!suspend_lvs(cmd, &lvs_changed, vg))
 		goto_out;
-	}
 
 	if (!(r = vg_commit(vg)))
 		stack;
--- LVM2/lib/metadata/metadata-exported.h	2011/09/14 09:57:35	1.211
+++ LVM2/lib/metadata/metadata-exported.h	2011/09/27 17:09:43	1.212
@@ -400,7 +400,7 @@
 */
 int vg_write(struct volume_group *vg);
 int vg_commit(struct volume_group *vg);
-int vg_revert(struct volume_group *vg);
+void vg_revert(struct volume_group *vg);
 struct volume_group *vg_read_internal(struct cmd_context *cmd, const char *vg_name,
 				      const char *vgid, int warnings, int *consistent);
 struct physical_volume *pv_read(struct cmd_context *cmd, const char *pv_name,
--- LVM2/lib/metadata/metadata.c	2011/09/07 08:34:22	1.467
+++ LVM2/lib/metadata/metadata.c	2011/09/27 17:09:43	1.468
@@ -2685,7 +2685,7 @@
 }
 
 /* Don't commit any pending changes */
-int vg_revert(struct volume_group *vg)
+void vg_revert(struct volume_group *vg)
 {
 	struct metadata_area *mda;
 
@@ -2701,8 +2701,6 @@
 			  "after reverted update for VG %s.", vg->name);
 
 	remote_revert_cached_metadata(vg);
-
-	return 1;
 }
 
 /* Make orphan PVs look like a VG */
--- LVM2/tools/pvmove.c	2011/09/21 16:36:39	1.87
+++ LVM2/tools/pvmove.c	2011/09/27 17:09:43	1.88
@@ -307,17 +307,21 @@
 
 static int _suspend_lvs(struct cmd_context *cmd, unsigned first_time,
 			struct logical_volume *lv_mirr,
-			struct dm_list *lvs_changed)
+			struct dm_list *lvs_changed,
+			struct volume_group *vg_to_revert)
 {
 	/*
 	 * Suspend lvs_changed the first time.
 	 * Suspend mirrors on subsequent calls.
 	 */
 	if (first_time) {
-		if (!suspend_lvs(cmd, lvs_changed))
+		if (!suspend_lvs(cmd, lvs_changed, vg_to_revert))
 			return_0;
-	} else if (!suspend_lv(cmd, lv_mirr))
+	} else if (!suspend_lv(cmd, lv_mirr)) {
+		if (vg_to_revert)
+			vg_revert(vg_to_revert);
 		return_0;
+	}
 
 	return 1;
 }
@@ -364,16 +368,14 @@
 		return 0;
 	}
 
-	if (!_suspend_lvs(cmd, first_time, lv_mirr, lvs_changed)) {
-		/* FIXME vg_revert must be moved *before* any LV resumes */
-		vg_revert(vg);
-		goto_out;
+	if (!_suspend_lvs(cmd, first_time, lv_mirr, lvs_changed, vg)) {
+		log_error("ABORTING: Volume group metadata update failed.");
+		goto out;
 	}
 
 	/* Commit on-disk metadata */
 	if (!vg_commit(vg)) {
 		log_error("ABORTING: Volume group metadata update failed.");
-		vg_revert(vg);
 		goto out;
 	}
 
@@ -555,16 +557,15 @@
 	}
 
 	/* Suspend LVs changed (implicitly suspends lv_mirr) */
-	if (!suspend_lvs(cmd, lvs_changed)) {
-		log_error("Locking LVs to remove temporary mirror failed");
-		r = 0;
+	if (!suspend_lvs(cmd, lvs_changed, vg)) {
+		log_error("ABORTING: Locking LVs to remove temporary mirror failed");
+		return 0;
 	}
 
 	/* Store metadata without dependencies on mirror segments */
 	if (!vg_commit(vg)) {
 		log_error("ABORTING: Failed to write new data locations "
 			  "to disk.");
-		vg_revert(vg);
 		if (!resume_lv(cmd, lv_mirr))
 			stack;
 		if (!resume_lvs(cmd, lvs_changed))


