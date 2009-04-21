From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 21 Apr 2009 14:32:00 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/lv_manip.c lib/m ...
Message-ID: <20090421143200.11505.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-04-21 14:31:58

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : lv_manip.c mirror.c 
	tools          : lvchange.c lvconvert.c lvcreate.c lvresize.c 
	                 pvmove.c 

Log message:
	Move metadata backup call after vg_commit.
	
	The backup() call store metadata from memory.
	
	But in cluster backup() call performs
	remote nodes metadata backup and it reads data from disk.
	
	For metadata backup consistency,
	patch moves all backup() calls after vg_commit.
	
	(Moreover, some tools already do that this way.)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1090&r2=1.1091
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.165&r2=1.166
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.83&r2=1.84
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvchange.c.diff?cvsroot=lvm2&r1=1.96&r2=1.97
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.69&r2=1.70
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.181&r2=1.182
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvresize.c.diff?cvsroot=lvm2&r1=1.106&r2=1.107
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvmove.c.diff?cvsroot=lvm2&r1=1.56&r2=1.57

--- LVM2/WHATS_NEW	2009/04/21 13:11:28	1.1090
+++ LVM2/WHATS_NEW	2009/04/21 14:31:57	1.1091
@@ -1,5 +1,6 @@
 Version 2.02.46 - 
 ================================
+  Fix metadata backup to run after vg_commit always.
   Tidy clvmd volume lock cache functions.
   Fix pvs report for orphan PVs when segment attributes are requested.
   Fix pvs -a output to not read volume groups from non-PV devices.
