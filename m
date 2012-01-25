From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 25 Jan 2012 09:15:44 -0000
Subject: LVM2/lib/metadata lv_manip.c
Message-ID: <20120125091544.32584.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-01-25 09:15:44

Modified files:
	lib/metadata   : lv_manip.c 

Log message:
	Thin correct activation order
	
	When the message is passed only in resume path the order needs
	to be corrected.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.351&r2=1.352

--- LVM2/lib/metadata/lv_manip.c	2012/01/25 09:14:25	1.351
+++ LVM2/lib/metadata/lv_manip.c	2012/01/25 09:15:44	1.352
@@ -4373,18 +4373,17 @@
 		if (((lp->activate == CHANGE_AY) ||
 		     (lp->activate == CHANGE_AE) ||
 		     (lp->activate == CHANGE_ALY))) {
+			/* At this point send message to kernel thin mda */
+			pool_lv = lv_is_thin_pool(lv) ? lv : first_seg(lv)->pool_lv;
+			if (!update_pool_lv(pool_lv, 1)) {
+				stack;
+				goto deactivate_and_revert_new_lv;
+			}
 			if (!activate_lv_excl(cmd, lv)) {
 				log_error("Aborting. Failed to activate thin %s.",
 					  lv->name);
 				goto deactivate_and_revert_new_lv;
 			}
-
-			pool_lv = lv_is_thin_pool(lv) ? lv : first_seg(lv)->pool_lv;
-			/* Drop any queued thin messages after activation */
-			if (!update_pool_lv(pool_lv, 0)) {
-				stack;
-				goto deactivate_and_revert_new_lv;
-			}
 		}
 	} else if (lp->snapshot) {
 		if (!activate_lv_excl(cmd, lv)) {


