From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 17 Jun 2010 11:25:44 -0000
Subject: LVM2 ./WHATS_NEW man/lvextend.8.in man/lvreduc ...
Message-ID: <20100617112544.25455.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-06-17 11:25:43

Modified files:
	.              : WHATS_NEW 
	man            : lvextend.8.in lvreduce.8.in lvresize.8.in 

Log message:
	Update lvresize/extend/reduce manpages with --nofsck, --resizefs options

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1613&r2=1.1614
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvextend.8.in.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvreduce.8.in.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvresize.8.in.diff?cvsroot=lvm2&r1=1.7&r2=1.8

--- LVM2/WHATS_NEW	2010/06/16 13:03:48	1.1613
+++ LVM2/WHATS_NEW	2010/06/17 11:25:43	1.1614
@@ -1,5 +1,6 @@
 Version 2.02.68 -
 ===============================
+  Update lvresize/extend/reduce manpages with --nofsck, --resizefs options.
   Fix lvm2cmd example in documentation.
   Allow use of lvm2app and lvm2cmd headers in C++ mode.
   Fix wrong lvm path creation from configure introduced in previous release.
--- LVM2/man/lvextend.8.in	2010/02/03 03:58:08	1.6
+++ LVM2/man/lvextend.8.in	2010/06/17 11:25:43	1.7
@@ -9,6 +9,9 @@
 [\-i|\-\-stripes Stripes [\-I|\-\-stripesize StripeSize]]
 {\-l|\-\-extents [+]LogicalExtentsNumber[%{VG|LV|PVS|FREE|ORIGIN}] |
 \-L|\-\-size [+]LogicalVolumeSize[bBsSkKmMgGtTpPeE]}
+[\-f|\-\-force]
+[\-n|\-\-nofsck]
+[\-r|\-\-resizefs]
 [\-t|\-\-test]
 [\-v|\-\-verbose] LogicalVolumePath [PhysicalVolumePath[:PE[-PE]]...]
 .SH DESCRIPTION
@@ -60,6 +63,18 @@
 use a single value throughout.
 .br
 StripeSize must be 2^n (n = 2 to 9)
+.TP
+.I \-f, \-\-force
+Force size extension without any question.
+.TP
+.I \-n, \-\-nofsck
+Do not perform fsck before extending filesystem when filesystem
+requires it. You may need to use \fB--force\fR to proceed with 
+this option.
+.TP
+.I \-r, \-\-resizefs
+Resize underlying filesystem together with logical volume size.
+\fBfsadm\fR tool is used for filesystem resize.
 .SH Examples
 "lvextend -L +54 /dev/vg01/lvol10 /dev/sdk3" tries to extend the size of
 that logical volume by 54MB on physical volume /dev/sdk3.
@@ -77,6 +92,7 @@
 /dev/sda:8-9 and /dev/sdb:8-9 for allocation of extents.
 
 .SH SEE ALSO
+.BR fsadm (8),
 .BR lvm (8), 
 .BR lvcreate (8), 
 .BR lvconvert (8), 
--- LVM2/man/lvreduce.8.in	2010/02/03 03:58:08	1.6
+++ LVM2/man/lvreduce.8.in	2010/06/17 11:25:43	1.7
@@ -8,6 +8,8 @@
 [\-\-noudevsync]
 {\-l|\-\-extents [\-]LogicalExtentsNumber[%{VG|LV|FREE|ORIGIN}] |
 \-L|\-\-size [\-]LogicalVolumeSize[bBsSkKmMgGtTpPeE]}
+[\-n|\-\-nofsck]
+[\-r|\-\-resizefs]
 [\-t|\-\-test]
 [\-v|\-\-verbose] LogicalVolume[Path]
 .SH DESCRIPTION
@@ -64,10 +66,20 @@
 With the - sign the value will be subtracted from
 the logical volume's actual size and without it it will be taken as
 an absolute size.
+.TP
+.I \-n, \-\-nofsck
+Do not perform fsck before resizing filesystem when filesystem
+requires it. You may need to use \fB--force\fR to proceed with 
+this option. Note: using this option is dangerous.
+.TP
+.I \-r, \-\-resizefs
+Resize underlying filesystem together with logical volume size.
+\fBfsadm\fR tool is used for filesystem resize.
 .SH Example
 "lvreduce -l -3 vg00/lvol1" reduces the size of logical volume lvol1
 in volume group vg00 by 3 logical extents.
 .SH SEE ALSO
+.BR fsadm (8),
 .BR lvchange (8),
 .BR lvconvert (8), 
 .BR lvcreate (8), 
--- LVM2/man/lvresize.8.in	2010/02/03 03:58:08	1.7
+++ LVM2/man/lvresize.8.in	2010/06/17 11:25:43	1.8
@@ -9,6 +9,9 @@
 [\-i|\-\-stripes Stripes [\-I|\-\-stripesize StripeSize]]
 {\-l|\-\-extents [+]LogicalExtentsNumber[%{VG|LV|PVS|FREE|ORIGIN}] |
 \-L|\-\-size [+]LogicalVolumeSize[bBsSkKmMgGtTpPeE]}
+[\-f|\-\-force]
+[\-n|\-\-nofsck]
+[\-r|\-\-resizefs]
 [\-t|\-\-test]
 [\-v|\-\-verbose] LogicalVolumePath [PhysicalVolumePath[:PE[-PE]]...]
 .SH DESCRIPTION
@@ -67,6 +70,18 @@
 must use a single value throughout.
 .br
 StripeSize must be 2^n (n = 2 to 9)
+.TP
+.I \-f, \-\-force
+Force resize without any question.
+.TP
+.I \-n, \-\-nofsck
+Do not perform fsck before resizing filesystem when filesystem
+requires it. You may need to use \fB--force\fR to proceed with 
+this option.
+.TP
+.I \-r, \-\-resizefs
+Resize underlying filesystem together with logical volume size.
+\fBfsadm\fR tool is used for filesystem resize.
 .SH Examples
 .br
 "lvresize -L+16M vg1/lv1 /dev/sda:0-1 /dev/sdb:0-1"
@@ -75,6 +90,7 @@
 /dev/sda:0-1 and /dev/sdb:0-1 for allocation of extents.
 
 .SH SEE ALSO
+.BR fsadm (8),
 .BR lvm (8), 
 .BR lvconvert (8),
 .BR lvcreate (8), 


