From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 11 Jun 2014 09:11:40 +0000 (UTC)
Subject: master - man: update lvmthin
Message-ID: <20140611091140.CC01260EE7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d13efac51b7a191e02106fcf467b64f3929eeb2d
Commit:        d13efac51b7a191e02106fcf467b64f3929eeb2d
Parent:        e1568376360b3e0b0d640441909bc92056009143
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 10 23:58:45 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jun 11 11:10:55 2014 +0200

man: update lvmthin

Improve graphics form of page and use shorter correct and suggested
forms of thin pool manipulation commands.
---
 man/lvmthin.7.in |  258 +++++++++++++++++++++++++++++-------------------------
 1 files changed, 138 insertions(+), 120 deletions(-)

diff --git a/man/lvmthin.7.in b/man/lvmthin.7.in
index a2da3ca..7d2ef45 100644
--- a/man/lvmthin.7.in
+++ b/man/lvmthin.7.in
@@ -95,166 +95,177 @@ appears as a snapshot of another LV after creation
 
 The primary method for using lvm thin provisioning:
 
-.nf
-1. create ThinDataLV
+.SS 1. create ThinDataLV
 
-   Create an LV that will hold thin pool data.
+Create an LV that will hold thin pool data.
 
-   Command
-   lvcreate \-n ThinDataLV \-L LargeSize VG
+.B lvcreate \-n ThinDataLV \-L LargeSize VG
 
-   Example
-   # lvcreate \-n pool0 \-L 10G vg
+.I Example
+.br
+.B # lvcreate \-n pool0 \-L 10G vg
 
-2. create ThinMetaLV
+.SS 2. create ThinMetaLV
 
-   Create an LV that will hold thin pool metadata.
+Create an LV that will hold thin pool metadata.
 
-   Command
-   lvcreate \-n ThinMetaLV \-L SmallSize VG
+.B lvcreate \-n ThinMetaLV \-L SmallSize VG
 
-   Example
-   # lvcreate \-n pool0meta \-L 1G vg
+.I Example
+.br
+.B # lvcreate \-n pool0meta \-L 1G vg
 
-   # lvs
-   pool0     vg          -wi-a-----  10.00g
-   pool0meta vg          -wi-a-----   1.00g
+# lvs
+  LV        VG Attr       LSize
+  pool0     vg -wi-a----- 10.00g
+  pool0meta vg -wi-a----- 1.00g
 
-3. create ThinPoolLV
+.SS 3. create ThinPoolLV
 
-   Combine the data and metadata LVs into a thin pool LV.
-   ThinDataLV is renamed to hidden ThinPoolLV_tdata.
-   ThinMetaLV is renamed to hidden ThinPoolLV_tmeta.
-   The new ThinPoolLV takes the previous name of ThinDataLV.
+Combine the data and metadata LVs into a thin pool LV.
+ThinDataLV is renamed to hidden ThinPoolLV_tdata.
+ThinMetaLV is renamed to hidden ThinPoolLV_tmeta.
+The new ThinPoolLV takes the previous name of ThinDataLV.
 
-   Command
-   lvconvert \-\-thinpool VG/ThinDataLV \-\-poolmetadata VG/ThinMetaLV
+.B lvconvert \-\-thinpool VG/ThinDataLV \-\-poolmetadata VG/ThinMetaLV
 
-   Example
-   # lvconvert \-\-thinpool vg/pool0 \-\-poolmetadata vg/pool0meta
+.I Example
+.br
+.B # lvconvert \-\-thinpool vg/pool0 \-\-poolmetadata vg/pool0meta
 
-   # lvs vg/pool0
-   LV    VG  Attr       LSize  Pool Origin Data%
-   pool0 vg  twi-a-tz-- 10.00g               0.00
+# lvs vg/pool0
+  LV    VG Attr       LSize  Pool Origin Data% Meta%
+  pool0 vg twi-a-tz-- 10.00g      0.00   0.00
 
