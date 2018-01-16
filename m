From: Alasdair Kergon <agk@sourceware.org>
Date: Mon, 15 Jan 2018 22:17:09 -0500
Subject: master - device: Store offset to data instead of pointer.
Message-ID: <201801160317.w0G3H91D025353@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1f01eaa61200bb1144bb6f424d8df2c77a8b8307
Commit:        1f01eaa61200bb1144bb6f424d8df2c77a8b8307
Parent:        61d3296f2aae134a9215a9c9c2f3146a75fddc19
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Jan 15 19:32:59 2018 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Jan 15 19:32:59 2018 +0000

device: Store offset to data instead of pointer.

We want to save the relative offset before we've allocated the
buffer's memory.
---
 lib/device/dev-io.c |   12 ++++++------
 lib/device/device.h |    3 ++-
 2 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index f916761..38127c7 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -358,7 +358,7 @@ static int _aligned_io(struct device_area *where, char *buffer,
 	/* read */
 
 	/* We store what we just read as it often also satisfies the next request */
-	devbuf->data = bounce + (where->start - widened.start);
+	devbuf->data_offset = where->start - widened.start;
 
 	return 1;
 
@@ -791,7 +791,7 @@ static void _dev_inc_error_count(struct device *dev)
 }
 
 /*
- * Data is returned (read-only) at dev->last_[extra_]devbuf->data
+ * Data is returned (read-only) at DEV_DEVBUF_DATA(dev, reason)
  */
 static int _dev_read(struct device *dev, uint64_t offset, size_t len, dev_io_reason_t reason)
 {
@@ -815,7 +815,7 @@ static int _dev_read(struct device *dev, uint64_t offset, size_t len, dev_io_rea
 		buf_end = devbuf->where.start + devbuf->where.size - 1;
 		if (offset >= devbuf->where.start && offset <= buf_end && offset + len - 1 <= buf_end) {
 			/* Reuse this buffer */
-			devbuf->data = (char *) devbuf->buf + (offset - devbuf->where.start);
+			devbuf->data_offset = offset - devbuf->where.start;
 			log_debug_io("Cached read for %" PRIu64 " bytes at %" PRIu64 " on %s (for %s)",
 				     (uint64_t) len, (uint64_t) offset, dev_name(dev), _reason_text(reason));
 			return 1;
@@ -841,7 +841,7 @@ const char *dev_read(struct device *dev, uint64_t offset, size_t len, dev_io_rea
 		return NULL;
 	}
 
-	return DEV_DEVBUF(dev, reason)->data;
+	return DEV_DEVBUF_DATA(dev, reason);
 }
 
 /* Obtains data requested then passes it (read-only) to dev_read_callback_fn() */
@@ -859,7 +859,7 @@ int dev_read_callback(struct device *dev, uint64_t offset, size_t len, dev_io_re
 
 out:
 	if (dev_read_callback_fn)
-		dev_read_callback_fn(!r, callback_context, DEV_DEVBUF(dev, reason)->data);
+		dev_read_callback_fn(!r, callback_context, DEV_DEVBUF_DATA(dev, reason));
 
 	return r;
 }
@@ -872,7 +872,7 @@ int dev_read_buf(struct device *dev, uint64_t offset, size_t len, dev_io_reason_
 		return 0;
 	}
 	
-	memcpy(retbuf, DEV_DEVBUF(dev, reason)->data, len);
+	memcpy(retbuf, DEV_DEVBUF_DATA(dev, reason), len);
 
 	return 1;
 }
diff --git a/lib/device/device.h b/lib/device/device.h
index 6280138..2a05fd4 100644
--- a/lib/device/device.h
+++ b/lib/device/device.h
@@ -77,6 +77,7 @@ typedef enum dev_io_reason {
  */
 #define EXTRA_IO(reason) ((reason) == DEV_IO_MDA_EXTRA_HEADER || (reason) == DEV_IO_MDA_EXTRA_CONTENT)
 #define DEV_DEVBUF(dev, reason) (EXTRA_IO((reason)) ? &(dev)->last_extra_devbuf : &(dev)->last_devbuf)
+#define DEV_DEVBUF_DATA(dev, reason) ((char *) DEV_DEVBUF((dev), (reason))->buf + DEV_DEVBUF((dev), (reason))->data_offset)
 
 struct device_area {
 	struct device *dev;
@@ -85,7 +86,7 @@ struct device_area {
 };
 
 struct device_buffer {
-	const void *data;	/* Location of start of requested data (inside buf) */
+	uint64_t data_offset;	/* Offset to start of requested data within buf */
 	void *malloc_address;	/* Start of allocated memory */
 	void *buf;		/* Aligned buffer that contains data within it */
 	struct device_area where;	/* Location of buf */


