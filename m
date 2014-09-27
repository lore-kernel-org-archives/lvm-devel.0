From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat, 27 Sep 2014 13:11:10 +0000 (UTC)
Subject: master - Revert "man: lvmthin should use clearer thin pool options"
Message-ID: <20140927131110.D7E056115C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=17a1869df506a3641d49d52c413b5bc04ec2adc9
Commit:        17a1869df506a3641d49d52c413b5bc04ec2adc9
Parent:        95df06d721048f7089fd46ca5332f75ec64a8cb5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Sep 27 15:08:31 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Sep 27 15:08:31 2014 +0200

Revert "man: lvmthin should use clearer thin pool options"

Revert: --cachepool  and --thipnpool is the right way

they both take arg

This is a major difference from  --cache   and --thin
---
 man/lvmthin.7.in |   50 +++++++++++++++++++-------------------------------
 1 files changed, 19 insertions(+), 31 deletions(-)

diff --git a/man/lvmthin.7.in b/man/lvmthin.7.in
index 30a31d1..6652f7e 100644
--- a/man/lvmthin.7.in
+++ b/man/lvmthin.7.in
@@ -129,11 +129,11 @@ ThinMetaLV is renamed to hidden ThinPoolLV_tmeta.
 The new ThinPoolLV takes the previous name of ThinDataLV.
 .fi
 
-.B lvconvert \-\-type thin-pool \-\-poolmetadata VG/ThinMetaLV VG/ThinDataLV
+.B lvconvert \-\-thinpool VG/ThinDataLV \-\-poolmetadata VG/ThinMetaLV
 
 .I Example
 .br
-# lvconvert \-\-type thin-pool \-\-poolmetadata vg/pool0meta vg/pool0
+# lvconvert \-\-thinpool vg/pool0 \-\-poolmetadata vg/pool0meta
 
 # lvs vg/pool0
   LV    VG Attr       LSize  Pool Origin Data% Meta%
@@ -286,14 +286,14 @@ to use fast devices for the metadata LV.
 .br
 .B lvcreate \-n ThinMetaLV \-L SmallSize VG SmallPV
 .br
-.B lvconvert \-\-type thin\-pool \-\-poolmetadata VG/ThinMetaLV VG/ThinDataLV
+.B lvconvert \-\-thinpool VG/ThinDataLV \-\-poolmetadata VG/ThinMetaLV
 
 .I Example
 .br
 .nf
 # lvcreate \-n pool0 \-L 10G vg /dev/sdA
 # lvcreate \-n pool0meta \-L 1G vg /dev/sdB
-# lvconvert \-\-type thin\-pool \-\-poolmetadata vg/pool0meta vg/pool0
+# lvconvert \-\-thinpool vg/pool0 \-\-poolmetadata vg/pool0meta
 .fi
 
 .BR lvm.conf (5)
@@ -314,14 +314,14 @@ pool metadata LV.  This is especially recommended for pool metadata LVs.
 .br
 .B lvcreate \-\-type raid1 \-m 1 \-n ThinDataLV \-L LargeSize VG PVC PVD
 .br
-.B lvconvert \-\-type thin\-pool \-\-poolmetadata VG/ThinMetaLV VG/ThinDataLV
+.B lvconvert \-\-thinpool VG/ThinDataLV \-\-poolmetadata VG/ThinMetaLV
 
 .I Example
 .br
 .nf
 # lvcreate \-\-type raid1 \-m 1 \-n pool0 \-L 10G vg /dev/sdA /dev/sdB
 # lvcreate \-\-type raid1 \-m 1 \-n pool0meta \-L 1G vg /dev/sdC /dev/sdD
-# lvconvert \-\-type thin\-pool \-\-poolmetadata vg/pool0meta vg/pool0
+# lvconvert \-\-thinpool vg/pool0 \-\-poolmetadata vg/pool0meta
 .fi
 
 
@@ -348,7 +348,7 @@ explicitly.
 .nf
 # lvcreate \-n pool0 \-L 10G vg
 # lvcreate \-n pool0meta \-L 1G vg
