From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Sun,  8 Aug 2010 10:57:26 +0200
Subject: [PATCH 14/25] Replicator: replicator.c changes
In-Reply-To: <cover.1281256234.git.zkabelac@redhat.com>
References: <cover.1281256234.git.zkabelac@redhat.com>
Message-ID: <64ad110384e9e362283e4f4b57a47afc19340dae.1281256235.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Changes for replicator.c source file.

Reusing few new API functions from replicator_manip.c for replicator.
Add few missing log_error() diagnostic messages instead of <backtrace>.

Segment for replicator has now SEG_VIRTUAL and SEG_CANNOT_BE_ZEROED
flags. (Not really sure about logic here).

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/replicator/replicator.c |  363 ++++++++++++++++++------------------------
 1 files changed, 156 insertions(+), 207 deletions(-)

diff --git a/lib/replicator/replicator.c b/lib/replicator/replicator.c
index 2c58d16..360aa7f 100644
--- a/lib/replicator/replicator.c
+++ b/lib/replicator/replicator.c
@@ -28,7 +28,7 @@
 
 /* Dm kernel module name for replicator */
 #define REPLICATOR_MODULE "replicator"
-#define REPLICATOR_DEV_MODULE "replicator-dev"
+#define REPLICATED_MODULE "replicated"
 
 /*
  * Macro used as return argument - returns 0.
@@ -104,61 +104,17 @@ static replicator_state_t _get_state(const struct config_node *sn,
 	return def;
 }
 
-/* Strings for replicator_action_t enum */
-static const char _op_mode_txt[NUM_DM_REPLICATOR_MODES][8] = {
-	"sync",
-	"warn",
-	"stall",
-	"drop",
-	"fail"
-};
-
-
-/* Parse action string */
-static dm_replicator_mode_t _get_op_mode(const struct config_node *sn,
-					 const char *path, dm_replicator_mode_t def)
-{
-	char *str;
-	unsigned i;
-
-	if (get_config_str(sn, path, &str)) {
-		for (i = 0; i < sizeof(_op_mode_txt)/sizeof(_op_mode_txt[0]); ++i)
-			if (strcasecmp(str, _op_mode_txt[i]) == 0) {
-				log_very_verbose("Setting %s to %s",
-						 path, _op_mode_txt[i]);
-				return (dm_replicator_mode_t) i;
-			}
-		log_warn("%s: unknown value '%s', using default '%s' operation mode",
-			 path, str, _op_mode_txt[def]);
-	}
-
-	return def;
-}
-
 static struct replicator_site *_get_site(struct logical_volume *replicator,
 					 const char *key)
 {
-	struct dm_pool *mem = replicator->vg->vgmem;
 	struct replicator_site *rsite;
 
-	dm_list_iterate_items(rsite, &replicator->rsites)
-		if (strcasecmp(rsite->name, key) == 0)
-			return rsite;
-
-	if (!(rsite = dm_pool_zalloc(mem, sizeof(*rsite))))
-		return_NULL;
-
-	if (!(rsite->name = dm_pool_strdup(mem, key)))
-		return_NULL;
+	if ((rsite = find_site_in_replicator(replicator, key)))
+		return rsite;
 
-	rsite->replicator = replicator;
-	dm_list_init(&rsite->rdevices);
-	dm_list_add(&replicator->rsites, &rsite->list);
-
-	return rsite;
+	return replicator_add_site(replicator, key);
 }
 
