From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 3 Feb 2011 01:16:36 -0000
Subject: LVM2/lib/activate activate.c fs.c fs.h
Message-ID: <20110203011636.13491.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-02-03 01:16:35

Modified files:
	lib/activate   : activate.c fs.c fs.h 

Log message:
	Synchronize with udev for lv_info
	
	In case the open_count is requested via lv_info - check if there
	are any udev operations in-progress - and wait for them
	before checking for lv_info

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.186&r2=1.187
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/fs.c.diff?cvsroot=lvm2&r1=1.56&r2=1.57
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/fs.h.diff?cvsroot=lvm2&r1=1.16&r2=1.17

--- LVM2/lib/activate/activate.c	2011/01/13 14:51:33	1.186
+++ LVM2/lib/activate/activate.c	2011/02/03 01:16:35	1.187
@@ -460,6 +460,18 @@
 
 	if (!activation())
 		return 0;
+	/*
+	 * If open_count info is requested and we have to be sure our own udev
+	 * transactions are finished
+	 * For non-clustered locking type we are only interested for non-delete operation
+	 * in progress - as only those could lead to opened files
+	 */
+	if (with_open_count) {
+		if (locking_is_clustered())
+			sync_local_dev_names(cmd); /* Wait to have udev in sync */
+		else if (fs_has_non_delete_ops())
+			fs_unlock(); /* For non clustered - wait if there are non-delete ops */
+	}
 
 	if (!dev_manager_info(lv->vg->cmd->mem, lv, origin_only ? "real" : NULL, with_open_count,
 			      with_read_ahead, &dminfo, &info->read_ahead))
--- LVM2/lib/activate/fs.c	2011/01/12 20:42:50	1.56
+++ LVM2/lib/activate/fs.c	2011/02/03 01:16:35	1.57
@@ -422,3 +422,8 @@
 {
 	_fs_cookie = cookie;
 }
+
+int fs_has_non_delete_ops(void)
+{
+	return _other_fs_ops(FS_DEL);
+}
--- LVM2/lib/activate/fs.h	2011/01/10 14:02:31	1.16
+++ LVM2/lib/activate/fs.h	2011/02/03 01:16:35	1.17
@@ -32,5 +32,6 @@
 /* void fs_unlock(void);  moved to activate.h */
 uint32_t fs_get_cookie(void);
 void fs_set_cookie(uint32_t cookie);
+int fs_has_non_delete_ops(void);
 
 #endif


