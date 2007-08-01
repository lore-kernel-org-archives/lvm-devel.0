From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 1 Aug 2007 20:54:29 -0000
Subject: LVM2/tools lvconvert.c
Message-ID: <20070801205429.12364.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2007-08-01 20:54:29

Modified files:
	tools          : lvconvert.c 

Log message:
	- cleanup excessive indentation in tools/lvconvert.c:lvconvert_mirrors

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.29&r2=1.30

--- LVM2/tools/lvconvert.c	2007/07/23 22:20:41	1.29
+++ LVM2/tools/lvconvert.c	2007/08/01 20:54:28	1.30
@@ -241,19 +241,32 @@
 	seg = first_seg(lv);
 	existing_mirrors = seg->area_count;
 
-	/* Adjust required number of mirrors */
-	if (lp->mirrors_sign == SIGN_PLUS)
+	/*
+	 * Adjust required number of mirrors
+	 *
+	 * We check mirrors_ARG again to see if it
+	 * was supplied.  If not, they want the mirror
+	 * count to remain the same.  They may be changing
+	 * the logging type.
+	 */
+	if (!arg_count(cmd, mirrors_ARG))
+		lp->mirrors = existing_mirrors;
+	else if (lp->mirrors_sign == SIGN_PLUS)
 		lp->mirrors = existing_mirrors + lp->mirrors;
-	else if (lp->mirrors_sign == SIGN_MINUS) {
-		if (lp->mirrors >= existing_mirrors) {
-			log_error("Logical volume %s only has %" PRIu32 " mirrors.",
-				  lv->name, existing_mirrors);
-			return 0;
-		}
+	else if (lp->mirrors_sign == SIGN_MINUS)
 		lp->mirrors = existing_mirrors - lp->mirrors;
-	} else
+	else
 		lp->mirrors += 1;
 
