From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 29 Nov 2012 13:21:31 +0000 (UTC)
Subject: master - udev: recognize DM_DISABLE_UDEV environment variable
Message-ID: <20121129132131.476F34A1D@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4891a735d343db26460f1b6218169c458d59f2a1
Commit:        4891a735d343db26460f1b6218169c458d59f2a1
Parent:        fb8cc7c63f7f5ab9e0d6d2d38f29169346a54087
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Nov 29 14:03:48 2012 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Nov 29 14:03:48 2012 +0100

udev: recognize DM_DISABLE_UDEV environment variable

Setting this environment variable will cause a full fallback
to old direct node and symlink management in libdevmapper and lvm2.

It means:

 - disabling udev synchronization
   (--noudevsync in dmsetup and --noudevsync + activation/udev_sync=0
    lvm2 config)
 - disabling dm and any subsystem related udev rules
   (--noudevrules in dmsetup and activation/udev_rules=0 lvm2 config)
 - management of nodes/symlinks under /dev directly by libdevmapper/lvm2
   (--verifyudev in dmsetup and activation/verify_udev_operations=1
    lvm2 config)
 - not obtaining any device list from udev database
   (devices/obtain_device_list_from_udev=0 lvm2 config)

Note: we could set all of these before - there's no functional change!
However the DM_DISABLE_UDEV environment variable is a nice shortcut
to make it easier for libdevmapper users so that one can switch off all
of the udev management off at one go directly on the command line,
without a need to modify any source or add any extra switches.
---
 WHATS_NEW                  |    1 +
 WHATS_NEW_DM               |    1 +
 lib/commands/toolcontext.c |   55 +++++++++++++++++++++++++++++++------------
 libdm/libdm-common.c       |   34 ++++++++++++++++++++++++---
 4 files changed, 71 insertions(+), 20 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 657b3a4..ca1b539 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Recognize DM_DISABLE_UDEV environment variable for a complete fallback.
   Do not verify udev operations if --noudevsync command option is used.
   Fix lvm2api and return lvseg discards property as string.
   Allow forced vgcfgrestore of lvm2 metadata with thin volumes.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 3f8d9c9..3ea0502 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.78 - 
 ===================================
+  Add DM_DISABLE_UDEV environment variable to manage dev nodes by libdm only.
   Fix dm_task_set_cookie to properly process udev flags if udev_sync disabled.
 
 Version 1.02.77 - 15th October 2012
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index aec4df3..57ce1fe 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -237,6 +237,7 @@ static int _process_config(struct cmd_context *cmd)
 	const struct dm_config_value *cv;
 	int64_t pv_min_kb;
 	const char *lvmetad_socket;
+	int udev_disabled = 0;
 
 	/* umask */
 	cmd->default_settings.umask = find_config_tree_int(cmd,
@@ -310,13 +311,25 @@ static int _process_config(struct cmd_context *cmd)
 		return 0;
 	}
 
-	cmd->default_settings.udev_rules = find_config_tree_int(cmd,
-								"activation/udev_rules",
-								DEFAULT_UDEV_RULES);
+	/*
+	 * If udev is disabled using DM_DISABLE_UDEV environment
+	 * variable, override existing config and hardcode these:
+	 *   - udev_rules = 0
+	 *   - udev_sync = 0
+	 *   - udev_fallback = 1
+	 */
+	if (getenv("DM_DISABLE_UDEV")) {
+		log_very_verbose("DM_DISABLE_UDEV environment variable set. "
+				 "Overriding configuration to use "
+				 "udev_rules=0, udev_sync=0, verify_udev_operations=1.");
+		udev_disabled = 1;
+	}
+
+	cmd->default_settings.udev_rules = udev_disabled ? 0 :
+		find_config_tree_int(cmd, "activation/udev_rules", DEFAULT_UDEV_RULES);
 
-	cmd->default_settings.udev_sync = find_config_tree_int(cmd,
-								"activation/udev_sync",
-								DEFAULT_UDEV_SYNC);
+	cmd->default_settings.udev_sync = udev_disabled ? 0 :
+		find_config_tree_int(cmd, "activation/udev_sync", DEFAULT_UDEV_SYNC);
 
 	init_retry_deactivation(find_config_tree_int(cmd, "activation/retry_deactivation",
 							DEFAULT_RETRY_DEACTIVATION));
@@ -326,14 +339,12 @@ static int _process_config(struct cmd_context *cmd)
 
 #ifdef UDEV_SYNC_SUPPORT
 	/*
-	 * We need udev rules to be applied, otherwise we would end up with no
-	 * nodes and symlinks! However, we can disable the synchronization itself
-	 * in runtime and still have only udev to create the nodes and symlinks
-	 * without any fallback.
+	 * Use udev fallback automatically in case udev
+	 * is disabled via DM_DISABLE_UDEV environment
+	 * variable or udev rules are switched off.
 	 */
