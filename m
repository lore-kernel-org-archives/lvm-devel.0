From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 14 Oct 2011 13:23:49 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/dev_manager.c li ...
Message-ID: <20111014132349.15957.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-14 13:23:48

Modified files:
	.              : WHATS_NEW 
	lib/activate   : dev_manager.c fs.c fs.h 

Log message:
	Fix lv_info open_count test
	
	When verify_udev_operations was disable, code for stacking fs operation for
	lvm links was completely disable - but this code was also used for collecting
	information, that a new node is being created.
	
	Add a new flag which is set when a creation of lv symlinks is requested which
	should restore old behaviour of lv_info function, that has called fs_sync()
	before quere for open count on device.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2160&r2=1.2161
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.244&r2=1.245
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/fs.c.diff?cvsroot=lvm2&r1=1.62&r2=1.63
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/fs.h.diff?cvsroot=lvm2&r1=1.17&r2=1.18

--- LVM2/WHATS_NEW	2011/10/11 09:54:39	1.2160
+++ LVM2/WHATS_NEW	2011/10/14 13:23:47	1.2161
@@ -1,6 +1,7 @@
 Version 2.02.89 - 
 ==================================
-  Simplify code for lvm worker thread in clvmd.
+  Fix lv_info open_count test for disabled verify_udev_operations (2.02.86).
+  Simplify code for lvm worker thread in clvmd.                     
   Use pthread_barrier to synchronize clvmd threads at startup.
   Limit clvmd's thread size to 128KiB.
   Reduce default preallocated stack size to 64KiB.
--- LVM2/lib/activate/dev_manager.c	2011/10/11 10:02:28	1.244
+++ LVM2/lib/activate/dev_manager.c	2011/10/14 13:23:47	1.245
@@ -1746,8 +1746,10 @@
 	int r = 1;
 
 	/* Nothing to do if udev fallback is disabled. */
-	if (!dm->cmd->current_settings.udev_fallback)
+	if (!dm->cmd->current_settings.udev_fallback) {
+		fs_set_create();
 		return 1;
+	}
 
 	while ((child = dm_tree_next_child(&handle, root, 0))) {
 		if (!(lvlayer = dm_tree_node_get_context(child)))
--- LVM2/lib/activate/fs.c	2011/04/08 14:40:19	1.62
+++ LVM2/lib/activate/fs.c	2011/10/14 13:23:48	1.63
@@ -32,6 +32,7 @@
  * Supports to wait for udev device settle only when needed.
  */
 static uint32_t _fs_cookie = DM_COOKIE_AUTO_CREATE;
+static int _fs_create = 0;
 
 static int _mk_dir(const char *dev_dir, const char *vg_name)
 {
@@ -427,6 +428,8 @@
 			  fsp->dev, fsp->old_lv_name, fsp->check_udev);
 		_del_fs_op(fsp);
 	}
+
+	_fs_create = 0;
 }
 
 static int _fs_op(fs_op_t type, const char *dev_dir, const char *vg_name,
@@ -500,7 +503,12 @@
 	_fs_cookie = cookie;
 }
 
+void fs_set_create(void)
+{
+	_fs_create = 1;
+}
+
 int fs_has_non_delete_ops(void)
 {
-	return _other_fs_ops(FS_DEL);
+	return _fs_create || _other_fs_ops(FS_DEL);
 }
--- LVM2/lib/activate/fs.h	2011/02/03 01:16:35	1.17
+++ LVM2/lib/activate/fs.h	2011/10/14 13:23:48	1.18
@@ -32,6 +32,7 @@
 /* void fs_unlock(void);  moved to activate.h */
 uint32_t fs_get_cookie(void);
 void fs_set_cookie(uint32_t cookie);
+void fs_set_create(void);
 int fs_has_non_delete_ops(void);
 
 #endif


