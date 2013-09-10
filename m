From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 10 Sep 2013 14:29:57 +0000 (UTC)
Subject: master - udev: fix pvscan --cache -aay to trigger on relevant events
Message-ID: <20130910142957.B5CB561122@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8d1d83504dcf9c86ad42d34d3bd0b201d7bab8f6
Commit:        8d1d83504dcf9c86ad42d34d3bd0b201d7bab8f6
Parent:        9ba40da7ae908fb36cb9927cde60a1a45cacce80
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Sep 10 15:49:05 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Sep 10 16:27:58 2013 +0200

udev: fix pvscan --cache -aay to trigger on relevant events

This patch fixes the way the special devices are handled
(special in this context means that they're not usable
after the usual ADD event like other generic devices):

  - DM and MD devices are pvscanned only when they are just set up.
    This is the first CHANGE event that makes the device  usable
    (the DM_UDEV_PRIMARY_SOURCE_FLAG is set for DM and the
     md/array_state sysfs attribute is present for MD).
    Whether the device is activated is remembered via
    DM_ACTIVATED (for DM) and LVM_MD_PV_ACTIVATED (for MD)
    udev environment variable. This is then used to decide
    whether we should fire the pvscan on ADD event to
    support coldplugging. For any (artificial) ADD event
    generated during coldplug, the device must be already
    set up properly to fire the pvscan on it.

  - Similar for loop devices. For loop devices, only CHANGE
    events are relevant (so there's a CHANGE after the loop
    device is set up as well as detached). Whether the loop
    has just been activated is detected via loop/backing_file
    sysfs attribute presence. The activation state is remembered
    via LVM_LOOP_PV_ACTIVATED udev environment variable.

  - Do not pvscan multipath device components (underlying paths).

  - Do not pvscan RAID device components.

  - Also, set LVM_SCANNED="1" udev environment variable for
    debug purposes (it's visible in the lvmdump -u that takes
    the current udev database). This variable is set once
    the pvscan is triggered.

The table below summarises when the pvscan is triggered
(marked with X, X* means fire only if the special dev is properly set up):

      | real ADD | real CHANGE | artificial ADD | artificial CHANGE | remove
=============================================================================
DM    |          |      X      |       X*       |                   |   X
MD    |          |      X      |       X*       |                   |
loop  |          |      X      |       X*       |                   |
other |    X     |             |       X        |                   |   X
---
 udev/10-dm.rules.in           |   20 +++++-------
 udev/13-dm-disk.rules.in      |    4 --
 udev/69-dm-lvm-metad.rules.in |   66 +++++++++++++++++++++++++++++++++++-----
 3 files changed, 65 insertions(+), 25 deletions(-)

diff --git a/udev/10-dm.rules.in b/udev/10-dm.rules.in
index 3a157d5..f495103 100644
--- a/udev/10-dm.rules.in
+++ b/udev/10-dm.rules.in
@@ -45,14 +45,13 @@ ENV{DISK_RO}=="1", GOTO="dm_disable"
 # in libdevmapper so we need to detect this and try to behave correctly.
 # For such spurious events, regenerate all flags from current udev database content
 # (this information would normally be inaccessible for spurious ADD and CHANGE events).
-ENV{DM_UDEV_PRIMARY_SOURCE_FLAG}=="1", ENV{DM_ACTIVATION}="1", GOTO="dm_flags_done"
+ENV{DM_UDEV_PRIMARY_SOURCE_FLAG}=="1", ENV{DM_ACTIVATED}="1", GOTO="dm_flags_done"
 IMPORT{db}="DM_UDEV_DISABLE_DM_RULES_FLAG"
 IMPORT{db}="DM_UDEV_DISABLE_SUBSYSTEM_RULES_FLAG"
 IMPORT{db}="DM_UDEV_DISABLE_DISK_RULES_FLAG"
 IMPORT{db}="DM_UDEV_DISABLE_OTHER_RULES_FLAG"
 IMPORT{db}="DM_UDEV_LOW_PRIORITY_FLAG"
 IMPORT{db}="DM_UDEV_DISABLE_LIBRARY_FALLBACK_FLAG"
-IMPORT{db}="DM_UDEV_PRIMARY_SOURCE_FLAG"
 IMPORT{db}="DM_UDEV_FLAG7"
 IMPORT{db}="DM_SUBSYSTEM_UDEV_FLAG0"
 IMPORT{db}="DM_SUBSYSTEM_UDEV_FLAG1"
