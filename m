From: agk@sourceware.org <agk@sourceware.org>
Date: 19 Jan 2007 22:21:48 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/lvm-functions.c ...
Message-ID: <20070119222148.27021.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-01-19 22:21:46

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : lvm-functions.c 
	lib/activate   : activate.c activate.h 
	lib/locking    : cluster_locking.c locking.h 
	lib/log        : log.c log.h 
	lib/metadata   : segtype.h 
	lib/mirror     : mirrored.c 
	tools          : lvchange.c vgchange.c 

Log message:
	register->monitor etc.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.548&r2=1.549
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.25&r2=1.26
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.116&r2=1.117
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.h.diff?cvsroot=lvm2&r1=1.52&r2=1.53
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/cluster_locking.c.diff?cvsroot=lvm2&r1=1.16&r2=1.17
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.h.diff?cvsroot=lvm2&r1=1.29&r2=1.30
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/log/log.c.diff?cvsroot=lvm2&r1=1.35&r2=1.36
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/log/log.h.diff?cvsroot=lvm2&r1=1.32&r2=1.33
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/segtype.h.diff?cvsroot=lvm2&r1=1.15&r2=1.16
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mirror/mirrored.c.diff?cvsroot=lvm2&r1=1.43&r2=1.44
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvchange.c.diff?cvsroot=lvm2&r1=1.76&r2=1.77
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgchange.c.diff?cvsroot=lvm2&r1=1.55&r2=1.56

--- LVM2/WHATS_NEW	2007/01/18 22:33:24	1.548
+++ LVM2/WHATS_NEW	2007/01/19 22:21:44	1.549
@@ -1,5 +1,6 @@
 Version 2.02.20 -
 ===================================
+  Change remaining dmeventd terminology 'register' to 'monitor'.
   Update reporting man pages.
   No longer necessary to specify alignment for report fields.
 
--- LVM2/daemons/clvmd/lvm-functions.c	2006/10/24 18:49:31	1.25
+++ LVM2/daemons/clvmd/lvm-functions.c	2007/01/19 22:21:45	1.26
@@ -325,8 +325,8 @@
 	if (lock_flags & LCK_MIRROR_NOSYNC_MODE)
 		init_mirror_in_sync(1);
 
-	if (!(lock_flags & LCK_DMEVENTD_REGISTER_MODE))
-		init_dmeventd_register(0);
+	if (!(lock_flags & LCK_DMEVENTD_MONITOR_MODE))
+		init_dmeventd_monitor(0);
 
 	switch (command) {
 	case LCK_LV_EXCLUSIVE:
@@ -362,8 +362,8 @@
 	if (lock_flags & LCK_MIRROR_NOSYNC_MODE)
 		init_mirror_in_sync(0);
 
-	if (!(lock_flags & LCK_DMEVENTD_REGISTER_MODE))
-		init_dmeventd_register(DEFAULT_DMEVENTD_MONITOR);
+	if (!(lock_flags & LCK_DMEVENTD_MONITOR_MODE))
+		init_dmeventd_monitor(DEFAULT_DMEVENTD_MONITOR);
 
 	/* clean the pool for another command */
 	dm_pool_empty(cmd->mem);
--- LVM2/lib/activate/activate.c	2007/01/12 20:38:29	1.116
+++ LVM2/lib/activate/activate.c	2007/01/19 22:21:45	1.117
@@ -640,28 +640,23 @@
 }
 
 /*
- * register_dev_for_events
- *
- * This function uses proper error codes (but breaks convention)
- * to return:
- *      -1 on error
- *       0 if the lv's targets don't do event [un]registration
- *       0 if the lv is already [un]registered -- FIXME: not implemented
- *       1 if the lv had a segment which was [un]registered
- *
- * Returns: -1 on error
+ * Returns 0 if an attempt to (un)monitor the device failed.
+ * Returns 1 otherwise.
  */
