From: Peter Rajnoha <prajnoha@redhat.com>
Date: Thu, 14 Jun 2012 14:47:23 +0200
Subject: [PATCH] Remove binary path detection from udev rules.
Message-ID: <4FD9DD5B.3030409@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This detection was distro specific and it really shouldn't be there
in upstream. Binary paths should not differ in various environments
(for example as it was with the anaconda installer, luckily, this is
now not the case anymore). I hope there are no such other remnants
anywhere else and if yes, it should be fixed as soon as possible.

Use @sbindir@ from configure instead.
---
 configure.in                  |    4 ++++
 udev/10-dm.rules.in           |   11 +++--------
 udev/11-dm-lvm.rules          |    2 +-
 udev/11-dm-lvm.rules.in       |   37 +++++++++++++++++++++++++++++++++++++
 udev/69-dm-lvm-metad.rules    |   30 ------------------------------
 udev/69-dm-lvm-metad.rules.in |   25 +++++++++++++++++++++++++
 udev/95-dm-notify.rules       |    2 +-
 udev/95-dm-notify.rules.in    |   12 ++++++++++++
 udev/Makefile.in              |   13 +++++++------
 9 files changed, 90 insertions(+), 46 deletions(-)
 create mode 100644 udev/11-dm-lvm.rules.in
 delete mode 100644 udev/69-dm-lvm-metad.rules
 create mode 100644 udev/69-dm-lvm-metad.rules.in
 create mode 100644 udev/95-dm-notify.rules.in

diff --git a/configure.in b/configure.in
index 7e2bb10..91687f1 100644
--- a/configure.in
+++ b/configure.in
@@ -1593,6 +1593,10 @@ test/api/Makefile
 test/unit/Makefile
 tools/Makefile
 udev/Makefile
+udev/10-dm.rules
+udev/11-dm-lvm.rules
+udev/69-dm-lvm-metad.rules
+udev/95-dm-notify.rules
 unit-tests/datastruct/Makefile
 unit-tests/regex/Makefile
 unit-tests/mm/Makefile
diff --git a/udev/10-dm.rules.in b/udev/10-dm.rules.in
index 605e088..70c1fca 100644
--- a/udev/10-dm.rules.in
+++ b/udev/10-dm.rules.in
@@ -19,11 +19,6 @@ KERNEL=="device-mapper", NAME="(DM_DIR)/control"
 SUBSYSTEM!="block", GOTO="dm_end"
 KERNEL!="dm-[0-9]*", GOTO="dm_end"
 
-# Set proper sbin path, /sbin has higher priority than /usr/sbin.
-ENV{DM_SBIN_PATH}="/sbin"
-TEST!="$env{DM_SBIN_PATH}/dmsetup", ENV{DM_SBIN_PATH}="/usr/sbin"
-TEST!="$env{DM_SBIN_PATH}/dmsetup", GOTO="dm_end"
-
 # Device created, major and minor number assigned - "add" event generated.
 # Table loaded - no event generated.
 # Device resumed (or renamed) - "change" event generated.
@@ -40,7 +35,7 @@ ACTION!="add|change", GOTO="dm_end"
 # These flags are encoded in DM_COOKIE variable that was introduced in
 # kernel version 2.6.31. Therefore, we can use this feature with
 # kernels >= 2.6.31 only. Cookie is not decoded for remove event.
-ENV{DM_COOKIE}=="?*", IMPORT{program}="$env{DM_SBIN_PATH}/dmsetup udevflags $env{DM_COOKIE}"
+ENV{DM_COOKIE}=="?*", IMPORT{program}="@sbindir@/dmsetup udevflags $env{DM_COOKIE}"
 
 # Rule out easy-to-detect inappropriate events first.
 ENV{DISK_RO}=="1", GOTO="dm_disable"
@@ -91,8 +86,8 @@ ACTION=="add", ENV{DM_UDEV_RULES_VSN}!="1", ENV{DM_UDEV_PRIMARY_SOURCE_FLAG}!="1
 # so we also have to call dmsetup if the kernel version used
 # is in between these releases.
 TEST=="dm", ENV{DM_NAME}="$attr{dm/name}", ENV{DM_UUID}="$attr{dm/uuid}", ENV{DM_SUSPENDED}="$attr{dm/suspended}"
-TEST!="dm", IMPORT{program}="$env{DM_SBIN_PATH}/dmsetup info -j %M -m %m -c --nameprefixes --noheadings --rows -o name,uuid,suspended"
-ENV{DM_SUSPENDED}!="?*", IMPORT{program}="$env{DM_SBIN_PATH}/dmsetup info -j %M -m %m -c --nameprefixes --noheadings --rows -o suspended"
+TEST!="dm", IMPORT{program}="@sbindir@/dmsetup info -j %M -m %m -c --nameprefixes --noheadings --rows -o name,uuid,suspended"
+ENV{DM_SUSPENDED}!="?*", IMPORT{program}="@sbindir@/dmsetup info -j %M -m %m -c --nameprefixes --noheadings --rows -o suspended"
 
 # dmsetup tool provides suspended state information in textual
 # form with values "Suspended"/"Active". We translate it to
