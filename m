From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 27 Jun 2012 10:12:56 +0000 (UTC)
Subject: master - udev: udev rules cleanup
Message-ID: <20120627101256.B64AF171E@lists.fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e6f8d86409e54300aeda05a82aad9b072d22ed4d
Commit:        e6f8d86409e54300aeda05a82aad9b072d22ed4d
Parent:        9a96f930a762418f1014f6a9da9546cb1f501f04
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Jun 22 05:50:02 2012 -0400
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jun 27 12:11:56 2012 +0200

udev: udev rules cleanup

Remove executable path detection in udev rules and use sbindir that
is configured, but still provide the original functionality by means
of 'configure --enable-udev-rule-exec-detection'.

Normally, the exec path for the tools called in udev rules should
not differ from the sbindir used, however, there are cases this is
necessary. For example different environments could be assembled
in a way that these path differ for some reason (distribution installer,
initrd ...).

This functionality is kept for compatibility only. Any environment
moving the binaries around and using different paths should be fixed
eventually!
---
 WHATS_NEW_DM                  |    2 ++
 configure.in                  |   25 ++++++++++++++++---------
 udev/10-dm.rules.in           |   12 ++++--------
 udev/11-dm-lvm.rules          |   37 -------------------------------------
 udev/11-dm-lvm.rules.in       |   37 +++++++++++++++++++++++++++++++++++++
 udev/69-dm-lvm-metad.rules    |   30 ------------------------------
 udev/69-dm-lvm-metad.rules.in |   26 ++++++++++++++++++++++++++
 udev/95-dm-notify.rules       |   12 ------------
 udev/95-dm-notify.rules.in    |   12 ++++++++++++
 udev/Makefile.in              |   33 ++++++++++++++++++++++-----------
 10 files changed, 119 insertions(+), 107 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index f6596c1..711104b 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,7 @@
 Version 1.02.76 - 
 ===============================
+  Add configure --enable-udev-rule-exec-detection to detect exec path in rules.
+  Use sbindir in udev rules by default and remove executable path detection.
   Remove hard-coded paths for dmeventd fifos and use default-dm-run-dir.
   Add configure --with-lvmetad-pidfile to remove hard-coded value.
   Add configure --with-default-pid-dir for common directory with pid files.
diff --git a/configure.in b/configure.in
index 814c0bd..6c27324 100644
--- a/configure.in
+++ b/configure.in
@@ -934,16 +934,22 @@ AC_ARG_ENABLE(udev_rules,
 	      UDEV_RULES=$enableval, UDEV_RULES=$UDEV_SYNC)
 AC_MSG_RESULT($UDEV_RULES)
 
-if test x$UDEV_RULES = xyes; then
-	AC_MSG_CHECKING(whether udev supports builtin blkid)
-	udev_version=$(udevadm info --version 2>/dev/null)
-	if test -n "$udev_version" && test "$udev_version" -ge 176; then
-		UDEV_HAS_BUILTIN_BLKID=yes
-	else
-		UDEV_HAS_BUILTIN_BLKID=no
-	fi
-	AC_MSG_RESULT($UDEV_HAS_BUILTIN_BLKID)
+AC_MSG_CHECKING(whether to enable executable path detection in udev rules)
+AC_ARG_ENABLE(udev_rule_exec_detection,
+	      AC_HELP_STRING([--enable-udev-rule-exec-detection],
+			     [enable executable path detection in udev rules]),
+	      UDEV_RULE_EXEC_DETECTION=$enableval, UDEV_RULE_EXEC_DETECTION=no)
+AC_MSG_RESULT($UDEV_RULE_EXEC_DETECTION)
+
+dnl -- Check support for built-in blkid against target udev version
+AC_MSG_CHECKING(whether udev supports built-in blkid)
+test x$PKGCONFIG_INIT != x1 && pkg_config_init
+if $($PKG_CONFIG --atleast-version=176 libudev); then
+	UDEV_HAS_BUILTIN_BLKID=yes
+else
+	UDEV_HAS_BUILTIN_BLKID=no
 fi