-int register_dev_for_events(struct cmd_context *cmd,
-			    struct logical_volume *lv, int do_reg)
+int monitor_dev_for_events(struct cmd_context *cmd,
+			    struct logical_volume *lv, int monitor)
 {
 #ifdef DMEVENTD
-	int i, pending = 0, registered;
-	int r = 0;
+	int i, pending = 0, monitored;
+	int r = 1;
 	struct list *tmp;
 	struct lv_segment *seg;
-	int (*reg) (struct cmd_context *c, struct lv_segment *s, int e);
+	int (*monitor_fn) (struct cmd_context *c, struct lv_segment *s, int e);
 
-	if (do_reg && !dmeventd_register_mode())
+	/*
+	 * Nothing to do if dmeventd configured not to be used.
+	 */
+	if (monitor && !dmeventd_monitor_mode())
 		return 1;
 
 	list_iterate(tmp, &lv->segments) {
@@ -669,57 +664,61 @@
 
 		if (!seg_monitored(seg) || (seg->status & PVMOVE))
 			continue;
-		reg = NULL;
+
+		monitor_fn = NULL;
 
 		/* Check monitoring status */
-		if (seg->segtype->ops->target_registered)
-			registered = seg->segtype->ops->target_registered(seg, &pending);
+		if (seg->segtype->ops->target_monitored)
+			monitored = seg->segtype->ops->target_monitored(seg, &pending);
 		else
 			continue;  /* segtype doesn't support registration */
 
 		/*
 		 * FIXME: We should really try again if pending
 		 */
-		registered = (pending) ? 0 : registered;
+		monitored = (pending) ? 0 : monitored;
 
-		if (do_reg) {
-			if (registered)
+		if (monitor) {
+			if (monitored)
 				log_verbose("%s/%s already monitored.", lv->vg->name, lv->name);
-			else if (seg->segtype->ops->target_register_events)
-				reg = seg->segtype->ops->target_register_events;
+			else if (seg->segtype->ops->target_monitor_events)
+				monitor_fn = seg->segtype->ops->target_monitor_events;
 		} else {
-			if (!registered)
+			if (!monitored)
 				log_verbose("%s/%s already not monitored.", lv->vg->name, lv->name);
-			else if (seg->segtype->ops->target_unregister_events)
-				reg = seg->segtype->ops->target_unregister_events;
+			else if (seg->segtype->ops->target_unmonitor_events)
+				monitor_fn = seg->segtype->ops->target_unmonitor_events;
 		}
 
 		/* Do [un]monitor */
-		if (!reg)
+		if (!monitor_fn)
 			continue;
 
+		log_verbose("%sonitoring %s/%s", monitor ? "M" : "Not m", lv->vg->name, lv->name);
+
 		/* FIXME specify events */
-		if (!reg(cmd, seg, 0)) {
-			stack;
-			return -1;
+		if (!monitor_fn(cmd, seg, 0)) {
+			log_error("%s/%s: %s segment monitoring function failed.",
+				  lv->vg->name, lv->name, seg->segtype->name);
+			return 0;
 		}
 
 		/* Check [un]monitor results */
 		/* Try a couple times if pending, but not forever... */
 		for (i = 0; i < 10; i++) {
 			pending = 0;
-			registered = seg->segtype->ops->target_registered(seg, &pending);
+			monitored = seg->segtype->ops->target_monitored(seg, &pending);
 			if (pending ||
-			    (!registered && do_reg) ||
-			    (registered && !do_reg))
-				log_very_verbose("%s/%s %smonitoring still pending.",
-						 lv->vg->name, lv->name, do_reg ? "" : "un");
+			    (!monitored && monitor) ||
+			    (monitored && !monitor))
+				log_very_verbose("%s/%s %smonitoring still pending: waiting...",
+						 lv->vg->name, lv->name, monitor ? "" : "un");
 			else
 				break;
 			sleep(1);
 		}
 
-		r = (registered && do_reg) || (!registered && !do_reg);
+		r = (monitored && monitor) || (!monitored && !monitor);
 	}
 
 	return r;
@@ -764,7 +763,7 @@
 		}
 	}
 
-	if (register_dev_for_events(cmd, lv, 0) < 0)
+	if (!monitor_dev_for_events(cmd, lv, 0))
 		/* FIXME Consider aborting here */
 		stack;
 
@@ -822,7 +821,7 @@
 	memlock_dec();
 	fs_unlock();
 
-	if (register_dev_for_events(cmd, lv, 1) < 0)
+	if (!monitor_dev_for_events(cmd, lv, 1))
 		stack;
 
 	return 1;
