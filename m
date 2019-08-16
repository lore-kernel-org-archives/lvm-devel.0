From: David Teigland <teigland@sourceware.org>
Date: Fri, 16 Aug 2019 14:28:50 -0400
Subject: master - improve duplicate pv handling for md components
Message-ID: <201908161828.x7GISouP006525@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e01fddc5789b10d1bd15e8aee8985f14e81d3087
Commit:        e01fddc5789b10d1bd15e8aee8985f14e81d3087
Parent:        ee4a32e99224a0d4d2156c55d195e217967490b1
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Aug 1 15:04:10 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Aug 16 13:26:12 2019 -0500

improve duplicate pv handling for md components

Eliminate md components at the start so they don't
interfere with actual duplicates, and don't need
to be removed later.  This also allows for choosing
no copy of a PVID if they all happen to be md
components.
---
 lib/cache/lvmcache.c |  287 +++++++++++++++++++++++++++++---------------------
 lib/cache/lvmcache.h |   14 +--
 lib/label/label.c    |    5 +-
 3 files changed, 175 insertions(+), 131 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index f2503b2..87c0021 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -116,6 +116,11 @@ void lvmcache_unlock_vgname(const char *vgname)
 	}
 }
 
+int lvmcache_found_duplicate_vgnames(void)
+{
+	return _found_duplicate_vgnames;
+}
+
 static struct device_list *_get_devl_in_device_list(struct device *dev, struct dm_list *head)
 {
 	struct device_list *devl;
@@ -145,11 +150,6 @@ bool lvmcache_has_duplicate_devs(void)
 	return true;
 }
 
