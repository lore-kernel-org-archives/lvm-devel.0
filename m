From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 10 Mar 2011 13:12:01 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata.c
Message-ID: <20110310131201.23411.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-03-10 13:12:00

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata.c 

Log message:
	Use hash tables for validating names
	
	Accelerate validation loop by using lvname, lvid, pvid hash tables.
	Also merge pvl loop into one cycle now - no need to scan the list twice.
	List scan is stopped when dm_hash_insert fails.
	
	The error message with loop_counter1 is no longer provided - however
	the message has been misleading anyway.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1941&r2=1.1942
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.438&r2=1.439

--- LVM2/WHATS_NEW	2011/03/10 12:43:30	1.1941
+++ LVM2/WHATS_NEW	2011/03/10 13:11:59	1.1942
@@ -1,5 +1,6 @@
 Version 2.02.85 - 
 ===================================
+  Use hash tables to speedup string search in validate_vg().
   Refactor allocation of VG structure, add alloc_vg().
   Avoid possible endless loop in _free_vginfo when 4 or more VGs have same name.
   Use empty string instead of /dev// for LV path when there's no VG.
--- LVM2/lib/metadata/metadata.c	2011/03/10 12:43:30	1.438
+++ LVM2/lib/metadata/metadata.c	2011/03/10 13:12:00	1.439
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2010 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -2192,15 +2192,17 @@
 
 int vg_validate(struct volume_group *vg)
 {
-	struct pv_list *pvl, *pvl2;
-	struct lv_list *lvl, *lvl2;
+	struct pv_list *pvl;
+	struct lv_list *lvl;
 	struct lv_segment *seg;
 	char uuid[64] __attribute__((aligned(8)));
 	int r = 1;
 	uint32_t hidden_lv_count = 0, lv_count = 0, lv_visible_count = 0;
 	uint32_t pv_count = 0;
 	uint32_t num_snapshots = 0;
-	uint32_t loop_counter1, loop_counter2;
+	struct dm_hash_table *lvname_hash;
+	struct dm_hash_table *lvid_hash;
+	struct dm_hash_table *pvid_hash;
 
 	if (vg->alloc == ALLOC_CLING_BY_TAGS) {
 		log_error(INTERNAL_ERROR "VG %s allocation policy set to invalid cling_by_tags.",
@@ -2209,50 +2211,53 @@
 	}
 
 	/* FIXME Also check there's no data/metadata overlap */
+	if (!(pvid_hash = dm_hash_create(vg->pv_count))) {
+		log_error("Failed to allocate pvid hash.");
+		return 0;
+	}
+
 	dm_list_iterate_items(pvl, &vg->pvs) {
 		if (++pv_count > vg->pv_count) {
 			log_error(INTERNAL_ERROR "PV list corruption detected in VG %s.", vg->name);
 			/* FIXME Dump list structure? */
 			r = 0;
 		}
+
 		if (pvl->pv->vg != vg) {
 			log_error(INTERNAL_ERROR "VG %s PV list entry points "
-				  "to different VG %s", vg->name,
+				  "to different VG %s.", vg->name,
 				  pvl->pv->vg ? pvl->pv->vg->name : "NULL");
 			r = 0;
 		}
-	}
-
-	loop_counter1 = loop_counter2 = 0;
-	/* FIXME Use temp hash table instead? */
-	dm_list_iterate_items(pvl, &vg->pvs) {
-		if (++loop_counter1 > pv_count)
-			break;
-		dm_list_iterate_items(pvl2, &vg->pvs) {
-			if (++loop_counter2 > pv_count)
-				break;
-			if (pvl == pvl2)
-				break;
-			if (id_equal(&pvl->pv->id,
-				     &pvl2->pv->id)) {
-				if (!id_write_format(&pvl->pv->id, uuid,
-						     sizeof(uuid)))
-					 stack;
-				log_error(INTERNAL_ERROR "Duplicate PV id "
-					  "%s detected for %s in %s.",
-					  uuid, pv_dev_name(pvl->pv),
-					  vg->name);
-				r = 0;
-			}
-		}
 
 		if (strcmp(pvl->pv->vg_name, vg->name)) {
 			log_error(INTERNAL_ERROR "VG name for PV %s is corrupted.",
 				  pv_dev_name(pvl->pv));
 			r = 0;
 		}
+
+		if (dm_hash_lookup_binary(pvid_hash, &pvl->pv->id,
+					  sizeof(pvl->pv->id))) {
+			if (!id_write_format(&pvl->pv->id, uuid,
+					     sizeof(uuid)))
+				stack;
+			log_error(INTERNAL_ERROR "Duplicate PV id "
+				  "%s detected for %s in %s.",
+				  uuid, pv_dev_name(pvl->pv),
+				  vg->name);
+			r = 0;
+		}
+
+		if (!dm_hash_insert_binary(pvid_hash, &pvl->pv->id,
+					   sizeof(pvl->pv->id), pvl->pv)) {
+			log_error("Failed to hash pvid.");
+			r = 0;
+			break;
+		}
 	}
 
+	dm_hash_destroy(pvid_hash);
+
 	if (!check_pv_segments(vg)) {
 		log_error(INTERNAL_ERROR "PV segments corrupted in %s.",
 			  vg->name);
@@ -2320,33 +2325,34 @@
 	if (!r)
 		return r;
 
-	loop_counter1 = loop_counter2 = 0;
-	/* FIXME Use temp hash table instead? */
+	if (!(lvname_hash = dm_hash_create(lv_count))) {
+		log_error("Failed to allocate lv_name hash");
+		return 0;
+	}
+
+	if (!(lvid_hash = dm_hash_create(lv_count))) {
+		log_error("Failed to allocate uuid hash");
+		dm_hash_destroy(lvname_hash);
+		return 0;
+	}
+
 	dm_list_iterate_items(lvl, &vg->lvs) {
-		if (++loop_counter1 > lv_count)
-			break;
-		dm_list_iterate_items(lvl2, &vg->lvs) {
-			if (++loop_counter2 > lv_count)
-				break;
-			if (lvl == lvl2)
-				break;
-			if (!strcmp(lvl->lv->name, lvl2->lv->name)) {
-				log_error(INTERNAL_ERROR "Duplicate LV name "
-					  "%s detected in %s.", lvl->lv->name,
-					  vg->name);
-				r = 0;
-			}
-			if (id_equal(&lvl->lv->lvid.id[1],
-				     &lvl2->lv->lvid.id[1])) {
-				if (!id_write_format(&lvl->lv->lvid.id[1], uuid,
-						     sizeof(uuid)))
-					 stack;
-				log_error(INTERNAL_ERROR "Duplicate LV id "
-					  "%s detected for %s and %s in %s.",
-					  uuid, lvl->lv->name, lvl2->lv->name,
-					  vg->name);
-				r = 0;
-			}
+		if (dm_hash_lookup(lvname_hash, lvl->lv->name)) {
+			log_error(INTERNAL_ERROR
+				  "Duplicate LV name %s detected in %s.",
+				  lvl->lv->name, vg->name);
+			r = 0;
+		}
+
+		if (dm_hash_lookup_binary(lvid_hash, &lvl->lv->lvid.id[1],
+					  sizeof(lvl->lv->lvid.id[1]))) {
+			if (!id_write_format(&lvl->lv->lvid.id[1], uuid,
+					     sizeof(uuid)))
+				stack;
+			log_error(INTERNAL_ERROR "Duplicate LV id "
+				  "%s detected for %s in %s.",
+				  uuid, lvl->lv->name, vg->name);
+			r = 0;
 		}
 
 		if (!check_lv_segments(lvl->lv, 1)) {
@@ -2354,8 +2360,24 @@
 				  lvl->lv->name);
 			r = 0;
 		}
+
+		if (!dm_hash_insert(lvname_hash, lvl->lv->name, lvl)) {
+			log_error("Failed to hash lvname.");
+			r = 0;
+			break;
+		}
+
+		if (!dm_hash_insert_binary(lvid_hash, lvl->lv->lvid.id,
+					   sizeof(lvl->lv->lvid.id), lvl->lv)) {
+			log_error("Failed to hash lvid.");
+			r = 0;
+			break;
+		}
 	}
 
+	dm_hash_destroy(lvname_hash);
+	dm_hash_destroy(lvid_hash);
+
 	dm_list_iterate_items(lvl, &vg->lvs) {
 		if (!_lv_postorder(lvl->lv, _lv_validate_references_single, NULL))
 			r = 0;
@@ -2368,14 +2390,14 @@
 			if (seg_is_mirrored(seg)) {
 				if (seg->area_count != 2) {
 					log_error(INTERNAL_ERROR
-						  "Segment %d in %s is not 2-way.",
-						  loop_counter1, lvl->lv->name);
+						  "Segment in %s is not 2-way.",
+						  lvl->lv->name);
 					r = 0;
 				}
 			} else if (seg->area_count != 1) {
 				log_error(INTERNAL_ERROR
-					  "Segment %d in %s has wrong number of areas: %d.",
-					  loop_counter1, lvl->lv->name, seg->area_count);
+					  "Segment in %s has wrong number of areas: %d.",
+					  lvl->lv->name, seg->area_count);
 				r = 0;
 			}
 		}


