From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 20 Feb 2012 19:38:42 -0000
Subject: LVM2/udev Makefile.in 13-dm-disk.rules.in 13-d ...
Message-ID: <20120220193842.30627.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2012-02-20 19:38:41

Modified files:
	udev           : Makefile.in 
Added files:
	udev           : 13-dm-disk.rules.in 
Removed files:
	udev           : 13-dm-disk.rules 

Log message:
	Call built-in blkid conditionaly (udev version >= 176), call standard blkid
	with full path otherwise.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/udev/13-dm-disk.rules.in.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/udev/Makefile.in.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/udev/13-dm-disk.rules.diff?cvsroot=lvm2&r1=1.8&r2=NONE

/cvs/lvm2/LVM2/udev/13-dm-disk.rules.in,v  -->  standard output
revision 1.1
--- LVM2/udev/13-dm-disk.rules.in
+++ -	2012-02-20 19:38:41.564935000 +0000
@@ -0,0 +1,38 @@
+# Copyright (C) 2009 Red Hat, Inc. All rights reserved.
+#
+# This file is part of LVM2.
+
+# Udev rules for device-mapper devices.
+#
+# These rules create symlinks in /dev/disk directory.
+# Symlinks that depend on probing filesystem type,
+# label and uuid are created only if the device is not
+# suspended.
+
+# "add" event is processed on coldplug only!
+ACTION!="add|change", GOTO="dm_end"
+ENV{DM_UDEV_RULES_VSN}!="?*", GOTO="dm_end"
+ENV{DM_UDEV_DISABLE_DISK_RULES_FLAG}=="1", GOTO="dm_end"
+
+SYMLINK+="disk/by-id/dm-name-$env{DM_NAME}"
+ENV{DM_UUID}=="?*", SYMLINK+="disk/by-id/dm-uuid-$env{DM_UUID}"
+
+ENV{DM_SUSPENDED}=="1", GOTO="dm_end"
+
+(BLKID_RULE)
+ENV{DM_UDEV_LOW_PRIORITY_FLAG}=="1", OPTIONS="link_priority=-100"
+ENV{ID_FS_USAGE}=="filesystem|other|crypto", ENV{ID_FS_UUID_ENC}=="?*", SYMLINK+="disk/by-uuid/$env{ID_FS_UUID_ENC}"
+ENV{ID_FS_USAGE}=="filesystem|other", ENV{ID_FS_LABEL_ENC}=="?*", SYMLINK+="disk/by-label/$env{ID_FS_LABEL_ENC}"
+
+# Add inotify watch to track changes on this device.
+# Using the watch rule is not optimal - it generates a lot of spurious
+# and useless events whenever the device opened for read-write is closed.
+# The best would be to generete the event directly in the tool changing
+# relevant information so only relevant events will be processed
+# (like creating a filesystem, changing filesystem label etc.).
+#
+# But let's use this until we have something better...
+
+OPTIONS+="watch"
+
+LABEL="dm_end"
--- LVM2/udev/Makefile.in	2010/04/09 21:44:28	1.8
+++ LVM2/udev/Makefile.in	2012/02/20 19:38:40	1.9
@@ -19,6 +19,12 @@
 LVM_RULES=11-dm-lvm.rules
 DM_DIR=$(shell grep "\#define DM_DIR" $(top_srcdir)/libdm/misc/dm-ioctl.h | awk '{print $$3}')
 
+ifeq ("@UDEV_HAS_BUILTIN_BLKID@", "yes")
+	BLKID_RULE=IMPORT{builtin}=\"blkid\"
+else
+	BLKID_RULE=IMPORT{program}=\"\$$env{DM_SBIN_PATH}\/blkid -o udev -p \$$tempnode\"
+endif
+
 CLEAN_TARGETS=10-dm.rules
 
 include $(top_builddir)/make.tmpl
@@ -26,7 +32,7 @@
 vpath %.rules $(srcdir)
 
 %.rules: %.rules.in
-	$(SED) -e "s/(DM_DIR)/$(DM_DIR)/" $< >$@
+	$(SED) -e "s/(DM_DIR)/$(DM_DIR)/" -e "s/(BLKID_RULE)/$(BLKID_RULE)/" $< >$@
 
 %_install: %.rules
 	$(INSTALL_DATA) -D $< $(udevdir)/$(<F)


