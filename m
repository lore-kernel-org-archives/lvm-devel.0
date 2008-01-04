From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 4 Jan 2008 11:48:41 -0000
Subject: LVM2 ./WHATS_NEW man/pvchange.8 man/pvcreate.8 ...
Message-ID: <20080104114841.8832.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2008-01-04 11:48:40

Modified files:
	.              : WHATS_NEW 
	man            : pvchange.8 pvcreate.8 vgchange.8 

Log message:
	Update --uuid argument description in man pages.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.750&r2=1.751
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/pvchange.8.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/pvcreate.8.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgchange.8.diff?cvsroot=lvm2&r1=1.13&r2=1.14

--- LVM2/WHATS_NEW	2008/01/03 19:03:31	1.750
+++ LVM2/WHATS_NEW	2008/01/04 11:48:40	1.751
@@ -1,5 +1,6 @@
 Version 2.02.30 -
 ===================================
+  Update --uuid argument description in man pages.
   Fix vgreduce PV list processing not to process every PV in the VG. (2.02.29)
   Extend lvconvert to use polldaemon.
   Add support for stacked mirrors.
--- LVM2/man/pvchange.8	2004/03/22 15:08:50	1.4
+++ LVM2/man/pvchange.8	2008/01/04 11:48:40	1.5
@@ -8,7 +8,8 @@
 [\-\-deltag Tag]
 [\-h/\-?/\-\-help]
 [\-t/\-\-test]
-[\-v/\-\-verbose] [\-a/\-\-all] [\-x/\-\-allocatable y/n] [PhysicalVolumePath...]
+[\-v/\-\-verbose] [\-a/\-\-all] [\-x/\-\-allocatable y/n]
+[\-u/\-\-uuid] [PhysicalVolumePath...]
 .SH DESCRIPTION
 pvchange allows you to change the allocation permissions of one or
 more physical volumes.
@@ -19,6 +20,9 @@
 If PhysicalVolumePath is not specified on the command line all
 physical volumes are searched for and used.
 .TP
+.I \-u, \-\-uuid
+Generate new random UUID for specified physical volumes.
+.TP
 .I \-x, \-\-allocatable y/n
 Enable or disable allocation of physical extents on this physical volume.
 .SH Example
--- LVM2/man/pvcreate.8	2005/03/03 21:52:58	1.5
+++ LVM2/man/pvcreate.8	2008/01/04 11:48:40	1.6
@@ -15,6 +15,7 @@
 .RB [ \-\-metadatasize size ]
 .RB [ \-\-restorefile file ]
 .RB [ \-\-setphysicalvolumesize size ]
+.RB [ \-u | \-\-uuid uuid ]
 .RB [ \-\-version ]
 .RB [ \-Z | \-\-zero y/n ]
 .IR PhysicalVolume " [" PhysicalVolume ...]
--- LVM2/man/vgchange.8	2007/06/18 14:14:33	1.13
+++ LVM2/man/vgchange.8	2008/01/04 11:48:40	1.14
@@ -11,6 +11,7 @@
 .RB [ \-a | \-\-available " [e|l] {" y | n }]
 .RB [ \-\-monitor " {" y | n }]
 .RB [ \-c | \-\-clustered " {" y | n }]
+.RB [ \-u | \-\-uuid ]
 .RB [ \-d | \-\-debug]
 .RB [ \-\-deltag
 .IR Tag ]
@@ -70,6 +71,9 @@
 particular time, you may still be able to use Volume Groups that
 are not marked as clustered.
 .TP
+.BR \-u ", " \-\-uuid
+Generate new random UUID for specified Volume Groups.
+.TP
 .BR \-\-monitor " " { y | n }
 Controls whether or not a mirrored logical volume is monitored by
 dmeventd, if it is installed.


