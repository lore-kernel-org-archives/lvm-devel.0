From: David Teigland <teigland@sourceware.org>
Date: Mon, 23 Apr 2018 09:52:34 -0400
Subject: master - dev_cache: clean up scan
Message-ID: <201804231352.w3NDqYVd000841@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c0973e70a58e7e14e9cca29a0f8ad12719ea554f
Commit:        c0973e70a58e7e14e9cca29a0f8ad12719ea554f
Parent:        89c65d4f71e51c2db4fcba176546d2474e3451bd
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Apr 9 11:13:43 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 20 11:22:48 2018 -0500

dev_cache: clean up scan

Pull out all of the twisted logic and simply call dev_cache_scan
at the start of the command prior to label scan.
---
 daemons/clvmd/lvm-functions.c   |    1 -
 lib/cache/lvmcache.c            |    5 +--
 lib/commands/toolcontext.c      |    1 -
 lib/device/dev-cache.c          |   40 ++++----------------------------------
 lib/device/dev-cache.h          |    6 +---
 lib/filters/filter-persistent.c |   13 ------------
 lib/label/label.c               |    2 +-
 lib/misc/lvm-globals.c          |   11 ----------
 lib/misc/lvm-globals.h          |    2 -
 tools/lvmcmdline.c              |    1 -
 tools/polldaemon.c              |    9 +++----
 tools/pvscan.c                  |    4 +-
 tools/toollib.c                 |    2 -
 tools/vgimportclone.c           |    1 -
 14 files changed, 16 insertions(+), 82 deletions(-)

diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
index 64bdab3..c278692 100644
--- a/daemons/clvmd/lvm-functions.c
+++ b/daemons/clvmd/lvm-functions.c
@@ -661,7 +661,6 @@ int do_refresh_cache(void)
 		return -1;
 	}
 
-	init_full_scan_done(0);
 	init_ignore_suspended_devices(1);
 	lvmcache_force_next_label_scan();
 	lvmcache_label_scan(cmd);
diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 78665bf..ef180b9 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -157,6 +157,8 @@ void lvmcache_seed_infos_from_lvmetad(struct cmd_context *cmd)
 	if (!lvmetad_used() || _has_scanned)
 		return;
 
+	dev_cache_scan();
+
 	if (!lvmetad_pv_list_to_lvmcache(cmd)) {
 		stack;
 		return;
@@ -357,9 +359,6 @@ void lvmcache_drop_metadata(const char *vgname, int drop_precommitted)
 		_drop_metadata(FMT_TEXT_ORPHAN_VG_NAME, 0);
 		_drop_metadata(FMT_LVM1_ORPHAN_VG_NAME, 0);
 		_drop_metadata(FMT_POOL_ORPHAN_VG_NAME, 0);
-
-		/* Indicate that PVs could now be missing from the cache */
-		init_full_scan_done(0);
 	} else
 		_drop_metadata(vgname, drop_precommitted);
 }
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 3dc3e2d..a54f4d7 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1648,7 +1648,6 @@ static void _init_rand(struct cmd_context *cmd)
 
 static void _init_globals(struct cmd_context *cmd)
 {
-	init_full_scan_done(0);
 	init_mirror_in_sync(0);
 }
 
diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index e72ffd6..52edad8 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -1077,12 +1077,11 @@ static int _insert(const char *path, const struct stat *info,
 	return 1;
 }
 
-static void _full_scan(int dev_scan)
+void dev_cache_scan(void)
 {
 	struct dir_list *dl;
 
-	if (_cache.has_scanned && !dev_scan)
-		return;
+	_cache.has_scanned = 1;
 
 	_insert_dirs(&_cache.dirs);
 
@@ -1090,9 +1089,6 @@ static void _full_scan(int dev_scan)
 
 	dm_list_iterate_items(dl, &_cache.files)
 		_insert_file(dl->dir);
-
-	_cache.has_scanned = 1;
-	init_full_scan_done(1);
 }
 
 int dev_cache_has_scanned(void)
@@ -1100,14 +1096,6 @@ int dev_cache_has_scanned(void)
 	return _cache.has_scanned;
 }
 
