From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 10 Jan 2011 13:44:40 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/fs.c lib/activat ...
Message-ID: <20110110134440.25922.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-01-10 13:44:39

Modified files:
	.              : WHATS_NEW 
	lib/activate   : fs.c fs.h 

Log message:
	Add internal fs cookie
	
	Add functions for handling internal lvm cookie used for
	all dm_tree operations until fs_unlock is called.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1868&r2=1.1869
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/fs.c.diff?cvsroot=lvm2&r1=1.53&r2=1.54
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/fs.h.diff?cvsroot=lvm2&r1=1.14&r2=1.15

--- LVM2/WHATS_NEW	2011/01/10 13:15:57	1.1868
+++ LVM2/WHATS_NEW	2011/01/10 13:44:39	1.1869
@@ -1,5 +1,6 @@
 Version 2.02.80 - 
 ====================================
+  Add internal lvm library cookie.
   Speedup command processing by caching resolved config tree.
   Pass config_tree to renamed function import_vg_from_config_tree().
   Detect NULL handle in get_property().
--- LVM2/lib/activate/fs.c	2010/12/13 10:43:57	1.53
+++ LVM2/lib/activate/fs.c	2011/01/10 13:44:39	1.54
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -26,6 +26,12 @@
 #include <limits.h>
 #include <dirent.h>
 
+/*
+ * Library cookie to combine multiple fs transactions.
+ * Supports to wait for udev device settle only when needed.
+ */
+static uint32_t _fs_cookie = DM_COOKIE_AUTO_CREATE;
+
 static int _mk_dir(const char *dev_dir, const char *vg_name)
 {
 	char vg_path[PATH_MAX];
@@ -396,7 +402,21 @@
 void fs_unlock(void)
 {
 	if (!memlock()) {
+		/* Wait for all processed udev devices */
+		if (!dm_udev_wait(_fs_cookie))
+			stack;
+		_fs_cookie = DM_COOKIE_AUTO_CREATE; /* Reset cookie */
 		dm_lib_release();
 		_pop_fs_ops();
 	}
 }
+
+uint32_t fs_get_cookie(void)
+{
+	return _fs_cookie;
+}
+
+void fs_set_cookie(uint32_t cookie)
+{
+	_fs_cookie = cookie;
+}
--- LVM2/lib/activate/fs.h	2010/01/07 19:54:21	1.14
+++ LVM2/lib/activate/fs.h	2011/01/10 13:44:39	1.15
@@ -30,5 +30,7 @@
 int fs_rename_lv(struct logical_volume *lv, const char *dev, 
 		 const char *old_vgname, const char *old_lvname);
 void fs_unlock(void);
+uint32_t fs_get_cookie(void);
+void fs_set_cookie(uint32_t cookie);
 
 #endif


