From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 13 Feb 2017 18:10:43 +0000 (UTC)
Subject: master - man: lvmthin updates
Message-ID: <20170213181043.92880601DD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c3e1838382122e254aaf9bda6159bc5e95303309
Commit:        c3e1838382122e254aaf9bda6159bc5e95303309
Parent:        15d9f2850e60a44cfc55d48ce108b4a82aecd9ae
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Jan 16 16:26:14 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Feb 13 08:20:10 2017 -0600

man: lvmthin updates

Some minor changes to some of the command syntaxes
to use more standard forms.
---
 man/lvmthin.7.in |   21 +++++++++------------
 1 files changed, 9 insertions(+), 12 deletions(-)

diff --git a/man/lvmthin.7.in b/man/lvmthin.7.in
index ce86974..714233e 100644
--- a/man/lvmthin.7.in
+++ b/man/lvmthin.7.in
@@ -157,17 +157,17 @@ The --thinpool argument specifies which thin pool will
 contain the ThinLV.
 .fi
 
-.B lvcreate \-n ThinLV \-V VirtualSize \-\-thinpool VG/ThinPoolLV
+.B lvcreate \-n ThinLV \-V VirtualSize \-\-thinpool ThinPoolLV VG
 
 .I Example
 .br
 Create a thin LV in a thin pool:
 .br
-# lvcreate \-n thin1 \-V 1T \-\-thinpool vg/pool0
+# lvcreate \-n thin1 \-V 1T \-\-thinpool pool0 vg
 
 Create another thin LV in the same thin pool:
 .br
-# lvcreate \-n thin2 \-V 1T \-\-thinpool vg/pool0
+# lvcreate \-n thin2 \-V 1T \-\-thinpool pool0 vg
 
 # lvs vg/thin1 vg/thin2
   LV    VG Attr       LSize Pool  Origin Data%
@@ -184,9 +184,9 @@ when creating a thin snapshot.
 .br
 A size argument will cause an old COW snapshot to be created.
 
-.B lvcreate \-n SnapLV \-s VG/ThinLV
+.B lvcreate \-n SnapLV \-\-snapshot VG/ThinLV
 .br
-.B lvcreate \-n SnapLV \-s VG/PrevSnapLV
+.B lvcreate \-n SnapLV \-\-snapshot VG/PrevSnapLV
 
 .I Example
 .br
@@ -286,15 +286,12 @@ The fully specified syntax for creating a thin pool LV shown above is:
 
 .B lvconvert \-\-type thin-pool \-\-poolmetadata VG/ThinMetaLV VG/ThinDataLV
 
-An existing LV is converted to a thin pool by changing its type to
-thin-pool.  An alternate syntax may be used for the same operation:
+An alternate syntax may be used for the same operation:
 
 .B lvconvert \-\-thinpool VG/ThinDataLV \-\-poolmetadata VG/ThinMetaLV
 
-The thin-pool type is inferred by lvm; the --thinpool option is not an
-alias for --type thin-pool.  The use of the --thinpool option here is
-different from the use of the --thinpool option when creating a thin LV,
-where it specifies the pool in which the thin LV is created.
+The thin-pool type is inferred by lvm; the \-\-thinpool option is not an
+alias for \-\-type thin\-pool.
 
 
 .SS Automatic pool metadata LV
@@ -1234,7 +1231,7 @@ and creates a thin LV in the new pool.
 .br
 \-V VirtualSize specifies the virtual size of the thin LV.
 
-.B lvcreate \-V VirtualSize \-L LargeSize
+.B lvcreate \-\-type thin \-V VirtualSize \-L LargeSize
 .RS
 .B \-n ThinLV \-\-thinpool VG/ThinPoolLV
 .RE