diff --git a/udev/11-dm-lvm.rules b/udev/11-dm-lvm.rules
index 8244464..2f2cd14 100644
--- a/udev/11-dm-lvm.rules
+++ b/udev/11-dm-lvm.rules
@@ -18,7 +18,7 @@ ENV{DM_UDEV_RULES_VSN}!="?*", GOTO="lvm_end"
 ENV{DM_UUID}!="LVM-?*", GOTO="lvm_end"
 
 # Use DM name and split it up into its VG/LV/layer constituents.
-IMPORT{program}="$env{DM_SBIN_PATH}/dmsetup splitname --nameprefixes --noheadings --rows $env{DM_NAME}"
+IMPORT{program}="/sbin/dmsetup splitname --nameprefixes --noheadings --rows $env{DM_NAME}"
 
 ENV{DM_UDEV_DISABLE_SUBSYSTEM_RULES_FLAG}=="1", GOTO="lvm_end"
 
diff --git a/udev/11-dm-lvm.rules.in b/udev/11-dm-lvm.rules.in
new file mode 100644
index 0000000..06feaee
--- /dev/null
+++ b/udev/11-dm-lvm.rules.in
@@ -0,0 +1,37 @@
+# Copyright (C) 2009 Red Hat, Inc. All rights reserved.
+#
+# This file is part of LVM2.
+
+# Udev rules for LVM.
+#
+# These rules create symlinks for LVM logical volumes in
+# /dev/VG directory (VG is an actual VG name). Some udev
+# environment variables are set (they can be used in later
+# rules as well):
+#   DM_LV_NAME - logical volume name
+#   DM_VG_NAME - volume group name
+#   DM_LV_LAYER - logical volume layer (blank if not set)
+
+# "add" event is processed on coldplug only!
+ACTION!="add|change", GOTO="lvm_end"
+ENV{DM_UDEV_RULES_VSN}!="?*", GOTO="lvm_end"
+ENV{DM_UUID}!="LVM-?*", GOTO="lvm_end"
+
+# Use DM name and split it up into its VG/LV/layer constituents.
+IMPORT{program}="@sbindir@/dmsetup splitname --nameprefixes --noheadings --rows $env{DM_NAME}"
+
+ENV{DM_UDEV_DISABLE_SUBSYSTEM_RULES_FLAG}=="1", GOTO="lvm_end"
+
+# Do not create symlinks for inappropriate subdevices.
+ENV{DM_LV_NAME}=="pvmove?*|?*_vorigin", GOTO="lvm_disable"
+ENV{DM_LV_LAYER}=="?*", GOTO="lvm_disable"
+
+# Create symlinks for top-level devices only.
+ENV{DM_VG_NAME}=="?*", ENV{DM_LV_NAME}=="?*", SYMLINK+="$env{DM_VG_NAME}/$env{DM_LV_NAME}", GOTO="lvm_end"
+
+LABEL="lvm_disable"
+ENV{DM_UDEV_DISABLE_DISK_RULES_FLAG}="1"
+ENV{DM_UDEV_DISABLE_OTHER_RULES_FLAG}="1"
+OPTIONS:="nowatch"
+
+LABEL="lvm_end"
diff --git a/udev/69-dm-lvm-metad.rules b/udev/69-dm-lvm-metad.rules
deleted file mode 100644
index d272e6e..0000000
--- a/udev/69-dm-lvm-metad.rules
+++ /dev/null
@@ -1,30 +0,0 @@
-# Copyright (C) 2012 Red Hat, Inc. All rights reserved.
-#
-# This file is part of LVM2.
-
-# Udev rules for LVM.
-#
-# Scan all block devices having a PV label for LVM metadata.
-# Store this information in LVMetaD (the LVM metadata daemon) and maintain LVM
-# metadata state for improved performance by avoiding further scans while
-# running subsequent LVM commands or while using lvm2app library.
-# Also, notify LVMetaD about any relevant block device removal.
-#
-# This rule is essential for having the information in LVMetaD up-to-date.
-# It also requires blkid to be called on block devices before so only devices
-# used as LVM PVs are processed (ID_FS_TYPE="LVM2_member" or "LVM1_member").
-
-SUBSYSTEM!="block", GOTO="lvm_end"
-
-# Device-mapper devices are processed only on change event or on supported synthesized event.
-KERNEL=="dm-[0-9]*", ENV{DM_UDEV_RULES_VSN}!="?*", GOTO="lvm_end"
-
-# Set proper sbin path, /sbin has higher priority than /usr/sbin.
-ENV{LVM_SBIN_PATH}="/sbin"
-TEST!="$env{LVM_SBIN_PATH}/lvm", ENV{LVM_SBIN_PATH}="/usr/sbin"
-TEST!="$env{LVM_SBIN_PATH}/lvm", GOTO="lvm_end"
-
-# Only process devices already marked as a PV - this requires blkid to be called before.
-ENV{ID_FS_TYPE}=="LVM2_member|LVM1_member", RUN+="$env{LVM_SBIN_PATH}/lvm pvscan --cache --major $major --minor $minor"
-
-LABEL="lvm_end"
diff --git a/udev/69-dm-lvm-metad.rules.in b/udev/69-dm-lvm-metad.rules.in
new file mode 100644
index 0000000..393c0e0
--- /dev/null
+++ b/udev/69-dm-lvm-metad.rules.in
@@ -0,0 +1,25 @@
+# Copyright (C) 2012 Red Hat, Inc. All rights reserved.
+#
+# This file is part of LVM2.
+
+# Udev rules for LVM.
+#
+# Scan all block devices having a PV label for LVM metadata.
+# Store this information in LVMetaD (the LVM metadata daemon) and maintain LVM
+# metadata state for improved performance by avoiding further scans while
+# running subsequent LVM commands or while using lvm2app library.
+# Also, notify LVMetaD about any relevant block device removal.
+#
+# This rule is essential for having the information in LVMetaD up-to-date.
+# It also requires blkid to be called on block devices before so only devices
+# used as LVM PVs are processed (ID_FS_TYPE="LVM2_member" or "LVM1_member").
+
+SUBSYSTEM!="block", GOTO="lvm_end"
+
+# Device-mapper devices are processed only on change event or on supported synthesized event.
+KERNEL=="dm-[0-9]*", ENV{DM_UDEV_RULES_VSN}!="?*", GOTO="lvm_end"
+
+# Only process devices already marked as a PV - this requires blkid to be called before.
+ENV{ID_FS_TYPE}=="LVM2_member|LVM1_member", RUN+="@sbindir@/lvm pvscan --cache --major $major --minor $minor"
+
+LABEL="lvm_end"
diff --git a/udev/95-dm-notify.rules b/udev/95-dm-notify.rules
index 72cc609..d22abba 100644
--- a/udev/95-dm-notify.rules
+++ b/udev/95-dm-notify.rules
@@ -9,4 +9,4 @@
 # a cookie value sent within "change" and "remove" events (the cookie
 # value is set before by that process for every action requested).
 
