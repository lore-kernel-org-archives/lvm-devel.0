From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon,  8 Feb 2021 22:45:13 +0000 (GMT)
Subject: main - dev-type: convert to use log_warn
Message-ID: <20210208224513.0DD143874C24@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d422aa79249a069317ef71e872da42d6e2e6c344
Commit:        d422aa79249a069317ef71e872da42d6e2e6c344
Parent:        3bf2ca11d9ce4ce205a98828ec4bfe8169c33403
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Feb 7 14:06:12 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 8 23:43:38 2021 +0100

dev-type: convert to use log_warn

Keep log_error designated only for 'erroring' condition of command
and replace these errors with log_warn() WARNING.

Also do some indent changes.
---
 lib/device/bcache.c    | 27 +++++++++++++--------------
 lib/device/dev-cache.c |  6 +++---
 lib/device/dev-io.c    |  9 +++++----
 lib/device/dev-type.c  | 34 +++++++++++++++++-----------------
 4 files changed, 38 insertions(+), 38 deletions(-)

diff --git a/lib/device/bcache.c b/lib/device/bcache.c
index 2451eda2b..a3803befb 100644
--- a/lib/device/bcache.c
+++ b/lib/device/bcache.c
@@ -42,7 +42,7 @@ static int *_fd_table;
 
 static void log_sys_warn(const char *call)
 {
-	log_warn("%s failed: %s", call, strerror(errno));
+	log_warn("WARNING: %s failed: %s.", call, strerror(errno));
 }
 
 // Assumes the list is not empty.
@@ -92,7 +92,7 @@ static void _cb_set_destroy(struct cb_set *cbs)
 	// never be in flight IO.
 	if (!dm_list_empty(&cbs->allocated)) {
 		// bail out
-		log_error("async io still in flight");
+		log_warn("WARNING: async io still in flight.");
 		return;
 	}
 
