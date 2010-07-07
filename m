From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed,  7 Jul 2010 14:34:47 +0200
Subject: [PATCH 13/22] Replicator: replicator.c changes
In-Reply-To: <cover.1278505885.git.zkabelac@redhat.com>
References: <cover.1278505885.git.zkabelac@redhat.com>
Message-ID: <70e46104ce47166436a5af22168809ca9819677e.1278505885.git.zkabelac@redhat.com>
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
 lib/replicator/replicator.c |  178 +++++++++++++++----------------------------
 1 files changed, 61 insertions(+), 117 deletions(-)

diff --git a/lib/replicator/replicator.c b/lib/replicator/replicator.c
index 6f09321..821e16d 100644
--- a/lib/replicator/replicator.c
+++ b/lib/replicator/replicator.c
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
@@ -200,8 +157,11 @@ static int _add_site(struct lv_segment *seg,
 			return SEG_LOG_ERROR("Defined both fall_behind_ios "
 					     "and fall_behind_timeout in");
 
-		rsite->op_mode = _get_op_mode(sn, "operation_mode",
-					      rsite->op_mode);
+		if (!get_config_str(sn, "operation_mode", &op_mode))
+			return SEG_LOG_ERROR("Operation mode undefined in");
+
+		if (!replicator_site_set_op_mode(rsite, op_mode))
+			return SEG_LOG_ERROR("Unknown value for operation mode in");
 	}
 
 	if ((cn = find_config_node(sn, "volume_group"))) {
@@ -226,8 +186,7 @@ static int _replicator_text_import(struct lv_segment *seg,
 	const struct config_node *cn;
 	struct logical_volume *rlog_lv;
 
-	if (!replicator_add_replicator_dev(seg->lv, NULL))
-		return_0;
+	replicator_init(seg->lv);
 
 	if (!(cn = find_config_node(sn, "replicator_log")) ||
 	    !cn->v || cn->v->type != CFG_STRING)
@@ -246,7 +205,6 @@ static int _replicator_text_import(struct lv_segment *seg,
 	if (!(seg->rlog_type = dm_pool_strdup(seg->lv->vg->vgmem, cn->v->v.str)))
 		return_0;
 
-
 	log_very_verbose("replicator_log = %s", rlog_lv->name);
 	log_very_verbose("replicator_log_type = %s", seg->rlog_type);
 
@@ -267,6 +225,7 @@ static int _replicator_text_import(struct lv_segment *seg,
 			if (!_add_site(seg, sn->key, sn->child))
 				return_0;
 		}
+
 	return 1;
 }
 
@@ -275,9 +234,10 @@ static int _replicator_text_export(const struct lv_segment *seg,
 				   struct formatter *f)
 {
 	struct replicator_site *rsite;
+	const char *op_mode;
 
 	if (!seg->rlog_lv)
-                return_0;
+		return_0;
 
 	outf(f, "replicator_log = \"%s\"", seg->rlog_lv->name);
 	outf(f, "replicator_log_type = \"%s\"", seg->rlog_type);
@@ -299,9 +259,13 @@ static int _replicator_text_export(const struct lv_segment *seg,
 		outf(f, "site_index = %d", rsite->site_index);
 
 		/* Only non-default parameters are written */
-		if (rsite->op_mode != DM_REPLICATOR_SYNC)
-			outf(f, "operation_mode = \"%s\"",
-			     _op_mode_txt[rsite->op_mode]);
+		if (rsite->op_mode != DM_REPLICATOR_SYNC) {
+			if (!(op_mode = replicator_site_get_op_mode(rsite))) {
+				log_error("Unknown operation mode.");
+				return 0;
+			}
+			outf(f, "operation_mode = \"%s\"", op_mode);
+		}
 		if (rsite->fall_behind_timeout)
 			outfc(f, "# seconds", "fall_behind_timeout = %u",
 			     rsite->fall_behind_timeout);
@@ -445,13 +409,13 @@ static int _add_device(struct lv_segment *seg,
 		       const struct config_node *sn,
 		       uint64_t devidx)
 {
-	struct dm_pool *mem = seg->lv->vg->vgmem;
-	struct logical_volume *lv = NULL;
-	struct logical_volume *slog_lv = NULL;
+	struct logical_volume *rimage = NULL;
+	struct logical_volume *slog = NULL;
 	struct replicator_site *rsite = _get_site(seg->replicator, site_name);
 	struct replicator_device *rdev;
-	const char *dev_str = NULL;
+	const char *lv_name = NULL;
 	const char *slog_str = NULL;
+	uint32_t slog_core = 0;
 	const struct config_node *cn;
 
 	dm_list_iterate_items(rdev, &rsite->rdevices)
@@ -459,61 +423,42 @@ static int _add_device(struct lv_segment *seg,
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
 
@@ -553,9 +498,6 @@ static int _replicator_dev_text_import(struct lv_segment *seg,
 	if (!seg->lv->rdevice)
 		return SEG_LOG_ERROR("Replicator device without site in");
 
-	seg->rlog_lv = NULL;
-	seg->lv->status |= REPLICATOR;
-
 	return 1;
 }
 
@@ -586,10 +528,12 @@ static int _replicator_dev_text_export(const struct lv_segment *seg,
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
 
@@ -625,8 +569,10 @@ static int _replicator_dev_add_target_line(struct dev_manager *dm,
 				 seg->lv->name, seg->lv->rdevice->lv->name);
 		if (!dm_tree_node_add_linear_target(node, seg->lv->size))
 			return_0;
-		if (!(rdev_dlid = build_dm_uuid(mem, seg->lv->rdevice->lv->lvid.s, NULL)))
-			return_0;
+		if (!(rdev_dlid = build_dm_uuid(mem, seg->lv->rdevice->lv->lvid.s, NULL))) {
+			log_error("Failed to build replicator-dev uuid.");
+			return 0;
+		}
 		return dm_tree_node_add_target_area(node, NULL, rdev_dlid, 0);
 	} else if (seg->lv->rdevice->rsite->site_index) {
 		log_error("Active site with site_index != 0 (%s, %d)",
@@ -640,8 +586,10 @@ static int _replicator_dev_add_target_line(struct dev_manager *dm,
 	 * must be present in dm_tree
 	 */
 	if (!seg_is_replicator_dev(seg) ||
-	    !(replicator_dlid = build_dm_uuid(mem, seg->replicator->lvid.s, NULL)))
-		return_0;
+	    !(replicator_dlid = build_dm_uuid(mem, seg->replicator->lvid.s, NULL))) {
+		log_error("Failed to build replicator dlid.");
+		return 0;
+	}
 
 	/* Select remote devices with the same device index */
 	dm_list_iterate_items(rsite, &seg->replicator->rsites) {
@@ -664,8 +612,10 @@ static int _replicator_dev_add_target_line(struct dev_manager *dm,
 		}
 
 		if (!rdev->lv ||
-		    !(rdev_dlid = build_dm_uuid(mem, rdev->lv->lvid.s, NULL)))
-			return_0;
+		    !(rdev_dlid = build_dm_uuid(mem, rdev->lv->lvid.s, NULL))) {
+			log_error("Failed UUID allocation.");
+			return 0;
+		}
 
 		slog_dlid = NULL;
 
@@ -675,18 +625,12 @@ static int _replicator_dev_add_target_line(struct dev_manager *dm,
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
 
 		if (!dm_tree_node_add_replicator_dev_target(node,
@@ -766,7 +710,7 @@ int init_multiple_segtype(struct segtype_library *seglib)
 	segtype->ops = &_replicator_ops;
 	segtype->name = REPLICATOR_MODULE;
 	segtype->private = NULL;
-	segtype->flags = SEG_REPLICATOR;
+	segtype->flags = SEG_REPLICATOR | SEG_VIRTUAL | SEG_CANNOT_BE_ZEROED;
 
 	if (!lvm_register_segtype(seglib, segtype))
 		return_0;
-- 
1.7.1.1


