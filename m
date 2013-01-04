From: Tony Asleson <tasleson@redhat.com>
Date: Fri,  4 Jan 2013 16:51:47 -0600
Subject: [PATCH 2/3] lvm2app: Implementation of lv resize
In-Reply-To: <1357339908-14608-1-git-send-email-tasleson@redhat.com>
References: <1357339908-14608-1-git-send-email-tasleson@redhat.com>
Message-ID: <1357339908-14608-2-git-send-email-tasleson@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

When re-sizing a LV with the command line, after the re-size
occurs the code used to do a vg_write and then a number of
operations before and after the commit.  As the API requires
the ability to have the re-size done independantly of the
write and commit a flag was added so that when we go through
vg_commit we will do the same required steps to commit the
lv size change regardless if it was done through the command
line or the API.

The core functionality was moved to lv_manip so that the
command line and the API could call it.  To make this work
all the argument parsing functions are being done in
tools/lv_resize.c and all the parameters are expected to be
passed in with the struct lvresize_params.

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 lib/format_text/flags.c          |   1 +
 lib/metadata/lv_manip.c          | 665 ++++++++++++++++++++++++++++++++
 lib/metadata/metadata-exported.h |  76 +++-
 lib/metadata/metadata.c          |  87 ++++-
 lib/misc/lvm-percent.c           |   5 +
 lib/misc/lvm-percent.h           |   2 +
 liblvm/lvm2app.h                 |   2 -
 liblvm/lvm_lv.c                  |  19 +-
 tools/lvresize.c                 | 811 +++------------------------------------
 tools/toollib.c                  |   6 -
 tools/tools.h                    |  17 -
 11 files changed, 902 insertions(+), 789 deletions(-)

diff --git a/lib/format_text/flags.c b/lib/format_text/flags.c
index a3a3d0e..4edf7e1 100644
--- a/lib/format_text/flags.c
+++ b/lib/format_text/flags.c
@@ -77,6 +77,7 @@ static const struct flag _lv_flags[] = {
 	{THIN_POOL, NULL, 0},
 	{THIN_POOL_DATA, NULL, 0},
 	{THIN_POOL_METADATA, NULL, 0},
+	{LV_RESIZE, NULL, 0},
 	{0, NULL, 0}
 };
 
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 35a75ff..6fcf6f2 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -27,6 +27,7 @@
 #include "activate.h"
 #include "str_list.h"
 #include "defaults.h"
