From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 23 Jun 2010 16:12:34 -0000
Subject: LVM2/man vgimportclone.8.in
Message-ID: <20100623161234.943.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2010-06-23 16:12:31

Modified files:
	man            : vgimportclone.8.in 

Log message:
	Use more standard naming for PVs and VG in vgimportclone example.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgimportclone.8.in.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/man/vgimportclone.8.in	2010/06/23 14:15:55	1.2
+++ LVM2/man/vgimportclone.8.in	2010/06/23 16:12:30	1.3
@@ -34,22 +34,22 @@
 Defaults to "lvm".
 .SH EXAMPLES
 The origin VG
-.B test_vg
+.B vg00
 has origin PVs
-.BR /dev/loop0 " and " /dev/loop1
+.BR /dev/sda " and " /dev/sdb
 and the respective snapshot PVs are
-.BR /dev/loop2 " and " /dev/loop3 "."
+.BR /dev/sdc " and " /dev/sdd "."
 To rename the VG
 associated with
-.BR /dev/loop2 " and " /dev/loop3
+.BR /dev/sdc " and " /dev/sdd
 from
-.B test_vg
+.B vg00
 to
-.B test_vg_snap
+.B vg00_snap
 (and to change associated VG and PV UUIDs) do:
 .nf
 
-\	vgimportclone --basevgname test_vg_snap /dev/loop2 /dev/loop3
+\	vgimportclone --basevgname vg00_snap /dev/sdc /dev/sdd
 
 .fi
 .SH SEE ALSO


