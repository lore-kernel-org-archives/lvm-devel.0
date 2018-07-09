From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 9 Jul 2018 09:35:24 -0400
Subject: master - lvcreate: vdo support
Message-ID: <201807091335.w69DZOsg030798@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c58733ca1538d04a298c4c857492ca544a820064
Commit:        c58733ca1538d04a298c4c857492ca544a820064
Parent:        6945bbdbc6f997568707594b4b930f3551893910
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 29 13:16:08 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 9 15:29:12 2018 +0200

lvcreate: vdo support

Supports basic:  'lvcreate --vdo -LXXXG -VYYYG vg/vdoname -n lvname'
Allows to create basic VDO pool volume and virtual VDO volume.
---
 WHATS_NEW                        |    1 +
 lib/metadata/metadata-exported.h |    3 +
 lib/metadata/vdo_manip.c         |   53 ++++++++++++++++++++++++++
 tools/command-lines.in           |   26 +++++++++++++
 tools/lvcreate.c                 |   76 +++++++++++++++++++++++++++++++++++---
 5 files changed, 153 insertions(+), 6 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 54d6790..407cb7e 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 3.0.0
 =============
+  Add basic creation support for VDO target.
   Never send any discard ioctl with test mode.
   Fix thin-pool alloc which needs same PV for data and metadata.
   Extend list of non-memlocked areas with newly linked libs.
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 92def2b..840f623 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1270,6 +1270,9 @@ struct logical_volume *convert_vdo_pool_lv(struct logical_volume *data_lv,
 					   const struct dm_vdo_target_params *vtp,
 					   uint32_t *virtual_extents);
 int get_vdo_write_policy(enum dm_vdo_write_policy *vwp, const char *policy);
+int fill_vdo_target_params(struct cmd_context *cmd,
+			   struct dm_vdo_target_params *vtp,
+			   struct profile *profile);
 /* --  metadata/vdo_manip.c */
 
 struct logical_volume *find_pvmove_lv(struct volume_group *vg,
diff --git a/lib/metadata/vdo_manip.c b/lib/metadata/vdo_manip.c
index 1286e84..0b3ed19 100644
--- a/lib/metadata/vdo_manip.c
+++ b/lib/metadata/vdo_manip.c
@@ -404,3 +404,56 @@ int get_vdo_write_policy(enum dm_vdo_write_policy *vwp, const char *policy)
 
 	return 1;
 }
+
+int fill_vdo_target_params(struct cmd_context *cmd,
+			   struct dm_vdo_target_params *vtp,
+			   struct profile *profile)
+{
+	const char *policy;
+
+	// TODO: Postpone filling data to the moment when VG is known with profile.
+	// TODO: Maybe add more lvm cmdline switches to set profile settings.
+
+	vtp->use_compression =
+		find_config_tree_int(cmd, allocation_vdo_use_compression_CFG, profile);
+	vtp->use_deduplication =
+		find_config_tree_int(cmd, allocation_vdo_use_deduplication_CFG, profile);
+	vtp->emulate_512_sectors =
+		find_config_tree_int(cmd, allocation_vdo_emulate_512_sectors_CFG, profile);
+	vtp->block_map_cache_size_mb =
+		find_config_tree_int64(cmd, allocation_vdo_block_map_cache_size_mb_CFG, profile);
+	vtp->block_map_period =
+		find_config_tree_int(cmd, allocation_vdo_block_map_period_CFG, profile);
+	vtp->check_point_frequency =
+		find_config_tree_int(cmd, allocation_vdo_check_point_frequency_CFG, profile);
+	vtp->use_sparse_index =
+		find_config_tree_int(cmd, allocation_vdo_use_sparse_index_CFG, profile);
+	vtp->index_memory_size_mb =
+		find_config_tree_int64(cmd, allocation_vdo_index_memory_size_mb_CFG, profile);
+	vtp->use_read_cache =
+		find_config_tree_int(cmd, allocation_vdo_use_read_cache_CFG, profile);
+	vtp->read_cache_size_mb =
+		find_config_tree_int64(cmd, allocation_vdo_read_cache_size_mb_CFG, profile);
+	vtp->slab_size_mb =
+		find_config_tree_int(cmd, allocation_vdo_slab_size_mb_CFG, profile);
+	vtp->ack_threads =
+		find_config_tree_int(cmd, allocation_vdo_ack_threads_CFG, profile);
+	vtp->bio_threads =
+		find_config_tree_int(cmd, allocation_vdo_bio_threads_CFG, profile);
+	vtp->bio_rotation =
+		find_config_tree_int(cmd, allocation_vdo_bio_rotation_CFG, profile);
+	vtp->cpu_threads =
+		find_config_tree_int(cmd, allocation_vdo_cpu_threads_CFG, profile);
+	vtp->hash_zone_threads =
+		find_config_tree_int(cmd, allocation_vdo_hash_zone_threads_CFG, profile);
+	vtp->logical_threads =
+		find_config_tree_int(cmd, allocation_vdo_logical_threads_CFG, profile);
+	vtp->physical_threads =
+		find_config_tree_int(cmd, allocation_vdo_physical_threads_CFG, profile);
+
+	policy = find_config_tree_str(cmd, allocation_vdo_write_policy_CFG, profile);
+	if (!get_vdo_write_policy(&vtp->write_policy, policy))
+		return_0;
+
+	return 1;
+}
diff --git a/tools/command-lines.in b/tools/command-lines.in
index 0155b33..de5c88b 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -731,6 +731,7 @@ OO_LVCREATE_POOL: --poolmetadatasize SizeMB, --poolmetadataspare Bool, --chunksi
 
 OO_LVCREATE_THIN: --discards Discards, --errorwhenfull Bool
 
