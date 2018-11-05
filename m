From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 5 Nov 2018 11:27:44 -0500
Subject: master - debug: missing backtrace
Message-ID: <201811051627.wA5GRiCn005498@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9a6f0e64f92bfb9f8c7fd4e5692a8107eba50034
Commit:        9a6f0e64f92bfb9f8c7fd4e5692a8107eba50034
Parent:        9d9979963ffa5ec72a188e123a89eeea8ea666c5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 2 22:19:26 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 5 17:25:11 2018 +0100

debug: missing backtrace

---
 lib/cache/lvmcache.c |    3 ++-
 lib/device/bcache.c  |    3 ++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index e681ed8..d35b366 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -1848,7 +1848,8 @@ void lvmcache_destroy(struct cmd_context *cmd, int retain_orphans, int reset)
 	if (retain_orphans) {
 		struct format_type *fmt;
 
-		lvmcache_init(cmd);
+		if (!lvmcache_init(cmd))
+			stack;
 
 		dm_list_iterate_items(fmt, &cmd->formats) {
 			if (!lvmcache_add_orphan_vginfo(fmt->orphan_vg_name, fmt))
diff --git a/lib/device/bcache.c b/lib/device/bcache.c
index 0183079..62970ef 100644
--- a/lib/device/bcache.c
+++ b/lib/device/bcache.c
@@ -1004,7 +1004,8 @@ void bcache_destroy(struct bcache *cache)
 	if (cache->nr_locked)
 		log_warn("some blocks are still locked");
 
-	bcache_flush(cache);
+	if (!bcache_flush(cache))
+		stack;
 	_wait_all(cache);
 	_exit_free_list(cache);
 	radix_tree_destroy(cache->rtree);


