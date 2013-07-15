From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 15 Jul 2013 14:03:05 +0000 (UTC)
Subject: master - thin: lvcreate man examples
Message-ID: <20130715140305.B22A360FE8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e1e986f16d27e468a70dcbc2d2c2a249111d7725
Commit:        e1e986f16d27e468a70dcbc2d2c2a249111d7725
Parent:        97d36d5750924029c247265c8d700f993405668f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jul 15 11:52:05 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 15 15:54:33 2013 +0200

thin: lvcreate man examples

Add more examples to man page about thin volume snapshot creation
and try to make the text more explicit about size specification.
---
 man/lvcreate.8.in |   22 +++++++++++++++-------
 1 files changed, 15 insertions(+), 7 deletions(-)

diff --git a/man/lvcreate.8.in b/man/lvcreate.8.in
index fd36e90..64319c1 100644
--- a/man/lvcreate.8.in
+++ b/man/lvcreate.8.in
@@ -312,11 +312,11 @@ Snapshots provide a 'frozen image' of the contents of the origin
 while the origin can still be updated. They enable consistent
 backups and online recovery of removed/overwritten data/files.
 Thin snapshot is created when the origin is a thin volume and
-the size is not specified. Thin snapshot shares same blocks within
+the size IS NOT specified. Thin snapshot shares same blocks within
 the thin pool volume.
-The snapshot with the specified size does not need the same amount of
-storage the origin has. In a typical scenario, 15-20% might be enough.
-In case the snapshot runs out of storage, use
+The non thin volume snapshot with the specified size does not need
+the same amount of storage the origin has. In a typical scenario,
+15-20% might be enough. In case the snapshot runs out of storage, use
 .BR lvextend (8)
 to grow it. Shrinking a snapshot is supported by
 .BR lvreduce (8)
@@ -453,10 +453,18 @@ build with 2 stripes 64KiB and chunk size 256KiB together with
 .sp
 .B lvcreate \-i 2 \-I 64 \-c 256 \-L100M \-T vg00/pool \-V 1T \-\-name thin_lv
 
-Creates thin volume snapshot of read only inactive volume "vg00/origin"
-that will use an existing thin pool "vg00/pool":
+Creates a thin snapshot volume "thinsnap" of thin volume "thinvol" that
+will share the same blocks within the thin pool.
+Note: the size MUST NOT be specified, otherwise the non-thin snapshot
+is created instead:
 .sp
-.B lvcreate -s --thinpool "vg00/pool"  origin
+.B lvcreate -s vg00/thinvol --name thinsnap
+
+Creates a thin snapshot volume of read-only inactive volume "origin"
+which then becomes the thin external origin for the thin snapshot volume
+in vg00 that will use an existing thin pool "vg00/pool":
+.sp
+.B lvcreate -s --thinpool vg00/pool  origin
 
 .SH SEE ALSO
 .BR lvm (8),


