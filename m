From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 5 Jan 2010 20:56:53 -0000
Subject: LVM2 ./WHATS_NEW lib/config/defaults.h lib/mis ...
Message-ID: <20100105205653.28535.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2010-01-05 20:56:52

Modified files:
	.              : WHATS_NEW 
	lib/config     : defaults.h 
	lib/misc       : lvm-globals.c lvm-globals.h 
	man            : lvchange.8.in vgchange.8.in 
	scripts        : lvm2_monitoring_init_red_hat.in 
	tools          : args.h commands.h lvchange.c vgchange.c 

Log message:
	Add a [--poll {y|n}] flag to vgchange and lvchange to control whether
	the background polldaemon is allowed to start.  It can be used
	standalone or in conjunction with --refresh or --available y.
	
	Control over when the background polldaemon starts will be particularly
	important for snapshot-merge of a root filesystem.
	
	Dracut will be updated to activate all LVs with: --poll n
	
	The lvm2-monitor initscript will start polling with: --poll y
	
	NOTE: Because we currently have no way of knowing if a background
	polldaemon is active for a given LV the following limitations exist and
	have been deemed acceptable:
	1) it is not possible to stop an active polldaemon; so the lvm2-monitor
	initscript doesn't stop running polldaemon(s)
	2) redundant polldaemon instances will be started for all specified LVs
	if vgchange or lvchange are repeatedly used with '--poll y'
	
	Signed-off-by: Mike Snitzer <snitzer@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1361&r2=1.1362
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/defaults.h.diff?cvsroot=lvm2&r1=1.55&r2=1.56
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-globals.c.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-globals.h.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvchange.8.in.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgchange.8.in.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/lvm2_monitoring_init_red_hat.in.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/args.h.diff?cvsroot=lvm2&r1=1.69&r2=1.70
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/commands.h.diff?cvsroot=lvm2&r1=1.135&r2=1.136
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvchange.c.diff?cvsroot=lvm2&r1=1.113&r2=1.114
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgchange.c.diff?cvsroot=lvm2&r1=1.92&r2=1.93

--- LVM2/WHATS_NEW	2010/01/05 16:09:33	1.1361
+++ LVM2/WHATS_NEW	2010/01/05 20:56:51	1.1362
@@ -1,5 +1,6 @@
 Version 2.02.57 -
 ====================================
+  Add --poll flag to vgchange and lvchange.
   Propagate commit and revert metadata notification to other nodes in cluster.
   Use proper mask for VG lock mode in clvmd.
   Add possibility to drop precommitted metadata in lvmcache.
--- LVM2/lib/config/defaults.h	2009/11/30 17:17:12	1.55
+++ LVM2/lib/config/defaults.h	2010/01/05 20:56:51	1.56
@@ -50,6 +50,7 @@
 #define DEFAULT_MIRROR_MAX_IMAGES 8 /* limited by kernel DM_KCOPYD_MAX_REGIONS */
 #define DEFAULT_DMEVENTD_MIRROR_LIB "libdevmapper-event-lvm2mirror.so"
 #define DEFAULT_DMEVENTD_MONITOR 1
+#define DEFAULT_BACKGROUND_POLLING 1
 
 #define DEFAULT_UMASK 0077
 
--- LVM2/lib/misc/lvm-globals.c	2009/07/15 05:49:48	1.3
+++ LVM2/lib/misc/lvm-globals.c	2010/01/05 20:56:51	1.4
@@ -35,6 +35,7 @@
 static char _cmd_name[30] = "";
 static int _mirror_in_sync = 0;
 static int _dmeventd_monitor = DEFAULT_DMEVENTD_MONITOR;
+static int _background_polling = DEFAULT_BACKGROUND_POLLING;
 static int _ignore_suspended_devices = 0;
 static int _error_message_produced = 0;
 static unsigned _is_static = 0;
@@ -91,6 +92,11 @@
 	_dmeventd_monitor = reg;
 }
 
+void init_background_polling(int polling)
+{
+	_background_polling = polling;
+}
+
 void init_ignore_suspended_devices(int ignore)
 {
 	_ignore_suspended_devices = ignore;
@@ -155,6 +161,11 @@
 	return _trust_cache;
 }
 
