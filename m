From: Takahiro Yasui <takahiro.yasui@hds.com>
Date: Mon, 28 Jun 2010 23:32:58 -0400
Subject: [RFC][PATCH] lvm2: limit accesses to broken devices
Message-ID: <5C30BE7ED8B03E448B2E104602D4848A59228864BB@USINDEVS02.corp.hds.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

This is a patch to limit the number of accesses to broken devices.


* Issues and solution

lvm commands accesses same devices repeatedly  even if they are
broken and read or write I/Os fail. For example, lvconvert command
accesses 70 times to a broken device. lvconvert is used to recover
a mirror volume when an error is reported, and unnecessary access
to broken devices might prolong a recovery time.

As a solution, this patch introduces a new configuration parameter,
devices/dev_max_error_count. The number of errors on a device is
counted and the device is desabled when the count reaches the value
specified by the parameter, devices/dev_max_error_count. If a value
(-1) is set to the parameter, no access control to a device is done.


* Effectiveness of this patch

This test result shows the number of accesses to a broken device
(8:48) when the parameter, devices/dev_max_error_count is set to 1.

- Environment
  # vgs
    VG   #PV #LV #SN Attr   VSize  VFree
    vg00   4   1   0 wz--n- 63.98G 63.95G
  # dmsetup ls --tree -o ascii
  vg00-lv00 (253:5)
   |-vg00-lv00_mimage_1 (253:2)
   |  `- (8:48)
   |-vg00-lv00_mimage_0 (253:1)
   |  `- (8:64)
   `-vg00-lv00_mlog (253:4)
      |-vg00-lv00_mlog_mimage_1 (253:3)
      |  `- (8:32)
      `-vg00-lv00_mlog_mimage_0 (253:0)
         `- (8:80)

- Result
  lvconvert --repair --use-policies vg00/lv00   70 times -> 1 time
  vgs                                            9 times -> 1 time
  lvs                                            7 times -> 1 time
  vgchange -an vg00                              7 times -> 1 time


Appreciate your review and comments.

Thanks,
Taka


Signed-off-by: Takahiro Yasui <takahiro.yasui@hds.com>
---
 doc/example.conf.in        |    5 +++++
 lib/commands/toolcontext.c |    5 +++++
 lib/device/dev-cache.c     |    3 +++
 lib/device/dev-io.c        |   34 ++++++++++++++++++++++++++++++++--
 lib/device/device.h        |    2 ++
 lib/misc/lvm-globals.c     |   11 +++++++++++
 lib/misc/lvm-globals.h     |    2 ++
 man/lvm.conf.5.in          |    5 +++++
 8 files changed, 65 insertions(+), 2 deletions(-)

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
+    # Set to -1 to disable the error number control.
+    dev_max_error_count = -1
 }
 
 # This section that allows you to configure the nature of the
Index: LVM2-2.02.68/lib/commands/toolcontext.c
===================================================================
--- LVM2-2.02.68.orig/lib/commands/toolcontext.c
+++ LVM2-2.02.68/lib/commands/toolcontext.c
@@ -603,6 +603,8 @@ static int _init_dev_cache(struct cmd_co
 		}
 	}
 
+	init_dev_max_error_count(
+		find_config_tree_int(cmd, "devices/dev_max_error_count", -1));
 
 	return 1;
 }
@@ -1166,6 +1168,9 @@ struct cmd_context *create_toolcontext(u
 
 	_init_logging(cmd);
 
+	init_dev_max_error_count(
+		find_config_tree_int(cmd, "devices/dev_max_error_count", -1));
+
 	if (!_init_hostname(cmd))
 		goto_out;
 
Index: LVM2-2.02.68/lib/device/dev-cache.c
===================================================================
--- LVM2-2.02.68.orig/lib/device/dev-cache.c
+++ LVM2-2.02.68/lib/device/dev-cache.c
@@ -104,6 +104,8 @@ struct device *dev_create_file(const cha
 	dev->dev = 0;
 	dev->fd = -1;
 	dev->open_count = 0;
+	dev->error_count = 0;
+	dev->max_error_count = -1;
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
Index: LVM2-2.02.68/lib/device/dev-io.c
===================================================================
--- LVM2-2.02.68.orig/lib/device/dev-io.c
+++ LVM2-2.02.68/lib/device/dev-io.c
@@ -595,18 +595,40 @@ void dev_close_all(void)
 	}
 }
 
+static inline int _dev_is_valid(struct device *dev)
+{
+	return (dev->max_error_count == -1 ||
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
+static int _dev_max_error_count = -1;
 
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
 
@@ -56,6 +57,7 @@ int ignore_suspended_devices(void);
 const char *log_command_name(void);
 unsigned is_static(void);
 int udev_checking(void);
+int dev_max_error_count(void);
 
 #define DMEVENTD_MONITOR_IGNORE -1
 int dmeventd_monitor_mode(void);
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
+being accessed repeatedly. If set to -1, no access control to devices is
+done.
 .TP
 \fBlog\fP \(em Default log settings
 .IP

-- 
Takahiro Yasui
Hitachi Data Systems


