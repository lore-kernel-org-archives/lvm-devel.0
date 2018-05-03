From: Joe Thornber <thornber@sourceware.org>
Date: Thu, 3 May 2018 15:17:36 -0400
Subject: master - bcache: Move the utils to a separate file.
Message-ID: <201805031917.w43JHaNv012418@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=efad84ebc297a652a2b88ced57128fc51edcf8ef
Commit:        efad84ebc297a652a2b88ced57128fc51edcf8ef
Parent:        b3c41bce3db2124af9296722bd5cda720c943462
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Thu May 3 09:34:41 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Thu May 3 09:34:41 2018 +0100

bcache: Move the utils to a separate file.

This makes it clearer that they don't access the cache internals.
---
 lib/Makefile.in           |    1 +
 lib/device/bcache-utils.c |  162 +++++++++++++++++++++++++++++++++++++++++++++
 lib/device/bcache.c       |  145 ----------------------------------------
 3 files changed, 163 insertions(+), 145 deletions(-)

diff --git a/lib/Makefile.in b/lib/Makefile.in
index dbe7b90..1d42235 100644
--- a/lib/Makefile.in
+++ b/lib/Makefile.in
@@ -29,6 +29,7 @@ SOURCES =\
 	datastruct/btree.c \
 	datastruct/str_list.c \
 	device/bcache.c \
+	device/bcache-utils.c \
 	device/dev-cache.c \
 	device/dev-ext.c \
 	device/dev-io.c \
diff --git a/lib/device/bcache-utils.c b/lib/device/bcache-utils.c
new file mode 100644
index 0000000..c9a685c
--- /dev/null
+++ b/lib/device/bcache-utils.c
@@ -0,0 +1,162 @@
+/*
+ * Copyright (C) 2018 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+ */
+
+#include "bcache.h"
+
+// FIXME: need to define this in a common place (that doesn't pull in deps)
+#ifndef SECTOR_SHIFT
+#define SECTOR_SHIFT 9
+#endif
+
+//----------------------------------------------------------------
+
+static void byte_range_to_block_range(struct bcache *cache, off_t start, size_t len,
+				      block_address *bb, block_address *be)
+{
+	block_address block_size = bcache_block_sectors(cache) << SECTOR_SHIFT;
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
+	if (rhs < lhs)
+		return rhs;
+
+	return lhs;
+}
+
+// These functions are all utilities, they should only use the public
+// interface to bcache.
+// FIXME: there's common code that can be factored out of these 3
+bool bcache_read_bytes(struct bcache *cache, int fd, off_t start, size_t len, void *data)
+{
+	struct block *b;
+	block_address bb, be, i;
+	unsigned char *udata = data;
+	off_t block_size = bcache_block_sectors(cache) << SECTOR_SHIFT;
+	int errors = 0;
+
+	byte_range_to_block_range(cache, start, len, &bb, &be);
+	for (i = bb; i < be; i++)
+		bcache_prefetch(cache, fd, i);
+
+	for (i = bb; i < be; i++) {
+		if (!bcache_get(cache, fd, i, 0, &b, NULL)) {
+			errors++;
+			continue;
+		}
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
+
+		bcache_put(b);
+	}
+
+	return errors ? false : true;
+}
+
+bool bcache_write_bytes(struct bcache *cache, int fd, off_t start, size_t len, void *data)
+{
+	struct block *b;
+	block_address bb, be, i;
+	unsigned char *udata = data;
+	off_t block_size = bcache_block_sectors(cache) << SECTOR_SHIFT;
+	int errors = 0;
+
+	byte_range_to_block_range(cache, start, len, &bb, &be);
+	for (i = bb; i < be; i++)
+		bcache_prefetch(cache, fd, i);
+
+	for (i = bb; i < be; i++) {
+		if (!bcache_get(cache, fd, i, GF_DIRTY, &b, NULL)) {
+			errors++;
+			continue;
+		}
+
+		if (i == bb) {
+			off_t block_offset = start % block_size;
+			size_t blen = _min(block_size - block_offset, len);
+			memcpy(((unsigned char *) b->data) + block_offset, udata, blen);
+			len -= blen;
+			udata += blen;
+		} else {
+			size_t blen = _min(block_size, len);
+			memcpy(b->data, udata, blen);
+			len -= blen;
+			udata += blen;
+		}
+
+		bcache_put(b);
+	}
+
+	return errors ? false : true;
+}
+
+bool bcache_write_zeros(struct bcache *cache, int fd, off_t start, size_t len)
+{
+	struct block *b;
+	block_address bb, be, i;
+	off_t block_size = bcache_block_sectors(cache) << SECTOR_SHIFT;
+	int errors = 0;
+
+	byte_range_to_block_range(cache, start, len, &bb, &be);
+	for (i = bb; i < be; i++)
+		bcache_prefetch(cache, fd, i);
+
+	for (i = bb; i < be; i++) {
+		if (!bcache_get(cache, fd, i, GF_DIRTY, &b, NULL)) {
+			errors++;
+			continue;
+		}
+
+		if (i == bb) {
+			off_t block_offset = start % block_size;
+			size_t blen = _min(block_size - block_offset, len);
+			memset(((unsigned char *) b->data) + block_offset, 0, blen);
+			len -= blen;
+		} else {
+			size_t blen = _min(block_size, len);
+			memset(b->data, 0, blen);
+			len -= blen;
+		}
+
+		bcache_put(b);
+	}
+
+	return errors ? false : true;
+}
+
+//----------------------------------------------------------------
diff --git a/lib/device/bcache.c b/lib/device/bcache.c
index 2b50ae5..6ea0349 100644
--- a/lib/device/bcache.c
+++ b/lib/device/bcache.c
@@ -1034,150 +1034,5 @@ bool bcache_invalidate_fd(struct bcache *cache, int fd)
        return r;
 }
 
