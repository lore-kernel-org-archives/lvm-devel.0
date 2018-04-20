From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 20 Apr 2018 07:01:53 -0400
Subject: master - mirror: fix region_size for clustered VG
Message-ID: <201804201101.w3KB1rh9031209@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=66400d003d357611f19f99fb68500c364fbef547
Commit:        66400d003d357611f19f99fb68500c364fbef547
Parent:        a19456b868849816f21cfd7517777c5999c43a89
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 20 10:07:42 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 20 12:13:48 2018 +0200

mirror: fix region_size for clustered VG

When adjusting region size for clustered VG it always needs to fit
2 full bitset into 1MB due to old limits of CPG.

This is relatively big amount of bits, but we have still limitation
for region size to fit into 32bits (0x8000000).

So for too big mirrors this operation needs to fail - so whenever
function returns now 0, it means we can't find matching region_size.

Since return 0 is now 'error' we need to also pass proper region_size
when creating pvmove mirror.
---
 WHATS_NEW               |    1 +
 lib/metadata/lv_manip.c |   20 +++++++-------------
 lib/metadata/mirror.c   |   21 ++++++++++++---------
 lib/mirror/mirrored.c   |   12 ++++++------
 tools/lvconvert.c       |   20 +++++++++++---------
 tools/pvmove.c          |    5 +++--
 6 files changed, 40 insertions(+), 39 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 9682d22..6affa13 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.178 - 
 =====================================
+  Detect too big region_size with clustered mirrors.
   Fix evaluation of maximal region size for mirror log.
   Enhance mirror log size estimation and use smaller size when possible.
   Fix incorrect mirror log size calculation on 32bit arch.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index b8bbdec..707aec3 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -7582,6 +7582,13 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 			return NULL;
 		}
 
+		if (!(lp->region_size = adjusted_mirror_region_size(vg->cmd,
+								    vg->extent_size,
+								    lp->extents,
+								    lp->region_size, 0,
+								    vg_is_clustered(vg))))
+			return_NULL;
+
 		/* FIXME This will not pass cluster lock! */
 		init_mirror_in_sync(lp->nosync);
 
@@ -7591,19 +7598,6 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 				 lp->segtype->name);
 			status |= LV_NOTSYNCED;
 		}