+OO_LVCREATE_VDO: --compression Bool, --deduplication Bool
 ---
 
 lvcreate --type error --size SizeMB VG
@@ -741,6 +742,31 @@ FLAGS: SECONDARY_SYNTAX
 
 ---
 
+lvcreate --type vdo --size SizeMB VG
+OO: --vdo, OO_LVCREATE, OO_LVCREATE_VDO, --virtualsize SizeMB, --stripes Number, --stripesize SizeKB,
+OP: PV ...
+IO: --mirrors 0
+ID: lvcreate_vdo_vol
+DESC: Create an LV that returns VDO when used.
+
+lvcreate --vdo --size SizeMB VG
+OO: OO_LVCREATE, OO_LVCREATE_VDO, --virtualsize SizeMB, --stripes Number, --stripesize SizeKB
+OP: PV ...
+IO: --mirrors 0
+ID: lvcreate_vdo_vol
+DESC: Create an VDO LV with VDO pool.
+FLAGS: SECONDARY_SYNTAX
+
+lvcreate --vdopool LV --virtualsize SizeMB VG
+OO: --vdo, --type vdo
+OP: PV ...
+IO: --mirrors 0
+ID: lvcreate_vdo_vol
+DESC: Create an VDO LV using existing VDO pool.
+FLAGS: SECONDARY_SYNTAX
+
+---
+
 lvcreate --type zero --size SizeMB VG
 OO: OO_LVCREATE
 ID: lvcreate_zero_vol
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 4009ea5..3c22794 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -61,6 +61,7 @@ static int _lvcreate_name_params(struct cmd_context *cmd,
 		return_0;
 
 	lp->pool_name = arg_str_value(cmd, thinpool_ARG, NULL)
+		? : arg_str_value(cmd, vdopool_ARG, NULL)
 		? : arg_str_value(cmd, cachepool_ARG, NULL);
 	if (!validate_lvname_param(cmd, &lp->vg_name, &lp->pool_name))
 		return_0;
@@ -154,7 +155,7 @@ static int _lvcreate_name_params(struct cmd_context *cmd,
 		}
 
 		(*pargv)++, (*pargc)--;
-	} else if ((seg_is_thin(lp) || seg_is_pool(lp)) && argc) {
+	} else if ((seg_is_pool(lp) || seg_is_thin(lp) || seg_is_vdo(lp)) && argc) {
 		/* argv[0] might be [/dev.../]vg or [/dev../]vg/pool */
 
 		vg_name = skip_dev_dir(cmd, argv[0], NULL);
@@ -766,6 +767,8 @@ static int _lvcreate_params(struct cmd_context *cmd,
 		segtype_str = SEG_TYPE_NAME_CACHE;
 	else if (arg_is_set(cmd, thin_ARG) || arg_is_set(cmd, thinpool_ARG))
 		segtype_str = SEG_TYPE_NAME_THIN;
+	else if (arg_is_set(cmd, vdo_ARG))
+		segtype_str = SEG_TYPE_NAME_VDO;
 	else if (arg_is_set(cmd, virtualsize_ARG)) {
 		if (arg_is_set(cmd, virtualoriginsize_ARG))
 			segtype_str = SEG_TYPE_NAME_SNAPSHOT; /* --virtualoriginsize incompatible with pools */
@@ -852,6 +855,10 @@ static int _lvcreate_params(struct cmd_context *cmd,
 	discards_ARG,\
 	thinpool_ARG
 
+#define VDO_POOL_ARGS \
+	compression_ARG,\
+	deduplication_ARG
+
 	/* Cache and cache-pool segment type */
 	if (seg_is_cache(lp)) {
 		/* Only supported with --type cache, -H, --cache */
@@ -1034,6 +1041,46 @@ static int _lvcreate_params(struct cmd_context *cmd,
 					thin_ARG, THIN_POOL_ARGS,
 					-1))
 		return_0;
+	else if (seg_is_vdo(lp)) {
+		/* Only supported with --type thin, -T, --thin, -V */
+		if (arg_outside_list_is_set(cmd, "is unsupported with VDOs",
+					    LVCREATE_ARGS,
+					    PERSISTENT_ARGS,
+					    SIZE_ARGS,
+					    VDO_POOL_ARGS,
+					    vdo_ARG,
+					    virtualsize_ARG,
+					    wipesignatures_ARG, zero_ARG,
+					    -1))
+			return_0;
+
+		/* If size/extents given with thin, then we are also creating a thin-pool */
+		if (arg_is_set(cmd, size_ARG) || arg_is_set(cmd, extents_ARG)) {
+			if (arg_is_set(cmd, pooldatasize_ARG)) {
+				log_error("Please specify either size or pooldatasize.");
+				return 0;
+			}
+			lp->create_pool = 1;
+		} else if (arg_from_list_is_set(cmd, "is supported only with VDO pool creation",
+						VDO_POOL_ARGS,
+						SIZE_ARGS,
+						zero_ARG,
+						-1))
+			return_0;
+
+		// FIXME: prefiling here - this is wrong place
+		// but will work for this moment
+		if (!fill_vdo_target_params(cmd, &lp->vdo_params, NULL))
+			return_0;
+
+		if (arg_is_set(cmd, compression_ARG))
+			lp->vdo_params.use_compression =
+				arg_int_value(cmd, compression_ARG, 0);
+
+		if (arg_is_set(cmd, deduplication_ARG))
+			lp->vdo_params.use_deduplication =
+				arg_int_value(cmd, deduplication_ARG, 0);
+	}
 
 	/* Check options shared between more segment types */
 	if (!seg_is_mirror(lp) && !seg_is_raid(lp)) {
@@ -1055,8 +1102,8 @@ static int _lvcreate_params(struct cmd_context *cmd,
 				 -1))
 		return_0;
 
-	if (!lp->snapshot && !seg_is_thin_volume(lp) &&
-	    arg_from_list_is_set(cmd, "is supported only with sparse snapshots and thins",
+	if (!lp->snapshot && !seg_is_thin_volume(lp) && !seg_is_vdo(lp) &&
+	    arg_from_list_is_set(cmd, "is supported only with vdo,  sparse snapshots and thins",
 				 virtualsize_ARG,
 				 -1))
 		return_0;
@@ -1423,6 +1470,7 @@ static int _check_pool_parameters(struct cmd_context *cmd,
 
 	if (!seg_is_cache(lp) &&
 	    !seg_is_thin_volume(lp) &&
+	    !seg_is_vdo(lp) &&
 	    !seg_is_pool(lp)) {
 		if (lp->pool_name && !lp->snapshot) {
 			log_error("Segment type %s cannot use pool %s.",
@@ -1444,13 +1492,14 @@ static int _check_pool_parameters(struct cmd_context *cmd,
 				return 0;
 			}
 		}
-		if (seg_is_pool(lp)) {
+		if (seg_is_pool(lp) || seg_is_vdo(lp)) {
 			if (lp->major != -1 || lp->minor != -1) {
 				log_error("Persistent major and minor numbers are unsupported with pools.");
 				return 0;
 			}
 			/* When creating just pool the pool_name needs to be in lv_name */
-			lp->lv_name = lp->pool_name;
+			if (seg_is_pool(lp))
+				lp->lv_name = lp->pool_name;
 		} else if (vg) {
 			/* FIXME: what better to do with --readahead and pools? */
 			if (arg_is_set(cmd, readahead_ARG)) {
@@ -1492,6 +1541,17 @@ static int _check_pool_parameters(struct cmd_context *cmd,
 	return 1;
 }
 
+static int _check_vdo_parameters(struct volume_group *vg, struct lvcreate_params *lp,
+				  struct lvcreate_cmdline_params *lcp)
+{
+	if (seg_is_vdo(lp) && lp->snapshot) {
+		log_error("Please either create VDO or snapshot.");
+		return 0;
+	}
+
+	return 1;
+}
+
 /*
  * Check zero_ARG with default value set to value of wipesignatures_ARG
  * with its default set to 'n'. So if user specifies on command line either
@@ -1612,6 +1672,9 @@ static int _lvcreate_single(struct cmd_context *cmd, const char *vg_name,
 	if (!_check_pool_parameters(cmd, vg, lp, lcp))
 		goto_out;
 
+	if (seg_is_vdo(lp) && !_check_vdo_parameters(vg, lp, lcp))
+		return_0;
+
 	/* All types are checked */
 	if (!_check_zero_parameters(cmd, lp))
 		return_0;
@@ -1622,7 +1685,8 @@ static int _lvcreate_single(struct cmd_context *cmd, const char *vg_name,
 	if (seg_is_thin(lp) && !_validate_internal_thin_processing(lp))
 		goto_out;
 
-	if (lp->create_pool) {
+	if (lp->create_pool && !seg_is_vdo(lp)) {
+		/* TODO: VDO does not use spare LV ATM, maybe later for rescue resize ? */
 		if (!handle_pool_metadata_spare(vg, lp->pool_metadata_extents,
 						lp->pvh, lp->pool_metadata_spare))
 			goto_out;


