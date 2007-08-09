From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 9 Aug 2007 20:43:30 -0000
Subject: LVM2/man lvconvert.8 lvcreate.8
Message-ID: <20070809204330.6654.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2007-08-09 20:43:29

Modified files:
	man            : lvconvert.8 lvcreate.8 

Log message:
	minor updates to the lvcreate/lvconvert man pages.
	- put back reference to '--corelog'.  It now says that it
	is the same as '--log core'.
	- other minor touches

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvconvert.8.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvcreate.8.diff?cvsroot=lvm2&r1=1.15&r2=1.16

--- LVM2/man/lvconvert.8	2007/08/01 21:01:06	1.6
+++ LVM2/man/lvconvert.8	2007/08/09 20:43:29	1.7
@@ -3,7 +3,7 @@
 lvconvert \- convert a logical volume from linear to mirror or snapshot
 .SH SYNOPSIS
 .B lvconvert
-\-m/\-\-mirrors Mirrors [\-\-log {disk|core}] [\-R/\-\-regionsize MirrorLogRegionSize]
+\-m/\-\-mirrors Mirrors [\-\-log {disk|core}] [\-\-corelog] [\-R/\-\-regionsize MirrorLogRegionSize]
 [\-A/\-\-alloc AllocationPolicy]
 [\-h/\-?/\-\-help]
 [\-v/\-\-verbose]
@@ -38,9 +38,12 @@
 linear volume plus one copy.
 .TP
 .I \-\-log disk/core
-This optional argument gives the ability to switch the
-logging type that is used by a mirror.  The logging type
-can be either "disk" (persistent) or "core" (non-persistent).
+This optional argument switches the logging type of a
+mirror.  The logging type can be either "disk" (persistent)
+or "core" (non-persistent).  The default logging type is "disk".
+.TP
+.I \-\-corelog
+The optional argument "--corelog" is the same as specifying "--log core".
 .TP
 .I \-R, \-\-regionsize MirrorLogRegionSize
 A mirror is divided into regions of this size (in MB), and the mirror log
@@ -62,7 +65,7 @@
 "lvconvert -m1 vg00/lvol1"
 .br
 converts the linear logical volume "vg00/lvol1" to
-a two-legged mirror logical volume.
+a two-way mirror logical volume.
 
 "lvconvert --log core vg00/lvol1"
 .br
--- LVM2/man/lvcreate.8	2007/08/01 21:01:06	1.15
+++ LVM2/man/lvcreate.8	2007/08/09 20:43:29	1.16
@@ -11,7 +11,7 @@
 {\-l/\-\-extents LogicalExtentsNumber[%{VG|FREE}] |
  \-L/\-\-size LogicalVolumeSize[kKmMgGtT]}
 [\-M/\-\-persistent y/n] [\-\-minor minor]
-[\-m/\-\-mirrors Mirrors [\-\-nosync] [\-\-log {disk|log}]
+[\-m/\-\-mirrors Mirrors [\-\-nosync] [\-\-log {disk|log}] [\-\-corelog]
 [\-R/\-\-regionsize MirrorLogRegionSize]]
 [\-n/\-\-name LogicalVolumeName]
 [\-p/\-\-permission r/rw] [\-r/\-\-readahead ReadAheadSectors]
@@ -99,9 +99,12 @@
 of mirror log to be used.  The available types are "disk" and "core",
 where "disk" is the default.  The "disk" log is persistent and requires
 a small amount of storage space - usually on a separate device from the
-mirror legs.  While the "disk" log may cause the mirror to be slightly
+mirror devices.  While the "disk" log may cause the mirror to be slightly
 slower during writes, it prevents the need to completely resynchronize
 the mirror upon each instantiation (e.g. a reboot).
+
+The optional argument "--corelog" is the same as specifying "--log core".
+
 .TP
 .I \-n, \-\-name LogicalVolumeName
 The name for the new logical volume.


