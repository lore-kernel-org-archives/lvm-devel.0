From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 21 Mar 2016 12:26:20 +0000 (UTC)
Subject: master - dev: detect mismatch between devices used and devices assumed for an LV
Message-ID: <20160321122620.2CDBA60D1B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=03b0a786403ad1762bfbbe354756a9b83ee6629c
Commit:        03b0a786403ad1762bfbbe354756a9b83ee6629c
Parent:        65d9f742f8e45caaa530e1eaf9f18bfd689af6f3
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Mar 16 14:01:26 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Mar 21 11:40:40 2016 +0100

dev: detect mismatch between devices used and devices assumed for an LV

It's possible for an LVM LV to use a device during activation which
then differs from device which LVM assumes based on metadata later on.

For example, such device mismatch can occur if LVM doesn't have
complete view of devices during activation or if filters are
misbehaving or they're incorrectly set during activation.

This patch adds code that can detect this mismatch by creating
VG UUID and LV UUID index while scanning devices for device cache.

The VG UUID index maps VG UUID to a device list. Each device in the
list has a device layered above as a holder which is an LVM LV device
and for which we know the VG UUID (and similarly for LV UUID index).

We can acquire VG and LV UUID by reading /sys/block/<dm_dev_name>/dm/uuid.
So these indices represent the actual state of PV device use in
the system by LVs and then we compare that to what LVM assumes
based on metadata.

For example:

[0] fedora/~ # lsblk /dev/sdq /dev/sdr /dev/sds /dev/sdt
NAME         MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
sdq           65:0    0  104M  0 disk
|-vg-lvol0   253:2    0  200M  0 lvm
`-mpath_dev1 253:3    0  104M  0 mpath
sdr           65:16   0  104M  0 disk
`-mpath_dev1 253:3    0  104M  0 mpath
sds           65:32   0  104M  0 disk
|-vg-lvol0   253:2    0  200M  0 lvm
`-mpath_dev2 253:4    0  104M  0 mpath
sdt           65:48   0  104M  0 disk
`-mpath_dev2 253:4    0  104M  0 mpath

In this case the vg-lvol0 is mapped onto sdq and sds becauset this is
what was available and seen during activation. Then later on, sdr and
sdt appeared and mpath devices were created out of sdq+sdr (mpath_dev1)
and sds+sdt (mpath_dev2). Now, LVM assumes (correctly) that mpath_dev1
and mpath_dev2 are the PVs that should be used, not the mpath
components (sdq/sdr, sds/sdt).

[0] fedora/~ # pvs
  Found duplicate PV xSUix1GJ2SK82ACFuKzFLAQi8xMfFxnO: using /dev/mapper/mpath_dev1 not /dev/sdq
  Using duplicate PV /dev/mapper/mpath_dev1 from subsystem DM, replacing /dev/sdq
  Found duplicate PV MvHyMVabtSqr33AbkUrobq1LjP8oiTRm: using /dev/mapper/mpath_dev2 not /dev/sds
  Using duplicate PV /dev/mapper/mpath_dev2 from subsystem DM, ignoring /dev/sds
  WARNING: Device mismatch detected for vg/lvol0 which is accessing /dev/sdq, /dev/sds instead of /dev/mapper/mpath_dev1, /dev/mapper/mpath_dev2.
  PV                     VG     Fmt  Attr PSize   PFree
  /dev/mapper/mpath_dev1 vg     lvm2 a--  100.00m      0
  /dev/mapper/mpath_dev2 vg     lvm2 a--  100.00m      0
---
 WHATS_NEW               |    1 +
 lib/device/dev-cache.c  |  257 ++++++++++++++++++++++++++++++++++++++++++++++-
 lib/device/dev-cache.h  |    3 +
 lib/device/device.h     |    7 +-
 lib/metadata/metadata.c |  119 ++++++++++++++++++++++
 5 files changed, 385 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index d096a52..0f81021 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.148 - 
 ==================================
+  Detect and warn about mismatch between devices used and assumed for an LV.
 
 Version 2.02.147 - 19th March 2016
 ==================================
diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 47ae140..490cec3 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -17,6 +17,8 @@
 #include "btree.h"
 #include "config.h"
 #include "toolcontext.h"
+#include "dm-ioctl.h" /* for DM_UUID_LEN */
+#include "lvm-string.h" /* for LVM's UUID_PREFIX */
 
 #ifdef UDEV_SYNC_SUPPORT
 #include <libudev.h>
