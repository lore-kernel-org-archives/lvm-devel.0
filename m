From: David Teigland <teigland@sourceware.org>
Date: Mon, 23 Apr 2018 09:56:06 -0400
Subject: master - bcache: let caller see an error
Message-ID: <201804231356.w3NDu68o001925@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6d05859862cebe79981557fe1a1005a530302f70
Commit:        6d05859862cebe79981557fe1a1005a530302f70
Parent:        ae21305ee7fa60edbd85824d83ce554989161189
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Apr 6 13:11:39 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 20 11:22:48 2018 -0500

bcache: let caller see an error

---
 lib/device/bcache.c |   21 ++++++++++++++-------
 lib/device/bcache.h |    9 ++++++++-
 2 files changed, 22 insertions(+), 8 deletions(-)

diff --git a/lib/device/bcache.c b/lib/device/bcache.c
index 9034776..ea8f702 100644
--- a/lib/device/bcache.c
+++ b/lib/device/bcache.c
@@ -234,7 +234,6 @@ static bool _async_wait(struct io_engine *ioe, io_complete_fn fn)
 			fn((void *) cb->context, 0);
 
 		} else {
-			log_warn("short io");
 			fn(cb->context, -ENODATA);
 		}
 
@@ -538,10 +537,8 @@ static void _complete_io(void *context, int err)
 	 */
 	dm_list_del(&b->list);
 
-	if (b->error) {
-		log_warn("bcache io error %d fd %d", b->error, b->fd);
+	if (b->error)
 		memset(b->data, 0, cache->block_sectors << SECTOR_SHIFT);
-	}
 
 	/* Things don't work with this block of code, but work without it. */
 #if 0
@@ -583,6 +580,7 @@ static void _issue_low_level(struct block *b, enum dir d)
 	dm_list_add(&cache->io_pending, &b->list);
 
 	if (!cache->engine->issue(cache->engine, d, b->fd, sb, se, b->data, b)) {
+		/* FIXME: if io_submit() set an errno, return that instead of EIO? */
 		_complete_io(b, -EIO);
 		return;
 	}
@@ -904,7 +902,7 @@ void bcache_prefetch(struct bcache *cache, int fd, block_address index)
 }
 
 bool bcache_get(struct bcache *cache, int fd, block_address index,
-	        unsigned flags, struct block **result)
+	        unsigned flags, struct block **result, int *error)
 {
 	struct block *b;
 
@@ -916,12 +914,19 @@ bool bcache_get(struct bcache *cache, int fd, block_address index,
 
 		*result = b;
 
+		if (error)
+			*error = b->error;
+
 		if (b->error)
 			return false;
 		return true;
 	}
 
 	*result = NULL;
+
+	if (error)
+		*error = -BCACHE_NO_BLOCK;
+
 	log_error("bcache failed to get block %u fd %d", (uint32_t)index, fd);
 	return false;
 }
@@ -1068,7 +1073,9 @@ bool bcache_read_bytes(struct bcache *cache, int fd, off_t start, size_t len, vo
 		bcache_prefetch(cache, fd, i);
 
 	for (i = bb; i < be; i++) {
-		if (!bcache_get(cache, fd, i, 0, &b)) {
+		if (!bcache_get(cache, fd, i, 0, &b, NULL)) {
+			log_error("bcache_read failed to get block %u fd %d bb %u be %u",
+				  (uint32_t)i, fd, (uint32_t)bb, (uint32_t)be);
 			errors++;
 			continue;
 		}
@@ -1105,7 +1112,7 @@ bool bcache_write_bytes(struct bcache *cache, int fd, off_t start, size_t len, v
 		bcache_prefetch(cache, fd, i);
 
 	for (i = bb; i < be; i++) {
-		if (!bcache_get(cache, fd, i, 0, &b)) {
+		if (!bcache_get(cache, fd, i, 0, &b, NULL)) {
 			log_error("bcache_write failed to get block %u fd %d bb %u be %u",
 				  (uint32_t)i, fd, (uint32_t)bb, (uint32_t)be);
 			errors++;
diff --git a/lib/device/bcache.h b/lib/device/bcache.h
index d5f6d0a..999223a 100644
--- a/lib/device/bcache.h
+++ b/lib/device/bcache.h
@@ -29,6 +29,13 @@
 
 /*----------------------------------------------------------------*/
 
+/*
+ * bcache-specific error numbers
+ * These supplement standard -EXXX error numbers and
+ * should not overlap.
+ */
+#define BCACHE_NO_BLOCK 201
+
 enum dir {
 	DIR_READ,
 	DIR_WRITE
@@ -120,7 +127,7 @@ void bcache_prefetch(struct bcache *cache, int fd, block_address index);
  * Returns true on success.
  */
 bool bcache_get(struct bcache *cache, int fd, block_address index,
-	        unsigned flags, struct block **result);
+	        unsigned flags, struct block **result, int *error);
 void bcache_put(struct block *b);
 
 /*


