From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 23 Feb 2010 15:49:53 -0000
Subject: LVM2/lib/activate dev_manager.c
Message-ID: <20100223154953.3353.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-02-23 15:49:52

Modified files:
	lib/activate   : dev_manager.c 

Log message:
	Add _mlog devices to dependency trees using UUID, not name, in activation.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.181&r2=1.182

--- LVM2/lib/activate/dev_manager.c	2010/02/17 22:59:46	1.181
+++ LVM2/lib/activate/dev_manager.c	2010/02/23 15:49:52	1.182
@@ -840,7 +840,8 @@
 	if (!_add_dev_to_dtree(dm, dtree, lv, "cow"))
 		return_0;
 
-	if (!_add_dev_to_dtree(dm, dtree, lv, "_mlog"))
+	if ((lv->status & MIRRORED) && first_seg(lv)->log_lv &&
+	    !_add_dev_to_dtree(dm, dtree, first_seg(lv)->log_lv, NULL))
 		return_0;
 
 	return 1;


