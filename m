From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 15 May 2014 10:14:17 +0000 (UTC)
Subject: master - man:misc updates
Message-ID: <20140515101417.86E9660DC4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=309201a53bcbbd4967f380214e688c520b957fdf
Commit:        309201a53bcbbd4967f380214e688c520b957fdf
Parent:        7c86131233011c9fb81190bcb40d5d4ac54a533d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu May 15 10:25:15 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu May 15 12:08:35 2014 +0200

man:misc updates

---
 man/lvchange.8.in  |    6 +++++-
 man/lvconvert.8.in |   35 ++++++++++++++++++++++-------------
 2 files changed, 27 insertions(+), 14 deletions(-)

diff --git a/man/lvchange.8.in b/man/lvchange.8.in
index 5de75e0..b138c3d 100644
--- a/man/lvchange.8.in
+++ b/man/lvchange.8.in
@@ -181,7 +181,7 @@ the number of I/Os to the drive to a minimum.  The default behavior is to
 set the write-mostly attribute for the specified physical volume in the
 logical volume.  It is possible to also remove the write-mostly flag by
 appending a ":n" to the physical volume or to toggle the value by specifying
-":t".  The \fI--writemostly\fP argument can be specified more than one time
+":t".  The \fB--writemostly\fP argument can be specified more than one time
 in a single command; making it possible to toggle the write-mostly attributes
 for all the physical volumes in a logical volume at once.
 .TP
@@ -237,6 +237,10 @@ manually without a clustered lock manager.
 Set zeroing mode for thin pool. Note: already provisioned blocks from pool
 in non-zero mode are not cleared in unwritten parts when setting zero to
 \fIy\fP.
+.SH ENVIRONMENT VARIABLES
+.TP
+.B LVM_SUPPRESS_LOCKING_FAILURE_MESSAGES
+Suppress locking failure messages.
 .SH Examples
 Changes the permission on volume lvol1 in volume group vg00 to be read-only:
 .sp
diff --git a/man/lvconvert.8.in b/man/lvconvert.8.in
index fe6525b..8c3479f 100644
--- a/man/lvconvert.8.in
+++ b/man/lvconvert.8.in
@@ -162,15 +162,17 @@ Exactly one of
 .BR \-\-replace ,
 .BR \-\-splitsnapshot ,
 .BR \-\-snapshot ,
-.BR \-\-splitmirrors
-or
+.BR \-\-splitmirrors ,
+.BR \-\-thin ,
 .BR \-\-thinpool
+or
+.BR \-\-type
 arguments is required.
 .TP
 .BR \-b ", " \-\-background
 Run the daemon in the background.
 .TP
-.BR \-\-cachepool " " \fCachePoolLV
+.BR \-\-cachepool " " \fICachePoolLV
 This argument is necessary when converting a logical volume to a cache LV.
 For more information on cache pool LVs and cache LVs, see \fBlvm\fP(8).
 .TP
@@ -204,9 +206,15 @@ A mirror is divided into regions of this size (in MB), and the mirror log
 uses this granularity to track which regions are in sync.
 .TP
 .B \-\-type \fISegmentType
-Used to convert a logical volume to another segment type, like cache-pool,
-cache, raid1, or thin-pool.  When converting a logical volume to a cache LV,
-the \-\-cachepool argument is required.
+Used to convert a logical volume to another segment type, like
+.IR cache-pool ,
+.IR cache ,
+.IR raid1 ,
+or
+.IR thin-pool .
+When converting a logical volume to a cache LV, the
+.B \-\-cachepool
+argument is required.
 .TP
 .BR \-i ", " \-\-interval " " \fISeconds
 Report progress as a percentage at regular intervals.
@@ -246,8 +254,9 @@ The inverse of \-\-snapshot.
 .TP
 .B \-s, \-\-snapshot
 Recreates a snapshot from constituent logical volumes (or copies of them) after
-having been separated using \-\-splitsnapshot.  For this to work correctly, no
-changes may be made to the contents of either volume after the split.
+having been separated using \fB\-\-splitsnapshot\fP.
+For this to work correctly, no changes may be made to the contents
+of either volume after the split.
 .TP
 .BR \-c ", " \-\-chunksize " " \fIChunkSize [ \fIbBsSkKmMgG ]
 Gives the size of chunk for snapshot and thin pool logical volumes.
@@ -328,9 +337,9 @@ Default unit is megabytes.
 .TP
 .IR \fB\-r ", " \fB\-\-readahead " {" ReadAheadSectors | auto | none }
 Sets read ahead sector count of thin pool metadata logical volume.
-The default value is "auto" which allows the kernel to choose
+The default value is "\fIauto\fP" which allows the kernel to choose
 a suitable value automatically.
-"None" is equivalent to specifying zero.
+"\fINone\fP" is equivalent to specifying zero.
 .TP
 .B \-\-repair
 Repair a mirror after suffering a disk failure or try to fix thin pool metadata.
@@ -380,9 +389,9 @@ The volume cannot be further modified as long as it is used as an
 external origin volume for unprovisioned areas of any thin logical volume.
 .TP
 .IR \fB\-\-thinpool " " ThinPoolLogicalVolume { Name | Path }
-Changes logical volume into a thin pool volume. The volume
-will store the pool's data.
-Thin pool metadata logical volume can be specified with the option
+Switches logical volume into a thin pool's data volume.
+Content of converted volume is lost.
+Thin pool's metadata logical volume can be specified with the option
 \fB\-\-poolmetadata\fP or allocated with \fB\-\-poolmetadatasize\fP.
 
 .SH Examples


