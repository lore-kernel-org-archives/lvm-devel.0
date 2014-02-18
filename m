From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 18 Feb 2014 10:37:32 +0000 (UTC)
Subject: master - udev: create /dev/disk/by-id/lvm-pv-uuid-<PV_UUID> symlink for a PV
Message-ID: <20140218103732.DBCA961245@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=417e52c13a8156b11c25c411d44bda8b32bf87e4
Commit:        417e52c13a8156b11c25c411d44bda8b32bf87e4
Parent:        0e0f91b6ddcdd338bcd528b3f44eb3f019704fb3
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Feb 18 11:27:21 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Feb 18 11:37:20 2014 +0100

udev: create /dev/disk/by-id/lvm-pv-uuid-<PV_UUID> symlink for a PV

We already have /dev/disk/by-id/dm-uuid-... (which encompasses the
VG UUID and LV UUID in case of LVs since the mapping's UUID is
VG+LV UUID together) and /dev/disk/by-id/dm-name-... (which encompasses
the VG and LV name in case of LVs).

This patch addds /dev/disk/by-id/lvm-pv-uuid-<PV_UUID> that completes
this scheme and makes navigation a bit easier using PV UUIDs since
one can navigate using PV UUIDs only and there's no need to do extra
PV UUID <--> kernel name matching (the PV UUID is stable across reboots).
This may come in handy in various scripts.

Since we already have the PV UUID stored in udev database (as a result
of blkid call - returned in ID_FS_UUID blkid's variable), this operation
is very cheap indeed, just creating the extra one symlink.
---
 WHATS_NEW                     |    1 +
 udev/69-dm-lvm-metad.rules.in |    3 +++
 2 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 39e8b88..5bb37d8 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.106 - 
 ====================================
+  Create /dev/disk/by-id/lvm-pv-uuid-<PV_UUID> symlink for each PV via udev.
   lvcreate computes RAID4/5/6 stripes if not given from # of allocatable PVs.
   Fix merging of old snapshot into thin volume origin.
   Use --ignoreskippedcluster in lvm2-monitor initscript/systemd unit.
diff --git a/udev/69-dm-lvm-metad.rules.in b/udev/69-dm-lvm-metad.rules.in
index e8304b5..bd75fc8 100644
--- a/udev/69-dm-lvm-metad.rules.in
+++ b/udev/69-dm-lvm-metad.rules.in
@@ -34,6 +34,9 @@ ENV{DM_MULTIPATH_DEVICE_PATH}=="1", GOTO="lvm_end"
 # Inform lvmetad about any PV that is gone.
 ACTION=="remove", GOTO="lvm_scan"
 
+# Create /dev/disk/by-id/lvm-pv-uuid-<PV_UUID> symlink for each PV
+ENV{ID_FS_UUID_ENC}=="?*", SYMLINK+="disk/by-id/lvm-pv-uuid-$env{ID_FS_UUID_ENC}"
+
 # If the PV is a special device listed below, scan only if the device is
 # properly activated. These devices are not usable after an ADD event,
 # but they require an extra setup and they are ready after a CHANGE event.