-void dev_cache_scan(int do_scan)
-{
-	if (!do_scan)
-		_cache.has_scanned = 1;
-	else
-		_full_scan(1);
-}
-
 static int _init_preferred_names(struct cmd_context *cmd)
 {
 	const struct dm_config_node *cn;
@@ -1171,7 +1159,6 @@ out:
 int dev_cache_init(struct cmd_context *cmd)
 {
 	_cache.names = NULL;
-	_cache.has_scanned = 0;
 
 	if (!(_cache.mem = dm_pool_create("dev_cache", 10 * 1024)))
 		return_0;
@@ -1413,7 +1400,7 @@ struct device *dev_cache_get(const char *name, struct dev_filter *f)
 		_insert(name, info_available ? &buf : NULL, 0, obtain_device_list_from_udev());
 		d = (struct device *) dm_hash_lookup(_cache.names, name);
 		if (!d) {
-			_full_scan(0);
+			dev_cache_scan();
 			d = (struct device *) dm_hash_lookup(_cache.names, name);
 		}
 	}
@@ -1469,7 +1456,7 @@ struct device *dev_cache_get_by_devt(dev_t dev, struct dev_filter *f)
 			}
 		}
 
-		_full_scan(0);
+		dev_cache_scan();
 		d = _dev_cache_seek_devt(dev);
 	}
 
@@ -1477,17 +1464,7 @@ struct device *dev_cache_get_by_devt(dev_t dev, struct dev_filter *f)
 		      f->passes_filter(f, d))) ? d : NULL;
 }
 
-void dev_cache_full_scan(struct dev_filter *f)
-{
-	if (f && f->wipe) {
-		f->wipe(f); /* might call _full_scan(1) */
-		if (!full_scan_done())
-			_full_scan(1);
-	} else
-		_full_scan(1);
-}
-
-struct dev_iter *dev_iter_create(struct dev_filter *f, int dev_scan)
+struct dev_iter *dev_iter_create(struct dev_filter *f, int unused)
 {
 	struct dev_iter *di = dm_malloc(sizeof(*di));
 
@@ -1496,13 +1473,6 @@ struct dev_iter *dev_iter_create(struct dev_filter *f, int dev_scan)
 		return NULL;
 	}
 
-	if (dev_scan && !trust_cache()) {
-		/* Flag gets reset between each command */
-		if (!full_scan_done())
-			dev_cache_full_scan(f);
-	} else
-		_full_scan(0);
-
 	di->current = btree_first(_cache.devices);
 	di->filter = f;
 	if (di->filter)
diff --git a/lib/device/dev-cache.h b/lib/device/dev-cache.h
index 546b1fe..4797274 100644
--- a/lib/device/dev-cache.h
+++ b/lib/device/dev-cache.h
@@ -46,10 +46,8 @@ int dev_cache_exit(void);
  */
 int dev_cache_check_for_open_devices(void);
 
-/* Trigger(1) or avoid(0) a scan */
-void dev_cache_scan(int do_scan);
+void dev_cache_scan(void);
 int dev_cache_has_scanned(void);
-void dev_cache_full_scan(struct dev_filter *f);
 
 int dev_cache_add_dir(const char *path);
 int dev_cache_add_loopfile(const char *path);
@@ -66,7 +64,7 @@ void dev_set_preferred_name(struct dm_str_list *sl, struct device *dev);
  * Object for iterating through the cache.
  */
 struct dev_iter;
-struct dev_iter *dev_iter_create(struct dev_filter *f, int dev_scan);
+struct dev_iter *dev_iter_create(struct dev_filter *f, int unused);
 void dev_iter_destroy(struct dev_iter *iter);
 struct device *dev_iter_get(struct dev_iter *iter);
 
