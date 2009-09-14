From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 14 Sep 2009 19:42:14 -0000
Subject: LVM2/man lvm.8.in vgs.8.in
Message-ID: <20090914194214.4977.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-09-14 19:42:13

Modified files:
	man            : lvm.8.in vgs.8.in 

Log message:
	Update lvm and vgs man pages to clarify 'partial' is a VG missing PVs.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvm.8.in.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgs.8.in.diff?cvsroot=lvm2&r1=1.9&r2=1.10

--- LVM2/man/lvm.8.in	2009/05/14 16:46:13	1.3
+++ LVM2/man/lvm.8.in	2009/09/14 19:42:13	1.4
@@ -182,8 +182,9 @@
 .TP
 \fB-P | --partial\fP
 When set, the tools will do their best to provide access to volume groups
-that are only partially available.  Where part of a logical volume is 
-missing, \fB/dev/ioerror\fP will be substituted, and you could use
+that are only partially available (one or more physical volumes belonging
+to the volume group are missing from the system).  Where part of a logical
+volume is missing, \fB/dev/ioerror\fP will be substituted, and you could use
 \fBdmsetup (8)\fP to set this up to return I/O errors when accessed,
 or create it as a large block device of nulls.  Metadata may not be
 changed with this option. To insert a replacement physical volume
--- LVM2/man/vgs.8.in	2009/07/07 19:28:57	1.9
+++ LVM2/man/vgs.8.in	2009/09/14 19:42:13	1.10
@@ -60,7 +60,8 @@
 .IP 3 3
 E(x)ported
 .IP 4 3
-(p)artial
+(p)artial: one or more physical volumes belonging to the volume group
+are missing from the system
 .IP 5 3
 Allocation policy: (c)ontiguous, c(l)ing, (n)ormal, (a)nywhere, (i)nherited
 .IP 6 3


