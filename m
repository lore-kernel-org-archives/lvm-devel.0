From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 9 Feb 2011 17:42:16 -0000
Subject: LVM2/man pvmove.8.in
Message-ID: <20110209174216.17308.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-02-09 17:42:16

Modified files:
	man            : pvmove.8.in 

Log message:
	Fix a typo in pvmove.8 (fixes BZ 673618, spotted by John Bradshaw).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/pvmove.8.in.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/man/pvmove.8.in	2009/08/04 08:09:52	1.3
+++ LVM2/man/pvmove.8.in	2011/02/09 17:42:15	1.4
@@ -21,7 +21,7 @@
 .IR DestinationPhysicalVolume (s).
 If no
 .I DestinationPhysicalVolume
-is specifed, the normal allocation rules for the volume group are used.
+is specified, the normal allocation rules for the volume group are used.
 
 If \fBpvmove\fP gets interrupted for any reason (e.g. the machine crashes)
 then run \fBpvmove\fP again without any PhysicalVolume arguments to


