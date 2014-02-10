From: Jonathan Brassow <jbrassow@redhat.com>
Date: Mon, 10 Feb 2014 17:29:57 -0600
Subject: [PATCH] allocation: Allow "fuzzy" allocation when specifying size in percent
Message-ID: <1392074997.17667.6.camel@f16>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch is still a bit rough around the edges and needs accompanying
tests before in can be checked-in.  If there are no objections to it,
I'll clean it up a bit more and add the tests.

 brassow


Introduce a new parameter called "fuzzy_alloc" that is set when the
desired size of a new LV is specified in percentage terms.  If set,
the allocation code tries to get as much space as it can but does not
fail if can at least get some.

One of the practical implications is that users can now specify 100%FREE
when creating RAID LVs, like this:
~> lvcreate --type raid5 -l 100%FREE -n lv vg

(The stripe count is computed implicitly due to a previous patch, and
the full size of the PVs in the VG is used.)

** This patch is not yet well tested and needs review **

Index: lvm2/lib/metadata/lv_alloc.h
===================================================================
--- lvm2.orig/lib/metadata/lv_alloc.h
+++ lvm2/lib/metadata/lv_alloc.h
@@ -54,7 +54,7 @@ struct alloc_handle *allocate_extents(st
                                       uint32_t mirrors, uint32_t log_count,
 				      uint32_t log_region_size, uint32_t extents,
                                       struct dm_list *allocatable_pvs,
-				      alloc_policy_t alloc,
+				      alloc_policy_t alloc, int fuzzy_alloc,
 				      struct dm_list *parallel_areas);
 
 int lv_add_segment(struct alloc_handle *ah,
Index: lvm2/lib/metadata/lv_manip.c
===================================================================
--- lvm2.orig/lib/metadata/lv_manip.c
+++ lvm2/lib/metadata/lv_manip.c
@@ -918,6 +918,7 @@ struct alloc_handle {
 	struct dm_pool *mem;
 
 	alloc_policy_t alloc;		/* Overall policy */
+	int fuzzy_alloc;                /* get as much as possible up to new_extents */
 	uint32_t new_extents;		/* Number of new extents required */
 	uint32_t area_count;		/* Number of parallel areas */
 	uint32_t parity_count;   /* Adds to area_count, but not area_multiple */
@@ -1041,7 +1042,7 @@ static uint32_t mirror_log_extents(uint3
 static struct alloc_handle *_alloc_init(struct cmd_context *cmd,
 					struct dm_pool *mem,
 					const struct segment_type *segtype,
-					alloc_policy_t alloc,
+					alloc_policy_t alloc, int fuzzy_alloc,
 					uint32_t new_extents,
 					uint32_t mirrors,
 					uint32_t stripes,
@@ -1194,6 +1195,7 @@ static struct alloc_handle *_alloc_init(
 
 	ah->maximise_cling = find_config_tree_bool(cmd, allocation_maximise_cling_CFG, NULL);
 
+	ah->fuzzy_alloc = fuzzy_alloc;
 	return ah;
 }
 
@@ -1214,10 +1216,18 @@ static int _sufficient_pes_free(struct a
 	uint32_t free_pes = pv_maps_size(pvms);
 
 	if (total_extents_needed > free_pes) {
-		log_error("Insufficient free space: %" PRIu32 " extents needed,"
-			  " but only %" PRIu32 " available",
-			  total_extents_needed, free_pes);
-		return 0;
+		if (!ah->fuzzy_alloc) {
+			log_error("Insufficient free space: %" PRIu32
+				  " extents needed,"
+				  " but only %" PRIu32 " available",
+				  total_extents_needed, free_pes);
+
+			return 0;
+		}
+		log_verbose("Insufficient free space: %" PRIu32
+			    " extents needed, but only %" PRIu32
+			    " available: amount will be reduced",
+			    total_extents_needed, free_pes);
 	}
 
 	return 1;
@@ -2006,7 +2016,8 @@ static void _report_needed_allocation_sp
 		metadata_count = alloc_state->log_area_count_still_needed;
 	}
 
-	log_debug_alloc("Still need %" PRIu32 " total extents:",
+	log_debug_alloc("Still need %s%" PRIu32 " total extents:",
+			ah->fuzzy_alloc ? "about " : "",
 			parallel_area_size * parallel_areas_count + metadata_size * metadata_count);
 	log_debug_alloc("  %" PRIu32 " (%" PRIu32 " data/%" PRIu32
 			" parity) parallel areas of %" PRIu32 " extents each",
@@ -2414,19 +2425,29 @@ static int _allocate(struct alloc_handle
 		if (!_find_max_parallel_space_for_one_policy(ah, &alloc_parms, pvms, &alloc_state))
 			goto_out;
 
-		if ((alloc_state.allocated == ah->new_extents && !alloc_state.log_area_count_still_needed) ||
+		if ((alloc_state.allocated == ah->new_extents &&
+		     !alloc_state.log_area_count_still_needed) ||
 		    (!can_split && (alloc_state.allocated != old_allocated)))
 			break;
 	}
 
 	if (alloc_state.allocated != ah->new_extents) {
-		log_error("Insufficient suitable %sallocatable extents "
-			  "for logical volume %s: %u more required",
-			  can_split ? "" : "contiguous ",
-			  lv ? lv->name : "",
-			  (ah->new_extents - alloc_state.allocated) * ah->area_count
-			  / ah->area_multiple);
-		goto out;
+		if (!ah->fuzzy_alloc) {
+			log_error("Insufficient suitable %sallocatable extents "
+				  "for logical volume %s: %u more required",
+				  can_split ? "" : "contiguous ",
+				  lv ? lv->name : "",
+				  (ah->new_extents - alloc_state.allocated) *
+				  ah->area_count / ah->area_multiple);
+			goto out;
+		}
+		log_verbose("Insufficient suitable %sallocatable extents "
+			    "for logical volume %s: size reduced by %u extents",
+			    can_split ? "" : "contiguous ",
+			    lv ? lv->name : "",
+			    (ah->new_extents - alloc_state.allocated) *
+			    ah->area_count / ah->area_multiple);
+		ah->new_extents = alloc_state.allocated;
 	}
 
 	if (alloc_state.log_area_count_still_needed) {
@@ -2503,7 +2524,7 @@ struct alloc_handle *allocate_extents(st
 				      uint32_t mirrors, uint32_t log_count,
 				      uint32_t region_size, uint32_t extents,
 				      struct dm_list *allocatable_pvs,
-				      alloc_policy_t alloc,
+				      alloc_policy_t alloc, int fuzzy_alloc,
 				      struct dm_list *parallel_areas)
 {
 	struct alloc_handle *ah;
@@ -2533,7 +2554,7 @@ struct alloc_handle *allocate_extents(st
 		alloc = vg->alloc;
 
 	new_extents = (lv ? lv->le_count : 0) + extents;
-	if (!(ah = _alloc_init(vg->cmd, vg->cmd->mem, segtype, alloc,
+	if (!(ah = _alloc_init(vg->cmd, vg->cmd->mem, segtype, alloc, fuzzy_alloc,
 			       new_extents, mirrors, stripes, log_count,
 			       vg->extent_size, region_size,
 			       parallel_areas)))
@@ -2999,7 +3020,8 @@ int lv_extend(struct logical_volume *lv,
 	      uint32_t stripes, uint32_t stripe_size,
 	      uint32_t mirrors, uint32_t region_size,
 	      uint32_t extents, const char *thin_pool_name,
-	      struct dm_list *allocatable_pvs, alloc_policy_t alloc)
+	      struct dm_list *allocatable_pvs, alloc_policy_t alloc,
+	      int fuzzy_alloc)
 {
 	int r = 1;
 	int log_count = 0;
@@ -3027,9 +3049,15 @@ int lv_extend(struct logical_volume *lv,
 
 	if (!(ah = allocate_extents(lv->vg, lv, segtype, stripes, mirrors,
 				    log_count, region_size, extents,
-				    allocatable_pvs, alloc, NULL)))
+				    allocatable_pvs, alloc, fuzzy_alloc, NULL)))
 		return_0;
 
+	if (ah->fuzzy_alloc) {
+		extents = ah->new_extents;
+		if (segtype_is_raid(segtype))
+			extents -= ah->log_len * ah->area_count;
+	}
+
 	if (segtype_is_thin_pool(segtype) || segtype_is_cache_pool(segtype)) {
 		if (lv->le_count) {
 			/* lv_resize abstracts properly _tdata */
@@ -3646,7 +3674,7 @@ static int _lvresize_poolmetadata(struct
 		       seg_mirrors,
 		       mseg->region_size,
 		       lp->poolmetadataextents - lv->le_count, NULL,
-		       pvh, alloc))
+		       pvh, alloc, 0))
 		return_0;
 
 	return 1;
@@ -4159,7 +4187,7 @@ static struct logical_volume *_lvresize_
 			      lp->stripes, lp->stripe_size,
 			      lp->mirrors, first_seg(lv)->region_size,
 			      lp->extents - lv->le_count, NULL,
-			      pvh, alloc))
+			      pvh, alloc, 0))
 		return_NULL;
 
 	if (lock_lv) {
@@ -5595,7 +5623,7 @@ static struct logical_volume *_create_vi
 		return_NULL;
 
 	if (!lv_extend(lv, segtype, 1, 0, 1, 0, voriginextents,
-		       NULL, NULL, ALLOC_INHERIT))
+		       NULL, NULL, ALLOC_INHERIT, 0))
 		return_NULL;
 
 	/* store vg on disk(s) */
@@ -6109,7 +6137,7 @@ static struct logical_volume *_lv_create
 		       (seg_is_thin_pool(lp) || seg_is_cache_pool(lp)) ?
 		       lp->poolmetadataextents : lp->region_size,
 		       seg_is_thin_volume(lp) ? lp->voriginextents : lp->extents,
-		       thin_name, lp->pvh, lp->alloc))
+		       thin_name, lp->pvh, lp->alloc, lp->fuzzy_alloc))
 		return_NULL;
 
 	if (seg_is_cache_pool(lp)) {
Index: lvm2/lib/metadata/metadata-exported.h
===================================================================
--- lvm2.orig/lib/metadata/metadata-exported.h
+++ lvm2/lib/metadata/metadata-exported.h
@@ -672,7 +672,8 @@ int lv_extend(struct logical_volume *lv,
 	      uint32_t stripes, uint32_t stripe_size,
 	      uint32_t mirrors, uint32_t region_size,
 	      uint32_t extents, const char *thin_pool_name,
-	      struct dm_list *allocatable_pvs, alloc_policy_t alloc);
+	      struct dm_list *allocatable_pvs, alloc_policy_t alloc,
+	      int fuzzy_alloc);
 
 /* lv must be part of lv->vg->lvs */
 int lv_remove(struct logical_volume *lv);
@@ -810,6 +811,7 @@ struct lvcreate_params {
 
 	uint32_t permission; /* all */
 	uint32_t read_ahead; /* all */
+	int fuzzy_alloc;     /* all */
 	alloc_policy_t alloc; /* all */
 
 	struct dm_list tags;	/* all */
Index: lvm2/lib/metadata/mirror.c
===================================================================
--- lvm2.orig/lib/metadata/mirror.c
+++ lvm2/lib/metadata/mirror.c
@@ -1676,7 +1676,7 @@ int add_mirrors_to_segments(struct cmd_c
 							   region_size);
 
 	if (!(ah = allocate_extents(lv->vg, NULL, segtype, 1, mirrors, 0, 0,
-				    lv->le_count, allocatable_pvs, alloc,
+				    lv->le_count, allocatable_pvs, alloc, 0,
 				    parallel_areas))) {
 		log_error("Unable to allocate mirror extents for %s.", lv->name);
 		return 0;
@@ -1944,7 +1944,7 @@ int add_mirror_log(struct cmd_context *c
 	ah = allocate_extents(lv->vg, NULL, segtype,
 			      0, 0, log_count - old_log_count, region_size,
 			      lv->le_count, allocatable_pvs,
-			      alloc, parallel_areas);
+			      alloc, 0, parallel_areas);
 	if (!ah) {
 		log_error("Unable to allocate extents for mirror log.");
 		return 0;
@@ -2008,7 +2008,7 @@ int add_mirror_images(struct cmd_context
 
 	ah = allocate_extents(lv->vg, NULL, segtype,
 			      stripes, mirrors, log_count, region_size, lv->le_count,
-			      allocatable_pvs, alloc, parallel_areas);
+			      allocatable_pvs, alloc, 0, parallel_areas);
 	if (!ah) {
 		log_error("Unable to allocate extents for mirror(s).");
 		return 0;
Index: lvm2/lib/metadata/raid_manip.c
===================================================================
--- lvm2.orig/lib/metadata/raid_manip.c
+++ lvm2/lib/metadata/raid_manip.c
@@ -419,7 +419,7 @@ static int _alloc_image_components(struc
 
 	if (!(ah = allocate_extents(lv->vg, NULL, segtype, 0, count, count,
 				    region_size, extents, pvs,
-				    lv->alloc, parallel_areas)))
+				    lv->alloc, 0, parallel_areas)))
 		return_0;
 
 	for (s = 0; s < count; s++) {
@@ -483,7 +483,7 @@ static int _alloc_rmeta_for_lv(struct lo
 	if (!(ah = allocate_extents(data_lv->vg, NULL, seg->segtype, 0, 1, 0,
 				    seg->region_size,
 				    1 /*RAID_METADATA_AREA_LEN*/,
-				    &allocatable_pvs, data_lv->alloc, NULL)))
+				    &allocatable_pvs, data_lv->alloc, 0, NULL)))
 		return_0;
 
 	if (!_alloc_image_component(data_lv, base_name, ah, 0,
Index: lvm2/lib/metadata/thin_manip.c
===================================================================
--- lvm2.orig/lib/metadata/thin_manip.c
+++ lvm2/lib/metadata/thin_manip.c
@@ -678,7 +678,7 @@ int handle_pool_metadata_spare(struct vo
 		       seg_mirrors,
 		       seg->region_size,
 		       extents - lv->le_count, NULL,
-		       pvh, lv->alloc))
+		       pvh, lv->alloc, 0))
 		return_0;
 
 	return 1;
Index: lvm2/tools/lvcreate.c
===================================================================
--- lvm2.orig/tools/lvcreate.c
+++ lvm2/tools/lvcreate.c
@@ -363,6 +363,8 @@ static int _update_extents_params(struct
 	} else
 		lp->pvh = &vg->pvs;
 
+	if (lcp->percent)
+		lp->fuzzy_alloc = 1;
 	switch(lcp->percent) {
 		case PERCENT_VG:
 			lp->extents = percent_of_extents(lp->extents, vg->extent_count, 0);
Index: lvm2/test/shell/lvcreate-raid.sh
===================================================================
--- lvm2.orig/test/shell/lvcreate-raid.sh
+++ lvm2/test/shell/lvcreate-raid.sh
@@ -110,3 +110,12 @@ lv_devices $vg raid6 6
 lvcreate --type raid10 -l2 -n raid10 $vg
 lv_devices $vg raid10 6
 lvremove -ff $vg
+
+# Create RAID using 100%FREE
+############################
+lvcreate --type raid1 -l 100%FREE -n raid1 $vg
+lvremove -ff $vg
+lvcreate --type raid5 -l 100%FREE -n raid5 $vg
+lvremove -ff $vg
+lvcreate --type raid6 -l 100%FREE -n raid6 $vg
+lvremove -ff $vg
Index: lvm2/test/shell/lvcreate-raid10.sh
===================================================================
--- lvm2.orig/test/shell/lvcreate-raid10.sh
+++ lvm2/test/shell/lvcreate-raid10.sh
@@ -46,6 +46,10 @@ aux wait_for_sync $vg $lv2
 
 lvremove -ff $vg
 
+# Test 100%FREE option (requires implicit stripe/mirror calculation)
+lvcreate --type raid10 -l 100%FREE -n raid10 $vg
+lvremove -ff $vg
+
 #
 # FIXME: Add tests that specify particular PVs to use for creation
 #



