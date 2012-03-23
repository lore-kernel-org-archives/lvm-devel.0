From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 23 Mar 2012 09:58:06 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/activate.c lib/a ...
Message-ID: <20120323095806.24737.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-23 09:58:05

Modified files:
	.              : WHATS_NEW 
	lib/activate   : activate.c activate.h 
	lib/metadata   : thin_manip.c 
	tools          : lvchange.c vgchange.c 

Log message:
	Update and fix monitoring of thin pool devices
	
	Code adds better support for monitoring of thin pool devices.
	update_pool_lv uses DMEVENTD_MONITOR_IGNORE to not manipulate with monitoring.
	vgchange & lvchange are checking real thin pool device for existance
	as we are using   _tpool  real device and visible LV pool device might not
	be even active (_tpool is activated implicitely for any thin volume).
	monitor_dev_for_events is another _lv_postorder like code it might be worth
	to think about reusing it here - for now update the code to properly
	monitory thin volume deps.
	For unmonitoring add extra code to check the usage of thin pool - in case it's in use
	unmonitoring of thin volume is skipped.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2364&r2=1.2365
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.243&r2=1.244
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.h.diff?cvsroot=lvm2&r1=1.98&r2=1.99
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/thin_manip.c.diff?cvsroot=lvm2&r1=1.35&r2=1.36
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvchange.c.diff?cvsroot=lvm2&r1=1.140&r2=1.141
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgchange.c.diff?cvsroot=lvm2&r1=1.131&r2=1.132

--- LVM2/WHATS_NEW	2012/03/23 09:48:17	1.2364
+++ LVM2/WHATS_NEW	2012/03/23 09:58:04	1.2365
@@ -1,5 +1,6 @@
 Version 2.02.96 - 
 ================================
+  Update and fix monitoring of thin pool devices.
   Check hash insert success in lock_vg clvmd.
   Check for buffer overwrite in get_cluster_type() clvmd.
   Fix global/detect_internal_vg_cache_corruption config check.
--- LVM2/lib/activate/activate.c	2012/02/23 22:42:00	1.243
+++ LVM2/lib/activate/activate.c	2012/03/23 09:58:05	1.244
@@ -1221,6 +1221,8 @@
 	int (*monitor_fn) (struct lv_segment *s, int e);
 	uint32_t s;
 	static const struct lv_activate_opts zlaopts = { 0 };
+	static const struct lv_activate_opts thinopts = { .skip_in_use = 1 };
+	struct lvinfo info;
 
 	if (!laopts)
 		laopts = &zlaopts;
@@ -1236,6 +1238,19 @@
 		return 1;
 
 	/*
+	 * Allow to unmonitor thin pool via explicit pool unmonitor
+	 * or unmonitor before the last thin pool user deactivation
+	 * Skip unmonitor, if invoked via unmonitor of thin volume
+	 * and there is another thin pool user (open_count > 1)
+	 */
+	if (laopts->skip_in_use && lv_info(lv->vg->cmd, lv, 1, &info, 1, 0) &&
+	    (info.open_count != 1)) {
+		log_debug("Skipping unmonitor of opened %s (open:%d)",
+			  lv->name, info.open_count);
+		return 1;
+	}
+
+	/*
 	 * In case of a snapshot device, we monitor lv->snapshot->lv,
 	 * not the actual LV itself.
 	 */
@@ -1279,6 +1294,21 @@
 			}
 		}
 
+		/*
+		 * If requested unmonitoring of thin volume, request test
+		 * if there is no other thin pool user
+		 *
+		 * FIXME: code here looks like _lv_postorder()
+		 */
+		if (seg->pool_lv &&
+		    !monitor_dev_for_events(cmd, seg->pool_lv,
+					    (!monitor) ? &thinopts : NULL, monitor))
+			r = 0;
+
+		if (seg->metadata_lv &&
+		    !monitor_dev_for_events(cmd, seg->metadata_lv, NULL, monitor))
+			r = 0;
+
 		if (!seg_monitored(seg) || (seg->status & PVMOVE))
 			continue;
 
--- LVM2/lib/activate/activate.h	2012/02/23 22:42:00	1.98
+++ LVM2/lib/activate/activate.h	2012/03/23 09:58:05	1.99
@@ -36,6 +36,7 @@
 	int no_merging;
 	int real_pool;
 	int is_activate;
+	int skip_in_use;
 	unsigned revert;
 	unsigned read_only;
 };
--- LVM2/lib/metadata/thin_manip.c	2012/03/02 13:26:09	1.35
+++ LVM2/lib/metadata/thin_manip.c	2012/03/23 09:58:05	1.36
@@ -388,6 +388,8 @@
 
 int update_pool_lv(struct logical_volume *lv, int activate)
 {
+	int monitored;
+
 	if (!lv_is_thin_pool(lv)) {
 		log_error(INTERNAL_ERROR "Updated LV %s is not pool.", lv->name);
 		return 0;
@@ -399,10 +401,13 @@
 	if (activate) {
 		/* If the pool is not active, do activate deactivate */
 		if (!lv_is_active(lv)) {
+			monitored = dmeventd_monitor_mode();
+			init_dmeventd_monitor(DMEVENTD_MONITOR_IGNORE);
 			if (!activate_lv_excl(lv->vg->cmd, lv))
 				return_0;
 			if (!deactivate_lv(lv->vg->cmd, lv))
 				return_0;
+			init_dmeventd_monitor(monitored);
 		}
 		/*
 		 * Resume active pool to send thin messages.
--- LVM2/tools/lvchange.c	2012/03/06 02:30:50	1.140
+++ LVM2/tools/lvchange.c	2012/03/23 09:58:05	1.141
@@ -94,7 +94,8 @@
 {
 	struct lvinfo info;
 
-	if (!lv_info(cmd, lv, 0, &info, 0, 0) || !info.exists) {
+	if (!lv_info(cmd, lv, lv_is_thin_pool(lv) ? 1 : 0,
+		     &info, 0, 0) || !info.exists) {
 		log_error("Logical volume, %s, is not active", lv->name);
 		return 0;
 	}
--- LVM2/tools/vgchange.c	2012/02/28 14:24:59	1.131
+++ LVM2/tools/vgchange.c	2012/03/23 09:58:05	1.132
@@ -24,21 +24,19 @@
 	struct lv_list *lvl;
 	struct logical_volume *lv;
 	struct lvinfo info;
-	int lv_active;
 	int r = 1;
 
 	dm_list_iterate_items(lvl, &vg->lvs) {
 		lv = lvl->lv;
 
-		if (!lv_info(cmd, lv, 0, &info, 0, 0))
-			lv_active = 0;
-		else
-			lv_active = info.exists;
-
+		if (!lv_info(cmd, lv, lv_is_thin_pool(lv) ? 1 : 0,
+			     &info, 0, 0) ||
+		    !info.exists)
+			continue;
 		/*
 		 * FIXME: Need to consider all cases... PVMOVE, etc
 		 */
-		if ((lv->status & PVMOVE) || !lv_active)
+		if (lv->status & PVMOVE)
 			continue;
 
 		if (!monitor_dev_for_events(cmd, lv, 0, reg)) {


