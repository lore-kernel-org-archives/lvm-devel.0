From: David Teigland <teigland@sourceware.org>
Date: Fri, 15 Jun 2018 15:05:49 -0400
Subject: master - Remove unused device error counting
Message-ID: <201806151905.w5FJ5nn7012191@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=328303d4d45b4e9480cc806ef84e843e2176f584
Commit:        328303d4d45b4e9480cc806ef84e843e2176f584
Parent:        54f61e7dccf82471dd4a963bfcbcf14802806ca9
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Jun 15 14:04:39 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Jun 15 14:04:39 2018 -0500

Remove unused device error counting

---
 lib/commands/toolcontext.c   |    3 ---
 lib/config/config_settings.h |    8 ++------
 lib/config/defaults.h        |    3 ---
 lib/device/dev-cache.c       |   19 +++----------------
 lib/device/dev-io.c          |   24 ------------------------
 lib/device/device.h          |    2 --
 lib/misc/lvm-globals.c       |   11 -----------
 lib/misc/lvm-globals.h       |    4 ----
 8 files changed, 5 insertions(+), 69 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index a76c68d..723f882 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -974,9 +974,6 @@ static int _init_dev_cache(struct cmd_context *cmd)
 	int len_diff;
 	int device_list_from_udev;
 
-	init_dev_disable_after_error_count(
-		find_config_tree_int(cmd, devices_disable_after_error_count_CFG, NULL));
-
 	if (!dev_cache_init(cmd))
 		return_0;
 
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index ff098d8..ac0f0ff 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -410,12 +410,8 @@ cfg(devices_ignore_lvm_mirrors_CFG, "ignore_lvm_mirrors", devices_CFG_SECTION, 0
 	"apply to LVM RAID types like 'raid1' which handle failures in a\n"
 	"different way, making them a better choice for VG stacking.\n")
 
-cfg(devices_disable_after_error_count_CFG, "disable_after_error_count", devices_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_DISABLE_AFTER_ERROR_COUNT, vsn(2, 2, 75), NULL, 0, NULL,
-	"Number of I/O errors after which a device is skipped.\n"
-	"During each LVM operation, errors received from each device are\n"
-	"counted. If the counter of a device exceeds the limit set here,\n"
-	"no further I/O is sent to that device for the remainder of the\n"
-	"operation. Setting this to 0 disables the counters altogether.\n")
+cfg(devices_disable_after_error_count_CFG, "disable_after_error_count", devices_CFG_SECTION, 0, CFG_TYPE_INT, 0, vsn(2, 2, 75), NULL, vsn(3, 0, 0), NULL,
+	"This setting is no longer used.\n")
 
 cfg(devices_require_restorefile_with_uuid_CFG, "require_restorefile_with_uuid", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_REQUIRE_RESTOREFILE_WITH_UUID, vsn(2, 2, 73), NULL, 0, NULL,
 	"Allow use of pvcreate --uuid without requiring --restorefile.\n")
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 7cebd84..084d365 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -39,7 +39,6 @@
 #define DEFAULT_IGNORE_LVM_MIRRORS 1
 #define DEFAULT_MULTIPATH_COMPONENT_DETECTION 1
 #define DEFAULT_IGNORE_SUSPENDED_DEVICES 0
-#define DEFAULT_DISABLE_AFTER_ERROR_COUNT 0
 #define DEFAULT_REQUIRE_RESTOREFILE_WITH_UUID 1
 #define DEFAULT_DATA_ALIGNMENT_OFFSET_DETECTION 1
 #define DEFAULT_DATA_ALIGNMENT_DETECTION 1
@@ -206,8 +205,6 @@
 
 #define DEFAULT_MAX_HISTORY 100
 
-#define DEFAULT_MAX_ERROR_COUNT	NO_DEV_ERROR_COUNT_LIMIT
-
 #define DEFAULT_REP_COMPACT_OUTPUT 0
 #define DEFAULT_REP_ALIGNED 1
 #define DEFAULT_REP_BUFFERED 1
diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 1635c99..a0d98a3 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -62,13 +62,12 @@ static int _insert(const char *path, const struct stat *info,
 		   int rec, int check_with_udev_db);
 
 /* Setup non-zero members of passed zeroed 'struct device' */
-static void _dev_init(struct device *dev, int max_error_count)
+static void _dev_init(struct device *dev)
 {
 	dev->phys_block_size = -1;
 	dev->block_size = -1;
 	dev->fd = -1;
 	dev->read_ahead = -1;
-	dev->max_error_count = max_error_count;
 
 	dev->ext.enabled = 0;
 	dev->ext.src = DEV_EXT_NONE;
@@ -129,7 +128,7 @@ struct device *dev_create_file(const char *filename, struct device *dev,
 		return NULL;
 	}
 
-	_dev_init(dev, NO_DEV_ERROR_COUNT_LIMIT);
+	_dev_init(dev);
 	dev->flags = DEV_REGULAR | ((use_malloc) ? DEV_ALLOCED : 0);
 	dm_list_add(&dev->aliases, &alias->list);
 
@@ -145,7 +144,7 @@ static struct device *_dev_create(dev_t d)
 		return NULL;
 	}
 
-	_dev_init(dev, dev_disable_after_error_count());
+	_dev_init(dev);
 	dev->dev = d;
 
 	return dev;
@@ -1690,18 +1689,6 @@ struct device *dev_iter_get(struct cmd_context *cmd, struct dev_iter *iter)
 	return NULL;
 }
 
