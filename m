From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 30 Mar 2016 10:52:23 +0000 (UTC)
Subject: master - dev-cache: handle situation where device is referenced in sysfs, but the node is not yet in dev dir
Message-ID: <20160330105223.58BD060FFB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=91bb202ded059a4109ff4351825c77c1fcf9197b
Commit:        91bb202ded059a4109ff4351825c77c1fcf9197b
Parent:        bc0372cf9d0f7537c537b46b20703db21bc4a165
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Mar 30 10:29:35 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Mar 30 10:56:46 2016 +0200

dev-cache: handle situation where device is referenced in sysfs, but the node is not yet in dev dir

It's possible that while a device is already referenced in sysfs, the node
is not yet in /dev directory.

This may happen in some rare cases right after LVs get created - we sync
with udev (or alternatively we create /dev content ourselves) while VG
lock is held. However, dev scan is done without VG lock so devices may
already be in sysfs, but /dev may not be updated yet if we call LVM command
right after LV creation (so the fact that fs_unlock is done within VG
lock is not usable here much). This is not a problem with devtmpfs as
there's at least kernel name for device in /dev as soon as the sysfs
item exists, but we still support environments without devtmpfs or
where different directory for dev nodes is used (e.g. our test suite).

This patch covers these situations by tracking such devices in
_cache.sysfs_only_names helper hash for the vgid/lvid check to work still.

This also resolves commit 6129d2e64d14047169048775dc7081135c0fcc50
which was then reverted by commit 109b7e2095a7bc5603bf79db0224b8399463af7c
due to performance issues it may have brought (...and it didn't resolve
the problem fully anyway).
---
 WHATS_NEW              |    1 +
 lib/device/dev-cache.c |   38 +++++++++++++++++++++++++++++++++++++-
 2 files changed, 38 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 3e4152f..ca6077b 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.149 - 
 ==================================
+  Fix holder device not being found in /dev while sysfs has it during dev scan.
 
 Version 2.02.148 - 26th March 2016
 ==================================
diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index c0267a9..b3d45b3 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -40,6 +40,7 @@ struct dir_list {
 static struct {
 	struct dm_pool *mem;
 	struct dm_hash_table *names;
+	struct dm_hash_table *sysfs_only_names; /* see comments in _get_device_for_sysfs_dev_name_using_devno */
 	struct dm_hash_table *vgid_index;
 	struct dm_hash_table *lvid_index;
 	struct btree *devices;
@@ -433,6 +434,8 @@ static struct device *_get_device_for_sysfs_dev_name_using_devno(const char *dev
 	char path[PATH_MAX];
 	char buf[PATH_MAX];
 	int major, minor;
+	dev_t devno;
+	struct device *dev;
 
 	if (dm_snprintf(path, sizeof(path), "%sblock/%s/dev", dm_sysfs_dir(), devname) < 0) {
 		log_error("_get_device_for_non_dm_dev: %s: dm_snprintf failed", devname);
@@ -447,7 +450,37 @@ static struct device *_get_device_for_sysfs_dev_name_using_devno(const char *dev
 		return NULL;
 	}
 
-	return (struct device *) btree_lookup(_cache.devices, (uint32_t) MKDEV(major, minor));
+	devno = MKDEV(major, minor);
+	if (!(dev = (struct device *) btree_lookup(_cache.devices, (uint32_t) devno))) {
+		/*
+		 * If we get here, it means the device is referenced in sysfs, but it's not yet in /dev.
+		 * This may happen in some rare cases right after LVs get created - we sync with udev
+		 * (or alternatively we create /dev content ourselves) while VG lock is held. However,
+		 * dev scan is done without VG lock so devices may already be in sysfs, but /dev may
+		 * not be updated yet if we call LVM command right after LV creation. This is not a
+		 * problem with devtmpfs as there's@least kernel name for device in /dev as soon
+		 * as the sysfs item exists, but we still support environments without devtmpfs or
+		 * where different directory for dev nodes is used (e.g. our test suite). So track
+		 * such devices in _cache.sysfs_only_names hash for the vgid/lvid check to work still.
+		 */
+		if (!_cache.sysfs_only_names) {
+			if (!(_cache.sysfs_only_names = dm_hash_create(32))) {
+				log_error("Failed to create hash in dev cache for sysfs-only devices.");
+				return NULL;
+			}
+		}
+
+		if (!(dev = (struct device *) dm_hash_lookup(_cache.sysfs_only_names, devname))) {
+			if (!(dev = _dev_create(devno)))
+				return_NULL;
+			if (!dm_hash_insert(_cache.sysfs_only_names, devname, dev)) {
+				log_error("Couldn't add device to sysfs-only hash in dev cache.");
+				return NULL;
+			}
+		}
+	}
+
+	return dev;
 }
 
 #define NOT_LVM_UUID "-"
@@ -1092,6 +1125,9 @@ int dev_cache_exit(void)
 	if (_cache.names)
 		dm_hash_destroy(_cache.names);
 
+	if (_cache.sysfs_only_names)
+		dm_hash_destroy(_cache.sysfs_only_names);
+
 	if (_cache.vgid_index)
 		dm_hash_destroy(_cache.vgid_index);
 


