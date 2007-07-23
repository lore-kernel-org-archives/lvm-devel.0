From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 23 Jul 2007 21:10:37 -0000
Subject: LVM2/tools vgsplit.c
Message-ID: <20070723211037.18068.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2007-07-23 21:10:36

Modified files:
	tools          : vgsplit.c 

Log message:
	Fix error introduced with previous checkin

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgsplit.c.diff?cvsroot=lvm2&r1=1.33&r2=1.34

--- LVM2/tools/vgsplit.c	2007/07/23 21:03:42	1.33
+++ LVM2/tools/vgsplit.c	2007/07/23 21:10:36	1.34
@@ -240,7 +240,7 @@
 	}
 
 	log_verbose("Checking for volume group \"%s\"", vg_name_from);
-	if (!(vg_to = vg_lock_and_read(cmd, vg_name_from, LCK_VG_WRITE,
+	if (!(vg_from = vg_lock_and_read(cmd, vg_name_from, LCK_VG_WRITE,
 				       CLUSTERED | EXPORTED_VG |
 				       RESIZEABLE_VG | LVM_WRITE,
 				       CORRECT_INCONSISTENT | FAIL_INCONSISTENT)))