+int background_polling()
+{
+	return _background_polling;
+}
+
 int ignorelockingfailure()
 {
 	return _ignorelockingfailure;
--- LVM2/lib/misc/lvm-globals.h	2008/12/18 05:27:18	1.4
+++ LVM2/lib/misc/lvm-globals.h	2010/01/05 20:56:51	1.5
@@ -32,6 +32,7 @@
 void init_security_level(int level);
 void init_mirror_in_sync(int in_sync);
 void init_dmeventd_monitor(int reg);
+void init_background_polling(int polling);
 void init_ignore_suspended_devices(int ignore);
 void init_error_message_produced(int produced);
 void init_is_static(unsigned value);
@@ -49,6 +50,7 @@
 int lockingfailed(void);
 int security_level(void);
 int mirror_in_sync(void);
+int background_polling(void);
 int ignore_suspended_devices(void);
 const char *log_command_name(void);
 unsigned is_static(void);
--- LVM2/man/lvchange.8.in	2009/08/03 10:58:40	1.4
+++ LVM2/man/lvchange.8.in	2010/01/05 20:56:51	1.5
@@ -12,6 +12,7 @@
 [\-\-ignorelockingfailure]
 [\-\-ignoremonitoring]
 [\-\-monitor {y|n}]
+[\-\-poll {y|n}]
 [\-\-noudevsync]
 [\-M|\-\-persistent y|n] [\-\-minor minor]
 [\-P|\-\-partial]
@@ -62,6 +63,14 @@
 \fBmirror_image_fault_policy\fP and \fBmirror_log_fault_policy\fP
 set in \fBlvm.conf\fP.
 .TP
+.I \-\-poll y|n
+Controls whether or not a logical volume's progress is polled.  It may
+not be appropriate to immediately poll the progress of a logical
+volume's transformation when it is activated (for example, when merging
+a snapshot into the root FS).  The progress polling of an incomplete
+pvmove or lvconvert can be deferred using \fB--poll n\fP and restarted
+using \fB--poll y\fP.
+.TP
 .I \-\-noudevsync
 Disable udev synchronisation. The
 process will not wait for notification from udev.
--- LVM2/man/vgchange.8.in	2009/10/05 20:55:57	1.5
+++ LVM2/man/vgchange.8.in	2010/01/05 20:56:51	1.6
@@ -10,6 +10,7 @@
 .RB [ \-A | \-\-autobackup " {" y | n }]
 .RB [ \-a | \-\-available " [e|l] {" y | n }]
 .RB [ \-\-monitor " {" y | n }]
+.RB [ \-\-poll " {" y | n }]
 .RB [ \-c | \-\-clustered " {" y | n }]
 .RB [ \-u | \-\-uuid ]
 .RB [ \-d | \-\-debug]
@@ -87,6 +88,14 @@
 set in 
 .BR lvm.conf (5).
 .TP
+.BR \-\-poll " " { y | n }
+Controls whether or not a logical volume's progress is polled.  It may
+not be appropriate to immediately poll the progress of a logical
+volume's transformation when it is activated (for example, when merging
+a snapshot into the root FS).  The progress polling of an incomplete
+pvmove or lvconvert can be deferred using \fB--poll n\fP and restarted
+using \fB--poll y\fP.
+.TP
 .BR \-\-noudevsync
 Disable udev synchronisation. The
 process will not wait for notification from udev.
--- LVM2/scripts/lvm2_monitoring_init_red_hat.in	2009/09/16 23:40:19	1.2
+++ LVM2/scripts/lvm2_monitoring_init_red_hat.in	2010/01/05 20:56:52	1.3
@@ -26,7 +26,7 @@
 # Required-Stop: $local_fs
 # Default-Start: 1 2 3 4 5
 # Default-Stop: 0 6
-# Short-Description: Monitoring of LVM2 mirrors, snapshots etc. using dmeventd
+# Short-Description: Monitoring of LVM2 mirrors, snapshots etc. using dmeventd or progress polling
 ### END INIT INFO
 
 . /etc/init.d/functions
@@ -50,7 +50,7 @@
 	VGSLIST=`$VGS --noheadings -o name 2> /dev/null`
 	for vg in $VGSLIST
 	do
-	    action "Starting monitoring for VG $vg:" $VGCHANGE --monitor y $vg || ret=$?
+	    action "Starting monitoring for VG $vg:" $VGCHANGE --monitor y --poll y $vg || ret=$?
 	done
 
 	return $ret
--- LVM2/tools/args.h	2009/10/26 14:37:09	1.69
+++ LVM2/tools/args.h	2010/01/05 20:56:52	1.70
@@ -64,6 +64,7 @@
 arg(virtualoriginsize_ARG, '\0', "virtualoriginsize", size_mb_arg, 0)
 arg(virtualsize_ARG, '\0', "virtualsize", size_mb_arg, 0)
 arg(noudevsync_ARG, '\0', "noudevsync", NULL, 0)
+arg(poll_ARG, '\0', "poll", yes_no_arg, 0)
 
 /* Allow some variations */
 arg(resizable_ARG, '\0', "resizable", yes_no_arg, 0)
