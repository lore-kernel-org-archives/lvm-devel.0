From: ccaulfield@sourceware.org <ccaulfield@sourceware.org>
Date: 5 Aug 2009 14:18:36 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/lvm-functions.c
Message-ID: <20090805141836.17430.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	ccaulfield at sourceware.org	2009-08-05 14:18:36

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : lvm-functions.c 

Log message:
	Fix locking in clvmd
	
	The changes to remove LCK_NONBLOCK from the LVM locks broke clvmd because the
	code was clearly wrong but working anyway! The constant was being masked rather
	than the variable that was supposed to match against it.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1231&r2=1.1232
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.67&r2=1.68

--- LVM2/WHATS_NEW	2009/08/04 15:55:43	1.1231
+++ LVM2/WHATS_NEW	2009/08/05 14:18:35	1.1232
@@ -1,5 +1,6 @@
 Version 2.02.51 - 
 ================================
+  Fix locking in clvmd (2.02.50).
   Add --noudevsync option for relevant LVM tools.
   Add activation/udev_sync to lvm.conf.
   Only change LV symlinks on ACTIVATE not PRELOAD.
--- LVM2/daemons/clvmd/lvm-functions.c	2009/07/24 18:15:07	1.67
+++ LVM2/daemons/clvmd/lvm-functions.c	2009/08/05 14:18:35	1.68
@@ -479,29 +479,29 @@
 
 	cmd->partial_activation = (lock_flags & LCK_PARTIAL_MODE) ? 1 : 0;
 
-	switch (command) {
-	case LCK_LV_EXCLUSIVE & LCK_MASK:
+	switch (command & LCK_MASK) {
+	case LCK_LV_EXCLUSIVE:
 		status = do_activate_lv(resource, lock_flags, LKM_EXMODE);
 		break;
 
-	case LCK_LV_SUSPEND & LCK_MASK:
+	case LCK_LV_SUSPEND:
 		status = do_suspend_lv(resource);
 		if (!status)
 			suspended++;
 		break;
 
 	case LCK_UNLOCK:
-	case LCK_LV_RESUME & LCK_MASK:	/* if active */
+	case LCK_LV_RESUME:	/* if active */
 		status = do_resume_lv(resource);
 		if (!status)
 			suspended--;
 		break;
 
-	case LCK_LV_ACTIVATE & LCK_MASK:
+	case LCK_LV_ACTIVATE:
 		status = do_activate_lv(resource, lock_flags, LKM_CRMODE);
 		break;
 
-	case LCK_LV_DEACTIVATE & LCK_MASK:
+	case LCK_LV_DEACTIVATE:
 		status = do_deactivate_lv(resource, lock_flags);
 		break;
 


