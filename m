From: Takahiro Yasui <takahiro.yasui@hds.com>
Date: Tue, 29 Jun 2010 03:26:15 -0400
Subject: [RFC][PATCH] lvm2: limit accesses to broken devices (v2)
Message-ID: <5C30BE7ED8B03E448B2E104602D4848A59228864BC@USINDEVS02.corp.hds.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

This is a updated patch (v2) to limit accesses to broken devices.

* v2 changes:
  - reset error count whenever lvm command is executed
  - change default value from -1 to 0

Appreciate your review and comments.

Thanks,
Taka


Signed-off-by: Takahiro Yasui <takahiro.yasui@hds.com>
---
 doc/example.conf.in        |    5 +++++
 lib/commands/toolcontext.c |    4 ++++
 lib/config/defaults.h      |    2 ++
 lib/device/dev-cache.c     |   21 +++++++++++++++++++++
 lib/device/dev-cache.h     |    2 ++
 lib/device/dev-io.c        |   34 ++++++++++++++++++++++++++++++++--
 lib/device/device.h        |    2 ++
 lib/misc/lvm-globals.c     |   11 +++++++++++
 lib/misc/lvm-globals.h     |    4 ++++
 man/lvm.conf.5.in          |    5 +++++
 tools/lvmcmdline.c         |    3 +++
 11 files changed, 91 insertions(+), 2 deletions(-)

Index: LVM2-2.02.68/doc/example.conf.in
===================================================================
--- LVM2-2.02.68.orig/doc/example.conf.in
+++ LVM2-2.02.68/doc/example.conf.in
@@ -130,6 +130,11 @@ devices {
     # Set this to 1 to skip such devices.  This should only be needed
     # in recovery situations.
     ignore_suspended_devices = 0
+
+    # Maximum number of error counts per device before disabling the device.
+    # This option prevents a broken device from being accessed repeatedly.
+    # Set to 0 to disable the error number control.
+    dev_max_error_count = 0
 }
 
 # This section that allows you to configure the nature of the
