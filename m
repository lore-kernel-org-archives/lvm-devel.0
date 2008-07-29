From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 29 Jul 2008 18:35:01 -0000
Subject: LVM2/man pvcreate.8
Message-ID: <20080729183501.15524.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-07-29 18:35:01

Modified files:
	man            : pvcreate.8 

Log message:
	Fix trivial typo in pvcreate man page.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/pvcreate.8.diff?cvsroot=lvm2&r1=1.6&r2=1.7

--- LVM2/man/pvcreate.8	2008/01/04 11:48:40	1.6
+++ LVM2/man/pvcreate.8	2008/07/29 18:35:00	1.7
@@ -126,5 +126,5 @@
 .sp
 .SH SEE ALSO
 .BR lvm "(8), " vgcreate "(8), " vgextend "(8), " lvcreate "(8), "
-.BR cfdisk "(8), " fdisk "(8), " losetup "(8), " mdadd "(8), "
+.BR cfdisk "(8), " fdisk "(8), " losetup "(8), " mdadm "(8), "
 .BR vgcfgrestore "(8), " vgconvert "(8)"


