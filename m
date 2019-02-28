From: David Teigland <teigland@sourceware.org>
Date: Thu, 28 Feb 2019 12:02:45 -0500
Subject: master - remove unused io functions
Message-ID: <201902281702.x1SH2jMQ019060@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3ed9256985bd9fadcbbb8f419b8d44bf22e93ef2
Commit:        3ed9256985bd9fadcbbb8f419b8d44bf22e93ef2
Parent:        fb83719d7f6ca0b2da0a56e5ce7ac1a9d1ebc7e1
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Feb 28 10:48:30 2019 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Feb 28 10:58:00 2019 -0600

remove unused io functions

---
 lib/device/dev-io.c |  328 ---------------------------------------------------
 lib/device/device.h |    8 --
 2 files changed, 0 insertions(+), 336 deletions(-)

diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index 4460e55..3fe2647 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -53,95 +53,6 @@
 
 static unsigned _dev_size_seqno = 1;
 
-static const char *_reasons[] = {
-	"dev signatures",
-	"PV labels",
-	"VG metadata header",
-	"VG metadata content",
-	"extra VG metadata header",
-	"extra VG metadata content",
-	"LVM1 metadata",
-	"pool metadata",
-	"LV content",
-	"logging",
-};
-
-static const char *_reason_text(dev_io_reason_t reason)
-{
-	return _reasons[(unsigned) reason];
-}
-
-/*-----------------------------------------------------------------
- * The standard io loop that keeps submitting an io until it's
- * all gone.
- *---------------------------------------------------------------*/
-static int _io(struct device_area *where, char *buffer, int should_write, dev_io_reason_t reason)
-{
-	int fd = dev_fd(where->dev);
-	ssize_t n = 0;
-	size_t total = 0;
-
-	if (fd < 0) {
-		log_error("Attempt to read an unopened device (%s).",
-			  dev_name(where->dev));
-		return 0;
-	}
-
-	log_debug_io("%s %s:%8" PRIu64 " bytes (sync) at %" PRIu64 "%s (for %s)",
-		     should_write ? "Write" : "Read ", dev_name(where->dev),
-		     where->size, (uint64_t) where->start,
-		     (should_write && test_mode()) ? " (test mode - suppressed)" : "", _reason_text(reason));
-
-	/*
-	 * Skip all writes in test mode.
-	 */
-	if (should_write && test_mode())
-		return 1;
-
-	if (where->size > SSIZE_MAX) {
-		log_error("Read size too large: %" PRIu64, where->size);
-		return 0;
-	}
-
-	if (lseek(fd, (off_t) where->start, SEEK_SET) == (off_t) -1) {
-		log_error("%s: lseek %" PRIu64 " failed: %s",
-			  dev_name(where->dev), (uint64_t) where->start,
-			  strerror(errno));
-		return 0;
-	}
-
-	while (total < (size_t) where->size) {
-		do
-			n = should_write ?
-			    write(fd, buffer, (size_t) where->size - total) :
-			    read(fd, buffer, (size_t) where->size - total);
-		while ((n < 0) && ((errno == EINTR) || (errno == EAGAIN)));
-
-		if (n < 0)
-			log_error_once("%s: %s failed after %" PRIu64 " of %" PRIu64
-				       "@%" PRIu64 ": %s", dev_name(where->dev),
-				       should_write ? "write" : "read",
-				       (uint64_t) total,
-				       (uint64_t) where->size,
-				       (uint64_t) where->start, strerror(errno));
-
-		if (n <= 0)
-			break;
-
-		total += n;
-		buffer += n;
-	}
-
-	return (total == (size_t) where->size);
-}
-
-/*-----------------------------------------------------------------
- * LVM2 uses O_DIRECT when performing metadata io, which requires
- * block size aligned accesses.  If any io is not aligned we have
- * to perform the io via a bounce buffer, obviously this is quite
- * inefficient.
- *---------------------------------------------------------------*/
-
 /*
  * Get the physical and logical block size for a device.
  */
@@ -213,101 +124,6 @@ out:
 	return r;
 }
 