-
-		if (seg_is_raid(lp)) {
-			/* Value raid target constraint */
-			if (lp->region_size > (uint64_t)vg->extent_size * lp->extents) {
-				log_error("Cannot create RAID LV with region size larger than LV size.");
-				return NULL;
-			}
-		} else
-			lp->region_size = adjusted_mirror_region_size(vg->cmd,
-								      vg->extent_size,
-								      lp->extents,
-								      lp->region_size, 0,
-								      vg_is_clustered(vg));
 	} else if (pool_lv && seg_is_thin_volume(lp)) {
 		if (!lv_is_thin_pool(pool_lv)) {
 			log_error("Logical volume %s is not a thin pool.",
diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index db2883b..6c8732b 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -193,10 +193,12 @@ uint32_t adjusted_mirror_region_size(struct cmd_context *cmd,
 		 * This code should be removed when the CPG restriction is
 		 * lifted.
 		 */
-		region_min = (uint64_t) extents * extent_size / CMIRROR_REGION_COUNT_LIMIT;
-		region_min_pow2 = 1;
-		while (region_min_pow2 < region_min)
-			region_min_pow2 *= 2;
+		region_min = region_max / CMIRROR_REGION_COUNT_LIMIT;
+		if (region_min > UINT32_MAX / 2) {
+			log_error("Can't find proper region size for too big mirror.");
+			return 0;
+		}
+		region_min_pow2 = UINT64_C(1) << (1 + 31 - clz(region_min));
 
 		if (region_size < region_min_pow2) {
 			if (internal)
@@ -1591,11 +1593,12 @@ static int _add_mirrors_that_preserve_segments(struct logical_volume *lv,
 	if (!(segtype = get_segtype_from_string(cmd, SEG_TYPE_NAME_MIRROR)))
 		return_0;
 
-	adjusted_region_size = adjusted_mirror_region_size(cmd,
-							   lv->vg->extent_size,
-							   lv->le_count,
-							   region_size, 1,
-							   vg_is_clustered(lv->vg));
+	if (!(adjusted_region_size = adjusted_mirror_region_size(cmd,
+								lv->vg->extent_size,
+								lv->le_count,
+								region_size, 1,
+								vg_is_clustered(lv->vg))))
+		return_0;
 
 	if (!(ah = allocate_extents(lv->vg, NULL, segtype, 1, mirrors, 0, 0,
 				    lv->le_count, allocatable_pvs, alloc, 0,
diff --git a/lib/mirror/mirrored.c b/lib/mirror/mirrored.c
index a46cc29..e6dc99b 100644
--- a/lib/mirror/mirrored.c
+++ b/lib/mirror/mirrored.c
@@ -378,12 +378,12 @@ static int _mirrored_add_target_line(struct dev_manager *dm, struct dm_pool *mem
 		}
 		region_size = seg->region_size;
 
-	} else
-		region_size = adjusted_mirror_region_size(cmd,
-							  seg->lv->vg->extent_size,
-							  seg->area_len,
-							  mirr_state->default_region_size, 1,
-							  vg_is_clustered(seg->lv->vg));
+	} else if (!(region_size = adjusted_mirror_region_size(cmd,
+							       seg->lv->vg->extent_size,
+							       seg->area_len,
+							       mirr_state->default_region_size, 1,
+							       vg_is_clustered(seg->lv->vg))))
+		return_0;
 
 	if (!dm_tree_node_add_mirror_target(node, len))
 		return_0;
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 21db0ef..44fdd16 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -628,10 +628,11 @@ static int _lv_update_log_type(struct cmd_context *cmd,
 
 	/* Adding redundancy to the log */
 	if (old_log_count < log_count) {
-		region_size = adjusted_mirror_region_size(cmd, lv->vg->extent_size,
-							  lv->le_count,
-							  region_size, 0,
-							  vg_is_clustered(lv->vg));
+		if (!(region_size = adjusted_mirror_region_size(cmd, lv->vg->extent_size,
+								lv->le_count,
+								region_size, 0,
+								vg_is_clustered(lv->vg))))
+			return_0;
 
 		if (!add_mirror_log(cmd, original_lv, log_count,
 				    region_size, operable_pvs, alloc))
@@ -833,17 +834,18 @@ static int _lvconvert_mirrors_aux(struct cmd_context *cmd,
 		return 1;
 	}
 
+	if (!(region_size = adjusted_mirror_region_size(cmd, lv->vg->extent_size,
+							lv->le_count,
+							lp->region_size ? : seg->region_size, 0,
+							vg_is_clustered(lv->vg))))
+		return_0;
+
 	if (lv_component_is_active(lv)) {
 		log_error("Cannot convert logical volume %s with active component LV(s).",
 			  display_lvname(lv));
 		return 0;
 	}
 
-	region_size = adjusted_mirror_region_size(cmd, lv->vg->extent_size,
-						  lv->le_count,
-						  lp->region_size ? : seg->region_size, 0,
-						  vg_is_clustered(lv->vg));
-
 	if (!operable_pvs)
 		operable_pvs = pvh;
 
diff --git a/tools/pvmove.c b/tools/pvmove.c
index 84efdf4..9ad17f6 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -511,8 +511,9 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 		return NULL;
 	}
 
-	if (!lv_add_mirrors(cmd, lv_mirr, 1, 1, 0, 0, log_count,
-			    allocatable_pvs, alloc,
+	if (!lv_add_mirrors(cmd, lv_mirr, 1, 1, 0,
+			    get_default_region_size(cmd),
+			    log_count, allocatable_pvs, alloc,
 			    (arg_is_set(cmd, atomic_ARG)) ?
 			    MIRROR_BY_SEGMENTED_LV : MIRROR_BY_SEG)) {
 		log_error("Failed to convert pvmove LV to mirrored.");


