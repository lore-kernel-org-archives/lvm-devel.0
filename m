From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 23 Feb 2009 14:03:57 -0500
Subject: [PATCH] Update vgchange and vgmknodes to include --refresh.
Message-ID: <1235415837-28061-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 man/vgchange.8.in  |    7 +++++++
 man/vgmknodes.8.in |   13 +++++++++++--
 2 files changed, 18 insertions(+), 2 deletions(-)

diff --git a/man/vgchange.8.in b/man/vgchange.8.in
index 3905441..413339a 100644
--- a/man/vgchange.8.in
+++ b/man/vgchange.8.in
@@ -25,6 +25,7 @@ vgchange \- change attributes of a volume group
 .RB [ \-P | \-\-partial]
 .RB [ \-s | \-\-physicalextentsize
 .IR PhysicalExtentSize [ \fBkKmMgGtT\fR ]]
+.RB [ \-\-refresh]
 .RB [ -t | \-\-test]
 .RB [ \-v | \-\-verbose]
 .RB [ \-\-version ]
@@ -128,6 +129,12 @@ impact on I/O performance to the logical volume.  The smallest PE is 1KB.
  
 The 2.4 kernel has a limitation of 2TB per block device.
 .TP
+.BR \-\-refresh
+If any logical volume in the volume group is active, reload its metadata.
+This is not necessary in normal operation, but may be useful
+if something has gone wrong or if you're doing clustering
+manually without a clustered lock manager.
+.TP
 .BR \-x ", " \-\-resizeable " " { y | n }
 Enables or disables the extension/reduction of this volume group
 with/by physical volumes.
diff --git a/man/vgmknodes.8.in b/man/vgmknodes.8.in
index acba91a..49f6a9d 100644
--- a/man/vgmknodes.8.in
+++ b/man/vgmknodes.8.in
@@ -3,13 +3,22 @@
 vgmknodes \- recreate volume group directory and logical volume special files
 .SH SYNOPSIS
 .B vgmknodes
-[\-d|\-\-debug] [\-h|\-?|\-\-help] 
-[\-v|\-\-verbose]
+.RB [ \-d | \-\-debug]
+.RB [ \-h | \-\-help]
+.RB [ \-\-refresh]
+.RB [ \-v | \-\-verbose]
 [[VolumeGroupName | LogicalVolumePath]...]
 .SH DESCRIPTION
 Checks the LVM2 special files in /dev that are needed for active 
 logical volumes and creates any missing ones and removes unused ones.
 .SH OPTIONS
+.TP
+.BR \-\-refresh
+If any logical volume in the volume group is active, reload its metadata.
+This is not necessary in normal operation, but may be useful
+if something has gone wrong or if you're doing clustering
+manually without a clustered lock manager.
+.TP
 See \fBlvm\fP for common options.
 .SH SEE ALSO
 .BR lvm (8),
-- 
1.6.0.6


