From: David Teigland <teigland@sourceware.org>
Date: Mon, 23 Apr 2018 09:47:34 -0400
Subject: master - [device/bcache] add bcache_prefetch_bytes() and bcache_read_bytes()
Message-ID: <201804231347.w3NDlY5L031301@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6a57ed17a28aee0e8fb9557ec3c03a02f0b2a4be
Commit:        6a57ed17a28aee0e8fb9557ec3c03a02f0b2a4be
Parent:        467adfa082c3be10d012fa156db7810d23221648
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Mon Feb 5 16:56:56 2018 +0000
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 20 11:12:50 2018 -0500

[device/bcache] add bcache_prefetch_bytes() and bcache_read_bytes()

Not tested yet.
---
 lib/device/bcache.c |   59 +++++++++++++++++++++++++++++++++++++++++++++++++++
 lib/device/bcache.h |   10 ++++++++
 2 files changed, 69 insertions(+), 0 deletions(-)

diff --git a/lib/device/bcache.c b/lib/device/bcache.c
index 86b56c0..1d83306 100644
--- a/lib/device/bcache.c
+++ b/lib/device/bcache.c
@@ -966,5 +966,64 @@ void bcache_invalidate_fd(struct bcache *cache, int fd)
 			_recycle_block(cache, b);
 }
 
+static void byte_range_to_block_range(struct bcache *cache, off_t start, size_t len,
+				      block_address *bb, block_address *be)
+{
+	block_address block_size = cache->block_sectors << SECTOR_SHIFT;
+	*bb = start / block_size;
+	*be = (start + len + block_size - 1) / block_size;
+}
+
+void bcache_prefetch_bytes(struct bcache *cache, int fd, off_t start, size_t len)
+{
+	block_address bb, be;
+
+	byte_range_to_block_range(cache, start, len, &bb, &be);
+	while (bb < be) {
+		bcache_prefetch(cache, fd, bb);
+		bb++;
+	}
+}
+
+static off_t _min(off_t lhs, off_t rhs)
+{
+	if (rhs > lhs)
+		return rhs;
+
+	return lhs;
+}
+
+bool bcache_read_bytes(struct bcache *cache, int fd, off_t start, size_t len, void *data)
+{
+	struct block *b;
+	block_address bb, be, i;
+	unsigned char *udata = data;
+	off_t block_size = cache->block_sectors << SECTOR_SHIFT;
+
+	byte_range_to_block_range(cache, start, len, &bb, &be);
+	for (i = bb; i < be; i++)
+		bcache_prefetch(cache, fd, i);
+
+	for (i = bb; i < be; i++) {
+		if (!bcache_get(cache, fd, i, 0, &b))
+			return false;
+
+		if (i == bb) {
+			off_t block_offset = start % block_size;
+			size_t blen = _min(block_size - block_offset, len);
+			memcpy(udata, ((unsigned char *) b->data) + block_offset, blen);
+			len -= blen;
+			udata += blen;
+		} else {
+			size_t blen = _min(block_size, len);
+			memcpy(udata, b->data, blen);
+			len -= blen;
+			udata += blen;
+		}
+	}
+
+	return true;
+}
+
 //----------------------------------------------------------------
 
diff --git a/lib/device/bcache.h b/lib/device/bcache.h
index 818dee2..7d38d33 100644
--- a/lib/device/bcache.h
+++ b/lib/device/bcache.h
@@ -137,6 +137,16 @@ void bcache_invalidate(struct bcache *cache, int fd, block_address index);
  */
 void bcache_invalidate_fd(struct bcache *cache, int fd);
 
+/*
+ * Prefetches the blocks neccessary to satisfy a byte range.
+ */
+void bcache_prefetch_bytes(struct bcache *cache, int fd, off_t start, size_t len);
+
+/*
+ * Reads the bytes.
+ */
+bool bcache_read_bytes(struct bcache *cache, int fd, off_t start, size_t len, void *data);
+
 /*----------------------------------------------------------------*/
 
 #endif


