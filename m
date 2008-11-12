From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 12 Nov 2008 15:16:59 -0000
Subject: LVM2/man lvresize.8.in lvs.8.in pvs.8.in vgs.8.in
Message-ID: <20081112151659.21376.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-11-12 15:16:58

Modified files:
	man            : lvresize.8.in lvs.8.in pvs.8.in vgs.8.in 

Log message:
	More man page cleanup - convert "+/-" to "+|-"

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvresize.8.in.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvs.8.in.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/pvs.8.in.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgs.8.in.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/man/lvresize.8.in	2008/11/12 15:01:36	1.2
+++ LVM2/man/lvresize.8.in	2008/11/12 15:16:58	1.3
@@ -25,7 +25,7 @@
 .SH OPTIONS
 See \fBlvm\fP for common options.
 .TP
-.I \-l, \-\-extents [+/-]LogicalExtentsNumber[%{VG|LV|PVS|FREE}]
+.I \-l, \-\-extents [+|-]LogicalExtentsNumber[%{VG|LV|PVS|FREE}]
 Change or set the logical volume size in units of logical extents.
 With the + or - sign the value is added to or subtracted from the actual size
 of the logical volume and without it, the value is taken as an absolute one.
@@ -36,7 +36,7 @@
 suffix %PVS, or as a percentage of the remaining free space in the
 Volume Group with the suffix %FREE.
 .TP
-.I \-L, \-\-size [+/-]LogicalVolumeSize[kKmMgGtTpPeE]
+.I \-L, \-\-size [+|-]LogicalVolumeSize[kKmMgGtTpPeE]
 Change or set the logical volume size in units of megabytes.
 A size suffix of M for megabytes,
 G for gigabytes, T for terabytes, P for petabytes 
--- LVM2/man/lvs.8.in	2008/11/12 15:01:36	1.2
+++ LVM2/man/lvs.8.in	2008/11/12 15:16:58	1.3
@@ -6,7 +6,7 @@
 [\-\-aligned] [\-d|\-\-debug] [\-h|\-?|\-\-help]
 [\-\-ignorelockingfailure] [\-\-noheadings] [\-\-nosuffix]
 [\-o|\-\-options [+]Field[,Field]]
-[\-O|\-\-sort [+/-]Key1[,[+/-]Key2[,...]]]
+[\-O|\-\-sort [+|-]Key1[,[+|-]Key2[,...]]]
 [\-P|\-\-partial] [\-\-segments]
 [\-\-separator Separator] [\-\-unbuffered]
 [\-\-units hsbkmgtHKMGT]
--- LVM2/man/pvs.8.in	2008/11/12 15:01:36	1.2
+++ LVM2/man/pvs.8.in	2008/11/12 15:16:58	1.3
@@ -6,7 +6,7 @@
 [\-\-aligned] [\-d|\-\-debug] [\-h|\-?|\-\-help]
 [\-\-ignorelockingfailure] [\-\-noheadings] [\-\-nosuffix]
 [\-o|\-\-options [+]Field[,Field]]
-[\-O|\-\-sort [+/-]Key1[,[+/-]Key2[,...]]]
+[\-O|\-\-sort [+|-]Key1[,[+|-]Key2[,...]]]
 [\-\-separator Separator] [\-\-unbuffered]
 [\-\-units hsbkmgtHKMGT]
 [\-v|\-\-verbose] 
--- LVM2/man/vgs.8.in	2008/11/12 15:01:36	1.2
+++ LVM2/man/vgs.8.in	2008/11/12 15:16:58	1.3
@@ -6,7 +6,7 @@
 [\-\-aligned] [\-d|\-\-debug] [\-h|\-?|\-\-help]
 [\-\-ignorelockingfailure] [\-\-noheadings] [\-\-nosuffix]
 [\-o|\-\-options [+]Field[,Field]]
-[\-O|\-\-sort [+/-]Key1[,[+/-]Key2[,...]]]
+[\-O|\-\-sort [+|-]Key1[,[+|-]Key2[,...]]]
 [\-P|\-\-partial]
 [\-\-separator Separator] [\-\-unbuffered]
 [\-\-units hsbkmgtHKMGT]


