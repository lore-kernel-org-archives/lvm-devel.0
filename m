From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 25 Jan 2012 22:16:05 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/activate.c
Message-ID: <20120125221605.7981.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-01-25 22:16:05

Modified files:
	.              : WHATS_NEW 
	lib/activate   : activate.c 

Log message:
	Fix missing dmt destructor
	
	Also always initialize maj,min,patchlevel when success is returned.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2242&r2=1.2243
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.240&r2=1.241

--- LVM2/WHATS_NEW	2012/01/25 21:52:53	1.2242
+++ LVM2/WHATS_NEW	2012/01/25 22:16:04	1.2243
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Fix memleak in target_version() error path (unsupported LIST_VERSIONS).
   Limit alignment to 32bit values.
   Check for correctness of uint64 dev_size value.
   Rename origin_only parameter to more generic flag use_layer for lv_info().
--- LVM2/lib/activate/activate.c	2012/01/25 13:12:59	1.240
+++ LVM2/lib/activate/activate.c	2012/01/25 22:16:04	1.241
@@ -481,7 +481,11 @@
 	if (!dm_task_run(dmt)) {
 		log_debug("Failed to get %s target version", target_name);
 		/* Assume this was because LIST_VERSIONS isn't supported */
-		return 1;
+		*maj = 0;
+		*min = 0;
+		*patchlevel = 0;
+		r = 1;
+		goto out;
 	}
 
 	target = dm_task_get_versions(dmt);


