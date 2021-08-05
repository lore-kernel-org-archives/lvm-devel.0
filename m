From: David Teigland <teigland@sourceware.org>
Date: Thu,  5 Aug 2021 18:21:25 +0000 (GMT)
Subject: main - devices file: avoid updating entry dev names in some cases
Message-ID: <20210805182125.281B83858415@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=87714a1384def2ea107d7dbc264eff44c2025865
Commit:        87714a1384def2ea107d7dbc264eff44c2025865
Parent:        d3d6a0e820ff930a5a7c137e7bbeb0225e251df7
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jul 27 16:56:20 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Aug 5 13:20:26 2021 -0500

devices file: avoid updating entry dev names in some cases

Avoid thrashing changes to devices file device names by
some commands that are run during startup when devnames
are still being set up.
---
 lib/commands/toolcontext.h | 1 +
 lib/device/device_id.c     | 9 +++++++++
 tools/lvchange.c           | 3 +++
 tools/pvscan.c             | 2 ++
 tools/vgchange.c           | 3 +++
 5 files changed, 18 insertions(+)

diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index 4dbc75cfc..0911b05f1 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -194,6 +194,7 @@ struct cmd_context {
 	unsigned sysinit:1;			/* --sysinit is used */
 	unsigned check_devs_used:1;		/* check devs used by LVs */
 	unsigned print_device_id_not_found;	/* print devices file entries not found */
+	unsigned ignore_device_name_mismatch;   /* skip updating devices file names */
 
 	/*
 	 * Devices and filtering.
diff --git a/lib/device/device_id.c b/lib/device/device_id.c
index 6ac646a16..6f61cf3f1 100644
--- a/lib/device/device_id.c
+++ b/lib/device/device_id.c
@@ -1639,6 +1639,15 @@ void device_ids_validate(struct cmd_context *cmd, struct dm_list *scanned_devs,
 			}
 		}
 
+		/*
+		 * Avoid thrashing changes to the devices file during
+		 * startup due to device names that are still being
+		 * established.  Commands that may run during startup
+		 * should set this flag.
+		 */
+		if (cmd->ignore_device_name_mismatch)
+			continue;
+
 		if (!du->devname || strcmp(dev_name(du->dev), du->devname)) {
 			log_warn("Device %s has updated name (devices file %s)",
 				 dev_name(du->dev), du->devname ?: "none");
diff --git a/tools/lvchange.c b/tools/lvchange.c
index bfd464d5c..d4c40df47 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -1535,6 +1535,7 @@ int lvchange_activate_cmd(struct cmd_context *cmd, int argc, char **argv)
 	init_background_polling(arg_is_set(cmd, sysinit_ARG) ? 0 : arg_int_value(cmd, poll_ARG, DEFAULT_BACKGROUND_POLLING));
 	cmd->handles_missing_pvs = 1;
 	cmd->lockd_vg_default_sh = 1;
+	cmd->ignore_device_name_mismatch = 1;
 
 	/*
 	 * Include foreign VGs that contain active LVs.
@@ -1619,6 +1620,7 @@ int lvchange_refresh_cmd(struct cmd_context *cmd, int argc, char **argv)
 	init_background_polling(arg_is_set(cmd, sysinit_ARG) ? 0 : arg_int_value(cmd, poll_ARG, DEFAULT_BACKGROUND_POLLING));
 	cmd->handles_missing_pvs = 1;
 	cmd->lockd_vg_default_sh = 1;
+	cmd->ignore_device_name_mismatch = 1;
 
 	return process_each_lv(cmd, argc, argv, NULL, NULL, 0,
 			       NULL, &_lvchange_refresh_check, &_lvchange_refresh_single);
@@ -1792,6 +1794,7 @@ int lvchange_monitor_poll_cmd(struct cmd_context *cmd, int argc, char **argv)
 {
 	init_background_polling(arg_is_set(cmd, sysinit_ARG) ? 0 : arg_int_value(cmd, poll_ARG, DEFAULT_BACKGROUND_POLLING));
 	cmd->handles_missing_pvs = 1;
+	cmd->ignore_device_name_mismatch = 1;
 	return process_each_lv(cmd, argc, argv, NULL, NULL, 0,
 			       NULL, &_lvchange_monitor_poll_check, &_lvchange_monitor_poll_single);
 }
diff --git a/tools/pvscan.c b/tools/pvscan.c
index 46d0786bc..1c84b8407 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -1622,6 +1622,8 @@ int pvscan_cache_cmd(struct cmd_context *cmd, int argc, char **argv)
 
 	cmd->print_device_id_not_found = 0;
 
+	cmd->ignore_device_name_mismatch = 1;
+
 	event_activation = find_config_tree_bool(cmd, global_event_activation_CFG, NULL);
 
 	if (do_activate && !event_activation) {
diff --git a/tools/vgchange.c b/tools/vgchange.c
index 22038ba9b..d2d5f9dd2 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -799,6 +799,9 @@ int vgchange(struct cmd_context *cmd, int argc, char **argv)
 	if (!update || !update_partial_unsafe)
 		cmd->handles_missing_pvs = 1;
 
+	if (noupdate)
+		cmd->ignore_device_name_mismatch = 1;
+
 	/*
 	 * Include foreign VGs that contain active LVs.
 	 * That shouldn't happen in general, but if it does by some