+#include "lvm-exec.h"
 
 typedef enum {
 	PREFERRED,
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
+int lv_resize(struct cmd_context *cmd, struct volume_group *vg,
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
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 4af9edf..ca289f4 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -26,6 +26,7 @@
 #include "vg.h"
 #include "lv.h"
 #include "lvm-percent.h"
+#include "errors.h"
 
 #define MAX_STRIPES 128U
 #define SECTOR_SHIFT 9L
@@ -62,8 +63,9 @@
 #define MIRROR_LOG		UINT64_C(0x00020000)	/* LV */
 #define MIRROR_IMAGE		UINT64_C(0x00040000)	/* LV */
 
-#define LV_NOTSYNCED		UINT64_C(0x00080000)	/* LV */
+#define LV_NOTSYNCED	UINT64_C(0x00080000)	/* LV */
 #define LV_REBUILD		UINT64_C(0x00100000)	/* LV */
+#define LV_RESIZE		UINT64_C(0x00200000)	/* LV - internal use only */
 //#define PRECOMMITTED		UINT64_C(0x00200000)	/* VG - internal use only */
 #define CONVERTING		UINT64_C(0x00400000)	/* LV */
 
@@ -408,6 +410,70 @@ struct pvcreate_params {
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
@@ -454,6 +520,14 @@ int vgs_are_compatible(struct cmd_context *cmd,
 		       struct volume_group *vg_to);
 uint32_t vg_lock_newname(struct cmd_context *cmd, const char *vgname);
 
+int lv_resize(struct cmd_context *cmd, struct volume_group *vg,
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
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 807d06a..6f2bfec 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2696,6 +2696,80 @@ static int _vg_commit_mdas(struct volume_group *vg)
 	return cache_updated;
 }
 
+/* Check to see if we have a lv that was re-sized, if yes then suspend the lv */
+static int _pre_lv_resize(struct volume_group *vg)
+{
+	struct lv_list *lvl = NULL;
+	struct logical_volume *lock_lv = NULL;
+
+	dm_list_iterate_items(lvl, &vg->lvs) {
+		if (lvl->lv->status & LV_RESIZE) {
+			if (lv_is_cow(lvl->lv))
+				lock_lv = origin_from_cow(lvl->lv);
+			else
+				lock_lv = lvl->lv;
+
+			if (!suspend_lv(vg->cmd, lock_lv)) {
+				log_error("Failed to suspend %s", lvl->lv->name);
+				vg_revert(vg);
+				backup(vg);
+				return 0;
+			}
+		}
+	}
+	return 1;
+}
+
+/* If we have lv resize then resume the suspended lv */
+static int _post_lv_resize(struct volume_group *vg, int ok)
+{
+	struct lv_list *lvl = NULL;
+	struct logical_volume *lock_lv = NULL;
+
+	dm_list_iterate_items(lvl, &vg->lvs) {
+		if (lvl->lv->status & LV_RESIZE) {
+
+			/* Clear the flag */
+			lvl->lv->status &= ~LV_RESIZE;
+
+			if (lv_is_cow(lvl->lv))
+				lock_lv = origin_from_cow(lvl->lv);
+			else
+				lock_lv = lvl->lv;
+
+			if (!resume_lv(vg->cmd, lock_lv)) {
+				log_error("Problem reactivating %s", lvl->lv->name);
+				backup(vg);
+				return 0;
+			}
+
+			backup(vg);
+
+			/* We could have been called after an error has occurred, in that
+			   case we will not do the next step */
+			if (ok) {
+
+				/*
+				* Update lvm pool metadata (drop messages) if the pool has been
+				* resumed and do a pool active/deactivate in other case.
+				*
+				* Note: Active thin pool can be waiting for resize.
+				*
+				* FIXME: Activate only when thin volume is active
+				*/
+				if (lv_is_thin_pool(lvl->lv) &&
+					!update_pool_lv(lvl->lv, !lv_is_active(lvl->lv))) {
+					stack;
+					return 0;
+				}
+			}
+		}
+	}
+
+	return 1;
+}
+
+
 /* Commit pending changes */
 int vg_commit(struct volume_group *vg)
 {
@@ -2707,9 +2781,15 @@ int vg_commit(struct volume_group *vg)
 		return cache_updated;
 	}
 
-	if (!lvmetad_vg_update(vg))
+	if (!_pre_lv_resize(vg))
 		return 0;
 
+	if (!lvmetad_vg_update(vg)) {
+		cache_updated = 0;
+		goto out;
+	}
+
+
 	cache_updated = _vg_commit_mdas(vg);
 
 	if (cache_updated) {
@@ -2728,6 +2808,11 @@ int vg_commit(struct volume_group *vg)
 		log_error("Attempt to drop cached metadata failed "
 			  "after commit for VG %s.", vg->name);
 
+out:
+	if (!_post_lv_resize(vg, cache_updated)) {
+		cache_updated = 0;
+	}
+
 	/* If at least one mda commit succeeded, it was committed */
 	return cache_updated;
 }
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
diff --git a/liblvm/lvm2app.h b/liblvm/lvm2app.h
index 00f92ab..7515973 100644
--- a/liblvm/lvm2app.h
+++ b/liblvm/lvm2app.h
@@ -1365,8 +1365,6 @@ int lvm_lv_rename(lv_t lv, const char *new_name);
  *
  * \memberof lv_t
  *
- * NOTE: This function is currently not implemented.
- *
  * \param   lv
  * Logical volume handle.
  *
diff --git a/liblvm/lvm_lv.c b/liblvm/lvm_lv.c
index 91948a6..8167fc3 100644
--- a/liblvm/lvm_lv.c
+++ b/liblvm/lvm_lv.c
@@ -309,9 +309,22 @@ int lvm_lv_rename(lv_t lv, const char *new_name)
 
 int lvm_lv_resize(const lv_t lv, uint64_t new_size)
 {
-	/* FIXME: add lv resize code here */
-	log_error("NOT IMPLEMENTED YET");
-	return -1;
+	struct lvresize_params lp = { 0 };
+
+	lp.vg_name = lv->vg->name;
+	lp.lv_name = lv->name;
+	lp.sign = SIGN_NONE;
+	lp.percent = PERCENT_NONE;
+	lp.resize = LV_ANY;
+	lp.size = new_size >> SECTOR_SHIFT;
+	lp.ac_force = 1;	/* Assume the user has a good backup? */
+
+	if (ECMD_PROCESSED != lv_resize(lv->vg->cmd, lv->vg, &lp, &lv->vg->pvs)) {
+		log_verbose("LV Re-size failed.");
+		return -1;
+	}
+
+	return 0;
 }
 
 lv_t lvm_lv_snapshot(const lv_t lv, const char *snap_name, uint64_t max_snap_size)
diff --git a/tools/lvresize.c b/tools/lvresize.c
index 4c9580d..ef79fad 100644
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
@@ -277,611 +110,44 @@ static int _lvresize_params(struct cmd_context *cmd, int argc, char **argv,
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
-	}
-
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
-
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
-	struct logical_volume *lock_lv;
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
+		lp->ac_stripes_value = 0;
 	}
 
-	if (lvl->lv->status & (RAID_IMAGE | RAID_META)) {
-		log_error("Cannot resize a RAID %s directly",
-			  (lvl->lv->status & RAID_IMAGE) ? "image" :
-			  "metadata area");
-		return ECMD_FAILED;
-	}
+	lp->ac_mirrors = arg_count(cmd, mirrors_ARG);
 
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
-		}
-	}
-
-	if ((lp->resize == LV_REDUCE) && lp->argc)
-		log_warn("Ignoring PVs on command line when reducing");
-
-	/* Request confirmation before operations that are often mistakes. */
-	if ((lp->resizefs || (lp->resize == LV_REDUCE)) &&
-	    !_request_confirmation(cmd, vg, lv, lp)) {
-		stack;
-		return ECMD_FAILED;
-	}
-
-	if (lp->resizefs) {
-		if (!lp->nofsck &&
-		    !_fsadm_cmd(cmd, vg, lp, FSADM_CMD_CHECK, &status)) {
-			if (status != FSADM_CHECK_FAILS_FOR_MOUNTED) {
-				log_error("Filesystem check failed.");
-				return ECMD_FAILED;
-			}
-			/* some filesystems supports online resize */
-		}
-
-		if ((lp->resize == LV_REDUCE) &&
-		    !_fsadm_cmd(cmd, vg, lp, FSADM_CMD_RESIZE, NULL)) {
-			log_error("Filesystem resize failed.");
-			return ECMD_FAILED;
+			return 0;
 		}
-	}
 
