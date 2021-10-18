From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 18 Oct 2021 19:18:40 +0000 (GMT)
Subject: main - dev-cache: better detection of filesystem
Message-ID: <20211018191840.B89363858C27@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=88e0d68909c007576272d65216b0e7a9011b9c9b
Commit:        88e0d68909c007576272d65216b0e7a9011b9c9b
Parent:        c60bac466175949b56b768b5e8d01ea5655a423e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 18 21:08:19 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 18 21:16:53 2021 +0200

dev-cache: better detection of filesystem

It appear on some systems the first found dev might not be actually for
the filesytem - so use a better way through _cache.st_dev.
---
 lib/device/dev-cache.c | 22 +++++++++++++---------
 1 file changed, 13 insertions(+), 9 deletions(-)

diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 6d706eb1e..57fa916a9 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -53,6 +53,7 @@ static struct {
 	const char *dev_dir;
 
 	int has_scanned;
+	long st_dev;
 	struct dm_list dirs;
 	struct dm_list files;
 
@@ -1064,11 +1065,18 @@ static void _insert_dirs(struct dm_list *dirs)
 	struct dir_list *dl;
 	struct udev *udev = NULL;
 	int with_udev;
+	struct stat tinfo;
 
 	with_udev = obtain_device_list_from_udev() &&
 		    (udev = udev_get_library_context());
 
 	dm_list_iterate_items(dl, &_cache.dirs) {
+		if (stat(dl->dir, &tinfo) < 0) {
+			log_warn("WARNING: Cannot use dir %s, %s.",
+				 dl->dir, strerror(errno));
+			continue;
+		}
+		_cache.st_dev = tinfo.st_dev;
 		if (with_udev) {
 			if (!_insert_udev_dir(udev, dl->dir))
 				log_debug_devs("%s: Failed to insert devices from "
@@ -1101,7 +1109,6 @@ static void _insert_dirs(struct dm_list *dirs)
 static int _insert(const char *path, const struct stat *info,
 		   int rec, int check_with_udev_db)
 {
-	static long _st_dev = -1;
 	struct stat tinfo;
 
 	if (!info) {
@@ -1112,20 +1119,12 @@ static int _insert(const char *path, const struct stat *info,
 		info = &tinfo;
 	}
 
-	if (_st_dev == -1)
-		_st_dev = info->st_dev; /* first dir device */
-
 	if (check_with_udev_db && !_device_in_udev_db(info->st_rdev)) {
 		log_very_verbose("%s: Not in udev db", path);
 		return 0;
 	}
 
 	if (S_ISDIR(info->st_mode)) {	/* add a directory */
-		if (info->st_dev != _st_dev) {
-			log_debug_devs("%s: Different filesystem in directory", path);
-			return 1;
-		}
-
 		/* check it's not a symbolic link */
 		if (lstat(path, &tinfo) < 0) {
 			log_sys_very_verbose("lstat", path);
@@ -1137,6 +1136,11 @@ static int _insert(const char *path, const struct stat *info,
 			return 1;
 		}
 
+		if (info->st_dev != _cache.st_dev) {
+			log_debug_devs("%s: Different filesystem in directory", path);
+			return 1;
+		}
+
 		if (rec && !_insert_dir(path))
 			return 0;
 	} else {		/* add a device */


