From: Jonathan Brassow <jbrassow@redhat.com>
Date: Mon, 21 Oct 2013 17:34:12 -0500
Subject: [PATCH]: Mirror: Fix hangs and lock-ups caused by attempting label reads of mirrors
Message-ID: <1382394852.4860.4.camel@f16>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

agk,

The patch below is designed to address bug 1009700:
https://bugzilla.redhat.com/show_bug.cgi?id=1009700
It is the simplest way with the most flexibility for users that I could
think of to handle the problem outside of doing the asynchronous label
reads.

 brassow


There is a problem with the way mirrors have been designed to handle
failures that is resulting in stuck LVM processes and hung I/O.  When
mirrors encounter a write failure, they block I/O and notify userspace
to reconfigure the mirror to remove failed devices.  This process is
open to a couple races:
1) Any LVM process other than the one that is meant to deal with the
mirror failure can attempt to read the mirror, fail, and block other
LVM commands (including the repair command) from proceeding due to
holding a lock on the volume group.
2) If there are multiple mirrors that suffer a failure in the same
volume group, a repair can block while attempting to read the LVM
label from one mirror while trying to repair the other.

Mitigation of these races has been attempted by disallowing label reading
of mirrors that are either suspended or are indicated as blocking by
the kernel.  While this has closed the window of opportunity for hitting
the above problems considerably, it hasn't closed it completely.  This is
because it is still possible to start an LVM command, read the status of
the mirror as healthy, and then perform the read for the label at the
moment after a the failure is discovered by the kernel.

I can see two solutions to this problem:
1) Allow users to configure whether mirrors can be candidates for LVM
labels (i.e. whether PVs can be created on mirror LVs).  The default
will be to not allow this.  If the user chooses to allow label scanning
of mirror LVs, it will be at the expense of a possible hang in I/O or
LVM processes during a mirror failure.
2) Instrument a way to allow asynchronous label reading - allowing
blocked label reads to be ignored while continuing to process the LVM
command.  This would action would allow LVM commands to continue even
though they would have otherwise blocked trying to read a mirror.  They
can then release their lock and allow a repair command to commence.  In
the event of #2 above, the repair command already in progress can continue
and repair the failed mirror.

This patch brings solution #1.  If solution #2 is developed later on, the
configuration option created in #1 can be negated - allowing mirrors to
be scanned for labels by default once again.

