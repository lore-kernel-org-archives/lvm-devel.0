From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  1 Apr 2016 12:51:21 +0000 (UTC)
Subject: master - refactor: dev-cache: move code adding sysfs-only device into separate fn
Message-ID: <20160401125121.B486060E50@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=91d32f9d1ba1ff3bed0f47104721e97960df3878
Commit:        91d32f9d1ba1ff3bed0f47104721e97960df3878
Parent:        0e774d5ae77fb67c7a015d9bb8e4c289dd8fa2e4
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Apr 1 09:41:41 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Apr 1 11:47:06 2016 +0200

refactor: dev-cache: move code adding sysfs-only device into separate fn

---
 lib/device/dev-cache.c |   31 +++++++++++++++++++++----------
 1 files changed, 21 insertions(+), 10 deletions(-)

diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index d99352b..12dcceb 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -431,6 +431,22 @@ static struct dm_list *_get_or_add_list_by_index_key(struct dm_hash_table *idx,
 	return list;
 }
 
+static struct device *_insert_sysfs_dev(dev_t devno, const char *devname)
+{
+	struct device *dev;
+
+	if (!(dev = _dev_create(devno)))
+		return_NULL;
+
+	if (!btree_insert(_cache.sysfs_only_devices, (uint32_t) devno, dev)) {
+		log_error("Couldn't add device to binary tree of sysfs-only devices in dev cache.");
+		_free(dev);
+		return NULL;
+	}
+
+	return dev;
+}
+
 static struct device *_get_device_for_sysfs_dev_name_using_devno(const char *devname)
 {
 	char path[PATH_MAX];
@@ -440,7 +456,7 @@ static struct device *_get_device_for_sysfs_dev_name_using_devno(const char *dev
 	struct device *dev;
 
 	if (dm_snprintf(path, sizeof(path), "%sblock/%s/dev", dm_sysfs_dir(), devname) < 0) {
-		log_error("_get_device_for_non_dm_dev: %s: dm_snprintf failed", devname);
+		log_error("_get_device_for_sysfs_dev_name_using_devno: %s: dm_snprintf failed", devname);
 		return NULL;
 	}
 
@@ -448,7 +464,7 @@ static struct device *_get_device_for_sysfs_dev_name_using_devno(const char *dev
 		return_NULL;
 
 	if (sscanf(buf, "%d:%d", &major, &minor) != 2) {
-		log_error("_get_device_for_non_dm_dev: %s: failed to get major and minor number", devname);
+		log_error("_get_device_for_sysfs_dev_name_using_devno: %s: failed to get major and minor number", devname);
 		return NULL;
 	}
 
@@ -465,14 +481,9 @@ static struct device *_get_device_for_sysfs_dev_name_using_devno(const char *dev
 		 * where different directory for dev nodes is used (e.g. our test suite). So track
 		 * such devices in _cache.sysfs_only_devices hash for the vgid/lvid check to work still.
 		 */
-		if (!(dev = (struct device *) btree_lookup(_cache.sysfs_only_devices, (uint32_t) devno))) {
-			if (!(dev = _dev_create(devno)))
-				return_NULL;
-			if (!btree_insert(_cache.sysfs_only_devices, (uint32_t) devno, dev)) {
-				log_error("Couldn't add device to binary tree of sysfs-only devices in dev cache.");
-				return NULL;
-			}
-		}
+		if (!(dev = (struct device *) btree_lookup(_cache.sysfs_only_devices, (uint32_t) devno)) &&
+		    !(dev = _insert_sysfs_dev(devno, devname)))
+			return_NULL;
 	}
 
 	return dev;


