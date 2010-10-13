From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 13 Oct 2010 15:40:42 -0000
Subject: LVM2 doc/example.conf.in lib/commands/toolcont ...
Message-ID: <20101013154042.16590.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-10-13 15:40:39

Modified files:
	doc            : example.conf.in 
	lib/commands   : toolcontext.c 
	lib/config     : defaults.h 
	lib/device     : dev-cache.c dev-cache.h dev-io.c device.h 
	lib/locking    : locking.c 
	lib/misc       : lvm-globals.c lvm-globals.h 
	man            : lvm.conf.5.in 

Log message:
	Limit repeated accesses to broken devices.
	
	Signed-off-by: Takahiro Yasui <takahiro.yasui@hds.com>
	Reviewed-by: Petr Rockai <prockai@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/example.conf.in.diff?cvsroot=lvm2&r1=1.11&r2=1.12
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.105&r2=1.106
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/defaults.h.diff?cvsroot=lvm2&r1=1.68&r2=1.69
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-cache.c.diff?cvsroot=lvm2&r1=1.59&r2=1.60
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-cache.h.diff?cvsroot=lvm2&r1=1.12&r2=1.13
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-io.c.diff?cvsroot=lvm2&r1=1.71&r2=1.72
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/device.h.diff?cvsroot=lvm2&r1=1.45&r2=1.46
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.c.diff?cvsroot=lvm2&r1=1.85&r2=1.86
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-globals.c.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-globals.h.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvm.conf.5.in.diff?cvsroot=lvm2&r1=1.13&r2=1.14

--- LVM2/doc/example.conf.in	2010/08/25 13:06:03	1.11
+++ LVM2/doc/example.conf.in	2010/10/13 15:40:38	1.12
@@ -136,6 +136,11 @@
     # in recovery situations.
     ignore_suspended_devices = 0
 
+    # During each LVM operation any errors received from a device are counted.
+    # If this counter exceeds the number here, no further I/O is sent to the
+    # device.
+    disable_after_error_count = 0
+
     # Allow use of pvcreate --uuid without requiring --restorefile.
     require_restorefile_with_uuid = 1
 }
--- LVM2/lib/commands/toolcontext.c	2010/09/30 21:06:51	1.105
+++ LVM2/lib/commands/toolcontext.c	2010/10/13 15:40:38	1.106
@@ -560,6 +560,10 @@
 	const struct config_node *cn;
 	struct config_value *cv;
 
+	init_dev_disable_after_error_count(
+		find_config_tree_int(cmd, "devices/disable_after_error_count",
+				     DEFAULT_DISABLE_AFTER_ERROR_COUNT));
+
 	if (!dev_cache_init(cmd))
 		return_0;
 
--- LVM2/lib/config/defaults.h	2010/08/20 22:24:59	1.68
+++ LVM2/lib/config/defaults.h	2010/10/13 15:40:39	1.69
@@ -33,6 +33,7 @@
 #define DEFAULT_MD_COMPONENT_DETECTION 1
 #define DEFAULT_MD_CHUNK_ALIGNMENT 1
 #define DEFAULT_IGNORE_SUSPENDED_DEVICES 1
+#define DEFAULT_DISABLE_AFTER_ERROR_COUNT 0
 #define DEFAULT_REQUIRE_RESTOREFILE_WITH_UUID 1
 #define DEFAULT_DATA_ALIGNMENT_OFFSET_DETECTION 1
 #define DEFAULT_DATA_ALIGNMENT_DETECTION 1
@@ -117,6 +118,8 @@
 #  define DEFAULT_MAX_HISTORY 100
 #endif
 
+#define DEFAULT_MAX_ERROR_COUNT	NO_DEV_ERROR_COUNT_LIMIT
+
 #define DEFAULT_REP_ALIGNED 1
 #define DEFAULT_REP_BUFFERED 1
 #define DEFAULT_REP_COLUMNS_AS_ROWS 0
--- LVM2/lib/device/dev-cache.c	2010/09/22 01:36:14	1.59
+++ LVM2/lib/device/dev-cache.c	2010/10/13 15:40:39	1.60
@@ -104,6 +104,8 @@
 	dev->dev = 0;
 	dev->fd = -1;
 	dev->open_count = 0;
+	dev->error_count = 0;
+	dev->max_error_count = NO_DEV_ERROR_COUNT_LIMIT;
 	dev->block_size = -1;
 	dev->read_ahead = -1;
 	memset(dev->pvid, 0, sizeof(dev->pvid));
@@ -125,6 +127,7 @@
 	dev->dev = d;
 	dev->fd = -1;
 	dev->open_count = 0;
+	dev->max_error_count = dev_disable_after_error_count();
 	dev->block_size = -1;
 	dev->read_ahead = -1;
 	dev->end = UINT64_C(0);
@@ -845,6 +848,22 @@
 	return NULL;
 }
 
+void dev_reset_error_count(struct cmd_context *cmd)
+{
+	struct dev_iter *iter;
+	struct device *dev;
+
+	if (!(iter = dev_iter_create(cmd->filter, 0))) {
+		log_error("Resetting device error count failed");
+		return;
+	}
+
+	for (dev = dev_iter_get(iter); dev; dev = dev_iter_get(iter))
+		dev->error_count = 0;
+
+	dev_iter_destroy(iter);
+}
+
 int dev_fd(struct device *dev)
 {
 	return dev->fd;
--- LVM2/lib/device/dev-cache.h	2010/09/22 01:36:14	1.12
+++ LVM2/lib/device/dev-cache.h	2010/10/13 15:40:39	1.13
@@ -53,4 +53,6 @@
 void dev_iter_destroy(struct dev_iter *iter);
 struct device *dev_iter_get(struct dev_iter *iter);
 
+void dev_reset_error_count(struct cmd_context *cmd);
+
 #endif
--- LVM2/lib/device/dev-io.c	2010/09/27 19:15:13	1.71
+++ LVM2/lib/device/dev-io.c	2010/10/13 15:40:39	1.72
@@ -603,18 +603,40 @@
 	}
 }
 
