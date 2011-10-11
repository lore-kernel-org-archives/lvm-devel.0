From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 11 Oct 2011 08:59:43 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/dev_manager.c
Message-ID: <20111011085943.30108.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-11 08:59:42

Modified files:
	.              : WHATS_NEW 
	lib/activate   : dev_manager.c 

Log message:
	Improve backtrace reporting
	
	Add <backtrace> so the function appears logged for the fail path.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2153&r2=1.2154
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.239&r2=1.240

--- LVM2/WHATS_NEW	2011/10/11 08:57:13	1.2153
+++ LVM2/WHATS_NEW	2011/10/11 08:59:42	1.2154
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Improve backtrace reporting for some dev_manager_ functions.
   Change message severity to log_warn when symlink creation fails.
   Add ability to convert mirror segtype to RAID1 segtype.
   Add ability to convert from linear to RAID1.
--- LVM2/lib/activate/dev_manager.c	2011/10/11 08:57:16	1.239
+++ LVM2/lib/activate/dev_manager.c	2011/10/11 08:59:42	1.240
@@ -1941,7 +1941,10 @@
 	if (!_tree_action(dm, lv, laopts, ACTIVATE))
 		return_0;
 
-	return _tree_action(dm, lv, laopts, CLEAN);
+	if (!_tree_action(dm, lv, laopts, CLEAN))
+		return_0;
+
+	return 1;
 }
 
 /* origin_only may only be set if we are resuming (not activating) an origin LV */
@@ -1949,7 +1952,7 @@
 			struct lv_activate_opts *laopts, int *flush_required)
 {
 	if (!_tree_action(dm, lv, laopts, PRELOAD))
-		return 0;
+		return_0;
 
 	*flush_required = dm->flush_required;
 
@@ -1959,11 +1962,11 @@
 int dev_manager_deactivate(struct dev_manager *dm, struct logical_volume *lv)
 {
 	struct lv_activate_opts laopts = { 0 };
-	int r;
 
-	r = _tree_action(dm, lv, &laopts, DEACTIVATE);
+	if (!_tree_action(dm, lv, &laopts, DEACTIVATE))
+		return_0;
 
-	return r;
+	return 1;
 }
 
 int dev_manager_suspend(struct dev_manager *dm, struct logical_volume *lv,
@@ -1971,7 +1974,10 @@
 {
 	dm->flush_required = flush_required;
 
-	return _tree_action(dm, lv, laopts, lockfs ? SUSPEND_WITH_LOCKFS : SUSPEND);
+	if (!_tree_action(dm, lv, laopts, lockfs ? SUSPEND_WITH_LOCKFS : SUSPEND))
+		return_0;
+
+	return 1;
 }
 
 /*


