From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon,  8 Feb 2021 22:45:09 +0000 (GMT)
Subject: main - dev-cache: better code reuse for _add_alias
Message-ID: <20210208224509.9A47F3800C1A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2c597c73a837e9d259ee620f167b08ebf1b14a9e
Commit:        2c597c73a837e9d259ee620f167b08ebf1b14a9e
Parent:        be9b731f440243df8fb42f6f2a506bf27de5ac64
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Feb 7 19:30:26 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 8 23:43:38 2021 +0100

dev-cache: better code reuse for _add_alias

Move path copying into _add_alish together with hashing.
Remove duplicated code.
---
 lib/device/dev-cache.c | 112 ++++++++++++++++---------------------------------
 1 file changed, 35 insertions(+), 77 deletions(-)

diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index a93600965..517b9e6f8 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -321,20 +321,33 @@ static int _compare_paths(const char *path0, const char *path1)
 	return 1;
 }
 
-static int _add_alias(struct device *dev, const char *path)
+enum add_hash {
+	NO_HASH,
+	HASH,
+	REHASH
+};
+
+static int _add_alias(struct device *dev, const char *path, enum add_hash hash)
 {
 	struct dm_str_list *sl = _zalloc(sizeof(*sl));
 	struct dm_str_list *strl;
 	const char *oldpath;
 	int prefer_old = 1;
 
-	if (!sl)
-		return_0;
+	if (hash == REHASH)
+		dm_hash_remove(_cache.names, path);
 
 	/* Is name already there? */
-	dm_list_iterate_items(strl, &dev->aliases) {
-		if (!strcmp(strl->str, path))
-			return 1;
+	dm_list_iterate_items(strl, &dev->aliases)
+		if (!strcmp(strl->str, path)) {
+			path = strl->str;
+			goto out;
+		}
+
+	if (!(path = dm_pool_strdup(_cache.mem, path)) ||
+	    !(sl = _zalloc(sizeof(*sl)))) {
+		log_error("Failed to add allias to dev cache.");
+		return 0;
 	}
 
 	if (!strncmp(path, "/dev/nvme", 9)) {
@@ -353,6 +366,12 @@ static int _add_alias(struct device *dev, const char *path)
 		dm_list_add(&dev->aliases, &sl->list);
 	else
 		dm_list_add_h(&dev->aliases, &sl->list);
+out:
+	if ((hash != NO_HASH) &&
+	    !dm_hash_insert(_cache.names, path, dev)) {
+		log_error("Couldn't add name to hash in dev cache.");
+		return 0;
+	}
 
 	return 1;
 }
@@ -428,7 +447,6 @@ static struct device *_insert_sysfs_dev(dev_t devno, const char *devname)
 	static struct device _fake_dev = { .flags = DEV_USED_FOR_LV };
 	struct stat stat0;
 	char path[PATH_MAX];
-	char *path_copy;
 	struct device *dev;
 
 	if (dm_snprintf(path, sizeof(path), "%s%s", _cache.dev_dir, devname) < 0) {
@@ -446,15 +464,9 @@ static struct device *_insert_sysfs_dev(dev_t devno, const char *devname)
 	if (!(dev = _dev_create(devno)))
 		return_NULL;
 
-	if (!(path_copy = dm_pool_strdup(_cache.mem, path))) {
-		log_error("_insert_sysfs_dev: %s: dm_pool_strdup failed", devname);
-		return NULL;
-	}
-
-	if (!_add_alias(dev, path_copy)) {
-		log_error("Couldn't add alias to dev cache.");
+	if (!_add_alias(dev, path, NO_HASH)) {
 		_free(dev);
-		return NULL;
+		return_NULL;
 	}
 
 	if (!btree_insert(_cache.sysfs_only_devices, (uint32_t) devno, dev)) {
@@ -696,7 +708,6 @@ static int _insert_dev(const char *path, dev_t d)
 	struct device *dev;
 	struct device *dev_by_devt;
 	struct device *dev_by_path;
-	char *path_copy;
 
 	dev_by_devt = (struct device *) btree_lookup(_cache.devices, (uint32_t) d);
 	dev_by_path = (struct device *) dm_hash_lookup(_cache.names, path);
@@ -730,20 +741,8 @@ static int _insert_dev(const char *path, dev_t d)
 			return 0;
 		}
 
-		if (!(path_copy = dm_pool_strdup(_cache.mem, path))) {
-			log_error("Failed to duplicate path string.");
-			return 0;
-		}
-
-		if (!_add_alias(dev, path_copy)) {
-			log_error("Couldn't add alias to dev cache.");
-			return 0;
-		}
-
-		if (!dm_hash_insert(_cache.names, path_copy, dev)) {
-			log_error("Couldn't add name to hash in dev cache.");
-			return 0;
-		}
+		if (!_add_alias(dev, path, HASH))
+			return_0;
 
 		return 1;
 	}
@@ -755,20 +754,8 @@ static int _insert_dev(const char *path, dev_t d)
 		log_debug_devs("Found dev %d:%d %s - new alias.",
 			       (int)MAJOR(d), (int)MINOR(d), path);
 
-		if (!(path_copy = dm_pool_strdup(_cache.mem, path))) {
-			log_error("Failed to duplicate path string.");
-			return 0;
-		}
-
-		if (!_add_alias(dev, path_copy)) {
-			log_error("Couldn't add alias to dev cache.");
-			return 0;
-		}
-
-		if (!dm_hash_insert(_cache.names, path_copy, dev)) {
-			log_error("Couldn't add name to hash in dev cache.");
-			return 0;
-		}
+		if (!_add_alias(dev, path, HASH))
+			return_0;
 
 		return 1;
 	}
@@ -794,25 +781,10 @@ static int _insert_dev(const char *path, dev_t d)
 			return 0;
 		}
 
-		if (!(path_copy = dm_pool_strdup(_cache.mem, path))) {
-			log_error("Failed to duplicate path string.");
-			return 0;
-		}
-
-		if (!_add_alias(dev, path_copy)) {
-			log_error("Couldn't add alias to dev cache.");
-			return 0;
-		}
-
-		dm_hash_remove(_cache.names, path);
-
-		if (!dm_hash_insert(_cache.names, path_copy, dev)) {
-			log_error("Couldn't add name to hash in dev cache.");
-			return 0;
-		}
+		if (!_add_alias(dev, path, REHASH))
+			return_0;
 
 		return 1;
-
 	}
 
 	/*
@@ -824,22 +796,8 @@ static int _insert_dev(const char *path, dev_t d)
 			       (int)MAJOR(d), (int)MINOR(d), path,
 			       (int)MAJOR(dev_by_path->dev), (int)MINOR(dev_by_path->dev));
 
-		if (!(path_copy = dm_pool_strdup(_cache.mem, path))) {
-			log_error("Failed to duplicate path string.");
-			return 0;
-		}
-
-		if (!_add_alias(dev, path_copy)) {
-			log_error("Couldn't add alias to dev cache.");
-			return 0;
-		}
-
-		dm_hash_remove(_cache.names, path);
-
-		if (!dm_hash_insert(_cache.names, path_copy, dev)) {
-			log_error("Couldn't add name to hash in dev cache.");
-			return 0;
-		}
+		if (!_add_alias(dev, path, REHASH))
+			return_0;
 
 		return 1;
 	}