-int lvmcache_found_duplicate_vgnames(void)
-{
-	return _found_duplicate_vgnames;
-}
-
 int lvmcache_get_unused_duplicates(struct cmd_context *cmd, struct dm_list *head)
 {
 	struct device_list *devl, *devl2;
@@ -169,6 +169,10 @@ void lvmcache_del_dev_from_duplicates(struct device *dev)
 {
 	struct device_list *devl;
 
+	if ((devl = _get_devl_in_device_list(dev, &_initial_duplicates))) {
+		log_debug_cache("delete dev from initial duplicates %s", dev_name(dev));
+		dm_list_del(&devl->list);
+	}
 	if ((devl = _get_devl_in_device_list(dev, &_unused_duplicates))) {
 		log_debug_cache("delete dev from unused duplicates %s", dev_name(dev));
 		dm_list_del(&devl->list);
@@ -384,7 +388,7 @@ const char *lvmcache_vgname_from_info(struct lvmcache_info *info)
 
 /*
  * Check if any PVs in vg->pvs have the same PVID as any
- * entries in _unused_duplicate_devices.
+ * entries in _unused_duplicates.
  */
 
 int vg_has_duplicate_pvs(struct volume_group *vg)
@@ -406,65 +410,20 @@ bool lvmcache_dev_is_unused_duplicate(struct device *dev)
 	return dev_in_device_list(dev, &_unused_duplicates) ? true : false;
 }
 
-/*
- * Treat some duplicate devs as if they were filtered out by filters.
- * The actual filters are evaluated too early, before a complete
- * picture of all PVs is available, to eliminate these duplicates.
- *
- * By removing some duplicates from unused_duplicate_devs here, we remove
- * the restrictions that are placed on using duplicate devs or VGs with
- * duplicate devs.
- *
- * In cases where we know that two duplicates refer to the same underlying
- * storage, and we know which dev path to use, it's best for us to just
- * use that one preferred device path and ignore the others.  It is the cases
- * where we are unsure whether dups refer to the same underlying storage where
- * we need to keep the unused duplicate referenced in the
- * unused_duplicate_devs list, and restrict what we allow done with it.
- *
- * In the case of md components, we usually filter these out in filter-md,
- * but in the special case of md superblock version 1.0 where the superblock
- * is at the end of the device, filter-md doesn't always eliminate them
- * first, so we eliminate them here.
- *
- * There may other kinds of duplicates that we want to eliminate at
- * this point (using the knowledge from the scan) that we couldn't
- * eliminate in the filters prior to the scan.
- */
-
-static void _filter_duplicate_devs(struct cmd_context *cmd)
-{
-	struct dev_types *dt = cmd->dev_types;
-	struct lvmcache_info *info;
-	struct device_list *devl, *devl2;
-
-	dm_list_iterate_items_safe(devl, devl2, &_unused_duplicates) {
-
-		if (!(info = lvmcache_info_from_pvid(devl->dev->pvid, NULL, 0)))
-			continue;
-
-		if (MAJOR(info->dev->dev) == dt->md_major) {
-			log_debug_devs("Ignoring md component duplicate %s", dev_name(devl->dev));
-			dm_list_del(&devl->list);
-			free(devl);
-		}
-	}
-}
-
 static void _warn_unused_duplicates(struct cmd_context *cmd)
 {
 	char uuid[64] __attribute__((aligned(8)));
 	struct lvmcache_info *info;
-	struct device_list *devl, *devl2;
+	struct device_list *devl;
 
-	dm_list_iterate_items_safe(devl, devl2, &_unused_duplicates) {
+	dm_list_iterate_items(devl, &_unused_duplicates) {
 		if (!id_write_format((const struct id *)devl->dev->pvid, uuid, sizeof(uuid)))
 			stack;
 
 		log_warn("WARNING: Not using device %s for PV %s.", dev_name(devl->dev), uuid);
 	}
 
-	dm_list_iterate_items_safe(devl, devl2, &_unused_duplicates) {
+	dm_list_iterate_items(devl, &_unused_duplicates) {
 		/* info for the preferred device that we're actually using */
 		if (!(info = lvmcache_info_from_pvid(devl->dev->pvid, NULL, 0)))
 			continue;
@@ -478,18 +437,42 @@ static void _warn_unused_duplicates(struct cmd_context *cmd)
 }
 
 /*
- * Compare _initial_duplicates entries with the corresponding duplicate dev
- * in lvmcache.  There may be multiple duplicates in _initial_duplicates for
- * a given pvid.  If a dev from _initial_duplicates is preferred over the dev
- * in lvmcache, then drop the dev in lvmcache and rescan the preferred dev to
- * add it to lvmcache.
+ * If we've found devices with the same PVID, decide which one
+ * to use.
+ *
+ * Compare _initial_duplicates entries with the corresponding
+ * dev (matching PVID) in lvmcache.  There may be multiple
+ * entries in _initial_duplicates for a given PVID.  If a dev
+ * from _initial is preferred over the comparable dev in lvmcache,
+ * then drop the comparable dev from lvmcache and rescan the dev
+ * from _initial (rescanning adds it to lvmcache.)
  *
- * _initial_duplicates: duplicate devs found during initial scan.
- * These are compared to lvmcache devs to see if any are preferred.
+ * When a preferred dev is chosen, the dispreferred duplicate for
+ * it is kept in _unused_duplicates.
+ *
+ * For some duplicate entries, like a PV detected on an MD dev and
+ * on a component of that MD dev, we simply ignore the component
+ * dev, like it was excluded by a filter.  In this case we do not
+ * keep the ignored dev on the _unused list.
+ *
+ * _initial_duplicates: duplicate devs found during label_scan.
+ * The first dev with a given PVID is added to lvmcache, and any
+ * subsequent devs with that PVID are not added to lvmcache, but
+ * are kept in the _initial_duplicates list.  When label_scan is
+ * done, the caller (lvmcache_label_scan) compares the dev in
+ * lvmcache with the matching entries in _initial_duplicates to
+ * decide which dev should be the one used by the command (which
+ * will be the one kept in lvmcache.)
  *
  * _unused_duplicates: duplicate devs not chosen to be used.
- * These are _initial_duplicates entries that were not chosen,
- * or unpreferred lvmcache devs that were dropped.
+ * After label_scan adds entries to _initial_duplicates, the
+ * _initial entries are processed.  If the current lvmcache dev is
+ * preferred over the _initial entry, then the _initial entry is
+ * moved to _unused_duplicates.  If the current lvmcache dev
+ * is dispreferred vs the _initial duplicate, then the current
+ * lvmcache dev is added to _unused, the lvmcache info for it is
+ * dropped, the _initial dev is removed, that _initial dev is
+ * scanned and added to lvmcache.
  *
  * del_cache_devs: devices to drop from lvmcache
  * add_cache_devs: devices to scan to add to lvmcache
@@ -499,11 +482,12 @@ static void _choose_duplicates(struct cmd_context *cmd,
 			       struct dm_list *del_cache_devs,
 			       struct dm_list *add_cache_devs)
 {
+	char *pvid;
 	const char *reason;
 	struct dm_list altdevs;
 	struct dm_list new_unused;
 	struct dev_types *dt = cmd->dev_types;
-	struct device_list *devl, *devl_safe, *alt, *del;
+	struct device_list *devl, *devl_safe, *devl_add, *devl_del;
 	struct lvmcache_info *info;
 	struct device *dev1, *dev2;
 	uint32_t dev1_major, dev1_minor, dev2_major, dev2_minor;
@@ -523,54 +507,91 @@ static void _choose_duplicates(struct cmd_context *cmd,
 	 */
 next:
 	dm_list_init(&altdevs);
-	alt = NULL;
+	pvid = NULL;
 
 	dm_list_iterate_items_safe(devl, devl_safe, &_initial_duplicates) {
-		if (!alt) {
+		if (!pvid) {
 			dm_list_move(&altdevs, &devl->list);
-			alt = devl;
+			pvid = devl->dev->pvid;
 		} else {
-			if (!strcmp(alt->dev->pvid, devl->dev->pvid))
+			if (!strcmp(pvid, devl->dev->pvid))
 				dm_list_move(&altdevs, &devl->list);
 		}
 	}
 
-	if (!alt) {
+	/* done, no more entries to process */
+	if (!pvid) {
 		_destroy_device_list(&_unused_duplicates);
 		dm_list_splice(&_unused_duplicates, &new_unused);
 		return;
 	}
 
 	/*
+	 * Get rid of any md components before comparing alternatives.
+	 * (Since an md component can never be used, it's not an
+	 * option to use like other kinds of alternatives.)
+	 */
+
+	info = lvmcache_info_from_pvid(pvid, NULL, 0);
+	if (info && dev_is_md_component(info->dev, NULL, 1)) {
+		/* does not go in del_cache_devs which become unused_duplicates */
+		log_debug_cache("PV %s drop MD component from scan selection %s", pvid, dev_name(info->dev));
+		lvmcache_del(info);
+		info = NULL;
+	}
+
+	dm_list_iterate_items_safe(devl, devl_safe, &altdevs) {
+		if (dev_is_md_component(devl->dev, NULL, 1)) {
+			log_debug_cache("PV %s drop MD component from scan duplicates %s", pvid, dev_name(devl->dev));
+			dm_list_del(&devl->list);
+		}
+	}
+
+	if (dm_list_empty(&altdevs))
+		goto next;
+
+
+	/*
 	 * Find the device for the pvid that's currently in lvmcache.
 	 */
 
-	if (!(info = lvmcache_info_from_pvid(alt->dev->pvid, NULL, 0))) {
+	if (!(info = lvmcache_info_from_pvid(pvid, NULL, 0))) {
 		/*
-		 * This will happen if a duplicate dev has been dropped already,
-		 * e.g. it was found to be an md component.
+		 * This will happen if the lvmcache dev was already recognized
+		 * as an md component and already dropped from lvmcache.
+		 * One of the altdev entries for the PVID should be added to
+		 * lvmcache.
 		 */
-		log_debug("PVID %s on duplicate device %s not found in cache.",
-			 alt->dev->pvid, dev_name(alt->dev));
-		goto next;
+		if (dm_list_size(&altdevs) == 1) {
+			devl = dm_list_item(dm_list_first(&altdevs), struct device_list);
+			dm_list_del(&devl->list);
+			dm_list_add(add_cache_devs, &devl->list);
+
+			log_debug_cache("PV %s with duplicates unselected using %s.",
+					pvid, dev_name(devl->dev));
+			goto next;
+		} else {
+			devl = dm_list_item(dm_list_first(&altdevs), struct device_list);
+			dev1 = devl->dev;
+
+			log_debug_cache("PV %s with duplicates unselected comparing alternatives", pvid);
+		}
+	} else {
+		log_debug_cache("PV %s with duplicates comparing alternatives for %s",
+				pvid, dev_name(info->dev));
+		dev1 = info->dev;
 	}
 
 	/*
 	 * Compare devices for the given pvid to find one that's preferred.
-	 * "dev1" is the currently preferred device, starting with the device
-	 * currently in lvmcache.
 	 */
 
-	dev1 = info->dev;
-
 	dm_list_iterate_items(devl, &altdevs) {
 		dev2 = devl->dev;
 
-		if (dev1 == dev2) {
-			/* This shouldn't happen */
-			log_warn("Same duplicate device repeated %s", dev_name(dev1));
+		/* Took the first altdev to start with above. */
+		if (dev1 == dev2)
 			continue;
-		}
 
 		prev_unchosen1 = dev_in_device_list(dev1, &_unused_duplicates);
 		prev_unchosen2 = dev_in_device_list(dev2, &_unused_duplicates);
@@ -697,43 +718,75 @@ next:
 			reason = "device was seen first";
 		}
 
-		if (change) {
+		if (change)
 			dev1 = dev2;
-			alt = devl;
-		}
 
 		dev1->duplicate_prefer_reason = reason;
 	}
 
-	if (dev1 != info->dev) {
-		log_debug_cache("PV %s: switching to device %s instead of device %s.",
-				 dev1->pvid, dev_name(dev1), dev_name(info->dev));
+	/*
+	 * At the end of the loop, dev1 is the device we prefer to
+	 * use.  If there's no info struct, it means there's no dev
+	 * currently in lvmcache for this PVID, so just add the
+	 * preferred one (dev1).  If dev1 is different from the dev
+	 * currently in lvmcache, then drop the dev in lvmcache and
+	 * add dev1 to lvmcache.  If dev1 is the same as the dev
+	 * in lvmcache already, then no changes are needed and the
+	 * altdevs all become unused duplicates.
+	 */
+
+	if (!info) {
+		log_debug_cache("PV %s with duplicates will use %s.", pvid, dev_name(dev1));
+
+		if (!(devl_add = _get_devl_in_device_list(dev1, &altdevs))) {
+			/* shouldn't happen */
+			log_error(INTERNAL_ERROR "PV %s with duplicates no alternate list entry for %s", pvid, dev_name(dev1));
+			dm_list_splice(&new_unused, &altdevs);
+			goto next;
+		}
+
+		dm_list_move(add_cache_devs, &devl_add->list);
+
+	} else if (dev1 != info->dev) {
+		log_debug_cache("PV %s with duplicates will change from %s to %s.",
+				pvid, dev_name(info->dev), dev_name(dev1));
+
 		/*
-		 * Move the preferred device from altdevs to add_cache_devs.
-		 * Create a del_cache_devs entry for the current lvmcache
-		 * device to drop.
+		 * Move the preferred device (dev1) from altdevs
+		 * to add_cache_devs.  Create a del_cache_devs entry
+		 * for the current lvmcache device to drop.
 		 */
 
-		dm_list_move(add_cache_devs, &alt->list);
+		if (!(devl_add = _get_devl_in_device_list(dev1, &altdevs))) {
+			/* shouldn't happen */
+			log_error(INTERNAL_ERROR "PV %s with duplicates no alternate list entry for %s", pvid, dev_name(dev1));
+			dm_list_splice(&new_unused, &altdevs);
+			goto next;
+		}
 
-		if ((del = zalloc(sizeof(*del)))) {
-			del->dev = info->dev;
-			dm_list_add(del_cache_devs, &del->list);
+		dm_list_move(add_cache_devs, &devl_add->list);
+
+		if ((devl_del = zalloc(sizeof(*devl_del)))) {
+			devl_del->dev = info->dev;
+			dm_list_add(del_cache_devs, &devl_del->list);
 		}
 
 	} else {
-		log_debug_cache("PV %s: keeping current device %s.", dev1->pvid, dev_name(info->dev));
+		/*
+		 * Keeping existing dev in lvmcache for this PVID.
+		 */
+		log_debug_cache("PV %s with duplicates will continue using %s.",
+				pvid, dev_name(info->dev));
 	}
 
 	/*
-	 * alt devs not chosen are moved to _unused_duplicates.
+	 * Any altdevs entries not chosen are moved to _unused_duplicates.
 	 * del_cache_devs being dropped are moved to _unused_duplicates
 	 * after being dropped.  So, _unused_duplicates represents all
 	 * duplicates not being used in lvmcache.
 	 */
 
 	dm_list_splice(&new_unused, &altdevs);
-
 	goto next;
 }
 
@@ -795,9 +848,6 @@ static int _label_rescan_vg(struct cmd_context *cmd, const char *vgname, const c
 	if ((vginfo = lvmcache_vginfo_from_vgname(vgname, vgid)))
 		log_warn("VG info not dropped before rescan of %s", vgname);
 
-	/* FIXME: should we also rescan unused_duplicate_devs for devs
-	   being rescanned here and then repeat resolving the duplicates? */
-
 	if (rw)
 		label_scan_devs_rw(cmd, cmd->filter, &devs);
 	else
@@ -873,9 +923,10 @@ int lvmcache_label_scan(struct cmd_context *cmd)
 		log_error("Scan failed to refresh device filter.");
 
 	/*
-	 * Duplicates found during this label scan are added to _initial_duplicates().
+	 * Duplicates found during this label scan are added to _initial_duplicates.
 	 */
 	_destroy_device_list(&_initial_duplicates);
+	_destroy_device_list(&_unused_duplicates);
 
 	/*
 	 * Do the actual scanning.  This populates lvmcache
@@ -915,28 +966,19 @@ int lvmcache_label_scan(struct cmd_context *cmd)
 		_choose_duplicates(cmd, &del_cache_devs, &add_cache_devs);
 
 		dm_list_iterate_items(devl, &del_cache_devs) {
-			log_debug_cache("Drop duplicate device %s in lvmcache", dev_name(devl->dev));
+			log_debug_cache("Dropping unchosen duplicate %s", dev_name(devl->dev));
 			if ((info = lvmcache_info_from_pvid(devl->dev->pvid, NULL, 0)))
 				lvmcache_del(info);
 		}
 
 		dm_list_iterate_items(devl, &add_cache_devs) {
-			log_debug_cache("Rescan preferred device %s for lvmcache", dev_name(devl->dev));
+			log_debug_cache("Adding chosen duplicate %s", dev_name(devl->dev));
 			label_read(devl->dev);
 		}
 
 		dm_list_splice(&_unused_duplicates, &del_cache_devs);
 
-		/*
-		 * This may remove some entries from the unused_duplicates list for
-		 * devs that we know are the same underlying dev.
-		 */
-		_filter_duplicate_devs(cmd);
-
-		/*
-		 * Warn about remaining duplicates that may actually be separate copies of
-		 * the same device.
-		 */
+		/* Warn about unused duplicates that the user might want to resolve. */
 		_warn_unused_duplicates(cmd);
 	}
 
@@ -1839,8 +1881,8 @@ struct lvmcache_info *lvmcache_add(struct labeller *labeller,
 	 */
 	if (!created) {
 		if (info->dev != dev) {
-			log_debug_cache("PV %s on %s was already found on %s.",
-				        uuid, dev_name(dev), dev_name(info->dev));
+			log_debug_cache("Saving initial duplicate device %s previously seen on %s with PVID %s.",
+					dev_name(dev), dev_name(info->dev), uuid);
 
 			strncpy(dev->pvid, pvid_s, sizeof(dev->pvid));
 
@@ -1857,7 +1899,12 @@ struct lvmcache_info *lvmcache_add(struct labeller *labeller,
 				return_NULL;
 			devl->dev = dev;
 
-			dm_list_add(&_initial_duplicates, &devl->list);
+			/* shouldn't happen */
+			if (dev_in_device_list(dev, &_initial_duplicates))
+				log_debug_cache("Initial duplicate already in list %s", dev_name(dev));
+			else
+				dm_list_add(&_initial_duplicates, &devl->list);
+
 			if (is_duplicate)
 				*is_duplicate = 1;
 			return NULL;
@@ -1865,8 +1912,8 @@ struct lvmcache_info *lvmcache_add(struct labeller *labeller,
 
 		if (info->dev->pvid[0] && pvid[0] && strcmp(pvid_s, info->dev->pvid)) {
 			/* This happens when running pvcreate on an existing PV. */
-			log_verbose("Changing pvid on dev %s from %s to %s",
-				    dev_name(info->dev), info->dev->pvid, pvid_s);
+			log_debug_cache("Changing pvid on dev %s from %s to %s",
+					dev_name(info->dev), info->dev->pvid, pvid_s);
 		}
 
 		if (info->label->labeller != labeller) {
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index c831d0e..89fbe6f 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -170,12 +170,14 @@ struct metadata_area *lvmcache_get_mda(struct cmd_context *cmd,
                                       int use_mda_num);
 
 bool lvmcache_has_duplicate_devs(void);
-int lvmcache_found_duplicate_vgnames(void);
-
+void lvmcache_del_dev_from_duplicates(struct device *dev);
+bool lvmcache_dev_is_unused_duplicate(struct device *dev);
+int lvmcache_pvid_in_unused_duplicates(const char *pvid);
 int lvmcache_get_unused_duplicates(struct cmd_context *cmd, struct dm_list *head);
-
 int vg_has_duplicate_pvs(struct volume_group *vg);
 
+int lvmcache_found_duplicate_vgnames(void);
+
 int lvmcache_contains_lock_type_sanlock(struct cmd_context *cmd);
 
 void lvmcache_get_max_name_lengths(struct cmd_context *cmd,
@@ -183,12 +185,6 @@ void lvmcache_get_max_name_lengths(struct cmd_context *cmd,
 
 int lvmcache_vg_is_foreign(struct cmd_context *cmd, const char *vgname, const char *vgid);
 
-bool lvmcache_dev_is_unused_duplicate(struct device *dev);
-
-void lvmcache_del_dev_from_duplicates(struct device *dev);
-
-int lvmcache_pvid_in_unused_duplicates(const char *pvid);
-
 bool lvmcache_scan_mismatch(struct cmd_context *cmd, const char *vgname, const char *vgid);
 
 int lvmcache_vginfo_has_pvid(struct lvmcache_vginfo *vginfo, char *pvid);
diff --git a/lib/label/label.c b/lib/label/label.c
index 9454fc8..3c8e10c 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -441,7 +441,7 @@ static int _process_block(struct cmd_context *cmd, struct dev_filter *f,
 			 * struct for this dev, but added this dev to the list
 			 * of duplicate devs.
 			 */
-			log_warn("WARNING: scan found duplicate PVID %s on %s", dev->pvid, dev_name(dev));
+			log_debug("label scan found duplicate PVID %s on %s", dev->pvid, dev_name(dev));
 		} else {
 			/*
 			 * Leave the info in lvmcache because the device is
@@ -1117,9 +1117,10 @@ int label_scan(struct cmd_context *cmd)
 				log_debug_devs("Scanning end of PVs with no udev info for MD components");
 
 			if (dev_is_md_component(devl->dev, NULL, 1)) {
-				log_debug_devs("Drop PV from MD component %s", dev_name(devl->dev));
+				log_debug_devs("Scan dropping PV from MD component %s", dev_name(devl->dev));
 				devl->dev->flags &= ~DEV_SCAN_FOUND_LABEL;
 				lvmcache_del_dev(devl->dev);
+				lvmcache_del_dev_from_duplicates(devl->dev);
 			}
 		}
 	}


