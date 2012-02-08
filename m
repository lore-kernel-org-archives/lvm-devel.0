From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 8 Feb 2012 10:43:43 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/fs.c
Message-ID: <20120208104343.16759.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-08 10:43:43

Modified files:
	.              : WHATS_NEW 
	lib/activate   : fs.c 

Log message:
	Check result of lstat
	
	If lstat returns errno different from ENOENT, do not use the content of
	struct stat 'buf'.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2257&r2=1.2258
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/fs.c.diff?cvsroot=lvm2&r1=1.64&r2=1.65

--- LVM2/WHATS_NEW	2012/02/01 20:13:44	1.2257
+++ LVM2/WHATS_NEW	2012/02/08 10:43:42	1.2258
@@ -1,5 +1,6 @@
 Version 2.02.91 -
 ===================================
+  Do not use lstat() results when failed in _rm_link().
   Remove a "waiting for another thread" log message from dmeventd plugins.
 
 Version 2.02.90 - 1st February 2012
--- LVM2/lib/activate/fs.c	2011/11/18 19:31:09	1.64
+++ LVM2/lib/activate/fs.c	2012/02/08 10:43:42	1.65
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2012 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -225,6 +225,7 @@
 static int _rm_link(const char *dev_dir, const char *vg_name,
 		    const char *lv_name, int check_udev)
 {
+	int r;
 	struct stat buf;
 	static char lv_path[PATH_MAX];
 
@@ -234,14 +235,14 @@
 		return 0;
 	}
 
-	if (lstat(lv_path, &buf) && errno == ENOENT)
+	if ((r = lstat(lv_path, &buf)) && errno == ENOENT)
 		return 1;
 	else if (dm_udev_get_sync_support() && udev_checking() && check_udev)
 		log_warn("The link %s should have been removed by udev "
 			 "but it is still present. Falling back to "
 			 "direct link removal.", lv_path);
 
-	if (!S_ISLNK(buf.st_mode)) {
+	if (r || !S_ISLNK(buf.st_mode)) {
 		log_error("%s not symbolic link - not removing", lv_path);
 		return 0;
 	}


