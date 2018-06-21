From: David Teigland <teigland@sourceware.org>
Date: Thu, 21 Jun 2018 10:35:32 -0400
Subject: master - Remove code for using files as devices
Message-ID: <201806211435.w5LEZWPu014333@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=15826214f94da5a447f34ae9d237f1f018d3bac3
Commit:        15826214f94da5a447f34ae9d237f1f018d3bac3
Parent:        e166d2b14ca22ead559a5898cc229ecbcc261007
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Jun 21 09:33:21 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Jun 21 09:33:21 2018 -0500

Remove code for using files as devices

It appears this has not been used in a long time,
and it seems to have no point since loop devices exist.
---
 lib/commands/toolcontext.c   |   18 ---------
 lib/config/config_settings.h |    2 +-
 lib/device/dev-cache.c       |   80 +++--------------------------------------
 lib/device/dev-cache.h       |    2 -
 4 files changed, 7 insertions(+), 95 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 50474c1..eb15581 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1030,24 +1030,6 @@ static int _init_dev_cache(struct cmd_context *cmd)
 		}
 	}
 
-	if (!(cn = find_config_tree_array(cmd, devices_loopfiles_CFG, NULL)))
-		return 1;
-
-	for (cv = cn->v; cv; cv = cv->next) {
-		if (cv->type != DM_CFG_STRING) {
-			log_error("Invalid string in config file: "
-				  "devices/loopfiles");
-			return 0;
-		}
-
-		if (!dev_cache_add_loopfile(cv->v.str)) {
-			log_error("Failed to add loopfile %s to internal "
-				  "device cache", cv->v.str);
-			return 0;
-		}
-	}
-
-
 	return 1;
 }
 
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index ac0f0ff..7cb266c 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -226,7 +226,7 @@ cfg(devices_dir_CFG, "dir", devices_CFG_SECTION, CFG_ADVANCED, CFG_TYPE_STRING,
 cfg_array(devices_scan_CFG, "scan", devices_CFG_SECTION, CFG_ADVANCED, CFG_TYPE_STRING, "#S/dev", vsn(1, 0, 0), NULL, 0, NULL,
 	"Directories containing device nodes to use with LVM.\n")
 
-cfg_array(devices_loopfiles_CFG, "loopfiles", devices_CFG_SECTION, CFG_DEFAULT_UNDEFINED | CFG_UNSUPPORTED, CFG_TYPE_STRING, NULL, vsn(1, 2, 0), NULL, 0, NULL, NULL)
+cfg_array(devices_loopfiles_CFG, "loopfiles", devices_CFG_SECTION, CFG_DEFAULT_UNDEFINED | CFG_UNSUPPORTED, CFG_TYPE_STRING, NULL, vsn(1, 2, 0), NULL, vsn(3, 0, 0), NULL, NULL)
 
 cfg(devices_obtain_device_list_from_udev_CFG, "obtain_device_list_from_udev", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_OBTAIN_DEVICE_LIST_FROM_UDEV, vsn(2, 2, 85), NULL, 0, NULL,
 	"Obtain the list of available devices from udev.\n"
diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index a0d98a3..59e00ae 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -690,18 +690,8 @@ static int _insert_dev(const char *path, dev_t d)
 	struct device *dev;
 	struct device *dev_by_devt;
 	struct device *dev_by_path;
-	static dev_t loopfile_count = 0;
-	int loopfile = 0;
 	char *path_copy;
 
-	/* Generate pretend device numbers for loopfiles */
-	if (!d) {
-		if (dm_hash_lookup(_cache.names, path))
-			return 1;
-		d = ++loopfile_count;
-		loopfile = 1;
-	}
-
 	dev_by_devt = (struct device *) btree_lookup(_cache.devices, (uint32_t) d);
 	dev_by_path = (struct device *) dm_hash_lookup(_cache.names, path);
 	dev = dev_by_devt;
@@ -724,10 +714,7 @@ static int _insert_dev(const char *path, dev_t d)
 
 		if (!(dev = (struct device *) btree_lookup(_cache.sysfs_only_devices, (uint32_t) d))) {
 			/* create new device */
-			if (loopfile) {
-				if (!(dev = dev_create_file(path, NULL, NULL, 0)))
-					return_0;
-			} else if (!(dev = _dev_create(d)))
+			if (!(dev = _dev_create(d)))
 				return_0;
 		}
 
@@ -742,7 +729,7 @@ static int _insert_dev(const char *path, dev_t d)
 			return 0;
 		}
 
-		if (!loopfile && !_add_alias(dev, path_copy)) {
+		if (!_add_alias(dev, path_copy)) {
 			log_error("Couldn't add alias to dev cache.");
 			return 0;
 		}
@@ -767,7 +754,7 @@ static int _insert_dev(const char *path, dev_t d)
 			return 0;
 		}
 
-		if (!loopfile && !_add_alias(dev, path_copy)) {
+		if (!_add_alias(dev, path_copy)) {
 			log_error("Couldn't add alias to dev cache.");
 			return 0;
 		}
@@ -791,10 +778,7 @@ static int _insert_dev(const char *path, dev_t d)
 
 		if (!(dev = (struct device *) btree_lookup(_cache.sysfs_only_devices, (uint32_t) d))) {
 			/* create new device */
-			if (loopfile) {
-				if (!(dev = dev_create_file(path, NULL, NULL, 0)))
-					return_0;
-			} else if (!(dev = _dev_create(d)))
+			if (!(dev = _dev_create(d)))
 				return_0;
 		}
 
@@ -809,7 +793,7 @@ static int _insert_dev(const char *path, dev_t d)
 			return 0;
 		}
 
-		if (!loopfile && !_add_alias(dev, path_copy)) {
+		if (!_add_alias(dev, path_copy)) {
 			log_error("Couldn't add alias to dev cache.");
 			return 0;
 		}
@@ -839,7 +823,7 @@ static int _insert_dev(const char *path, dev_t d)
 			return 0;
 		}
 
-		if (!loopfile && !_add_alias(dev, path_copy)) {
+		if (!_add_alias(dev, path_copy)) {
 			log_error("Couldn't add alias to dev cache.");
 			return 0;
 		}
@@ -919,26 +903,6 @@ static int _insert_dir(const char *dir)
 	return r;
 }
 
-static int _insert_file(const char *path)
-{
-	struct stat info;
-
-	if (stat(path, &info) < 0) {
-		log_sys_very_verbose("stat", path);
-		return 0;
-	}
-
-	if (!S_ISREG(info.st_mode)) {
-		log_debug_devs("%s: Not a regular file", path);
-		return 0;
-	}
-
-	if (!_insert_dev(path, 0))
-		return_0;
-
-	return 1;
-}
-
 static int _dev_cache_iterate_devs_for_index(void)
 {
 	struct btree_iter *iter = btree_first(_cache.devices);
@@ -1207,8 +1171,6 @@ static int _insert(const char *path, const struct stat *info,
 
 void dev_cache_scan(void)
 {
-	struct dir_list *dl;
-	
 	log_debug_devs("Creating list of system devices.");
 
 	_cache.has_scanned = 1;
@@ -1216,9 +1178,6 @@ void dev_cache_scan(void)
 	_insert_dirs(&_cache.dirs);
 
 	(void) dev_cache_index_devs();
-
-	dm_list_iterate_items(dl, &_cache.files)
-		_insert_file(dl->dir);
 }
 
 int dev_cache_has_scanned(void)
@@ -1317,7 +1276,6 @@ int dev_cache_init(struct cmd_context *cmd)
 	}
 
 	dm_list_init(&_cache.dirs);
-	dm_list_init(&_cache.files);
 
 	if (!_init_preferred_names(cmd))
 		goto_bad;
@@ -1411,32 +1369,6 @@ int dev_cache_add_dir(const char *path)
 	return 1;
 }
 
-int dev_cache_add_loopfile(const char *path)
-{
-	struct dir_list *dl;
-	struct stat st;
-
-	if (stat(path, &st)) {
-		log_warn("Ignoring %s: %s.", path, strerror(errno));
-		/* But don't fail */
-		return 1;
-	}
-
-	if (!S_ISREG(st.st_mode)) {
-		log_warn("Ignoring %s: Not a regular file.", path);
-		return 1;
-	}
-
-	if (!(dl = _zalloc(sizeof(*dl) + strlen(path) + 1))) {
-		log_error("dir_list allocation failed for file");
-		return 0;
-	}
-
-	strcpy(dl->dir, path);
-	dm_list_add(&_cache.files, &dl->list);
-	return 1;
-}
-
 /* Check cached device name is still valid before returning it */
 /* This should be a rare occurrence */
 /* set quiet if the cache is expected to be out-of-date */
diff --git a/lib/device/dev-cache.h b/lib/device/dev-cache.h
index 6386ba9..41c4a9c 100644
--- a/lib/device/dev-cache.h
+++ b/lib/device/dev-cache.h
@@ -51,8 +51,6 @@ void dev_cache_scan(void);
 int dev_cache_has_scanned(void);
 
 int dev_cache_add_dir(const char *path);
-int dev_cache_add_loopfile(const char *path);
-__attribute__((nonnull(1)))
 struct device *dev_cache_get(struct cmd_context *cmd, const char *name, struct dev_filter *f);
 const char *dev_cache_filtered_reason(const char *name);
 


