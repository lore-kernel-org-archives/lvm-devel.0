From: David Teigland <teigland@sourceware.org>
Date: Fri, 18 Sep 2020 20:10:31 +0000 (GMT)
Subject: master - bcache: use indirection table for fd
Message-ID: <20200918201031.C58DD397303F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1570e76233398957911c3559b40de6e03c37df9a
Commit:        1570e76233398957911c3559b40de6e03c37df9a
Parent:        4b07ae55f1a1e7ad33b2fb0067112ed074f30bf4
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Sep 17 09:40:18 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Sep 18 15:10:11 2020 -0500

bcache: use indirection table for fd

Add a "device index" (di) for each device, and use this
in the bcache api to the rest of lvm.  This replaces the
file descriptor (fd) in the api.  The rest of lvm uses
new functions bcache_set_fd(), bcache_clear_fd(), and
bcache_change_fd() to control which fd bcache uses for
io to a particular device.

. lvm opens a dev and gets and fd.
  fd = open(dev);

. lvm passes fd to the bcache layer and gets a di
  to use in the bcache api for the dev.
  di = bcache_set_fd(fd);

. lvm uses bcache functions, passing di for the dev.
  bcache_write_bytes(di, ...), etc.

. bcache translates di to fd to do io.

. lvm closes the device and clears the di/fd bcache state.
  close(fd);
  bcache_clear_fd(di);

In the bcache layer, a di-to-fd translation table
(int *_fd_table) is added.  When bcache needs to
perform io on a di, it uses _fd_table[di].

In the following commit, lvm will make use of the new
bcache_change_fd() function to change the fd that
bcache uses for the dev, without dropping cached blocks.
---
 lib/device/bcache-utils.c  |  64 ++++++------
 lib/device/bcache.c        | 188 +++++++++++++++++++++++++----------
 lib/device/bcache.h        |  36 ++++---
 lib/device/dev-cache.c     |   1 +
 lib/device/device.h        |   1 +
 lib/label/label.c          | 115 +++++++++++----------
 lib/metadata/metadata.c    |   1 +
 test/unit/bcache_t.c       | 242 ++++++++++++++++++++++-----------------------
 test/unit/bcache_utils_t.c |  18 ++--
 test/unit/io_engine_t.c    |  24 +++--
 tools/toollib.c            |   2 +-
 11 files changed, 406 insertions(+), 286 deletions(-)

diff --git a/lib/device/bcache-utils.c b/lib/device/bcache-utils.c
index cf7414457..85ec07aa6 100644
--- a/lib/device/bcache-utils.c
+++ b/lib/device/bcache-utils.c
@@ -39,32 +39,32 @@ static uint64_t _min(uint64_t lhs, uint64_t rhs)
 
 //----------------------------------------------------------------
 
-void bcache_prefetch_bytes(struct bcache *cache, int fd, uint64_t start, size_t len)
+void bcache_prefetch_bytes(struct bcache *cache, int di, uint64_t start, size_t len)
 {
 	block_address bb, be;
 
 	byte_range_to_block_range(cache, start, len, &bb, &be);
 	while (bb < be) {
-		bcache_prefetch(cache, fd, bb);
+		bcache_prefetch(cache, di, bb);
 		bb++;
 	}
 }
 
 //----------------------------------------------------------------
 
