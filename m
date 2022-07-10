From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sun, 10 Jul 2022 23:22:22 +0000 (GMT)
Subject: main - vdo: enhance lvcreate validation
Message-ID: <20220710232222.E5CEF3857023@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e2e31d9acf1b96ab741c22dc0a2fefd672996d3a
Commit:        e2e31d9acf1b96ab741c22dc0a2fefd672996d3a
Parent:        1c18ed3b4ab2f2d5a15995b8f0a18d7d1c4d60ca
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jul 8 23:38:34 2022 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 11 01:18:24 2022 +0200

vdo: enhance lvcreate validation

When creating VDO pool based of  % values, lvm2 is now more clever
and avoids to create 'unsupportable' sizes of physical backend
volumes as 16TiB is maximum size supported by VDO target
(and also limited by maximum supportable slabs (8192) based on slab
size.

If the requested virtual size is approaching max supported size 4PiB,
switch header size to 0.
---
 lib/metadata/metadata-exported.h |  2 ++
 lib/metadata/vdo_manip.c         | 14 ++++++++++++
 tools/lvcreate.c                 | 48 +++++++++++++++++++++++++++++++++-------
 3 files changed, 56 insertions(+), 8 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 191bf4326..6180ac88e 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1364,6 +1364,8 @@ const char *get_vdo_operating_mode_name(enum dm_vdo_operating_mode mode);
 const char *get_vdo_write_policy_name(enum dm_vdo_write_policy policy);
 uint64_t get_vdo_pool_virtual_size(const struct lv_segment *vdo_pool_seg);
 int update_vdo_pool_virtual_size(struct lv_segment *vdo_pool_seg);
+uint32_t get_vdo_pool_max_extents(const struct dm_vdo_target_params *vtp,
+				  uint32_t extent_size);
 int parse_vdo_pool_status(struct dm_pool *mem, const struct logical_volume *vdo_pool_lv,
 			  const char *params, const struct dm_info *dminfo,
 			  struct lv_status_vdo *status);
diff --git a/lib/metadata/vdo_manip.c b/lib/metadata/vdo_manip.c
index a7de55d36..250080b25 100644
--- a/lib/metadata/vdo_manip.c
+++ b/lib/metadata/vdo_manip.c
@@ -127,6 +127,20 @@ int update_vdo_pool_virtual_size(struct lv_segment *vdo_pool_seg)
 	return 1;
 }
 
