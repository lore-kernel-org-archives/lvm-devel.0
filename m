From: M. Mohan Kumar <mohan@in.ibm.com>
Date: Wed, 23 Jan 2013 12:55:08 +0530
Subject: [RFC/PATCH] lvm2app: Add LV creation support
In-Reply-To: <1358925908-32347-1-git-send-email-mohan@in.ibm.com>
References: <1358925908-32347-1-git-send-email-mohan@in.ibm.com>
Message-ID: <1358925908-32347-3-git-send-email-mohan@in.ibm.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

From: "M. Mohan Kumar" <mohan@in.ibm.com>

This patch adds lv creation API to liblvm. Using this API one create any
logical volume with requested target type (like mirror, raid-x etc).

Advantage with this approach is that it gives the user to control
properties of new LVs such as if the minor number of new lv should be
persistent, allocation policy, permission mode, stripe size etc.

TODO:
* Lots of code duplicated from tools part of lvm, make the code generic
  and make it as library so that tools and library can use them

Signed-off-by: M. Mohan Kumar <mohan@in.ibm.com>
---
 liblvm/lvm2app.h |  58 +++++
 liblvm/lvm_lv.c  | 741 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 799 insertions(+)

diff --git a/liblvm/lvm2app.h b/liblvm/lvm2app.h
index 92bdf71..d23c30b 100644
--- a/liblvm/lvm2app.h
+++ b/liblvm/lvm2app.h
@@ -97,6 +97,7 @@ struct volume_group;
 struct logical_volume;
 struct lv_segment;
 struct pv_segment;
+typedef struct lv_params lv_params_t;
 
 /**
  * \class lvm_t
@@ -1024,6 +1025,25 @@ int lvm_vg_set_property(const vg_t vg, const char *name,
 lv_t lvm_vg_create_lv_linear(vg_t vg, const char *name, uint64_t size);
 
 /**
+ * Create a logical volume as per lv_params_t request.
+ * This function commits the change to disk and does _not_ require calling
+ * lvm_vg_write().
+ * NOTE: The commit behavior of this function is subject to change
+ * as the API is developed.
+ *
+ * \param   vg
+ * VG handle obtained from lvm_vg_create() or lvm_vg_open().
+ *
+ * \param   params
+ * LV parameter
+ *
+ * \return
+ * non-NULL handle to an LV object created, or NULL if creation fails.
+ *
+ */
+lv_t lvm_vg_create_lv(vg_t vg, lv_params_t *params);
+
+/**
  * Return a list of lvseg handles for a given LV handle.
  *
  * \memberof lv_t
@@ -1708,6 +1728,44 @@ typedef int32_t percent_t;
  */
 float lvm_percent_to_float(percent_t v);
 
+#define LV_TYPE_INVALID   0x00000000
+#define LV_STRIPE         0x00000001
+#define LV_MIRROR         0x00000010
+#define LV_THIN           0x00000020
+#define LV_THINPOOL       0x00000040
+#define LV_SNAPSHOT       0x00000080
+#define LV_RAID1          0x00000100
+#define LV_RAID4          0x00000200
+#define LV_RAID5          0x00000400
+#define LV_RAID6          0x00000800
+#define LV_ERROR          0x00001000
+
+typedef struct lv_params {
+	int       type;
+	char     *name;
+	lv_t      origin;
+	char     *pool_name;
+	uint32_t  stripes; /* striped */
+	uint32_t  stripe_size; /* striped */
+	uint32_t  chunk_size; /* snapshot */
+	uint32_t  region_size; /* mirror */
+	uint32_t  mirrors; /* mirror */
+	uint64_t  size;
+	uint64_t  virtualsize; /* snapshot */
+	uint64_t  poolmetadatasize; /* thin pool */
+	uint32_t  permission; /* all */
+	uint32_t  read_ahead; /* all */
+	int       alloc; /* all */
+	int       thind;
+	uint32_t  zero;
+	uint32_t  mirrorlog;
+	uint32_t  nosync;
+	int       activate;
+	int       major;
+	int       minor;
+	int       persistent;
+} lv_params_t;
+
 #ifdef __cplusplus
 }
 #endif
