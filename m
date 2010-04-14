From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 14 Apr 2010 13:01:46 -0000
Subject: LVM2 ./WHATS_NEW daemons/dmeventd/libdevmapper ...
Message-ID: <20100414130146.2801.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2010-04-14 13:01:44

Modified files:
	.              : WHATS_NEW 
	daemons/dmeventd: libdevmapper-event.c 
	lib/activate   : dev_manager.c targets.h 
	lib/mirror     : mirrored.c 
	lib/misc       : lvm-string.c lvm-string.h 
	lib/snapshot   : snapshot.c 

Log message:
	Use UUIDs instead of names while processing event handlers.
	
	Internally, we used DM names instead of UUIDs while processing event
	handlers. This caused problems while trying to vgrename a VG with active LVs
	where the names are being changed and so the devices were not found then.
	The patch also contains a little bit of refactoring, moving "build_dlid" code
	found in dev_manager.c to "build_dm_uuid", now in lvm-string.c (so we have
	build_dm_uuid and build_dm_name at one place).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1517&r2=1.1518
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/libdevmapper-event.c.diff?cvsroot=lvm2&r1=1.31&r2=1.32
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.184&r2=1.185
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/targets.h.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mirror/mirrored.c.diff?cvsroot=lvm2&r1=1.66&r2=1.67
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-string.c.diff?cvsroot=lvm2&r1=1.18&r2=1.19
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-string.h.diff?cvsroot=lvm2&r1=1.18&r2=1.19
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/snapshot/snapshot.c.diff?cvsroot=lvm2&r1=1.45&r2=1.46

--- LVM2/WHATS_NEW	2010/04/14 02:19:49	1.1517
+++ LVM2/WHATS_NEW	2010/04/14 13:01:38	1.1518
@@ -1,5 +1,6 @@
 Version 2.02.63 -  
 ================================
+  Use UUIDs instead of names while processing event handlers.
   Only pass visible LVs to tools in cmdline VG name/tag expansions without -a.
   Use typedefs for toollib process_each functions.
   Use C locales and use_mlockall for clvmd.
--- LVM2/daemons/dmeventd/libdevmapper-event.c	2010/03/24 11:36:48	1.31
+++ LVM2/daemons/dmeventd/libdevmapper-event.c	2010/04/14 13:01:42	1.32
@@ -113,7 +113,7 @@
 	_dm_event_handler_clear_dev_info(dmevh);
 
 	dmevh->uuid = dm_strdup(uuid);
-	if (!dmevh->dev_name)
+	if (!dmevh->uuid)
 		return -ENOMEM;
 	return 0;
 }
--- LVM2/lib/activate/dev_manager.c	2010/04/07 20:04:42	1.184
+++ LVM2/lib/activate/dev_manager.c	2010/04/14 13:01:42	1.185
@@ -31,7 +31,6 @@
 #include <dirent.h>
 
 #define MAX_TARGET_PARAMSIZE 50000
-#define UUID_PREFIX "LVM-"
 
 typedef enum {
 	PRELOAD,
@@ -59,32 +58,6 @@
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
@@ -238,7 +211,7 @@
 		return 0;
 	}
 
