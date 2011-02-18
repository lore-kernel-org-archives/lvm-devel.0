From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 18 Feb 2011 14:26:32 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/activate.c
Message-ID: <20110218142632.9030.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-02-18 14:26:31

Modified files:
	.              : WHATS_NEW 
	lib/activate   : activate.c 

Log message:
	Remove fs_unlock after failed suspend
	
	Explicit fs_unlock() after failed suspend is not need -
	as it will happen automatically with nearest lv_info()
	or vg_unlock().

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1916&r2=1.1917
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.193&r2=1.194

--- LVM2/WHATS_NEW	2011/02/18 14:16:11	1.1916
+++ LVM2/WHATS_NEW	2011/02/18 14:26:31	1.1917
@@ -1,5 +1,6 @@
 Version 2.02.85 - 
 ===================================
+  Remove fs_unlock() from lv_suspend error path.
   Change memory locking semantic and use critical sections.
   Add configurable pv_min_size to select block devices by its size.
   Add function to read 64bit ints from config find_config_tree_int64.
--- LVM2/lib/activate/activate.c	2011/02/18 14:16:11	1.193
+++ LVM2/lib/activate/activate.c	2011/02/18 14:26:31	1.194
@@ -1126,7 +1126,6 @@
 
 	if (!_lv_suspend_lv(lv, origin_only, lockfs, flush_required)) {
 		critical_section_dec(cmd);
-		fs_unlock();
 		goto out;
 	}
 


