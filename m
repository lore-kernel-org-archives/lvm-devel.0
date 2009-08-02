From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 2 Aug 2009 21:01:52 -0000
Subject: LVM2 ./WHATS_NEW man/lvconvert.8.in
Message-ID: <20090802210152.30200.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2009-08-02 21:01:52

Modified files:
	.              : WHATS_NEW 
	man            : lvconvert.8.in 

Log message:
	Update synopsis in lvconvert manpage to mention --repair.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1225&r2=1.1226
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvconvert.8.in.diff?cvsroot=lvm2&r1=1.5&r2=1.6

--- LVM2/WHATS_NEW	2009/08/01 17:08:43	1.1225
+++ LVM2/WHATS_NEW	2009/08/02 21:01:51	1.1226
@@ -1,5 +1,6 @@
 Version 2.02.51 - 
 ================================
+  Update synopsis in lvconvert manpage to mention --repair.
   Set cookies in activation code and wait for udev to complete processing.
   Added configure --enable-udev_rules --enable-udev_sync.
   Added configure --with-udev-prefix --with-udevdir.
--- LVM2/man/lvconvert.8.in	2009/06/30 18:39:32	1.5
+++ LVM2/man/lvconvert.8.in	2009/08/02 21:01:52	1.6
@@ -21,6 +21,13 @@
 [\-\-version]
 .br
 OriginalLogicalVolume[Path] SnapshotLogicalVolume[Path]
+
+.B lvconvert
+\-\-repair
+[\-h|\-?|\-\-help]
+[\-v|\-\-verbose]
+[\-\-version]
+LogicalVolume[Path] [PhysicalVolume[Path]...]
 .SH DESCRIPTION
 lvconvert will change a linear logical volume to a mirror
 logical volume or to a snapshot of linear volume and vice versa.


