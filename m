From: Dave Wysochanski <dwysocha@redhat.com>
Date: Sun, 25 Oct 2009 22:48:22 -0400
Subject: [PATCH] Update lvcreate/lvconvert man pages to explain PhysicalVolume parameter.
Message-ID: <1256525302-5189-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Addresses rhbz 500177.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 man/lvconvert.8.in |   14 ++++++++++++++
 man/lvcreate.8.in  |    4 +++-
 2 files changed, 17 insertions(+), 1 deletions(-)

diff --git a/man/lvconvert.8.in b/man/lvconvert.8.in
index b8fe27d..1c736c9 100644
--- a/man/lvconvert.8.in
+++ b/man/lvconvert.8.in
@@ -35,6 +35,14 @@ LogicalVolume[Path] [PhysicalVolume[Path]...]
 lvconvert will change a linear logical volume to a mirror
 logical volume or to a snapshot of linear volume and vice versa.
 It is also used to add and remove disk logs from mirror devices.
+.br
+If the conversion requires allocation of physical extents (for
+example, when converting from linear to mirror) and you specify
+one or more PhysicalVolumes, allocation of physical extents will
+be restricted to these volumes.  If the conversion frees physical
+extents (for example, when converting from a mirror to a linear, or
+reducing mirror legs) and you specify one or more PhysicalVolumes,
+the freed extents come first from the specified PhysicalVolumes.
 .SH OPTIONS
 See \fBlvm\fP for common options.
 .br
@@ -131,6 +139,12 @@ converts logical volume "vg00/lvol2" to snapshot of original volume "vg00/lvol1"
 converts linear logical volume "vg00/lvol1" to a two-way mirror, using physical
 extents /dev/sda:0-15 and /dev/sdb:0-15 for allocation of new extents.
 
+.br
+"lvconvert -m0 vg00/lvmirror1 /dev/sda
+.br
+converts mirror logical volume "vg00/lvmirror1" to linear, freeing physical
+extents from /dev/sda.
+
 .SH SEE ALSO
 .BR lvm (8),
 .BR vgcreate (8),
diff --git a/man/lvcreate.8.in b/man/lvcreate.8.in
index ded98f9..5041eab 100644
--- a/man/lvcreate.8.in
+++ b/man/lvcreate.8.in
@@ -41,7 +41,9 @@ the volume group can be extended ( see
 ) with other physical volumes or by reducing existing logical volumes
 of this volume group in size ( see
 .B lvreduce(8)
-).
+). If you specify one or more PhysicalVolumes, allocation of physical
+extents will be restricted to these volumes.
+.br
 .br
 The second form supports the creation of snapshot logical volumes which 
 keep the contents of the original logical volume for backup purposes.
-- 
1.6.0.6