diff --git a/liblvm/lvm_lv.c b/liblvm/lvm_lv.c
index 42ee78f..d1b5f32 100644
--- a/liblvm/lvm_lv.c
+++ b/liblvm/lvm_lv.c
@@ -21,6 +21,84 @@
 #include "activate.h"
 #include "lvm_misc.h"
 #include "lvm2app.h"
+#include "segtype.h"
+
+/* move this to new file */
+/*
+   code taken from lvcreate.c, toollib.c etc
+   ideally it should be made generic so lvmlibrary and tools can use
+*/
+int validate_stripe_params(uint32_t *stripes, uint32_t *stripe_size);
+int validate_mirror_params(const struct lvcreate_params *lp);
+int lv_get_pool_params(struct lvcreate_params *lp,
+		       struct cmd_context *cmd, lv_params_t *param);
+int lv_read_mirror_params(struct lvcreate_params *lp,
+			  struct cmd_context *cmd, lv_params_t *param);
+static int lv_read_raid_params(struct lvcreate_params *lp,
+			       struct cmd_context *cmd, lv_params_t *param);
+int update_pool_params(unsigned attr,
+		       uint32_t data_extents, uint32_t extent_size,
+		       uint32_t *chunk_size, thin_discards_t *discards,
+		       uint64_t *pool_metadata_size, lv_params_t *param);
+
+/*
+ * Generic stripe parameter checks.
+ */
+int validate_stripe_params(uint32_t *stripes, uint32_t *stripe_size)
+{
+	if (*stripes == 1 && *stripe_size)
+		*stripe_size = 0;
+
+	if (*stripes > 1 && !*stripe_size)
+		*stripe_size = DEFAULT_STRIPESIZE * 2;
+
+	if (*stripes < 1 || *stripes > MAX_STRIPES) {
+		log_error("Number of stripes (%d) must be between %d and %d",
+			  *stripes, 1, MAX_STRIPES);
+		return 0;
+	}
+
+	if (*stripes > 1 && (*stripe_size < STRIPE_SIZE_MIN ||
+			     *stripe_size & (*stripe_size - 1))) {
+		log_error("Invalid stripe size %d", *stripe_size);
+		return 0;
+	}
+
+	return 1;
+}
+
+/*
+ * Generic mirror parameter checks.
+ * FIXME: Should eventually be moved into lvm library.
+ */
+int validate_mirror_params(const struct lvcreate_params *lp)
+{
+	int pagesize = lvm_getpagesize();
+
+	if (lp->region_size & (lp->region_size - 1)) {
+		log_error("Region size (%" PRIu32 ") must be a power of 2",
+			  lp->region_size);
+		return 0;
+	}
+
+	if (lp->region_size % (pagesize >> SECTOR_SHIFT)) {
+		log_error("Region size (%" PRIu32 ") must be a multiple of "
+			  "machine memory page size (%d)",
+			  lp->region_size, pagesize >> SECTOR_SHIFT);
+		return 0;
+	}
+
+	if (!lp->region_size) {
+		log_error("Non-zero region size must be supplied.");
+		return 0;
+	}
+
+	return 1;
+}
+
+
+/* end of move this to new file */
+
 
 static int _lv_check_handle(const lv_t lv, const int vg_writeable)
 {
@@ -174,6 +252,669 @@ lv_t lvm_vg_create_lv_linear(vg_t vg, const char *name, uint64_t size)
 	return (lv_t) lv;
 }
 
