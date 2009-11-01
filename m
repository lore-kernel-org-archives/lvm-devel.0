From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 1 Nov 2009 18:01:32 -0000
Subject: LVM2/udev 10-dm.rules.in 11-dm-lvm.rules 95-dm ...
Message-ID: <20091101180132.31649.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2009-11-01 18:01:31

Modified files:
	udev           : 10-dm.rules.in 11-dm-lvm.rules 
	                 95-dm-notify.rules 

Log message:
	More cleanup in udev rules:
	
	- add copyright notice for 10-dm.rules.in,
	
	- set DM_UDEV_DISABLE_{DISK, OTHER}_RULES_FLAG in 11-dm-lvm.rules directly
	for inappropriate and non-top-level subdevices in case we use older kernels
	where DM_COOKIE is not used (and therefore there are no flags passed from
	the LVM process itself). This applies for older kernels (version < 2.6.31),
	
	- remove unnecessary filters in 95-dm-notify.rules - the DM_COOKIE env var
	itself is set for change/remove udev events and for DM devices only so
	there's no need to double-check this.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/udev/10-dm.rules.in.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/udev/11-dm-lvm.rules.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/udev/95-dm-notify.rules.diff?cvsroot=lvm2&r1=1.4&r2=1.5

--- LVM2/udev/10-dm.rules.in	2009/10/26 14:29:34	1.5
+++ LVM2/udev/10-dm.rules.in	2009/11/01 18:01:31	1.6
@@ -1,3 +1,7 @@
+# Copyright (C) 2009 Red Hat, Inc. All rights reserved.
+#
+# This file is part of LVM2.
+
 # Udev rules for device-mapper devices.
 #
 # These rules create a DM control node in /dev/(DM_DIR) directory.
--- LVM2/udev/11-dm-lvm.rules	2009/10/26 22:42:07	1.3
+++ LVM2/udev/11-dm-lvm.rules	2009/11/01 18:01:31	1.4
@@ -22,9 +22,14 @@
 IMPORT{program}="$env{DM_SBIN_PATH}/dmsetup splitname --nameprefixes --noheadings --rows $env{DM_NAME}"
 
 # Do not create symlinks for inappropriate subdevices.
-ENV{DM_LV_NAME}=="?*_mimage_[0-9]*|pvmove?*|?*_vorigin", GOTO="lvm_end"
+ENV{DM_LV_NAME}=="?*_mimage_[0-9]*|pvmove?*|?*_vorigin", GOTO="lvm_disable"
+ENV{DM_LV_LAYER}=="?*", GOTO="lvm_disable"
 
 # Create symlinks for top-level devices only.
-ENV{DM_VG_NAME}=="?*", ENV{DM_LV_NAME}=="?*", ENV{DM_LV_LAYER}!="?*", SYMLINK+="$env{DM_VG_NAME}/$env{DM_LV_NAME}"
+ENV{DM_VG_NAME}=="?*", ENV{DM_LV_NAME}=="?*", SYMLINK+="$env{DM_VG_NAME}/$env{DM_LV_NAME}", GOTO="lvm_end"
+
+LABEL="lvm_disable"
+ENV{DM_UDEV_DISABLE_DISK_RULES_FLAG}="1"
+ENV{DM_UDEV_DISABLE_OTHER_RULES_FLAG}="1"
 
 LABEL="lvm_end"
--- LVM2/udev/95-dm-notify.rules	2009/10/26 22:42:07	1.4
+++ LVM2/udev/95-dm-notify.rules	2009/11/01 18:01:31	1.5
@@ -9,10 +9,4 @@
 # a cookie value sent within "change" and "remove" events (the cookie
 # value is set before by that process for every action requested).
 
-SUBSYSTEM!="block", GOTO="dm_end"
-KERNEL!="dm-[0-9]*", GOTO="dm_end"
-ACTION!="change|remove", GOTO="dm_end"
-
 ENV{DM_COOKIE}=="?*", RUN+="$env{DM_SBIN_PATH}/dmsetup udevcomplete $env{DM_COOKIE}"
-
-LABEL="dm_end"


