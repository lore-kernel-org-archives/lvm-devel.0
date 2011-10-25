From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 25 Oct 2011 13:24:24 -0000
Subject: LVM2/man lvconvert.8.in lvcreate.8.in
Message-ID: <20111025132424.18003.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2011-10-25 13:24:23

Modified files:
	man            : lvconvert.8.in lvcreate.8.in 

Log message:
	Update lvconvert man page to describe '--type <segtype>' argument
	
	Man page changes were not included when the ability to convert from
	"mirror" -> "raid1" or "linear" -> "raid1" were made.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvconvert.8.in.diff?cvsroot=lvm2&r1=1.22&r2=1.23
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvcreate.8.in.diff?cvsroot=lvm2&r1=1.25&r2=1.26

--- LVM2/man/lvconvert.8.in	2011/08/19 17:36:13	1.22
+++ LVM2/man/lvconvert.8.in	2011/10/25 13:24:23	1.23
@@ -4,6 +4,7 @@
 .SH SYNOPSIS
 .B lvconvert
 \-m|\-\-mirrors Mirrors [\-\-mirrorlog {disk|core|mirrored}] [\-\-corelog] [\-R|\-\-regionsize MirrorLogRegionSize]
+[\-\-type SegmentType]
 [\-A|\-\-alloc AllocationPolicy]
 [\-b|\-\-background] [\-f|\-\-force] [\-i|\-\-interval Seconds]
 [\-h|\-?|\-\-help]
@@ -50,6 +51,7 @@
 [\-v|\-\-verbose]
 [\-\-version]
 LogicalVolume[Path] [PhysicalVolume[Path]...]
+
 .SH DESCRIPTION
 lvconvert is used to change the segment type (i.e. linear, mirror, etc) or
 characteristics of a logical volume.  For example, it can add or remove the
@@ -94,6 +96,11 @@
 A mirror is divided into regions of this size (in MB), and the mirror log
 uses this granularity to track which regions are in sync.
 .TP
+.I \-\-type SegmentType
+Used to convert a logical volume to another segment type or to explicitly state
+the desired RAID1 segment type ("mirror" or "raid1") when converting a linear
+logical volume to a mirror with the '-m' argument.
+.TP
 .I \-b, \-\-background
 Run the daemon in the background.
 .TP
@@ -179,6 +186,12 @@
 .br
 converts the linear logical volume "vg00/lvol1" to
 a two-way mirror logical volume.
+.br
+.SH Examples
+"lvconvert --type raid1 -m1 vg00/lvol1"
+.br
+converts the linear logical volume "vg00/lvol1" to a two-way RAID1
+logical volume.
 
 "lvconvert --mirrorlog core vg00/lvol1"
 .br
@@ -195,6 +208,11 @@
 converts a mirror logical volume to a linear logical
 volume.
 .br
+"lvconvert --type raid1 vg00/mirror_lv"
+.br
+converts a mirror logical volume to a RAID1 logical volume with the same
+number of images.
+.br
 
 .br
 "lvconvert -s vg00/lvol1 vg00/lvol2"
--- LVM2/man/lvcreate.8.in	2011/10/21 09:55:07	1.25
+++ LVM2/man/lvcreate.8.in	2011/10/25 13:24:23	1.26
@@ -267,7 +267,7 @@
 commandline switch alias that will enable their use (-s is an alias for
 --type snapshot).  However, this argument must be used when no existing
 commandline switch alias is available for the desired type, as is the case
-with "error", "zero", "raid4", "raid5", or "raid6".
+with "error", "zero", "raid1", "raid4", "raid5", or "raid6".
 .TP
 .BR \-V ", " \-\-virtualsize " " \fIVirtualSize
 Create a sparse device of the given size (in MB by default) using a snapshot.  


