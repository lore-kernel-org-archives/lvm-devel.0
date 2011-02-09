From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 9 Feb 2011 22:24:55 -0000
Subject: LVM2/man pvmove.8.in
Message-ID: <20110209222455.30740.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2011-02-09 22:24:55

Modified files:
	man            : pvmove.8.in 

Log message:
	bug 659264: more examples for pvmove

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/pvmove.8.in.diff?cvsroot=lvm2&r1=1.4&r2=1.5

--- LVM2/man/pvmove.8.in	2011/02/09 17:42:15	1.4
+++ LVM2/man/pvmove.8.in	2011/02/09 22:24:55	1.5
@@ -95,12 +95,37 @@
 
 .SH EXAMPLES
 To move all logical extents of any logical volumes on
-.B /dev/hda4
-to free physical extents elsewhere in the volume group, giving verbose
-runtime information, use:
+.B /dev/sdb1
+to free physical extents elsewhere in the volume group, use:
 .sp
-\	pvmove -v /dev/hda4
+\	pvmove /dev/sdb1
+.P
+Additionally, the destination device can be specified.
 .sp
+\	pvmove /dev/sdb1 /dev/sdc1
+.P
+It is possible to perform the action on a single logical volume (instead of all
+the logical volumes that might be on the source device), like this:
+.sp
+\	pvmove -n lvol1 /dev/sdb1 /dev/sdc1
+.P
+Rather than moving the contents of the entire device, it is possible to
+move a range of extents.
+.sp
+\	pvmove /dev/sdb1:1000-1999
+.P
+It is possible to move the range of extents to a specific location (as long
+as the location has sufficent free extents) - even on the same device.
+.sp
+\	pvmove /dev/sdb1:1000-1999 /dev/sdc1
+.sp
+\	pvmove /dev/sdb1:1000-1999 /dev/sdb1:0-999
+.P
+A specific logical volume in a range of extents can also be picked out and
+moved.
+.sp
+\	pvmove -n lvol1 /dev/sdb1:1000-1999 /dev/sdc1
 .SH SEE ALSO
 .BR lvm (8),
 .BR vgconvert (8)
+.BR pvs (8)
\ No newline at end of file


