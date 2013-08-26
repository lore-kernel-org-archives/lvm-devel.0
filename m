From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 26 Aug 2013 13:43:10 +0000 (UTC)
Subject: master - udev: inform lvmetad about lost PV label
Message-ID: <20130826134310.9731260790@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4d3b5724e0b51782000a45027de00e0fed1c9833
Commit:        4d3b5724e0b51782000a45027de00e0fed1c9833
Parent:        6b416f837f4ee71ca5705cb40fad22b26b0c664a
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Aug 26 15:27:00 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Aug 26 15:40:16 2013 +0200

udev: inform lvmetad about lost PV label

In stacked environment where we have a PV layered on top of a
snapshot LV and then removing the LV, lvmetad still keeps information
about the PV:

[0] raw/~ $ pvcreate /dev/sda
  Physical volume "/dev/sda" successfully created
[0] raw/~ $ vgcreate vg /dev/sda
  Volume group "vg" successfully created
[0] raw/~ $ lvcreate -L32m vg
  Logical volume "lvol0" created
[0] raw/~ $ lvcreate -L32m -s vg/lvol0
  Logical volume "lvol1" created
[0] raw/~ $ pvcreate /dev/vg/lvol1
  Physical volume "/dev/vg/lvol1" successfully created
[0] raw/~ $ lvremove -ff vg/lvol1
  Logical volume "lvol1" successfully removed
[0] raw/~ $ pvs
  No device found for PV BdNlu2-7bHV-XcIp-mFFC-PPuR-ef6K-yffdzO.
  PV         VG         Fmt  Attr PSize   PFree
  /dev/sda   vg         lvm2 a--  124.00m 92.00m
[0] raw/~ $ pvscan --cache --major 253 --minor 3
  Device 253:3 not found. Cleared from lvmetad cache.

This is because of the reactivation that is done just before
snapshot removal as part of the process (vg/lvol1 from the example above).
This causes a CHANGE event to be generated, but any scan done
on the LV does not see the original data anymore (in this case
the stacked PV label on top) and consequently the ID_FS_TYPE="LVM2_member"
(provided by blkid scan) is not stored in udev db anymore for the LV.
Consequently, the pvscan --cache is not run anymore as the dev is not
identified as LVM PV by the "LVM2_member" id - lvmetad loses this info
and still keeps records about the PV.

We can run into a very similar problem with erasing the PV label directly:

[0] raw/~ $ lvcreate -L32m vg
  Logical volume "lvol0" created
[0] raw/~ $ pvcreate /dev/vg/lvol0
  Physical volume "/dev/vg/lvol0" successfully created
[0] raw/~ $ dd if=/dev/zero of=/dev/vg/lvol0 bs=1M
dd: error writing '/dev/vg/lvol0': No space left on device
33+0 records in
32+0 records out
33554432 bytes (34 MB) copied, 0.380921 s, 88.1 MB/s
[0] raw/~ $ pvs
  PV            VG         Fmt  Attr PSize   PFree
  /dev/sda      vg         lvm2 a--  124.00m 92.00m
  /dev/vg/lvol0            lvm2 a--   32.00m 32.00m
[0] raw/~ $ pvscan --cache --major 253 --minor 2
  No PV label found on /dev/vg/lvol0.

This patch adds detection of this change from ID_FS_LABEL="LVM2_member"
to ID_FS_LABEL="<whatever_else>" and hence informing the lvmetad
about PV being gone.
---
 udev/13-dm-disk.rules.in      |    4 ++++
 udev/69-dm-lvm-metad.rules.in |    3 +++
 2 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/udev/13-dm-disk.rules.in b/udev/13-dm-disk.rules.in
index 1920260..f8e4ac6 100644
--- a/udev/13-dm-disk.rules.in
+++ b/udev/13-dm-disk.rules.in
@@ -17,6 +17,10 @@ ENV{DM_UDEV_DISABLE_DISK_RULES_FLAG}=="1", GOTO="dm_end"
 SYMLINK+="disk/by-id/dm-name-$env{DM_NAME}"
 ENV{DM_UUID}=="?*", SYMLINK+="disk/by-id/dm-uuid-$env{DM_UUID}"
 
+# Save previously detected dev type.
+IMPORT{db}="ID_FS_TYPE"
+ENV{ID_FS_TYPE}=="?*", ENV{DM_ID_FS_TYPE_OLD}="$env{ID_FS_TYPE}", ENV{ID_FS_TYPE}=""
+
 ENV{DM_SUSPENDED}=="1", GOTO="dm_end"
 
 (BLKID_RULE)
diff --git a/udev/69-dm-lvm-metad.rules.in b/udev/69-dm-lvm-metad.rules.in
index d5087e3..2d6720e 100644
--- a/udev/69-dm-lvm-metad.rules.in
+++ b/udev/69-dm-lvm-metad.rules.in
@@ -17,6 +17,9 @@
 SUBSYSTEM!="block", GOTO="lvm_end"
 (LVM_EXEC_RULE)
 
+# If the PV label got lost, inform lvmetad about it.
+ENV{DM_ID_FS_TYPE_OLD}=="LVM2_member", ENV{DM_ID_FS_TYPE}!="LVM2_member", GOTO="lvm_scan"
+
 # Only process devices already marked as a PV - this requires blkid to be called before.
 ENV{ID_FS_TYPE}!="LVM2_member|LVM1_member", GOTO="lvm_end"
 


