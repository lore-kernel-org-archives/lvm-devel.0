From: Peter Rajnoha <prajnoha@redhat.com>
Date: Mon, 19 Oct 2009 13:46:57 +0200
Subject: [PATCH 3/4] Edit udev rules to use new udev flags and a cleanup
Message-ID: <4ADC51B1.2040704@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Changes in udev rules:

10-dm.rules
  - we need to decode the flags first, so we call "dmsetup udevflags"
  - I've removed OPTIONS+="last_rule" based for inappropriate devices
    that should not be processed further (like temporary-cryptsetup).

    Also, I've added ENV{DM_UUID}=="mpath-?*", ENV{DM_ACTION}=="PATH_FAILED", GOTO="dm_disable",
    this one is issued on PATH_FAIL and we definitely don't want to process this (...and
    call blkid on this one, as an example). I use the flags instead of OPTIONS+="last_rule".

    There is a potential danger here and that is when someone does not check the flags
    to filter out these events (in contrast to OPTIONS+="last_rule"). However, the use
    of OPTIONS+="last_rule" is controversial and a source of potential disputes.
    I'm still not convinced about withdrawing the last_rule, I'll probably ask someone
    from udev directly to get the opinion...

11-lvm.rules:
  - since we have DM_UDEV_RULES_VSN that is defined only when 10-dm.rules is processed,
    we don't need to do a filter on SUBSYSTEM and KERNEL again. Also, we don't need
    to check again the situation with the coldplug.

12-dm-disk.rules:
  - the same as with 11-lvm.rules...
  - we set higher priority for the symlink with the possibility of the same name
    (/dev/disk/by-uuid that is based on FS UUID).
  - (it does not work now because of the bug in udevd/libudev - patch is on a way
     to udev team :) )

12-dm-permissions.rules:
  - the same as with 11-lvm.rules...

95-dm-notify.rules:
  - I've removed the setting for default permission root:root/0600 based on the feedback
    I got. I should leave the permissions to be set based on default udev rules installed
    in the system (which is 50-udev-default.rules in Fedora that sets the group to "disk").
    If there's anyone who wants to change this, he can use 12-dm-permissions to set different
    default rules.

Peter


diff --git a/udev/10-dm.rules.in b/udev/10-dm.rules.in
index 1386b40..901f219 100644
--- a/udev/10-dm.rules.in
+++ b/udev/10-dm.rules.in
@@ -20,6 +20,9 @@ ENV{DM_SBIN_PATH}="/sbin"
 TEST!="$env{DM_SBIN_PATH}/dmsetup", ENV{DM_SBIN_PATH}="/usr/sbin"
 TEST!="$env{DM_SBIN_PATH}/dmsetup", GOTO="dm_end"
 
+# Decode udev control flags and set environment variables appropriately.
+ENV{DM_COOKIE}=="?*", IMPORT{program}="$env{DM_SBIN_PATH}/dmsetup udevflags $env{DM_COOKIE}"
+
 ACTION!="add|change", GOTO="dm_end"
 
 # Normally, we operate on "change" events only. But when
@@ -57,15 +60,15 @@ ENV{DM_UDEV_RULES_VSN}="1"
 
 ENV{DM_NAME}=="?*", NAME="$kernel", SYMLINK+="(DM_DIR)/$env{DM_NAME}"
 
-# We have to ignore further rule application for temporary
-# cryptsetup devices. But don't forget to send the notification!
-ENV{DM_UUID}=="CRYPT-TEMP-?*", GOTO="dm_last_rule"
-ENV{DM_UUID}!="?*", ENV{DM_NAME}=="temporary-cryptsetup-?*", GOTO="dm_last_rule"
+# Try to not process inappropriate devices (events) in the rules further.
+ENV{DM_UUID}=="mpath-?*", ENV{DM_ACTION}=="PATH_FAILED", GOTO="dm_disable"
+ENV{DM_UUID}=="CRYPT-TEMP-?*", GOTO="dm_disable"
+ENV{DM_UUID}!="?*", ENV{DM_NAME}=="temporary-cryptsetup-?*", GOTO="dm_disable"
 
 GOTO="dm_end"
 
-LABEL="dm_last_rule"
-ENV{DM_COOKIE}=="?*", RUN+="$env{DM_SBIN_PATH}/dmsetup udevcomplete $env{DM_COOKIE}"
-OPTIONS+="last_rule"
+LABEL="dm_disable"
+ENV{DM_UDEV_FLAG_DISABLE_SUBSYTEM_RULES}="1"
+ENV{DM_UDEV_FLAG_DISABLE_DISK_RULES}="1"
 
 LABEL="dm_end"
diff --git a/udev/11-lvm.rules b/udev/11-lvm.rules
index 8ac6525..dc4a9e5 100644
--- a/udev/11-lvm.rules
+++ b/udev/11-lvm.rules
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
+ENV{DM_UDEV_FLAG_DISABLE_SUBSYSTEM_RULES}=="1", GOTO="lvm_end"
 
 # Use DM name and split it up into its VG/LV/layer constituents.
 IMPORT{program}="$env{DM_SBIN_PATH}/dmsetup splitname --nameprefixes --noheadings --rows $env{DM_NAME}"
diff --git a/udev/12-dm-disk.rules b/udev/12-dm-disk.rules
index b110064..92ffce8 100644
--- a/udev/12-dm-disk.rules
+++ b/udev/12-dm-disk.rules
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
+ENV{DM_UDEV_FLAG_DISABLE_DISK_RULES}=="1", GOTO="dm_end"
 
 SYMLINK+="disk/by-id/dm-name-$env{DM_NAME}"
 ENV{DM_UUID}=="?*", SYMLINK+="disk/by-id/dm-uuid-$env{DM_UUID}"
@@ -23,7 +17,7 @@ ENV{DM_SUSPENDED}=="1", GOTO="dm_end"
 
 IMPORT{program}="$env{DM_SBIN_PATH}/blkid -o udev -p $tempnode"
 OPTIONS="link_priority=-100"
-ENV{DM_LV_LAYER}=="?*", OPTIONS="link_priority=-90"
+ENV{DM_UDEV_FLAG_HIGH_SYMLINK_PRIORITY}=="1", OPTIONS="link_priority=-90"
 ENV{ID_FS_USAGE}=="filesystem|other|crypto", ENV{ID_FS_UUID_ENC}=="?*", SYMLINK+="disk/by-uuid/$env{ID_FS_UUID_ENC}"
 ENV{ID_FS_USAGE}=="filesystem|other", ENV{ID_FS_LABEL_ENC}=="?*", SYMLINK+="disk/by-label/$env{ID_FS_LABEL_ENC}"
 
diff --git a/udev/12-dm-permissions.rules b/udev/12-dm-permissions.rules
index cc3e4cf..9ceb8f8 100644
--- a/udev/12-dm-permissions.rules
+++ b/udev/12-dm-permissions.rules
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
@@ -72,4 +71,7 @@ ENV{DM_UDEV_RULES_VSN}!="?*", GOTO="dm_end"
 # listed at the beginning of this file (udev provides simple pattern matching by
 # using *, ? and [] that you can use, see 'man udev' for more information).
 
+# Set default permissions for all DM devices if not set before.
+# OWNER:="root", GROUP:="root", MODE:="660"
+
 LABEL="dm_end"
diff --git a/udev/95-dm-notify.rules b/udev/95-dm-notify.rules
index 5834239..085313b 100644
--- a/udev/95-dm-notify.rules
+++ b/udev/95-dm-notify.rules
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


