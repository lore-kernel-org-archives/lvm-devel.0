From: Alasdair Kergon <agk@sourceware.org>
Date: Wed, 10 Jan 2018 10:53:30 -0500
Subject: master - device: Keep the last data buffer read off each device.
Message-ID: <201801101553.w0AFrURA004737@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bd0967a4b1ac3dc6402b0e9ad8bc2f85f4f7af1c
Commit:        bd0967a4b1ac3dc6402b0e9ad8bc2f85f4f7af1c
Parent:        bacc94233368cf136b55e2574e969e7f53b31c6c
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Jan 10 02:09:06 2018 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Jan 10 15:48:03 2018 +0000

device: Keep the last data buffer read off each device.

If there's a second metadata area on device, we record that separately.

Note that the memory requirements aren't restricted yet.
---
 lib/device/dev-cache.c |   10 +++
 lib/device/dev-io.c    |  156 +++++++++++++++++++++++++++++++-----------------
 lib/device/device.h    |   31 ++++++++--
 3 files changed, 137 insertions(+), 60 deletions(-)

diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 2cd38f4..3d57735 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -1247,12 +1247,22 @@ int dev_cache_check_for_open_devices(void)
 
 int dev_cache_exit(void)
 {
+	struct btree_iter *b;
 	int num_open = 0;
 
 	if (_cache.names)
 		if ((num_open = _check_for_open_devices(1)) > 0)
 			log_error(INTERNAL_ERROR "%d device(s) were left open and have been closed.", num_open);
 
+	if (_cache.devices) {
+		/* FIXME Replace with structured devbuf cache */
+		b = btree_first(_cache.devices);
+		while (b) {
+			devbufs_release(btree_get_data(b));
+			b = btree_next(b);
+		}
+	}
+
 	if (_cache.mem)
 		dm_pool_destroy(_cache.mem);
 
diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index ee4a0a5..47d3ad9 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -74,38 +74,33 @@ static const char *_reason_text(dev_io_reason_t reason)
 	return _reasons[(unsigned) reason];
 }
 
+/*
+ * Release the memory holding the last data we read
+ */
+static void _release_devbuf(struct device_buffer *devbuf)
+{
+	dm_free(devbuf->malloc_address);
+	devbuf->malloc_address = NULL;
+}
+
+void devbufs_release(struct device *dev)
+{
+	_release_devbuf(&dev->last_devbuf);
+	_release_devbuf(&dev->last_extra_devbuf);
+}
+
 /*-----------------------------------------------------------------
  * The standard io loop that keeps submitting an io until it's
  * all gone.
  *---------------------------------------------------------------*/