@@ -868,7 +867,7 @@
 		return 0;
 	}
 
-	if (register_dev_for_events(cmd, lv, 0) < 0)
+	if (!monitor_dev_for_events(cmd, lv, 0))
 		stack;
 
 	memlock_inc();
@@ -941,7 +940,7 @@
 	memlock_dec();
 	fs_unlock();
 
-	if (!register_dev_for_events(cmd, lv, 1) < 0)
+	if (!monitor_dev_for_events(cmd, lv, 1))
 		stack;
 
 	return r;
--- LVM2/lib/activate/activate.h	2006/10/03 17:55:19	1.52
+++ LVM2/lib/activate/activate.h	2007/01/19 22:21:45	1.53
@@ -86,7 +86,7 @@
 int lvs_in_vg_opened(struct volume_group *vg);
 
 
-int register_dev_for_events(struct cmd_context *cmd,
+int monitor_dev_for_events(struct cmd_context *cmd,
 			    struct logical_volume *lv, int do_reg);
 
 /*
--- LVM2/lib/locking/cluster_locking.c	2006/12/01 23:10:26	1.16
+++ LVM2/lib/locking/cluster_locking.c	2007/01/19 22:21:45	1.17
@@ -321,8 +321,8 @@
 	if (mirror_in_sync())
 		args[1] |= LCK_MIRROR_NOSYNC_MODE;
 
-	if (dmeventd_register_mode())
-		args[1] |= LCK_DMEVENTD_REGISTER_MODE;
+	if (dmeventd_monitor_mode())
+		args[1] |= LCK_DMEVENTD_MONITOR_MODE;
 
 	/*
 	 * VG locks are just that: locks, and have no side effects
--- LVM2/lib/locking/locking.h	2006/12/11 14:00:26	1.29
+++ LVM2/lib/locking/locking.h	2007/01/19 22:21:45	1.30
@@ -75,7 +75,7 @@
  */
 #define LCK_PARTIAL_MODE	0x00000001	/* Running in partial mode */
 #define LCK_MIRROR_NOSYNC_MODE	0x00000002	/* Mirrors don't require sync */
-#define LCK_DMEVENTD_REGISTER_MODE	0x00000004	/* Register with dmeventd */
+#define LCK_DMEVENTD_MONITOR_MODE	0x00000004	/* Register with dmeventd */
 
 
 /*
--- LVM2/lib/log/log.c	2006/08/21 12:54:53	1.35
+++ LVM2/lib/log/log.c	2007/01/19 22:21:45	1.36
@@ -48,7 +48,7 @@
 static char _msg_prefix[30] = "  ";
 static int _already_logging = 0;
 static int _mirror_in_sync = 0;
-static int _dmeventd_register = DEFAULT_DMEVENTD_MONITOR;
+static int _dmeventd_monitor = DEFAULT_DMEVENTD_MONITOR;
 
 static lvm2_log_fn_t _lvm2_log_fn = NULL;
 
@@ -189,9 +189,9 @@
 	_mirror_in_sync = in_sync;
 }
 
-void init_dmeventd_register(int reg)
+void init_dmeventd_monitor(int reg)
 {
-	_dmeventd_register = reg;
+	_dmeventd_monitor = reg;
 }
 
 void init_cmd_name(int status)
@@ -268,9 +268,9 @@
 	return _mirror_in_sync;
 }
 
-int dmeventd_register_mode(void)
+int dmeventd_monitor_mode(void)
 {
-	return _dmeventd_register;
+	return _dmeventd_monitor;
 }
 
 void init_debug(int level)
--- LVM2/lib/log/log.h	2006/08/01 14:56:33	1.32
+++ LVM2/lib/log/log.h	2007/01/19 22:21:45	1.33
@@ -75,7 +75,7 @@
 void init_lockingfailed(int level);
 void init_security_level(int level);
 void init_mirror_in_sync(int in_sync);
-void init_dmeventd_register(int reg);
+void init_dmeventd_monitor(int reg);
 
 void set_cmd_name(const char *cmd_name);
 
@@ -90,7 +90,7 @@
 int lockingfailed(void);
 int security_level(void);
 int mirror_in_sync(void);
-int dmeventd_register_mode(void);
+int dmeventd_monitor_mode(void);
 
 /* Suppress messages to stdout/stderr (1) or everywhere (2) */
 /* Returns previous setting */
--- LVM2/lib/metadata/segtype.h	2007/01/12 20:38:29	1.15
+++ LVM2/lib/metadata/segtype.h	2007/01/19 22:21:45	1.16
@@ -83,10 +83,10 @@
 			       const struct lv_segment *seg,
 			       struct list *modules);
 	void (*destroy) (const struct segment_type * segtype);
