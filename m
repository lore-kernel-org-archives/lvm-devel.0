From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 20 Jan 2012 22:04:16 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/lv_manip.c
Message-ID: <20120120220416.28389.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2012-01-20 22:04:16

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : lv_manip.c 

Log message:
	Prompt if request is made to remove a snapshot whose "Merge failed".

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2232&r2=1.2233
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.344&r2=1.345

--- LVM2/WHATS_NEW	2012/01/20 22:03:48	1.2232
+++ LVM2/WHATS_NEW	2012/01/20 22:04:16	1.2233
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Prompt if request is made to remove a snapshot whose "Merge failed".
   Allow removal of an invalid snapshot that was to be merged on next activation.
   Don't allow a user to merge an invalid snapshot.
   Use m and M lv_attr to indicate that a snapshot merge failed in lvs.
--- LVM2/lib/metadata/lv_manip.c	2012/01/20 22:03:48	1.344
+++ LVM2/lib/metadata/lv_manip.c	2012/01/20 22:04:16	1.345
@@ -3271,7 +3271,7 @@
 	if (lv_is_cow(lv)) {
 		/*
 		 * A merging snapshot cannot be removed directly unless
-		 * it has been invalidated.
+		 * it has been invalidated or failed merge removal is requested.
 		 */
 		if (lv_is_merging_cow(lv) && !level) {
 			if (lv_info(lv->vg->cmd, lv, 0, &info, 1, 0) &&
@@ -3283,6 +3283,13 @@
 						  lv->name);
 					return 0;
 				}
+				else if ((snap_percent == PERCENT_MERGE_FAILED) &&
+					 (force == PROMPT) &&
+					 yes_no_prompt("Removing snapshot \"%s\" that failed to merge may leave origin \"%s\" inconsistent. "
+						       "Proceed? [y/n]: ", lv->name, origin_from_cow(lv)->name) == 'n') {
+					log_error("Logical volume %s not removed.", lv->name);
+					return 0;
+				}
 			}
 		}
 	}


