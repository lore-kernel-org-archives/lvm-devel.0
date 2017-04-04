From: David Teigland <teigland@sourceware.org>
Date: Tue, 4 Apr 2017 18:08:50 -0400
Subject: master - vgchange/lvchange: fix poll and monitor use
Message-ID: <201704042208.v34M8okL018826@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1c41898c07ad750820fb39770355fded8e9b030a
Commit:        1c41898c07ad750820fb39770355fded8e9b030a
Parent:        a12b3af033d8086e0399e5433a3307ebb05b9d0b
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Apr 4 12:52:29 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Apr 4 17:04:45 2017 -0500

vgchange/lvchange: fix poll and monitor use

Fill in some gaps where old versions of lvm allowed
--poll and --monitor in combination with other operations,
but those combinations had been lost since the cmd def work.
(The new cmd def code also added some combinations that
had been missed by the old code.)

Changes:

lvchange --activate: add poll and monitor options, and
                     add calls to them in implementation.

lvchange --refresh: add monitor option (poll already there),
                    and call to monitor in implementation.

lvchange <metadata ops>: add poll and monitor options, and
                         add calls to them in implementation.

vgchange <metadata ops>: add poll option (call to poll
                         already in implementation).

vgchange --refresh: remove monitor option (not used by code)

lvchange --persistent y: add poll and monitor options, and
                         add calls to them, and to activate
                         in the implementation. (Making it
                         match the main lvchange metadata
                         command.)

Summary of current usage:

lvchange --activate: monitor, poll
vgchange --activate: monitor, poll

lvchange --refresh: monitor, poll
vgchange --refresh: poll

lvchange --monitor: ok
lvchange --poll: ok
lvchange --monitor --poll: ok
vgchange --monitor: ok
vgchange --poll: ok
vgchange --monitor --poll: ok

lvchange <metadata ops>: monitor, poll
vgchange <metadata ops>: poll
---
 tools/command-lines.in |   16 ++++++------
 tools/lvchange.c       |   62 +++++++++++++++++++++++++++++++++++++++++------
 2 files changed, 62 insertions(+), 16 deletions(-)

diff --git a/tools/command-lines.in b/tools/command-lines.in
index fe98cc6..20a9e79 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -234,7 +234,7 @@ OO_LVCHANGE_META: --addtag Tag, --deltag Tag,
 # in combination with unrelated metadata changes.
 
 lvchange OO_LVCHANGE_META VG|LV|Tag|Select ...
-OO: --activate Active, OO_LVCHANGE
+OO: --activate Active, --poll Bool, --monitor Bool, OO_LVCHANGE
 ID: lvchange_properties
 DESC: Change a general LV attribute.
 DESC: For options listed in parentheses, any one is
@@ -275,18 +275,18 @@ DESC: Reconstruct data on specific PVs of a raid LV.
 RULE: all not LV_raid0
 
 lvchange --activate Active VG|LV|Tag|Select ...
-OO: --activationmode ActivationMode, --partial, --ignoreactivationskip,
---ignorelockingfailure, --sysinit, OO_LVCHANGE
+OO: --activationmode ActivationMode, --partial, --poll Bool, --monitor Bool,
+--ignoreactivationskip, --ignorelockingfailure, --sysinit, OO_LVCHANGE
 ID: lvchange_activate
 DESC: Activate or deactivate an LV.
 
 lvchange --refresh VG|LV|Tag|Select ...
-OO: --activationmode ActivationMode, --partial, --poll Bool, OO_LVCHANGE
+OO: --activationmode ActivationMode, --partial, --poll Bool, --monitor Bool, OO_LVCHANGE
 ID: lvchange_refresh
 DESC: Reactivate an LV using the latest metadata.
 
 lvchange --monitor Bool VG|LV|Tag|Select ...
-OO: --poll Bool, OO_LVCHANGE
+OO: OO_LVCHANGE
 ID: lvchange_monitor
 DESC: Start or stop monitoring an LV from dmeventd.
 RULE: all not lv_is_pvmove
@@ -297,7 +297,7 @@ ID: lvchange_poll
 DESC: Start or stop processing an LV conversion.
 
 lvchange --persistent y --minor Number LV
-OO: --major Number, --activate Activate, OO_LVCHANGE
+OO: --major Number, --activate Activate, --poll Bool, --monitor Bool, OO_LVCHANGE
 ID: lvchange_persistent
 DESC: Make the minor device number persistent for an LV.
 RULE: all not LV_thinpool LV_cachepool
@@ -1470,7 +1470,7 @@ OO_VGCHANGE_META: --addtag Tag, --deltag Tag,
 --profile String, --detachprofile, --metadataprofile String
 
 vgchange OO_VGCHANGE_META
-OO: OO_VGCHANGE
+OO: --poll Bool, OO_VGCHANGE
 OP: VG|Tag|Select ...
 ID: vgchange_properties
 DESC: Change a general VG attribute.
@@ -1497,7 +1497,7 @@ ID: vgchange_activate
 DESC: Activate or deactivate LVs.
 
 vgchange --refresh
-OO: --sysinit, --ignorelockingfailure, --monitor Bool, --poll Bool, OO_VGCHANGE
+OO: --sysinit, --ignorelockingfailure, --poll Bool, OO_VGCHANGE
 OP: VG|Tag|Select ...
 ID: vgchange_refresh
 DESC: Reactivate LVs using the latest metadata.
