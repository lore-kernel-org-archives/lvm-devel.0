From: agk@sourceware.org <agk@sourceware.org>
Date: 3 Aug 2009 18:09:26 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/dev_manager.c
Message-ID: <20090803180926.10360.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-08-03 18:09:26

Modified files:
	.              : WHATS_NEW 
	lib/activate   : dev_manager.c 

Log message:
	Only create LV symlinks on ACTIVATE not PRELOAD.
	(This is the udev behaviour - but does this change break anything?)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1228&r2=1.1229
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.156&r2=1.157

--- LVM2/WHATS_NEW	2009/08/02 21:59:21	1.1228
+++ LVM2/WHATS_NEW	2009/08/03 18:09:25	1.1229
@@ -1,5 +1,6 @@
 Version 2.02.51 - 
 ================================
+  Only change LV symlinks on ACTIVATE not PRELOAD.
   Make lvconvert honour log mirror options combined with downconversion.
   Allow LV suspend while --ignorelockingfailure is in force.
   Update synopsis in lvconvert manpage to mention --repair.
--- LVM2/lib/activate/dev_manager.c	2009/08/03 18:01:45	1.156
+++ LVM2/lib/activate/dev_manager.c	2009/08/03 18:09:26	1.157
@@ -1212,12 +1212,12 @@
 				stack;
 			if (!r)
 				goto_out;
+			if (!_create_lv_symlinks(dm, root)) {
+				log_error("Failed to create symlinks for %s.", lv->name);
+				goto out;
+			}
 		}
 
-		if (!_create_lv_symlinks(dm, root)) {
-			log_error("Failed to create symlinks for %s.", lv->name);
-			goto out;
-		}
 		break;
 	default:
 		log_error("_tree_action: Action %u not supported.", action);


