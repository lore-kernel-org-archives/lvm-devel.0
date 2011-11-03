From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 3 Nov 2011 14:56:20 -0000
Subject: LVM2/lib/metadata lv_manip.c
Message-ID: <20111103145620.32131.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-11-03 14:56:20

Modified files:
	lib/metadata   : lv_manip.c 

Log message:
	Thin using update_pool_lv
	
	Replace detach_pool_messages with update_pool_lv.
	Move creation code from to 'if' condition into 1.
	Ensure creation has finished all previous message operations.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.317&r2=1.318

--- LVM2/lib/metadata/lv_manip.c	2011/11/03 14:36:40	1.317
+++ LVM2/lib/metadata/lv_manip.c	2011/11/03 14:56:20	1.318
@@ -519,8 +519,14 @@
 			if (seg->pool_metadata_lv && !lv_remove(seg->pool_metadata_lv))
 				return_0;
 
-			if (seg->pool_lv && !detach_pool_lv(seg))
-				return_0;
+			if (seg->pool_lv) {
+                                /* For now, clear stacked messages here */
+				if (!update_pool_lv(seg->pool_lv, 1))
+					return_0;
+
+				if (!detach_pool_lv(seg))
+					return_0;
+			}
 
 			dm_list_del(&seg->list);
 			reduction = seg->len;
@@ -3917,6 +3923,7 @@
 	uint64_t status = UINT64_C(0);
 	struct logical_volume *lv, *org = NULL;
 	struct logical_volume *pool_lv;
+	struct lv_list *lvl;
 	int origin_active = 0;
 	struct lvinfo info;
 
@@ -4097,6 +4104,22 @@
 		}
 	}
 
+	if (seg_is_thin_volume(lp) &&
+	    ((lp->activate == CHANGE_AY) ||
+	     (lp->activate == CHANGE_AE) ||
+	     (lp->activate == CHANGE_ALY))) {
+		/* Ensure all stacked messages are submitted */
+		if (!(lvl = find_lv_in_vg(vg, lp->pool))) {
+			log_error("Unable to find existing pool LV %s in VG %s.",
+				  lp->pool, vg->name);
+			return 0;
+		}
+		if (!update_pool_lv(lvl->lv, 1)) {
+			stack;
+			goto revert_new_lv;
+		}
+	}
+
 	if (segtype_is_mirrored(lp->segtype) || segtype_is_raid(lp->segtype)) {
 		init_mirror_in_sync(lp->nosync);
 
@@ -4196,14 +4219,21 @@
 	init_dmeventd_monitor(lp->activation_monitoring);
 
 	if (seg_is_thin(lp)) {
-		if ((lp->activate == CHANGE_AY) ||
-		    (lp->activate == CHANGE_ALY))
-                        lp->activate = CHANGE_AE;
-		if ((lp->activate == CHANGE_AE) &&
-		    !activate_lv_excl(cmd, lv)) {
-			log_error("Aborting. Failed to activate thin %s.",
-				  lv->name);
-			goto deactivate_and_revert_new_lv;
+		if (((lp->activate == CHANGE_AY) ||
+		     (lp->activate == CHANGE_AE) ||
+		     (lp->activate == CHANGE_ALY))) {
+			if (!activate_lv_excl(cmd, lv)) {
+				log_error("Aborting. Failed to activate thin %s.",
+					  lv->name);
+				goto deactivate_and_revert_new_lv;
+			}
+
+			pool_lv = lv_is_thin_pool(lv) ? lv : first_seg(lv)->pool_lv;
+			/* Drop any queued thin messages after activation */
+			if (!update_pool_lv(pool_lv, 0)) {
+				stack;
+				goto deactivate_and_revert_new_lv;
+			}
 		}
 	} else if (lp->snapshot) {
 		if (!activate_lv_excl(cmd, lv)) {
@@ -4227,13 +4257,6 @@
 			  lp->snapshot ? "snapshot exception store" :
 					 "start of new LV");
 		goto deactivate_and_revert_new_lv;
-	} else if (seg_is_thin_volume(lp) && (lp->activate == CHANGE_AE)) {
-		/* FIXME: for now we may drop any queued thin messages
-		 * since we are sure everything was activated already */
-		if (!detach_pool_messages(first_seg(lv)->pool_lv)) {
-			stack;
-			goto deactivate_and_revert_new_lv;
-		}
 	}
 
 	if (lp->snapshot) {


