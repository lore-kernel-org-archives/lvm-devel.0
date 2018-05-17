From: Joe Thornber <thornber@sourceware.org>
Date: Thu, 17 May 2018 05:06:09 -0400
Subject: master - bcache: Don't call sysconf for every io
Message-ID: <201805170906.w4H969Ei015874@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5052970da3bdf3ef702fa0f54a25cc2a44d0829e
Commit:        5052970da3bdf3ef702fa0f54a25cc2a44d0829e
Parent:        7ee0a6e44d5e6c1085d04c407453f69ac14935b0
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Thu May 17 10:05:10 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Thu May 17 10:05:10 2018 +0100

bcache: Don't call sysconf for every io

---
 lib/device/bcache.c |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/lib/device/bcache.c b/lib/device/bcache.c
index 3f5a45e..9e94fcc 100644
--- a/lib/device/bcache.c
+++ b/lib/device/bcache.c
@@ -133,6 +133,7 @@ struct async_engine {
 	struct io_engine e;
 	io_context_t aio_context;
 	struct cb_set *cbs;
+	unsigned page_mask;
 };
 
 static struct async_engine *_to_async(struct io_engine *e)
@@ -162,9 +163,8 @@ static bool _async_issue(struct io_engine *ioe, enum dir d, int fd,
 	struct iocb *cb_array[1];
 	struct control_block *cb;
 	struct async_engine *e = _to_async(ioe);
-	long pgsize = sysconf(_SC_PAGESIZE);
 
-	if (((uintptr_t) data) & (pgsize - 1)) {
+	if (((uintptr_t) data) & e->page_mask) {
 		log_warn("misaligned data buffer");
 		return false;
 	}
@@ -276,6 +276,8 @@ struct io_engine *create_async_io_engine(void)
 		return NULL;
 	}
 
+	e->page_mask = sysconf(_SC_PAGESIZE) - 1;
+
 	return &e->e;
 }
 
@@ -544,11 +546,10 @@ static void _hash_table_exit(struct bcache *cache)
 
 //----------------------------------------------------------------
 
-static bool _init_free_list(struct bcache *cache, unsigned count)
+static bool _init_free_list(struct bcache *cache, unsigned count, unsigned pgsize)
 {
 	unsigned i;
 	size_t block_size = cache->block_sectors << SECTOR_SHIFT;
-	long pgsize = sysconf(_SC_PAGESIZE);
 	unsigned char *data =
 		(unsigned char *) _alloc_aligned(count * block_size, pgsize);
 
@@ -949,7 +950,7 @@ struct bcache *bcache_create(sector_t block_sectors, unsigned nr_cache_blocks,
 	cache->write_misses = 0;
 	cache->prefetches = 0;
 
-	if (!_init_free_list(cache, nr_cache_blocks)) {
+	if (!_init_free_list(cache, nr_cache_blocks, pgsize)) {
 		cache->engine->destroy(cache->engine);
 		_hash_table_exit(cache);
 		dm_free(cache);


