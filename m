From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 10 Feb 2012 14:48:31 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/libdm-deptree.c
Message-ID: <20120210144831.20341.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-10 14:48:30

Modified files:
	.              : WHATS_NEW_DM 
	libdm          : libdm-deptree.c 

Log message:
	Check for deps pointer before dererence
	
	As _deps() call may return NULL - check for it.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.547&r2=1.548
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.155&r2=1.156

--- LVM2/WHATS_NEW_DM	2012/02/10 14:42:28	1.547
+++ LVM2/WHATS_NEW_DM	2012/02/10 14:48:28	1.548
@@ -1,6 +1,7 @@
 Version 1.02.70 - 
 ===================================
-  Validate name and uuid params of dm_tree_add_new_dev_with_udev_flags().  
+  Add pointer test for dependency check in _add_dev().
+  Validate name and uuid params of dm_tree_add_new_dev_with_udev_flags().
   Do not crash for dm_report_init() sort_key == NULL and behave like "".
   Return error for failing allocation in dm_asprintf().
   Add missing test for failing allocation in dm_realloc() code.
--- LVM2/libdm/libdm-deptree.c	2012/02/10 14:42:28	1.155
+++ LVM2/libdm/libdm-deptree.c	2012/02/10 14:48:28	1.156
@@ -1180,7 +1180,7 @@
 		goto out;
 
 	/* Can't recurse if not a mapped device or there are no dependencies */
-	if (!node->info.exists || !deps->count) {
+	if (!node->info.exists || !deps || !deps->count) {
 		if (!_add_to_bottomlevel(node)) {
 			stack;
 			node = NULL;