diff --git a/lib/filters/filter-persistent.c b/lib/filters/filter-persistent.c
index 5bc0861..a4151c2 100644
--- a/lib/filters/filter-persistent.c
+++ b/lib/filters/filter-persistent.c
@@ -48,11 +48,7 @@ static void _persistent_filter_wipe(struct dev_filter *f)
 {
 	struct pfilter *pf = (struct pfilter *) f->private;
 
-	log_verbose("Wiping cache of LVM-capable devices");
 	dm_hash_wipe(pf->devices);
-
-	/* Trigger complete device scan */
-	dev_cache_scan(1);
 }
 
 static int _read_array(struct pfilter *pf, struct dm_config_tree *cft,
@@ -126,15 +122,6 @@ int persistent_filter_load(struct dev_filter *f, struct dm_config_tree **cft_out
 	/* _read_array(pf, cft, "persistent_filter_cache/invalid_devices",
 	   PF_BAD_DEVICE); */
 
-	/* Did we find anything? */
-	if (dm_hash_get_num_entries(pf->devices)) {
-		/* We populated dev_cache ourselves */
-		dev_cache_scan(0);
-		if (!dev_cache_index_devs())
-			stack;
-		r = 1;
-	}
-
 	log_very_verbose("Loaded persistent filter cache from %s", pf->file);
 
       out:
diff --git a/lib/label/label.c b/lib/label/label.c
index 6c3be05..c11a040 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -631,7 +631,7 @@ int label_scan(struct cmd_context *cmd)
 	 * on it.  This info will be used by the vg_read() phase of the
 	 * command.
 	 */
-	dev_cache_full_scan(cmd->full_filter);
+	dev_cache_scan();
 
 	if (!(iter = dev_iter_create(cmd->full_filter, 0))) {
 		log_error("Scanning failed to get devices.");
diff --git a/lib/misc/lvm-globals.c b/lib/misc/lvm-globals.c
index 0f384bb..9941489 100644
--- a/lib/misc/lvm-globals.c
+++ b/lib/misc/lvm-globals.c
@@ -28,7 +28,6 @@ static int _md_filtering = 0;
 static int _internal_filtering = 0;
 static int _fwraid_filtering = 0;
 static int _pvmove = 0;
-static int _full_scan_done = 0;	/* Restrict to one full scan during each cmd */
 static int _obtain_device_list_from_udev = DEFAULT_OBTAIN_DEVICE_LIST_FROM_UDEV;
 static enum dev_ext_e _external_device_info_source = DEV_EXT_NONE;
 static int _trust_cache = 0; /* Don't scan when incomplete VGs encountered */
@@ -92,11 +91,6 @@ void init_pvmove(int level)
 	_pvmove = level;
 }
 
-void init_full_scan_done(int level)
-{
-	_full_scan_done = level;
-}
-
 void init_obtain_device_list_from_udev(int device_list_from_udev)
 {
 	_obtain_device_list_from_udev = device_list_from_udev;
@@ -253,11 +247,6 @@ int pvmove_mode(void)
 	return _pvmove;
 }
 
-int full_scan_done(void)
-{
-	return _full_scan_done;
-}
-
 int obtain_device_list_from_udev(void)
 {
 	return _obtain_device_list_from_udev;
diff --git a/lib/misc/lvm-globals.h b/lib/misc/lvm-globals.h
index e23d598..b383891 100644
--- a/lib/misc/lvm-globals.h
+++ b/lib/misc/lvm-globals.h
@@ -29,7 +29,6 @@ void init_md_filtering(int level);
 void init_internal_filtering(int level);
 void init_fwraid_filtering(int level);
 void init_pvmove(int level);
-void init_full_scan_done(int level);
 void init_external_device_info_source(enum dev_ext_e src);
 void init_obtain_device_list_from_udev(int device_list_from_udev);
 void init_trust_cache(int trustcache);
@@ -63,7 +62,6 @@ int md_filtering(void);
 int internal_filtering(void);
 int fwraid_filtering(void);
 int pvmove_mode(void);
-int full_scan_done(void);
 int obtain_device_list_from_udev(void);
 enum dev_ext_e external_device_info_source(void);
 int trust_cache(void);
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index bcb2c53..c7ac4b6 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -2446,7 +2446,6 @@ static void _apply_current_settings(struct cmd_context *cmd)
 	_apply_current_output_settings(cmd);
 
 	init_test(cmd->current_settings.test);
-	init_full_scan_done(0);
 	init_mirror_in_sync(0);
 	init_dmeventd_monitor(DEFAULT_DMEVENTD_MONITOR);
 
diff --git a/tools/polldaemon.c b/tools/polldaemon.c
index d69284d..cf7a947 100644
--- a/tools/polldaemon.c
+++ b/tools/polldaemon.c
@@ -123,13 +123,12 @@ static void _nanosleep(unsigned secs, unsigned allow_zero_time)
 	while (!nanosleep(&wtime, &wtime) && errno == EINTR) {}
 }
 
-static void _sleep_and_rescan_devices(struct daemon_parms *parms)
+static void _sleep_and_rescan_devices(struct cmd_context *cmd, struct daemon_parms *parms)
 {
 	if (parms->interval && !parms->aborting) {
 		dev_close_all();
 		_nanosleep(parms->interval, 1);
-		/* Devices might have changed while we slept */
-		init_full_scan_done(0);
+		lvmcache_label_scan(cmd);
 	}
 }
 
@@ -145,7 +144,7 @@ int wait_for_single_lv(struct cmd_context *cmd, struct poll_operation_id *id,
 	/* Poll for completion */
 	while (!finished) {
 		if (parms->wait_before_testing)
-			_sleep_and_rescan_devices(parms);
+			_sleep_and_rescan_devices(cmd, parms);
 
 		/*
 		 * An ex VG lock is needed because the check can call finish_copy
@@ -218,7 +217,7 @@ int wait_for_single_lv(struct cmd_context *cmd, struct poll_operation_id *id,
 		 * continue polling an LV that doesn't have a "status".
 		 */
 		if (!parms->wait_before_testing && !finished)
-			_sleep_and_rescan_devices(parms);
+			_sleep_and_rescan_devices(cmd, parms);
 	}
 
 	return 1;
diff --git a/tools/pvscan.c b/tools/pvscan.c
index ab6ea0b..1fcf606 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -288,8 +288,6 @@ static int _pvscan_autoactivate(struct cmd_context *cmd, struct pvscan_aa_params
 		pp->refresh_all = 1;
 	}
 
-	dev_cache_full_scan(cmd->full_filter);
-
 	ret = process_each_vg(cmd, 0, NULL, NULL, vgnames, 0, 0, handle, _pvscan_autoactivate_single);
 
 	destroy_processing_handle(cmd, handle);
@@ -495,6 +493,7 @@ static int _pvscan_cache(struct cmd_context *cmd, int argc, char **argv)
 	}
 
 	if (!dm_list_empty(&single_devs)) {
+		dev_cache_scan();
 		label_scan_devs(cmd, &single_devs);
 
 		dm_list_iterate_items(devl, &single_devs) {
@@ -540,6 +539,7 @@ static int _pvscan_cache(struct cmd_context *cmd, int argc, char **argv)
 	}
 
 	if (!dm_list_empty(&single_devs)) {
+		dev_cache_scan();
 		label_scan_devs(cmd, &single_devs);
 
 		dm_list_iterate_items(devl, &single_devs) {
diff --git a/tools/toollib.c b/tools/toollib.c
index 7e3b021..fabf2dc 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -5503,8 +5503,6 @@ int pvcreate_each_device(struct cmd_context *cmd,
 		return 0;
 	}
 
-	dev_cache_full_scan(cmd->full_filter);
-
 	lvmcache_label_scan(cmd);
 
 	/*
diff --git a/tools/vgimportclone.c b/tools/vgimportclone.c
index 146d3b4..224d0b5 100644
--- a/tools/vgimportclone.c
+++ b/tools/vgimportclone.c
@@ -332,7 +332,6 @@ retry_name:
 	dm_list_iterate_items(vd, &vp.arg_import)
 		internal_filter_allow(cmd->mem, vd->dev);
 	lvmcache_destroy(cmd, 1, 0);
-	dev_cache_full_scan(cmd->full_filter);
 
 	log_debug("Changing VG %s to %s.", vp.old_vgname, vp.new_vgname);
 


