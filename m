From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 8 Feb 2012 11:17:35 -0000
Subject: LVM2 ./WHATS_NEW lib/locking/file_locking.c
Message-ID: <20120208111735.31746.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-08 11:17:35

Modified files:
	.              : WHATS_NEW 
	lib/locking    : file_locking.c 

Log message:
	Check that whole locking_dir fits _lock_dir buffer

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2264&r2=1.2265
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/file_locking.c.diff?cvsroot=lvm2&r1=1.62&r2=1.63

--- LVM2/WHATS_NEW	2012/02/08 11:12:18	1.2264
+++ LVM2/WHATS_NEW	2012/02/08 11:17:34	1.2265
@@ -1,5 +1,6 @@
 Version 2.02.91 -
 ===================================
+  Check that whole locking_dir fits _lock_dir buffer in init_file_locking().
   Use list functions for label_exit().
   Ensure strncpy() function always ends with '\0'.
   Set status in _fsadm_cmd() for error path.
--- LVM2/lib/locking/file_locking.c	2012/01/20 00:27:20	1.62
+++ LVM2/lib/locking/file_locking.c	2012/02/08 11:17:35	1.63
@@ -337,6 +337,7 @@
 		      int suppress_messages)
 {
 	int r;
+	const char *locking_dir;
 
 	locking->lock_resource = _file_lock_resource;
 	locking->reset_locking = _reset_file_locking;
@@ -344,9 +345,14 @@
 	locking->flags = 0;
 
 	/* Get lockfile directory from config file */
-	strncpy(_lock_dir, find_config_tree_str(cmd, "global/locking_dir",
-						DEFAULT_LOCK_DIR),
-		sizeof(_lock_dir));
+	locking_dir = find_config_tree_str(cmd, "global/locking_dir",
+					   DEFAULT_LOCK_DIR);
+	if (strlen(locking_dir) >= sizeof(_lock_dir)) {
+		log_error("Path for locking_dir %s is invalid.", locking_dir);
+		return 0;
+	}
+
+	strcpy(_lock_dir, locking_dir);
 
 	_prioritise_write_locks =
 	    find_config_tree_bool(cmd, "global/prioritise_write_locks",


