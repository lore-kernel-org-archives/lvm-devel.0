From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 12 Dec 2013 12:43:45 +0000 (UTC)
Subject: master - dev-cache: skip double stat() call on each _insert
Message-ID: <20131212124345.3B7506024C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6c0e44d5a2e82aa160d48e83992e7ca342bc4bdf
Commit:        6c0e44d5a2e82aa160d48e83992e7ca342bc4bdf
Parent:        7c5feaed3be5c26f5782e4e891ba99862f1e968f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 25 10:01:37 2011 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Dec 12 13:42:28 2013 +0100

dev-cache: skip double stat() call on each _insert

When the device is inserted in dev_name_confirmed() stat() is
called twice as _insert() has it's own stat() call.

Extend _insert() parameter with struct stat* - which could be used
if it has been just obtained.  When NULL is passed code is
doing its own stat() call as before.
---
 WHATS_NEW              |    1 +
 lib/device/dev-cache.c |   49 ++++++++++++++++++++++++++++++-----------------
 2 files changed, 32 insertions(+), 18 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 704d0be..78657dd 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.105 -
 =====================================
+  Optimize double call of stat() for cached devices.
   Enable support for thin provisioning for default configuration.
   Improve process_each_lv_in_vg() tag processing.
   Reodered and simplified logging code.
diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index bbdde92..fabdcbb 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -50,7 +50,8 @@ static struct {
 #define _free(x) dm_pool_free(_cache.mem, (x))
 #define _strdup(x) dm_pool_strdup(_cache.mem, (x))
 
-static int _insert(const char *path, int rec, int check_with_udev_db);
+static int _insert(const char *path, const struct stat *info,
+		   int rec, int check_with_udev_db);
 
 /* Setup non-zero members of passed zeroed 'struct device' */
 static void _dev_init(struct device *dev, int max_error_count)
@@ -442,7 +443,7 @@ static int _insert_dir(const char *dir)
 				return_0;
 
 			_collapse_slashes(path);
-			r &= _insert(path, 1, 0);
+			r &= _insert(path, NULL, 1, 0);
 			dm_free(path);
 
 			free(dirent[n]);
@@ -528,14 +529,14 @@ static int _insert_udev_dir(struct udev *udev, const char *dir)
 			log_very_verbose("udev failed to return a device node for entry %s.",
 					 entry_name);
 		else
-			r &= _insert(node_name, 0, 0);
+			r &= _insert(node_name, NULL, 0, 0);
 
 		udev_list_entry_foreach(symlink_entry, udev_device_get_devlinks_list_entry(device)) {
 			if (!(symlink_name = udev_list_entry_get_name(symlink_entry)))
 				log_very_verbose("udev failed to return a symlink name for entry %s.",
 						 entry_name);
 			else
-				r &= _insert(symlink_name, 0, 0);
+				r &= _insert(symlink_name, NULL, 0, 0);
 		}
 
 		udev_device_unref(device);
@@ -589,28 +590,33 @@ static void _insert_dirs(struct dm_list *dirs)
 
 #endif	/* UDEV_SYNC_SUPPORT */
 
-static int _insert(const char *path, int rec, int check_with_udev_db)
+static int _insert(const char *path, const struct stat *info,
+		   int rec, int check_with_udev_db)
 {
-	struct stat info;
+	struct stat tinfo;
+	int r = 0;
 
-	if (stat(path, &info) < 0) {
-		log_sys_very_verbose("stat", path);
-		return 0;
+	if (!info) {
+		if (stat(path, &tinfo) < 0) {
+			log_sys_very_verbose("stat", path);
+			return 0;
+		}
+		info = &tinfo;
 	}
 
-	if (check_with_udev_db && !_device_in_udev_db(info.st_rdev)) {
+	if (check_with_udev_db && !_device_in_udev_db(info->st_rdev)) {
 		log_very_verbose("%s: Not in udev db", path);
 		return 0;
 	}
 
-	if (S_ISDIR(info.st_mode)) {	/* add a directory */
+	if (S_ISDIR(info->st_mode)) {	/* add a directory */
 		/* check it's not a symbolic link */
-		if (lstat(path, &info) < 0) {
+		if (lstat(path, &tinfo) < 0) {
 			log_sys_very_verbose("lstat", path);
 			return 0;
 		}
 
-		if (S_ISLNK(info.st_mode)) {
+		if (S_ISLNK(tinfo.st_mode)) {
 			log_debug_devs("%s: Symbolic link to directory", path);
 			return 1;
 		}
@@ -618,12 +624,12 @@ static int _insert(const char *path, int rec, int check_with_udev_db)
 		if (rec && !_insert_dir(path))
 			return_0;
 	} else {		/* add a device */
-		if (!S_ISBLK(info.st_mode)) {
+		if (!S_ISBLK(info->st_mode)) {
 			log_debug_devs("%s: Not a block device", path);
 			return 1;
 		}
 
-		if (!_insert_dev(path, info.st_rdev))
+		if (!_insert_dev(path, info->st_rdev))
 			return_0;
 	}
 
@@ -881,7 +887,7 @@ const char *dev_name_confirmed(struct device *dev, int quiet)
 		if (dm_list_size(&dev->aliases) > 1) {
 			dm_list_del(dev->aliases.n);
 			if (!r)
-				_insert(name, 0, obtain_device_list_from_udev());
+				_insert(name, &buf, 0, obtain_device_list_from_udev());
 			continue;
 		}
 
@@ -903,13 +909,20 @@ struct device *dev_cache_get(const char *name, struct dev_filter *f)
 		return d;
 
 	/* If the entry's wrong, remove it */
-	if (d && (stat(name, &buf) || (buf.st_rdev != d->dev))) {
+	if (stat(name, &buf) < 0) {
+		if (d)
+			dm_hash_remove(_cache.names, name);
+		log_sys_very_verbose("stat", name);
+		return NULL;
+	}
+
+	if (d && (buf.st_rdev != d->dev)) {
 		dm_hash_remove(_cache.names, name);
 		d = NULL;
 	}
 
 	if (!d) {
-		_insert(name, 0, obtain_device_list_from_udev());
+		_insert(name, &buf, 0, obtain_device_list_from_udev());
 		d = (struct device *) dm_hash_lookup(_cache.names, name);
 		if (!d) {
 			_full_scan(0);