+AC_MSG_RESULT($UDEV_HAS_BUILTIN_BLKID)
 
 ################################################################################
 dnl -- Compatibility mode
@@ -1528,6 +1534,7 @@ AC_SUBST(UDEV_LIBS)
 AC_SUBST(UDEV_PC)
 AC_SUBST(UDEV_RULES)
 AC_SUBST(UDEV_SYNC)
+AC_SUBST(UDEV_RULE_EXEC_DETECTION)
 AC_SUBST(UDEV_HAS_BUILTIN_BLKID)
 AC_SUBST(CUNIT_LIBS)
 AC_SUBST(CUNIT_CFLAGS)
diff --git a/udev/10-dm.rules.in b/udev/10-dm.rules.in
index 605e088..29af467 100644
--- a/udev/10-dm.rules.in
+++ b/udev/10-dm.rules.in
@@ -18,11 +18,7 @@ KERNEL=="device-mapper", NAME="(DM_DIR)/control"
 
 SUBSYSTEM!="block", GOTO="dm_end"
 KERNEL!="dm-[0-9]*", GOTO="dm_end"
-
-# Set proper sbin path, /sbin has higher priority than /usr/sbin.
-ENV{DM_SBIN_PATH}="/sbin"
-TEST!="$env{DM_SBIN_PATH}/dmsetup", ENV{DM_SBIN_PATH}="/usr/sbin"
-TEST!="$env{DM_SBIN_PATH}/dmsetup", GOTO="dm_end"
+(DM_EXEC_RULE)
 
 # Device created, major and minor number assigned - "add" event generated.
 # Table loaded - no event generated.
@@ -40,7 +36,7 @@ ACTION!="add|change", GOTO="dm_end"
 # These flags are encoded in DM_COOKIE variable that was introduced in
 # kernel version 2.6.31. Therefore, we can use this feature with
 # kernels >= 2.6.31 only. Cookie is not decoded for remove event.
-ENV{DM_COOKIE}=="?*", IMPORT{program}="$env{DM_SBIN_PATH}/dmsetup udevflags $env{DM_COOKIE}"
+ENV{DM_COOKIE}=="?*", IMPORT{program}="(DM_EXEC)/dmsetup udevflags $env{DM_COOKIE}"
 
 # Rule out easy-to-detect inappropriate events first.
 ENV{DISK_RO}=="1", GOTO="dm_disable"
@@ -91,8 +87,8 @@ ACTION=="add", ENV{DM_UDEV_RULES_VSN}!="1", ENV{DM_UDEV_PRIMARY_SOURCE_FLAG}!="1
 # so we also have to call dmsetup if the kernel version used
 # is in between these releases.
 TEST=="dm", ENV{DM_NAME}="$attr{dm/name}", ENV{DM_UUID}="$attr{dm/uuid}", ENV{DM_SUSPENDED}="$attr{dm/suspended}"
-TEST!="dm", IMPORT{program}="$env{DM_SBIN_PATH}/dmsetup info -j %M -m %m -c --nameprefixes --noheadings --rows -o name,uuid,suspended"
-ENV{DM_SUSPENDED}!="?*", IMPORT{program}="$env{DM_SBIN_PATH}/dmsetup info -j %M -m %m -c --nameprefixes --noheadings --rows -o suspended"
+TEST!="dm", IMPORT{program}="(DM_EXEC)/dmsetup info -j %M -m %m -c --nameprefixes --noheadings --rows -o name,uuid,suspended"
+ENV{DM_SUSPENDED}!="?*", IMPORT{program}="(DM_EXEC)/dmsetup info -j %M -m %m -c --nameprefixes --noheadings --rows -o suspended"
 
 # dmsetup tool provides suspended state information in textual
 # form with values "Suspended"/"Active". We translate it to
