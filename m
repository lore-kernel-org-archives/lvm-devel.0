From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 11 Sep 2009 16:05:22 -0000
Subject: LVM2 ./WHATS_NEW udev/10-dm.rules.in udev/11-l ...
Message-ID: <20090911160522.24461.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2009-09-11 16:05:21

Modified files:
	.              : WHATS_NEW 
	udev           : 10-dm.rules.in 11-lvm.rules 12-dm-disk.rules 
	                 12-dm-permissions.rules 95-dm-notify.rules 

Log message:
	Several changes in udev rules:
	
	- add DM_UDEV_RULES_VSN to provide a variable to be checked for in the other
	rules (e.g. to check that DM rules are actually installed, we can alternate
	functionality in the other rules based on this information, also we have
	versioning support for the rules)
	- set proper sbin path for dmsetup and blkid, /sbin first, then /usr/sbin.
	This is necessary for anaconda to work properly.
	- add 'last_rule' for cryptsetup's temporary devices (symlinks in /dev/mapper
	only)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1257&r2=1.1258
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/udev/10-dm.rules.in.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/udev/11-lvm.rules.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/udev/12-dm-disk.rules.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/udev/12-dm-permissions.rules.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/udev/95-dm-notify.rules.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/WHATS_NEW	2009/09/11 15:56:06	1.1257
+++ LVM2/WHATS_NEW	2009/09/11 16:05:20	1.1258
@@ -1,5 +1,6 @@
 Version 2.02.52 -
 =================================
+  Add DM_UDEV_RULES_VSN udev enviroment variable.
   Check that udev is running and set internal state appropriately.
   Add libudev configuration check.
   Add lvm2app.sh to nightly tests conditional upon configure --enable-applib.
--- LVM2/udev/10-dm.rules.in	2009/08/04 08:05:06	1.2
+++ LVM2/udev/10-dm.rules.in	2009/09/11 16:05:20	1.3
@@ -8,11 +8,18 @@
 #   DM_NAME - actual DM device's name
 #   DM_UUID - UUID set for DM device (blank if not specified)
 #   DM_SUSPENDED - suspended state of DM device (0 or 1)
+#   DM_UDEV_RULES_VSN - DM udev rules version
 
 KERNEL=="device-mapper", NAME="(DM_DIR)/control"
 
 SUBSYSTEM!="block", GOTO="dm_end"
 KERNEL!="dm-[0-9]*", GOTO="dm_end"
+
+# Set proper sbin path, /sbin has higher priority than /usr/sbin.
+ENV{DM_SBIN_PATH}="/sbin"
+TEST!="$env{DM_SBIN_PATH}/dmsetup", ENV{DM_SBIN_PATH}="/usr/sbin"
+TEST!="$env{DM_SBIN_PATH}/dmsetup", GOTO="dm_end"
+
 ACTION!="add|change", GOTO="dm_end"
 
 # Normally, we operate on "change" events only. But when
@@ -30,8 +37,8 @@
 # so we also have to call dmsetup if the kernel version used
 # is in between these releases.
 TEST=="dm", ENV{DM_NAME}="$attr{dm/name}", ENV{DM_UUID}="$attr{dm/uuid}", ENV{DM_SUSPENDED}="$attr{dm/suspended}"
-TEST!="dm", IMPORT{program}="/sbin/dmsetup info -j %M -m %m -c --nameprefixes --noheadings --rows -o name,uuid,suspended"
-ENV{DM_SUSPENDED}!="?*", IMPORT{program}="/sbin/dmsetup info -j %M -m %m -c --nameprefixes --noheadings --rows -o suspended"
+TEST!="dm", IMPORT{program}="$env{DM_SBIN_PATH}/dmsetup info -j %M -m %m -c --nameprefixes --noheadings --rows -o name,uuid,suspended"
+ENV{DM_SUSPENDED}!="?*", IMPORT{program}="$env{DM_SBIN_PATH}/dmsetup info -j %M -m %m -c --nameprefixes --noheadings --rows -o suspended"
 
 # dmsetup tool provides suspended state information in textual
 # form with values "Suspended"/"Active". We translate it to
@@ -39,6 +46,26 @@
 ENV{DM_SUSPENDED}=="Active", ENV{DM_SUSPENDED}="0"
 ENV{DM_SUSPENDED}=="Suspended", ENV{DM_SUSPENDED}="1"
 
+# This variable provides a reliable way to check that device-mapper
+# rules were installed. It means that all needed variables are set
+# by these rules directly so there's no need to acquire them again
+# later. Other rules can alternate the functionality based on this
+# fact (e.g. fallback to rules that behave correctly even without
+# these rules installed). It also provides versioning for any
+# possible future changes.
+ENV{DM_UDEV_RULES_VSN}="1"
+
 ENV{DM_NAME}=="?*", NAME="$kernel", SYMLINK+="(DM_DIR)/$env{DM_NAME}"
 
+# We have to ignore further rule application for temporary
+# cryptsetup devices. But don't forget to send the notification!
+ENV{DM_UUID}=="CRYPT-TEMP-?*", GOTO="dm_last_rule"
+ENV{DM_UUID}!="?*", ENV{DM_NAME}=="temporary-cryptsetup-?*", GOTO="dm_last_rule"
+
+GOTO="dm_end"
+
+LABEL="dm_last_rule"
+ENV{DM_COOKIE}=="?*", RUN+="$env{DM_SBIN_PATH}/dmsetup udevcomplete $env{DM_COOKIE}"
+OPTIONS+="last_rule"
+
 LABEL="dm_end"
