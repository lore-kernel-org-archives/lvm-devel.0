From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 6 Jul 2010 17:02:04 -0000
Subject: LVM2 ./WHATS_NEW tools/lvconvert.c
Message-ID: <20100706170204.5474.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2010-07-06 17:02:04

Modified files:
	.              : WHATS_NEW 
	tools          : lvconvert.c 

Log message:
	Fix for bug 607347: failing both redundant mirror log legs...
	
	Rather than attempting to remove all the images of a mirrored
	log volume via remove_mirror_images, simply remove the log
	if all its devices have failed.
	
	Taka was the first to report that there is still an outstanding
	issue with handling this case.  I've managed to reproduce it
	only very rarely, and am still working on identifying the problem.
	Failing to handle the problem rarely is better than not handling
	the scenario at all, so I'm checking this in.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1653&r2=1.1654
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.136&r2=1.137

--- LVM2/WHATS_NEW	2010/07/06 16:49:38	1.1653
+++ LVM2/WHATS_NEW	2010/07/06 17:02:03	1.1654
@@ -1,5 +1,6 @@
 Version 2.02.70 - 6th July 2010
 ===============================
+  Change logic to handle double failure of a "mirrored" mirror log.
   Randomly select which mdas to use or ignore.
   Add some missing standard configure.in checks.
   Add printf format attributes to yes_no_prompt and fix a caller.
--- LVM2/tools/lvconvert.c	2010/07/01 10:10:52	1.136
+++ LVM2/tools/lvconvert.c	2010/07/06 17:02:03	1.137
@@ -705,9 +705,12 @@
 		return 1;
 
 	/* Reducing redundancy of the log */
-	return remove_mirror_images(log_lv, log_count,
-				    is_mirror_image_removable,
-				    operable_pvs, 0U);
+	if (log_count)
+		return remove_mirror_images(log_lv, log_count,
+					    is_mirror_image_removable,
+					    operable_pvs, 0U);
+
+	return remove_mirror_log(lv->vg->cmd, lv, operable_pvs);
 }
 
 static int _lv_update_log_type(struct cmd_context *cmd,


