From: David Teigland <teigland@sourceware.org>
Date: Wed, 30 May 2018 10:05:54 -0400
Subject: master - scan: removed failed paths for devices
Message-ID: <201805301405.w4UE5sPk009358@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6d14d5d16b92c520b5f4ee464f171684cac40735
Commit:        6d14d5d16b92c520b5f4ee464f171684cac40735
Parent:        06c789eda19445d5e59a9c8044d91300fa1d2000
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue May 29 17:02:27 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed May 30 09:05:18 2018 -0500

scan: removed failed paths for devices

Drop a device path when the scan fails to open it.
---
 lib/device/dev-cache.c          |  187 +++++++++++++++++++++++++++++++++------
 lib/device/dev-cache.h          |    2 +
 lib/filters/filter-persistent.c |   10 ++-
 lib/label/label.c               |   65 +++++++++++---
 4 files changed, 219 insertions(+), 45 deletions(-)

diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index dd01558..c866ff9 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -333,10 +333,8 @@ static int _add_alias(struct device *dev, const char *path)
 
 	/* Is name already there? */
 	dm_list_iterate_items(strl, &dev->aliases) {
-		if (!strcmp(strl->str, path)) {
-			log_debug_devs("%s: Already in device cache", path);
+		if (!strcmp(strl->str, path))
 			return 1;
-		}
 	}
 
 	sl->str = path;
@@ -344,13 +342,7 @@ static int _add_alias(struct device *dev, const char *path)
 	if (!dm_list_empty(&dev->aliases)) {
 		oldpath = dm_list_item(dev->aliases.n, struct dm_str_list)->str;
 		prefer_old = _compare_paths(path, oldpath);
-		log_debug_devs("%s: Aliased to %s in device cache%s (%d:%d)",
-			       path, oldpath, prefer_old ? "" : " (preferred name)",
-			       (int) MAJOR(dev->dev), (int) MINOR(dev->dev));
-
-	} else
-		log_debug_devs("%s: Added to device cache (%d:%d)", path,
-			       (int) MAJOR(dev->dev), (int) MINOR(dev->dev));
+	}
 
 	if (prefer_old)
 		dm_list_add(&dev->aliases, &sl->list);
@@ -667,12 +659,37 @@ struct dm_list *dev_cache_get_dev_list_for_lvid(const char *lvid)
 }
 
 /*
+ * Scanning code calls this when it fails to open a device using
+ * this path.  The path is dropped from dev-cache.  In the next
+ * dev_cache_scan it may be added again, but it could be for a
+ * different device.
+ */
+
+void dev_cache_failed_path(struct device *dev, const char *path)
+{
+	struct device *dev_by_path;
+	struct dm_str_list *strl;
+
+	if ((dev_by_path = (struct device *) dm_hash_lookup(_cache.names, path)))
+		dm_hash_remove(_cache.names, path);
+
+	dm_list_iterate_items(strl, &dev->aliases) {
+		if (!strcmp(strl->str, path)) {
+			dm_list_del(&strl->list);
+			break;
+		}
+	}
+}
+
+/*
  * Either creates a new dev, or adds an alias to
  * an existing dev.
  */
 static int _insert_dev(const char *path, dev_t d)
 {
 	struct device *dev;
+	struct device *dev_by_devt;
+	struct device *dev_by_path;
 	static dev_t loopfile_count = 0;
 	int loopfile = 0;
 	char *path_copy;
@@ -685,8 +702,26 @@ static int _insert_dev(const char *path, dev_t d)
 		loopfile = 1;
 	}
 
