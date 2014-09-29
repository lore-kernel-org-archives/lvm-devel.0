From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 29 Sep 2014 17:28:39 +0000 (UTC)
Subject: master - Revert "Revert "man: lvmthin should use clearer thin pool options""
Message-ID: <20140929172839.4433A60EF4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9646c3359f89840dd05560d0adfab99f337d81f3
Commit:        9646c3359f89840dd05560d0adfab99f337d81f3
Parent:        d1be66ba3708c23a20c2062ff63b0240531caa31
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Sep 29 12:26:16 2014 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Sep 29 12:26:16 2014 -0500

Revert "Revert "man: lvmthin should use clearer thin pool options""

This reverts commit 17a1869df506a3641d49d52c413b5bc04ec2adc9.

We've agreed on the clearer syntax.
---
 man/lvmthin.7.in |   50 +++++++++++++++++++++++++++++++-------------------
 1 files changed, 31 insertions(+), 19 deletions(-)

diff --git a/man/lvmthin.7.in b/man/lvmthin.7.in
index 6652f7e..30a31d1 100644
--- a/man/lvmthin.7.in
+++ b/man/lvmthin.7.in
@@ -129,11 +129,11 @@ ThinMetaLV is renamed to hidden ThinPoolLV_tmeta.
 The new ThinPoolLV takes the previous name of ThinDataLV.
 .fi
 
-.B lvconvert \-\-thinpool VG/ThinDataLV \-\-poolmetadata VG/ThinMetaLV
+.B lvconvert \-\-type thin-pool \-\-poolmetadata VG/ThinMetaLV VG/ThinDataLV
 
 .I Example
 .br
-# lvconvert \-\-thinpool vg/pool0 \-\-poolmetadata vg/pool0meta
+# lvconvert \-\-type thin-pool \-\-poolmetadata vg/pool0meta vg/pool0
 
 # lvs vg/pool0
   LV    VG Attr       LSize  Pool Origin Data% Meta%
@@ -286,14 +286,14 @@ to use fast devices for the metadata LV.
 .br
 .B lvcreate \-n ThinMetaLV \-L SmallSize VG SmallPV
 .br
-.B lvconvert \-\-thinpool VG/ThinDataLV \-\-poolmetadata VG/ThinMetaLV
+.B lvconvert \-\-type thin\-pool \-\-poolmetadata VG/ThinMetaLV VG/ThinDataLV
 
 .I Example
 .br
 .nf
 # lvcreate \-n pool0 \-L 10G vg /dev/sdA
 # lvcreate \-n pool0meta \-L 1G vg /dev/sdB
-# lvconvert \-\-thinpool vg/pool0 \-\-poolmetadata vg/pool0meta
+# lvconvert \-\-type thin\-pool \-\-poolmetadata vg/pool0meta vg/pool0
 .fi
 
 .BR lvm.conf (5)
@@ -314,14 +314,14 @@ pool metadata LV.  This is especially recommended for pool metadata LVs.
 .br
 .B lvcreate \-\-type raid1 \-m 1 \-n ThinDataLV \-L LargeSize VG PVC PVD
 .br
-.B lvconvert \-\-thinpool VG/ThinDataLV \-\-poolmetadata VG/ThinMetaLV
+.B lvconvert \-\-type thin\-pool \-\-poolmetadata VG/ThinMetaLV VG/ThinDataLV
 
 .I Example
 .br
 .nf
 # lvcreate \-\-type raid1 \-m 1 \-n pool0 \-L 10G vg /dev/sdA /dev/sdB
 # lvcreate \-\-type raid1 \-m 1 \-n pool0meta \-L 1G vg /dev/sdC /dev/sdD
-# lvconvert \-\-thinpool vg/pool0 \-\-poolmetadata vg/pool0meta
+# lvconvert \-\-type thin\-pool \-\-poolmetadata vg/pool0meta vg/pool0
 .fi
 
 
@@ -348,7 +348,7 @@ explicitly.
 .nf
 # lvcreate \-n pool0 \-L 10G vg
 # lvcreate \-n pool0meta \-L 1G vg
