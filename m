From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed,  5 Jun 2013 12:03:11 +0000 (UTC)
Subject: dev-mornfall-lvmcache - toolcontext: check dm version lazily for udev_fallback setting
Message-ID: <20130605120311.F34EE60DF2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=44071331138a7ca3a7d775d8a091933404ee7509
Commit:        44071331138a7ca3a7d775d8a091933404ee7509
Parent:        3d0cb0611e5e68fc4d865102f8339552a907ff4b
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon May 13 11:46:24 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon May 13 11:53:53 2013 +0200

toolcontext: check dm version lazily for udev_fallback setting

Setting the cmd->default_settings.udev_fallback also requires DM
driver version check. However, this caused useless mapper/control
access with ioctl if not needed actually. For example if we're not
using activation code, we don't need to know the udev_fallback as
there's no node and symlink processing.

For example, this premature mapper/control access caused problems
when using lvm2app even when no activation happens - there are
situations in which we don't need to use mapper/control, but still
need some of the lvm2app functionality. This is also the case for
lvm2-activation systemd generator which just needs to look at the
lvm2 configuration, but it shouldn't touch mapper/control.
---
 WHATS_NEW                  |    1 +
 lib/activate/dev_manager.c |   57 +++++++++++++++++++++++++++++++++++++++++--
 lib/commands/toolcontext.c |   46 ++++++-----------------------------
 3 files changed, 63 insertions(+), 41 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index bad183c..2cdd0cd 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Fix premature DM version checking which caused useless mapper/control access.
   Add "active" LV reporting field to show activation state.
   Add "monitor" segment reporting field to show dmevent monitoring status.
   Document lvextend --use-policies option in man.
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 150bb35..8e3cbb7 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1309,6 +1309,57 @@ int dev_manager_mknodes(const struct logical_volume *lv)
 	return r;
 }
 
