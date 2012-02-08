From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 8 Feb 2012 13:02:09 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/lv_manip.c
Message-ID: <20120208130209.32629.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-08 13:02:08

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : lv_manip.c 

Log message:
	Fix test for lv_snapshot_percent
	
	Do not check for PERCENT_MERGE_FAILED if the lv_snapshot_percent() failed.
	(test for snap_percent would be testing uninitialized value).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2271&r2=1.2272
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.356&r2=1.357

--- LVM2/WHATS_NEW	2012/02/08 12:57:15	1.2271
+++ LVM2/WHATS_NEW	2012/02/08 13:02:07	1.2272
@@ -1,5 +1,6 @@
 Version 2.02.91 -
 ===================================
+  Fix test for snap percent for failing merge when removing LV.
   Switch int to void return for str_list_del().
   Fix error path handling in _build_desc().
   Add range test for device number in _scan_proc_dev().
--- LVM2/lib/metadata/lv_manip.c	2012/02/01 02:11:43	1.356
+++ LVM2/lib/metadata/lv_manip.c	2012/02/08 13:02:07	1.357
@@ -3315,14 +3315,14 @@
 		if (lv_is_merging_cow(lv) && !level) {
 			if (lv_info(lv->vg->cmd, lv, 0, &info, 1, 0) &&
 			    info.exists && info.live_table) {
-				if (lv_snapshot_percent(lv, &snap_percent) &&
-				    ((snap_percent != PERCENT_INVALID) &&
-				     (snap_percent != PERCENT_MERGE_FAILED))) {
+				if (!lv_snapshot_percent(lv, &snap_percent))
+					return_0;
+				if ((snap_percent != PERCENT_INVALID) &&
+				     (snap_percent != PERCENT_MERGE_FAILED)) {
 					log_error("Can't remove merging snapshot logical volume \"%s\"",
 						  lv->name);
 					return 0;
-				}
-				else if ((snap_percent == PERCENT_MERGE_FAILED) &&
+				} else if ((snap_percent == PERCENT_MERGE_FAILED) &&
 					 (force == PROMPT) &&
 					 yes_no_prompt("Removing snapshot \"%s\" that failed to merge may leave origin \"%s\" inconsistent. "
 						       "Proceed? [y/n]: ", lv->name, origin_from_cow(lv)->name) == 'n') {