-static void byte_range_to_block_range(struct bcache *cache, off_t start, size_t len,
-				      block_address *bb, block_address *be)
-{
-	block_address block_size = cache->block_sectors << SECTOR_SHIFT;
-	*bb = start / block_size;
-	*be = (start + len + block_size - 1) / block_size;
-}
-
-void bcache_prefetch_bytes(struct bcache *cache, int fd, off_t start, size_t len)
-{
-	block_address bb, be;
-
-	byte_range_to_block_range(cache, start, len, &bb, &be);
-	while (bb < be) {
-		bcache_prefetch(cache, fd, bb);
-		bb++;
-	}
-}
-
-static off_t _min(off_t lhs, off_t rhs)
-{
-	if (rhs < lhs)
-		return rhs;
-
-	return lhs;
-}
-
-// These functions are all utilities, they should only use the public
-// interface to bcache.
-// FIXME: there's common code that can be factored out of these 3
-bool bcache_read_bytes(struct bcache *cache, int fd, off_t start, size_t len, void *data)
-{
-	struct block *b;
-	block_address bb, be, i;
-	unsigned char *udata = data;
-	off_t block_size = cache->block_sectors << SECTOR_SHIFT;
-	int errors = 0;
-
-	byte_range_to_block_range(cache, start, len, &bb, &be);
-	for (i = bb; i < be; i++)
-		bcache_prefetch(cache, fd, i);
-
-	for (i = bb; i < be; i++) {
-		if (!bcache_get(cache, fd, i, 0, &b, NULL)) {
-			log_error("bcache_read_bytes failed to get block %u fd %d bb %u be %u",
-				  (uint32_t)i, fd, (uint32_t)bb, (uint32_t)be);
-			errors++;
-			continue;
-		}
-
-		if (i == bb) {
-			off_t block_offset = start % block_size;
-			size_t blen = _min(block_size - block_offset, len);
-			memcpy(udata, ((unsigned char *) b->data) + block_offset, blen);
-			len -= blen;
-			udata += blen;
-		} else {
-			size_t blen = _min(block_size, len);
-			memcpy(udata, b->data, blen);
-			len -= blen;
-			udata += blen;
-		}
-
-		bcache_put(b);
-	}
-
-	return errors ? false : true;
-}
-
-bool bcache_write_bytes(struct bcache *cache, int fd, off_t start, size_t len, void *data)
-{
-	struct block *b;
-	block_address bb, be, i;
-	unsigned char *udata = data;
-	off_t block_size = cache->block_sectors << SECTOR_SHIFT;
-	int errors = 0;
-
-	byte_range_to_block_range(cache, start, len, &bb, &be);
-	for (i = bb; i < be; i++)
-		bcache_prefetch(cache, fd, i);
-
-	for (i = bb; i < be; i++) {
-		if (!bcache_get(cache, fd, i, GF_DIRTY, &b, NULL)) {
-			log_error("bcache_write_bytes failed to get block %u fd %d bb %u be %u",
-				  (uint32_t)i, fd, (uint32_t)bb, (uint32_t)be);
-			errors++;
-			continue;
-		}
-
-		if (i == bb) {
-			off_t block_offset = start % block_size;
-			size_t blen = _min(block_size - block_offset, len);
-			memcpy(((unsigned char *) b->data) + block_offset, udata, blen);
-			len -= blen;
-			udata += blen;
-		} else {
-			size_t blen = _min(block_size, len);
-			memcpy(b->data, udata, blen);
-			len -= blen;
-			udata += blen;
-		}
-
-		bcache_put(b);
-	}
-
-	return errors ? false : true;
-}
-
-bool bcache_write_zeros(struct bcache *cache, int fd, off_t start, size_t len)
-{
-	struct block *b;
-	block_address bb, be, i;
-	off_t block_size = cache->block_sectors << SECTOR_SHIFT;
-	int errors = 0;
-
-	byte_range_to_block_range(cache, start, len, &bb, &be);
-	for (i = bb; i < be; i++)
-		bcache_prefetch(cache, fd, i);
-
-	for (i = bb; i < be; i++) {
-		if (!bcache_get(cache, fd, i, GF_DIRTY, &b, NULL)) {
-			log_error("bcache_write_bytes failed to get block %u fd %d bb %u be %u",
-				  (uint32_t)i, fd, (uint32_t)bb, (uint32_t)be);
-			errors++;
-			continue;
-		}
-
-		if (i == bb) {
-			off_t block_offset = start % block_size;
-			size_t blen = _min(block_size - block_offset, len);
-			memset(((unsigned char *) b->data) + block_offset, 0, blen);
-			len -= blen;
-		} else {
-			size_t blen = _min(block_size, len);
-			memset(b->data, 0, blen);
-			len -= blen;
-		}
-
-		bcache_put(b);
-	}
-
-	return errors ? false : true;
-}
-
-
 //----------------------------------------------------------------
 


