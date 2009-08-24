From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 24 Aug 2009 11:37:21 -0000
Subject: LVM2 ./WHATS_NEW tools/toollib.c
Message-ID: <20090824113721.12644.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-08-24 11:37:21

Modified files:
	.              : WHATS_NEW 
	tools          : toollib.c 

Log message:
	Fix global locking in PV reporting commands (2.02.49).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1243&r2=1.1244
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.166&r2=1.167

--- LVM2/WHATS_NEW	2009/08/20 07:03:02	1.1243
+++ LVM2/WHATS_NEW	2009/08/24 11:37:20	1.1244
@@ -1,5 +1,6 @@
 Version 2.02.52 -
 =================================
+  Fix global locking in PV reporting commands (2.02.49).
   Fix pvcreate string termination in duplicate uuid warning message.
   Fix pvcreate on a partition (2.02.51).
   Fix vgcfgrestore error paths when locking fails (2.02.49).
--- LVM2/tools/toollib.c	2009/07/21 11:10:49	1.166
+++ LVM2/tools/toollib.c	2009/08/24 11:37:21	1.167
@@ -643,7 +643,7 @@
 
 	dm_list_init(&tags);
 
-	if (lock_global && !lock_vol(cmd, VG_GLOBAL, LCK_READ)) {
+	if (lock_global && !lock_vol(cmd, VG_GLOBAL, LCK_VG_READ)) {
 		log_error("Unable to obtain global lock.");
 		return ECMD_FAILED;
 	}


