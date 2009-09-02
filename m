From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 2 Sep 2009 21:40:11 -0000
Subject: LVM2 ./WHATS_NEW liblvm/lvm2app.h liblvm/lvm_vg.c
Message-ID: <20090902214011.18828.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-09-02 21:40:10

Modified files:
	.              : WHATS_NEW 
	liblvm         : lvm2app.h lvm_vg.c 

Log message:
	Update lvm_vg_write() to handle the deferred commit of lvm_vg_write().
	
	Now that we've refactored the internal library functions that do the
	vg_remove, we can handle the deferred commit of a lvm_vg_remove() inside
	lvm_vg_write().  This makes the VG create/remove API more consistent in
	terms of disk commits - they now both require an lvm_vg_write() to commit
	the create or remove to disk.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1253&r2=1.1254
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm2app.h.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_vg.c.diff?cvsroot=lvm2&r1=1.27&r2=1.28

--- LVM2/WHATS_NEW	2009/09/02 21:34:11	1.1253
+++ LVM2/WHATS_NEW	2009/09/02 21:40:10	1.1254
@@ -1,5 +1,6 @@
 Version 2.02.52 -
 =================================
+  Update lvm_vg_remove to require lvm_vg_write to commit remove to disk.
   Enforce an alphabetical lock ordering for vgname locks.
   Refactor vgsplit, vgmerge, and vgrename to obey vgname ordering rules.
   Implement write lock prioritisation for file locking and make it default.
--- LVM2/liblvm/lvm2app.h	2009/08/13 12:18:15	1.6
+++ LVM2/liblvm/lvm2app.h	2009/09/02 21:40:10	1.7
@@ -394,8 +394,8 @@
 /**
  * Remove a VG from the system.
  *
- * This function commits the change to disk and does not require calling
- * lvm_vg_write.
+ * This function removes a Volume Group object in memory, and requires
+ * calling lvm_vg_write to commit the removal to disk.
  *
  * \param   vg
  * VG handle obtained from lvm_vg_create or lvm_vg_open.
--- LVM2/liblvm/lvm_vg.c	2009/09/02 21:39:29	1.27
+++ LVM2/liblvm/lvm_vg.c	2009/09/02 21:40:10	1.28
@@ -106,9 +106,9 @@
 		return -1;
 
 	if (dm_list_empty(&vg->pvs)) {
-		log_error("Volume group %s does not contain any "
-			  "physical volumes.", vg->name);
-		return -1;
+		if (!vg_remove(vg))
+			return -1;
+		return 0;
 	}
 
 	if (! dm_list_empty(&vg->removed_pvs)) {
@@ -156,8 +156,6 @@
 	if (!vg_remove_check(vg))
 		return -1;
 
-	if (!vg_remove(vg))
-		return -1;
 	return 0;
 }
 


