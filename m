From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 25 Apr 2012 13:38:44 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/vg.c
Message-ID: <20120425133844.2502.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2012-04-25 13:38:42

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : vg.c 

Log message:
	Disallow changing cluster attribute of VG while RAID LVs are active.
	
	Mirror and snapshot LVs are already checked for when switching the cluster
	attribute of a VG.  This patch adds RAID.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2392&r2=1.2393
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/vg.c.diff?cvsroot=lvm2&r1=1.17&r2=1.18

--- LVM2/WHATS_NEW	2012/04/25 09:32:36	1.2392
+++ LVM2/WHATS_NEW	2012/04/25 13:38:41	1.2393
@@ -1,5 +1,6 @@
 Version 2.02.96 - 
 ================================
+  Disallow changing cluster attribute of VG while RAID LVs are active.
   Fix lvconvert error message for non-mergeable volumes.
   Allow subset of failed devices to be replaced in RAID LVs.
   Prevent resume from creating error devices that already exist from suspend.
--- LVM2/lib/metadata/vg.c	2012/02/13 11:04:00	1.17
+++ LVM2/lib/metadata/vg.c	2012/04/25 13:38:42	1.18
@@ -517,9 +517,11 @@
 	 * on active mirrors or snapshots.
 	 */
 	dm_list_iterate_items(lvl, &vg->lvs) {
-		if (lv_is_mirrored(lvl->lv) && lv_is_active(lvl->lv)) {
-			log_error("Mirror logical volumes must be inactive "
-				  "when changing the cluster attribute.");
+		if (lv_is_active(lvl->lv) &&
+		    (lv_is_mirrored(lvl->lv) || lv_is_raid_type(lvl->lv))) {
+			log_error("%s logical volumes must be inactive "
+				  "when changing the cluster attribute.",
+				  lv_is_raid_type(lvl->lv) ? "RAID" : "Mirror");
 			return 0;
 		}
 


