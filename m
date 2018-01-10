From: Alasdair Kergon <agk@sourceware.org>
Date: Wed, 10 Jan 2018 14:26:41 -0500
Subject: master - device: Eliminate unnecessary buffer from dev_read.
Message-ID: <201801101926.w0AJQf1s012684@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c350f96c09f3fb591de1742829006769f53c29eb
Commit:        c350f96c09f3fb591de1742829006769f53c29eb
Parent:        366493a1d1900757f4a203d3b89185afb878ad30
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Jan 10 18:48:01 2018 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Jan 10 18:48:01 2018 +0000

device: Eliminate unnecessary buffer from dev_read.

---
 lib/device/dev-io.c           |   39 ++++++++++++---------------------------
 lib/format_text/format-text.c |   14 +++++---------
 lib/label/label.c             |    1 -
 3 files changed, 17 insertions(+), 37 deletions(-)

diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index bacc7de..9920ee5 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -817,7 +817,7 @@ static int _dev_read(struct device *dev, uint64_t offset, size_t len, dev_io_rea
 			/* Reuse this buffer */
 			devbuf->data = (char *) devbuf->buf + (offset - devbuf->where.start);
 			log_debug_io("Cached read for %" PRIu64 " bytes at %" PRIu64 " on %s (for %s)",
-				     len, (uint64_t) offset, dev_name(dev), _reason_text(reason));
+				     (uint64_t) len, (uint64_t) offset, dev_name(dev), _reason_text(reason));
 			return 1;
 		}
 	}
@@ -833,27 +833,18 @@ static int _dev_read(struct device *dev, uint64_t offset, size_t len, dev_io_rea
 	return ret;
 }
 
-/* Caller is responsible for dm_free */
+/* Returns pointer to read-only buffer. Caller does not free it.  */
 char *dev_read(struct device *dev, uint64_t offset, size_t len, dev_io_reason_t reason)
 {
-	char *buf;
-
-	if (!(buf = dm_malloc(len))) {
-		log_error("Buffer allocation failed for device read.");
-		return NULL;
-	}
-
 	if (!_dev_read(dev, offset, len, reason)) {
 		log_error("Read from %s failed", dev_name(dev));
-		dm_free(buf);
 		return NULL;
 	}
 
-	memcpy(buf, DEV_DEVBUF(dev, reason)->data, len);
-
-	return buf;
+	return DEV_DEVBUF(dev, reason)->data;
 }
 
+/* Obtains data requested then passes it (read-only) to dev_read_callback_fn() */
 int dev_read_callback(struct device *dev, uint64_t offset, size_t len, dev_io_reason_t reason,
 		      lvm_callback_fn_t dev_read_callback_fn, void *callback_context)
 {
@@ -873,17 +864,15 @@ out:
 	return r;
 }
 
-/* Read into supplied retbuf */
+/* Read into supplied retbuf owned by the caller. */
 int dev_read_buf(struct device *dev, uint64_t offset, size_t len, dev_io_reason_t reason, void *retbuf)
 {
-	char *buf = NULL;
-
-	if (!(buf = dev_read(dev, offset, len, reason)))
-		return_0;
+	if (!_dev_read(dev, offset, len, reason)) {
+		log_error("Read from %s failed", dev_name(dev));
+		return 0;
+	}
 	
-	memcpy(retbuf, buf, len);
-
-	dm_free(buf);
+	memcpy(retbuf, DEV_DEVBUF(dev, reason)->data, len);
 
 	return 1;
 }
@@ -902,22 +891,18 @@ char *dev_read_circular(struct device *dev, uint64_t offset, size_t len,
 		return NULL;
 	}
 
-	if (!_dev_read(dev, offset, len, reason)) {
+	if (!dev_read_buf(dev, offset, len, reason, buf)) {
 		log_error("Read from %s failed", dev_name(dev));
 		dm_free(buf);
 		return NULL;
 	}
 
-	memcpy(buf, DEV_DEVBUF(dev, reason)->data, len);
-
-	if (!_dev_read(dev, offset2, len2, reason)) {
+	if (!dev_read_buf(dev, offset2, len2, reason, buf + len)) {
 		log_error("Circular read from %s failed", dev_name(dev));
 		dm_free(buf);
 		return NULL;
 	}
 
-	memcpy(buf + len, DEV_DEVBUF(dev, reason)->data, len2);
-
 	return buf;
 }
 
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 26a5007..d28449c 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -272,20 +272,20 @@ static int _pv_analyze_mda_raw (const struct format_type * fmt,
 				size += SECTOR_SIZE;
 			}
 		}
-		dm_free(buf);
+		if (circular)
+			dm_free(buf);
 		buf = NULL;
 	}
 
 	r = 1;
  out:
-	dm_free(buf);
+	if (circular)
+		dm_free(buf);
 	if (!dev_close(area->dev))
 		stack;
 	return r;
 }
 
-
-
 static int _text_lv_setup(struct format_instance *fid __attribute__((unused)),
 			  struct logical_volume *lv)
 {
@@ -512,12 +512,8 @@ static struct raw_locn *_find_vg_rlocn(struct device_area *dev_area,
 		goto_bad;
 
 	if (!strncmp(buf, vgname, len = strlen(vgname)) &&
-	    (isspace(*(buf + len)) || *(buf + len) == '{')) {
-		dm_free(buf);
+	    (isspace(*(buf + len)) || *(buf + len) == '{'))
 		return rlocn;
-	}
-
-	dm_free(buf);
 
 	log_debug_metadata("Volume group name found in %smetadata on %s at " FMTu64 " does "
 			   "not match expected name %s.", 
diff --git a/lib/label/label.c b/lib/label/label.c
index 919a507..afb3b19 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -307,7 +307,6 @@ int label_remove(struct device *dev)
 	if (!dev_close(dev))
 		stack;
 
-	dm_free(readbuf);
 	return r;
 }
 


