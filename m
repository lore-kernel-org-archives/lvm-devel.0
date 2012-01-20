From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 20 Jan 2012 22:03:49 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/lv_manip.c tools ...
Message-ID: <20120120220349.28245.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2012-01-20 22:03:49

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : lv_manip.c 
	tools          : lvconvert.c 

Log message:
	Allow removal of an invalid snapshot that was to be merged on next activation.
	
	Don't allow a user to merge an invalid snapshot.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2231&r2=1.2232
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.343&r2=1.344
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.178&r2=1.179

--- LVM2/WHATS_NEW	2012/01/20 22:03:03	1.2231
+++ LVM2/WHATS_NEW	2012/01/20 22:03:48	1.2232
@@ -1,5 +1,7 @@
 Version 2.02.89 - 
 ==================================
+  Allow removal of an invalid snapshot that was to be merged on next activation.
+  Don't allow a user to merge an invalid snapshot.
   Use m and M lv_attr to indicate that a snapshot merge failed in lvs.
   Differentiate between snapshot status of "Invalid" and "Merge failed".
   Lookup snapshot usage percent of origin volume when a snapshot is merging.
--- LVM2/lib/metadata/lv_manip.c	2012/01/19 15:39:41	1.343
+++ LVM2/lib/metadata/lv_manip.c	2012/01/20 22:03:48	1.344
@@ -3263,15 +3263,27 @@
 int lv_remove_with_dependencies(struct cmd_context *cmd, struct logical_volume *lv,
 				const force_t force, unsigned level)
 {
+	percent_t snap_percent;
 	struct dm_list *snh, *snht;
 	struct seg_list *sl, *tsl;
+	struct lvinfo info;
 
 	if (lv_is_cow(lv)) {
-		/* A merging snapshot cannot be removed directly */
+		/*
+		 * A merging snapshot cannot be removed directly unless
+		 * it has been invalidated.
+		 */
 		if (lv_is_merging_cow(lv) && !level) {
-			log_error("Can't remove merging snapshot logical volume \"%s\"",
-				  lv->name);
-			return 0;
+			if (lv_info(lv->vg->cmd, lv, 0, &info, 1, 0) &&
+			    info.exists && info.live_table) {
+				if (lv_snapshot_percent(lv, &snap_percent) &&
+				    ((snap_percent != PERCENT_INVALID) &&
+				     (snap_percent != PERCENT_MERGE_FAILED))) {
+					log_error("Can't remove merging snapshot logical volume \"%s\"",
+						  lv->name);
+					return 0;
+				}
+			}
 		}
 	}
 
--- LVM2/tools/lvconvert.c	2012/01/20 22:02:05	1.178
+++ LVM2/tools/lvconvert.c	2012/01/20 22:03:48	1.179
@@ -1709,6 +1709,8 @@
 {
 	struct lvconvert_params *lp = handle;
 	struct dm_list *failed_pvs;
+	struct lvinfo info;
+	percent_t snap_percent;
 
 	if (lv->status & LOCKED) {
 		log_error("Cannot convert locked LV %s", lv->name);
@@ -1742,6 +1744,13 @@
 				  lv->name);
 			return ECMD_FAILED;
 		}
+	        if (lv_info(lv->vg->cmd, lv, 0, &info, 1, 0)
+		    && info.exists && info.live_table &&
+		    (!lv_snapshot_percent(lv, &snap_percent) ||
+		     snap_percent == PERCENT_INVALID)) {
+			log_error("Unable to merge invalidated snapshot LV \"%s\"", lv->name);
+			return ECMD_FAILED;
+		}
 		if (!archive(lv->vg)) {
 			stack;
 			return ECMD_FAILED;


