From: Tony Asleson <tasleson@redhat.com>
Date: Thu,  1 Nov 2012 18:11:24 -0500
Subject: [PATCH 2/3] liblvm: Move core lv re-size to lv_manip.c
In-Reply-To: <1351811485-18488-1-git-send-email-tasleson@redhat.com>
References: <1351811485-18488-1-git-send-email-tasleson@redhat.com>
Message-ID: <1351811485-18488-3-git-send-email-tasleson@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Moved the core function to lv_manip so that the command
line and the API could call it.  To make this work all
the argument parsing functions are being done in
tools/lv_resize.c and all the parameters are expected to be
passed in with the struct lvresize_params.

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 lib/metadata/lv_manip.c          |  689 ++++++++++++++++++++++++++++++++++-
 lib/metadata/metadata-exported.h |   75 ++++-
 lib/metadata/pv_manip.c          |    2 +-
 lib/misc/lvm-percent.c           |    5 +
 lib/misc/lvm-percent.h           |    2 +
 tools/lvresize.c                 |  737 ++------------------------------------
 tools/toollib.c                  |    4 +-
 tools/tools.h                    |   27 +--
 8 files changed, 801 insertions(+), 740 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 9f87854..20bcc1c 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -27,6 +27,7 @@
 #include "activate.h"
 #include "str_list.h"
 #include "defaults.h"
