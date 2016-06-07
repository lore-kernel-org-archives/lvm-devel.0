From: David Teigland <teigland@fedoraproject.org>
Date: Tue,  7 Jun 2016 20:22:56 +0000 (UTC)
Subject: master - lvmcache: fix duplicate handling with multiple scans
Message-ID: <20160607202256.8726960CE6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=199b7b55c21270d62ce35f32b16df200417dc41c
Commit:        199b7b55c21270d62ce35f32b16df200417dc41c
Parent:        01156de6f70ba5b1c8e2ae23c655ccd36ac59441
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Jun 6 15:20:55 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jun 7 15:15:51 2016 -0500

lvmcache: fix duplicate handling with multiple scans

Some commands scan labels to populate lvmcache multiple
times, i.e. lvmcache_init, scan labels to fill lvmcache,
lvmcache_destroy, then later repeat

Each time labels are scanned, duplicates are detected,
and preferred devices are chosen.  Each time this is done
within a single command, we want to choose the same
preferred devices.  So, check for existing preferences
when choosing preferred devices.

This also fixes a problem with the list of unused duplicate
devs when run in an lvm shell.  The devs had been allocated
from cmd memory, resulting in invalid list entries between
commands.
---
 lib/cache/lvmcache.c       |   90 ++++++++++++++++++++++++++++++++++++++-----
 lib/commands/toolcontext.c |    2 +
 lib/commands/toolcontext.h |    1 +
 3 files changed, 82 insertions(+), 11 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 1af6363..87b25f1 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -97,6 +97,8 @@ int lvmcache_init(void)
 	_vgs_locked = 0;
 
 	dm_list_init(&_vginfos);
+	dm_list_init(&_found_duplicate_devs);
+	dm_list_init(&_unused_duplicate_devs);
 
 	if (!(_vgname_hash = dm_hash_create(128)))
 		return 0;
@@ -471,6 +473,16 @@ void lvmcache_remove_unchosen_duplicate(struct device *dev)
 	}
 }
 
+static void _destroy_duplicate_device_list(struct dm_list *head)
+{
+	struct device_list *devl, *devl2;
+
+	dm_list_iterate_items_safe(devl, devl2, head) {
+		dm_list_del(&devl->list);
+		dm_free(devl);
+	}
+	dm_list_init(head);
+}
 
 static void _vginfo_attach_info(struct lvmcache_vginfo *vginfo,
 				struct lvmcache_info *info)
@@ -807,17 +819,22 @@ int vg_has_duplicate_pvs(struct volume_group *vg)
 	return 0;
 }
 
-int lvmcache_dev_is_unchosen_duplicate(struct device *dev)
+static int _dev_in_device_list(struct device *dev, struct dm_list *head)
 {
 	struct device_list *devl;
 
-	dm_list_iterate_items(devl, &_unused_duplicate_devs) {
+	dm_list_iterate_items(devl, head) {
 		if (devl->dev == dev)
 			return 1;
 	}
 	return 0;
 }
 
+int lvmcache_dev_is_unchosen_duplicate(struct device *dev)
+{
+	return _dev_in_device_list(dev, &_unused_duplicate_devs);
+}
+
 /*
  * Compare _found_duplicate_devs entries with the corresponding duplicate dev
  * in lvmcache.  There may be multiple duplicates in _found_duplicate_devs for
@@ -843,6 +860,7 @@ static void _choose_preferred_devs(struct cmd_context *cmd,
 	char uuid[64] __attribute__((aligned(8)));
 	const char *reason = "none";
 	struct dm_list altdevs;
+	struct dm_list new_unused;
 	struct dev_types *dt = cmd->dev_types;
 	struct device_list *devl, *devl_safe, *alt, *del;
 	struct lvmcache_info *info;
@@ -854,8 +872,11 @@ static void _choose_preferred_devs(struct cmd_context *cmd,
 	int has_fs1, has_fs2;
 	int has_lv1, has_lv2;
 	int same_size1, same_size2;
+	int prev_unchosen1, prev_unchosen2;
 	int change;
 
+	dm_list_init(&new_unused);
+
 	/*
 	 * Create a list of all alternate devs for the same pvid: altdevs.
 	 */
@@ -873,8 +894,11 @@ next:
 		}
 	}
 
-	if (!alt)
+	if (!alt) {
+		_destroy_duplicate_device_list(&_unused_duplicate_devs);
+		dm_list_splice(&_unused_duplicate_devs, &new_unused);
 		return;
+	}
 
 	/*
 	 * Find the device for the pvid that's currently in lvmcache.
@@ -904,6 +928,21 @@ next:
 			continue;
 		}
 
+		prev_unchosen1 = _dev_in_device_list(dev1, &_unused_duplicate_devs);
+		prev_unchosen2 = _dev_in_device_list(dev2, &_unused_duplicate_devs);
+
+		if (!prev_unchosen1 && !prev_unchosen2) {
+			/*
+			 * The cmd list saves the unchosen preference across
+			 * lvmcache_destroy.  Sometimes a single command will
+			 * fill lvmcache, destroy it, and refill it, and we
+			 * want the same duplicate preference to be preserved
+			 * in each instance of lvmcache for a single command.
+			 */
+			prev_unchosen1 = _dev_in_device_list(dev1, &cmd->unused_duplicate_devs);
+			prev_unchosen2 = _dev_in_device_list(dev2, &cmd->unused_duplicate_devs);
+		}
+
 		dev1_major = MAJOR(dev1->dev);
 		dev1_minor = MINOR(dev1->dev);
 		dev2_major = MAJOR(dev2->dev);
