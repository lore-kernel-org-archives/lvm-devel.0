From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 27 Feb 2012 09:56:29 -0000
Subject: LVM2 ./WHATS_NEW lib/filters/filter-sysfs.c
Message-ID: <20120227095629.6342.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-27 09:56:27

Modified files:
	.              : WHATS_NEW 
	lib/filters    : filter-sysfs.c 

Log message:
	Check allocation result

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2309&r2=1.2310
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter-sysfs.c.diff?cvsroot=lvm2&r1=1.22&r2=1.23

--- LVM2/WHATS_NEW	2012/02/23 22:50:50	1.2309
+++ LVM2/WHATS_NEW	2012/02/27 09:56:27	1.2310
@@ -1,5 +1,6 @@
 Version 2.02.94 - 
 ====================================
+  Test allocation result in sysfs filter creation.
   Limit sscanf parameters with buffer size in clvmd get_initial_state().
   Use const lv pointer for lv_is_active...() functions. 
   Use same signed numbers in _mirrored_transient_status().
--- LVM2/lib/filters/filter-sysfs.c	2010/09/22 01:36:14	1.22
+++ LVM2/lib/filters/filter-sysfs.c	2012/02/27 09:56:27	1.23
@@ -113,7 +113,9 @@
 		return NULL;
 
 	ds->mem = mem;
-	ds->sys_block = dm_pool_strdup(mem, sys_block);
+	if (!(ds->sys_block = dm_pool_strdup(mem, sys_block)))
+		return NULL;
+
 	ds->sysfs_depth = sysfs_depth;
 	ds->initialised = 0;
 


