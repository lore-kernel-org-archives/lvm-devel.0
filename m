From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 22 Oct 2009 13:11:34 -0000
Subject: LVM2 ./WHATS_NEW_DM udev/10-dm.rules.in udev/1 ...
Message-ID: <20091022131134.2584.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2009-10-22 13:11:33

Modified files:
	.              : WHATS_NEW_DM 
	udev           : 10-dm.rules.in 11-lvm.rules 12-dm-disk.rules 
	                 12-dm-permissions.rules 95-dm-notify.rules 

Log message:
	Use udev flags in the rules and cleanup the rules:
	- remove default permissions set in 95-dm-notify.rules (and add a hint in 12-dm-permissions.rules to set it by the user directly)
	- add multipath DM_ACTION=="PATH_FAILED" filter
	- remove unnecessary filters in the headers of the rules (we can simply use DM_UDEV_RULES_VSN instead)
	- fix symlink priorities in /dev/disk/ (snapshot volumes have low priority for FS UUID symlinks so it will not overwrite symlinks for the origin)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.306&r2=1.307
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/udev/10-dm.rules.in.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/udev/11-lvm.rules.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/udev/12-dm-disk.rules.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/udev/12-dm-permissions.rules.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/udev/95-dm-notify.rules.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/WHATS_NEW_DM	2009/10/22 12:55:47	1.306
+++ LVM2/WHATS_NEW_DM	2009/10/22 13:11:33	1.307
@@ -1,5 +1,6 @@
 Version 1.02.39 - 
 =====================================
+  Remove strict default permissions for DM devices from 95-dm-notify.rules.
   Add dmsetup udevflags command to decode udev flags in given cookie value.
   Add udev flags support in libdevmapper.
   Make libdm ABI consistent when built with/without selinux support.
--- LVM2/udev/10-dm.rules.in	2009/09/11 16:05:20	1.3
+++ LVM2/udev/10-dm.rules.in	2009/10/22 13:11:33	1.4
@@ -20,6 +20,9 @@
 TEST!="$env{DM_SBIN_PATH}/dmsetup", ENV{DM_SBIN_PATH}="/usr/sbin"
 TEST!="$env{DM_SBIN_PATH}/dmsetup", GOTO="dm_end"
 
+# Decode udev control flags and set environment variables appropriately.
+ENV{DM_COOKIE}=="?*", IMPORT{program}="$env{DM_SBIN_PATH}/dmsetup udevflags $env{DM_COOKIE}"
+
 ACTION!="add|change", GOTO="dm_end"
 
 # Normally, we operate on "change" events only. But when
@@ -55,10 +58,11 @@
 # possible future changes.
 ENV{DM_UDEV_RULES_VSN}="1"
 
-ENV{DM_NAME}=="?*", NAME="$kernel", SYMLINK+="(DM_DIR)/$env{DM_NAME}"
+ENV{DM_NAME}=="?*", SYMLINK+="(DM_DIR)/$env{DM_NAME}"
 
-# We have to ignore further rule application for temporary
-# cryptsetup devices. But don't forget to send the notification!
+# We have to ignore further rule application for inappropriate events
+# and devices. But still send the notification if cookie exists.
+ENV{DM_UUID}=="mpath-?*", ENV{DM_ACTION}=="PATH_FAILED", GOTO="dm_last_rule"
 ENV{DM_UUID}=="CRYPT-TEMP-?*", GOTO="dm_last_rule"
 ENV{DM_UUID}!="?*", ENV{DM_NAME}=="temporary-cryptsetup-?*", GOTO="dm_last_rule"
 
--- LVM2/udev/11-lvm.rules	2009/09/11 16:05:20	1.3
+++ LVM2/udev/11-lvm.rules	2009/10/22 13:11:33	1.4
@@ -8,17 +8,11 @@
 #   DM_VG_NAME - volume group name
 #   DM_LV_LAYER - logical volume layer (blank if not set)
 
-SUBSYSTEM!="block", GOTO="lvm_end"
-KERNEL!="dm-[0-9]*", GOTO="lvm_end"
+# "add" event is processed on coldplug only!
 ACTION!="add|change", GOTO="lvm_end"
 ENV{DM_UDEV_RULES_VSN}!="?*", GOTO="lvm_end"
 ENV{DM_UUID}!="LVM-?*", GOTO="lvm_end"
