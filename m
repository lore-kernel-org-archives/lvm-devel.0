From: Jonathan Brassow <jbrassow@redhat.com>
Date: Tue, 22 Oct 2013 18:39:41 -0500
Subject: [PATCH v2]: Mirror: Fix hangs and lock-ups caused by attempting label reads of mirrors
In-Reply-To: <1382394852.4860.4.camel@f16>
References: <1382394852.4860.4.camel@f16>
Message-ID: <1382485181.19061.3.camel@f16>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Changed some variable/function names and added more explanation to the
config file.

I will send a separate patch that contains a warning message if mirrors
are activated and 'ignore_lvm_mirrors' is not set... We can talk about
whether that is needed also.

 brassow

Mirror: Fix hangs and lock-ups caused by attempting label reads of mirrors

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
labels (i.e. whether PVs can be created on mirror LVs).  If the user
chooses to allow label scanning of mirror LVs, it will be at the expense
of a possible hang in I/O or LVM processes.
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
@@ -186,6 +186,35 @@ devices {
     # in recovery situations.
     ignore_suspended_devices = 0
 
+    # ignore_lvm_mirrors:  Introduced in version 2.02.104
+    # This setting determines whether logical volumes of "mirror" segment
+    # type are scanned for LVM labels.  This affects the ability of
+    # mirrors to be used as physical volumes.  If 'ignore_lvm_mirrors'
+    # is set to '1', it becomes impossible to create volume groups on top
+    # of mirror logical volumes - i.e. to stack volume groups on mirrors.
+    #
+    # Allowing mirror logical volumes to be scanned (setting the value to '0')
+    # can potentially cause LVM processes and I/O to the mirror to become
+    # blocked.  This is due to the way that the "mirror" segment type handles
+    # failures.  In order for the hang to manifest itself, an LVM command must
+    # be run just after a failure and before the automatic LVM repair process
+    # takes place OR there must be failures in multiple mirrors in the same
+    # volume group at the same time with write failures occurring moments
+    # before a scan of the mirror's labels.
+    #
+    # Note that these scanning limitations do not apply to the LVM RAID
+    # types, like "raid1".  The RAID segment types handle failures in a
+    # different way and are not subject to possible process or I/O blocking.
+    #
+    # It is encouraged that users set 'ignore_lvm_mirrors' to 1 if they
+    # are using the "mirror" segment type.  Users that require volume group
+    # stacking on mirrored logical volumes should consider using the "raid1"
+    # segment type.  The "raid1" segment type is not available for
+    # active/active clustered volume groups.
+    #
+    # Set to 1 to disallow stacking and thereby avoid a possible deadlock.
+    ignore_lvm_mirrors = 1
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
+			if (ignore_lvm_mirrors()) {
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
+static int _ignore_lvm_mirrors = DEFAULT_IGNORE_LVM_MIRRORS;
 static int _error_message_produced = 0;
 static unsigned _is_static = 0;
 static int _udev_checking = 1;
@@ -123,6 +124,11 @@ void init_ignore_suspended_devices(int i
 	_ignore_suspended_devices = ignore;
 }
 
+void init_ignore_lvm_mirrors(int scan)
+{
+	_ignore_lvm_mirrors = scan;
+}
+
 void init_cmd_name(int status)
 {
 	_log_cmd_name = status;
@@ -259,6 +265,11 @@ int ignore_suspended_devices(void)
 	return _ignore_suspended_devices;
 }
 
+int ignore_lvm_mirrors(void)
+{
+	return _ignore_lvm_mirrors;
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
+cfg(devices_ignore_lvm_mirrors_CFG, "ignore_lvm_mirrors", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_IGNORE_LVM_MIRRORS, vsn(2, 2, 104), NULL)
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
+#define DEFAULT_IGNORE_LVM_MIRRORS 1
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
+void init_ignore_lvm_mirrors(int scan);
 void init_error_message_produced(int produced);
 void init_is_static(unsigned value);
 void init_udev_checking(int checking);
@@ -66,6 +67,7 @@ int security_level(void);
 int mirror_in_sync(void);
 int background_polling(void);
 int ignore_suspended_devices(void);
+int ignore_lvm_mirrors(void);
 const char *log_command_name(void);
 unsigned is_static(void);
 int udev_checking(void);
Index: lvm2/lib/commands/toolcontext.c
===================================================================
--- lvm2.orig/lib/commands/toolcontext.c
+++ lvm2/lib/commands/toolcontext.c
@@ -905,6 +905,7 @@ static int _init_filters(struct cmd_cont
 		goto_bad;
 
 	init_ignore_suspended_devices(find_config_tree_bool(cmd, devices_ignore_suspended_devices_CFG, NULL));
+	init_ignore_lvm_mirrors(find_config_tree_bool(cmd, devices_ignore_lvm_mirrors_CFG, NULL));
 
 	/*
 	 * If 'cache_dir' or 'cache_file_prefix' is set, ignore 'cache'.



