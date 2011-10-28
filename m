From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 28 Oct 2011 20:28:03 -0000
Subject: LVM2 lib/activate/activate.c lib/metadata/lv_m ...
Message-ID: <20111028202803.6184.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-28 20:28:01

Modified files:
	lib/activate   : activate.c 
	lib/metadata   : lv_manip.c metadata-exported.h 
	tools          : lvchange.c toollib.c vgchange.c 

Log message:
	Thin pool activation change
	
	To ensure we properly handle LV cluster locking - explicitely do
	not allow to change the availability of the thin pool that is in use
	for some thin LV.
	
	As soon as the thin volume is created the only way to activate pool
	is via implicit dependency.
	
	Ignore thinpool open count for lv/vgchange operations.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.218&r2=1.219
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.308&r2=1.309
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.217&r2=1.218
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvchange.c.diff?cvsroot=lvm2&r1=1.130&r2=1.131
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.231&r2=1.232
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgchange.c.diff?cvsroot=lvm2&r1=1.124&r2=1.125

--- LVM2/lib/activate/activate.c	2011/10/17 14:18:07	1.218
+++ LVM2/lib/activate/activate.c	2011/10/28 20:28:00	1.219
@@ -782,7 +782,7 @@
 		return 0;
 
 	dm_list_iterate_items(lvl, &vg->lvs)
-		if (lv_is_visible(lvl->lv))
+		if (lv_is_visible(lvl->lv) && !lv_is_used_thin_pool(lvl->lv))
 			count += (_lv_open_count(vg->cmd, lvl->lv) > 0);
 
 	log_debug("Counted %d open LVs in VG %s", count, vg->name);
--- LVM2/lib/metadata/lv_manip.c	2011/10/28 20:23:25	1.308
+++ LVM2/lib/metadata/lv_manip.c	2011/10/28 20:28:01	1.309
@@ -3210,7 +3210,7 @@
 		}
 	}
 
-	if (lv_is_thin_pool(lv) && dm_list_size(&lv->segs_using_this_lv)) {
+	if (lv_is_used_thin_pool(lv)) {
 		/* remove thin LVs first */
 		if ((force == PROMPT) &&
 		    yes_no_prompt("Do you really want to remove all thin volumes when removing"
@@ -4139,23 +4139,26 @@
 	} else if (seg_is_thin_volume(lp)) {
 		pool_lv = first_seg(lv)->pool_lv;
 
+		/* Ensure unused thin pool is not active */
+		if (!lv_is_used_thin_pool(pool_lv) &&
+		    !deactivate_lv(cmd, pool_lv)) {
+			log_error("Failed to deactivate unused pool %s.",
+				  pool_lv->name);
+			return NULL;
+		}
+
+		/*
+		 * From now the thin pool de/activation is made
+		 * only via implicit thin volume dependency.
+		 */
+
 		if (!(first_seg(lv)->device_id =
 		      get_free_pool_device_id(first_seg(pool_lv))))
 			return_NULL;
 
-		if (!activate_lv(pool_lv->vg->cmd, pool_lv)) {
-			log_error("Failed to activate %s/%s to send message.",
-				  pool_lv->vg->name, pool_lv->name);
-			return NULL;
-		}
-
 		if (!attach_pool_message(first_seg(pool_lv),
 					 DM_THIN_MESSAGE_CREATE_THIN, lv, 0, 0))
 			return_NULL;
-		/*
-		 * FIXME: Skipping deactivate_lv(pool_lv) as it is going to be needed anyway
-		 * but revert_new_lv should revert to deactivated state.
-		 */
 	}
 
 	if (lp->log_count &&
--- LVM2/lib/metadata/metadata-exported.h	2011/10/28 20:12:55	1.217
+++ LVM2/lib/metadata/metadata-exported.h	2011/10/28 20:28:01	1.218
@@ -136,6 +136,7 @@
 
 #define lv_is_thin_volume(lv)	((lv)->status & THIN_VOLUME ? 1 : 0)
 #define lv_is_thin_pool(lv)	((lv)->status & THIN_POOL ? 1 : 0)
+#define lv_is_used_thin_pool(lv)	(lv_is_thin_pool(lv) && !dm_list_empty(&(lv)->segs_using_this_lv))
 #define lv_is_thin_pool_data(lv)	((lv)->status & THIN_POOL_DATA ? 1 : 0)
 #define lv_is_thin_pool_metadata(lv)	((lv)->status & THIN_POOL_METADATA ? 1 : 0)
 #define lv_is_mirrored(lv)	((lv)->status & MIRRORED ? 1 : 0)
--- LVM2/tools/lvchange.c	2011/09/05 12:54:29	1.130
+++ LVM2/tools/lvchange.c	2011/10/28 20:28:01	1.131
@@ -532,6 +532,12 @@
 		return ECMD_FAILED;
 	}
 
+	if (lv_is_used_thin_pool(lv) &&
+	    (arg_count(cmd, available_ARG))) {
+		log_error("Can't change pool volume \"%s\".", lv->name);
+		return ECMD_FAILED;
+	}
+
 	if (lv_is_cow(lv) && !lv_is_virtual_origin(origin_from_cow(lv)) &&
 	    arg_count(cmd, available_ARG)) {
 		log_error("Can't change snapshot logical volume \"%s\"",
--- LVM2/tools/toollib.c	2011/09/15 15:26:40	1.231
+++ LVM2/tools/toollib.c	2011/10/28 20:28:01	1.232
@@ -126,6 +126,11 @@
 		if (lv_is_virtual_origin(lvl->lv) && !arg_count(cmd, all_ARG))
 			continue;
 
+		/* Only unused thin pool can change its availability */
+		if (!lvargs_supplied && lv_is_used_thin_pool(lvl->lv) &&
+		    arg_count(cmd, available_ARG))
+			continue;
+
 		/*
 		 * Only let hidden LVs through it --all was used or the LVs 
 		 * were specifically named on the command line.
--- LVM2/tools/vgchange.c	2011/10/22 16:47:23	1.124
+++ LVM2/tools/vgchange.c	2011/10/28 20:28:01	1.125
@@ -100,6 +100,10 @@
 		if (!lv_is_visible(lv))
 			continue;
 
+		/* Never manipulate with thin pools in use */
+		if (lv_is_used_thin_pool(lv))
+			continue;
+
 		/* If LV is sparse, activate origin instead */
 		if (lv_is_cow(lv) && lv_is_virtual_origin(origin_from_cow(lv)))
 			lv = origin_from_cow(lv);