-bool bcache_read_bytes(struct bcache *cache, int fd, uint64_t start, size_t len, void *data)
+bool bcache_read_bytes(struct bcache *cache, int di, uint64_t start, size_t len, void *data)
 {
 	struct block *b;
 	block_address bb, be;
 	uint64_t block_size = bcache_block_sectors(cache) << SECTOR_SHIFT;
 	uint64_t block_offset = start % block_size;
 
-	bcache_prefetch_bytes(cache, fd, start, len);
+	bcache_prefetch_bytes(cache, di, start, len);
 
 	byte_range_to_block_range(cache, start, len, &bb, &be);
 
 	for (; bb != be; bb++) {
-        	if (!bcache_get(cache, fd, bb, 0, &b))
+        	if (!bcache_get(cache, di, bb, 0, &b))
 			return false;
 
 		size_t blen = _min(block_size - block_offset, len);
@@ -79,7 +79,7 @@ bool bcache_read_bytes(struct bcache *cache, int fd, uint64_t start, size_t len,
 	return true;
 }
 
-bool bcache_invalidate_bytes(struct bcache *cache, int fd, uint64_t start, size_t len)
+bool bcache_invalidate_bytes(struct bcache *cache, int di, uint64_t start, size_t len)
 {
 	block_address bb, be;
 	bool result = true;
@@ -87,7 +87,7 @@ bool bcache_invalidate_bytes(struct bcache *cache, int fd, uint64_t start, size_
 	byte_range_to_block_range(cache, start, len, &bb, &be);
 
 	for (; bb != be; bb++) {
-		if (!bcache_invalidate(cache, fd, bb))
+		if (!bcache_invalidate(cache, di, bb))
 			result = false;
 	}
 
@@ -101,8 +101,8 @@ bool bcache_invalidate_bytes(struct bcache *cache, int fd, uint64_t start, size_
  
 struct updater;
 
-typedef bool (*partial_update_fn)(struct updater *u, int fd, block_address bb, uint64_t offset, size_t len);
-typedef bool (*whole_update_fn)(struct updater *u, int fd, block_address bb, block_address be);
+typedef bool (*partial_update_fn)(struct updater *u, int di, block_address bb, uint64_t offset, size_t len);
+typedef bool (*whole_update_fn)(struct updater *u, int di, block_address bb, block_address be);
 
 struct updater {
 	struct bcache *cache;
@@ -111,7 +111,7 @@ struct updater {
 	void *data;
 };
 
-static bool _update_bytes(struct updater *u, int fd, uint64_t start, size_t len)
+static bool _update_bytes(struct updater *u, int di, uint64_t start, size_t len)
 {
         struct bcache *cache = u->cache;
 	block_address bb, be;
@@ -124,12 +124,12 @@ static bool _update_bytes(struct updater *u, int fd, uint64_t start, size_t len)
 	// If the last block is partial, we will require a read, so let's 
 	// prefetch it.
 	if ((start + len) % block_size)
-        	bcache_prefetch(cache, fd, (start + len) / block_size);
+        	bcache_prefetch(cache, di, (start + len) / block_size);
 
 	// First block may be partial
 	if (block_offset) {
         	size_t blen = _min(block_size - block_offset, len);
-		if (!u->partial_fn(u, fd, bb, block_offset, blen))
+		if (!u->partial_fn(u, di, bb, block_offset, blen))
         		return false;
 
 		len -= blen;
@@ -141,7 +141,7 @@ static bool _update_bytes(struct updater *u, int fd, uint64_t start, size_t len)
 
         // Now we write out a set of whole blocks
         nr_whole = len / block_size;
-        if (!u->whole_fn(u, fd, bb, bb + nr_whole))
+        if (!u->whole_fn(u, di, bb, bb + nr_whole))
                 return false;
 
 	bb += nr_whole;
@@ -151,17 +151,17 @@ static bool _update_bytes(struct updater *u, int fd, uint64_t start, size_t len)
         	return true;
 
         // Finally we write a partial end block
-        return u->partial_fn(u, fd, bb, 0, len);
+        return u->partial_fn(u, di, bb, 0, len);
 }
 
 //----------------------------------------------------------------
 
-static bool _write_partial(struct updater *u, int fd, block_address bb,
+static bool _write_partial(struct updater *u, int di, block_address bb,
                            uint64_t offset, size_t len)
 {
 	struct block *b;
 
-	if (!bcache_get(u->cache, fd, bb, GF_DIRTY, &b))
+	if (!bcache_get(u->cache, di, bb, GF_DIRTY, &b))
 		return false;
 
 	memcpy(((unsigned char *) b->data) + offset, u->data, len);
@@ -171,7 +171,7 @@ static bool _write_partial(struct updater *u, int fd, block_address bb,
 	return true;
 }
 
-static bool _write_whole(struct updater *u, int fd, block_address bb, block_address be)
+static bool _write_whole(struct updater *u, int di, block_address bb, block_address be)
 {
 	struct block *b;
 	uint64_t block_size = bcache_block_sectors(u->cache) << SECTOR_SHIFT;
@@ -179,7 +179,7 @@ static bool _write_whole(struct updater *u, int fd, block_address bb, block_addr
 	for (; bb != be; bb++) {
         	// We don't need to read the block since we are overwriting
         	// it completely.
-		if (!bcache_get(u->cache, fd, bb, GF_ZERO, &b))
+		if (!bcache_get(u->cache, di, bb, GF_ZERO, &b))
         		return false;
 		memcpy(b->data, u->data, block_size);
 		u->data = ((unsigned char *) u->data) + block_size;
@@ -189,7 +189,7 @@ static bool _write_whole(struct updater *u, int fd, block_address bb, block_addr
 	return true;
 }
 
-bool bcache_write_bytes(struct bcache *cache, int fd, uint64_t start, size_t len, void *data)
+bool bcache_write_bytes(struct bcache *cache, int di, uint64_t start, size_t len, void *data)
 {
         struct updater u;
 
@@ -198,16 +198,16 @@ bool bcache_write_bytes(struct bcache *cache, int fd, uint64_t start, size_t len
         u.whole_fn = _write_whole;
         u.data = data;
 
-	return _update_bytes(&u, fd, start, len);
+	return _update_bytes(&u, di, start, len);
 }
 
 //----------------------------------------------------------------
 
-static bool _zero_partial(struct updater *u, int fd, block_address bb, uint64_t offset, size_t len)
+static bool _zero_partial(struct updater *u, int di, block_address bb, uint64_t offset, size_t len)
 {
 	struct block *b;
 
-	if (!bcache_get(u->cache, fd, bb, GF_DIRTY, &b))
+	if (!bcache_get(u->cache, di, bb, GF_DIRTY, &b))
 		return false;
 
 	memset(((unsigned char *) b->data) + offset, 0, len);
@@ -216,12 +216,12 @@ static bool _zero_partial(struct updater *u, int fd, block_address bb, uint64_t
 	return true;
 }
 
-static bool _zero_whole(struct updater *u, int fd, block_address bb, block_address be)
+static bool _zero_whole(struct updater *u, int di, block_address bb, block_address be)
 {
 	struct block *b;
 
 	for (; bb != be; bb++) {
-		if (!bcache_get(u->cache, fd, bb, GF_ZERO, &b))
+		if (!bcache_get(u->cache, di, bb, GF_ZERO, &b))
         		return false;
         	bcache_put(b);
 	}
@@ -229,7 +229,7 @@ static bool _zero_whole(struct updater *u, int fd, block_address bb, block_addre
 	return true;
 }
 
-bool bcache_zero_bytes(struct bcache *cache, int fd, uint64_t start, size_t len)
+bool bcache_zero_bytes(struct bcache *cache, int di, uint64_t start, size_t len)
 {
         struct updater u;
 
@@ -238,17 +238,17 @@ bool bcache_zero_bytes(struct bcache *cache, int fd, uint64_t start, size_t len)
         u.whole_fn = _zero_whole;
         u.data = NULL;
 
-	return _update_bytes(&u, fd, start, len);
+	return _update_bytes(&u, di, start, len);
 }
 
 //----------------------------------------------------------------
 
-static bool _set_partial(struct updater *u, int fd, block_address bb, uint64_t offset, size_t len)
+static bool _set_partial(struct updater *u, int di, block_address bb, uint64_t offset, size_t len)
 {
 	struct block *b;
 	uint8_t val = *((uint8_t *) u->data);
 
-	if (!bcache_get(u->cache, fd, bb, GF_DIRTY, &b))
+	if (!bcache_get(u->cache, di, bb, GF_DIRTY, &b))
 		return false;
 
 	memset(((unsigned char *) b->data) + offset, val, len);
@@ -257,14 +257,14 @@ static bool _set_partial(struct updater *u, int fd, block_address bb, uint64_t o
 	return true;
 }
 
-static bool _set_whole(struct updater *u, int fd, block_address bb, block_address be)
+static bool _set_whole(struct updater *u, int di, block_address bb, block_address be)
 {
 	struct block *b;
 	uint8_t val = *((uint8_t *) u->data);
         uint64_t len = bcache_block_sectors(u->cache) * 512;
 
 	for (; bb != be; bb++) {
-		if (!bcache_get(u->cache, fd, bb, GF_ZERO, &b))
+		if (!bcache_get(u->cache, di, bb, GF_ZERO, &b))
         		return false;
         	memset((unsigned char *) b->data, val, len);
         	bcache_put(b);
@@ -273,7 +273,7 @@ static bool _set_whole(struct updater *u, int fd, block_address bb, block_addres
 	return true;
 }
 
-bool bcache_set_bytes(struct bcache *cache, int fd, uint64_t start, size_t len, uint8_t val)
+bool bcache_set_bytes(struct bcache *cache, int di, uint64_t start, size_t len, uint8_t val)
 {
         struct updater u;
 
@@ -282,6 +282,6 @@ bool bcache_set_bytes(struct bcache *cache, int fd, uint64_t start, size_t len,
         u.whole_fn = _set_whole;
         u.data = &val;
 
-	return _update_bytes(&u, fd, start, len);
+	return _update_bytes(&u, di, start, len);
 }
 
diff --git a/lib/device/bcache.c b/lib/device/bcache.c
index 03cd4be87..c78445d99 100644
--- a/lib/device/bcache.c
+++ b/lib/device/bcache.c
@@ -33,6 +33,11 @@
 
 #define SECTOR_SHIFT 9L
 
+#define FD_TABLE_INC 1024
+static int _fd_table_size;
+static int *_fd_table;
+
+
 //----------------------------------------------------------------
 
 static void log_sys_warn(const char *call)
@@ -155,11 +160,11 @@ static void _async_destroy(struct io_engine *ioe)
 	free(e);
 }
 
-static int _last_byte_fd;
+static int _last_byte_di;
 static uint64_t _last_byte_offset;
 static int _last_byte_sector_size;
 
-static bool _async_issue(struct io_engine *ioe, enum dir d, int fd,
+static bool _async_issue(struct io_engine *ioe, enum dir d, int di,
 			 sector_t sb, sector_t se, void *data, void *context)
 {
 	int r;
@@ -183,7 +188,7 @@ static bool _async_issue(struct io_engine *ioe, enum dir d, int fd,
 	/*
 	 * If bcache block goes past where lvm wants to write, then clamp it.
 	 */
-	if ((d == DIR_WRITE) && _last_byte_offset && (fd == _last_byte_fd)) {
+	if ((d == DIR_WRITE) && _last_byte_offset && (di == _last_byte_di)) {
 		if (offset > _last_byte_offset) {
 			log_error("Limit write at %llu len %llu beyond last byte %llu",
 				  (unsigned long long)offset,
@@ -268,7 +273,7 @@ static bool _async_issue(struct io_engine *ioe, enum dir d, int fd,
 
 	memset(&cb->cb, 0, sizeof(cb->cb));
 
-	cb->cb.aio_fildes = (int) fd;
+	cb->cb.aio_fildes = (int) _fd_table[di];
 	cb->cb.u.c.buf = data;
 	cb->cb.u.c.offset = offset;
 	cb->cb.u.c.nbytes = nbytes;
@@ -276,13 +281,15 @@ static bool _async_issue(struct io_engine *ioe, enum dir d, int fd,
 
 #if 0
 	if (d == DIR_READ) {
-		log_debug("io R off %llu bytes %llu",
+		log_debug("io R off %llu bytes %llu di %d fd %d",
 			  (unsigned long long)cb->cb.u.c.offset,
-			  (unsigned long long)cb->cb.u.c.nbytes);
+			  (unsigned long long)cb->cb.u.c.nbytes,
+			  di, _fd_table[di]);
 	} else {
-		log_debug("io W off %llu bytes %llu",
+		log_debug("io W off %llu bytes %llu di %d fd %d",
 			  (unsigned long long)cb->cb.u.c.offset,
-			  (unsigned long long)cb->cb.u.c.nbytes);
+			  (unsigned long long)cb->cb.u.c.nbytes,
+			  di, _fd_table[di]);
 	}
 #endif
 
@@ -414,7 +421,7 @@ static void _sync_destroy(struct io_engine *ioe)
         free(e);
 }
 
-static bool _sync_issue(struct io_engine *ioe, enum dir d, int fd,
+static bool _sync_issue(struct io_engine *ioe, enum dir d, int di,
                         sector_t sb, sector_t se, void *data, void *context)
 {
 	int rv;
@@ -430,7 +437,7 @@ static bool _sync_issue(struct io_engine *ioe, enum dir d, int fd,
 	}
 
 	where = sb * 512;
-	off = lseek(fd, where, SEEK_SET);
+	off = lseek(_fd_table[di], where, SEEK_SET);
 	if (off == (off_t) -1) {
 		log_warn("Device seek error %d for offset %llu", errno, (unsigned long long)where);
 		free(io);
@@ -445,7 +452,7 @@ static bool _sync_issue(struct io_engine *ioe, enum dir d, int fd,
 	/*
 	 * If bcache block goes past where lvm wants to write, then clamp it.
 	 */
-	if ((d == DIR_WRITE) && _last_byte_offset && (fd == _last_byte_fd)) {
+	if ((d == DIR_WRITE) && _last_byte_offset && (di == _last_byte_di)) {
 		uint64_t offset = where;
 		uint64_t nbytes = len;
 		sector_t limit_nbytes = 0;
@@ -526,9 +533,9 @@ static bool _sync_issue(struct io_engine *ioe, enum dir d, int fd,
 
 	while (pos < len) {
 		if (d == DIR_READ)
-			rv = read(fd, (char *)data + pos, len - pos);
+			rv = read(_fd_table[di], (char *)data + pos, len - pos);
 		else
-			rv = write(fd, (char *)data + pos, len - pos);
+			rv = write(_fd_table[di], (char *)data + pos, len - pos);
 
 		if (rv == -1 && errno == EINTR)
 			continue;
@@ -688,7 +695,7 @@ struct bcache {
 //----------------------------------------------------------------
 
 struct key_parts {
-	uint32_t fd;
+	uint32_t di;
 	uint64_t b;
 } __attribute__ ((packed));
 
@@ -697,12 +704,12 @@ union key {
         uint8_t bytes[12];
 };
 
-static struct block *_block_lookup(struct bcache *cache, int fd, uint64_t i)
+static struct block *_block_lookup(struct bcache *cache, int di, uint64_t i)
 {
 	union key k;
 	union radix_value v;
 
-	k.parts.fd = fd;
+	k.parts.di = di;
 	k.parts.b = i;
 
 	if (radix_tree_lookup(cache->rtree, k.bytes, k.bytes + sizeof(k.bytes), &v))
@@ -716,7 +723,7 @@ static bool _block_insert(struct block *b)
         union key k;
         union radix_value v;
 
-        k.parts.fd = b->fd;
+        k.parts.di = b->di;
         k.parts.b = b->index;
         v.ptr = b;
 
@@ -727,7 +734,7 @@ static void _block_remove(struct block *b)
 {
         union key k;
 
-        k.parts.fd = b->fd;
+        k.parts.di = b->di;
         k.parts.b = b->index;
 
 	radix_tree_remove(b->cache->rtree, k.bytes, k.bytes + sizeof(k.bytes));
@@ -869,7 +876,7 @@ static void _issue_low_level(struct block *b, enum dir d)
 
 	dm_list_move(&cache->io_pending, &b->list);
 
-	if (!cache->engine->issue(cache->engine, d, b->fd, sb, se, b->data, b)) {
+	if (!cache->engine->issue(cache->engine, d, b->di, sb, se, b->data, b)) {
 		/* FIXME: if io_submit() set an errno, return that instead of EIO? */
 		_complete_io(b, -EIO);
 		return;
@@ -945,7 +952,7 @@ static struct block *_find_unused_clean_block(struct bcache *cache)
 	return NULL;
 }
 
-static struct block *_new_block(struct bcache *cache, int fd, block_address i, bool can_wait)
+static struct block *_new_block(struct bcache *cache, int di, block_address i, bool can_wait)
 {
 	struct block *b;
 
@@ -958,8 +965,8 @@ static struct block *_new_block(struct bcache *cache, int fd, block_address i, b
 					_writeback(cache, 16);  // FIXME: magic number
 				_wait_io(cache);
 			} else {
-				log_debug("bcache no new blocks for fd %d index %u",
-					  fd, (uint32_t) i);
+				log_debug("bcache no new blocks for di %d index %u",
+					  di, (uint32_t) i);
 				return NULL;
 			}
 		}
@@ -968,7 +975,7 @@ static struct block *_new_block(struct bcache *cache, int fd, block_address i, b
 	if (b) {
 		dm_list_init(&b->list);
 		b->flags = 0;
-		b->fd = fd;
+		b->di = di;
 		b->index = i;
 		b->ref_count = 0;
 		b->error = 0;
@@ -1014,10 +1021,10 @@ static void _miss(struct bcache *cache, unsigned flags)
 }
 
 static struct block *_lookup_or_read_block(struct bcache *cache,
-				  	   int fd, block_address i,
+				  	   int di, block_address i,
 					   unsigned flags)
 {
-	struct block *b = _block_lookup(cache, fd, i);
+	struct block *b = _block_lookup(cache, di, i);
 
 	if (b) {
 		// FIXME: this is insufficient.  We need to also catch a read
@@ -1042,7 +1049,7 @@ static struct block *_lookup_or_read_block(struct bcache *cache,
 	} else {
 		_miss(cache, flags);
 
-		b = _new_block(cache, fd, i, true);
+		b = _new_block(cache, di, i, true);
 		if (b) {
 			if (flags & GF_ZERO)
 				_zero_block(b);
@@ -1087,6 +1094,7 @@ struct bcache *bcache_create(sector_t block_sectors, unsigned nr_cache_blocks,
 	struct bcache *cache;
 	unsigned max_io = engine->max_io(engine);
 	long pgsize = sysconf(_SC_PAGESIZE);
+	int i;
 
 	if (pgsize < 0) {
 		log_warn("WARNING: _SC_PAGESIZE returns negative value.");
@@ -1147,6 +1155,18 @@ struct bcache *bcache_create(sector_t block_sectors, unsigned nr_cache_blocks,
 		return NULL;
 	}
 
+	_fd_table_size = FD_TABLE_INC;
+
+	if (!(_fd_table = malloc(sizeof(int) * _fd_table_size))) {
+		cache->engine->destroy(cache->engine);
+		radix_tree_destroy(cache->rtree);
+		free(cache);
+		return NULL;
+	}
+
+	for (i = 0; i < _fd_table_size; i++)
+		_fd_table[i] = -1;
+
 	return cache;
 }
 
@@ -1162,6 +1182,9 @@ void bcache_destroy(struct bcache *cache)
 	radix_tree_destroy(cache->rtree);
 	cache->engine->destroy(cache->engine);
 	free(cache);
+	free(_fd_table);
+	_fd_table = NULL;
+	_fd_table_size = 0;
 }
 
 sector_t bcache_block_sectors(struct bcache *cache)
@@ -1179,13 +1202,13 @@ unsigned bcache_max_prefetches(struct bcache *cache)
 	return cache->max_io;
 }
 
-void bcache_prefetch(struct bcache *cache, int fd, block_address i)
+void bcache_prefetch(struct bcache *cache, int di, block_address i)
 {
-	struct block *b = _block_lookup(cache, fd, i);
+	struct block *b = _block_lookup(cache, di, i);
 
 	if (!b) {
 		if (cache->nr_io_pending < cache->max_io) {
-			b = _new_block(cache, fd, i, false);
+			b = _new_block(cache, di, i, false);
 			if (b) {
 				cache->prefetches++;
 				_issue_read(b);
@@ -1203,12 +1226,15 @@ static void _recycle_block(struct bcache *cache, struct block *b)
 	_free_block(b);
 }
 
-bool bcache_get(struct bcache *cache, int fd, block_address i,
+bool bcache_get(struct bcache *cache, int di, block_address i,
 	        unsigned flags, struct block **result)
 {
 	struct block *b;
 
-	b = _lookup_or_read_block(cache, fd, i, flags);
+	if (di >= _fd_table_size)
+		goto bad;
+
+	b = _lookup_or_read_block(cache, di, i, flags);
 	if (b) {
 		if (b->error) {
 			if (b->io_dir == DIR_READ) {
@@ -1227,10 +1253,10 @@ bool bcache_get(struct bcache *cache, int fd, block_address i,
 		*result = b;
 		return true;
 	}
-
+bad:
 	*result = NULL;
 
-	log_error("bcache failed to get block %u fd %d", (uint32_t) i, fd);
+	log_error("bcache failed to get block %u di %d", (uint32_t) i, di);
 	return false;
 }
 
@@ -1294,7 +1320,7 @@ static bool _invalidate_block(struct bcache *cache, struct block *b)
 
 	if (b->ref_count) {
 		log_warn("bcache_invalidate: block (%d, %llu) still held",
-			 b->fd, (unsigned long long) b->index);
+			 b->di, (unsigned long long) b->index);
 		return false;
 	}
 
@@ -1311,9 +1337,9 @@ static bool _invalidate_block(struct bcache *cache, struct block *b)
 	return true;
 }
 
-bool bcache_invalidate(struct bcache *cache, int fd, block_address i)
+bool bcache_invalidate(struct bcache *cache, int di, block_address i)
 {
-	return _invalidate_block(cache, _block_lookup(cache, fd, i));
+	return _invalidate_block(cache, _block_lookup(cache, di, i));
 }
 
 //----------------------------------------------------------------
@@ -1342,14 +1368,14 @@ static bool _invalidate_v(struct radix_tree_iterator *it,
 
 	if (b->error || _test_flags(b, BF_DIRTY)) {
         	log_warn("bcache_invalidate: block (%d, %llu) still dirty",
-                         b->fd, (unsigned long long) b->index);
+                         b->di, (unsigned long long) b->index);
         	iit->success = false;
         	return true;
 	}
 
 	if (b->ref_count) {
 		log_warn("bcache_invalidate: block (%d, %llu) still held",
-			 b->fd, (unsigned long long) b->index);
+			 b->di, (unsigned long long) b->index);
 		iit->success = false;
 		return true;
 	}
@@ -1362,24 +1388,24 @@ static bool _invalidate_v(struct radix_tree_iterator *it,
 	return true;
 }
 
-bool bcache_invalidate_fd(struct bcache *cache, int fd)
+bool bcache_invalidate_di(struct bcache *cache, int di)
 {
         union key k;
 	struct invalidate_iterator it;
 
-	k.parts.fd = fd;
+	k.parts.di = di;
 
 	it.it.visit = _writeback_v;
-	radix_tree_iterate(cache->rtree, k.bytes, k.bytes + sizeof(k.parts.fd), &it.it);
+	radix_tree_iterate(cache->rtree, k.bytes, k.bytes + sizeof(k.parts.di), &it.it);
 
 	_wait_all(cache);
 
 	it.success = true;
 	it.it.visit = _invalidate_v;
-	radix_tree_iterate(cache->rtree, k.bytes, k.bytes + sizeof(k.parts.fd), &it.it);
+	radix_tree_iterate(cache->rtree, k.bytes, k.bytes + sizeof(k.parts.di), &it.it);
 
 	if (it.success)
-		radix_tree_remove_prefix(cache->rtree, k.bytes, k.bytes + sizeof(k.parts.fd));
+		radix_tree_remove_prefix(cache->rtree, k.bytes, k.bytes + sizeof(k.parts.di));
 
 	return it.success;
 }
@@ -1393,7 +1419,7 @@ static bool _abort_v(struct radix_tree_iterator *it,
 
 	if (b->ref_count) {
 		log_fatal("bcache_abort: block (%d, %llu) still held",
-			 b->fd, (unsigned long long) b->index);
+			 b->di, (unsigned long long) b->index);
 		return true;
 	}
 
@@ -1405,35 +1431,91 @@ static bool _abort_v(struct radix_tree_iterator *it,
 	return true;
 }
 
-void bcache_abort_fd(struct bcache *cache, int fd)
+void bcache_abort_di(struct bcache *cache, int di)
 {
         union key k;
 	struct radix_tree_iterator it;
 
-	k.parts.fd = fd;
+	k.parts.di = di;
 
 	it.visit = _abort_v;
-	radix_tree_iterate(cache->rtree, k.bytes, k.bytes + sizeof(k.parts.fd), &it);
-	radix_tree_remove_prefix(cache->rtree, k.bytes, k.bytes + sizeof(k.parts.fd));
+	radix_tree_iterate(cache->rtree, k.bytes, k.bytes + sizeof(k.parts.di), &it);
+	radix_tree_remove_prefix(cache->rtree, k.bytes, k.bytes + sizeof(k.parts.di));
 }
 
 //----------------------------------------------------------------
 
-void bcache_set_last_byte(struct bcache *cache, int fd, uint64_t offset, int sector_size)
+void bcache_set_last_byte(struct bcache *cache, int di, uint64_t offset, int sector_size)
 {
-	_last_byte_fd = fd;
+	_last_byte_di = di;
 	_last_byte_offset = offset;
 	_last_byte_sector_size = sector_size;
 	if (!sector_size)
 		_last_byte_sector_size = 512;
 }
 
-void bcache_unset_last_byte(struct bcache *cache, int fd)
+void bcache_unset_last_byte(struct bcache *cache, int di)
 {
-	if (_last_byte_fd == fd) {
-		_last_byte_fd = 0;
+	if (_last_byte_di == di) {
+		_last_byte_di = 0;
 		_last_byte_offset = 0;
 		_last_byte_sector_size = 0;
 	}
 }
 
+int bcache_set_fd(int fd)
+{
+	int *new_table = NULL;
+	int new_size = 0;
+	int i;
+
+ retry:
+	for (i = 0; i < _fd_table_size; i++) {
+		if (_fd_table[i] == -1) {
+			_fd_table[i] = fd;
+			return i;
+		}
+	}
+
+	/* already tried once, shouldn't happen */
+	if (new_size)
+		return -1;
+
+	new_size = _fd_table_size + FD_TABLE_INC;
+
+	new_table = realloc(_fd_table, sizeof(int) * new_size);
+	if (!new_table) {
+		log_error("Cannot extend bcache fd table");
+		return -1;
+	}
+
+	for (i = _fd_table_size; i < new_size; i++)
+		new_table[i] = -1;
+
+	_fd_table = new_table;
+	_fd_table_size = new_size;
+
+	goto retry;
+}
+
+/*
+ * Should we check for unflushed or inprogress io on an fd
+ * prior to doing clear_fd or change_fd?  (To catch mistakes;
+ * the caller should be smart enough to not do that.)
+ */
+
+void bcache_clear_fd(int di)
+{
+	if (di >= _fd_table_size)
+		return;
+	_fd_table[di] = -1;
+}
+
+int bcache_change_fd(int di, int fd)
+{
+	if (di >= _fd_table_size)
+		return -1;
+	_fd_table[di] = fd;
+	return 1;
+}
+
diff --git a/lib/device/bcache.h b/lib/device/bcache.h
index 2950afa69..f437c45e1 100644
--- a/lib/device/bcache.h
+++ b/lib/device/bcache.h
@@ -34,7 +34,7 @@ typedef void io_complete_fn(void *context, int io_error);
 
 struct io_engine {
 	void (*destroy)(struct io_engine *e);
-	bool (*issue)(struct io_engine *e, enum dir d, int fd,
+	bool (*issue)(struct io_engine *e, enum dir d, int di,
 		      sector_t sb, sector_t se, void *data, void *context);
 	bool (*wait)(struct io_engine *e, io_complete_fn fn);
 	unsigned (*max_io)(struct io_engine *e);
@@ -48,7 +48,7 @@ struct io_engine *create_sync_io_engine(void);
 struct bcache;
 struct block {
 	/* clients may only access these three fields */
-	int fd;
+	int di;
 	uint64_t index;
 	void *data;
 
@@ -106,12 +106,12 @@ unsigned bcache_max_prefetches(struct bcache *cache);
  * they complete.  But we're talking a very small difference, and it's worth it
  * to keep callbacks out of this interface.
  */
-void bcache_prefetch(struct bcache *cache, int fd, block_address index);
+void bcache_prefetch(struct bcache *cache, int di, block_address index);
 
 /*
  * Returns true on success.
  */
-bool bcache_get(struct bcache *cache, int fd, block_address index,
+bool bcache_get(struct bcache *cache, int di, block_address index,
 	        unsigned flags, struct block **result);
 void bcache_put(struct block *b);
 
@@ -129,38 +129,42 @@ bool bcache_flush(struct bcache *cache);
  * 
  * If the block is currently held false will be returned.
  */
-bool bcache_invalidate(struct bcache *cache, int fd, block_address index);
+bool bcache_invalidate(struct bcache *cache, int di, block_address index);
 
 /*
  * Invalidates all blocks on the given descriptor.  Call this before closing
  * the descriptor to make sure everything is written back.
  */
-bool bcache_invalidate_fd(struct bcache *cache, int fd);
+bool bcache_invalidate_di(struct bcache *cache, int di);
 
 /*
  * Call this function if flush, or invalidate fail and you do not
  * wish to retry the writes.  This will throw away any dirty data
- * not written.  If any blocks for fd are held, then it will call
+ * not written.  If any blocks for di are held, then it will call
  * abort().
  */
-void bcache_abort_fd(struct bcache *cache, int fd);
+void bcache_abort_di(struct bcache *cache, int di);
 
 //----------------------------------------------------------------
 // The next four functions are utilities written in terms of the above api.
  
 // Prefetches the blocks neccessary to satisfy a byte range.
-void bcache_prefetch_bytes(struct bcache *cache, int fd, uint64_t start, size_t len);
+void bcache_prefetch_bytes(struct bcache *cache, int di, uint64_t start, size_t len);
 
 // Reads, writes and zeroes bytes.  Returns false if errors occur.
-bool bcache_read_bytes(struct bcache *cache, int fd, uint64_t start, size_t len, void *data);
-bool bcache_write_bytes(struct bcache *cache, int fd, uint64_t start, size_t len, void *data);
-bool bcache_zero_bytes(struct bcache *cache, int fd, uint64_t start, size_t len);
-bool bcache_set_bytes(struct bcache *cache, int fd, uint64_t start, size_t len, uint8_t val);
-bool bcache_invalidate_bytes(struct bcache *cache, int fd, uint64_t start, size_t len);
+bool bcache_read_bytes(struct bcache *cache, int di, uint64_t start, size_t len, void *data);
+bool bcache_write_bytes(struct bcache *cache, int di, uint64_t start, size_t len, void *data);
+bool bcache_zero_bytes(struct bcache *cache, int di, uint64_t start, size_t len);
+bool bcache_set_bytes(struct bcache *cache, int di, uint64_t start, size_t len, uint8_t val);
+bool bcache_invalidate_bytes(struct bcache *cache, int di, uint64_t start, size_t len);
 
-void bcache_set_last_byte(struct bcache *cache, int fd, uint64_t offset, int sector_size);
-void bcache_unset_last_byte(struct bcache *cache, int fd);
+void bcache_set_last_byte(struct bcache *cache, int di, uint64_t offset, int sector_size);
+void bcache_unset_last_byte(struct bcache *cache, int di);
 
 //----------------------------------------------------------------
 
+int bcache_set_fd(int fd); /* returns di */
+void bcache_clear_fd(int di);
+int bcache_change_fd(int di, int fd);
+
 #endif
diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index d4e2658aa..7f5e55e8c 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -66,6 +66,7 @@ static void _dev_init(struct device *dev)
 {
 	dev->fd = -1;
 	dev->bcache_fd = -1;
+	dev->bcache_di = -1;
 	dev->read_ahead = -1;
 
 	dev->ext.enabled = 0;
diff --git a/lib/device/device.h b/lib/device/device.h
index bd3b35557..2706f28e1 100644
--- a/lib/device/device.h
+++ b/lib/device/device.h
@@ -71,6 +71,7 @@ struct device {
 	int logical_block_size;  /* From BLKSSZGET: lowest possible block size that the storage device can address */
 	int read_ahead;
 	int bcache_fd;
+	int bcache_di;
 	uint32_t flags;
 	unsigned size_seqno;
 	uint64_t size;
diff --git a/lib/label/label.c b/lib/label/label.c
index 3b2011f6e..afe342629 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -467,10 +467,11 @@ static int _scan_dev_open(struct device *dev)
 	struct dm_list *name_list;
 	struct dm_str_list *name_sl;
 	const char *name;
+	const char *modestr;
 	struct stat sbuf;
 	int retried = 0;
 	int flags = 0;
-	int fd;
+	int fd, di;
 
 	if (!dev)
 		return 0;
@@ -481,10 +482,10 @@ static int _scan_dev_open(struct device *dev)
 		dev->flags &= ~DEV_IN_BCACHE;
 	}
 
-	if (dev->bcache_fd > 0) {
+	if (dev->bcache_di != -1) {
 		/* Shouldn't happen */
-		log_error("Device open %s already open with fd %d",
-			  dev_name(dev), dev->bcache_fd);
+		log_error("Device open %s already open with di %d fd %d",
+			  dev_name(dev), dev->bcache_di, dev->bcache_fd);
 		return 0;
 	}
 
@@ -514,10 +515,13 @@ static int _scan_dev_open(struct device *dev)
 	if (dev->flags & DEV_BCACHE_EXCL) {
 		flags |= O_EXCL;
 		flags |= O_RDWR;
+		modestr = "rwex";
 	} else if (dev->flags & DEV_BCACHE_WRITE) {
 		flags |= O_RDWR;
+		modestr = "rw";
 	} else {
 		flags |= O_RDONLY;
+		modestr = "ro";
 	}
 
 retry_open:
@@ -568,6 +572,20 @@ retry_open:
 
 	dev->flags |= DEV_IN_BCACHE;
 	dev->bcache_fd = fd;
+
+	di = bcache_set_fd(fd);
+
+	if (di == -1) {
+		log_error("Failed to set bcache fd.");
+		close(fd);
+		dev->bcache_fd = -1;
+		return 0;
+	}
+
+	log_debug("open %s %s di %d fd %d", dev_name(dev), modestr, di, fd);
+
+	dev->bcache_di = di;
+
 	return 1;
 }
 
@@ -578,15 +596,21 @@ static int _scan_dev_close(struct device *dev)
 
 	dev->flags &= ~DEV_IN_BCACHE;
 	dev->flags &= ~DEV_BCACHE_EXCL;
+	dev->flags &= ~DEV_BCACHE_WRITE;
 
-	if (dev->bcache_fd < 0) {
+	if (dev->bcache_di == -1) {
 		log_error("scan_dev_close %s already closed", dev_name(dev));
 		return 0;
 	}
 
+	bcache_clear_fd(dev->bcache_di);
+
 	if (close(dev->bcache_fd))
 		log_warn("close %s errno %d", dev_name(dev), errno);
+
 	dev->bcache_fd = -1;
+	dev->bcache_di = -1;
+
 	return 1;
 }
 
@@ -623,10 +647,10 @@ static void _drop_bad_aliases(struct device *dev)
 
 // Like bcache_invalidate, only it throws any dirty data away if the
 // write fails.
-static void _invalidate_fd(struct bcache *cache, int fd)
+static void _invalidate_di(struct bcache *cache, int di)
 {
-	if (!bcache_invalidate_fd(cache, fd))
-		bcache_abort_fd(cache, fd);
+	if (!bcache_invalidate_di(cache, di))
+		bcache_abort_di(cache, di);
 }
 
 /*
@@ -689,7 +713,7 @@ static int _scan_list(struct cmd_context *cmd, struct dev_filter *f,
 			}
 		}
 
-		bcache_prefetch(scan_bcache, devl->dev->bcache_fd, 0);
+		bcache_prefetch(scan_bcache, devl->dev->bcache_di, 0);
 
 		rem_prefetches--;
 		submit_count++;
@@ -705,18 +729,18 @@ static int _scan_list(struct cmd_context *cmd, struct dev_filter *f,
 		scan_failed = 0;
 		is_lvm_device = 0;
 
-		if (!bcache_get(scan_bcache, devl->dev->bcache_fd, 0, 0, &bb)) {
+		if (!bcache_get(scan_bcache, devl->dev->bcache_di, 0, 0, &bb)) {
 			log_debug_devs("Scan failed to read %s.", dev_name(devl->dev));
 			scan_failed = 1;
 			scan_read_errors++;
 			scan_failed_count++;
 			lvmcache_del_dev(devl->dev);
 		} else {
-			log_debug_devs("Processing data from device %s %d:%d fd %d block %p",
+			log_debug_devs("Processing data from device %s %d:%d di %d block %p",
 				       dev_name(devl->dev),
 				       (int)MAJOR(devl->dev->dev),
 				       (int)MINOR(devl->dev->dev),
-				       devl->dev->bcache_fd, (void *)bb);
+				       devl->dev->bcache_di, (void *)bb);
 
 			ret = _process_block(cmd, f, devl->dev, bb, 0, 0, &is_lvm_device);
 
@@ -738,7 +762,7 @@ static int _scan_list(struct cmd_context *cmd, struct dev_filter *f,
 		 * drop it from bcache.
 		 */
 		if (scan_failed || !is_lvm_device) {
-			_invalidate_fd(scan_bcache, devl->dev->bcache_fd);
+			_invalidate_di(scan_bcache, devl->dev->bcache_di);
 			_scan_dev_close(devl->dev);
 		}
 
@@ -1229,20 +1253,16 @@ int label_scan_devs(struct cmd_context *cmd, struct dev_filter *f, struct dm_lis
 			return 0;
 	}
 
-	dm_list_iterate_items(devl, devs)
-		label_scan_invalidate(devl->dev);
+	dm_list_iterate_items(devl, devs) {
+		if (_in_bcache(devl->dev))
+			_invalidate_di(scan_bcache, devl->dev->bcache_di);
+	}
 
 	_scan_list(cmd, f, devs, NULL);
 
 	return 1;
 }
 
-/*
- * This function is used when the caller plans to write to the devs, so opening
- * them RW during rescan avoids needing to close and reopen with WRITE in
- * dev_write_bytes.
- */
-
 int label_scan_devs_rw(struct cmd_context *cmd, struct dev_filter *f, struct dm_list *devs)
 {
 	struct device_list *devl;
@@ -1253,11 +1273,8 @@ int label_scan_devs_rw(struct cmd_context *cmd, struct dev_filter *f, struct dm_
 	}
 
 	dm_list_iterate_items(devl, devs) {
-		label_scan_invalidate(devl->dev);
-		/*
-		 * With this flag set, _scan_dev_open() done by
-		 * _scan_list() will do open RW
-		 */
+		if (_in_bcache(devl->dev))
+			_invalidate_di(scan_bcache, devl->dev->bcache_di);
 		devl->dev->flags |= DEV_BCACHE_WRITE;
 	}
 
@@ -1278,6 +1295,7 @@ int label_scan_devs_excl(struct dm_list *devs)
 		 * _scan_list() will do open EXCL
 		 */
 		devl->dev->flags |= DEV_BCACHE_EXCL;
+		devl->dev->flags |= DEV_BCACHE_WRITE;
 	}
 
 	_scan_list(NULL, NULL, devs, &failed);
@@ -1290,7 +1308,7 @@ int label_scan_devs_excl(struct dm_list *devs)
 void label_scan_invalidate(struct device *dev)
 {
 	if (_in_bcache(dev)) {
-		_invalidate_fd(scan_bcache, dev->bcache_fd);
+		_invalidate_di(scan_bcache, dev->bcache_di);
 		_scan_dev_close(dev);
 	}
 }
@@ -1396,7 +1414,7 @@ int label_scan_setup_bcache(void)
  * This is needed to write to a new non-lvm device.
  * Scanning that dev would not keep it open or in
  * bcache, but to use bcache_write we need the dev
- * to be open so we can use dev->bcache_fd to write.
+ * to be open so we can use dev->bcache_di to write.
  */
 
 int label_scan_open(struct device *dev)
@@ -1409,9 +1427,8 @@ int label_scan_open(struct device *dev)
 int label_scan_open_excl(struct device *dev)
 {
 	if (_in_bcache(dev) && !(dev->flags & DEV_BCACHE_EXCL)) {
-		/* FIXME: avoid tossing out bcache blocks just to replace fd. */
-		log_debug("Close and reopen excl %s", dev_name(dev));
-		_invalidate_fd(scan_bcache, dev->bcache_fd);
+		log_debug("close and reopen excl %s", dev_name(dev));
+		_invalidate_di(scan_bcache, dev->bcache_di);
 		_scan_dev_close(dev);
 	}
 	dev->flags |= DEV_BCACHE_EXCL;
@@ -1422,9 +1439,8 @@ int label_scan_open_excl(struct device *dev)
 int label_scan_open_rw(struct device *dev)
 {
 	if (_in_bcache(dev) && !(dev->flags & DEV_BCACHE_WRITE)) {
-		/* FIXME: avoid tossing out bcache blocks just to replace fd. */
-		log_debug("Close and reopen rw %s", dev_name(dev));
-		_invalidate_fd(scan_bcache, dev->bcache_fd);
+		log_debug("close and reopen rw %s", dev_name(dev));
+		_invalidate_di(scan_bcache, dev->bcache_di);
 		_scan_dev_close(dev);
 	}
 	dev->flags |= DEV_BCACHE_WRITE;
@@ -1439,7 +1455,7 @@ bool dev_read_bytes(struct device *dev, uint64_t start, size_t len, void *data)
 		return false;
 	}
 
-	if (dev->bcache_fd <= 0) {
+	if (dev->bcache_di < 0) {
 		/* This is not often needed. */
 		if (!label_scan_open(dev)) {
 			log_error("Error opening device %s for reading@%llu length %u.",
@@ -1448,7 +1464,7 @@ bool dev_read_bytes(struct device *dev, uint64_t start, size_t len, void *data)
 		}
 	}
 
-	if (!bcache_read_bytes(scan_bcache, dev->bcache_fd, start, len, data)) {
+	if (!bcache_read_bytes(scan_bcache, dev->bcache_di, start, len, data)) {
 		log_error("Error reading device %s at %llu length %u.",
 			  dev_name(dev), (unsigned long long)start, (uint32_t)len);
 		label_scan_invalidate(dev);
@@ -1471,15 +1487,15 @@ bool dev_write_bytes(struct device *dev, uint64_t start, size_t len, void *data)
 
 	if (_in_bcache(dev) && !(dev->flags & DEV_BCACHE_WRITE)) {
 		/* FIXME: avoid tossing out bcache blocks just to replace fd. */
-		log_debug("Close and reopen to write %s", dev_name(dev));
-		_invalidate_fd(scan_bcache, dev->bcache_fd);
+		log_debug("close and reopen to write %s", dev_name(dev));
+		_invalidate_di(scan_bcache, dev->bcache_di);
 		_scan_dev_close(dev);
 
 		dev->flags |= DEV_BCACHE_WRITE;
 		label_scan_open(dev);
 	}
 
-	if (dev->bcache_fd <= 0) {
+	if (dev->bcache_di < 0) {
 		/* This is not often needed. */
 		dev->flags |= DEV_BCACHE_WRITE;
 		if (!label_scan_open(dev)) {
@@ -1489,7 +1505,7 @@ bool dev_write_bytes(struct device *dev, uint64_t start, size_t len, void *data)
 		}
 	}
 
-	if (!bcache_write_bytes(scan_bcache, dev->bcache_fd, start, len, data)) {
+	if (!bcache_write_bytes(scan_bcache, dev->bcache_di, start, len, data)) {
 		log_error("Error writing device %s at %llu length %u.",
 			  dev_name(dev), (unsigned long long)start, (uint32_t)len);
 		dev_unset_last_byte(dev);
@@ -1509,7 +1525,7 @@ bool dev_write_bytes(struct device *dev, uint64_t start, size_t len, void *data)
 
 bool dev_invalidate_bytes(struct device *dev, uint64_t start, size_t len)
 {
-	return bcache_invalidate_bytes(scan_bcache, dev->bcache_fd, start, len);
+	return bcache_invalidate_bytes(scan_bcache, dev->bcache_di, start, len);
 }
 
 bool dev_write_zeros(struct device *dev, uint64_t start, size_t len)
@@ -1530,14 +1546,13 @@ bool dev_set_bytes(struct device *dev, uint64_t start, size_t len, uint8_t val)
 	}
 
 	if (_in_bcache(dev) && !(dev->flags & DEV_BCACHE_WRITE)) {
-		/* FIXME: avoid tossing out bcache blocks just to replace fd. */
-		log_debug("Close and reopen to write %s", dev_name(dev));
-		_invalidate_fd(scan_bcache, dev->bcache_fd);
+		log_debug("close and reopen to write %s", dev_name(dev));
+		_invalidate_di(scan_bcache, dev->bcache_di);
 		_scan_dev_close(dev);
-		/* goes to label_scan_open() since bcache_fd < 0 */
+		/* goes to label_scan_open() since bcache_di < 0 */
 	}
 
-	if (dev->bcache_fd <= 0) {
+	if (dev->bcache_di == -1) {
 		/* This is not often needed. */
 		dev->flags |= DEV_BCACHE_WRITE;
 		if (!label_scan_open(dev)) {
@@ -1550,9 +1565,9 @@ bool dev_set_bytes(struct device *dev, uint64_t start, size_t len, uint8_t val)
 	dev_set_last_byte(dev, start + len);
 
 	if (!val)
-		rv = bcache_zero_bytes(scan_bcache, dev->bcache_fd, start, len);
+		rv = bcache_zero_bytes(scan_bcache, dev->bcache_di, start, len);
 	else
-		rv = bcache_set_bytes(scan_bcache, dev->bcache_fd, start, len, val);
+		rv = bcache_set_bytes(scan_bcache, dev->bcache_di, start, len, val);
 
 	if (!rv) {
 		log_error("Error writing device value %s at %llu length %u.",
@@ -1604,10 +1619,10 @@ void dev_set_last_byte(struct device *dev, uint64_t offset)
 		bs = 512;
 	}
 
-	bcache_set_last_byte(scan_bcache, dev->bcache_fd, offset, bs);
+	bcache_set_last_byte(scan_bcache, dev->bcache_di, offset, bs);
 }
 
 void dev_unset_last_byte(struct device *dev)
 {
-	bcache_unset_last_byte(scan_bcache, dev->bcache_fd);
+	bcache_unset_last_byte(scan_bcache, dev->bcache_di);
 }
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 8b8c491c0..d4a069cd0 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -4732,6 +4732,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 	 * we check that they are unchanged in all mdas.  This added checking is
 	 * probably unnecessary; all commands could likely just check a single mda.
 	 */
+
 	if (lvmcache_scan_mismatch(cmd, vgname, vgid) || _scan_text_mismatch(cmd, vgname, vgid)) {
 		log_debug_metadata("Rescanning devices for %s %s", vgname, writing ? "rw" : "");
 		if (writing)
diff --git a/test/unit/bcache_t.c b/test/unit/bcache_t.c
index 2a8f931e4..9c4d102de 100644
--- a/test/unit/bcache_t.c
+++ b/test/unit/bcache_t.c
@@ -46,7 +46,7 @@ struct mock_call {
 
 	bool match_args;
 	enum dir d;
-	int fd;
+	int di;
 	block_address b;
 	bool issue_r;
 	bool wait_r;
@@ -54,7 +54,7 @@ struct mock_call {
 
 struct mock_io {
 	struct dm_list list;
-	int fd;
+	int di;
 	sector_t sb;
 	sector_t se;
 	void *data;
@@ -86,13 +86,13 @@ static void _expect(struct mock_engine *e, enum method m)
 	dm_list_add(&e->expected_calls, &mc->list);
 }
 
-static void _expect_read(struct mock_engine *e, int fd, block_address b)
+static void _expect_read(struct mock_engine *e, int di, block_address b)
 {
 	struct mock_call *mc = malloc(sizeof(*mc));
 	mc->m = E_ISSUE;
 	mc->match_args = true;
 	mc->d = DIR_READ;
-	mc->fd = fd;
+	mc->di = di;
 	mc->b = b;
 	mc->issue_r = true;
 	mc->wait_r = true;
@@ -109,65 +109,65 @@ static void _expect_read_any(struct mock_engine *e)
 	dm_list_add(&e->expected_calls, &mc->list);
 }
 
-static void _expect_write(struct mock_engine *e, int fd, block_address b)
+static void _expect_write(struct mock_engine *e, int di, block_address b)
 {
 	struct mock_call *mc = malloc(sizeof(*mc));
 	mc->m = E_ISSUE;
 	mc->match_args = true;
 	mc->d = DIR_WRITE;
-	mc->fd = fd;
+	mc->di = di;
 	mc->b = b;
 	mc->issue_r = true;
 	mc->wait_r = true;
 	dm_list_add(&e->expected_calls, &mc->list);
 }
 
-static void _expect_read_bad_issue(struct mock_engine *e, int fd, block_address b)
+static void _expect_read_bad_issue(struct mock_engine *e, int di, block_address b)
 {
 	struct mock_call *mc = malloc(sizeof(*mc));
 	mc->m = E_ISSUE;
 	mc->match_args = true;
 	mc->d = DIR_READ;
-	mc->fd = fd;
+	mc->di = di;
 	mc->b = b;
 	mc->issue_r = false;
 	mc->wait_r = true;
 	dm_list_add(&e->expected_calls, &mc->list);
 }
 
-static void _expect_write_bad_issue(struct mock_engine *e, int fd, block_address b)
+static void _expect_write_bad_issue(struct mock_engine *e, int di, block_address b)
 {
 	struct mock_call *mc = malloc(sizeof(*mc));
 	mc->m = E_ISSUE;
 	mc->match_args = true;
 	mc->d = DIR_WRITE;
-	mc->fd = fd;
+	mc->di = di;
 	mc->b = b;
 	mc->issue_r = false;
 	mc->wait_r = true;
 	dm_list_add(&e->expected_calls, &mc->list);
 }
 
-static void _expect_read_bad_wait(struct mock_engine *e, int fd, block_address b)
+static void _expect_read_bad_wait(struct mock_engine *e, int di, block_address b)
 {
 	struct mock_call *mc = malloc(sizeof(*mc));
 	mc->m = E_ISSUE;
 	mc->match_args = true;
 	mc->d = DIR_READ;
-	mc->fd = fd;
+	mc->di = di;
 	mc->b = b;
 	mc->issue_r = true;
 	mc->wait_r = false;
 	dm_list_add(&e->expected_calls, &mc->list);
 }
 
-static void _expect_write_bad_wait(struct mock_engine *e, int fd, block_address b)
+static void _expect_write_bad_wait(struct mock_engine *e, int di, block_address b)
 {
 	struct mock_call *mc = malloc(sizeof(*mc));
 	mc->m = E_ISSUE;
 	mc->match_args = true;
 	mc->d = DIR_WRITE;
-	mc->fd = fd;
+	mc->di = di;
 	mc->b = b;
 	mc->issue_r = true;
 	mc->wait_r = false;
@@ -227,7 +227,7 @@ static void _mock_destroy(struct io_engine *e)
 	free(_to_mock(e));
 }
 
-static bool _mock_issue(struct io_engine *e, enum dir d, int fd,
+static bool _mock_issue(struct io_engine *e, enum dir d, int di,
 	      		sector_t sb, sector_t se, void *data, void *context)
 {
 	bool r, wait_r;
@@ -238,7 +238,7 @@ static bool _mock_issue(struct io_engine *e, enum dir d, int fd,
 	mc = _match_pop(me, E_ISSUE);
 	if (mc->match_args) {
 		T_ASSERT(d == mc->d);
-		T_ASSERT(fd == mc->fd);
+		T_ASSERT(di == mc->di);
 		T_ASSERT(sb == mc->b * me->block_size);
 		T_ASSERT(se == (mc->b + 1) * me->block_size);
 	}
@@ -251,7 +251,7 @@ static bool _mock_issue(struct io_engine *e, enum dir d, int fd,
 		if (!io)
 			abort();
 
-		io->fd = fd;
+		io->di = di;
 		io->sb = sb;
 		io->se = se;
 		io->data = data;
@@ -419,18 +419,18 @@ static void test_get_triggers_read(void *context)
 {
 	struct fixture *f = context;
 
-	int fd = 17;   // arbitrary key
+	int di = 17;   // arbitrary key
 	struct block *b;
 
-	_expect_read(f->me, fd, 0);
+	_expect_read(f->me, di, 0);
 	_expect(f->me, E_WAIT);
-	T_ASSERT(bcache_get(f->cache, fd, 0, 0, &b));
+	T_ASSERT(bcache_get(f->cache, di, 0, 0, &b));
 	bcache_put(b);
 
-	_expect_read(f->me, fd, 1);
+	_expect_read(f->me, di, 1);
 	_expect(f->me, E_WAIT);
-	T_ASSERT(bcache_get(f->cache, fd, 1, GF_DIRTY, &b));
-	_expect_write(f->me, fd, 1);
+	T_ASSERT(bcache_get(f->cache, di, 1, GF_DIRTY, &b));
+	_expect_write(f->me, di, 1);
 	_expect(f->me, E_WAIT);
 	bcache_put(b);
 }
@@ -439,14 +439,14 @@ static void test_repeated_reads_are_cached(void *context)
 {
 	struct fixture *f = context;
 
-	int fd = 17;   // arbitrary key
+	int di = 17;   // arbitrary key
 	unsigned i;
 	struct block *b;
 
-	_expect_read(f->me, fd, 0);
+	_expect_read(f->me, di, 0);
 	_expect(f->me, E_WAIT);
 	for (i = 0; i < 100; i++) {
-		T_ASSERT(bcache_get(f->cache, fd, 0, 0, &b));
+		T_ASSERT(bcache_get(f->cache, di, 0, 0, &b));
 		bcache_put(b);
 	}
 }
@@ -459,21 +459,21 @@ static void test_block_gets_evicted_with_many_reads(void *context)
 	struct bcache *cache = f->cache;
 	const unsigned nr_cache_blocks = 16;
 
-	int fd = 17;   // arbitrary key
+	int di = 17;   // arbitrary key
 	unsigned i;
 	struct block *b;
 
 	for (i = 0; i < nr_cache_blocks; i++) {
-		_expect_read(me, fd, i);
+		_expect_read(me, di, i);
 		_expect(me, E_WAIT);
-		T_ASSERT(bcache_get(cache, fd, i, 0, &b));
+		T_ASSERT(bcache_get(cache, di, i, 0, &b));
 		bcache_put(b);
 	}
 
 	// Not enough cache blocks to hold this one
-	_expect_read(me, fd, nr_cache_blocks);
+	_expect_read(me, di, nr_cache_blocks);
 	_expect(me, E_WAIT);
-	T_ASSERT(bcache_get(cache, fd, nr_cache_blocks, 0, &b));
+	T_ASSERT(bcache_get(cache, di, nr_cache_blocks, 0, &b));
 	bcache_put(b);
 
 	// Now if we run through we should find one block has been
@@ -482,7 +482,7 @@ static void test_block_gets_evicted_with_many_reads(void *context)
 	_expect_read_any(me);
 	_expect(me, E_WAIT);
 	for (i = nr_cache_blocks; i; i--) {
-		T_ASSERT(bcache_get(cache, fd, i - 1, 0, &b));
+		T_ASSERT(bcache_get(cache, di, i - 1, 0, &b));
 		bcache_put(b);
 	}
 }
@@ -494,20 +494,20 @@ static void test_prefetch_issues_a_read(void *context)
 	struct bcache *cache = f->cache;
 	const unsigned nr_cache_blocks = 16;
 
-	int fd = 17;   // arbitrary key
+	int di = 17;   // arbitrary key
 	unsigned i;
 	struct block *b;
 
 	for (i = 0; i < nr_cache_blocks; i++) {
 		// prefetch should not wait
-		_expect_read(me, fd, i);
-		bcache_prefetch(cache, fd, i);
+		_expect_read(me, di, i);
+		bcache_prefetch(cache, di, i);
 	}
 	_no_outstanding_expectations(me);
 
 	for (i = 0; i < nr_cache_blocks; i++) {
 		_expect(me, E_WAIT);
-		T_ASSERT(bcache_get(cache, fd, i, 0, &b));
+		T_ASSERT(bcache_get(cache, di, i, 0, &b));
 		bcache_put(b);
 	}
 }
@@ -519,14 +519,14 @@ static void test_too_many_prefetches_does_not_trigger_a_wait(void *context)
 	struct bcache *cache = f->cache;
 
 	const unsigned nr_cache_blocks = 16;
-	int fd = 17;   // arbitrary key
+	int di = 17;   // arbitrary key
 	unsigned i;
 
 	for (i = 0; i < 10 * nr_cache_blocks; i++) {
 		// prefetch should not wait
 		if (i < nr_cache_blocks)
-			_expect_read(me, fd, i);
-		bcache_prefetch(cache, fd, i);
+			_expect_read(me, di, i);
+		bcache_prefetch(cache, di, i);
 	}
 
 	// Destroy will wait for any in flight IO triggered by prefetches.
@@ -540,17 +540,17 @@ static void test_dirty_data_gets_written_back(void *context)
 	struct mock_engine *me = f->me;
 	struct bcache *cache = f->cache;
 
-	int fd = 17;   // arbitrary key
+	int di = 17;   // arbitrary key
 	struct block *b;
 
 	// Expect the read
-	_expect_read(me, fd, 0);
+	_expect_read(me, di, 0);
 	_expect(me, E_WAIT);
-	T_ASSERT(bcache_get(cache, fd, 0, GF_DIRTY, &b));
+	T_ASSERT(bcache_get(cache, di, 0, GF_DIRTY, &b));
 	bcache_put(b);
 
 	// Expect the write
-	_expect_write(me, fd, 0);
+	_expect_write(me, di, 0);
 	_expect(me, E_WAIT);
 }
 
@@ -560,15 +560,15 @@ static void test_zeroed_data_counts_as_dirty(void *context)
 	struct mock_engine *me = f->me;
 	struct bcache *cache = f->cache;
 
-	int fd = 17;   // arbitrary key
+	int di = 17;   // arbitrary key
 	struct block *b;
 
 	// No read
-	T_ASSERT(bcache_get(cache, fd, 0, GF_ZERO, &b));
+	T_ASSERT(bcache_get(cache, di, 0, GF_ZERO, &b));
 	bcache_put(b);
 
 	// Expect the write
-	_expect_write(me, fd, 0);
+	_expect_write(me, di, 0);
 	_expect(me, E_WAIT);
 }
 
@@ -579,24 +579,24 @@ static void test_flush_waits_for_all_dirty(void *context)
 	struct bcache *cache = f->cache;
 
 	const unsigned count = 16;
-	int fd = 17;   // arbitrary key
+	int di = 17;   // arbitrary key
 	unsigned i;
 	struct block *b;
 
 	for (i = 0; i < count; i++) {
 		if (i % 2) {
-			T_ASSERT(bcache_get(cache, fd, i, GF_ZERO, &b));
+			T_ASSERT(bcache_get(cache, di, i, GF_ZERO, &b));
 		} else {
-			_expect_read(me, fd, i);
+			_expect_read(me, di, i);
 			_expect(me, E_WAIT);
-			T_ASSERT(bcache_get(cache, fd, i, 0, &b));
+			T_ASSERT(bcache_get(cache, di, i, 0, &b));
 		}
 		bcache_put(b);
 	}
 
 	for (i = 0; i < count; i++) {
 		if (i % 2)
-			_expect_write(me, fd, i);
+			_expect_write(me, di, i);
 	}
 
 	for (i = 0; i < count; i++) {
@@ -610,7 +610,7 @@ static void test_flush_waits_for_all_dirty(void *context)
 
 static void test_multiple_files(void *context)
 {
-	static int _fds[] = {1, 128, 345, 678, 890};
+	static int _dis[] = {1, 128, 345, 678, 890};
 
 	struct fixture *f = context;
 	struct mock_engine *me = f->me;
@@ -618,11 +618,11 @@ static void test_multiple_files(void *context)
 	struct block *b;
 	unsigned i;
 
-	for (i = 0; i < DM_ARRAY_SIZE(_fds); i++) {
-		_expect_read(me, _fds[i], 0);
+	for (i = 0; i < DM_ARRAY_SIZE(_dis); i++) {
+		_expect_read(me, _dis[i], 0);
 		_expect(me, E_WAIT);
 
-		T_ASSERT(bcache_get(cache, _fds[i], 0, 0, &b));
+		T_ASSERT(bcache_get(cache, _dis[i], 0, 0, &b));
 		bcache_put(b);
 	}
 }
@@ -644,14 +644,14 @@ static void test_read_bad_issue_intermittent(void *context)
 	struct mock_engine *me = f->me;
 	struct bcache *cache = f->cache;
 	struct block *b;
-	int fd = 17;
+	int di = 17;
 
-	_expect_read_bad_issue(me, fd, 0);
-	T_ASSERT(!bcache_get(cache, fd, 0, 0, &b));
+	_expect_read_bad_issue(me, di, 0);
+	T_ASSERT(!bcache_get(cache, di, 0, 0, &b));
 
-	_expect_read(me, fd, 0);
+	_expect_read(me, di, 0);
 	_expect(me, E_WAIT);
-	T_ASSERT(bcache_get(cache, fd, 0, 0, &b));
+	T_ASSERT(bcache_get(cache, di, 0, 0, &b));
 	bcache_put(b);
 }
 
@@ -661,11 +661,11 @@ static void test_read_bad_wait(void *context)
 	struct mock_engine *me = f->me;
 	struct bcache *cache = f->cache;
 	struct block *b;
-	int fd = 17;
+	int di = 17;
 
-	_expect_read_bad_wait(me, fd, 0);
+	_expect_read_bad_wait(me, di, 0);
 	_expect(me, E_WAIT);
-	T_ASSERT(!bcache_get(cache, fd, 0, 0, &b));
+	T_ASSERT(!bcache_get(cache, di, 0, 0, &b));
 }
 
 static void test_read_bad_wait_intermittent(void *context)
@@ -674,15 +674,15 @@ static void test_read_bad_wait_intermittent(void *context)
 	struct mock_engine *me = f->me;
 	struct bcache *cache = f->cache;
 	struct block *b;
-	int fd = 17;
+	int di = 17;
 
-	_expect_read_bad_wait(me, fd, 0);
+	_expect_read_bad_wait(me, di, 0);
 	_expect(me, E_WAIT);
-	T_ASSERT(!bcache_get(cache, fd, 0, 0, &b));
+	T_ASSERT(!bcache_get(cache, di, 0, 0, &b));
 
-	_expect_read(me, fd, 0);
+	_expect_read(me, di, 0);
 	_expect(me, E_WAIT);
-	T_ASSERT(bcache_get(cache, fd, 0, 0, &b));
+	T_ASSERT(bcache_get(cache, di, 0, 0, &b));
 	bcache_put(b);
 }
 
@@ -692,15 +692,15 @@ static void test_write_bad_issue_stops_flush(void *context)
 	struct mock_engine *me = f->me;
 	struct bcache *cache = f->cache;
 	struct block *b;
-	int fd = 17;
+	int di = 17;
 
-	T_ASSERT(bcache_get(cache, fd, 0, GF_ZERO, &b));
-	_expect_write_bad_issue(me, fd, 0);
+	T_ASSERT(bcache_get(cache, di, 0, GF_ZERO, &b));
+	_expect_write_bad_issue(me, di, 0);
 	bcache_put(b);
 	T_ASSERT(!bcache_flush(cache));
 
 	// we'll let it succeed the second time
-	_expect_write(me, fd, 0);
+	_expect_write(me, di, 0);
 	_expect(me, E_WAIT);
 	T_ASSERT(bcache_flush(cache));
 }
@@ -711,16 +711,16 @@ static void test_write_bad_io_stops_flush(void *context)
 	struct mock_engine *me = f->me;
 	struct bcache *cache = f->cache;
 	struct block *b;
-	int fd = 17;
+	int di = 17;
 
-	T_ASSERT(bcache_get(cache, fd, 0, GF_ZERO, &b));
-	_expect_write_bad_wait(me, fd, 0);
+	T_ASSERT(bcache_get(cache, di, 0, GF_ZERO, &b));
+	_expect_write_bad_wait(me, di, 0);
 	_expect(me, E_WAIT);
 	bcache_put(b);
 	T_ASSERT(!bcache_flush(cache));
 
 	// we'll let it succeed the second time
-	_expect_write(me, fd, 0);
+	_expect_write(me, di, 0);
 	_expect(me, E_WAIT);
 	T_ASSERT(bcache_flush(cache));
 }
@@ -729,9 +729,9 @@ static void test_invalidate_not_present(void *context)
 {
 	struct fixture *f = context;
 	struct bcache *cache = f->cache;
-	int fd = 17;
+	int di = 17;
 
-	T_ASSERT(bcache_invalidate(cache, fd, 0));
+	T_ASSERT(bcache_invalidate(cache, di, 0));
 }
 
 static void test_invalidate_present(void *context)
@@ -740,14 +740,14 @@ static void test_invalidate_present(void *context)
 	struct mock_engine *me = f->me;
 	struct bcache *cache = f->cache;
 	struct block *b;
-	int fd = 17;
+	int di = 17;
 
-	_expect_read(me, fd, 0);
+	_expect_read(me, di, 0);
 	_expect(me, E_WAIT);
-	T_ASSERT(bcache_get(cache, fd, 0, 0, &b));
+	T_ASSERT(bcache_get(cache, di, 0, 0, &b));
 	bcache_put(b);
 
-	T_ASSERT(bcache_invalidate(cache, fd, 0));
+	T_ASSERT(bcache_invalidate(cache, di, 0));
 }
 
 static void test_invalidate_after_read_error(void *context)
@@ -756,11 +756,11 @@ static void test_invalidate_after_read_error(void *context)
 	struct mock_engine *me = f->me;
 	struct bcache *cache = f->cache;
 	struct block *b;
-	int fd = 17;
+	int di = 17;
 
-	_expect_read_bad_issue(me, fd, 0);
-	T_ASSERT(!bcache_get(cache, fd, 0, 0, &b));
-	T_ASSERT(bcache_invalidate(cache, fd, 0));
+	_expect_read_bad_issue(me, di, 0);
+	T_ASSERT(!bcache_get(cache, di, 0, 0, &b));
+	T_ASSERT(bcache_invalidate(cache, di, 0));
 }
 
 static void test_invalidate_after_write_error(void *context)
@@ -769,25 +769,25 @@ static void test_invalidate_after_write_error(void *context)
 	struct mock_engine *me = f->me;
 	struct bcache *cache = f->cache;
 	struct block *b;
-	int fd = 17;
+	int di = 17;
 
-	T_ASSERT(bcache_get(cache, fd, 0, GF_ZERO, &b));
+	T_ASSERT(bcache_get(cache, di, 0, GF_ZERO, &b));
 	bcache_put(b);
 
 	// invalidate should fail if the write fails
-	_expect_write_bad_wait(me, fd, 0);
+	_expect_write_bad_wait(me, di, 0);
 	_expect(me, E_WAIT);
-	T_ASSERT(!bcache_invalidate(cache, fd, 0));
+	T_ASSERT(!bcache_invalidate(cache, di, 0));
 
 	// and should succeed if the write does
-	_expect_write(me, fd, 0);
+	_expect_write(me, di, 0);
 	_expect(me, E_WAIT);
-	T_ASSERT(bcache_invalidate(cache, fd, 0));
+	T_ASSERT(bcache_invalidate(cache, di, 0));
 
 	// a read is not required to get the block
-	_expect_read(me, fd, 0);
+	_expect_read(me, di, 0);
 	_expect(me, E_WAIT);
-	T_ASSERT(bcache_get(cache, fd, 0, 0, &b));
+	T_ASSERT(bcache_get(cache, di, 0, 0, &b));
 	bcache_put(b);
 }
 
@@ -797,13 +797,13 @@ static void test_invalidate_held_block(void *context)
 	struct mock_engine *me = f->me;
 	struct bcache *cache = f->cache;
 	struct block *b;
-	int fd = 17;
+	int di = 17;
 
-	T_ASSERT(bcache_get(cache, fd, 0, GF_ZERO, &b));
+	T_ASSERT(bcache_get(cache, di, 0, GF_ZERO, &b));
 
-	T_ASSERT(!bcache_invalidate(cache, fd, 0));
+	T_ASSERT(!bcache_invalidate(cache, di, 0));
 
-	_expect_write(me, fd, 0);
+	_expect_write(me, di, 0);
 	_expect(me, E_WAIT);
 	bcache_put(b);
 }
@@ -815,10 +815,10 @@ static void test_abort_no_blocks(void *context)
 {
 	struct fixture *f = context;
 	struct bcache *cache = f->cache;
-	int fd = 17;
+	int di = 17;
 
 	// We have no expectations
-	bcache_abort_fd(cache, fd);
+	bcache_abort_di(cache, di);
 }
 
 static void test_abort_single_block(void *context)
@@ -826,12 +826,12 @@ static void test_abort_single_block(void *context)
 	struct fixture *f = context;
 	struct bcache *cache = f->cache;
 	struct block *b;
-	int fd = 17;
+	int di = 17;
 
-	T_ASSERT(bcache_get(cache, fd, 0, GF_ZERO, &b));
+	T_ASSERT(bcache_get(cache, di, 0, GF_ZERO, &b));
 	bcache_put(b);
 
-	bcache_abort_fd(cache, fd);
+	bcache_abort_di(cache, di);
 
 	// no write should be issued
 	T_ASSERT(bcache_flush(cache));
@@ -843,48 +843,48 @@ static void test_abort_forces_reread(void *context)
 	struct mock_engine *me = f->me;
 	struct bcache *cache = f->cache;
 	struct block *b;
-	int fd = 17;
+	int di = 17;
 
-	_expect_read(me, fd, 0);
+	_expect_read(me, di, 0);
 	_expect(me, E_WAIT);
-	T_ASSERT(bcache_get(cache, fd, 0, GF_DIRTY, &b));
+	T_ASSERT(bcache_get(cache, di, 0, GF_DIRTY, &b));
 	bcache_put(b);
 
-	bcache_abort_fd(cache, fd);
+	bcache_abort_di(cache, di);
 	T_ASSERT(bcache_flush(cache));
 
 	// Check the block is re-read
-	_expect_read(me, fd, 0);
+	_expect_read(me, di, 0);
 	_expect(me, E_WAIT);
-	T_ASSERT(bcache_get(cache, fd, 0, 0, &b));
+	T_ASSERT(bcache_get(cache, di, 0, 0, &b));
 	bcache_put(b);
 }
 
-static void test_abort_only_specific_fd(void *context)
+static void test_abort_only_specific_di(void *context)
 {
 	struct fixture *f = context;
 	struct mock_engine *me = f->me;
 	struct bcache *cache = f->cache;
 	struct block *b;
-	int fd1 = 17, fd2 = 18;
+	int di1 = 17, di2 = 18;
 
-	T_ASSERT(bcache_get(cache, fd1, 0, GF_ZERO, &b));
+	T_ASSERT(bcache_get(cache, di1, 0, GF_ZERO, &b));
 	bcache_put(b);
 
-	T_ASSERT(bcache_get(cache, fd1, 1, GF_ZERO, &b));
+	T_ASSERT(bcache_get(cache, di1, 1, GF_ZERO, &b));
 	bcache_put(b);
 
-	T_ASSERT(bcache_get(cache, fd2, 0, GF_ZERO, &b));
+	T_ASSERT(bcache_get(cache, di2, 0, GF_ZERO, &b));
 	bcache_put(b);
 
-	T_ASSERT(bcache_get(cache, fd2, 1, GF_ZERO, &b));
+	T_ASSERT(bcache_get(cache, di2, 1, GF_ZERO, &b));
 	bcache_put(b);
 
-	bcache_abort_fd(cache, fd2);
+	bcache_abort_di(cache, di2);
 
-	// writes for fd1 should still be issued
-	_expect_write(me, fd1, 0);
-	_expect_write(me, fd1, 1);
+	// writes for di1 should still be issued
+	_expect_write(me, di1, 0);
+	_expect_write(me, di1, 1);
 
 	_expect(me, E_WAIT);
 	_expect(me, E_WAIT);
@@ -928,7 +928,7 @@ static void test_concurrent_reads_after_invalidate(void *context)
 
 	_cycle(f, nr_cache_blocks);
 	for (i = 0; i < nr_cache_blocks; i++)
-        	bcache_invalidate_fd(f->cache, i);
+        	bcache_invalidate_di(f->cache, i);
         _cycle(f, nr_cache_blocks);
 }
 
@@ -984,7 +984,7 @@ static struct test_suite *_small_tests(void)
 	T("abort-with-no-blocks", "you can call abort, even if there are no blocks in the cache", test_abort_no_blocks);
 	T("abort-single-block", "single block get silently discarded", test_abort_single_block);
 	T("abort-forces-read", "if a block has been discarded then another read is necc.", test_abort_forces_reread);
-	T("abort-specific-fd", "abort doesn't effect other fds", test_abort_only_specific_fd);
+	T("abort-specific-di", "abort doesn't effect other dis", test_abort_only_specific_di);
 
 	T("concurrent-reads-after-invalidate", "prefetch should still issue concurrent reads after invalidate",
           test_concurrent_reads_after_invalidate);
diff --git a/test/unit/bcache_utils_t.c b/test/unit/bcache_utils_t.c
index d022c5115..69c510109 100644
--- a/test/unit/bcache_utils_t.c
+++ b/test/unit/bcache_utils_t.c
@@ -32,6 +32,7 @@
 
 struct fixture {
 	int fd;
+	int di;
 	char fname[32];
 	struct bcache *cache;
 };
@@ -84,6 +85,8 @@ static void *_fix_init(struct io_engine *engine)
 	f->cache = bcache_create(T_BLOCK_SIZE / 512, NR_BLOCKS, engine);
 	T_ASSERT(f->cache);
 
+	f->di = bcache_set_fd(f->fd);
+
         return f;
 }
 
@@ -107,6 +110,7 @@ static void _fix_exit(void *fixture)
 
 	bcache_destroy(f->cache);
 	close(f->fd);
+	bcache_clear_fd(f->di);
 	unlink(f->fname);
         free(f);
 }
@@ -140,7 +144,7 @@ static void _verify(struct fixture *f, uint64_t byte_b, uint64_t byte_e, uint8_t
         	unsigned i;
         	size_t len2 = byte_e - byte_b;
 		uint8_t *buffer = malloc(len2);
-		T_ASSERT(bcache_read_bytes(f->cache, f->fd, byte_b, len2, buffer));
+		T_ASSERT(bcache_read_bytes(f->cache, f->di, byte_b, len2, buffer));
 		for (i = 0; i < len; i++)
         		T_ASSERT_EQUAL(buffer[i], _pattern_at(pat, byte_b + i));
         	free(buffer);
@@ -148,7 +152,7 @@ static void _verify(struct fixture *f, uint64_t byte_b, uint64_t byte_e, uint8_t
 
 	// Verify again, driving bcache directly
 	for (; bb != be; bb++) {
-        	T_ASSERT(bcache_get(f->cache, f->fd, bb, 0, &b));
+        	T_ASSERT(bcache_get(f->cache, f->di, bb, 0, &b));
 
 		blen = _min(T_BLOCK_SIZE - offset, len);
         	_verify_bytes(b, bb * T_BLOCK_SIZE, offset, blen, pat);
@@ -170,7 +174,7 @@ static void _verify_set(struct fixture *f, uint64_t byte_b, uint64_t byte_e, uin
 	uint64_t blen, len = byte_e - byte_b;
 
 	for (; bb != be; bb++) {
-        	T_ASSERT(bcache_get(f->cache, f->fd, bb, 0, &b));
+        	T_ASSERT(bcache_get(f->cache, f->di, bb, 0, &b));
 
 		blen = _min(T_BLOCK_SIZE - offset, len);
 		for (i = 0; i < blen; i++)
@@ -198,18 +202,18 @@ static void _do_write(struct fixture *f, uint64_t byte_b, uint64_t byte_e, uint8
         for (i = 0; i < len; i++)
 		buffer[i] = _pattern_at(pat, byte_b + i);
 
-        T_ASSERT(bcache_write_bytes(f->cache, f->fd, byte_b, byte_e - byte_b, buffer));
+        T_ASSERT(bcache_write_bytes(f->cache, f->di, byte_b, byte_e - byte_b, buffer));
 	free(buffer);
 }
 
 static void _do_zero(struct fixture *f, uint64_t byte_b, uint64_t byte_e)
 {
-	T_ASSERT(bcache_zero_bytes(f->cache, f->fd, byte_b, byte_e - byte_b));
+	T_ASSERT(bcache_zero_bytes(f->cache, f->di, byte_b, byte_e - byte_b));
 }
 
 static void _do_set(struct fixture *f, uint64_t byte_b, uint64_t byte_e, uint8_t val)
 {
-	T_ASSERT(bcache_set_bytes(f->cache, f->fd, byte_b, byte_e - byte_b, val));
+	T_ASSERT(bcache_set_bytes(f->cache, f->di, byte_b, byte_e - byte_b, val));
 }
 
 static void _reopen(struct fixture *f)
@@ -222,6 +226,8 @@ static void _reopen(struct fixture *f)
 
 	f->cache = bcache_create(T_BLOCK_SIZE / 512, NR_BLOCKS, engine);
 	T_ASSERT(f->cache);
+
+	f->di = bcache_set_fd(f->fd);
 }
 
 //----------------------------------------------------------------
diff --git a/test/unit/io_engine_t.c b/test/unit/io_engine_t.c
index 44e93e025..349df2586 100644
--- a/test/unit/io_engine_t.c
+++ b/test/unit/io_engine_t.c
@@ -35,6 +35,7 @@ struct fixture {
 
 	char fname[64];
 	int fd;
+	int di;
 };
 
 static void _fill_buffer(uint8_t *buffer, uint8_t seed, size_t count)
@@ -102,6 +103,7 @@ static void _fix_exit(void *fixture)
         struct fixture *f = fixture;
 
 	close(f->fd);
+	bcache_clear_fd(f->di);
 	unlink(f->fname);
         free(f->data);
         if (f->e)
@@ -135,11 +137,14 @@ static void _complete_io(void *context, int io_error)
 static void _test_read(void *fixture)
 {
 	struct fixture *f = fixture;
-
 	struct io io;
+	struct bcache *cache = bcache_create(8, BLOCK_SIZE_SECTORS, f->e);
+	T_ASSERT(cache);
+
+	f->di = bcache_set_fd(f->fd);
 
 	_io_init(&io);
-	T_ASSERT(f->e->issue(f->e, DIR_READ, f->fd, 0, BLOCK_SIZE_SECTORS, f->data, &io));
+	T_ASSERT(f->e->issue(f->e, DIR_READ, f->di, 0, BLOCK_SIZE_SECTORS, f->data, &io));
 	T_ASSERT(f->e->wait(f->e, _complete_io));
 	T_ASSERT(io.completed);
 	T_ASSERT(!io.error);
@@ -150,11 +155,14 @@ static void _test_read(void *fixture)
 static void _test_write(void *fixture)
 {
 	struct fixture *f = fixture;
-
 	struct io io;
+	struct bcache *cache = bcache_create(8, BLOCK_SIZE_SECTORS, f->e);
+	T_ASSERT(cache);
+
+	f->di = bcache_set_fd(f->fd);
 
 	_io_init(&io);
-	T_ASSERT(f->e->issue(f->e, DIR_WRITE, f->fd, 0, BLOCK_SIZE_SECTORS, f->data, &io));
+	T_ASSERT(f->e->issue(f->e, DIR_WRITE, f->di, 0, BLOCK_SIZE_SECTORS, f->data, &io));
 	T_ASSERT(f->e->wait(f->e, _complete_io));
 	T_ASSERT(io.completed);
 	T_ASSERT(!io.error);
@@ -170,10 +178,12 @@ static void _test_write_bytes(void *fixture)
 	struct bcache *cache = bcache_create(8, BLOCK_SIZE_SECTORS, f->e);
 	T_ASSERT(cache);
 
-	// T_ASSERT(bcache_read_bytes(cache, f->fd, offset, sizeof(buf_in), buf_in));
+	f->di = bcache_set_fd(f->fd);
+
+	// T_ASSERT(bcache_read_bytes(cache, f->di, offset, sizeof(buf_in), buf_in));
 	_fill_buffer((uint8_t *) buf_out, 234, sizeof(buf_out));
-	T_ASSERT(bcache_write_bytes(cache, f->fd, offset, sizeof(buf_out), buf_out));
-	T_ASSERT(bcache_read_bytes(cache, f->fd, offset, sizeof(buf_in), buf_in));
+	T_ASSERT(bcache_write_bytes(cache, f->di, offset, sizeof(buf_out), buf_out));
+	T_ASSERT(bcache_read_bytes(cache, f->di, offset, sizeof(buf_in), buf_in));
 
 	_print_buffer("buf_out", (uint8_t *) buf_out, sizeof(buf_out));
 	_print_buffer("buf_in", (uint8_t *) buf_in, sizeof(buf_in));
diff --git a/tools/toollib.c b/tools/toollib.c
index 019346ce9..0016648e3 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -5579,7 +5579,7 @@ do_command:
 	 * Wipe signatures on devices being created.
 	 */
 	dm_list_iterate_items_safe(pd, pd2, &pp->arg_create) {
-		label_scan_open(pd->dev);
+		label_scan_open_excl(pd->dev);
 
 		log_verbose("Wiping signatures on new PV %s.", pd->name);
 