-   # lvs -a
-   pool0           vg          twi-a-tz--  10.00g
-   [pool0_tdata]   vg          Twi-ao----  10.00g
-   [pool0_tmeta]   vg          ewi-ao----   1.00g
+# lvs \-a
+  LV            VG Attr       LSize
+  pool0         vg twi-a-tz-- 10.00g
+  [pool0_tdata] vg Twi-ao---- 10.00g
+  [pool0_tmeta] vg ewi-ao---- 1.00g
 
-4. create ThinLV
+.SS 4. create ThinLV
 
-   Create a new thin LV from the thin pool LV.
-   The thin LV is created with a virtual size.
-   Multiple new thin LVs may be created in the thin pool.
-   Thin LV names must be unique in the VG.
-   The thinpool argument specifies which thin pool will
-   contain the ThinLV.
+Create a new thin LV from the thin pool LV.
+The thin LV is created with a virtual size.
+Multiple new thin LVs may be created in the thin pool.
+Thin LV names must be unique in the VG.
+The thinpool argument specifies which thin pool will
+contain the ThinLV.
 
-   Command
-   lvcreate \-\-type thin \-n ThinLV \-V VirtualSize \-\-thinpool VG/ThinPoolLV
+.B lvcreate \-n ThinLV \-V VirtualSize \-\-thinpool VG/ThinPoolLV
+.br
+.B lvcreate \-T \-n ThinLV \-V VirtualSize VG/ThinPoolLV
 
-   Example
-   Create a thin LV in a thin pool:
-   # lvcreate \-\-type thin \-n thin1 \-V 1T \-\-thinpool vg/pool0
+.I Example
+.br
+Create a thin LV in a thin pool:
+.br
+.B # lvcreate \-T \-n thin1 \-V 1T vg/pool0
 
-   Create another thin LV in the same thin pool:
-   # lvcreate \-\-type thin \-n thin2 \-V 1T \-\-thinpool vg/pool0
+Create another thin LV in the same thin pool:
+.br
+.B # lvcreate \-n thin2 \-V 1T \-\-thinpool vg/pool0
 
-   # lvs vg/thin1 vg/thin2
-   LV    VG  Attr       LSize Pool  Origin Data%
-   thin1 vg  Vwi-a-tz-- 1.00t pool0          0.00
-   thin2 vg  Vwi-a-tz-- 1.00t pool0          0.00
+# lvs vg/thin1 vg/thin2
+  LV    VG Attr       LSize Pool  Origin Data%
+  thin1 vg Vwi-a-tz-- 1.00t pool0        0.00
+  thin2 vg Vwi-a-tz-- 1.00t pool0        0.00
 
-5. create SnapLV
+.SS 5. create SnapLV
 
-   Create snapshots of an existing ThinLV or SnapLV.
+Create snapshots of an existing ThinLV or SnapLV.
+Do not \fBNOT\fP specify
+.BR \-L ", " \-\-size
+since this would not create thin snapshot, but old COW volume.
 
-   Command
-   lvcreate \-\-type thin \-n SnapLV \-s ThinLV \-\-thinpool VG/ThinPoolLV
-   lvcreate \-\-type thin \-n SnapLV \-s PrevSnapLV \-\-thinpool VG/ThinPoolLV
+.B lvcreate \-n SnapLV \-s VG/ThinLV
+.br
+.B lvcreate \-n SnapLV \-s VG/PrevSnapLV
 
-   Example
-   Create first snapshot of an existing ThinLV:
-   # lvcreate \-\-type thin \-n thin1s1 \-s thin1 \-\-thinpool vg/pool0
+.I Example
+.br
+Create first snapshot of an existing ThinLV:
+.br
+.B # lvcreate \-n thin1s1 \-s vg/thin1
 
