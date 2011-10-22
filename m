From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 22 Oct 2011 16:48:59 -0000
Subject: LVM2/lib/metadata lv_manip.c
Message-ID: <20111022164859.9914.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-22 16:48:59

Modified files:
	lib/metadata   : lv_manip.c 

Log message:
	Remove old thin code from _lv_insert_empty_sublvs
	
	Since thin is not able to use _lv_insert_empty_sublvs,
	remove its appearence from this function.
	
	Start to use extend_pool() function for desired functionality
	and modify lv_extend() for this.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.302&r2=1.303

--- LVM2/lib/metadata/lv_manip.c	2011/10/22 16:46:34	1.302
+++ LVM2/lib/metadata/lv_manip.c	2011/10/22 16:48:59	1.303
@@ -2369,9 +2369,6 @@
 		lv->status |= MIRRORED;
 		sub_lv_status = MIRROR_IMAGE;
 		layer_name = "mimage";
-	} else if (segtype_is_thin_pool(segtype)) {
-		lv->status |= THIN_POOL;
-		layer_name = "tpool";
 	} else
 		return_0;
 
@@ -2406,19 +2403,13 @@
 					 lv->alloc, lv->vg)))
 			return_0;
 
-		if (segtype_is_thin_pool(segtype)) {
-			if (!attach_pool_data_lv(mapseg, sub_lv))
-				return_0;
-		} else if (!set_lv_segment_area_lv(mapseg, i, sub_lv, 0, sub_lv_status))
+		if (!set_lv_segment_area_lv(mapseg, i, sub_lv, 0, sub_lv_status))
 			return_0;
 
-		/* Metadata LVs for raid or thin pool */
+		/* Metadata LVs for raid */
 		if (segtype_is_raid(segtype)) {
 			if (dm_snprintf(img_name, len, "%s_rmeta_%u", lv->name, i) < 0)
 				return_0;
-		} else if (segtype_is_thin_pool(segtype)) {
-			if (dm_snprintf(img_name, len, "%s_tmeta", lv->name) < 0)
-				return_0;
 		} else
 			continue;
 
@@ -2428,12 +2419,10 @@
 					       lv->alloc, lv->vg)))
 			return_0;
 
-		if (segtype_is_thin_pool(segtype)) {
-			if (!attach_pool_metadata_lv(mapseg, sub_lv))
-				return_0;
-		} else if (!set_lv_segment_area_lv(mapseg, i, sub_lv, 0, RAID_META))
+		if (!set_lv_segment_area_lv(mapseg, i, sub_lv, 0, RAID_META))
 				return_0;
 	}
+
 	dm_list_add(&lv->segments, &mapseg->list);
 
 	return 1;
@@ -2562,29 +2551,15 @@
 	struct alloc_handle *ah;
 	uint32_t sub_lv_count;
 
-	/*
-	 * For RAID, all the devices are AREA_LV.
-	 * However, for 'mirror on stripe' using non-RAID targets,
-	 * the mirror legs are AREA_LV while the stripes underneath
-	 * are AREA_PV.  
-	 */
-	if (segtype_is_raid(segtype))
-		sub_lv_count = mirrors * stripes + segtype->parity_devs;
-	else if (segtype_is_thin_pool(segtype))
-		sub_lv_count = 1;
-	else
-		sub_lv_count = mirrors;
-
 	log_very_verbose("Extending segment type, %s", segtype->name);
 
 	if (segtype_is_virtual(segtype))
 		return lv_add_virtual_segment(lv, 0u, extents, segtype, thin_pool_name);
 
-	if (segtype_is_raid(segtype) && !lv->le_count)
-		log_count = mirrors * stripes;
-
 	if (segtype_is_thin_pool(segtype))
 		log_count = 1;
+	else if (segtype_is_raid(segtype) && !lv->le_count)
+		log_count = mirrors * stripes;
 
 	/* Thin pool allocation treats its metadata device like a mirror log. */
 	if (!(ah = allocate_extents(lv->vg, lv, segtype, stripes, mirrors,
@@ -2592,10 +2567,24 @@
 				    allocatable_pvs, alloc, NULL)))
 		return_0;
 
-	if (!segtype_is_mirrored(segtype) && !segtype_is_raid(segtype) && !segtype_is_thin_pool(segtype))
+	if (segtype_is_thin_pool(segtype)) {
+		if (!(r = extend_pool(lv, segtype, ah)))
+			stack;
+	} else if (!segtype_is_mirrored(segtype) && !segtype_is_raid(segtype))
 		r = lv_add_segment(ah, 0, ah->area_count, lv, segtype,
 				   stripe_size, 0u, 0);
 	else {
+		/*
+		 * For RAID, all the devices are AREA_LV.
+		 * However, for 'mirror on stripe' using non-RAID targets,
+		 * the mirror legs are AREA_LV while the stripes underneath
+		 * are AREA_PV.
+		 */
+		if (segtype_is_raid(segtype))
+			sub_lv_count = mirrors * stripes + segtype->parity_devs;
+		else
+			sub_lv_count = mirrors;
+
 		if (!lv->le_count &&
 		    !_lv_insert_empty_sublvs(lv, segtype, stripe_size,
 					     region_size, sub_lv_count)) {
@@ -4202,34 +4191,12 @@
 
 	init_dmeventd_monitor(lp->activation_monitoring);
 
-	if (seg_is_thin_pool(lp)) {
-		/* FIXME: skipping in test mode is not going work */
-		if (!activate_lv_excl(cmd, first_seg(lv)->pool_metadata_lv) ||
-		    /* Clear 4KB of metadata device for new thin-pool. */
-		    // FIXME: maybe -zero n  should  allow to recreate same thin pool
-		    // and different option should be used for zero_new_blocks
-		    !set_lv(cmd, first_seg(lv)->pool_metadata_lv, UINT64_C(0), 0)) {
-			log_error("Aborting. Failed to wipe pool metadata %s.",
-				  lv->name);
-			goto revert_new_lv;
-		}
-		/* FIXME: we may postpone finish of the pool creation to the
-		 * moment of the first activation - but this needs more changes
-		 * so we would update metadata with vgchange -ay
-		 *
-		 * For now always activate.
-		 */
+	if (seg_is_thin_pool(lp) || seg_is_thin(lp)) {
 		if (!activate_lv_excl(cmd, lv)) {
-			log_error("Aborting. Could not to activate thin pool %s.",
+			log_error("Aborting. Failed to activate thin %s.",
 				  lv->name);
 			goto revert_new_lv;
 		}
-	} else if (seg_is_thin(lp)) {
-		/* FIXME: same as with thin pool - add lazy creation support */
-		if (!activate_lv_excl(cmd, lv)) {
-			log_error("Aborting. Failed to activate thin %s.", lv->name);
-			goto revert_new_lv;
-		}
 	} else if (lp->snapshot) {
 		if (!activate_lv_excl(cmd, lv)) {
 			log_error("Aborting. Failed to activate snapshot "


