From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 25 Nov 2011 10:59:09 +0100
Subject: [PATCH 7/7] Skip double stat() call with each _insert
In-Reply-To: <cover.1322213495.git.zkabelac@redhat.com>
References: <cover.1322213495.git.zkabelac@redhat.com>
Message-ID: <d27b93e6d408b9d7f024f90c4d5b2e89b19f16d9.1322213495.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

When the device is inserted in dev_name_confirmed() stat() is
called twice as _insert() has it's own stat() call.

Extend _insert() parameter with struct stat* - which could be reused
if it has been just obtained.  Udev path passes NULL and code is
doing then its own stat() as before.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/device/dev-cache.c |   48 ++++++++++++++++++++++++++++++------------------
 1 files changed, 30 insertions(+), 18 deletions(-)

diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 161bff7..9abaf1c 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -52,7 +52,8 @@ static struct {
 #define _free(x) dm_pool_free(_cache.mem, (x))
 #define _strdup(x) dm_pool_strdup(_cache.mem, (x))
 
-static int _insert(const char *path, int rec, int check_with_udev_db);
+static int _insert(const char *path, const struct stat *info,
+		   int rec, int check_with_udev_db);
 
 static void _dev_init(struct device *dev)
 {
@@ -443,7 +444,7 @@ static int _insert_dir(const char *dir)
 				return_0;
 
 			_collapse_slashes(path);
-			r &= _insert(path, 1, 0);
+			r &= _insert(path, NULL, 1, 0);
 			dm_free(path);
 
 			free(dirent[n]);
@@ -511,11 +512,11 @@ static int _insert_udev_dir(struct udev *udev, const char *dir)
 		device = udev_device_new_from_syspath(udev, udev_list_entry_get_name(device_entry));
 
 		node_name = udev_device_get_devnode(device);
-		r &= _insert(node_name, 0, 0);
+		r &= _insert(node_name, NULL, 0, 0);
 
 		udev_list_entry_foreach(symlink_entry, udev_device_get_devlinks_list_entry(device)) {
 			symlink_name = udev_list_entry_get_name(symlink_entry);
-			r &= _insert(symlink_name, 0, 0);
+			r &= _insert(symlink_name, NULL, 0, 0);
 		}
 
 		udev_device_unref(device);
@@ -569,29 +570,33 @@ static void _insert_dirs(struct dm_list *dirs)
 
 #endif	/* UDEV_SYNC_SUPPORT */
 
-static int _insert(const char *path, int rec, int check_with_udev_db)
+static int _insert(const char *path, const struct stat *info,
+		   int rec, int check_with_udev_db)
 {
-	struct stat info;
+	struct stat tinfo;
 	int r = 0;
 
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
 			log_debug("%s: Symbolic link to directory", path);
 			return 0;
 		}
@@ -600,12 +605,12 @@ static int _insert(const char *path, int rec, int check_with_udev_db)
 			r = _insert_dir(path);
 
 	} else {		/* add a device */
-		if (!S_ISBLK(info.st_mode)) {
+		if (!S_ISBLK(info->st_mode)) {
 			log_debug("%s: Not a block device", path);
 			return 0;
 		}
 
-		if (!_insert_dev(path, info.st_rdev))
+		if (!_insert_dev(path, info->st_rdev))
 			return_0;
 
 		r = 1;
@@ -865,7 +870,7 @@ const char *dev_name_confirmed(struct device *dev, int quiet)
 		if (dm_list_size(&dev->aliases) > 1) {
 			dm_list_del(dev->aliases.n);
 			if (!r)
-				_insert(name, 0, obtain_device_list_from_udev());
+				_insert(name, &buf, 0, obtain_device_list_from_udev());
 			continue;
 		}
 
@@ -887,13 +892,20 @@ struct device *dev_cache_get(const char *name, struct dev_filter *f)
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
-- 
1.7.7.3


