From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 24 Sep 2014 08:56:45 +0000 (UTC)
Subject: master - mirror: extend adjusted_mirror_region_size API
Message-ID: <20140924085645.C6B756109B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=736f40134b5a9bcc0335a8054d1838129952a5fc
Commit:        736f40134b5a9bcc0335a8054d1838129952a5fc
Parent:        fa6482344c9f2491d29008b00ac1a4089c883aa7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 22 15:54:33 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 24 10:48:02 2014 +0200

mirror: extend adjusted_mirror_region_size API

We use adjusted_mirror_region_size() in two different contexts.

Either on command line -
 here we do want to inform user about reduction of size.

Or in pvmove activation context -
 here we should only use 'verbose' info.
---
 WHATS_NEW                        |    1 +
 lib/metadata/lv_manip.c          |    2 +-
 lib/metadata/metadata-exported.h |    2 +-
 lib/metadata/mirror.c            |   14 ++++++++++----
 lib/mirror/mirrored.c            |    2 +-
 tools/lvconvert.c                |    4 ++--
 6 files changed, 16 insertions(+), 9 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index dafa16f..b0766a0 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.112 - 
 =====================================
+  Don't print message in adjusted_mirror_region_size() in activation.
   Improve lv_update_and_reload() to find out proper lock holding LV.
   Improve search of LV in lv_ondisk().
   Do not scan sysfs in lv_check_not_in_use() when device is closed.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 277662e..14000b8 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6849,7 +6849,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 
 		lp->region_size = adjusted_mirror_region_size(vg->extent_size,
 							      lp->extents,
-							      lp->region_size);
+							      lp->region_size, 0);
 	}
 
 	if (!(lv = lv_create_empty(new_lv_name ? : "lvol%d", NULL,
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 0fa6c97..4993c22 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1000,7 +1000,7 @@ int is_temporary_mirror_layer(const struct logical_volume *lv);
 struct logical_volume * find_temporary_mirror(const struct logical_volume *lv);
 uint32_t lv_mirror_count(const struct logical_volume *lv);
 uint32_t adjusted_mirror_region_size(uint32_t extent_size, uint32_t extents,
-				    uint32_t region_size);
+				     uint32_t region_size, int internal);
 int remove_mirrors_from_segments(struct logical_volume *lv,
 				 uint32_t new_mirrors, uint64_t status_mask);
 int add_mirrors_to_segments(struct cmd_context *cmd, struct logical_volume *lv,
diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index 0fc9314..1206a1c 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -156,9 +156,11 @@ struct lv_segment *find_mirror_seg(struct lv_segment *seg)
 /*
  * Reduce the region size if necessary to ensure
  * the volume size is a multiple of the region size.
+ *
+ * For internal use only log only in verbose mode
  */
 uint32_t adjusted_mirror_region_size(uint32_t extent_size, uint32_t extents,
-				     uint32_t region_size)
+				     uint32_t region_size, int internal)
 {
 	uint64_t region_max;
 
@@ -166,8 +168,12 @@ uint32_t adjusted_mirror_region_size(uint32_t extent_size, uint32_t extents,
 
 	if (region_max < UINT32_MAX && region_size > region_max) {
 		region_size = (uint32_t) region_max;
-		log_print_unless_silent("Using reduced mirror region size of %" PRIu32
-					" sectors", region_size);
+		if (!internal)
+			log_print_unless_silent("Using reduced mirror region size of %"
+						PRIu32 " sectors.", region_size);
+                else
+			log_verbose("Using reduced mirror region size of %"
+				    PRIu32 " sectors.", region_size);
 	}
 
 	return region_size;
@@ -1697,7 +1703,7 @@ static int _add_mirrors_that_preserve_segments(struct logical_volume *lv,
 
 	adjusted_region_size = adjusted_mirror_region_size(lv->vg->extent_size,
 							   lv->le_count,
-							   region_size);
+							   region_size, 1);
 
 	if (!(ah = allocate_extents(lv->vg, NULL, segtype, 1, mirrors, 0, 0,
 				    lv->le_count, allocatable_pvs, alloc, 0,
diff --git a/lib/mirror/mirrored.c b/lib/mirror/mirrored.c
index 74a8e37..411b4d4 100644
--- a/lib/mirror/mirrored.c
+++ b/lib/mirror/mirrored.c
@@ -440,7 +440,7 @@ static int _mirrored_add_target_line(struct dev_manager *dm, struct dm_pool *mem
 	} else
 		region_size = adjusted_mirror_region_size(seg->lv->vg->extent_size,
 							  seg->area_len,
-							  mirr_state->default_region_size);
+							  mirr_state->default_region_size, 1);
 
 	if (!dm_tree_node_add_mirror_target(node, len))
 		return_0;
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 6a2676b..e501978 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1155,7 +1155,7 @@ static int _lv_update_log_type(struct cmd_context *cmd,
 	if (old_log_count < log_count) {
 		region_size = adjusted_mirror_region_size(lv->vg->extent_size,
 							  lv->le_count,
-							  region_size);
+							  region_size, 0);
 
 		if (!add_mirror_log(cmd, original_lv, log_count,
 				    region_size, operable_pvs, alloc))
@@ -1386,7 +1386,7 @@ static int _lvconvert_mirrors_aux(struct cmd_context *cmd,
 
 	region_size = adjusted_mirror_region_size(lv->vg->extent_size,
 						  lv->le_count,
-						  lp->region_size);
+						  lp->region_size, 0);
 
 	if (!operable_pvs)
 		operable_pvs = lp->pvh;


