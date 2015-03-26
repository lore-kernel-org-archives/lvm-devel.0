From: Alasdair Kergon <agk@fedoraproject.org>
Date: Thu, 26 Mar 2015 18:45:32 +0000 (UTC)
Subject: master - metadata: Move alloc_handle init/destroy fns.
Message-ID: <20150326184532.75A4460323@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4b1219ee876b5a27e9fa08a1153632dda0f8efd1
Commit:        4b1219ee876b5a27e9fa08a1153632dda0f8efd1
Parent:        9506760c7ec86448e54803a74ade58d24d975ff1
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Mar 26 18:44:24 2015 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Mar 26 18:44:24 2015 +0000

metadata: Move alloc_handle init/destroy fns.

---
 lib/metadata/lv_manip.c |  362 +++++++++++++++++++++++-----------------------
 1 files changed, 181 insertions(+), 181 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 99fb91f..2b6855a 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1553,187 +1553,6 @@ static uint32_t mirror_log_extents(uint32_t region_size, uint32_t pe_size, uint3
 		(region_size / pe_size);
 }
 
-/*
- * Preparation for a specific allocation attempt
- * stripes and mirrors refer to the parallel areas used for data.
- * If log_area_count > 1 it is always mirrored (not striped).
- */
-static struct alloc_handle *_alloc_init(struct cmd_context *cmd,
-					struct dm_pool *mem,
-					const struct segment_type *segtype,
-					alloc_policy_t alloc, int approx_alloc,
-					uint32_t existing_extents,
-					uint32_t new_extents,
-					uint32_t mirrors,
-					uint32_t stripes,
-					uint32_t metadata_area_count,
-					uint32_t extent_size,
-					uint32_t region_size,
-					struct dm_list *parallel_areas)
-{
-	struct alloc_handle *ah;
-	uint32_t s, area_count, alloc_count, parity_count, total_extents;
-	size_t size = 0;
-
-	/* FIXME Caller should ensure this */
-	if (mirrors && !stripes)
-		stripes = 1;
-
-	if (segtype_is_virtual(segtype))
-		area_count = 0;
-	else if (mirrors > 1)
-		area_count = mirrors * stripes;
-	else
-		area_count = stripes;
-
-	size = sizeof(*ah);
-
-	/*
-	 * It is a requirement that RAID 4/5/6 are created with a number of
-	 * stripes that is greater than the number of parity devices.  (e.g
-	 * RAID4/5 must have at least 2 stripes and RAID6 must have at least
-	 * 3.)  It is also a constraint that, when replacing individual devices
-	 * in a RAID 4/5/6 array, no more devices can be replaced than
-	 * there are parity devices.  (Otherwise, there would not be enough
-	 * redundancy to maintain the array.)  Understanding these two
-	 * constraints allows us to infer whether the caller of this function
-	 * is intending to allocate an entire array or just replacement
-	 * component devices.  In the former case, we must account for the
-	 * necessary parity_count.  In the later case, we do not need to
-	 * account for the extra parity devices because the array already
-	 * exists and they only want replacement drives.
-	 */
-	parity_count = (area_count <= segtype->parity_devs) ? 0 : segtype->parity_devs;
-	alloc_count = area_count + parity_count;
-	if (segtype_is_raid(segtype) && metadata_area_count)
-		/* RAID has a meta area for each device */
-		alloc_count *= 2;
-	else
-		/* mirrors specify their exact log count */
-		alloc_count += metadata_area_count;
-
-	size += sizeof(ah->alloced_areas[0]) * alloc_count;
-
-	if (!(ah = dm_pool_zalloc(mem, size))) {
-		log_error("allocation handle allocation failed");
-		return NULL;
-	}
-
-	ah->cmd = cmd;
-
-	if (segtype_is_virtual(segtype))
-		return ah;
-
-	if (!(area_count + metadata_area_count)) {
-		log_error(INTERNAL_ERROR "_alloc_init called for non-virtual segment with no disk space.");
-		return NULL;
-	}
-
-	if (!(ah->mem = dm_pool_create("allocation", 1024))) {
-		log_error("allocation pool creation failed");
-		return NULL;
-	}
-
-	ah->area_count = area_count;
-	ah->parity_count = parity_count;
-	ah->region_size = region_size;
-	ah->alloc = alloc;
-
-	/*
-	 * For the purposes of allocation, area_count and parity_count are
-	 * kept separately.  However, the 'area_count' field in an
-	 * lv_segment includes both; and this is what '_calc_area_multiple'
-	 * is calculated from.  So, we must pass in the total count to get
-	 * a correct area_multiple.
-	 */
-	ah->area_multiple = _calc_area_multiple(segtype, area_count + parity_count, stripes);
-	//FIXME: s/mirror_logs_separate/metadata_separate/ so it can be used by others?
-	ah->mirror_logs_separate = find_config_tree_bool(cmd, allocation_mirror_logs_require_separate_pvs_CFG, NULL);
-
-	if (mirrors || stripes)
-		total_extents = new_extents;
-	else
-		total_extents = 0;
-
-	if (segtype_is_raid(segtype)) {
-		if (metadata_area_count) {
-			if (metadata_area_count != area_count)
-				log_error(INTERNAL_ERROR
-					  "Bad metadata_area_count");
-			ah->metadata_area_count = area_count;
-			ah->alloc_and_split_meta = 1;
-
-			ah->log_len = RAID_METADATA_AREA_LEN;
-
-			/*
-			 * We need 'log_len' extents for each
-			 * RAID device's metadata_area
-			 */
-			total_extents += (ah->log_len * ah->area_multiple);
-		} else {
-			ah->log_area_count = 0;
-			ah->log_len = 0;
-		}
-	} else if (segtype_is_thin_pool(segtype)) {
-		/*
-		 * thin_pool uses ah->region_size to
-		 * pass metadata size in extents
-		 */
-		ah->log_len = ah->region_size;
-		ah->log_area_count = metadata_area_count;
-		ah->region_size = 0;
-		ah->mirror_logs_separate =
-			find_config_tree_bool(cmd, allocation_thin_pool_metadata_require_separate_pvs_CFG, NULL);
-	} else if (segtype_is_cache_pool(segtype)) {
-		/*
-		 * Like thin_pool, cache_pool uses ah->region_size to
-		 * pass metadata size in extents
-		 */
-		ah->log_len = ah->region_size;
-		/* use metadata_area_count, not log_area_count */
-		ah->metadata_area_count = metadata_area_count;
-		ah->region_size = 0;
-		ah->mirror_logs_separate =
-			find_config_tree_bool(cmd, allocation_cache_pool_metadata_require_separate_pvs_CFG, NULL);
-		if (!ah->mirror_logs_separate) {
-			ah->alloc_and_split_meta = 1;
-			total_extents += ah->log_len;
-		}
-	} else {
-		ah->log_area_count = metadata_area_count;
-		ah->log_len = !metadata_area_count ? 0 :
-			mirror_log_extents(ah->region_size, extent_size,
-					   (existing_extents + total_extents) / ah->area_multiple);
-	}
-
-	log_debug("Adjusted allocation request to %" PRIu32 " logical extents. Existing size %" PRIu32 ". New size %" PRIu32 ".",
-		  total_extents, existing_extents, total_extents + existing_extents);
-
-	if (mirrors || stripes)
-		total_extents += existing_extents;
-
-	ah->new_extents = total_extents;
-
-	for (s = 0; s < alloc_count; s++)
-		dm_list_init(&ah->alloced_areas[s]);
-
-	ah->parallel_areas = parallel_areas;
-
-	ah->cling_tag_list_cn = find_config_tree_node(cmd, allocation_cling_tag_list_CFG, NULL);
-
-	ah->maximise_cling = find_config_tree_bool(cmd, allocation_maximise_cling_CFG, NULL);
-
-	ah->approx_alloc = approx_alloc;
-
-	return ah;
-}
-
-void alloc_destroy(struct alloc_handle *ah)
-{
-	if (ah->mem)
-		dm_pool_destroy(ah->mem);
-}
-
 /* Is there enough total space or should we give up immediately? */
 static int _sufficient_pes_free(struct alloc_handle *ah, struct dm_list *pvms,
 				uint32_t allocated, uint32_t extents_still_needed)
