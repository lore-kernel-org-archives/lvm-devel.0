From: Alasdair Kergon <agk@sourceware.org>
Date: Wed, 10 Jan 2018 10:53:37 -0500
Subject: master - device: Remove some data copying between buffers.
Message-ID: <201801101553.w0AFrbJF004751@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=dcb2a5a6116ed4853933e1a72e185a8109aab9cc
Commit:        dcb2a5a6116ed4853933e1a72e185a8109aab9cc
Parent:        4d568b709cec5f84c8a8a278747b997a75b4c463
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Jan 10 13:18:56 2018 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Jan 10 15:48:03 2018 +0000

device: Remove some data copying between buffers.

Callers that read larger amounts of data now get a pointer to read-only
data directly without copying it through an intermediate buffer.  This
data is owned by the device layer so the callers no longer free it.
---
 lib/config/config.c           |    4 +---
 lib/device/dev-io.c           |   38 ++++++++++++++++++--------------------
 lib/device/device.h           |    1 +
 lib/format_text/format-text.c |    6 +-----
 lib/label/label.c             |    2 --
 5 files changed, 21 insertions(+), 30 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index 7217cd9..9dd8a61 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -534,9 +534,6 @@ static void _process_config_file_buffer(int failed, void *context, void *data)
 	}
 
 out:
-	if (!failed && !pcfp->use_mmap)
-		dm_free(data);
-
 	if (pcfp->config_file_read_fd_callback)
 		pcfp->config_file_read_fd_callback(!pcfp->ret, pcfp->config_file_read_fd_context, NULL);
 }
@@ -612,6 +609,7 @@ int config_file_read_fd(struct dm_pool *mem, struct dm_config_tree *cft, struct
 			if (!(buf = dev_read_circular(dev, (uint64_t) offset, size, (uint64_t) offset2, size2, reason)))
 				goto_out;
 			_process_config_file_buffer(0, pcfp, buf);
+			dm_free(buf);
 		} else if (!dev_read_callback(dev, (uint64_t) offset, size, reason, _process_config_file_buffer, pcfp))
 			goto_out;
 		r = pcfp->ret;
diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index 18a09d1..30e4235 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -284,7 +284,7 @@ static int _aligned_io(struct device_area *where, char *buffer,
 			     where->size, (uint64_t) where->start, widened.size, (uint64_t) widened.start, dev_name(where->dev), _reason_text(reason));
 	} 
 
-	if (!buffer_was_widened && !((uintptr_t) buffer & mask))
+	if (should_write && !buffer_was_widened && !((uintptr_t) buffer & mask))
 		/* Perform the I/O directly. */
 		bounce = buffer;
 #ifndef DEBUG_MEM
@@ -308,7 +308,7 @@ static int _aligned_io(struct device_area *where, char *buffer,
 	}
 #endif
 
-	devbuf = EXTRA_IO(reason) ? &where->dev->last_extra_devbuf : &where->dev->last_devbuf;
+	devbuf = DEV_DEVBUF(where->dev, reason);
  	_release_devbuf(devbuf);
 	devbuf->malloc_address = bounce_buf;
 	devbuf->buf = bounce;
@@ -345,9 +345,6 @@ static int _aligned_io(struct device_area *where, char *buffer,
 	}
 
 	/* read */
-	if (bounce_buf)
-		memcpy(buffer, bounce + (where->start - widened.start),
-		       (size_t) where->size);
 
 	/* We store what we just read as it often also satisfies the next request */
 	devbuf->data = bounce + (where->start - widened.start);
@@ -782,7 +779,10 @@ static void _dev_inc_error_count(struct device *dev)
 			 dev->max_error_count, dev_name(dev));
 }
 