diff --git a/tools/lvchange.c b/tools/lvchange.c
index c68ea98..d80095d 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -141,6 +141,11 @@ static int _lvchange_pool_update(struct cmd_context *cmd,
 	return 1;
 }
 
+/*
+ * The --monitor y|n value is taken indirectly from dmeventd_monitor_mode()
+ * whose value was set via init_dmeventd_monitor().
+ */
+
 static int _lvchange_monitoring(struct cmd_context *cmd,
 				struct logical_volume *lv)
 {
@@ -152,13 +157,20 @@ static int _lvchange_monitoring(struct cmd_context *cmd,
 		return 0;
 	}
 
-	if ((dmeventd_monitor_mode() != DMEVENTD_MONITOR_IGNORE) &&
-	    !monitor_dev_for_events(cmd, lv, 0, dmeventd_monitor_mode()))
-		return_0;
+	if (dmeventd_monitor_mode() != DMEVENTD_MONITOR_IGNORE) {
+		log_verbose("Monitoring LV %s", display_lvname(lv));
+		if (!monitor_dev_for_events(cmd, lv, 0, dmeventd_monitor_mode()))
+			return_0;
+	}
 
 	return 1;
 }
 
+/*
+ * The --poll y|n value is taken indirectly from background_polling(),
+ * whose value was set via init_background_polling().
+ */
+
 static int _lvchange_background_polling(struct cmd_context *cmd,
 					struct logical_volume *lv)
 {
@@ -169,8 +181,10 @@ static int _lvchange_background_polling(struct cmd_context *cmd,
 		return 0;
 	}
 
-	if (background_polling())
+	if (background_polling()) {
+		log_verbose("Polling LV %s", display_lvname(lv));
 		lv_spawn_background_polling(cmd, lv);
+	}
 
 	return 1;
 }
@@ -1246,6 +1260,9 @@ int lvchange_properties_cmd(struct cmd_context *cmd, int argc, char **argv)
 	if (arg_is_set(cmd, activate_ARG)) {
 		log_warn("WARNING: Combining activation change with other commands is not advised.");
 		ret = lvchange_activate_cmd(cmd, argc, argv);
+
+	} else if (arg_is_set(cmd, monitor_ARG) || arg_is_set(cmd, poll_ARG)) {
+		ret = lvchange_monitor_poll_cmd(cmd, argc, argv);
 	}
 
 	return ret;
@@ -1321,6 +1338,8 @@ static int _lvchange_activate_check(struct cmd_context *cmd,
 
 int lvchange_activate_cmd(struct cmd_context *cmd, int argc, char **argv)
 {
+	int ret;
+
 	cmd->handles_missing_pvs = 1;
 	cmd->lockd_vg_default_sh = 1;
 
@@ -1335,8 +1354,16 @@ int lvchange_activate_cmd(struct cmd_context *cmd, int argc, char **argv)
 	if (is_change_activating((activation_change_t)arg_uint_value(cmd, activate_ARG, CHANGE_AY)))
 		cmd->lockd_vg_enforce_sh = 1;
 
-	return process_each_lv(cmd, argc, argv, NULL, NULL, 0,
-			       NULL, &_lvchange_activate_check, &_lvchange_activate_single);
+	ret = process_each_lv(cmd, argc, argv, NULL, NULL, 0,
+			      NULL, &_lvchange_activate_check, &_lvchange_activate_single);
+
+	if (ret != ECMD_PROCESSED)
+		return ret;
+
+	if (arg_is_set(cmd, monitor_ARG) || arg_is_set(cmd, poll_ARG))
+		ret = lvchange_monitor_poll_cmd(cmd, argc, argv);
+
+	return ret;
 }
 
 static int _lvchange_refresh_single(struct cmd_context *cmd,
@@ -1356,6 +1383,10 @@ static int _lvchange_refresh_single(struct cmd_context *cmd,
 	    !_lvchange_background_polling(cmd, lv))
 		return_ECMD_FAILED;
 
+	if (arg_is_set(cmd, monitor_ARG) &&
+	    !_lvchange_monitoring(cmd, lv))
+		return_ECMD_FAILED;
+
 	return ECMD_PROCESSED;
 }
 
@@ -1560,9 +1591,24 @@ static int _lvchange_persistent_check(struct cmd_context *cmd,
 
 int lvchange_persistent_cmd(struct cmd_context *cmd, int argc, char **argv)
 {
+	int ret;
+
 	cmd->handles_missing_pvs = 1;
-	return process_each_lv(cmd, argc, argv, NULL, NULL, READ_FOR_UPDATE,
-			       NULL, &_lvchange_persistent_check, &_lvchange_persistent_single);
+
+	ret = process_each_lv(cmd, argc, argv, NULL, NULL, READ_FOR_UPDATE,
+			      NULL, &_lvchange_persistent_check, &_lvchange_persistent_single);
+
+	if (ret != ECMD_PROCESSED)
+		return ret;
+
+	/* See comment in lvchange_properties about needing to allow these. */
+	if (arg_is_set(cmd, activate_ARG)) {
+		log_warn("WARNING: Combining activation change with other commands is not advised.");
+		ret = lvchange_activate_cmd(cmd, argc, argv);
+
+	} else if (arg_is_set(cmd, monitor_ARG) || arg_is_set(cmd, poll_ARG)) {
+		ret = lvchange_monitor_poll_cmd(cmd, argc, argv);
+	}
 }
 
 int lvchange(struct cmd_context *cmd, int argc, char **argv)


