From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 29 Nov 2012 14:58:34 +0000 (UTC)
Subject: master - udev: add a warning message if DM_DISABLE_UDEV set and udev running
Message-ID: <20121129145834.99649A0C4F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ed9751d9fa6638e0cae5aa38727f971eeac6516c
Commit:        ed9751d9fa6638e0cae5aa38727f971eeac6516c
Parent:        b13d45d21d616c5512593617bbf5ed4c623805ed
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Nov 29 15:50:52 2012 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Nov 29 15:57:43 2012 +0100

udev: add a warning message if DM_DISABLE_UDEV set and udev running

$ export DM_DISABLE_UDEV=1

$ dmsetup create test --table "0 1 zero"
Udev is running and DM_DISABLE_UDEV environment variable is set. Bypassing udev, device-mapper library will manage device nodes in device directory.

$ lvchange -ay vg/lvol0
  Udev is running and DM_DISABLE_UDEV environment variable is set. Bypassing udev, LVM will manage logical volume symlinks in device directory.
  Udev is running and DM_DISABLE_UDEV environment variable is set. Bypassing udev, LVM will obtain device list by scanning device directory.
  Udev is running and DM_DISABLE_UDEV environment variable is set. Bypassing udev, device-mapper library will manage device nodes in device directory.
---
 lib/commands/toolcontext.c |   29 ++++++++++++++++++-----------
 libdm/libdm-common.c       |   14 ++++++++------
 2 files changed, 26 insertions(+), 17 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 57ce1fe..14152b7 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -211,6 +211,21 @@ static void _init_logging(struct cmd_context *cmd)
 	reset_lvm_errno(1);
 }
 
+static int _check_disable_udev(const char *msg) {
+	if (getenv("DM_DISABLE_UDEV")) {
+		log_very_verbose("DM_DISABLE_UDEV environment variable set. "
+				 "Overriding configuration to use "
+				 "udev_rules=0, udev_sync=0, verify_udev_operations=1.");
+		if (udev_is_running())
+			log_warn("Udev is running and DM_DISABLE_UDEV environment variable is set. "
+				 "Bypassing udev, LVM will %s.", msg);
+
+		return 1;
+	}
+
+	return 0;
+}
+
 #ifdef UDEV_SYNC_SUPPORT
 /*
  * Until the DM_UEVENT_GENERATED_FLAG was introduced in kernel patch 
@@ -318,12 +333,7 @@ static int _process_config(struct cmd_context *cmd)
 	 *   - udev_sync = 0
 	 *   - udev_fallback = 1
 	 */
-	if (getenv("DM_DISABLE_UDEV")) {
-		log_very_verbose("DM_DISABLE_UDEV environment variable set. "
-				 "Overriding configuration to use "
-				 "udev_rules=0, udev_sync=0, verify_udev_operations=1.");
-		udev_disabled = 1;
-	}
+	udev_disabled = _check_disable_udev("manage logical volume symlinks in device directory");
 
 	cmd->default_settings.udev_rules = udev_disabled ? 0 :
 		find_config_tree_int(cmd, "activation/udev_rules", DEFAULT_UDEV_RULES);
@@ -709,12 +719,9 @@ static int _init_dev_cache(struct cmd_context *cmd)
 	 *   - udev is not running
 	 *   - udev is disabled using DM_DISABLE_UDEV environment variable
 	 */
-	if (getenv("DM_DISABLE_UDEV")) {
-		log_very_verbose("DM_DISABLE_UDEV environment variable set. "
-				 "Overriding configuration to use "
-				 "device_list_from_udev=0");
+	if (_check_disable_udev("obtain device list by scanning device directory"))
 		device_list_from_udev = 0;
-	} else
+	else
 		device_list_from_udev = udev_is_running() ?
 			find_config_tree_bool(cmd, "devices/obtain_device_list_from_udev",
 					      DEFAULT_OBTAIN_DEVICE_LIST_FROM_UDEV) : 0;
diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index 527124f..075fba8 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -1933,8 +1933,13 @@ static void _check_udev_sync_requirements_once(void)
 	if (_semaphore_supported < 0)
 		_semaphore_supported = _check_semaphore_is_supported();
 
-	if (_udev_running < 0)
+	if (_udev_running < 0) {
 		_udev_running = _check_udev_is_running();
+		if (_udev_disabled && _udev_running)
+			log_warn("Udev is running and DM_DISABLE_UDEV environment variable is set. "
+				 "Bypassing udev, device-mapper library will manage device "
+				 "nodes in device directory.");
+	}
 }
 
 void dm_udev_set_sync_support(int sync_with_udev)
@@ -1945,13 +1950,10 @@ void dm_udev_set_sync_support(int sync_with_udev)
 
 int dm_udev_get_sync_support(void)
 {
-	if (_udev_disabled)
-		return 0;
-
 	_check_udev_sync_requirements_once();
 
-	return _semaphore_supported && dm_cookie_supported() &&
-		_udev_running && _sync_with_udev;
+	return !_udev_disabled && _semaphore_supported &&
+		dm_cookie_supported() &&_udev_running && _sync_with_udev;
 }
 
 void dm_udev_set_checking(int checking)