--- LVM2/lib/metadata/lv_manip.c	2009/04/07 10:20:29	1.165
+++ LVM2/lib/metadata/lv_manip.c	2009/04/21 14:31:58	1.166
@@ -1736,6 +1736,7 @@
 {
 	struct volume_group *vg = lv->vg;
 	struct lv_names lv_names;
+	int r = 0;
 
 	/* rename is not allowed on sub LVs */
 	if (!lv_is_displayable(lv)) {
@@ -1773,23 +1774,21 @@
 	if (!vg_write(vg))
 		return 0;
 
-	backup(vg);
-
 	if (!suspend_lv(cmd, lv)) {
-		stack;
 		vg_revert(vg);
-		return 0;
+		goto_out;
 	}
 
 	if (!vg_commit(vg)) {
-		stack;
 		resume_lv(cmd, lv);
-		return 0;
+		goto_out;
 	}
 
 	resume_lv(cmd, lv);
-
-	return 1;
+	r = 1;
+out:
+	backup(vg);
+	return r;
 }
 
 char *generate_lv_name(struct volume_group *vg, const char *format,
@@ -2051,14 +2050,11 @@
 	}
 
 	/* store it on disks */
-	if (!vg_write(vg))
-		return 0;
+	if (!vg_write(vg) || !vg_commit(vg))
+		return_0;
 
 	backup(vg);
 
-	if (!vg_commit(vg))
-		return 0;
-
 	/* If no snapshots left, reload without -real. */
 	if (origin && !lv_is_origin(origin)) {
 		if (!suspend_lv(cmd, origin))
--- LVM2/lib/metadata/mirror.c	2009/04/10 09:53:43	1.83
+++ LVM2/lib/metadata/mirror.c	2009/04/21 14:31:58	1.84
@@ -270,14 +270,11 @@
 		}
 
 	/* store mirror log on disk(s) */
-	if (!vg_write(log_lv->vg))
+	if (!vg_write(log_lv->vg) || !vg_commit(log_lv->vg))
 		goto activate_lv;
 
 	backup(log_lv->vg);
 
-	if (!vg_commit(log_lv->vg))
-		goto activate_lv;
-
 	if (!activate_lv(cmd, log_lv)) {
 		log_error("Aborting. Failed to activate mirror log.");
 		goto revert_new_lv;
@@ -334,10 +331,12 @@
 		return 0;
 	}
 
-	if (!vg_write(log_lv->vg) ||
-	    (backup(log_lv->vg), !vg_commit(log_lv->vg)))
+	if (!vg_write(log_lv->vg) || !vg_commit(log_lv->vg))
 		log_error("Manual intervention may be required to "
 			  "remove/restore abandoned log LV before retrying.");
+	else
+		backup(log_lv->vg);
+
 activate_lv:
 	if (was_active && !remove_on_failure && !activate_lv(cmd, log_lv))
 		return_0;
@@ -1504,11 +1503,15 @@
 	return 1;
 
   out_remove_log:
-	if (log_lv && (!lv_remove(log_lv) || !vg_write(log_lv->vg) ||
-		       (backup(log_lv->vg), !vg_commit(log_lv->vg))))
-		log_error("Manual intervention may be required to remove "
-			  "abandoned log LV before retrying.");
-
+	if (log_lv) {
+		if (!lv_remove(log_lv) ||
+		    !vg_write(log_lv->vg) ||
+		    !vg_commit(log_lv->vg))
+			log_error("Manual intervention may be required to remove "
+				  "abandoned log LV before retrying.");
+		else
+			backup(log_lv->vg);
+	}
   out_remove_imgs:
 	alloc_destroy(ah);
 	return 0;
--- LVM2/tools/lvchange.c	2008/12/19 14:22:48	1.96
+++ LVM2/tools/lvchange.c	2009/04/21 14:31:58	1.97
@@ -20,6 +20,7 @@
 {
 	uint32_t lv_access;
 	struct lvinfo info;
+	int r = 0;
 
 	lv_access = arg_uint_value(cmd, permission_ARG, 0);
 
@@ -56,26 +57,27 @@
 	if (!vg_write(lv->vg))
 		return_0;
 
-	backup(lv->vg);
-
 	if (!suspend_lv(cmd, lv)) {
 		log_error("Failed to lock %s", lv->name);
 		vg_revert(lv->vg);
-		return 0;
+		goto out;
 	}
 
 	if (!vg_commit(lv->vg)) {
 		resume_lv(cmd, lv);
-		return 0;
+		goto_out;
 	}
 
 	log_very_verbose("Updating permissions for \"%s\" in kernel", lv->name);
 	if (!resume_lv(cmd, lv)) {
 		log_error("Problem reactivating %s", lv->name);
-		return 0;
+		goto out;
 	}
 
-	return 1;
+	r = 1;	
+out:
+	backup(lv->vg);
+	return r;
 }
 
 static int lvchange_monitoring(struct cmd_context *cmd,
@@ -274,8 +276,6 @@
 			return 0;
 		}
 
-		backup(lv->vg);
-
 		if (!vg_commit(lv->vg)) {
 			log_error("Failed to commit intermediate VG metadata.");
 			if (!attach_mirror_log(first_seg(lv), log_lv))
@@ -285,6 +285,8 @@
 			return 0;
 		}
 
+		backup(lv->vg);
+
 		if (!activate_lv(cmd, log_lv)) {
 			log_error("Unable to activate %s for mirror log resync",
 				  log_lv->name);
@@ -349,15 +351,12 @@
 
 	log_very_verbose("Updating logical volume \"%s\" on disk(s)", lv->name);
 
-	if (!vg_write(lv->vg))
+	/* No need to suspend LV for this change */
+	if (!vg_write(lv->vg) || !vg_commit(lv->vg))
 		return_0;
 
 	backup(lv->vg);
 
-	/* No need to suspend LV for this change */
-	if (!vg_commit(lv->vg))
-		return_0;
-
 	return 1;
 }
 
@@ -366,6 +365,7 @@
 {
 	unsigned read_ahead = 0;
 	unsigned pagesize = (unsigned) lvm_getpagesize() >> SECTOR_SHIFT;
+	int r = 0;
 
 	read_ahead = arg_uint_value(cmd, readahead_ARG, 0);
 
@@ -401,26 +401,27 @@
 	if (!vg_write(lv->vg))
 		return_0;
 
-	backup(lv->vg);
-
 	if (!suspend_lv(cmd, lv)) {
 		log_error("Failed to lock %s", lv->name);
 		vg_revert(lv->vg);
-		return 0;
+		goto out;
 	}
 
 	if (!vg_commit(lv->vg)) {
 		resume_lv(cmd, lv);
-		return 0;
+		goto_out;
 	}
 
 	log_very_verbose("Updating permissions for \"%s\" in kernel", lv->name);
 	if (!resume_lv(cmd, lv)) {
 		log_error("Problem reactivating %s", lv->name);
-		return 0;
+		goto out;
 	}
 
-	return 1;
+	r = 1;
+out:
+	backup(lv->vg);
+	return r;
 }
 
 static int lvchange_persistent(struct cmd_context *cmd,
@@ -477,14 +478,11 @@
 	}
 
 	log_very_verbose("Updating logical volume \"%s\" on disk(s)", lv->name);
-	if (!vg_write(lv->vg))
+	if (!vg_write(lv->vg) || !vg_commit(lv->vg))
 		return_0;
 
 	backup(lv->vg);
 
-	if (!vg_commit(lv->vg))
-		return_0;
-
 	if (active) {
 		log_verbose("Re-activating logical volume \"%s\"", lv->name);
 		if (!activate_lv(cmd, lv)) {
@@ -527,15 +525,13 @@
 	}
 
 	log_very_verbose("Updating logical volume \"%s\" on disk(s)", lv->name);
-	if (!vg_write(lv->vg))
-		return_0;
-
-	backup(lv->vg);
 
 	/* No need to suspend LV for this change */
-	if (!vg_commit(lv->vg))
+	if (!vg_write(lv->vg) || !vg_commit(lv->vg))
 		return_0;
 
+	backup(lv->vg);
+
 	return 1;
 }
 
--- LVM2/tools/lvconvert.c	2009/04/10 10:01:38	1.69
+++ LVM2/tools/lvconvert.c	2009/04/21 14:31:58	1.70
@@ -269,6 +269,8 @@
 				    struct logical_volume *lv,
 				    struct dm_list *lvs_changed __attribute((unused)))
 {
+	int r = 0;
+
 	if (!collapse_mirrored_lv(lv)) {
 		log_error("Failed to remove temporary sync layer.");
 		return 0;
@@ -281,29 +283,29 @@
 	if (!vg_write(vg))
 		return_0;
 
-	backup(vg);
-
 	if (!suspend_lv(cmd, lv)) {
 		log_error("Failed to lock %s", lv->name);
 		vg_revert(vg);
-		return 0;
+		goto out;
 	}
 
 	if (!vg_commit(vg)) {
 		resume_lv(cmd, lv);
-		return 0;
+		goto_out;
 	}
 
 	log_very_verbose("Updating \"%s\" in kernel", lv->name);
 
 	if (!resume_lv(cmd, lv)) {
 		log_error("Problem reactivating %s", lv->name);
-		return 0;
+		goto out;
 	}
 
+	r = 1;
 	log_print("Logical volume %s converted.", lv->name);
-
-	return 1;
+out:
+	backup(vg);
+	return r;
 }
 
 static struct poll_functions _lvconvert_mirror_fns = {
@@ -383,6 +385,7 @@
 	const char *mirrorlog;
 	unsigned corelog = 0;
 	struct logical_volume *original_lv;
+	int r = 0;
 
 	seg = first_seg(lv);
 	existing_mirrors = lv_mirror_count(lv);
@@ -589,30 +592,31 @@
 	if (!vg_write(lv->vg))
 		return_0;
 
-	backup(lv->vg);
-
 	if (!suspend_lv(cmd, lv)) {
 		log_error("Failed to lock %s", lv->name);
 		vg_revert(lv->vg);
-		return 0;
+		goto out;
 	}
 
 	if (!vg_commit(lv->vg)) {
 		resume_lv(cmd, lv);
-		return 0;
+		goto_out;
 	}
 
 	log_very_verbose("Updating \"%s\" in kernel", lv->name);
 
 	if (!resume_lv(cmd, lv)) {
 		log_error("Problem reactivating %s", lv->name);
-		return 0;
+		goto out;
 	}
 
 	if (!lp->need_polling)
 		log_print("Logical volume %s converted.", lv->name);
 
-	return 1;
+	r = 1;
+out:
+	backup(lv->vg);
+	return r;
 }
 
 static int lvconvert_snapshot(struct cmd_context *cmd,
@@ -620,6 +624,7 @@
 			      struct lvconvert_params *lp)
 {
 	struct logical_volume *org;
+	int r = 0;
 
 	if (!(org = find_lv(lv->vg, lp->origin))) {
 		log_error("Couldn't find origin volume '%s'.", lp->origin);
@@ -664,25 +669,25 @@
 	if (!vg_write(lv->vg))
 		return_0;
 
-	backup(lv->vg);
-
 	if (!suspend_lv(cmd, org)) {
 		log_error("Failed to suspend origin %s", org->name);
 		vg_revert(lv->vg);
-		return 0;
+		goto out;
 	}
 
 	if (!vg_commit(lv->vg))
-		return_0;
+		goto_out;
 
 	if (!resume_lv(cmd, org)) {
 		log_error("Problem reactivating origin %s", org->name);
-		return 0;
+		goto out;
 	}
 
 	log_print("Logical volume %s converted to snapshot.", lv->name);
-
-	return 1;
+	r = 1;
+out:
+	backup(lv->vg);
+	return r;
 }
 
 static int lvconvert_single(struct cmd_context *cmd, struct logical_volume *lv,
--- LVM2/tools/lvcreate.c	2009/04/10 10:01:38	1.181
+++ LVM2/tools/lvcreate.c	2009/04/21 14:31:58	1.182
@@ -786,14 +786,11 @@
 	}
 
 	/* store vg on disk(s) */
-	if (!vg_write(vg))
+	if (!vg_write(vg) || !vg_commit(vg))
 		return_0;
 
 	backup(vg);
 
-	if (!vg_commit(vg))
-		return_0;
-
 	if (lp->snapshot) {
 		if (!activate_lv_excl(cmd, lv)) {
 			log_error("Aborting. Failed to activate snapshot "
@@ -878,9 +875,12 @@
 
 revert_new_lv:
 	/* FIXME Better to revert to backup of metadata? */
-	if (!lv_remove(lv) || !vg_write(vg) || (backup(vg), !vg_commit(vg)))
+	if (!lv_remove(lv) || !vg_write(vg) || !vg_commit(vg))
 		log_error("Manual intervention may be required to remove "
 			  "abandoned LV(s) before retrying.");
+	else
+		backup(vg);
+
 	return 0;
 }
 
--- LVM2/tools/lvresize.c	2009/04/10 10:01:38	1.106
+++ LVM2/tools/lvresize.c	2009/04/21 14:31:58	1.107
@@ -626,8 +626,6 @@
 		return ECMD_FAILED;
 	}
 
-	backup(vg);
-
 	/* If snapshot, must suspend all associated devices */
 	if (lv_is_cow(lv))
 		lock_lv = origin_from_cow(lv);
@@ -637,20 +635,25 @@
 	if (!suspend_lv(cmd, lock_lv)) {
 		log_error("Failed to suspend %s", lp->lv_name);
 		vg_revert(vg);
+		backup(vg);
 		return ECMD_FAILED;
 	}
 
 	if (!vg_commit(vg)) {
 		stack;
 		resume_lv(cmd, lock_lv);
+		backup(vg);
 		return ECMD_FAILED;
 	}
 
 	if (!resume_lv(cmd, lock_lv)) {
 		log_error("Problem reactivating %s", lp->lv_name);
+		backup(vg);
 		return ECMD_FAILED;
 	}
 
+	backup(vg);
+
 	log_print("Logical volume %s successfully resized", lp->lv_name);
 
 	if (lp->resizefs && (lp->resize == LV_EXTEND) &&
--- LVM2/tools/pvmove.c	2009/04/10 10:01:38	1.56
+++ LVM2/tools/pvmove.c	2009/04/21 14:31:58	1.57
@@ -280,6 +280,7 @@
 {
 	unsigned exclusive = _pvmove_is_exclusive(cmd, vg);
 	unsigned first_time = (flags & PVMOVE_FIRST_TIME) ? 1 : 0;
+	int r = 0;
 
 	log_verbose("Updating volume group metadata");
 	if (!vg_write(vg)) {
@@ -287,19 +288,16 @@
 		return 0;
 	}
 
-	backup(vg);
-
 	/* Suspend lvs_changed */
 	if (!suspend_lvs(cmd, lvs_changed))
-		return_0;
+		goto_out;
 
 	/* Suspend mirrors on subsequent calls */
 	if (!first_time) {
 		if (!suspend_lv(cmd, lv_mirr)) {
-			stack;
 			resume_lvs(cmd, lvs_changed);
 			vg_revert(vg);
-			return 0;
+			goto_out;
 		}
 	}
 
@@ -309,7 +307,7 @@
 		if (!first_time)
 			resume_lv(cmd, lv_mirr);
 		resume_lvs(cmd, lvs_changed);
-		return 0;
+		goto out;
 	}
 
 	/* Activate the temporary mirror LV */
@@ -323,22 +321,25 @@
 					  "Run pvmove --abort.");
 			/* FIXME Resume using *original* metadata here! */
 			resume_lvs(cmd, lvs_changed);
-			return 0;
+			goto out;
 		}
 	} else if (!resume_lv(cmd, lv_mirr)) {
 		log_error("Unable to reactivate logical volume \"%s\"",
 			  lv_mirr->name);
 		resume_lvs(cmd, lvs_changed);
-		return 0;
+		goto out;
 	}
 
 	/* Unsuspend LVs */
 	if (!resume_lvs(cmd, lvs_changed)) {
 		log_error("Unable to resume logical volumes");
-		return 0;
+		goto out;
 	}
 
-	return 1;
+	r = 1;
+out:
+	backup(vg);
+	return r;
 }
 
 static int _set_up_pvmove(struct cmd_context *cmd, const char *pv_name,


