From: Jonathan Brassow <jbrassow@redhat.com>
Date: Sun, 15 Aug 2010 17:35:21 -0500
Subject: [PATCH 3 of 3] Handle failures of mirror devices while under snapshot origin (bug 613829)
Message-ID: <1281911721.30206.11.camel@hydrogen.msp.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch attempts to correct for the inability to handle mirror
failures under a snapshot origin.  There seem to be many ways to
solve this problem - some more hackish than others.  This patch
is a first attempt (that I am willing to publicly show).  I am
hoping it helps illustrate the problem and spawns some discussion.
It is a working solution - even if it is not elegant.

The problem revolves around the fact that the mirror device must
be suspended in order to be reconfigured.  Until it is reconfigured,
the kernel blocks all I/O.  The code attempts to suspend the chain
of devices from top to bottom as follows:
	origin -> mirror -> mirror legs/logs
Suspending in this way forces the origin to flush any outstanding I/O,
which will hang due to the blocking mirror.  The result is that the
entire stack stops WRT I/O and any LVM commands will hang too.

The solution is to recognize that it is the mirror we are targeting
for reconfiguration.  In this case, we must bypass the origin and
operate on the mirror.  This solution is complicated by the fact that
the origin and mirror share the same 'logical_volume' structure.  It
is not until the device-mapper layer that the two separate into
'my_lv' and 'my_lv-real' - where 'my_lv' would now represent the
origin and 'my_lv-real' represents the mirror device underneath it.
Therefore, it is impossible to address the mirror device directly at
the LVM code level.  We must instead somehow signal the necessity to
bypass the origin.  The best place to do this is likely in
'_remove_mirror_images' when calling 'suspend_lv' on the mirror that
is being reconfigured.  We may need a new macro, like
'suspend_lv_bypass_origin' (and by extention 'resume_lv_bypass_origin').

It would be nice if these new macros would be able to pass down the
LV's UUID + "-real" in order to directly affect the device we want,
however, the UUID (aka resource) is simply used later on as a way to
lookup the 'struct logical_volume' that is being suspended/resumed - and there
is no LV that represents the '-real' device as device-mapper knows it.
Therefore, the most likely solution will involve a new 'flag' that
would get passed on to 'lock_vol' that would signify the need to
bypass the origin.  This is nice because it should work in the cluster
context as well.  The new flag would reach down to the _*_lock_resource
functions.  At that point, I'm not sure we have any other choice but
to expand the parameters to lv_suspend_if_active and other functions,
or create new functions like, lv_suspend_if_active_bypass_origin...
Perhaps there is a mechanism for doing this by way of globally set
flags, similar to the way the monitor variable relates to its locking
flag, LCK_DMEVENTD_MONITOR_MODE.

At the moment, I've tried to minimize my changes by detecting which
type of suspend is necessary based on whether the mirror is being
altered (and if it is progressing from PARTIAL_LV to !PARTIAL_LV).
Upon resuming, I simply detect if the origin is not suspended, while
the mirror it rests on is suspended.  So, while this solution works,
it is somewhat incomplete because it does not run up the stack and
become available to any API.

RFC-by: Jonathan Brassow <jbrassow@redhat.com>

Index: LVM2/lib/activate/activate.c
===================================================================
--- LVM2.orig/lib/activate/activate.c
+++ LVM2/lib/activate/activate.c
@@ -610,6 +610,21 @@ static int _lv_activate_lv(struct logica
 	return r;
 }
 
+static int _lv_activate_lv_bypass_origin(struct logical_volume *lv)
+{
+	int r;
+	struct dev_manager *dm;
+
+	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name)))
+		return_0;
+
+	if (!(r = dev_manager_activate_bypass_origin(dm, lv)))
+		stack;
+
+	dev_manager_destroy(dm);
+	return r;
+}
+
 static int _lv_preload(struct logical_volume *lv, int *flush_required)
 {
 	int r;
@@ -655,6 +670,21 @@ static int _lv_suspend_lv(struct logical
 	return r;
 }
 
+static int _lv_suspend_lv_bypass_origin(struct logical_volume *lv)
+{
+	int r;
+	struct dev_manager *dm;
+
+	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name)))
+		return_0;
+
+	if (!(r = dev_manager_suspend_bypass_origin(dm, lv)))
+		stack;
+
+	dev_manager_destroy(dm);
+	return r;
+}
+
 /*
  * These two functions return the number of visible LVs in the state,
  * or -1 on error.
@@ -924,10 +954,19 @@ static int _lv_suspend(struct cmd_contex
 	if (lv_is_origin(lv_pre) || lv_is_cow(lv_pre))
 		lockfs = 1;
 
-	if (!_lv_suspend_lv(lv, lockfs, flush_required)) {
-		memlock_dec(cmd);
-		fs_unlock();
-		goto out;
+	if (lv_is_mirrored(lv) && (lv->status & PARTIAL_LV) &&
+	    !(lv_pre->status & PARTIAL_LV)) {
+		if (!_lv_suspend_lv_bypass_origin(lv)) {
+			memlock_dec(cmd);
+			fs_unlock();
+			goto out;
+		}
+	} else {
+		if (!_lv_suspend_lv(lv, lockfs, flush_required)) {
+			memlock_dec(cmd);
+			fs_unlock();
+			goto out;
+		}
 	}
 
 	r = 1;
@@ -975,14 +1014,32 @@ static int _lv_resume(struct cmd_context
 	if (!lv_info(cmd, lv, &info, 0, 0))
 		goto_out;
 
-	if (!info.exists || !info.suspended) {
+	if (!info.exists) {
 		if (error_if_not_active)
 			goto_out;
 		r = 1;
 		goto out;
 	}
 
-	if (!_lv_activate_lv(lv))
+	if (!info.suspended) {
+		if (!lv_is_origin(lv) && !lv_is_mirrored(lv)) {
+			if (error_if_not_active)
+				goto_out;
+			r = 1;
+			goto out;
+		}
+
+		/*
+		 * If the LV is both origin and mirror, and the
+		 * lv is not suspended, it means that the real
+		 * device (lv-real) is a mirror and is suspended.
+		 * We must activate(resume) the mirror independently
+		 * of the origin.
+		 */
+		if (!_lv_activate_lv_bypass_origin(lv))
+			goto_out;
+
+	} else if (!_lv_activate_lv(lv))
 		goto_out;
 
 	memlock_dec(cmd);
