From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 10 Jan 2007 14:13:48 -0000
Subject: LVM2 ./WHATS_NEW man/lvconvert.8 man/lvcreate. ...
Message-ID: <20070110141348.28867.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2007-01-10 14:13:46

Modified files:
	.              : WHATS_NEW 
	man            : lvconvert.8 lvcreate.8 
	tools          : lvconvert.c lvcreate.c 

Log message:
	Print warning instead of error message if cannot zero volume
	Update lvconvert man page (snapshot option)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.532&r2=1.533
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvconvert.8.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvcreate.8.diff?cvsroot=lvm2&r1=1.13&r2=1.14
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.24&r2=1.25
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.131&r2=1.132

--- LVM2/WHATS_NEW	2007/01/09 23:22:31	1.532
+++ LVM2/WHATS_NEW	2007/01/10 14:13:46	1.533
@@ -1,5 +1,7 @@
 Version 2.02.18 -
 ====================================
+  Print warning instead of error message if cannot zero volume
+  Update lvconvert man page (snapshot option)
   dumpconfig accepts a list of configuration variables to display.
   Change dumpconfig to use --file to redirect output to a file.
   Avoid vgreduce error when mirror code removes the log LV.
--- LVM2/man/lvconvert.8	2006/10/07 10:47:05	1.3
+++ LVM2/man/lvconvert.8	2007/01/10 14:13:46	1.4
@@ -1,20 +1,35 @@
 .TH LVCONVERT 8 "LVM TOOLS" "Red Hat, Inc" \" -*- nroff -*-
 .SH NAME
-lvconvert \- convert a logical volume between linear and mirror
+lvconvert \- convert a logical volume from linear to mirror or snapshot
 .SH SYNOPSIS
 .B lvconvert
-[\-m/\-\-mirrors Mirrors [\-\-corelog] [\-R/\-\-regionsize MirrorLogRegionSize]]
+\-m/\-\-mirrors Mirrors [\-\-corelog] [\-R/\-\-regionsize MirrorLogRegionSize]
 [\-A/\-\-alloc AllocationPolicy]
 [\-h/\-?/\-\-help]
 [\-v/\-\-verbose]
 [\-\-version]
+.br
 LogicalVolume[Path] [PhysicalVolume[Path]...]
+.br
+
+.br
+.B lvconvert
+\-s/\-\-snapshot [\-c/\-\-chunksize ChunkSize]
+[\-h/\-?/\-\-help]
+[\-v/\-\-verbose]
+[\-Z/\-\-zero y/n]
+[\-\-version]
+.br
+OriginalLogicalVolume[Path] SnapshotLogicalVolume[Path]
 .SH DESCRIPTION
 lvconvert will change a linear logical volume to a mirror
-logical volume or vis versa.  It is also used to add and
-remove disk logs from mirror devices.
+logical volume or to a snapshot of linear volume and vice versa.
+It is also used to add and remove disk logs from mirror devices.
 .SH OPTIONS
 See \fBlvm\fP for common options.
+.br
+Exactly one of \-\-mirrors or \-\-snapshot arguments required.
+.br
 .TP
 .I \-m, \-\-mirrors Mirrors
 Specifies the degree of the mirror you wish to create.
@@ -32,6 +47,19 @@
 .I \-R, \-\-regionsize MirrorLogRegionSize
 A mirror is divided into regions of this size (in MB), and the mirror log
 uses this granularity to track which regions are in sync.
+.br
+.TP
+.I \-s, \-\-snapshot
+Create a snapshot from existing logical volume using another
+existing logical volume as its origin.
+.TP
+.I \-c, \-\-chunksize ChunkSize
+Power of 2 chunk size for the snapshot logical volume between 4k and 512k.
+.TP
+.I \-Z, \-\-zero y/n
+Controls zeroing of the first KB of data in the snapshot.
+If the volume is read only snapshot will not be zeroed.
+.br
 .SH Examples
 "lvconvert -m1 vg00/lvol1"
 .br
@@ -49,6 +77,12 @@
 .br
 converts a mirror logical volume to a linear logical
 volume.
+.br
+
+.br
+"lvconvert -s vg00/lvol1 vg00/lvol2"
+.br
+converts logical volume "vg00/lvol2" to snapshot of original volume "vg00/lvol1"
 
 .SH SEE ALSO
 .BR lvm (8),
--- LVM2/man/lvcreate.8	2006/11/10 18:24:11	1.13
+++ LVM2/man/lvcreate.8	2007/01/10 14:13:46	1.14
@@ -139,6 +139,10 @@
 Controls zeroing of the first KB of data in the new logical volume.
 .br
 Default is yes.
+.br
+Volume will not be zeroed if read only flag is set.
+.br
+Snapshot volumes are zeroed always.
 
 .br
 Warning: trying to mount an unzeroed logical volume can cause the system to
--- LVM2/tools/lvconvert.c	2006/12/13 03:39:58	1.24
+++ LVM2/tools/lvconvert.c	2007/01/10 14:13:46	1.25
@@ -446,8 +446,8 @@
 		return 0;
 	}
 
-	if (!lp->zero)
-		log_error("WARNING: \"%s\" not zeroed", lv->name);
+	if (!lp->zero || !(lv->status & LVM_WRITE))
+		log_print("WARNING: \"%s\" not zeroed", lv->name);
 	else if (!set_lv(cmd, lv, 0, 0)) {
 			log_error("Aborting. Failed to wipe snapshot "
 				  "exception store.");
--- LVM2/tools/lvcreate.c	2006/11/10 18:24:11	1.131
+++ LVM2/tools/lvcreate.c	2007/01/10 14:13:46	1.132
@@ -434,6 +434,10 @@
 	else
 		lp->permission = LVM_READ | LVM_WRITE;
 
+	/* Must not zero read only volume */
+	if (!(lp->permission & LVM_WRITE))
+		lp->zero = 0;
+
 	lp->minor = arg_int_value(cmd, minor_ARG, -1);
 	lp->major = arg_int_value(cmd, major_ARG, -1);
 


