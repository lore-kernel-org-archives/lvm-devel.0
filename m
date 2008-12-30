From: malahal@us.ibm.com <malahal@us.ibm.com>
Date: Mon, 29 Dec 2008 16:10:55 -0800
Subject: [RFC] [PATCH] lvm2: mirroredlog support
Message-ID: <20081230001055.GA13710@us.ibm.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch adds '--mirroredlog' option to LVM commands to create a
mirror with mirrored log device. Rebased to the latest LVM code
(LVM2.2.02.43). Appreciate any comments.

Signed-off-by: Stefan Raspl <raspl@de.ibm.com>

---
 lib/activate/activate.c          |   16 ++++++
 lib/metadata/metadata-exported.h |   17 +++++--
 lib/metadata/mirror.c            |   90 ++++++++++++++++++++++++++++-----------
 tools/args.h                     |    1
 tools/commands.h                 |    7 ++-
 tools/lvconvert.c                |   17 +++----
 tools/lvcreate.c                 |    9 +++
 tools/pvmove.c                   |    4 -
 8 files changed, 118 insertions(+), 43 deletions(-)

diff -r d548a82e6195 lib/activate/activate.c
--- a/lib/activate/activate.c	Mon Dec 29 15:36:50 2008 -0800
+++ b/lib/activate/activate.c	Mon Dec 29 15:54:33 2008 -0800
@@ -948,6 +948,8 @@
 {
 	struct logical_volume *lv;
 	struct lvinfo info;
+	struct lv_segment *seg, *log_seg;
+	struct segment_type *type = get_segtype_from_string(cmd, "mirror");
 	int r;
 
 	if (!activation())
@@ -975,6 +977,20 @@
 
 	if (!monitor_dev_for_events(cmd, lv, 0))
 		stack;
+
+	if ( !dm_list_empty(&lv->segments) ) {
+		seg = dm_list_item(dm_list_first(&lv->segments), struct lv_segment);
+		if (seg->log_lv) {
+			log_very_verbose("lv %s is mirrored, check it's log %s...", lv->name, seg->log_lv->name);
+			if ( !dm_list_empty(&seg->log_lv->segments) ) {
+				log_seg = dm_list_item(dm_list_first(&seg->log_lv->segments), struct lv_segment);
+				if (log_seg->segtype == type) {
+					log_verbose("log %s is mirrored, unregister for events", log_seg->lv->name);
+					monitor_dev_for_events(cmd, log_seg->lv, 0);
+				}
+			}
+		}
+	}
 
 	memlock_inc();
 	r = _lv_deactivate(lv);
diff -r d548a82e6195 lib/metadata/metadata-exported.h
--- a/lib/metadata/metadata-exported.h	Mon Dec 29 15:36:50 2008 -0800
+++ b/lib/metadata/metadata-exported.h	Mon Dec 29 15:54:33 2008 -0800
@@ -505,9 +505,11 @@
 */
 struct lv_segment *find_mirror_seg(struct lv_segment *seg);
 int lv_add_mirrors(struct cmd_context *cmd, struct logical_volume *lv,
-		   uint32_t mirrors, uint32_t stripes,
+		   const struct segment_type *segtype,
+		   uint32_t mirrors, uint32_t stripes, uint32_t stripe_size,
 		   uint32_t region_size, uint32_t log_count,
-		   struct dm_list *pvs, alloc_policy_t alloc, uint32_t flags);
+		   struct dm_list *pvs, alloc_policy_t alloc, uint32_t flags,
+		   uint32_t mirrored_log);
 int lv_remove_mirrors(struct cmd_context *cmd, struct logical_volume *lv,
 		      uint32_t mirrors, uint32_t log_count,
 		      struct dm_list *pvs, uint32_t status_mask);
