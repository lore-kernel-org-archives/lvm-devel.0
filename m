From: David Teigland <teigland@sourceware.org>
Date: Mon, 23 Apr 2018 09:54:39 -0400
Subject: master - misc bcache fixes from ejt
Message-ID: <201804231354.w3NDsdLH001529@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8b26a007b1b545333b40675b1c425b1ef5e0b653
Commit:        8b26a007b1b545333b40675b1c425b1ef5e0b653
Parent:        0da296003d3af3f505213a25783dda534af2d9d6
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Feb 20 09:33:27 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 20 11:22:47 2018 -0500

misc bcache fixes from ejt

---
 lib/device/bcache.c |   64 +++++++++++++++++++++++++++++++--------------------
 lib/device/bcache.h |    9 +++++-
 lib/label/label.c   |    2 +-
 3 files changed, 47 insertions(+), 28 deletions(-)

diff --git a/lib/device/bcache.c b/lib/device/bcache.c
index 38c909c..499c6af 100644
--- a/lib/device/bcache.c
+++ b/lib/device/bcache.c
@@ -134,7 +134,6 @@ struct async_engine {
 	struct io_engine e;
 	io_context_t aio_context;
 	struct cb_set *cbs;
-	unsigned max_io;
 };
 
 static struct async_engine *_to_async(struct io_engine *e)
