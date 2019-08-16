From: David Teigland <teigland@sourceware.org>
Date: Fri, 16 Aug 2019 14:28:34 -0400
Subject: master - lvmcache: renaming functions and variables
Message-ID: <201908161828.x7GISYsE006491@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=677833ce6fcd7596f8dd5857bde90610cd6500c7
Commit:        677833ce6fcd7596f8dd5857bde90610cd6500c7
Parent:        65bcd16be2cb46c73f6243e553b4a8685c159b7a
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Aug 1 13:50:04 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Aug 16 13:26:11 2019 -0500

lvmcache: renaming functions and variables

related to duplicates, no functional changes.
---
 lib/cache/lvmcache.c    |  119 +++++++++++++++++++++--------------------------
 lib/cache/lvmcache.h    |   10 ++--
 lib/label/hints.c       |    8 ++--
 lib/metadata/metadata.c |    2 +-
 lib/metadata/pv.c       |    2 +-
 lib/report/report.c     |    2 +-
 tools/pvchange.c        |    2 +-
 tools/toollib.c         |   14 +++---
 8 files changed, 73 insertions(+), 86 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index e2d19e8..2634f07 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -72,8 +72,8 @@ static struct dm_hash_table *_pvid_hash = NULL;
 static struct dm_hash_table *_vgid_hash = NULL;
 static struct dm_hash_table *_vgname_hash = NULL;
 static DM_LIST_INIT(_vginfos);
-static DM_LIST_INIT(_found_duplicate_devs);
-static DM_LIST_INIT(_unused_duplicate_devs);
+static DM_LIST_INIT(_initial_duplicates);
+static DM_LIST_INIT(_unused_duplicates);
 static DM_LIST_INIT(_prev_unused_duplicate_devs);
 static int _vgs_locked = 0;
 static int _found_duplicate_pvs = 0;	/* If we never see a duplicate PV we can skip checking for them later. */
@@ -88,8 +88,8 @@ int lvmcache_init(struct cmd_context *cmd)
 	_vgs_locked = 0;
 
 	dm_list_init(&_vginfos);
-	dm_list_init(&_found_duplicate_devs);
-	dm_list_init(&_unused_duplicate_devs);
+	dm_list_init(&_initial_duplicates);
+	dm_list_init(&_unused_duplicates);
 	dm_list_init(&_prev_unused_duplicate_devs);
 
 	if (!(_vgname_hash = dm_hash_create(128)))
@@ -117,22 +117,9 @@ void lvmcache_unlock_vgname(const char *vgname)
 	}
 }
 
-/*
- * When lvmcache sees a duplicate PV, this is set.
- * process_each_pv() can avoid searching for duplicates
- * by checking this and seeing that no duplicate PVs exist.
- *
- *
- * found_duplicate_pvs tells the process_each_pv code
- * to search the devices list for duplicates, so that
- * devices can be processed together with their
- * duplicates (while processing the VG, rather than
- * reporting pv->dev under the VG, and its duplicate
- * outside the VG context.)
- */
-int lvmcache_found_duplicate_pvs(void)
+bool lvmcache_has_duplicate_devs(void)
 {
-	return _found_duplicate_pvs;
+	return _found_duplicate_pvs ? true : false;
 }
 
 int lvmcache_found_duplicate_vgnames(void)
@@ -140,11 +127,11 @@ int lvmcache_found_duplicate_vgnames(void)
 	return _found_duplicate_vgnames;
 }
 
