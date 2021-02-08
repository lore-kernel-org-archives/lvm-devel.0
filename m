From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon,  8 Feb 2021 22:45:10 +0000 (GMT)
Subject: main - dev-type: dev_is_pmem reuses topology read code
Message-ID: <20210208224510.BBFE6384A02A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e429e69b6593fa688727fb632d7050f05cd27317
Commit:        e429e69b6593fa688727fb632d7050f05cd27317
Parent:        2c597c73a837e9d259ee620f167b08ebf1b14a9e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Feb 7 15:03:13 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 8 23:43:38 2021 +0100

dev-type: dev_is_pmem reuses topology read code

---
 lib/device/dev-type.c   | 45 ++++++++++++---------------------------------
 lib/device/dev-type.h   |  2 +-
 lib/metadata/metadata.c |  8 ++++----
 3 files changed, 17 insertions(+), 38 deletions(-)

diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index 8eacbf096..dca81d8d1 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -35,39 +35,6 @@
 #include <libgen.h>
 #include <ctype.h>
 
-/*
- * dev is pmem if /sys/dev/block/<major>:<minor>/queue/dax is 1
- */
-
-int dev_is_pmem(struct device *dev)
-{
-	FILE *fp;
-	char path[PATH_MAX];
-	int is_pmem = 0;
-
-	if (dm_snprintf(path, sizeof(path), "%sdev/block/%d:%d/queue/dax",
-			dm_sysfs_dir(),
-			(int) MAJOR(dev->dev),
-			(int) MINOR(dev->dev)) < 0) {
-		log_warn("Sysfs path for %s dax is too long.", dev_name(dev));
-		return 0;
-	}
-
-	if (!(fp = fopen(path, "r")))
-		return 0;
-
-	if (fscanf(fp, "%d", &is_pmem) != 1)
-		log_warn("Failed to parse DAX %s.", path);
-
-	if (is_pmem)
-		log_debug("%s is pmem", dev_name(dev));
-
-	if (fclose(fp))
-		log_sys_debug("fclose", path);
-
-	return is_pmem ? 1 : 0;
-}
-
 /*
  * An nvme device has major number 259 (BLKEXT), minor number <minor>,
  * and reading /sys/dev/block/259:<minor>/device/dev shows a character
@@ -1078,6 +1045,13 @@ int dev_is_rotational(struct dev_types *dt, struct device *dev)
 {
 	return (int) _dev_topology_attribute(dt, "queue/rotational", dev, 1UL);
 }
+
+/* dev is pmem if /sys/dev/block/<major>:<minor>/queue/dax is 1 */
+int dev_is_pmem(struct dev_types *dt, struct device *dev)
+{
+	return (int) _dev_topology_attribute(dt, "queue/dax", dev, 0UL);
+}
+
 #else
 
 int dev_get_primary_dev(struct dev_types *dt, struct device *dev, dev_t *result)
@@ -1114,6 +1088,11 @@ int dev_is_rotational(struct dev_types *dt, struct device *dev)
 {
 	return 1;
 }
+
+int dev_is_pmem(struct dev_types *dt, struct device *dev)
+{
+	return 0;
+}
 #endif
 
 #ifdef UDEV_SYNC_SUPPORT
diff --git a/lib/device/dev-type.h b/lib/device/dev-type.h
index 8b94b7997..f96b67ca3 100644
--- a/lib/device/dev-type.h
+++ b/lib/device/dev-type.h
@@ -93,7 +93,7 @@ unsigned long dev_discard_granularity(struct dev_types *dt, struct device *dev);
 
 int dev_is_rotational(struct dev_types *dt, struct device *dev);
 
-int dev_is_pmem(struct device *dev);
+int dev_is_pmem(struct dev_types *dt, struct device *dev);
 
 int dev_is_nvme(struct dev_types *dt, struct device *dev);
 
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index d83cf21a6..692094ec8 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -4436,11 +4436,11 @@ int lv_on_pmem(struct logical_volume *lv)
 		for (s = 0; s < seg->area_count; s++) {
 			pv = seg_pv(seg, s);
 
-			if (dev_is_pmem(pv->dev)) {
-				log_debug("LV %s dev %s is pmem.", lv->name, dev_name(pv->dev));
+			if (dev_is_pmem(lv->vg->cmd->dev_types, pv->dev)) {
+				log_debug("LV %s dev %s is pmem.", display_lvname(lv), dev_name(pv->dev));
 				pmem_devs++;
 			} else {
-				log_debug("LV %s dev %s not pmem.", lv->name, dev_name(pv->dev));
+				log_debug("LV %s dev %s not pmem.", display_lvname(lv), dev_name(pv->dev));
 				other_devs++;
 			}
 		}
@@ -4452,7 +4452,7 @@ int lv_on_pmem(struct logical_volume *lv)
 	}
 
 	if (pmem_devs) {
-		log_debug("LV %s on pmem", lv->name);
+		log_debug("LV %s on pmem", display_lvname(lv));
 		return 1;
 	}
 


