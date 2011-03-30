From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 30 Mar 2011 13:35:53 -0000
Subject: LVM2/lib/metadata metadata.c
Message-ID: <20110330133553.18521.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-03-30 13:35:52

Modified files:
	lib/metadata   : metadata.c 

Log message:
	Use created hash tables for quick check of LV, PV.
	
	Instead of searching linear list of all LVs, PVs - use created hash tables
	also for quick mapping between LV.
	
	(Note - for small number of PVs or LVs the overhead of the hash is bigger).
	
	TODO: Use hash tables in volume_group structure directly.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.451&r2=1.452

--- LVM2/lib/metadata/metadata.c	2011/03/29 21:57:56	1.451
+++ LVM2/lib/metadata/metadata.c	2011/03/30 13:35:51	1.452
@@ -2182,6 +2182,12 @@
 	}
 }
 
+struct validate_hash {
+	struct dm_hash_table *lvname;
+	struct dm_hash_table *lvid;
+	struct dm_hash_table *pvid;
+};
+
 /*
  * Check that an LV and all its PV references are correctly listed in vg->lvs
  * and vg->pvs, respectively. This only looks at a single LV, but *not* at the
@@ -2191,21 +2197,14 @@
 static int _lv_validate_references_single(struct logical_volume *lv, void *data)
 {
 	struct volume_group *vg = lv->vg;
+	struct validate_hash *vhash = data;
 	struct lv_segment *lvseg;
-	struct pv_list *pvl;
-	struct lv_list *lvl;
+	struct physical_volume *pv;
 	int s;
 	int r = 1;
-	int ok = 0;
 
-	dm_list_iterate_items(lvl, &vg->lvs) {
-		if (lvl->lv == lv) {
-			ok = 1;
-			break;
-		}
-	}
-
-	if (!ok) {
+	if (lv != dm_hash_lookup_binary(vhash->lvid, &lv->lvid.id[1],
+					sizeof(lv->lvid.id[1]))) {
 		log_error(INTERNAL_ERROR
 			  "Referenced LV %s not listed in VG %s.",
 			  lv->name, vg->name);
@@ -2214,22 +2213,16 @@
 
 	dm_list_iterate_items(lvseg, &lv->segments) {
 		for (s = 0; s < lvseg->area_count; ++s) {
-			if (seg_type(lvseg, s) == AREA_PV) {
-				ok = 0;
-				/* look up the reference in vg->pvs */
-				dm_list_iterate_items(pvl, &vg->pvs) {
-					if (pvl->pv == seg_pv(lvseg, s)) {
-						ok = 1;
-						break;
-					}
-				}
-
-				if (!ok) {
-					log_error(INTERNAL_ERROR
-						  "Referenced PV %s not listed in VG %s.",
-						  pv_dev_name(seg_pv(lvseg, s)), vg->name);
-					r = 0;
-				}
+			if (seg_type(lvseg, s) != AREA_PV)
+				continue;
+			pv = seg_pv(lvseg, s);
+			/* look up the reference in vg->pvs */
+			if (pv != dm_hash_lookup_binary(vhash->pvid, &pv->id,
+							sizeof(pv->id))) {
+				log_error(INTERNAL_ERROR
+					  "Referenced PV %s not listed in VG %s.",
+					  pv_dev_name(pv), vg->name);
+				r = 0;
 			}
 		}
 	}
@@ -2247,9 +2240,7 @@
 	uint32_t hidden_lv_count = 0, lv_count = 0, lv_visible_count = 0;
 	uint32_t pv_count = 0;
 	uint32_t num_snapshots = 0;
