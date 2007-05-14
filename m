From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 14 May 2007 11:27:35 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/dev_manager.c
Message-ID: <20070514112735.28059.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2007-05-14 11:27:34

Modified files:
	.              : WHATS_NEW 
	lib/activate   : dev_manager.c 

Log message:
	Fix a segfault if a device has no target (no table)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.615&r2=1.616
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.122&r2=1.123

--- LVM2/WHATS_NEW	2007/05/02 12:22:40	1.615
+++ LVM2/WHATS_NEW	2007/05/14 11:27:33	1.616
@@ -1,5 +1,6 @@
 Version 2.02.26 -
 =================================
+  Fix a segfault if a device has no target (no table)
   Add some more debuglogs to clvmd startup.
   Misc clvmd cleanups
 
--- LVM2/lib/activate/dev_manager.c	2007/04/26 16:44:58	1.122
+++ LVM2/lib/activate/dev_manager.c	2007/05/14 11:27:34	1.123
@@ -187,7 +187,7 @@
                 next = dm_get_next_target(dmt, next, &start, &length,
                                           &target_type, &params);
                 /* Skip if target type doesn't match */
-                if (!strcmp(target_type, "mirror"))
+                if (target_type && !strcmp(target_type, "mirror"))
 			goto out;
         } while (next);
 


