From: agk@sourceware.org <agk@sourceware.org>
Date: 28 Feb 2011 19:40:04 -0000
Subject: LVM2/man pvremove.8.in
Message-ID: <20110228194004.31869.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-02-28 19:40:04

Modified files:
	man            : pvremove.8.in 

Log message:
	mention vgreduce in pvremove man page

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/pvremove.8.in.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/man/pvremove.8.in	2011/02/04 21:19:04	1.3
+++ LVM2/man/pvremove.8.in	2011/02/28 19:40:04	1.4
@@ -22,6 +22,7 @@
 .TP
 .BR \-ff ", " \-\-force " " \-\-force
 Force the removal of a physical volume belonging to an existing volume group.
+Normally \fBvgreduce\fP(8) should be used instead of this command.
 You cannot remove a physical volume which in use by some active logical volume.
 .TP
 .BR \-y ", " \-\-yes
@@ -29,4 +30,5 @@
 .SH SEE ALSO
 .BR lvm (8),
 .BR pvcreate (8),
-.BR pvdisplay (8)
+.BR pvdisplay (8),
+.BR vgreduce (8)