@@ -3059,6 +2878,187 @@ int lv_add_virtual_segment(struct logical_volume *lv, uint64_t status,
 }
 
 /*
+ * Preparation for a specific allocation attempt
+ * stripes and mirrors refer to the parallel areas used for data.
+ * If log_area_count > 1 it is always mirrored (not striped).
+ */
+static struct alloc_handle *_alloc_init(struct cmd_context *cmd,
+					struct dm_pool *mem,
+					const struct segment_type *segtype,
+					alloc_policy_t alloc, int approx_alloc,
+					uint32_t existing_extents,
+					uint32_t new_extents,
+					uint32_t mirrors,
+					uint32_t stripes,
+					uint32_t metadata_area_count,
+					uint32_t extent_size,
+					uint32_t region_size,
+					struct dm_list *parallel_areas)
+{
+	struct alloc_handle *ah;
+	uint32_t s, area_count, alloc_count, parity_count, total_extents;
+	size_t size = 0;
+
+	/* FIXME Caller should ensure this */
+	if (mirrors && !stripes)
+		stripes = 1;
+
+	if (segtype_is_virtual(segtype))
+		area_count = 0;
+	else if (mirrors > 1)
+		area_count = mirrors * stripes;
+	else
+		area_count = stripes;
+
+	size = sizeof(*ah);
+
+	/*
+	 * It is a requirement that RAID 4/5/6 are created with a number of
+	 * stripes that is greater than the number of parity devices.  (e.g
+	 * RAID4/5 must have at least 2 stripes and RAID6 must have at least
+	 * 3.)  It is also a constraint that, when replacing individual devices
+	 * in a RAID 4/5/6 array, no more devices can be replaced than
+	 * there are parity devices.  (Otherwise, there would not be enough
+	 * redundancy to maintain the array.)  Understanding these two
+	 * constraints allows us to infer whether the caller of this function
+	 * is intending to allocate an entire array or just replacement
+	 * component devices.  In the former case, we must account for the
+	 * necessary parity_count.  In the later case, we do not need to
+	 * account for the extra parity devices because the array already
+	 * exists and they only want replacement drives.
+	 */
+	parity_count = (area_count <= segtype->parity_devs) ? 0 : segtype->parity_devs;
+	alloc_count = area_count + parity_count;
+	if (segtype_is_raid(segtype) && metadata_area_count)
+		/* RAID has a meta area for each device */
+		alloc_count *= 2;
+	else
+		/* mirrors specify their exact log count */
+		alloc_count += metadata_area_count;
+
+	size += sizeof(ah->alloced_areas[0]) * alloc_count;
+
+	if (!(ah = dm_pool_zalloc(mem, size))) {
+		log_error("allocation handle allocation failed");
+		return NULL;
+	}
+
+	ah->cmd = cmd;
+
+	if (segtype_is_virtual(segtype))
+		return ah;
+
+	if (!(area_count + metadata_area_count)) {
+		log_error(INTERNAL_ERROR "_alloc_init called for non-virtual segment with no disk space.");
+		return NULL;
+	}
+
+	if (!(ah->mem = dm_pool_create("allocation", 1024))) {
+		log_error("allocation pool creation failed");
+		return NULL;
+	}
+
+	ah->area_count = area_count;
+	ah->parity_count = parity_count;
+	ah->region_size = region_size;
+	ah->alloc = alloc;
+
+	/*
+	 * For the purposes of allocation, area_count and parity_count are
+	 * kept separately.  However, the 'area_count' field in an
+	 * lv_segment includes both; and this is what '_calc_area_multiple'
+	 * is calculated from.  So, we must pass in the total count to get
+	 * a correct area_multiple.
+	 */
+	ah->area_multiple = _calc_area_multiple(segtype, area_count + parity_count, stripes);
+	//FIXME: s/mirror_logs_separate/metadata_separate/ so it can be used by others?
+	ah->mirror_logs_separate = find_config_tree_bool(cmd, allocation_mirror_logs_require_separate_pvs_CFG, NULL);
+
+	if (mirrors || stripes)
+		total_extents = new_extents;
+	else
+		total_extents = 0;
+
+	if (segtype_is_raid(segtype)) {
+		if (metadata_area_count) {
+			if (metadata_area_count != area_count)
+				log_error(INTERNAL_ERROR
+					  "Bad metadata_area_count");
+			ah->metadata_area_count = area_count;
+			ah->alloc_and_split_meta = 1;
+
+			ah->log_len = RAID_METADATA_AREA_LEN;
+
+			/*
+			 * We need 'log_len' extents for each
+			 * RAID device's metadata_area
+			 */
+			total_extents += (ah->log_len * ah->area_multiple);
+		} else {
+			ah->log_area_count = 0;
+			ah->log_len = 0;
+		}
+	} else if (segtype_is_thin_pool(segtype)) {
+		/*
+		 * thin_pool uses ah->region_size to
+		 * pass metadata size in extents
+		 */
+		ah->log_len = ah->region_size;
+		ah->log_area_count = metadata_area_count;
+		ah->region_size = 0;
+		ah->mirror_logs_separate =
+			find_config_tree_bool(cmd, allocation_thin_pool_metadata_require_separate_pvs_CFG, NULL);
+	} else if (segtype_is_cache_pool(segtype)) {
+		/*
+		 * Like thin_pool, cache_pool uses ah->region_size to
+		 * pass metadata size in extents
+		 */
+		ah->log_len = ah->region_size;
+		/* use metadata_area_count, not log_area_count */
+		ah->metadata_area_count = metadata_area_count;
+		ah->region_size = 0;
+		ah->mirror_logs_separate =
+			find_config_tree_bool(cmd, allocation_cache_pool_metadata_require_separate_pvs_CFG, NULL);
+		if (!ah->mirror_logs_separate) {
+			ah->alloc_and_split_meta = 1;
+			total_extents += ah->log_len;
+		}
+	} else {
+		ah->log_area_count = metadata_area_count;
+		ah->log_len = !metadata_area_count ? 0 :
+			mirror_log_extents(ah->region_size, extent_size,
+					   (existing_extents + total_extents) / ah->area_multiple);
+	}
+
+	log_debug("Adjusted allocation request to %" PRIu32 " logical extents. Existing size %" PRIu32 ". New size %" PRIu32 ".",
+		  total_extents, existing_extents, total_extents + existing_extents);
+
+	if (mirrors || stripes)
+		total_extents += existing_extents;
+
+	ah->new_extents = total_extents;
+
+	for (s = 0; s < alloc_count; s++)
+		dm_list_init(&ah->alloced_areas[s]);
+
+	ah->parallel_areas = parallel_areas;
+
+	ah->cling_tag_list_cn = find_config_tree_node(cmd, allocation_cling_tag_list_CFG, NULL);
+
+	ah->maximise_cling = find_config_tree_bool(cmd, allocation_maximise_cling_CFG, NULL);
+
+	ah->approx_alloc = approx_alloc;
+
+	return ah;
+}
+
+void alloc_destroy(struct alloc_handle *ah)
+{
+	if (ah->mem)
+		dm_pool_destroy(ah->mem);
+}
+
+/*
  * Entry point for all extent allocations.
  */
 struct alloc_handle *allocate_extents(struct volume_group *vg,


