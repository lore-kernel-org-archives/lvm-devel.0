From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 19 Aug 2020 13:09:41 +0000 (GMT)
Subject: master - man: vdo improvals
Message-ID: <20200819130941.035753857C54@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3e9664bacad3b31f074d58ff5ae8e2403a7ba9d0
Commit:        3e9664bacad3b31f074d58ff5ae8e2403a7ba9d0
Parent:        7b41ea61b2e33dbfad754fd4c6e7851faf7ca5ef
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jul 22 00:41:35 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Aug 19 15:09:09 2020 +0200

man: vdo improvals

Add some more notes about discard.
Correct enumeration.
---
 WHATS_NEW         |  1 +
 man/lvmvdo.7_main | 54 +++++++++++++++++++++++++++++++++++++++---------------
 2 files changed, 40 insertions(+), 15 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 05d9c0ac9..f3cb50692 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.11 - 
 ==================================
+  Update lvmvdo man page and better explain DISCARD usage.
 
 Version 2.03.10 - 09th August 2020
 ==================================
diff --git a/man/lvmvdo.7_main b/man/lvmvdo.7_main
index 582f7a879..ab9a27811 100644
--- a/man/lvmvdo.7_main
+++ b/man/lvmvdo.7_main
@@ -1,7 +1,7 @@
 .TH "LVMVDO" "7" "LVM TOOLS #VERSION#" "Red Hat, Inc" "\""
 
 .SH NAME
-lvmvdo \(em EXPERIMENTAL LVM Virtual Data Optimizer support
+lvmvdo \(em LVM Virtual Data Optimizer support
 
 .SH DESCRIPTION
 
@@ -86,14 +86,14 @@ The primary methods for using VDO with lvm2:
 
 .SS 1. Create VDOPoolLV with VDOLV
 
-Create an VDOPoolLV that will holds VDO data together with
+Create a VDOPoolLV that will hold VDO data together with
 virtual size VDOLV, that user can use. When the virtual size
 is not specified, then such LV is created with maximum size that
 always fits into data volume even if there cannot happen any
 deduplication and compression
 (i.e. it can hold uncompressible content of /dev/urandom).
-When the name of VDOPoolLV is not specified, it tales name from
-sequence of vpool0, vpool1 ...
+When the name of VDOPoolLV is not specified, it is taken from
+the sequence of vpool0, vpool1 ...
 
 Note: As the performance of TRIM/Discard operation is slow for large
 volumes of VDO type, please try to avoid sending discard requests unless
@@ -112,7 +112,7 @@ operation.
 # mkfs.ext4 -E nodiscard /dev/vg/vdo0
 .fi
 
-.SS 2. Create VDOPoolLV and convert existing LV into VDODataLV
+.SS 2. Create VDOPoolLV from conversion of an existing LV into VDODataLV
 
 Convert an already created/existing LV into a volume that can hold
 VDO data and metadata (a volume reference by VDOPoolLV).
@@ -120,7 +120,7 @@ User will be prompted to confirm such conversion as it is \fBIRREVERSIBLY
 DESTROYING\fP content of such volume, as it's being immediately
 formatted by \fBvdoformat\fP(8) as VDO pool data volume. User can
 specify virtual size of associated VDOLV with this VDOPoolLV.
-When the virtual size is not specified, it will set to the maximum size
+When the virtual size is not specified, it will be set to the maximum size
 that can keep 100% uncompressible data there.
 
 .nf
@@ -134,9 +134,9 @@ that can keep 100% uncompressible data there.
 # lvconvert --type vdo-pool -n vdo0 -V10G vg/existinglv
 .fi
 
-.SS 3. Change default setting used for creating VDOPoolLV
+.SS 3. Change default settings used for creating VDOPoolLV
 
-VDO allows to set large variety of option. Lots of these setting
+VDO allows to set large variety of options. Lots of these settings
 can be specified by lvm.conf or profile settings. User can prepare
 number of different profiles and just specify profile file name.
 Check output of \fBlvmconfig --type full\fP for detailed description
@@ -189,7 +189,7 @@ Disable or enable compression and deduplication for VDO pool LV
 # lvchange --deduplication y vg/vdpool1
 .fi
 
-.SS 4. Checking usage of VDOPoolLV
+.SS 5. Checking usage of VDOPoolLV
 
 To quickly check how much data of VDOPoolLV are already consumed
 use \fBlvs\fP(8). Field Data% will report how much data occupies
@@ -219,7 +219,7 @@ Note: \fBvdostats\fP(8) currently understands only /dev/mapper device names.
   ...
 .fi
 
-.SS 4. Extending VDOPoolLV size
+.SS 6. Extending VDOPoolLV size
 
 Adding more space to hold VDO data and metadata can be made via
 extension of VDODataLV with commands
@@ -227,6 +227,8 @@ extension of VDODataLV with commands
 
 Note: Size of VDOPoolLV cannot be reduced.
 
+Note: Size of cached VDOPoolLV cannot be changed.
+
 .nf
 .B lvextend -L+AddingSize VG/VDOPoolLV
 .fi
@@ -238,7 +240,7 @@ Note: Size of VDOPoolLV cannot be reduced.
 # lvresize -L300G vg/vdopool1
 .fi
 
-.SS 4. Extending or reducing VDOLV size
+.SS 7. Extending or reducing VDOLV size
 
 VDO LV can be extended or reduced as standard LV with commands
 \fBlvresize\fP(8), \fBlvextend\fP(8), \fBlvreduce\fP(8).
@@ -260,7 +262,7 @@ a long time.
 # lvresize -L200G vg/vdo2
 .fi
 
-.SS 5. Component activation of VDODataLV
+.SS 8. Component activation of VDODataLV
 
 VDODataLV can be activated separately as component LV for examination
 purposes. It activates data LV in read-only mode and cannot be modified.
@@ -294,7 +296,12 @@ Using Raid type LV for VDO Data LV.
 
 .SS 3. Caching VDODataLV, VDOPoolLV
 
-Cache VDO Data LV (accepts also VDOPoolLV.
+VDO Pool LV (accepts also VDOPoolLV) caching provides mechanism
+to accelerate read and write of already compressed and deduplicated
+blocks together with vdo metadata.
+
+Cached VDO Data LV cannot be currently resized (also automatic
+resize will not work).
 
 .I Example
 .br
@@ -305,9 +312,10 @@ Cache VDO Data LV (accepts also VDOPoolLV.
 # lvconvert --uncache vg/vpool
 .fi
 
-.SS 3. Caching VDOLV
+.SS 4. Caching VDOLV
 
-Cache VDO LV.
+VDO LV cache allow users to 'cache' device for better perfomance before
+it hits processing of VDO Pool LV layer.
 
 .I Example
 .br
@@ -318,6 +326,22 @@ Cache VDO LV.
 # lvconvert --uncache vg/vdo1
 .fi
 
+.SS 5. Usage of Discard/TRIM with VDOLV
+
+User can discard data in VDO LV and reduce used blocks in VDOPoolLV.
+However present performance of discard operation is still not optimal
+and takes considerable amount of time and CPU.
+So unless it's really needed users should avoid usage of discard.
+
+When block device is going to be rewritten,
+block will be automatically reused for new data.
+Discard is useful in situation, when it is known the given portion of a VDO LV
+is not going to be used and the discarded space can be used for block
+provisioning in other regions of VDO LV.
+For the same reason, user should avoid using mkfs with discard for
+freshly created VDO LV to save a lot of time this operation would
+take otherwise as device after create empty.
+
 .br
 
 \&


