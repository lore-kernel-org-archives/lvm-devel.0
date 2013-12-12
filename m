From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 12 Dec 2013 14:03:24 +0000 (UTC)
Subject: master - device: add physical block size info and make sure VG extent size >= PV's phys. block size
Message-ID: <20131212140324.E19C360E5A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=32080c4ff748e4afbeacf9dbc4a98bfea658a392
Commit:        32080c4ff748e4afbeacf9dbc4a98bfea658a392
Parent:        3eed0aa7dca9c1895bbf80e1585debf9bddac5a8
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Dec 12 11:26:35 2013 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Dec 12 15:02:36 2013 +0100

device: add physical block size info and make sure VG extent size >= PV's phys. block size

---
 WHATS_NEW                        |    1 +
 lib/device/dev-cache.c           |    1 +
 lib/device/dev-io.c              |   65 +++++++++++++++++---------------------
 lib/device/device.h              |    3 +-
 lib/metadata/metadata-exported.h |    1 +
 lib/metadata/metadata.c          |   56 +++++++++++++++++++++++++++++---
 lib/metadata/metadata.h          |    3 ++
 man/vgchange.8.in                |    6 ++-
 man/vgcreate.8.in                |    6 ++-
 tools/vgchange.c                 |    6 +++
 10 files changed, 101 insertions(+), 47 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 78657dd..1679131 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.105 -
 =====================================
+  Make sure VG extent size is always greater or equal to PV phys. block size.
   Optimize double call of stat() for cached devices.
   Enable support for thin provisioning for default configuration.
   Improve process_each_lv_in_vg() tag processing.
diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 5d26d41..87d2f58 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -56,6 +56,7 @@ static int _insert(const char *path, const struct stat *info,
 /* Setup non-zero members of passed zeroed 'struct device' */
 static void _dev_init(struct device *dev, int max_error_count)
 {
+	dev->phys_block_size = -1;
 	dev->block_size = -1;
 	dev->fd = -1;
 	dev->read_ahead = -1;
diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index 1d35a8f..45700e5 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -123,23 +123,44 @@ static int _io(struct device_area *where, char *buffer, int should_write)
  *---------------------------------------------------------------*/
 
 /*
- * Get the sector size from an _open_ device.
+ * Get the physical and logical block size for a device.
  */
-static int _get_block_size(struct device *dev, unsigned int *size)
+int dev_get_block_size(struct device *dev, unsigned int *physical_block_size, unsigned int *block_size)
 {
 	const char *name = dev_name(dev);
+	int needs_open;
+	int r = 1;
+
+	needs_open = (!dev->open_count && (dev->phys_block_size == -1 || dev->block_size == -1));
+
+	if (needs_open && !dev_open_readonly(dev))
+		return_0;
+
+	if (dev->phys_block_size == -1) {
+		if (ioctl(dev_fd(dev), BLKPBSZGET, &dev->phys_block_size) < 0) {
+			log_sys_error("ioctl BLKPBSZGET", name);
+			r = 0;
+			goto out;
+		}
+		log_debug_devs("%s: physical block size is %u bytes", name, dev->phys_block_size);
+	}
 
 	if (dev->block_size == -1) {
 		if (ioctl(dev_fd(dev), BLKBSZGET, &dev->block_size) < 0) {
 			log_sys_error("ioctl BLKBSZGET", name);
-			return 0;
+			r = 0;
+			goto out;
 		}
 		log_debug_devs("%s: block size is %u bytes", name, dev->block_size);
 	}
 
-	*size = (unsigned int) dev->block_size;
+	*physical_block_size = (unsigned int) dev->phys_block_size;
+	*block_size = (unsigned int) dev->block_size;
+out:
+	if (needs_open)
+		dev_close(dev);
 
-	return 1;
+	return r;
 }
 
 /*
@@ -168,13 +189,14 @@ static int _aligned_io(struct device_area *where, char *buffer,
 		       int should_write)
 {
 	char *bounce, *bounce_buf;
+	unsigned int physical_block_size = 0;
 	unsigned int block_size = 0;
 	uintptr_t mask;
 	struct device_area widened;
 	int r = 0;
 
 	if (!(where->dev->flags & DEV_REGULAR) &&
-	    !_get_block_size(where->dev, &block_size))
+	    !dev_get_block_size(where->dev, &physical_block_size, &block_size))
 		return_0;
 
 	if (!block_size)
@@ -370,36 +392,6 @@ int dev_discard_blocks(struct device *dev, uint64_t offset_bytes, uint64_t size_
 	return _dev_discard_blocks(dev, offset_bytes, size_bytes);
 }
 
-/* FIXME Unused
-int dev_get_sectsize(struct device *dev, uint32_t *size)
-{
-	int fd;
-	int s;
-	const char *name = dev_name(dev);
-
-	if ((fd = open(name, O_RDONLY)) < 0) {
-		log_sys_error("open", name);
-		return 0;
-	}
-
-	if (ioctl(fd, BLKSSZGET, &s) < 0) {
-		log_sys_error("ioctl BLKSSZGET", name);
-		if (close(fd))
-			log_sys_error("close", name);
-		return 0;
-	}
-
-	if (close(fd))
-		log_sys_error("close", name);
-
-	*size = (uint32_t) s;
-
-	log_very_verbose("%s: sector size is %" PRIu32 " bytes", name, *size);
-
-	return 1;
-}
-*/
-
 void dev_flush(struct device *dev)
 {
 	if (!(dev->flags & DEV_REGULAR) && ioctl(dev->fd, BLKFLSBUF, 0) >= 0)
@@ -571,6 +563,7 @@ static void _close(struct device *dev)
 	if (close(dev->fd))
 		log_sys_error("close", dev_name(dev));
 	dev->fd = -1;
+	dev->phys_block_size = -1;
 	dev->block_size = -1;
 	dm_list_del(&dev->open_list);
 
diff --git a/lib/device/device.h b/lib/device/device.h
index e42f664..35d7505 100644
--- a/lib/device/device.h
+++ b/lib/device/device.h
@@ -42,6 +42,7 @@ struct device {
 	int open_count;
 	int error_count;
 	int max_error_count;
+	int phys_block_size;
 	int block_size;
 	int read_ahead;
 	uint32_t flags;
@@ -66,8 +67,8 @@ struct device_area {
 /*
  * All io should use these routines.
  */
+int dev_get_block_size(struct device *dev, unsigned int *phys_block_size, unsigned int *block_size);
 int dev_get_size(const struct device *dev, uint64_t *size);
-int dev_get_sectsize(struct device *dev, uint32_t *size);
 int dev_get_read_ahead(struct device *dev, uint32_t *read_ahead);
 int dev_discard_blocks(struct device *dev, uint64_t offset_bytes, uint64_t size_bytes);
 
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 9d547bb..1cce72c 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -903,6 +903,7 @@ int vg_remove_snapshot(struct logical_volume *cow);
 
 int vg_check_status(const struct volume_group *vg, uint64_t status);
 
+int vg_check_pv_dev_block_sizes(const struct volume_group *vg);
 
 /*
  * Check if the VG reached maximal LVs count (if set)
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 5f2addd..84d3200 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -619,6 +619,40 @@ int vg_remove(struct volume_group *vg)
 	return ret;
 }
 
+int check_dev_block_size_for_vg(struct device *dev, const struct volume_group *vg,
+				unsigned int *max_phys_block_size_found)
+{
+	unsigned int phys_block_size, block_size;
+
+	if (!(dev_get_block_size(dev, &phys_block_size, &block_size)))
+		return_0;
+
+	if (phys_block_size > *max_phys_block_size_found)
+		*max_phys_block_size_found = phys_block_size;
+
+	if (phys_block_size >> SECTOR_SHIFT > vg->extent_size) {
+		log_error("Physical extent size used for volume group %s "
+			  "is less than physical block size that %s uses.",
+			   vg->name, dev_name(dev));
+		return 0;
+	}
+
+	return 1;
+}
+
+int vg_check_pv_dev_block_sizes(const struct volume_group *vg)
+{
+	struct pv_list *pvl;
+	unsigned int max_phys_block_size_found = 0;
+
+	dm_list_iterate_items(pvl, &vg->pvs) {
+		if (!check_dev_block_size_for_vg(pvl->pv->dev, vg, &max_phys_block_size_found))
+			return 0;
+	}
+
+	return 1;
+}
+
 /*
  * Extend a VG by a single PV / device path
  *
@@ -626,10 +660,12 @@ int vg_remove(struct volume_group *vg)
  * - vg: handle of volume group to extend by 'pv_name'
  * - pv_name: device path of PV to add to VG
  * - pp: parameters to pass to implicit pvcreate; if NULL, do not pvcreate
+ * - max_phys_block_size: largest physical block size found amongst PVs in a VG
  *
  */
 static int vg_extend_single_pv(struct volume_group *vg, char *pv_name,
-			       struct pvcreate_params *pp)
+			       struct pvcreate_params *pp,
+			       unsigned int *max_phys_block_size)
 {
 	struct physical_volume *pv;
 
@@ -643,11 +679,18 @@ static int vg_extend_single_pv(struct volume_group *vg, char *pv_name,
 		if (!(pv = pvcreate_vol(vg->cmd, pv_name, pp, 0)))
 			return_0;
 	}
-	if (!add_pv_to_vg(vg, pv_name, pv, pp)) {
-		free_pv_fid(pv);
-		return_0;
-	}
+
+	if (!(check_dev_block_size_for_vg(pv->dev, (const struct volume_group *) vg,
+					  max_phys_block_size)))
+		goto_bad;
+
+	if (!add_pv_to_vg(vg, pv_name, pv, pp))
+		goto_bad;
+
 	return 1;
+bad:
+	free_pv_fid(pv);
+	return 0;
 }
 
 /*
@@ -665,6 +708,7 @@ int vg_extend(struct volume_group *vg, int pv_count, const char *const *pv_names
 {
 	int i;
 	char *pv_name;
+	unsigned int max_phys_block_size = 0;
 
 	if (_vg_bad_status_bits(vg, RESIZEABLE_VG))
 		return_0;
@@ -676,7 +720,7 @@ int vg_extend(struct volume_group *vg, int pv_count, const char *const *pv_names
 			return 0;
 		}
 		dm_unescape_colons_and_at_signs(pv_name, NULL, NULL);
-		if (!vg_extend_single_pv(vg, pv_name, pp)) {
+		if (!vg_extend_single_pv(vg, pv_name, pp, &max_phys_block_size)) {
 			log_error("Unable to add physical volume '%s' to "
 				  "volume group '%s'.", pv_name, vg->name);
 			dm_free(pv_name);
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index 0ab63f2..fef4b3f 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -347,6 +347,9 @@ int pvremove_single(struct cmd_context *cmd, const char *pv_name,
 struct physical_volume *pvcreate_vol(struct cmd_context *cmd, const char *pv_name,
                                      struct pvcreate_params *pp, int write_now);
 
+int check_dev_block_size_for_vg(struct device *dev, const struct volume_group *vg,
+				unsigned int *max_phys_block_size_found);
+
 /* Manipulate PV structures */
 int pv_add(struct volume_group *vg, struct physical_volume *pv);
 int pv_remove(struct volume_group *vg, struct physical_volume *pv);
diff --git a/man/vgchange.8.in b/man/vgchange.8.in
index e687587..823d134 100644
--- a/man/vgchange.8.in
+++ b/man/vgchange.8.in
@@ -183,8 +183,10 @@ minimize metadata read and write overhead.
 .BR \-s ", " \-\-physicalextentsize " " \fIPhysicalExtentSize [ \fIBbBsSkKmMgGtTpPeE ]
 Changes the physical extent size on physical volumes of this volume group.
 A size suffix (k for kilobytes up to t for terabytes) is optional, megabytes
-is the default if no suffix is present.
-The default is 4 MiB and it must be at least 1 KiB and a power of 2.
+is the default if no suffix is present. The value must be at least 1 sector
+for LVM2 format (where the sector size is the largest sector size of the
+PVs currently used in the VG) or 8KiB for LVM1 format and it must be a
+power of 2. The default is 4 MiB.
 
 Before increasing the physical extent size, you might need to use lvresize,
 pvresize and/or pvmove so that everything fits.  For example, every
diff --git a/man/vgcreate.8.in b/man/vgcreate.8.in
index 577fee2..e62df9e 100644
--- a/man/vgcreate.8.in
+++ b/man/vgcreate.8.in
@@ -94,8 +94,10 @@ The default value is \fIunmanaged\fP.
 .BR \-s ", " \-\-physicalextentsize " " \fIPhysicalExtentSize [ \fIbBsSkKmMgGtTpPeE ]
 Sets the physical extent size on physical volumes of this volume group.
 A size suffix (k for kilobytes up to t for terabytes) is optional, megabytes
-is the default if no suffix is present.
-The default is 4 MiB and it must be at least 1 KiB and a power of 2.
+is the default if no suffix is present. The value must be at least 1 sector
+for LVM2 format (where the sector size is the largest sector size of the
+PVs currently used in the VG) or 8KiB for LVM1 format and it must be a
+power of 2. The default is 4 MiB.
 
 Once this value has been set, it is difficult to change it without recreating
 the volume group which would involve backing up and restoring data on any
diff --git a/tools/vgchange.c b/tools/vgchange.c
index f9811d2..af4b002 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -368,6 +368,12 @@ static int _vgchange_pesize(struct cmd_context *cmd, struct volume_group *vg)
 	if (!vg_set_extent_size(vg, extent_size))
 		return_0;
 
+	if (!vg_check_pv_dev_block_sizes(vg)) {
+		log_error("Failed to change physical extent size for VG %s.",
+			   vg->name);
+		return 0;
+	}
+
 	return 1;
 }
 


