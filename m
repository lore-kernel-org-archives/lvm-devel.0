From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  1 Apr 2016 12:51:23 +0000 (UTC)
Subject: master - dev-cache: also add dev name for device found in sysfs only
Message-ID: <20160401125123.C6AFD60E29@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7ed5a65ee5ccb92de388977cff0dc697045ffc09
Commit:        7ed5a65ee5ccb92de388977cff0dc697045ffc09
Parent:        91d32f9d1ba1ff3bed0f47104721e97960df3878
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Apr 1 10:09:03 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Apr 1 14:48:56 2016 +0200

dev-cache: also add dev name for device found in sysfs only

For the case when we print device name associated with struct device
that was not found in /dev, but in sysfs, for example when printing
devices where LV device mismatch is found.
---
 lib/device/dev-cache.c |   18 ++++++++++++++++++
 1 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 12dcceb..27540d9 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -433,11 +433,29 @@ static struct dm_list *_get_or_add_list_by_index_key(struct dm_hash_table *idx,
 
 static struct device *_insert_sysfs_dev(dev_t devno, const char *devname)
 {
+	char path[PATH_MAX];
+	char *path_copy;
 	struct device *dev;
 
+	if (dm_snprintf(path, sizeof(path), "%s%s", _cache.dev_dir, devname) < 0) {
+		log_error("_insert_sysfs_dev: %s: dm_snprintf failed", devname);
+		return NULL;
+	}
+
 	if (!(dev = _dev_create(devno)))
 		return_NULL;
 
+	if (!(path_copy = dm_pool_strdup(_cache.mem, path))) {
+		log_error("_insert_sysfs_dev: %s: dm_pool_strdup failed", devname);
+		return NULL;
+	}
+
+	if (!_add_alias(dev, path_copy)) {
+		log_error("Couldn't add alias to dev cache.");
+		_free(dev);
+		return NULL;
+	}
+
 	if (!btree_insert(_cache.sysfs_only_devices, (uint32_t) devno, dev)) {
 		log_error("Couldn't add device to binary tree of sysfs-only devices in dev cache.");
 		_free(dev);