-/*
- * Widens a region to be an aligned region.
- */
-static void _widen_region(unsigned int block_size, struct device_area *region,
-			  struct device_area *result)
-{
-	uint64_t mask = block_size - 1, delta;
-	memcpy(result, region, sizeof(*result));
-
-	/* adjust the start */
-	delta = result->start & mask;
-	if (delta) {
-		result->start -= delta;
-		result->size += delta;
-	}
-
-	/* adjust the end */
-	delta = (result->start + result->size) & mask;
-	if (delta)
-		result->size += block_size - delta;
-}
-
-static int _aligned_io(struct device_area *where, char *buffer,
-		       int should_write, dev_io_reason_t reason)
-{
-	char *bounce, *bounce_buf;
-	unsigned int physical_block_size = 0;
-	unsigned int block_size = 0;
-	unsigned buffer_was_widened = 0;
-	uintptr_t mask;
-	struct device_area widened;
-	int r = 0;
-
-	if (!(where->dev->flags & DEV_REGULAR) &&
-	    !dev_get_block_size(where->dev, &physical_block_size, &block_size))
-		return_0;
-
-	if (!block_size)
-		block_size = lvm_getpagesize();
-	mask = block_size - 1;
-
-	_widen_region(block_size, where, &widened);
-
-	/* Did we widen the buffer?  When writing, this means means read-modify-write. */
-	if (where->size != widened.size || where->start != widened.start) {
-		buffer_was_widened = 1;
-		log_debug_io("Widening request for %" PRIu64 " bytes at %" PRIu64 " to %" PRIu64 " bytes at %" PRIu64 " on %s (for %s)",
-			     where->size, (uint64_t) where->start, widened.size, (uint64_t) widened.start, dev_name(where->dev), _reason_text(reason));
-	} else if (!((uintptr_t) buffer & mask))
-		/* Perform the I/O directly. */
-		return _io(where, buffer, should_write, reason);
-
-	/* Allocate a bounce buffer with an extra block */
-	if (!(bounce_buf = bounce = malloc((size_t) widened.size + block_size))) {
-		log_error("Bounce buffer malloc failed");
-		return 0;
-	}
-
-	/*
-	 * Realign start of bounce buffer (using the extra sector)
-	 */
-	if (((uintptr_t) bounce) & mask)
-		bounce = (char *) ((((uintptr_t) bounce) + mask) & ~mask);
-
-	/* Do we need to read into the bounce buffer? */
-	if ((!should_write || buffer_was_widened) &&
-	    !_io(&widened, bounce, 0, reason)) {
-		if (!should_write)
-			goto_out;
-		/* FIXME Handle errors properly! */
-		/* FIXME pre-extend the file */
-		memset(bounce, '\n', widened.size);
-	}
-
-	if (should_write) {
-		memcpy(bounce + (where->start - widened.start), buffer,
-		       (size_t) where->size);
-
-		/* ... then we write */
-		if (!(r = _io(&widened, bounce, 1, reason)))
-			stack;
-			
-		goto out;
-	}
-
-	memcpy(buffer, bounce + (where->start - widened.start),
-	       (size_t) where->size);
-
-	r = 1;
-
-out:
-	free(bounce_buf);
-	return r;
-}
-
 static int _dev_get_size_file(struct device *dev, uint64_t *size)
 {
 	const char *name = dev_name(dev);
@@ -581,7 +397,6 @@ int dev_open_flags(struct device *dev, int flags, int direct, int quiet)
 		dev->flags |= DEV_O_DIRECT_TESTED;
 #endif
 	dev->open_count++;
-	dev->flags &= ~DEV_ACCESSED_W;
 
 	if (need_rw)
 		dev->flags |= DEV_OPENED_RW;
@@ -643,16 +458,6 @@ int dev_open_readonly_quiet(struct device *dev)
 	return dev_open_flags(dev, O_RDONLY, 1, 1);
 }
 
-int dev_test_excl(struct device *dev)
-{
-	int flags = 0;
-
-	flags |= O_EXCL;
-	flags |= O_RDWR;
-
-	return dev_open_flags(dev, flags, 1, 1);
-}
-
 static void _close(struct device *dev)
 {
 	if (close(dev->fd))
@@ -675,11 +480,6 @@ static int _dev_close(struct device *dev, int immediate)
 		return 0;
 	}
 
-#ifndef O_DIRECT_SUPPORT
-	if (dev->flags & DEV_ACCESSED_W)
-		dev_flush(dev);
-#endif
-
 	if (dev->open_count > 0)
 		dev->open_count--;
 
@@ -702,131 +502,3 @@ int dev_close_immediate(struct device *dev)
 {
 	return _dev_close(dev, 1);
 }
