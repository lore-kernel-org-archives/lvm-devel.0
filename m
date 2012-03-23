From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 23 Mar 2012 09:42:37 -0000
Subject: LVM2 ./WHATS_NEW lib/commands/toolcontext.c
Message-ID: <20120323094237.19286.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-23 09:42:37

Modified files:
	.              : WHATS_NEW 
	lib/commands   : toolcontext.c 

Log message:
	Fix typo in config option check

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2362&r2=1.2363
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.155&r2=1.156

--- LVM2/WHATS_NEW	2012/03/23 09:39:03	1.2362
+++ LVM2/WHATS_NEW	2012/03/23 09:42:36	1.2363
@@ -1,5 +1,6 @@
 Version 2.02.96 - 
 ================================
+  Fix global/detect_internal_vg_cache_corruption config check.
   Update lcov Makefile target to support all dmeventd plugins.
   Fix initializiation of thin monitoring (2.02.92).
   Support improperly formated device numbers in /proc/devices (2.02.91).
--- LVM2/lib/commands/toolcontext.c	2012/03/12 14:35:57	1.155
+++ LVM2/lib/commands/toolcontext.c	2012/03/23 09:42:36	1.156
@@ -387,7 +387,7 @@
 	init_pv_min_size((uint64_t)pv_min_kb * (1024 >> SECTOR_SHIFT));
 
 	init_detect_internal_vg_cache_corruption
-		(find_config_tree_int(cmd, "global/detect_internal_vg_cache_corruption()",
+		(find_config_tree_int(cmd, "global/detect_internal_vg_cache_corruption",
 				      DEFAULT_DETECT_INTERNAL_VG_CACHE_CORRUPTION));
 
 	lvmetad_set_active(find_config_tree_int(cmd, "global/use_lvmetad", 0));


