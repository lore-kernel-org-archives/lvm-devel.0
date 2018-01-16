From: Alasdair Kergon <agk@sourceware.org>
Date: Mon, 15 Jan 2018 22:17:26 -0500
Subject: master - device: Merge _dev_read and dev_read_callback.
Message-ID: <201801160317.w0G3HQKn025413@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=081902b4c115c465b123c13e9d8287a75f9d7b2a
Commit:        081902b4c115c465b123c13e9d8287a75f9d7b2a
Parent:        0a3c6bf8c61224024c030152693fe2ce103cc6f0
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Jan 16 00:41:42 2018 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Jan 16 00:41:42 2018 +0000

device: Merge _dev_read and dev_read_callback.

---
 lib/device/dev-io.c      |   59 ++++++++++++++++++---------------------------
 lib/format1/lvm1-label.c |    2 +-
 2 files changed, 25 insertions(+), 36 deletions(-)

diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index 6d5433f..d995452 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -791,20 +791,26 @@ static void _dev_inc_error_count(struct device *dev)
 /*
  * Data is returned (read-only) at DEV_DEVBUF_DATA(dev, reason)
  */
-static int _dev_read(struct device *dev, uint64_t offset, size_t len, dev_io_reason_t reason)
+int dev_read_callback(struct device *dev, uint64_t offset, size_t len, dev_io_reason_t reason,
+		      lvm_callback_fn_t dev_read_callback_fn, void *callback_context)
 {
 	struct device_area where;
 	struct device_buffer *devbuf;
 	uint64_t buf_end;
-	int ret;
+	int cached = 0;
+	int ret = 1;
 
 	if (!dev->open_count) {
 		log_error(INTERNAL_ERROR "Attempt to access device %s while closed.", dev_name(dev));
-		return 0;
+		ret = 0;
+		goto out;
 	}
 
-	if (!_dev_is_valid(dev))
-		return 0;
+	if (!_dev_is_valid(dev)) {
+		log_error("Not reading from %s - too many errors.", dev_name(dev));
+		ret = 0;
+		goto out;
+	}
 
 	/*
 	 * Can we satisfy this from data we stored last time we read?
@@ -813,10 +819,11 @@ static int _dev_read(struct device *dev, uint64_t offset, size_t len, dev_io_rea
 		buf_end = devbuf->where.start + devbuf->where.size - 1;
 		if (offset >= devbuf->where.start && offset <= buf_end && offset + len - 1 <= buf_end) {
 			/* Reuse this buffer */
+			cached = 1;
 			devbuf->data_offset = offset - devbuf->where.start;
 			log_debug_io("Cached read for %" PRIu64 " bytes at %" PRIu64 " on %s (for %s)",
 				     (uint64_t) len, (uint64_t) offset, dev_name(dev), _reason_text(reason));
-			return 1;
+			goto out;
 		}
 	}
 
@@ -825,8 +832,14 @@ static int _dev_read(struct device *dev, uint64_t offset, size_t len, dev_io_rea
 	where.size = len;
 
 	ret = _aligned_io(&where, NULL, 0, reason);
-	if (!ret)
+	if (!ret) {
+		log_error("Read from %s failed.", dev_name(dev));
 		_dev_inc_error_count(dev);
+	}
+
+out:
+	if (dev_read_callback_fn)
+		dev_read_callback_fn(!ret, callback_context, DEV_DEVBUF_DATA(dev, reason));
 
 	return ret;
 }
@@ -834,41 +847,17 @@ static int _dev_read(struct device *dev, uint64_t offset, size_t len, dev_io_rea
 /* Returns pointer to read-only buffer. Caller does not free it.  */
 const char *dev_read(struct device *dev, uint64_t offset, size_t len, dev_io_reason_t reason)
 {
-	if (!_dev_read(dev, offset, len, reason)) {
-		log_error("Read from %s failed", dev_name(dev));
-		return NULL;
-	}
+	if (!dev_read_callback(dev, offset, len, reason, NULL, NULL))
+		return_NULL;
 
 	return DEV_DEVBUF_DATA(dev, reason);
 }
 
-/* Obtains data requested then passes it (read-only) to dev_read_callback_fn() */
-int dev_read_callback(struct device *dev, uint64_t offset, size_t len, dev_io_reason_t reason,
-		      lvm_callback_fn_t dev_read_callback_fn, void *callback_context)
-{
-	int r = 0;
-
-	if (!_dev_read(dev, offset, len, reason)) {
-		log_error("Read from %s failed", dev_name(dev));
-		goto out;
-	}
-
-	r = 1;
-
-out:
-	if (dev_read_callback_fn)
-		dev_read_callback_fn(!r, callback_context, DEV_DEVBUF_DATA(dev, reason));
-
-	return r;
-}
-
 /* Read into supplied retbuf owned by the caller. */
 int dev_read_buf(struct device *dev, uint64_t offset, size_t len, dev_io_reason_t reason, void *retbuf)
 {
-	if (!_dev_read(dev, offset, len, reason)) {
-		log_error("Read from %s failed", dev_name(dev));
-		return 0;
-	}
+	if (!dev_read_callback(dev, offset, len, reason, NULL, NULL))
+		return_0;
 	
 	memcpy(retbuf, DEV_DEVBUF_DATA(dev, reason), len);
 
diff --git a/lib/format1/lvm1-label.c b/lib/format1/lvm1-label.c
index 1452dea..77dab1e 100644
--- a/lib/format1/lvm1-label.c
+++ b/lib/format1/lvm1-label.c
@@ -64,7 +64,7 @@ static int _lvm1_read(struct labeller *l, struct device *dev, void *buf,
 	const char *vgid = FMT_LVM1_ORPHAN_VG_NAME;
 	const char *vgname = FMT_LVM1_ORPHAN_VG_NAME;
 	unsigned exported = 0;
-	int r;
+	int r = 0;
 
 	munge_pvd(dev, pvd);
 


