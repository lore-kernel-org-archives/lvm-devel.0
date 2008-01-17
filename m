From: agk@sourceware.org <agk@sourceware.org>
Date: 17 Jan 2008 13:37:52 -0000
Subject: LVM2/lib/metadata mirror.c
Message-ID: <20080117133752.32597.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-01-17 13:37:52

Modified files:
	lib/metadata   : mirror.c 

Log message:
	mirror log stuff

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.60&r2=1.61

--- LVM2/lib/metadata/mirror.c	2008/01/17 13:13:54	1.60
+++ LVM2/lib/metadata/mirror.c	2008/01/17 13:37:51	1.61
@@ -192,9 +192,12 @@
  */
 static int _init_mirror_log(struct cmd_context *cmd,
 			    struct logical_volume *log_lv, int in_sync,
-			    struct list *tags)
+			    struct list *tags, int remove_on_failure)
 {
 	struct str_list *sl;
+	struct lvinfo info;
+	uint32_t orig_status = log_lv->status;
+	int was_active = 0;
 
 	if (!activation() && in_sync) {
 		log_error("Aborting. Unable to create in-sync mirror log "
@@ -202,21 +205,31 @@
 		return 0;
 	}
 
+	/* If the LV is active, deactivate it first. */
+	if (lv_info(cmd, log_lv, &info, 0, 0) && info.exists) {
+		if (!deactivate_lv(cmd, log_lv))
+			return_0;
+		was_active = 1;
+	}
+
+	/* Temporary make it visible for set_lv() */
+	log_lv->status |= VISIBLE_LV;
+
 	/* Temporary tag mirror log for activation */
 	list_iterate_items(sl, tags)
 		if (!str_list_add(cmd->mem, &log_lv->tags, sl->str)) {
 			log_error("Aborting. Unable to tag mirror log.");
-			return 0;
+			goto activate_lv;
 		}
 
 	/* store mirror log on disk(s) */
 	if (!vg_write(log_lv->vg))
-		return_0;
+		goto activate_lv;
 
 	backup(log_lv->vg);
 
 	if (!vg_commit(log_lv->vg))
-		return_0;
+		goto activate_lv;
 
 	if (!activate_lv(cmd, log_lv)) {
 		log_error("Aborting. Failed to activate mirror log.");
@@ -248,6 +261,9 @@
 
 	log_lv->status &= ~VISIBLE_LV;
 
+	if (was_active && !activate_lv(cmd, log_lv))
+		return_0;
+
 	return 1;
 
 deactivate_and_revert_new_lv:
@@ -258,10 +274,27 @@
 	}
 
 revert_new_lv:
-	if (!lv_remove(log_lv) || !vg_write(log_lv->vg) ||
-	    (backup(log_lv->vg), !vg_commit(log_lv->vg)))
+	log_lv->status = orig_status;
+
+	list_iterate_items(sl, tags)
+		if (!str_list_del(&log_lv->tags, sl->str))
+			log_error("Failed to remove tag %s from mirror log.",
+				  sl->str);
+
+	if (remove_on_failure && !lv_remove(log_lv)) {
 		log_error("Manual intervention may be required to remove "
 			  "abandoned log LV before retrying.");
+		return 0;
+	}
+
+	if (!vg_write(log_lv->vg) ||
+	    (backup(log_lv->vg), !vg_commit(log_lv->vg)))
+		log_error("Manual intervention may be required to "
+			  "remove/restore abandoned log LV before retrying.");
+activate_lv:
+	if (was_active && !remove_on_failure && !activate_lv(cmd, log_lv))
+		return_0;
+
 	return 0;
 }
 
@@ -1199,7 +1232,7 @@
 		return NULL;
 	}
 
-	if (!_init_mirror_log(cmd, log_lv, in_sync, &lv->tags)) {
+	if (!_init_mirror_log(cmd, log_lv, in_sync, &lv->tags, 1)) {
 		log_error("Failed to create mirror log.");
 		return NULL;
 	}