@@ -526,16 +528,21 @@
 int remove_mirror_images(struct logical_volume *lv, uint32_t num_mirrors,
 			 struct dm_list *removable_pvs, unsigned remove_log);
 int add_mirror_images(struct cmd_context *cmd, struct logical_volume *lv,
-		      uint32_t mirrors, uint32_t stripes, uint32_t region_size,
+		      const struct segment_type *segtype,
+		      uint32_t mirrors, uint32_t stripes, uint32_t stripe_size,
+		      uint32_t region_size,
 		      struct dm_list *allocatable_pvs, alloc_policy_t alloc,
-		      uint32_t log_count);
+		      uint32_t log_count, uint32_t mirrored_log);
 struct logical_volume *detach_mirror_log(struct lv_segment *seg);
 int attach_mirror_log(struct lv_segment *seg, struct logical_volume *lv);
 int remove_mirror_log(struct cmd_context *cmd, struct logical_volume *lv,
 		      struct dm_list *removable_pvs);
 int add_mirror_log(struct cmd_context *cmd, struct logical_volume *lv,
+		   const struct segment_type *segtype,
 		   uint32_t log_count, uint32_t region_size,
-		   struct dm_list *allocatable_pvs, alloc_policy_t alloc);
+		   struct dm_list *allocatable_pvs, alloc_policy_t alloc,
+		   uint32_t mirrors, uint32_t stripes, uint32_t stripe_size,
+		   uint32_t mirrored_log);
 
 int reconfigure_mirror_images(struct lv_segment *mirrored_seg, uint32_t num_mirrors,
 			      struct dm_list *removable_pvs, unsigned remove_log);
diff -r d548a82e6195 lib/metadata/mirror.c
--- a/lib/metadata/mirror.c	Mon Dec 29 15:36:50 2008 -0800
+++ b/lib/metadata/mirror.c	Mon Dec 29 15:54:33 2008 -0800
@@ -1241,7 +1241,8 @@
 						 struct alloc_handle *ah,
 						 alloc_policy_t alloc,
 						 const char *lv_name,
-						 const char *suffix)
+						 const char *suffix,
+						 uint32_t mirrored_log)
 {
 	struct logical_volume *log_lv;
 	char *log_name;
@@ -1263,7 +1264,7 @@
 				       alloc, 0, lv->vg)))
 		return_NULL;
 
-	if (!lv_add_log_segment(ah, log_lv))
+	if (!mirrored_log && !lv_add_log_segment(ah, log_lv))
 		return_NULL;
 
 	return log_lv;