-
-# Normally, we operate on "change" events only. But when
-# coldplugging, there's an "add" event present. We have
-# to recognize this and do our actions in this particular
-# situation, too.
-ACTION=="add", ENV{STARTUP}!="1", GOTO="lvm_end"
+ENV{DM_UDEV_DISABLE_SUBSYSTEM_RULES_FLAG}=="1", GOTO="lvm_end"
 
 # Use DM name and split it up into its VG/LV/layer constituents.
 IMPORT{program}="$env{DM_SBIN_PATH}/dmsetup splitname --nameprefixes --noheadings --rows $env{DM_NAME}"
--- LVM2/udev/12-dm-disk.rules	2009/09/11 16:05:20	1.3
+++ LVM2/udev/12-dm-disk.rules	2009/10/22 13:11:33	1.4
@@ -5,16 +5,10 @@
 # label and uuid are created only if the device is not
 # suspended.
 
-SUBSYSTEM!="block", GOTO="dm_end"
-KERNEL!="dm-[0-9]*", GOTO="dm_end"
+# "add" event is processed on coldplug only!
 ACTION!="add|change", GOTO="dm_end"
 ENV{DM_UDEV_RULES_VSN}!="?*", GOTO="dm_end"
-
-# Normally, we operate on "change" events only. But when
-# coldplugging, there's an "add" event present. We have to
-# recognize this and do our actions in this particular
-# situation, too.
-ACTION=="add", ENV{STARTUP}!="1", GOTO="dm_end"
+ENV{DM_UDEV_DISABLE_DISK_RULES_FLAG}=="1", GOTO="dm_end"
 
 SYMLINK+="disk/by-id/dm-name-$env{DM_NAME}"
 ENV{DM_UUID}=="?*", SYMLINK+="disk/by-id/dm-uuid-$env{DM_UUID}"
@@ -22,8 +16,7 @@
 ENV{DM_SUSPENDED}=="1", GOTO="dm_end"
 
 IMPORT{program}="$env{DM_SBIN_PATH}/blkid -o udev -p $tempnode"
-OPTIONS="link_priority=-100"
-ENV{DM_LV_LAYER}=="?*", OPTIONS="link_priority=-90"
+ENV{DM_UDEV_LOW_PRIORITY_FLAG}=="1", OPTIONS="link_priority=-100"
 ENV{ID_FS_USAGE}=="filesystem|other|crypto", ENV{ID_FS_UUID_ENC}=="?*", SYMLINK+="disk/by-uuid/$env{ID_FS_UUID_ENC}"
 ENV{ID_FS_USAGE}=="filesystem|other", ENV{ID_FS_LABEL_ENC}=="?*", SYMLINK+="disk/by-label/$env{ID_FS_LABEL_ENC}"
 
--- LVM2/udev/12-dm-permissions.rules	2009/09/23 12:52:52	1.4
+++ LVM2/udev/12-dm-permissions.rules	2009/10/22 13:11:33	1.5
@@ -15,9 +15,8 @@
 #   DM_VG_NAME - volume group name (not set if LVM device not present)
 #   DM_LV_LAYER - logical volume layer (not set if LVM device not present)
 
-SUBSYSTEM!="block", GOTO="dm_end"
-KERNEL!="dm-[0-9]*", GOTO="dm_end"
-ACTION!="change", GOTO="dm_end"
+# "add" event is processed on coldplug only!
+ACTION!="add|change", GOTO="dm_end"
 ENV{DM_UDEV_RULES_VSN}!="?*", GOTO="dm_end"
 
 # A few demonstrational examples...
@@ -72,4 +71,7 @@
 # listed at the beginning of this file (udev provides simple pattern matching by
 # using *, ? and [] that you can use, see 'man udev' for more information).
 
+# Set default permissions for all DM devices if not set before.
+# OWNER:="root", GROUP:="root", MODE:="660"
+
 LABEL="dm_end"
--- LVM2/udev/95-dm-notify.rules	2009/09/11 16:05:20	1.2
+++ LVM2/udev/95-dm-notify.rules	2009/10/22 13:11:33	1.3
@@ -4,13 +4,11 @@
 # waiting for completion of udev rules. The process is identified by
 # a cookie value sent within "change" and "remove" events (the cookie
 # value is set before by that process for every action requested).
-# Also, it sets default permissions for DM devices if not set already.
 
 SUBSYSTEM!="block", GOTO="dm_end"
 KERNEL!="dm-[0-9]*", GOTO="dm_end"
 ACTION!="change|remove", GOTO="dm_end"
 
-ACTION=="change", OWNER:="root", GROUP:="root", MODE:="600"
 ENV{DM_COOKIE}=="?*", RUN+="$env{DM_SBIN_PATH}/dmsetup udevcomplete $env{DM_COOKIE}"
 
 LABEL="dm_end"