-static int _io(struct device_area *where, char *buffer, int should_write, dev_io_reason_t reason)
+static int _io_sync(struct device_buffer *devbuf)
 {
+	struct device_area *where = &devbuf->where;
 	int fd = dev_fd(where->dev);
+	char *buffer = devbuf->buf;
 	ssize_t n = 0;
 	size_t total = 0;
 
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
 	if (lseek(fd, (off_t) where->start, SEEK_SET) == (off_t) -1) {
 		log_error("%s: lseek %" PRIu64 " failed: %s",
 			  dev_name(where->dev), (uint64_t) where->start,
@@ -115,7 +110,7 @@ static int _io(struct device_area *where, char *buffer, int should_write, dev_io
 
 	while (total < (size_t) where->size) {
 		do
-			n = should_write ?
+			n = devbuf->write ?
 			    write(fd, buffer, (size_t) where->size - total) :
 			    read(fd, buffer, (size_t) where->size - total);
 		while ((n < 0) && ((errno == EINTR) || (errno == EAGAIN)));
@@ -123,7 +118,7 @@ static int _io(struct device_area *where, char *buffer, int should_write, dev_io
 		if (n < 0)
 			log_error_once("%s: %s failed after %" PRIu64 " of %" PRIu64
 				       "@%" PRIu64 ": %s", dev_name(where->dev),
-				       should_write ? "write" : "read",
+				       devbuf->write ? "write" : "read",
 				       (uint64_t) total,
 				       (uint64_t) where->size,
 				       (uint64_t) where->start, strerror(errno));
@@ -138,6 +133,36 @@ static int _io(struct device_area *where, char *buffer, int should_write, dev_io
 	return (total == (size_t) where->size);
 }
 
+static int _io(struct device_buffer *devbuf, dev_io_reason_t reason)
+{
+	struct device_area *where = &devbuf->where;
+	int fd = dev_fd(where->dev);
+
+	if (fd < 0) {
+		log_error("Attempt to read an unopened device (%s).",
+			  dev_name(where->dev));
+		return 0;
+	}
+
+	log_debug_io("%s %s(fd %d):%8" PRIu64 " bytes (sync) at %" PRIu64 "%s (for %s)",
+		     devbuf->write ? "Write" : "Read ", dev_name(where->dev), fd,
+		     where->size, (uint64_t) where->start,
+		     (devbuf->write && test_mode()) ? " (test mode - suppressed)" : "", _reason_text(reason));
+
+	/*
+	 * Skip all writes in test mode.
+	 */
+	if (devbuf->write && test_mode())
+		return 1;
+
+	if (where->size > SSIZE_MAX) {
+		log_error("Read size too large: %" PRIu64, where->size);
+		return 0;
+	}
+
+	return _io_sync(devbuf);
+}
+
 /*-----------------------------------------------------------------
  * LVM2 uses O_DIRECT when performing metadata io, which requires
  * block size aligned accesses.  If any io is not aligned we have
@@ -230,12 +255,13 @@ static void _widen_region(unsigned int block_size, struct device_area *region,
 static int _aligned_io(struct device_area *where, char *buffer,
 		       int should_write, dev_io_reason_t reason)
 {
-	char *bounce, *bounce_buf;
+	char *bounce, *bounce_buf = NULL;
 	unsigned int physical_block_size = 0;
 	unsigned int block_size = 0;
 	unsigned buffer_was_widened = 0;
 	uintptr_t mask;
 	struct device_area widened;
+	struct device_buffer *devbuf;
 	int r = 0;
 
 	if (!(where->dev->flags & DEV_REGULAR) &&
@@ -253,59 +279,81 @@ static int _aligned_io(struct device_area *where, char *buffer,
 		buffer_was_widened = 1;
 		log_debug_io("Widening request for %" PRIu64 " bytes at %" PRIu64 " to %" PRIu64 " bytes at %" PRIu64 " on %s (for %s)",
 			     where->size, (uint64_t) where->start, widened.size, (uint64_t) widened.start, dev_name(where->dev), _reason_text(reason));
-	} else if (!((uintptr_t) buffer & mask))
-		/* Perform the I/O directly. */
-		return _io(where, buffer, should_write, reason);
+	} 
 
+	if (!buffer_was_widened && !((uintptr_t) buffer & mask))
+		/* Perform the I/O directly. */
+		bounce = buffer;
 #ifndef DEBUG_MEM
-	/* Allocate a bounce buffer with an extra block */
-	if (!(bounce_buf = bounce = dm_malloc_aligned((size_t) widened.size, 0))) {
+	else if (!(bounce_buf = bounce = dm_malloc_aligned((size_t) widened.size, 0))) {
 		log_error("Bounce buffer malloc failed");
 		return 0;
 	}
 #else
-	/* Allocate a bounce buffer with an extra block */
-	if (!(bounce_buf = bounce = dm_malloc((size_t) widened.size + block_size))) {
-		log_error("Bounce buffer malloc failed");
-		return 0;
-	}
+	else {
+		/* Allocate a bounce buffer with an extra block */
+		if (!(bounce_buf = bounce = dm_malloc((size_t) widened.size + block_size))) {
+			log_error("Bounce buffer malloc failed");
+			return 0;
+		}
 
-	/*
-	 * Realign start of bounce buffer (using the extra sector)
-	 */
-	if (((uintptr_t) bounce) & mask)
-		bounce = (char *) ((((uintptr_t) bounce) + mask) & ~mask);
+		/*
+		 * Realign start of bounce buffer (using the extra sector)
+		 */
+		if (((uintptr_t) bounce) & mask)
+			bounce = (char *) ((((uintptr_t) bounce) + mask) & ~mask);
+	}
 #endif
 
+	devbuf = EXTRA_IO(reason) ? &where->dev->last_extra_devbuf : &where->dev->last_devbuf;
+ 	_release_devbuf(devbuf);
+	devbuf->malloc_address = bounce_buf;
+	devbuf->buf = bounce;
+	devbuf->where.dev = where->dev;
+	devbuf->where.start = widened.start;
+	devbuf->where.size = widened.size;
+	devbuf->write = 0;
+
 	/* Do we need to read into the bounce buffer? */
 	if ((!should_write || buffer_was_widened) &&
-	    !_io(&widened, bounce, 0, reason)) {
+	    !_io(devbuf, reason)) {
 		if (!should_write)
-			goto_out;
+			goto_bad;
 		/* FIXME Handle errors properly! */
 		/* FIXME pre-extend the file */
 		memset(bounce, '\n', widened.size);
 	}
 
 	if (should_write) {
-		memcpy(bounce + (where->start - widened.start), buffer,
-		       (size_t) where->size);
+		if (bounce_buf) {
+			memcpy(bounce + (where->start - widened.start), buffer,
+			       (size_t) where->size);
+			log_debug_io("Overwriting %" PRIu64 " bytes at %" PRIu64 " (for %s)", where->size,
+				     (uint64_t) where->start, _reason_text(reason));
+		}
 
 		/* ... then we write */
-		if (!(r = _io(&widened, bounce, 1, reason)))
-			stack;
+		devbuf->write = 1;
+		if (!(r = _io(devbuf, reason)))
+			goto_bad;
 			
-		goto out;
+		_release_devbuf(devbuf);
+		return 1;
 	}
 
-	memcpy(buffer, bounce + (where->start - widened.start),
-	       (size_t) where->size);
+	/* read */
+	if (bounce_buf)
+		memcpy(buffer, bounce + (where->start - widened.start),
+		       (size_t) where->size);
 
-	r = 1;
+	/* We store what we just read as it often also satisfies the next request */
+	devbuf->data = bounce + (where->start - widened.start);
 
-out:
-	dm_free(bounce_buf);
-	return r;
+	return 1;
+
+bad:
+	_release_devbuf(devbuf);
+	return 0;
 }
 
 static int _dev_get_size_file(struct device *dev, uint64_t *size)
diff --git a/lib/device/device.h b/lib/device/device.h
index 4349222..1728596 100644
--- a/lib/device/device.h
+++ b/lib/device/device.h
@@ -56,6 +56,22 @@ struct dev_ext {
 	void *handle;
 };
 
+struct device_area {
+	struct device *dev;
+	uint64_t start;		/* Bytes */
+	uint64_t size;		/* Bytes */
+};
+
+struct device_buffer {
+	void *data;             /* Location of start of requested data (inside buf) */
+
+	/* Private */
+	void *malloc_address;   /* Start of allocated memory */
+	void *buf;              /* Aligned buffer that contains data within it */
+	struct device_area where;       /* Location of buf */
+	unsigned write:1;       /* 1 if write; 0 if read */
+};
+
 /*
  * All devices in LVM will be represented by one of these.
  * pointer comparisons are valid.
@@ -78,6 +94,8 @@ struct device {
 	uint64_t end;
 	struct dm_list open_list;
 	struct dev_ext ext;
+	struct device_buffer last_devbuf;       /* Last data buffer read from the device */
+	struct device_buffer last_extra_devbuf; /* Last data buffer read from the device for extra metadata area */
 
 	const char *vgid; /* if device is an LV */
 	const char *lvid; /* if device is an LV */
@@ -102,17 +120,16 @@ typedef enum dev_io_reason {
 	DEV_IO_LOG		/* Logging messages */
 } dev_io_reason_t;
 
+/*
+ * Is this I/O for a device's extra metadata area?
+ */
+#define EXTRA_IO(reason) ((reason) == DEV_IO_MDA_EXTRA_HEADER || (reason) == DEV_IO_MDA_EXTRA_CONTENT)
+
 struct device_list {
 	struct dm_list list;
 	struct device *dev;
 };
 
-struct device_area {
-	struct device *dev;
-	uint64_t start;		/* Bytes */
-	uint64_t size;		/* Bytes */
-};
-
 /*
  * Support for external device info.
  */
@@ -174,6 +191,8 @@ struct device *dev_create_file(const char *filename, struct device *dev,
 			       struct dm_str_list *alias, int use_malloc);
 void dev_destroy_file(struct device *dev);
 
+void devbufs_release(struct device *dev);
+
 /* Return a valid device name from the alias list; NULL otherwise */
 const char *dev_name_confirmed(struct device *dev, int quiet);
 


