From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 12 Sep 2013 11:49:09 +0000 (UTC)
Subject: master - udev: keep DM_ACTIVATION and DM_UDEV_PRIMARY_SOURCE_FLAG meaning as before commit 8d1d835
Message-ID: <20130912114909.9BC2161059@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6940e24aeeff3d6c5c8da259b74afd908b4716f2
Commit:        6940e24aeeff3d6c5c8da259b74afd908b4716f2
Parent:        4d544004863b3d443fbeca11d264a324275958bd
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Sep 12 13:46:20 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Sep 12 13:49:02 2013 +0200

udev: keep DM_ACTIVATION and DM_UDEV_PRIMARY_SOURCE_FLAG meaning as before commit 8d1d835

The DM_ACTIVATION and DM_UDEV_PRIMARY_SOURCE_FLAG needs to be kept the
way it was for backward compatibility (e.g. the old rules are still
in initramfs). This way the check in whether the device should be
scanned in 69-dm-lvmetad.rules is even easier.
---
 udev/10-dm.rules.in           |   18 ++++++++++--------
 udev/69-dm-lvm-metad.rules.in |    3 +--
 2 files changed, 11 insertions(+), 10 deletions(-)

diff --git a/udev/10-dm.rules.in b/udev/10-dm.rules.in
index f495103..bc9681f 100644
--- a/udev/10-dm.rules.in
+++ b/udev/10-dm.rules.in
@@ -45,13 +45,14 @@ ENV{DISK_RO}=="1", GOTO="dm_disable"
 # in libdevmapper so we need to detect this and try to behave correctly.
 # For such spurious events, regenerate all flags from current udev database content
 # (this information would normally be inaccessible for spurious ADD and CHANGE events).
-ENV{DM_UDEV_PRIMARY_SOURCE_FLAG}=="1", ENV{DM_ACTIVATED}="1", GOTO="dm_flags_done"
+ENV{DM_UDEV_PRIMARY_SOURCE_FLAG}=="1", ENV{DM_ACTIVATION}="1", GOTO="dm_flags_done"
 IMPORT{db}="DM_UDEV_DISABLE_DM_RULES_FLAG"
 IMPORT{db}="DM_UDEV_DISABLE_SUBSYSTEM_RULES_FLAG"
 IMPORT{db}="DM_UDEV_DISABLE_DISK_RULES_FLAG"
 IMPORT{db}="DM_UDEV_DISABLE_OTHER_RULES_FLAG"
 IMPORT{db}="DM_UDEV_LOW_PRIORITY_FLAG"
 IMPORT{db}="DM_UDEV_DISABLE_LIBRARY_FALLBACK_FLAG"
+IMPORT{db}="DM_UDEV_PRIMARY_SOURCE_FLAG"
 IMPORT{db}="DM_UDEV_FLAG7"
 IMPORT{db}="DM_SUBSYSTEM_UDEV_FLAG0"
 IMPORT{db}="DM_SUBSYSTEM_UDEV_FLAG1"
@@ -62,7 +63,6 @@ IMPORT{db}="DM_SUBSYSTEM_UDEV_FLAG5"
 IMPORT{db}="DM_SUBSYSTEM_UDEV_FLAG6"
 IMPORT{db}="DM_SUBSYSTEM_UDEV_FLAG7"
 IMPORT{db}="DM_UDEV_RULES_VSN"
-IMPORT{db}="DM_ACTIVATED"
 LABEL="dm_flags_done"
 
 # Normally, we operate on "change" events. But when coldplugging, there's an
@@ -77,24 +77,26 @@ LABEL="dm_flags_done"
 # before (e.g. in initrd). If udev is used in initrd, we require the udev init
 # script to not remove the existing udev database so we can reuse the information
 # stored at the time of device activation in the initrd.
-# The DM_ACTIVATED variable indicates that the device has already been activated.
-ACTION=="add", ENV{DM_UDEV_RULES_VSN}!="1", ENV{DM_ACTIVATED}!="1", GOTO="dm_disable"
+ACTION!="add", GOTO="dm_no_coldplug"
+ENV{DM_UDEV_RULES_VSN}!="1", ENV{DM_UDEV_PRIMARY_SOURCE_FLAG}!="1", GOTO="dm_disable"
+ENV{DM_ACTIVATION}="1"
+LABEL="dm_no_coldplug"
 
 # Putting it together, following table is used to recognize genuine and spurious events.
 # N.B. Spurious events are generated based on use of the WATCH udev
 # rule or by triggering an event manually by "udevadm trigger" call
 # or by "echo <event_name> > /sys/block/dm-X/uevent".
 #
-#        EVENT              DM_UDEV_PRIMARY_SOURCE_FLAG   DM_ACTIVATED
-# ====================================================================
+#        EVENT              DM_UDEV_PRIMARY_SOURCE_FLAG   DM_ACTIVATION
+# ======================================================================
 # add event (genuine)                  0                        0
 # change event (genuine)               1                        1
 # add event (spurious)
 #   |_ dev still not active            0                        0
-#   \_ dev already active              0                        1
+#   \_ dev already active              1                        1
 # change event (spurious)
 #   |_ dev still not active            0                        0
-#   \_ dev already active              0                        1
+#   \_ dev already active              1                        0
 
 # "dm" sysfs subdirectory is available in newer versions of DM
 # only (kernels >= 2.6.29). We have to check for its existence
diff --git a/udev/69-dm-lvm-metad.rules.in b/udev/69-dm-lvm-metad.rules.in
index f2d2f1b..6363a79 100644
--- a/udev/69-dm-lvm-metad.rules.in
+++ b/udev/69-dm-lvm-metad.rules.in
@@ -39,8 +39,7 @@ ACTION=="remove", GOTO="lvm_scan"
 
 # DM device:
 KERNEL!="dm-[0-9]*", GOTO="next"
-ACTION=="add", ENV{DM_ACTIVATED}=="1", GOTO="lvm_scan"
-ACTION=="change", ENV{DM_UDEV_PRIMARY_SOURCE_FLAG}=="1", GOTO="lvm_scan"
+ENV{DM_UDEV_PRIMARY_SOURCE_FLAG}=="1", ENV{DM_ACTIVATION}=="1", GOTO="lvm_scan"
 GOTO="lvm_end"
 
 # MD device:


