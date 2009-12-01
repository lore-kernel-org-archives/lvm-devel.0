From: Mike Snitzer <snitzer@redhat.com>
Date: Tue,  1 Dec 2009 17:46:34 -0500
Subject: [RFC][PATCH] add --poll flag to vgchange and lvchange
Message-ID: <1259707594-22742-1-git-send-email-snitzer@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add a [--poll {y|n}] flag to vgchange and lvchange to control whether
the background polldaemon is allowed to start.  It can be used
standalone or in conjunction with --refresh or --available y.

Control over when the background polldaemon starts will be particularly
important for snapshot-merge of a root filesystem.

Dracut will be updated to activate all LVs with: --poll n

The lvm2-monitor initscript will start polling with: --poll y

Because we currently have no way of knowing if a background polldaemon
is active for a given LV the following limitations exist:
1) it is not possible to stop an active polldaemon; so the lvm2-monitor
   initscript doesn't stop running polldaemon(s)
2) redundant polldaemon instances will be started for all specified LVs
   if vgchange or lvchange are repeatedly used with '--poll y'

TODO:
At a minimum I believe we need to add an LV flag that tells us the
background polldaemon is already active for a given LV.

I'll also update the vgchange and lvchange man pages once I get feedback
on this RFC patch.

---
 lib/config/defaults.h                   |    1 
 lib/misc/lvm-globals.c                  |   11 +++++
 lib/misc/lvm-globals.h                  |    2 +
 scripts/lvm2_monitoring_init_red_hat.in |    4 +-
 tools/args.h                            |    1 
 tools/commands.h                        |    8 ++--
 tools/lvchange.c                        |   37 ++++++++++++++++--
 tools/vgchange.c                        |   64 ++++++++++++++++++++++++++++++--
 8 files changed, 115 insertions(+), 13 deletions(-)

Index: lvm2/lib/config/defaults.h
===================================================================
--- lvm2.orig/lib/config/defaults.h
+++ lvm2/lib/config/defaults.h
@@ -50,6 +50,7 @@
 #define DEFAULT_MIRROR_MAX_IMAGES 8 /* limited by kernel DM_KCOPYD_MAX_REGIONS */
 #define DEFAULT_DMEVENTD_MIRROR_LIB "libdevmapper-event-lvm2mirror.so"
 #define DEFAULT_DMEVENTD_MONITOR 1
+#define DEFAULT_BACKGROUND_POLLING 1
 
 #define DEFAULT_UMASK 0077
 
Index: lvm2/lib/misc/lvm-globals.c
===================================================================
--- lvm2.orig/lib/misc/lvm-globals.c
+++ lvm2/lib/misc/lvm-globals.c
@@ -35,6 +35,7 @@ static int _security_level = SECURITY_LE
 static char _cmd_name[30] = "";
 static int _mirror_in_sync = 0;
 static int _dmeventd_monitor = DEFAULT_DMEVENTD_MONITOR;
+static int _background_polling = DEFAULT_BACKGROUND_POLLING;
 static int _ignore_suspended_devices = 0;
 static int _error_message_produced = 0;
 static unsigned _is_static = 0;
@@ -91,6 +92,11 @@ void init_dmeventd_monitor(int reg)
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
@@ -155,6 +161,11 @@ int trust_cache()
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
Index: lvm2/lib/misc/lvm-globals.h
===================================================================
--- lvm2.orig/lib/misc/lvm-globals.h
+++ lvm2/lib/misc/lvm-globals.h
@@ -32,6 +32,7 @@ void init_lockingfailed(int level);
 void init_security_level(int level);
 void init_mirror_in_sync(int in_sync);
 void init_dmeventd_monitor(int reg);
+void init_background_polling(int polling);
 void init_ignore_suspended_devices(int ignore);
 void init_error_message_produced(int produced);
 void init_is_static(unsigned value);
@@ -49,6 +50,7 @@ int ignorelockingfailure(void);
 int lockingfailed(void);
 int security_level(void);
 int mirror_in_sync(void);
+int background_polling(void);
 int ignore_suspended_devices(void);
 const char *log_command_name(void);
 unsigned is_static(void);
