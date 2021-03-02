From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  2 Mar 2021 21:58:30 +0000 (GMT)
Subject: main - dev-cache: replace inefficient looking for dev
Message-ID: <20210302215830.351443851C35@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9dd759c6b1c0e25e785485f823b09c59ef5b2583
Commit:        9dd759c6b1c0e25e785485f823b09c59ef5b2583
Parent:        081e47912e6c80f233fec5d472e32e1ac4f19a78
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Feb 26 00:21:41 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 2 22:54:40 2021 +0100

dev-cache: replace inefficient looking for dev

Use btree loopkup to find dev structure by major:minor.
This could have slow down lvm2 commands significantly with
higher amount of LVs.
---
 lib/device/dev-cache.c | 21 ++-------------------
 1 file changed, 2 insertions(+), 19 deletions(-)

diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 8dd069c79..21c9ef0ea 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -1549,29 +1549,12 @@ struct device *dev_cache_get(struct cmd_context *cmd, const char *name, struct d
 	return dev;
 }
 
-static struct device *_dev_cache_seek_devt(dev_t dev)
-{
-	struct device *d = NULL;
-	struct dm_hash_node *n = dm_hash_get_first(_cache.names);
-	while (n) {
-		d = dm_hash_get_data(_cache.names, n);
-		if (d->dev == dev)
-			return d;
-		n = dm_hash_get_next(_cache.names, n);
-	}
-	return NULL;
-}
-
-/*
- * TODO This is very inefficient. We probably want a hash table indexed by
- * major:minor for keys to speed up these lookups.
- */
 struct device *dev_cache_get_by_devt(struct cmd_context *cmd, dev_t dev, struct dev_filter *f, int *filtered)
 {
 	char path[PATH_MAX];
 	const char *sysfs_dir;
 	struct stat info;
-	struct device *d = _dev_cache_seek_devt(dev);
+	struct device *d = (struct device *) btree_lookup(_cache.devices, (uint32_t) dev);
 	int ret;
 
 	if (filtered)
@@ -1600,7 +1583,7 @@ struct device *dev_cache_get_by_devt(struct cmd_context *cmd, dev_t dev, struct
 		log_debug_devs("Device num not found in dev_cache repeat dev_cache_scan for %d:%d",
 				(int)MAJOR(dev), (int)MINOR(dev));
 		dev_cache_scan();
-		d = _dev_cache_seek_devt(dev);
+		d = (struct device *) btree_lookup(_cache.devices, (uint32_t) dev);
 	}
 
 	if (!d)