-	if (!(dlid = _build_dlid(mem, lv->lvid.s, NULL))) {
+	if (!(dlid = build_dm_uuid(mem, lv->lvid.s, NULL))) {
 		log_error("dlid build failed for %s", lv->name);
 		return 0;
 	}
@@ -258,7 +231,7 @@
 	struct dm_tree_node *dnode;
 	const struct dm_info *dinfo;
 
-	if (!(dlid = _build_dlid(mem, lv->lvid.s, NULL))) {
+	if (!(dlid = build_dm_uuid(mem, lv->lvid.s, NULL))) {
 		log_error("dlid build failed for %s", lv->name);
 		return NULL;
 	}
@@ -370,7 +343,7 @@
 	char *type = NULL;
 	char *params = NULL;
 
-	if (!(dlid = build_dlid(dm, lv->lvid.s, layer)))
+	if (!(dlid = build_dm_uuid(dm->mem, lv->lvid.s, layer)))
 		return_0;
 
 	if (!(dmt = _setup_task(NULL, dlid, 0,
@@ -631,7 +604,7 @@
 	if (!(name = build_dm_name(dm->mem, lv->vg->name, lv->name, NULL)))
 		return_0;
 
-	if (!(dlid = build_dlid(dm, lv->lvid.s, NULL)))
+	if (!(dlid = build_dm_uuid(dm->mem, lv->lvid.s, NULL)))
 		return_0;
 
 	/*
@@ -667,7 +640,7 @@
 
 	/* FIXME dm_pool_free ? */
 
-	if (!(dlid = build_dlid(dm, lv->lvid.s, suffix))) {
+	if (!(dlid = build_dm_uuid(dm->mem, lv->lvid.s, suffix))) {
 		log_error("dlid build failed for %s", lv->name);
 		return 0;
 	}
@@ -790,7 +763,7 @@
 	if (!(name = build_dm_name(dm->mem, lv->vg->name, lv->name, layer)))
 		return_0;
 
-	if (!(dlid = build_dlid(dm, lv->lvid.s, layer)))
+	if (!(dlid = build_dm_uuid(dm->mem, lv->lvid.s, layer)))
 		return_0;
 
 	log_debug("Getting device info for %s [%s]", name, dlid);
@@ -925,7 +898,7 @@
 
 	sprintf(errid, "missing_%d_%d", segno, s);
 
-	if (!(id = build_dlid(dm, seg->lv->lvid.s, errid)))
+	if (!(id = build_dm_uuid(dm->mem, seg->lv->lvid.s, errid)))
 		return_NULL;
 
 	if (!(name = build_dm_name(dm->mem, seg->lv->vg->name,
@@ -987,9 +960,9 @@
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
@@ -1009,7 +982,7 @@
 {
 	const char *real_dlid;
 
-	if (!(real_dlid = build_dlid(dm, lv->lvid.s, "real")))
+	if (!(real_dlid = build_dm_uuid(dm->mem, lv->lvid.s, "real")))
 		return_0;
 
 	if (!dm_tree_node_add_snapshot_origin_target(dnode, lv->size, real_dlid))
@@ -1025,13 +998,13 @@
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
@@ -1056,10 +1029,10 @@
 		return 0;
 	}
 
-	if (!(origin_dlid = build_dlid(dm, snap_seg->origin->lvid.s, "real")))
+	if (!(origin_dlid = build_dm_uuid(dm->mem, snap_seg->origin->lvid.s, "real")))
 		return_0;
 
-	if (!(cow_dlid = build_dlid(dm, snap_seg->cow->lvid.s, "cow")))
+	if (!(cow_dlid = build_dm_uuid(dm->mem, snap_seg->cow->lvid.s, "cow")))
 		return_0;
 
 	size = (uint64_t) snap_seg->len * snap_seg->origin->vg->extent_size;
@@ -1218,7 +1191,7 @@
 	if (!(name = build_dm_name(dm->mem, lv->vg->name, lv->name, layer)))
 		return_0;
 
-	if (!(dlid = build_dlid(dm, lv->lvid.s, layer)))
+	if (!(dlid = build_dm_uuid(dm->mem, lv->lvid.s, layer)))
 		return_0;
 
 	/* We've already processed this node if it already has a context ptr */
@@ -1421,7 +1394,7 @@
 		goto out;
 	}
 
-	if (!(dlid = build_dlid(dm, lv->lvid.s, NULL)))
+	if (!(dlid = build_dm_uuid(dm->mem, lv->lvid.s, NULL)))
 		goto_out;
 
 	/* Only process nodes with uuid of "LVM-" plus VG id. */
--- LVM2/lib/activate/targets.h	2007/08/20 20:55:24	1.8
+++ LVM2/lib/activate/targets.h	2010/04/14 13:01:42	1.9
@@ -29,6 +29,4 @@
 int build_dev_string(struct dev_manager *dm, char *dlid, char *devbuf,
 		     size_t bufsize, const char *desc);
 
-char *build_dlid(struct dev_manager *dm, const char *lvid, const char *layer);
-
 #endif
--- LVM2/lib/mirror/mirrored.c	2010/01/07 14:46:51	1.66
+++ LVM2/lib/mirror/mirrored.c	2010/04/14 13:01:42	1.67
@@ -239,7 +239,7 @@
 	return 1;
 }
 
-static int _add_log(struct dev_manager *dm, struct lv_segment *seg,
+static int _add_log(struct dm_pool *mem, struct lv_segment *seg,
 		    struct dm_tree_node *node, uint32_t area_count, uint32_t region_size)
 {
 	unsigned clustered = 0;
@@ -256,14 +256,14 @@
 
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
@@ -342,7 +342,7 @@
 	if (!dm_tree_node_add_mirror_target(node, len))
 		return_0;
 
-	if ((r = _add_log(dm, seg, node, area_count, region_size)) <= 0) {
+	if ((r = _add_log(mem, seg, node, area_count, region_size)) <= 0) {
 		stack;
 		return r;
 	}
@@ -422,7 +422,7 @@
 	return 1;
 }
 
-static struct dm_event_handler *_create_dm_event_handler(const char *dmname,
+static struct dm_event_handler *_create_dm_event_handler(const char *dmuuid,
 							 const char *dso,
 							 enum dm_event_mask mask)
 {
@@ -434,7 +434,7 @@
        if (dm_event_handler_set_dso(dmevh, dso))
 		goto fail;
 
-	if (dm_event_handler_set_dev_name(dmevh, dmname))
+	if (dm_event_handler_set_uuid(dmevh, dmuuid))
 		goto fail;
 
 	dm_event_handler_set_event_mask(dmevh, mask);
@@ -447,7 +447,7 @@
 
 static int _target_monitored(struct lv_segment *seg, int *pending)
 {
-	char *dso, *name;
+	char *dso, *uuid;
 	struct logical_volume *lv;
 	struct volume_group *vg;
 	enum dm_event_mask evmask = 0;
@@ -460,10 +460,10 @@
 	if (!_get_mirror_dso_path(vg->cmd, &dso))
 		return_0;
 
-	if (!(name = build_dm_name(vg->cmd->mem, vg->name, lv->name, NULL)))
+	if (!(uuid = build_dm_uuid(vg->cmd->mem, lv->lvid.s, NULL)))
 		return_0;
 
-	if (!(dmevh = _create_dm_event_handler(name, dso, DM_EVENT_ALL_ERRORS)))
+	if (!(dmevh = _create_dm_event_handler(uuid, dso, DM_EVENT_ALL_ERRORS)))
 		return_0;
 
 	if (dm_event_get_registered_device(dmevh, 0)) {
@@ -486,7 +486,7 @@
 static int _target_set_events(struct lv_segment *seg,
 			      int evmask __attribute((unused)), int set)
 {
-	char *dso, *name;
+	char *dso, *uuid;
 	struct logical_volume *lv;
 	struct volume_group *vg;
 	struct dm_event_handler *dmevh;
@@ -498,10 +498,10 @@
 	if (!_get_mirror_dso_path(vg->cmd, &dso))
 		return_0;
 
-	if (!(name = build_dm_name(vg->cmd->mem, vg->name, lv->name, NULL)))
+	if (!(uuid = build_dm_uuid(vg->cmd->mem, lv->lvid.s, NULL)))
 		return_0;
 
-	if (!(dmevh = _create_dm_event_handler(name, dso, DM_EVENT_ALL_ERRORS)))
+	if (!(dmevh = _create_dm_event_handler(uuid, dso, DM_EVENT_ALL_ERRORS)))
 		return_0;
 
 	r = set ? dm_event_register_handler(dmevh) : dm_event_unregister_handler(dmevh);
@@ -509,7 +509,7 @@
 	if (!r)
 		return_0;
 
-	log_info("%s %s for events", set ? "Monitored" : "Unmonitored", name);
+	log_info("%s %s for events", set ? "Monitored" : "Unmonitored", uuid);
 
 	return 1;
 }
--- LVM2/lib/misc/lvm-string.c	2009/12/11 13:16:39	1.18
+++ LVM2/lib/misc/lvm-string.c	2010/04/14 13:01:43	1.19
@@ -170,6 +170,27 @@
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
--- LVM2/lib/misc/lvm-string.h	2008/03/12 16:03:22	1.18
+++ LVM2/lib/misc/lvm-string.h	2010/04/14 13:01:43	1.19
@@ -20,6 +20,7 @@
 #include <stdarg.h>
 
 #define NAME_LEN 128
+#define UUID_PREFIX "LVM-"
 
 struct pool;
 
@@ -28,6 +29,8 @@
 
 char *build_dm_name(struct dm_pool *mem, const char *vg,
                     const char *lv, const char *layer);
+char *build_dm_uuid(struct dm_pool *mem, const char *lvid,
+		    const char *layer);
 
 int validate_name(const char *n);
 
--- LVM2/lib/snapshot/snapshot.c	2010/01/15 17:46:08	1.45
+++ LVM2/lib/snapshot/snapshot.c	2010/04/14 13:01:43	1.46
@@ -185,7 +185,7 @@
 	return 1;
 }
 
-static struct dm_event_handler *_create_dm_event_handler(const char *dmname,
+static struct dm_event_handler *_create_dm_event_handler(const char *dmuuid,
 							 const char *dso,
 							 const int timeout,
 							 enum dm_event_mask mask)
@@ -198,7 +198,7 @@
        if (dm_event_handler_set_dso(dmevh, dso))
 		goto fail;
 
-	if (dm_event_handler_set_dev_name(dmevh, dmname))
+	if (dm_event_handler_set_uuid(dmevh, dmuuid))
 		goto fail;
 
 	dm_event_handler_set_timeout(dmevh, timeout);
@@ -212,7 +212,7 @@
 
 static int _target_registered(struct lv_segment *seg, int *pending)
 {
-	char *dso, *name;
+	char *dso, *uuid;
 	struct logical_volume *lv;
 	struct volume_group *vg;
 	enum dm_event_mask evmask = 0;
@@ -225,10 +225,10 @@
 	if (!_get_snapshot_dso_path(vg->cmd, &dso))
 		return_0;
 
-	if (!(name = build_dm_name(vg->cmd->mem, vg->name, seg->cow->name, NULL)))
+	if (!(uuid = build_dm_uuid(vg->cmd->mem, seg->cow->lvid.s, NULL)))
 		return_0;
 
-	if (!(dmevh = _create_dm_event_handler(name, dso, 0, DM_EVENT_ALL_ERRORS)))
+	if (!(dmevh = _create_dm_event_handler(uuid, dso, 0, DM_EVENT_ALL_ERRORS)))
 		return_0;
 
 	if (dm_event_get_registered_device(dmevh, 0)) {
@@ -251,7 +251,7 @@
 static int _target_set_events(struct lv_segment *seg,
 			      int events __attribute((unused)), int set)
 {
-	char *dso, *name;
+	char *dso, *uuid;
 	struct volume_group *vg = seg->lv->vg;
 	struct dm_event_handler *dmevh;
 	int r;
@@ -259,11 +259,11 @@
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
 
@@ -272,7 +272,7 @@
 	if (!r)
 		return_0;
 
-	log_info("%s %s for events", set ? "Registered" : "Unregistered", name);
+	log_info("%s %s for events", set ? "Registered" : "Unregistered", uuid);
 
 	return 1;
 }


