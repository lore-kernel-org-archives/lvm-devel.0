From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 22 Jan 2008 03:49:39 -0000
Subject: LVM2/tools vgsplit.c
Message-ID: <20080122034939.14990.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-01-22 03:49:39

Modified files:
	tools          : vgsplit.c 

Log message:
	Fix vgsplit test mode

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgsplit.c.diff?cvsroot=lvm2&r1=1.48&r2=1.49

--- LVM2/tools/vgsplit.c	2008/01/22 03:25:45	1.48
+++ LVM2/tools/vgsplit.c	2008/01/22 03:49:39	1.49
@@ -361,7 +361,8 @@
 	}
 
 	/* Remove EXPORTED flag from new VG */
-	if (!(vg_to = vg_lock_and_read(cmd, vg_name_to, NULL, LCK_NONE, 0,
+	if (!test_mode() &&
+	    !(vg_to = vg_lock_and_read(cmd, vg_name_to, NULL, LCK_NONE, 0,
 				       CORRECT_INCONSISTENT | FAIL_INCONSISTENT))) {
 		log_error("Volume group \"%s\" became inconsistent: please "
 			  "fix manually", vg_name_to);


