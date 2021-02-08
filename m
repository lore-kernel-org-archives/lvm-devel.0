From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon,  8 Feb 2021 22:45:08 +0000 (GMT)
Subject: main - dev-cache: check for nvme name while adding alias
Message-ID: <20210208224508.7714D389681C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=be9b731f440243df8fb42f6f2a506bf27de5ac64
Commit:        be9b731f440243df8fb42f6f2a506bf27de5ac64
Parent:        9b173bb931426cd1d35beb5ec5151289112b2568
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Feb 7 14:04:58 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 8 23:43:38 2021 +0100

dev-cache: check for nvme name while adding alias

Instead of repeated list retest, compare name once during add of alias.
---
 lib/device/dev-cache.c |  5 +++++
 lib/device/dev-type.c  | 14 +-------------
 2 files changed, 6 insertions(+), 13 deletions(-)

diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 8082efac4..a93600965 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -337,6 +337,11 @@ static int _add_alias(struct device *dev, const char *path)
 			return 1;
 	}
 
+	if (!strncmp(path, "/dev/nvme", 9)) {
+		log_debug("Found nvme device %s", dev_name(dev));
+		dev->flags |= DEV_IS_NVME;
+	}
+
 	sl->str = path;
 
 	if (!dm_list_empty(&dev->aliases)) {
diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index 379afa89c..8eacbf096 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -78,19 +78,7 @@ int dev_is_pmem(struct device *dev)
 
 int dev_is_nvme(struct dev_types *dt, struct device *dev)
 {
-	struct dm_str_list *strl;
-
-	if (dev->flags & DEV_IS_NVME)
-		return 1;
-
-	dm_list_iterate_items(strl, &dev->aliases) {
-		if (!strncmp(strl->str, "/dev/nvme", 9)) {
-			log_debug("Found nvme device %s", dev_name(dev));
-			dev->flags |= DEV_IS_NVME;
-			return 1;
-		}
-	}
-	return 0;
+	return (dev->flags & DEV_IS_NVME) ? 1 : 0;
 }
 
 int dev_is_lv(struct device *dev)