@@ -63,6 +62,7 @@ IMPORT{db}="DM_SUBSYSTEM_UDEV_FLAG5"
 IMPORT{db}="DM_SUBSYSTEM_UDEV_FLAG6"
 IMPORT{db}="DM_SUBSYSTEM_UDEV_FLAG7"
 IMPORT{db}="DM_UDEV_RULES_VSN"
+IMPORT{db}="DM_ACTIVATED"
 LABEL="dm_flags_done"
 
 # Normally, we operate on "change" events. But when coldplugging, there's an
@@ -77,28 +77,24 @@ LABEL="dm_flags_done"
 # before (e.g. in initrd). If udev is used in initrd, we require the udev init
 # script to not remove the existing udev database so we can reuse the information
 # stored at the time of device activation in the initrd.
-# The DM_ACTIVATION variable tells when any device stacked above should be
-# (re)activated as well.
-ACTION!="add", GOTO="dm_no_coldplug"
-ENV{DM_UDEV_RULES_VSN}!="1", ENV{DM_UDEV_PRIMARY_SOURCE_FLAG}!="1", GOTO="dm_disable"
-ENV{DM_ACTIVATION}="1"
-LABEL="dm_no_coldplug"
+# The DM_ACTIVATED variable indicates that the device has already been activated.
+ACTION=="add", ENV{DM_UDEV_RULES_VSN}!="1", ENV{DM_ACTIVATED}!="1", GOTO="dm_disable"
 
 # Putting it together, following table is used to recognize genuine and spurious events.
 # N.B. Spurious events are generated based on use of the WATCH udev
 # rule or by triggering an event manually by "udevadm trigger" call
 # or by "echo <event_name> > /sys/block/dm-X/uevent".
 #
-#        EVENT              DM_UDEV_PRIMARY_SOURCE_FLAG   DM_ACTIVATION
-# ======================================================================
+#        EVENT              DM_UDEV_PRIMARY_SOURCE_FLAG   DM_ACTIVATED
+# ====================================================================
 # add event (genuine)                  0                        0
 # change event (genuine)               1                        1
 # add event (spurious)
 #   |_ dev still not active            0                        0
-#   \_ dev already active              1                        1
+#   \_ dev already active              0                        1
 # change event (spurious)
 #   |_ dev still not active            0                        0
-#   \_ dev already active              1                        0
+#   \_ dev already active              0                        1
 
 # "dm" sysfs subdirectory is available in newer versions of DM
 # only (kernels >= 2.6.29). We have to check for its existence
diff --git a/udev/13-dm-disk.rules.in b/udev/13-dm-disk.rules.in
index f8e4ac6..1920260 100644
--- a/udev/13-dm-disk.rules.in
+++ b/udev/13-dm-disk.rules.in
@@ -17,10 +17,6 @@ ENV{DM_UDEV_DISABLE_DISK_RULES_FLAG}=="1", GOTO="dm_end"
 SYMLINK+="disk/by-id/dm-name-$env{DM_NAME}"
 ENV{DM_UUID}=="?*", SYMLINK+="disk/by-id/dm-uuid-$env{DM_UUID}"
 
-# Save previously detected dev type.
-IMPORT{db}="ID_FS_TYPE"
-ENV{ID_FS_TYPE}=="?*", ENV{DM_ID_FS_TYPE_OLD}="$env{ID_FS_TYPE}", ENV{ID_FS_TYPE}=""
-
 ENV{DM_SUSPENDED}=="1", GOTO="dm_end"
 
 (BLKID_RULE)
diff --git a/udev/69-dm-lvm-metad.rules.in b/udev/69-dm-lvm-metad.rules.in
index aa787e3..f2d2f1b 100644
--- a/udev/69-dm-lvm-metad.rules.in
+++ b/udev/69-dm-lvm-metad.rules.in
@@ -17,23 +17,71 @@
 SUBSYSTEM!="block", GOTO="lvm_end"
 (LVM_EXEC_RULE)
 
-# If the PV label got lost, inform lvmetad about it.
-ENV{DM_ID_FS_TYPE_OLD}=="LVM2_member|LVM1_member", ENV{ID_FS_TYPE}!="LVM2_member|LVM1_member", GOTO="lvm_scan"
+# If the PV label got lost, inform lvmetad immediately.
+# Detect the lost PV label by comparing previous ID_FS_TYPE value with current one.
+ENV{.ID_FS_TYPE_NEW}="$env{ID_FS_TYPE}"
+IMPORT{db}="ID_FS_TYPE"
+ENV{ID_FS_TYPE}=="LVM2_member|LVM1_member", ENV{.ID_FS_TYPE_NEW}!="LVM2_member|LVM1_member", ENV{LVM_PV_GONE}="1"
+ENV{ID_FS_TYPE}="$env{.ID_FS_TYPE_NEW}"
+ENV{LVM_PV_GONE}=="1", GOTO="lvm_scan"
 
 # Only process devices already marked as a PV - this requires blkid to be called before.
 ENV{ID_FS_TYPE}!="LVM2_member|LVM1_member", GOTO="lvm_end"
 