@@ -1272,10 +1273,16 @@
 static struct logical_volume *_set_up_mirror_log(struct cmd_context *cmd,
 						 struct alloc_handle *ah,
 						 struct logical_volume *lv,
+						 const struct segment_type *segtype,
 						 uint32_t log_count,
-						 uint32_t region_size __attribute((unused)),
+						 uint32_t region_size,
 						 alloc_policy_t alloc,
-						 int in_sync)
+						 int in_sync,
+						 uint32_t mirrors,
+						 uint32_t stripes,
+						 uint32_t stripe_size,
+						 struct list *allocatable_pvs,
+						 uint32_t mirrored_log)
 {
 	struct logical_volume *log_lv;
 	const char *suffix, *c;
@@ -1317,9 +1324,18 @@
 	}
 
 	if (!(log_lv = _create_mirror_log(lv, ah, alloc,
-					  (const char *) lv_name, suffix))) {
+					  (const char *) lv_name, suffix, mirrored_log))) {
 		log_error("Failed to create mirror log.");
 		return NULL;
+	}
+
+	if (mirrored_log) {
+		if (!lv_extend(log_lv, segtype, stripes, stripe_size,
+				1u, 1u, NULL, 0u, 0u, allocatable_pvs, alloc))
+			return NULL;
+
+		add_mirror_images(cmd, log_lv, segtype, mirrors, stripes, stripe_size,
+				   region_size, allocatable_pvs, alloc, 0, 0);
 	}
 
 	if (!_init_mirror_log(cmd, log_lv, in_sync, &lv->tags, 1)) {
@@ -1339,8 +1355,11 @@
 }
 
 int add_mirror_log(struct cmd_context *cmd, struct logical_volume *lv,
+		   const struct segment_type *seg_type,
 		   uint32_t log_count, uint32_t region_size,
-		   struct dm_list *allocatable_pvs, alloc_policy_t alloc)
+		   struct dm_list *allocatable_pvs, alloc_policy_t alloc,
+		   uint32_t mirrors, uint32_t stripes, uint32_t stripe_size,
+		   uint32_t mirrored_log)
 {
 	struct alloc_handle *ah;
 	const struct segment_type *segtype;
@@ -1402,8 +1421,10 @@
 	else
 		in_sync = 0;
 
-	if (!(log_lv = _set_up_mirror_log(cmd, ah, lv, log_count,
-					  region_size, alloc, in_sync)))
+	if (!(log_lv = _set_up_mirror_log(cmd, ah, lv, seg_type, log_count,
+					  region_size, alloc, in_sync,
+					  mirrors, stripes, stripe_size, allocatable_pvs,
+					  mirrored_log)))
 		return_0;
 
 	if (!attach_mirror_log(first_seg(lv), log_lv))
@@ -1417,9 +1438,10 @@
  * Convert "linear" LV to "mirror".
  */
 int add_mirror_images(struct cmd_context *cmd, struct logical_volume *lv,
-		      uint32_t mirrors, uint32_t stripes, uint32_t region_size,
+		      const struct segment_type *seg_type, uint32_t mirrors,
+		      uint32_t stripes, uint32_t stripe_size, uint32_t region_size,
 		      struct dm_list *allocatable_pvs, alloc_policy_t alloc,
-		      uint32_t log_count)
+		      uint32_t log_count, uint32_t mirrored_log)
 {
 	struct alloc_handle *ah;
 	const struct segment_type *segtype;
@@ -1442,9 +1464,16 @@
 	if (!(segtype = get_segtype_from_string(cmd, "mirror")))
 		return_0;
 
-	ah = allocate_extents(lv->vg, NULL, segtype,
-			      stripes, mirrors, log_count, lv->le_count,
-			      allocatable_pvs, alloc, parallel_areas);
+	if (mirrored_log)
+		// no PV allocation restriction for mirrored logs
+		ah = allocate_extents(lv->vg, NULL, segtype,
+				       stripes, mirrors, 0, 1,
+				       allocatable_pvs, alloc, parallel_areas);
+	else
+		ah = allocate_extents(lv->vg, NULL, segtype,
+				       stripes, mirrors, log_count, lv->le_count,
+				       allocatable_pvs, alloc, parallel_areas);
+
 	if (!ah) {
 		log_error("Unable to allocate extents for mirror(s).");
 		return 0;
@@ -1453,10 +1482,19 @@
 	/*
 	 * create and initialize mirror log
 	 */
-	if (log_count &&
-	    !(log_lv = _set_up_mirror_log(cmd, ah, lv, log_count, region_size,
-					  alloc, mirror_in_sync())))
-		return_0;
+	if (log_count) {
+		if (!(log_lv = _set_up_mirror_log(cmd, ah, lv, seg_type, log_count, region_size,
+				  alloc, mirror_in_sync(), mirrors, stripes,
+				  stripe_size, allocatable_pvs, mirrored_log)))
+			return_0;
+		if (mirrored_log) {
+			ah = allocate_extents(lv->vg, NULL, segtype,
+						stripes, mirrors, 0, lv->le_count,
+						allocatable_pvs, alloc, parallel_areas);
+			if (!ah)
+				return_0;
+		}
+	}
 
 	/* The log initialization involves vg metadata commit.
 	   So from here on, if failure occurs, the log must be explicitly
@@ -1512,9 +1550,11 @@
  * 'pvs' is either allocatable pvs.
  */
 int lv_add_mirrors(struct cmd_context *cmd, struct logical_volume *lv,
-		   uint32_t mirrors, uint32_t stripes,
+		   const struct segment_type *seg_type, uint32_t mirrors,
+		   uint32_t stripes, uint32_t stripe_size,
 		   uint32_t region_size, uint32_t log_count,
-		   struct dm_list *pvs, alloc_policy_t alloc, uint32_t flags)
+		   struct dm_list *pvs, alloc_policy_t alloc, uint32_t flags,
+		   uint32_t mirrored_log)
 {
 	if (!mirrors && !log_count) {
 		log_error("No conversion is requested");
@@ -1547,11 +1587,13 @@
 					       region_size, pvs, alloc);
 	} else if (flags & MIRROR_BY_LV) {
 		if (!mirrors)
-			return add_mirror_log(cmd, lv, log_count,
-					      region_size, pvs, alloc);
-		return add_mirror_images(cmd, lv, mirrors,
-					 stripes, region_size,
-					 pvs, alloc, log_count);
+			return add_mirror_log(cmd, lv, seg_type, log_count,
+					      region_size, pvs, alloc, mirrors,
+				              stripes, stripe_size, mirrored_log);
+		return add_mirror_images(cmd, lv, seg_type, mirrors,
+					 stripes, stripe_size, region_size,
+					 pvs, alloc, log_count,
+					 mirrored_log);
 	}
 
 	log_error("Unsupported mirror conversion type");
diff -r d548a82e6195 tools/args.h
--- a/tools/args.h	Mon Dec 29 15:36:50 2008 -0800
+++ b/tools/args.h	Mon Dec 29 15:54:33 2008 -0800
@@ -45,6 +45,7 @@
 arg(alloc_ARG, '\0', "alloc", alloc_arg, 0)
 arg(separator_ARG, '\0', "separator", string_arg, 0)
 arg(mirrorsonly_ARG, '\0', "mirrorsonly", NULL, 0)
+arg(mirroredlog_ARG, '\0', "mirroredlog", NULL, 0)
 arg(nosync_ARG, '\0', "nosync", NULL, 0)
 arg(resync_ARG, '\0', "resync", NULL, 0)
 arg(corelog_ARG, '\0', "corelog", NULL, 0)
diff -r d548a82e6195 tools/commands.h
--- a/tools/commands.h	Mon Dec 29 15:36:50 2008 -0800
+++ b/tools/commands.h	Mon Dec 29 15:54:33 2008 -0800
@@ -93,7 +93,7 @@
    "Change logical volume layout",
    0,
    "lvconvert "
-   "[-m|--mirrors Mirrors [{--mirrorlog {disk|core}|--corelog}]]\n"
+   "[-m|--mirrors Mirrors [{--mirrorlog {disk|core}|--corelog|--mirroredlog}]]\n"
    "\t[-R|--regionsize MirrorLogRegionSize]\n"
    "\t[--alloc AllocationPolicy]\n"
    "\t[-b|--background]\n"
@@ -115,7 +115,8 @@
    "\tOriginalLogicalVolume[Path] SnapshotLogicalVolume[Path]\n",
 
    alloc_ARG, background_ARG, chunksize_ARG, corelog_ARG, interval_ARG,
-   mirrorlog_ARG, mirrors_ARG, regionsize_ARG, snapshot_ARG, test_ARG, zero_ARG)
+   mirrorlog_ARG, mirrors_ARG, regionsize_ARG, mirroredlog_ARG,
+   snapshot_ARG, test_ARG, zero_ARG)
 
 xx(lvcreate,
    "Create a logical volume",
@@ -132,6 +133,7 @@
    "\t -L|--size LogicalVolumeSize[kKmMgGtTpPeE]}\n"
    "\t[-M|--persistent {y|n}] [--major major] [--minor minor]\n"
    "\t[-m|--mirrors Mirrors [--nosync] [{--mirrorlog {disk|core}|--corelog}]]\n"
+   "\t[--mirroredlog]\n"
    "\t[-n|--name LogicalVolumeName]\n"
    "\t[-p|--permission {r|rw}]\n"
    "\t[-r|--readahead ReadAheadSectors|auto|none]\n"
@@ -163,6 +165,7 @@
    "\t[--version]\n"
    "\tOriginalLogicalVolume[Path] [PhysicalVolumePath...]\n\n",
 
+   mirroredlog_ARG,
    addtag_ARG, alloc_ARG, autobackup_ARG, chunksize_ARG, contiguous_ARG,
    corelog_ARG, extents_ARG, major_ARG, minor_ARG, mirrorlog_ARG, mirrors_ARG,
    name_ARG, nosync_ARG, permission_ARG, persistent_ARG, readahead_ARG,
diff -r d548a82e6195 tools/lvconvert.c
--- a/tools/lvconvert.c	Mon Dec 29 15:36:50 2008 -0800
+++ b/tools/lvconvert.c	Mon Dec 29 15:54:33 2008 -0800
@@ -383,6 +383,7 @@
 	const char *mirrorlog;
 	unsigned corelog = 0;
 	struct logical_volume *original_lv;
+	uint32_t mirrored_log = arg_count(cmd, mirroredlog_ARG);
 
 	seg = first_seg(lv);
 	existing_mirrors = lv_mirror_count(lv);
@@ -484,13 +485,13 @@
 			}
 		}
 
