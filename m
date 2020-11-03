From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  3 Nov 2020 15:39:26 +0000 (GMT)
Subject: master - man: update vdo
Message-ID: <20201103153926.2AE433857C4C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8801a86a3e0c87d92b250a6477f86ef9efdb2ba0
Commit:        8801a86a3e0c87d92b250a6477f86ef9efdb2ba0
Parent:        63169594385ed4b02d93c2e8f422bbeb0b8225af
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Nov 3 16:32:14 2020 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Nov 3 16:34:46 2020 +0100

man: update vdo

Enhance VDO man page with description of memory usage
and space requirements chapter.

Remove some unneeded blank lines in man page.

Use more precise terminology.

Correct examples since  cpool and vpool are protected names.
---
 man/lvmvdo.7_main | 175 +++++++++++++++++++++++++++---------------------------
 1 file changed, 88 insertions(+), 87 deletions(-)

diff --git a/man/lvmvdo.7_main b/man/lvmvdo.7_main
index 76a758061..3701e3f58 100644
--- a/man/lvmvdo.7_main
+++ b/man/lvmvdo.7_main
@@ -2,9 +2,7 @@
 
 .SH NAME
 lvmvdo \(em LVM Virtual Data Optimizer support
-
 .SH DESCRIPTION
-
 VDO (which includes kvdo and vdo) is software that provides inline
 block-level deduplication, compression, and thin provisioning capabilities
 for primary storage.
@@ -13,9 +11,9 @@ Deduplication is a technique for reducing the consumption of storage
 resources by eliminating multiple copies of duplicate blocks. Compression
 takes the individual unique blocks and shrinks them with coding
 algorithms; these reduced blocks are then efficiently packed together into
-physical blocks. Thin provisioning manages the mapping from LBAs presented
-by VDO to where the data has actually been stored, and also eliminates any
-blocks of all zeroes.
+physical blocks. Thin provisioning manages the mapping from logical blocks
+presented by VDO to where the data has actually been physically stored,
+and also eliminates any blocks of all zeroes.
 
 With deduplication, instead of writing the same data more than once each
 duplicate block is detected and recorded as a reference to the original
@@ -48,29 +46,23 @@ thin provisioning, block sharing, and compression;
 the "\fIuds\fP" module provides memory-efficient duplicate
 identification. The userspace tools include \fBvdostats\fP(8)
 for extracting statistics from those volumes.
-
-
-.SH VDO Terms
-
+.SH VDO TERMS
 .TP
 VDODataLV
 .br
 VDO data LV
 .br
-large hidden LV with suffix _vdata created in a VG.
+large hidden LV with suffix _vdata created in a VG
 .br
-used by VDO target to store all data and metadata blocks.
-
+used by VDO kernel target to store all data and metadata blocks.
 .TP
 VDOPoolLV
 .br
 VDO pool LV
 .br
-maintains virtual for LV(s) stored in attached VDO data LV
-and it has same size.
+pool for virtual VDOLV(s) with the size of used VDODataLV
 .br
-contains VDOLV(s) (currently supports only a single VDOLV).
-
+a single VDOLV is currently supported.
 .TP
 VDOLV
 .br
@@ -78,14 +70,10 @@ VDO LV
 .br
 created from VDOPoolLV
 .br
-appears blank after creation
-
-.SH VDO Usage
-
+appears blank after creation.
+.SH VDO USAGE
 The primary methods for using VDO with lvm2:
-
 .SS 1. Create VDOPoolLV with VDOLV
-
 Create a VDOPoolLV that will hold VDO data together with
 virtual size VDOLV, that user can use. When the virtual size
 is not specified, then such LV is created with maximum size that
@@ -106,18 +94,15 @@ operation.
 .fi
 
 .I Example
-.br
 .nf
 # lvcreate --type vdo -n vdo0 -L 10G -V 100G vg/vdopool0
 # mkfs.ext4 -E nodiscard /dev/vg/vdo0
 .fi
-
 .SS 2. Create VDOPoolLV from conversion of an existing LV into VDODataLV
-
 Convert an already created/existing LV into a volume that can hold
-VDO data and metadata (a volume reference by VDOPoolLV).
+VDO data and metadata (volume referenced by VDOPoolLV).
 User will be prompted to confirm such conversion as it is \fBIRREVERSIBLY
-DESTROYING\fP content of such volume, as it's being immediately
+DESTROYING\fP content of such volume and it is being immediately
 formatted by \fBvdoformat\fP(8) as VDO pool data volume. User can
 specify virtual size of associated VDOLV with this VDOPoolLV.
 When the virtual size is not specified, it will be set to the maximum size
@@ -129,13 +114,10 @@ that can keep 100% uncompressible data there.
 .fi
 
 .I Example
-.br
 .nf
-# lvconvert --type vdo-pool -n vdo0 -V10G vg/existinglv
+# lvconvert --type vdo-pool -n vdo0 -V10G vg/ExistingLV
 .fi
-
 .SS 3. Change default settings used for creating VDOPoolLV
-
 VDO allows to set large variety of options. Lots of these settings
 can be specified by lvm.conf or profile settings. User can prepare
 number of different profiles in #DEFAULT_SYS_DIR#/profile directory
@@ -144,7 +126,6 @@ Check output of \fBlvmconfig --type full\fP for detailed description
 of all individual vdo settings.
 
 .I Example
-.br
 .nf
 # cat <<EOF > #DEFAULT_SYS_DIR#/profile/vdo_create.profile
 allocation {
@@ -173,10 +154,8 @@ EOF
 # lvcreate --vdo -L10G --metadataprofile vdo_create vg/vdopool0
 # lvcreate --vdo -L10G --config 'allocation/vdo_cpu_threads=4' vg/vdopool1
 .fi
-
 .SS 4. Change compression and deduplication of VDOPoolLV
-
-Disable or enable compression and deduplication for VDO pool LV
+Disable or enable compression and deduplication for VDOPoolLV
 (the volume that maintains all VDO LV(s) associated with it).
 
 .nf
@@ -184,14 +163,11 @@ Disable or enable compression and deduplication for VDO pool LV
 .fi
 
 .I Example
-.br
 .nf
-# lvchange --compression n  vg/vdpool0
-# lvchange --deduplication y vg/vdpool1
+# lvchange --compression n  vg/vdopool0
+# lvchange --deduplication y vg/vdopool1
 .fi
-
 .SS 5. Checking usage of VDOPoolLV
-
 To quickly check how much data of VDOPoolLV are already consumed
 use \fBlvs\fP(8). Field Data% will report how much data occupies
 content of virtual data for VDOLV and how much space is already
@@ -201,7 +177,6 @@ For a detailed description use \fBvdostats\fP(8) command.
 Note: \fBvdostats\fP(8) currently understands only /dev/mapper device names.
 
 .I Example
-.br
 .nf
 # lvcreate --type vdo -L10G -V20G -n vdo0 vg/vdopool0
 # mkfs.ext4 -E nodiscard /dev/vg/vdo0
@@ -219,12 +194,16 @@ Note: \fBvdostats\fP(8) currently understands only /dev/mapper device names.
   data blocks used                    : 79
   ...
 .fi
-
 .SS 6. Extending VDOPoolLV size
-
 Adding more space to hold VDO data and metadata can be made via
 extension of VDODataLV with commands
 \fBlvresize\fP(8), \fBlvextend\fP(8).
+Extension needs to add at least one new VDO slab which can be
+configured with \fBallocation/vdo_slab_size_mb\fP setting.
+
+User can also enable automatic size extension of monitored VDOPoolLV
+with \fBactivation/vdo_pool_autoextend_percent\fP and
+\fBactivation/vdo_pool_autoextend_threshold\fP settings.
 
 Note: Size of VDOPoolLV cannot be reduced.
 
@@ -235,15 +214,12 @@ Note: Size of cached VDOPoolLV cannot be changed.
 .fi
 
 .I Example
-.br
 .nf
 # lvextend -L+50G vg/vdopool0
 # lvresize -L300G vg/vdopool1
 .fi
-
 .SS 7. Extending or reducing VDOLV size
-
-VDO LV can be extended or reduced as standard LV with commands
+Virtual VDO LV can be extended or reduced as standard LV with commands
 \fBlvresize\fP(8), \fBlvextend\fP(8), \fBlvreduce\fP(8).
 
 Note: Reduction needs to process TRIM for reduced disk area
@@ -256,79 +232,61 @@ a long time.
 .fi
 
 .I Example
-.br
 .nf
 # lvextend -L+50G vg/vdo0
 # lvreduce -L-50G vg/vdo1
 # lvresize -L200G vg/vdo2
 .fi
-
 .SS 8. Component activation of VDODataLV
-
 VDODataLV can be activated separately as component LV for examination
 purposes. It activates data LV in read-only mode and cannot be modified.
 If the VDODataLV is active as component, any upper LV using this volume CANNOT
 be activated. User has to deactivate VDODataLV first to continue to use VDOPoolLV.
 
 .I Example
-.br
 .nf
 # lvchange -ay vg/vpool0_vdata
 # lvchange -an vg/vpool0_vdata
 .fi
-
-
-.SH VDO Topics
-
+.SH VDO TOPICS
 .SS 1. Stacking VDO
-
-User can convert/stack VDO with existing volumes.
-
-.SS 2. VDO on top of raid
-
-Using Raid type LV for VDO Data LV.
+User can convert/stack VDOPooLV with these currently supported
+volume types: linear, stripe, raid and cache with cachepool
+.SS 2. VDOPoolLV on top of raid
+Using raid type LV for VDODataLV.
 
 .I Example
-.br
 .nf
-# lvcreate --type raid1 -L 5G -n vpool vg
-# lvconvert --type vdo-pool -V 10G vg/vpool
+# lvcreate --type raid1 -L 5G -n vdopool vg
+# lvconvert --type vdo-pool -V 10G vg/vdopool
 .fi
-
 .SS 3. Caching VDODataLV, VDOPoolLV
-
-VDO Pool LV (accepts also VDOPoolLV) caching provides mechanism
+VDODataLV (accepts also VDOPoolLV) caching provides mechanism
 to accelerate read and write of already compressed and deduplicated
-blocks together with vdo metadata.
+data blocks together with VDO metadata.
 
-Cached VDO Data LV cannot be currently resized (also automatic
-resize will not work).
+Cached VDO data LV cannot be currently resized and also the threshold
+based automatic resize will not work.
 
 .I Example
-.br
 .nf
-# lvcreate --type vdo -L 5G -V 10G -n vdo1 vg/vpool
-# lvcreate --type cache-pool -L 1G -n cpool vg
-# lvconvert --cache --cachepool vg/cpool vg/vpool
-# lvconvert --uncache vg/vpool
+# lvcreate --type vdo -L 5G -V 10G -n vdo1 vg/vdopool
+# lvcreate --type cache-pool -L 1G -n cachepool vg
+# lvconvert --cache --cachepool vg/cachepool vg/vdopool
+# lvconvert --uncache vg/vdopool
 .fi
-
 .SS 4. Caching VDOLV
-
 VDO LV cache allow users to 'cache' device for better perfomance before
 it hits processing of VDO Pool LV layer.
 
 .I Example
-.br
 .nf
-# lvcreate -L 5G -V 10G -n vdo1 vg/vpool
-# lvcreate --type cache-pool -L 1G -n cpool vg
-# lvconvert --cache --cachepool vg/cpool vg/vdo1
+# lvcreate -L 5G -V 10G -n vdo1 vg/vdopool
+# lvcreate --type cache-pool -L 1G -n cachepool vg
+# lvconvert --cache --cachepool vg/cachepool vg/vdo1
 # lvconvert --uncache vg/vdo1
 .fi
-
 .SS 5. Usage of Discard/TRIM with VDOLV
-
 User can discard data in VDO LV and reduce used blocks in VDOPoolLV.
 However present performance of discard operation is still not optimal
 and takes considerable amount of time and CPU.
@@ -342,10 +300,53 @@ provisioning in other regions of VDO LV.
 For the same reason, user should avoid using mkfs with discard for
 freshly created VDO LV to save a lot of time this operation would
 take otherwise as device after create empty.
-
-.br
-
-\&
+.SS 6. Memory usage
+VDO target requires 370 MiB of RAM plus an additional 268 MiB
+per each 1 TiB of physical storage managed by the volume.
+
+UDS requires a minimum of 250 MiB of RAM,
+which is also the default amount that deduplication uses.
+
+The memory required for the UDS index is determined by the index type
+and the required size of the deduplication window and
+is controled by \fBallocation/vdo_use_sparse_index\fP setting.
+
+With enabled UDS sparse indexing it relies on the temporal locality of data
+and attempts to retain only the most relevant index entries in memory and
+can maintain a deduplication window that is ten times larger
+than with dense while using the same amount of memory.
+
+Although the sparse index provides the greatest coverage,
+the dense index provides more deduplication advice.
+For most workloads, given the same amount of memory,
+the difference in deduplication rates between dense
+and sparse indexes is negligible.
+
+Dense index with 1 GiB of RAM maintains 1 TiB deduplication window,
+while sparse index with 1 GiB of RAM maintains 10 TiB deduplication window.
+In general 1 GiB is sufficient for 4 TiB or physical space with
+dense index and 40 TiB with sparse index.
+.SS 7. Storage space requirements
+User can configure a VDOPoolLV to use up to 256 TiB of physical storage.
+Only a certain part of the physical storage is usable to store data.
+This section provides the calculations to determine the usable size
+of a VDO-managed volume.
+
+VDO target requires storage for two types of VDO metadata and for the UDS index:
+.TP
+\(bu
+The first type of VDO metadata uses approximately 1 MiB for each 4 GiB
+of physical storage plus an additional 1 MiB per slab.
+.TP
+\(bu
+The second type of VDO metadata consumes approximately 1.25 MiB
+for each 1 GiB of logical storage, rounded up to the nearest slab.
+.TP
+\(bu
+The amount of storage required for the UDS index depends on the type of index
+and the amount of RAM allocated to the index. For each 1 GiB of RAM,
+a dense UDS index uses 17 GiB of storage and a sparse UDS index will use
+170 GiB of storage.
 
 .SH SEE ALSO
 .BR lvm (8),