+static int lv_parse_name_params(struct lvcreate_params *lp, lv_params_t *param)
+{
+	lp->pool = param->pool_name;
+	lp->lv_name = param->name;
+
+	/* Need an origin? */
+	if (lp->snapshot && !param->virtualsize) {
+		if (!param->origin) {
+			log_error("Please specify a logical volume to act as "
+				  "the snapshot origin.");
+			return 0;
+		}
+
+		lp->origin = param->origin->name;
+	}
+
+	if (lp->lv_name) {
+		if (!apply_lvname_restrictions(lp->lv_name))
+			return_0;
+
+		if (!validate_name(lp->lv_name)) {
+			log_error("Logical volume name \"%s\" is invalid",
+				  lp->lv_name);
+			return 0;
+		}
+	}
+
+	if (lp->pool) {
+		if (!apply_lvname_restrictions(lp->pool))
+			return_0;
+
+		if (!validate_name(lp->pool)) {
+			log_error("Logical volume name \"%s\" is invalid",
+				  lp->pool);
+			return 0;
+		}
+
+		/* Needed? FIXME */
+		if (lp->lv_name && !strcmp(lp->lv_name, lp->pool)) {
+			log_error("Logical volume name %s and pool name %s "
+				  "must be different.", lp->lv_name, lp->pool);
+			return 0;
+		}
+	}
+
+	return 1;
+}
+
+int update_pool_params(unsigned attr,
+		       uint32_t data_extents, uint32_t extent_size,
+		       uint32_t *chunk_size, thin_discards_t *discards,
+		       uint64_t *pool_metadata_size, lv_params_t *param)
+{
+	size_t estimate_chunk_size;
+
+	if (!(attr & THIN_FEATURE_BLOCK_SIZE) &&
+	    (*chunk_size & (*chunk_size - 1))) {
+		log_error("Chunk size must be a power of 2 for this thin target version.");
+		return 0;
+	} else if (*chunk_size & (DM_THIN_MIN_DATA_BLOCK_SIZE - 1)) {
+		log_error("Chunk size must be multiple of %d.",
+			  DM_THIN_MIN_DATA_BLOCK_SIZE);
+		return 0;
+	}
+
+	if (!*pool_metadata_size) {
+		/* Defaults to nr_pool_blocks * 64b converted to size in sectors */
+		*pool_metadata_size = (uint64_t) data_extents * extent_size /
+			(*chunk_size * (SECTOR_SIZE / UINT64_C(64)));
+		/* Check if we could eventually use bigger chunk size */
+		if (!param->chunk_size) {
+			while ((*pool_metadata_size >
+				(DEFAULT_THIN_POOL_OPTIMAL_SIZE / SECTOR_SIZE)) &&
+			       (*chunk_size < DM_THIN_MAX_DATA_BLOCK_SIZE)) {
+				*chunk_size <<= 1;
+				*pool_metadata_size >>= 1;
+			}
+		} else if (*pool_metadata_size > (2 * DEFAULT_THIN_POOL_MAX_METADATA_SIZE)) {
+			/* Suggest bigger chunk size */
+			estimate_chunk_size = (uint64_t) data_extents * extent_size /
+				(2 * DEFAULT_THIN_POOL_MAX_METADATA_SIZE *
+				 (SECTOR_SIZE / UINT64_C(64)));
+			log_warn("WARNING: Chunk size is too small for"
+				 "pool, suggested minimum is %d.",
+				 1 << (int)(ffs(estimate_chunk_size) + 1));
+		}
+
+		/* Round up to extent size */
+		if (*pool_metadata_size % extent_size)
+			*pool_metadata_size += extent_size - *pool_metadata_size % extent_size;
+	} else {
+		estimate_chunk_size =  (uint64_t) data_extents * extent_size /
+			(*pool_metadata_size * (SECTOR_SIZE / UINT64_C(64)));
+		/* Check to eventually use bigger chunk size */
+		if (!param->chunk_size) {
+			*chunk_size = estimate_chunk_size;
+
+			if (*chunk_size < DM_THIN_MIN_DATA_BLOCK_SIZE)
+				*chunk_size = DM_THIN_MIN_DATA_BLOCK_SIZE;
+			else if (*chunk_size > DM_THIN_MAX_DATA_BLOCK_SIZE)
+				*chunk_size = DM_THIN_MAX_DATA_BLOCK_SIZE;
+		} else if (*chunk_size < estimate_chunk_size) {
+			/* Suggest bigger chunk size */
+		  log_warn("WARNING: Chunk size is smaller then "
+			   "suggested minimum size %ld.", estimate_chunk_size);
+		}
+	}
+
+	if ((uint64_t) *chunk_size > (uint64_t) data_extents * extent_size) {
+		log_error("Chunk size is bigger then pool data size.");
+		return 0;
+	}
+
+	if (*pool_metadata_size > (2 * DEFAULT_THIN_POOL_MAX_METADATA_SIZE)) {
+		if (param->poolmetadatasize)
+		log_warn("WARNING: Maximum supported pool "
+			 "metadata size is %d.",
+			 2 * DEFAULT_THIN_POOL_MAX_METADATA_SIZE);
+		*pool_metadata_size = 2 * DEFAULT_THIN_POOL_MAX_METADATA_SIZE;
+	} else if (*pool_metadata_size < (2 * DEFAULT_THIN_POOL_MIN_METADATA_SIZE)) {
+		if (param->poolmetadatasize)
+		log_warn("WARNING: Minimum supported pool "
+			 "metadata size is %d.",
+			 2 * DEFAULT_THIN_POOL_MIN_METADATA_SIZE);
+		*pool_metadata_size = 2 * DEFAULT_THIN_POOL_MIN_METADATA_SIZE;
+	}
+
+	log_verbose("Setting pool metadata size to %ld.", *pool_metadata_size);
+
+	return 1;
+}
+
+/*
+ * Update extents parameters based on other parameters which affect the size
+ * calculation.
+ * NOTE: We must do this here because of the percent_t typedef and because we
+ * need the vg.
+ */
+static int _update_extents_params(struct volume_group *vg,
+				  struct lvcreate_params *lp,
+				  lv_params_t *param)
+{
+	uint32_t stripesize_extents;
+
+	if (param->size &&
+	    !(lp->extents = extents_from_size(vg->cmd, param->size,
+					       vg->extent_size)))
+		return_0;
+
+	if (lp->voriginsize &&
+	    !(lp->voriginextents = extents_from_size(vg->cmd, lp->voriginsize,
+						      vg->extent_size)))
+		return_0;
+
+	if (!(stripesize_extents = lp->stripe_size / vg->extent_size))
+		stripesize_extents = 1;
+
+	if (lp->create_thin_pool) {
+		if (!update_pool_params(lp->target_attr,
+					lp->extents, vg->extent_size,
+					&lp->chunk_size, &lp->discards,
+					&lp->poolmetadatasize, param))
+			return_0;
+
+		if (!(lp->poolmetadataextents =
+		      extents_from_size(vg->cmd, lp->poolmetadatasize, vg->extent_size)))
+			return_0;
+	}
+
+	return 1;
+}
+
+static int lv_read_size_params(struct lvcreate_params *lp,
+			       struct cmd_context *cmd, lv_params_t *param)
+{
+	if (param->size && param->virtualsize) {
+		log_error("Please specify either size or virtualsize (not both)");
+		return 0;
+	}
+
+	if (!lp->thin && !lp->snapshot && !param->size && !param->virtualsize) {
+		log_error("Please specify either size or virtualsize");
+		return 0;
+	}
+
+	/* If size given with thin, then we are creating a thin pool */
+	if (lp->thin && param->size)
+		lp->create_thin_pool = 1;
+
+	if (param->poolmetadatasize && !seg_is_thin(lp)) {
+		log_error("poolmetadatasize may only be specified when "
+			  "allocating the thin pool.");
+		return 0;
+	}
+
+	/* Size returned in kilobyte units; held in sectors */
+	if (param->virtualsize) {
+		if (seg_is_thin_pool(lp)) {
+			log_error("Virtual size in incompatible with "
+				  "thin_pool segment type.");
+			return 0;
+		}
+		lp->voriginsize = param->virtualsize;
+	} else {
+		/* No virtual size given, so no thin LV to create. */
+		if (seg_is_thin_volume(lp) &&
+				!(lp->segtype = get_segtype_from_string(cmd, "thin-pool")))
+			return_0;
+
+		lp->thin = 0;
+	}
+
+	return 1;
+}
+
+int lv_get_pool_params(struct lvcreate_params *lp,
+			      struct cmd_context *cmd, lv_params_t *param)
+{
+	const char *dstr;
+
+	if (param->zero)
+		lp->zero = param->zero;
+	else
+		lp->zero = find_config_tree_int(cmd,
+			"allocation/thin_pool_zero", DEFAULT_THIN_POOL_ZERO);
+	if (param->thind)
+		lp->discards = param->thind;
+	else {
+                dstr = find_config_tree_str(cmd,
+					    "allocation/thin_pool_discards",
+					    DEFAULT_THIN_POOL_DISCARDS);
+		if (!get_pool_discards(dstr, &lp->discards))
+			return_0;
+	}
+	if (param->chunk_size)
+		lp->chunk_size = param->chunk_size;
+	else
+		lp->chunk_size = find_config_tree_int(cmd,
+						      "allocation/thin_pool_chunk_size",
+						      DEFAULT_THIN_POOL_CHUNK_SIZE) * 2;
+	if ((lp->chunk_size < DM_THIN_MIN_DATA_BLOCK_SIZE) ||
+	    (lp->chunk_size > DM_THIN_MAX_DATA_BLOCK_SIZE)) {
+		log_error("chunk size must be in the range %d - %d",
+		  DM_THIN_MIN_DATA_BLOCK_SIZE, DM_THIN_MAX_DATA_BLOCK_SIZE);
+		return 0;
+	}
+	lp->poolmetadatasize = param->poolmetadatasize;
+	return 1;
+}
+
+int lv_read_mirror_params(struct lvcreate_params *lp,
+				 struct cmd_context *cmd, lv_params_t *param)
+{
+	/* default log is disk */
+	if (param->mirrorlog == -1) {
+		lp->log_count = 1;
+		goto next;
+	}
+
+	switch (param->mirrorlog) {
+	case 0:
+	case 1:
+	case 2:
+		lp->log_count = param->mirrorlog;
+		break;
+	default:
+		log_error("invalid mirrorlog %d", param->mirrorlog);
+		return_0;
+	}
+next:
+	lp->nosync = param->nosync;
+	if (param->region_size)
+		lp->region_size = param->region_size;
+	else {
+		lp->region_size = 2 * find_config_tree_int(cmd,
+							  "activation/mirror_region_size",
+							  DEFAULT_MIRROR_REGION_SIZE);
+		if (lp->region_size < 0) {
+			log_error("invalid regionsize in configuration file");
+			return_0;
+		}
+	}
+	if (!validate_mirror_params(lp))
+		return_0;
+	return 1;
+}
+
+static int lv_read_raid_params(struct lvcreate_params *lp,
+				 struct cmd_context *cmd, lv_params_t *param)
+{
+	if (!segtype_is_raid(lp->segtype))
+		return 1;
+	if (param->mirrorlog) {
+		log_error("log option not applicable to %s segtype",
+			  lp->segtype->name);
+		return_0;
+	}
+
+	/*
+	 * get_stripe_params is called before _read_raid_params
+	 * and already sets:
+	 *   lp->stripes
+	 *   lp->stripe_size
+	 *
+	 * For RAID 4/5/6/10, these values must be set.
+	 */
+	if (!segtype_is_mirrored(lp->segtype) &&
+	    (lp->stripes <= lp->segtype->parity_devs)) {
+		log_error("Number of stripes must be at least %d for %s",
+			  lp->segtype->parity_devs + 1, lp->segtype->name);
+		return 0;
+	} else if (!strcmp(lp->segtype->name, "raid10")) {
+		if (lp->stripes < 2) {
+			log_error("Number of stripes must be@least %d for %s",
+				lp->segtype->parity_devs + 1, lp->segtype->name);
+			  return_0;
+		}
+		/* No stripe argument was given - default to 2 */
+		lp->stripes = 2;
+		lp->stripe_size = DEFAULT_STRIPESIZE * 2;
+	}
+
+	/*
+	 * RAID types without a mirror component do not take '-m' arg
+	 */
+	if (!segtype_is_mirrored(lp->segtype) && param->mirrors) {
+		log_error("Mirror argument cannot be used with segment type, %s",
+			  lp->segtype->name);
+		return 0;
+	}
+
+	/*
+	 * RAID1 does not take a stripe arg
+	 */
+	if ((lp->stripes > 1) && segtype_is_mirrored(lp->segtype) &&
+	    strcmp(lp->segtype->name, "raid10")) {
+		log_error("Stripe argument cannot be used with segment type, %s",
+			  lp->segtype->name);
+		return 0;
+	}
+
+	/*
+	 * _read_mirror_params is called before _read_raid_params
+	 * and already sets:
+	 *   lp->nosync
+	 *   lp->region_size
+	 *
+	 * But let's ensure that programmers don't reorder
+	 * that by checking and warning if they aren't set.
+	 */
+	if (!lp->region_size) {
+		log_error(INTERNAL_ERROR "region_size not set.");
+		return 0;
+	}
+
+	return 1;
+}
+
+int lv_create_params(struct lvcreate_params *lp,
+		     struct cmd_context *cmd,
+		     const char *vg, lv_params_t *lvparam);
+
+int lv_create_params(struct lvcreate_params *lp,
+		     struct cmd_context *cmd,
+		     const char *vg, lv_params_t *param)
+{
+	const char *segtype_str;
+	int type;
+
+	if (param->type == LV_TYPE_INVALID)
+		return_0;
+
+	memset(lp, 0, sizeof(*lp));
+
+	dm_list_init(&lp->tags);
+	lp->target_attr = ~0;
+
+	lp->vg_name = vg;
+	type = param->type;
+	if ((type & LV_THIN || type & LV_THINPOOL) && type & LV_MIRROR)
+		return_0;
+
+	if (type & LV_MIRROR)
+		segtype_str = "mirror";
+	else if(type & LV_THIN)
+		segtype_str = "thin";
+        else if (type & LV_STRIPE)
+		segtype_str = "striped";
+        else if (type & LV_MIRROR)
+		segtype_str = "mirror";
+        else if (type & LV_SNAPSHOT)
+		segtype_str = "snapshot";
+        else if (type & LV_RAID1)
+		segtype_str = "raid1";
+	else if (type & LV_RAID4)
+		segtype_str = "raid4";
+	else if (type & LV_RAID5)
+		segtype_str = "raid5";
+	else if (type & LV_RAID6)
+		segtype_str = "raid6";
+        else if (type & LV_ERROR)
+		segtype_str = "error";
+        else if (type & LV_THINPOOL)
+		segtype_str = "thin-pool";
+
+	if (!(lp->segtype = get_segtype_from_string(cmd, segtype_str)))
+		return_0;
+	if (seg_unknown(lp)) {
+		log_error("Unable to create LV with unknown segment type %s.", segtype_str);
+		return 0;
+	}
+
+	if (type & LV_SNAPSHOT || seg_is_snapshot(lp) ||
+	    (!seg_is_thin(lp) && param->virtualsize))
+		lp->snapshot = 1;
+
+	if (seg_is_thin_pool(lp)) {
+		if (lp->snapshot) {
+			log_error("Snapshots are incompatible with thin_pool segment_type.");
+			return 0;
+		}
+		lp->create_thin_pool = 1;
+	}
+
+	if (seg_is_thin_volume(lp))
+		lp->thin = 1;
+
+        lp->mirrors = 1;
+
+	/* Default to 2 mirrored areas if '--type mirror|raid1|raid10' */
+	if (segtype_is_mirrored(lp->segtype))
+		lp->mirrors = 2;
+
+	if (type & LV_MIRROR) {
+		lp->mirrors = param->mirrors + 1;
+		if (lp->mirrors == 1) {
+			if (segtype_is_mirrored(lp->segtype)) {
+				log_error("mirrors must be at least 1 with segment type %s.",
+					  lp->segtype->name);
+				return 0;
+			}
+			log_print_unless_silent("Redundant mirrors argument: default is 0");
+		}
+
+		if ((lp->mirrors > 2) && !strcmp(lp->segtype->name, "raid10")) {
+			/*
+			 * FIXME: When RAID10 is no longer limited to
+			 * 2-way mirror, 'lv_mirror_count()'
+			 * must also change for RAID10.
+			 */
+			log_error("RAID10 currently supports "
+				  "only 2-way mirroring (i.e. '-m 1')");
+			return 0;
+		}
+	}
+
+        if (lp->snapshot && param->zero) {
+		log_error("zero is incompatible with snapshots");
+		return 0;
+	}
+
+	if (segtype_is_mirrored(lp->segtype) || segtype_is_raid(lp->segtype)) {
+		if (lp->snapshot) {
+			log_error("mirrors and snapshots are currently "
+				  "incompatible");
+			return 0;
+		}
+	} else {
+		if (param->mirrorlog) {
+			log_error("mirrorlog is only available with mirrors");
+			return 0;
+		}
+
+		if (param->nosync) {
+			log_error("nosync is only available with mirrors");
+			return 0;
+		}
+	}
+
+	if (activation() && lp->segtype->ops->target_present &&
+	    !lp->segtype->ops->target_present(cmd, NULL, &lp->target_attr)) {
+		log_error("%s: Required device-mapper target(s) not "
+			  "detected in your kernel", lp->segtype->name);
+		return 0;
+	} else if (!strcmp(lp->segtype->name, "raid10")) {
+		uint32_t maj, min, patchlevel;
+		if (!target_version("raid", &maj, &min, &patchlevel)) {
+			log_error("Failed to determine version of RAID kernel module");
+			return 0;
+		}
+		if ((maj != 1) || (min < 3)) {
+			log_error("RAID module does not support RAID10");
+			return 0;
+		}
+	}
+
+        /*
+	 * Should we zero the lv.
+	 */
+        lp->zero = param->zero;
+
+	/* stripe validation */
+	if (param->stripe_size > STRIPE_SIZE_LIMIT) {
+		log_error("Invalid stripe size %d\n", param->stripe_size);
+		return_0;
+	}
+	lp->stripe_size = param->stripe_size;
+	lp->stripes = param->stripes ? param->stripes : 1;
+	if (!validate_stripe_params(&lp->stripes, &lp->stripe_size))
+		return_0;
+
+	if (!lv_parse_name_params(lp, param) ||
+	    !lv_read_size_params(lp, cmd, param) ||
+	    (lp->create_thin_pool && !lv_get_pool_params(lp, cmd, param)) ||
+	    !lv_read_mirror_params(lp, cmd, param) ||
+	    !lv_read_raid_params(lp, cmd, param))
+		return_0;
+
+        if (!lp->create_thin_pool && param->thind) {
+		log_error("discards is only available for thin pool creation.");
+		return 0;
+	}
+
+	if (lp->snapshot && lp->thin && param->chunk_size)
+		log_warn("WARNING: Ignoring chunksize with thin snapshots.");
+	else if (lp->thin && !lp->create_thin_pool) {
+		if (param->chunk_size)
+			log_warn("WARNING: Ignoring chunksize when using an existing pool.");
+	} else if (lp->snapshot) {
+		lp->chunk_size = param->chunk_size ? param->chunk_size : 8;
+		if (lp->chunk_size < 8 || lp->chunk_size > 1024 ||
+		    (lp->chunk_size & (lp->chunk_size - 1))) {
+			log_error("Chunk size must be a power of 2 in the "
+				  "range 4K to 512K");
+			return 0;
+		}
+
+		if (!lp->thin && !(lp->segtype = get_segtype_from_string(cmd, "snapshot")))
+			return_0;
+	} else if (param->chunk_size && !lp->create_thin_pool) {
+		log_error("chunk_size is only available with snapshots and thin pools");
+		return 0;
+	}
+
+	if (lp->mirrors > DEFAULT_MIRROR_MAX_IMAGES) {
+		log_error("Only up to %d images in mirror supported currently.",
+			  DEFAULT_MIRROR_MAX_IMAGES);
+		return 0;
+	}
+
+	/*
+	 * Allocation parameters
+	 */
+	lp->alloc = param->alloc ? ALLOC_CONTIGUOUS : ALLOC_INHERIT;
+
+	return 1;
+}
+
+static int lv_read_activation_params(struct lvcreate_params *lp, struct cmd_context *cmd,
+				     struct volume_group *vg, lv_params_t *params)
+{
+	unsigned pagesize;
+
+	lp->activate = params->activate;
+	if (lp->activate == CHANGE_AN || lp->activate == CHANGE_ALN) {
+		if (lp->zero && !seg_is_thin(lp)) {
+			log_error("no activation requires not zeroing");
+			return 0;
+		}
+	} else if (lp->activate == CHANGE_AAY) {
+		if (params->zero) {
+			log_error("zero is incompatible with automatic activation");
+			return 0;
+		}
+		lp->zero = 0;
+	}
+
+	/*
+	 * Read ahead.
+	 */
+	lp->read_ahead = params->read_ahead ? params->read_ahead :
+		DM_READ_AHEAD_NONE;
+
+	pagesize = lvm_getpagesize() >> SECTOR_SHIFT;
+	if (lp->read_ahead != DM_READ_AHEAD_AUTO &&
+	    lp->read_ahead != DM_READ_AHEAD_NONE &&
+	    lp->read_ahead % pagesize) {
+		if (lp->read_ahead < pagesize)
+			lp->read_ahead = pagesize;
+		else
+			lp->read_ahead = (lp->read_ahead / pagesize) * pagesize;
+		log_warn("WARNING: Overriding readahead to %u sectors, a multiple "
+			    "of %uK page size.", lp->read_ahead, pagesize >> 1);
+	}
+
+	/*
+	 * Permissions.
+	 */
+        lp->permission = params->permission ? params->permission :
+		(LVM_READ | LVM_WRITE);
+
+	/* Must not zero read only volume */
+	if (!(lp->permission & LVM_WRITE))
+		lp->zero = 0;
+
+        lp->major = params->major ? params->major : -1;
+	lp->minor = params->minor ? params->minor : -1;
+
+	/* Persistent minor */
+	if (params->persistent) {
+		if (lp->create_thin_pool && !lp->thin) {
+			log_error("persistent is not permitted when creating a thin pool device.");
+			return 0;
+		}
+		if (lp->minor == -1) {
+			log_error("Please specify minor number with "
+				  "when using persistent");
+			return 0;
+		}
+		if (lp->major == -1) {
+			log_error("Please specify major number with "
+				  "when using persistent");
+			return 0;
+		}
+		/* FIXME: Move this function
+		if (!major_minor_valid(cmd, vg->fid->fmt, lp->major, lp->minor))
+			return 0;
+		*/
+	} else if (params->major || params->minor) {
+		log_error("major and minor require persistent");
+		return 0;
+	}
+
+	return 1;
+}
+
+lv_t lvm_vg_create_lv(vg_t vg, lv_params_t *params)
+{
+	struct lvcreate_params lp = { 0 };
+	struct logical_volume *lv;
+
+	if (!lv_create_params(&lp, vg->cmd, vg->name, params))
+	    return 0;
+
+	lp.pvh = &vg->pvs;
+
+	if (vg_read_error(vg))
+		return NULL;
+	if (!vg_check_write_mode(vg))
+		return NULL;
+
+	if (!lv_read_activation_params(&lp, vg->cmd, vg, params))
+		return_NULL;
+
+	if (!_update_extents_params(vg, &lp, params))
+		return_NULL;
+
+	if (!(lv = lv_create_single(vg, &lp)))
+		return_NULL;
+
+	return (lv_t) lv;
+}
+
 /*
  * FIXME: This function should probably not commit to disk but require calling
  * lvm_vg_write.
-- 
1.7.11.7