--- LVM2/tools/commands.h	2009/10/26 14:37:09	1.135
+++ LVM2/tools/commands.h	2010/01/05 20:56:52	1.136
@@ -72,6 +72,7 @@
    "\t[--ignorelockingfailure]\n"
    "\t[--ignoremonitoring]\n"
    "\t[--monitor {y|n}]\n"
+   "\t[--poll {y|n}]\n"
    "\t[--noudevsync]\n"
    "\t[-M|--persistent y|n] [--major major] [--minor minor]\n"
    "\t[-P|--partial] " "\n"
@@ -88,8 +89,8 @@
    alloc_ARG, autobackup_ARG, available_ARG, contiguous_ARG, force_ARG,
    ignorelockingfailure_ARG, ignoremonitoring_ARG, major_ARG, minor_ARG,
    monitor_ARG, noudevsync_ARG, partial_ARG, permission_ARG, persistent_ARG,
-   readahead_ARG, resync_ARG, refresh_ARG, addtag_ARG, deltag_ARG, test_ARG,
-   yes_ARG)
+   poll_ARG, readahead_ARG, resync_ARG, refresh_ARG, addtag_ARG, deltag_ARG,
+   test_ARG, yes_ARG)
 
 xx(lvconvert,
    "Change logical volume layout",
@@ -688,6 +689,7 @@
    "\t[--ignorelockingfailure]\n"
    "\t[--ignoremonitoring]\n"
    "\t[--monitor {y|n}]\n"
+   "\t[--poll {y|n}]\n"
    "\t[--noudevsync]\n"
    "\t[--refresh]\n"
    "\t[-t|--test]" "\n"
@@ -707,7 +709,7 @@
    addtag_ARG, alloc_ARG, allocation_ARG, autobackup_ARG, available_ARG,
    clustered_ARG, deltag_ARG, ignorelockingfailure_ARG, ignoremonitoring_ARG,
    logicalvolume_ARG, maxphysicalvolumes_ARG, monitor_ARG, noudevsync_ARG,
-   partial_ARG, physicalextentsize_ARG, refresh_ARG, resizeable_ARG,
+   partial_ARG, physicalextentsize_ARG, poll_ARG, refresh_ARG, resizeable_ARG,
    resizable_ARG, test_ARG, uuid_ARG)
 
 xx(vgck,
--- LVM2/tools/lvchange.c	2009/12/03 19:18:34	1.113
+++ LVM2/tools/lvchange.c	2010/01/05 20:56:52	1.114
@@ -101,6 +101,22 @@
 	return 1;
 }
 
+static int lvchange_background_polling(struct cmd_context *cmd,
+				       struct logical_volume *lv)
+{
+	struct lvinfo info;
+
+	if (!lv_info(cmd, lv, &info, 0, 0) || !info.exists) {
+		log_error("Logical volume, %s, is not active", lv->name);
+		return 0;
+	}
+
+	if (background_polling())
+		lv_spawn_background_polling(cmd, lv);
+
+	return 1;
+}
+
 static int lvchange_availability(struct cmd_context *cmd,
 				 struct logical_volume *lv)
 {
@@ -135,7 +151,8 @@
 				return_0;
 		}
 
-		lv_spawn_background_polling(cmd, lv);
+		if (background_polling())
+			lv_spawn_background_polling(cmd, lv);
 	}
 
 	return 1;
@@ -577,6 +594,9 @@
 					    (is_static() || arg_count(cmd, ignoremonitoring_ARG)) ?
 					    DMEVENTD_MONITOR_IGNORE : DEFAULT_DMEVENTD_MONITOR));
 
+	init_background_polling(arg_int_value(cmd, poll_ARG,
+					      DEFAULT_BACKGROUND_POLLING));
+
 	/* access permission change */
 	if (arg_count(cmd, permission_ARG)) {
 		if (!archive(lv->vg)) {
@@ -679,6 +699,15 @@
 		}
 	}
 
+	if (!arg_count(cmd, available_ARG) &&
+	    !arg_count(cmd, refresh_ARG) &&
+	    arg_count(cmd, poll_ARG)) {
+		if (!lvchange_background_polling(cmd, lv)) {
+			stack;
+			return ECMD_FAILED;
+		}
+	}
+
 	if (doit != docmds) {
 		stack;
 		return ECMD_FAILED;
@@ -695,10 +724,10 @@
 	    && !arg_count(cmd, persistent_ARG) && !arg_count(cmd, addtag_ARG)
 	    && !arg_count(cmd, deltag_ARG) && !arg_count(cmd, refresh_ARG)
 	    && !arg_count(cmd, alloc_ARG) && !arg_count(cmd, monitor_ARG)
-	    && !arg_count(cmd, resync_ARG)) {
+	    && !arg_count(cmd, poll_ARG) && !arg_count(cmd, resync_ARG)) {
 		log_error("Need 1 or more of -a, -C, -j, -m, -M, -p, -r, "
-			  "--resync, --refresh, --alloc, --addtag, --deltag "
-			  "or --monitor");
+			  "--resync, --refresh, --alloc, --addtag, --deltag, "
+			  "--monitor or --poll");
 		return EINVALID_CMD_LINE;
 	}
 