-	if (!archive(vg)) {
-		stack;
-		return ECMD_FAILED;
+		lp->ac_mirrors_value = arg_uint_value(cmd, mirrors_ARG, 1) + 1;
+	} else {
+		lp->ac_mirrors_value = 0;
 	}
 
-	log_print_unless_silent("%sing logical volume %s to %s",
-				(lp->resize == LV_REDUCE) ? "Reduc" : "Extend",
-				lp->lv_name,
-				display_size(cmd, (uint64_t) lp->extents * vg->extent_size));
-
-	if (lp->resize == LV_REDUCE) {
-		if (!lv_reduce(lv, lv->le_count - lp->extents)) {
-			stack;
-			return ECMD_FAILED;
+	lp->ac_stripesize = arg_count(cmd, stripesize_ARG);
+	if (lp->ac_stripesize) {
+		if (arg_sign_value(cmd, stripesize_ARG, SIGN_NONE) == SIGN_MINUS) {
+			log_error("Stripesize may not be negative.");
+			return 0;
 		}
-	} else if ((lp->extents > lv->le_count) && /* Ensure we extend */
-		   !lv_extend(lv, lp->segtype,
-			      lp->stripes, lp->stripe_size,
-			      lp->mirrors, first_seg(lv)->region_size,
-			      lp->extents - lv->le_count, NULL,
-			      pvh, alloc)) {
-		stack;
-		return ECMD_FAILED;
-	}
 
-	/* store vg on disk(s) */
-	if (!vg_write(vg)) {
-		stack;
-		return ECMD_FAILED;
+		lp->ac_stripesize_value = arg_uint64_value(cmd, stripesize_ARG, 0);
 	}
 
-	/* If snapshot, must suspend all associated devices */
-	if (lv_is_cow(lv))
-		lock_lv = origin_from_cow(lv);
-	else
-		lock_lv = lv;
+	lp->ac_no_sync = arg_count(cmd, nosync_ARG);
+	lp->ac_alloc = arg_uint_value(cmd, alloc_ARG, 0);
 
-	if (!suspend_lv(cmd, lock_lv)) {
-		log_error("Failed to suspend %s", lp->lv_name);
-		vg_revert(vg);
-		backup(vg);
-		return ECMD_FAILED;
-	}
+	lp->ac_type = arg_str_value(cmd, type_ARG, NULL);
+	lp->ac_force = arg_count(cmd, force_ARG);
 
-	if (!vg_commit(vg)) {
-		stack;
-		if (!resume_lv(cmd, lock_lv))
-			stack;
-		backup(vg);
-		return ECMD_FAILED;
-	}
-
-	if (!resume_lv(cmd, lock_lv)) {
-		log_error("Problem reactivating %s", lp->lv_name);
-		backup(vg);
-		return ECMD_FAILED;
-	}
-
-	backup(vg);
-
-	/*
-	 * Update lvm pool metadata (drop messages) if the pool has been
-	 * resumed and do a pool active/deactivate in other case.
-	 *
-	 * Note: Active thin pool can be waiting for resize.
-	 *
-	 * FIXME: Activate only when thin volume is active
-	 */
-	if (lv_is_thin_pool(lv) &&
-	    !update_pool_lv(lv, !lv_is_active(lv))) {
-		stack;
-		return ECMD_FAILED;
-	}
-
-	log_print_unless_silent("Logical volume %s successfully resized", lp->lv_name);
-
-	if (lp->resizefs && (lp->resize == LV_EXTEND) &&
-	    !_fsadm_cmd(cmd, vg, lp, FSADM_CMD_RESIZE, NULL)) {
-		stack;
-		return ECMD_FAILED;
-	}
-
-	return ECMD_PROCESSED;
+	return 1;
 }
 
 int lvresize(struct cmd_context *cmd, int argc, char **argv)
@@ -889,6 +155,7 @@ int lvresize(struct cmd_context *cmd, int argc, char **argv)
 	struct lvresize_params lp = { 0 };
 	struct volume_group *vg;
 	int r;
+	struct dm_list *pvh = NULL;
 
 	if (!_lvresize_params(cmd, argc, argv, &lp))
 		return EINVALID_CMD_LINE;
@@ -901,10 +168,36 @@ int lvresize(struct cmd_context *cmd, int argc, char **argv)
 		return ECMD_FAILED;
 	}
 
