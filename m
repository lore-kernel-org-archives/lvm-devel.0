From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 10 Apr 2009 10:00:06 -0000
Subject: LVM2 daemons/clvmd/lvm-functions.c lib/activat ...
Message-ID: <20090410100006.19820.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-04-10 10:00:05

Modified files:
	daemons/clvmd  : lvm-functions.c 
	lib/activate   : activate.c 

Log message:
	Properly release VG memory pool in activation code and clvmd.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.58&r2=1.59
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.144&r2=1.145

--- LVM2/daemons/clvmd/lvm-functions.c	2009/03/05 16:25:36	1.58
+++ LVM2/daemons/clvmd/lvm-functions.c	2009/04/10 10:00:04	1.59
@@ -724,6 +724,7 @@
 	else
 		log_error("Error backing up metadata, can't find VG for group %s", vgname);
 
+	vg_release(vg);
 	dm_pool_empty(cmd->mem);
 
 	pthread_mutex_unlock(&lvm_lock);
--- LVM2/lib/activate/activate.c	2009/02/28 00:54:06	1.144
+++ LVM2/lib/activate/activate.c	2009/04/10 10:00:04	1.145
@@ -843,36 +843,39 @@
 static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
 		       int error_if_not_suspended)
 {
-	struct logical_volume *lv, *lv_pre;
+	struct logical_volume *lv = NULL, *lv_pre = NULL;
 	struct lvinfo info;
-	int lockfs = 0;
+	int r = 0, lockfs = 0;
 
 	if (!activation())
 		return 1;
 
 	if (!(lv = lv_from_lvid(cmd, lvid_s, 0)))
-		return_0;
+		goto_out;
 
 	/* Use precommitted metadata if present */
 	if (!(lv_pre = lv_from_lvid(cmd, lvid_s, 1)))
-		return_0;
+		goto_out;
 
 	if (test_mode()) {
 		_skip("Suspending '%s'.", lv->name);
-		return 1;
+		r = 1;
+		goto out;
 	}
 
 	if (!lv_info(cmd, lv, &info, 0, 0))
-		return_0;
+		goto_out;
 
-	if (!info.exists || info.suspended)
-		return error_if_not_suspended ? 0 : 1;
+	if (!info.exists || info.suspended) {
+		r = error_if_not_suspended ? 0 : 1;
+		goto out;
+	}
 
 	/* If VG was precommitted, preload devices for the LV */
 	if ((lv_pre->vg->status & PRECOMMITTED)) {
 		if (!_lv_preload(lv_pre)) {
 			/* FIXME Revert preloading */
-			return_0;
+			goto_out;
 		}
 	}
 
@@ -888,10 +891,17 @@
 	if (!_lv_suspend_lv(lv, lockfs)) {
 		memlock_dec();
 		fs_unlock();
-		return 0;
+		goto out;
 	}
 
-	return 1;
+	r = 1;
+out:
+	if (lv_pre)
+		vg_release(lv_pre->vg);
+	if (lv)
+		vg_release(lv->vg);
+
+	return r;
 }
 
 /* Returns success if the device is not active */
@@ -910,26 +920,30 @@
 {
 	struct logical_volume *lv;
 	struct lvinfo info;
+	int r = 0;
 
 	if (!activation())
 		return 1;
 
 	if (!(lv = lv_from_lvid(cmd, lvid_s, 0)))
-		return 0;
+		goto out;
 
 	if (test_mode()) {
 		_skip("Resuming '%s'.", lv->name);
-		return 1;
+		r = 1;
+		goto out;
 	}
 
 	if (!lv_info(cmd, lv, &info, 0, 0))
-		return_0;
+		goto_out;
 
-	if (!info.exists || !info.suspended)
-		return error_if_not_active ? 0 : 1;
+	if (!info.exists || !info.suspended) {
+		r = error_if_not_active ? 0 : 1;
+		goto out;
+	}
 
 	if (!_lv_activate_lv(lv))
-		return 0;
+		goto out;
 
 	memlock_dec();
 	fs_unlock();
@@ -937,7 +951,12 @@
 	if (!monitor_dev_for_events(cmd, lv, 1))
 		stack;
 
-	return 1;
+	r = 1;
+out:
+	if (lv)
+		vg_release(lv->vg);
+
+	return r;
 }
 
 /* Returns success if the device is not active */
