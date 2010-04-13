From: Peter Rajnoha <prajnoha@redhat.com>
Date: Tue, 13 Apr 2010 17:04:15 +0200
Subject: [PATCH] Use UUIDs instead of names while processing dm event handlers
Message-ID: <4BC487EF.2060006@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This is somewhat important as a preparation for "vgrename with active LVs" patch that
will come next. Internally, we used DM names instead of UUIDs while processing event
handlers. This caused problems while trying to vgrename a VG with active LVs where
the names are being changed and so the devices were not found then.

The patch also contains a little bit of refactoring, moving "build_dlid" code found
in dev_manager.c to "build_dm_uuid", now in lvm-string.c (so we have build_dm_uuid and
build_dm_name at one place).

It also fixes a little bug in dm_event_set_uuid fn that improperly checked name
instead of uuid (and since we clear one or the other when one of them is set,
this fn always returned with a failure, breaking further processing).

Peter
---

 daemons/dmeventd/libdevmapper-event.c |    2 +-
 lib/activate/dev_manager.c            |   63 +++++++++-----------------------
 lib/activate/targets.h                |    2 -
 lib/mirror/mirrored.c                 |   26 +++++++-------
 lib/misc/lvm-string.c                 |   21 +++++++++++
 lib/misc/lvm-string.h                 |    3 ++
 lib/snapshot/snapshot.c               |   18 +++++-----
 7 files changed, 65 insertions(+), 70 deletions(-)

diff --git a/daemons/dmeventd/libdevmapper-event.c b/daemons/dmeventd/libdevmapper-event.c
index 115622d..222be1e 100644
--- a/daemons/dmeventd/libdevmapper-event.c
+++ b/daemons/dmeventd/libdevmapper-event.c
@@ -113,7 +113,7 @@ int dm_event_handler_set_uuid(struct dm_event_handler *dmevh, const char *uuid)
 	_dm_event_handler_clear_dev_info(dmevh);
 
 	dmevh->uuid = dm_strdup(uuid);
-	if (!dmevh->dev_name)
+	if (!dmevh->uuid)
 		return -ENOMEM;
 	return 0;
 }
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index dcd5000..66cc94c 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -31,7 +31,6 @@
 #include <dirent.h>
 
 #define MAX_TARGET_PARAMSIZE 50000
