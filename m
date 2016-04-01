From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  1 Apr 2016 12:51:25 +0000 (UTC)
Subject: master - dev-cache: iterate devices in sysfs for VGID/LVID index if obtain_device_list_from_udev=0
Message-ID: <20160401125125.DCAF360E29@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=15d1824facce1ac38c2669b17c8c0965b8c18f3e
Commit:        15d1824facce1ac38c2669b17c8c0965b8c18f3e
Parent:        7ed5a65ee5ccb92de388977cff0dc697045ffc09
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Apr 1 11:34:09 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Apr 1 14:49:39 2016 +0200

dev-cache: iterate devices in sysfs for VGID/LVID index if obtain_device_list_from_udev=0

If obtain_device_list_from_udev=0, LVM can make use of persistent .cache
file. This cache file contains only devices which underwent filters in
previous LVM command run. But we need to iterate over all block devices
to create the VGID/LVID index completely for the device mismatch check
to be complete as well.

This patch iterates over block devices found in sysfs to generate the
VGID/LVID index in dev cache if obtain_device_list_from_udev=0
(if obtain_device_list_from_udev=1, we always read complete list of
block devices from udev and we ignore .cache file so we don't need
to look in sysfs for the complete list).
---
 lib/device/dev-cache.c |   82 +++++++++++++++++++++++++++++++++++++++++++-----
 1 files changed, 74 insertions(+), 8 deletions(-)

diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 27540d9..84bd85b 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -684,14 +684,15 @@ static int _insert_dev(const char *path, dev_t d)
 	}
 
 	/* is this device already registered ? */
-	if (!(dev = (struct device *) btree_lookup(_cache.devices,
-						   (uint32_t) d))) {
-		/* create new device */
-		if (loopfile) {
-			if (!(dev = dev_create_file(path, NULL, NULL, 0)))
+	if (!(dev = (struct device *) btree_lookup(_cache.devices, (uint32_t) d))) {
+		if (!(dev = (struct device *) btree_lookup(_cache.sysfs_only_devices, (uint32_t) d))) {
+			/* create new device */
+			if (loopfile) {
+				if (!(dev = dev_create_file(path, NULL, NULL, 0)))
+					return_0;
+			} else if (!(dev = _dev_create(d)))
 				return_0;
-		} else if (!(dev = _dev_create(d)))
-			return_0;
+		}
 
 		if (!(btree_insert(_cache.devices, (uint32_t) d, dev))) {
 			log_error("Couldn't insert device into binary tree.");
@@ -799,7 +800,7 @@ static int _insert_file(const char *path)
 	return 1;
 }
 
-int dev_cache_index_devs(void)
+static int _dev_cache_iterate_devs_for_index(void)
 {
 	struct btree_iter *iter = btree_first(_cache.devices);
 	struct device *dev;
@@ -817,6 +818,71 @@ int dev_cache_index_devs(void)
 	return r;
 }
 
+static int _dev_cache_iterate_sysfs_for_index(void)
+{
+	char path[PATH_MAX];
+	char devname[PATH_MAX];
+	DIR *d;
+	struct dirent *dirent;
+	int major, minor;
+	dev_t devno;
+	struct device *dev;
+	int partial_failure = 0;
+	int r = 0;
+
+	if (dm_snprintf(path, sizeof(path), "%sdev/block", dm_sysfs_dir()) < 0) {
+		log_error("_dev_cache_iterate_sysfs_for_index: dm_snprintf failed.");
+		return 0;
+	}
+
+	if (!(d = opendir(path))) {
+		log_sys_error("opendir", path);
+		return 0;
+	}
+
+	while ((dirent = readdir(d))) {
+		if (!strcmp(".", dirent->d_name) ||
+		    !strcmp("..", dirent->d_name))
+			continue;
+
+		if (sscanf(dirent->d_name, "%d:%d", &major, &minor) != 2) {
+			log_error("_dev_cache_iterate_sysfs_for_index: %s: failed "
+				  "to get major and minor number", dirent->d_name);
+			partial_failure = 1;
+			continue;
+		}
+
+		devno = MKDEV(major, minor);
+		if (!(dev = (struct device *) btree_lookup(_cache.devices, (uint32_t) devno)) &&
+		    !(dev = (struct device *) btree_lookup(_cache.sysfs_only_devices, (uint32_t) devno))) {
+			if (!dm_device_get_name(major, minor, 1, devname, sizeof(devname)) ||
+			    !(dev = _insert_sysfs_dev(devno, devname))) {
+				partial_failure = 1;
+				continue;
+			}
+		}
+
+		if (!_index_dev_by_vgid_and_lvid(dev))
+			partial_failure = 1;
+	}
+
+	r = !partial_failure;
+
+	if (closedir(d))
+		log_sys_error("closedir", path);
+
+	return r;
+}
+
+int dev_cache_index_devs(void)
+{
+	int with_udev = obtain_device_list_from_udev() &&
+			udev_get_library_context();
+
+	return with_udev ? _dev_cache_iterate_devs_for_index()
+			 : _dev_cache_iterate_sysfs_for_index();
+}
+
 #ifdef UDEV_SYNC_SUPPORT
 
 static int _device_in_udev_db(const dev_t d)