-	cmd->default_settings.udev_fallback = cmd->default_settings.udev_rules ?
-		find_config_tree_int(cmd, "activation/verify_udev_operations",
-				     DEFAULT_VERIFY_UDEV_OPERATIONS) : 1;
+	cmd->default_settings.udev_fallback = !cmd->default_settings.udev_rules || udev_disabled ? 1 :
+		find_config_tree_int(cmd, "activation/verify_udev_operations", DEFAULT_VERIFY_UDEV_OPERATIONS);
 
 	/* Do not rely fully on udev if the udev support is known to be incomplete. */
 	if (!cmd->default_settings.udev_fallback && !_dm_driver_has_stable_udev_support()) {
@@ -693,9 +704,21 @@ static int _init_dev_cache(struct cmd_context *cmd)
 	if (!dev_cache_init(cmd))
 		return_0;
 
-	device_list_from_udev = udev_is_running() ?
-		find_config_tree_bool(cmd, "devices/obtain_device_list_from_udev",
-				      DEFAULT_OBTAIN_DEVICE_LIST_FROM_UDEV) : 0;
+	/*
+	 * Override existing config and hardcode device_list_from_udev = 0 if:
+	 *   - udev is not running
+	 *   - udev is disabled using DM_DISABLE_UDEV environment variable
+	 */
+	if (getenv("DM_DISABLE_UDEV")) {
+		log_very_verbose("DM_DISABLE_UDEV environment variable set. "
+				 "Overriding configuration to use "
+				 "device_list_from_udev=0");
+		device_list_from_udev = 0;
+	} else
+		device_list_from_udev = udev_is_running() ?
+			find_config_tree_bool(cmd, "devices/obtain_device_list_from_udev",
+					      DEFAULT_OBTAIN_DEVICE_LIST_FROM_UDEV) : 0;
+
 	init_obtain_device_list_from_udev(device_list_from_udev);
 
 	if (!(cn = find_config_tree_node(cmd, "devices/scan"))) {
diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index afdac89..2d79efa 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -75,6 +75,7 @@ static struct selabel_handle *_selabel_handle = NULL;
 #endif
 
 #ifdef UDEV_SYNC_SUPPORT
+static int _udev_disabled = 0;
 static int _semaphore_supported = -1;
 static int _udev_running = -1;
 static int _sync_with_udev = 1;
@@ -85,6 +86,9 @@ void dm_lib_init(void)
 {
 	const char *env;
 
+	if ((env = getenv("DM_DISABLE_UDEV")))
+		_udev_disabled = 1;
+
 	env = getenv(DM_DEFAULT_NAME_MANGLING_MODE_ENV_VAR_NAME);
 	if (env && *env) {
 		if (!strcasecmp(env, "none"))
@@ -1814,6 +1818,26 @@ out:
 	return r;
 }
 
+static void _set_cookie_flags(struct dm_task *dmt, uint16_t flags)
+{
+	if (!dm_cookie_supported())
+		return;
+
+	if (_udev_disabled) {
+		/*
+		 * If udev is disabled, hardcode this functionality:
+		 *   - we want libdm to create the nodes
+		 *   - we don't want the /dev/mapper and any subsystem
+		 *     related content to be created by udev if udev
+		 *     rules are installed
+		 */
+		flags &= ~DM_UDEV_DISABLE_LIBRARY_FALLBACK;
+		flags |= DM_UDEV_DISABLE_DM_RULES_FLAG | DM_UDEV_DISABLE_SUBSYSTEM_RULES_FLAG;
+	}
+
+	dmt->event_nr = flags << DM_UDEV_FLAGS_SHIFT;
+}
+
 #ifndef UDEV_SYNC_SUPPORT
 void dm_udev_set_sync_support(int sync_with_udev)
 {
@@ -1835,8 +1859,8 @@ int dm_udev_get_checking(void)
 
 int dm_task_set_cookie(struct dm_task *dmt, uint32_t *cookie, uint16_t flags)
 {
-	if (dm_cookie_supported())
-		dmt->event_nr = flags << DM_UDEV_FLAGS_SHIFT;
+	_set_cookie_flags(dmt, flags);
+
 	*cookie = 0;
 	dmt->cookie_set = 1;
 
@@ -1920,6 +1944,9 @@ void dm_udev_set_sync_support(int sync_with_udev)
 
 int dm_udev_get_sync_support(void)
 {
+	if (_udev_disabled)
+		return 0;
+
 	_check_udev_sync_requirements_once();
 
 	return _semaphore_supported && dm_cookie_supported() &&
@@ -2203,8 +2230,7 @@ int dm_task_set_cookie(struct dm_task *dmt, uint32_t *cookie, uint16_t flags)
 {
 	int semid;
 
-	if (dm_cookie_supported())
-		dmt->event_nr = flags << DM_UDEV_FLAGS_SHIFT;
+	_set_cookie_flags(dmt, flags);
 
 	if (!dm_udev_get_sync_support()) {
 		*cookie = 0;


