From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 22 Jul 2009 03:13:36 -0000
Subject: LVM2/liblvm lvm_vg.c
Message-ID: <20090722031336.26517.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-22 03:13:36

Modified files:
	liblvm         : lvm_vg.c 

Log message:
	Fix lvm_vg_close() when locking fails.
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_vg.c.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/liblvm/lvm_vg.c	2009/07/14 03:02:14	1.1
+++ LVM2/liblvm/lvm_vg.c	2009/07/22 03:13:35	1.2
@@ -64,13 +64,11 @@
 
 int lvm_vg_close(vg_t *vg)
 {
-	if (vg_read_error(vg))
-		goto_bad;
-
-	unlock_and_release_vg(vg->cmd, vg, vg->name);
+	if (vg_read_error(vg) == FAILED_LOCKING)
+		vg_release(vg);
+	else
+		unlock_and_release_vg(vg->cmd, vg, vg->name);
 	return 1;
-bad:
-	return 0;
 }
 
 int lvm_vg_remove(vg_t *vg)


