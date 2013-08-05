From: Jonathan Brassow <jbrassow@redhat.com>
Date: Mon,  5 Aug 2013 15:03:12 -0500
Subject: [PATCH 1/6] Misc: Make get_pv_list_for_lv() available to more than just RAID
In-Reply-To: <1375732997-23644-1-git-send-email-jbrassow@redhat.com>
References: <1375732997-23644-1-git-send-email-jbrassow@redhat.com>
Message-ID: <1375732997-23644-2-git-send-email-jbrassow@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The function 'get_pv_list_for_lv' will assemble all the PVs that are
used by the specified LV.
---
 lib/metadata/lv_manip.c          |   76 ++++++++++++++++++++++++++++++++++++++
 lib/metadata/metadata-exported.h |    2 +
 lib/metadata/raid_manip.c        |   59 ++++++++---------------------
 3 files changed, 95 insertions(+), 42 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 24c66ef..d835411 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -162,6 +162,82 @@ int lv_is_on_pvs(struct logical_volume *lv, struct dm_list *pvs)
 }
 
 /*
+ * get_pv_list_for_lv
+ * @mem - mempool to allocate the list from.
+ * @lv
+ * @pvs - The list to add pv_list items to.
+ *
+ * 'pvs' is filled with 'pv_list' items for PVs that compose the LV.
+ * If the 'pvs' list already has items in it, duplicates will not be
+ * added.  So, it is safe to repeatedly call this function for different
+ * LVs and build up a list of PVs for them all.
+ * Currently handles:
+ *  - linear
+ *  - stripe
+ *  - raid
+ * It is up to the caller to free the pv_list when they are finished
+ * with it.
+ *
+ * Returns: 1 on success, 0 on error
+ */
+int get_pv_list_for_lv(struct dm_pool *mem,
+		       struct logical_volume *lv, struct dm_list *pvs)
+{
+	int dup_found;
+	uint32_t s;
+	struct pv_list *pvl;
+	struct lv_segment *seg = first_seg(lv);
+
+	log_debug_metadata("Getting list of PVs that %s/%s is on:",
+			   lv->vg->name, lv->name);
+
+	dm_list_iterate_items(seg, &lv->segments) {
+		for (s = 0; s < seg->area_count; s++) {
+			dup_found = 0;
+
+			if (seg_is_raid(seg) && /* RAID metadata areas */
+			    (seg_type(seg, s) == AREA_LV) &&
+			    !get_pv_list_for_lv(mem, seg_metalv(seg, s), pvs))
+				return_0;
+
+			if (seg_type(seg, s) == AREA_LV) { /* Recurse */
+				if (!get_pv_list_for_lv(mem,
+							seg_lv(seg, s), pvs))
+					return_0;
+				continue;
+			}
+
+			if (seg_type(seg, s) != AREA_PV) {
+				log_error(INTERNAL_ERROR
+					  "Linear seg_type should be AREA_PV");
+				return 0;
+			}
+
+			/* do not add duplicates */
+			dm_list_iterate_items(pvl, pvs)
+				if (pvl->pv == seg_pv(seg, s))
+					dup_found = 1;
+
+			if (dup_found)
+				continue;
+
+			if (!(pvl = dm_pool_zalloc(mem, sizeof(*pvl)))) {
+				log_error("Failed to allocate memory");
+				return 0;
+			}
+
+			pvl->pv = seg_pv(seg, s);
+			log_debug_metadata("  %s/%s is on %s", lv->vg->name,
+					   lv->name, pv_dev_name(pvl->pv));
+
+			dm_list_add(pvs, &pvl->list);
+		}
+	}
+
+	return 1;
+}
+
+/*
  * get_default_region_size
  * @cmd
  *
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 67dc7f7..31c46ad 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -825,6 +825,8 @@ const char *find_vgname_from_pvid(struct cmd_context *cmd,
 
 int lv_is_on_pv(struct logical_volume *lv, struct physical_volume *pv);
 int lv_is_on_pvs(struct logical_volume *lv, struct dm_list *pvs);
+int get_pv_list_for_lv(struct dm_pool *mem,
+		       struct logical_volume *lv, struct dm_list *pvs);
 
 
 /* Find LV segment containing given LE */
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 05f509a..17514c2 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -93,45 +93,6 @@ static int _activate_sublv_preserving_excl(struct logical_volume *top_lv,
 	return 1;
 }
 
