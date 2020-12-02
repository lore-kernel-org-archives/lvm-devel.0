From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed,  2 Dec 2020 09:32:06 +0000 (GMT)
Subject: main - man: update writing style of the lvmvdo man page
Message-ID: <20201202093206.35C373857806@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a2affffed558899af563b790eaf5112b8c7e5bd5
Commit:        a2affffed558899af563b790eaf5112b8c7e5bd5
Parent:        205fb35b50a14f10b95bb4a47935010efe6d96e8
Author:        Marek Such????nek <msuchane@redhat.com>
AuthorDate:    Fri Nov 27 12:03:53 2020 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Dec 2 10:31:11 2020 +0100

man: update writing style of the lvmvdo man page

This patch improves the clarity, writing style, and language
of the lvmvdo(7) man page.

See https://bugzilla.redhat.com/show_bug.cgi?id=1855804.
---
 man/lvmvdo.7_main | 205 +++++++++++++++++++++++++++---------------------------
 1 file changed, 102 insertions(+), 103 deletions(-)

diff --git a/man/lvmvdo.7_main b/man/lvmvdo.7_main
index 3701e3f58..39dee3914 100644
--- a/man/lvmvdo.7_main
+++ b/man/lvmvdo.7_main
@@ -1,30 +1,29 @@
 .TH "LVMVDO" "7" "LVM TOOLS #VERSION#" "Red Hat, Inc" "\""
 
 .SH NAME