+uint32_t get_vdo_pool_max_extents(const struct dm_vdo_target_params *vtp,
+				  uint32_t extent_size)
+{
+	uint64_t max_extents = (DM_VDO_PHYSICAL_SIZE_MAXIMUM + extent_size - 1) / extent_size;
+	uint64_t max_slab_extents = ((extent_size - 1 + DM_VDO_SLABS_MAXIMUM *
+				      ((uint64_t)vtp->slab_size_mb << (20 - SECTOR_SHIFT))) /
+				     extent_size);
+
+	max_extents = (max_slab_extents < max_extents) ? max_slab_extents : max_extents;
+
+	return (max_extents > UINT32_MAX) ? UINT32_MAX : (uint32_t)max_extents;
+}
+
+
 static int _sysfs_get_kvdo_value(const char *dm_name, const struct dm_info *dminfo,
 				 const char *vdo_param, uint64_t *value)
 {
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 6bdbe943e..9bf5f4821 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -253,6 +253,7 @@ static int _update_extents_params(struct volume_group *vg,
 	uint32_t stripesize_extents;
 	uint32_t extents;
 	uint32_t base_calc_extents;
+	uint32_t vdo_pool_max_extents;
 
 	if (lcp->size &&
 	    !(lp->extents = extents_from_size(vg->cmd, lcp->size,
@@ -322,6 +323,23 @@ static int _update_extents_params(struct volume_group *vg,
 			return 0;
 	}
 
+	if (seg_is_vdo(lp)) {
+		vdo_pool_max_extents = get_vdo_pool_max_extents(&lp->vdo_params, vg->extent_size);
+		if (extents > vdo_pool_max_extents) {
+			if (lcp->percent == PERCENT_NONE) {
+				log_error("Can't use %s size. Maximal supported VDO POOL volume size with slab size %s is %s.",
+					  display_size(vg->cmd, (uint64_t)vg->extent_size * extents),
+					  display_size(vg->cmd, (uint64_t)lp->vdo_params.slab_size_mb << (20 - SECTOR_SHIFT)),
+					  display_size(vg->cmd, (uint64_t)vg->extent_size * vdo_pool_max_extents));
+				return 0;
+			}
+			extents = vdo_pool_max_extents;
+			log_verbose("Using maximal supported VDO POOL volume size %s (with slab size %s).",
+				    display_size(vg->cmd, (uint64_t)vg->extent_size * extents),
+				    display_size(vg->cmd, (uint64_t)lp->vdo_params.slab_size_mb << (20 - SECTOR_SHIFT)));
+		}
+	}
+
 	if (lcp->percent != PERCENT_NONE) {
 		/* FIXME Don't do the adjustment for parallel allocation with PERCENT_ORIGIN! */
 		lp->approx_alloc = 1;
@@ -699,15 +717,23 @@ static int _read_cache_params(struct cmd_context *cmd,
 }
 
 static int _read_vdo_params(struct cmd_context *cmd,
-			    struct lvcreate_params *lp)
+			    struct lvcreate_params *lp,
+			    struct lvcreate_cmdline_params *lcp)
 {
 	if (!seg_is_vdo(lp))
 		return 1;
 
 	// prefiling settings here
-	if (!fill_vdo_target_params(cmd, &lp->vdo_params,  &lp->vdo_pool_header_size, NULL))
+	if (!fill_vdo_target_params(cmd, &lp->vdo_params, &lp->vdo_pool_header_size, NULL))
 		return_0;
 
+	if ((lcp->virtual_size <= DM_VDO_LOGICAL_SIZE_MAXIMUM) &&
+	    ((lcp->virtual_size + lp->vdo_pool_header_size) > DM_VDO_LOGICAL_SIZE_MAXIMUM)) {
+		log_verbose("Dropping VDO pool header size to 0 to support maximal size %s.",
+			    display_size(cmd, DM_VDO_LOGICAL_SIZE_MAXIMUM));
+		lp->vdo_pool_header_size = 0;
+	}
+
 	// override with optional vdo settings
 	if (!get_vdo_settings(cmd, &lp->vdo_params, NULL))
 		return_0;
@@ -1203,7 +1229,7 @@ static int _lvcreate_params(struct cmd_context *cmd,
 			      &lp->pool_metadata_size, &lp->pool_metadata_spare,
 			      &lp->chunk_size, &lp->discards, &lp->zero_new_blocks)) ||
 	    !_read_cache_params(cmd, lp) ||
-	    !_read_vdo_params(cmd, lp) ||
+	    !_read_vdo_params(cmd, lp, lcp) ||
 	    !_read_mirror_and_raid_params(cmd, lp))
 		return_0;
 
@@ -1589,13 +1615,19 @@ static int _check_pool_parameters(struct cmd_context *cmd,
 }
 
 static int _check_vdo_parameters(struct volume_group *vg, struct lvcreate_params *lp,
-				  struct lvcreate_cmdline_params *lcp)
+				 struct lvcreate_cmdline_params *lcp)
 {
-	if (seg_is_vdo(lp) && lp->snapshot) {
+	if (lp->snapshot) {
 		log_error("Please either create VDO or snapshot.");
 		return 0;
 	}
 
+	if (lcp->virtual_size > DM_VDO_LOGICAL_SIZE_MAXIMUM) {
+		log_error("Maximal supported VDO virtual size is %s.",
+			  display_size(vg->cmd, DM_VDO_LOGICAL_SIZE_MAXIMUM));
+		return 0;
+	}
+
 	return 1;
 }
 
@@ -1717,12 +1749,12 @@ static int _lvcreate_single(struct cmd_context *cmd, const char *vg_name,
 	if (seg_is_thin(lp) && !_check_thin_parameters(vg, lp, lcp))
 		goto_out;
 
-	if (!_check_pool_parameters(cmd, vg, lp, lcp))
-		goto_out;
-
 	if (seg_is_vdo(lp) && !_check_vdo_parameters(vg, lp, lcp))
 		return_0;
 
+	if (!_check_pool_parameters(cmd, vg, lp, lcp))
+		goto_out;
+
 	/* All types are checked */
 	if (!_check_zero_parameters(cmd, lp))
 		return_0;