-void dev_reset_error_count(struct cmd_context *cmd)
-{
-	struct dev_iter iter;
-
-	if (!_cache.devices)
-		return;
-
-	iter.current = btree_first(_cache.devices);
-	while (iter.current)
-		_iter_next(&iter)->error_count = 0;
-}
-
 int dev_fd(struct device *dev)
 {
 	return dev->fd;
diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index ffdf75e..43c2c2d 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -689,20 +689,6 @@ int dev_close_immediate(struct device *dev)
 	return _dev_close(dev, 1);
 }
 
-static inline int _dev_is_valid(struct device *dev)
-{
-	return (dev->max_error_count == NO_DEV_ERROR_COUNT_LIMIT ||
-		dev->error_count < dev->max_error_count);
-}
-
-static void _dev_inc_error_count(struct device *dev)
-{
-	if (++dev->error_count == dev->max_error_count)
-		log_warn("WARNING: Error counts reached a limit of %d. "
-			 "Device %s was disabled",
-			 dev->max_error_count, dev_name(dev));
-}
-
 int dev_read(struct device *dev, uint64_t offset, size_t len, dev_io_reason_t reason, void *buffer)
 {
 	struct device_area where;
@@ -711,16 +697,11 @@ int dev_read(struct device *dev, uint64_t offset, size_t len, dev_io_reason_t re
 	if (!dev->open_count)
 		return_0;
 
-	if (!_dev_is_valid(dev))
-		return 0;
-
 	where.dev = dev;
 	where.start = offset;
 	where.size = len;
 
 	ret = _aligned_io(&where, buffer, 0, reason);
-	if (!ret)
-		_dev_inc_error_count(dev);
 
 	return ret;
 }
@@ -783,9 +764,6 @@ int dev_write(struct device *dev, uint64_t offset, size_t len, dev_io_reason_t r
 	if (!dev->open_count)
 		return_0;
 
-	if (!_dev_is_valid(dev))
-		return 0;
-
 	if (!len) {
 		log_error(INTERNAL_ERROR "Attempted to write 0 bytes to %s at " FMTu64, dev_name(dev), offset);
 		return 0;
@@ -798,8 +776,6 @@ int dev_write(struct device *dev, uint64_t offset, size_t len, dev_io_reason_t r
 	dev->flags |= DEV_ACCESSED_W;
 
 	ret = _aligned_io(&where, buffer, 1, reason);
-	if (!ret)
-		_dev_inc_error_count(dev);
 
 	return ret;
 }
diff --git a/lib/device/device.h b/lib/device/device.h
index 8f9ed55..00e398a 100644
--- a/lib/device/device.h
+++ b/lib/device/device.h
@@ -64,8 +64,6 @@ struct device {
 	/* private */
 	int fd;
 	int open_count;
-	int error_count;
-	int max_error_count;
 	int phys_block_size;
 	int block_size;
 	int read_ahead;
diff --git a/lib/misc/lvm-globals.c b/lib/misc/lvm-globals.c
index 9377588..86e6cf4 100644
--- a/lib/misc/lvm-globals.c
+++ b/lib/misc/lvm-globals.c
@@ -49,7 +49,6 @@ static int _udev_checking = 1;
 static int _retry_deactivation = DEFAULT_RETRY_DEACTIVATION;
 static int _activation_checks = 0;
 static char _sysfs_dir_path[PATH_MAX] = "";
-static int _dev_disable_after_error_count = DEFAULT_DISABLE_AFTER_ERROR_COUNT;
 static uint64_t _pv_min_size = (DEFAULT_PV_MIN_SIZE_KB * 1024L >> SECTOR_SHIFT);
 static const char *_unknown_device_name = DEFAULT_UNKNOWN_DEVICE_NAME;
 
@@ -173,11 +172,6 @@ void init_activation_checks(int checks)
 		log_debug_activation("LVM activation checks disabled");
 }
 
-void init_dev_disable_after_error_count(int value)
-{
-	_dev_disable_after_error_count = value;
-}
-
 void init_pv_min_size(uint64_t sectors)
 {
 	_pv_min_size = sectors;
@@ -345,11 +339,6 @@ const char *sysfs_dir_path(void)
 	return _sysfs_dir_path;
 }
 
-int dev_disable_after_error_count(void)
-{
-	return _dev_disable_after_error_count;
-}
-
 uint64_t pv_min_size(void)
 {
 	return _pv_min_size;
diff --git a/lib/misc/lvm-globals.h b/lib/misc/lvm-globals.h
index 55a9399..6fc26cc 100644
--- a/lib/misc/lvm-globals.h
+++ b/lib/misc/lvm-globals.h
@@ -45,7 +45,6 @@ void init_ignore_lvm_mirrors(int scan);
 void init_error_message_produced(int produced);
 void init_is_static(unsigned value);
 void init_udev_checking(int checking);
-void init_dev_disable_after_error_count(int value);
 void init_pv_min_size(uint64_t sectors);
 void init_activation_checks(int checks);
 void init_retry_deactivation(int retry);
@@ -84,7 +83,4 @@ const char *unknown_device_name(void);
 #define DMEVENTD_MONITOR_IGNORE -1
 int dmeventd_monitor_mode(void);
 
-#define NO_DEV_ERROR_COUNT_LIMIT 0
-int dev_disable_after_error_count(void);
-
 #endif