diff --git a/udev/11-dm-lvm.rules b/udev/11-dm-lvm.rules
deleted file mode 100644
index 8244464..0000000
--- a/udev/11-dm-lvm.rules
+++ /dev/null
@@ -1,37 +0,0 @@
-# Copyright (C) 2009 Red Hat, Inc. All rights reserved.
-#
-# This file is part of LVM2.
-
-# Udev rules for LVM.
-#
-# These rules create symlinks for LVM logical volumes in
-# /dev/VG directory (VG is an actual VG name). Some udev
-# environment variables are set (they can be used in later
-# rules as well):
-#   DM_LV_NAME - logical volume name
-#   DM_VG_NAME - volume group name
-#   DM_LV_LAYER - logical volume layer (blank if not set)
-
-# "add" event is processed on coldplug only!
-ACTION!="add|change", GOTO="lvm_end"
-ENV{DM_UDEV_RULES_VSN}!="?*", GOTO="lvm_end"
-ENV{DM_UUID}!="LVM-?*", GOTO="lvm_end"
-
-# Use DM name and split it up into its VG/LV/layer constituents.
-IMPORT{program}="$env{DM_SBIN_PATH}/dmsetup splitname --nameprefixes --noheadings --rows $env{DM_NAME}"
-
-ENV{DM_UDEV_DISABLE_SUBSYSTEM_RULES_FLAG}=="1", GOTO="lvm_end"
-
-# Do not create symlinks for inappropriate subdevices.
-ENV{DM_LV_NAME}=="pvmove?*|?*_vorigin", GOTO="lvm_disable"
-ENV{DM_LV_LAYER}=="?*", GOTO="lvm_disable"
-
-# Create symlinks for top-level devices only.
-ENV{DM_VG_NAME}=="?*", ENV{DM_LV_NAME}=="?*", SYMLINK+="$env{DM_VG_NAME}/$env{DM_LV_NAME}", GOTO="lvm_end"
-
-LABEL="lvm_disable"
-ENV{DM_UDEV_DISABLE_DISK_RULES_FLAG}="1"
-ENV{DM_UDEV_DISABLE_OTHER_RULES_FLAG}="1"
-OPTIONS:="nowatch"
-
-LABEL="lvm_end"
diff --git a/udev/11-dm-lvm.rules.in b/udev/11-dm-lvm.rules.in
new file mode 100644
index 0000000..58ef210
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
+IMPORT{program}="(DM_EXEC)/dmsetup splitname --nameprefixes --noheadings --rows $env{DM_NAME}"
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
index 0000000..26309de
--- /dev/null
+++ b/udev/69-dm-lvm-metad.rules.in
@@ -0,0 +1,26 @@
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
+(LVM_EXEC_RULE)
+
+# Device-mapper devices are processed only on change event or on supported synthesized event.
+KERNEL=="dm-[0-9]*", ENV{DM_UDEV_RULES_VSN}!="?*", GOTO="lvm_end"
+
+# Only process devices already marked as a PV - this requires blkid to be called before.
+ENV{ID_FS_TYPE}=="LVM2_member|LVM1_member", RUN+="(LVM_EXEC)/lvm pvscan --cache --major $major --minor $minor"
+
+LABEL="lvm_end"
diff --git a/udev/95-dm-notify.rules b/udev/95-dm-notify.rules
deleted file mode 100644
index 72cc609..0000000
--- a/udev/95-dm-notify.rules
+++ /dev/null
@@ -1,12 +0,0 @@
-# Copyright (C) 2009 Red Hat, Inc. All rights reserved.
-#
-# This file is part of LVM2.
-
-# Udev rules for device-mapper devices.
-#
-# These rules are responsible for sending a notification to a process
-# waiting for completion of udev rules. The process is identified by
-# a cookie value sent within "change" and "remove" events (the cookie
-# value is set before by that process for every action requested).
-
-ENV{DM_COOKIE}=="?*", RUN+="$env{DM_SBIN_PATH}/dmsetup udevcomplete $env{DM_COOKIE}"
diff --git a/udev/95-dm-notify.rules.in b/udev/95-dm-notify.rules.in
new file mode 100644
index 0000000..80d59d3
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
+ENV{DM_COOKIE}=="?*", RUN+="(DM_EXEC)/dmsetup udevcomplete $env{DM_COOKIE}"
diff --git a/udev/Makefile.in b/udev/Makefile.in
index 4ace910..5c15bdb 100644
--- a/udev/Makefile.in
+++ b/udev/Makefile.in
@@ -15,28 +15,39 @@ srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
 
