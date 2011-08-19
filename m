From: agk@sourceware.org <agk@sourceware.org>
Date: 19 Aug 2011 17:36:13 -0000
Subject: LVM2/man lvconvert.8.in
Message-ID: <20110819173613.25661.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-08-19 17:36:13

Modified files:
	man            : lvconvert.8.in 

Log message:
	tweak split/track/merge
	How do you discover the value of N?

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvconvert.8.in.diff?cvsroot=lvm2&r1=1.21&r2=1.22

--- LVM2/man/lvconvert.8.in	2011/08/18 19:43:09	1.21
+++ LVM2/man/lvconvert.8.in	2011/08/19 17:36:13	1.22
@@ -125,12 +125,12 @@
 
 .TP
 .I \-\-trackchanges
-This argument is used along with \-\-splitmirrors when the intention
-is to use the split-off image temporarily in a read-only fashion.  Splitting
-off an image in this way allows it to be merged back into the mirror later
-- only resynchronizing those portions of the image that have changed since
-the split occurred.  This option is only available to the "raid1" segment
-type.
+Used with \-\-splitmirrors on a raid1 device, this tracks changes so that the
+read-only detached image can be merged efficiently back into the mirror later.
+Only the regions of the detatched device where the data changed get resynchronized.
+
+Please note that this feature is only supported with the new md-based mirror
+implementation and not with the original device-mapper mirror implementation.
 .br
 
 .TP
@@ -146,7 +146,7 @@
 If the volume is read-only the snapshot will not be zeroed.
 .TP
 .I \-\-merge
-Merges a snapshot into its origin volume or merges a RAID1 image that has
+Merges a snapshot into its origin volume or merges a raid1 image that has
 been split from its mirror with \-\-trackchanges back into its mirror.
 
 To check if your kernel supports the snapshot merge feature, look
@@ -164,7 +164,6 @@
 multiple snapshots be merged to their respective origin.
 .br
 
-
 .TP
 .I \-\-repair
 Repair a mirror after suffering a disk failure. The mirror will be brought back
@@ -238,20 +237,20 @@
 .br
 "lvconvert --splitmirrors 1 --trackchanges vg00/lv_raid1"
 .br
-A mirrored logical volume that uses the "raid1" segment type (i.e. created
-with '--type raid1') can use the '\-\-trackchanges' argument when splitting
-off an image.  The split-off image cannot be given a new name, as it is still
-part of the original RAID1 logical volume in the sense that changes between
-the two are being tracked for future integration upon merging.  The device that
-results from the split will be read-only and will be named similarly to the
-original - in this case "lv_raid1_rimage_N", where 'N' is the index of the
-image that has been split.
+A mirrored logical volume created with --type raid1 can use the '\-\-trackchanges' argument when splitting
+off an image.  
+
+Detach one image from the mirrored logical volume lv_raid1 as a separate
+read-only device and track the changes made to the mirror while it is detached.
+The split-off device has a name of the form lv_raid1_rimage_N, where N is
+a number, and it cannot be renamed.
 
 .br
 "lvconvert --merge vg00/lv_raid1_rimage_1"
 .br
-Merge an image back into the mirror it was split from when the '\-\-trackchanges'
-argument was used.
+Merge an image that was detached temporarily from its mirror with 
+the '\-\-trackchanges' argument back into its original mirror and
+bring its contents back up-to-date.
 
 .SH SEE ALSO
 .BR lvm (8),


