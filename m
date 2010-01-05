From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 5 Jan 2010 21:07:32 -0000
Subject: LVM2 lib/locking/locking.c lib/metadata/lv_man ...
Message-ID: <20100105210732.24591.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2010-01-05 21:07:31

Modified files:
	lib/locking    : locking.c 
	lib/metadata   : lv_manip.c mirror.c 
	tools          : lvchange.c lvconvert.c lvresize.c pvmove.c 
	                 toollib.c 

Log message:
	Add missing 'stack;' for all suspend_lv and resume_lv callers.
	
	Signed-off-by: Mike Snitzer <snitzer@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.c.diff?cvsroot=lvm2&r1=1.69&r2=1.70
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.190&r2=1.191
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.101&r2=1.102
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvchange.c.diff?cvsroot=lvm2&r1=1.114&r2=1.115
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.98&r2=1.99
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvresize.c.diff?cvsroot=lvm2&r1=1.117&r2=1.118
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvmove.c.diff?cvsroot=lvm2&r1=1.70&r2=1.71
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.180&r2=1.181

--- LVM2/lib/locking/locking.c	2009/12/16 19:22:12	1.69
+++ LVM2/lib/locking/locking.c	2010/01/05 21:07:31	1.70
@@ -454,7 +454,8 @@
 	struct lv_list *lvl;
 
 	dm_list_iterate_items(lvl, lvs)
-		resume_lv(cmd, lvl->lv);
+		if (!resume_lv(cmd, lvl->lv))
+			stack;
 
 	return 1;
 }
@@ -470,7 +471,8 @@
 			log_error("Failed to suspend %s", lvl->lv->name);
 			dm_list_uniterate(lvh, lvs, &lvl->list) {
 				lvl = dm_list_item(lvh, struct lv_list);
-				resume_lv(cmd, lvl->lv);
+				if (!resume_lv(cmd, lvl->lv))
+					stack;
 			}
 
 			return 0;
--- LVM2/lib/metadata/lv_manip.c	2010/01/05 15:58:11	1.190
+++ LVM2/lib/metadata/lv_manip.c	2010/01/05 21:07:31	1.191
@@ -1828,7 +1828,8 @@
 	 * (resume of snapshot resumes origin too)
 	 */
 	dm_list_iterate_back_items(lvlp, &lvs_changed)
-		resume_lv(cmd, lvlp->lv);
+		if (!resume_lv(cmd, lvlp->lv))
+			stack;
 out:
 	backup(vg);
 	return r;
--- LVM2/lib/metadata/mirror.c	2009/12/17 15:59:53	1.101
+++ LVM2/lib/metadata/mirror.c	2010/01/05 21:07:31	1.102
@@ -615,8 +615,9 @@
 		log_error("Problem suspending temporary LV %s", temp_layer_lv->name);
 
 	if (!vg_commit(mirrored_seg->lv->vg)) {
-		resume_lv(mirrored_seg->lv->vg->cmd, mirrored_seg->lv);
-		return 0;
+		if (!resume_lv(mirrored_seg->lv->vg->cmd, mirrored_seg->lv))
+			stack;
+		return_0;
 	}
 
 	log_very_verbose("Updating \"%s\" in kernel", mirrored_seg->lv->name);
--- LVM2/tools/lvchange.c	2010/01/05 20:56:52	1.114
+++ LVM2/tools/lvchange.c	2010/01/05 21:07:31	1.115
@@ -64,7 +64,8 @@
 	}
 
 	if (!vg_commit(lv->vg)) {
-		resume_lv(cmd, lv);
+		if (!resume_lv(cmd, lv))
+			stack;
 		goto_out;
 	}
 
@@ -402,7 +403,8 @@
 	}
 
 	if (!vg_commit(lv->vg)) {
-		resume_lv(cmd, lv);
+		if (!resume_lv(cmd, lv))
+			stack;
 		goto_out;
 	}
 
--- LVM2/tools/lvconvert.c	2009/11/27 14:35:39	1.98
+++ LVM2/tools/lvconvert.c	2010/01/05 21:07:31	1.99
@@ -796,7 +796,8 @@
 	}
 
 	if (!vg_commit(lv->vg)) {
-		resume_lv(cmd, lv);
+		if (!resume_lv(cmd, lv))
+			stack;
 		goto_out;
 	}
 
--- LVM2/tools/lvresize.c	2009/12/03 19:18:34	1.117
+++ LVM2/tools/lvresize.c	2010/01/05 21:07:31	1.118
@@ -638,7 +638,8 @@
 
 	if (!vg_commit(vg)) {
 		stack;
-		resume_lv(cmd, lock_lv);
+		if (!resume_lv(cmd, lock_lv))
+			stack;
 		backup(vg);
 		return ECMD_FAILED;
 	}
--- LVM2/tools/pvmove.c	2009/12/04 14:03:18	1.70
+++ LVM2/tools/pvmove.c	2010/01/05 21:07:31	1.71
@@ -302,7 +302,8 @@
 	/* Suspend mirrors on subsequent calls */
 	if (!first_time) {
 		if (!suspend_lv(cmd, lv_mirr)) {
-			resume_lvs(cmd, lvs_changed);
+			if (!resume_lvs(cmd, lvs_changed))
+				stack;
 			vg_revert(vg);
 			goto_out;
 		}
@@ -312,8 +313,10 @@
 	if (!vg_commit(vg)) {
 		log_error("ABORTING: Volume group metadata update failed.");
 		if (!first_time)
-			resume_lv(cmd, lv_mirr);
-		resume_lvs(cmd, lvs_changed);
+			if (!resume_lv(cmd, lv_mirr))
+				stack;
+		if (!resume_lvs(cmd, lvs_changed))
+			stack;
 		goto out;
 	}
 
@@ -339,7 +342,8 @@
 	} else if (!resume_lv(cmd, lv_mirr)) {
 		log_error("Unable to reactivate logical volume \"%s\"",
 			  lv_mirr->name);
-		resume_lvs(cmd, lvs_changed);
+		if (!resume_lvs(cmd, lvs_changed))
+			stack;
 		goto out;
 	}
 
@@ -513,8 +517,10 @@
 		log_error("ABORTING: Failed to write new data locations "
 			  "to disk.");
 		vg_revert(vg);
-		resume_lv(cmd, lv_mirr);
-		resume_lvs(cmd, lvs_changed);
+		if (!resume_lv(cmd, lv_mirr))
+			stack;
+		if (!resume_lvs(cmd, lvs_changed))
+			stack;
 		return 0;
 	}
 
@@ -526,7 +532,8 @@
 	}
 
 	/* Unsuspend LVs */
-	resume_lvs(cmd, lvs_changed);
+	if (!resume_lvs(cmd, lvs_changed))
+		stack;
 
 	/* Deactivate mirror LV */
 	if (!deactivate_lv(cmd, lv_mirr)) {
--- LVM2/tools/toollib.c	2009/12/11 13:11:56	1.180
+++ LVM2/tools/toollib.c	2010/01/05 21:07:31	1.181
@@ -1251,7 +1251,18 @@
 
 int lv_refresh(struct cmd_context *cmd, struct logical_volume *lv)
 {
-	return suspend_lv(cmd, lv) && resume_lv(cmd, lv);
+	int r = 0;
+
+	r = suspend_lv(cmd, lv);
+	if (!r)
+		goto_out;
+
+	r = resume_lv(cmd, lv);
+	if (!r)
+		goto_out;
+
+out:
+	return r;
 }
 
 int vg_refresh_visible(struct cmd_context *cmd, struct volume_group *vg)


