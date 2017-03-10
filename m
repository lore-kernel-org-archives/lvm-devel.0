From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 10 Mar 2017 13:35:20 -0500
Subject: master - thin: add new ZERO/DISCARDS_UNSELECTED
Message-ID: <201703101835.v2AIZKCw018136@int-mx09.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b8cd0f4808fcb88ea803a7ffff5f27801fb14e02
Commit:        b8cd0f4808fcb88ea803a7ffff5f27801fb14e02
Parent:        8c72878cf2f53811cf5ae6fc9b7c787feb74e0c6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 3 20:46:13 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 10 19:33:00 2017 +0100

thin: add new ZERO/DISCARDS_UNSELECTED

To more easily recognize unselected state from select '0' state
add new 'THIN_ZERO_UNSELECTED' enum.
Same applies to THIN_DISCARDS_UNSELECTED.

For those we no longer need to use PASS_ARG_ZERO or PASS_ARG_DISCARDS.
---
 lib/metadata/lv.c                |    2 +-
 lib/metadata/lv_manip.c          |    2 +-
 lib/metadata/merge.c             |    8 ++++++--
 lib/metadata/metadata-exported.h |   12 ++++++++++--
 lib/metadata/thin_manip.c        |   27 +++++++++++++++++++--------
 lib/report/properties.c          |    2 +-
 lib/report/report.c              |    2 +-
 lib/thin/thin.c                  |   16 ++++++++++++----
 tools/lvchange.c                 |    2 +-
 tools/lvconvert.c                |    6 +++---
 tools/lvcreate.c                 |    2 +-
 tools/toollib.c                  |   16 ++++++++++------
 tools/toollib.h                  |    2 +-
 13 files changed, 67 insertions(+), 32 deletions(-)

diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 8c33a5e..e58de66 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -1279,7 +1279,7 @@ char *lv_attr_dup_with_info_and_seg_status(struct dm_pool *mem, const struct lv_
 
 	if (((lv_is_thin_volume(lv) && (seg = first_seg(lv)) && seg->pool_lv && (seg = first_seg(seg->pool_lv))) ||
 	     (lv_is_thin_pool(lv) && (seg = first_seg(lv)))) &&
-	    seg->zero_new_blocks)
+	    (seg->zero_new_blocks == THIN_ZERO_YES))
 		repstr[7] = 'z';
 	else
 		repstr[7] = '-';
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 90c61aa..cb9ba68 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -7684,7 +7684,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		first_seg(lv)->max_recovery_rate = lp->max_recovery_rate;
 	} else if (lv_is_thin_pool(lv)) {
 		first_seg(lv)->chunk_size = lp->chunk_size;
-		first_seg(lv)->zero_new_blocks = lp->zero ? 1 : 0;
+		first_seg(lv)->zero_new_blocks = lp->zero_new_blocks;
 		first_seg(lv)->discards = lp->discards;
 		if (!recalculate_pool_chunk_size_with_dev_hints(lv, lp->passed_args,
 								lp->thin_chunk_size_calc_policy)) {
diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
index b600bc4..a5cb9f3 100644
--- a/lib/metadata/merge.c
+++ b/lib/metadata/merge.c
@@ -396,10 +396,14 @@ static void _check_lv_segment(struct logical_volume *lv, struct lv_segment *seg,
 
 		if (!validate_thin_pool_chunk_size(lv->vg->cmd, seg->chunk_size))
 			seg_error("has invalid chunk size.");
+
+		if (seg->zero_new_blocks != THIN_ZERO_YES &&
+                    seg->zero_new_blocks != THIN_ZERO_NO)
+			seg_error("zero_new_blocks is invalid");
 	} else { /* !thin_pool */
-		if (seg->zero_new_blocks)
+		if (seg->zero_new_blocks != THIN_ZERO_UNSELECTED)
 			seg_error("sets zero_new_blocks");
-		if (seg->discards)
+		if (seg->discards != THIN_DISCARDS_UNSELECTED)
 			seg_error("sets discards");
 		if (!dm_list_empty(&seg->thin_messages))
 			seg_error("sets thin_messages list");
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index c80a3c5..42ca820 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -275,6 +275,13 @@ enum {
 };
 
 typedef enum {
+	THIN_ZERO_UNSELECTED = 0,
+	THIN_ZERO_NO,
+	THIN_ZERO_YES,
+} thin_zero_t;
+
+typedef enum {
+	THIN_DISCARDS_UNSELECTED = 0,
 	THIN_DISCARDS_IGNORE,
 	THIN_DISCARDS_NO_PASSDOWN,
 	THIN_DISCARDS_PASSDOWN,
@@ -482,7 +489,7 @@ struct lv_segment {
 	struct lv_segment_area *meta_areas;	/* For RAID */
 	struct logical_volume *metadata_lv;	/* For thin_pool */
 	uint64_t transaction_id;		/* For thin_pool, thin */
-	unsigned zero_new_blocks;		/* For thin_pool */
+	thin_zero_t zero_new_blocks;		/* For thin_pool */
 	thin_discards_t discards;		/* For thin_pool */
 	struct dm_list thin_messages;		/* For thin_pool */
 	struct logical_volume *external_lv;	/* For thin */
@@ -868,7 +875,7 @@ int update_thin_pool_params(const struct segment_type *segtype,
 			    int passed_args, uint32_t pool_data_extents,
 			    uint32_t *pool_metadata_extents,
 			    int *chunk_size_calc_method, uint32_t *chunk_size,
-			    thin_discards_t *discards, int *zero);
+			    thin_discards_t *discards, thin_zero_t *zero_new_blocks);
 const char *get_pool_discards_name(thin_discards_t discards);
 int set_pool_discards(thin_discards_t *discards, const char *str);
 struct logical_volume *alloc_pool_metadata(struct logical_volume *pool_lv,
@@ -931,6 +938,7 @@ struct lvcreate_params {
 	int activation_skip; /* activation skip flags */
 	activation_change_t activate; /* non-snapshot, non-mirror */
 	thin_discards_t discards;     /* thin */
+	thin_zero_t zero_new_blocks;
 #define THIN_CHUNK_SIZE_CALC_METHOD_GENERIC 0x01
 #define THIN_CHUNK_SIZE_CALC_METHOD_PERFORMANCE 0x02
 	int thin_chunk_size_calc_policy;
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index 7748cd3..5c74248 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -604,7 +604,7 @@ int update_thin_pool_params(const struct segment_type *segtype,
 			    uint32_t pool_data_extents,
 			    uint32_t *pool_metadata_extents,
 			    int *chunk_size_calc_method, uint32_t *chunk_size,
-			    thin_discards_t *discards, int *zero)
+			    thin_discards_t *discards, thin_zero_t *zero_new_blocks)
 {
 	struct cmd_context *cmd = vg->cmd;
 	struct profile *profile = vg->profile;
@@ -625,7 +625,9 @@ int update_thin_pool_params(const struct segment_type *segtype,
 	if (!validate_thin_pool_chunk_size(cmd, *chunk_size))
 		return_0;
 
-	if (!(passed_args & PASS_ARG_DISCARDS)) {
+	if (discards &&
+	    (*discards == THIN_DISCARDS_UNSELECTED) &&
+	    find_config_tree_node(cmd, allocation_thin_pool_discards_CFG, profile)) {
 		if (!(str = find_config_tree_str(cmd, allocation_thin_pool_discards_CFG, profile))) {
 			log_error(INTERNAL_ERROR "Could not find configuration.");
 			return 0;
@@ -634,8 +636,11 @@ int update_thin_pool_params(const struct segment_type *segtype,
 			return_0;
 	}
 
-	if (!(passed_args & PASS_ARG_ZERO))
-		*zero = find_config_tree_bool(cmd, allocation_thin_pool_zero_CFG, profile);
+	if (zero_new_blocks &&
+	    (*zero_new_blocks == THIN_ZERO_UNSELECTED) &&
+	    find_config_tree_node(cmd, allocation_thin_pool_zero_CFG, profile))
+		*zero_new_blocks = find_config_tree_bool(cmd, allocation_thin_pool_zero_CFG, profile)
+			? THIN_ZERO_YES : THIN_ZERO_NO;
 
 	if (!(attr & THIN_FEATURE_BLOCK_SIZE) &&
 	    !is_power_of_2(*chunk_size)) {
@@ -705,6 +710,13 @@ int update_thin_pool_params(const struct segment_type *segtype,
 	      extents_from_size(vg->cmd, pool_metadata_size, extent_size)))
 		return_0;
 
+	if (discards && (*discards == THIN_DISCARDS_UNSELECTED))
+		if (!set_pool_discards(discards, DEFAULT_THIN_POOL_DISCARDS))
+			return_0;
+
+	if (zero_new_blocks && (*zero_new_blocks == THIN_ZERO_UNSELECTED))
+		*zero_new_blocks = (DEFAULT_THIN_POOL_ZERO) ? THIN_ZERO_YES : THIN_ZERO_NO;
+
 	return 1;
 }
 
@@ -733,11 +745,10 @@ const char *get_pool_discards_name(thin_discards_t discards)
 		return "nopassdown";
 	case THIN_DISCARDS_IGNORE:
 		return "ignore";
+	default:
+		log_error(INTERNAL_ERROR "Unknown discards type encountered.");
+		return "unknown";
 	}
-
-	log_error(INTERNAL_ERROR "Unknown discards type encountered.");
-
-	return "unknown";
 }
 
 int lv_is_thin_origin(const struct logical_volume *lv, unsigned int *snap_count)
diff --git a/lib/report/properties.c b/lib/report/properties.c
index 04f2cef..c07fb2a 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -470,7 +470,7 @@ GET_LVSEG_NUM_PROPERTY_FN(chunk_size, (SECTOR_SIZE * lvseg_chunksize(lvseg)))
 #define _chunk_size_set prop_not_implemented_set
 GET_LVSEG_NUM_PROPERTY_FN(thin_count, dm_list_size(&lvseg->lv->segs_using_this_lv))
 #define _thin_count_set prop_not_implemented_set
-GET_LVSEG_NUM_PROPERTY_FN(zero, lvseg->zero_new_blocks)
+GET_LVSEG_NUM_PROPERTY_FN(zero, (lvseg->zero_new_blocks == THIN_ZERO_YES))
 #define _zero_set prop_not_implemented_set
 GET_LVSEG_NUM_PROPERTY_FN(transaction_id, lvseg->transaction_id)
 #define _transaction_id_set prop_not_implemented_set
diff --git a/lib/report/report.c b/lib/report/report.c
index b5791c6..27269d4 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -3654,7 +3654,7 @@ static int _thinzero_disp(struct dm_report *rh, struct dm_pool *mem,
 		seg = first_seg(seg->pool_lv);
 
 	if (seg_is_thin_pool(seg))
-		return _binary_disp(rh, mem, field, seg->zero_new_blocks, GET_FIRST_RESERVED_NAME(zero_y), private);
+		return _binary_disp(rh, mem, field, (seg->zero_new_blocks == THIN_ZERO_YES), GET_FIRST_RESERVED_NAME(zero_y), private);
 
 	return _binary_undef_disp(rh, mem, field, private);
 }
diff --git a/lib/thin/thin.c b/lib/thin/thin.c
index 1e29566..73fffa6 100644
--- a/lib/thin/thin.c
+++ b/lib/thin/thin.c
@@ -45,7 +45,7 @@ static void _thin_pool_display(const struct lv_segment *seg)
 		  dm_list_size(&seg->lv->segs_using_this_lv));
 	log_print("  Transaction ID\t%" PRIu64, seg->transaction_id);
 	log_print("  Zero new blocks\t%s",
-		  seg->zero_new_blocks ? "yes" : "no");
+		  (seg->zero_new_blocks == THIN_ZERO_YES) ? "yes" : "no");
 
 	log_print(" ");
 }
@@ -84,6 +84,7 @@ static int _thin_pool_text_import(struct lv_segment *seg,
 	const char *lv_name;
 	struct logical_volume *pool_data_lv, *pool_metadata_lv;
 	const char *discards_str = NULL;
+	uint32_t zero = 0;
 
 	if (!dm_config_get_str(sn, "metadata", &lv_name))
 		return SEG_LOG_ERROR("Metadata must be a string in");
@@ -124,9 +125,11 @@ static int _thin_pool_text_import(struct lv_segment *seg,
 				     seg->device_id);
 
 	if (dm_config_has_node(sn, "zero_new_blocks") &&
-	    !dm_config_get_uint32(sn, "zero_new_blocks", &seg->zero_new_blocks))
+	    !dm_config_get_uint32(sn, "zero_new_blocks", &zero))
 		return SEG_LOG_ERROR("Could not read zero_new_blocks for");
 
+	seg->zero_new_blocks = (zero) ? THIN_ZERO_YES : THIN_ZERO_NO;
+
 	/* Read messages */
 	for (; sn; sn = sn->sib)
 		if (!(sn->v) && !_thin_pool_add_message(seg, sn->key, sn->child))
@@ -165,8 +168,13 @@ static int _thin_pool_text_export(const struct lv_segment *seg, struct formatter
 		return 0;
 	}
 
-	if (seg->zero_new_blocks)
+	if (seg->zero_new_blocks == THIN_ZERO_YES)
 		outf(f, "zero_new_blocks = 1");
+	else if (seg->zero_new_blocks != THIN_ZERO_NO) {
+		log_error(INTERNAL_ERROR "Invalid zero new blocks value %d.",
+			  seg->zero_new_blocks);
+		return 0;
+	}
 
 	dm_list_iterate_items(tmsg, &seg->thin_messages) {
 		/* Extra validation */
@@ -304,7 +312,7 @@ static int _thin_pool_add_target_line(struct dev_manager *dm,
 					       seg->transaction_id,
 					       metadata_dlid, pool_dlid,
 					       seg->chunk_size, low_water_mark,
-					       seg->zero_new_blocks ? 0 : 1))
+					       (seg->zero_new_blocks == THIN_ZERO_YES) ? 0 : 1))
 		return_0;
 
 	if (attr & THIN_FEATURE_DISCARDS) {
diff --git a/tools/lvchange.c b/tools/lvchange.c
index cba0496..8fae806 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -98,7 +98,7 @@ static int _lvchange_pool_update(struct cmd_context *cmd,
 	}
 
 	if (arg_is_set(cmd, zero_ARG)) {
-		val = arg_uint_value(cmd, zero_ARG, 1);
+		val = arg_uint_value(cmd, zero_ARG, 0) ? THIN_ZERO_YES : THIN_ZERO_NO;
 		if (val != first_seg(lv)->zero_new_blocks) {
 			first_seg(lv)->zero_new_blocks = val;
 			update++;
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 3d7259e..4ed5018 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -3063,9 +3063,9 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 		const char *discards_name;
 
 		if (arg_is_set(cmd, zero_ARG))
-			seg->zero_new_blocks = arg_int_value(cmd, zero_ARG, 0);
+			seg->zero_new_blocks = arg_int_value(cmd, zero_ARG, 0) ? THIN_ZERO_YES : THIN_ZERO_NO;
 		else
-			seg->zero_new_blocks = find_config_tree_bool(cmd, allocation_thin_pool_zero_CFG, vg->profile);
+			seg->zero_new_blocks = find_config_tree_bool(cmd, allocation_thin_pool_zero_CFG, vg->profile) ? THIN_ZERO_YES : THIN_ZERO_NO;
 
 		if (arg_is_set(cmd, discards_ARG))
 			seg->discards = (thin_discards_t) arg_uint_value(cmd, discards_ARG, THIN_DISCARDS_PASSDOWN);
@@ -3097,7 +3097,7 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 	if (!vg_write(vg) || !vg_commit(vg))
 		return_0;
 
-	if (seg->zero_new_blocks &&
+	if ((seg->zero_new_blocks == THIN_ZERO_YES) &&
 	    seg->chunk_size >= DEFAULT_THIN_POOL_CHUNK_SIZE_PERFORMANCE * 2)
 		log_warn("WARNING: Pool zeroing and large %s chunk size slows down provisioning.",
 			 display_size(cmd, seg->chunk_size));
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 206a10b..63b2c6d 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -1079,7 +1079,7 @@ static int _lvcreate_params(struct cmd_context *cmd,
 	    (lp->create_pool &&
 	     !get_pool_params(cmd, lp->segtype, &lp->passed_args,
 			      &lp->pool_metadata_size, &lp->pool_metadata_spare,
-			      &lp->chunk_size, &lp->discards, &lp->zero)) ||
+			      &lp->chunk_size, &lp->discards, &lp->zero_new_blocks)) ||
 	    !_read_cache_params(cmd, lp) ||
 	    !_read_mirror_and_raid_params(cmd, lp))
 		return_0;
diff --git a/tools/toollib.c b/tools/toollib.c
index c10f5ca..c9461e5 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2015 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2017 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -1199,22 +1199,26 @@ int get_pool_params(struct cmd_context *cmd,
 		    int *pool_metadata_spare,
 		    uint32_t *chunk_size,
 		    thin_discards_t *discards,
-		    int *zero)
+		    thin_zero_t *zero_new_blocks)
 {
 	*passed_args = 0;
 
 	if (segtype_is_thin_pool(segtype) || segtype_is_thin(segtype)) {
 		if (arg_is_set(cmd, zero_ARG)) {
 			*passed_args |= PASS_ARG_ZERO;
-			*zero = arg_int_value(cmd, zero_ARG, 1);
-			log_very_verbose("%s pool zeroing.", *zero ? "Enabling" : "Disabling");
-		}
+			*zero_new_blocks = arg_int_value(cmd, zero_ARG, 0) ? THIN_ZERO_YES : THIN_ZERO_NO;
+			log_very_verbose("%s pool zeroing.",
+					 (*zero_new_blocks == THIN_ZERO_YES) ? "Enabling" : "Disabling");
+		} else
+			*zero_new_blocks = THIN_ZERO_UNSELECTED;
+
 		if (arg_is_set(cmd, discards_ARG)) {
 			*passed_args |= PASS_ARG_DISCARDS;
 			*discards = (thin_discards_t) arg_uint_value(cmd, discards_ARG, 0);
 			log_very_verbose("Setting pool discards to %s.",
 					 get_pool_discards_name(*discards));
-		}
+		} else
+			*discards = THIN_DISCARDS_UNSELECTED;
 	}
 
 	if (arg_from_list_is_negative(cmd, "may not be negative",
diff --git a/tools/toollib.h b/tools/toollib.h
index 504721e..7c588fc 100644
--- a/tools/toollib.h
+++ b/tools/toollib.h
@@ -214,7 +214,7 @@ int get_pool_params(struct cmd_context *cmd,
 		    int *pool_metadata_spare,
 		    uint32_t *chunk_size,
 		    thin_discards_t *discards,
-		    int *zero);
+		    thin_zero_t *zero_new_blocks);
 
 int get_stripe_params(struct cmd_context *cmd, const struct segment_type *segtype,
 		      uint32_t *stripes, uint32_t *stripe_size,


