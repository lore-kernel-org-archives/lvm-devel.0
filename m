From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Fri, 14 Feb 2014 03:10:45 +0000 (UTC)
Subject: master - allocation: Allow approximate allocation when specifying size in percent
Message-ID: <20140214031045.E9C9A60D82@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4b6e3b5e5ea682b4b6f7c77a447ccadc7f3c99c3
Commit:        4b6e3b5e5ea682b4b6f7c77a447ccadc7f3c99c3
Parent:        f4658b53d7f3292c802f33f5fd0cca807870049f
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Thu Feb 13 21:10:28 2014 -0600
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Thu Feb 13 21:10:28 2014 -0600

allocation: Allow approximate allocation when specifying size in percent

Introduce a new parameter called "approx_alloc" that is set when the
desired size of a new LV is specified in percentage terms.  If set,
the allocation code tries to get as much space as it can but does not
fail if can at least get some.

One of the practical implications is that users can now specify 100%FREE
when creating RAID LVs, like this:
~> lvcreate --type raid5 -i 2 -l 100%FREE -n lv vg
---
 lib/metadata/lv_alloc.h          |    2 +-
 lib/metadata/lv_manip.c          |   75 ++++++++++++++++++++++++----------
 lib/metadata/metadata-exported.h |    4 +-
 lib/metadata/mirror.c            |    6 +-
 lib/metadata/raid_manip.c        |    4 +-
 lib/metadata/thin_manip.c        |    2 +-
 test/shell/lvcreate-raid.sh      |   84 ++++++++++++++++++++++++++++++++++++++
 test/shell/lvcreate-raid10.sh    |    8 ++++
 tools/lvcreate.c                 |    2 +
 9 files changed, 157 insertions(+), 30 deletions(-)