+#include "lvm-exec.h"
 
 typedef enum {
 	PREFERRED,
@@ -993,7 +994,7 @@ static void _init_alloc_parms(struct alloc_handle *ah, struct alloc_parms *alloc
 		alloc_parms->flags |= A_CLING_BY_TAGS;
 
 	/*
-	 * For normal allocations, if any extents have already been found 
+	 * For normal allocations, if any extents have already been found
 	 * for allocation, prefer to place further extents on the same disks as
 	 * have already been used.
 	 */
@@ -1325,7 +1326,7 @@ static int _is_same_pv(struct pv_match *pvmatch __attribute((unused)), struct pv
 }
 
 /*
- * Does PV area have a tag listed in allocation/cling_tag_list that 
+ * Does PV area have a tag listed in allocation/cling_tag_list that
  * matches a tag of the PV of the existing segment?
  */
 static int _pvs_have_matching_tag(const struct dm_config_node *cling_tag_list_cn, struct physical_volume *pv1, struct physical_volume *pv2)
@@ -1409,8 +1410,8 @@ static void _reserve_area(struct pv_area_used *area_used, struct pv_area *pva, u
 {
 	log_debug("%s allocation area %" PRIu32 " %s %s start PE %" PRIu32
 		  " length %" PRIu32 " leaving %" PRIu32 ".",
-		  area_used->pva ? "Changing   " : "Considering", 
-		  ix_pva - 1, area_used->pva ? "to" : "as", 
+		  area_used->pva ? "Changing   " : "Considering",
+		  ix_pva - 1, area_used->pva ? "to" : "as",
 		  dev_name(pva->map->pv->dev), pva->start, required, unreserved);
 
 	area_used->pva = pva;
@@ -1581,7 +1582,7 @@ static area_use_t _check_pva(struct alloc_handle *ah, struct pv_area *pva, uint3
 		if (((alloc_parms->flags & A_CONTIGUOUS_TO_LVSEG) || (ah->maximise_cling && alloc_parms->prev_lvseg)) &&
 		    _check_contiguous(ah->cmd, alloc_parms->prev_lvseg, pva, alloc_state))
 			return PREFERRED;
-	
+
 		/* Try next area on same PV if looking for contiguous space */
 		if (alloc_parms->flags & A_CONTIGUOUS_TO_LVSEG)
 			return NEXT_AREA;
@@ -1631,7 +1632,7 @@ static uint32_t _calc_required_extents(struct alloc_handle *ah, struct pv_area *
 	uint32_t required = max_to_allocate / ah->area_multiple;
 
 	/*
-	 * Update amount unreserved - effectively splitting an area 
+	 * Update amount unreserved - effectively splitting an area
 	 * into two or more parts.  If the whole stripe doesn't fit,
 	 * reduce amount we're looking for.
 	 */
@@ -1805,7 +1806,7 @@ static int _find_some_parallel_space(struct alloc_handle *ah, const struct alloc
 					goto next_pv;
 
 				/*
-				 * Avoid PVs already set aside for log.  
+				 * Avoid PVs already set aside for log.
 				 * We only reach here if there were enough PVs for the main areas but
 				 * not enough for the logs.
 				 */
@@ -1908,7 +1909,7 @@ static int _find_some_parallel_space(struct alloc_handle *ah, const struct alloc
 				alloc_state->areas[ix_offset++].pva = NULL;
 			}
 	}
-	
+
 	/*
 	 * First time around, if there's a log, allocate it on the
 	 * smallest device that has space for it.
@@ -1946,7 +1947,7 @@ static int _find_some_parallel_space(struct alloc_handle *ah, const struct alloc
 }
 
 /*
- * Choose sets of parallel areas to use, respecting any constraints 
+ * Choose sets of parallel areas to use, respecting any constraints
  * supplied in alloc_parms.
  */
 static int _find_max_parallel_space_for_one_policy(struct alloc_handle *ah, struct alloc_parms *alloc_parms,
@@ -3041,6 +3042,670 @@ int lv_rename(struct cmd_context *cmd, struct logical_volume *lv,
 	return lv_rename_update(cmd, lv, new_name, 1);
 }
 
+static uint32_t lvseg_get_stripes(struct lv_segment *seg, uint32_t *stripesize)
+{
+	uint32_t s;
+	struct lv_segment *seg_mirr;
+
+	/* If segment mirrored, check if images are striped */
+	if (seg_is_mirrored(seg))
+		for (s = 0; s < seg->area_count; s++) {
+			if (seg_type(seg, s) != AREA_LV)
+				continue;
+			seg_mirr = first_seg(seg_lv(seg, s));
+
+			if (seg_is_striped(seg_mirr)) {
+				seg = seg_mirr;
+				break;
+			}
+		}
+
+
+	if (seg_is_striped(seg)) {
+		*stripesize = seg->stripe_size;
+		return seg->area_count;
+	}
+
+	*stripesize = 0;
+	return 0;
+}
+
+static int _validate_stripesize(struct cmd_context *cmd,
+				const struct volume_group *vg,
+				struct lvresize_params *lp)
+{
+
+	if ( lp->ac_stripesize_value > STRIPE_SIZE_LIMIT * 2) {
+		log_error("Stripe size cannot be larger than %s",
+			  display_size(cmd, (uint64_t) STRIPE_SIZE_LIMIT));
+		return 0;
+	}
+
+	if (!(vg->fid->fmt->features & FMT_SEGMENTS))
+		log_warn("Varied stripesize not supported. Ignoring.");
+	else if (lp->ac_stripesize_value > (uint64_t) vg->extent_size * 2) {
+		log_error("Reducing stripe size %s to maximum, "
+			  "physical extent size %s",
+			  display_size(cmd,lp->ac_stripesize_value),
+			  display_size(cmd, (uint64_t) vg->extent_size));
+		lp->stripe_size = vg->extent_size;
+	} else
+		lp->stripe_size = lp->ac_stripesize_value;
+
+	if (lp->stripe_size & (lp->stripe_size - 1)) {
+		log_error("Stripe size must be power of 2");
+		return 0;
+	}
+
+	return 1;
+}
+
+static int _request_confirmation(struct cmd_context *cmd,
+				 const struct volume_group *vg,
+				 const struct logical_volume *lv,
+				 const struct lvresize_params *lp)
+{
+	struct lvinfo info = { 0 };
+
+	if (!lv_info(cmd, lv, 0, &info, 1, 0) && driver_version(NULL, 0)) {
+		log_error("lv_info failed: aborting");
+		return 0;
+	}
+
+	if (lp->resizefs) {
+		if (!info.exists) {
+			log_error("Logical volume %s must be activated "
+				  "before resizing filesystem", lp->lv_name);
+			return 0;
+		}
+		return 1;
+	}
+
+	if (!info.exists)
+		return 1;
+
+	log_warn("WARNING: Reducing active%s logical volume to %s",
+		 info.open_count ? " and open" : "",
+		 display_size(cmd, (uint64_t) lp->extents * vg->extent_size));
+
+	log_warn("THIS MAY DESTROY YOUR DATA (filesystem etc.)");
+
+	if (!lp->ac_force) {
+		if (yes_no_prompt("Do you really want to reduce %s? [y/n]: ",
+				  lp->lv_name) == 'n') {
+			log_error("Logical volume %s NOT reduced", lp->lv_name);
+			return 0;
+		}
+		if (sigint_caught())
+			return 0;
+	}
+
+	return 1;
+}
+
+static int _adjust_policy_params(struct cmd_context *cmd,
+				 struct logical_volume *lv, struct lvresize_params *lp)
+{
+	percent_t percent;
+	int policy_threshold, policy_amount;
+
+	if (lv_is_thin_pool(lv)) {
+		policy_threshold =
+			find_config_tree_int(cmd, "activation/thin_pool_autoextend_threshold",
+					     DEFAULT_THIN_POOL_AUTOEXTEND_THRESHOLD) * PERCENT_1;
+		policy_amount =
+			find_config_tree_int(cmd, "activation/thin_pool_autoextend_percent",
+					     DEFAULT_THIN_POOL_AUTOEXTEND_PERCENT);
+		if (!policy_amount && policy_threshold < PERCENT_100)
+                        return 0;
+	} else {
+		policy_threshold =
+			find_config_tree_int(cmd, "activation/snapshot_autoextend_threshold",
+					     DEFAULT_SNAPSHOT_AUTOEXTEND_THRESHOLD) * PERCENT_1;
+		policy_amount =
+			find_config_tree_int(cmd, "activation/snapshot_autoextend_percent",
+					     DEFAULT_SNAPSHOT_AUTOEXTEND_PERCENT);
+	}
+
+	if (policy_threshold >= PERCENT_100)
+		return 1; /* nothing to do */
+
+	if (lv_is_thin_pool(lv)) {
+		if (!lv_thin_pool_percent(lv, 1, &percent))
+			return_0;
+		if (percent > policy_threshold) {
+			/* FIXME: metadata resize support missing */
+			log_error("Resize for %s/%s is not yet supported.",
+				  lp->vg_name, lp->lv_name);
+			return ECMD_FAILED;
+		}
+
+		if (!lv_thin_pool_percent(lv, 0, &percent))
+			return_0;
+		if (!(PERCENT_0 < percent && percent <= PERCENT_100) ||
+		    percent <= policy_threshold)
+			return 1; /* nothing to do */
+	} else {
+		if (!lv_snapshot_percent(lv, &percent))
+			return_0;
+		if (!(PERCENT_0 < percent && percent < PERCENT_100) || percent <= policy_threshold)
+			return 1; /* nothing to do */
+	}
+
+	lp->extents = policy_amount;
+
+	return 1;
+}
+
+/*
+ * FSADM_CMD --dry-run --verbose --force check lv_path
+ * FSADM_CMD --dry-run --verbose --force resize lv_path size
+ */
+int fsadm_cmd(struct cmd_context *cmd,
+		      const struct volume_group *vg,
+		      const struct lvresize_params *lp,
+		      enum fsadm_cmd_e fcmd,
+		      int *status)
+{
+	char lv_path[PATH_MAX];
+	char size_buf[SIZE_BUF];
+	const char *argv[FSADM_CMD_MAX_ARGS + 2];
+	unsigned i = 0;
+
+	argv[i++] = FSADM_CMD;
+
+	if (test_mode())
+		argv[i++] = "--dry-run";
+
+	if (verbose_level() >= _LOG_NOTICE)
+		argv[i++] = "--verbose";
+
+	if (lp->ac_force)
+		argv[i++] = "--force";
+
+	argv[i++] = (fcmd == FSADM_CMD_RESIZE) ? "resize" : "check";
+
+	if (status)
+		*status = -1;
+
+	if (dm_snprintf(lv_path, PATH_MAX, "%s%s/%s", cmd->dev_dir, lp->vg_name,
+			lp->lv_name) < 0) {
+		log_error("Couldn't create LV path for %s", lp->lv_name);
+		return 0;
+	}
+
+	argv[i++] = lv_path;
+
+	if (fcmd == FSADM_CMD_RESIZE) {
+		if (dm_snprintf(size_buf, SIZE_BUF, "%" PRIu64 "K",
+				(uint64_t) lp->extents * vg->extent_size / 2) < 0) {
+			log_error("Couldn't generate new LV size string");
+			return 0;
+		}
+
+		argv[i++] = size_buf;
+	}
+
+	argv[i] = NULL;
+
+	return exec_cmd(cmd, argv, status, 1);
+}
+
+int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
+		     struct lvresize_params *lp, struct dm_list *pvh)
+{
+	struct logical_volume *lv;
+	struct lvinfo info;
+	uint32_t stripesize_extents;
+	uint32_t seg_stripes = 0, seg_stripesize = 0, seg_size;
+	uint32_t seg_mirrors = 0;
+	uint32_t extents_used;
+	uint32_t size_rest;
+	uint32_t pv_extent_count;
+	alloc_policy_t alloc;
+	struct lv_list *lvl;
+	struct lv_segment *seg, *uninitialized_var(mirr_seg);
+	uint32_t seg_extents;
+	uint32_t sz, str;
+	int status;
+
+	/* does LV exist? */
+	if (!(lvl = find_lv_in_vg(vg, lp->lv_name))) {
+		log_error("Logical volume %s not found in volume group %s",
+			  lp->lv_name, lp->vg_name);
+		return ECMD_FAILED;
+	}
+
+	if (lvl->lv->status & (RAID_IMAGE | RAID_META)) {
+		log_error("Cannot resize a RAID %s directly",
+			  (lvl->lv->status & RAID_IMAGE) ? "image" :
+			  "metadata area");
+		return ECMD_FAILED;
+	}
+
+	if (lv_is_raid_with_tracking(lvl->lv)) {
+		log_error("Cannot resize %s while it is tracking a split image",
+			  lvl->lv->name);
+		return ECMD_FAILED;
+	}
+
+	if (lp->ac_stripes) {
+		if (vg->fid->fmt->features & FMT_SEGMENTS)
+			lp->stripes = lp->ac_stripes_value;
+		else
+			log_warn("Varied striping not supported. Ignoring.");
+	}
+
+	if (lp->ac_mirrors) {
+		if (vg->fid->fmt->features & FMT_SEGMENTS)
+			lp->mirrors = lp->ac_mirrors_value;
+		else
+			log_warn("Mirrors not supported. Ignoring.");
+	}
+
+	if (lp->ac_stripesize &&
+	    !_validate_stripesize(cmd, vg, lp))
+		return EINVALID_CMD_LINE;
+
+	lv = lvl->lv;
+
+	if (lp->ac_policy) {
+		if (!lv_is_cow(lv) &&
+		    !lv_is_thin_pool(lv)) {
+			log_error("Policy-based resize is supported only for snapshot and thin pool volumes.");
+			return ECMD_FAILED;
+		}
+		if (!_adjust_policy_params(cmd, lv, lp))
+			return ECMD_FAILED;
+	}
+
+	if (!lv_is_visible(lv)) {
+		log_error("Can't resize internal logical volume %s", lv->name);
+		return ECMD_FAILED;
+	}
+
+	if (lv->status & LOCKED) {
+		log_error("Can't resize locked LV %s", lv->name);
+		return ECMD_FAILED;
+	}
+
+	if (lv->status & CONVERTING) {
+		log_error("Can't resize %s while lvconvert in progress", lv->name);
+		return ECMD_FAILED;
+	}
+
+	alloc = (alloc_policy_t)(lp->ac_alloc)?lp->ac_alloc: lv->alloc;
+
+	/*
+	 * First adjust to an exact multiple of extent size.
+	 * When extending by a relative amount we round that amount up.
+	 * When reducing by a relative amount we remove at most that amount.
+	 * When changing to an absolute size, we round that size up.
+	 */
+	if (lp->size) {
+		if (lp->size % vg->extent_size) {
+			if (lp->sign == SIGN_MINUS)
+				lp->size -= lp->size % vg->extent_size;
+			else
+				lp->size += vg->extent_size -
+				    (lp->size % vg->extent_size);
+
+			log_print_unless_silent("Rounding size to boundary between physical extents: %s",
+						display_size(cmd, lp->size));
+		}
+
+		lp->extents = lp->size / vg->extent_size;
+	}
+
+	switch(lp->percent) {
+		case PERCENT_VG:
+			lp->extents = percent_of_extents(lp->extents, vg->extent_count,
+							 (lp->sign != SIGN_MINUS));
+			break;
+		case PERCENT_FREE:
+			lp->extents = percent_of_extents(lp->extents, vg->free_count,
+							 (lp->sign != SIGN_MINUS));
+			break;
+		case PERCENT_LV:
+			lp->extents = percent_of_extents(lp->extents, lv->le_count,
+							 (lp->sign != SIGN_MINUS));
+			break;
+		case PERCENT_PVS:
+			if (lp->argc) {
+				pv_extent_count = pv_list_extents_free(pvh);
+				lp->extents = percent_of_extents(lp->extents, pv_extent_count,
+								 (lp->sign != SIGN_MINUS));
+			} else
+				lp->extents = percent_of_extents(lp->extents, vg->extent_count,
+								 (lp->sign != SIGN_MINUS));
+			break;
+		case PERCENT_ORIGIN:
+			if (!lv_is_cow(lv)) {
+				log_error("Specified LV does not have an origin LV.");
+				return EINVALID_CMD_LINE;
+			}
+			lp->extents = percent_of_extents(lp->extents, origin_from_cow(lv)->le_count,
+							 (lp->sign != SIGN_MINUS));
+			break;
+		case PERCENT_NONE:
+			break;
+	}
+
+	if (lp->sign == SIGN_PLUS) {
+		if (lp->extents >= (MAX_EXTENT_COUNT - lv->le_count)) {
+			log_error("Unable to extend %s by %u extents, exceeds limit (%u).",
+				  lp->lv_name, lv->le_count, MAX_EXTENT_COUNT);
+			return EINVALID_CMD_LINE;
+		}
+		lp->extents += lv->le_count;
+	}
+
+	if (lp->sign == SIGN_MINUS) {
+		if (lp->extents >= lv->le_count) {
+			log_error("Unable to reduce %s below 1 extent",
+				  lp->lv_name);
+			return EINVALID_CMD_LINE;
+		}
+
+		lp->extents = lv->le_count - lp->extents;
+	}
+
+	if (!lp->extents) {
+		log_error("New size of 0 not permitted");
+		return EINVALID_CMD_LINE;
+	}
+
+	if (lp->extents == lv->le_count) {
+		if (lp->ac_policy)
+			return ECMD_PROCESSED; /* Nothing to do. */
+		if (!lp->resizefs) {
+			log_error("New size (%d extents) matches existing size "
+				  "(%d extents)", lp->extents, lv->le_count);
+			return EINVALID_CMD_LINE;
+		}
+		lp->resize = LV_EXTEND; /* lets pretend zero size extension */
+	}
+
+	seg_size = lp->extents - lv->le_count;
+
+	/* Use segment type of last segment */
+	dm_list_iterate_items(seg, &lv->segments) {
+		lp->segtype = seg->segtype;
+	}
+
+	/* FIXME Support LVs with mixed segment types */
+	if (lp->segtype !=
+		get_segtype_from_string(cmd, (lp->ac_type)?lp->ac_type:lp->segtype->name)) {
+		log_error("VolumeType does not match (%s)", lp->segtype->name);
+		return EINVALID_CMD_LINE;
+	}
+
+	/* If extending, find mirrors of last segment */
+	if ((lp->extents > lv->le_count)) {
+		/*
+		 * Has the user specified that they would like the additional
+		 * extents of a mirror not to have an initial sync?
+		 */
+		if (seg_is_mirrored(first_seg(lv)) && lp->ac_no_sync)
+			lv->status |= LV_NOTSYNCED;
+
+		dm_list_iterate_back_items(mirr_seg, &lv->segments) {
+			if (seg_is_mirrored(mirr_seg))
+				seg_mirrors = lv_mirror_count(mirr_seg->lv);
+			else
+				seg_mirrors = 0;
+			break;
+		}
+
+		if (!lp->ac_mirrors && seg_mirrors) {
+			log_print_unless_silent("Extending %" PRIu32 " mirror images.",
+						seg_mirrors);
+			lp->mirrors = seg_mirrors;
+		}
+		if ((lp->ac_mirrors || seg_mirrors) &&
+		    (lp->mirrors != seg_mirrors)) {
+			log_error("Cannot vary number of mirrors in LV yet.");
+			return EINVALID_CMD_LINE;
+		}
+
+		if (seg_mirrors && !strcmp(mirr_seg->segtype->name, "raid10")) {
+			lp->stripes = mirr_seg->area_count / seg_mirrors;
+			lp->stripe_size = mirr_seg->stripe_size;
+		}
+	}
+
+	/* If extending, find stripes, stripesize & size of last segment */
+	if ((lp->extents > lv->le_count) &&
+	    !(lp->stripes == 1 || (lp->stripes > 1 && lp->stripe_size)) &&
+	    strcmp(mirr_seg->segtype->name, "raid10")) {
+		/* FIXME Don't assume mirror seg will always be AREA_LV */
+		/* FIXME We will need to support resize for metadata LV as well,
+		 *       and data LV could be any type (i.e. mirror)) */
+		dm_list_iterate_items(seg, seg_mirrors ? &seg_lv(mirr_seg, 0)->segments :
+				      lv_is_thin_pool(lv) ? &seg_lv(first_seg(lv), 0)->segments : &lv->segments) {
+			/* Allow through "striped" and RAID 4/5/6/10 */
+			if (!seg_is_striped(seg) &&
+			    (!seg_is_raid(seg) || seg_is_mirrored(seg)) &&
+			    strcmp(seg->segtype->name, "raid10"))
+				continue;
+
+			sz = seg->stripe_size;
+			str = seg->area_count - lp->segtype->parity_devs;
+
+			if ((seg_stripesize && seg_stripesize != sz &&
+			     sz && !lp->stripe_size) ||
+			    (seg_stripes && seg_stripes != str && !lp->stripes)) {
+				log_error("Please specify number of "
+					  "stripes (-i) and stripesize (-I)");
+				return EINVALID_CMD_LINE;
+			}
+
+			seg_stripesize = sz;
+			seg_stripes = str;
+		}
+
+		if (!lp->stripes)
+			lp->stripes = seg_stripes;
+		else if (seg_is_raid(first_seg(lv)) &&
+			 (lp->stripes != seg_stripes)) {
+			log_error("Unable to extend \"%s\" segment type with different number of stripes.", first_seg(lv)->segtype->ops->name(first_seg(lv)));
+			return ECMD_FAILED;
+		}
+
+		if (!lp->stripe_size && lp->stripes > 1) {
+			if (seg_stripesize) {
+				log_print_unless_silent("Using stripesize of last segment %s",
+							display_size(cmd, (uint64_t) seg_stripesize));
+				lp->stripe_size = seg_stripesize;
+			} else {
+				lp->stripe_size =
+					find_config_tree_int(cmd,
+							"metadata/stripesize",
+							DEFAULT_STRIPESIZE) * 2;
+				log_print_unless_silent("Using default stripesize %s",
+							display_size(cmd, (uint64_t) lp->stripe_size));
+			}
+		}
+	}
+
+	/* If reducing, find stripes, stripesize & size of last segment */
+	if (lp->extents < lv->le_count) {
+		extents_used = 0;
+
+		if (lp->stripes || lp->stripe_size || lp->mirrors)
+			log_error("Ignoring stripes, stripesize and mirrors "
+				  "arguments when reducing");
+
+		dm_list_iterate_items(seg, &lv->segments) {
+			seg_extents = seg->len;
+
+			/* Check for underlying stripe sizes */
+			seg_stripes = lvseg_get_stripes(seg, &seg_stripesize);
+
+			if (seg_is_mirrored(seg))
+				seg_mirrors = lv_mirror_count(seg->lv);
+			else
+				seg_mirrors = 0;
+
+			if (lp->extents <= extents_used + seg_extents)
+				break;
+
+			extents_used += seg_extents;
+		}
+
+		seg_size = lp->extents - extents_used;
+		lp->stripe_size = seg_stripesize;
+		lp->stripes = seg_stripes;
+		lp->mirrors = seg_mirrors;
+	}
+
+	if (lp->stripes > 1 && !lp->stripe_size) {
+		log_error("Stripesize for striped segment should not be 0!");
+		return EINVALID_CMD_LINE;
+	}
+
+	if (lp->stripes > 1) {
+		if (lp->stripe_size < STRIPE_SIZE_MIN) {
+			log_error("Invalid stripe size %s",
+				  display_size(cmd, (uint64_t) lp->stripe_size));
+			return EINVALID_CMD_LINE;
+		}
+
+		if (!(stripesize_extents = lp->stripe_size / vg->extent_size))
+			stripesize_extents = 1;
+
+		size_rest = seg_size % (lp->stripes * stripesize_extents);
+		/* Round toward the original size. */
+		if (size_rest &&
+		    ((lp->extents < lv->le_count) ||
+		     !lp->percent ||
+		     (vg->free_count >= (lp->extents - lv->le_count - size_rest +
+					 (lp->stripes * stripesize_extents))))) {
+			log_print_unless_silent("Rounding size (%d extents) up to stripe "
+						"boundary size for segment (%d extents)",
+						lp->extents, lp->extents - size_rest +
+						(lp->stripes * stripesize_extents));
+			lp->extents = lp->extents - size_rest +
+				      (lp->stripes * stripesize_extents);
+		} else if (size_rest) {
+			log_print_unless_silent("Rounding size (%d extents) down to stripe "
+						"boundary size for segment (%d extents)",
+						lp->extents, lp->extents - size_rest);
+			lp->extents = lp->extents - size_rest;
+		}
+	}
+
+	if (lp->extents < lv->le_count) {
+		if (lp->resize == LV_EXTEND) {
+			log_error("New size given (%d extents) not larger "
+				  "than existing size (%d extents)",
+				  lp->extents, lv->le_count);
+			return EINVALID_CMD_LINE;
+		}
+		lp->resize = LV_REDUCE;
+	} else if (lp->extents > lv->le_count) {
+		if (lp->resize == LV_REDUCE) {
+			log_error("New size given (%d extents) not less than "
+				  "existing size (%d extents)", lp->extents,
+				  lv->le_count);
+			return EINVALID_CMD_LINE;
+		}
+		lp->resize = LV_EXTEND;
+	} else if (lp->extents == lv->le_count) {
+		if (lp->ac_policy)
+			return ECMD_PROCESSED; /* Nothing to do. */
+		if (!lp->resizefs) {
+			log_error("New size (%d extents) matches existing size "
+				  "(%d extents)", lp->extents, lv->le_count);
+			return EINVALID_CMD_LINE;
+		}
+		lp->resize = LV_EXTEND;
+	}
+
+	if (lv_is_origin(lv)) {
+		if (lp->resize == LV_REDUCE) {
+			log_error("Snapshot origin volumes cannot be reduced "
+				  "in size yet.");
+			return ECMD_FAILED;
+		}
+
+		if (lv_info(cmd, lv, 0, &info, 0, 0) && info.exists) {
+			log_error("Snapshot origin volumes can be resized "
+				  "only while inactive: try lvchange -an");
+			return ECMD_FAILED;
+		}
+	}
+
+	if (lv_is_thin_pool(lv)) {
+		if (lp->resize == LV_REDUCE) {
+			log_error("Thin pool volumes cannot be reduced in size yet.");
+			return ECMD_FAILED;
+		}
+
+		if (lp->resizefs) {
+			log_warn("Thin pool volumes do not have filesystem.");
+			lp->resizefs = 0;
+		}
+	}
+
+	if ((lp->resize == LV_REDUCE) && lp->argc)
+		log_warn("Ignoring PVs on command line when reducing");
+
+	/* Request confirmation before operations that are often mistakes. */
+	if ((lp->resizefs || (lp->resize == LV_REDUCE)) &&
+	    !_request_confirmation(cmd, vg, lv, lp)) {
+		stack;
+		return ECMD_FAILED;
+	}
+
+	if (lp->resizefs) {
+		if (!lp->nofsck &&
+		    !fsadm_cmd(cmd, vg, lp, FSADM_CMD_CHECK, &status)) {
+			if (status != FSADM_CHECK_FAILS_FOR_MOUNTED) {
+				log_error("Filesystem check failed.");
+				return ECMD_FAILED;
+			}
+			/* some filesystems supports online resize */
+		}
+
+		if ((lp->resize == LV_REDUCE) &&
+		    !fsadm_cmd(cmd, vg, lp, FSADM_CMD_RESIZE, NULL)) {
+			log_error("Filesystem resize failed.");
+			return ECMD_FAILED;
+		}
+	}
+
+	if (!archive(vg)) {
+		stack;
+		return ECMD_FAILED;
+	}
+
+	log_print_unless_silent("%sing logical volume %s to %s",
+				(lp->resize == LV_REDUCE) ? "Reduc" : "Extend",
+				lp->lv_name,
+				display_size(cmd, (uint64_t) lp->extents * vg->extent_size));
+
+	if (lp->resize == LV_REDUCE) {
+		if (!lv_reduce(lv, lv->le_count - lp->extents)) {
+			stack;
+			return ECMD_FAILED;
+		}
+	} else if ((lp->extents > lv->le_count) && /* Ensure we extend */
+		   !lv_extend(lv, lp->segtype,
+			      lp->stripes, lp->stripe_size,
+			      lp->mirrors, first_seg(lv)->region_size,
+			      lp->extents - lv->le_count, NULL,
+			      pvh, alloc)) {
+		stack;
+		return ECMD_FAILED;
+	}
+
+	/* Set the flag to tell commit that we have addl. work todo*/
+	lv->status |= LV_RESIZE;
+
+	return ECMD_PROCESSED;
+}
+
 char *generate_lv_name(struct volume_group *vg, const char *format,
 		       char *buffer, size_t len)
 {
@@ -3145,10 +3810,10 @@ struct logical_volume *lv_create_empty(const char *name,
 
 	if (!lv_set_creation(lv, NULL, 0))
 		goto_bad;
- 
+
 	if (fi->fmt->ops->lv_setup && !fi->fmt->ops->lv_setup(fi, lv))
 		goto_bad;
- 
+
 	return lv;
 bad:
 	dm_pool_free(vg->vgmem, lv);
@@ -3425,7 +4090,7 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 
 	if (!vg_commit(vg))
 		return_0;
- 
+
 	/* format1 */
 	if (format1_reload_required && !resume_lv(cmd, format1_origin)) {
 		log_error("Failed to resume %s.", format1_origin->name);
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index b1cc985..12dbea1 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -26,6 +26,7 @@
 #include "vg.h"
 #include "lv.h"
 #include "lvm-percent.h"
+#include "errors.h"
 
 #define MAX_STRIPES 128U
 #define SECTOR_SHIFT 9L
@@ -409,6 +410,70 @@ struct pvcreate_params {
 	unsigned metadataignore;
 };
 
+#define SIZE_BUF 128
+enum fsadm_cmd_e { FSADM_CMD_CHECK, FSADM_CMD_RESIZE };
+#define FSADM_CMD "fsadm"
+#define FSADM_CMD_MAX_ARGS 6
+#define FSADM_CHECK_FAILS_FOR_MOUNTED 3 /* shell exist status code */
+
+typedef enum {
+	SIGN_NONE = 0,
+	SIGN_PLUS = 1,
+	SIGN_MINUS = 2
+} sign_t;
+
+typedef enum {
+	PERCENT_NONE = 0,
+	PERCENT_VG,
+	PERCENT_FREE,
+	PERCENT_LV,
+	PERCENT_PVS,
+	PERCENT_ORIGIN
+} percent_type_t;
+
+struct lvresize_params {
+	const char *vg_name;
+	const char *lv_name;
+
+	uint32_t stripes;
+	uint32_t stripe_size;
+	uint32_t mirrors;
+
+	const struct segment_type *segtype;
+
+	/* size */
+	uint32_t extents;
+	uint64_t size;
+	sign_t sign;
+	percent_type_t percent;
+
+	enum {
+		LV_ANY = 0,
+		LV_REDUCE = 1,
+		LV_EXTEND = 2
+	} resize;
+
+	int resizefs;
+	int nofsck;
+
+	int argc;
+	char **argv;
+
+	/* Arg counts */
+	unsigned ac_policy;
+	unsigned ac_stripes;
+	uint32_t ac_stripes_value;
+	unsigned ac_mirrors;
+	uint32_t ac_mirrors_value;
+	unsigned ac_stripesize;
+	uint64_t ac_stripesize_value;
+	unsigned ac_alloc;
+	unsigned ac_no_sync;
+	unsigned ac_force;
+
+	const char *ac_type;
+};
+
 struct physical_volume *pvcreate_single(struct cmd_context *cmd,
 					const char *pv_name,
 					struct pvcreate_params *pp,
@@ -455,6 +520,14 @@ int vgs_are_compatible(struct cmd_context *cmd,
 		       struct volume_group *vg_to);
 uint32_t vg_lock_newname(struct cmd_context *cmd, const char *vgname);
 
+int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
+		     struct lvresize_params *lp, struct dm_list *pvh);
+
+int fsadm_cmd(struct cmd_context *cmd,
+		      const struct volume_group *vg,
+		      const struct lvresize_params *lp,
+		      enum fsadm_cmd_e fcmd,
+		      int *status);
 /*
  * Return a handle to VG metadata.
  */
@@ -463,7 +536,7 @@ struct volume_group *vg_read(struct cmd_context *cmd, const char *vg_name,
 struct volume_group *vg_read_for_update(struct cmd_context *cmd, const char *vg_name,
 			 const char *vgid, uint32_t flags);
 
-/* 
+/*
  * Test validity of a VG handle.
  */
 uint32_t vg_read_error(struct volume_group *vg_handle);
diff --git a/lib/metadata/pv_manip.c b/lib/metadata/pv_manip.c
index 4d37a6b..685427a 100644
--- a/lib/metadata/pv_manip.c
+++ b/lib/metadata/pv_manip.c
@@ -207,7 +207,7 @@ int discard_pv_segment(struct pv_segment *peg, uint32_t discard_area_reduction)
 	if (!find_config_tree_bool(peg->pv->fmt->cmd,
 				   "devices/issue_discards", DEFAULT_ISSUE_DISCARDS))
 		return 1;
- 
+
 	/* Missing PV? */
 	if (is_missing_pv(peg->pv) || !peg->pv->dev) {
 		if (!id_write_format(&peg->pv->id, uuid, sizeof(uuid)))
diff --git a/lib/misc/lvm-percent.c b/lib/misc/lvm-percent.c
index 4b73db4..1dafa57 100644
--- a/lib/misc/lvm-percent.c
+++ b/lib/misc/lvm-percent.c
@@ -38,3 +38,8 @@ percent_t make_percent(uint64_t numerator, uint64_t denominator)
     }
 }
 
+uint32_t percent_of_extents(uint32_t percents, uint32_t count, int roundup)
+{
+	return (uint32_t)(((uint64_t)percents * (uint64_t)count +
+			   ((roundup) ? 99 : 0)) / 100);
+}
diff --git a/lib/misc/lvm-percent.h b/lib/misc/lvm-percent.h
index bf30a7e..e0a2eae 100644
--- a/lib/misc/lvm-percent.h
+++ b/lib/misc/lvm-percent.h
@@ -41,4 +41,6 @@ typedef enum {
 float percent_to_float(percent_t v);
 percent_t make_percent(uint64_t numerator, uint64_t denominator);
 
+uint32_t percent_of_extents(uint32_t percents, uint32_t count, int roundup);
+
 #endif
diff --git a/tools/lvresize.c b/tools/lvresize.c
index a32751d..e2ab990 100644
--- a/tools/lvresize.c
+++ b/tools/lvresize.c
@@ -14,174 +14,7 @@
  */
 
 #include "tools.h"
-
-#define SIZE_BUF 128
-
-struct lvresize_params {
-	const char *vg_name;
-	const char *lv_name;
-
-	uint32_t stripes;
-	uint32_t stripe_size;
-	uint32_t mirrors;
-
-	const struct segment_type *segtype;
-
-	/* size */
-	uint32_t extents;
-	uint64_t size;
-	sign_t sign;
-	percent_type_t percent;
-
-	enum {
-		LV_ANY = 0,
-		LV_REDUCE = 1,
-		LV_EXTEND = 2
-	} resize;
-
-	int resizefs;
-	int nofsck;
-
-	int argc;
-	char **argv;
-};
-
-static int _validate_stripesize(struct cmd_context *cmd,
-				const struct volume_group *vg,
-				struct lvresize_params *lp)
-{
-	if (arg_sign_value(cmd, stripesize_ARG, SIGN_NONE) == SIGN_MINUS) {
-		log_error("Stripesize may not be negative.");
-		return 0;
-	}
-
-	if (arg_uint64_value(cmd, stripesize_ARG, 0) > STRIPE_SIZE_LIMIT * 2) {
-		log_error("Stripe size cannot be larger than %s",
-			  display_size(cmd, (uint64_t) STRIPE_SIZE_LIMIT));
-		return 0;
-	}
-
-	if (!(vg->fid->fmt->features & FMT_SEGMENTS))
-		log_warn("Varied stripesize not supported. Ignoring.");
-	else if (arg_uint_value(cmd, stripesize_ARG, 0) > (uint64_t) vg->extent_size * 2) {
-		log_error("Reducing stripe size %s to maximum, "
-			  "physical extent size %s",
-			  display_size(cmd,
-				       (uint64_t) arg_uint_value(cmd, stripesize_ARG, 0)),
-			  display_size(cmd, (uint64_t) vg->extent_size));
-		lp->stripe_size = vg->extent_size;
-	} else
-		lp->stripe_size = arg_uint_value(cmd, stripesize_ARG, 0);
-
-	if (lp->stripe_size & (lp->stripe_size - 1)) {
-		log_error("Stripe size must be power of 2");
-		return 0;
-	}
-
-	return 1;
-}
-
-static int _request_confirmation(struct cmd_context *cmd,
-				 const struct volume_group *vg,
-				 const struct logical_volume *lv,
-				 const struct lvresize_params *lp)
-{
-	struct lvinfo info = { 0 };
-
-	if (!lv_info(cmd, lv, 0, &info, 1, 0) && driver_version(NULL, 0)) {
-		log_error("lv_info failed: aborting");
-		return 0;
-	}
-
-	if (lp->resizefs) {
-		if (!info.exists) {
-			log_error("Logical volume %s must be activated "
-				  "before resizing filesystem", lp->lv_name);
-			return 0;
-		}
-		return 1;
-	}
-
-	if (!info.exists)
-		return 1;
-
-	log_warn("WARNING: Reducing active%s logical volume to %s",
-		 info.open_count ? " and open" : "",
-		 display_size(cmd, (uint64_t) lp->extents * vg->extent_size));
-
-	log_warn("THIS MAY DESTROY YOUR DATA (filesystem etc.)");
-
-	if (!arg_count(cmd, force_ARG)) {
-		if (yes_no_prompt("Do you really want to reduce %s? [y/n]: ",
-				  lp->lv_name) == 'n') {
-			log_error("Logical volume %s NOT reduced", lp->lv_name);
-			return 0;
-		}
-		if (sigint_caught())
-			return 0;
-	}
-
-	return 1;
-}
-
-enum fsadm_cmd_e { FSADM_CMD_CHECK, FSADM_CMD_RESIZE };
-#define FSADM_CMD "fsadm"
-#define FSADM_CMD_MAX_ARGS 6
-#define FSADM_CHECK_FAILS_FOR_MOUNTED 3 /* shell exist status code */
-
-/*
- * FSADM_CMD --dry-run --verbose --force check lv_path
- * FSADM_CMD --dry-run --verbose --force resize lv_path size
- */
-static int _fsadm_cmd(struct cmd_context *cmd,
-		      const struct volume_group *vg,
-		      const struct lvresize_params *lp,
-		      enum fsadm_cmd_e fcmd,
-		      int *status)
-{
-	char lv_path[PATH_MAX];
-	char size_buf[SIZE_BUF];
-	const char *argv[FSADM_CMD_MAX_ARGS + 2];
-	unsigned i = 0;
-
-	argv[i++] = FSADM_CMD;
-
-	if (test_mode())
-		argv[i++] = "--dry-run";
-
-	if (verbose_level() >= _LOG_NOTICE)
-		argv[i++] = "--verbose";
-
-	if (arg_count(cmd, force_ARG))
-		argv[i++] = "--force";
-
-	argv[i++] = (fcmd == FSADM_CMD_RESIZE) ? "resize" : "check";
-
-	if (status)
-		*status = -1;
-
-	if (dm_snprintf(lv_path, PATH_MAX, "%s%s/%s", cmd->dev_dir, lp->vg_name,
-			lp->lv_name) < 0) {
-		log_error("Couldn't create LV path for %s", lp->lv_name);
-		return 0;
-	}
-
-	argv[i++] = lv_path;
-
-	if (fcmd == FSADM_CMD_RESIZE) {
-		if (dm_snprintf(size_buf, SIZE_BUF, "%" PRIu64 "K",
-				(uint64_t) lp->extents * vg->extent_size / 2) < 0) {
-			log_error("Couldn't generate new LV size string");
-			return 0;
-		}
-
-		argv[i++] = size_buf;
-	}
-
-	argv[i] = NULL;
-
-	return exec_cmd(cmd, argv, status, 1);
-}
+#include "metadata.h"
 
 static int _lvresize_params(struct cmd_context *cmd, int argc, char **argv,
 			    struct lvresize_params *lp)
@@ -277,556 +110,44 @@ static int _lvresize_params(struct cmd_context *cmd, int argc, char **argv,
 	lp->argc = argc;
 	lp->argv = argv;
 
-	return 1;
-}
-
-static int _adjust_policy_params(struct cmd_context *cmd,
-				 struct logical_volume *lv, struct lvresize_params *lp)
-{
-	percent_t percent;
-	int policy_threshold, policy_amount;
-
-	if (lv_is_thin_pool(lv)) {
-		policy_threshold =
-			find_config_tree_int(cmd, "activation/thin_pool_autoextend_threshold",
-					     DEFAULT_THIN_POOL_AUTOEXTEND_THRESHOLD) * PERCENT_1;
-		policy_amount =
-			find_config_tree_int(cmd, "activation/thin_pool_autoextend_percent",
-					     DEFAULT_THIN_POOL_AUTOEXTEND_PERCENT);
-		if (!policy_amount && policy_threshold < PERCENT_100)
-                        return 0;
-	} else {
-		policy_threshold =
-			find_config_tree_int(cmd, "activation/snapshot_autoextend_threshold",
-					     DEFAULT_SNAPSHOT_AUTOEXTEND_THRESHOLD) * PERCENT_1;
-		policy_amount =
-			find_config_tree_int(cmd, "activation/snapshot_autoextend_percent",
-					     DEFAULT_SNAPSHOT_AUTOEXTEND_PERCENT);
-	}
-
-	if (policy_threshold >= PERCENT_100)
-		return 1; /* nothing to do */
-
-	if (lv_is_thin_pool(lv)) {
-		if (!lv_thin_pool_percent(lv, 1, &percent))
-			return_0;
-		if (percent > policy_threshold) {
-			/* FIXME: metadata resize support missing */
-			log_error("Resize for %s/%s is not yet supported.",
-				  lp->vg_name, lp->lv_name);
-			return ECMD_FAILED;
-		}
-
-		if (!lv_thin_pool_percent(lv, 0, &percent))
-			return_0;
-		if (!(PERCENT_0 < percent && percent <= PERCENT_100) ||
-		    percent <= policy_threshold)
-			return 1; /* nothing to do */
+	lp->ac_policy = arg_count(cmd, use_policies_ARG);
+	lp->ac_stripes = arg_count(cmd, stripes_ARG);
+	if (lp->ac_stripes) {
+		lp->ac_stripes_value = arg_uint_value(cmd, stripes_ARG, 1);
 	} else {
-		if (!lv_snapshot_percent(lv, &percent))
-			return_0;
-		if (!(PERCENT_0 < percent && percent < PERCENT_100) || percent <= policy_threshold)
-			return 1; /* nothing to do */
+		lp->ac_stripes_value = 0;
 	}
 
-	lp->extents = policy_amount;
-
-	return 1;
-}
-
-static uint32_t lvseg_get_stripes(struct lv_segment *seg, uint32_t *stripesize)
-{
-	uint32_t s;
-	struct lv_segment *seg_mirr;
-
-	/* If segment mirrored, check if images are striped */
-	if (seg_is_mirrored(seg))
-		for (s = 0; s < seg->area_count; s++) {
-			if (seg_type(seg, s) != AREA_LV)
-				continue;
-			seg_mirr = first_seg(seg_lv(seg, s));
-
-			if (seg_is_striped(seg_mirr)) {
-				seg = seg_mirr;
-				break;
-			}
-		}
-
+	lp->ac_mirrors = arg_count(cmd, mirrors_ARG);
 
-	if (seg_is_striped(seg)) {
-		*stripesize = seg->stripe_size;
-		return seg->area_count;
-	}
-
-	*stripesize = 0;
-	return 0;
-}
-
-static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
-		     struct lvresize_params *lp)
-{
-	struct logical_volume *lv;
-	struct lvinfo info;
-	uint32_t stripesize_extents;
-	uint32_t seg_stripes = 0, seg_stripesize = 0, seg_size;
-	uint32_t seg_mirrors = 0;
-	uint32_t extents_used;
-	uint32_t size_rest;
-	uint32_t pv_extent_count;
-	alloc_policy_t alloc;
-	struct lv_list *lvl;
-	struct lv_segment *seg, *uninitialized_var(mirr_seg);
-	uint32_t seg_extents;
-	uint32_t sz, str;
-	int status;
-	struct dm_list *pvh = NULL;
-	int use_policy = arg_count(cmd, use_policies_ARG);
-
-	/* does LV exist? */
-	if (!(lvl = find_lv_in_vg(vg, lp->lv_name))) {
-		log_error("Logical volume %s not found in volume group %s",
-			  lp->lv_name, lp->vg_name);
-		return ECMD_FAILED;
-	}
-
-	if (lvl->lv->status & (RAID_IMAGE | RAID_META)) {
-		log_error("Cannot resize a RAID %s directly",
-			  (lvl->lv->status & RAID_IMAGE) ? "image" :
-			  "metadata area");
-		return ECMD_FAILED;
-	}
-
-	if (lv_is_raid_with_tracking(lvl->lv)) {
-		log_error("Cannot resize %s while it is tracking a split image",
-			  lvl->lv->name);
-		return ECMD_FAILED;
-	}
-
-	if (arg_count(cmd, stripes_ARG)) {
-		if (vg->fid->fmt->features & FMT_SEGMENTS)
-			lp->stripes = arg_uint_value(cmd, stripes_ARG, 1);
-		else
-			log_warn("Varied striping not supported. Ignoring.");
-	}
-
-	if (arg_count(cmd, mirrors_ARG)) {
-		if (vg->fid->fmt->features & FMT_SEGMENTS)
-			lp->mirrors = arg_uint_value(cmd, mirrors_ARG, 1) + 1;
-		else
-			log_warn("Mirrors not supported. Ignoring.");
+	if (lp->ac_mirrors) {
 		if (arg_sign_value(cmd, mirrors_ARG, SIGN_NONE) == SIGN_MINUS) {
 			log_error("Mirrors argument may not be negative");
-			return EINVALID_CMD_LINE;
-		}
-	}
-
-	if (arg_count(cmd, stripesize_ARG) &&
-	    !_validate_stripesize(cmd, vg, lp))
-		return EINVALID_CMD_LINE;
-
-	lv = lvl->lv;
-
-	if (use_policy) {
-		if (!lv_is_cow(lv) &&
-		    !lv_is_thin_pool(lv)) {
-			log_error("Policy-based resize is supported only for snapshot and thin pool volumes.");
-			return ECMD_FAILED;
-		}
-		if (!_adjust_policy_params(cmd, lv, lp))
-			return ECMD_FAILED;
-	}
-
-	if (!lv_is_visible(lv)) {
-		log_error("Can't resize internal logical volume %s", lv->name);
-		return ECMD_FAILED;
-	}
-
-	if (lv->status & LOCKED) {
-		log_error("Can't resize locked LV %s", lv->name);
-		return ECMD_FAILED;
-	}
-
-	if (lv->status & CONVERTING) {
-		log_error("Can't resize %s while lvconvert in progress", lv->name);
-		return ECMD_FAILED;
-	}
-
-	alloc = (alloc_policy_t) arg_uint_value(cmd, alloc_ARG, lv->alloc);
-
-	/*
-	 * First adjust to an exact multiple of extent size.
-	 * When extending by a relative amount we round that amount up.
-	 * When reducing by a relative amount we remove at most that amount.
-	 * When changing to an absolute size, we round that size up.
-	 */
-	if (lp->size) {
-		if (lp->size % vg->extent_size) {
-			if (lp->sign == SIGN_MINUS)
-				lp->size -= lp->size % vg->extent_size;
-			else
-				lp->size += vg->extent_size -
-				    (lp->size % vg->extent_size);
-
-			log_print_unless_silent("Rounding size to boundary between physical extents: %s",
-						display_size(cmd, lp->size));
-		}
-
-		lp->extents = lp->size / vg->extent_size;
-	}
-
-	if (!(pvh = lp->argc ? create_pv_list(cmd->mem, vg, lp->argc,
-						     lp->argv, 1) : &vg->pvs)) {
-		stack;
-		return ECMD_FAILED;
-	}
-
-	switch(lp->percent) {
-		case PERCENT_VG:
-			lp->extents = percent_of_extents(lp->extents, vg->extent_count,
-							 (lp->sign != SIGN_MINUS));
-			break;
-		case PERCENT_FREE:
-			lp->extents = percent_of_extents(lp->extents, vg->free_count,
-							 (lp->sign != SIGN_MINUS));
-			break;
-		case PERCENT_LV:
-			lp->extents = percent_of_extents(lp->extents, lv->le_count,
-							 (lp->sign != SIGN_MINUS));
-			break;
-		case PERCENT_PVS:
-			if (lp->argc) {
-				pv_extent_count = pv_list_extents_free(pvh);
-				lp->extents = percent_of_extents(lp->extents, pv_extent_count,
-								 (lp->sign != SIGN_MINUS));
-			} else
-				lp->extents = percent_of_extents(lp->extents, vg->extent_count,
-								 (lp->sign != SIGN_MINUS));
-			break;
-		case PERCENT_ORIGIN:
-			if (!lv_is_cow(lv)) {
-				log_error("Specified LV does not have an origin LV.");
-				return EINVALID_CMD_LINE;
-			}
-			lp->extents = percent_of_extents(lp->extents, origin_from_cow(lv)->le_count,
-							 (lp->sign != SIGN_MINUS));
-			break;
-		case PERCENT_NONE:
-			break;
-	}
-
-	if (lp->sign == SIGN_PLUS) {
-		if (lp->extents >= (MAX_EXTENT_COUNT - lv->le_count)) {
-			log_error("Unable to extend %s by %u extents, exceeds limit (%u).",
-				  lp->lv_name, lv->le_count, MAX_EXTENT_COUNT);
-			return EINVALID_CMD_LINE;
-		}
-		lp->extents += lv->le_count;
-	}
-
-	if (lp->sign == SIGN_MINUS) {
-		if (lp->extents >= lv->le_count) {
-			log_error("Unable to reduce %s below 1 extent",
-				  lp->lv_name);
-			return EINVALID_CMD_LINE;
-		}
-
-		lp->extents = lv->le_count - lp->extents;
-	}
-
-	if (!lp->extents) {
-		log_error("New size of 0 not permitted");
-		return EINVALID_CMD_LINE;
-	}
-
-	if (lp->extents == lv->le_count) {
-		if (use_policy)
-			return ECMD_PROCESSED; /* Nothing to do. */
-		if (!lp->resizefs) {
-			log_error("New size (%d extents) matches existing size "
-				  "(%d extents)", lp->extents, lv->le_count);
-			return EINVALID_CMD_LINE;
-		}
-		lp->resize = LV_EXTEND; /* lets pretend zero size extension */
-	}
-
-	seg_size = lp->extents - lv->le_count;
-
-	/* Use segment type of last segment */
-	dm_list_iterate_items(seg, &lv->segments) {
-		lp->segtype = seg->segtype;
-	}
-
-	/* FIXME Support LVs with mixed segment types */
-	if (lp->segtype != get_segtype_from_string(cmd, arg_str_value(cmd, type_ARG,
-								      lp->segtype->name))) {
-		log_error("VolumeType does not match (%s)", lp->segtype->name);
-		return EINVALID_CMD_LINE;
-	}
-
-	/* If extending, find mirrors of last segment */
-	if ((lp->extents > lv->le_count)) {
-		/*
-		 * Has the user specified that they would like the additional
-		 * extents of a mirror not to have an initial sync?
-		 */
-		if (seg_is_mirrored(first_seg(lv)) && arg_count(cmd, nosync_ARG))
-			lv->status |= LV_NOTSYNCED;
-
-		dm_list_iterate_back_items(mirr_seg, &lv->segments) {
-			if (seg_is_mirrored(mirr_seg))
-				seg_mirrors = lv_mirror_count(mirr_seg->lv);
-			else
-				seg_mirrors = 0;
-			break;
-		}
-
-		if (!arg_count(cmd, mirrors_ARG) && seg_mirrors) {
-			log_print_unless_silent("Extending %" PRIu32 " mirror images.",
-						seg_mirrors);
-			lp->mirrors = seg_mirrors;
-		}
-		if ((arg_count(cmd, mirrors_ARG) || seg_mirrors) &&
-		    (lp->mirrors != seg_mirrors)) {
-			log_error("Cannot vary number of mirrors in LV yet.");
-			return EINVALID_CMD_LINE;
-		}
-
-		if (seg_mirrors && !strcmp(mirr_seg->segtype->name, "raid10")) {
-			lp->stripes = mirr_seg->area_count / seg_mirrors;
-			lp->stripe_size = mirr_seg->stripe_size;
-		}
-	}
-
-	/* If extending, find stripes, stripesize & size of last segment */
-	if ((lp->extents > lv->le_count) &&
-	    !(lp->stripes == 1 || (lp->stripes > 1 && lp->stripe_size)) &&
-	    strcmp(mirr_seg->segtype->name, "raid10")) {
-		/* FIXME Don't assume mirror seg will always be AREA_LV */
-		/* FIXME We will need to support resize for metadata LV as well,
-		 *       and data LV could be any type (i.e. mirror)) */
-		dm_list_iterate_items(seg, seg_mirrors ? &seg_lv(mirr_seg, 0)->segments :
-				      lv_is_thin_pool(lv) ? &seg_lv(first_seg(lv), 0)->segments : &lv->segments) {
-			/* Allow through "striped" and RAID 4/5/6/10 */
-			if (!seg_is_striped(seg) &&
-			    (!seg_is_raid(seg) || seg_is_mirrored(seg)) &&
-			    strcmp(seg->segtype->name, "raid10"))
-				continue;
-
-			sz = seg->stripe_size;
-			str = seg->area_count - lp->segtype->parity_devs;
-
-			if ((seg_stripesize && seg_stripesize != sz &&
-			     sz && !lp->stripe_size) ||
-			    (seg_stripes && seg_stripes != str && !lp->stripes)) {
-				log_error("Please specify number of "
-					  "stripes (-i) and stripesize (-I)");
-				return EINVALID_CMD_LINE;
-			}
-
-			seg_stripesize = sz;
-			seg_stripes = str;
-		}
-
-		if (!lp->stripes)
-			lp->stripes = seg_stripes;
-		else if (seg_is_raid(first_seg(lv)) &&
-			 (lp->stripes != seg_stripes)) {
-			log_error("Unable to extend \"%s\" segment type with different number of stripes.", first_seg(lv)->segtype->ops->name(first_seg(lv)));
-			return ECMD_FAILED;
-		}
-
-		if (!lp->stripe_size && lp->stripes > 1) {
-			if (seg_stripesize) {
-				log_print_unless_silent("Using stripesize of last segment %s",
-							display_size(cmd, (uint64_t) seg_stripesize));
-				lp->stripe_size = seg_stripesize;
-			} else {
-				lp->stripe_size =
-					find_config_tree_int(cmd,
-							"metadata/stripesize",
-							DEFAULT_STRIPESIZE) * 2;
-				log_print_unless_silent("Using default stripesize %s",
-							display_size(cmd, (uint64_t) lp->stripe_size));
-			}
-		}
-	}
-
-	/* If reducing, find stripes, stripesize & size of last segment */
-	if (lp->extents < lv->le_count) {
-		extents_used = 0;
-
-		if (lp->stripes || lp->stripe_size || lp->mirrors)
-			log_error("Ignoring stripes, stripesize and mirrors "
-				  "arguments when reducing");
-
-		dm_list_iterate_items(seg, &lv->segments) {
-			seg_extents = seg->len;
-
-			/* Check for underlying stripe sizes */
-			seg_stripes = lvseg_get_stripes(seg, &seg_stripesize);
-
-			if (seg_is_mirrored(seg))
-				seg_mirrors = lv_mirror_count(seg->lv);
-			else
-				seg_mirrors = 0;
-
-			if (lp->extents <= extents_used + seg_extents)
-				break;
-
-			extents_used += seg_extents;
-		}
-
-		seg_size = lp->extents - extents_used;
-		lp->stripe_size = seg_stripesize;
-		lp->stripes = seg_stripes;
-		lp->mirrors = seg_mirrors;
-	}
-
-	if (lp->stripes > 1 && !lp->stripe_size) {
-		log_error("Stripesize for striped segment should not be 0!");
-		return EINVALID_CMD_LINE;
-	}
-
-	if (lp->stripes > 1) {
-		if (lp->stripe_size < STRIPE_SIZE_MIN) {
-			log_error("Invalid stripe size %s",
-				  display_size(cmd, (uint64_t) lp->stripe_size));
-			return EINVALID_CMD_LINE;
-		}
-
-		if (!(stripesize_extents = lp->stripe_size / vg->extent_size))
-			stripesize_extents = 1;
-
-		size_rest = seg_size % (lp->stripes * stripesize_extents);
-		/* Round toward the original size. */
-		if (size_rest &&
-		    ((lp->extents < lv->le_count) ||
-		     !lp->percent ||
-		     (vg->free_count >= (lp->extents - lv->le_count - size_rest +
-					 (lp->stripes * stripesize_extents))))) {
-			log_print_unless_silent("Rounding size (%d extents) up to stripe "
-						"boundary size for segment (%d extents)",
-						lp->extents, lp->extents - size_rest +
-						(lp->stripes * stripesize_extents));
-			lp->extents = lp->extents - size_rest +
-				      (lp->stripes * stripesize_extents);
-		} else if (size_rest) {
-			log_print_unless_silent("Rounding size (%d extents) down to stripe "
-						"boundary size for segment (%d extents)",
-						lp->extents, lp->extents - size_rest);
-			lp->extents = lp->extents - size_rest;
-		}
-	}
-
-	if (lp->extents < lv->le_count) {
-		if (lp->resize == LV_EXTEND) {
-			log_error("New size given (%d extents) not larger "
-				  "than existing size (%d extents)",
-				  lp->extents, lv->le_count);
-			return EINVALID_CMD_LINE;
-		}
-		lp->resize = LV_REDUCE;
-	} else if (lp->extents > lv->le_count) {
-		if (lp->resize == LV_REDUCE) {
-			log_error("New size given (%d extents) not less than "
-				  "existing size (%d extents)", lp->extents,
-				  lv->le_count);
-			return EINVALID_CMD_LINE;
-		}
-		lp->resize = LV_EXTEND;
-	} else if (lp->extents == lv->le_count) {
-		if (use_policy)
-			return ECMD_PROCESSED; /* Nothing to do. */
-		if (!lp->resizefs) {
-			log_error("New size (%d extents) matches existing size "
-				  "(%d extents)", lp->extents, lv->le_count);
-			return EINVALID_CMD_LINE;
-		}
-		lp->resize = LV_EXTEND;
-	}
-
-	if (lv_is_origin(lv)) {
-		if (lp->resize == LV_REDUCE) {
-			log_error("Snapshot origin volumes cannot be reduced "
-				  "in size yet.");
-			return ECMD_FAILED;
-		}
-
-		if (lv_info(cmd, lv, 0, &info, 0, 0) && info.exists) {
-			log_error("Snapshot origin volumes can be resized "
-				  "only while inactive: try lvchange -an");
-			return ECMD_FAILED;
-		}
-	}
-
-	if (lv_is_thin_pool(lv)) {
-		if (lp->resize == LV_REDUCE) {
-			log_error("Thin pool volumes cannot be reduced in size yet.");
-			return ECMD_FAILED;
-		}
-
-		if (lp->resizefs) {
-			log_warn("Thin pool volumes do not have filesystem.");
-			lp->resizefs = 0;
+			return 0;
 		}
-	}
-
-	if ((lp->resize == LV_REDUCE) && lp->argc)
-		log_warn("Ignoring PVs on command line when reducing");
 
-	/* Request confirmation before operations that are often mistakes. */
-	if ((lp->resizefs || (lp->resize == LV_REDUCE)) &&
-	    !_request_confirmation(cmd, vg, lv, lp)) {
-		stack;
-		return ECMD_FAILED;
+		lp->ac_mirrors_value = arg_uint_value(cmd, mirrors_ARG, 1) + 1;
+	} else {
+		lp->ac_mirrors_value = 0;
 	}
 
-	if (lp->resizefs) {
-		if (!lp->nofsck &&
-		    !_fsadm_cmd(cmd, vg, lp, FSADM_CMD_CHECK, &status)) {
-			if (status != FSADM_CHECK_FAILS_FOR_MOUNTED) {
-				log_error("Filesystem check failed.");
-				return ECMD_FAILED;
-			}
-			/* some filesystems supports online resize */
+	lp->ac_stripesize = arg_count(cmd, stripesize_ARG);
+	if (lp->ac_stripesize) {
+		if (arg_sign_value(cmd, stripesize_ARG, SIGN_NONE) == SIGN_MINUS) {
+			log_error("Stripesize may not be negative.");
+			return 0;
 		}
 
-		if ((lp->resize == LV_REDUCE) &&
-		    !_fsadm_cmd(cmd, vg, lp, FSADM_CMD_RESIZE, NULL)) {
-			log_error("Filesystem resize failed.");
-			return ECMD_FAILED;
-		}
+		lp->ac_stripesize_value = arg_uint64_value(cmd, stripesize_ARG, 0);
 	}
 
-	if (!archive(vg)) {
-		stack;
-		return ECMD_FAILED;
-	}
-
-	log_print_unless_silent("%sing logical volume %s to %s",
-				(lp->resize == LV_REDUCE) ? "Reduc" : "Extend",
-				lp->lv_name,
-				display_size(cmd, (uint64_t) lp->extents * vg->extent_size));
+	lp->ac_no_sync = arg_count(cmd, nosync_ARG);
+	lp->ac_alloc = arg_uint_value(cmd, alloc_ARG, 0);
 
-	if (lp->resize == LV_REDUCE) {
-		if (!lv_reduce(lv, lv->le_count - lp->extents)) {
-			stack;
-			return ECMD_FAILED;
-		}
-	} else if ((lp->extents > lv->le_count) && /* Ensure we extend */
-		   !lv_extend(lv, lp->segtype,
-			      lp->stripes, lp->stripe_size,
-			      lp->mirrors, first_seg(lv)->region_size,
-			      lp->extents - lv->le_count, NULL,
-			      pvh, alloc)) {
-		stack;
-		return ECMD_FAILED;
-	}
+	lp->ac_type = arg_str_value(cmd, type_ARG, NULL);
+	lp->ac_force = arg_count(cmd, force_ARG);
 
-	/* Set the flag to tell commit that we have addl. work todo*/
-	lv->status |= LV_RESIZE;
-
-	return ECMD_PROCESSED;
+	return 1;
 }
 
 int lvresize(struct cmd_context *cmd, int argc, char **argv)
@@ -834,6 +155,7 @@ int lvresize(struct cmd_context *cmd, int argc, char **argv)
 	struct lvresize_params lp = { 0 };
 	struct volume_group *vg;
 	int r;
+	struct dm_list *pvh = NULL;
 
 	if (!_lvresize_params(cmd, argc, argv, &lp))
 		return EINVALID_CMD_LINE;
@@ -846,7 +168,14 @@ int lvresize(struct cmd_context *cmd, int argc, char **argv)
 		return ECMD_FAILED;
 	}
 
-	r = _lvresize(cmd, vg, &lp);
+	if (!(pvh = lp.argc ? create_pv_list(cmd->mem, vg, lp.argc,
+						     lp.argv, 1) : &vg->pvs)) {
+		stack;
+		r = ECMD_FAILED;
+		goto out;
+	}
+
+	r = _lvresize(cmd, vg, &lp, pvh);
 
 	if (ECMD_PROCESSED == r) {
 		if (!vg_write(vg)) {
@@ -863,7 +192,7 @@ int lvresize(struct cmd_context *cmd, int argc, char **argv)
 		log_print_unless_silent("Logical volume %s successfully resized", lp.lv_name);
 
 		if (lp.resizefs && (lp.resize == LV_EXTEND) &&
-			!_fsadm_cmd(cmd, vg, &lp, FSADM_CMD_RESIZE, NULL)) {
+			!fsadm_cmd(cmd, vg, &lp, FSADM_CMD_RESIZE, NULL)) {
 			r = ECMD_FAILED;
 		}
 	}
diff --git a/tools/toollib.c b/tools/toollib.c
index 62f59d8..aea5ee0 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -133,7 +133,7 @@ int process_each_lv_in_vg(struct cmd_context *cmd,
 			continue;
 
 		/*
-		 * Only let hidden LVs through it --all was used or the LVs 
+		 * Only let hidden LVs through it --all was used or the LVs
 		 * were specifically named on the command line.
 		 */
 		if (!lvargs_supplied && !lv_is_visible(lvl->lv) && !arg_count(cmd, all_ARG))
@@ -1625,8 +1625,10 @@ int change_tag(struct cmd_context *cmd, struct volume_group *vg,
 }
 
 /* Return percents of extents and avoid overflow, with optional roundup */
+/*
 uint32_t percent_of_extents(uint32_t percents, uint32_t count, int roundup)
 {
 	return (uint32_t)(((uint64_t)percents * (uint64_t)count +
 			   ((roundup) ? 99 : 0)) / 100);
 }
+*/
diff --git a/tools/tools.h b/tools/tools.h
index a3ad9fd..9f3eef3 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
@@ -34,7 +34,7 @@
 #include "dev-cache.h"
 #include "device.h"
 #include "display.h"
-#include "errors.h"
+/*#include "errors.h"*/
 #include "filter.h"
 #include "filter-composite.h"
 #include "filter-persistent.h"
@@ -73,21 +73,6 @@ enum {
 #undef arg
 };
 
-typedef enum {
-	SIGN_NONE = 0,
-	SIGN_PLUS = 1,
-	SIGN_MINUS = 2
-} sign_t;
-
-typedef enum {
-	PERCENT_NONE = 0,
-	PERCENT_VG,
-	PERCENT_FREE,
-	PERCENT_LV,
-	PERCENT_PVS,
-	PERCENT_ORIGIN
-} percent_type_t;
-
 #define ARG_COUNTABLE 0x00000001	/* E.g. -vvvv */
 #define ARG_GROUPABLE 0x00000002	/* E.g. --addtag */
 
@@ -164,8 +149,8 @@ unsigned arg_count(const struct cmd_context *cmd, int a);
 unsigned arg_is_set(const struct cmd_context *cmd, int a);
 const char *arg_value(struct cmd_context *cmd, int a);
 const char *arg_str_value(struct cmd_context *cmd, int a, const char *def);
-int32_t arg_int_value(struct cmd_context *cmd, int a, const int32_t def); 
-int32_t first_grouped_arg_int_value(struct cmd_context *cmd, int a, const int32_t def); 
+int32_t arg_int_value(struct cmd_context *cmd, int a, const int32_t def);
+int32_t first_grouped_arg_int_value(struct cmd_context *cmd, int a, const int32_t def);
 uint32_t arg_uint_value(struct cmd_context *cmd, int a, const uint32_t def);
 int64_t arg_int64_value(struct cmd_context *cmd, int a, const int64_t def);
 uint64_t arg_uint64_value(struct cmd_context *cmd, int a, const uint64_t def);
@@ -177,7 +162,7 @@ int arg_count_increment(struct cmd_context *cmd, int a);
 unsigned grouped_arg_count(const struct arg_values *av, int a);
 unsigned grouped_arg_is_set(const struct arg_values *av, int a);
 const char *grouped_arg_str_value(const struct arg_values *av, int a, const char *def);
-int32_t grouped_arg_int_value(const struct arg_values *av, int a, const int32_t def); 
+int32_t grouped_arg_int_value(const struct arg_values *av, int a, const int32_t def);
 
 const char *command_name(struct cmd_context *cmd);
 
@@ -187,7 +172,7 @@ int lvconvert_poll(struct cmd_context *cmd, struct logical_volume *lv, unsigned
 int mirror_remove_missing(struct cmd_context *cmd,
 			  struct logical_volume *lv, int force);
 
-uint32_t percent_of_extents(uint32_t percents, uint32_t count, int roundup);
+/* uint32_t percent_of_extents(uint32_t percents, uint32_t count, int roundup); */
 
 int vgchange_activate(struct cmd_context *cmd, struct volume_group *vg,
 		       activation_change_t activate);
-- 
1.7.1