+#ifdef UDEV_SYNC_SUPPORT
+/*
+ * Until the DM_UEVENT_GENERATED_FLAG was introduced in kernel patch
+ * 856a6f1dbd8940e72755af145ebcd806408ecedd
+ * some operations could not be performed by udev, requiring our fallback code.
+ */
+static int _dm_driver_has_stable_udev_support(void)
+{
+	char vsn[80];
+	unsigned maj, min, patchlevel;
+
+	return driver_version(vsn, sizeof(vsn)) &&
+	       (sscanf(vsn, "%u.%u.%u", &maj, &min, &patchlevel) == 3) &&
+	       (maj == 4 ? min >= 18 : maj > 4);
+}
+
+static int _check_udev_fallback(struct cmd_context *cmd)
+{
+	struct config_info *settings = &cmd->current_settings;
+
+	if (settings->udev_fallback != -1)
+		goto out;
+
+	/*
+	 * Use udev fallback automatically in case udev
+	 * is disabled via DM_DISABLE_UDEV environment
+	 * variable or udev rules are switched off.
+	 */
+	settings->udev_fallback = !settings->udev_rules ? 1 :
+		find_config_tree_bool(cmd, activation_verify_udev_operations_CFG);
+
+	/* Do not rely fully on udev if the udev support is known to be incomplete. */
+	if (!settings->udev_fallback && !_dm_driver_has_stable_udev_support()) {
+		log_very_verbose("Kernel driver has incomplete udev support so "
+				 "LVM will check and perform some operations itself.");
+		settings->udev_fallback = 1;
+	}
+out:
+	return settings->udev_fallback;
+}
+
+#else /* UDEV_SYNC_SUPPORT */
+
+static int _check_udev_fallback(struct cmd_context *cmd)
+{
+	/* We must use old node/symlink creation code if not compiled with udev support at all! */
+	return cmd->current_settings.udev_fallback = 1;
+}
+
+#endif /* UDEV_SYNC_SUPPORT */
+
 static uint16_t _get_udev_flags(struct dev_manager *dm, struct logical_volume *lv,
 				const char *layer)
 {
@@ -1318,7 +1369,7 @@ static uint16_t _get_udev_flags(struct dev_manager *dm, struct logical_volume *l
 	 * Instruct also libdevmapper to disable udev
 	 * fallback in accordance to LVM2 settings.
 	 */
-	if (!dm->cmd->current_settings.udev_fallback)
+	if (!_check_udev_fallback(dm->cmd))
 		udev_flags |= DM_UDEV_DISABLE_LIBRARY_FALLBACK;
 
 	/*
@@ -2399,7 +2450,7 @@ static int _create_lv_symlinks(struct dev_manager *dm, struct dm_tree_node *root
 	int r = 1;
 
 	/* Nothing to do if udev fallback is disabled. */
-	if (!dm->cmd->current_settings.udev_fallback) {
+	if (!_check_udev_fallback(dm->cmd)) {
 		fs_set_create();
 		return 1;
 	}
@@ -2447,7 +2498,7 @@ static int _remove_lv_symlinks(struct dev_manager *dm, struct dm_tree_node *root
 	int r = 1;
 
 	/* Nothing to do if udev fallback is disabled. */
-	if (!dm->cmd->current_settings.udev_fallback)
+	if (!_check_udev_fallback(dm->cmd))
 		return 1;
 
 	while ((child = dm_tree_next_child(&handle, root, 0))) {
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 8f06285..2ea877a 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -262,23 +262,6 @@ static int _check_disable_udev(const char *msg) {
 	return 0;
 }
 
-#ifdef UDEV_SYNC_SUPPORT
-/*
- * Until the DM_UEVENT_GENERATED_FLAG was introduced in kernel patch 
- * 856a6f1dbd8940e72755af145ebcd806408ecedd
- * some operations could not be performed by udev, requiring our fallback code.
- */
-static int _dm_driver_has_stable_udev_support(void)
-{
-	char vsn[80];
-	unsigned maj, min, patchlevel;
-
-	return driver_version(vsn, sizeof(vsn)) &&
-	       (sscanf(vsn, "%u.%u.%u", &maj, &min, &patchlevel) == 3) &&
-	       (maj == 4 ? min >= 18 : maj > 4);
-}
-#endif
-
 static int _process_config(struct cmd_context *cmd)
 {
 	mode_t old_umask;
@@ -372,30 +355,17 @@ static int _process_config(struct cmd_context *cmd)
 	cmd->default_settings.udev_sync = udev_disabled ? 0 :
 		find_config_tree_bool(cmd, activation_udev_sync_CFG);
 
-	init_retry_deactivation(find_config_tree_bool(cmd, activation_retry_deactivation_CFG));
-
-	init_activation_checks(find_config_tree_bool(cmd, activation_checks_CFG));
-
-#ifdef UDEV_SYNC_SUPPORT
 	/*
-	 * Use udev fallback automatically in case udev
-	 * is disabled via DM_DISABLE_UDEV environment
-	 * variable or udev rules are switched off.
+	 * Set udev_fallback lazily on first use since it requires
+	 * checking DM driver version which is an extra ioctl!
+	 * This also prevents unnecessary use of mapper/control.
+	 * If udev is disabled globally, set fallback mode immediately.
 	 */
-	cmd->default_settings.udev_fallback = !cmd->default_settings.udev_rules || udev_disabled ? 1 :
-		find_config_tree_bool(cmd, activation_verify_udev_operations_CFG);
+	cmd->default_settings.udev_fallback = udev_disabled ? 1 : -1;
 
-	/* Do not rely fully on udev if the udev support is known to be incomplete. */
-	if (!cmd->default_settings.udev_fallback && !_dm_driver_has_stable_udev_support()) {
-		log_very_verbose("Kernel driver has incomplete udev support so "
-				 "LVM will check and perform some operations itself.");
-		cmd->default_settings.udev_fallback = 1;
-	}
+	init_retry_deactivation(find_config_tree_bool(cmd, activation_retry_deactivation_CFG));
 
-#else
-	/* We must use old node/symlink creation code if not compiled with udev support at all! */
-	cmd->default_settings.udev_fallback = 1;
-#endif
+	init_activation_checks(find_config_tree_bool(cmd, activation_checks_CFG));
 
 	cmd->use_linear_target = find_config_tree_bool(cmd, activation_use_linear_target_CFG);
 


