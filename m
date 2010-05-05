From: Peter Rajnoha <prajnoha@redhat.com>
Date: Wed, 05 May 2010 15:00:05 +0200
Subject: [PATCH] Provide a new --sysinit switch for vgchange and lvchange
Message-ID: <4BE16BD5.7030402@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

In read-only environment, we normally use the same bunch of switches
to disable several things (--ignoremonitoring, --ignorelockingfailure,
--poll n, LVM_SUPPRESS_LOCKING_FAILURE_MESSAGES=1...) This is used
on system startup mainly. Maybe we could add a new switch that will
set everything automatically to make things a little bit cleaner and
more maintainable, so we don't have to bug people around to change
things if we need to add/change something (it could be used in
initscripts, dracut, anything similar...).

(see rhbz #588777)

For now, it's just vgchange and lvchange.
Just a proposal, what do you think?

Peter
---
 lib/locking/locking.c |    7 +------
 lib/locking/locking.h |    2 +-
 liblvm/lvm_base.c     |    2 +-
 tools/args.h          |    1 +
 tools/commands.h      |    6 ++++--
 tools/lvchange.c      |   17 +++++++++++++----
 tools/lvmcmdline.c    |    4 ++--
 tools/toollib.c       |    6 ++++--
 tools/vgchange.c      |   18 +++++++++++++-----
 9 files changed, 40 insertions(+), 23 deletions(-)

diff --git a/lib/locking/locking.c b/lib/locking/locking.c
index a24b4c6..b5ff777 100644
--- a/lib/locking/locking.c
+++ b/lib/locking/locking.c
@@ -217,13 +217,8 @@ static void _update_vg_lock_count(const char *resource, uint32_t flags)
  * Select a locking type
  * type: locking type; if < 0, then read config tree value
  */
-int init_locking(int type, struct cmd_context *cmd)
+int init_locking(int type, struct cmd_context *cmd, int suppress_messages)
 {
-	int suppress_messages = 0;
-
-	if (ignorelockingfailure() && getenv("LVM_SUPPRESS_LOCKING_FAILURE_MESSAGES"))
-		suppress_messages = 1;
-
 	if (type < 0)
 		type = find_config_tree_int(cmd, "global/locking_type", 1);
 
diff --git a/lib/locking/locking.h b/lib/locking/locking.h
index e7f25b9..7a787ac 100644
--- a/lib/locking/locking.h
+++ b/lib/locking/locking.h
@@ -19,7 +19,7 @@
 #include "uuid.h"
 #include "config.h"
 
-int init_locking(int type, struct cmd_context *cmd);
+int init_locking(int type, struct cmd_context *cmd, int suppress_messages);
 void fin_locking(void);
 void reset_locking(void);
 int vg_write_lock_held(void);
diff --git a/liblvm/lvm_base.c b/liblvm/lvm_base.c
index 733d4d5..1b2ed9f 100644
--- a/liblvm/lvm_base.c
+++ b/liblvm/lvm_base.c
@@ -50,7 +50,7 @@ lvm_t lvm_init(const char *system_dir)
 
 	/* FIXME: locking_type config option needed? */
 	/* initialize locking */
-	if (!init_locking(-1, cmd)) {
+	if (!init_locking(-1, cmd, 0)) {
 		/* FIXME: use EAGAIN as error code here */
 		lvm_quit((lvm_t) cmd);
 		return NULL;
diff --git a/tools/args.h b/tools/args.h
index 88d0d05..76146ee 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -66,6 +66,7 @@ arg(virtualsize_ARG, '\0', "virtualsize", size_mb_arg, 0)
 arg(noudevsync_ARG, '\0', "noudevsync", NULL, 0)
 arg(poll_ARG, '\0', "poll", yes_no_arg, 0)
 arg(stripes_long_ARG, '\0', "stripes", int_arg, 0)
+arg(sysinit_ARG, '\0', "sysinit", NULL, 0)
 
 /* Allow some variations */
 arg(resizable_ARG, '\0', "resizable", yes_no_arg, 0)
diff --git a/tools/commands.h b/tools/commands.h
index 7d0185b..e33cadc 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -80,6 +80,7 @@ xx(lvchange,
    "\t[-r|--readahead ReadAheadSectors|auto|none]\n"
    "\t[--refresh]\n"
    "\t[--resync]\n"
+   "\t[--sysinit]\n"
    "\t[-t|--test]\n"
    "\t[-v|--verbose]\n"
    "\t[-y|--yes]\n"
@@ -90,7 +91,7 @@ xx(lvchange,
    ignorelockingfailure_ARG, ignoremonitoring_ARG, major_ARG, minor_ARG,
    monitor_ARG, noudevsync_ARG, partial_ARG, permission_ARG, persistent_ARG,
    poll_ARG, readahead_ARG, resync_ARG, refresh_ARG, addtag_ARG, deltag_ARG,
-   test_ARG, yes_ARG)
+   sysinit_ARG, test_ARG, yes_ARG)
 
 xx(lvconvert,
    "Change logical volume layout",
@@ -711,6 +712,7 @@ xx(vgchange,
    "\t[--poll {y|n}]\n"
    "\t[--noudevsync]\n"
    "\t[--refresh]\n"
+   "\t[--sysinit]\n"
    "\t[-t|--test]" "\n"
    "\t[-u|--uuid] " "\n"
    "\t[-v|--verbose] " "\n"
@@ -729,7 +731,7 @@ xx(vgchange,
    clustered_ARG, deltag_ARG, ignorelockingfailure_ARG, ignoremonitoring_ARG,
    logicalvolume_ARG, maxphysicalvolumes_ARG, monitor_ARG, noudevsync_ARG,
    partial_ARG, physicalextentsize_ARG, poll_ARG, refresh_ARG, resizeable_ARG,
-   resizable_ARG, test_ARG, uuid_ARG)
+   resizable_ARG, sysinit_ARG, test_ARG, uuid_ARG)
 
 xx(vgck,
    "Check the consistency of volume group(s)",
diff --git a/tools/lvchange.c b/tools/lvchange.c
index 9929740..1376bf4 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -586,9 +586,12 @@ static int lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 	 * should only be started if the LV is not already active. So:
 	 * 1) change the activation code to say if the LV was actually activated
 	 * 2) make polling of an LV tightly coupled with LV activation
+	 *
+	 * Do not initiate any polling if --sysinit option is used.
 	 */
-	init_background_polling(arg_int_value(cmd, poll_ARG,
-					      DEFAULT_BACKGROUND_POLLING));
+	init_background_polling(arg_count(cmd, sysinit_ARG) ? 0 :
+						arg_int_value(cmd, poll_ARG,
+						DEFAULT_BACKGROUND_POLLING));
 
 	/* access permission change */
 	if (arg_count(cmd, permission_ARG)) {
@@ -730,8 +733,9 @@ int lvchange(struct cmd_context *cmd, int argc, char **argv)
 	     arg_count(cmd, addtag_ARG) || arg_count(cmd, deltag_ARG) ||
 	     arg_count(cmd, resync_ARG) || arg_count(cmd, alloc_ARG));
 
-	if (arg_count(cmd, ignorelockingfailure_ARG) && !avail_only) {
-		log_error("Only -a permitted with --ignorelockingfailure");
+	if ((arg_count(cmd, ignorelockingfailure_ARG) ||
+	     arg_count(cmd, sysinit_ARG)) && !avail_only) {
+		log_error("Only -a permitted with --ignorelockingfailure and --sysinit");
 		return EINVALID_CMD_LINE;
 	}
 
@@ -759,6 +763,11 @@ int lvchange(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
+	if (arg_count(cmd, poll_ARG) && arg_count(cmd, sysinit_ARG)) {
+		log_error("Only one of --poll and --sysinit permitted");
+		return EINVALID_CMD_LINE;
+	}
+
 	return process_each_lv(cmd, argc, argv,
 			       avail_only ? 0 : READ_FOR_UPDATE, NULL,
 			       &lvchange_single);
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 033ef74..5feaa3f 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -793,7 +793,7 @@ static int _get_settings(struct cmd_context *cmd)
 			  "be activated read-only.");
 	}
 
-	if (arg_count(cmd, ignorelockingfailure_ARG))
+	if (arg_count(cmd, ignorelockingfailure_ARG) || arg_count(cmd, sysinit_ARG))
 		init_ignorelockingfailure(1);
 	else
 		init_ignorelockingfailure(0);
@@ -1049,7 +1049,7 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 	else
 		locking_type = -1;
 
-	if (!init_locking(locking_type, cmd)) {
+	if (!init_locking(locking_type, cmd, arg_count(cmd, sysinit_ARG))) {
 		ret = ECMD_FAILED;
 		goto out;
 	}
diff --git a/tools/toollib.c b/tools/toollib.c
index 393c529..735f3b0 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1372,8 +1372,9 @@ int get_activation_monitoring_mode(struct cmd_context *cmd,
 	*monitoring_mode = DEFAULT_DMEVENTD_MONITOR;
 
 	if (arg_count(cmd, monitor_ARG) &&
-	    arg_count(cmd, ignoremonitoring_ARG)) {
-		log_error("Conflicting monitor and ignoremonitoring options");
+	    (arg_count(cmd, ignoremonitoring_ARG) ||
+	     arg_count(cmd, sysinit_ARG))) {
+		log_error("--ignoremonitoring or --sysinit option not allowed with --monitor option");
 		return 0;
 	}
 
@@ -1381,6 +1382,7 @@ int get_activation_monitoring_mode(struct cmd_context *cmd,
 		*monitoring_mode = arg_int_value(cmd, monitor_ARG,
 						 DEFAULT_DMEVENTD_MONITOR);
 	else if (is_static() || arg_count(cmd, ignoremonitoring_ARG) ||
+		 arg_count(cmd, sysinit_ARG) ||
 		 !find_config_tree_bool(cmd, "activation/monitoring",
 					DEFAULT_DMEVENTD_MONITOR))
 		*monitoring_mode = DMEVENTD_MONITOR_IGNORE;
diff --git a/tools/vgchange.c b/tools/vgchange.c
index 81c95d1..a25a373 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -540,9 +540,12 @@ static int vgchange_single(struct cmd_context *cmd, const char *vg_name,
 	 * should only be started if the LV is not already active. So:
 	 * 1) change the activation code to say if the LV was actually activated
 	 * 2) make polling of an LV tightly coupled with LV activation
+	 *
+	 * Do not initiate any polling if --sysinit option is used.
 	 */
-	init_background_polling(arg_int_value(cmd, poll_ARG,
-					      DEFAULT_BACKGROUND_POLLING));
+	init_background_polling(arg_count(cmd, sysinit_ARG) ? 0 :
+						arg_int_value(cmd, poll_ARG,
+						DEFAULT_BACKGROUND_POLLING));
 
 	if (arg_count(cmd, available_ARG))
 		r = _vgchange_available(cmd, vg);
@@ -615,9 +618,14 @@ int vgchange(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
-	if (arg_count(cmd, ignorelockingfailure_ARG) &&
-	    !arg_count(cmd, available_ARG)) {
-		log_error("--ignorelockingfailure only available with -a");
+	if ((arg_count(cmd, ignorelockingfailure_ARG) ||
+	     arg_count(cmd, sysinit_ARG)) && !arg_count(cmd, available_ARG)) {
+		log_error("Only -a premitted with --ignorelockingfailure and --sysinit");
+		return EINVALID_CMD_LINE;
+	}
+
+	if (arg_count(cmd, poll_ARG) && arg_count(cmd, sysinit_ARG)) {
+		log_error("Only one of --poll and --sysinit permitted.");
 		return EINVALID_CMD_LINE;
 	}
 


