From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 20 Oct 2011 10:35:14 -0000
Subject: LVM2/lib/metadata lv_manip.c
Message-ID: <20111020103514.28091.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-20 10:35:14

Modified files:
	lib/metadata   : lv_manip.c 

Log message:
	Ensure right activation order
	
	Couple FIXMEs put into the code for parts of the code which may be
	improved later, since we might be able to add 'lazy' device creation later.
	For now require exclusive activation.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.296&r2=1.297

--- LVM2/lib/metadata/lv_manip.c	2011/10/19 16:36:39	1.296
+++ LVM2/lib/metadata/lv_manip.c	2011/10/20 10:35:14	1.297
@@ -4214,7 +4214,33 @@
 
 	init_dmeventd_monitor(lp->activation_monitoring);
 
-	if (lp->snapshot) {
+	if (seg_is_thin_pool(lp)) {
+		/* FIXME: skipping in test mode is not going work */
+		if (!activate_lv_excl(cmd, first_seg(lv)->pool_metadata_lv) ||
+		    /* First 4KB of metadata device must be cleared. */
+		    !set_lv(cmd, first_seg(lv)->pool_metadata_lv, UINT64_C(0), 0)) {
+			log_error("Aborting. Failed to wipe pool metadata %s.",
+				  lv->name);
+			goto revert_new_lv;
+		}
+		/* FIXME: we may postpone finish of the pool creation to the
+		 * moment of the first activation - but this needs more changes
+		 * so we would update metadata with vgchange -ay
+		 *
+		 * For now always activate.
+		 */
+		if (!activate_lv_excl(cmd, lv)) {
+			log_error("Aborting. Could not to activate thin pool %s.",
+				  lv->name);
+			goto revert_new_lv;
+		}
+	} else if (seg_is_thin(lp)) {
+		/* FIXME: same as with thin pool - add lazy creation support */
+		if (!activate_lv_excl(cmd, lv)) {
+			log_error("Aborting. Failed to activate thin %s.", lv->name);
+			goto revert_new_lv;
+		}
+	} else if (lp->snapshot) {
 		if (!activate_lv_excl(cmd, lv)) {
 			log_error("Aborting. Failed to activate snapshot "
 				  "exception store.");
@@ -4236,12 +4262,9 @@
 			  lp->snapshot ? "snapshot exception store" :
 					 "start of new LV");
 		goto deactivate_and_revert_new_lv;
-	} else if (seg_is_thin_pool(lp)) {
-		if (!set_lv(cmd, first_seg(lv)->pool_metadata_lv, UINT64_C(0), 0))
-			log_error("Aborting. Failed to wipe pool metadata %s.",
-				  lv->name);
 	} else if (seg_is_thin_volume(lp)) {
-		/* since we've got here, we may drop any queued thin messages */
+		/* FIXME: for now we may drop any queued thin messages
+		 * since we are sure everything was activated already */
 		if (!detach_pool_messages(first_seg(first_seg(lv)->pool_lv)))
 			goto deactivate_and_revert_new_lv;
 