@@ -185,7 +184,10 @@ static bool _async_issue(struct io_engine *ioe, enum dir d, int fd,
 	cb->cb.aio_lio_opcode = (d == DIR_READ) ? IO_CMD_PREAD : IO_CMD_PWRITE;
 
 	cb_array[0] = &cb->cb;
-	r = io_submit(e->aio_context, 1, cb_array);
+	do {
+		r = io_submit(e->aio_context, 1, cb_array);
+	} while (r == -EAGAIN);
+
 	if (r < 0) {
 		log_sys_warn("io_submit");
 		_cb_free(e->cbs, cb);
@@ -206,7 +208,10 @@ static bool _async_wait(struct io_engine *ioe, io_complete_fn fn)
 	struct async_engine *e = _to_async(ioe);
 
 	memset(&event, 0, sizeof(event));
-	r = io_getevents(e->aio_context, 1, MAX_EVENT, event, NULL);
+	do {
+		r = io_getevents(e->aio_context, 1, MAX_EVENT, event, NULL);
+	} while (r == -EINTR);
+
 	if (r < 0) {
 		log_sys_warn("io_getevents");
 		return false;
@@ -223,6 +228,7 @@ static bool _async_wait(struct io_engine *ioe, io_complete_fn fn)
 		else if ((int) ev->res < 0)
 			fn(cb->context, (int) ev->res);
 
+		// FIXME: dct added this. a short read is ok?!
 		else if (ev->res >= (1 << SECTOR_SHIFT)) {
 			/* minimum acceptable read is 1 sector */
 			fn((void *) cb->context, 0);
@@ -238,13 +244,12 @@ static bool _async_wait(struct io_engine *ioe, io_complete_fn fn)
 	return true;
 }
 
-static unsigned _async_max_io(struct io_engine *ioe)
+static unsigned _async_max_io(struct io_engine *e)
 {
-	struct async_engine *e = _to_async(ioe);
-	return e->max_io;
+	return MAX_IO;
 }
 
-struct io_engine *create_async_io_engine(unsigned max_io)
+struct io_engine *create_async_io_engine(void)
 {
 	int r;
 	struct async_engine *e = dm_malloc(sizeof(*e));
@@ -252,22 +257,20 @@ struct io_engine *create_async_io_engine(unsigned max_io)
 	if (!e)
 		return NULL;
 
-	e->max_io = max_io;
-
 	e->e.destroy = _async_destroy;
 	e->e.issue = _async_issue;
 	e->e.wait = _async_wait;
 	e->e.max_io = _async_max_io;
 
 	e->aio_context = 0;
-	r = io_setup(max_io, &e->aio_context);
+	r = io_setup(MAX_IO, &e->aio_context);
 	if (r < 0) {
 		log_warn("io_setup failed");
 		dm_free(e);
 		return NULL;
 	}
 
-	e->cbs = _cb_set_create(max_io);
+	e->cbs = _cb_set_create(MAX_IO);
 	if (!e->cbs) {
 		log_warn("couldn't create control block set");
 		dm_free(e);
@@ -535,10 +538,17 @@ static void _complete_io(void *context, int err)
 	 */
 	dm_list_del(&b->list);
 
-	if (b->error)
-		dm_list_add(&cache->errored, &b->list);
+	if (b->error) {
+		if (b->io_dir == DIR_READ) {
+			// We can just forget about this block, since there's
+			// no dirty data to be written back.
+			_hash_remove(b);
+			dm_list_add(&cache->free, &b->list);
 
-	else {
+		} else
+			dm_list_add(&cache->errored, &b->list);
+
+	} else {
 		_clear_flags(b, BF_DIRTY);
 		_link_block(b);
 	}
@@ -548,35 +558,34 @@ static void _complete_io(void *context, int err)
  * |b->list| should be valid (either pointing to itself, on one of the other
  * lists.
  */
-static bool _issue_low_level(struct block *b, enum dir d)
+static void _issue_low_level(struct block *b, enum dir d)
 {
 	struct bcache *cache = b->cache;
 	sector_t sb = b->index * cache->block_sectors;
 	sector_t se = sb + cache->block_sectors;
 
 	if (_test_flags(b, BF_IO_PENDING))
-		return false;
+		return;
 
+	b->io_dir = d;
 	_set_flags(b, BF_IO_PENDING);
 	dm_list_add(&cache->io_pending, &b->list);
 
 	if (!cache->engine->issue(cache->engine, d, b->fd, sb, se, b->data, b)) {
 		_complete_io(b, -EIO);
-		return false;
+		return;
 	}
 
-	return true;
-
 }
 
-static inline bool _issue_read(struct block *b)
+static inline void _issue_read(struct block *b)
 {
-	return _issue_low_level(b, DIR_READ);
+	_issue_low_level(b, DIR_READ);
 }
 
-static inline bool _issue_write(struct block *b)
+static inline void _issue_write(struct block *b)
 {
-	return _issue_low_level(b, DIR_WRITE);
+	_issue_low_level(b, DIR_WRITE);
 }
 
 static bool _wait_io(struct bcache *cache)
@@ -903,8 +912,13 @@ void bcache_put(struct block *b)
 		_preemptive_writeback(b->cache);
 }
 
-int bcache_flush(struct bcache *cache)
+bool bcache_flush(struct bcache *cache)
 {
+	// Only dirty data is on the errored list, since bad read blocks get
+	// recycled straight away.  So we put these back on the dirty list, and
+	// try and rewrite everything.
+	dm_list_splice(&cache->dirty, &cache->errored);
+
 	while (!dm_list_empty(&cache->dirty)) {
 		struct block *b = dm_list_item(_list_pop(&cache->dirty), struct block);
 		if (b->ref_count || _test_flags(b, BF_IO_PENDING)) {
@@ -917,7 +931,7 @@ int bcache_flush(struct bcache *cache)
 
 	_wait_all(cache);
 
-	return dm_list_empty(&cache->errored) ? 0 : -EIO;
+	return dm_list_empty(&cache->errored);
 }
 
 static void _recycle_block(struct bcache *cache, struct block *b)
diff --git a/lib/device/bcache.h b/lib/device/bcache.h
index 7d38d33..e5d98e8 100644
--- a/lib/device/bcache.h
+++ b/lib/device/bcache.h
@@ -47,7 +47,7 @@ struct io_engine {
 	unsigned (*max_io)(struct io_engine *e);
 };
 
-struct io_engine *create_async_io_engine(unsigned max_io);
+struct io_engine *create_async_io_engine(void);
 
 /*----------------------------------------------------------------*/
 
@@ -65,6 +65,7 @@ struct block {
 	unsigned flags;
 	unsigned ref_count;
 	int error;
+	enum dir io_dir;
 };
 
 /*
@@ -122,7 +123,11 @@ bool bcache_get(struct bcache *cache, int fd, block_address index,
 	        unsigned flags, struct block **result);
 void bcache_put(struct block *b);
 
-int bcache_flush(struct bcache *cache);
+/*
+ * flush() does not attempt to writeback locked blocks.  flush will fail
+ * (return false), if any unlocked dirty data cannot be written back.
+ */
+bool bcache_flush(struct bcache *cache);
 
 /*
  * Removes a block from the cache.  If the block is dirty it will be written
diff --git a/lib/label/label.c b/lib/label/label.c
index dfd3e37..278f26a 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -587,7 +587,7 @@ static int _setup_bcache(int cache_blocks)
 	 * possible, i.e, the number of devices that can be read at
 	 * once.  Should this be configurable?
 	 */
-	if (!(ioe = create_async_io_engine(100))) {
+	if (!(ioe = create_async_io_engine())) {
 		log_error("Failed to create bcache io engine.");
 		return 0;
 	}


