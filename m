From: David Teigland <teigland@sourceware.org>
Date: Tue, 4 Apr 2017 18:08:52 -0400
Subject: master - lvchange: fix --poll value when set from option
Message-ID: <201704042208.v34M8qPM018836@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a7d4156a9aba1454249c945d07ebbfc366d86eaf
Commit:        a7d4156a9aba1454249c945d07ebbfc366d86eaf
Parent:        1c41898c07ad750820fb39770355fded8e9b030a
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Apr 4 15:32:08 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Apr 4 17:04:45 2017 -0500

lvchange: fix --poll value when set from option

The actual value specified by the --poll y|n option was not
being used.  The way the --poll value is used is hidden
through an indirection where the value is stored in a
global variable at the start of the command, and then the
value is read from there later.  Setting the global
variable early in the command had been lost with the
cmd def changes.
---
 tools/lvchange.c |   19 ++++++++++++++-----
 1 files changed, 14 insertions(+), 5 deletions(-)

diff --git a/tools/lvchange.c b/tools/lvchange.c
index d80095d..60a37a9 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -142,8 +142,9 @@ static int _lvchange_pool_update(struct cmd_context *cmd,
 }
 
 /*
- * The --monitor y|n value is taken indirectly from dmeventd_monitor_mode()
- * whose value was set via init_dmeventd_monitor().
+ * The --monitor y|n value is read from dmeventd_monitor_mode(),
+ * which was set by the init_dmeventd_monitor() /
+ * get_activation_monitoring_mode() / arg_int_value(monitor_ARG).
  */
 
 static int _lvchange_monitoring(struct cmd_context *cmd,
@@ -158,7 +159,10 @@ static int _lvchange_monitoring(struct cmd_context *cmd,
 	}
 
 	if (dmeventd_monitor_mode() != DMEVENTD_MONITOR_IGNORE) {
-		log_verbose("Monitoring LV %s", display_lvname(lv));
+		if (dmeventd_monitor_mode())
+			log_verbose("Monitoring LV %s", display_lvname(lv));
+		else
+			log_verbose("Unmonitoring LV %s", display_lvname(lv));
 		if (!monitor_dev_for_events(cmd, lv, 0, dmeventd_monitor_mode()))
 			return_0;
 	}
@@ -167,8 +171,8 @@ static int _lvchange_monitoring(struct cmd_context *cmd,
 }
 
 /*
- * The --poll y|n value is taken indirectly from background_polling(),
- * whose value was set via init_background_polling().
+ * The --poll y|n value is read from background_polling(),
+ * which was set by init_background_polling(arg_int_value(poll_ARG)).
  */
 
 static int _lvchange_background_polling(struct cmd_context *cmd,
@@ -1236,6 +1240,7 @@ int lvchange_properties_cmd(struct cmd_context *cmd, int argc, char **argv)
 	 * A command def rule allows only some options when LV is partial,
 	 * so handles_missing_pvs will only affect those.
 	 */
+	init_background_polling(arg_is_set(cmd, sysinit_ARG) ? 0 : arg_int_value(cmd, poll_ARG, DEFAULT_BACKGROUND_POLLING));
 	cmd->handles_missing_pvs = 1;
 	ret = process_each_lv(cmd, argc, argv, NULL, NULL, READ_FOR_UPDATE,
 			      NULL, &_lvchange_properties_check, &_lvchange_properties_single);
@@ -1340,6 +1345,7 @@ int lvchange_activate_cmd(struct cmd_context *cmd, int argc, char **argv)
 {
 	int ret;
 
+	init_background_polling(arg_is_set(cmd, sysinit_ARG) ? 0 : arg_int_value(cmd, poll_ARG, DEFAULT_BACKGROUND_POLLING));
 	cmd->handles_missing_pvs = 1;
 	cmd->lockd_vg_default_sh = 1;
 
@@ -1406,6 +1412,7 @@ static int _lvchange_refresh_check(struct cmd_context *cmd,
 
 int lvchange_refresh_cmd(struct cmd_context *cmd, int argc, char **argv)
 {
+	init_background_polling(arg_is_set(cmd, sysinit_ARG) ? 0 : arg_int_value(cmd, poll_ARG, DEFAULT_BACKGROUND_POLLING));
 	cmd->handles_missing_pvs = 1;
 	cmd->lockd_vg_default_sh = 1;
 
@@ -1555,6 +1562,7 @@ static int _lvchange_monitor_poll_check(struct cmd_context *cmd,
 
 int lvchange_monitor_poll_cmd(struct cmd_context *cmd, int argc, char **argv)
 {
+	init_background_polling(arg_is_set(cmd, sysinit_ARG) ? 0 : arg_int_value(cmd, poll_ARG, DEFAULT_BACKGROUND_POLLING));
 	cmd->handles_missing_pvs = 1;
 	return process_each_lv(cmd, argc, argv, NULL, NULL, 0,
 			       NULL, &_lvchange_monitor_poll_check, &_lvchange_monitor_poll_single);
@@ -1593,6 +1601,7 @@ int lvchange_persistent_cmd(struct cmd_context *cmd, int argc, char **argv)
 {
 	int ret;
 
+	init_background_polling(arg_is_set(cmd, sysinit_ARG) ? 0 : arg_int_value(cmd, poll_ARG, DEFAULT_BACKGROUND_POLLING));
 	cmd->handles_missing_pvs = 1;
 
 	ret = process_each_lv(cmd, argc, argv, NULL, NULL, READ_FOR_UPDATE,


