From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 18 Aug 2011 19:31:33 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/raid_manip.c
Message-ID: <20110818193133.13685.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2011-08-18 19:31:33

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : raid_manip.c 

Log message:
	When down-converting RAID1, don't activate sub-lvs between suspend/resume
	of top-level LV.
	
	We can't activate sub-lv's that are being removed from a RAID1 LV while it
	is suspended.  However, this is what was being used to have them show-up
	so we could remove them.  'sync_local_dev_names' is a sufficient and
	proper replacement and can be done after the top-level LV is resumed.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2074&r2=1.2075
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/raid_manip.c.diff?cvsroot=lvm2&r1=1.4&r2=1.5

--- LVM2/WHATS_NEW	2011/08/17 15:15:36	1.2074
+++ LVM2/WHATS_NEW	2011/08/18 19:31:33	1.2075
@@ -1,5 +1,6 @@
 Version 2.02.88 - 
 ==================================
+  When down-converting RAID1, don't activate sub-lvs between suspend/resume
   Add -V as short form of --virtualsize in lvcreate.
   Fix make clean not to remove Makefile.  (2.02.87)
 
--- LVM2/lib/metadata/raid_manip.c	2011/08/13 04:28:34	1.4
+++ LVM2/lib/metadata/raid_manip.c	2011/08/18 19:31:33	1.5
@@ -488,22 +488,9 @@
 	}
 
 	/*
-	 * Bring extracted LVs into existance, so there are no
-	 * conflicts for the main RAID device's resume
+	 * Resume original LV
+	 * This also resumes all other sub-lvs (including the extracted)
 	 */
-	if (!dm_list_empty(&removal_list)) {
-		dm_list_iterate_items(lvl, &removal_list) {
-			/* If top RAID was EX, use EX */
-			if (lv_is_active_exclusive_locally(lv)) {
-				if (!activate_lv_excl(lv->vg->cmd, lvl->lv))
-					return_0;
-			} else {
-				if (!activate_lv(lv->vg->cmd, lvl->lv))
-					return_0;
-			}
-		}
-	}
-
 	if (!resume_lv(lv->vg->cmd, lv)) {
 		log_error("Failed to resume %s/%s after committing changes",
 			  lv->vg->name, lv->name);
@@ -513,6 +500,7 @@
 	/*
 	 * Eliminate the extracted LVs
 	 */
+	sync_local_dev_names(lv->vg->cmd);
 	if (!dm_list_empty(&removal_list)) {
 		dm_list_iterate_items(lvl, &removal_list) {
 			if (!deactivate_lv(lv->vg->cmd, lvl->lv))


