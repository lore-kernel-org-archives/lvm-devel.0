From: David Teigland <teigland@sourceware.org>
Date: Mon, 23 Apr 2018 09:46:49 -0400
Subject: master - [device/bcache] Add bcache_max_prefetches()
Message-ID: <201804231346.w3NDknT0031133@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1563b936911d26c665b590f200884c9ed31ab7c3
Commit:        1563b936911d26c665b590f200884c9ed31ab7c3
Parent:        c4c4acfd423323cbe8fbfbdb8c1882edb4a92b29
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Fri Feb 2 12:06:14 2018 +0000
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 20 11:12:50 2018 -0500

[device/bcache] Add bcache_max_prefetches()

Ignore prefetches if max io is in flight.
---
 lib/device/bcache.c |   23 +++++++++++++++--------
 lib/device/bcache.h |    1 +
 2 files changed, 16 insertions(+), 8 deletions(-)

diff --git a/lib/device/bcache.c b/lib/device/bcache.c
index 09ef6ef..4283ce5 100644
--- a/lib/device/bcache.c
+++ b/lib/device/bcache.c
@@ -216,17 +216,18 @@ static bool _engine_issue(struct io_engine *e, enum dir d, int fd,
 	return true;
 }
 
-#define MAX_IO 64
+#define MAX_IO 1024
+#define MAX_EVENT 64
 typedef void complete_fn(void *context, int io_error);
 
 static bool _engine_wait(struct io_engine *e, complete_fn fn)
 {
 	int i, r;
-	struct io_event event[MAX_IO];
+	struct io_event event[MAX_EVENT];
 	struct control_block *cb;
 
 	memset(&event, 0, sizeof(event));
-	r = io_getevents(e->aio_context, 1, MAX_IO, event, NULL);
+	r = io_getevents(e->aio_context, 1, MAX_EVENT, event, NULL);
 	if (r < 0) {
 		log_sys_warn("io_getevents");
 		return false;
@@ -300,6 +301,7 @@ struct bcache {
 	sector_t block_sectors;
 	uint64_t nr_data_blocks;
 	uint64_t nr_cache_blocks;
+	unsigned max_io;
 
 	struct io_engine *engine;
 
@@ -762,8 +764,8 @@ struct bcache *bcache_create(sector_t block_sectors, unsigned nr_cache_blocks)
 
 	cache->block_sectors = block_sectors;
 	cache->nr_cache_blocks = nr_cache_blocks;
-
-	cache->engine = _engine_create(nr_cache_blocks < 1024u ? nr_cache_blocks : 1024u);
+	cache->max_io = nr_cache_blocks < MAX_IO ? nr_cache_blocks : MAX_IO;
+	cache->engine = _engine_create(cache->max_io);
 	if (!cache->engine) {
 		dm_free(cache);
 		return NULL;
@@ -820,16 +822,21 @@ unsigned bcache_nr_cache_blocks(struct bcache *cache)
 	return cache->nr_cache_blocks;
 }
 
+unsigned bcache_max_prefetches(struct bcache *cache)
+{
+	return cache->max_io;
+}
+
 void bcache_prefetch(struct bcache *cache, int fd, block_address index)
 {
 	struct block *b = _hash_lookup(cache, fd, index);
 
 	if (!b) {
-		cache->prefetches++;
-
 		b = _new_block(cache, fd, index);
-		if (b)
+		if (b && (cache->nr_io_pending < cache->max_io)) {
+			cache->prefetches++;
 			_issue_read(b);
+		}
 	}
 }
 
diff --git a/lib/device/bcache.h b/lib/device/bcache.h
index 5c68e3c..14204be 100644
--- a/lib/device/bcache.h
+++ b/lib/device/bcache.h
@@ -62,6 +62,7 @@ enum bcache_get_flags {
 typedef uint64_t block_address;
 
 unsigned bcache_nr_cache_blocks(struct bcache *cache);
+unsigned bcache_max_prefetches(struct bcache *cache);
 
 /*
  * Use the prefetch method to take advantage of asynchronous IO.  For example,