-# lvconvert \-\-type thin\-pool \-\-poolmetadata vg/pool0meta vg/pool0
+# lvconvert \-\-thinpool vg/pool0 \-\-poolmetadata vg/pool0meta
 
 # lvs \-a
   [lvol0_pmspare] vg          ewi-------  10.00g
@@ -430,13 +430,13 @@ create a metadata LV from the same VG.
 
 .B lvcreate \-n ThinDataLV \-L LargeSize VG
 .br
-.B lvconvert \-\-type thin\-pool VG/ThinDataLV
+.B lvconvert \-\-thinpool VG/ThinDataLV
 
 .I Example
 .br
 .nf
 # lvcreate \-n pool0 \-L 10G vg
-# lvconvert \-\-type thin\-pool vg/pool0
+# lvconvert \-\-thinpool vg/pool0
 
 # lvs \-a
   pool0           vg          twi-a-tz--  10.00g
@@ -772,11 +772,10 @@ indicated by the "z" attribute displayed by lvs.  The option \-Z
 
 Command to set the zeroing mode when creating a thin pool LV:
 .br
-.B lvconvert \-\-type thin\-pool \-Z{y|n}
+.B lvconvert \-Z{y|n} \-\-thinpool VG/ThinDataLV
 .br
-.RS
-.B \-\-poolmetadata VG/ThinMetaLV VG/ThinDataLV
-.RE
+.B "   "  \-\-poolmetadata VG/ThinMetaLV
+
 
 Command to change the zeroing mode of an existing thin pool LV:
 .br
@@ -820,7 +819,7 @@ Command to set the discard mode when creating a thin pool LV:
 .B lvconvert \-\-discards {ignore|nopassdown|passdown}
 .br
 .RS
-.B \-\-type thin\-pool \-\-poolmetadata VG/ThinMetaLV VG/ThinDataLV
+.B \-\-thinpool VG/ThinDataLV \-\-poolmetadata VG/ThinMetaLV
 .RE
 
 Command to change the discard mode of an existing thin pool LV:
@@ -967,16 +966,12 @@ rather than using lvconvert on existing LVs.
 This one command creates a thin data LV, a thin metadata LV,
 and combines the two into a thin pool LV.
 
-.B lvcreate \-\-type thin\-pool \-L LargeSize VG/ThinPoolLV
-
-./" FIXME: make this work
-./" or using standard form of lvcreate:
-./" .B lvcreate \-\-type thin\-pool \-L LargeSize \-n ThinPoolLV VG
+.B lvcreate \-L LargeSize \-\-thinpool VG/ThinPoolLV
 
 .I Example
 .br
 .nf
-# lvcreate \-\-type thin\-pool \-L8M vg/pool0
+# lvcreate \-L8M \-\-thinpool vg/pool0
 
 # lvs vg/pool0
   LV    VG  Attr       LSize Pool Origin Data%
@@ -1002,17 +997,13 @@ and creates a thin LV in the new pool.
 .br
 \-V VirtualSize specifies the virtual size of the thin LV.
 
-.B lvcreate \-V VirtualSize \-L LargeSize
-.RS
-.B \-n ThinLV \-\-thinpool VG/ThinPoolLV
-.RE
-
-./" FIXME: make this work
-./" lvcreate \-\-type thin\-pool \-V VirtualSize \-L LargeSize \-n ThinLV VG/ThinPoolLV
+.B lvcreate \-L LargeSize \-V VirtualSize \-n ThinLV
+.br
+.B "   "  \-\-thinpool VG/ThinPoolLV
 
 Equivalent to:
 .br
-.B lvcreate \-\-type thin\-pool \-L LargeSize VG/ThinPoolLV
+.B lvcreate \-L LargeSize \-\-thinpool VG/ThinPoolLV
 .br
 .B lvcreate \-n ThinLV \-V VirtualSize \-\-thinpool VG/ThinPoolLV
 
@@ -1021,9 +1012,6 @@ Equivalent to:
 .nf
 # lvcreate \-L8M \-V2G \-n thin1 \-\-thinpool vg/pool0
 
-./" FIXME: change to
-./" lvcreate \-\-type thin\-pool \-L8M \-V2G \-n thin1 vg/pool0
-
 # lvs \-a
   pool0           vg          twi-a-tz--   8.00m
   [pool0_tdata]   vg          Twi-ao----   8.00m


