From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 26 Oct 2009 14:04:32 -0000
Subject: LVM2/udev 11-dm-lvm.rules 13-dm-disk.rules 11- ...
Message-ID: <20091026140432.24014.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2009-10-26 14:04:31

Added files:
	udev           : 11-dm-lvm.rules 13-dm-disk.rules 
Removed files:
	udev           : 11-lvm.rules 12-dm-disk.rules 

Log message:
	Rename 11-lvm.rules to 11-dm-lvm.rules and 12-dm-disk.rules to 13-dm-disk.rules.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/udev/11-dm-lvm.rules.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/udev/13-dm-disk.rules.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/udev/11-lvm.rules.diff?cvsroot=lvm2&r1=1.4&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/udev/12-dm-disk.rules.diff?cvsroot=lvm2&r1=1.4&r2=NONE

/cvs/lvm2/LVM2/udev/11-dm-lvm.rules,v  -->  standard output
revision 1.1
--- LVM2/udev/11-dm-lvm.rules
+++ -	2009-10-26 14:04:32.114834000 +0000
@@ -0,0 +1,26 @@
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
+ENV{DM_UDEV_DISABLE_SUBSYSTEM_RULES_FLAG}=="1", GOTO="lvm_end"
+
+# Use DM name and split it up into its VG/LV/layer constituents.
+IMPORT{program}="$env{DM_SBIN_PATH}/dmsetup splitname --nameprefixes --noheadings --rows $env{DM_NAME}"
+
+# Do not create symlinks for hidden subdevices.
+ENV{DM_LV_NAME}=="?*_mimage_[0-9]*|pvmove?*|?*_vorigin", GOTO="lvm_end"
+
+# Create symlinks for top-level devices only.
+ENV{DM_VG_NAME}=="?*", ENV{DM_LV_NAME}=="?*", ENV{DM_LV_LAYER}!="?*", SYMLINK+="$env{DM_VG_NAME}/$env{DM_LV_NAME}"
+
+LABEL="lvm_end"
/cvs/lvm2/LVM2/udev/13-dm-disk.rules,v  -->  standard output
revision 1.1
--- LVM2/udev/13-dm-disk.rules
+++ -	2009-10-26 14:04:32.214815000 +0000
@@ -0,0 +1,23 @@
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
+IMPORT{program}="$env{DM_SBIN_PATH}/blkid -o udev -p $tempnode"
+ENV{DM_UDEV_LOW_PRIORITY_FLAG}=="1", OPTIONS="link_priority=-100"
+ENV{ID_FS_USAGE}=="filesystem|other|crypto", ENV{ID_FS_UUID_ENC}=="?*", SYMLINK+="disk/by-uuid/$env{ID_FS_UUID_ENC}"
+ENV{ID_FS_USAGE}=="filesystem|other", ENV{ID_FS_LABEL_ENC}=="?*", SYMLINK+="disk/by-label/$env{ID_FS_LABEL_ENC}"
+
+LABEL="dm_end"


