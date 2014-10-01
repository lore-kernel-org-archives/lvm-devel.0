From: David Teigland <teigland@fedoraproject.org>
Date: Wed,  1 Oct 2014 15:44:41 +0000 (UTC)
Subject: master - man: lvmthin mention alternate syntax
Message-ID: <20141001154441.69D0460F5F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d66f2574529ccce5fab2c217805504f6a8fe1673
Commit:        d66f2574529ccce5fab2c217805504f6a8fe1673
Parent:        33b96bef5bd8cfda3cf24007b84597f61a2cf0b6
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Oct 1 10:29:30 2014 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Oct 1 10:44:18 2014 -0500

man: lvmthin mention alternate syntax

Users will probably run across the alternate syntax,
so we should explain how it relates to what is used here.
---
 man/lvmthin.7.in |   78 ++++++++++++++++++++++++++++++++++-------------------
 1 files changed, 50 insertions(+), 28 deletions(-)

diff --git a/man/lvmthin.7.in b/man/lvmthin.7.in
index af9669d..8009a9e 100644
--- a/man/lvmthin.7.in
+++ b/man/lvmthin.7.in
@@ -152,7 +152,8 @@ Create a new thin LV from the thin pool LV.
 The thin LV is created with a virtual size.
 Multiple new thin LVs may be created in the thin pool.
 Thin LV names must be unique in the VG.
-The thinpool argument specifies which thin pool will
+The '--type thin' option is inferred from the virtual size option.
+The --thinpool argument specifies which thin pool will
 contain the ThinLV.
 .fi
 
@@ -225,6 +226,10 @@ or vgchange to activate thin snapshots with the "k" attribute.
 
 .SH Thin Topics
 
+.B Alternate syntax for specifying type thin\-pool
+.br
+.B Automatic pool metadata LV
+.br
 .B Specify devices for data and metadata LVs
 .br
 .B Tolerate device failures using raid
@@ -233,8 +238,6 @@ or vgchange to activate thin snapshots with the "k" attribute.
 .br
 .B Metadata check and repair
 .br
-.B Automatic pool metadata LV
-.br
 .B Activation of thin snapshots
 .br
 .B Removing thin pool LVs, thin LVs and snapshots
@@ -273,6 +276,50 @@ or vgchange to activate thin snapshots with the "k" attribute.
 
 \&
 
+.SS Alternate syntax for specifying type thin\-pool
+
+\&
+
+The fully specified syntax for creating a thin pool LV shown above is:
+
+.B lvconvert \-\-type thin-pool \-\-poolmetadata VG/ThinMetaLV VG/ThinDataLV
+
+An existing LV is converted to a thin pool by changing its type to
+thin-pool.  An alternate syntax may be used for the same operation:
+
+.B lvconvert \-\-thinpool VG/ThinDataLV \-\-poolmetadata VG/ThinMetaLV
+
+The thin-pool type is inferred by lvm; the --thinpool option is not an
+alias for --type thin-pool.  The use of the --thinpool option here is
+different from the use of the --thinpool option when creating a thin LV,
+where it specifies the pool in which the thin LV is created.
+
+
+.SS Automatic pool metadata LV
+
+\&
+
+A thin data LV can be converted to a thin pool LV without specifying a
+thin pool metadata LV.  LVM automatically creates a metadata LV from the
+same VG.
+
+.B lvcreate \-n ThinDataLV \-L LargeSize VG
+.br
+.B lvconvert \-\-type thin\-pool VG/ThinDataLV
+
+.I Example
+.br
+.nf
+# lvcreate \-n pool0 \-L 10G vg
+# lvconvert \-\-type thin\-pool vg/pool0
+
+# lvs \-a
+  pool0           vg          twi-a-tz--  10.00g
+  [pool0_tdata]   vg          Twi-ao----  10.00g
+  [pool0_tmeta]   vg          ewi-ao----  16.00m
+.fi
+
+
 .SS Specify devices for data and metadata LVs
 
 \&
@@ -420,31 +467,6 @@ containing new metadata:
 .B lvconvert \-\-thinpool VG/ThinPoolLV \-\-poolmetadata VG/NewThinMetaLV
 
 
-.SS Automatic pool metadata LV
-
-\&
-
-A thin data LV can be converted to a thin pool LV without
-specifying a thin pool metadata LV.  LVM will automatically
-create a metadata LV from the same VG.
-
-.B lvcreate \-n ThinDataLV \-L LargeSize VG
-.br
-.B lvconvert \-\-type thin\-pool VG/ThinDataLV
-
-.I Example
-.br
-.nf
-# lvcreate \-n pool0 \-L 10G vg
-# lvconvert \-\-type thin\-pool vg/pool0
-
-# lvs \-a
-  pool0           vg          twi-a-tz--  10.00g
-  [pool0_tdata]   vg          Twi-ao----  10.00g
-  [pool0_tmeta]   vg          ewi-ao----  16.00m
-.fi
-
-
 .SS Activation of thin snapshots
 
 \&