+	/*
+	 * Did the user try to subtract more legs than available?
+	 */
+	if (lp->mirrors < 1) {
+		log_error("Logical volume %s only has %" PRIu32 " mirrors.",
+			  lv->name, existing_mirrors);
+		return 0;
+	}
+
 	if (arg_count(cmd, regionsize_ARG) && (lv->status & MIRRORED) &&
 	    (lp->region_size != seg->region_size)) {
 		log_error("Mirror log region size cannot be changed on "
@@ -261,6 +274,9 @@
 		return 0;
 	}
 
+	/*
+	 * Converting from mirror to linear
+	 */
 	if ((lp->mirrors == 1)) {
 		if (!(lv->status & MIRRORED)) {
 			log_error("Logical volume %s is already not mirrored.",
@@ -271,133 +287,143 @@
 		if (!remove_mirror_images(seg, 1,
 					  lp->pv_count ? lp->pvh : NULL, 1))
 			return_0;
-	} else {		/* mirrors > 1 */
-		if ((lv->status & MIRRORED)) {
-			if (list_size(&lv->segments) != 1) {
-				log_error("Logical volume %s has multiple "
-					  "mirror segments.", lv->name);
-				return 0;
-			}
-			if (lp->mirrors == existing_mirrors) {
-				if (!seg->log_lv && !arg_count(cmd, corelog_ARG)) {
-					/* No disk log present, add one. */
-					if (!(parallel_areas = build_parallel_areas_from_lv(cmd, lv)))
-						return_0;
-					if (!lv_mirror_percent(cmd, lv, 0, &sync_percent, NULL)) {
-						log_error("Unable to determine mirror sync status.");
-						return 0;
-					}
-
-					segtype = get_segtype_from_string(cmd, "striped");
-
-					if (!(ah = allocate_extents(lv->vg, NULL, segtype, 0,
-								    0, 1, 0,
-								    NULL, 0, 0, lp->pvh,
-								    lp->alloc,
-								    parallel_areas))) {
-						stack;
-						return 0;
-					}
-
-					if (sync_percent >= 100.0)
-						init_mirror_in_sync(1);
-					else
-						init_mirror_in_sync(0);
-
-					if (!(log_lv = create_mirror_log(cmd, lv->vg, ah,
-									 lp->alloc, lv->name,
-									 (sync_percent >= 100.0) ?
-									 1 : 0, &lv->tags))) {
-						log_error("Failed to create mirror log.");
-						return 0;
-					}
-					seg->log_lv = log_lv;
-					log_lv->status |= MIRROR_LOG;
-					first_seg(log_lv)->mirror_seg = seg;
-				} else if (seg->log_lv && arg_count(cmd, corelog_ARG)) {
-					/* Had disk log, switch to core. */
-					if (!lv_mirror_percent(cmd, lv, 0, &sync_percent, NULL)) {
-						log_error("Unable to determine mirror sync status.");
-						return 0;
-					}
-
-					if (sync_percent >= 100.0)
-						init_mirror_in_sync(1);
-					else
-						init_mirror_in_sync(0);
-
-					if (!remove_mirror_images(seg, lp->mirrors,
-								  lp->pv_count ?
-								  lp->pvh : NULL, 1))
-						return_0;
-				} else {
-					/* No change */
-					log_error("Logical volume %s already has %"
-						  PRIu32 " mirror(s).", lv->name,
-						  lp->mirrors - 1);
-					return 1;
-				}
-			} else if (lp->mirrors > existing_mirrors) {
-				/* FIXME Unless anywhere, remove PV of log_lv 
-				 * from allocatable_pvs & allocate 
-				 * (mirrors - existing_mirrors) new areas
-				 */
-				/* FIXME Create mirror hierarchy to sync */
-				log_error("Adding mirror images is not "
-					  "supported yet.");
+		goto commit_changes;
+	}
+
+	/*
+	 * Converting from linear to mirror
+	 */
+	if (!(lv->status & MIRRORED)) {
+		/* FIXME Share code with lvcreate */
+
+		/* FIXME Why is this restriction here?  Fix it! */
+		list_iterate_items(seg, &lv->segments) {
+			if (seg_is_striped(seg) && seg->area_count > 1) {
+				log_error("Mirrors of striped volumes are not yet supported.");
 				return 0;
-			} else {
-				/* Reduce number of mirrors */
-				if (!remove_mirror_images(seg, lp->mirrors,
-							  lp->pv_count ?
-							  lp->pvh : NULL, 0))
-					return_0;
 			}
-		} else {
-			/* Make existing LV into mirror set */
-			/* FIXME Share code with lvcreate */
+		}
 
-			/* FIXME Why is this restriction here?  Fix it! */
-			list_iterate_items(seg, &lv->segments) {
-				if (seg_is_striped(seg) && seg->area_count > 1) {
-					log_error("Mirrors of striped volumes are not yet supported.");
-					return 0;
-				}
-			}
+		if (!(parallel_areas = build_parallel_areas_from_lv(cmd, lv)))
+			return_0;
+
+		if (!(ah = allocate_extents(lv->vg, NULL, lp->segtype,
+					    1, lp->mirrors - 1,
+					    arg_count(cmd, corelog_ARG) ? 0 : 1,
+					    lv->le_count * (lp->mirrors - 1),
+					    NULL, 0, 0, lp->pvh,
+					    lp->alloc,
+					    parallel_areas)))
+			return_0;
 
+		lp->region_size = adjusted_mirror_region_size(lv->vg->extent_size,
+							      lv->le_count,
+							      lp->region_size);
+
+		log_lv = NULL;
+		if (!arg_count(cmd, corelog_ARG) &&
+		    !(log_lv = create_mirror_log(cmd, lv->vg, ah,
+						 lp->alloc,
+						 lv->name, 0, &lv->tags))) {
+			log_error("Failed to create mirror log.");
+			return 0;
+		}
+
+		if (!create_mirror_layers(ah, 1, lp->mirrors, lv,
+					  lp->segtype, 0,
+					  lp->region_size,
+					  log_lv))
+			return_0;
+		goto commit_changes;
+	}
+
+	/*
+	 * Converting from mirror to mirror with different leg count,
+	 * or different log type.
+	 */
+	if (list_size(&lv->segments) != 1) {
+		log_error("Logical volume %s has multiple "
+			  "mirror segments.", lv->name);
+		return 0;
+	}
+
+	if (lp->mirrors == existing_mirrors) {
+		if (!seg->log_lv && !arg_count(cmd, corelog_ARG)) {
+			/* No disk log present, add one. */
 			if (!(parallel_areas = build_parallel_areas_from_lv(cmd, lv)))
 				return_0;
+			if (!lv_mirror_percent(cmd, lv, 0, &sync_percent, NULL)) {
+				log_error("Unable to determine mirror sync status.");
+				return 0;
+			}
+
+			segtype = get_segtype_from_string(cmd, "striped");
 
-			if (!(ah = allocate_extents(lv->vg, NULL, lp->segtype,
-						    1, lp->mirrors - 1,
-						    arg_count(cmd, corelog_ARG) ? 0 : 1,
-						    lv->le_count * (lp->mirrors - 1),
+			if (!(ah = allocate_extents(lv->vg, NULL, segtype, 0,
+						    0, 1, 0,
 						    NULL, 0, 0, lp->pvh,
 						    lp->alloc,
-						    parallel_areas)))
-				return_0;
+						    parallel_areas))) {
+				stack;
+				return 0;
+			}
 
-			lp->region_size = adjusted_mirror_region_size(lv->vg->extent_size,
-								      lv->le_count,
-								      lp->region_size);
-
-			log_lv = NULL;
-			if (!arg_count(cmd, corelog_ARG) &&
-			    !(log_lv = create_mirror_log(cmd, lv->vg, ah,
-							 lp->alloc,
-							 lv->name, 0, &lv->tags))) {
+			if (sync_percent >= 100.0)
+				init_mirror_in_sync(1);
+			else
+				init_mirror_in_sync(0);
+
+			if (!(log_lv = create_mirror_log(cmd, lv->vg, ah,
+							 lp->alloc, lv->name,
+							 (sync_percent >= 100.0) ?
+							 1 : 0, &lv->tags))) {
 				log_error("Failed to create mirror log.");
 				return 0;
 			}
+			seg->log_lv = log_lv;
+			log_lv->status |= MIRROR_LOG;
+			first_seg(log_lv)->mirror_seg = seg;
+		} else if (seg->log_lv && arg_count(cmd, corelog_ARG)) {
+			/* Had disk log, switch to core. */
+			if (!lv_mirror_percent(cmd, lv, 0, &sync_percent, NULL)) {
+				log_error("Unable to determine mirror sync status.");
+				return 0;
+			}
 
-			if (!create_mirror_layers(ah, 1, lp->mirrors, lv,
-						  lp->segtype, 0,
-						  lp->region_size,
-						  log_lv))
+			if (sync_percent >= 100.0)
+				init_mirror_in_sync(1);
+			else
+				init_mirror_in_sync(0);
+
+			if (!remove_mirror_images(seg, lp->mirrors,
+						  lp->pv_count ?
+						  lp->pvh : NULL, 1))
 				return_0;
+		} else {
+			/* No change */
+			log_error("Logical volume %s already has %"
+				  PRIu32 " mirror(s).", lv->name,
+				  lp->mirrors - 1);
+			return 1;
 		}
+	} else if (lp->mirrors > existing_mirrors) {
+		/* FIXME Unless anywhere, remove PV of log_lv
+		 * from allocatable_pvs & allocate
+		 * (mirrors - existing_mirrors) new areas
+		 */
+		/* FIXME Create mirror hierarchy to sync */
+		log_error("Adding mirror images is not "
+			  "supported yet.");
+		return 0;
+	} else {
+		/* Reduce number of mirrors */
+		if (!remove_mirror_images(seg, lp->mirrors,
+					  lp->pv_count ?
+					  lp->pvh : NULL, 0))
+			return_0;
 	}
 
+commit_changes:
 	log_very_verbose("Updating logical volume \"%s\" on disk(s)", lv->name);
 
 	if (!vg_write(lv->vg))
@@ -449,9 +475,9 @@
 	if (!lp->zero || !(lv->status & LVM_WRITE))
 		log_warn("WARNING: \"%s\" not zeroed", lv->name);
 	else if (!set_lv(cmd, lv, 0, 0)) {
-			log_error("Aborting. Failed to wipe snapshot "
-				  "exception store.");
-			return 0;
+		log_error("Aborting. Failed to wipe snapshot "
+			  "exception store.");
+		return 0;
 	}
 
 	if (!deactivate_lv(cmd, lv)) {