@@ -1351,26 +1351,26 @@ static bool _writeback_v(struct radix_tree_iterator *it,
 	struct block *b = v.ptr;
 
 	if (_test_flags(b, BF_DIRTY))
-        	_issue_write(b);
+		_issue_write(b);
 
-        return true;
+	return true;
 }
 
 static bool _invalidate_v(struct radix_tree_iterator *it,
                           uint8_t *kb, uint8_t *ke, union radix_value v)
 {
 	struct block *b = v.ptr;
-        struct invalidate_iterator *iit = container_of(it, struct invalidate_iterator, it);
+	struct invalidate_iterator *iit = container_of(it, struct invalidate_iterator, it);
 
 	if (b->error || _test_flags(b, BF_DIRTY)) {
-        	log_warn("bcache_invalidate: block (%d, %llu) still dirty",
-                         b->di, (unsigned long long) b->index);
-        	iit->success = false;
-        	return true;
+		log_warn("WARNING: bcache_invalidate: block (%d, %llu) still dirty.",
+			 b->di, (unsigned long long) b->index);
+		iit->success = false;
+		return true;
 	}
 
 	if (b->ref_count) {
-		log_warn("bcache_invalidate: block (%d, %llu) still held",
+		log_warn("WARNING: bcache_invalidate: block (%d, %llu) still held.",
 			 b->di, (unsigned long long) b->index);
 		iit->success = false;
 		return true;
@@ -1386,7 +1386,7 @@ static bool _invalidate_v(struct radix_tree_iterator *it,
 
 bool bcache_invalidate_di(struct bcache *cache, int di)
 {
-        union key k;
+	union key k;
 	struct invalidate_iterator it;
 
 	k.parts.di = di;
@@ -1429,7 +1429,7 @@ static bool _abort_v(struct radix_tree_iterator *it,
 
 void bcache_abort_di(struct bcache *cache, int di)
 {
-        union key k;
+	union key k;
 	struct radix_tree_iterator it;
 
 	k.parts.di = di;
@@ -1512,10 +1512,9 @@ int bcache_change_fd(int di, int fd)
 	if (di >= _fd_table_size)
 		return 0;
 	if (di < 0) {
-		log_error(INTERNAL_ERROR "Cannot change not openned DI with FD:%d", fd);
+		log_error(INTERNAL_ERROR "Cannot change not opened DI with FD:%d", fd);
 		return 0;
 	}
 	_fd_table[di] = fd;
 	return 1;
 }
-
diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 517b9e6f8..2783d4acc 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -403,7 +403,7 @@ static int _get_sysfs_value(const char *path, char *buf, size_t buf_size, int er
 		r = 1;
 out:
 	if (fclose(fp))
-		log_sys_error("fclose", path);
+		log_sys_debug("fclose", path);
 
 	return r;
 }
@@ -930,7 +930,7 @@ static int _dev_cache_iterate_sysfs_for_index(const char *path)
 	r = !partial_failure;
 
 	if (closedir(d))
-		log_sys_error("closedir", path);
+		log_sys_debug("closedir", path);
 
 	return r;
 }
@@ -956,7 +956,7 @@ int dev_cache_index_devs(void)
 				return 1;
 			}
 
-			log_sys_error("stat", path);
+			log_sys_debug("stat", path);
 			return 0;
 		}
 	} else if (!sysfs_has_dev_block)
diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index 4f52954fd..9b007dcaa 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -104,7 +104,7 @@ static int _dev_get_size_dev(struct device *dev, uint64_t *size)
 	}
 
 	if (ioctl(fd, BLKGETSIZE64, size) < 0) {
-		log_sys_error("ioctl BLKGETSIZE64", name);
+		log_warn("WARNING: %s: ioctl BLKGETSIZE64 %s", name, strerror(errno));
 		if (do_close && !dev_close_immediate(dev))
 			stack;
 		return 0;
@@ -132,12 +132,13 @@ static int _dev_read_ahead_dev(struct device *dev, uint32_t *read_ahead)
 	}
 
 	if (!dev_open_readonly_quiet(dev)) {
-		log_error("Failed to open to get readahead %s", dev_name(dev));
+		log_warn("WARNING: Failed to open %s to get readahead %s.",
+			 dev_name(dev), strerror(errno));
 		return 0;
 	}
 
 	if (ioctl(dev->fd, BLKRAGET, &read_ahead_long) < 0) {
-		log_sys_error("ioctl BLKRAGET", dev_name(dev));
+		log_warn("WARNING: %s: ioctl BLKRAGET %s.", dev_name(dev), strerror(errno));
 		if (!dev_close_immediate(dev))
 			stack;
 		return 0;
@@ -170,7 +171,7 @@ static int _dev_discard_blocks(struct device *dev, uint64_t offset_bytes, uint64
 		       test_mode() ? " (test mode - suppressed)" : "");
 
 	if (!test_mode() && ioctl(dev->fd, BLKDISCARD, &discard_range) < 0) {
-		log_error("%s: BLKDISCARD ioctl at offset %" PRIu64 " size %" PRIu64 " failed: %s.",
+		log_warn("WARNING: %s: ioctl BLKDISCARD@offset %" PRIu64 " size %" PRIu64 " failed: %s.",
 			  dev_name(dev), offset_bytes, size_bytes, strerror(errno));
 		if (!dev_close_immediate(dev))
 			stack;
diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index c9f12d793..11add4b6b 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -211,7 +211,7 @@ struct dev_types *create_dev_types(const char *proc_dir,
 				log_error("Expecting string in devices/types "
 					  "in config file");
 				if (fclose(pd))
-					log_sys_error("fclose", proc_devices);
+					log_sys_debug("fclose", proc_devices);
 				goto bad;
 			}
 			dev_len = strlen(cv->v.str);
@@ -222,7 +222,7 @@ struct dev_types *create_dev_types(const char *proc_dir,
 					  "in devices/types in config file",
 					  name);
 				if (fclose(pd))
-					log_sys_error("fclose", proc_devices);
+					log_sys_debug("fclose", proc_devices);
 				goto bad;
 			}
 			if (!cv->v.i) {
@@ -230,7 +230,7 @@ struct dev_types *create_dev_types(const char *proc_dir,
 					  "%s in devices/types in config file",
 					  name);
 				if (fclose(pd))
-					log_sys_error("fclose", proc_devices);
+					log_sys_debug("fclose", proc_devices);
 				goto bad;
 			}
 			if (dev_len <= strlen(line + i) &&
@@ -391,13 +391,13 @@ static int _has_sys_partition(struct device *dev)
 	/* check if dev is a partition */
 	if (dm_snprintf(path, sizeof(path), "%s/dev/block/%d:%d/partition",
 			dm_sysfs_dir(), major, minor) < 0) {
-		log_error("dm_snprintf partition failed");
+		log_warn("WARNING: %s: partition path is too long.", dev_name(dev));
 		return 0;
 	}
 
 	if (stat(path, &info) == -1) {
 		if (errno != ENOENT)
-			log_sys_error("stat", path);
+			log_sys_debug("stat", path);
 		return 0;
 	}
 	return 1;
@@ -563,7 +563,6 @@ int dev_is_partitioned(struct dev_types *dt, struct device *dev)
  */
 int dev_get_primary_dev(struct dev_types *dt, struct device *dev, dev_t *result)
 {
-	const char *sysfs_dir = dm_sysfs_dir();
 	int major = (int) MAJOR(dev->dev);
 	int minor = (int) MINOR(dev->dev);
 	char path[PATH_MAX];
@@ -616,24 +615,25 @@ int dev_get_primary_dev(struct dev_types *dt, struct device *dev, dev_t *result)
 	 * Parent's 'dev' sysfs attribute  = /sys/block/md0/dev
 	 */
 	if ((size = readlink(dirname(path), temp_path, sizeof(temp_path) - 1)) < 0) {
-		log_sys_error("readlink", path);
+		log_warn("WARNING: Readlink of %s failed.", path);
 		goto out;
 	}
 
 	temp_path[size] = '\0';
 
 	if (dm_snprintf(path, sizeof(path), "%s/block/%s/dev",
-			sysfs_dir, basename(dirname(temp_path))) < 0) {
-		log_error("dm_snprintf dev failed");
+			dm_sysfs_dir(), basename(dirname(temp_path))) < 0) {
+		log_warn("WARNING: sysfs path for %s is too long.",
+			 basename(dirname(temp_path)));
 		goto out;
 	}
 
 	/* finally, parse 'dev' attribute and create corresponding dev_t */
 	if (!(fp = fopen(path, "r"))) {
 		if (errno == ENOENT)
-			log_error("sysfs file %s does not exist.", path);
+			log_debug("sysfs file %s does not exist.", path);
 		else
-			log_sys_error("fopen", path);
+			log_sys_debug("fopen", path);
 		goto out;
 	}
 
@@ -643,7 +643,7 @@ int dev_get_primary_dev(struct dev_types *dt, struct device *dev, dev_t *result)
 	}
 
 	if (sscanf(buffer, "%d:%d", &major, &minor) != 2) {
-		log_error("sysfs file %s not in expected MAJ:MIN format: %s",
+		log_warn("WARNING: sysfs file %s not in expected MAJ:MIN format: %s",
 			  path, buffer);
 		goto out;
 	}
@@ -651,7 +651,7 @@ int dev_get_primary_dev(struct dev_types *dt, struct device *dev, dev_t *result)
 	ret = 2;
 out:
 	if (fp && fclose(fp))
-		log_sys_error("fclose", path);
+		log_sys_debug("fclose", path);
 
 	return ret;
 }
@@ -713,7 +713,7 @@ static int _blkid_wipe(blkid_probe probe, struct device *dev, const char *name,
 				return 0;
 			}
 
-			log_error("WARNING: " MSG_FAILED_SIG_OFFSET MSG_WIPING_SKIPPED, type, name);
+			log_warn("WARNING: " MSG_FAILED_SIG_OFFSET MSG_WIPING_SKIPPED, type, name);
 			return 2;
 		}
 		if (blkid_probe_lookup_value(probe, "SBMAGIC", &magic, &len)) {
@@ -911,9 +911,9 @@ int wipe_known_signatures(struct cmd_context *cmd, struct device *dev,
 							 yes, force, wiped);
 #endif
 	if (blkid_wiping_enabled) {
-		log_warn("allocation/use_blkid_wiping=1 configuration setting is set "
+		log_warn("WARNING: allocation/use_blkid_wiping=1 configuration setting is set "
 			 "while LVM is not compiled with blkid wiping support.");
-		log_warn("Falling back to native LVM signature detection.");
+		log_warn("WARNING: Falling back to native LVM signature detection.");
 	}
 	return _wipe_known_signatures_with_lvm(dev, name,
 					       types_to_exclude,
@@ -929,7 +929,7 @@ static int _snprintf_attr(char *buf, size_t buf_size, const char *sysfs_dir,
 	if (dm_snprintf(buf, buf_size, "%s/dev/block/%d:%d/%s", sysfs_dir,
 			(int)MAJOR(dev), (int)MINOR(dev),
 			attribute) < 0) {
-		log_warn("dm_snprintf %s failed.", attribute);
+		log_warn("WARNING: sysfs path for %s attribute is too long.", attribute);
 		return 0;
 	}
 