@@ -941,6 +980,11 @@ next:
 				dev_name(dev1), (unsigned long long)dev1_size,
 				dev_name(dev2), (unsigned long long)dev2_size);
 
+		log_debug_cache("PV %s: %s was prev %s. %s was prev %s.",
+				devl->dev->pvid,
+				dev_name(dev1), prev_unchosen1 ? "not chosen" : "<none>",
+				dev_name(dev2), prev_unchosen2 ? "not chosen" : "<none>");
+
 		log_debug_cache("PV %s: %s %s subsystem. %s %s subsystem.",
 				devl->dev->pvid,
 				dev_name(dev1), in_subsys1 ? "is in" : "is not in",
@@ -963,7 +1007,14 @@ next:
 
 		change = 0;
 
-		if (has_lv1 && !has_lv2) {
+		if (prev_unchosen1 && !prev_unchosen2) {
+			/* change to 2 (NB when unchosen is set we unprefer) */
+			change = 1;
+			reason = "of previous preference";
+		} else if (prev_unchosen2 && !prev_unchosen1) {
+			/* keep 1 (NB when unchosen is set we unprefer) */
+			reason = "of previous preference";
+		} else if (has_lv1 && !has_lv2) {
 			/* keep 1 */
 			reason = "device is used by LV";
 		} else if (has_lv2 && !has_lv1) {
@@ -1023,7 +1074,7 @@ next:
 
 		dm_list_move(add_cache_devs, &alt->list);
 
-		if ((del = dm_pool_alloc(cmd->mem, sizeof(*del)))) {
+		if ((del = dm_zalloc(sizeof(*del)))) {
 			del->dev = info->dev;
 			dm_list_add(del_cache_devs, &del->list);
 		}
@@ -1039,7 +1090,7 @@ next:
 	 * duplicates not being used in lvmcache.
 	 */
 
-	dm_list_splice(&_unused_duplicate_devs, &altdevs);
+	dm_list_splice(&new_unused, &altdevs);
 
 	goto next;
 }
@@ -1087,6 +1138,11 @@ int lvmcache_label_scan(struct cmd_context *cmd)
 
 	log_very_verbose("Scanning device labels");
 
+	/*
+	 * Duplicates found during this label scan are added to _found_duplicate_devs().
+	 */
+	_destroy_duplicate_device_list(&_found_duplicate_devs);
+
 	while ((dev = dev_iter_get(iter))) {
 		(void) label_read(dev, &label, UINT64_C(0));
 		dev_count++;
@@ -2127,7 +2183,7 @@ struct lvmcache_info *lvmcache_add(struct labeller *labeller,
 			 * use it.
 			 */
 
-			if (!(devl = dm_pool_alloc(fmt->cmd->mem, sizeof(*devl))))
+			if (!(devl = dm_zalloc(sizeof(*devl))))
 				return_NULL;
 			devl->dev = dev;
 
@@ -2266,13 +2322,25 @@ void lvmcache_destroy(struct cmd_context *cmd, int retain_orphans, int reset)
 		log_error(INTERNAL_ERROR "_vginfos list should be empty");
 	dm_list_init(&_vginfos);
 
+	/*
+	 * Copy the current _unused_duplicate_devs into a cmd list before
+	 * destroying _unused_duplicate_devs.
+	 *
+	 * One command can init/populate/destroy lvmcache multiple times.  Each
+	 * time it will encounter duplicates and choose the preferrred devs.
+	 * We want the same preferred devices to be chosen each time, so save
+	 * the unpreferred devs here so that _choose_preferred_devs can use
+	 * this to make the same choice each time.
+	 */
+	dm_list_init(&cmd->unused_duplicate_devs);
+	lvmcache_get_unused_duplicate_devs(cmd, &cmd->unused_duplicate_devs);
+	_destroy_duplicate_device_list(&_unused_duplicate_devs);
+	_destroy_duplicate_device_list(&_found_duplicate_devs); /* should be empty anyway */
+	_found_duplicate_pvs = 0;
+
 	if (retain_orphans)
 		if (!init_lvmcache_orphans(cmd))
 			stack;
-
-	dm_list_init(&_found_duplicate_devs);
-	dm_list_init(&_unused_duplicate_devs);
-	_found_duplicate_pvs = 0;
 }
 
 int lvmcache_pvid_is_locked(const char *pvid) {
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 1e3f14a..076f48d 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1977,6 +1977,8 @@ struct cmd_context *create_toolcontext(unsigned is_long_lived,
 	if (!init_lvmcache_orphans(cmd))
 		goto_out;
 
+	dm_list_init(&cmd->unused_duplicate_devs);
+
 	if (!_init_segtypes(cmd))
 		goto_out;
 
diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index 2cecf27..f4beae1 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -197,6 +197,7 @@ struct cmd_context {
 	const char *report_list_item_separator;
 	const char *time_format;
 	unsigned rand_seed;
+	struct dm_list unused_duplicate_devs; /* save preferences between lvmcache instances */
 };
 
 /*


