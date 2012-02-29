From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 29 Feb 2012 22:08:59 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/lv_manip.c
Message-ID: <20120229220859.9054.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-29 22:08:58

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : lv_manip.c 

Log message:
	Wipe initial 4KiB for non-zeroed thin volumes
	
	If the thin pool has disabled zeroing  (created with -Zn), we at least
	clear initial 4KiB of such thin volume (provisions 1st block).
	
	If lvcreate is executed with '-an' command will abort (same way like we for
	normal LV - however for normal LV option -Zn may skip clearing completely,
	for thin volumes this option is not supported (applies only for pools).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2326&r2=1.2327
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.367&r2=1.368

--- LVM2/WHATS_NEW	2012/02/29 21:15:34	1.2326
+++ LVM2/WHATS_NEW	2012/02/29 22:08:57	1.2327
@@ -1,5 +1,6 @@
 Version 2.02.94 - 
 ====================================
+  Use set_lv() (wipe initial 4KiB) for non zeroed thin volume.
   Allow cluster mirrors to handle the absence of the checkpoint lib (libSaCkpt).
   Revert free of allocated segtype in init segment error path (2.02.89).
   Test dm_hash_insert() failures in filter-persistent.c and fid_add_mda().
--- LVM2/lib/metadata/lv_manip.c	2012/02/28 10:08:20	1.367
+++ LVM2/lib/metadata/lv_manip.c	2012/02/29 22:08:58	1.368
@@ -4457,7 +4457,10 @@
 
 	if (!seg_is_thin(lp) && !lp->zero && !lp->snapshot)
 		log_warn("WARNING: \"%s\" not zeroed", lv->name);
-	else if (!seg_is_thin(lp) && !set_lv(cmd, lv, UINT64_C(0), 0)) {
+	else if ((!seg_is_thin(lp) ||
+		  (lv_is_thin_volume(lv) &&
+		   !first_seg(first_seg(lv)->pool_lv)->zero_new_blocks)) &&
+		 !set_lv(cmd, lv, UINT64_C(0), 0)) {
 		log_error("Aborting. Failed to wipe %s.",
 			  lp->snapshot ? "snapshot exception store" :
 					 "start of new LV");


