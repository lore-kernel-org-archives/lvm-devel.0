From: Alasdair Kergon <agk@sourceware.org>
Date: Thu, 8 Feb 2018 20:32:21 -0500
Subject: master - lvmcache: Use asynchronous I/O when scanning devices.
Message-ID: <201802090132.w191WLgK027465@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=db41fe6c5dab7ff66db9c0568f0e1e1b31657be3
Commit:        db41fe6c5dab7ff66db9c0568f0e1e1b31657be3
Parent:        8c7bbcfb0f6771a10acd238057fdb7931c3fbb12
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Jan 22 18:17:58 2018 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Feb 8 20:15:29 2018 +0000

lvmcache: Use asynchronous I/O when scanning devices.

---
 WHATS_NEW            |    1 +
 lib/cache/lvmcache.c |   11 +++
 lib/device/dev-io.c  |  165 ++++++++++++++++++++++++++++++++++++++++++++-----
 lib/device/device.h  |    4 +
 4 files changed, 164 insertions(+), 17 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 5aa4ed8..8ae79cf 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.178 - 
 =====================================
+  Support asynchronous I/O when scanning devices.
   Detect asynchronous I/O capability in configure or accept --disable-aio.
   Add AIO_SUPPORTED_CODE_PATH to indicate whether AIO may be used.
   Configure ensures /usr/bin dir is checked for dmpd tools.
diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 2eaf479..7678290 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -1103,6 +1103,11 @@ static void _process_label_data(int failed, unsigned ioflags, void *context, con
 {
 	int *nr_labels_outstanding = context;
 
+	if (!*nr_labels_outstanding) {
+		log_error(INTERNAL_ERROR "_process_label_data called too many times");
+		return;
+	}
+
 	(*nr_labels_outstanding)--;
 }
 
@@ -1163,6 +1168,12 @@ int lvmcache_label_scan(struct cmd_context *cmd)
 
 	dev_iter_destroy(iter);
 
+	while (nr_labels_outstanding) {
+		log_very_verbose("Scanned %d device labels (%d outstanding)", dev_count, nr_labels_outstanding);
+		if (!dev_async_getevents())
+			return_0;
+	}
+
 	log_very_verbose("Scanned %d device labels (%d outstanding)", dev_count, nr_labels_outstanding);
 
 	/*
diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index 48f5b8d..f2bb128 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -103,8 +103,11 @@ void devbufs_release(struct device *dev)
 #  include <libaio.h>
 
 static io_context_t _aio_ctx = 0;
+static struct io_event *_aio_events = NULL;
 static int _aio_max = 128;
 
+#define DEFAULT_AIO_COLLECTION_EVENTS 32
+
 int dev_async_setup(struct cmd_context *cmd)
 {
 	int r;
@@ -115,6 +118,11 @@ int dev_async_setup(struct cmd_context *cmd)
 
 	log_debug_io("Setting up aio context for up to %d events.", _aio_max);
 
+	if (!_aio_events && !(_aio_events = dm_zalloc(sizeof(*_aio_events) * DEFAULT_AIO_COLLECTION_EVENTS))) {
+		log_error("Failed to allocate io_event array for asynchronous I/O.");
+		return 0;
+	}
+
 	if ((r = io_setup(_aio_max, &_aio_ctx)) < 0) {
 		/*
 		 * Possible errors:
@@ -126,6 +134,8 @@ int dev_async_setup(struct cmd_context *cmd)
 		 */
 		log_warn("WARNING: Asynchronous I/O setup for %d events failed: %s", _aio_max, strerror(-r));
 		log_warn("WARNING: Using only synchronous I/O.");
+		dm_free(_aio_events);
+		_aio_events = NULL;
 		_aio_ctx = 0;
 		return 0;
 	}
@@ -138,10 +148,116 @@ int dev_async_reset(struct cmd_context *cmd)
 {
 	log_debug_io("Resetting asynchronous I/O context.");
 	_aio_ctx = 0;
+	dm_free(_aio_events);
+	_aio_events = NULL;
 
 	return dev_async_setup(cmd);
 }
 
