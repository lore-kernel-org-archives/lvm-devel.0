From: agk@sourceware.org <agk@sourceware.org>
Date: 13 Jun 2011 22:28:05 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/activate.c lib/m ...
Message-ID: <20110613222805.12344.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-06-13 22:28:05

Modified files:
	.              : WHATS_NEW 
	lib/activate   : activate.c 
	lib/metadata   : lv_manip.c 

Log message:
	Fix last snapshot removal to avoid table reload while a device is suspended.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2013&r2=1.2014
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.197&r2=1.198
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.261&r2=1.262

--- LVM2/WHATS_NEW	2011/06/13 03:32:45	1.2013
+++ LVM2/WHATS_NEW	2011/06/13 22:28:04	1.2014
@@ -1,5 +1,6 @@
 Version 2.02.86 -  
 =================================
+  Fix last snapshot removal to avoid table reload while a device is suspended.
   Use dm_get_suspended_counter in replacement critical_section logic.
   Downgrade critical_section errors to debug level until it is moved to libdm.
   Fix ignored background polling default in vgchange -ay.
--- LVM2/lib/activate/activate.c	2011/06/11 00:03:07	1.197
+++ LVM2/lib/activate/activate.c	2011/06/13 22:28:04	1.198
@@ -534,6 +534,8 @@
 	if (!activation())
 		return 0;
 
+	log_debug("Checking transient status for LV %s/%s", lv->vg->name, lv->name);
+
 	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name, 1)))
 		return_0;
 
@@ -556,6 +558,8 @@
 	if (!activation())
 		return 0;
 
+	log_debug("Checking snapshot percent for LV %s/%s", lv->vg->name, lv->name);
+
 	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name, 1)))
 		return_0;
 
@@ -585,6 +589,8 @@
 	if (!activation())
 		return 0;
 
+	log_debug("Checking mirror percent for LV %s/%s", lv->vg->name, lv->name);
+
 	if (!lv_info(cmd, lv, 0, &info, 0, 0))
 		return_0;
 
@@ -692,7 +698,7 @@
 
 /*
  * These two functions return the number of visible LVs in the state,
- * or -1 on error.
+ * or -1 on error.  FIXME Check this.
  */
 int lvs_in_vg_activated(struct volume_group *vg)
 {
@@ -702,10 +708,11 @@
 	if (!activation())
 		return 0;
 
-	dm_list_iterate_items(lvl, &vg->lvs) {
+	dm_list_iterate_items(lvl, &vg->lvs)
 		if (lv_is_visible(lvl->lv))
 			count += (_lv_active(vg->cmd, lvl->lv) == 1);
-	}
+
+	log_debug("Counted %d active LVs in VG %s", count, vg->name);
 
 	return count;
 }
@@ -718,10 +725,11 @@
 	if (!activation())
 		return 0;
 
-	dm_list_iterate_items(lvl, &vg->lvs) {
+	dm_list_iterate_items(lvl, &vg->lvs)
 		if (lv_is_visible(lvl->lv))
 			count += (_lv_open_count(vg->cmd, lvl->lv) > 0);
-	}
+
+	log_debug("Counted %d open LVs in VG %s", count, vg->name);
 
 	return count;
 }
@@ -822,12 +830,14 @@
 int lv_is_active_exclusive_locally(struct logical_volume *lv)
 {
 	int l, e;
+
 	return _lv_is_active(lv, &l, &e) && l && e;
 }
 
 int lv_is_active_exclusive_remotely(struct logical_volume *lv)
 {
 	int l, e;
+
 	return _lv_is_active(lv, &l, &e) && !l && e;
 }
 
@@ -1258,6 +1268,10 @@
 		goto out;
 	}
 
+	log_debug("Resuming LV %s/%s%s%s.", lv->vg->name, lv->name,
+		  error_if_not_active ? "" : " if active",
+		  origin_only ? " without snapshots" : "");
+
 	if (!lv_info(cmd, lv, origin_only, &info, 0, 0))
 		goto_out;
 
@@ -1347,6 +1361,8 @@
 		goto out;
 	}
 
+	log_debug("Deactivating %s/%s.", lv->vg->name, lv->name);
+
 	if (!lv_info(cmd, lv, 0, &info, 1, 0))
 		goto_out;
 
@@ -1454,6 +1470,8 @@
 		goto out;
 	}
 
+	log_debug("Activating %s/%s%s.", lv->vg->name, lv->name, exclusive ? " exclusively" : "");
+
 	if (!lv_info(cmd, lv, 0, &info, 0, 0))
 		goto_out;
 
--- LVM2/lib/metadata/lv_manip.c	2011/06/11 00:03:07	1.261
+++ LVM2/lib/metadata/lv_manip.c	2011/06/13 22:28:05	1.262
@@ -2677,6 +2677,7 @@
 	struct lvinfo info;
 	struct logical_volume *origin = NULL;
 	int was_merging = 0;
+	int reload_required = 0;
 
 	vg = lv->vg;
 
@@ -2738,6 +2739,7 @@
 			return_0;
 	}
 
+	/* FIXME Review and fix the snapshot error paths! */
 	if (!deactivate_lv(cmd, lv)) {
 		log_error("Unable to deactivate logical volume \"%s\"",
 			  lv->name);
@@ -2750,20 +2752,24 @@
 		return 0;
 	}
 
+	/* If no snapshots left, and was not merging, reload without -real. */
+	if (origin && (!lv_is_origin(origin) && !was_merging))
+		reload_required = 1;
+
 	/* store it on disks */
-	if (!vg_write(vg) || !vg_commit(vg))
+	if (!vg_write(vg))
 		return_0;
 
-	/* If no snapshots left, and was not merging, reload without -real. */
-	if (origin && (!lv_is_origin(origin) && !was_merging)) {
-		if (!suspend_lv(cmd, origin)) {
-			log_error("Failed to refresh %s without snapshot.", origin->name);
-			return 0;
-		}
-		if (!resume_lv(cmd, origin)) {
-			log_error("Failed to resume %s.", origin->name);
-			return 0;
-		}
+	if (reload_required && !suspend_lv(cmd, origin))
+		log_error("Failed to refresh %s without snapshot.", origin->name);
+		/* FIXME Falls through because first part of change already in kernel! */
+
+	if (!vg_commit(vg))
+		return_0;
+
+	if (reload_required && !resume_lv(cmd, origin)) {
+		log_error("Failed to resume %s.", origin->name);
+		return 0;
 	}
 
 	backup(vg);