-# lvconvert \-\-thinpool vg/pool0 \-\-poolmetadata vg/pool0meta
+# lvconvert \-\-type thin\-pool \-\-poolmetadata vg/pool0meta vg/pool0
 
 # lvs \-a
   [lvol0_pmspare] vg          ewi-------  10.00g
@@ -430,13 +430,13 @@ create a metadata LV from the same VG.
 
 .B lvcreate \-n ThinDataLV \-L LargeSize VG
 .br
-.B lvconvert \-\-thinpool VG/ThinDataLV
+.B lvconvert \-\-type thin\-pool VG/ThinDataLV
 
 .I Example
 .br
 .nf
 # lvcreate \-n pool0 \-L 10G vg
-# lvconvert \-\-thinpool vg/pool0
+# lvconvert \-\-type thin\-pool vg/pool0
 
 # lvs \-a
   pool0           vg          twi-a-tz--  10.00g
@@ -772,10 +772,11 @@ indicated by the "z" attribute displayed by lvs.  The option \-Z
 
 Command to set the zeroing mode when creating a thin pool LV:
 .br
-.B lvconvert \-Z{y|n} \-\-thinpool VG/ThinDataLV
+.B lvconvert \-\-type thin\-pool \-Z{y|n}
 .br
-.B "   "  \-\-poolmetadata VG/ThinMetaLV
-
+.RS
+.B \-\-poolmetadata VG/ThinMetaLV VG/ThinDataLV
+.RE
 
 Command to change the zeroing mode of an existing thin pool LV:
 .br
@@ -819,7 +820,7 @@ Command to set the discard mode when creating a thin pool LV:
 .B lvconvert \-\-discards {ignore|nopassdown|passdown}
 .br
 .RS
-.B \-\-thinpool VG/ThinDataLV \-\-poolmetadata VG/ThinMetaLV
+.B \-\-type thin\-pool \-\-poolmetadata VG/ThinMetaLV VG/ThinDataLV
 .RE
 
 Command to change the discard mode of an existing thin pool LV:
@@ -966,12 +967,16 @@ rather than using lvconvert on existing LVs.
 This one command creates a thin data LV, a thin metadata LV,
 and combines the two into a thin pool LV.
 
-.B lvcreate \-L LargeSize \-\-thinpool VG/ThinPoolLV
+.B lvcreate \-\-type thin\-pool \-L LargeSize VG/ThinPoolLV
+
+./" FIXME: make this work
+./" or using standard form of lvcreate:
+./" .B lvcreate \-\-type thin\-pool \-L LargeSize \-n ThinPoolLV VG
 
 .I Example
 .br
 .nf
-# lvcreate \-L8M \-\-thinpool vg/pool0
+# lvcreate \-\-type thin\-pool \-L8M vg/pool0
 
 # lvs vg/pool0
   LV    VG  Attr       LSize Pool Origin Data%
@@ -997,13 +1002,17 @@ and creates a thin LV in the new pool.
 .br
 \-V VirtualSize specifies the virtual size of the thin LV.
 
-.B lvcreate \-L LargeSize \-V VirtualSize \-n ThinLV
-.br
-.B "   "  \-\-thinpool VG/ThinPoolLV
+.B lvcreate \-V VirtualSize \-L LargeSize
+.RS
+.B \-n ThinLV \-\-thinpool VG/ThinPoolLV
+.RE
+
+./" FIXME: make this work
+./" lvcreate \-\-type thin\-pool \-V VirtualSize \-L LargeSize \-n ThinLV VG/ThinPoolLV
 
 Equivalent to:
 .br
-.B lvcreate \-L LargeSize \-\-thinpool VG/ThinPoolLV
+.B lvcreate \-\-type thin\-pool \-L LargeSize VG/ThinPoolLV
 .br
 .B lvcreate \-n ThinLV \-V VirtualSize \-\-thinpool VG/ThinPoolLV
 
@@ -1012,6 +1021,9 @@ Equivalent to:
 .nf
 # lvcreate \-L8M \-V2G \-n thin1 \-\-thinpool vg/pool0
 
+./" FIXME: change to
+./" lvcreate \-\-type thin\-pool \-L8M \-V2G \-n thin1 vg/pool0
+
 # lvs \-a
   pool0           vg          twi-a-tz--   8.00m
   [pool0_tdata]   vg          Twi-ao----   8.00m


