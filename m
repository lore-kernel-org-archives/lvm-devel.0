From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 9 Jun 2009 14:30:46 -0000
Subject: LVM2/tools vgcreate.c
Message-ID: <20090609143046.7049.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-06-09 14:30:45

Modified files:
	tools          : vgcreate.c 

Log message:
	Update vgcreate to use new vg_lock_newname().

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgcreate.c.diff?cvsroot=lvm2&r1=1.60&r2=1.61

--- LVM2/tools/vgcreate.c	2009/05/13 13:02:56	1.60
+++ LVM2/tools/vgcreate.c	2009/06/09 14:30:44	1.61
@@ -51,7 +51,7 @@
 		return ECMD_FAILED;
 	}
 
-	if (!lock_vol(cmd, vp_new.vg_name, LCK_VG_WRITE)) {
+	if (vg_lock_newname(cmd, vp_new.vg_name) != SUCCESS) {
 		log_error("Can't get lock for %s", vp_new.vg_name);
 		unlock_vg(cmd, VG_ORPHANS);
 		return ECMD_FAILED;