-#define UUID_PREFIX "LVM-"
 
 typedef enum {
 	PRELOAD,
@@ -59,32 +58,6 @@ struct lv_layer {
 	const char *old_name;
 };
 
-static char *_build_dlid(struct dm_pool *mem, const char *lvid, const char *layer)
-{
-	char *dlid;
-	size_t len;
-
-	if (!layer)
-		layer = "";
-
-	len = sizeof(UUID_PREFIX) + sizeof(union lvid) + strlen(layer);
-
-	if (!(dlid = dm_pool_alloc(mem, len))) {
-		log_error("_build_dlid: pool allocation failed for %" PRIsize_t
-			  " %s %s.", len, lvid, layer);
-		return NULL;
-	}
-
-	sprintf(dlid, UUID_PREFIX "%s%s%s", lvid, (*layer) ? "-" : "", layer);
-
-	return dlid;
-}
-
-char *build_dlid(struct dev_manager *dm, const char *lvid, const char *layer)
-{
-	return _build_dlid(dm->mem, lvid, layer);
-}
-
 static int _read_only_lv(struct logical_volume *lv)
 {
 	return (!(lv->vg->status & LVM_WRITE) || !(lv->status & LVM_WRITE));
@@ -238,7 +211,7 @@ int dev_manager_info(struct dm_pool *mem, const struct logical_volume *lv,
 		return 0;
 	}
 
-	if (!(dlid = _build_dlid(mem, lv->lvid.s, NULL))) {
+	if (!(dlid = build_dm_uuid(mem, lv->lvid.s, NULL))) {
 		log_error("dlid build failed for %s", lv->name);
 		return 0;
 	}
@@ -258,7 +231,7 @@ static const struct dm_info *_cached_info(struct dm_pool *mem,
 	struct dm_tree_node *dnode;
 	const struct dm_info *dinfo;
 
-	if (!(dlid = _build_dlid(mem, lv->lvid.s, NULL))) {
+	if (!(dlid = build_dm_uuid(mem, lv->lvid.s, NULL))) {
 		log_error("dlid build failed for %s", lv->name);
 		return NULL;
 	}
@@ -370,7 +343,7 @@ static int _lv_has_target_type(struct dev_manager *dm,
 	char *type = NULL;
 	char *params = NULL;
 
-	if (!(dlid = build_dlid(dm, lv->lvid.s, layer)))
+	if (!(dlid = build_dm_uuid(dm->mem, lv->lvid.s, layer)))
 		return_0;
 
 	if (!(dmt = _setup_task(NULL, dlid, 0,
@@ -631,7 +604,7 @@ int dev_manager_snapshot_percent(struct dev_manager *dm,
 	if (!(name = build_dm_name(dm->mem, lv->vg->name, lv->name, NULL)))
 		return_0;
 
-	if (!(dlid = build_dlid(dm, lv->lvid.s, NULL)))
+	if (!(dlid = build_dm_uuid(dm->mem, lv->lvid.s, NULL)))
 		return_0;
 
 	/*
@@ -667,7 +640,7 @@ int dev_manager_mirror_percent(struct dev_manager *dm,
 
 	/* FIXME dm_pool_free ? */
 
-	if (!(dlid = build_dlid(dm, lv->lvid.s, suffix))) {
+	if (!(dlid = build_dm_uuid(dm->mem, lv->lvid.s, suffix))) {
 		log_error("dlid build failed for %s", lv->name);
 		return 0;
 	}
@@ -790,7 +763,7 @@ static int _add_dev_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 	if (!(name = build_dm_name(dm->mem, lv->vg->name, lv->name, layer)))
 		return_0;
 
-	if (!(dlid = build_dlid(dm, lv->lvid.s, layer)))
+	if (!(dlid = build_dm_uuid(dm->mem, lv->lvid.s, layer)))
 		return_0;
 
 	log_debug("Getting device info for %s [%s]", name, dlid);
@@ -925,7 +898,7 @@ static char *_add_error_device(struct dev_manager *dm, struct dm_tree *dtree,
 
 	sprintf(errid, "missing_%d_%d", segno, s);
 
-	if (!(id = build_dlid(dm, seg->lv->lvid.s, errid)))
+	if (!(id = build_dm_uuid(dm->mem, seg->lv->lvid.s, errid)))
 		return_NULL;
 
 	if (!(name = build_dm_name(dm->mem, seg->lv->vg->name,
@@ -987,9 +960,9 @@ int add_areas_line(struct dev_manager *dm, struct lv_segment *seg,
 							(seg_pv(seg, s)->pe_start +
 							 (extent_size * seg_pe(seg, s))));
 		else if (seg_type(seg, s) == AREA_LV) {
-			if (!(dlid = build_dlid(dm,
-						 seg_lv(seg, s)->lvid.s,
-						 NULL)))
+			if (!(dlid = build_dm_uuid(dm->mem,
+						   seg_lv(seg, s)->lvid.s,
+						   NULL)))
 				return_0;
 			dm_tree_node_add_target_area(node, NULL, dlid,
 							extent_size * seg_le(seg, s));
@@ -1009,7 +982,7 @@ static int _add_origin_target_to_dtree(struct dev_manager *dm,
 {
 	const char *real_dlid;
 
-	if (!(real_dlid = build_dlid(dm, lv->lvid.s, "real")))
+	if (!(real_dlid = build_dm_uuid(dm->mem, lv->lvid.s, "real")))
 		return_0;
 
 	if (!dm_tree_node_add_snapshot_origin_target(dnode, lv->size, real_dlid))
@@ -1025,13 +998,13 @@ static int _add_snapshot_merge_target_to_dtree(struct dev_manager *dm,
 	const char *origin_dlid, *cow_dlid, *merge_dlid;
 	struct lv_segment *merging_cow_seg = find_merging_cow(lv);
 
-	if (!(origin_dlid = build_dlid(dm, lv->lvid.s, "real")))
+	if (!(origin_dlid = build_dm_uuid(dm->mem, lv->lvid.s, "real")))
 		return_0;
 
-	if (!(cow_dlid = build_dlid(dm, merging_cow_seg->cow->lvid.s, "cow")))
+	if (!(cow_dlid = build_dm_uuid(dm->mem, merging_cow_seg->cow->lvid.s, "cow")))
 		return_0;
 
-	if (!(merge_dlid = build_dlid(dm, merging_cow_seg->cow->lvid.s, NULL)))
+	if (!(merge_dlid = build_dm_uuid(dm->mem, merging_cow_seg->cow->lvid.s, NULL)))
 		return_0;
 
 	if (!dm_tree_node_add_snapshot_merge_target(dnode, lv->size, origin_dlid,
@@ -1056,10 +1029,10 @@ static int _add_snapshot_target_to_dtree(struct dev_manager *dm,
 		return 0;
 	}
 
-	if (!(origin_dlid = build_dlid(dm, snap_seg->origin->lvid.s, "real")))
+	if (!(origin_dlid = build_dm_uuid(dm->mem, snap_seg->origin->lvid.s, "real")))
 		return_0;
 
-	if (!(cow_dlid = build_dlid(dm, snap_seg->cow->lvid.s, "cow")))
+	if (!(cow_dlid = build_dm_uuid(dm->mem, snap_seg->cow->lvid.s, "cow")))
 		return_0;
 
 	size = (uint64_t) snap_seg->len * snap_seg->origin->vg->extent_size;
@@ -1218,7 +1191,7 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 	if (!(name = build_dm_name(dm->mem, lv->vg->name, lv->name, layer)))
 		return_0;
 
-	if (!(dlid = build_dlid(dm, lv->lvid.s, layer)))
+	if (!(dlid = build_dm_uuid(dm->mem, lv->lvid.s, layer)))
 		return_0;
 
 	/* We've already processed this node if it already has a context ptr */
@@ -1421,7 +1394,7 @@ static int _tree_action(struct dev_manager *dm, struct logical_volume *lv, actio
 		goto out;
 	}
 
-	if (!(dlid = build_dlid(dm, lv->lvid.s, NULL)))
+	if (!(dlid = build_dm_uuid(dm->mem, lv->lvid.s, NULL)))
 		goto_out;
 
 	/* Only process nodes with uuid of "LVM-" plus VG id. */
diff --git a/lib/activate/targets.h b/lib/activate/targets.h
index 70a4e2f..ac68c5b 100644
--- a/lib/activate/targets.h
+++ b/lib/activate/targets.h
@@ -29,6 +29,4 @@ int add_areas_line(struct dev_manager *dm, struct lv_segment *seg,
 int build_dev_string(struct dev_manager *dm, char *dlid, char *devbuf,
 		     size_t bufsize, const char *desc);
 
-char *build_dlid(struct dev_manager *dm, const char *lvid, const char *layer);
-
 #endif
diff --git a/lib/mirror/mirrored.c b/lib/mirror/mirrored.c
index f82b452..ee0ee64 100644
--- a/lib/mirror/mirrored.c
+++ b/lib/mirror/mirrored.c
@@ -239,7 +239,7 @@ static int _mirrored_target_percent(void **target_state,
 	return 1;
 }
 
-static int _add_log(struct dev_manager *dm, struct lv_segment *seg,
+static int _add_log(struct dm_pool *mem, struct lv_segment *seg,
 		    struct dm_tree_node *node, uint32_t area_count, uint32_t region_size)
 {
 	unsigned clustered = 0;
@@ -256,14 +256,14 @@ static int _add_log(struct dev_manager *dm, struct lv_segment *seg,
 
 	if (seg->log_lv) {
 		/* If disk log, use its UUID */
-		if (!(log_dlid = build_dlid(dm, seg->log_lv->lvid.s, NULL))) {
+		if (!(log_dlid = build_dm_uuid(mem, seg->log_lv->lvid.s, NULL))) {
 			log_error("Failed to build uuid for log LV %s.",
 				  seg->log_lv->name);
 			return 0;
 		}
 	} else {
 		/* If core log, use mirror's UUID and set DM_CORELOG flag */
-		if (!(log_dlid = build_dlid(dm, seg->lv->lvid.s, NULL))) {
+		if (!(log_dlid = build_dm_uuid(mem, seg->lv->lvid.s, NULL))) {
 			log_error("Failed to build uuid for mirror LV %s.",
 				  seg->lv->name);
 			return 0;
@@ -342,7 +342,7 @@ static int _mirrored_add_target_line(struct dev_manager *dm, struct dm_pool *mem
 	if (!dm_tree_node_add_mirror_target(node, len))
 		return_0;
 
-	if ((r = _add_log(dm, seg, node, area_count, region_size)) <= 0) {
+	if ((r = _add_log(mem, seg, node, area_count, region_size)) <= 0) {
 		stack;
 		return r;
 	}
@@ -422,7 +422,7 @@ static int _get_mirror_dso_path(struct cmd_context *cmd, char **dso)
 	return 1;
 }
 
-static struct dm_event_handler *_create_dm_event_handler(const char *dmname,
+static struct dm_event_handler *_create_dm_event_handler(const char *dmuuid,
 							 const char *dso,
 							 enum dm_event_mask mask)
 {
@@ -434,7 +434,7 @@ static struct dm_event_handler *_create_dm_event_handler(const char *dmname,
        if (dm_event_handler_set_dso(dmevh, dso))
 		goto fail;
 
-	if (dm_event_handler_set_dev_name(dmevh, dmname))
+	if (dm_event_handler_set_uuid(dmevh, dmuuid))
 		goto fail;
 
 	dm_event_handler_set_event_mask(dmevh, mask);
@@ -447,7 +447,7 @@ fail:
 
 static int _target_monitored(struct lv_segment *seg, int *pending)
 {
-	char *dso, *name;
+	char *dso, *uuid;
 	struct logical_volume *lv;
 	struct volume_group *vg;
 	enum dm_event_mask evmask = 0;
@@ -460,10 +460,10 @@ static int _target_monitored(struct lv_segment *seg, int *pending)
 	if (!_get_mirror_dso_path(vg->cmd, &dso))
 		return_0;
 
-	if (!(name = build_dm_name(vg->cmd->mem, vg->name, lv->name, NULL)))
+	if (!(uuid = build_dm_uuid(vg->cmd->mem, lv->lvid.s, NULL)))
 		return_0;
 
-	if (!(dmevh = _create_dm_event_handler(name, dso, DM_EVENT_ALL_ERRORS)))
+	if (!(dmevh = _create_dm_event_handler(uuid, dso, DM_EVENT_ALL_ERRORS)))
 		return_0;
 
 	if (dm_event_get_registered_device(dmevh, 0)) {
@@ -486,7 +486,7 @@ static int _target_monitored(struct lv_segment *seg, int *pending)
 static int _target_set_events(struct lv_segment *seg,
 			      int evmask __attribute((unused)), int set)
 {
-	char *dso, *name;
+	char *dso, *uuid;
 	struct logical_volume *lv;
 	struct volume_group *vg;
 	struct dm_event_handler *dmevh;
@@ -498,10 +498,10 @@ static int _target_set_events(struct lv_segment *seg,
 	if (!_get_mirror_dso_path(vg->cmd, &dso))
 		return_0;
 
-	if (!(name = build_dm_name(vg->cmd->mem, vg->name, lv->name, NULL)))
+	if (!(uuid = build_dm_uuid(vg->cmd->mem, lv->lvid.s, NULL)))
 		return_0;
 
-	if (!(dmevh = _create_dm_event_handler(name, dso, DM_EVENT_ALL_ERRORS)))
+	if (!(dmevh = _create_dm_event_handler(uuid, dso, DM_EVENT_ALL_ERRORS)))
 		return_0;
 
 	r = set ? dm_event_register_handler(dmevh) : dm_event_unregister_handler(dmevh);
@@ -509,7 +509,7 @@ static int _target_set_events(struct lv_segment *seg,
 	if (!r)
 		return_0;
 
-	log_info("%s %s for events", set ? "Monitored" : "Unmonitored", name);
+	log_info("%s %s for events", set ? "Monitored" : "Unmonitored", uuid);
 
 	return 1;
 }
diff --git a/lib/misc/lvm-string.c b/lib/misc/lvm-string.c
index 5a7de96..f79c8b0 100644
--- a/lib/misc/lvm-string.c
+++ b/lib/misc/lvm-string.c
@@ -170,6 +170,27 @@ char *build_dm_name(struct dm_pool *mem, const char *vgname,
 	return r;
 }
 
+char *build_dm_uuid(struct dm_pool *mem, const char *lvid, const char *layer)
+{
+	char *dmuuid;
+	size_t len;
+
+	if (!layer)
+		layer = "";
+
+	len = sizeof(UUID_PREFIX) + strlen(lvid) + strlen(layer) + 1;
+
+	if (!(dmuuid = dm_pool_alloc(mem, len))) {
+		log_error("build_dm_name: Allocation failed for %" PRIsize_t
+			  " %s %s.", len, lvid, layer);
+		return NULL;
+	}
+
+	sprintf(dmuuid, UUID_PREFIX "%s%s%s", lvid, (*layer) ? "-" : "", layer);
+
+	return dmuuid;
+}
+
 /*
  * Copies a string, quoting double quotes with backslashes.
  */
diff --git a/lib/misc/lvm-string.h b/lib/misc/lvm-string.h
index 7f50a97..d5e5449 100644
--- a/lib/misc/lvm-string.h
+++ b/lib/misc/lvm-string.h
@@ -20,6 +20,7 @@
 #include <stdarg.h>
 
 #define NAME_LEN 128
+#define UUID_PREFIX "LVM-"
 
 struct pool;
 
@@ -28,6 +29,8 @@ int emit_to_buffer(char **buffer, size_t *size, const char *fmt, ...)
 
 char *build_dm_name(struct dm_pool *mem, const char *vg,
                     const char *lv, const char *layer);
+char *build_dm_uuid(struct dm_pool *mem, const char *lvid,
+		    const char *layer);
 
 int validate_name(const char *n);
 
diff --git a/lib/snapshot/snapshot.c b/lib/snapshot/snapshot.c
index 0a8212a..62766cb 100644
--- a/lib/snapshot/snapshot.c
+++ b/lib/snapshot/snapshot.c
@@ -185,7 +185,7 @@ static int _get_snapshot_dso_path(struct cmd_context *cmd, char **dso)
 	return 1;
 }
 
-static struct dm_event_handler *_create_dm_event_handler(const char *dmname,
+static struct dm_event_handler *_create_dm_event_handler(const char *dmuuid,
 							 const char *dso,
 							 const int timeout,
 							 enum dm_event_mask mask)
@@ -198,7 +198,7 @@ static struct dm_event_handler *_create_dm_event_handler(const char *dmname,
        if (dm_event_handler_set_dso(dmevh, dso))
 		goto fail;
 
-	if (dm_event_handler_set_dev_name(dmevh, dmname))
+	if (dm_event_handler_set_uuid(dmevh, dmuuid))
 		goto fail;
 
 	dm_event_handler_set_timeout(dmevh, timeout);
@@ -212,7 +212,7 @@ fail:
 
 static int _target_registered(struct lv_segment *seg, int *pending)
 {
-	char *dso, *name;
+	char *dso, *uuid;
 	struct logical_volume *lv;
 	struct volume_group *vg;
 	enum dm_event_mask evmask = 0;
@@ -225,10 +225,10 @@ static int _target_registered(struct lv_segment *seg, int *pending)
 	if (!_get_snapshot_dso_path(vg->cmd, &dso))
 		return_0;
 
-	if (!(name = build_dm_name(vg->cmd->mem, vg->name, seg->cow->name, NULL)))
+	if (!(uuid = build_dm_uuid(vg->cmd->mem, seg->cow->lvid.s, NULL)))
 		return_0;
 
-	if (!(dmevh = _create_dm_event_handler(name, dso, 0, DM_EVENT_ALL_ERRORS)))
+	if (!(dmevh = _create_dm_event_handler(uuid, dso, 0, DM_EVENT_ALL_ERRORS)))
 		return_0;
 
 	if (dm_event_get_registered_device(dmevh, 0)) {
@@ -251,7 +251,7 @@ static int _target_registered(struct lv_segment *seg, int *pending)
 static int _target_set_events(struct lv_segment *seg,
 			      int events __attribute((unused)), int set)
 {
-	char *dso, *name;
+	char *dso, *uuid;
 	struct volume_group *vg = seg->lv->vg;
 	struct dm_event_handler *dmevh;
 	int r;
@@ -259,11 +259,11 @@ static int _target_set_events(struct lv_segment *seg,
 	if (!_get_snapshot_dso_path(vg->cmd, &dso))
 		return_0;
 
-	if (!(name = build_dm_name(vg->cmd->mem, vg->name, seg->cow->name, NULL)))
+	if (!(uuid = build_dm_uuid(vg->cmd->mem, seg->cow->lvid.s, NULL)))
 		return_0;
 
 	/* FIXME: make timeout configurable */
-	if (!(dmevh = _create_dm_event_handler(name, dso, 10,
+	if (!(dmevh = _create_dm_event_handler(uuid, dso, 10,
 		DM_EVENT_ALL_ERRORS|DM_EVENT_TIMEOUT)))
 		return_0;
 
@@ -272,7 +272,7 @@ static int _target_set_events(struct lv_segment *seg,
 	if (!r)
 		return_0;
 
-	log_info("%s %s for events", set ? "Registered" : "Unregistered", name);
+	log_info("%s %s for events", set ? "Registered" : "Unregistered", uuid);
 
 	return 1;
 }