@@ -955,29 +974,32 @@
 {
 	struct logical_volume *lv;
 	struct lvinfo info;
-	int r;
+	int r = 0;
 
 	if (!activation())
 		return 1;
 
 	if (!(lv = lv_from_lvid(cmd, lvid_s, 0)))
-		return 0;
+		goto out;
 
 	if (test_mode()) {
 		_skip("Deactivating '%s'.", lv->name);
-		return 1;
+		r = 1;
+		goto out;
 	}
 
 	if (!lv_info(cmd, lv, &info, 1, 0))
-		return_0;
+		goto_out;
 
-	if (!info.exists)
-		return 1;
+	if (!info.exists) {
+		r = 1;
+		goto out;
+	}
 
 	if (info.open_count && (lv->status & VISIBLE_LV)) {
 		log_error("LV %s/%s in use: not deactivating", lv->vg->name,
 			  lv->name);
-		return 0;
+		goto out;
 	}
 
 	if (!monitor_dev_for_events(cmd, lv, 0))
@@ -988,6 +1010,10 @@
 	memlock_dec();
 	fs_unlock();
 
+out:
+	if (lv)
+		vg_release(lv->vg);
+
 	return r;
 }
 
@@ -996,23 +1022,28 @@
 			 int *activate_lv)
 {
 	struct logical_volume *lv;
+	int r = 0;
 
-	if (!activation())
-		goto activate;
+	if (!activation()) {
+		*activate_lv = 1;
+		return 1;
+	}
 
 	if (!(lv = lv_from_lvid(cmd, lvid_s, 0)))
-		return 0;
+		goto out;
 
 	if (!_passes_activation_filter(cmd, lv)) {
 		log_verbose("Not activating %s/%s due to config file settings",
 			    lv->vg->name, lv->name);
 		*activate_lv = 0;
-		return 1;
-	}
+	} else
+		*activate_lv = 1;
+	r = 1;
+out:
+	if (lv)
+		vg_release(lv->vg);
 
-      activate:
-	*activate_lv = 1;
-	return 1;
+	return r;
 }
 
 static int _lv_activate(struct cmd_context *cmd, const char *lvid_s,
@@ -1020,36 +1051,39 @@
 {
 	struct logical_volume *lv;
 	struct lvinfo info;
-	int r;
+	int r = 0;
 
 	if (!activation())
 		return 1;
 
 	if (!(lv = lv_from_lvid(cmd, lvid_s, 0)))
-		return 0;
+		goto out;
 
 	if (filter && !_passes_activation_filter(cmd, lv)) {
 		log_verbose("Not activating %s/%s due to config file settings",
 			    lv->vg->name, lv->name);
-		return 0;
+		goto out;
 	}
 
 	if ((!lv->vg->cmd->partial_activation) && (lv->status & PARTIAL_LV)) {
 		log_error("Refusing activation of partial LV %s. Use --partial to override.",
 			  lv->name);
-		return_0;
+		goto_out;
 	}
 
 	if (test_mode()) {
 		_skip("Activating '%s'.", lv->name);
-		return 1;
+		r = 1;
+		goto out;
 	}
 
 	if (!lv_info(cmd, lv, &info, 0, 0))
-		return_0;
+		goto_out;
 
-	if (info.exists && !info.suspended && info.live_table)
-		return 1;
+	if (info.exists && !info.suspended && info.live_table) {
+		r = 1;
+		goto out;
+	}
 
 	if (exclusive)
 		lv->status |= ACTIVATE_EXCL;
@@ -1062,6 +1096,10 @@
 	if (r && !monitor_dev_for_events(cmd, lv, 1))
 		stack;
 
+out:
+	if (lv)
+		vg_release(lv->vg);
+
 	return r;
 }
 


