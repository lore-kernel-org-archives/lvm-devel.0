From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 7 Nov 2008 19:23:53 -0000
Subject: LVM2 ./WHATS_NEW man/lvchange.8.in man/lvcreat ...
Message-ID: <20081107192353.29450.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-11-07 19:23:52

Modified files:
	.              : WHATS_NEW 
	man            : lvchange.8.in lvcreate.8.in 

Log message:
	Fix lvhange and lvcreate man pages to properly describe permissions option.
	
	James Youngman <jay@gnu.org>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.991&r2=1.992
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvchange.8.in.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvcreate.8.in.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/WHATS_NEW	2008/11/07 19:02:47	1.991
+++ LVM2/WHATS_NEW	2008/11/07 19:23:52	1.992
@@ -1,5 +1,6 @@
 Version 2.02.43 -
 ===================================
+  Fix lvchange and lvcreate man pages permissions option.
   Fix vgdisplay return code and exit status.
   Move list.c into libdevmapper and rename functions.
   Rename a couple of variables that matched function names.
--- LVM2/man/lvchange.8.in	2008/10/08 12:50:13	1.1
+++ LVM2/man/lvchange.8.in	2008/11/07 19:23:52	1.2
@@ -14,7 +14,7 @@
 [\-\-monitor {y|n}]
 [\-M/\-\-persistent y/n] [\-\-minor minor]
 [\-P/\-\-partial]
-[\-p/\-\-permission r/w] [\-r/\-\-readahead ReadAheadSectors|auto|none]
+[\-p/\-\-permission r|rw] [\-r/\-\-readahead ReadAheadSectors|auto|none]
 [\-\-refresh]
 [\-t/\-\-test]
 [\-v/\-\-verbose] LogicalVolumePath [LogicalVolumePath...]
@@ -69,7 +69,7 @@
 .I \-M, \-\-persistent y/n
 Set to y to make the minor number specified persistent.
 .TP
-.I \-p, \-\-permission r/w
+.I \-p, \-\-permission r|rw
 Change access permission to read-only or read/write.
 .TP
 .I \-r, \-\-readahead ReadAheadSectors|auto|none
--- LVM2/man/lvcreate.8.in	2008/10/08 12:50:13	1.1
+++ LVM2/man/lvcreate.8.in	2008/11/07 19:23:52	1.2
@@ -14,7 +14,7 @@
 [\-m/\-\-mirrors Mirrors [\-\-nosync] [\-\-mirrorlog {disk|core}] [\-\-corelog]
 [\-R/\-\-regionsize MirrorLogRegionSize]]
 [\-n/\-\-name LogicalVolumeName]
-[\-p/\-\-permission r/rw] [\-r/\-\-readahead ReadAheadSectors|auto|none]
+[\-p/\-\-permission r|rw] [\-r/\-\-readahead ReadAheadSectors|auto|none]
 [\-t/\-\-test]
 [\-v/\-\-verbose] [\-Z/\-\-zero y/n]
 VolumeGroupName [PhysicalVolumePath...]
@@ -113,7 +113,7 @@
 Without this option a default names of "lvol#" will be generated where
 # is the LVM internal number of the logical volume.
 .TP
-.I \-p, \-\-permission r/w
+.I \-p, \-\-permission r|rw
 Set access permissions to read only or read and write.
 .br
 Default is read and write.


