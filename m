From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 26 Nov 2015 08:48:48 +0000 (UTC)
Subject: master - cleanup: remove unused code
Message-ID: <20151126084848.E17C560F92@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b7b59ad9323cd38889e78068813c311170920d9d
Commit:        b7b59ad9323cd38889e78068813c311170920d9d
Parent:        528695ec2004dcadaacba99d51685ac4a0582ea7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Nov 25 15:45:19 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 26 09:27:37 2015 +0100

cleanup: remove unused code

Remove long outstand unused code lines, which were already
been obsoleted by other code.

Statuses and snapshot tree creation is already handled differently.

Also drop some 'extra' log_error() and use only stack;
since error has already been reported.
---
 lib/activate/activate.c    |    7 --
 lib/activate/dev_manager.c |  218 ++------------------------------------------
 2 files changed, 7 insertions(+), 218 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 4bcfcd6..47c675c 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1977,13 +1977,6 @@ int lv_suspend_if_active(struct cmd_context *cmd, const char *lvid_s, unsigned o
 	return _lv_suspend(cmd, lvid_s, &laopts, 0, lv, lv_pre);
 }
 
-/* No longer used */
-/***********
-int lv_suspend(struct cmd_context *cmd, const char *lvid_s)
-{
-	return _lv_suspend(cmd, lvid_s, 1);
-}
-***********/
 
 static int _lv_resume(struct cmd_context *cmd, const char *lvid_s,
 		      struct lv_activate_opts *laopts, int error_if_not_active,
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 9110ecb..328d8ac 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -794,15 +794,12 @@ int dev_manager_info(struct dm_pool *mem, const struct logical_volume *lv,
 	char *dlid, *name;
 	int r;
 
-	if (!(name = dm_build_dm_name(mem, lv->vg->name, lv->name, layer))) {
-		log_error("name build failed for %s", lv->name);
-		return 0;
-	}
+	if (!(name = dm_build_dm_name(mem, lv->vg->name, lv->name, layer)))
+		return_0;
 
 	if (!(dlid = build_dm_uuid(mem, lv, layer))) {
-		log_error("dlid build failed for %s", name);
 		r = 0;
-		goto out;
+		goto_out;
 	}
 
 	log_debug_activation("Getting device info for %s [%s]", name, dlid);
@@ -823,10 +820,8 @@ static const struct dm_info *_cached_dm_info(struct dm_pool *mem,
 	const struct dm_tree_node *dnode;
 	const struct dm_info *dinfo = NULL;
 
-	if (!(dlid = build_dm_uuid(mem, lv, layer))) {
-		log_error("Failed to build dlid for %s.", lv->name);
-		return NULL;
-	}
+	if (!(dlid = build_dm_uuid(mem, lv, layer)))
+		return_NULL;
 
 	if (!(dnode = dm_tree_find_node_by_uuid(dtree, dlid)))
 		goto_out;
@@ -844,83 +839,6 @@ out:
 	return dinfo;
 }
 
-#if 0
-/* FIXME Interface must cope with multiple targets */
-static int _status_run(const char *name, const char *uuid,
-		       unsigned long long *s, unsigned long long *l,
-		       char **t, uint32_t t_size, char **p, uint32_t p_size)
-{
-	int r = 0;
-	struct dm_task *dmt;
-	struct dm_info info;
-	void *next = NULL;
-	uint64_t start, length;
-	char *type = NULL;
-	char *params = NULL;
-
-	if (!(dmt = _setup_task(name, uuid, 0, DM_DEVICE_STATUS, 0, 0, 0)))
-		return_0;
-
-	if (!dm_task_run(dmt))
-		goto_out;
-
-	if (!dm_task_get_info(dmt, &info) || !info.exists)
-		goto_out;
-
-	do {
-		next = dm_get_next_target(dmt, next, &start, &length,
-					  &type, &params);
-		if (type) {
-			*s = start;
-			*l = length;
-			/* Make sure things are null terminated */
-			strncpy(*t, type, t_size);
-			(*t)[t_size - 1] = '\0';
-			strncpy(*p, params, p_size);
-			(*p)[p_size - 1] = '\0';
-
-			r = 1;
-			/* FIXME Cope with multiple targets! */
-			break;
-		}
-
-	} while (next);
-
-      out:
-	dm_task_destroy(dmt);
-	return r;
-}
-
-static int _status(const char *name, const char *uuid,
-		   unsigned long long *start, unsigned long long *length,
-		   char **type, uint32_t type_size, char **params,
-		   uint32_t param_size) __attribute__ ((unused));
-
-static int _status(const char *name, const char *uuid,
-		   unsigned long long *start, unsigned long long *length,
-		   char **type, uint32_t type_size, char **params,
-		   uint32_t param_size)
-{
-	if (uuid && *uuid) {
-		if (_status_run(NULL, uuid, start, length, type,
-				type_size, params, param_size) &&
-		    *params)
-			return 1;
-		else if (_status_run(NULL, uuid + sizeof(UUID_PREFIX) - 1, start,
-				     length, type, type_size, params,
-				     param_size) &&
-			 *params)
-			return 1;
-	}
-
-	if (name && _status_run(name, NULL, start, length, type, type_size,
-				params, param_size))
-		return 1;
-
-	return 0;
-}
-#endif
-
 int lv_has_target_type(struct dm_pool *mem, const struct logical_volume *lv,
 		       const char *layer, const char *target_type)
 {
@@ -1333,10 +1251,8 @@ int dev_manager_mirror_percent(struct dev_manager *dm,
 	if (!(name = dm_build_dm_name(dm->mem, lv->vg->name, lv->name, layer)))
 		return_0;
 
-	if (!(dlid = build_dm_uuid(dm->mem, lv, layer))) {
-		log_error("dlid build failed for %s", lv->name);
-		return 0;
-	}
+	if (!(dlid = build_dm_uuid(dm->mem, lv, layer)))
+		return_0;
 
 	log_debug_activation("Getting device %s status percentage for %s",
 			     target_type, name);
@@ -1497,66 +1413,6 @@ out:
 	return r;
 }
 
-//FIXME: Can we get rid of this crap below?
-#if 0
-	log_very_verbose("%s %s", sus ? "Suspending" : "Resuming", name);
-
-	log_verbose("Loading %s", dl->name);
-			log_very_verbose("Activating %s read-only", dl->name);
-	log_very_verbose("Activated %s %s %03u:%03u", dl->name,
-			 dl->dlid, dl->info.major, dl->info.minor);
-
-	if (_get_flag(dl, VISIBLE))
-		log_verbose("Removing %s", dl->name);
-	else
-		log_very_verbose("Removing %s", dl->name);
-
-	log_debug_activation("Adding target: %" PRIu64 " %" PRIu64 " %s %s",
-		  extent_size * seg->le, extent_size * seg->len, target, params);
-
-	log_debug_activation("Adding target: 0 %" PRIu64 " snapshot-origin %s",
-		  dl->lv->size, params);
-	log_debug_activation("Adding target: 0 %" PRIu64 " snapshot %s", size, params);
-	log_debug_activation("Getting device info for %s", dl->name);
-
-	/* Rename? */
-		if ((suffix = strrchr(dl->dlid + sizeof(UUID_PREFIX) - 1, '-')))
-			suffix++;
-		new_name = dm_build_dm_name(dm->mem, dm->vg_name, dl->lv->name,
-					suffix);
-
-static int _belong_to_vg(const char *vgname, const char *name)
-{
-	const char *v = vgname, *n = name;
-
-	while (*v) {
-		if ((*v != *n) || (*v == '-' && *(++n) != '-'))
-			return 0;
-		v++, n++;
-	}
-
-	if (*n == '-' && *(n + 1) != '-')
-		return 1;
-	else
-		return 0;
-}
-
-	if (!(snap_seg = find_snapshot(lv)))
-		return 1;
-
-	old_origin = snap_seg->origin;
-
-	/* Was this the last active snapshot with this origin? */
-	dm_list_iterate_items(lvl, active_head) {
-		active = lvl->lv;
-		if ((snap_seg = find_snapshot(active)) &&
-		    snap_seg->origin == old_origin) {
-			return 1;
-		}
-	}
-
-#endif
-
 int dev_manager_thin_pool_status(struct dev_manager *dm,
 				 const struct logical_volume *lv,
 				 struct dm_status_thin_pool **status,
@@ -2734,7 +2590,6 @@ static int _add_new_external_lv_to_dtree(struct dev_manager *dm,
 	 * needed because of conversion of thin which could have been
 	 * also an old-snapshot to external origin.
 	 */
-	//if (lv_is_origin(external_lv))
 	dm_list_iterate_items(sl, &external_lv->segs_using_this_lv)
 		if ((sl->seg->external_lv == external_lv) &&
 		    /* Add only active layered devices (also avoids loop) */
@@ -2835,59 +2690,6 @@ static int _add_segment_to_dtree(struct dev_manager *dm,
 	return 1;
 }
 
-#if 0
-static int _set_udev_flags_for_children(struct dev_manager *dm,
-					struct volume_group *vg,
-					struct dm_tree_node *dnode)
-{
-	char *p;
-	const char *uuid;
-	void *handle = NULL;
-	struct dm_tree_node *child;
-	const struct dm_info *info;
-	struct lv_list *lvl;
-
-	while ((child = dm_tree_next_child(&handle, dnode, 0))) {
-		/* Ignore root node */
-		if (!(info  = dm_tree_node_get_info(child)) || !info->exists)
-			continue;
-
-		if (!(uuid = dm_tree_node_get_uuid(child))) {
-			log_error(INTERNAL_ERROR
-				  "Failed to get uuid for %" PRIu32 ":%" PRIu32,
-				  info->major, info->minor);
-			continue;
-		}
-
-		/* Ignore non-LVM devices */
-		if (!(p = strstr(uuid, UUID_PREFIX)))
-			continue;
-		p += strlen(UUID_PREFIX);
-
-		/* Ignore LVs that belong to different VGs (due to stacking) */
-		if (strncmp(p, (char *)vg->id.uuid, ID_LEN))
-			continue;
-
-		/* Ignore LVM devices with 'layer' suffixes */
-		if (strrchr(p, '-'))
-			continue;
-
-		if (!(lvl = find_lv_in_vg_by_lvid(vg, (const union lvid *)p))) {
-			log_error(INTERNAL_ERROR
-				  "%s (%" PRIu32 ":%" PRIu32 ") not found in VG",
-				  dm_tree_node_get_name(child),
-				  info->major, info->minor);
-			return 0;
-		}
-
-		dm_tree_node_set_udev_flags(child,
-					    _get_udev_flags(dm, lvl->lv, NULL, 0, 0));
-	}
-
-	return 1;
-}
-#endif
-
 static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 				const struct logical_volume *lv, struct lv_activate_opts *laopts,
 				const char *layer)
@@ -3073,12 +2875,6 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 			if (!_add_new_lv_to_dtree(dm, dtree, sl->seg->lv, laopts, NULL))
 				return_0;
 
-#if 0
-	/* Should not be needed, will be removed */
-	if (!_set_udev_flags_for_children(dm, lv->vg, dnode))
-		return_0;
-#endif
-
 	dm->track_pending_delete = save_pending_delete; /* restore */
 
 	return 1;