diff --git a/lib/metadata/lv_alloc.h b/lib/metadata/lv_alloc.h
index acfebca..395420d 100644
--- a/lib/metadata/lv_alloc.h
+++ b/lib/metadata/lv_alloc.h
@@ -54,7 +54,7 @@ struct alloc_handle *allocate_extents(struct volume_group *vg,
                                       uint32_t mirrors, uint32_t log_count,
 				      uint32_t log_region_size, uint32_t extents,
                                       struct dm_list *allocatable_pvs,
-				      alloc_policy_t alloc,
+				      alloc_policy_t alloc, int approx_alloc,
 				      struct dm_list *parallel_areas);
 
 int lv_add_segment(struct alloc_handle *ah,
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 826dbb2..d38dd7c 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -918,6 +918,7 @@ struct alloc_handle {
 	struct dm_pool *mem;
 
 	alloc_policy_t alloc;		/* Overall policy */
+	int approx_alloc;                /* get as much as possible up to new_extents */
 	uint32_t new_extents;		/* Number of new extents required */
 	uint32_t area_count;		/* Number of parallel areas */
 	uint32_t parity_count;   /* Adds to area_count, but not area_multiple */
@@ -1041,7 +1042,7 @@ static uint32_t mirror_log_extents(uint32_t region_size, uint32_t pe_size, uint3
 static struct alloc_handle *_alloc_init(struct cmd_context *cmd,
 					struct dm_pool *mem,
 					const struct segment_type *segtype,
-					alloc_policy_t alloc,
+					alloc_policy_t alloc, int approx_alloc,
 					uint32_t new_extents,
 					uint32_t mirrors,
 					uint32_t stripes,
@@ -1194,6 +1195,7 @@ static struct alloc_handle *_alloc_init(struct cmd_context *cmd,
 
 	ah->maximise_cling = find_config_tree_bool(cmd, allocation_maximise_cling_CFG, NULL);
 
+	ah->approx_alloc = approx_alloc;
 	return ah;
 }
 
@@ -1214,10 +1216,18 @@ static int _sufficient_pes_free(struct alloc_handle *ah, struct dm_list *pvms,
 	uint32_t free_pes = pv_maps_size(pvms);
 
 	if (total_extents_needed > free_pes) {
-		log_error("Insufficient free space: %" PRIu32 " extents needed,"
-			  " but only %" PRIu32 " available",
-			  total_extents_needed, free_pes);
-		return 0;
+		if (!ah->approx_alloc) {
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
@@ -2006,7 +2016,8 @@ static void _report_needed_allocation_space(struct alloc_handle *ah,
 		metadata_count = alloc_state->log_area_count_still_needed;
 	}
 
-	log_debug_alloc("Still need %" PRIu32 " total extents:",
+	log_debug_alloc("Still need %s%" PRIu32 " total extents:",
+			ah->approx_alloc ? "up to " : "",
 			parallel_area_size * parallel_areas_count + metadata_size * metadata_count);
 	log_debug_alloc("  %" PRIu32 " (%" PRIu32 " data/%" PRIu32
 			" parity) parallel areas of %" PRIu32 " extents each",
@@ -2414,19 +2425,29 @@ static int _allocate(struct alloc_handle *ah,
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
+		if (!ah->approx_alloc) {
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
@@ -2503,7 +2524,7 @@ struct alloc_handle *allocate_extents(struct volume_group *vg,
 				      uint32_t mirrors, uint32_t log_count,
 				      uint32_t region_size, uint32_t extents,
 				      struct dm_list *allocatable_pvs,
-				      alloc_policy_t alloc,
+				      alloc_policy_t alloc, int approx_alloc,
 				      struct dm_list *parallel_areas)
 {
 	struct alloc_handle *ah;
@@ -2533,7 +2554,7 @@ struct alloc_handle *allocate_extents(struct volume_group *vg,
 		alloc = vg->alloc;
 
 	new_extents = (lv ? lv->le_count : 0) + extents;
-	if (!(ah = _alloc_init(vg->cmd, vg->cmd->mem, segtype, alloc,
+	if (!(ah = _alloc_init(vg->cmd, vg->cmd->mem, segtype, alloc, approx_alloc,
 			       new_extents, mirrors, stripes, log_count,
 			       vg->extent_size, region_size,
 			       parallel_areas)))
@@ -2999,7 +3020,8 @@ int lv_extend(struct logical_volume *lv,
 	      uint32_t stripes, uint32_t stripe_size,
 	      uint32_t mirrors, uint32_t region_size,
 	      uint32_t extents, const char *thin_pool_name,
-	      struct dm_list *allocatable_pvs, alloc_policy_t alloc)
+	      struct dm_list *allocatable_pvs, alloc_policy_t alloc,
+	      int approx_alloc)
 {
 	int r = 1;
 	int log_count = 0;
@@ -3027,9 +3049,18 @@ int lv_extend(struct logical_volume *lv,
 
 	if (!(ah = allocate_extents(lv->vg, lv, segtype, stripes, mirrors,
 				    log_count, region_size, extents,
-				    allocatable_pvs, alloc, NULL)))
+				    allocatable_pvs, alloc, approx_alloc, NULL)))
 		return_0;
 
+	if (ah->approx_alloc) {
+		extents = ah->new_extents;
+		if (segtype_is_raid(segtype)) {
+			log_error("Extents before: %u", extents);
+			extents -= ah->log_len * ah->area_multiple;
+			log_error("Extents after : %u", extents);
+		}
+	}
+
 	if (segtype_is_thin_pool(segtype) || segtype_is_cache_pool(segtype)) {
 		if (lv->le_count) {
 			/* lv_resize abstracts properly _tdata */
@@ -3646,7 +3677,7 @@ static int _lvresize_poolmetadata(struct cmd_context *cmd, struct volume_group *
 		       seg_mirrors,
 		       mseg->region_size,
 		       lp->poolmetadataextents - lv->le_count, NULL,
-		       pvh, alloc))
+		       pvh, alloc, 0))
 		return_0;
 
 	return 1;
@@ -4159,7 +4190,7 @@ static struct logical_volume *_lvresize_volume(struct cmd_context *cmd,
 			      lp->stripes, lp->stripe_size,
 			      lp->mirrors, first_seg(lv)->region_size,
 			      lp->extents - lv->le_count, NULL,
-			      pvh, alloc))
+			      pvh, alloc, 0))
 		return_NULL;
 
 	if (lock_lv) {
@@ -5596,7 +5627,7 @@ static struct logical_volume *_create_virtual_origin(struct cmd_context *cmd,
 		return_NULL;
 
 	if (!lv_extend(lv, segtype, 1, 0, 1, 0, voriginextents,
-		       NULL, NULL, ALLOC_INHERIT))
+		       NULL, NULL, ALLOC_INHERIT, 0))
 		return_NULL;
 
 	/* store vg on disk(s) */
@@ -6110,7 +6141,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		       (seg_is_thin_pool(lp) || seg_is_cache_pool(lp)) ?
 		       lp->poolmetadataextents : lp->region_size,
 		       seg_is_thin_volume(lp) ? lp->voriginextents : lp->extents,
-		       thin_name, lp->pvh, lp->alloc))
+		       thin_name, lp->pvh, lp->alloc, lp->approx_alloc))
 		return_NULL;
 
 	if (seg_is_cache_pool(lp)) {
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index faa8217..6ca4309 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -672,7 +672,8 @@ int lv_extend(struct logical_volume *lv,
 	      uint32_t stripes, uint32_t stripe_size,
 	      uint32_t mirrors, uint32_t region_size,
 	      uint32_t extents, const char *thin_pool_name,
-	      struct dm_list *allocatable_pvs, alloc_policy_t alloc);
+	      struct dm_list *allocatable_pvs, alloc_policy_t alloc,
+	      int approx_alloc);
 
 /* lv must be part of lv->vg->lvs */
 int lv_remove(struct logical_volume *lv);
@@ -810,6 +811,7 @@ struct lvcreate_params {
 
 	uint32_t permission; /* all */
 	uint32_t read_ahead; /* all */
+	int approx_alloc;     /* all */
 	alloc_policy_t alloc; /* all */
 
 	struct dm_list tags;	/* all */
diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index 5d99c50..86ec4ca 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -1676,7 +1676,7 @@ int add_mirrors_to_segments(struct cmd_context *cmd, struct logical_volume *lv,
 							   region_size);
 
 	if (!(ah = allocate_extents(lv->vg, NULL, segtype, 1, mirrors, 0, 0,
-				    lv->le_count, allocatable_pvs, alloc,
+				    lv->le_count, allocatable_pvs, alloc, 0,
 				    parallel_areas))) {
 		log_error("Unable to allocate mirror extents for %s.", lv->name);
 		return 0;
@@ -1944,7 +1944,7 @@ int add_mirror_log(struct cmd_context *cmd, struct logical_volume *lv,
 	ah = allocate_extents(lv->vg, NULL, segtype,
 			      0, 0, log_count - old_log_count, region_size,
 			      lv->le_count, allocatable_pvs,
-			      alloc, parallel_areas);
+			      alloc, 0, parallel_areas);
 	if (!ah) {
 		log_error("Unable to allocate extents for mirror log.");
 		return 0;
@@ -2008,7 +2008,7 @@ int add_mirror_images(struct cmd_context *cmd, struct logical_volume *lv,
 
 	ah = allocate_extents(lv->vg, NULL, segtype,
 			      stripes, mirrors, log_count, region_size, lv->le_count,
-			      allocatable_pvs, alloc, parallel_areas);
+			      allocatable_pvs, alloc, 0, parallel_areas);
 	if (!ah) {
 		log_error("Unable to allocate extents for mirror(s).");
 		return 0;
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 3f2b043..d1759ae 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -419,7 +419,7 @@ static int _alloc_image_components(struct logical_volume *lv,
 
 	if (!(ah = allocate_extents(lv->vg, NULL, segtype, 0, count, count,
 				    region_size, extents, pvs,
-				    lv->alloc, parallel_areas)))
+				    lv->alloc, 0, parallel_areas)))
 		return_0;
 
 	for (s = 0; s < count; s++) {
@@ -483,7 +483,7 @@ static int _alloc_rmeta_for_lv(struct logical_volume *data_lv,
 	if (!(ah = allocate_extents(data_lv->vg, NULL, seg->segtype, 0, 1, 0,
 				    seg->region_size,
 				    1 /*RAID_METADATA_AREA_LEN*/,
-				    &allocatable_pvs, data_lv->alloc, NULL)))
+				    &allocatable_pvs, data_lv->alloc, 0, NULL)))
 		return_0;
 
 	if (!_alloc_image_component(data_lv, base_name, ah, 0,
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index c3f8e56..1ae893a 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -677,7 +677,7 @@ int handle_pool_metadata_spare(struct volume_group *vg, uint32_t extents,
 		       seg_mirrors,
 		       seg->region_size,
 		       extents - lv->le_count, NULL,
-		       pvh, lv->alloc))
+		       pvh, lv->alloc, 0))
 		return_0;
 
 	return 1;
diff --git a/test/shell/lvcreate-raid.sh b/test/shell/lvcreate-raid.sh
index 214b162..2a1ed6d 100644
--- a/test/shell/lvcreate-raid.sh
+++ b/test/shell/lvcreate-raid.sh
@@ -70,3 +70,87 @@ for i in raid4 \
 	aux wait_for_sync $vg $lv1
 	lvremove -ff $vg
 done
+
+# Create RAID using 100%FREE
+############################
+# 6 PVs with 18.5m in each PV.
+# 1 metadata LV = 1 extent   = .5m
+# 1 image = 36+37+37 extents = 55.00m = lv_size
+lvcreate --type raid1 -m 1 -l 100%FREE -n raid1 $vg
+check lv_field $vg/raid1 size "55.00m"
+lvremove -ff $vg
+
+# 1 metadata LV = 1 extent
+# 1 image = 36 extents
+# 5 images = 180 extents = 90.00m = lv_size
+lvcreate --type raid5 -i 5 -l 100%FREE -n raid5 $vg
+check lv_field $vg/raid5 size "90.00m"
+lvremove -ff $vg
+
+# 1 image = 36+37 extents
+# 2 images = 146 extents = 73.00m = lv_size
+lvcreate --type raid5 -i 2 -l 100%FREE -n raid5 $vg
+check lv_field $vg/raid5 size "73.00m"
+lvremove -ff $vg
+
+# 1 image = 36 extents
+# 4 images = 144 extents = 72.00m = lv_size
+lvcreate --type raid6 -i 4 -l 100%FREE -n raid6 $vg
+check lv_field $vg/raid6 size "72.00m"
+lvremove -ff $vg
+
+# Eat 18 of 37 extents from dev1, leaving 19
+lvcreate -l 18 -n lv $vg $dev1
+# Using 100% free should take the rest of dev1 and equal from dev2
+# 1 meta takes 1 extent
+# 1 image = 18 extents = 9.00m = lv_size
+lvcreate --type raid1 -m 1 -l 100%FREE -n raid1 $vg $dev1 $dev2
+check lv_field $vg/raid1 size "9.00m"
+# Ensure image size is the same as the RAID1 size
+check lv_field $vg/raid1 size `lvs --noheadings -o size $vg/raid1_rimage_0`
+# Amount remaining in dev2 should equal the amount taken by 'lv' in dev1
+check pv_field "$dev2" pv_free `lvs --noheadings -o size $vg/lv`
+lvremove -ff $vg
+
+# Eat 18 of 37 extents from dev1, leaving 19
+lvcreate -l 18 -n lv $vg $dev1
+# Using 100% free should take the rest of dev1 and equal amount from the rest
+# 1 meta takes 1 extent
+# 1 image = 18 extents = 9.00m
+# 5 images = 90 extents = 45.00m = lv_size
+lvcreate --type raid5 -i 5 -l 100%FREE -n raid5 $vg
+check lv_field $vg/raid5 size "45.00m"
+# Amount remaining in dev6 should equal the amount taken by 'lv' in dev1
+check pv_field "$dev6" pv_free `lvs --noheadings -o size $vg/lv`
+lvremove -ff $vg
+
+# Eat 18 of 37 extents from dev1, leaving 19
+lvcreate -l 18 -n lv $vg $dev1
+# Using 100% free should take the rest of dev1, an equal amount
+# from 2 more devs, and all extents from 3 additional devs
+# 1 meta takes 1 extent
+# 1 image = 18+37 extents
+# 2 images = 110 extents = 55.00m = lv_size
+lvcreate --type raid5 -i 2 -l 100%FREE -n raid5 $vg
+check lv_field $vg/raid5 size "55.00m"
+lvremove -ff $vg
+
+# Let's do some stripe tests too
+# Eat 18 of 37 extents from dev1, leaving 19
+lvcreate -l 18 -n lv $vg $dev1
+# Using 100% free should take the rest of dev1 and an equal amount from rest
+# 1 image = 19 extents
+# 6 images = 114 extents = 57.00m = lv_size
+lvcreate -i 6 -l 100%FREE -n stripe $vg
+check lv_field $vg/stripe size "57.00m"
+lvremove -ff $vg
+
+# Eat 18 of 37 extents from dev1, leaving 19
+lvcreate -l 18 -n lv $vg $dev1
+# Using 100% free should take the rest of dev1, an equal amount from
+#  one more dev, and all of the remaining 4
+# 1 image = 19+37+37 extents
+# 2 images = 186 extents = 93.00m = lv_size
+lvcreate -i 2 -l 100%FREE -n stripe $vg
+check lv_field $vg/stripe size "93.00m"
+lvremove -ff $vg
diff --git a/test/shell/lvcreate-raid10.sh b/test/shell/lvcreate-raid10.sh
index 143e869..0ee18b8 100644
--- a/test/shell/lvcreate-raid10.sh
+++ b/test/shell/lvcreate-raid10.sh
@@ -46,6 +46,14 @@ aux wait_for_sync $vg $lv2
 
 lvremove -ff $vg
 
+# Test 100%FREE option
+# 37 extents / device
+# 1 image = 36 extents (1 for meta)
+# 3 images = 108 extents = 54.00m
+lvcreate --type raid10 -i 3 -l 100%FREE -n raid10 $vg
+check lv_field $vg/raid10 size "54.00m"
+lvremove -ff $vg
+
 #
 # FIXME: Add tests that specify particular PVs to use for creation
 #
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index bf719fe..b413f34 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -363,6 +363,8 @@ static int _update_extents_params(struct volume_group *vg,
 	} else
 		lp->pvh = &vg->pvs;
 
+	if (lcp->percent)
+		lp->approx_alloc = 1;
 	switch(lcp->percent) {
 		case PERCENT_VG:
 			lp->extents = percent_of_extents(lp->extents, vg->extent_count, 0);