+static inline int _dev_is_valid(struct device *dev)
+{
+	return (dev->max_error_count == NO_DEV_ERROR_COUNT_LIMIT ||
+		dev->error_count < dev->max_error_count);
+}
+
+static void _dev_inc_error_count(struct device *dev)
+{
+	if (++dev->error_count == dev->max_error_count)
+		log_warn("WARNING: Error counts reached a limit of %d. "
+			 "Device %s was disabled",
+			 dev->max_error_count, dev_name(dev));
+}
+
 int dev_read(struct device *dev, uint64_t offset, size_t len, void *buffer)
 {
 	struct device_area where;
+	int ret;
 
 	if (!dev->open_count)
 		return_0;
 
+	if (!_dev_is_valid(dev))
+		return 0;
+
 	where.dev = dev;
 	where.start = offset;
 	where.size = len;
 
-	return _aligned_io(&where, buffer, 0);
+	ret = _aligned_io(&where, buffer, 0);
+	if (!ret)
+		_dev_inc_error_count(dev);
+
+	return ret;
 }
 
 /*
@@ -670,17 +692,25 @@
 int dev_write(struct device *dev, uint64_t offset, size_t len, void *buffer)
 {
 	struct device_area where;
+	int ret;
 
 	if (!dev->open_count)
 		return_0;
 
+	if (!_dev_is_valid(dev))
+		return 0;
+
 	where.dev = dev;
 	where.start = offset;
 	where.size = len;
 
 	dev->flags |= DEV_ACCESSED_W;
 
-	return _aligned_io(&where, buffer, 1);
+	ret = _aligned_io(&where, buffer, 1);
+	if (!ret)
+		_dev_inc_error_count(dev);
+
+	return ret;
 }
 
 int dev_set(struct device *dev, uint64_t offset, size_t len, int value)
--- LVM2/lib/device/device.h	2010/08/19 23:08:18	1.45
+++ LVM2/lib/device/device.h	2010/10/13 15:40:39	1.46
@@ -39,6 +39,8 @@
 	/* private */
 	int fd;
 	int open_count;
+	int error_count;
+	int max_error_count;
 	int block_size;
 	int read_ahead;
 	uint32_t flags;
--- LVM2/lib/locking/locking.c	2010/07/09 15:34:45	1.85
+++ LVM2/lib/locking/locking.c	2010/10/13 15:40:39	1.86
@@ -382,6 +382,7 @@
 			else
 				lvmcache_lock_vgname(resource, (flags & LCK_TYPE_MASK)
 								== LCK_READ);
+			dev_reset_error_count(cmd);
 		}
 
 		_update_vg_lock_count(resource, flags);
--- LVM2/lib/misc/lvm-globals.c	2010/08/11 12:14:24	1.6
+++ LVM2/lib/misc/lvm-globals.c	2010/10/13 15:40:39	1.7
@@ -41,6 +41,7 @@
 static unsigned _is_static = 0;
 static int _udev_checking = 1;
 static char _sysfs_dir_path[PATH_MAX] = "";
+static int _dev_disable_after_error_count = DEFAULT_DISABLE_AFTER_ERROR_COUNT;
 
 void init_verbose(int level)
 {
@@ -122,6 +123,11 @@
 		log_debug("LVM udev checking disabled");
 }
 
+void init_dev_disable_after_error_count(int value)
+{
+	_dev_disable_after_error_count = value;
+}
+
 void set_cmd_name(const char *cmd)
 {
 	strncpy(_cmd_name, cmd, sizeof(_cmd_name));
@@ -236,3 +242,8 @@
 {
 	return _sysfs_dir_path;
 }
+
+int dev_disable_after_error_count(void)
+{
+	return _dev_disable_after_error_count;
+}
--- LVM2/lib/misc/lvm-globals.h	2010/08/11 12:14:24	1.7
+++ LVM2/lib/misc/lvm-globals.h	2010/10/13 15:40:39	1.8
@@ -37,6 +37,7 @@
 void init_error_message_produced(int produced);
 void init_is_static(unsigned value);
 void init_udev_checking(int checking);
+void init_dev_disable_after_error_count(int value);
 
 void set_cmd_name(const char *cmd_name);
 void set_sysfs_dir_path(const char *path);
@@ -62,4 +63,7 @@
 #define DMEVENTD_MONITOR_IGNORE -1
 int dmeventd_monitor_mode(void);
 
+#define NO_DEV_ERROR_COUNT_LIMIT 0
+int dev_disable_after_error_count(void);
+
 #endif
--- LVM2/man/lvm.conf.5.in	2010/07/13 15:04:23	1.13
+++ LVM2/man/lvm.conf.5.in	2010/10/13 15:40:39	1.14
@@ -165,6 +165,11 @@
 \fBdata_alignment\fP plus the alignment_offset from
 \fBdata_alignment_offset_detection\fP (if enabled) or the pvcreate
 commandline.
+.IP
+\fBdev_max_error_count\fP \(em Maximum number of error counts per device
+before disabling devices. This option prevents a broken device from
+being accessed repeatedly. If set to 0, no access control to devices is
+done.
 .TP
 \fBlog\fP \(em Default log settings
 .IP


