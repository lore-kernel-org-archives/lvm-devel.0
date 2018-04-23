From: David Teigland <teigland@sourceware.org>
Date: Mon, 23 Apr 2018 09:46:46 -0400
Subject: master - [device/bcache] Add a couple of invalidate methods
Message-ID: <201804231346.w3NDkk7M031102@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c4c4acfd423323cbe8fbfbdb8c1882edb4a92b29
Commit:        c4c4acfd423323cbe8fbfbdb8c1882edb4a92b29
Parent:        0f0eb04edb00cb5e95c47cb9ca2e70574e6e49ce
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Fri Feb 2 07:59:49 2018 +0000
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 20 11:12:50 2018 -0500

[device/bcache] Add a couple of invalidate methods

---
 lib/device/bcache.c |   60 +++++++++++++++++++++++++++++++++++++++++++++++++++
 lib/device/bcache.h |   13 +++++++++++
 2 files changed, 73 insertions(+), 0 deletions(-)

diff --git a/lib/device/bcache.c b/lib/device/bcache.c
index 5a7b2f9..09ef6ef 100644
--- a/lib/device/bcache.c
+++ b/lib/device/bcache.c
@@ -884,5 +884,65 @@ int bcache_flush(struct bcache *cache)
 	return dm_list_empty(&cache->errored) ? 0 : -EIO;
 }
 
+static void _recycle_block(struct bcache *cache, struct block *b)
+{
+	_unlink_block(b);
+	_hash_remove(b);
+	dm_list_add(&cache->free, &b->list);
+}
+
+/*
+ * You can safely call this with a NULL block.
+ */
+static void _invalidate_block(struct bcache *cache, struct block *b)
+{
+	if (!b)
+		return;
+
+	if (_test_flags(b, BF_IO_PENDING))
+		_wait_specific(b);
+
+	if (b->ref_count)
+		log_warn("bcache_invalidate: block (%d, %llu) still held",
+			 b->fd, (unsigned long long) index);
+	else {
+		if (_test_flags(b, BF_DIRTY)) {
+			_issue_write(b);
+			_wait_specific(b);
+		}
+
+		_recycle_block(cache, b);
+	}
+}
+
+void bcache_invalidate(struct bcache *cache, int fd, block_address index)
+{
+	_invalidate_block(cache, _hash_lookup(cache, fd, index));
+}
+
+// FIXME: switch to a trie, or maybe 1 hash table per fd?  To save iterating
+// through the whole cache.
+void bcache_invalidate_fd(struct bcache *cache, int fd)
+{
+	struct block *b, *tmp;
+
+	// Start writing back any dirty blocks on this fd.
+	dm_list_iterate_items_safe (b, tmp, &cache->dirty)
+		if (b->fd == fd)
+			_issue_write(b);
+
+	_wait_all(cache);
+
+	// Everything should be in the clean list now.
+	dm_list_iterate_items_safe (b, tmp, &cache->clean)
+		if (b->fd == fd)
+			_invalidate_block(cache, b);
+
+	// Except they could be in the errored list :)
+	dm_list_iterate_items_safe (b, tmp, &cache->errored)
+		if (b->fd == fd)
+			_recycle_block(cache, b);
+}
+
 //----------------------------------------------------------------
 
diff --git a/lib/device/bcache.h b/lib/device/bcache.h
index 2730347..5c68e3c 100644
--- a/lib/device/bcache.h
+++ b/lib/device/bcache.h
@@ -93,6 +93,19 @@ void bcache_put(struct block *b);
 
 int bcache_flush(struct bcache *cache);
 
+/*
+ * Removes a block from the cache.  If the block is dirty it will be written
+ * back first.  If the block is currently held a warning will be issued, and it
+ * will not be removed.
+ */
+void bcache_invalidate(struct bcache *cache, int fd, block_address index);
+
+/*
+ * Invalidates all blocks on the given descriptor.  Call this before closing
+ * the descriptor to make sure everything is written back.
+ */
+void bcache_invalidate_fd(struct bcache *cache, int fd);
+
 /*----------------------------------------------------------------*/
 
 #endif


