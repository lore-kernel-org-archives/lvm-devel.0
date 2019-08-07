From: David Teigland <teigland@sourceware.org>
Date: Wed, 7 Aug 2019 12:53:34 -0400
Subject: master - devices: clean up block size functions
Message-ID: <201908071653.x77GrYdL023627@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=09bc2d0fd15a5bbb5d1e8d6ce79bd786ffed42b3
Commit:        09bc2d0fd15a5bbb5d1e8d6ce79bd786ffed42b3
Parent:        bec3088f85a9a2d0b6a355aea1adc67fab8de6e9
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Aug 7 11:38:06 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Aug 7 11:48:10 2019 -0500

devices: clean up block size functions

Replace calls to the old dev_get_block_size function
with calls to the new dev_get_direct_block_size function,
and remove the old function.
---
 lib/device/dev-cache.c  |    2 -
 lib/device/dev-io.c     |   73 -----------------------------------------------
 lib/device/device.h     |    3 --
 lib/locking/lvmlockd.c  |   10 +++---
 lib/metadata/metadata.c |   25 ++++++++--------
 5 files changed, 18 insertions(+), 95 deletions(-)

diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 980dd3c..a15e239 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -64,8 +64,6 @@ static int _insert(const char *path, const struct stat *info,
 /* Setup non-zero members of passed zeroed 'struct device' */
 static void _dev_init(struct device *dev)
 {
-	dev->phys_block_size = -1;
-	dev->block_size = -1;
 	dev->fd = -1;
 	dev->read_ahead = -1;
 
diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index 5fa0b7a..8a9ed5c 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -53,77 +53,6 @@
 
 static unsigned _dev_size_seqno = 1;
 
-/*
- * Get the physical and logical block size for a device.
- */
-int dev_get_block_size(struct device *dev, unsigned int *physical_block_size, unsigned int *block_size)
-{
-	const char *name = dev_name(dev);
-	int fd = dev->bcache_fd;
-	int do_close = 0;
-	int r = 1;
-
-	if ((dev->phys_block_size > 0) && (dev->block_size > 0)) {
-		*physical_block_size = (unsigned int)dev->phys_block_size;
-		*block_size = (unsigned int)dev->block_size;
-		return 1;
-	}
-
-	if (fd <= 0) {
-		if (!dev->open_count) {
-			if (!dev_open_readonly(dev))
-				return_0;
-			do_close = 1;
-		}
-		fd = dev_fd(dev);
-	}
-
-	if (dev->block_size == -1) {
-		if (ioctl(fd, BLKBSZGET, &dev->block_size) < 0) {
-			log_sys_error("ioctl BLKBSZGET", name);
-			r = 0;
-			goto out;
-		}
-		log_debug_devs("%s: Block size is %u bytes", name, dev->block_size);
-	}
-
-#ifdef BLKPBSZGET
-	/* BLKPBSZGET is available in kernel >= 2.6.32 only */
-	if (dev->phys_block_size == -1) {
-		if (ioctl(fd, BLKPBSZGET, &dev->phys_block_size) < 0) {
-			log_sys_error("ioctl BLKPBSZGET", name);
-			r = 0;
-			goto out;
-		}
-		log_debug_devs("%s: Physical block size is %u bytes", name, dev->phys_block_size);
-	}
-#elif defined (BLKSSZGET)
-	/* if we can't get physical block size, just use logical block size instead */
-	if (dev->phys_block_size == -1) {
-		if (ioctl(fd, BLKSSZGET, &dev->phys_block_size) < 0) {
-			log_sys_error("ioctl BLKSSZGET", name);
-			r = 0;
-			goto out;
-		}
-		log_debug_devs("%s: Physical block size can't be determined: Using logical block size of %u bytes", name, dev->phys_block_size);
-	}
-#else
-	/* if even BLKSSZGET is not available, use default 512b */
-	if (dev->phys_block_size == -1) {
-		dev->phys_block_size = 512;
-		log_debug_devs("%s: Physical block size can't be determined: Using block size of %u bytes instead", name, dev->phys_block_size);
-	}
-#endif
-
-	*physical_block_size = (unsigned int) dev->phys_block_size;
-	*block_size = (unsigned int) dev->block_size;
-out:
-	if (do_close && !dev_close_immediate(dev))
-		stack;
-
-	return r;
-}
-
 static int _dev_get_size_file(struct device *dev, uint64_t *size)
 {
 	const char *name = dev_name(dev);
@@ -515,8 +444,6 @@ static void _close(struct device *dev)
 	if (close(dev->fd))
 		log_sys_error("close", dev_name(dev));
 	dev->fd = -1;
-	dev->phys_block_size = -1;
-	dev->block_size = -1;
 
 	log_debug_devs("Closed %s", dev_name(dev));
 
diff --git a/lib/device/device.h b/lib/device/device.h
index bb65f84..bd3b355 100644
--- a/lib/device/device.h
+++ b/lib/device/device.h
@@ -67,8 +67,6 @@ struct device {
 	/* private */
 	int fd;
 	int open_count;
-	int phys_block_size;     /* From either BLKPBSZGET or BLKSSZGET, don't use */
-	int block_size;	         /* From BLKBSZGET, returns bdev->bd_block_size, likely set by fs, probably don't use */
 	int physical_block_size; /* From BLKPBSZGET: lowest possible sector size that the hardware can operate on without reverting to read-modify-write operations */
 	int logical_block_size;  /* From BLKSSZGET: lowest possible block size that the storage device can address */
 	int read_ahead;
@@ -133,7 +131,6 @@ void dev_size_seqno_inc(void);
 /*
  * All io should use these routines.
  */
-int dev_get_block_size(struct device *dev, unsigned int *phys_block_size, unsigned int *block_size);
 int dev_get_direct_block_sizes(struct device *dev, unsigned int *physical_block_size,
                                unsigned int *logical_block_size);
 int dev_get_size(struct device *dev, uint64_t *size);
diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index 5ef3c94..612de5d 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -636,7 +636,7 @@ static int _init_vg_sanlock(struct cmd_context *cmd, struct volume_group *vg, in
 	struct pv_list *pvl;
 	struct device *sector_dev;
 	uint32_t sector_size = 0;
-	unsigned int phys_block_size, block_size;
+	unsigned int physical_block_size, logical_block_size;
 	int num_mb = 0;
 	int result;
 	int ret;
@@ -653,14 +653,14 @@ static int _init_vg_sanlock(struct cmd_context *cmd, struct volume_group *vg, in
 	 */
 
 	dm_list_iterate_items(pvl, &vg->pvs) {
-		if (!dev_get_block_size(pvl->pv->dev, &phys_block_size, &block_size))
+		if (!dev_get_direct_block_sizes(pvl->pv->dev, &physical_block_size, &logical_block_size))
 			continue;
 
 		if (!sector_size) {
-			sector_size = phys_block_size;
+			sector_size = logical_block_size;
 			sector_dev = pvl->pv->dev;
-		} else if (sector_size != phys_block_size) {
-			log_error("Inconsistent sector sizes for %s and %s.",
+		} else if (sector_size != logical_block_size) {
+			log_error("Inconsistent logical block sizes for %s and %s.",
 				  dev_name(pvl->pv->dev), dev_name(sector_dev));
 			return 0;
 		}
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index e55adc2..0f5154d 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -679,20 +679,21 @@ int vg_remove(struct volume_group *vg)
 }
 
 int check_dev_block_size_for_vg(struct device *dev, const struct volume_group *vg,
-				unsigned int *max_phys_block_size_found)
+				unsigned int *max_logical_block_size_found)
 {
-	unsigned int phys_block_size, block_size;
+	unsigned int physical_block_size, logical_block_size;
 
-	if (!(dev_get_block_size(dev, &phys_block_size, &block_size)))
+	if (!(dev_get_direct_block_sizes(dev, &physical_block_size, &logical_block_size)))
 		return_0;
 
-	if (phys_block_size > *max_phys_block_size_found)
-		*max_phys_block_size_found = phys_block_size;
+	/* FIXME: max_logical_block_size_found does not seem to be used anywhere */
+	if (logical_block_size > *max_logical_block_size_found)
+		*max_logical_block_size_found = logical_block_size;
 
-	if (phys_block_size >> SECTOR_SHIFT > vg->extent_size) {
+	if (logical_block_size >> SECTOR_SHIFT > vg->extent_size) {
 		log_error("Physical extent size used for volume group %s "
-			  "is less than physical block size that %s uses.",
-			   vg->name, dev_name(dev));
+			  "is less than logical block size (%u bytes) that %s uses.",
+			   vg->name, logical_block_size, dev_name(dev));
 		return 0;
 	}
 
@@ -702,10 +703,10 @@ int check_dev_block_size_for_vg(struct device *dev, const struct volume_group *v
 int vg_check_pv_dev_block_sizes(const struct volume_group *vg)
 {
 	struct pv_list *pvl;
-	unsigned int max_phys_block_size_found = 0;
+	unsigned int max_logical_block_size_found = 0;
 
 	dm_list_iterate_items(pvl, &vg->pvs) {
-		if (!check_dev_block_size_for_vg(pvl->pv->dev, vg, &max_phys_block_size_found))
+		if (!check_dev_block_size_for_vg(pvl->pv->dev, vg, &max_logical_block_size_found))
 			return 0;
 	}
 
@@ -750,7 +751,7 @@ int check_pv_dev_sizes(struct volume_group *vg)
 int vg_extend_each_pv(struct volume_group *vg, struct pvcreate_params *pp)
 {
 	struct pv_list *pvl;
-	unsigned int max_phys_block_size = 0;
+	unsigned int max_logical_block_size = 0;
 	unsigned int physical_block_size, logical_block_size;
 	unsigned int prev_lbs = 0;
 	int inconsistent_existing_lbs = 0;
@@ -790,7 +791,7 @@ int vg_extend_each_pv(struct volume_group *vg, struct pvcreate_params *pp)
 
 		if (!(check_dev_block_size_for_vg(pvl->pv->dev,
 						  (const struct volume_group *) vg,
-						  &max_phys_block_size))) {
+						  &max_logical_block_size))) {
 			log_error("PV %s has wrong block size.", pv_dev_name(pvl->pv));
 			return 0;
 		}