-	int (*target_registered) (struct lv_segment *seg, int *pending);
-	int (*target_register_events) (struct cmd_context *cmd,
+	int (*target_monitored) (struct lv_segment *seg, int *pending);
+	int (*target_monitor_events) (struct cmd_context *cmd,
 				       struct lv_segment *seg, int events);
-	int (*target_unregister_events) (struct cmd_context *cmd,
+	int (*target_unmonitor_events) (struct cmd_context *cmd,
 					 struct lv_segment *seg, int events);
 };
 
--- LVM2/lib/mirror/mirrored.c	2007/01/17 15:00:57	1.43
+++ LVM2/lib/mirror/mirrored.c	2007/01/19 22:21:45	1.44
@@ -411,7 +411,7 @@
 	return NULL;
 }
 
-static int _target_registered(struct lv_segment *seg, int *pending)
+static int _target_monitored(struct lv_segment *seg, int *pending)
 {
 	char *dso, *name;
 	struct logical_volume *lv;
@@ -476,19 +476,19 @@
 	if (!r)
 		return_0;
 
-	log_info("%s %s for events", set ? "Registered" : "Unregistered", name);
+	log_info("%s %s for events", set ? "Monitored" : "Unmonitored", name);
 
 	return 1;
 }
 
-static int _target_register_events(struct cmd_context *cmd,
+static int _target_monitor_events(struct cmd_context *cmd,
 				     struct lv_segment *seg,
 				     int events)
 {
 	return _target_set_events(cmd, seg, events, 1);
 }
 
-static int _target_unregister_events(struct cmd_context *cmd,
+static int _target_unmonitor_events(struct cmd_context *cmd,
 				     struct lv_segment *seg,
 				     int events)
 {
@@ -536,9 +536,9 @@
 	.target_percent = _mirrored_target_percent,
 	.target_present = _mirrored_target_present,
 #ifdef DMEVENTD
-	.target_registered = _target_registered,
-	.target_register_events = _target_register_events,
-	.target_unregister_events = _target_unregister_events,
+	.target_monitored = _target_monitored,
+	.target_monitor_events = _target_monitor_events,
+	.target_unmonitor_events = _target_unmonitor_events,
 #endif
 #endif
 	.modules_needed = _mirrored_modules_needed,
--- LVM2/tools/lvchange.c	2007/01/12 20:38:30	1.76
+++ LVM2/tools/lvchange.c	2007/01/19 22:21:45	1.77
@@ -80,10 +80,9 @@
 	return 1;
 }
 
-static int lvchange_registration(struct cmd_context *cmd,
-				 struct logical_volume *lv)
+static int lvchange_monitoring(struct cmd_context *cmd,
+			       struct logical_volume *lv)
 {
-	int r;
 	struct lvinfo info;
 
 	if (!lv_info(cmd, lv, &info, 0) || !info.exists) {
@@ -91,27 +90,14 @@
 		return 0;
 	}
 
-	/* do not register pvmove lv's */
+	/* do not monitor pvmove lv's */
 	if (lv->status & PVMOVE)
 		return 1;
 
-	log_verbose("%smonitoring logical volume \"%s\"",
-		    (dmeventd_register_mode()) ? "" : "Not ", lv->name);
-	r = register_dev_for_events(cmd, lv, dmeventd_register_mode());
-
-	if (r < 0) {
-		log_error("Unable to %smonitor logical volume, %s",
-			  (dmeventd_register_mode()) ? "" : "un", lv->name);
-		r = 0;
-	} else if (!r) {
-		log_verbose("Logical volume %s needs no %smonitoring, or is already %smonitored",
-			    (dmeventd_register_mode()) ? "" : "un",
-			    lv->name,
-			    (dmeventd_register_mode()) ? "" : "un");
-		r = 1;
-	}
+	if (!monitor_dev_for_events(cmd, lv, dmeventd_monitor_mode()))
+		stack;
 
-	return r;
+	return 1;
 }
 
 static int lvchange_availability(struct cmd_context *cmd,
@@ -605,7 +591,7 @@
 		return ECMD_FAILED;
 	}
 
-	init_dmeventd_register(arg_int_value(cmd, monitor_ARG, DEFAULT_DMEVENTD_MONITOR));
+	init_dmeventd_monitor(arg_int_value(cmd, monitor_ARG, DEFAULT_DMEVENTD_MONITOR));
 
 	/* access permission change */
 	if (arg_count(cmd, permission_ARG)) {
@@ -675,7 +661,7 @@
 	if (!arg_count(cmd, available_ARG) &&
 	    !arg_count(cmd, refresh_ARG) &&
 	    arg_count(cmd, monitor_ARG)) {
-		if (!lvchange_registration(cmd, lv))
+		if (!lvchange_monitoring(cmd, lv))
 			return ECMD_FAILED;
 	}
 
--- LVM2/tools/vgchange.c	2007/01/12 20:38:30	1.55
+++ LVM2/tools/vgchange.c	2007/01/19 22:21:45	1.56
@@ -15,7 +15,7 @@
 
 #include "tools.h"
 
-static int _register_lvs_in_vg(struct cmd_context *cmd,
+static int _monitor_lvs_in_vg(struct cmd_context *cmd,
 			       struct volume_group *vg, int reg)
 {
 	struct lv_list *lvl;
@@ -23,7 +23,6 @@
 	struct lvinfo info;
 	int lv_active;
 	int count = 0;
-	int r;
 
 	list_iterate_items(lvl, &vg->lvs) {
 		lv = lvl->lv;
@@ -39,16 +38,9 @@
 		if ((lv->status & PVMOVE) || !lv_active)
 			continue;
 
-		r = register_dev_for_events(cmd, lv, reg);
-
-		if (r < 0) {
-			log_error("Failed to %s logical volume, %s",
-				  (reg) ? "register" : "unregister",
-				  lv->name);
+		if (!monitor_dev_for_events(cmd, lv, reg)) {
 			continue;
-		}
-
-		if (r)
+		} else
 			count++;
 	}
 
@@ -114,10 +106,10 @@
 	int active, monitored;
 
 	if ((active = lvs_in_vg_activated(vg))) {
-		monitored = _register_lvs_in_vg(cmd, vg, dmeventd_register_mode());
+		monitored = _monitor_lvs_in_vg(cmd, vg, dmeventd_monitor_mode());
 		log_print("%d logical volume(s) in volume group "
 			    "\"%s\" %smonitored",
-			    monitored, vg->name, (dmeventd_register_mode()) ? "" : "un");
+			    monitored, vg->name, (dmeventd_monitor_mode()) ? "" : "un");
 	}
 
 	return ECMD_PROCESSED;
@@ -154,11 +146,11 @@
 	if (activate && (active = lvs_in_vg_activated(vg))) {
 		log_verbose("%d logical volume(s) in volume group \"%s\" "
 			    "already active", active, vg->name);
-		monitored = _register_lvs_in_vg(cmd, vg, dmeventd_register_mode());
+		monitored = _monitor_lvs_in_vg(cmd, vg, dmeventd_monitor_mode());
 		log_verbose("%d existing logical volume(s) in volume "
 			    "group \"%s\" %smonitored",
 			    monitored, vg->name,
-			    dmeventd_register_mode() ? "" : "un");
+			    dmeventd_monitor_mode() ? "" : "un");
 	}
 
 	if (activate && _activate_lvs_in_vg(cmd, vg, available))
@@ -540,7 +532,7 @@
 		return ECMD_FAILED;
 	}
 
-	init_dmeventd_register(arg_int_value(cmd, monitor_ARG, DEFAULT_DMEVENTD_MONITOR));
+	init_dmeventd_monitor(arg_int_value(cmd, monitor_ARG, DEFAULT_DMEVENTD_MONITOR));
 
 	if (arg_count(cmd, available_ARG))
 		r = _vgchange_available(cmd, vg);


