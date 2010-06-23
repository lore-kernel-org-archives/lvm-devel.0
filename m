From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 23 Jun 2010 14:16:01 -0000
Subject: LVM2/man vgimportclone.8.in
Message-ID: <20100623141601.4301.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2010-06-23 14:15:58

Modified files:
	man            : vgimportclone.8.in 

Log message:
	Cleanup sentences of the example provided in the vgimportclone man page
	(motivated by a patch that Debian was carrying).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgimportclone.8.in.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/man/vgimportclone.8.in	2009/05/14 16:46:13	1.1
+++ LVM2/man/vgimportclone.8.in	2010/06/23 14:15:55	1.2
@@ -33,13 +33,12 @@
 The LVM2 binary to use.
 Defaults to "lvm".
 .SH EXAMPLES
-If origin VG
-.B test_vg 
-has PVs 
+The origin VG
+.B test_vg
+has origin PVs
 .BR /dev/loop0 " and " /dev/loop1
-and 
-.BR /dev/loop2 " and " /dev/loop3
-are respective snapshot PVs of the origin PVs.
+and the respective snapshot PVs are
+.BR /dev/loop2 " and " /dev/loop3 "."
 To rename the VG
 associated with
 .BR /dev/loop2 " and " /dev/loop3
@@ -47,7 +46,7 @@
 .B test_vg
 to
 .B test_vg_snap
-(and change associated VG and PV UUIDs):
+(and to change associated VG and PV UUIDs) do:
 .nf
 
 \	vgimportclone --basevgname test_vg_snap /dev/loop2 /dev/loop3