+# Inform lvmetad about any PV that is gone.
 ACTION=="remove", GOTO="lvm_scan"
-ACTION=="change", KERNEL=="md[0-9]*|loop[0-9]*", GOTO="lvm_scan"
 
-# If the PV is not a dm device, scan only after device addition (ADD event)
-KERNEL!="dm-[0-9]*", ACTION!="add", GOTO="lvm_end"
+# If the PV is a special device listed below, scan only if the device is
+# properly activated. These devices are not usable after an ADD event,
+# but they require an extra setup and they are ready after a CHANGE event.
+# Also support coldplugging with ADD event but only if the device is already
+# properly activated.
 
-# If the PV is a dm device, scan only after proper mapping activation (CHANGE event + DM_ACTIVATION=1)
-# or after a coldplug (event retrigger) with "add" event (ADD event + DM_ACTIVATION=1)
-KERNEL=="dm-[0-9]*", ENV{DM_ACTIVATION}!="1", GOTO="lvm_end"
+# DM device:
+KERNEL!="dm-[0-9]*", GOTO="next"
+ACTION=="add", ENV{DM_ACTIVATED}=="1", GOTO="lvm_scan"
+ACTION=="change", ENV{DM_UDEV_PRIMARY_SOURCE_FLAG}=="1", GOTO="lvm_scan"
+GOTO="lvm_end"
+
+# MD device:
+LABEL="next"
+KERNEL!="md[0-9]*", GOTO="next"
+IMPORT{db}="LVM_MD_PV_ACTIVATED"
+ACTION=="add", ENV{LVM_MD_PV_ACTIVATED}=="1", GOTO="lvm_scan"
+ACTION=="change", ENV{LVM_MD_PV_ACTIVATED}!="1", TEST=="md/array_state", ENV{LVM_MD_PV_ACTIVATED}="1", GOTO="lvm_scan"
+GOTO="lvm_end"
+
+# Loop device:
+LABEL="next"
+KERNEL!="loop[0-9]*", GOTO="next"
+ACTION=="add", ENV{LVM_LOOP_PV_ACTIVATED}=="1", GOTO="lvm_scan"
+ACTION=="change", ENV{LVM_LOOP_PV_ACTIVATED}!="1", TEST=="loop/backing_file", ENV{LVM_LOOP_PV_ACTIVATED}="1", GOTO="lvm_scan"
+GOTO="lvm_end"
+
+# If the PV is not a special device listed above, scan only after device addition (ADD event)
+LABEL="next"
+ACTION!="add", GOTO="lvm_end"
 
 LABEL="lvm_scan"
-RUN+="(LVM_EXEC)/lvm pvscan --background --cache --activate ay --major $major --minor $minor"
+
+# The table below summarises the situations in which we reach the LABEL="lvm_scan".
+# Marked by X, X* means only if the special dev is properly set up.
+# The artificial ADD is supported for coldplugging. We avoid running the pvscan
+# on artificial CHANGE so there's no unexpected autoactivation when WATCH rule fires.
+# N.B. MD and loop never actually  reaches lvm_scan on REMOVE as the PV label is gone
+# within a CHANGE event (these are caught by the "LVM_PV_GONE" rule at the beginning).
+#
+#        | real ADD | real CHANGE | artificial ADD | artificial CHANGE | REMOVE
+# =============================================================================
+#  DM    |          |      X      |       X*       |                   |   X
+#  MD    |          |      X      |       X*       |                   |
+#  loop  |          |      X      |       X*       |                   |
+#  other |    X     |             |       X        |                   |   X
+
+# Skip device that is a multipath or RAID component
+ENV{DM_MULTIPATH_DEVICE_PATH}=="1", GOTO="lvm_end"
+ENV{ID_FS_TYPE}=="*_raid_member", GOTO="lvm_end"
+
+RUN+="(LVM_EXEC)/lvm pvscan --background --cache --activate ay --major $major --minor $minor", ENV{LVM_SCANNED}="1"
 
 LABEL="lvm_end"