Index: LVM2-2.02.68/lib/commands/toolcontext.c
===================================================================
--- LVM2-2.02.68.orig/lib/commands/toolcontext.c
+++ LVM2-2.02.68/lib/commands/toolcontext.c
@@ -558,6 +558,10 @@ static int _init_dev_cache(struct cmd_co
 	const struct config_node *cn;
 	struct config_value *cv;
 
+	init_dev_max_error_count(
+		find_config_tree_int(cmd, "devices/dev_max_error_count",
+				     DEFAULT_MAX_ERROR_COUNT));
+
 	if (!dev_cache_init(cmd))
 		return_0;
 
Index: LVM2-2.02.68/lib/config/defaults.h
===================================================================
--- LVM2-2.02.68.orig/lib/config/defaults.h
+++ LVM2-2.02.68/lib/config/defaults.h
@@ -109,6 +109,8 @@
 #  define DEFAULT_MAX_HISTORY 100
 #endif
 
+#define DEFAULT_MAX_ERROR_COUNT	NO_DEV_ERROR_COUNT_LIMIT
+
 #define DEFAULT_REP_ALIGNED 1
 #define DEFAULT_REP_BUFFERED 1
 #define DEFAULT_REP_COLUMNS_AS_ROWS 0
Index: LVM2-2.02.68/lib/device/dev-cache.c
===================================================================
--- LVM2-2.02.68.orig/lib/device/dev-cache.c
+++ LVM2-2.02.68/lib/device/dev-cache.c
@@ -104,6 +104,8 @@ struct device *dev_create_file(const cha
 	dev->dev = 0;
 	dev->fd = -1;
 	dev->open_count = 0;
+	dev->error_count = 0;
+	dev->max_error_count = NO_DEV_ERROR_COUNT_LIMIT;
 	dev->block_size = -1;
 	dev->read_ahead = -1;
 	memset(dev->pvid, 0, sizeof(dev->pvid));
@@ -125,6 +127,7 @@ static struct device *_dev_create(dev_t 
 	dev->dev = d;
 	dev->fd = -1;
 	dev->open_count = 0;
+	dev->max_error_count = dev_max_error_count();
 	dev->block_size = -1;
 	dev->read_ahead = -1;
 	dev->end = UINT64_C(0);
@@ -791,6 +794,24 @@ struct device *dev_iter_get(struct dev_i
 	return NULL;
 }
 
+int dev_reset_error_count(struct cmd_context *cmd)
+{
+	struct dev_iter *iter;
+	struct device *dev;
+
+	if (!(iter = dev_iter_create(cmd->filter, 0))) {
+		log_error("dev_iter_create failed");
+		return 0;
+	}
+
+	for (dev = dev_iter_get(iter); dev; dev = dev_iter_get(iter))
+		dev->error_count = 0;
+
+	dev_iter_destroy(iter);
+
+	return 1;
+}
+
 int dev_fd(struct device *dev)
 {
 	return dev->fd;
Index: LVM2-2.02.68/lib/device/dev-cache.h
===================================================================
--- LVM2-2.02.68.orig/lib/device/dev-cache.h
+++ LVM2-2.02.68/lib/device/dev-cache.h
@@ -52,4 +52,6 @@ struct dev_iter *dev_iter_create(struct 
 void dev_iter_destroy(struct dev_iter *iter);
 struct device *dev_iter_get(struct dev_iter *iter);
 
+int dev_reset_error_count(struct cmd_context *cmd);
+
 #endif
Index: LVM2-2.02.68/lib/device/dev-io.c
===================================================================
--- LVM2-2.02.68.orig/lib/device/dev-io.c
+++ LVM2-2.02.68/lib/device/dev-io.c
@@ -595,18 +595,40 @@ void dev_close_all(void)
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
+		log_warn("WARNING: Error counts exceeded limit of %d. "
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
@@ -662,17 +684,25 @@ int dev_append(struct device *dev, size_
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
Index: LVM2-2.02.68/lib/device/device.h
===================================================================
--- LVM2-2.02.68.orig/lib/device/device.h
+++ LVM2-2.02.68/lib/device/device.h
@@ -39,6 +39,8 @@ struct device {
 	/* private */
 	int fd;
 	int open_count;
+	int error_count;
+	int max_error_count;
 	int block_size;
 	int read_ahead;
 	uint32_t flags;
Index: LVM2-2.02.68/lib/misc/lvm-globals.c
===================================================================
--- LVM2-2.02.68.orig/lib/misc/lvm-globals.c
+++ LVM2-2.02.68/lib/misc/lvm-globals.c
@@ -40,6 +40,7 @@ static int _ignore_suspended_devices = 0
 static int _error_message_produced = 0;
 static unsigned _is_static = 0;
 static int _udev_checking = 1;
+static int _dev_max_error_count = DEFAULT_MAX_ERROR_COUNT;
 
 void init_verbose(int level)
 {
@@ -121,6 +122,11 @@ void init_udev_checking(int checking)
 		log_debug("LVM udev checking disabled");
 }
 
+void init_dev_max_error_count(int value)
+{
+	_dev_max_error_count = value;
+}
+
 void set_cmd_name(const char *cmd)
 {
 	strncpy(_cmd_name, cmd, sizeof(_cmd_name));
@@ -224,3 +230,8 @@ int udev_checking(void)
 {
 	return _udev_checking;
 }
+
+int dev_max_error_count(void)
+{
+	return _dev_max_error_count;
+}
Index: LVM2-2.02.68/lib/misc/lvm-globals.h
===================================================================
--- LVM2-2.02.68.orig/lib/misc/lvm-globals.h
+++ LVM2-2.02.68/lib/misc/lvm-globals.h
@@ -37,6 +37,7 @@ void init_ignore_suspended_devices(int i
 void init_error_message_produced(int produced);
 void init_is_static(unsigned value);
 void init_udev_checking(int checking);
+void init_dev_max_error_count(int value);
 
 void set_cmd_name(const char *cmd_name);
 
@@ -56,8 +57,11 @@ int ignore_suspended_devices(void);
 const char *log_command_name(void);
 unsigned is_static(void);
 int udev_checking(void);
+int dev_max_error_count(void);
 
 #define DMEVENTD_MONITOR_IGNORE -1
 int dmeventd_monitor_mode(void);
 
+#define NO_DEV_ERROR_COUNT_LIMIT 0
+
 #endif
Index: LVM2-2.02.68/man/lvm.conf.5.in
===================================================================
--- LVM2-2.02.68.orig/man/lvm.conf.5.in
+++ LVM2-2.02.68/man/lvm.conf.5.in
@@ -165,6 +165,11 @@ use \fBpvs -o +pe_start\fP .  It will be
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
Index: LVM2-2.02.68/tools/lvmcmdline.c
===================================================================
--- LVM2-2.02.68.orig/tools/lvmcmdline.c
+++ LVM2-2.02.68/tools/lvmcmdline.c
@@ -1020,6 +1020,9 @@ int lvm_run_command(struct cmd_context *
 			goto_out;
 		}
 
+	if (!dev_reset_error_count(cmd))
+		goto_out;
+
 	if (arg_count(cmd, config_ARG) || !cmd->config_valid || config_files_changed(cmd)) {
 		/* Reinitialise various settings inc. logging, filters */
 		if (!refresh_toolcontext(cmd)) {

-- 
Takahiro Yasui
Hitachi Data Systems


