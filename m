From: David Teigland <teigland@fedoraproject.org>
Date: Fri,  6 May 2016 14:00:48 +0000 (UTC)
Subject: master - lvmcache: improve duplicate PV handling
Message-ID: <20160506140048.4634060722@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8b7a78c728be3b9af698dae9344d01752c4cf615
Commit:        8b7a78c728be3b9af698dae9344d01752c4cf615
Parent:        67da017fd2502138d0cc469f3aea320440353156
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Feb 9 13:06:27 2016 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri May 6 09:00:00 2016 -0500

lvmcache: improve duplicate PV handling

Wait to compare and choose alternate duplicate devices until
after all devices are scanned.  During scanning, the first
duplicate dev is kept in lvmcache, and others are kept in a
new list (_found_duplicate_devs).

After all devices are scanned, compare all the duplicates
available for a given PVID and decide which is best.

If the dev used in lvmcache is changed, drop the old dev
from lvmcache entirely and rescan the replacement dev.
Previously the VG metadata from the old dev was kept in
lvmcache and only the dev was replaced.

A new config setting devices/allow_changes_with_duplicate_pvs
can be set to 0 which disallows modifying a VG or activating
LVs in it when the VG contains PVs with duplicate devices.
Set to 1 is the old behavior which allowed the VG to be
changed.

The logic for which of two devs is preferred has changed.
The primary goal is to choose a device that is currently
in use if the other isn't, e.g. by an active LV.

. prefer dev with fs mounted if the other doesn't, else
. prefer dev that is dm if the other isn't, else
. prefer dev in subsystem if the other isn't

If neither device is preferred by these rules, then don't
change devices in lvmcache, leaving the one that was found
first.

The previous logic for preferring a device was:

. prefer dev in subsystem if the other isn't, else
. prefer dev without holders if the other has holders, else
. prefer dev that is dm if the other isn't
---
 lib/cache/lvmcache.c         |  557 +++++++++++++++++++++++++-----------------
 lib/cache/lvmcache.h         |    2 +
 lib/config/config_settings.h |   12 +
 lib/config/defaults.h        |    1 +
 lib/metadata/metadata.c      |   17 ++
 tools/toollib.c              |    9 +
 6 files changed, 376 insertions(+), 222 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 4e89371..14ce68b 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -79,6 +79,8 @@ static struct dm_hash_table *_vgid_hash = NULL;
 static struct dm_hash_table *_vgname_hash = NULL;
 static struct dm_hash_table *_lock_hash = NULL;
 static DM_LIST_INIT(_vginfos);
+static DM_LIST_INIT(_found_duplicate_devs);
+static DM_LIST_INIT(_unused_duplicate_devs);
 static int _scanning_in_progress = 0;
 static int _has_scanned = 0;
 static int _vgs_locked = 0;
@@ -428,6 +430,14 @@ int lvmcache_vgs_locked(void)
  * When lvmcache sees a duplicate PV, this is set.
  * process_each_pv() can avoid searching for duplicates
  * by checking this and seeing that no duplicate PVs exist.
+ *
+ *
+ * found_duplicate_pvs tells the process_each_pv code
+ * to search the devices list for duplicates, so that
+ * devices can be processed together with their
+ * duplicates (while processing the VG, rather than
+ * reporting pv->dev under the VG, and its duplicate
+ * outside the VG context.)
  */
 int lvmcache_found_duplicate_pvs(void)
 {
@@ -733,8 +743,194 @@ void lvmcache_force_next_label_scan(void)
 	_force_label_scan = 1;
 }
 
