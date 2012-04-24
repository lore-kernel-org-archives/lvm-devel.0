From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 24 Apr 2012 20:05:32 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/raid_manip.c
Message-ID: <20120424200532.15146.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2012-04-24 20:05:31

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : raid_manip.c 

Log message:
	Allow a subset of failed devices to be replaced in RAID LVs.
	
	If two devices in an array failed, it was previously impossible to replace
	just one of them.  This patch allows for the replacement of some, but perhaps
	not all, failed devices.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2390&r2=1.2391
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/raid_manip.c.diff?cvsroot=lvm2&r1=1.28&r2=1.29

--- LVM2/WHATS_NEW	2012/04/24 20:00:03	1.2390
+++ LVM2/WHATS_NEW	2012/04/24 20:05:31	1.2391
@@ -1,5 +1,6 @@
 Version 2.02.96 - 
 ================================
+  Allow subset of failed devices to be replaced in RAID LVs.
   Prevent resume from creating error devices that already exist from suspend.
   Improve clmvd singlenode locking for better testing.
   Update and correct lvs man page with supported column names.
--- LVM2/lib/metadata/raid_manip.c	2012/04/12 03:16:37	1.28
+++ LVM2/lib/metadata/raid_manip.c	2012/04/24 20:05:31	1.29
@@ -1632,10 +1632,28 @@
 	 *
 	 * - We need to change the LV names when we insert them.
 	 */
+try_again:
 	if (!_alloc_image_components(lv, allocate_pvs, match_count,
 				     &new_meta_lvs, &new_data_lvs)) {
 		log_error("Failed to allocate replacement images for %s/%s",
 			  lv->vg->name, lv->name);
+
+		/*
+		 * If this is a repair, then try to
+		 * do better than all-or-nothing
+		 */
+		if (match_count > 1) {
+			log_error("Attempting replacement of %u devices"
+				  " instead of %u", match_count - 1, match_count);
+			match_count--;
+
+			/*
+			 * Since we are replacing some but not all of the bad
+			 * devices, we must set partial_activation
+			 */
+			lv->vg->cmd->partial_activation = 1;
+			goto try_again;
+		}
 		return 0;
 	}
 