-	/* is this device already registered ? */
-	if (!(dev = (struct device *) btree_lookup(_cache.devices, (uint32_t) d))) {
+	dev_by_devt = (struct device *) btree_lookup(_cache.devices, (uint32_t) d);
+	dev_by_path = (struct device *) dm_hash_lookup(_cache.names, path);
+	dev = dev_by_devt;
+
+	/*
+	 * Existing device, existing path points to the same device.
+	 */
+	if (dev_by_devt && dev_by_path && (dev_by_devt == dev_by_path)) {
+		log_debug_devs("Found dev %d:%d %s - exists. %.8s",
+			       (int)MAJOR(d), (int)MINOR(d), path, dev->pvid);
+		return 1;
+	}
+
+	/*
+	 * No device or path found, add devt to cache.devices, add name to cache.names.
+	 */
+	if (!dev_by_devt && !dev_by_path) {
+		log_debug_devs("Found dev %d:%d %s - new.",
+			       (int)MAJOR(d), (int)MINOR(d), path);
+
 		if (!(dev = (struct device *) btree_lookup(_cache.sysfs_only_devices, (uint32_t) d))) {
 			/* create new device */
 			if (loopfile) {
@@ -701,30 +736,126 @@ static int _insert_dev(const char *path, dev_t d)
 			_free(dev);
 			return 0;
 		}
-	}
 
-	if (dm_hash_lookup(_cache.names, path) == dev) {
-		/* Hash already has matching entry present */
-		log_debug("%s: Path already cached.", path);
+		if (!(path_copy = dm_pool_strdup(_cache.mem, path))) {
+			log_error("Failed to duplicate path string.");
+			return 0;
+		}
+
+		if (!loopfile && !_add_alias(dev, path_copy)) {
+			log_error("Couldn't add alias to dev cache.");
+			return 0;
+		}
+
+		if (!dm_hash_insert(_cache.names, path_copy, dev)) {
+			log_error("Couldn't add name to hash in dev cache.");
+			return 0;
+		}
+
 		return 1;
 	}
 
-	if (!(path_copy = dm_pool_strdup(_cache.mem, path))) {
-		log_error("Failed to duplicate path string.");
-		return 0;
+	/*
+	 * Existing device, path is new, add path as a new alias for the device.
+	 */
+	if (dev_by_devt && !dev_by_path) {
+		log_debug_devs("Found dev %d:%d %s - new alias.",
+			       (int)MAJOR(d), (int)MINOR(d), path);
+
+		if (!(path_copy = dm_pool_strdup(_cache.mem, path))) {
+			log_error("Failed to duplicate path string.");
+			return 0;
+		}
+
+		if (!loopfile && !_add_alias(dev, path_copy)) {
+			log_error("Couldn't add alias to dev cache.");
+			return 0;
+		}
+
+		if (!dm_hash_insert(_cache.names, path_copy, dev)) {
+			log_error("Couldn't add name to hash in dev cache.");
+			return 0;
+		}
+
+		return 1;
 	}
 
-	if (!loopfile && !_add_alias(dev, path_copy)) {
-		log_error("Couldn't add alias to dev cache.");
-		return 0;
+	/*
+	 * No existing device, but path exists and previously pointed
+	 * to a different device.
+	 */
+	if (!dev_by_devt && dev_by_path) {
+		log_debug_devs("Found dev %d:%d %s - new device, path was previously %d:%d.",
+			       (int)MAJOR(d), (int)MINOR(d), path,
+			       (int)MAJOR(dev_by_path->dev), (int)MINOR(dev_by_path->dev));
+
+		if (!(dev = (struct device *) btree_lookup(_cache.sysfs_only_devices, (uint32_t) d))) {
+			/* create new device */
+			if (loopfile) {
+				if (!(dev = dev_create_file(path, NULL, NULL, 0)))
+					return_0;
+			} else if (!(dev = _dev_create(d)))
+				return_0;
+		}
+
+		if (!(btree_insert(_cache.devices, (uint32_t) d, dev))) {
+			log_error("Couldn't insert device into binary tree.");
+			_free(dev);
+			return 0;
+		}
+
+		if (!(path_copy = dm_pool_strdup(_cache.mem, path))) {
+			log_error("Failed to duplicate path string.");
+			return 0;
+		}
+
+		if (!loopfile && !_add_alias(dev, path_copy)) {
+			log_error("Couldn't add alias to dev cache.");
+			return 0;
+		}
+
+		dm_hash_remove(_cache.names, path);
+
+		if (!dm_hash_insert(_cache.names, path_copy, dev)) {
+			log_error("Couldn't add name to hash in dev cache.");
+			return 0;
+		}
+
+		return 1;
+
 	}
 
-	if (!dm_hash_insert(_cache.names, path_copy, dev)) {
-		log_error("Couldn't add name to hash in dev cache.");
-		return 0;
+	/*
+	 * Existing device, and path exists and previously pointed to
+	 * a different device.
+	 */
+	if (dev_by_devt && dev_by_path) {
+		log_debug_devs("Found dev %d:%d %s - existing device, path was previously %d:%d.",
+			       (int)MAJOR(d), (int)MINOR(d), path,
+			       (int)MAJOR(dev_by_path->dev), (int)MINOR(dev_by_path->dev));
+
+		if (!(path_copy = dm_pool_strdup(_cache.mem, path))) {
+			log_error("Failed to duplicate path string.");
+			return 0;
+		}
+
+		if (!loopfile && !_add_alias(dev, path_copy)) {
+			log_error("Couldn't add alias to dev cache.");
+			return 0;
+		}
+
+		dm_hash_remove(_cache.names, path);
+
+		if (!dm_hash_insert(_cache.names, path_copy, dev)) {
+			log_error("Couldn't add name to hash in dev cache.");
+			return 0;
+		}
+
+		return 1;
 	}
 
-	return 1;
+	log_error("Found dev %d:%d %s - failed to use.", (int)MAJOR(d), (int)MINOR(d), path);
+	return 0;
 }
 
 static char *_join(const char *dir, const char *name)
@@ -1064,10 +1195,8 @@ static int _insert(const char *path, const struct stat *info,
 		if (rec && !_insert_dir(path))
 			return_0;
 	} else {		/* add a device */
-		if (!S_ISBLK(info->st_mode)) {
-			log_debug_devs("%s: Not a block device", path);
+		if (!S_ISBLK(info->st_mode))
 			return 1;
-		}
 
 		if (!_insert_dev(path, info->st_rdev))
 			return_0;
diff --git a/lib/device/dev-cache.h b/lib/device/dev-cache.h
index 4797274..df6ba0e 100644
--- a/lib/device/dev-cache.h
+++ b/lib/device/dev-cache.h
@@ -70,4 +70,6 @@ struct device *dev_iter_get(struct dev_iter *iter);
 
 void dev_reset_error_count(struct cmd_context *cmd);
 
+void dev_cache_failed_path(struct device *dev, const char *path);
+
 #endif
diff --git a/lib/filters/filter-persistent.c b/lib/filters/filter-persistent.c
index 3fa57f1..e4659aa 100644
--- a/lib/filters/filter-persistent.c
+++ b/lib/filters/filter-persistent.c
@@ -286,10 +286,18 @@ out:
 static int _lookup_p(struct dev_filter *f, struct device *dev)
 {
 	struct pfilter *pf = (struct pfilter *) f->private;
-	void *l = dm_hash_lookup(pf->devices, dev_name(dev));
+	void *l;
 	struct dm_str_list *sl;
 	int pass = 1;
 
+	if (dm_list_empty(&dev->aliases)) {
+		log_debug_devs("%d:%d: filter cache skipping (no name)",
+				(int)MAJOR(dev->dev), (int)MINOR(dev->dev));
+		return 0;
+	}
+
+	l = dm_hash_lookup(pf->devices, dev_name(dev));
+
 	/* Cached bad, skip dev */
 	if (l == PF_BAD_DEVICE) {
 		log_debug_devs("%s: filter cache skipping (cached bad)", dev_name(dev));
diff --git a/lib/label/label.c b/lib/label/label.c
index 8ecaa61..97a4359 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -501,15 +501,6 @@ retry_open:
 					       (int)MAJOR(sbuf.st_rdev), (int)MINOR(sbuf.st_rdev));
 			}
 
-			/*
-			 * FIXME: do we want to try opening this device using
-			 * one of the other path aliases for the same
-			 * major:minor from dev->aliases?  We could iterate
-			 * through those aliases to try opening each of them to
-			 * find one that works.  What are the consequences of
-			 * using a different, non-preferred alias to a device?
-			 */
-
 			if (!retried) {
 				/*
 				 * FIXME: remove this, the theory for this retry is that
@@ -550,6 +541,37 @@ static int _scan_dev_close(struct device *dev)
 	return 1;
 }
 
+static void _drop_bad_aliases(struct device *dev)
+{
+	struct dm_str_list *strl, *strl2;
+	const char *name;
+	struct stat sbuf;
+	int major = (int)MAJOR(dev->dev);
+	int minor = (int)MINOR(dev->dev);
+	int bad;
+
+	dm_list_iterate_items_safe(strl, strl2, &dev->aliases) {
+		name = strl->str;
+		bad = 0;
+
+		if (stat(name, &sbuf)) {
+			bad = 1;
+			log_debug_devs("Device path check %d:%d %s stat failed errno %d",
+					major, minor, name, errno);
+		} else if (sbuf.st_rdev != dev->dev) {
+			bad = 1;
+			log_debug_devs("Device path check %d:%d %s stat %d:%d does not match.",
+				       major, minor, name,
+				       (int)MAJOR(sbuf.st_rdev), (int)MINOR(sbuf.st_rdev));
+		}
+
+		if (bad) {
+			log_debug_devs("Device path check %d:%d dropping path %s.", major, minor, name);
+			dev_cache_failed_path(dev, name);
+		}
+	}
+}
+
 /*
  * Read or reread label/metadata from selected devs.
  *
@@ -635,7 +657,11 @@ static int _scan_list(struct cmd_context *cmd, struct dev_filter *f,
 			scan_failed_count++;
 			lvmcache_del_dev(devl->dev);
 		} else {
-			log_debug_devs("Processing data from device %s fd %d block %p", dev_name(devl->dev), devl->dev->bcache_fd, bb);
+			log_debug_devs("Processing data from device %s %d:%d fd %d block %p",
+				       dev_name(devl->dev),
+				       (int)MAJOR(devl->dev->dev),
+				       (int)MINOR(devl->dev->dev),
+				       devl->dev->bcache_fd, bb);
 
 			ret = _process_block(cmd, f, devl->dev, bb, 0, 0, &is_lvm_device);
 
@@ -675,11 +701,6 @@ static int _scan_list(struct cmd_context *cmd, struct dev_filter *f,
 	 * to open the devs on the reopen_devs list.
 	 *
 	 * FIXME: it's not clear if or why this helps.
-	 *
-	 * FIXME: should we delete the first path name from dev->aliases that
-	 * we failed to open the first time before retrying?  If that path
-	 * still exists on the system, dev_cache_scan should put it back, but
-	 * if it doesn't exist we don't want to try using it again.
 	 */
 	if (!dm_list_empty(&reopen_devs)) {
 		if (retried_open) {
@@ -690,6 +711,20 @@ static int _scan_list(struct cmd_context *cmd, struct dev_filter *f,
 		}
 		retried_open = 1;
 
+		dm_list_iterate_items_safe(devl, devl2, &reopen_devs) {
+			_drop_bad_aliases(devl->dev);
+
+			if (dm_list_empty(&devl->dev->aliases)) {
+				log_warn("WARNING: Scan ignoring device %d:%d with no paths.",
+					 (int)MAJOR(devl->dev->dev),
+					 (int)MINOR(devl->dev->dev));
+					 
+				dm_list_del(&devl->list);
+				lvmcache_del_dev(devl->dev);
+				scan_failed_count++;
+			}
+		}
+
 		/*
 		 * This will search the system's /dev for new path names and
 		 * could help us reopen the device if it finds a new preferred


