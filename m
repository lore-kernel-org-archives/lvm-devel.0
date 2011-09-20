From: Peter Rajnoha <prajnoha@redhat.com>
Date: Tue, 20 Sep 2011 14:59:16 +0200
Subject: [PATCH 7/7][retry remove] Add support for "retry_deactivation" lvm.conf option
Message-ID: <4E788E24.4010502@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

...the comment in the lvm.conf would need a few more words to explain,
but let's see if this patchset is acceptable first :)

Peter
---
 doc/example.conf.in        |    3 +++
 lib/activate/dev_manager.c |    2 ++
 lib/commands/toolcontext.c |    3 +++
 lib/config/defaults.h      |    1 +
 lib/misc/lvm-globals.c     |   11 +++++++++++
 lib/misc/lvm-globals.h     |    2 ++
 6 files changed, 22 insertions(+), 0 deletions(-)

diff --git a/doc/example.conf.in b/doc/example.conf.in
index 94c632f..e588a34 100644
--- a/doc/example.conf.in
+++ b/doc/example.conf.in
@@ -465,6 +465,9 @@ activation {
     # Useful for diagnosing problems with LVM2/udev interactions.
     verify_udev_operations = 0
 
+    # Set to 1 to retry the volume deactivation several times
+    retry_deactivation = 1
+
     # How to fill in missing stripes if activating an incomplete volume.
     # Using "error" will make inaccessible parts of the device return
     # I/O errors on access.  You can instead use a device path, in which 
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index b5b4b9e..0a3c29c 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1782,6 +1782,8 @@ static int _tree_action(struct dev_manager *dm, struct logical_volume *lv,
 			goto_out;
 		break;
 	case DEACTIVATE:
+		if (retry_deactivation())
+			dm_tree_retry_remove(root);
  		/* Deactivate LV and all devices it references that nothing else has open. */
 		r = dm_tree_deactivate_children(root, dlid, ID_LEN + sizeof(UUID_PREFIX) - 1);
 		if (!r)
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 3dccc18..38ec577 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -304,6 +304,9 @@ static int _process_config(struct cmd_context *cmd)
 								"activation/udev_sync",
 								DEFAULT_UDEV_SYNC);
 
+	init_retry_deactivation(find_config_tree_int(cmd, "activation/retry_deactivation",
+							DEFAULT_RETRY_DEACTIVATION));
+
 	init_activation_checks(find_config_tree_int(cmd, "activation/checks",
 						      DEFAULT_ACTIVATION_CHECKS));
 
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index a517943..16b524d 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -81,6 +81,7 @@
 #define DEFAULT_UDEV_RULES 1
 #define DEFAULT_UDEV_SYNC 1
 #define DEFAULT_VERIFY_UDEV_OPERATIONS 0
+#define DEFAULT_RETRY_DEACTIVATION 1
 #define DEFAULT_ACTIVATION_CHECKS 0
 #define DEFAULT_EXTENT_SIZE 4096	/* In KB */
 #define DEFAULT_MAX_PV 0
diff --git a/lib/misc/lvm-globals.c b/lib/misc/lvm-globals.c
index 7358a34..69de623 100644
--- a/lib/misc/lvm-globals.c
+++ b/lib/misc/lvm-globals.c
@@ -42,6 +42,7 @@ static int _ignore_suspended_devices = 0;
 static int _error_message_produced = 0;
 static unsigned _is_static = 0;
 static int _udev_checking = 1;
+static int _retry_deactivation = DEFAULT_RETRY_DEACTIVATION;
 static int _activation_checks = 0;
 static char _sysfs_dir_path[PATH_MAX] = "";
 static int _dev_disable_after_error_count = DEFAULT_DISABLE_AFTER_ERROR_COUNT;
@@ -134,6 +135,11 @@ void init_udev_checking(int checking)
 		log_debug("LVM udev checking disabled");
 }
 
+void init_retry_deactivation(int retry)
+{
+	_retry_deactivation = retry;
+}
+
 void init_activation_checks(int checks)
 {
 	if ((_activation_checks = checks))
@@ -272,6 +278,11 @@ int udev_checking(void)
 	return _udev_checking;
 }
 
+int retry_deactivation(void)
+{
+	return _retry_deactivation;
+}
+
 int activation_checks(void)
 {
 	return _activation_checks;
diff --git a/lib/misc/lvm-globals.h b/lib/misc/lvm-globals.h
index fcba687..ba10417 100644
--- a/lib/misc/lvm-globals.h
+++ b/lib/misc/lvm-globals.h
@@ -42,6 +42,7 @@ void init_dev_disable_after_error_count(int value);
 void init_pv_min_size(uint64_t sectors);
 void init_activation_checks(int checks);
 void init_detect_internal_vg_cache_corruption(int detect);
+void init_retry_deactivation(int retry);
 
 void set_cmd_name(const char *cmd_name);
 void set_sysfs_dir_path(const char *path);
@@ -67,6 +68,7 @@ const char *sysfs_dir_path(void);
 uint64_t pv_min_size(void);
 int activation_checks(void);
 int detect_internal_vg_cache_corruption(void);
+int retry_deactivation(void);
 
 #define DMEVENTD_MONITOR_IGNORE -1
 int dmeventd_monitor_mode(void);