+include $(top_builddir)/make.tmpl
+vpath %.rules $(srcdir)
+
 DM_RULES=10-dm.rules 13-dm-disk.rules 95-dm-notify.rules
 LVM_RULES=11-dm-lvm.rules
-DM_DIR=$(shell grep "\#define DM_DIR" $(top_srcdir)/libdm/misc/dm-ioctl.h | awk '{print $$3}')
-
 ifeq ("@BUILD_LVMETAD@", "yes")
 LVM_RULES+=69-dm-lvm-metad.rules
 endif
 
-ifeq ("@UDEV_HAS_BUILTIN_BLKID@", "yes")
-	BLKID_RULE=IMPORT{builtin}=\"blkid\"
+DM_DIR=$(shell grep "\#define DM_DIR" $(top_srcdir)/libdm/misc/dm-ioctl.h | awk '{print $$3}')
+
+ifeq ("@UDEV_RULE_EXEC_DETECTION@", "yes")
+SBIN=\$$env{DM_SBIN_PATH}
+DM_EXEC_RULE=ENV{DM_SBIN_PATH}=\"\/sbin\"\\nTEST!=\"\$$env{DM_SBIN_PATH}\/dmsetup\", ENV{DM_SBIN_PATH}=\"\/usr\/sbin\"
+DM_EXEC=\$$env{DM_SBIN_PATH}
+LVM_EXEC_RULE=ENV{LVM_SBIN_PATH}=\"\/sbin\"\\nTEST!=\"\$$env{LVM_SBIN_PATH}\/lvm\", ENV{LVM_SBIN_PATH}=\"\/usr\/sbin\"
+LVM_EXEC=\$$env{LVM_SBIN_PATH}
 else
-	BLKID_RULE=IMPORT{program}=\"\$$env{DM_SBIN_PATH}\/blkid -o udev -p \$$tempnode\"
+SBIN="@sbindir@"
+DM_EXEC_RULE=""
+DM_EXEC=${SBIN}
+LVM_EXEC_RULE=""
+LVM_EXEC=${SBIN}
 endif
 
-CLEAN_TARGETS = 10-dm.rules 13-dm-disk.rules
-
-include $(top_builddir)/make.tmpl
-
-vpath %.rules $(srcdir)
+ifeq ("@UDEV_HAS_BUILTIN_BLKID@", "yes")
+BLKID_RULE=IMPORT{builtin}=\"blkid\"
+else
+BLKID_RULE=IMPORT{program}=\"${SBIN}\/blkid -o udev -p \$$tempnode\"
+endif
 
 %.rules: %.rules.in
-	$(SED) -e "s/(DM_DIR)/$(DM_DIR)/" -e "s/(BLKID_RULE)/$(BLKID_RULE)/" $< >$@
+	$(SED) -e "s+(DM_DIR)+$(DM_DIR)+;s+(BLKID_RULE)+$(BLKID_RULE)+;s+(DM_EXEC_RULE)+$(DM_EXEC_RULE)+;s+(DM_EXEC)+$(DM_EXEC)+;s+(LVM_EXEC_RULE)+$(LVM_EXEC_RULE)+;s+(LVM_EXEC)+$(LVM_EXEC)+;" $< >$@
 
 %_install: %.rules
 	$(INSTALL_DATA) -D $< $(udevdir)/$(<F)


