From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 4 Feb 2011 21:19:04 -0000
Subject: LVM2/man pvcreate.8.in pvremove.8.in pvresize. ...
Message-ID: <20110204211904.16103.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-02-04 21:19:04

Modified files:
	man            : pvcreate.8.in pvremove.8.in pvresize.8.in 
	                 pvscan.8.in 

Log message:
	Place back some common options
	
	Until man pages are generated keep some common options with all commands.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/pvcreate.8.in.diff?cvsroot=lvm2&r1=1.10&r2=1.11
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/pvremove.8.in.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/pvresize.8.in.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/pvscan.8.in.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/man/pvcreate.8.in	2011/01/28 16:03:38	1.10
+++ LVM2/man/pvcreate.8.in	2011/02/04 21:19:03	1.11
@@ -3,6 +3,11 @@
 pvcreate \- initialize a disk or partition for use by LVM
 .SH SYNOPSIS
 .B pvcreate
+.RB [ \-d | \-\-debug ]
+.RB [ \-h | \-\-help ]
+.RB [ \-t | \-\-test ]
+.RB [ \-v | \-\-verbose ]
+.RB [ \-\-version ]
 .RB [ \-f [ f ]| \-\-force " [" \-\-force ]]
 .RB [ \-y | \-\-yes ]
 .RB [ \-\-labelsector ]
--- LVM2/man/pvremove.8.in	2011/01/28 16:03:38	1.2
+++ LVM2/man/pvremove.8.in	2011/02/04 21:19:04	1.3
@@ -3,9 +3,16 @@
 pvremove \- remove a physical volume
 .SH SYNOPSIS
 .B pvremove
-.RB [ \-f [ f ]| \-\-force " [" \-\-force ]]
+.RB [ \-d | \-\-debug ]
+.RB [ \-h | \-\-help ]
+.RB [ \-t | \-\-test ]
+.RB [ \-v | \-\-verbose ]
+.RB [ \-\-version ]
+.RB [ \-f [ f ]| \-\-force 
+.RB [ \-\-force ]]
 .RB [ \-y | \-\-yes ]
-.IR PhysicalVolume " [" PhysicalVolume ...]
+.I PhysicalVolume
+.RI [ PhysicalVolume ...]
 .SH DESCRIPTION
 .B pvremove
 wipes the label on a device so that LVM will no longer recognise it
--- LVM2/man/pvresize.8.in	2011/01/28 16:03:38	1.2
+++ LVM2/man/pvresize.8.in	2011/02/04 21:19:04	1.3
@@ -3,8 +3,15 @@
 pvresize \- resize a disk or partition in use by LVM2
 .SH SYNOPSIS
 .B pvresize
-.RB [ \-\-setphysicalvolumesize " " \fIsize ]
-.IR PhysicalVolume " [" PhysicalVolume ...]
+.RB [ \-d | \-\-debug ]
+.RB [ \-h | \-\-help ]
+.RB [ \-t | \-\-test ]
+.RB [ \-v | \-\-verbose ]
+.RB [ \-\-version ]
+.RB [ \-\-setphysicalvolumesize
+.IR size ]
+.I PhysicalVolume 
+.RI [ PhysicalVolume ...]
 .SH DESCRIPTION
 .B pvresize
 resizes
--- LVM2/man/pvscan.8.in	2011/01/28 16:03:38	1.2
+++ LVM2/man/pvscan.8.in	2011/02/04 21:19:04	1.3
@@ -3,6 +3,11 @@
 pvscan \- scan all disks for physical volumes
 .SH SYNOPSIS
 .B pvscan
+.RB [ \-d | \-\-debug ]
+.RB [ \-h | \-\-help ]
+.RB [ \-v | \-\-verbose ]
+.RB [ \-\-version ]
+.RB [ \-\-ignorelockingfailure ]
 .RB [ \-e | \-\-exported ]
 .RB [ \-n | \-\-novolumegroup ]
 .RB [ \-s | \-\-short ]