-int lvmcache_get_unused_duplicate_devs(struct cmd_context *cmd, struct dm_list *head)
+int lvmcache_get_unused_duplicates(struct cmd_context *cmd, struct dm_list *head)
 {
 	struct device_list *devl, *devl2;
 
-	dm_list_iterate_items(devl, &_unused_duplicate_devs) {
+	dm_list_iterate_items(devl, &_unused_duplicates) {
 		if (!(devl2 = dm_pool_alloc(cmd->mem, sizeof(*devl2)))) {
 			log_error("device_list element allocation failed");
 			return 0;
@@ -155,11 +142,11 @@ int lvmcache_get_unused_duplicate_devs(struct cmd_context *cmd, struct dm_list *
 	return 1;
 }
 
-void lvmcache_remove_unchosen_duplicate(struct device *dev)
+void lvmcache_del_dev_from_duplicates(struct device *dev)
 {
 	struct device_list *devl;
 
-	dm_list_iterate_items(devl, &_unused_duplicate_devs) {
+	dm_list_iterate_items(devl, &_unused_duplicates) {
 		if (devl->dev == dev) {
 			dm_list_del(&devl->list);
 			return;
@@ -167,7 +154,7 @@ void lvmcache_remove_unchosen_duplicate(struct device *dev)
 	}
 }
 
-static void _destroy_duplicate_device_list(struct dm_list *head)
+static void _destroy_device_list(struct dm_list *head)
 {
 	struct device_list *devl, *devl2;
 
@@ -385,7 +372,7 @@ int vg_has_duplicate_pvs(struct volume_group *vg)
 	struct device_list *devl;
 
 	dm_list_iterate_items(pvl, &vg->pvs) {
-		dm_list_iterate_items(devl, &_unused_duplicate_devs) {
+		dm_list_iterate_items(devl, &_unused_duplicates) {
 			if (id_equal(&pvl->pv->id, (const struct id *)devl->dev->pvid))
 				return 1;
 		}
@@ -404,9 +391,9 @@ int dev_in_device_list(struct device *dev, struct dm_list *head)
 	return 0;
 }
 
-int lvmcache_dev_is_unchosen_duplicate(struct device *dev)
+bool lvmcache_dev_is_unused_duplicate(struct device *dev)
 {
-	return dev_in_device_list(dev, &_unused_duplicate_devs);
+	return dev_in_device_list(dev, &_unused_duplicates) ? true : false;
 }
 
 /*
@@ -441,7 +428,7 @@ static void _filter_duplicate_devs(struct cmd_context *cmd)
 	struct lvmcache_info *info;
 	struct device_list *devl, *devl2;
 
-	dm_list_iterate_items_safe(devl, devl2, &_unused_duplicate_devs) {
+	dm_list_iterate_items_safe(devl, devl2, &_unused_duplicates) {
 
 		if (!(info = lvmcache_info_from_pvid(devl->dev->pvid, NULL, 0)))
 			continue;
@@ -453,24 +440,24 @@ static void _filter_duplicate_devs(struct cmd_context *cmd)
 		}
 	}
 
-	if (dm_list_empty(&_unused_duplicate_devs))
+	if (dm_list_empty(&_unused_duplicates))
 		_found_duplicate_pvs = 0;
 }
 
-static void _warn_duplicate_devs(struct cmd_context *cmd)
+static void _warn_unused_duplicates(struct cmd_context *cmd)
 {
 	char uuid[64] __attribute__((aligned(8)));
 	struct lvmcache_info *info;
 	struct device_list *devl, *devl2;
 
-	dm_list_iterate_items_safe(devl, devl2, &_unused_duplicate_devs) {
+	dm_list_iterate_items_safe(devl, devl2, &_unused_duplicates) {
 		if (!id_write_format((const struct id *)devl->dev->pvid, uuid, sizeof(uuid)))
 			stack;
 
 		log_warn("WARNING: Not using device %s for PV %s.", dev_name(devl->dev), uuid);
 	}
 
-	dm_list_iterate_items_safe(devl, devl2, &_unused_duplicate_devs) {
+	dm_list_iterate_items_safe(devl, devl2, &_unused_duplicates) {
 		/* info for the preferred device that we're actually using */
 		if (!(info = lvmcache_info_from_pvid(devl->dev->pvid, NULL, 0)))
 			continue;
@@ -484,26 +471,26 @@ static void _warn_duplicate_devs(struct cmd_context *cmd)
 }
 
 /*
- * Compare _found_duplicate_devs entries with the corresponding duplicate dev
- * in lvmcache.  There may be multiple duplicates in _found_duplicate_devs for
- * a given pvid.  If a dev from _found_duplicate_devs is preferred over the dev
+ * Compare _initial_duplicates entries with the corresponding duplicate dev
+ * in lvmcache.  There may be multiple duplicates in _initial_duplicates for
+ * a given pvid.  If a dev from _initial_duplicates is preferred over the dev
  * in lvmcache, then drop the dev in lvmcache and rescan the preferred dev to
  * add it to lvmcache.
  *
- * _found_duplicate_devs: duplicate devs found during initial scan.
+ * _initial_duplicates: duplicate devs found during initial scan.
  * These are compared to lvmcache devs to see if any are preferred.
  *
- * _unused_duplicate_devs: duplicate devs not chosen to be used.
- * These are _found_duplicate_devs entries that were not chosen,
+ * _unused_duplicates: duplicate devs not chosen to be used.
+ * These are _initial_duplicates entries that were not chosen,
  * or unpreferred lvmcache devs that were dropped.
  *
  * del_cache_devs: devices to drop from lvmcache
  * add_cache_devs: devices to scan to add to lvmcache
  */
 
-static void _choose_preferred_devs(struct cmd_context *cmd,
-				   struct dm_list *del_cache_devs,
-				   struct dm_list *add_cache_devs)
+static void _choose_duplicates(struct cmd_context *cmd,
+			       struct dm_list *del_cache_devs,
+			       struct dm_list *add_cache_devs)
 {
 	const char *reason;
 	struct dm_list altdevs;
@@ -531,7 +518,7 @@ next:
 	dm_list_init(&altdevs);
 	alt = NULL;
 
-	dm_list_iterate_items_safe(devl, devl_safe, &_found_duplicate_devs) {
+	dm_list_iterate_items_safe(devl, devl_safe, &_initial_duplicates) {
 		if (!alt) {
 			dm_list_move(&altdevs, &devl->list);
 			alt = devl;
@@ -542,8 +529,8 @@ next:
 	}
 
 	if (!alt) {
-		_destroy_duplicate_device_list(&_unused_duplicate_devs);
-		dm_list_splice(&_unused_duplicate_devs, &new_unused);
+		_destroy_device_list(&_unused_duplicates);
+		dm_list_splice(&_unused_duplicates, &new_unused);
 		return;
 	}
 
@@ -578,8 +565,8 @@ next:
 			continue;
 		}
 
-		prev_unchosen1 = dev_in_device_list(dev1, &_unused_duplicate_devs);
-		prev_unchosen2 = dev_in_device_list(dev2, &_unused_duplicate_devs);
+		prev_unchosen1 = dev_in_device_list(dev1, &_unused_duplicates);
+		prev_unchosen2 = dev_in_device_list(dev2, &_unused_duplicates);
 
 		if (!prev_unchosen1 && !prev_unchosen2) {
 			/*
@@ -732,9 +719,9 @@ next:
 	}
 
 	/*
-	 * alt devs not chosen are moved to _unused_duplicate_devs.
-	 * del_cache_devs being dropped are moved to _unused_duplicate_devs
-	 * after being dropped.  So, _unused_duplicate_devs represents all
+	 * alt devs not chosen are moved to _unused_duplicates.
+	 * del_cache_devs being dropped are moved to _unused_duplicates
+	 * after being dropped.  So, _unused_duplicates represents all
 	 * duplicates not being used in lvmcache.
 	 */
 
@@ -879,9 +866,9 @@ int lvmcache_label_scan(struct cmd_context *cmd)
 		log_error("Scan failed to refresh device filter.");
 
 	/*
-	 * Duplicates found during this label scan are added to _found_duplicate_devs().
+	 * Duplicates found during this label scan are added to _initial_duplicates().
 	 */
-	_destroy_duplicate_device_list(&_found_duplicate_devs);
+	_destroy_device_list(&_initial_duplicates);
 
 	/*
 	 * Do the actual scanning.  This populates lvmcache
@@ -895,7 +882,7 @@ int lvmcache_label_scan(struct cmd_context *cmd)
 	label_scan(cmd);
 
 	/*
-	 * _choose_preferred_devs() returns:
+	 * _choose_duplicates() returns:
 	 *
 	 * . del_cache_devs: a list of devs currently in lvmcache that should
 	 * be removed from lvmcache because they will be replaced with
@@ -909,16 +896,16 @@ int lvmcache_label_scan(struct cmd_context *cmd)
 	 * the devs that are preferred to add them to lvmcache.
 	 *
 	 * Keep a complete list of all devs that are unused by moving the
-	 * del_cache_devs onto _unused_duplicate_devs.
+	 * del_cache_devs onto _unused_duplicates.
 	 */
 
-	if (!dm_list_empty(&_found_duplicate_devs)) {
+	if (!dm_list_empty(&_initial_duplicates)) {
 		dm_list_init(&del_cache_devs);
 		dm_list_init(&add_cache_devs);
 
 		log_debug_cache("Resolving duplicate devices");
 
-		_choose_preferred_devs(cmd, &del_cache_devs, &add_cache_devs);
+		_choose_duplicates(cmd, &del_cache_devs, &add_cache_devs);
 
 		dm_list_iterate_items(devl, &del_cache_devs) {
 			log_debug_cache("Drop duplicate device %s in lvmcache", dev_name(devl->dev));
@@ -931,7 +918,7 @@ int lvmcache_label_scan(struct cmd_context *cmd)
 			label_read(devl->dev);
 		}
 
-		dm_list_splice(&_unused_duplicate_devs, &del_cache_devs);
+		dm_list_splice(&_unused_duplicates, &del_cache_devs);
 
 		/*
 		 * This may remove some entries from the unused_duplicates list for
@@ -943,7 +930,7 @@ int lvmcache_label_scan(struct cmd_context *cmd)
 		 * Warn about remaining duplicates that may actually be separate copies of
 		 * the same device.
 		 */
-		_warn_duplicate_devs(cmd);
+		_warn_unused_duplicates(cmd);
 	}
 
 	r = 1;
@@ -1028,11 +1015,11 @@ struct device *lvmcache_device_from_pvid(struct cmd_context *cmd, const struct i
 	return NULL;
 }
 
-int lvmcache_pvid_in_unchosen_duplicates(const char *pvid)
+int lvmcache_pvid_in_unused_duplicates(const char *pvid)
 {
 	struct device_list *devl;
 
-	dm_list_iterate_items(devl, &_unused_duplicate_devs) {
+	dm_list_iterate_items(devl, &_unused_duplicates) {
 		if (!strncmp(devl->dev->pvid, pvid, ID_LEN))
 			return 1;
 	}
@@ -1863,7 +1850,7 @@ struct lvmcache_info *lvmcache_add(struct labeller *labeller,
 				return_NULL;
 			devl->dev = dev;
 
-			dm_list_add(&_found_duplicate_devs, &devl->list);
+			dm_list_add(&_initial_duplicates, &devl->list);
 			_found_duplicate_pvs = 1;
 			if (is_duplicate)
 				*is_duplicate = 1;
@@ -1971,8 +1958,8 @@ void lvmcache_destroy(struct cmd_context *cmd, int retain_orphans, int reset)
 	dm_list_init(&_vginfos);
 
 	/*
-	 * Move the current _unused_duplicate_devs to _prev_unused_duplicate_devs
-	 * before destroying _unused_duplicate_devs.
+	 * Move the current _unused_duplicates to _prev_unused_duplicate_devs
+	 * before destroying _unused_duplicates.
 	 *
 	 * One command can init/populate/destroy lvmcache multiple times.  Each
 	 * time it will encounter duplicates and choose the preferrred devs.
@@ -1980,10 +1967,10 @@ void lvmcache_destroy(struct cmd_context *cmd, int retain_orphans, int reset)
 	 * the unpreferred devs here so that _choose_preferred_devs can use
 	 * this to make the same choice each time.
 	 */
-	_destroy_duplicate_device_list(&_prev_unused_duplicate_devs);
-	dm_list_splice(&_prev_unused_duplicate_devs, &_unused_duplicate_devs);
-	_destroy_duplicate_device_list(&_unused_duplicate_devs);
-	_destroy_duplicate_device_list(&_found_duplicate_devs); /* should be empty anyway */
+	_destroy_device_list(&_prev_unused_duplicate_devs);
+	dm_list_splice(&_prev_unused_duplicate_devs, &_unused_duplicates);
+	_destroy_device_list(&_unused_duplicates);
+	_destroy_device_list(&_initial_duplicates); /* should be empty anyway */
 	_found_duplicate_pvs = 0;
 
 	if (retain_orphans) {
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index e2d967c..c831d0e 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -169,10 +169,10 @@ struct metadata_area *lvmcache_get_mda(struct cmd_context *cmd,
                                       struct device *dev,
                                       int use_mda_num);
 
-int lvmcache_found_duplicate_pvs(void);
+bool lvmcache_has_duplicate_devs(void);
 int lvmcache_found_duplicate_vgnames(void);
 
-int lvmcache_get_unused_duplicate_devs(struct cmd_context *cmd, struct dm_list *head);
+int lvmcache_get_unused_duplicates(struct cmd_context *cmd, struct dm_list *head);
 
 int vg_has_duplicate_pvs(struct volume_group *vg);
 
@@ -183,11 +183,11 @@ void lvmcache_get_max_name_lengths(struct cmd_context *cmd,
 
 int lvmcache_vg_is_foreign(struct cmd_context *cmd, const char *vgname, const char *vgid);
 
-int lvmcache_dev_is_unchosen_duplicate(struct device *dev);
+bool lvmcache_dev_is_unused_duplicate(struct device *dev);
 
-void lvmcache_remove_unchosen_duplicate(struct device *dev);
+void lvmcache_del_dev_from_duplicates(struct device *dev);
 
-int lvmcache_pvid_in_unchosen_duplicates(const char *pvid);
+int lvmcache_pvid_in_unused_duplicates(const char *pvid);
 
 bool lvmcache_scan_mismatch(struct cmd_context *cmd, const char *vgname, const char *vgid);
 
diff --git a/lib/label/hints.c b/lib/label/hints.c
index 72dc91e..6de54bc 100644
--- a/lib/label/hints.c
+++ b/lib/label/hints.c
@@ -450,7 +450,7 @@ int validate_hints(struct cmd_context *cmd, struct dm_list *hints)
 	if (!cmd->use_hints && !cmd->pvscan_recreate_hints)
 		return 0;
 
-	if (lvmcache_found_duplicate_pvs()) {
+	if (lvmcache_has_duplicate_devs()) {
 		log_debug("Hints not used with duplicate pvs");
 		ret = 0;
 		goto out;
@@ -820,7 +820,7 @@ int write_hint_file(struct cmd_context *cmd, int newhints)
 	if (!cmd->use_hints && !cmd->pvscan_recreate_hints)
 		return 0;
 
-	if (lvmcache_found_duplicate_pvs() || lvmcache_found_duplicate_vgnames()) {
+	if (lvmcache_has_duplicate_devs() || lvmcache_found_duplicate_vgnames()) {
 		/*
 		 * When newhints is EMPTY, it means get_hints() found an empty
 		 * hint file.  So we scanned all devs and found duplicate pvids
@@ -841,11 +841,11 @@ int write_hint_file(struct cmd_context *cmd, int newhints)
 
 	t = time(NULL);
 
-	if (lvmcache_found_duplicate_pvs() || lvmcache_found_duplicate_vgnames()) {
+	if (lvmcache_has_duplicate_devs() || lvmcache_found_duplicate_vgnames()) {
 		fprintf(fp, "# Created empty by %s pid %d %s", cmd->name, getpid(), ctime(&t));
 
 		/* leave a comment about why it's empty in case someone is curious */
-		if (lvmcache_found_duplicate_pvs())
+		if (lvmcache_has_duplicate_devs())
 			fprintf(fp, "# info: duplicate_pvs\n");
 		if (lvmcache_found_duplicate_vgnames())
 			fprintf(fp, "# info: duplicate_vgnames\n");
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 09000de..2c61bde 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2962,7 +2962,7 @@ int vg_write(struct volume_group *vg)
 		return 0;
 	}
 
-	if (lvmcache_found_duplicate_pvs() && vg_has_duplicate_pvs(vg) &&
+	if (lvmcache_has_duplicate_devs() && vg_has_duplicate_pvs(vg) &&
 	    !find_config_tree_bool(vg->cmd, devices_allow_changes_with_duplicate_pvs_CFG, NULL)) {
 		log_error("Cannot update volume group %s with duplicate PV devices.",
 			  vg->name);
diff --git a/lib/metadata/pv.c b/lib/metadata/pv.c
index 7b6f778..9cebbac 100644
--- a/lib/metadata/pv.c
+++ b/lib/metadata/pv.c
@@ -236,7 +236,7 @@ char *pv_attr_dup(struct dm_pool *mem, const struct physical_volume *pv)
 {
 	char *repstr;
 	int used = is_used_pv(pv);
-	int duplicate = lvmcache_dev_is_unchosen_duplicate(pv->dev);
+	int duplicate = lvmcache_dev_is_unused_duplicate(pv->dev);
 
 	if (!(repstr = dm_pool_zalloc(mem, 4))) {
 		log_error("dm_pool_alloc failed");
diff --git a/lib/report/report.c b/lib/report/report.c
index e1150f6..730b0af 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -3354,7 +3354,7 @@ static int _pvduplicate_disp(struct dm_report *rh, struct dm_pool *mem,
 			    const void *data, void *private)
 {
 	const struct physical_volume *pv = (const struct physical_volume *) data;
-	int duplicate = lvmcache_dev_is_unchosen_duplicate(pv->dev);
+	int duplicate = lvmcache_dev_is_unused_duplicate(pv->dev);
 
 	return _binary_disp(rh, mem, field, duplicate, GET_FIRST_RESERVED_NAME(pv_duplicate_y), private);
 }
diff --git a/tools/pvchange.c b/tools/pvchange.c
index 1ece34a..dd72bf1 100644
--- a/tools/pvchange.c
+++ b/tools/pvchange.c
@@ -40,7 +40,7 @@ static int _pvchange_single(struct cmd_context *cmd, struct volume_group *vg,
 	 * to be copied here to prevent the pv_write() which is called before
 	 * the vg_write().
 	 */
-	if (vg && lvmcache_found_duplicate_pvs() && vg_has_duplicate_pvs(vg)) {
+	if (vg && lvmcache_has_duplicate_devs() && vg_has_duplicate_pvs(vg)) {
 	    	if (!find_config_tree_bool(vg->cmd, devices_allow_changes_with_duplicate_pvs_CFG, NULL)) {
 			log_error("Cannot update volume group %s with duplicate PV devices.",
 				  vg->name);
diff --git a/tools/toollib.c b/tools/toollib.c
index 155528c..1f41feb 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1048,7 +1048,7 @@ int lv_change_activate(struct cmd_context *cmd, struct logical_volume *lv,
 	}
 
 	if (is_change_activating(activate) &&
-	    lvmcache_found_duplicate_pvs() &&
+	    lvmcache_has_duplicate_devs() &&
 	    vg_has_duplicate_pvs(lv->vg) &&
 	    !find_config_tree_bool(cmd, devices_allow_changes_with_duplicate_pvs_CFG, NULL)) {
 		log_error("Cannot activate LVs in VG %s while PVs appear on duplicate devices.",
@@ -1499,7 +1499,7 @@ int process_each_label(struct cmd_context *cmd, int argc, char **argv,
 			}
 
 			if (!(label = lvmcache_get_dev_label(dev))) {
-				if (!lvmcache_dev_is_unchosen_duplicate(dev)) {
+				if (!lvmcache_dev_is_unused_duplicate(dev)) {
 					log_error("No physical volume label read from %s.", argv[opt]);
 					ret_max = ECMD_FAILED;
 				} else {
@@ -4089,7 +4089,7 @@ static int _process_duplicate_pvs(struct cmd_context *cmd,
 
 	dm_list_init(&unused_duplicate_devs);
 
-	if (!lvmcache_get_unused_duplicate_devs(cmd, &unused_duplicate_devs))
+	if (!lvmcache_get_unused_duplicates(cmd, &unused_duplicate_devs))
 		return_ECMD_FAILED;
 
 	dm_list_iterate_items(devl, &unused_duplicate_devs) {
@@ -5016,7 +5016,7 @@ static int _pvcreate_check_single(struct cmd_context *cmd,
 	/*
 	 * Don't allow using a device with duplicates.
 	 */
-	if (lvmcache_pvid_in_unchosen_duplicates(pd->dev->pvid)) {
+	if (lvmcache_pvid_in_unused_duplicates(pd->dev->pvid)) {
 		log_error("Cannot use device %s with duplicates.", pd->name);
 		dm_list_move(&pp->arg_fail, &pd->list);
 		return 1;
@@ -5473,9 +5473,9 @@ int pvcreate_each_device(struct cmd_context *cmd,
 	 * erase them below without going through the normal processing code.
 	 */
 	if (pp->is_remove && (pp->force == DONT_PROMPT_OVERRIDE) &&
-	   !dm_list_empty(&pp->arg_devices) && lvmcache_found_duplicate_pvs()) {
+	   !dm_list_empty(&pp->arg_devices) && lvmcache_has_duplicate_devs()) {
 		dm_list_iterate_items_safe(pd, pd2, &pp->arg_devices) {
-			if (lvmcache_dev_is_unchosen_duplicate(pd->dev)) {
+			if (lvmcache_dev_is_unused_duplicate(pd->dev)) {
 				log_debug("Found pvremove arg %s: device is a duplicate.", pd->name);
 				dm_list_move(&remove_duplicates, &pd->list);
 			}
@@ -5806,7 +5806,7 @@ do_command:
 			continue;
 		}
 
-		lvmcache_remove_unchosen_duplicate(pd->dev);
+		lvmcache_del_dev_from_duplicates(pd->dev);
 
 		log_print_unless_silent("Labels on physical volume \"%s\" successfully wiped.",
 					pd->name);