-lvmvdo \(em LVM Virtual Data Optimizer support
+lvmvdo \(em Support for Virtual Data Optimizer in LVM
 .SH DESCRIPTION
-VDO (which includes kvdo and vdo) is software that provides inline
+VDO is software that provides inline
 block-level deduplication, compression, and thin provisioning capabilities
 for primary storage.
 
 Deduplication is a technique for reducing the consumption of storage
 resources by eliminating multiple copies of duplicate blocks. Compression
-takes the individual unique blocks and shrinks them with coding
-algorithms; these reduced blocks are then efficiently packed together into
+takes the individual unique blocks and shrinks them. These reduced blocks are then efficiently packed together into
 physical blocks. Thin provisioning manages the mapping from logical blocks
 presented by VDO to where the data has actually been physically stored,
 and also eliminates any blocks of all zeroes.
 
-With deduplication, instead of writing the same data more than once each
-duplicate block is detected and recorded as a reference to the original
+With deduplication, instead of writing the same data more than once, VDO detects and records each
+duplicate block as a reference to the original
 block. VDO maintains a mapping from logical block addresses (used by the
 storage layer above VDO) to physical block addresses (used by the storage
 layer under VDO). After deduplication, multiple logical block addresses
 may be mapped to the same physical block address; these are called shared
 blocks and are reference-counted by the software.
 
-With VDO's compression, multiple blocks (or shared blocks) are compressed
-with the fast LZ4 algorithm, and binned together where possible so that
+With compression, VDO compresses multiple blocks (or shared blocks)
+with the fast LZ4 algorithm, and bins them together where possible so that
 multiple compressed blocks fit within a 4 KB block on the underlying
 storage. Mapping from LBA is to a physical block address and index within
 it for the desired compressed data. All compressed blocks are individually
@@ -37,55 +36,55 @@ allocated for storing the new block data to ensure that other logical
 block addresses that are mapped to the shared physical block are not
 modified.
 
-For usage of VDO with \fBlvm\fP(8) standard VDO userspace tools
-\fBvdoformat\fP(8) and currently non-standard kernel VDO module
-"\fIkvdo\fP" needs to be installed on the system.
+To use VDO with \fBlvm\fP(8), you must install the standard VDO user-space tools
+\fBvdoformat\fP(8) and the currently non-standard kernel VDO module
+"\fIkvdo\fP".
 
 The "\fIkvdo\fP" module implements fine-grained storage virtualization,
-thin provisioning, block sharing, and compression;
-the "\fIuds\fP" module provides memory-efficient duplicate
-identification. The userspace tools include \fBvdostats\fP(8)
-for extracting statistics from those volumes.
+thin provisioning, block sharing, and compression.
+The "\fIuds\fP" module provides memory-efficient duplicate
+identification. The user-space tools include \fBvdostats\fP(8)
+for extracting statistics from VDO volumes.
 .SH VDO TERMS
 .TP
 VDODataLV
 .br
 VDO data LV
 .br
-large hidden LV with suffix _vdata created in a VG
+A large hidden LV with the _vdata suffix. It is created in a VG
 .br
-used by VDO kernel target to store all data and metadata blocks.
+used by the VDO kernel target to store all data and metadata blocks.
 .TP
 VDOPoolLV
 .br
 VDO pool LV
 .br
-pool for virtual VDOLV(s) with the size of used VDODataLV
+A pool for virtual VDOLV(s) with the size of used VDODataLV.
 .br
-a single VDOLV is currently supported.
+Only a single VDOLV is currently supported.
 .TP
 VDOLV
 .br
 VDO LV
 .br
-created from VDOPoolLV
+Created from VDOPoolLV.
 .br
-appears blank after creation.
+Appears blank after creation.
 .SH VDO USAGE
 The primary methods for using VDO with lvm2:
 .SS 1. Create VDOPoolLV with VDOLV
-Create a VDOPoolLV that will hold VDO data together with
-virtual size VDOLV, that user can use. When the virtual size
-is not specified, then such LV is created with maximum size that
-always fits into data volume even if there cannot happen any
-deduplication and compression
-(i.e. it can hold uncompressible content of /dev/urandom).
-When the name of VDOPoolLV is not specified, it is taken from
+Create a VDOPoolLV that will hold VDO data, and a
+virtual size VDOLV that the user can use. If you do not specify the virtual size,
+then the VDOLV is created with the maximum size that
+always fits into data volume even if no
+deduplication or compression can happen
+(i.e. it can hold the incompressible content of /dev/urandom).
+If you do not specify the name of VDOPoolLV, it is taken from
 the sequence of vpool0, vpool1 ...
 
-Note: As the performance of TRIM/Discard operation is slow for large
-volumes of VDO type, please try to avoid sending discard requests unless
-necessary as it may take considerable amount of time to finish discard
+Note: The performance of TRIM/Discard operations is slow for large
+volumes of VDO type. Please try to avoid sending discard requests unless
+necessary because it might take considerable amount of time to finish the discard
 operation.
 
 .nf
@@ -99,14 +98,14 @@ operation.
 # mkfs.ext4 -E nodiscard /dev/vg/vdo0
 .fi
 .SS 2. Create VDOPoolLV from conversion of an existing LV into VDODataLV
-Convert an already created/existing LV into a volume that can hold
+Convert an already created or existing LV into a volume that can hold
 VDO data and metadata (volume referenced by VDOPoolLV).
-User will be prompted to confirm such conversion as it is \fBIRREVERSIBLY
-DESTROYING\fP content of such volume and it is being immediately
-formatted by \fBvdoformat\fP(8) as VDO pool data volume. User can
-specify virtual size of associated VDOLV with this VDOPoolLV.
-When the virtual size is not specified, it will be set to the maximum size
-that can keep 100% uncompressible data there.
+You will be prompted to confirm such conversion because it \fBIRREVERSIBLY
+DESTROYS\fP the content of such volume and the volume is immediately
+formatted by \fBvdoformat\fP(8) as a VDO pool data volume. You can
+specify the virtual size of the VDOLV associated with this VDOPoolLV.
+If you do not specify the virtual size, it will be set to the maximum size
+that can keep 100% incompressible data there.
 
 .nf
 .B lvconvert --type vdo-pool -n VDOLV -V VirtualSize VG/VDOPoolLV
@@ -117,13 +116,13 @@ that can keep 100% uncompressible data there.
 .nf
 # lvconvert --type vdo-pool -n vdo0 -V10G vg/ExistingLV
 .fi
-.SS 3. Change default settings used for creating VDOPoolLV
-VDO allows to set large variety of options. Lots of these settings
-can be specified by lvm.conf or profile settings. User can prepare
-number of different profiles in #DEFAULT_SYS_DIR#/profile directory
-and just specify profile file name.
-Check output of \fBlvmconfig --type full\fP for detailed description
-of all individual vdo settings.
+.SS 3. Change the default settings used for creating a VDOPoolLV
+VDO allows to set a large variety of options. Lots of these settings
+can be specified in lvm.conf or profile settings. You can prepare
+a number of different profiles in the #DEFAULT_SYS_DIR#/profile directory
+and just specify the profile file name.
+Check the output of \fBlvmconfig --type full\fP for a detailed description
+of all individual VDO settings.
 
 .I Example
 .nf
@@ -154,8 +153,8 @@ EOF
 # lvcreate --vdo -L10G --metadataprofile vdo_create vg/vdopool0
 # lvcreate --vdo -L10G --config 'allocation/vdo_cpu_threads=4' vg/vdopool1
 .fi
-.SS 4. Change compression and deduplication of VDOPoolLV
-Disable or enable compression and deduplication for VDOPoolLV
+.SS 4. Change the compression and deduplication of a VDOPoolLV
+Disable or enable the compression and deduplication for VDOPoolLV
 (the volume that maintains all VDO LV(s) associated with it).
 
 .nf
@@ -167,12 +166,12 @@ Disable or enable compression and deduplication for VDOPoolLV
 # lvchange --compression n  vg/vdopool0
 # lvchange --deduplication y vg/vdopool1
 .fi
-.SS 5. Checking usage of VDOPoolLV
-To quickly check how much data of VDOPoolLV are already consumed
-use \fBlvs\fP(8). Field Data% will report how much data occupies
-content of virtual data for VDOLV and how much space is already
-consumed with all the data and metadata blocks in VDOPoolLV.
-For a detailed description use \fBvdostats\fP(8) command.
+.SS 5. Checking the usage of VDOPoolLV
+To quickly check how much data on a VDOPoolLV is already consumed,
+use \fBlvs\fP(8). The Data% field reports how much data is occupied
+in the content of the virtual data for the VDOLV and how much space is already
+consumed with all the data and metadata blocks in the VDOPoolLV.
+For a detailed description, use the \fBvdostats\fP(8) command.
 
 Note: \fBvdostats\fP(8) currently understands only /dev/mapper device names.
 
@@ -194,20 +193,20 @@ Note: \fBvdostats\fP(8) currently understands only /dev/mapper device names.
   data blocks used                    : 79
   ...
 .fi
-.SS 6. Extending VDOPoolLV size
-Adding more space to hold VDO data and metadata can be made via
-extension of VDODataLV with commands
-\fBlvresize\fP(8), \fBlvextend\fP(8).
-Extension needs to add at least one new VDO slab which can be
-configured with \fBallocation/vdo_slab_size_mb\fP setting.
-
-User can also enable automatic size extension of monitored VDOPoolLV
-with \fBactivation/vdo_pool_autoextend_percent\fP and
+.SS 6. Extending the VDOPoolLV size
+You can add more space to hold VDO data and metadata by
+extending the VDODataLV using the commands
+\fBlvresize\fP(8) and \fBlvextend\fP(8).
+The extension needs to add at least one new VDO slab. You can configure
+the slab size with the \fBallocation/vdo_slab_size_mb\fP setting.
+
+You can also enable automatic size extension of a monitored VDOPoolLV
+with the \fBactivation/vdo_pool_autoextend_percent\fP and
 \fBactivation/vdo_pool_autoextend_threshold\fP settings.
 
-Note: Size of VDOPoolLV cannot be reduced.
+Note: You cannot reduce the size of a VDOPoolLV.
 
-Note: Size of cached VDOPoolLV cannot be changed.
+Note: You cannot change the size of a cached VDOPoolLV.
 
 .nf
 .B lvextend -L+AddingSize VG/VDOPoolLV
@@ -218,12 +217,12 @@ Note: Size of cached VDOPoolLV cannot be changed.
 # lvextend -L+50G vg/vdopool0
 # lvresize -L300G vg/vdopool1
 .fi
-.SS 7. Extending or reducing VDOLV size
-Virtual VDO LV can be extended or reduced as standard LV with commands
-\fBlvresize\fP(8), \fBlvextend\fP(8), \fBlvreduce\fP(8).
+.SS 7. Extending or reducing the VDOLV size
+You can extend or reduce a virtual VDO LV as a standard LV with the
+\fBlvresize\fP(8), \fBlvextend\fP(8), and \fBlvreduce\fP(8) commands.
 
-Note: Reduction needs to process TRIM for reduced disk area
-to unmap used data blocks from VDOPoolLV and it may take
+Note: The reduction needs to process TRIM for reduced disk area
+to unmap used data blocks from the VDOPoolLV, which might take
 a long time.
 
 .nf
@@ -237,11 +236,11 @@ a long time.
 # lvreduce -L-50G vg/vdo1
 # lvresize -L200G vg/vdo2
 .fi
-.SS 8. Component activation of VDODataLV
-VDODataLV can be activated separately as component LV for examination
-purposes. It activates data LV in read-only mode and cannot be modified.
-If the VDODataLV is active as component, any upper LV using this volume CANNOT
-be activated. User has to deactivate VDODataLV first to continue to use VDOPoolLV.
+.SS 8. Component activation of a VDODataLV
+You can activate a VDODataLV separately as a component LV for examination
+purposes. It activates the data LV in read-only mode, and the data LV cannot be modified.
+If the VDODataLV is active as a component, any upper LV using this volume CANNOT
+be activated. You have to deactivate the VDODataLV first to continue to use the VDOPoolLV.
 
 .I Example
 .nf
@@ -250,22 +249,22 @@ be activated. User has to deactivate VDODataLV first to continue to use VDOPoolL
 .fi
 .SH VDO TOPICS
 .SS 1. Stacking VDO
-User can convert/stack VDOPooLV with these currently supported
-volume types: linear, stripe, raid and cache with cachepool
+You can convert or stack a VDOPooLV with these currently supported
+volume types: linear, stripe, raid, and cache with cachepool.
 .SS 2. VDOPoolLV on top of raid
-Using raid type LV for VDODataLV.
+Using a raid type LV for a VDODataLV.
 
 .I Example
 .nf
 # lvcreate --type raid1 -L 5G -n vdopool vg
 # lvconvert --type vdo-pool -V 10G vg/vdopool
 .fi
-.SS 3. Caching VDODataLV, VDOPoolLV
-VDODataLV (accepts also VDOPoolLV) caching provides mechanism
-to accelerate read and write of already compressed and deduplicated
+.SS 3. Caching a VDODataLV or a VDOPoolLV
+VDODataLV (accepts also VDOPoolLV) caching provides a mechanism
+to accelerate reads and writes of already compressed and deduplicated
 data blocks together with VDO metadata.
 
-Cached VDO data LV cannot be currently resized and also the threshold
+A cached VDO data LV cannot be currently resized. Also, the threshold
 based automatic resize will not work.
 
 .I Example
@@ -275,9 +274,9 @@ based automatic resize will not work.
 # lvconvert --cache --cachepool vg/cachepool vg/vdopool
 # lvconvert --uncache vg/vdopool
 .fi
-.SS 4. Caching VDOLV
-VDO LV cache allow users to 'cache' device for better perfomance before
-it hits processing of VDO Pool LV layer.
+.SS 4. Caching a VDOLV
+VDO LV cache allow you to 'cache' a device for better performance before
+it hits the processing of the VDO Pool LV layer.
 
 .I Example
 .nf
@@ -286,22 +285,22 @@ it hits processing of VDO Pool LV layer.
 # lvconvert --cache --cachepool vg/cachepool vg/vdo1
 # lvconvert --uncache vg/vdo1
 .fi
-.SS 5. Usage of Discard/TRIM with VDOLV
-User can discard data in VDO LV and reduce used blocks in VDOPoolLV.
-However present performance of discard operation is still not optimal
-and takes considerable amount of time and CPU.
-So unless it's really needed users should avoid usage of discard.
+.SS 5. Usage of Discard/TRIM with a VDOLV
+You can discard data on a VDO LV and reduce used blocks on a VDOPoolLV.
+However, the current performance of discard operations is still not optimal
+and takes a considerable amount of time and CPU.
+Unless you really need it, you should avoid using discard.
 
-When block device is going to be rewritten,
+When a block device is going to be rewritten,
 block will be automatically reused for new data.
-Discard is useful in situation, when it is known the given portion of a VDO LV
+Discard is useful in situations when it is known that the given portion of a VDO LV
 is not going to be used and the discarded space can be used for block
-provisioning in other regions of VDO LV.
-For the same reason, user should avoid using mkfs with discard for
-freshly created VDO LV to save a lot of time this operation would
+provisioning in other regions of the VDO LV.
+For the same reason, you should avoid using mkfs with discard for
+a freshly created VDO LV to save a lot of time that this operation would
 take otherwise as device after create empty.
 .SS 6. Memory usage
-VDO target requires 370 MiB of RAM plus an additional 268 MiB
+The VDO target requires 370 MiB of RAM plus an additional 268 MiB
 per each 1 TiB of physical storage managed by the volume.
 
 UDS requires a minimum of 250 MiB of RAM,
@@ -309,9 +308,9 @@ which is also the default amount that deduplication uses.
 
 The memory required for the UDS index is determined by the index type
 and the required size of the deduplication window and
-is controled by \fBallocation/vdo_use_sparse_index\fP setting.
+is controlled by the \fBallocation/vdo_use_sparse_index\fP setting.
 
-With enabled UDS sparse indexing it relies on the temporal locality of data
+With enabled UDS sparse indexing, it relies on the temporal locality of data
 and attempts to retain only the most relevant index entries in memory and
 can maintain a deduplication window that is ten times larger
 than with dense while using the same amount of memory.
@@ -322,17 +321,17 @@ For most workloads, given the same amount of memory,
 the difference in deduplication rates between dense
 and sparse indexes is negligible.
 
-Dense index with 1 GiB of RAM maintains 1 TiB deduplication window,
-while sparse index with 1 GiB of RAM maintains 10 TiB deduplication window.
-In general 1 GiB is sufficient for 4 TiB or physical space with
-dense index and 40 TiB with sparse index.
+A dense index with 1 GiB of RAM maintains a 1 TiB deduplication window,
+while a sparse index with 1 GiB of RAM maintains a 10 TiB deduplication window.
+In general, 1 GiB is sufficient for 4 TiB of physical space with
+a dense index and 40 TiB with a sparse index.
 .SS 7. Storage space requirements
-User can configure a VDOPoolLV to use up to 256 TiB of physical storage.
+You can configure a VDOPoolLV to use up to 256 TiB of physical storage.
 Only a certain part of the physical storage is usable to store data.
 This section provides the calculations to determine the usable size
 of a VDO-managed volume.
 
-VDO target requires storage for two types of VDO metadata and for the UDS index:
+The VDO target requires storage for two types of VDO metadata and for the UDS index:
 .TP
 \(bu
 The first type of VDO metadata uses approximately 1 MiB for each 4 GiB


