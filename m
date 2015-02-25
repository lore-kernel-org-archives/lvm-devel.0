From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Wed, 25 Feb 2015 20:43:09 +0000 (UTC)
Subject: master - cmirror: Adjust region size to work around CPG msg limit to avoid hang.
Message-ID: <20150225204309.EB0A96003C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=dd0ee35378cc2ff405183fea9a3d970aab96ac63
Commit:        dd0ee35378cc2ff405183fea9a3d970aab96ac63
Parent:        a88430c6a1e072f326bf4f20fbfd6c11735d0e91
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Wed Feb 25 14:42:15 2015 -0600
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Wed Feb 25 14:42:15 2015 -0600

cmirror: Adjust region size to work around CPG msg limit to avoid hang.

cmirror uses the CPG library to pass messages around the cluster and maintain
its bitmaps.  When a cluster mirror starts-up, it must send the current state
to any joining members - a checkpoint.  When mirrors are large (or the region
size is small), the bitmap size can exceed the message limit of the CPG
library.  When this happens, the CPG library returns CPG_ERR_TRY_AGAIN.
(This is also a bug in CPG, since the message will never be successfully sent.)

There is an outstanding bug (bug 682771) that is meant to lift this message
length restriction in CPG, but for now we work around the issue by increasing
the mirror region size.  This limits the size of the bitmap and avoids any
issues we would otherwise have around checkpointing.

Since this issue only affects cluster mirrors, the region size adjustments
are only made on cluster mirrors.  This patch handles cluster mirror issues
involving pvmove, lvconvert (from linear to mirror), and lvcreate.  It also
ensures that when users convert a VG from single-machine to clustered, any
mirrors with too many regions (i.e. a bitmap that would be too large to
properly checkpoint) are trapped.
---
 WHATS_NEW                        |    1 +
 lib/metadata/lv_manip.c          |    3 +-
 lib/metadata/metadata-exported.h |    6 ++++-
 lib/metadata/mirror.c            |   44 ++++++++++++++++++++++++++++++++++++-
 lib/mirror/mirrored.c            |    3 +-
 tools/lvconvert.c                |    6 +++-
 tools/vgchange.c                 |   16 +++++++++++++
 7 files changed, 72 insertions(+), 7 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 8e80241..c119f3e 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.117 - 
 ====================================