-   Create second snapshot of the same ThinLV:
-   # lvcreate \-\-type thin \-n thin1s2 \-s thin1 \-\-thinpool vg/pool0
+Create second snapshot of the same ThinLV:
+.br
+.B # lvcreate \-n thin1s2 \-s vg/thin1
 
-   Create a snapshot of the first snapshot:
-   # lvcreate \-\-type thin \-n thin1s1s1 \-s thin1s1 \-\-thinpool vg/pool0
+Create a snapshot of the first snapshot:
+.br
+.B # lvcreate \-n thin1s1s1 \-s vg/thin1s1
 
-   # lvs vg/thin1s1 vg/thin1s2 vg/thin1s1s1
-   LV        VG  Attr       LSize Pool  Origin
-   thin1s1   vg  Vwi---tz-k 1.00t pool0 thin1
-   thin1s2   vg  Vwi---tz-k 1.00t pool0 thin1
-   thin1s1s1 vg  Vwi---tz-k 1.00t pool0 thin1s1
+# lvs vg/thin1s1 vg/thin1s2 vg/thin1s1s1
+  LV        VG Attr       LSize Pool  Origin
+  thin1s1   vg Vwi---tz-k 1.00t pool0 thin1
+  thin1s2   vg Vwi---tz-k 1.00t pool0 thin1
+  thin1s1s1 vg Vwi---tz-k 1.00t pool0 thin1s1
 
-6. activate SnapLV
 
-   Thin snapshots are created with the persistent "activation skip"
-   flag, indicated by the "k" attribute.  Use \-K with lvchange
-   or vgchange to activate thin snapshots with the "k" attribute.
+.SS 6. activate SnapLV
 
-   Command
-   lvchange \-ay \-K VG/SnapLV
+Thin snapshots are created with the persistent "activation skip"
+flag, indicated by the "k" attribute.  Use \-K with lvchange
+or vgchange to activate thin snapshots with the "k" attribute.
 
-   Example
-   # lvchange \-ay \-K vg/thin1s1
+.B lvchange \-ay \-K VG/SnapLV
 
-   # lvs vg/thin1s1
-   thin1s1 vg   Vwi-a-tz-k 1.00t pool0 thin1
-.fi
+.I Example
+.br
+.B # lvchange \-ay \-K vg/thin1s1
 
+# lvs vg/thin1s1
+  LV      VG Attr       LSize Pool  Origin
+  thin1s1 vg Vwi-a-tz-k 1.00t pool0 thin1
 
 .SH Thin Topics
 
-Specify devices for data and metadata LVs
-.br
-Tolerate device failures using raid
+.B Specify devices for data and metadata LVs
 .br
-Spare metadata LV
+.B Tolerate device failures using raid
 .br
-Metadata check and repair
+.B Spare metadata LV
 .br
-Automatic pool metadata LV
+.B Metadata check and repair
 .br
-Activation of thin snapshots
+.B Automatic pool metadata LV
 .br
-Removing thin pool LVs, thin LVs and snapshots
+.B Activation of thin snapshots
 .br
-Manually manage free data space of thin pool LV
+.B Removing thin pool LVs, thin LVs and snapshots
 .br
-Manually manage free metadata space of a thin pool LV
+.B Manually manage free data space of thin pool LV
 .br
-Using fstrim to increase free space in a thin pool LV
+.B Manually manage free metadata space of a thin pool LV
 .br
-Automatically extend thin pool LV
+.B Using fstrim to increase free space in a thin pool LV
 .br
-Data space exhaustion
+.B Automatically extend thin pool LV
 .br
-Metadata space exhaustion
+.B Data space exhaustion
 .br
-Zeroing
+.B Metadata space exhaustion
 .br
-Discard
+.B Zeroing
 .br
-Chunk size
+.B Discard
 .br
-Size of pool metadata LV
+.B Chunk size
 .br
-Create a thin snapshot of an external, read only LV
+.B Size of pool metadata LV
 .br
-Convert a standard LV to a thin LV with an external origin
+.B Create a thin snapshot of an external, read only LV
 .br