+static int _io(struct device_buffer *devbuf, unsigned ioflags);
+
+int dev_async_getevents(void)
+{
+	struct device_buffer *devbuf;
+	lvm_callback_fn_t dev_read_callback_fn;
+	void *dev_read_callback_context;
+	int r, event_nr;
+
+	if (!_aio_ctx)
+		return 1;
+
+	do {
+		/* FIXME Add timeout - currently NULL - waits for ever for@least 1 item */
+		r = io_getevents(_aio_ctx, 1, DEFAULT_AIO_COLLECTION_EVENTS, _aio_events, NULL);
+		if (r > 0)
+			break;
+		if (!r)
+			return 1; /* Timeout elapsed */
+		if (r == -EINTR)
+			continue;
+		if (r == -EAGAIN) {
+			usleep(100);
+			return 1; /* Give the caller the opportunity to do other work before repeating */
+		}
+		/*
+		 * ENOSYS - not supported by kernel
+		 * EFAULT - memory invalid
+		 * EINVAL - _aio_ctx invalid or min_nr/nr/timeout out of range
+		 */
+		log_error("Asynchronous event collection failed: %s", strerror(-r));
+		return 0;
+	} while (1);
+
+	for (event_nr = 0; event_nr < r; event_nr++) {
+		devbuf = _aio_events[event_nr].obj->data;
+		dm_free(_aio_events[event_nr].obj);
+
+		dev_read_callback_fn = devbuf->dev_read_callback_fn;
+		dev_read_callback_context = devbuf->dev_read_callback_context;
+
+		/* Clear the callbacks as a precaution */
+		devbuf->dev_read_callback_context = NULL;
+		devbuf->dev_read_callback_fn = NULL;
+
+		if (_aio_events[event_nr].res == devbuf->where.size) {
+			if (dev_read_callback_fn)
+				dev_read_callback_fn(0, AIO_SUPPORTED_CODE_PATH, dev_read_callback_context, (char *)devbuf->buf + devbuf->data_offset);
+		} else {
+			/* FIXME If partial read is possible, resubmit remainder */
+			log_error_once("%s: Asynchronous I/O failed: read only %" PRIu64 " of %" PRIu64 " bytes at %" PRIu64,
+				       dev_name(devbuf->where.dev),
+				       (uint64_t) _aio_events[event_nr].res, (uint64_t) devbuf->where.size,
+				       (uint64_t) devbuf->where.start);
+			_release_devbuf(devbuf);
+			if (dev_read_callback_fn)
+				dev_read_callback_fn(1, AIO_SUPPORTED_CODE_PATH, dev_read_callback_context, NULL);
+			r = 0;
+		}
+	}
+
+	return 1;
+}
+
+static int _io_async(struct device_buffer *devbuf)
+{
+	struct device_area *where = &devbuf->where;
+	struct iocb *iocb;
+	int r;
+
+	if (!(iocb = dm_malloc(sizeof(*iocb)))) {
+		log_error("Failed to allocate I/O control block array for asynchronous I/O.");
+		return 0;
+	}
+
+	io_prep_pread(iocb, dev_fd(where->dev), devbuf->buf, where->size, where->start);
+	iocb->data = devbuf;
+
+	do {
+		r = io_submit(_aio_ctx, 1L, &iocb);
+		if (r ==1)
+			break;	/* Success */
+		if (r == -EAGAIN) {
+			/* Try to release some resources then retry */
+			usleep(100);
+			if (dev_async_getevents())
+				return_0;
+			/* FIXME Add counter/timeout so we can't get stuck here for ever */
+			continue;
+		}
+		/*
+		 * Possible errors:
+		 *   EFAULT - invalid data
+		 *   ENOSYS - no aio support in kernel
+		 *   EBADF  - bad file descriptor in iocb
+		 *   EINVAL - invalid _aio_ctx / iocb not initialised / invalid operation for this fd
+		 */
+		log_error("Asynchronous event submission failed: %s", strerror(-r));
+		return 0;
+	} while (1);
+
+	return 1;
+}
+
 void dev_async_exit(void)
 {
 	int r;
@@ -154,6 +270,9 @@ void dev_async_exit(void)
 		/* Returns -ENOSYS if aio not in kernel or -EINVAL if _aio_ctx invalid */
 		log_error("Failed to destroy asynchronous I/O context: %s", strerror(-r));
 
+	dm_free(_aio_events);
+	_aio_events = NULL;
+
 	_aio_ctx = 0;
 }
 
@@ -171,10 +290,20 @@ int dev_async_reset(struct cmd_context *cmd)
 	return 1;
 }
 
+int dev_async_getevents(void)
+{
+	return 1;
+}
+
 void dev_async_exit(void)
 {
 }
 
