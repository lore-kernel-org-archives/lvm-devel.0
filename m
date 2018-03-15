From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 15 Mar 2018 06:04:21 -0400
Subject: master - devcache: add reason and always log_error
Message-ID: <201803151004.w2FA4LQh023564@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=70ad633638b15568d53312afdfca699f85a26fd1
Commit:        70ad633638b15568d53312afdfca699f85a26fd1
Parent:        2b3b486a371bd9e98f20d14bbad320d610f3ece7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 14 19:33:20 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 15 10:50:28 2018 +0100

devcache: add reason and always log_error

With these read errors it's useful to know the reason.
Also avoid to log error just once so we know exactly
how many times we did failing read.

On the other hand reduce repeated log_error() on code 'backtrace'
path and change severity of message to just log_debug() so the
actual read error is printed once for one read.
---
 WHATS_NEW           |    1 +
 lib/device/dev-io.c |   32 ++++++++++++++++----------------
 2 files changed, 17 insertions(+), 16 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index faf43fe..a545a5d 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.178 - 
 =====================================
+  Enhance error messages when read error happens.
   Enhance mirror log initialization for old mirror target.
   Skip private crypto and stratis devices.
   Skip frozen raid devices from scanning.
diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index 50b1ba8..f9422b1 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -238,10 +238,11 @@ int dev_async_getevents(void)
 				dev_read_callback_fn(0, AIO_SUPPORTED_CODE_PATH, dev_read_callback_context, (char *)devbuf->buf + devbuf->data_offset);
 		} else {
 			/* FIXME If partial read is possible, resubmit remainder */
-			log_error_once("%s: Asynchronous I/O failed: read only %" PRIu64 " of %" PRIu64 " bytes at %" PRIu64,
-				       dev_name(devbuf->where.dev),
-				       (uint64_t) _aio_events[event_nr].res, (uint64_t) devbuf->where.size,
-				       (uint64_t) devbuf->where.start);
+			log_error("%s: asynchronous read only I/O failed (" FMTd64 ") of " FMTu64 " bytes at " FMTu64 " (for %s): %s",
+				  dev_name(devbuf->where.dev), _aio_events[event_nr].res,
+				  (uint64_t) devbuf->where.size, (uint64_t) devbuf->where.start,
+				  _reason_text(devbuf->reason),
+				  ((int64_t)_aio_events[event_nr].res < 0) ? strerror(-(int64_t)_aio_events[event_nr].res) : 0);
 			_release_devbuf(devbuf);
 			if (dev_read_callback_fn)
 				dev_read_callback_fn(1, AIO_SUPPORTED_CODE_PATH, dev_read_callback_context, NULL);
@@ -407,12 +408,13 @@ static int _io_sync(struct device_buffer *devbuf)
 		while ((n < 0) && ((errno == EINTR) || (errno == EAGAIN)));
 
 		if (n < 0)
-			log_error_once("%s: %s failed after %" PRIu64 " of %" PRIu64
-				       "@%" PRIu64 ": %s", dev_name(where->dev),
-				       devbuf->write ? "write" : "read",
-				       (uint64_t) total,
-				       (uint64_t) where->size,
-				       (uint64_t) where->start, strerror(errno));
+			log_error("%s: synchronous %s failed after %" PRIu64 " of %" PRIu64
+				  " at %" PRIu64 " (for %s): %s", dev_name(where->dev),
+				  devbuf->write ? "write" : "read",
+				  (uint64_t) total,
+				  (uint64_t) where->size, (uint64_t) where->start,
+				  _reason_text(devbuf->reason),
+				  strerror(errno));
 
 		if (n <= 0)
 			break;
@@ -1126,7 +1128,7 @@ static int _dev_read_callback(struct device *dev, uint64_t offset, size_t len, d
 
 	ret = _aligned_io(&where, NULL, 0, reason, ioflags, dev_read_callback_fn, callback_context);
 	if (!ret) {
-		log_error("Read from %s failed", dev_name(dev));
+		log_debug("Read from %s failed (for %s).", dev_name(dev), _reason_text(reason));
 		_dev_inc_error_count(dev);
 	}
 
@@ -1160,11 +1162,9 @@ const char *dev_read(struct device *dev, uint64_t offset, size_t len, dev_io_rea
 /* Read into supplied retbuf owned by the caller. */
 int dev_read_buf(struct device *dev, uint64_t offset, size_t len, dev_io_reason_t reason, void *retbuf)
 {
-	if (!_dev_read_callback(dev, offset, len, reason, 0, NULL, NULL)) {
-		log_error("Read from %s failed", dev_name(dev));
-		return 0;
-	}
-	
+	if (!_dev_read_callback(dev, offset, len, reason, 0, NULL, NULL))
+		return_0;
+
 	memcpy(retbuf, DEV_DEVBUF_DATA(dev, reason), len);
 
 	return 1;


