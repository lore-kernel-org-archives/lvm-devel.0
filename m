From: Alasdair Kergon <agk@sourceware.org>
Date: Fri, 15 Dec 2017 17:38:21 -0500
Subject: master - format_text: Transfer circular buf alloc to device layer.
Message-ID: <201712152238.vBFMcLHF027363@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5f45cb90a7d6ca8ea3d0456c42d2fc4721cf5d79
Commit:        5f45cb90a7d6ca8ea3d0456c42d2fc4721cf5d79
Parent:        beee9940a503dd6165afd73835d3a6935afcce60
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Dec 15 22:34:26 2017 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Dec 15 22:34:26 2017 +0000

format_text: Transfer circular buf alloc to device layer.

Instead of the caller passing dev_read_circular() a buffer to fill with
data, the device layer itself now allocates it.
---
 lib/config/config.c           |   15 ++++-----------
 lib/device/dev-io.c           |   27 +++++++++++++++++----------
 lib/device/device.h           |    4 ++--
 lib/format_text/format-text.c |   12 +++++++-----
 4 files changed, 30 insertions(+), 28 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index f634e5b..fac7e4c 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -530,22 +530,15 @@ int config_file_read_fd(struct dm_config_tree *cft, struct device *dev, dev_io_r
 		fb = fb + mmap_offset;
 	} else {
 		if (circular) {
-			if (!(buf = dm_malloc(size + size2))) {
-				log_error("Failed to allocate circular buffer.");
-				return 0;
-			}
-			if (!dev_read_circular(dev, (uint64_t) offset, size,
-					       (uint64_t) offset2, size2, reason, buf)) {
-				goto out;
-			}
+			if (!(buf = dev_read_circular(dev, (uint64_t) offset, size, (uint64_t) offset2, size2, reason)))
+				goto_out;
 		} else {
 			if (!(buf = dm_malloc(size))) {
 				log_error("Failed to allocate buffer for metadata read.");
 				return 0;
 			}
-			if (!dev_read(dev, (uint64_t) offset, size, reason, buf)) {
-				goto out;
-			}
+			if (!dev_read(dev, (uint64_t) offset, size, reason, buf))
+				goto_out;
 		}
 		fb = buf;
 	}
diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index 1adf2ad..0545d8c 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -745,25 +745,32 @@ int dev_read(struct device *dev, uint64_t offset, size_t len, dev_io_reason_t re
 }
 
 /*
- * Read from 'dev' into 'buf' in 2 distinct regions, denoted
- * by (offset,len) and (offset2,len2).  Thus, the total size of
- * 'buf' should be len+len2.
+ * Read from 'dev' in 2 distinct regions, denoted by (offset,len) and (offset2,len2).
+ * Caller is responsible for dm_free().
  */
-int dev_read_circular(struct device *dev, uint64_t offset, size_t len,
-		      uint64_t offset2, size_t len2, dev_io_reason_t reason, char *buf)
+char *dev_read_circular(struct device *dev, uint64_t offset, size_t len,
+			uint64_t offset2, size_t len2, dev_io_reason_t reason)
 {
+	char *buf = NULL;
+
+	if (!(buf = dm_malloc(len + len2))) {
+		log_error("Buffer allocation failed for split metadata.");
+		return NULL;
+	}
+
 	if (!dev_read(dev, offset, len, reason, buf)) {
 		log_error("Read from %s failed", dev_name(dev));
-		return 0;
+		dm_free(buf);
+		return NULL;
 	}
 
 	if (!dev_read(dev, offset2, len2, reason, buf + len)) {
-		log_error("Circular read from %s failed",
-			  dev_name(dev));
-		return 0;
+		log_error("Circular read from %s failed", dev_name(dev));
+		dm_free(buf);
+		return NULL;
 	}
 
-	return 1;
+	return buf;
 }
 
 /* FIXME If O_DIRECT can't extend file, dev_extend first; dev_truncate after.
diff --git a/lib/device/device.h b/lib/device/device.h
index 503373f..a369195 100644
--- a/lib/device/device.h
+++ b/lib/device/device.h
@@ -146,8 +146,8 @@ int dev_fd(struct device *dev);
 const char *dev_name(const struct device *dev);
 
 int dev_read(struct device *dev, uint64_t offset, size_t len, dev_io_reason_t reason, void *buffer);
-int dev_read_circular(struct device *dev, uint64_t offset, size_t len,
-		      uint64_t offset2, size_t len2, dev_io_reason_t reason, char *buf);
+char *dev_read_circular(struct device *dev, uint64_t offset, size_t len,
+			uint64_t offset2, size_t len2, dev_io_reason_t reason);
 int dev_write(struct device *dev, uint64_t offset, size_t len, dev_io_reason_t reason, void *buffer);
 int dev_append(struct device *dev, size_t len, dev_io_reason_t reason, char *buffer);
 int dev_set(struct device *dev, uint64_t offset, size_t len, dev_io_reason_t reason, int value);
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index ebc2dbb..79bb9fa 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -234,16 +234,18 @@ static int _pv_analyze_mda_raw (const struct format_type * fmt,
 		 * "dm_config_maybe_section" returning true when there's no valid
 		 * metadata in a sector (sectors with all nulls).
 		 */
-		if (!(buf = dm_malloc(size + size2)))
-			goto_out;
 
 		circular = size2 ? 1 : 0;
 
 		if (circular) {
-			if (!dev_read_circular(area->dev, offset, size, offset2, size2, MDA_CONTENT_REASON(mda_is_primary(mda)), buf))
+			if (!(buf = dev_read_circular(area->dev, offset, size, offset2, size2, MDA_CONTENT_REASON(mda_is_primary(mda)))))
 				goto_out;
-		} else if (!dev_read(area->dev, offset, size, MDA_CONTENT_REASON(mda_is_primary(mda)), buf))
-			goto_out;
+		} else {
+			if (!(buf = dm_malloc(size)))
+				goto_out;
+			if (!dev_read(area->dev, offset, size, MDA_CONTENT_REASON(mda_is_primary(mda)), buf))
+				goto_out;
+		}
 
 		/*
 		 * FIXME: We could add more sophisticated metadata detection


