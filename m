From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed,  9 Mar 2011 13:18:32 +0100
Subject: [PATCH 1/4] Use hash tables for validating names
In-Reply-To: <cover.1299670163.git.zkabelac@redhat.com>
References: <cover.1299670163.git.zkabelac@redhat.com>
Message-ID: <3e35a80bc9effe4e90ca506b30dd1d66e3572c1d.1299670163.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Pick some low handing fruit and accelerate validation loop by
using lvname, lvid, pvid hash tables.
Comparing every name with >1000LVs becomes noticable.

Also merge pvl loop into one cycle now - no need to scan the list twice.

Somewhat unclear is error path behaviour when i.e. dm_hash_insert fails.
I've decided to break the loop in this moment with r=0.

Another noticable change here is - the error message with loop_counter1.
This counter is no longer provided - however the message must have been
misleading anyway.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/metadata/metadata.c |  138 +++++++++++++++++++++++++++--------------------
 1 files changed, 80 insertions(+), 58 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index ff61cbb..5525e3d 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2221,15 +2221,17 @@ static int _lv_validate_references_single(struct logical_volume *lv, void *data)
 
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
@@ -2238,50 +2240,53 @@ int vg_validate(struct volume_group *vg)
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
+			stack;
+			r = 0;
+			break;
+		}
 	}
 
+	dm_hash_destroy(pvid_hash);
+
 	if (!check_pv_segments(vg)) {
 		log_error(INTERNAL_ERROR "PV segments corrupted in %s.",
 			  vg->name);
@@ -2349,33 +2354,34 @@ int vg_validate(struct volume_group *vg)
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
+		if (dm_hash_lookup_binary(lvid_hash, lvl->lv->lvid.id,
+					  sizeof(lvl->lv->lvid.id))) {
+			if (!id_write_format(&lvl->lv->lvid.id[1], uuid,
+					     sizeof(uuid)))
+				stack;
+			log_error(INTERNAL_ERROR "Duplicate LV id "
+				  "%s detected for %s in %s.",
+				  uuid, lvl->lv->name, vg->name);
+			r = 0;
 		}
 
 		if (!check_lv_segments(lvl->lv, 1)) {
@@ -2383,8 +2389,24 @@ int vg_validate(struct volume_group *vg)
 				  lvl->lv->name);
 			r = 0;
 		}
+
+		if (!dm_hash_insert(lvname_hash, lvl->lv->name, lvl)) {
+			stack;
+			r = 0;
+			break;
+		}
+
+		if (!dm_hash_insert_binary(lvid_hash, lvl->lv->lvid.id,
+					   sizeof(lvl->lv->lvid.id), lvl->lv)) {
+			stack;
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
@@ -2397,14 +2419,14 @@ int vg_validate(struct volume_group *vg)
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
-- 
1.7.4.1