+/*
+ * Check if any PVs in vg->pvs have the same PVID as any
+ * entries in _unused_duplicate_devices.
+ */
+
+int vg_has_duplicate_pvs(struct volume_group *vg)
+{
+	struct pv_list *pvl;
+	struct device_list *devl;
+
+	dm_list_iterate_items(pvl, &vg->pvs) {
+		dm_list_iterate_items(devl, &_unused_duplicate_devs) {
+			if (id_equal(&pvl->pv->id, (const struct id *)devl->dev->pvid))
+				return 1;
+		}
+	}
+	return 0;
+}
+
+/*
+ * Compare _found_duplicate_devs entries with the corresponding duplicate dev
+ * in lvmcache.  There may be multiple duplicates in _found_duplicate_devs for
+ * a given pvid.  If a dev from _found_duplicate_devs is preferred over the dev
+ * in lvmcache, then drop the dev in lvmcache and rescan the preferred dev to
+ * add it to lvmcache.
+ *
+ * _found_duplicate_devs: duplicate devs found during initial scan.
+ * These are compared to lvmcache devs to see if any are preferred.
+ *
+ * _unused_duplicate_devs: duplicate devs not chosen to be used.
+ * These are _found_duplicate_devs entries that were not chosen,
+ * or unpreferred lvmcache devs that were dropped.
+ *
+ * del_cache_devs: devices to drop from lvmcache
+ * add_cache_devs: devices to scan to add to lvmcache
+ */
+
+static void _choose_preferred_devs(struct cmd_context *cmd,
+				   struct dm_list *del_cache_devs,
+				   struct dm_list *add_cache_devs)
+{
+	char uuid[64] __attribute__((aligned(8)));
+	struct dm_list altdevs;
+	struct dev_types *dt = cmd->dev_types;
+	struct device_list *devl, *devl_safe, *alt, *del;
+	struct lvmcache_info *info;
+	struct device *dev1, *dev2;
+	uint32_t dev1_major, dev1_minor, dev2_major, dev2_minor;
+	int in_subsys1, in_subsys2;
+	int is_dm1, is_dm2;
+	int has_fs1, has_fs2;
+	int change;
+
+	/*
+	 * Create a list of all alternate devs for the same pvid: altdevs.
+	 */
+next:
+	dm_list_init(&altdevs);
+	alt = NULL;
+
+	dm_list_iterate_items_safe(devl, devl_safe, &_found_duplicate_devs) {
+		if (!alt) {
+			dm_list_move(&altdevs, &devl->list);
+			alt = devl;
+		} else {
+			if (!strcmp(alt->dev->pvid, devl->dev->pvid))
+				dm_list_move(&altdevs, &devl->list);
+		}
+	}
+
+	if (!alt)
+		return;
+
+	/*
+	 * Find the device for the pvid that's currently in lvmcache.
+	 */
+
+	if (!(info = lvmcache_info_from_pvid(alt->dev->pvid, 0))) {
+		/* This shouldn't happen */
+		log_warn("WARNING: PV %s on duplicate device %s not found in cache.",
+			 alt->dev->pvid, dev_name(alt->dev));
+		goto next;
+	}
+
+	/*
+	 * Compare devices for the given pvid to find one that's preferred.
+	 * "dev1" is the currently preferred device, starting with the device
+	 * currently in lvmcache.
+	 */
+
+	dev1 = info->dev;
+
+	dm_list_iterate_items(devl, &altdevs) {
+		dev2 = devl->dev;
+
+		if (dev1 == dev2) {
+			/* This shouldn't happen */
+			log_warn("Same duplicate device repeated %s", dev_name(dev1));
+			continue;
+		}
+
+		dev1_major = MAJOR(dev1->dev);
+		dev1_minor = MINOR(dev1->dev);
+		dev2_major = MAJOR(dev2->dev);
+		dev2_minor = MINOR(dev2->dev);
+
+		in_subsys1 = dev_subsystem_part_major(dt, dev1);
+		in_subsys2 = dev_subsystem_part_major(dt, dev2);
+
+		is_dm1 = dm_is_dm_major(dev1_major);
+		is_dm2 = dm_is_dm_major(dev2_major);
+
+		has_fs1 = dm_device_has_mounted_fs(dev1_major, dev1_minor);
+		has_fs2 = dm_device_has_mounted_fs(dev2_major, dev2_minor);
+
+		log_debug_cache("PV %s compare duplicates %s and %s",
+				devl->dev->pvid, dev_name(dev1), dev_name(dev2));
+
+		log_debug_cache("dup dev1 %s subsys %d dm %d fs %d",
+				dev_name(dev1), in_subsys1, is_dm1, has_fs1);
+		log_debug_cache("dup dev2 %s subsys %d dm %d fs %d",
+				dev_name(dev2), in_subsys2, is_dm2, has_fs2);
+
+		change = 0;
+
+		if (has_fs1 && !has_fs2) {
+			/* keep 1 */
+		} else if (has_fs2 && !has_fs1) {
+			/* change to 2 */
+			change = 1;
+		} else if (is_dm1 && !is_dm2) {
+			/* keep 1 */
+		} else if (is_dm2 && !is_dm1) {
+			/* change to 2 */
+			change = 1;
+		} else if (in_subsys1 && !in_subsys2) {
+			/* keep 1 */
+		} else if (in_subsys2 && !in_subsys1) {
+			/* change to 2 */
+			change = 1;
+		}
+
+		if (change) {
+			dev1 = dev2;
+			alt = devl;
+		}
+	}
+
+	id_write_format((const struct id *)info->dev->pvid, uuid, sizeof(uuid));
+
+	if (dev1 != info->dev) {
+		log_warn("PV %s is using preferred device %s, changed from %s",
+			 uuid, dev_name(dev1), dev_name(info->dev));
+		/*
+		 * Move the preferred device from altdevs to add_cache_devs.
+		 * Create a del_cache_devs entry for the current lvmcache
+		 * device to drop.
+		 */
+
+		dm_list_move(add_cache_devs, &alt->list);
+
+		if ((del = dm_pool_alloc(cmd->mem, sizeof(*del)))) {
+			del->dev = info->dev;
+			dm_list_add(del_cache_devs, &del->list);
+		}
+	} else {
+		log_warn("PV %s is using preferred device %s",
+			 uuid, dev_name(info->dev));
+	}
+
+	/*
+	 * alt devs not chosen are moved to _unused_duplicate_devs.
+	 * del_cache_devs being dropped are moved to _unused_duplicate_devs
+	 * after being dropped.  So, _unused_duplicate_devs represents all
+	 * duplicates not being used in lvmcache.
+	 */
+
+	dm_list_splice(&_unused_duplicate_devs, &altdevs);
+
+	goto next;
+}
+
 int lvmcache_label_scan(struct cmd_context *cmd)
 {
+	struct dm_list del_cache_devs;
+	struct dm_list add_cache_devs;
+	struct lvmcache_info *info;
+	struct device_list *devl;
 	struct label *label;
 	struct dev_iter *iter;
 	struct device *dev;
@@ -781,6 +977,44 @@ int lvmcache_label_scan(struct cmd_context *cmd)
 
 	log_very_verbose("Scanned %d device labels", dev_count);
 
+	/*
+	 * _choose_preferred_devs() returns:
+	 *
+	 * . del_cache_devs: a list of devs currently in lvmcache that should
+	 * be removed from lvmcache because they will be replaced with
+	 * alternative devs for the same PV.
+	 *
+	 * . add_cache_devs: a list of devs that are preferred over devs in
+	 * lvmcache for the same PV.  These devices should be rescanned to
+	 * populate lvmcache from them.
+	 *
+	 * First remove lvmcache info for the devs to be dropped, then rescan
+	 * the devs that are preferred to add them to lvmcache.
+	 *
+	 * Keep a complete list of all devs that are unused by moving the
+	 * del_cache_devs onto _unused_duplicate_devs.
+	 */
+
+	if (!dm_list_empty(&_found_duplicate_devs)) {
+		dm_list_init(&del_cache_devs);
+		dm_list_init(&add_cache_devs);
+
+		_choose_preferred_devs(cmd, &del_cache_devs, &add_cache_devs);
+
+		dm_list_iterate_items(devl, &del_cache_devs) {
+			log_debug_cache("Drop duplicate device %s in lvmcache", dev_name(devl->dev));
+			if ((info = lvmcache_info_from_pvid(devl->dev->pvid, 0)))
+				lvmcache_del(info);
+		}
+
+		dm_list_iterate_items(devl, &add_cache_devs) {
+			log_debug_cache("Rescan preferred device %s for lvmcache", dev_name(devl->dev));
+			(void) label_read(devl->dev, &label, UINT64_C(0));
+		}
+
+		dm_list_splice(&_unused_duplicate_devs, &del_cache_devs);
+	}
+
 	_has_scanned = 1;
 
 	/* Perform any format-specific scanning e.g. text files */
@@ -1185,26 +1419,6 @@ void lvmcache_del(struct lvmcache_info *info)
 	return;
 }
 