Index: LVM2/lib/activate/dev_manager.c
===================================================================
--- LVM2.orig/lib/activate/dev_manager.c
+++ LVM2/lib/activate/dev_manager.c
@@ -49,6 +49,7 @@ struct dev_manager {
 	void *target_state;
 	uint32_t pvmove_mirror_count;
 	int flush_required;
+	int bypass_origin;
 
 	char *vg_name;
 };
@@ -1015,7 +1016,9 @@ static int _add_partial_replicator_to_dt
  */
 static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree, struct logical_volume *lv)
 {
-	if (!_add_dev_to_dtree(dm, dtree, lv, NULL))
+	if (dm->bypass_origin && lv_is_origin(lv))
+		log_very_verbose("Bypassing origin: %s/%s", lv->vg->name, lv->name);
+	else if (!_add_dev_to_dtree(dm, dtree, lv, NULL))
 		return_0;
 
 	/* FIXME Can we avoid doing this every time? */
@@ -1025,7 +1028,7 @@ static int _add_lv_to_dtree(struct dev_m
 	if (!_add_dev_to_dtree(dm, dtree, lv, "cow"))
 		return_0;
 
-	if ((lv->status & MIRRORED) && first_seg(lv)->log_lv &&
+	if (lv_is_mirrored(lv) && first_seg(lv)->log_lv &&
 	    !_add_dev_to_dtree(dm, dtree, first_seg(lv)->log_lv, NULL))
 		return_0;
 
@@ -1659,7 +1662,8 @@ static int _tree_action(struct dev_manag
 		break;
 	case SUSPEND:
 		dm_tree_skip_lockfs(root);
-		if (!dm->flush_required && (lv->status & MIRRORED) && !(lv->status & PVMOVE))
+		if (dm->bypass_origin ||
+		    (!dm->flush_required && (lv->status & MIRRORED) && !(lv->status & PVMOVE)))
 			dm_tree_use_no_flush_suspend(root);
 	case SUSPEND_WITH_LOCKFS:
 		if (!dm_tree_suspend_children(root, dlid, ID_LEN + sizeof(UUID_PREFIX) - 1))
@@ -1668,7 +1672,8 @@ static int _tree_action(struct dev_manag
 	case PRELOAD:
 	case ACTIVATE:
 		/* Add all required new devices to tree */
-		if (!_add_new_lv_to_dtree(dm, dtree, lv, NULL))
+		if (!(dm->bypass_origin && lv_is_origin(lv)) &&
+		    !_add_new_lv_to_dtree(dm, dtree, lv, NULL))
 			goto_out;
 
 		/* Preload any devices required before any suspensions */
@@ -1717,6 +1722,14 @@ int dev_manager_activate(struct dev_mana
 	return _tree_action(dm, lv, CLEAN);
 }
 
+int dev_manager_activate_bypass_origin(struct dev_manager *dm,
+				       struct logical_volume *lv)
+{
+	dm->bypass_origin = 1;
+
+	return dev_manager_activate(dm, lv);
+}
+
 int dev_manager_preload(struct dev_manager *dm, struct logical_volume *lv,
 			int *flush_required)
 {
@@ -1749,6 +1762,14 @@ int dev_manager_suspend(struct dev_manag
 	return _tree_action(dm, lv, lockfs ? SUSPEND_WITH_LOCKFS : SUSPEND);
 }
 
+int dev_manager_suspend_bypass_origin(struct dev_manager *dm,
+				      struct logical_volume *lv)
+{
+	dm->bypass_origin = 1;
+
+	return dev_manager_suspend(dm, lv, 0, 0);
+}
+
 /*
  * Does device use VG somewhere in its construction?
  * Returns 1 if uncertain.
Index: LVM2/lib/activate/dev_manager.h
===================================================================
--- LVM2.orig/lib/activate/dev_manager.h
+++ LVM2/lib/activate/dev_manager.h
@@ -54,6 +54,10 @@ int dev_manager_mirror_percent(struct de
 int dev_manager_suspend(struct dev_manager *dm, struct logical_volume *lv,
 			int lockfs, int flush_required);
 int dev_manager_activate(struct dev_manager *dm, struct logical_volume *lv);
+int dev_manager_suspend_bypass_origin(struct dev_manager *dm,
+				      struct logical_volume *lv);
+int dev_manager_activate_bypass_origin(struct dev_manager *dm,
+				       struct logical_volume *lv);
 int dev_manager_preload(struct dev_manager *dm, struct logical_volume *lv,
 			int *flush_required);
 int dev_manager_deactivate(struct dev_manager *dm, struct logical_volume *lv);



