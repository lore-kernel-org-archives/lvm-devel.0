From: Alasdair Kergon <agk@sourceware.org>
Date: Mon, 15 Jan 2018 22:17:15 -0500
Subject: master - device: Rearrange _aligned_io().
Message-ID: <201801160317.w0G3HFjg025379@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b825987b2fc6a8294d164bf4c5e1be7edc199bea
Commit:        b825987b2fc6a8294d164bf4c5e1be7edc199bea
Parent:        c90582344d4c04d020899a8ff8857f09368e0a98
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Jan 15 19:59:28 2018 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Jan 15 20:10:54 2018 +0000

device: Rearrange _aligned_io().

---
 lib/device/dev-io.c |   73 ++++++++++++++++++++++++--------------------------
 1 files changed, 35 insertions(+), 38 deletions(-)

diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index 514aaca..6d5433f 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -261,10 +261,9 @@ static void _widen_region(unsigned int block_size, struct device_area *region,
 		result->size += block_size - delta;
 }
 
-static int _aligned_io(struct device_area *where, char *buffer,
+static int _aligned_io(struct device_area *where, char *write_buffer,
 		       int should_write, dev_io_reason_t reason)
 {
-	char *bounce, *bounce_buf = NULL;
 	unsigned int physical_block_size = 0;
 	unsigned int block_size = 0;
 	unsigned buffer_was_widened = 0;
@@ -295,18 +294,30 @@ static int _aligned_io(struct device_area *where, char *buffer,
 			     where->size, (uint64_t) where->start, widened.size, (uint64_t) widened.start, dev_name(where->dev), _reason_text(reason));
 	} 
 
-	if (should_write && !buffer_was_widened && !((uintptr_t) buffer & mask))
+	devbuf = DEV_DEVBUF(where->dev, reason);
+ 	_release_devbuf(devbuf);
+	devbuf->where.dev = where->dev;
+	devbuf->where.start = widened.start;
+	devbuf->where.size = widened.size;
+	devbuf->write = should_write;
+	devbuf->reason = reason;
+
+	/* Store location of requested data relative to start of buf */
+	devbuf->data_offset = where->start - devbuf->where.start;
+
+	if (should_write && !buffer_was_widened && !((uintptr_t) write_buffer & mask)) {
 		/* Perform the I/O directly. */
-		bounce = buffer;
+		devbuf->buf = write_buffer;
+		devbuf->malloc_address = NULL;
 #ifndef DEBUG_MEM
-	else if (!(bounce_buf = bounce = dm_malloc_aligned((size_t) widened.size, 0))) {
+	} else if (!(devbuf->malloc_address = devbuf->buf = dm_malloc_aligned((size_t) devbuf->where.size, 0))) {
 		log_error("Bounce buffer malloc failed");
 		return 0;
 	}
 #else
-	else {
+	} else {
 		/* Allocate a bounce buffer with an extra block */
-		if (!(bounce_buf = bounce = dm_malloc((size_t) widened.size + block_size))) {
+		if (!(devbuf->malloc_address = devbuf->buf = dm_malloc((size_t) devbuf->where.size + block_size))) {
 			log_error("Bounce buffer malloc failed");
 			return 0;
 		}
@@ -314,53 +325,39 @@ static int _aligned_io(struct device_area *where, char *buffer,
 		/*
 		 * Realign start of bounce buffer (using the extra sector)
 		 */
-		if (((uintptr_t) bounce) & mask)
-			bounce = (char *) ((((uintptr_t) bounce) + mask) & ~mask);
+		if (((uintptr_t) devbuf->buf) & mask)
+			devbuf->buf = (char *) ((((uintptr_t) devbuf->buf) + mask) & ~mask);
 	}
 #endif
 
-	devbuf = DEV_DEVBUF(where->dev, reason);
- 	_release_devbuf(devbuf);
-	devbuf->malloc_address = bounce_buf;
-	devbuf->buf = bounce;
-	devbuf->where.dev = where->dev;
-	devbuf->where.start = widened.start;
-	devbuf->where.size = widened.size;
 	devbuf->write = 0;
-	devbuf->reason = reason;
 
 	/* Do we need to read into the bounce buffer? */
-	if ((!should_write || buffer_was_widened) &&
-	    !_io(devbuf)) {
+	if ((!should_write || buffer_was_widened) && !_io(devbuf)) {
 		if (!should_write)
 			goto_bad;
 		/* FIXME Handle errors properly! */
 		/* FIXME pre-extend the file */
-		memset(bounce, '\n', widened.size);
+		memset(devbuf->buf, '\n', devbuf->where.size);
 	}
 
-	if (should_write) {
-		if (bounce_buf) {
-			memcpy(bounce + (where->start - widened.start), buffer,
-			       (size_t) where->size);
-			log_debug_io("Overwriting %" PRIu64 " bytes at %" PRIu64 " (for %s)", where->size,
-				     (uint64_t) where->start, _reason_text(reason));
-		}
-
-		/* ... then we write */
-		devbuf->write = 1;
-		if (!(r = _io(devbuf)))
-			goto_bad;
-			
-		_release_devbuf(devbuf);
+	if (!should_write)
 		return 1;
-	}
 
-	/* read */
+	/* writes */
 
-	/* We store what we just read as it often also satisfies the next request */
-	devbuf->data_offset = where->start - widened.start;
+	if (devbuf->malloc_address) {
+		memcpy((char *) devbuf->buf + devbuf->data_offset, write_buffer, (size_t) where->size);
+		log_debug_io("Overwriting %" PRIu64 " bytes at %" PRIu64 " (for %s)", where->size,
+			     (uint64_t) where->start, _reason_text(devbuf->reason));
+	}
 
+	/* ... then we write */
+	devbuf->write = 1;
+	if (!(r = _io(devbuf)))
+		goto_bad;
+
+	_release_devbuf(devbuf);
 	return 1;
 
 bad:


