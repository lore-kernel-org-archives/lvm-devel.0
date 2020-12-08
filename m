From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  8 Dec 2020 19:35:10 +0000 (GMT)
Subject: main - man: update lvmvdo
Message-ID: <20201208193510.DAA953854805@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7691213a91ca7cc2d5518db31d04c8afa74622e7
Commit:        7691213a91ca7cc2d5518db31d04c8afa74622e7
Parent:        9b3458d5a945302a68e4f5ed3011f01677411e9b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Dec 7 17:04:49 2020 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Dec 8 20:32:34 2020 +0100

man: update lvmvdo

Fix vdo example.
Update some sentences.
---
 man/lvmvdo.7_main | 23 ++++++++++++-----------
 1 file changed, 12 insertions(+), 11 deletions(-)

diff --git a/man/lvmvdo.7_main b/man/lvmvdo.7_main
index 39dee3914..474d6dd73 100644
--- a/man/lvmvdo.7_main
+++ b/man/lvmvdo.7_main
@@ -16,7 +16,7 @@ and also eliminates any blocks of all zeroes.
 
 With deduplication, instead of writing the same data more than once, VDO detects and records each
 duplicate block as a reference to the original
-block. VDO maintains a mapping from logical block addresses (used by the
+block. VDO maintains a mapping from Logical Block Addresses (LBA) (used by the
 storage layer above VDO) to physical block addresses (used by the storage
 layer under VDO). After deduplication, multiple logical block addresses
 may be mapped to the same physical block address; these are called shared
@@ -59,7 +59,7 @@ VDOPoolLV
 .br
 VDO pool LV
 .br
-A pool for virtual VDOLV(s) with the size of used VDODataLV.
+A pool for virtual VDOLV(s), which are the size of used VDODataLV.
 .br
 Only a single VDOLV is currently supported.
 .TP
@@ -72,7 +72,7 @@ Created from VDOPoolLV.
 Appears blank after creation.
 .SH VDO USAGE
 The primary methods for using VDO with lvm2:
-.SS 1. Create VDOPoolLV with VDOLV
+.SS 1. Create a VDOPoolLV and a VDOLV
 Create a VDOPoolLV that will hold VDO data, and a
 virtual size VDOLV that the user can use. If you do not specify the virtual size,
 then the VDOLV is created with the maximum size that
@@ -97,9 +97,9 @@ operation.
 # lvcreate --type vdo -n vdo0 -L 10G -V 100G vg/vdopool0
 # mkfs.ext4 -E nodiscard /dev/vg/vdo0
 .fi
-.SS 2. Create VDOPoolLV from conversion of an existing LV into VDODataLV
-Convert an already created or existing LV into a volume that can hold
-VDO data and metadata (volume referenced by VDOPoolLV).
+.SS 2. Convert an existing LV into VDOPoolLV
+Convert an already created or existing LV into a VDOPoolLV, which is a volume
+that can hold data and metadata.
 You will be prompted to confirm such conversion because it \fBIRREVERSIBLY
 DESTROYS\fP the content of such volume and the volume is immediately
 formatted by \fBvdoformat\fP(8) as a VDO pool data volume. You can
@@ -238,7 +238,8 @@ a long time.
 .fi
 .SS 8. Component activation of a VDODataLV
 You can activate a VDODataLV separately as a component LV for examination
-purposes. It activates the data LV in read-only mode, and the data LV cannot be modified.
+purposes. The activation of the VDODataLV activates the data LV in read-only mode,
+and the data LV cannot be modified.
 If the VDODataLV is active as a component, any upper LV using this volume CANNOT
 be activated. You have to deactivate the VDODataLV first to continue to use the VDOPoolLV.
 
@@ -280,7 +281,7 @@ it hits the processing of the VDO Pool LV layer.
 
 .I Example
 .nf
-# lvcreate -L 5G -V 10G -n vdo1 vg/vdopool
+# lvcreate --type vdo -L 5G -V 10G -n vdo1 vg/vdopool
 # lvcreate --type cache-pool -L 1G -n cachepool vg
 # lvconvert --cache --cachepool vg/cachepool vg/vdo1
 # lvconvert --uncache vg/vdo1
@@ -292,13 +293,13 @@ and takes a considerable amount of time and CPU.
 Unless you really need it, you should avoid using discard.
 
 When a block device is going to be rewritten,
-block will be automatically reused for new data.
-Discard is useful in situations when it is known that the given portion of a VDO LV
+its blocks will be automatically reused for new data.
+Discard is useful in situations when user knows that the given portion of a VDO LV
 is not going to be used and the discarded space can be used for block
 provisioning in other regions of the VDO LV.
 For the same reason, you should avoid using mkfs with discard for
 a freshly created VDO LV to save a lot of time that this operation would
-take otherwise as device after create empty.
+take otherwise as device is already expected to be empty.
 .SS 6. Memory usage
 The VDO target requires 370 MiB of RAM plus an additional 268 MiB
 per each 1 TiB of physical storage managed by the volume.