-Single step thin pool LV creation
+.B Convert a standard LV to a thin LV with an external origin
 .br
-Single step thin pool LV and thin LV creation
+.B Single step thin pool LV creation
 .br
-Merge thin snapshots
+.B Single step thin pool LV and thin LV creation
 .br
-XFS on snapshots
+.B Merge thin snapshots
 .br
+.B XFS on snapshots
 
 \&
 
@@ -267,22 +278,26 @@ separate physical devices.  To do that, specify the device name(s)
 at the end of the lvcreate line.  It can be especially helpful
 to use fast devices for the metadata LV.
 
-.nf
-lvcreate \-n ThinDataLV \-L LargeSize VG LargePV
-lvcreate \-n ThinMetaLV \-L SmallSize VG SmallPV
-lvconvert \-\-thinpool VG/ThinDataLV \-\-poolmetadata VG/ThinMetaLV
+.B lvcreate \-n ThinDataLV \-L LargeSize VG LargePV
+.br
+.B lvcreate \-n ThinMetaLV \-L SmallSize VG SmallPV
+.br
+.B lvconvert \-\-thinpool VG/ThinDataLV \-\-poolmetadata VG/ThinMetaLV
 
-Example
-# lvcreate \-n pool0 \-L 10G vg /dev/sdA
-# lvcreate \-n pool0meta \-L 1G vg /dev/sdB
-# lvconvert \-\-thinpool vg/pool0 \-\-poolmetadata vg/pool0meta
-.fi
+.I Example
+.br
+.B # lvcreate \-n pool0 \-L 10G vg /dev/sdA
+.br
+.B # lvcreate \-n pool0meta \-L 1G vg /dev/sdB
+.br
+.B # lvconvert \-\-thinpool vg/pool0 \-\-poolmetadata vg/pool0meta
 
 .BR lvm.conf (5)
 .B thin_pool_metadata_require_separate_pvs
 .br
 controls the default PV usage for thin pool creation.
 
+\&
 
 .SS Tolerate device failures using raid
 
@@ -291,16 +306,19 @@ controls the default PV usage for thin pool creation.
 To tolerate device failures, use raid for the pool data LV and
 pool metadata LV.  This is especially recommended for pool metadata LVs.
 
-.nf
-lvcreate \-\-type raid1 \-m 1 \-n ThinMetaLV \-L SmallSize VG PVA PVB
-lvcreate \-\-type raid1 \-m 1 \-n ThinDataLV \-L LargeSize VG PVC PVD
-lvconvert \-\-thinpool VG/ThinDataLV \-\-poolmetadata VG/ThinMetaLV
+.B lvcreate \-\-type raid1 \-m 1 \-n ThinMetaLV \-L SmallSize VG PVA PVB
+.br
+.B lvcreate \-\-type raid1 \-m 1 \-n ThinDataLV \-L LargeSize VG PVC PVD
+.br
+.B lvconvert \-\-thinpool VG/ThinDataLV \-\-poolmetadata VG/ThinMetaLV
 
-Example
-# lvcreate \-\-type raid1 \-m 1 \-n pool0 \-L 10G vg /dev/sdA /dev/sdB
-# lvcreate \-\-type raid1 \-m 1 \-n pool0meta \-L 1G vg /dev/sdC /dev/sdD
-# lvconvert \-\-thinpool vg/pool0 \-\-poolmetadata vg/pool0meta
-.fi
+.I Example
+.br
+.B # lvcreate \-\-type raid1 \-m 1 \-n pool0 \-L 10G vg /dev/sdA /dev/sdB
+.br
+.B # lvcreate \-\-type raid1 \-m 1 \-n pool0meta \-L 1G vg /dev/sdC /dev/sdD
+.br
+.B # lvconvert \-\-thinpool vg/pool0 \-\-poolmetadata vg/pool0meta
 
 
 .SS Spare metadata LV