-
 /* Parse replicator site element */
 static int _add_site(struct lv_segment *seg,
 		     const char *key,
@@ -167,6 +123,7 @@ static int _add_site(struct lv_segment *seg,
 	struct dm_pool *mem = seg->lv->vg->vgmem;
 	const struct config_node *cn;
 	struct replicator_site *rsite;
+	char *op_mode;
 
 	if (!(rsite = _get_site(seg->lv, key)))
 		return_0;
@@ -180,36 +137,41 @@ static int _add_site(struct lv_segment *seg,
 		return SEG_LOG_ERROR("site_index=%d > highest_site_index=%d for",
 				     rsite->site_index, seg->rsite_index_highest);
 
-	rsite->fall_behind_data = _get_config_uint64(sn, "fall_behind_data", 0);
 	rsite->fall_behind_ios = _get_config_uint32(sn, "fall_behind_ios", 0);
+	rsite->fall_behind_size = _get_config_uint64(sn, "fall_behind_size", 0);
 	rsite->fall_behind_timeout = _get_config_uint32(sn, "fall_behind_timeout", 0);
-	rsite->op_mode = DM_REPLICATOR_SYNC;
+	rsite->policy = DM_REPLICATOR_SYNC;
 
-	if (rsite->fall_behind_data ||
-	    rsite->fall_behind_ios ||
+	if (rsite->fall_behind_ios ||
+	    rsite->fall_behind_size ||
 	    rsite->fall_behind_timeout) {
-		if (rsite->fall_behind_data && rsite->fall_behind_ios)
-			return SEG_LOG_ERROR("Defined both fall_behind_data "
-					     "and fall_behind_ios in");
-
-		if (rsite->fall_behind_data && rsite->fall_behind_timeout)
-			return SEG_LOG_ERROR("Defined both fall_behind_data "
-					     "and fall_behind_timeout in");
+		if (rsite->fall_behind_ios && rsite->fall_behind_size)
+			return SEG_LOG_ERROR("Defined both fall behind ios "
+					     "and size in");
 
 		if (rsite->fall_behind_ios && rsite->fall_behind_timeout)
-			return SEG_LOG_ERROR("Defined both fall_behind_ios "
-					     "and fall_behind_timeout in");
+			return SEG_LOG_ERROR("Defined both fall behind ios "
+					     "and timeout in");
+
+		if (rsite->fall_behind_size && rsite->fall_behind_timeout)
+			return SEG_LOG_ERROR("Defined both fall behind size "
+					     "and timeout in");
+
+		if (!get_config_str(sn, "operation_mode", &op_mode))
+			return SEG_LOG_ERROR("Operation mode undefined in");
 
-		rsite->op_mode = _get_op_mode(sn, "operation_mode",
-					      rsite->op_mode);
+		if (!replicator_site_set_policy(rsite, op_mode))
+			return SEG_LOG_ERROR("Unknown value for operation mode in");
 	}
 
 	if ((cn = find_config_node(sn, "volume_group"))) {
 		if (!cn->v || cn->v->type != CFG_STRING)
 			return SEG_LOG_ERROR("volume_group must be a string in");
 
-		if (!(rsite->vg_name = dm_pool_strdup(mem, cn->v->v.str)))
-			return_0;
+		if (!(rsite->vg_name = dm_pool_strdup(mem, cn->v->v.str))) {
+			log_error("Failed to duplicate volume group name.");
+			return 0;
+		}
 
 	} else if (rsite->site_index != 0)
 		return SEG_LOG_ERROR("volume_group is mandatory for remote site in");
@@ -226,12 +188,11 @@ static int _replicator_text_import(struct lv_segment *seg,
 	const struct config_node *cn;
 	struct logical_volume *rlog_lv;
 
-	if (!replicator_add_replicator_dev(seg->lv, NULL))
-		return_0;
+	replicator_init(seg->lv);
 
 	if (!(cn = find_config_node(sn, "replicator_log")) ||
 	    !cn->v || cn->v->type != CFG_STRING)
-		return SEG_LOG_ERROR("Replicator log type must be a string in");
+		return SEG_LOG_ERROR("Replicator log must be a string in");
 
 	if (!(rlog_lv = find_lv(seg->lv->vg, cn->v->v.str)))
 		return SEG_LOG_ERROR("Unknown replicator log %s in",
@@ -239,13 +200,15 @@ static int _replicator_text_import(struct lv_segment *seg,
 
 	if (!(cn = find_config_node(sn, "replicator_log_type")) ||
 	    !cn->v || cn->v->type != CFG_STRING)
-		return SEG_LOG_ERROR("Replicator log's type must be a string in");
+		return SEG_LOG_ERROR("Replicator log type must be a string in");
+
 	if (strcasecmp(cn->v->v.str, "ringbuffer"))
 		return SEG_LOG_ERROR("Only ringbuffer replicator log type is supported in");
 
-	if (!(seg->rlog_type = dm_pool_strdup(seg->lv->vg->vgmem, cn->v->v.str)))
-		return_0;
-
+	if (!(seg->rlog_type = dm_pool_strdup(seg->lv->vg->vgmem, cn->v->v.str))) {
+		log_error("Failed to duplicate replicator log type.");
+		return 0;
+	}
 
 	log_very_verbose("replicator_log = %s", rlog_lv->name);
 	log_very_verbose("replicator_log_type = %s", seg->rlog_type);
@@ -267,6 +230,7 @@ static int _replicator_text_import(struct lv_segment *seg,
 			if (!_add_site(seg, sn->key, sn->child))
 				return_0;
 		}
+
 	return 1;
 }
 
@@ -275,9 +239,10 @@ static int _replicator_text_export(const struct lv_segment *seg,
 				   struct formatter *f)
 {
 	struct replicator_site *rsite;
+	const char *policy;
 
 	if (!seg->rlog_lv)
-                return_0;
+		return_0;
 
 	outf(f, "replicator_log = \"%s\"", seg->rlog_lv->name);
 	outf(f, "replicator_log_type = \"%s\"", seg->rlog_type);
@@ -299,18 +264,22 @@ static int _replicator_text_export(const struct lv_segment *seg,
 		outf(f, "site_index = %d", rsite->site_index);
 
 		/* Only non-default parameters are written */
-		if (rsite->op_mode != DM_REPLICATOR_SYNC)
-			outf(f, "operation_mode = \"%s\"",
-			     _op_mode_txt[rsite->op_mode]);
-		if (rsite->fall_behind_timeout)
-			outfc(f, "# seconds", "fall_behind_timeout = %u",
-			     rsite->fall_behind_timeout);
+		if (rsite->policy != DM_REPLICATOR_SYNC) {
+			if (!(policy = replicator_site_get_policy(rsite))) {
+				log_error("Unknown operation mode.");
+				return 0;
+			}
+			outf(f, "operation_mode = \"%s\"", policy);
+		}
 		if (rsite->fall_behind_ios)
 			outfc(f, "# io operations", "fall_behind_ios = %u",
 			     rsite->fall_behind_ios);
-		if (rsite->fall_behind_data)
-			outsize(f, rsite->fall_behind_data, "fall_behind_data = %" PRIu64,
-				rsite->fall_behind_data);
+		if (rsite->fall_behind_size)
+			outsize(f, rsite->fall_behind_size, "fall_behind_size = %" PRIu64,
+				rsite->fall_behind_size);
+		if (rsite->fall_behind_timeout)
+			outfc(f, "# seconds", "fall_behind_timeout = %u",
+			     rsite->fall_behind_timeout);
 		if (rsite->state != REPLICATOR_STATE_ACTIVE && rsite->vg_name)
 			outf(f, "volume_group = \"%s\"", rsite->vg_name);
 
@@ -346,10 +315,10 @@ static int _replicator_add_target_line(struct dev_manager *dm,
 							rlog_dlid,
 							seg->rlog_type,
 							rsite->site_index,
-							rsite->op_mode,
-							rsite->fall_behind_timeout,
-							rsite->fall_behind_data,
-							rsite->fall_behind_ios)) {
+							rsite->policy,
+							rsite->fall_behind_ios,
+							rsite->fall_behind_size,
+							rsite->fall_behind_timeout)) {
 			if (rsite->site_index == 0) {
 				log_error("Failed to add replicator log '%s' "
 					  "to replicator '%s'.",
@@ -400,7 +369,7 @@ static int _replicator_modules_needed(struct dm_pool *mem,
 	if (!str_list_add(mem, modules, REPLICATOR_MODULE))
 		return_0;
 
-	if (!str_list_add(mem, modules, REPLICATOR_DEV_MODULE))
+	if (!str_list_add(mem, modules, REPLICATED_MODULE))
 		return_0;
 
 	return 1;
@@ -426,9 +395,9 @@ static struct segtype_handler _replicator_ops = {
 };
 
 /*
- *  Replicator-dev  target
+ *  Replicated target
  */
-static void _replicator_dev_display(const struct lv_segment *seg)
+static void _replicated_display(const struct lv_segment *seg)
 {
 	//const char *size;
 	//uint32_t s;
@@ -445,82 +414,63 @@ static int _add_device(struct lv_segment *seg,
 		       const struct config_node *sn,
 		       uint64_t devidx)
 {
-	struct dm_pool *mem = seg->lv->vg->vgmem;
-	struct logical_volume *lv = NULL;
-	struct logical_volume *slog_lv = NULL;
+	struct logical_volume *rimage = NULL;
+	struct logical_volume *slog = NULL;
 	struct replicator_site *rsite = _get_site(seg->replicator, site_name);
-	struct replicator_device *rdev;
-	const char *dev_str = NULL;
+	struct replicated_device *rdev;
+	const char *lv_name = NULL;
 	const char *slog_str = NULL;
+	uint32_t slog_core = 0;
 	const struct config_node *cn;
 
 	dm_list_iterate_items(rdev, &rsite->rdevices)
-		if (rdev->replicator_dev == seg)
+		if (rdev->replicated_seg == seg)
 			return SEG_LOG_ERROR("Duplicate site found in");
 
 	if ((cn = find_config_node(sn, "sync_log"))) {
-		if (!cn->v || !cn->v->v.str)
-			return SEG_LOG_ERROR("Sync log must be a string in");
-		slog_str = cn->v->v.str;
+		if (cn->v && cn->v->v.str)
+			slog_str = cn->v->v.str;
+		else if (!get_config_uint32(sn, "sync_log", &slog_core))
+			return SEG_LOG_ERROR("Could not read 'sync_log' for");
 	}
 
 	if (!(cn = find_config_node(sn, "logical_volume")) ||
 	    !cn->v || !cn->v->v.str)
 		return SEG_LOG_ERROR("Logical volume must be a string in");
 
-	dev_str = cn->v->v.str;
+	lv_name = cn->v->v.str;
 
 	if (!seg->lv->rdevice) {
 		if (slog_str)
 			return SEG_LOG_ERROR("Sync log %s defined for local "
-					     "device in", slog_str);
+					     "site device in", slog_str);
 
 		/* Check for device in current VG */
-		if (!(lv = find_lv(seg->lv->vg, dev_str)))
+		if (!(rimage = find_lv(seg->lv->vg, lv_name)))
 			return SEG_LOG_ERROR("Logical volume %s not found in",
-					     dev_str);
+					     lv_name);
 	} else {
-		if (!slog_str)
+		if (!slog_str && !slog_core)
 			return SEG_LOG_ERROR("Sync log is missing for remote "
-					     "device in");
+					     "site device in");
 		/* Check for slog device in current VG */
-		if (!(slog_lv = find_lv(seg->lv->vg, slog_str)))
+		if (!slog_core &&
+		    !(slog = find_lv(seg->lv->vg, slog_str)))
 			return SEG_LOG_ERROR("Sync log %s not found in",
 					     slog_str);
 	}
 
-	if (!(rdev = dm_pool_zalloc(mem, sizeof(*rdev))))
-		return_0;
-
-	if (!(rdev->name = dm_pool_strdup(mem, dev_str)))
+	if (!replicator_site_add_device(rsite, seg, lv_name, rimage,
+					slog_core, slog, devidx))
 		return_0;
 
-	rdev->replicator_dev = seg;
-	rdev->rsite = rsite;
-	rdev->device_index = devidx;
-
-	if (!seg->lv->rdevice) {
-		if (!replicator_dev_add_rimage(rdev, lv))
-			return SEG_LOG_ERROR("LV inconsistency found in");
-		seg->lv->rdevice = rdev;
-	} else {
-		if (!slog_str ||
-		    !(rdev->slog_name = dm_pool_strdup(mem, slog_str)))
-			return_0;
-
-		if (!replicator_dev_add_slog(rdev, slog_lv))
-			return SEG_LOG_ERROR("Sync log inconsistency found in");
-	}
-
-	dm_list_add(&rsite->rdevices, &rdev->list);// linked site list
-
 	return 1;
 }
 
 /* Import replicator segment */
-static int _replicator_dev_text_import(struct lv_segment *seg,
-				       const struct config_node *sn,
-				       struct dm_hash_table *pv_hash __attribute__((unused)))
+static int _replicated_text_import(struct lv_segment *seg,
+				   const struct config_node *sn,
+				   struct dm_hash_table *pv_hash __attribute__((unused)))
 {
 	const struct config_node *cn;
 	struct logical_volume *replicator;
@@ -535,7 +485,7 @@ static int _replicator_dev_text_import(struct lv_segment *seg,
 	if (!(replicator = find_lv(seg->lv->vg, cn->v->v.str)))
 		return SEG_LOG_ERROR("Unknown replicator %s for", cn->v->v.str);
 
-	if (!replicator_add_replicator_dev(replicator, seg))
+	if (!replicator_add_replicated_seg(replicator, seg))
 		return_0;
 
 	log_very_verbose("replicator=%s", replicator->name);
@@ -551,20 +501,17 @@ static int _replicator_dev_text_import(struct lv_segment *seg,
 			return_0;
 
 	if (!seg->lv->rdevice)
-		return SEG_LOG_ERROR("Replicator device without site in");
-
-	seg->rlog_lv = NULL;
-	seg->lv->status |= REPLICATOR;
+		return SEG_LOG_ERROR("Replicated device without site in");
 
 	return 1;
 }
 
-/* Export replicator-dev segment */
-static int _replicator_dev_text_export(const struct lv_segment *seg,
-				       struct formatter *f)
+/* Export replicated segment */
+static int _replicated_text_export(const struct lv_segment *seg,
+				   struct formatter *f)
 {
 	struct replicator_site *rsite;
-	struct replicator_device *rdev;
+	struct replicated_device *rdev;
 
 	if (!seg->replicator || !seg->lv->rdevice)
 		return_0;
@@ -576,7 +523,7 @@ static int _replicator_dev_text_export(const struct lv_segment *seg,
 
 	dm_list_iterate_items(rsite, &seg->replicator->rsites) {
 		dm_list_iterate_items(rdev, &rsite->rdevices) {
-			if (rdev->replicator_dev != seg)
+			if (rdev->replicated_seg != seg)
 				continue;
 
 			outf(f, "%s {", rdev->rsite->name);
@@ -586,10 +533,12 @@ static int _replicator_dev_text_export(const struct lv_segment *seg,
 			outf(f, "logical_volume = \"%s\"",
 			     rdev->name ? rdev->name : rdev->lv->name);
 
-			if (rdev->slog)
-				outf(f, "sync_log = \"%s\"", rdev->slog->name);
-			else if (rdev->slog_name)
-				outf(f, "sync_log = \"%s\"", rdev->slog_name);
+			if (rsite->site_index != 0) {
+				if (rdev->slog)
+					outf(f, "sync_log = \"%s\"", rdev->slog->name);
+				else
+					outf(f, "sync_log = %d", rdev->slog_core);
+			}
 
 			out_dec_indent(f);
 
@@ -604,29 +553,31 @@ static int _replicator_dev_text_export(const struct lv_segment *seg,
 /*
  * Add target for passive site matching the device index
  */
-static int _replicator_dev_add_target_line(struct dev_manager *dm,
-					   struct dm_pool *mem,
-					   struct cmd_context *cmd,
-					   void **target_state,
-					   struct lv_segment *seg,
-					   struct dm_tree_node *node,
-					   uint64_t len,
-					   uint32_t *pvmove_mirror_count)
+static int _replicated_add_target_line(struct dev_manager *dm,
+				       struct dm_pool *mem,
+				       struct cmd_context *cmd,
+				       void **target_state,
+				       struct lv_segment *seg,
+				       struct dm_tree_node *node,
+				       uint64_t len,
+				       uint32_t *pvmove_mirror_count)
 {
 	const char *replicator_dlid, *rdev_dlid, *slog_dlid;
-	struct replicator_device *rdev, *rdev_search;
+	struct replicated_device *rdev, *rdev_search;
 	struct replicator_site *rsite;
 	uint32_t slog_size;
 	uint32_t slog_flags;
 
-	if (!lv_is_active_replicator_dev(seg->lv)) {
+	if (!lv_is_active_replicated(seg->lv)) {
 		/* Create passive linear mapping */
 		log_very_verbose("Inactive replicator %s using %s.",
 				 seg->lv->name, seg->lv->rdevice->lv->name);
 		if (!dm_tree_node_add_linear_target(node, seg->lv->size))
 			return_0;
-		if (!(rdev_dlid = build_dm_uuid(mem, seg->lv->rdevice->lv->lvid.s, NULL)))
-			return_0;
+		if (!(rdev_dlid = build_dm_uuid(mem, seg->lv->rdevice->lv->lvid.s, NULL))) {
+			log_error("Failed to build replicated uuid.");
+			return 0;
+		}
 		return dm_tree_node_add_target_area(node, NULL, rdev_dlid, 0);
 	} else if (seg->lv->rdevice->rsite->site_index) {
 		log_error("Active site with site_index != 0 (%s, %d)",
@@ -639,9 +590,11 @@ static int _replicator_dev_add_target_line(struct dev_manager *dm,
 	 * At this point all devices that have some connection with replicator
 	 * must be present in dm_tree
 	 */
-	if (!seg_is_replicator_dev(seg) ||
-	    !(replicator_dlid = build_dm_uuid(mem, seg->replicator->lvid.s, NULL)))
-		return_0;
+	if (!seg_is_replicated(seg) ||
+	    !(replicator_dlid = build_dm_uuid(mem, seg->replicator->lvid.s, NULL))) {
+		log_error("Failed to build replicator dlid.");
+		return 0;
+	}
 
 	/* Select remote devices with the same device index */
 	dm_list_iterate_items(rsite, &seg->replicator->rsites) {
@@ -651,7 +604,7 @@ static int _replicator_dev_add_target_line(struct dev_manager *dm,
 		} else {
 			rdev = NULL;
 			dm_list_iterate_items(rdev_search, &rsite->rdevices) {
-				if (rdev_search->replicator_dev == seg) {
+				if (rdev_search->replicated_seg == seg) {
 					rdev = rdev_search;
 					break;
 				}
@@ -664,8 +617,10 @@ static int _replicator_dev_add_target_line(struct dev_manager *dm,
 		}
 
 		if (!rdev->lv ||
-		    !(rdev_dlid = build_dm_uuid(mem, rdev->lv->lvid.s, NULL)))
-			return_0;
+		    !(rdev_dlid = build_dm_uuid(mem, rdev->lv->lvid.s, NULL))) {
+			log_error("Failed UUID allocation.");
+			return 0;
+		}
 
 		slog_dlid = NULL;
 
@@ -675,29 +630,23 @@ static int _replicator_dev_add_target_line(struct dev_manager *dm,
 			slog_size = (uint32_t) rdev->slog->size;
 			if (!(slog_dlid = build_dm_uuid(mem, rdev->slog->lvid.s, NULL)))
 				return_0;
-		} else if (rdev->slog_name &&
-			   sscanf(rdev->slog_name, "%" PRIu32, &slog_size) == 1) {
-			slog_flags = DM_CORELOG | DM_FORCESYNC;
-			if (slog_size == 0) {
-				log_error("Failed to use empty corelog size "
-					  "in replicator '%s'.",
-					  rsite->replicator->name);
-				return 0;
-			}
-		} else  {
+		} else if (rdev->slog_core || (rsite->site_index == 0)) {
 			slog_flags = DM_CORELOG | DM_FORCESYNC;
 			slog_size = 0; /* NOLOG */
+		} else {
+			log_error(INTERNAL_ERROR "Either slog or corelog must be used.");
+			return 0;
 		}
 
-		if (!dm_tree_node_add_replicator_dev_target(node,
-							    seg->lv->size,
-							    replicator_dlid,
-							    seg->lv->rdevice->device_index,
-							    rdev_dlid,
-							    rsite->site_index,
-							    slog_dlid,
-							    slog_flags,
-							    slog_size)) {
+		if (!dm_tree_node_add_replicated_target(node,
+							seg->lv->size,
+							replicator_dlid,
+							seg->lv->rdevice->device_index,
+							rdev_dlid,
+							rsite->site_index,
+							slog_dlid,
+							slog_flags,
+							slog_size)) {
 			return_0;
 			/* FIXME: handle 'state = dropped' in future */
 		}
@@ -706,29 +655,29 @@ static int _replicator_dev_add_target_line(struct dev_manager *dm,
 	return 1;
 }
 
-/* FIXME: write something useful for replicator-dev here */
-static int _replicator_dev_target_percent(void **target_state,
-					  percent_range_t *percent_range,
-					  struct dm_pool *mem,
-					  struct cmd_context *cmd,
-					  struct lv_segment *seg,
-					  char *params,
-					  uint64_t *total_numerator,
-					  uint64_t *total_denominator)
+/* FIXME: write something useful for replicated target here */
+static int _replicated_target_percent(void **target_state,
+				      percent_range_t *percent_range,
+				      struct dm_pool *mem,
+				      struct cmd_context *cmd,
+				      struct lv_segment *seg,
+				      char *params,
+				      uint64_t *total_numerator,
+				      uint64_t *total_denominator)
 {
 	return 1;
 }
 
 /* Check for module presence */
-static int _replicator_dev_target_present(struct cmd_context *cmd,
-					  const struct lv_segment *seg __attribute__((unused)),
-					  unsigned *attributes __attribute__((unused)))
+static int _replicated_target_present(struct cmd_context *cmd,
+				      const struct lv_segment *seg __attribute__((unused)),
+				      unsigned *attributes __attribute__((unused)))
 {
 	static int _checked = 0;
 	static int _present = 0;
 
 	if (!_checked) {
-		_present = target_present(cmd, REPLICATOR_DEV_MODULE, 1);
+		_present = target_present(cmd, "replicator-dev", 1);
 		_checked = 1;
 	}
 
@@ -737,15 +686,15 @@ static int _replicator_dev_target_present(struct cmd_context *cmd,
 
 #endif
 
-static struct segtype_handler _replicator_dev_ops = {
+static struct segtype_handler _replicated_ops = {
 	.name = _replicator_name,
-	.display = _replicator_dev_display,
-	.text_import = _replicator_dev_text_import,
-	.text_export = _replicator_dev_text_export,
+	.display = _replicated_display,
+	.text_import = _replicated_text_import,
+	.text_export = _replicated_text_export,
 #ifdef DEVMAPPER_SUPPORT
-	.add_target_line = _replicator_dev_add_target_line,
-	.target_percent = _replicator_dev_target_percent,
-	.target_present = _replicator_dev_target_present,
+	.add_target_line = _replicated_add_target_line,
+	.target_percent = _replicated_target_percent,
+	.target_present = _replicated_target_present,
 #endif
 	.modules_needed = _replicator_modules_needed,
 	.destroy = _replicator_destroy,
@@ -766,7 +715,7 @@ int init_multiple_segtype(struct segtype_library *seglib)
 	segtype->ops = &_replicator_ops;
 	segtype->name = REPLICATOR_MODULE;
 	segtype->private = NULL;
-	segtype->flags = SEG_REPLICATOR;
+	segtype->flags = SEG_REPLICATOR | SEG_VIRTUAL | SEG_CANNOT_BE_ZEROED;
 
 	if (!lvm_register_segtype(seglib, segtype))
 		return_0;
@@ -776,15 +725,15 @@ int init_multiple_segtype(struct segtype_library *seglib)
 	if (!(segtype = dm_malloc(sizeof(*segtype))))
 		return_0;
 
-	segtype->ops = &_replicator_dev_ops;
-	segtype->name = REPLICATOR_DEV_MODULE;
+	segtype->ops = &_replicated_ops;
+	segtype->name = REPLICATED_MODULE;
 	segtype->private = NULL;
-	segtype->flags = SEG_REPLICATOR_DEV;
+	segtype->flags = SEG_REPLICATED;
 
 	if (!lvm_register_segtype(seglib, segtype))
 		return_0;
 
-	log_very_verbose("Initialised segtype: " REPLICATOR_DEV_MODULE);
+	log_very_verbose("Initialised segtype: " REPLICATED_MODULE);
 
 	return 1;
 }
-- 
1.7.2.1