-	if (!(r = _lvresize(cmd, vg, &lp)))
+	if (!(pvh = lp.argc ? create_pv_list(cmd->mem, vg, lp.argc,
+						     lp.argv, 1) : &vg->pvs)) {
 		stack;
+		r = ECMD_FAILED;
+		goto out;
+	}
 
-	unlock_and_release_vg(cmd, vg, lp.vg_name);
+	r = lv_resize(cmd, vg, &lp, pvh);
+
+	if (ECMD_PROCESSED == r) {
+		if (!vg_write(vg)) {
+			stack;
+			r = ECMD_FAILED;
+			goto out;
+		}
 
+		if (!vg_commit(vg)) {
+			r = ECMD_FAILED;
+			goto out;
+		}
+
+		log_print_unless_silent("Logical volume %s successfully resized", lp.lv_name);
+
+		if (lp.resizefs && (lp.resize == LV_EXTEND) &&
+			!fsadm_cmd(cmd, vg, &lp, FSADM_CMD_RESIZE, NULL)) {
+			r = ECMD_FAILED;
+		}
+	}
+
+out:
+	unlock_and_release_vg(cmd, vg, lp.vg_name);
 	return r;
 }
diff --git a/tools/toollib.c b/tools/toollib.c
index 669d772..9b7916a 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1814,9 +1814,3 @@ int change_tag(struct cmd_context *cmd, struct volume_group *vg,
 	return 1;
 }
 
-/* Return percents of extents and avoid overflow, with optional roundup */
-uint32_t percent_of_extents(uint32_t percents, uint32_t count, int roundup)
-{
-	return (uint32_t)(((uint64_t)percents * (uint64_t)count +
-			   ((roundup) ? 99 : 0)) / 100);
-}
diff --git a/tools/tools.h b/tools/tools.h
index a3ad9fd..19ba181 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -34,7 +34,6 @@
 #include "dev-cache.h"
 #include "device.h"
 #include "display.h"
-#include "errors.h"
 #include "filter.h"
 #include "filter-composite.h"
 #include "filter-persistent.h"
@@ -73,21 +72,6 @@ enum {
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
 
@@ -187,7 +171,6 @@ int lvconvert_poll(struct cmd_context *cmd, struct logical_volume *lv, unsigned
 int mirror_remove_missing(struct cmd_context *cmd,
 			  struct logical_volume *lv, int force);
 
-uint32_t percent_of_extents(uint32_t percents, uint32_t count, int roundup);
 
 int vgchange_activate(struct cmd_context *cmd, struct volume_group *vg,
 		       activation_change_t activate);
-- 
1.7.11.7


