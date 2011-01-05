From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 5 Jan 2011 23:18:47 -0000
Subject: LVM2 ./WHATS_NEW tools/lvconvert.c
Message-ID: <20110105231847.30157.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2011-01-05 23:18:47

Modified files:
	.              : WHATS_NEW 
	tools          : lvconvert.c 

Log message:
	Reverting recent commit to disallow adding/removing mirror log while
	removing/adding mirror images... There was already code in there to
	do the job - I just didn't find it in WHATS_NEW (or in the code right
	away).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1861&r2=1.1862
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.153&r2=1.154

--- LVM2/WHATS_NEW	2011/01/05 20:02:45	1.1861
+++ LVM2/WHATS_NEW	2011/01/05 23:18:46	1.1862
@@ -1,6 +1,5 @@
 Version 2.02.80 - 
 ====================================
-  Prevent adding/removing mirror log while removing/adding an image.
   Add missing tests in _setup_task().
   Fail poll daemon creation when lvmcache_init() fails.
   Return defined value for errors in _copy_percent() and _snap_percent().
--- LVM2/tools/lvconvert.c	2011/01/05 20:02:45	1.153
+++ LVM2/tools/lvconvert.c	2011/01/05 23:18:47	1.154
@@ -927,25 +927,6 @@
 	}
 
 	/*
-	 * Disallow adding logs while removing images or
-	 *          adding images while removing logs
-	 */
-	if ((*old_log_count < *new_log_count) &&
-	    (*old_mimage_count > *new_mimage_count)) {
-		log_error("Mirror logs cannot be added while images are"
-			  " being removed.");
-		log_error("Try two separate commands.");
-		return 0;
-	}
-	if ((*old_log_count > *new_log_count) &&
-	    (*old_mimage_count < *new_mimage_count)) {
-		log_error("Mirror images cannot be added while logs are"
-			  " being removed.");
-		log_error("Try two separate commands.");
-		return 0;
-	}
-
-	/*
 	 * No mirrored logs for cluster mirrors until
 	 * log daemon is multi-threaded.
 	 */
@@ -1368,8 +1349,8 @@
         if (((old_mimage_count < new_mimage_count && old_log_count > new_log_count) ||
              (old_mimage_count > new_mimage_count && old_log_count < new_log_count)) &&
             lp->pv_count) {
-		log_error("Cannot both allocate and free extents when specifying physical"
-			  " volumes to use.");
+		log_error("Cannot both allocate and free extents when "
+			  "specifying physical volumes to use.");
 		log_error("Please specify the operation in two steps.");
 		return 0;
         }