-static int _get_pv_list_for_lv(struct logical_volume *lv, struct dm_list *pvs)
-{
-	uint32_t s;
-	struct pv_list *pvl;
-	struct lv_segment *seg = first_seg(lv);
-
-	if (!seg_is_linear(seg)) {
-		log_error(INTERNAL_ERROR
-			  "_get_pv_list_for_lv only handles linear volumes");
-		return 0;
-	}
-
-	log_debug_metadata("Getting list of PVs that %s/%s is on:",
-			   lv->vg->name, lv->name);
-
-	dm_list_iterate_items(seg, &lv->segments) {
-		for (s = 0; s < seg->area_count; s++) {
-			if (seg_type(seg, s) != AREA_PV) {
-				log_error(INTERNAL_ERROR
-					  "Linear seg_type should be AREA_PV");
-				return 0;
-			}
-
-			if (!(pvl = dm_pool_zalloc(lv->vg->cmd->mem,
-						   sizeof(*pvl)))) {
-				log_error("Failed to allocate memory");
-				return 0;
-			}
-
-			pvl->pv = seg_pv(seg, s);
-			log_debug_metadata("  %s/%s is on %s", lv->vg->name, lv->name,
-					   pv_dev_name(pvl->pv));
-			dm_list_add(pvs, &pvl->list);
-		}
-	}
-
-	return 1;
-}
-
 /*
  * _raid_in_sync
  * @lv
@@ -513,6 +474,7 @@ static int _alloc_rmeta_for_lv(struct logical_volume *data_lv,
 {
 	struct dm_list allocatable_pvs;
 	struct alloc_handle *ah;
+	struct pv_list *pvl, *tmp_pvl;
 	struct lv_segment *seg = first_seg(data_lv);
 	char *p, base_name[strlen(data_lv->name) + 1];
 
@@ -528,7 +490,8 @@ static int _alloc_rmeta_for_lv(struct logical_volume *data_lv,
 	if ((p = strstr(base_name, "_mimage_")))
 		*p = '\0';
 
-	if (!_get_pv_list_for_lv(data_lv, &allocatable_pvs)) {
+	if (!get_pv_list_for_lv(data_lv->vg->cmd->mem,
+				data_lv, &allocatable_pvs)) {
 		log_error("Failed to build list of PVs for %s/%s",
 			  data_lv->vg->name, data_lv->name);
 		return 0;
@@ -545,6 +508,11 @@ static int _alloc_rmeta_for_lv(struct logical_volume *data_lv,
 		return_0;
 
 	alloc_destroy(ah);
+
+	dm_list_iterate_items_safe(pvl, tmp_pvl, &allocatable_pvs) {
+		dm_list_del(&pvl->list);
+		dm_pool_free(data_lv->vg->cmd->mem, pvl);
+	}
 	return 1;
 }
 
@@ -1104,9 +1072,11 @@ int lv_raid_split(struct logical_volume *lv, const char *split_name,
 	uint32_t old_count = lv_raid_image_count(lv);
 	struct logical_volume *tracking;
 	struct dm_list tracking_pvs;
+	struct pv_list *pvl, *tmp_pvl;
 
 	dm_list_init(&removal_list);
 	dm_list_init(&data_list);
+	dm_list_init(&tracking_pvs);
 
 	if ((old_count - new_count) != 1) {
 		log_error("Unable to split more than one image from %s/%s",
@@ -1145,9 +1115,9 @@ int lv_raid_split(struct logical_volume *lv, const char *split_name,
 			return 0;
 		} else {
 			/* Ensure we only split the tracking image */
-			dm_list_init(&tracking_pvs);
 			splittable_pvs = &tracking_pvs;
-			if (!_get_pv_list_for_lv(tracking, splittable_pvs))
+			if (!get_pv_list_for_lv(tracking->vg->cmd->mem,
+						tracking, splittable_pvs))
 				return_0;
 		}
 	}
@@ -1159,6 +1129,11 @@ int lv_raid_split(struct logical_volume *lv, const char *split_name,
 		return 0;
 	}
 
+	dm_list_iterate_items_safe(pvl, tmp_pvl, &tracking_pvs) {
+		dm_list_del(&pvl->list);
+		dm_pool_free(lv->vg->cmd->mem, pvl);
+	}
+
 	/* Convert to linear? */
 	if ((new_count == 1) && !_raid_remove_top_layer(lv, &removal_list)) {
 		log_error("Failed to remove RAID layer after linear conversion");
-- 
1.7.7.6


