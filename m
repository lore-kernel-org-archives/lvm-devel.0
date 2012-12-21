From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 21 Dec 2012 09:40:01 +0000 (UTC)
Subject: master - activation: fix autoactivation to not trigger on each PV change
Message-ID: <20121221094001.D16B5A0C29@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=756bcabbfe297688ba240a880bc2b55265ad33f0
Commit:        756bcabbfe297688ba240a880bc2b55265ad33f0
Parent:        970dfbcd691addb7b69f4011c067eba3b35270b6
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Dec 21 10:34:48 2012 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Dec 21 10:34:48 2012 +0100

activation: fix autoactivation to not trigger on each PV change

Before, the pvscan --cache -aay was called on each ADD and CHANGE
uevent (for a device that is not a device-mapper device) and each CHANGE
event (for a PV that is a device-mapper device).

This causes troubles with autoactivation in some cases as CHANGE event
may originate from using the OPTION+="watch" udev rule that is defined
in 60-persistent-storage.rules (part of the rules provided by udev
directly) and it's used for all block devices
(except fd*|mtd*|nbd*|gnbd*|btibm*|dm-*|md* devices). For example, the
following sequence incorrectly activates the rest of LVs in a VG if one
of the LVs in the VG is being removed:

[root at rhel6-a ~]# pvcreate /dev/sda
  Physical volume "/dev/sda" successfully created

[root at rhel6-a ~]# vgcreate vg /dev/sda
  Volume group "vg" successfully created

[root at rhel6-a ~]# lvcreate -l1 vg
  Logical volume "lvol0" created

[root at rhel6-a ~]# lvcreate -l1 vg
  Logical volume "lvol1" created

[root at rhel6-a ~]# vgchange -an vg
  0 logical volume(s) in volume group "vg" now active

[root at rhel6-a ~]# lvs
  LV      VG        Attr      LSize   Pool Origin Data%  Move Log
Cpy%Sync Convert
  lvol0   vg        -wi------   4.00m
  lvol1   vg        -wi------   4.00m

[root at rhel6-a ~]# lvremove -ff vg/lvol1
  Logical volume "lvol1" successfully removed

[root at rhel6-a ~]# lvs
  LV      VG        Attr      LSize   Pool Origin Data%  Move Log
Cpy%Sync Convert
  lvol0   vg        -wi-a----   4.00m

...so the vg was deactivated, then lvol1 removed, and we end up with
lvol1 removed (which is ok) BUT with lvol0 activated (which is wrong)!!!
This is because after lvol1 removal, we need to write metadata to the
underlying device /dev/sda and that causes the CHANGE event to be
generated (because of the WATCH udev rule set on this device) and this
causes the pvscan --cache -aay to be reevaluated.

We have to limit this and call pvscan --cache -aay to autoactivate
VGs/LVs only in these cases:

 --> if the *PV is not a dm device*, scan only after proper device
addition (ADD event) and not with any other changes (CHANGE event)

 --> if the *PV is a dm device*, scan only after proper mapping
activation (CHANGE event + the underlying PV in a state "just
activated")
---
 WHATS_NEW                     |    1 +
 udev/10-dm.rules.in           |    2 +-
 udev/69-dm-lvm-metad.rules.in |   16 ++++++++++++----
 3 files changed, 14 insertions(+), 5 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index d114ccc..5ac3090 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Fix autoactivation to not autoactivate VG/LV on each change of the PVs used.
   Limit RAID device replacement to repair only if LV is not in-sync.
   Disallow RAID device replacement or repair on inactive LVs.
   Fix possible race while removing metadata from lvmetad.
diff --git a/udev/10-dm.rules.in b/udev/10-dm.rules.in
index 29af467..cfee145 100644
--- a/udev/10-dm.rules.in
+++ b/udev/10-dm.rules.in
@@ -45,7 +45,7 @@ ENV{DISK_RO}=="1", GOTO="dm_disable"
 # in libdevmapper so we need to detect this and try to behave correctly.
 # For such spurious events, regenerate all flags from current udev database content
 # (this information would normally be inaccessible for spurious ADD and CHANGE events).
-ENV{DM_UDEV_PRIMARY_SOURCE_FLAG}=="1", GOTO="dm_flags_done"
+ENV{DM_UDEV_PRIMARY_SOURCE_FLAG}=="1", ENV{DM_ACTIVATION}="1", GOTO="dm_flags_done"
 IMPORT{db}="DM_UDEV_DISABLE_DM_RULES_FLAG"
 IMPORT{db}="DM_UDEV_DISABLE_SUBSYSTEM_RULES_FLAG"
 IMPORT{db}="DM_UDEV_DISABLE_DISK_RULES_FLAG"
diff --git a/udev/69-dm-lvm-metad.rules.in b/udev/69-dm-lvm-metad.rules.in
index 706c03b..b16a27a 100644
--- a/udev/69-dm-lvm-metad.rules.in
+++ b/udev/69-dm-lvm-metad.rules.in
@@ -17,10 +17,18 @@
 SUBSYSTEM!="block", GOTO="lvm_end"
 (LVM_EXEC_RULE)
 
-# Device-mapper devices are processed only on change event or on supported synthesized event.
-KERNEL=="dm-[0-9]*", ENV{DM_UDEV_RULES_VSN}!="?*", GOTO="lvm_end"
-
 # Only process devices already marked as a PV - this requires blkid to be called before.
-ENV{ID_FS_TYPE}=="LVM2_member|LVM1_member", RUN+="(LVM_EXEC)/lvm pvscan --cache --activate ay --major $major --minor $minor"
+ENV{ID_FS_TYPE}!="LVM2_member|LVM1_member", GOTO="lvm_end"
+
+ACTION=="remove", GOTO="lvm_scan"
+
+# If the PV is not a dm device, scan only after device addition (ADD event)
+KERNEL!="dm-[0-9]*", ACTION!="add", GOTO="lvm_end"
+
+# If the PV is a dm device, scan only after proper mapping activation (CHANGE event + DM_ACTIVATION=1)
+KERNEL=="dm-[0-9]*", ENV{DM_ACTIVATION}!="1", GOTO="lvm_end"
+
+LABEL="lvm_scan"
+RUN+="(LVM_EXEC)/lvm pvscan --cache --activate ay --major $major --minor $minor"
 
 LABEL="lvm_end"


