From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 25 Jun 2019 11:45:10 -0400
Subject: stable-2.02 - cov: add stack tracing for error paths
Message-ID: <201906251545.x5PFjAiA012935@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=66665f5e428c2b3d7f4dbcd3e88a872db0381b93
Commit:        66665f5e428c2b3d7f4dbcd3e88a872db0381b93
Parent:        5cf1c61152bfd5f1eef7f49509a877090f4cc26f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 25 14:42:16 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 25 17:33:25 2019 +0200

cov: add stack tracing for error paths

Add missing stack reports on error paths.
---
 lib/cache/lvmcache.c   |    3 ++-
 lib/device/bcache.c    |    3 ++-
 lib/device/dev-cache.c |    3 ++-
 lib/device/dev-io.c    |    6 ++++--
 4 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 0ce5df0..9890325 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -2595,7 +2595,8 @@ void lvmcache_destroy(struct cmd_context *cmd, int retain_orphans, int reset)
 	if (retain_orphans) {
 		struct format_type *fmt;
 
-		lvmcache_init(cmd);
+		if (!lvmcache_init(cmd))
+			stack;
 
 		dm_list_iterate_items(fmt, &cmd->formats) {
 			if (!lvmcache_add_orphan_vginfo(fmt->orphan_vg_name, fmt))
diff --git a/lib/device/bcache.c b/lib/device/bcache.c
index f64931f..dac8be6 100644
--- a/lib/device/bcache.c
+++ b/lib/device/bcache.c
@@ -1101,7 +1101,8 @@ void bcache_destroy(struct bcache *cache)
 	if (cache->nr_locked)
 		log_warn("some blocks are still locked");
 
-	bcache_flush(cache);
+	if (!bcache_flush(cache))
+		log_warn("cache flushing failed.");
 	_wait_all(cache);
 	_exit_free_list(cache);
 	_hash_table_exit(cache);
diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 04ee41e..a429b10 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -1344,7 +1344,8 @@ static int _check_for_open_devices(int close_immediate)
 				  dev_name(dev), dev->open_count);
 			num_open++;
 			if (close_immediate)
-				dev_close_immediate(dev);
+				if (!dev_close_immediate(dev))
+					stack;
 		}
 	}
 
diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index 6996a44..4590232 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -521,7 +521,8 @@ int dev_open_flags(struct device *dev, int flags, int direct, int quiet)
 		/* dev_close_immediate will decrement this */
 		dev->open_count++;
 
-		dev_close_immediate(dev);
+		if (!dev_close_immediate(dev))
+			stack;
 		// FIXME: dev with DEV_ALLOCED is released
 		// but code is referencing it
 	}
@@ -599,7 +600,8 @@ int dev_open_flags(struct device *dev, int flags, int direct, int quiet)
 	if (!(dev->flags & DEV_REGULAR) &&
 	    ((fstat(dev->fd, &buf) < 0) || (buf.st_rdev != dev->dev))) {
 		log_error("%s: fstat failed: Has device name changed?", name);
-		dev_close_immediate(dev);
+		if (!dev_close_immediate(dev))
+			stack;
 		return 0;
 	}
 