-		if (!lv_add_mirrors(cmd, lv, lp->mirrors - 1, 1,
+		if (!lv_add_mirrors(cmd, lv, lp->segtype, lp->mirrors - 1, 1, 0,
 				    adjusted_mirror_region_size(
 						lv->vg->extent_size,
 						lv->le_count,
 						lp->region_size),
 				    corelog ? 0U : 1U, lp->pvh, lp->alloc,
-				    MIRROR_BY_LV))
+				    MIRROR_BY_LV, mirrored_log))
 			return_0;
 		if (lp->wait_completion)
 			lp->need_polling = 1;
@@ -513,12 +514,12 @@
 		 */
 		original_lv = _original_lv(lv);
 		if (!first_seg(original_lv)->log_lv && !corelog) {
-			if (!add_mirror_log(cmd, original_lv, 1,
+			if (!add_mirror_log(cmd, original_lv, lp->segtype, 1,
 					    adjusted_mirror_region_size(
 							lv->vg->extent_size,
 							lv->le_count,
 							lp->region_size),
-					    lp->pvh, lp->alloc))
+					    lp->pvh, lp->alloc, lp->mirrors, 0, 0, mirrored_log))
 				return_0;
 		} else if (first_seg(original_lv)->log_lv && corelog) {
 			if (!remove_mirror_log(cmd, original_lv,
@@ -546,12 +547,12 @@
 		 */
 		original_lv = _original_lv(lv);
 		if (!first_seg(original_lv)->log_lv && !corelog) {
-			if (!add_mirror_log(cmd, original_lv, 1,
+			if (!add_mirror_log(cmd, original_lv, lp->segtype, 1,
 					    adjusted_mirror_region_size(
 							lv->vg->extent_size,
 							lv->le_count,
 							lp->region_size),
-					    lp->pvh, lp->alloc))
+					    lp->pvh, lp->alloc, lp->mirrors, 0, 0, mirrored_log))
 				return_0;
 		} else if (first_seg(original_lv)->log_lv && corelog) {
 			if (!remove_mirror_log(cmd, original_lv,
@@ -565,13 +566,13 @@
 			return 0;
 		}
 		/* FIXME: can't have multiple mlogs. force corelog. */
-		if (!lv_add_mirrors(cmd, lv, lp->mirrors - existing_mirrors, 1,
+		if (!lv_add_mirrors(cmd, lv, NULL, lp->mirrors - existing_mirrors, 1, 0,
 				    adjusted_mirror_region_size(
 						lv->vg->extent_size,
 						lv->le_count,
 						lp->region_size),
 				    0U, lp->pvh, lp->alloc,
-				    MIRROR_BY_LV))
+				    MIRROR_BY_LV, lp->mirrors))
 			return_0;
 		lv->status |= CONVERTING;
 		lp->need_polling = 1;
diff -r d548a82e6195 tools/lvcreate.c
--- a/tools/lvcreate.c	Mon Dec 29 15:36:50 2008 -0800
+++ b/tools/lvcreate.c	Mon Dec 29 15:54:33 2008 -0800
@@ -37,6 +37,7 @@
 	uint32_t region_size;
 
 	uint32_t mirrors;
+	uint32_t mirrored_log;
 
 	const struct segment_type *segtype;
 
@@ -320,6 +321,9 @@
 		}
 		lp->region_size = region_size;
 	}
+
+	if (arg_count(cmd, mirroredlog_ARG))
+		lp->mirrored_log = 1;
 
 	if (!_validate_mirror_params(cmd, lp))
 		return 0;
@@ -772,14 +776,15 @@
 		return_0;
 
 	if (lp->mirrors > 1) {
-		if (!lv_add_mirrors(cmd, lv, lp->mirrors - 1, lp->stripes,
+		if (!lv_add_mirrors(cmd, lv, lp->segtype, lp->mirrors - 1, lp->stripes, lp->stripe_size,
 				    adjusted_mirror_region_size(
 						vg->extent_size,
 						lv->le_count,
 						lp->region_size),
 				    lp->corelog ? 0U : 1U, pvh, lp->alloc,
 				    MIRROR_BY_LV |
-				    (lp->nosync ? MIRROR_SKIP_INIT_SYNC : 0))) {
+				    (lp->nosync ? MIRROR_SKIP_INIT_SYNC : 0),
+				    lp->mirrored_log)) {
 			stack;
 			goto revert_new_lv;
 		}
diff -r d548a82e6195 tools/pvmove.c
--- a/tools/pvmove.c	Mon Dec 29 15:36:50 2008 -0800
+++ b/tools/pvmove.c	Mon Dec 29 15:54:33 2008 -0800
@@ -251,8 +251,8 @@
 		return NULL;
 	}
 
-	if (!lv_add_mirrors(cmd, lv_mirr, 1, 1, 0, log_count,
-			    allocatable_pvs, alloc, MIRROR_BY_SEG)) {
+	if (!lv_add_mirrors(cmd, lv_mirr, NULL, 1u, 1u, 0u, 0u, log_count,
+			    allocatable_pvs, alloc, MIRROR_BY_SEG, 0)) {
 		log_error("Failed to convert pvmove LV to mirrored");
 		return_NULL;
 	}