@@ -38,6 +40,8 @@ struct dir_list {
 static struct {
 	struct dm_pool *mem;
 	struct dm_hash_table *names;
+	struct dm_hash_table *vgid_index;
+	struct dm_hash_table *lvid_index;
 	struct btree *devices;
 	struct dm_regex *preferred_names_matcher;
 	const char *dev_dir;
@@ -358,6 +362,229 @@ static int _add_alias(struct device *dev, const char *path)
 	return 1;
 }
 
+static int _get_sysfs_value(const char *path, char *buf, size_t buf_size)
+{
+	FILE *fp;
+
+	if (!(fp = fopen(path, "r"))) {
+		log_sys_error("fopen", path);
+		return 0;
+	}
+
+	if (!fgets(buf, buf_size, fp)) {
+		log_sys_error("fgets", path);
+		if (fclose(fp))
+			log_sys_error("fclose", path);
+		return 0;
+	}
+
+	buf[strlen(buf) - 1] = '\0';
+
+	if (fclose(fp))
+		log_sys_error("fclose", path);
+
+	return 1;
+}
+
+static int _get_dm_uuid_from_sysfs(char *buf, size_t buf_size, int major, int minor)
+{
+	char path[PATH_MAX];
+
+	if (dm_snprintf(path, sizeof(path), "%sdev/block/%d:%d/dm/uuid", dm_sysfs_dir(), major, minor) < 0) {
+		log_error("%d:%d: dm_snprintf failed for path to sysfs dm directory.", major, minor);
+		return 0;
+	}
+
+	return _get_sysfs_value(path, buf, buf_size);
+}
+
+static struct dm_list *_get_or_add_list_by_index_key(struct dm_hash_table *idx, const char *key)
+{
+	struct dm_list *list;
+
+	if ((list = dm_hash_lookup(idx, key)))
+		return list;
+
+	if (!(list = _zalloc(sizeof(*list)))) {
+		log_error("%s: failed to allocate device list for device cache index.", key);
+		return NULL;
+	}
+
+	dm_list_init(list);
+
+	if (!dm_hash_insert(idx, key, list)) {
+		log_error("%s: failed to insert device list to device cache index.", key);
+		return NULL;
+	}
+
+	return list;
+}
+
+static struct device *_get_device_for_sysfs_dev_name_using_devno(const char *dev_name)
+{
+	char path[PATH_MAX];
+	char buf[PATH_MAX];
+	int major, minor;
+
+	if (dm_snprintf(path, sizeof(path), "%sblock/%s/dev", dm_sysfs_dir(), dev_name) < 0) {
+		log_error("_get_device_for_non_dm_dev: %s: dm_snprintf failed", dev_name);
+		return NULL;
+	}
+
+	if (!_get_sysfs_value(path, buf, sizeof(buf)))
+		return_NULL;
+
+	if (sscanf(buf, "%d:%d", &major, &minor) != 2) {
+		log_error("_get_device_for_non_dm_dev: %s: failed to get major and minor number", dev_name);
+		return NULL;
+	}
+
+	return (struct device *) btree_lookup(_cache.devices, (uint32_t) MKDEV(major, minor));
+}
+
+#define NOT_LVM_UUID "-"
+
+static int _get_vgid_and_lvid_for_dev(struct device *dev)
+{
+	size_t lvm_prefix_len = strlen(UUID_PREFIX);
+	char uuid[DM_UUID_LEN];
+
+	if (!_get_dm_uuid_from_sysfs(uuid, sizeof(uuid), (int) MAJOR(dev->dev), (int) MINOR(dev->dev)))
+		return_0;
+
+	if (strlen(uuid) == (2 * ID_LEN + 4) &&
+	    !strncmp(uuid, UUID_PREFIX, lvm_prefix_len)) {
+		/* Separate VGID and LVID part from DM UUID. */
+		if (!(dev->vgid = dm_pool_strndup(_cache.mem, uuid + lvm_prefix_len, ID_LEN)) ||
+		    !(dev->lvid = dm_pool_strndup(_cache.mem, uuid + lvm_prefix_len + ID_LEN, ID_LEN)))
+			return_0;
+	} else
+		dev->vgid = dev->lvid = NOT_LVM_UUID;
+
+	return 1;
+}
+
+static int _index_dev_by_vgid_and_lvid(struct device *dev)
+{
+	const char *devname = dev_name(dev);
+	char devpath[PATH_MAX];
+	char path[PATH_MAX];
+	DIR *d;
+	struct dirent *dirent;
+	struct device *holder_dev;
+	struct dm_list *vgid_list, *lvid_list;
+	struct device_list *dl_vgid, *dl_lvid;
+	int r = 0;
+
+	/* Get holders for device. */
+	if (dm_snprintf(path, sizeof(path), "%sdev/block/%d:%d/holders/", dm_sysfs_dir(), (int) MAJOR(dev->dev), (int) MINOR(dev->dev)) < 0) {
+		log_error("%s: dm_snprintf failed for path to holders directory.", devname);
+		return 0;
+	}
+
+	if (!(d = opendir(path))) {
+		if (errno == ENOENT) {
+			log_debug("%s: path does not exist, skipping", path);
+			return 1;
+		}
+		log_sys_error("opendir", path);
+		return 0;
+	}
+
+	/* Iterate over device's holders and look for LVs. */
+	while ((dirent = readdir(d))) {
+		if (!strcmp(".", dirent->d_name) ||
+		    !strcmp("..", dirent->d_name))
+			continue;
+
+		if (dm_snprintf(devpath, sizeof(devpath), "%s%s", _cache.dev_dir, dirent->d_name) == -1) {
+			log_error("%s: dm_snprintf failed for holder %s device path.", devname, dirent->d_name);
+			goto out;
+		}
+
+		if (!(holder_dev = (struct device *) dm_hash_lookup(_cache.names, devpath))) {
+			/*
+			 * Cope with situation where canonical /<dev_dir>/<dirent->d_name>
+			 * does not exist, but some other node name or symlink exists in
+			 * non-standard environments - someone renaming the nodes or using
+			 * mknod with different dev names than actual kernel names.
+			 * This looks up struct device by major:minor pair which we get
+			 * by looking at /sys/block/<dirent->d_name>/dev sysfs attribute.
+			 */
+			if (!(holder_dev = _get_device_for_sysfs_dev_name_using_devno(dirent->d_name))) {
+				log_error("%s: failed to find associated device structure for holder %s.", devname, devpath);
+				goto out;
+			}
+		}
+
+		/* We're only interested in a holder which is a DM device. */
+		if (!dm_is_dm_major(MAJOR(holder_dev->dev)))
+			continue;
+
+		/*
+		 * And if it's a DM device, we're only interested in a holder which is an LVM device.
+		 * Get the VG UUID and LV UUID if we don't have that already.
+		 */
+		if (!holder_dev->vgid && !_get_vgid_and_lvid_for_dev(holder_dev))
+			goto_out;
+
+		if (*holder_dev->vgid == *NOT_LVM_UUID)
+			continue;
+
+		/*
+		 * Do not add internal LV devices to index.
+		 * If a device is internal, the holder has the same VG UUID as the device.
+		 */
+		if (dm_is_dm_major(MAJOR(dev->dev))) {
+			if (!dev->vgid && !_get_vgid_and_lvid_for_dev(dev))
+				goto_out;
+
+			if (*dev->vgid != *NOT_LVM_UUID && !strcmp(holder_dev->vgid, dev->vgid))
+				continue;
+		}
+
+		if (!(vgid_list = _get_or_add_list_by_index_key(_cache.vgid_index, holder_dev->vgid)) ||
+		    !(lvid_list = _get_or_add_list_by_index_key(_cache.lvid_index, holder_dev->lvid)))
+			goto_out;
+
+		/* Create dev list items for the holder device. */
+		if (!(dl_vgid = _zalloc(sizeof(*dl_vgid))) ||
+		    !(dl_lvid = _zalloc(sizeof(*dl_lvid)))) {
+			log_error("%s: failed to allocate dev list item.", devname);
+			goto out;
+		}
+
+		dl_vgid->dev = dl_lvid->dev = dev;
+
+		/* Add dev list item to VGID device list if it's not there already. */
+		if (!(dev->flags & DEV_USED_FOR_LV))
+			dm_list_add(vgid_list, &dl_vgid->list);
+
+		/* Add dev list item to LVID device list. */
+		dm_list_add(lvid_list, &dl_lvid->list);
+
+		/* Mark device as used == also indexed in dev cache by VGID and LVID. */
+		dev->flags |= DEV_USED_FOR_LV;
+	}
+
+	r = 1;
+out:
+	if (closedir(d))
+		log_sys_error("closedir", path);
+
+	return r;
+}
+
+struct dm_list *dev_cache_get_dev_list_for_vgid(const char *vgid)
+{
+	return dm_hash_lookup(_cache.vgid_index, vgid);
+}
+
+struct dm_list *dev_cache_get_dev_list_for_lvid(const char *lvid)
+{
+	return dm_hash_lookup(_cache.lvid_index, lvid);
+}
+
 /*
  * Either creates a new dev, or adds an alias to
  * an existing dev.
@@ -570,6 +797,24 @@ bad:
 	return 0;
 }
 
+static int _add_devs_to_index(void)
+{
+	struct btree_iter *iter = btree_first(_cache.devices);
+	struct device *dev;
+	int r = 1;
+
+	while (iter) {
+		dev = btree_get_data(iter);
+
+		if (!_index_dev_by_vgid_and_lvid(dev))
+			r = 0;
+
+		iter = btree_next(iter);
+	}
+
+	return r;
+}
+
 static void _insert_dirs(struct dm_list *dirs)
 {
 	struct dir_list *dl;
@@ -590,6 +835,8 @@ static void _insert_dirs(struct dm_list *dirs)
 			log_debug_devs("%s: Failed to insert devices to "
 				       "device cache fully", dl->dir);
 	}
+
+	(void) _add_devs_to_index();
 }
 
 #else	/* UDEV_SYNC_SUPPORT */
@@ -751,7 +998,9 @@ int dev_cache_init(struct cmd_context *cmd)
 	if (!(_cache.mem = dm_pool_create("dev_cache", 10 * 1024)))
 		return_0;
 
-	if (!(_cache.names = dm_hash_create(128))) {
+	if (!(_cache.names = dm_hash_create(128)) ||
+	    !(_cache.vgid_index = dm_hash_create(32)) ||
+	    !(_cache.lvid_index = dm_hash_create(32))) {
 		dm_pool_destroy(_cache.mem);
 		_cache.mem = 0;
 		return_0;
@@ -825,6 +1074,12 @@ int dev_cache_exit(void)
 	if (_cache.names)
 		dm_hash_destroy(_cache.names);
 
+	if (_cache.vgid_index)
+		dm_hash_destroy(_cache.vgid_index);
+
+	if (_cache.lvid_index)
+		dm_hash_destroy(_cache.lvid_index);
+
 	memset(&_cache, 0, sizeof(_cache));
 
 	return (!num_open);
diff --git a/lib/device/dev-cache.h b/lib/device/dev-cache.h
index 05911d4..d21f521 100644
--- a/lib/device/dev-cache.h
+++ b/lib/device/dev-cache.h
@@ -31,6 +31,9 @@ struct dev_filter {
 	unsigned use_count;
 };
 
+struct dm_list *dev_cache_get_dev_list_for_vgid(const char *vgid);
+struct dm_list *dev_cache_get_dev_list_for_lvid(const char *lvid);
+
 /*
  * The global device cache.
  */
diff --git a/lib/device/device.h b/lib/device/device.h
index fc5a5b9..aaa009f 100644
--- a/lib/device/device.h
+++ b/lib/device/device.h
@@ -28,6 +28,8 @@
 #define DEV_O_DIRECT		0x00000020	/* Use O_DIRECT */
 #define DEV_O_DIRECT_TESTED	0x00000040	/* DEV_O_DIRECT is reliable */
 #define DEV_OPEN_FAILURE	0x00000080	/* Has last open failed? */
+#define DEV_USED_FOR_LV		0x00000100	/* Is device used for an LV */
+#define DEV_ASSUMED_FOR_LV	0x00000200	/* Is device assumed for an LV */
 
 /*
  * Support for external device info.
@@ -69,7 +71,10 @@ struct device {
 	struct dm_list open_list;
 	struct dev_ext ext;
 
-	char pvid[ID_LEN + 1];
+	const char *vgid; /* if device is an LV */
+	const char *lvid; /* if device is an LV */
+
+	char pvid[ID_LEN + 1]; /* if device is a PV */
 	char _padding[7];
 };
 
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index d04adb6..86fb7cd 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -4580,6 +4580,124 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 	return correct_vg;
 }
 
+#define DEV_LIST_DELIM ", "
+
+static int _check_devs_used_correspond_with_lv(struct dm_list *list, struct logical_volume *lv)
+{
+	struct dm_pool *mem = lv->vg->vgmem;
+	struct device_list *dl;
+	int found_inconsistent = 0;
+	struct device *dev;
+	struct lv_segment *seg;
+	uint32_t s;
+	char *used_devnames = NULL, *assumed_devnames = NULL;
+
+	if (!(list = dev_cache_get_dev_list_for_lvid(lv->lvid.s + ID_LEN)))
+		return 1;
+
+	dm_list_iterate_items(dl, list) {
+		dev = dl->dev;
+		if (!(dev->flags & DEV_ASSUMED_FOR_LV)) {
+			if (!found_inconsistent) {
+				dm_pool_begin_object(mem, 32);
+				found_inconsistent = 1;
+			} else
+				dm_pool_grow_object(mem, DEV_LIST_DELIM, sizeof(DEV_LIST_DELIM) - 1);
+			if (!dm_pool_grow_object(mem, dev_name(dev), 0))
+				goto_bad;
+		}
+	}
+
+	if (!found_inconsistent)
+		return 1;
+
+	dm_pool_grow_object(mem, "\0", 1);
+	used_devnames = dm_pool_end_object(mem);
+
+	found_inconsistent = 0;
+	dm_list_iterate_items(seg, &lv->segments) {
+		for (s = 0; s < seg->area_count; s++) {
+			if (seg_type(seg, s) == AREA_PV) {
+				if (!(dev = seg_dev(seg, s))) {
+					log_error("Couldn't find device for segment belonging to "
+						  "%s/%s while checking used and assumed devices.",
+						  lv->vg->name, lv->name);
+					goto bad;
+				}
+				if (!(dev->flags & DEV_USED_FOR_LV)) {
+					if (!found_inconsistent) {
+						dm_pool_begin_object(mem, 32);
+						found_inconsistent = 1;
+					} else {
+						dm_pool_grow_object(mem, DEV_LIST_DELIM, sizeof(DEV_LIST_DELIM) - 1);
+					}
+					if (!dm_pool_grow_object(mem, dev_name(dev), 0))
+						goto bad;
+				}
+			}
+		}
+	}
+
+	if (found_inconsistent) {
+		dm_pool_grow_object(mem, "\0", 1);
+		assumed_devnames = dm_pool_end_object(mem);
+	}
+
+	log_warn("WARNING: Device mismatch detected for %s/%s which is accessing %s instead of %s.",
+		 lv->vg->name, lv->name, used_devnames, assumed_devnames);
+
+	/* This also frees assumed_devnames. */
+	dm_pool_free(mem, (void *) used_devnames);
+	return 1;
+bad:
+	if (found_inconsistent)
+		dm_pool_abandon_object(mem);
+	return 0;
+}
+
+static int _check_devs_used_correspond_with_vg(struct volume_group *vg)
+{
+	char vgid[ID_LEN + 1];
+	struct pv_list *pvl;
+	struct lv_list *lvl;
+	struct dm_list *list;
+	struct device_list *dl;
+	int found_inconsistent = 0;
+
+	if (is_orphan_vg(vg->name))
+		return 1;
+
+	strncpy(vgid, (const char *) vg->id.uuid, sizeof(vgid));
+	vgid[ID_LEN] = '\0';
+
+	/* Mark all PVs in VG as used. */
+	dm_list_iterate_items(pvl, &vg->pvs) {
+		if (is_missing_pv(pvl->pv))
+			continue;
+		pvl->pv->dev->flags |= DEV_ASSUMED_FOR_LV;
+	}
+
+	if (!(list = dev_cache_get_dev_list_for_vgid(vgid)))
+		return 1;
+
+	dm_list_iterate_items(dl, list) {
+		if (!(dl->dev->flags & DEV_OPEN_FAILURE) &&
+		    !(dl->dev->flags & DEV_ASSUMED_FOR_LV)) {
+			found_inconsistent = 1;
+			break;
+		}
+	}
+
+	if (found_inconsistent) {
+		dm_list_iterate_items(lvl, &vg->lvs) {
+			if (!_check_devs_used_correspond_with_lv(list, lvl->lv))
+				return_0;
+		}
+	}
+
+	return 1;
+}
+
 struct volume_group *vg_read_internal(struct cmd_context *cmd, const char *vgname,
 				      const char *vgid, uint32_t warn_flags, int *consistent)
 {
@@ -4624,6 +4742,7 @@ struct volume_group *vg_read_internal(struct cmd_context *cmd, const char *vgnam
 		}
 	}
 
+	(void) _check_devs_used_correspond_with_vg(vg);
 out:
 	if (!*consistent && (warn_flags & WARN_INCONSISTENT)) {
 		if (is_orphan_vg(vgname))


