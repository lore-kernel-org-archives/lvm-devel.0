From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 23 Jun 2010 17:00:33 -0000
Subject: LVM2 ./WHATS_NEW_DM udev/10-dm.rules.in
Message-ID: <20100623170033.21787.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2010-06-23 17:00:33

Modified files:
	.              : WHATS_NEW_DM 
	udev           : 10-dm.rules.in 

Log message:
	Fix udev rules to handle spurious events properly.
	
	We can use DM_UDEV_PRIMARY_SOURCE_FLAG to identify the spurious events
	and use it as an indication that the device has already been activated before
	(and hence we can find this property in udev database).
	
	WARNING: This change requires udev startup script to preserve udev database
	from initrd. All the information stored there during activation of devices
	is important for the initial "udevadm trigger --action=add" call that is
	used in udev startup script. If not done this way, udev startup script needs
	to define DM_UDEV_PRIMARY_SOURCE_FLAG=1 property for any ADD events it uses.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.379&r2=1.380
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/udev/10-dm.rules.in.diff?cvsroot=lvm2&r1=1.8&r2=1.9

--- LVM2/WHATS_NEW_DM	2010/06/16 13:01:25	1.379
+++ LVM2/WHATS_NEW_DM	2010/06/23 17:00:32	1.380
@@ -1,5 +1,6 @@
 Version 1.02.50 - 
 ===============================
+  Fix udev rules to handle spurious events properly.
   Allow use of devmapper header file in C++ mode.
 
 Version 1.02.49 - 4th June 2010
--- LVM2/udev/10-dm.rules.in	2010/04/28 13:37:37	1.8
+++ LVM2/udev/10-dm.rules.in	2010/06/23 17:00:32	1.9
@@ -19,13 +19,6 @@
 SUBSYSTEM!="block", GOTO="dm_end"
 KERNEL!="dm-[0-9]*", GOTO="dm_end"
 
-# There is a new change event generated in block layer since kernel
-# version 2.6.32. It adds notification for changes in read-only
-# attribute. We don't want to misinterpret the regular meaning of change
-# events for DM devices and we don't want to apply the rules prematurely,
-# therefore we disable them in this situation.
-ENV{DISK_RO}=="1", GOTO="dm_disable"
-
 # Set proper sbin path, /sbin has higher priority than /usr/sbin.
 ENV{DM_SBIN_PATH}="/sbin"
 TEST!="$env{DM_SBIN_PATH}/dmsetup", ENV{DM_SBIN_PATH}="/usr/sbin"
@@ -37,11 +30,16 @@
 # kernels >= 2.6.31 only.
 ENV{DM_COOKIE}=="?*", IMPORT{program}="$env{DM_SBIN_PATH}/dmsetup udevflags $env{DM_COOKIE}"
 
-# Normally, we would test for DM_UDEV_DISABLE_DM_RULES_FLAG here and skip
-# the rules if set. However, we need to set DM_* environment variables
-# for now to properly filter out inappropriate events. This dependency
-# might be removed in the future.
-
+# Device created, major and minor number assigned - "add" event generated.
+# Table loaded - no event generated.
+# Device resumed (or renamed) - "change" event generated.
+# Device removed - "remove" event generated.
+#
+# The dm-X nodes are always created, even on "add" event, we can't suppress
+# that (the node is created even earlier with devtmpfs). All the symlinks
+# (e.g. /dev/mapper) are created in right time after a device has its table
+# loaded and is properly resumed. For this reason, direct use of dm-X nodes
+# is not recommended.
 ACTION!="add|change", GOTO="dm_end"
 
 # There is no cookie set nor any flags encoded in events not originating
@@ -55,6 +53,7 @@
 IMPORT{db}="DM_UDEV_DISABLE_OTHER_RULES_FLAG"
 IMPORT{db}="DM_UDEV_LOW_PRIORITY_FLAG"
 IMPORT{db}="DM_UDEV_DISABLE_LIBRARY_FALLBACK_FLAG"
+IMPORT{db}="DM_UDEV_PRIMARY_SOURCE_FLAG"
 IMPORT{db}="DM_UDEV_FLAG7"
 IMPORT{db}="DM_SUBSYSTEM_UDEV_FLAG0"
 IMPORT{db}="DM_SUBSYSTEM_UDEV_FLAG1"
@@ -66,12 +65,19 @@
 IMPORT{db}="DM_SUBSYSTEM_UDEV_FLAG7"
 LABEL="dm_flags_done"
 
-# Normally, we operate on "change" events only. But when
-# coldplugging, there's an "add" event present. We have to
-# recognize this and do our actions in this particular
-# situation, too. Also, we don't want the nodes to be
-# created prematurely on "add" events while not coldplugging.
-ACTION=="add", ENV{STARTUP}!="1", NAME="", GOTO="dm_end"
+# Normally, we operate on "change" events. But when coldplugging, there's an
+# "add" event present. We have to recognize this and do our actions in this
+# particular situation, too. Also, we don't want the nodes to be created
+# prematurely on "add" events while not coldplugging. We check
+# DM_UDEV_PRIMARY_SOURCE_FLAG to see if the device was activated correctly
+# before and if not, we ignore the "add" event totally. This way we can support
+# udev triggers generating "add" events (e.g. "udevadm trigger --action=add" or
+# "echo add > /sys/block/<dm_device>/uevent"). The trigger with "add" event is
+# also used at boot to reevaluate udev rules for all existing devices activated
+# before (e.g. in initrd). If udev is used in initrd, we require the udev init
+# script to not remove the existing udev database so we can reuse the information
+# stored at the time of device activation in the initrd.
+ACTION=="add", ENV{DM_UDEV_PRIMARY_SOURCE_FLAG}!="1", GOTO="dm_disable"
 
 # "dm" sysfs subdirectory is available in newer versions of DM
 # only (kernels >= 2.6.29). We have to check for its existence


