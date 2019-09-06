From: David Teigland <teigland@sourceware.org>
Date: Fri, 6 Sep 2019 17:10:47 -0400
Subject: 2019-09-05-add-io-manager - io-manager: clean up block sizes
Message-ID: <201909062110.x86LAlPn030297@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=13c702f862008192a36ee171e546ba0d247bcf9f
Commit:        13c702f862008192a36ee171e546ba0d247bcf9f
Parent:        4b25dd7bc229645535698109fb411a9c0752c446
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Sep 6 14:40:39 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Sep 6 14:40:39 2019 -0500

io-manager: clean up block sizes

---
 lib/device/io-manager.c |   62 +++++++++++++++++++++++++---------------------
 lib/device/io-manager.h |    4 +-
 2 files changed, 36 insertions(+), 30 deletions(-)

diff --git a/lib/device/io-manager.c b/lib/device/io-manager.c
index 9b44ff3..e903b22 100644
--- a/lib/device/io-manager.c
+++ b/lib/device/io-manager.c
@@ -438,39 +438,44 @@ static bool _common_get_size(struct io_engine *e, const char *path, int fd, uint
 }
 
 static bool _common_get_block_sizes(struct io_engine *e, const char *path, int fd,
-                                    unsigned *physical, unsigned *block_size)
+                                    unsigned *physical_block_size,
+				    unsigned *logical_block_size)
 {
+	unsigned int pbs = 0;
+	unsigned int lbs = 0;
+
 	// There are 3 ioctls for getting a block size:
 	// BLKBSZGET  - fs allocation unit size
 	// BLKPBSZGET - physical block size (kernel 2.6.32 onwards)
 	// BLKSSZGET  - logical block size
 
-	if (ioctl(fd, BLKBSZGET, block_size) < 0) {
-		log_sys_error("ioctl BLKBSZGET", path);
-		return false;
-	}
-	log_debug_devs("%s: Block size is %u bytes", path, *block_size);
 
-#ifdef BLKPBSZGET
-	if (ioctl(fd, BLKPBSZGET, physical) < 0) {
-		log_sys_error("ioctl BLKPBSZGET", path);
-		return false;
-	}
-	log_debug_devs("%s: Physical block size is %u bytes", path, *physical);
-#elif defined (BLKSSZGET)
-	if (ioctl(fd, BLKSSZGET, physical) < 0) {
-		log_sys_error("ioctl BLKSSZGET", path);
-		return false;
+#ifdef BLKPBSZGET /* not defined before kernel version 2.6.32 (e.g. rhel5) */
+	/*
+	 * BLKPBSZGET from kernel comment for blk_queue_physical_block_size:
+	 * "the lowest possible sector size that the hardware can operate on
+	 * without reverting to read-modify-write operations"
+	 */
+	if (ioctl(fd, BLKPBSZGET, &pbs)) {
+		log_debug_devs("No physical block size for %s", path);
+		pbs = 0;
 	}
-	log_debug_devs("%s: Physical block size can't be determined: "
-                       "Using logical block size of %u bytes", path, physical);
-#else
-	/* if even BLKSSZGET is not available, use default 512b */
-	*physical = 512;
-	log_debug_devs("%s: Physical block size can't be determined: "
-                       "Using block size of %u bytes instead", path, *physical);
 #endif
 
+	/*
+	 * BLKSSZGET from kernel comment for blk_queue_logical_block_size:
+	 * "the lowest possible block size that the storage device can address."
+	 */
+	if (ioctl(fd, BLKSSZGET, &lbs)) {
+		log_debug_devs("No logical block size for %s", path);
+		lbs = 0;
+	}
+
+	*physical_block_size = pbs;
+	*logical_block_size = lbs;
+
+	if (!lbs)
+		return false;
 	return true;
 }
 
@@ -732,7 +737,7 @@ struct io_dev_internal {
 	// We cache these to avoid repeatedly issuing the ioctls
 	bool got_block_sizes;
 	unsigned physical_block_size;
-	unsigned block_size;
+	unsigned logical_block_size;
 
 	struct dm_list lru;
 };
@@ -1959,7 +1964,8 @@ bool io_dev_size(struct io_dev *dev, uint64_t *size)
 	return iom->engine->get_size(iom->engine, dev->idev->path, dev->idev->fd, size);
 }
 
-bool io_dev_block_sizes(struct io_dev *dev, unsigned *physical, unsigned *block_size)
+bool io_dev_block_sizes(struct io_dev *dev, unsigned *physical_block_size,
+					    unsigned *logical_block_size)
 {
 	struct io_manager *iom = dev->idev->iom;
 	struct io_dev_internal *d = dev->idev;
@@ -1967,14 +1973,14 @@ bool io_dev_block_sizes(struct io_dev *dev, unsigned *physical, unsigned *block_
 	if (!d->got_block_sizes) {
 		if (!iom->engine->get_block_sizes(iom->engine, d->path, d->fd,
                                                   &d->physical_block_size,
-                                                  &d->block_size))
+                                                  &d->logical_block_size))
 			return false;
 		else
 			d->got_block_sizes = true;
 	}
 
-	*physical = dev->idev->physical_block_size;
-	*block_size = dev->idev->block_size;
+	*physical_block_size = dev->idev->physical_block_size;
+	*logical_block_size = dev->idev->logical_block_size;
 	return true;
 }
 
diff --git a/lib/device/io-manager.h b/lib/device/io-manager.h
index 87429b6..af33259 100644
--- a/lib/device/io-manager.h
+++ b/lib/device/io-manager.h
@@ -61,7 +61,7 @@ struct io_engine {
 	// The path is there purely for logging.
 	bool (*get_size)(struct io_engine *e, const char *path, int fd, sector_t *size);
 	bool (*get_block_sizes)(struct io_engine *e, const char *path, int fd,
-                                unsigned *physical, unsigned *logical);
+                                unsigned *physical_block_size, unsigned *logical_block_size);
 };
 
 struct io_engine *create_async_io_engine(bool use_o_direct);
@@ -197,7 +197,7 @@ bool io_invalidate_dev(struct io_manager *iom, struct io_dev *dev);
 bool io_invalidate_all(struct io_manager *iom);
 
 bool io_dev_size(struct io_dev *dev, uint64_t *sectors);
-bool io_dev_block_sizes(struct io_dev *dev, unsigned *physical, unsigned *block_size);
+bool io_dev_block_sizes(struct io_dev *dev, unsigned *physical_block_size, unsigned *logical_block_size);
 
 // For testing and debug only
 int io_get_fd(struct io_dev *dev);