Index: lvm2/tools/args.h
===================================================================
--- lvm2.orig/tools/args.h
+++ lvm2/tools/args.h
@@ -64,6 +64,7 @@ arg(dataalignmentoffset_ARG, '\0', "data
 arg(virtualoriginsize_ARG, '\0', "virtualoriginsize", size_mb_arg, 0)
 arg(virtualsize_ARG, '\0', "virtualsize", size_mb_arg, 0)
 arg(noudevsync_ARG, '\0', "noudevsync", NULL, 0)
+arg(poll_ARG, '\0', "poll", yes_no_arg, 0)
 
 /* Allow some variations */
 arg(resizable_ARG, '\0', "resizable", yes_no_arg, 0)
Index: lvm2/tools/commands.h
===================================================================
--- lvm2.orig/tools/commands.h
+++ lvm2/tools/commands.h
@@ -72,6 +72,7 @@ xx(lvchange,
    "\t[--ignorelockingfailure]\n"
    "\t[--ignoremonitoring]\n"
    "\t[--monitor {y|n}]\n"
+   "\t[--poll {y|n}]\n"
    "\t[--noudevsync]\n"
    "\t[-M|--persistent y|n] [--major major] [--minor minor]\n"
    "\t[-P|--partial] " "\n"
@@ -88,8 +89,8 @@ xx(lvchange,
    alloc_ARG, autobackup_ARG, available_ARG, contiguous_ARG, force_ARG,
    ignorelockingfailure_ARG, ignoremonitoring_ARG, major_ARG, minor_ARG,
    monitor_ARG, noudevsync_ARG, partial_ARG, permission_ARG, persistent_ARG,
-   readahead_ARG, resync_ARG, refresh_ARG, addtag_ARG, deltag_ARG, test_ARG,
-   yes_ARG)
+   poll_ARG, readahead_ARG, resync_ARG, refresh_ARG, addtag_ARG, deltag_ARG,
+   test_ARG, yes_ARG)
 
 xx(lvconvert,
    "Change logical volume layout",
@@ -688,6 +689,7 @@ xx(vgchange,
    "\t[--ignorelockingfailure]\n"
    "\t[--ignoremonitoring]\n"
    "\t[--monitor {y|n}]\n"
+   "\t[--poll {y|n}]\n"
    "\t[--noudevsync]\n"
    "\t[--refresh]\n"
    "\t[-t|--test]" "\n"
@@ -707,7 +709,7 @@ xx(vgchange,
    addtag_ARG, alloc_ARG, allocation_ARG, autobackup_ARG, available_ARG,
    clustered_ARG, deltag_ARG, ignorelockingfailure_ARG, ignoremonitoring_ARG,
    logicalvolume_ARG, maxphysicalvolumes_ARG, monitor_ARG, noudevsync_ARG,
-   partial_ARG, physicalextentsize_ARG, refresh_ARG, resizeable_ARG,
+   partial_ARG, physicalextentsize_ARG, poll_ARG, refresh_ARG, resizeable_ARG,
    resizable_ARG, test_ARG, uuid_ARG)
 
 xx(vgck,
Index: lvm2/tools/lvchange.c
===================================================================
--- lvm2.orig/tools/lvchange.c
+++ lvm2/tools/lvchange.c
@@ -101,6 +101,22 @@ static int lvchange_monitoring(struct cm
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
@@ -135,7 +151,8 @@ static int lvchange_availability(struct 
 				return_0;
 		}
 
-		lv_spawn_background_polling(cmd, lv);
+		if (background_polling())
+			lv_spawn_background_polling(cmd, lv);
 	}
 
 	return 1;
@@ -577,6 +594,9 @@ static int lvchange_single(struct cmd_co
 					    (is_static() || arg_count(cmd, ignoremonitoring_ARG)) ?
 					    DMEVENTD_MONITOR_IGNORE : DEFAULT_DMEVENTD_MONITOR));
 
+	init_background_polling(arg_int_value(cmd, poll_ARG,
+					      DEFAULT_BACKGROUND_POLLING));
+
 	/* access permission change */
 	if (arg_count(cmd, permission_ARG)) {
 		if (!archive(lv->vg)) {
@@ -679,6 +699,15 @@ static int lvchange_single(struct cmd_co
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
@@ -695,10 +724,10 @@ int lvchange(struct cmd_context *cmd, in
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
 
Index: lvm2/tools/vgchange.c
===================================================================
--- lvm2.orig/tools/vgchange.c
+++ lvm2/tools/vgchange.c
@@ -51,6 +51,39 @@ static int _monitor_lvs_in_vg(struct cmd
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
+	 * - FIXME: no way to know if lv is already being polled
+	 */
+
+	return count;
+}
+
 static int _activate_lvs_in_vg(struct cmd_context *cmd,
 			       struct volume_group *vg, int activate)
 {
@@ -95,7 +128,8 @@ static int _activate_lvs_in_vg(struct cm
 		} else if (!activate_lv(cmd, lv))
 			continue;
 
-		if (activate != CHANGE_AN && activate != CHANGE_ALN &&
+		if (background_polling() &&
+		    activate != CHANGE_AN && activate != CHANGE_ALN &&
 		    (lv->status & (PVMOVE|CONVERTING)))
 			lv_spawn_background_polling(cmd, lv);
 
@@ -125,6 +159,20 @@ static int _vgchange_monitoring(struct c
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
@@ -490,12 +538,18 @@ static int vgchange_single(struct cmd_co
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
 
@@ -538,9 +592,11 @@ int vgchange(struct cmd_context *cmd, in
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
 
Index: lvm2/scripts/lvm2_monitoring_init_red_hat.in
===================================================================
--- lvm2.orig/scripts/lvm2_monitoring_init_red_hat.in
+++ lvm2/scripts/lvm2_monitoring_init_red_hat.in
@@ -26,7 +26,7 @@
 # Required-Stop: $local_fs
 # Default-Start: 1 2 3 4 5
 # Default-Stop: 0 6
-# Short-Description: Monitoring of LVM2 mirrors, snapshots etc. using dmeventd
+# Short-Description: Monitoring of LVM2 mirrors, snapshots etc. using dmeventd or polldaemon
 ### END INIT INFO
 
 . /etc/init.d/functions
@@ -50,7 +50,7 @@ start()
 	VGSLIST=`$VGS --noheadings -o name 2> /dev/null`
 	for vg in $VGSLIST
 	do
-	    action "Starting monitoring for VG $vg:" $VGCHANGE --monitor y $vg || ret=$?
+	    action "Starting monitoring for VG $vg:" $VGCHANGE --monitor y --poll y $vg || ret=$?
 	done
 
 	return $ret