+static int _io_async(struct device_buffer *devbuf)
+{
+	return 0;
+}
+
 #endif /* AIO_SUPPORT */
 
 /*-----------------------------------------------------------------
@@ -225,6 +354,7 @@ static int _io(struct device_buffer *devbuf, unsigned ioflags)
 {
 	struct device_area *where = &devbuf->where;
 	int fd = dev_fd(where->dev);
+	int async = (!devbuf->write && _aio_ctx && aio_supported_code_path(ioflags) && devbuf->dev_read_callback_fn) ? 1 : 0;
 
 	if (fd < 0) {
 		log_error("Attempt to read an unopened device (%s).",
@@ -237,9 +367,9 @@ static int _io(struct device_buffer *devbuf, unsigned ioflags)
 		return 0;
 	}
 
-	log_debug_io("%s %s(fd %d):%8" PRIu64 " bytes (sync) at %" PRIu64 "%s (for %s)",
+	log_debug_io("%s %s(fd %d):%8" PRIu64 " bytes (%ssync)@%" PRIu64 "%s (for %s)",
 		     devbuf->write ? "Write" : "Read ", dev_name(where->dev), fd,
-		     where->size, (uint64_t) where->start,
+		     where->size, async ? "a" : "", (uint64_t) where->start,
 		     (devbuf->write && test_mode()) ? " (test mode - suppressed)" : "", _reason_text(devbuf->reason));
 
 	/*
@@ -253,7 +383,7 @@ static int _io(struct device_buffer *devbuf, unsigned ioflags)
 		return 0;
 	}
 
-	return _io_sync(devbuf);
+	return async ? _io_async(devbuf) : _io_sync(devbuf);
 }
 
 /*-----------------------------------------------------------------
@@ -347,7 +477,7 @@ static void _widen_region(unsigned int block_size, struct device_area *region,
 
 static int _aligned_io(struct device_area *where, char *write_buffer,
 		       int should_write, dev_io_reason_t reason,
-		       unsigned ioflags)
+		       unsigned ioflags, lvm_callback_fn_t dev_read_callback_fn, void *dev_read_callback_context)
 {
 	unsigned int physical_block_size = 0;
 	unsigned int block_size = 0;
@@ -386,6 +516,8 @@ static int _aligned_io(struct device_area *where, char *write_buffer,
 	devbuf->where.size = widened.size;
 	devbuf->write = should_write;
 	devbuf->reason = reason;
+	devbuf->dev_read_callback_fn = dev_read_callback_fn;
+	devbuf->dev_read_callback_context = dev_read_callback_context;
 
 	/* Store location of requested data relative to start of buf */
 	devbuf->data_offset = where->start - devbuf->where.start;
@@ -882,15 +1014,11 @@ int dev_read_callback(struct device *dev, uint64_t offset, size_t len, dev_io_re
 
 	if (!dev->open_count) {
 		log_error(INTERNAL_ERROR "Attempt to access device %s while closed.", dev_name(dev));
-		ret = 0;
-		goto out;
+		return 0;
 	}
 
-	if (!_dev_is_valid(dev)) {
-		log_error("Not reading from %s - too many errors.", dev_name(dev));
-		ret = 0;
-		goto out;
-	}
+	if (!_dev_is_valid(dev))
+		return 0;
 
 	/*
 	 * Can we satisfy this from data we stored last time we read?
@@ -911,14 +1039,15 @@ int dev_read_callback(struct device *dev, uint64_t offset, size_t len, dev_io_re
 	where.start = offset;
 	where.size = len;
 
-	ret = _aligned_io(&where, NULL, 0, reason, ioflags);
+	ret = _aligned_io(&where, NULL, 0, reason, ioflags, dev_read_callback_fn, callback_context);
 	if (!ret) {
-		log_error("Read from %s failed.", dev_name(dev));
+		log_error("Read from %s failed", dev_name(dev));
 		_dev_inc_error_count(dev);
 	}
 
 out:
-	if (dev_read_callback_fn)
+	/* If we had an error or this was sync I/O, pass the result to any callback fn */
+	if ((!ret || !_aio_ctx || !aio_supported_code_path(ioflags) || cached) && dev_read_callback_fn)
 		dev_read_callback_fn(!ret, ioflags, callback_context, DEV_DEVBUF_DATA(dev, reason));
 
 	return ret;
@@ -936,8 +1065,10 @@ const char *dev_read(struct device *dev, uint64_t offset, size_t len, dev_io_rea
 /* Read into supplied retbuf owned by the caller. */
 int dev_read_buf(struct device *dev, uint64_t offset, size_t len, dev_io_reason_t reason, void *retbuf)
 {
-	if (!dev_read_callback(dev, offset, len, reason, 0, NULL, NULL))
-		return_0;
+	if (!dev_read_callback(dev, offset, len, reason, 0, NULL, NULL)) {
+		log_error("Read from %s failed", dev_name(dev));
+		return 0;
+	}
 	
 	memcpy(retbuf, DEV_DEVBUF_DATA(dev, reason), len);
 
@@ -1016,7 +1147,7 @@ int dev_write(struct device *dev, uint64_t offset, size_t len, dev_io_reason_t r
 
 	dev->flags |= DEV_ACCESSED_W;
 
-	ret = _aligned_io(&where, buffer, 1, reason, 0);
+	ret = _aligned_io(&where, buffer, 1, reason, 0, NULL, NULL);
 	if (!ret)
 		_dev_inc_error_count(dev);
 
diff --git a/lib/device/device.h b/lib/device/device.h
index 37d2fd2..b52522d 100644
--- a/lib/device/device.h
+++ b/lib/device/device.h
@@ -97,6 +97,9 @@ struct device_buffer {
 	struct device_area where;	/* Location of buf */
 	dev_io_reason_t reason;
 	unsigned write:1;	/* 1 if write; 0 if read */
+
+	lvm_callback_fn_t dev_read_callback_fn;
+	void *dev_read_callback_context;
 };
 
 /*
@@ -203,6 +206,7 @@ void devbufs_release(struct device *dev);
 const char *dev_name_confirmed(struct device *dev, int quiet);
 
 struct cmd_context;
+int dev_async_getevents(void);
 int dev_async_setup(struct cmd_context *cmd);
 void dev_async_exit(void);
 int dev_async_reset(struct cmd_context *cmd);