-static int _lvmcache_update_pvid(struct lvmcache_info *info, const char *pvid)
-{
-	/*
-	 * Nothing to do if already stored with same pvid.
-	 */
-
-	if (((dm_hash_lookup(_pvid_hash, pvid)) == info) &&
-	    !strcmp(info->dev->pvid, pvid))
-		return 1;
-	if (*info->dev->pvid)
-		dm_hash_remove(_pvid_hash, info->dev->pvid);
-	strncpy(info->dev->pvid, pvid, sizeof(info->dev->pvid));
-	if (!dm_hash_insert(_pvid_hash, pvid, info)) {
-		log_error("_lvmcache_update: pvid insertion failed: %s", pvid);
-		return 0;
-	}
-
-	return 1;
-}
-
 /*
  * vginfo must be info->vginfo unless info is NULL (orphans)
  */
@@ -1711,13 +1925,6 @@ void lvmcache_replace_dev(struct cmd_context *cmd, struct physical_volume *pv,
  * duplicate of that dev that is not part of a
  * subsystem.
  *
- * The has_holders calls check if the device is being
- * used by another, and prefers one that's being used.
- *
- * FIXME: why do we prefer a device without holders
- * over a device with holders?  We should understand
- * the reason for that choice.
- *
  * FIXME: there may be other reasons to prefer one
  * device over another:
  *
@@ -1732,73 +1939,74 @@ void lvmcache_replace_dev(struct cmd_context *cmd, struct physical_volume *pv,
  *   transient duplicate?
  */
 
-struct lvmcache_info *lvmcache_add(struct labeller *labeller, const char *pvid,
-				   struct device *dev,
-				   const char *vgname, const char *vgid,
-				   uint32_t vgstatus)
+static struct lvmcache_info * _create_info(struct labeller *labeller, struct device *dev)
 {
-	const struct format_type *fmt = labeller->fmt;
-	struct dev_types *dt = fmt->cmd->dev_types;
+	struct lvmcache_info *info;
 	struct label *label;
-	struct lvmcache_info *existing, *info;
-	char pvid_s[ID_LEN + 1] __attribute__((aligned(8)));
-	struct lvmcache_vgsummary vgsummary = {
-		.vgname = vgname,
-		.vgstatus = vgstatus,
-	};
-
-	/* N.B. vgid is not NUL-terminated when called from _text_pv_write */
-	if (vgid)
-		strncpy((char *)&vgsummary.vgid, vgid, sizeof(vgsummary.vgid));
 
-	if (!_vgname_hash && !lvmcache_init()) {
-		log_error("Internal cache initialisation failed");
+	if (!(label = label_create(labeller)))
+		return_NULL;
+	if (!(info = dm_zalloc(sizeof(*info)))) {
+		log_error("lvmcache_info allocation failed");
+		label_destroy(label);
 		return NULL;
 	}
 
+	info->dev = dev;
+	info->fmt = labeller->fmt;
+
+	label->info = info;
+	info->label = label;
+
+	dm_list_init(&info->list);
+	lvmcache_del_mdas(info);
+	lvmcache_del_das(info);
+	lvmcache_del_bas(info);
+
+	return info;
+}
+
+struct lvmcache_info *lvmcache_add(struct labeller *labeller,
+				   const char *pvid, struct device *dev,
+				   const char *vgname, const char *vgid, uint32_t vgstatus)
+{
+	char pvid_s[ID_LEN + 1] __attribute__((aligned(8)));
+	char uuid[64] __attribute__((aligned(8)));
+	struct lvmcache_vgsummary vgsummary = { 0 };
+	const struct format_type *fmt = labeller->fmt;
+	struct lvmcache_info *info;
+	struct lvmcache_info *info_lookup;
+	struct device_list *devl;
+	int created = 0;
+
 	strncpy(pvid_s, pvid, sizeof(pvid_s) - 1);
 	pvid_s[sizeof(pvid_s) - 1] = '\0';
+	id_write_format((const struct id *)&pvid_s, uuid, sizeof(uuid));
 
-	if (!(existing = lvmcache_info_from_pvid(pvid_s, 0)) &&
-	    !(existing = lvmcache_info_from_pvid(dev->pvid, 0))) {
-		if (!(label = label_create(labeller)))
-			return_NULL;
-		if (!(info = dm_zalloc(sizeof(*info)))) {
-			log_error("lvmcache_info allocation failed");
-			label_destroy(label);
-			return NULL;
-		}
+	/*
+	 * Find existing info struct in _pvid_hash or create a new one.
+	 */
 
-		label->info = info;
-		info->label = label;
-		dm_list_init(&info->list);
-		info->dev = dev;
+	info = lvmcache_info_from_pvid(pvid_s, 0);
 
-		lvmcache_del_mdas(info);
-		lvmcache_del_das(info);
-		lvmcache_del_bas(info);
-	} else {
-		if (existing->dev != dev) {
-			int old_in_subsystem = 0;
-			int new_in_subsystem = 0;
-			int old_is_dm = 0;
-			int new_is_dm = 0;
-			int old_has_holders = 0;
-			int new_has_holders = 0;
+	if (!info)
+		info = lvmcache_info_from_pvid(dev->pvid, 0);
 
-			/*
-			 * Here are different devices with the same pvid:
-			 * duplicates.  See comment above.
-			 */
+	if (!info) {
+		info = _create_info(labeller, dev);
+		created = 1;
+	}
 
-			/*
-			 * This flag tells the process_each_pv code to search
-			 * the devices list for duplicates, so that devices
-			 * can be processed together with their duplicates
-			 * (while processing the VG, rather than reporting
-			 * pv->dev under the VG, and its duplicate outside
-			 * the VG context.)
-			 */
+	if (!info)
+		return_NULL;
+
+	/*
+	 * If an existing info struct was found, check if any values are new.
+	 */
+	if (!created) {
+		if (info->dev != dev) {
+			log_warn("WARNING: PV %s on %s was already found on %s.",
+				  uuid, dev_name(dev), dev_name(info->dev));
 
 			if (!_found_duplicate_pvs && lvmetad_used()) {
 				log_warn("WARNING: Disabling lvmetad cache which does not support duplicate PVs."); 
@@ -1806,174 +2014,75 @@ struct lvmcache_info *lvmcache_add(struct labeller *labeller, const char *pvid,
 			}
 			_found_duplicate_pvs = 1;
 
-			/*
-			 * The new dev may not have pvid set.
-			 * The process_each_pv code needs to have the pvid
-			 * set in each device to detect that the devices
-			 * are duplicates.
-			 */
 			strncpy(dev->pvid, pvid_s, sizeof(dev->pvid));
 
 			/*
-			 * Now decide if we are going to ignore the new
-			 * device, or replace the existing/old device in
-			 * lvmcache with the new one.
+			 * Keep the existing PV/dev in lvmcache, and save the
+			 * new duplicate in the list of duplicates.  After
+			 * scanning is complete, compare the duplicate devs
+			 * with those in lvmcache to check if one of the
+			 * duplicates is preferred and if so switch lvmcache to
+			 * use it.
 			 */
-			old_in_subsystem = dev_subsystem_part_major(dt, existing->dev);
-			new_in_subsystem = dev_subsystem_part_major(dt, dev);
-
-			old_is_dm = dm_is_dm_major(MAJOR(existing->dev->dev));
-			new_is_dm = dm_is_dm_major(MAJOR(dev->dev));
-
-			old_has_holders = dm_device_has_holders(MAJOR(existing->dev->dev), MINOR(existing->dev->dev));
-			new_has_holders = dm_device_has_holders(MAJOR(dev->dev), MINOR(dev->dev));
-
-			if (old_has_holders && new_has_holders) {
-				/*
-				 * This is not a selection of old or new, but
-				 * just a warning to be aware of.
-				 */
-				log_warn("WARNING: duplicate PV %s is being used from both devices %s and %s",
-					 pvid_s,
-					 dev_name(existing->dev),
-					 dev_name(dev));
-			}
 
-			if (existing->vginfo->preferred_duplicates) {
-				/*
-				 * The preferred duplicate devs have already
-				 * been chosen during a previous populating of
-				 * lvmcache, so just use the existing preferences.
-				 */
-				log_warn("Found duplicate PV %s: using existing dev %s",
-					 pvid_s,
-					 dev_name(existing->dev));
-				return NULL;
-			}
+			if (!(devl = dm_pool_alloc(fmt->cmd->mem, sizeof(*devl))))
+				return_NULL;
+			devl->dev = dev;
 
-			if (old_in_subsystem && !new_in_subsystem) {
-				/* Use old, ignore new. */
-				log_warn("Found duplicate PV %s: using %s not %s",
-					 pvid_s,
-					 dev_name(existing->dev),
-					 dev_name(dev));
-				log_warn("Using duplicate PV %s from subsystem %s, ignoring %s",
-					 dev_name(existing->dev),
-					 dev_subsystem_name(dt, existing->dev),
-					 dev_name(dev));
-				return NULL;
-
-			} else if (!old_in_subsystem && new_in_subsystem) {
-				/* Use new, replace old. */
-				log_warn("Found duplicate PV %s: using %s not %s",
-					 pvid_s,
-					 dev_name(dev),
-					 dev_name(existing->dev));
-				log_warn("Using duplicate PV %s from subsystem %s, replacing %s",
-					 dev_name(dev),
-					 dev_subsystem_name(dt, dev),
-					 dev_name(existing->dev));
-
-			} else if (old_has_holders && !new_has_holders) {
-				/* Use new, replace old. */
-				/* FIXME: why choose the one without olders? */
-				log_warn("Found duplicate PV %s: using %s not %s",
-					 pvid_s,
-					 dev_name(dev),
-					 dev_name(existing->dev));
-				log_warn("Using duplicate PV %s without holders, replacing %s",
-					 dev_name(dev),
-					 dev_name(existing->dev));
-
-			} else if (!old_has_holders && new_has_holders) {
-				/* Use old, ignore new. */
-				log_warn("Found duplicate PV %s: using %s not %s",
-					 pvid_s,
-					 dev_name(existing->dev),
-					 dev_name(dev));
-				log_warn("Using duplicate PV %s without holders, ignoring %s",
-					 dev_name(existing->dev),
-					 dev_name(dev));
-				return NULL;
-
-			} else if (old_is_dm && new_is_dm) {
-				/* Use new, replace old. */
-				/* FIXME: why choose the new instead of the old? */
-				log_warn("Found duplicate PV %s: using %s not %s",
-					 pvid_s,
-					 dev_name(dev),
-					 dev_name(existing->dev));
-				log_warn("Using duplicate PV %s which is last seen, replacing %s",
-					 dev_name(dev),
-					 dev_name(existing->dev));
-
-			} else if (!strcmp(pvid_s, existing->dev->pvid)) {
-				/* No criteria to use for preferring old or new. */
-				/* FIXME: why choose the new instead of the old? */
-				/* FIXME: a transient duplicate would be a reason
-				 * to select the old instead of the new. */
-				log_warn("Found duplicate PV %s: using %s not %s",
-					 pvid_s,
-					 dev_name(dev),
-					 dev_name(existing->dev));
-				log_warn("Using duplicate PV %s which is last seen, replacing %s",
-					 dev_name(dev),
-					 dev_name(existing->dev));
-			}
-		} else {
-			/*
-			 * The new dev is the same as the existing dev.
-			 *
-			 * FIXME: Why can't we just return NULL here if the
-			 * device already exists?  Things don't seem to work
-			 * if we do that for some reason.
-			 */
-			log_debug_cache("Found same device %s with same pvid %s.",
-					dev_name(existing->dev), pvid_s);
+			dm_list_add(&_found_duplicate_devs, &devl->list);
+			return NULL;
 		}
 
-		/*
-		 * This happens when running pvcreate on an existing PV.
-		 */
-		if (strcmp(pvid_s, existing->dev->pvid))  {
-			log_verbose("Replacing dev %s pvid %s with dev %s pvid %s",
-				    dev_name(existing->dev), existing->dev->pvid,
-				    dev_name(dev), pvid_s);
+		if (info->dev->pvid[0] && pvid[0] && strcmp(pvid_s, info->dev->pvid)) {
+			/* This happens when running pvcreate on an existing PV. */
+			log_verbose("Changing pvid on dev %s from %s to %s",
+				    dev_name(info->dev), info->dev->pvid, pvid_s);
 		}
 
-		/*
-		 * Switch over to new preferred device.
-		 */
-		existing->dev = dev;
-		info = existing;
-		/* Has labeller changed? */
 		if (info->label->labeller != labeller) {
+			log_verbose("Changing labeller on dev %s from %s to %s",
+				    dev_name(info->dev),
+				    info->label->labeller->fmt->name,
+				    labeller->fmt->name);
 			label_destroy(info->label);
 			if (!(info->label = label_create(labeller)))
-				/* FIXME leaves info without label! */
 				return_NULL;
 			info->label->info = info;
 		}
-		label = info->label;
 	}
 
-	info->fmt = labeller->fmt;
 	info->status |= CACHE_INVALID;
 
-	if (!_lvmcache_update_pvid(info, pvid_s)) {
-		if (!existing) {
-			dm_free(info);
-			label_destroy(label);
-		}
+	/*
+	 * Add or update the _pvid_hash mapping, pvid to info.
+	 */
+
+	info_lookup = dm_hash_lookup(_pvid_hash, pvid_s);
+	if ((info_lookup == info) && !strcmp(info->dev->pvid, pvid_s))
+		goto update_vginfo;
+
+	if (info->dev->pvid[0])
+		dm_hash_remove(_pvid_hash, info->dev->pvid);
+
+	strncpy(info->dev->pvid, pvid_s, sizeof(info->dev->pvid));
+
+	if (!dm_hash_insert(_pvid_hash, pvid_s, info)) {
+		log_error("Adding pvid to hash failed %s", pvid_s);
 		return NULL;
 	}
 
+update_vginfo:
+	vgsummary.vgstatus = vgstatus;
+	vgsummary.vgname = vgname;
+	if (vgid)
+		strncpy((char *)&vgsummary.vgid, vgid, sizeof(vgsummary.vgid));
+
 	if (!lvmcache_update_vgname_and_id(info, &vgsummary)) {
-		if (!existing) {
+		if (created) {
 			dm_hash_remove(_pvid_hash, pvid_s);
 			strcpy(info->dev->pvid, "");
+			dm_free(info->label);
 			dm_free(info);
-			label_destroy(label);
 		}
 		return NULL;
 	}
@@ -2058,6 +2167,10 @@ void lvmcache_destroy(struct cmd_context *cmd, int retain_orphans, int reset)
 	if (retain_orphans)
 		if (!init_lvmcache_orphans(cmd))
 			stack;
+
+	dm_list_init(&_found_duplicate_devs);
+	dm_list_init(&_unused_duplicate_devs);
+	_found_duplicate_pvs = 0;
 }
 
 int lvmcache_pvid_is_locked(const char *pvid) {
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index f62607f..c964aec 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -198,6 +198,8 @@ void lvmcache_replace_dev(struct cmd_context *cmd, struct physical_volume *pv,
 
 int lvmcache_found_duplicate_pvs(void);
 
+int vg_has_duplicate_pvs(struct volume_group *vg);
+
 int lvmcache_contains_lock_type_sanlock(struct cmd_context *cmd);
 
 void lvmcache_get_max_name_lengths(struct cmd_context *cmd,
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 5d5ac48..0955d0a 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -395,6 +395,18 @@ cfg(devices_issue_discards_CFG, "issue_discards", devices_CFG_SECTION, 0, CFG_TY
 	"generally do. If enabled, discards will only be issued if both the\n"
 	"storage and kernel provide support.\n")
 
+cfg(devices_allow_changes_with_duplicate_pvs_CFG, "allow_changes_with_duplicate_pvs", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_ALLOW_CHANGES_WITH_DUPLICATE_PVS, vsn(2, 2, 153), NULL, 0, NULL,
+	"Allow VG modification while a PV appears on multiple devices.\n"
+	"When a PV appears on multiple devices, LVM attempts to choose the\n"
+	"best device to use for the PV. If the devices represent the same\n"
+	"underlying storage, the choice has minimal consequence. If the\n"
+	"devices represent different underlying storage, the wrong choice\n"
+	"can result in data loss if the VG is modified. Disabling this\n"
+	"setting is the safest option because it prevents modifying a VG\n"
+	"or activating LVs in it while a PV appears on multiple devices.\n"
+	"Enabling this setting allows the VG to be used as usual even with\n"
+	"uncertain devices.\n")
+
 cfg_array(allocation_cling_tag_list_CFG, "cling_tag_list", allocation_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 77), NULL, 0, NULL,
 	"Advise LVM which PVs to use when searching for new space.\n"
 	"When searching for free space to extend an LV, the 'cling' allocation\n"
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 5e10ce0..07ca5de 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -45,6 +45,7 @@
 #define DEFAULT_DATA_ALIGNMENT_DETECTION 1
 #define DEFAULT_ISSUE_DISCARDS 0
 #define DEFAULT_PV_MIN_SIZE_KB 2048
+#define DEFAULT_ALLOW_CHANGES_WITH_DUPLICATE_PVS 0
 
 #define DEFAULT_LOCKING_LIB "liblvm2clusterlock.so"
 #define DEFAULT_ERROR_WHEN_FULL 0
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index c7d3fcf..dbe443e 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3434,6 +3434,13 @@ int vg_write(struct volume_group *vg)
 		return 0;
 	}
 
+	if (lvmcache_found_duplicate_pvs() && vg_has_duplicate_pvs(vg) &&
+	    !find_config_tree_bool(vg->cmd, devices_allow_changes_with_duplicate_pvs_CFG, NULL)) {
+		log_error("Cannot update volume group %s with duplicate PV devices.",
+			  vg->name);
+		return 0;
+	}
+
 	if (vg_has_unknown_segments(vg) && !vg->cmd->handles_unknown_segments) {
 		log_error("Cannot update volume group %s with unknown segments in it!",
 			  vg->name);
@@ -3918,6 +3925,11 @@ static int _repair_inconsistent_vg(struct volume_group *vg)
 {
 	unsigned saved_handles_missing_pvs = vg->cmd->handles_missing_pvs;
 
+	if (lvmcache_found_duplicate_pvs()) {
+		log_debug_metadata("Skip metadata repair with duplicates.");
+		return 0;
+	}
+
 	/* Cannot write foreign VGs, the owner will repair it. */
 	if (_is_foreign_vg(vg)) {
 		log_verbose("Skip metadata repair for foreign VG.");
@@ -3952,6 +3964,11 @@ static int _wipe_outdated_pvs(struct cmd_context *cmd, struct volume_group *vg,
 	struct pv_list *pvl, *pvl2;
 	char uuid[64] __attribute__((aligned(8)));
 
+	if (lvmcache_found_duplicate_pvs()) {
+		log_debug_metadata("Skip wiping outdated PVs with duplicates.");
+		return 0;
+	}
+
 	/*
 	 * Cannot write foreign VGs, the owner will repair it.
 	 * Also, if another host is updating its VG, we may read
diff --git a/tools/toollib.c b/tools/toollib.c
index f1fe5b1..9917a67 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1070,6 +1070,15 @@ int lv_change_activate(struct cmd_context *cmd, struct logical_volume *lv,
 		}
 	}
 
+	if (is_change_activating(activate) &&
+	    lvmcache_found_duplicate_pvs() &&
+	    vg_has_duplicate_pvs(lv->vg) &&
+	    !find_config_tree_bool(cmd, devices_allow_changes_with_duplicate_pvs_CFG, NULL)) {
+		log_error("Cannot activate LVs in VG %s while PVs appear on duplicate devices.",
+			  lv->vg->name);
+		return 0;
+	}
+
 	if (!lv_active_change(cmd, lv, activate, 0))
 		return_0;
 


