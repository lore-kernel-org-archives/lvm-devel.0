From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 22 Jan 2019 08:36:29 -0500
Subject: master - vdo: some formating updates
Message-ID: <201901221336.x0MDaTPY032593@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2264399b0df9a5f81449fcabca891557a2df4026
Commit:        2264399b0df9a5f81449fcabca891557a2df4026
Parent:        105a8edea1c4a77cc3681a7cc46a6a5c02656c5c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jan 22 14:27:55 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jan 22 14:35:47 2019 +0100

vdo: some formating updates

---
 man/lvmvdo.7_main |   26 ++++++++++++++++----------
 1 files changed, 16 insertions(+), 10 deletions(-)

diff --git a/man/lvmvdo.7_main b/man/lvmvdo.7_main
index 11ca3ac..ae507df 100644
--- a/man/lvmvdo.7_main
+++ b/man/lvmvdo.7_main
@@ -5,7 +5,6 @@ lvmvdo \(em EXPERIMENTAL LVM Virtual Data Optimizer support
 
 .SH DESCRIPTION
 
-
 VDO (which includes kvdo and vdo) is software that provides inline
 block-level deduplication, compression, and thin provisioning capabilities
 for primary storage.
@@ -179,7 +178,9 @@ EOF
 Disable or enable compression and deduplication for VDO pool LV
 (the volume that maintains all VDO LV(s) associated with it).
 
+.nf
 .B lvchange --compression [y|n] --deduplication [y|n] VG/VDOPoolLV
+.fi
 
 .I Example
 .br
@@ -196,7 +197,7 @@ content of virtual data for VDOLV and how much space is already
 consumed with all the data and metadata blocks in VDOPoolLV.
 For a detailed description use \fBvdostats\fP(8) command.
 
-Note: vdostats currently understands only /dev/mapper device names.
+Note: \fBvdostats\fP(8) currently understands only /dev/mapper device names.
 
 .I Example
 .br
@@ -216,17 +217,19 @@ Note: vdostats currently understands only /dev/mapper device names.
   release version                     : 133524
   data blocks used                    : 79
   ...
-
 .fi
 
 .SS 4. Extending VDOPoolLV size
 
 Adding more space to hold VDO data and metadata can be made via
-extension of VDODataLV.
+extension of VDODataLV with commands
+\fBlvresize\fP(8), \fBlvextend\fP(8).
 
 Note: Size of VDOPoolLV cannot be reduced.
 
+.nf
 .B lvextend -L+AddingSize VG/VDOPoolLV
+.fi
 
 .I Example
 .br
@@ -237,14 +240,17 @@ Note: Size of VDOPoolLV cannot be reduced.
 
 .SS 4. Extending or reducing VDOLV size
 
-VDO LV can be extended or reduced as standard LV.
+VDO LV can be extended or reduced as standard LV with commands
+\fBlvresize\fP(8), \fBlvextend\fP(8), \fBlvreduce\fP(8).
 
 Note: Reduction needs to process TRIM for reduced disk area
 to unmap used data blocks from VDOPoolLV and it may take
 a long time.
 
+.nf
 .B lvextend -L+AddingSize VG/VDOLV
 .B lvreduce -L-ReducingSize VG/VDOLV
+.fi
 
 .I Example
 .br
@@ -254,9 +260,7 @@ a long time.
 # lvresize -L200G vg/vdo2
 .fi
 
-
 .SH VDO Topics
-
 .br
 
 \&
@@ -269,9 +273,11 @@ a long time.
 .BR lvconvert (8),
 .BR lvchange (8),
 .BR lvextend (8),
+.BR lvreduce (8),
+.BR lvresize (8),
 .BR lvremove (8),
 .BR lvs (8),
 .BR vdo (8),
-.BR vdoformat (8)
-.BR vdostats (8)
-
+.BR vdoformat (8),
+.BR vdostats (8),
+.BR mkfs (8)