-static int _dev_read(struct device *dev, uint64_t offset, size_t len, dev_io_reason_t reason, char *buf)
+/*
+ * Data is returned (read-only) at dev->last_[extra_]devbuf->data
+ */
+static int _dev_read(struct device *dev, uint64_t offset, size_t len, dev_io_reason_t reason)
 {
 	struct device_area where;
 	int ret;
@@ -797,7 +797,7 @@ static int _dev_read(struct device *dev, uint64_t offset, size_t len, dev_io_rea
 	where.start = offset;
 	where.size = len;
 
-	ret = _aligned_io(&where, buf, 0, reason);
+	ret = _aligned_io(&where, NULL, 0, reason);
 	if (!ret)
 		_dev_inc_error_count(dev);
 
@@ -814,30 +814,24 @@ char *dev_read(struct device *dev, uint64_t offset, size_t len, dev_io_reason_t
 		return NULL;
 	}
 
-	if (!_dev_read(dev, offset, len, reason, buf)) {
+	if (!_dev_read(dev, offset, len, reason)) {
 		log_error("Read from %s failed", dev_name(dev));
 		dm_free(buf);
 		return NULL;
 	}
 
+	memcpy(buf, DEV_DEVBUF(dev, reason)->data, len);
+
 	return buf;
 }
 
-/* Callback fn is responsible for dm_free */
 int dev_read_callback(struct device *dev, uint64_t offset, size_t len, dev_io_reason_t reason,
 		      lvm_callback_fn_t dev_read_callback_fn, void *callback_context)
 {
-	char *buf;
 	int r = 0;
 
-	if (!(buf = dm_malloc(len))) {
-		log_error("Buffer allocation failed for device read.");
-		goto out;
-	}
-
-	if (!_dev_read(dev, offset, len, reason, buf)) {
+	if (!_dev_read(dev, offset, len, reason)) {
 		log_error("Read from %s failed", dev_name(dev));
-		dm_free(buf);
 		goto out;
 	}
 
@@ -845,7 +839,7 @@ int dev_read_callback(struct device *dev, uint64_t offset, size_t len, dev_io_re
 
 out:
 	if (dev_read_callback_fn)
-		dev_read_callback_fn(!r, callback_context, buf);
+		dev_read_callback_fn(!r, callback_context, DEV_DEVBUF(dev, reason)->data);
 
 	return r;
 }
@@ -879,18 +873,22 @@ char *dev_read_circular(struct device *dev, uint64_t offset, size_t len,
 		return NULL;
 	}
 
-	if (!_dev_read(dev, offset, len, reason, buf)) {
+	if (!_dev_read(dev, offset, len, reason)) {
 		log_error("Read from %s failed", dev_name(dev));
 		dm_free(buf);
 		return NULL;
 	}
 
-	if (!_dev_read(dev, offset2, len2, reason, buf + len)) {
+	memcpy(buf, DEV_DEVBUF(dev, reason)->data, len);
+
+	if (!_dev_read(dev, offset2, len2, reason)) {
 		log_error("Circular read from %s failed", dev_name(dev));
 		dm_free(buf);
 		return NULL;
 	}
 
+	memcpy(buf + len, DEV_DEVBUF(dev, reason)->data, len2);
+
 	return buf;
 }
 
diff --git a/lib/device/device.h b/lib/device/device.h
index 1728596..cf44362 100644
--- a/lib/device/device.h
+++ b/lib/device/device.h
@@ -124,6 +124,7 @@ typedef enum dev_io_reason {
  * Is this I/O for a device's extra metadata area?
  */
 #define EXTRA_IO(reason) ((reason) == DEV_IO_MDA_EXTRA_HEADER || (reason) == DEV_IO_MDA_EXTRA_CONTENT)
+#define DEV_DEVBUF(dev, reason) (EXTRA_IO((reason)) ? &(dev)->last_extra_devbuf : &(dev)->last_devbuf)
 
 struct device_list {
 	struct dm_list list;
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 7e80a11..26a5007 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -385,9 +385,6 @@ static void _process_raw_mda_header(int failed, void *context, void *data)
 bad:
 	prmp->ret = 0;
 out:
-	if (!failed)
-		dm_free(data);
-
 	if (prmp->ret && prmp->mdah_callback_fn)
 		prmp->mdah_callback_fn(0, prmp->mdah_callback_context, mdah);
 }
@@ -1474,8 +1471,7 @@ static void _vgname_from_mda_validate(int failed, void *context, void *data)
 	}
 
 out:
-	if (!failed)
-		dm_free(data);
+	;
 }
 
 int vgname_from_mda(const struct format_type *fmt,
diff --git a/lib/label/label.c b/lib/label/label.c
index 362a1b0..919a507 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -226,8 +226,6 @@ static void _find_labeller(int failed, void *context, void *data)
 		}
 	}
 
-	dm_free(readbuf);
-
 	if (!l) {
 		if ((info = lvmcache_info_from_pvid(dev->pvid, dev, 0)))
 			_update_lvmcache_orphan(info);


