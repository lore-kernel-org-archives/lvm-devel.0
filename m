From: David Teigland <teigland@fedoraproject.org>
Date: Wed, 14 May 2014 20:15:47 +0000 (UTC)
Subject: master - man: more lvmthin discard references
Message-ID: <20140514201547.806106036A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=044b7968005a23e52a78c26eb56a7f74a973312f
Commit:        044b7968005a23e52a78c26eb56a7f74a973312f
Parent:        3b989e317fecf115ce9a2b89f777e4feec2461ec
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed May 14 09:44:09 2014 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed May 14 15:15:35 2014 -0500

man: more lvmthin discard references

and some fixes from Tom.
---
 man/lvmthin.7.in |   21 +++++++++++++--------
 1 files changed, 13 insertions(+), 8 deletions(-)

diff --git a/man/lvmthin.7.in b/man/lvmthin.7.in
index 55b1562..5a4ee87 100644
--- a/man/lvmthin.7.in
+++ b/man/lvmthin.7.in
@@ -23,10 +23,10 @@ that will hold blocks for thin LVs, and a metadata LV that will hold
 metadata.  The metadata tracks which data blocks belong to each thin LV.
 
 Snapshots of thin LVs are efficient because the data blocks common to a
-thin LV and its snapshot are shared.  Snapshots may be taken of thin LVs
-or of other thin snapshots.  Blocks common to recursive snapshots are also
-shared in the thin pool.  There is no limit to or degradation from
-sequences of snapshots.
+thin LV and any of its snapshots are shared.  Snapshots may be taken of
+thin LVs or of other thin snapshots.  Blocks common to recursive snapshots
+are also shared in the thin pool.  There is no limit to or degradation
+from sequences of snapshots.
 
 As thin LVs or snapshot LVs are written to, they consume data blocks in
 the thin pool.  As free data blocks in the pool decrease, more free blocks
@@ -620,6 +620,9 @@ pool0           vg   twi-a-tz--  10.00g               47.01  21.03
 thin1           vg   Vwi-aotz-- 100.00g pool0          2.70       
 .fi
 
+The "Discard" section covers an option for automatically freeing data
+space in a thin pool.
+
 
 .SS Automatically extend thin pool LV
 
@@ -691,7 +694,7 @@ extended.  (Disabling dmeventd is not recommended.)
 writes to thin LVs in the pool.  (This can be addressed by tuning the
 thin_pool_autoextend_threshold and thin_pool_autoextend_percent.)
 
-4. The VG does have enough free blocks to extend the thin pool.
+4. The VG does not have enough free blocks to extend the thin pool.
 
 The response to data space exhaustion is to extend the thin pool.  This is
 described in the section "Manually manage free data space of thin pool
@@ -768,8 +771,10 @@ controls the default zeroing mode used when creating a thin pool.
 
 \&
 
-The discard behavior of a thin pool LV determines how discard requests
-are handled.  Possible discard behaviors:
+The discard behavior of a thin pool LV determines how discard requests are
+handled.  Enabling discard under a file system may adversely affect the
+file system performance (see the section on fstrim for an alternative.)
+Possible discard behaviors:
 
 ignore: Ignore any discards that are received.
 
@@ -933,7 +938,7 @@ and combines the two into a thin pool LV.
 lvcreate -L LargeSize --thinpool VG/ThinPoolLV
 
 Example
-# lvcreate -l1 --thinpool vg/pool0
+# lvcreate -L8M --thinpool vg/pool0
 
 # lvs vg/pool0
 LV    VG  Attr       LSize Pool Origin Data%