--- LVM2/tools/vgchange.c	2009/12/07 19:32:28	1.92
+++ LVM2/tools/vgchange.c	2010/01/05 20:56:52	1.93
@@ -51,6 +51,39 @@
 	return count;
 }
 
+static int _poll_lvs_in_vg(struct cmd_context *cmd,
+			   struct volume_group *vg)
+{
+	struct lv_list *lvl;
+	struct logical_volume *lv;
+	struct lvinfo info;
+	int lv_active;
+	int count = 0;
+
+	dm_list_iterate_items(lvl, &vg->lvs) {
+		lv = lvl->lv;
+
+		if (!lv_info(cmd, lv, &info, 0, 0))
+			lv_active = 0;
+		else
+			lv_active = info.exists;
+
+		if (!lv_active ||
+		    !(lv->status & (PVMOVE|CONVERTING)))
+			continue;
+
+		lv_spawn_background_polling(cmd, lv);
+		count++;
+	}
+
+	/*
+	 * returns the number of polled devices
+	 * - there is no way to know if lv is already being polled
+	 */
+
+	return count;
+}
+
 static int _activate_lvs_in_vg(struct cmd_context *cmd,
 			       struct volume_group *vg, int activate)
 {
@@ -95,7 +128,8 @@
 		} else if (!activate_lv(cmd, lv))
 			continue;
 
-		if (activate != CHANGE_AN && activate != CHANGE_ALN &&
+		if (background_polling() &&
+		    activate != CHANGE_AN && activate != CHANGE_ALN &&
 		    (lv->status & (PVMOVE|CONVERTING)))
 			lv_spawn_background_polling(cmd, lv);
 
@@ -125,6 +159,20 @@
 	return ECMD_PROCESSED;
 }
 
+static int _vgchange_background_polling(struct cmd_context *cmd, struct volume_group *vg)
+{
+	int polled;
+
+	if (lvs_in_vg_activated(vg) && background_polling()) {
+	        polled = _poll_lvs_in_vg(cmd, vg);
+		log_print("Background polling started for %d logical volume(s) "
+			  "in volume group \"%s\"",
+			  polled, vg->name);
+	}
+
+	return ECMD_PROCESSED;
+}
+
 static int _vgchange_available(struct cmd_context *cmd, struct volume_group *vg)
 {
 	int lv_open, active, monitored;
@@ -490,12 +538,18 @@
 					    (is_static() || arg_count(cmd, ignoremonitoring_ARG)) ?
 					    DMEVENTD_MONITOR_IGNORE : DEFAULT_DMEVENTD_MONITOR));
 
+	init_background_polling(arg_int_value(cmd, poll_ARG,
+					      DEFAULT_BACKGROUND_POLLING));
+
 	if (arg_count(cmd, available_ARG))
 		r = _vgchange_available(cmd, vg);
 
 	else if (arg_count(cmd, monitor_ARG))
 		r = _vgchange_monitoring(cmd, vg);
 
+	else if (arg_count(cmd, poll_ARG))
+		r = _vgchange_background_polling(cmd, vg);
+
 	else if (arg_count(cmd, resizeable_ARG))
 		r = _vgchange_resizeable(cmd, vg);
 
@@ -538,9 +592,11 @@
 	     arg_count(cmd, addtag_ARG) + arg_count(cmd, uuid_ARG) +
 	     arg_count(cmd, physicalextentsize_ARG) +
 	     arg_count(cmd, clustered_ARG) + arg_count(cmd, alloc_ARG) +
-	     arg_count(cmd, monitor_ARG) + arg_count(cmd, refresh_ARG))) {
-		log_error("One of -a, -c, -l, -p, -s, -x, --refresh, "
-				"--uuid, --alloc, --addtag or --deltag required");
+	     arg_count(cmd, monitor_ARG) + arg_count(cmd, poll_ARG) +
+	     arg_count(cmd, refresh_ARG))) {
+		log_error("Need 1 or more of -a, -c, -l, -p, -s, -x, "
+			  "--refresh, --uuid, --alloc, --addtag, --deltag, "
+			  "--monitor or --poll");
 		return EINVALID_CMD_LINE;
 	}
 


