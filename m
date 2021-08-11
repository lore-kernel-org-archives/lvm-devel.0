From: Marian Csontos <mcsontos@sourceware.org>
Date: Wed, 11 Aug 2021 15:13:11 +0000 (GMT)
Subject: main - WHATS_NEW: update
Message-ID: <20210811151311.993083857413@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7dfaf5dc1348e8c06cdc9b1ec23b70c6aad5f30f
Commit:        7dfaf5dc1348e8c06cdc9b1ec23b70c6aad5f30f
Parent:        b328cfee5288c14e771404821baa646b5f378a3c
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Tue Aug 10 14:19:24 2021 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue Aug 10 14:19:24 2021 +0200

WHATS_NEW: update

---
 WHATS_NEW | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/WHATS_NEW b/WHATS_NEW
index 4fcd9f3c5..72060b40a 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,11 +1,20 @@
 Version 2.03.13 - 
 ===============================
+  Changes in udev support:
+  - obtain_device_list_from_udev defaults to 0.
+  - see devices/external_device_info_source,
+    devices/obtain_device_list_from_udev, and devices/multipath_wwids_file help
+    in lvm.conf
+  Fix devices file handling of loop with deleted backing file.
+  Fix devices file handling of scsi_debug WWIDs.
+  Fix many static analysis issues.
   Support --poolmetadataspare with vgsplit and vgmerge.
   Fix detection of active components of external origin volume.
   Add vdoimport tool to support conversion of VDO volumes.
   Support configurable allocation/vdo_pool_header_size.
   Fix handling of lvconvert --type vdo-pool --virtualsize.
   Simplified handling of archive() and backup() internal calls.
+  Add 'idm' locking type for IDM lock manager.
   Fix load of kvdo target when it is not present in memory (2.03.12).
 
 Version 2.03.12 - 07th May 2021