-	struct dm_hash_table *lvname_hash;
-	struct dm_hash_table *lvid_hash;
-	struct dm_hash_table *pvid_hash;
+	struct validate_hash vhash = { NULL };
 
 	if (vg->alloc == ALLOC_CLING_BY_TAGS) {
 		log_error(INTERNAL_ERROR "VG %s allocation policy set to invalid cling_by_tags.",
@@ -2258,7 +2249,7 @@
 	}
 
 	/* FIXME Also check there's no data/metadata overlap */
-	if (!(pvid_hash = dm_hash_create(vg->pv_count))) {
+	if (!(vhash.pvid = dm_hash_create(vg->pv_count))) {
 		log_error("Failed to allocate pvid hash.");
 		return 0;
 	}
@@ -2283,7 +2274,7 @@
 			r = 0;
 		}
 
-		if (dm_hash_lookup_binary(pvid_hash, &pvl->pv->id,
+		if (dm_hash_lookup_binary(vhash.pvid, &pvl->pv->id,
 					  sizeof(pvl->pv->id))) {
 			if (!id_write_format(&pvl->pv->id, uuid,
 					     sizeof(uuid)))
@@ -2295,7 +2286,7 @@
 			r = 0;
 		}
 
-		if (!dm_hash_insert_binary(pvid_hash, &pvl->pv->id,
+		if (!dm_hash_insert_binary(vhash.pvid, &pvl->pv->id,
 					   sizeof(pvl->pv->id), pvl->pv)) {
 			log_error("Failed to hash pvid.");
 			r = 0;
@@ -2303,7 +2294,6 @@
 		}
 	}
 
-	dm_hash_destroy(pvid_hash);
 
 	if (!check_pv_segments(vg)) {
 		log_error(INTERNAL_ERROR "PV segments corrupted in %s.",
@@ -2370,28 +2360,29 @@
 
 	/* Avoid endless loop if lv->segments list is corrupt */
 	if (!r)
-		return r;
+		goto out;
 
-	if (!(lvname_hash = dm_hash_create(lv_count))) {
+	if (!(vhash.lvname = dm_hash_create(lv_count))) {
 		log_error("Failed to allocate lv_name hash");
-		return 0;
+		r = 0;
+		goto out;
 	}
 
-	if (!(lvid_hash = dm_hash_create(lv_count))) {
+	if (!(vhash.lvid = dm_hash_create(lv_count))) {
 		log_error("Failed to allocate uuid hash");
-		dm_hash_destroy(lvname_hash);
-		return 0;
+		r = 0;
+		goto out;
 	}
 
 	dm_list_iterate_items(lvl, &vg->lvs) {
-		if (dm_hash_lookup(lvname_hash, lvl->lv->name)) {
+		if (dm_hash_lookup(vhash.lvname, lvl->lv->name)) {
 			log_error(INTERNAL_ERROR
 				  "Duplicate LV name %s detected in %s.",
 				  lvl->lv->name, vg->name);
 			r = 0;
 		}
 
-		if (dm_hash_lookup_binary(lvid_hash, &lvl->lv->lvid.id[1],
+		if (dm_hash_lookup_binary(vhash.lvid, &lvl->lv->lvid.id[1],
 					  sizeof(lvl->lv->lvid.id[1]))) {
 			if (!id_write_format(&lvl->lv->lvid.id[1], uuid,
 					     sizeof(uuid)))
@@ -2408,13 +2399,13 @@
 			r = 0;
 		}
 
-		if (!dm_hash_insert(lvname_hash, lvl->lv->name, lvl)) {
+		if (!dm_hash_insert(vhash.lvname, lvl->lv->name, lvl)) {
 			log_error("Failed to hash lvname.");
 			r = 0;
 			break;
 		}
 
-		if (!dm_hash_insert_binary(lvid_hash, &lvl->lv->lvid.id[1],
+		if (!dm_hash_insert_binary(vhash.lvid, &lvl->lv->lvid.id[1],
 					   sizeof(lvl->lv->lvid.id[1]), lvl->lv)) {
 			log_error("Failed to hash lvid.");
 			r = 0;
@@ -2422,10 +2413,7 @@
 		}
 	}
 
-	dm_hash_destroy(lvname_hash);
-	dm_hash_destroy(lvid_hash);
-
-	if (!_lv_postorder_vg(vg, _lv_validate_references_single, NULL)) {
+	if (!_lv_postorder_vg(vg, _lv_validate_references_single, &vhash)) {
 		stack;
 		r = 0;
 	}
@@ -2459,6 +2447,13 @@
 
 	if (vg_max_lv_reached(vg))
 		stack;
+out:
+	if (vhash.lvid)
+		dm_hash_destroy(vhash.lvid);
+	if (vhash.lvname)
+		dm_hash_destroy(vhash.lvname);
+	if (vhash.pvid)
+		dm_hash_destroy(vhash.pvid);
 
 	return r;
 }


