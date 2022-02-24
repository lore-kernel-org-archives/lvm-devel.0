From: David Teigland <teigland@sourceware.org>
Date: Thu, 24 Feb 2022 23:22:53 +0000 (GMT)
Subject: main - devices: simplify dev_cache_get_by_devt
Message-ID: <20220224232253.4632E3858D1E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1126be8f8dbce482e82d8f98a7e7f4b7cd2cac34
Commit:        1126be8f8dbce482e82d8f98a7e7f4b7cd2cac34
Parent:        ac1f4bbbfd4c5f1387c3e0607f7d556409e7a4b4
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Feb 24 15:57:29 2022 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Feb 24 17:21:58 2022 -0600

devices: simplify dev_cache_get_by_devt

remove unused args, and no callers need or want a
repeated dev_cache_scan if there is no dev from the
lookup.
---
 lib/device/dev-cache.c | 60 +++++---------------------------------------------
 lib/device/dev-cache.h |  2 +-
 lib/label/label.c      |  6 ++---
 3 files changed, 9 insertions(+), 59 deletions(-)

diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index d3fae4948..1777628a8 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -1577,63 +1577,13 @@ struct device *dev_cache_get(struct cmd_context *cmd, const char *name, struct d
 	return dev;
 }
 
-struct device *dev_cache_get_by_devt(struct cmd_context *cmd, dev_t dev, struct dev_filter *f, int *filtered)
+struct device *dev_cache_get_by_devt(struct cmd_context *cmd, dev_t devt)
 {
-	char path[PATH_MAX];
-	const char *sysfs_dir;
-	struct stat info;
-	struct device *d = (struct device *) btree_lookup(_cache.devices, (uint32_t) dev);
-	int ret;
-
-	if (filtered)
-		*filtered = 0;
-
-	if (!d) {
-		sysfs_dir = dm_sysfs_dir();
-		if (sysfs_dir && *sysfs_dir) {
-			/* First check if dev is sysfs to avoid useless scan */
-			if (dm_snprintf(path, sizeof(path), "%sdev/block/%d:%d",
-					sysfs_dir, (int)MAJOR(dev), (int)MINOR(dev)) < 0) {
-				log_error("dm_snprintf partition failed.");
-				return NULL;
-			}
-
-			if (lstat(path, &info)) {
-				log_debug("No sysfs entry for %d:%d errno %d@%s.",
-					  (int)MAJOR(dev), (int)MINOR(dev), errno, path);
-				return NULL;
-			}
-		}
-
-		log_debug_devs("Device num not found in dev_cache repeat dev_cache_scan for %d:%d",
-				(int)MAJOR(dev), (int)MINOR(dev));
-		dev_cache_scan(cmd);
-		d = (struct device *) btree_lookup(_cache.devices, (uint32_t) dev);
-
-		if (!d)
-			return NULL;
-	}
-
-	if (d->flags & DEV_REGULAR)
-		return d;
-
-	if (!f)
-		return d;
-
-	ret = f->passes_filter(cmd, f, d, NULL);
-
-	if (ret == -EAGAIN) {
-		log_debug_devs("get device by number defer filter %s", dev_name(d));
-		d->flags |= DEV_FILTER_AFTER_SCAN;
-		ret = 1;
-	}
-
-	if (ret)
-		return d;
-
-	if (filtered)
-		*filtered = 1;
+	struct device *dev = (struct device *) btree_lookup(_cache.devices, (uint32_t) devt);
 
+	if (dev)
+		return dev;
+	log_debug_devs("No devno %d:%d in dev cache.", (int)MAJOR(devt), (int)MINOR(devt));
 	return NULL;
 }
 
diff --git a/lib/device/dev-cache.h b/lib/device/dev-cache.h
index 449bfeb75..a88e3c282 100644
--- a/lib/device/dev-cache.h
+++ b/lib/device/dev-cache.h
@@ -54,7 +54,7 @@ int dev_cache_has_scanned(void);
 int dev_cache_add_dir(const char *path);
 struct device *dev_cache_get(struct cmd_context *cmd, const char *name, struct dev_filter *f);
 
-struct device *dev_cache_get_by_devt(struct cmd_context *cmd, dev_t device, struct dev_filter *f, int *filtered);
+struct device *dev_cache_get_by_devt(struct cmd_context *cmd, dev_t devt);
 
 struct device *dev_hash_get(const char *name);
 
diff --git a/lib/label/label.c b/lib/label/label.c
index fe2bc8fec..66d6e7db7 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -1134,7 +1134,7 @@ int label_scan_vg_online(struct cmd_context *cmd, const char *vgname,
 		dm_list_iterate_items(po, &pvs_online) {
 			if (po->dev)
 				continue;
-			if (!(po->dev = dev_cache_get_by_devt(cmd, po->devno, NULL, NULL))) {
+			if (!(po->dev = dev_cache_get_by_devt(cmd, po->devno))) {
 				log_error("No device found for %d:%d PVID %s",
 					  (int)MAJOR(po->devno), (int)MINOR(po->devno), po->pvid);
 				goto bad;
@@ -1722,7 +1722,7 @@ void label_scan_invalidate_lv(struct cmd_context *cmd, struct logical_volume *lv
 	if (lv_info(cmd, lv, 0, &lvinfo, 0, 0) && lvinfo.exists) {
 		/* FIXME: Still unclear what is it supposed to find */
 		devt = MKDEV(lvinfo.major, lvinfo.minor);
-		if ((dev = dev_cache_get_by_devt(cmd, devt, NULL, NULL)))
+		if ((dev = dev_cache_get_by_devt(cmd, devt)))
 			label_scan_invalidate(dev);
 	}
 }
@@ -1742,7 +1742,7 @@ void label_scan_invalidate_lvs(struct cmd_context *cmd, struct dm_list *lvs)
 				if (dm_dev->uuid &&
 				    strncmp(dm_dev->uuid, UUID_PREFIX, sizeof(UUID_PREFIX) - 1) == 0) {
 					devt = MKDEV(dm_dev->major, dm_dev->minor);
-					if ((dev = dev_cache_get_by_devt(cmd, devt, NULL, NULL)))
+					if ((dev = dev_cache_get_by_devt(cmd, devt)))
 						label_scan_invalidate(dev);
 				}
 			/* ATM no further caching for any lvconvert command


