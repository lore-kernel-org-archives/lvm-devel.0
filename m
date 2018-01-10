From: Alasdair Kergon <agk@sourceware.org>
Date: Wed, 10 Jan 2018 10:54:01 -0500
Subject: master - device: Suppress repeated reads of the same data.
Message-ID: <201801101554.w0AFs18t004784@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=366493a1d1900757f4a203d3b89185afb878ad30
Commit:        366493a1d1900757f4a203d3b89185afb878ad30
Parent:        dcb2a5a6116ed4853933e1a72e185a8109aab9cc
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Jan 10 13:19:12 2018 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Jan 10 15:52:03 2018 +0000

device: Suppress repeated reads of the same data.

If the data being requested is present in last_[extra_]devbuf,
return that directly instead of reading it from disk again.

Typical LVM2 access patterns request data within two adjacent 4k blocks
so we eliminate some read() system calls by always reading at least 8k.
---
 WHATS_NEW           |    1 +
 lib/device/dev-io.c |   33 +++++++++++++++++++++++++++++++--
 2 files changed, 32 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 897576c..489c315 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.178 - 
 =====================================
+  Suppress some repeated reads of the same disk data at the device layer.
   Avoid exceeding array bounds in allocation tag processing.
   Refactor metadata reading code to use callback functions.
   Move memory allocation for the key dev_reads into the device layer.
diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index 30e4235..bacc7de 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -53,6 +53,12 @@
 #  endif
 #endif
 
+/*
+ * Always read at least 8k from disk.
+ * This seems to be a good compromise for the existing LVM2 metadata layout.
+ */
+#define MIN_READ_SIZE (8 * 1024)
+
 static DM_LIST_INIT(_open_devices);
 static unsigned _dev_size_seqno = 1;
 
@@ -273,6 +279,11 @@ static int _aligned_io(struct device_area *where, char *buffer,
 
 	if (!block_size)
 		block_size = lvm_getpagesize();
+
+	/* Apply minimum read size */
+	if (!should_write && block_size < MIN_READ_SIZE)
+		block_size = MIN_READ_SIZE;
+
 	mask = block_size - 1;
 
 	_widen_region(block_size, where, &widened);
@@ -785,14 +796,32 @@ static void _dev_inc_error_count(struct device *dev)
 static int _dev_read(struct device *dev, uint64_t offset, size_t len, dev_io_reason_t reason)
 {
 	struct device_area where;
+	struct device_buffer *devbuf;
+	uint64_t buf_end;
 	int ret;
 
-	if (!dev->open_count)
-		return_0;
+	if (!dev->open_count) {
+		log_error(INTERNAL_ERROR "Attempt to access device %s while closed.", dev_name(dev));
+		return 0;
+	}
 
 	if (!_dev_is_valid(dev))
 		return 0;
 
+	/*
+	 * Can we satisfy this from data we stored last time we read?
+	 */
+	if ((devbuf = DEV_DEVBUF(dev, reason)) && devbuf->malloc_address) {
+		buf_end = devbuf->where.start + devbuf->where.size - 1;
+		if (offset >= devbuf->where.start && offset <= buf_end && offset + len - 1 <= buf_end) {
+			/* Reuse this buffer */
+			devbuf->data = (char *) devbuf->buf + (offset - devbuf->where.start);
+			log_debug_io("Cached read for %" PRIu64 " bytes at %" PRIu64 " on %s (for %s)",
+				     len, (uint64_t) offset, dev_name(dev), _reason_text(reason));
+			return 1;
+		}
+	}
+
 	where.dev = dev;
 	where.start = offset;
 	where.size = len;


