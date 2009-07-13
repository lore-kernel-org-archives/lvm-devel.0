From: agk@sourceware.org <agk@sourceware.org>
Date: 13 Jul 2009 11:25:36 -0000
Subject: LVM2 ./WHATS_NEW man/vgcreate.8.in
Message-ID: <20090713112536.13283.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-07-13 11:25:36

Modified files:
	.              : WHATS_NEW 
	man            : vgcreate.8.in 

Log message:
	Fix dev name mismatch in vgcreate man page example.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1176&r2=1.1177
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgcreate.8.in.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/WHATS_NEW	2009/07/10 20:16:15	1.1176
+++ LVM2/WHATS_NEW	2009/07/13 11:25:35	1.1177
@@ -1,5 +1,6 @@
 Version 2.02.49 - 
 ================================
+  Fix dev name mismatch in vgcreate man page example.
   Refactor vg_remove_single for use in liblvm.
   Make all tools consistent with lock ordering - obtain VG_ORPHAN lock second.
   Check MD devices for a partition table during device scan.
--- LVM2/man/vgcreate.8.in	2009/07/06 19:13:26	1.2
+++ LVM2/man/vgcreate.8.in	2009/07/13 11:25:36	1.3
@@ -90,7 +90,7 @@
 To create a volume group named
 .B test_vg 
 using physical volumes
-.BR /dev/hdk1 ", and " /dev/hdl1
+.BR /dev/sdk1 ", and " /dev/sdl1
 with default physical extent size of 4MB:
 .nf
 