--- LVM2/udev/11-lvm.rules	2009/08/04 08:05:06	1.2
+++ LVM2/udev/11-lvm.rules	2009/09/11 16:05:20	1.3
@@ -11,6 +11,7 @@
 SUBSYSTEM!="block", GOTO="lvm_end"
 KERNEL!="dm-[0-9]*", GOTO="lvm_end"
 ACTION!="add|change", GOTO="lvm_end"
+ENV{DM_UDEV_RULES_VSN}!="?*", GOTO="lvm_end"
 ENV{DM_UUID}!="LVM-?*", GOTO="lvm_end"
 
 # Normally, we operate on "change" events only. But when
@@ -20,11 +21,10 @@
 ACTION=="add", ENV{STARTUP}!="1", GOTO="lvm_end"
 
 # Use DM name and split it up into its VG/LV/layer constituents.
-IMPORT{program}="/sbin/dmsetup splitname --nameprefixes --noheadings --rows $env{DM_NAME}"
+IMPORT{program}="$env{DM_SBIN_PATH}/dmsetup splitname --nameprefixes --noheadings --rows $env{DM_NAME}"
 
 # Do not create symlinks for hidden subdevices.
-ENV{DM_LV_NAME}=="?*_mlog", GOTO="lvm_end"
-ENV{DM_LV_NAME}=="?*_mimage_[0-9]*", GOTO="lvm_end"
+ENV{DM_LV_NAME}=="?*_mimage_[0-9]*|pvmove?*|?*_vorigin", GOTO="lvm_end"
 
 # Create symlinks for top-level devices only.
 ENV{DM_VG_NAME}=="?*", ENV{DM_LV_NAME}=="?*", ENV{DM_LV_LAYER}!="?*", SYMLINK+="$env{DM_VG_NAME}/$env{DM_LV_NAME}"
--- LVM2/udev/12-dm-disk.rules	2009/08/14 14:37:46	1.2
+++ LVM2/udev/12-dm-disk.rules	2009/09/11 16:05:20	1.3
@@ -8,7 +8,7 @@
 SUBSYSTEM!="block", GOTO="dm_end"
 KERNEL!="dm-[0-9]*", GOTO="dm_end"
 ACTION!="add|change", GOTO="dm_end"
-ENV{DM_NAME}!="?*", GOTO="dm_end"
+ENV{DM_UDEV_RULES_VSN}!="?*", GOTO="dm_end"
 
 # Normally, we operate on "change" events only. But when
 # coldplugging, there's an "add" event present. We have to
@@ -21,7 +21,7 @@
 
 ENV{DM_SUSPENDED}=="1", GOTO="dm_end"
 
-IMPORT{program}="/sbin/blkid -o udev -p $tempnode"
+IMPORT{program}="$env{DM_SBIN_PATH}/blkid -o udev -p $tempnode"
 OPTIONS="link_priority=-100"
 ENV{DM_LV_LAYER}=="?*", OPTIONS="link_priority=-90"
 ENV{ID_FS_USAGE}=="filesystem|other|crypto", ENV{ID_FS_UUID_ENC}=="?*", SYMLINK+="disk/by-uuid/$env{ID_FS_UUID_ENC}"
--- LVM2/udev/12-dm-permissions.rules	2009/08/06 15:10:58	1.1
+++ LVM2/udev/12-dm-permissions.rules	2009/09/11 16:05:20	1.2
@@ -2,6 +2,7 @@
 #
 # These rules set permissions for DM devices. There are some environment
 # variables set that can be used:
+#   DM_UDEV_RULES_VSN - DM udev rules version
 #   DM_NAME - actual DM device's name
 #   DM_UUID - UUID set for DM device (blank if not specified)
 #   DM_SUSPENDED - suspended state of DM device (0 or 1)
@@ -12,6 +13,7 @@
 SUBSYSTEM!="block", GOTO="dm_end"
 KERNEL!="dm-[0-9]*", GOTO="dm_end"
 ACTION!="change", GOTO="dm_end"
+ENV{DM_UDEV_RULES_VSN}!="?*", GOTO="dm_end"
 
 #ENV{DM_NAME}=="my_device", OWNER:="peter", GROUP:="peter", MODE:="644"
 
--- LVM2/udev/95-dm-notify.rules	2009/08/03 18:44:54	1.1
+++ LVM2/udev/95-dm-notify.rules	2009/09/11 16:05:20	1.2
@@ -11,6 +11,6 @@
 ACTION!="change|remove", GOTO="dm_end"
 
 ACTION=="change", OWNER:="root", GROUP:="root", MODE:="600"
-ENV{DM_COOKIE}=="?*", RUN+="/sbin/dmsetup udevcomplete $env{DM_COOKIE}"
+ENV{DM_COOKIE}=="?*", RUN+="$env{DM_SBIN_PATH}/dmsetup udevcomplete $env{DM_COOKIE}"
 
 LABEL="dm_end"


