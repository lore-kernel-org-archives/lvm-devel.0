From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  2 Mar 2021 21:58:41 +0000 (GMT)
Subject: main - cleanup: simplify condition
Message-ID: <20210302215841.A28543851C35@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1042cd9a612e1f71fda15dac62948707acee326e
Commit:        1042cd9a612e1f71fda15dac62948707acee326e
Parent:        eb3dcc72eb0e1f3922dafcc4d018db70aabc3bc9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Feb 27 21:18:48 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 2 22:57:35 2021 +0100

cleanup: simplify condition

---
 lib/device/dev-cache.c | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index bbf6ce833..5632456bf 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -1563,9 +1563,6 @@ struct device *dev_cache_get_by_devt(struct cmd_context *cmd, dev_t dev, struct
 	if (filtered)
 		*filtered = 0;
 
-	if (d && (d->flags & DEV_REGULAR))
-		return d;
-
 	if (!d) {
 		sysfs_dir = dm_sysfs_dir();
 		if (sysfs_dir && *sysfs_dir) {
@@ -1587,10 +1584,10 @@ struct device *dev_cache_get_by_devt(struct cmd_context *cmd, dev_t dev, struct
 				(int)MAJOR(dev), (int)MINOR(dev));
 		dev_cache_scan();
 		d = (struct device *) btree_lookup(_cache.devices, (uint32_t) dev);
-	}
 
-	if (!d)
-		return NULL;
+		if (!d)
+			return NULL;
+	}
 
 	if (d->flags & DEV_REGULAR)
 		return d;
@@ -1611,6 +1608,7 @@ struct device *dev_cache_get_by_devt(struct cmd_context *cmd, dev_t dev, struct
 
 	if (filtered)
 		*filtered = 1;
+
 	return NULL;
 }
 