+  Fix hang by adjusting cluster mirror regionsize, avoiding CPG msg limit.
   Do not crash when --cachepolicy is given without --cachesettings.
   Add NEEDS_FOREIGN_VGS flag to vgimport so --foreign is always supplied.
   Add --foreign to the 6 display and reporting tools and vgcfgbackup.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index a77142c..c9c1145 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6854,7 +6854,8 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 
 		lp->region_size = adjusted_mirror_region_size(vg->extent_size,
 							      lp->extents,
-							      lp->region_size, 0);
+							      lp->region_size, 0,
+							      vg_is_clustered(vg));
 	} else if (pool_lv && seg_is_thin_volume(lp)) {
 		if (!lv_is_thin_pool(pool_lv)) {
 			log_error("Logical volume %s is not a thin pool.",
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 2dbaaf0..758fa53 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1032,8 +1032,12 @@ int cluster_mirror_is_available(struct cmd_context *cmd);
 int is_temporary_mirror_layer(const struct logical_volume *lv);
 struct logical_volume * find_temporary_mirror(const struct logical_volume *lv);
 uint32_t lv_mirror_count(const struct logical_volume *lv);
+
+/* Remove CMIRROR_REGION_COUNT_LIMIT when http://bugzilla.redhat.com/682771 is fixed */
+#define CMIRROR_REGION_COUNT_LIMIT (256*1024 * 8)
 uint32_t adjusted_mirror_region_size(uint32_t extent_size, uint32_t extents,
-				     uint32_t region_size, int internal);
+				     uint32_t region_size, int internal, int clustered);
+
 int remove_mirrors_from_segments(struct logical_volume *lv,
 				 uint32_t new_mirrors, uint64_t status_mask);
 int add_mirrors_to_segments(struct cmd_context *cmd, struct logical_volume *lv,
diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index edbf7d4..3f2fa2f 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -159,9 +159,10 @@ struct lv_segment *find_mirror_seg(struct lv_segment *seg)
  * For internal use only log only in verbose mode
  */
 uint32_t adjusted_mirror_region_size(uint32_t extent_size, uint32_t extents,
-				     uint32_t region_size, int internal)
+				     uint32_t region_size, int internal, int clustered)
 {
 	uint64_t region_max;
+	uint64_t region_min, region_min_pow2;
 
 	region_max = (1 << (ffs((int)extents) - 1)) * (uint64_t) (1 << (ffs((int)extent_size) - 1));
 
@@ -175,6 +176,44 @@ uint32_t adjusted_mirror_region_size(uint32_t extent_size, uint32_t extents,
 				    PRIu32 " sectors.", region_size);
 	}
 
+#ifdef CMIRROR_REGION_COUNT_LIMIT
+	if (clustered) {
+		/*
+		 * The CPG code used by cluster mirrors can only handle a
+		 * payload of < 1MB currently.  (This deficiency is tracked by
+		 * http://bugzilla.redhat.com/682771.)  The region size for cluster
+		 * mirrors must be restricted in such a way as to limit the
+		 * size of the bitmap to < 512kB, because there are two bitmaps
+		 * which get sent around during checkpointing while a cluster
+		 * mirror starts up.  Ergo, the number of regions must not
+		 * exceed 512k * 8.  We also need some room for the other
+		 * checkpointing structures as well, so we reduce by another
+		 * factor of two.
+		 *
+		 * This code should be removed when the CPG restriction is
+		 * lifted.
+		 */
+		region_min = extents;
+		region_min *= extent_size;
+		region_min /= CMIRROR_REGION_COUNT_LIMIT;
+		region_min_pow2 = 1;
+		while (region_min_pow2 < region_min)
+			region_min_pow2 *= 2;
+
+		if (region_size < region_min_pow2) {
+			if (internal)
+				log_print_unless_silent("Increasing mirror region size from %"
+							PRIu32 " to %" PRIu32 " sectors.",
+							region_size, region_min_pow2);
+			else
+				log_verbose("Increasing mirror region size from %"
+					    PRIu32 " to %" PRIu32 " sectors.",
+					    region_size, region_min_pow2);
+			region_size = region_min_pow2;
+		}
+	}
+#endif /* CMIRROR_REGION_COUNT_LIMIT */
+
 	return region_size;
 }
 
@@ -1708,7 +1747,8 @@ static int _add_mirrors_that_preserve_segments(struct logical_volume *lv,
 
 	adjusted_region_size = adjusted_mirror_region_size(lv->vg->extent_size,
 							   lv->le_count,
-							   region_size, 1);
+							   region_size, 1,
+							   vg_is_clustered(lv->vg));
 
 	if (!(ah = allocate_extents(lv->vg, NULL, segtype, 1, mirrors, 0, 0,
 				    lv->le_count, allocatable_pvs, alloc, 0,
diff --git a/lib/mirror/mirrored.c b/lib/mirror/mirrored.c
index 7ab11c2..e57e9bb 100644
--- a/lib/mirror/mirrored.c
+++ b/lib/mirror/mirrored.c
@@ -435,7 +435,8 @@ static int _mirrored_add_target_line(struct dev_manager *dm, struct dm_pool *mem
 	} else
 		region_size = adjusted_mirror_region_size(seg->lv->vg->extent_size,
 							  seg->area_len,
-							  mirr_state->default_region_size, 1);
+							  mirr_state->default_region_size, 1,
+							  vg_is_clustered(seg->lv->vg));
 
 	if (!dm_tree_node_add_mirror_target(node, len))
 		return_0;
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 9ec0b0b..0e6f162 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1209,7 +1209,8 @@ static int _lv_update_log_type(struct cmd_context *cmd,
 	if (old_log_count < log_count) {
 		region_size = adjusted_mirror_region_size(lv->vg->extent_size,
 							  lv->le_count,
-							  region_size, 0);
+							  region_size, 0,
+							  vg_is_clustered(lv->vg));
 
 		if (!add_mirror_log(cmd, original_lv, log_count,
 				    region_size, operable_pvs, alloc))
@@ -1425,7 +1426,8 @@ static int _lvconvert_mirrors_aux(struct cmd_context *cmd,
 
 	region_size = adjusted_mirror_region_size(lv->vg->extent_size,
 						  lv->le_count,
-						  lp->region_size, 0);
+						  lp->region_size, 0,
+						  vg_is_clustered(lv->vg));
 
 	if (!operable_pvs)
 		operable_pvs = lp->pvh;
diff --git a/tools/vgchange.c b/tools/vgchange.c
index c03d814..bf3d97d 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -300,6 +300,8 @@ static int _vgchange_clustered(struct cmd_context *cmd,
 			       struct volume_group *vg)
 {
 	int clustered = arg_int_value(cmd, clustered_ARG, 0);
+	struct lv_list *lvl;
+	struct lv_segment *mirror_seg;
 
 	if (clustered && vg_is_clustered(vg)) {
 		if (vg->system_id && *vg->system_id)
@@ -338,6 +340,20 @@ static int _vgchange_clustered(struct cmd_context *cmd,
 			log_error("No volume groups changed.");
 			return 0;
 		}
+#ifdef CMIRROR_REGION_COUNT_LIMIT
+		dm_list_iterate_items(lvl, &vg->lvs) {
+			if (!lv_is_mirror(lvl->lv))
+				continue;
+			mirror_seg = first_seg(lvl->lv);
+			if ((lvl->lv->size / mirror_seg->region_size) >
+			    CMIRROR_REGION_COUNT_LIMIT) {
+				log_error("Unable to convert %s to clustered mode:"
+					  " Mirror region size of %s is too small.",
+					  vg->name, lvl->lv->name);
+				return 0;
+			}
+		}
+#endif
 	}
 
 	if (!vg_set_system_id(vg, clustered ? NULL : cmd->system_id))