Index: lvm2/conf/example.conf.in
===================================================================
--- lvm2.orig/conf/example.conf.in
+++ lvm2/conf/example.conf.in
@@ -186,6 +186,15 @@ devices {
     # in recovery situations.
     ignore_suspended_devices = 0
 
+    # By default, LVM2 will ignore logical volumes of "mirror" segment
+    # types.  This means they will not be able to be used as physical
+    # volumes for a higher ("stacked") volume group.  This is done because
+    # of the possibility of reading a mirror logical volume during a device
+    # failure and blocking indefinitely on it.  This is a design limitation
+    # of the "mirror" segment type that does not affect the LVM RAID types,
+    # including "raid1".
+    lvm_mirror_scanning = 0
+
     # During each LVM operation errors received from each device are counted.
     # If the counter of a particular device exceeds the limit set here, no
     # further I/O is sent to that device for the remainder of the respective
Index: lvm2/lib/activate/dev_manager.c
===================================================================
--- lvm2.orig/lib/activate/dev_manager.c
+++ lvm2/lib/activate/dev_manager.c
@@ -397,11 +397,17 @@ static int _device_is_usable(struct devi
 		next = dm_get_next_target(dmt, next, &start, &length,
 					  &target_type, &params);
 
-		if (target_type && !strcmp(target_type, "mirror") &&
-		    !_ignore_blocked_mirror_devices(dev, start, length, params)) {
-			log_debug_activation("%s: Mirror device %s not usable.",
-					     dev_name(dev), name);
-			goto out;
+		if (target_type && !strcmp(target_type, "mirror")) {
+			if (!lvm_mirror_scanning()) {
+				log_debug_activation("%s: Scanning mirror devices is disabled.", dev_name(dev));
+				goto out;
+			}
+			if (!_ignore_blocked_mirror_devices(dev, start,
+							    length, params)) {
+				log_debug_activation("%s: Mirror device %s not usable.",
+						     dev_name(dev), name);
+				goto out;
+			}
 		}
 
 		/*
Index: lvm2/lib/misc/lvm-globals.c
===================================================================
--- lvm2.orig/lib/misc/lvm-globals.c
+++ lvm2/lib/misc/lvm-globals.c
@@ -40,6 +40,7 @@ static int _mirror_in_sync = 0;
 static int _dmeventd_monitor = DEFAULT_DMEVENTD_MONITOR;
 static int _background_polling = DEFAULT_BACKGROUND_POLLING;
 static int _ignore_suspended_devices = 0;
+static int _lvm_mirror_scanning = DEFAULT_LVM_MIRROR_SCANNING;
 static int _error_message_produced = 0;
 static unsigned _is_static = 0;
 static int _udev_checking = 1;
@@ -123,6 +124,11 @@ void init_ignore_suspended_devices(int i
 	_ignore_suspended_devices = ignore;
 }
 
+void init_lvm_mirror_scanning(int scan)
+{
+	_lvm_mirror_scanning = scan;
+}
+
 void init_cmd_name(int status)
 {
 	_log_cmd_name = status;
@@ -259,6 +265,11 @@ int ignore_suspended_devices(void)
 	return _ignore_suspended_devices;
 }
 
+int lvm_mirror_scanning(void)
+{
+	return _lvm_mirror_scanning;
+}
+
 void init_debug(int level)
 {
 	_debug_level = level;
Index: lvm2/lib/config/config_settings.h
===================================================================
--- lvm2.orig/lib/config/config_settings.h
+++ lvm2/lib/config/config_settings.h
@@ -96,6 +96,7 @@ cfg(devices_data_alignment_detection_CFG
 cfg(devices_data_alignment_CFG, "data_alignment", devices_CFG_SECTION, 0, CFG_TYPE_INT, 0, vsn(2, 2, 45), NULL)
 cfg(devices_data_alignment_offset_detection_CFG, "data_alignment_offset_detection", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_DATA_ALIGNMENT_OFFSET_DETECTION, vsn(2, 2, 50), NULL)
 cfg(devices_ignore_suspended_devices_CFG, "ignore_suspended_devices", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_IGNORE_SUSPENDED_DEVICES, vsn(1, 2, 19), NULL)
+cfg(lvm_mirror_scanning_CFG, "lvm_mirror_scanning", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_LVM_MIRROR_SCANNING, vsn(2, 2, 104), NULL)
 cfg(devices_disable_after_error_count_CFG, "disable_after_error_count", devices_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_DISABLE_AFTER_ERROR_COUNT, vsn(2, 2, 75), NULL)
 cfg(devices_require_restorefile_with_uuid_CFG, "require_restorefile_with_uuid", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_REQUIRE_RESTOREFILE_WITH_UUID, vsn(2, 2, 73), NULL)
 cfg(devices_pv_min_size_CFG, "pv_min_size", devices_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_PV_MIN_SIZE_KB, vsn(2, 2, 85), NULL)
Index: lvm2/lib/config/defaults.h
===================================================================
--- lvm2.orig/lib/config/defaults.h
+++ lvm2/lib/config/defaults.h
@@ -33,6 +33,7 @@
 #define DEFAULT_SYSFS_SCAN 1
 #define DEFAULT_MD_COMPONENT_DETECTION 1
 #define DEFAULT_MD_CHUNK_ALIGNMENT 1
+#define DEFAULT_LVM_MIRROR_SCANNING 0
 #define DEFAULT_MULTIPATH_COMPONENT_DETECTION 1
 #define DEFAULT_IGNORE_SUSPENDED_DEVICES 1
 #define DEFAULT_DISABLE_AFTER_ERROR_COUNT 0
Index: lvm2/lib/misc/lvm-globals.h
===================================================================
--- lvm2.orig/lib/misc/lvm-globals.h
+++ lvm2/lib/misc/lvm-globals.h
@@ -38,6 +38,7 @@ void init_mirror_in_sync(int in_sync);
 void init_dmeventd_monitor(int reg);
 void init_background_polling(int polling);
 void init_ignore_suspended_devices(int ignore);
+void init_lvm_mirror_scanning(int scan);
 void init_error_message_produced(int produced);
 void init_is_static(unsigned value);
 void init_udev_checking(int checking);
@@ -66,6 +67,7 @@ int security_level(void);
 int mirror_in_sync(void);
 int background_polling(void);
 int ignore_suspended_devices(void);
+int lvm_mirror_scanning(void);
 const char *log_command_name(void);
 unsigned is_static(void);
 int udev_checking(void);



