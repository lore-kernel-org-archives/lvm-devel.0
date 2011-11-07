From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 7 Nov 2011 10:58:14 -0000
Subject: LVM2 lib/activate/activate.c lib/metadata/lv_m ...
Message-ID: <20111107105814.8720.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-11-07 10:58:13

Modified files:
	lib/activate   : activate.c 
	lib/metadata   : lv_manip.c 
	tools          : lvresize.c vgchange.c 

Log message:
	Thin revert code for exclusive pool activation
	
	There are no limits on thin-pool activation now.
	Revert code that is no longer needed.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.219&r2=1.220
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.323&r2=1.324
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvresize.c.diff?cvsroot=lvm2&r1=1.141&r2=1.142
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgchange.c.diff?cvsroot=lvm2&r1=1.128&r2=1.129

--- LVM2/lib/activate/activate.c	2011/10/28 20:28:00	1.219
+++ LVM2/lib/activate/activate.c	2011/11/07 10:58:13	1.220
@@ -782,7 +782,7 @@
 		return 0;
 
 	dm_list_iterate_items(lvl, &vg->lvs)
-		if (lv_is_visible(lvl->lv) && !lv_is_used_thin_pool(lvl->lv))
+		if (lv_is_visible(lvl->lv))
 			count += (_lv_open_count(vg->cmd, lvl->lv) > 0);
 
 	log_debug("Counted %d open LVs in VG %s", count, vg->name);
--- LVM2/lib/metadata/lv_manip.c	2011/11/04 22:45:52	1.323
+++ LVM2/lib/metadata/lv_manip.c	2011/11/07 10:58:13	1.324
@@ -4184,19 +4184,6 @@
 	} else if (seg_is_thin_volume(lp)) {
 		pool_lv = first_seg(lv)->pool_lv;
 
-		/* Ensure unused thin pool is not active */
-		if (!lv_is_used_thin_pool(pool_lv) &&
-		    !deactivate_lv(cmd, pool_lv)) {
-			log_error("Failed to deactivate unused pool %s.",
-				  pool_lv->name);
-			goto revert_new_lv;
-		}
-
-		/*
-		 * From now the thin pool de/activation is made
-		 * only via implicit thin volume dependency.
-		 */
-
 		if (!(first_seg(lv)->device_id =
 		      get_free_pool_device_id(first_seg(pool_lv)))) {
 			stack;
--- LVM2/tools/lvresize.c	2011/11/04 22:49:53	1.141
+++ LVM2/tools/lvresize.c	2011/11/07 10:58:13	1.142
@@ -755,10 +755,6 @@
 	/* If snapshot, must suspend all associated devices */
 	if (lv_is_cow(lv))
 		lock_lv = origin_from_cow(lv);
-	else if (lv_is_used_thin_pool(lv))
-		// FIXME: what to pick here - maybe an active thin?
-		// but it still seems to be racy in cluster
-		lock_lv = lv;
 	else
 		lock_lv = lv;
 
--- LVM2/tools/vgchange.c	2011/11/03 14:41:18	1.128
+++ LVM2/tools/vgchange.c	2011/11/07 10:58:13	1.129
@@ -100,10 +100,6 @@
 		if (!lv_is_visible(lv))
 			continue;
 
-		/* Never manipulate with thin pools in use */
-		if (lv_is_used_thin_pool(lv))
-			continue;
-
 		/* If LV is sparse, activate origin instead */
 		if (lv_is_cow(lv) && lv_is_virtual_origin(origin_from_cow(lv)))
 			lv = origin_from_cow(lv);