-ENV{DM_COOKIE}=="?*", RUN+="$env{DM_SBIN_PATH}/dmsetup udevcomplete $env{DM_COOKIE}"
+ENV{DM_COOKIE}=="?*", RUN+="/sbin/dmsetup udevcomplete $env{DM_COOKIE}"
diff --git a/udev/95-dm-notify.rules.in b/udev/95-dm-notify.rules.in
new file mode 100644
index 0000000..8a2f94d
--- /dev/null
+++ b/udev/95-dm-notify.rules.in
@@ -0,0 +1,12 @@
+# Copyright (C) 2009 Red Hat, Inc. All rights reserved.
+#
+# This file is part of LVM2.
+
+# Udev rules for device-mapper devices.
+#
+# These rules are responsible for sending a notification to a process
+# waiting for completion of udev rules. The process is identified by
+# a cookie value sent within "change" and "remove" events (the cookie
+# value is set before by that process for every action requested).
+
+ENV{DM_COOKIE}=="?*", RUN+="@sbindir@/dmsetup udevcomplete $env{DM_COOKIE}"
diff --git a/udev/Makefile.in b/udev/Makefile.in
index 4ace910..9700d43 100644
--- a/udev/Makefile.in
+++ b/udev/Makefile.in
@@ -19,17 +19,18 @@ DM_RULES=10-dm.rules 13-dm-disk.rules 95-dm-notify.rules
 LVM_RULES=11-dm-lvm.rules
 DM_DIR=$(shell grep "\#define DM_DIR" $(top_srcdir)/libdm/misc/dm-ioctl.h | awk '{print $$3}')
 
-ifeq ("@BUILD_LVMETAD@", "yes")
-LVM_RULES+=69-dm-lvm-metad.rules
-endif
-
 ifeq ("@UDEV_HAS_BUILTIN_BLKID@", "yes")
 	BLKID_RULE=IMPORT{builtin}=\"blkid\"
 else
-	BLKID_RULE=IMPORT{program}=\"\$$env{DM_SBIN_PATH}\/blkid -o udev -p \$$tempnode\"
+	BLKID_RULE=IMPORT{program}=\"\\@sbindir@\/blkid -o udev -p \$$tempnode\"
 endif
 
-CLEAN_TARGETS = 10-dm.rules 13-dm-disk.rules
+CLEAN_TARGETS = 10-dm.rules 11-dm-lvm.rules 13-dm-disk.rules 95-dm-notify.rules
+
+ifeq ("@BUILD_LVMETAD@", "yes")
+LVM_RULES+=69-dm-lvm-metad.rules
+CLEAN_TARGETS+=69-dm-lvm-metad.rules
+endif
 
 include $(top_builddir)/make.tmpl
 
-- 
1.7.10.2