-
-int dev_read(struct device *dev, uint64_t offset, size_t len, dev_io_reason_t reason, void *buffer)
-{
-	struct device_area where;
-	int ret;
-
-	if (!dev->open_count)
-		return_0;
-
-	where.dev = dev;
-	where.start = offset;
-	where.size = len;
-
-	ret = _aligned_io(&where, buffer, 0, reason);
-
-	return ret;
-}
-
-/*
- * Read from 'dev' into 'buf', possibly in 2 distinct regions, denoted
- * by (offset,len) and (offset2,len2).  Thus, the total size of
- * 'buf' should be len+len2.
- */
-int dev_read_circular(struct device *dev, uint64_t offset, size_t len,
-		      uint64_t offset2, size_t len2, dev_io_reason_t reason, char *buf)
-{
-	if (!dev_read(dev, offset, len, reason, buf)) {
-		log_error("Read from %s failed", dev_name(dev));
-		return 0;
-	}
-
-	/*
-	 * The second region is optional, and allows for
-	 * a circular buffer on the device.
-	 */
-	if (!len2)
-		return 1;
-
-	if (!dev_read(dev, offset2, len2, reason, buf + len)) {
-		log_error("Circular read from %s failed",
-			  dev_name(dev));
-		return 0;
-	}
-
-	return 1;
-}
-
-/* FIXME If O_DIRECT can't extend file, dev_extend first; dev_truncate after.
- *       But fails if concurrent processes writing
- */
-
-/* FIXME pre-extend the file */
-int dev_append(struct device *dev, size_t len, dev_io_reason_t reason, char *buffer)
-{
-	int r;
-
-	if (!dev->open_count)
-		return_0;
-
-	r = dev_write(dev, dev->end, len, reason, buffer);
-	dev->end += (uint64_t) len;
-
-#ifndef O_DIRECT_SUPPORT
-	dev_flush(dev);
-#endif
-	return r;
-}
-
-int dev_write(struct device *dev, uint64_t offset, size_t len, dev_io_reason_t reason, void *buffer)
-{
-	struct device_area where;
-	int ret;
-
-	if (!dev->open_count)
-		return_0;
-
-	if (!len) {
-		log_error(INTERNAL_ERROR "Attempted to write 0 bytes to %s at " FMTu64, dev_name(dev), offset);
-		return 0;
-	}
-
-	where.dev = dev;
-	where.start = offset;
-	where.size = len;
-
-	dev->flags |= DEV_ACCESSED_W;
-
-	ret = _aligned_io(&where, buffer, 1, reason);
-
-	return ret;
-}
-
-int dev_set(struct device *dev, uint64_t offset, size_t len, dev_io_reason_t reason, int value)
-{
-	size_t s;
-	char buffer[4096] __attribute__((aligned(8)));
-
-	if (!dev_open(dev))
-		return_0;
-
-	if ((offset % SECTOR_SIZE) || (len % SECTOR_SIZE))
-		log_debug_devs("Wiping %s at %" PRIu64 " length %" PRIsize_t,
-			       dev_name(dev), offset, len);
-	else
-		log_debug_devs("Wiping %s at sector %" PRIu64 " length %" PRIsize_t
-			       " sectors", dev_name(dev), offset >> SECTOR_SHIFT,
-			       len >> SECTOR_SHIFT);
-
-	memset(buffer, value, sizeof(buffer));
-	while (1) {
-		s = len > sizeof(buffer) ? sizeof(buffer) : len;
-		if (!dev_write(dev, offset, s, reason, buffer))
-			break;
-
-		len -= s;
-		if (!len)
-			break;
-
-		offset += s;
-	}
-
-	dev->flags |= DEV_ACCESSED_W;
-
-	if (!dev_close(dev))
-		stack;
-
-	return (len == 0);
-}
diff --git a/lib/device/device.h b/lib/device/device.h
index fa7e738..afeee7f 100644
--- a/lib/device/device.h
+++ b/lib/device/device.h
@@ -20,7 +20,6 @@
 
 #include <fcntl.h>
 
-#define DEV_ACCESSED_W		0x00000001	/* Device written to? */
 #define DEV_REGULAR		0x00000002	/* Regular file? */
 #define DEV_ALLOCED		0x00000004	/* malloc used */
 #define DEV_OPENED_RW		0x00000008	/* Opened RW */
@@ -144,17 +143,10 @@ int dev_open_readonly_buffered(struct device *dev);
 int dev_open_readonly_quiet(struct device *dev);
 int dev_close(struct device *dev);
 int dev_close_immediate(struct device *dev);
-int dev_test_excl(struct device *dev);
 
 int dev_fd(struct device *dev);
 const char *dev_name(const struct device *dev);
 
-int dev_read(struct device *dev, uint64_t offset, size_t len, dev_io_reason_t reason, void *buffer);
-int dev_read_circular(struct device *dev, uint64_t offset, size_t len,
-		      uint64_t offset2, size_t len2, dev_io_reason_t reason, char *buf);
-int dev_write(struct device *dev, uint64_t offset, size_t len, dev_io_reason_t reason, void *buffer);
-int dev_append(struct device *dev, size_t len, dev_io_reason_t reason, char *buffer);
-int dev_set(struct device *dev, uint64_t offset, size_t len, dev_io_reason_t reason, int value);
 void dev_flush(struct device *dev);
 
 struct device *dev_create_file(const char *filename, struct device *dev,


