From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri,  3 Jun 2011 21:13:20 +0200
Subject: [PATCH 02/11] Add laopts
In-Reply-To: <cover.1307127169.git.zkabelac@redhat.com>
References: <cover.1307127169.git.zkabelac@redhat.com>
Message-ID: <940ebe27a92f6a4279b5524a7aa14578c0ccf74b.1307127169.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/activate/activate.c     |   24 ++++++++++++++----------
 lib/activate/activate.h     |    2 +-
 lib/activate/dev_manager.c  |   18 ++++++++++--------
 lib/error/errseg.c          |    1 +
 lib/metadata/segtype.h      |   13 ++++++++-----
 lib/mirror/mirrored.c       |   12 +++++++-----
 lib/replicator/replicator.c |    2 ++
 lib/snapshot/snapshot.c     |    3 ++-
 lib/striped/striped.c       |    1 +
 lib/unknown/unknown.c       |    1 +
 lib/zero/zero.c             |    1 +
 11 files changed, 48 insertions(+), 30 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 47d27be..49fa3e1 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -243,7 +243,7 @@ int lv_check_transient(struct logical_volume *lv)
 	return 1;
 }
 int monitor_dev_for_events(struct cmd_context *cmd, struct logical_volume *lv,
-			   unsigned origin_only, int monitor)
+			   struct lv_activate_opts *laopts, int monitor)
 {
 	return 1;
 }
@@ -943,7 +943,7 @@ int target_register_events(struct cmd_context *cmd, const char *dso, struct logi
  * Returns 1 otherwise.
  */
 int monitor_dev_for_events(struct cmd_context *cmd, struct logical_volume *lv,
-			   unsigned origin_only, int monitor)
+			   const struct lv_activate_opts *laopts, int monitor)
 {
 #ifdef DMEVENTD
 	int i, pending = 0, monitored;
@@ -953,6 +953,10 @@ int monitor_dev_for_events(struct cmd_context *cmd, struct logical_volume *lv,
 	struct lv_segment *log_seg;
 	int (*monitor_fn) (struct lv_segment *s, int e);
 	uint32_t s;
+	static const struct lv_activate_opts zlaopts = { 0 };
+
+	if (!laopts)
+		laopts = &zlaopts;
 
 	/* skip dmeventd code altogether */
 	if (dmeventd_monitor_mode() == DMEVENTD_MONITOR_IGNORE)
@@ -976,10 +980,10 @@ int monitor_dev_for_events(struct cmd_context *cmd, struct logical_volume *lv,
 	 * each of its respective snapshots.  The origin itself may
 	 * also need to be monitored if it is a mirror, for example.
 	 */
-	if (!origin_only && lv_is_origin(lv))
+	if (!laopts->origin_only && lv_is_origin(lv))
 		dm_list_iterate_safe(snh, snht, &lv->snapshot_segs)
 			if (!monitor_dev_for_events(cmd, dm_list_struct_base(snh,
-				    struct lv_segment, origin_list)->cow, 0, monitor))
+				    struct lv_segment, origin_list)->cow, NULL, monitor))
 				r = 0;
 
 	/*
@@ -989,7 +993,7 @@ int monitor_dev_for_events(struct cmd_context *cmd, struct logical_volume *lv,
 	if ((seg = first_seg(lv)) != NULL && seg->log_lv != NULL &&
 	    (log_seg = first_seg(seg->log_lv)) != NULL &&
 	    seg_is_mirrored(log_seg))
-		if (!monitor_dev_for_events(cmd, seg->log_lv, 0, monitor))
+		if (!monitor_dev_for_events(cmd, seg->log_lv, NULL, monitor))
 			r = 0;
 
 	dm_list_iterate(tmp, &lv->segments) {
@@ -999,7 +1003,7 @@ int monitor_dev_for_events(struct cmd_context *cmd, struct logical_volume *lv,
 		for (s = 0; s < seg->area_count; s++) {
 			if (seg_type(seg, s) != AREA_LV)
 				continue;
-			if (!monitor_dev_for_events(cmd, seg_lv(seg, s), 0,
+			if (!monitor_dev_for_events(cmd, seg_lv(seg, s), NULL,
 						    monitor)) {
 				log_error("Failed to %smonitor %s",
 					  monitor ? "" : "un",
@@ -1131,7 +1135,7 @@ static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
 		}
 	}
 
-	if (!monitor_dev_for_events(cmd, lv, laopts->origin_only, 0))
+	if (!monitor_dev_for_events(cmd, lv, laopts, 0))
 		/* FIXME Consider aborting here */
 		stack;
 
@@ -1229,7 +1233,7 @@ static int _lv_resume(struct cmd_context *cmd, const char *lvid_s,
 
 	critical_section_dec(cmd);
 
-	if (!monitor_dev_for_events(cmd, lv, laopts->origin_only, 1))
+	if (!monitor_dev_for_events(cmd, lv, laopts, 1))
 		stack;
 
 	r = 1;
@@ -1328,7 +1332,7 @@ int lv_deactivate(struct cmd_context *cmd, const char *lvid_s)
 
 	lv_calculate_readahead(lv, NULL);
 
-	if (!monitor_dev_for_events(cmd, lv, 0, 0))
+	if (!monitor_dev_for_events(cmd, lv, NULL, 0))
 		stack;
 
 	critical_section_inc(cmd);
@@ -1430,7 +1434,7 @@ static int _lv_activate(struct cmd_context *cmd, const char *lvid_s,
 		stack;
 	critical_section_dec(cmd);
 
-	if (r && !monitor_dev_for_events(cmd, lv, 0, 1))
+	if (r && !monitor_dev_for_events(cmd, lv, laopts, 1))
 		stack;
 
 out:
diff --git a/lib/activate/activate.h b/lib/activate/activate.h
index b136d59..022b797 100644
--- a/lib/activate/activate.h
+++ b/lib/activate/activate.h
@@ -108,7 +108,7 @@ int lv_has_target_type(struct dm_pool *mem, struct logical_volume *lv,
 		       const char *layer, const char *target_type);
 
 int monitor_dev_for_events(struct cmd_context *cmd, struct logical_volume *lv,
-			   unsigned origin_only, int do_reg);
+			   const struct lv_activate_opts *laopts, int do_reg);
 
 #ifdef DMEVENTD
 #  include "libdevmapper-event.h"
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index b07030a..fe5e1da 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1238,8 +1238,9 @@ static int _add_snapshot_merge_target_to_dtree(struct dev_manager *dm,
 }
 
 static int _add_snapshot_target_to_dtree(struct dev_manager *dm,
-					   struct dm_tree_node *dnode,
-					   struct logical_volume *lv)
+					 struct dm_tree_node *dnode,
+					 struct logical_volume *lv,
+					 struct lv_activate_opts *laopts)
 {
 	const char *origin_dlid;
 	const char *cow_dlid;
@@ -1272,8 +1273,9 @@ static int _add_snapshot_target_to_dtree(struct dev_manager *dm,
 }
 
 static int _add_target_to_dtree(struct dev_manager *dm,
-				  struct dm_tree_node *dnode,
-				  struct lv_segment *seg)
+				struct dm_tree_node *dnode,
+				struct lv_segment *seg,
+				struct lv_activate_opts *laopts)
 {
 	uint64_t extent_size = seg->lv->vg->extent_size;
 
@@ -1285,7 +1287,7 @@ static int _add_target_to_dtree(struct dev_manager *dm,
 
 	return seg->segtype->ops->add_target_line(dm, dm->mem, dm->cmd,
 						  &dm->target_state, seg,
-						  dnode,
+						  laopts, dnode,
 						  extent_size * seg->len,
 						  &dm-> pvmove_mirror_count);
 }
@@ -1368,7 +1370,7 @@ static int _add_segment_to_dtree(struct dev_manager *dm,
 	/* Ensure required device-mapper targets are loaded */
 	seg_present = find_cow(seg->lv) ? : seg;
 	target_name = (seg_present->segtype->ops->target_name ?
-		       seg_present->segtype->ops->target_name(seg_present) :
+		       seg_present->segtype->ops->target_name(seg_present, laopts) :
 		       seg_present->segtype->name);
 
 	log_debug("Checking kernel supports %s segment type for %s%s%s",
@@ -1427,9 +1429,9 @@ static int _add_segment_to_dtree(struct dev_manager *dm,
 				return_0;
 		}
 	} else if (lv_is_cow(seg->lv) && !layer) {
-		if (!_add_snapshot_target_to_dtree(dm, dnode, seg->lv))
+		if (!_add_snapshot_target_to_dtree(dm, dnode, seg->lv, laopts))
 			return_0;
-	} else if (!_add_target_to_dtree(dm, dnode, seg))
+	} else if (!_add_target_to_dtree(dm, dnode, seg, laopts))
 		return_0;
 
 	if (lv_is_origin(seg->lv) && !layer)
diff --git a/lib/error/errseg.c b/lib/error/errseg.c
index 41e451b..a2fbc4d 100644
--- a/lib/error/errseg.c
+++ b/lib/error/errseg.c
@@ -45,6 +45,7 @@ static int _errseg_add_target_line(struct dev_manager *dm __attribute__((unused)
 				struct cmd_context *cmd __attribute__((unused)),
 				void **target_state __attribute__((unused)),
 				struct lv_segment *seg __attribute__((unused)),
+				const struct lv_activate_opts *laopts __attribute__((unused)),
 				struct dm_tree_node *node, uint64_t len,
 				uint32_t *pvmove_mirror_count __attribute__((unused)))
 {
diff --git a/lib/metadata/segtype.h b/lib/metadata/segtype.h
index 6d50746..a914aac 100644
--- a/lib/metadata/segtype.h
+++ b/lib/metadata/segtype.h
@@ -22,6 +22,7 @@ struct segtype_handler;
 struct cmd_context;
 struct config_tree;
 struct lv_segment;
+struct lv_activate_opts;
 struct formatter;
 struct config_node;
 struct dev_manager;
@@ -66,7 +67,8 @@ struct segment_type {
 
 struct segtype_handler {
 	const char *(*name) (const struct lv_segment * seg);
-	const char *(*target_name) (const struct lv_segment * seg);
+	const char *(*target_name) (const struct lv_segment *seg,
+				    const struct lv_activate_opts *laopts);
 	void (*display) (const struct lv_segment * seg);
 	int (*text_export) (const struct lv_segment * seg,
 			    struct formatter * f);
@@ -78,10 +80,11 @@ struct segtype_handler {
 	int (*merge_segments) (struct lv_segment * seg1,
 			       struct lv_segment * seg2);
 	int (*add_target_line) (struct dev_manager *dm, struct dm_pool *mem,
-                                struct cmd_context *cmd, void **target_state,
-                                struct lv_segment *seg,
-                                struct dm_tree_node *node, uint64_t len,
-                                uint32_t *pvmove_mirror_count);
+				struct cmd_context *cmd, void **target_state,
+				struct lv_segment *seg,
+				const struct lv_activate_opts *laopts,
+				struct dm_tree_node *node, uint64_t len,
+				uint32_t *pvmove_mirror_count);
 	int (*target_status_compatible) (const char *type);
 	int (*check_transient_status) (struct lv_segment *seg, char *params);
 	int (*target_percent) (void **target_state,
diff --git a/lib/mirror/mirrored.c b/lib/mirror/mirrored.c
index 4c74a44..50e79c3 100644
--- a/lib/mirror/mirrored.c
+++ b/lib/mirror/mirrored.c
@@ -349,6 +349,7 @@ static int _mirrored_transient_status(struct lv_segment *seg, char *params)
 }
 
 static int _add_log(struct dm_pool *mem, struct lv_segment *seg,
+		    const struct lv_activate_opts *laopts,
 		    struct dm_tree_node *node, uint32_t area_count, uint32_t region_size)
 {
 	unsigned clustered = 0;
@@ -390,10 +391,11 @@ static int _add_log(struct dm_pool *mem, struct lv_segment *seg,
 }
 
 static int _mirrored_add_target_line(struct dev_manager *dm, struct dm_pool *mem,
-				struct cmd_context *cmd, void **target_state,
-				struct lv_segment *seg,
-				struct dm_tree_node *node, uint64_t len,
-				uint32_t *pvmove_mirror_count)
+				     struct cmd_context *cmd, void **target_state,
+				     struct lv_segment *seg,
+				     const struct lv_activate_opts *laopts,
+				     struct dm_tree_node *node, uint64_t len,
+				     uint32_t *pvmove_mirror_count)
 {
 	struct mirror_state *mirr_state;
 	uint32_t area_count = seg->area_count;
@@ -451,7 +453,7 @@ static int _mirrored_add_target_line(struct dev_manager *dm, struct dm_pool *mem
 	if (!dm_tree_node_add_mirror_target(node, len))
 		return_0;
 
-	if ((r = _add_log(mem, seg, node, area_count, region_size)) <= 0) {
+	if ((r = _add_log(mem, seg, laopts, node, area_count, region_size)) <= 0) {
 		stack;
 		return r;
 	}
diff --git a/lib/replicator/replicator.c b/lib/replicator/replicator.c
index 2be49c2..9bfc0a2 100644
--- a/lib/replicator/replicator.c
+++ b/lib/replicator/replicator.c
@@ -327,6 +327,7 @@ static int _replicator_add_target_line(struct dev_manager *dm,
 				       struct cmd_context *cmd,
 				       void **target_state,
 				       struct lv_segment *seg,
+				       const struct lv_activate_opts *laopts,
 				       struct dm_tree_node *node,
 				       uint64_t len,
 				       uint32_t *pvmove_mirror_count)
@@ -609,6 +610,7 @@ static int _replicator_dev_add_target_line(struct dev_manager *dm,
 					   struct cmd_context *cmd,
 					   void **target_state,
 					   struct lv_segment *seg,
+					   const struct lv_activate_opts *laopts,
 					   struct dm_tree_node *node,
 					   uint64_t len,
 					   uint32_t *pvmove_mirror_count)
diff --git a/lib/snapshot/snapshot.c b/lib/snapshot/snapshot.c
index a2851b4..3555f36 100644
--- a/lib/snapshot/snapshot.c
+++ b/lib/snapshot/snapshot.c
@@ -28,7 +28,8 @@ static const char *_snap_name(const struct lv_segment *seg)
 	return seg->segtype->name;
 }
 
-static const char *_snap_target_name(const struct lv_segment *seg)
+static const char *_snap_target_name(const struct lv_segment *seg,
+				     const struct lv_activate_opts *laopts)
 {
 	if (seg->status & MERGING)
 		return "snapshot-merge";
diff --git a/lib/striped/striped.c b/lib/striped/striped.c
index 4de4a18..6fa49e3 100644
--- a/lib/striped/striped.c
+++ b/lib/striped/striped.c
@@ -164,6 +164,7 @@ static int _striped_add_target_line(struct dev_manager *dm,
 				struct cmd_context *cmd __attribute__((unused)),
 				void **target_state __attribute__((unused)),
 				struct lv_segment *seg,
+				const struct lv_activate_opts *laopts __attribute__((unused)),
 				struct dm_tree_node *node, uint64_t len,
 				uint32_t *pvmove_mirror_count __attribute__((unused)))
 {
diff --git a/lib/unknown/unknown.c b/lib/unknown/unknown.c
index b218371..2fbd11c 100644
--- a/lib/unknown/unknown.c
+++ b/lib/unknown/unknown.c
@@ -67,6 +67,7 @@ static int _unknown_add_target_line(struct dev_manager *dm __attribute__((unused
 				struct cmd_context *cmd __attribute__((unused)),
 				void **target_state __attribute__((unused)),
 				struct lv_segment *seg __attribute__((unused)),
+				const struct lv_activate_opts *laopts __attribute__((unused)),
 				struct dm_tree_node *node, uint64_t len,
 				uint32_t *pvmove_mirror_count __attribute__((unused)))
 {
diff --git a/lib/zero/zero.c b/lib/zero/zero.c
index 471bc11..9611e9b 100644
--- a/lib/zero/zero.c
+++ b/lib/zero/zero.c
@@ -44,6 +44,7 @@ static int _zero_add_target_line(struct dev_manager *dm __attribute__((unused)),
 				 struct cmd_context *cmd __attribute__((unused)),
 				 void **target_state __attribute__((unused)),
 				 struct lv_segment *seg __attribute__((unused)),
+				 const struct lv_activate_opts *laopts __attribute__((unused)),
 				 struct dm_tree_node *node,uint64_t len,
 				 uint32_t *pvmove_mirror_count __attribute__((unused)))
 {
-- 
1.7.5.2


