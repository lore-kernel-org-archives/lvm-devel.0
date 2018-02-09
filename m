From: Alasdair Kergon <agk@sourceware.org>
Date: Thu, 8 Feb 2018 20:32:30 -0500
Subject: master - device: Fix basic async I/O error handling
Message-ID: <201802090132.w191WUd6027517@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d6cabbbc53de615fe92ff6372a570285704b59d2
Commit:        d6cabbbc53de615fe92ff6372a570285704b59d2
Parent:        3e29c80122b8eb1123e42d143f17dd7bddefedcd
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Feb 6 21:43:06 2018 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Feb 8 20:19:21 2018 +0000

device: Fix basic async I/O error handling

---
 lib/cache/lvmcache.c          |    2 ++
 lib/config/config.c           |    7 +++++--
 lib/device/dev-io.c           |   36 ++++++++++++++++++++++++++----------
 lib/device/device.h           |    6 +++---
 lib/format_text/format-text.c |   32 +++++++++++++++++---------------
 lib/format_text/import.c      |    4 ++--
 lib/format_text/text_label.c  |    6 +++++-
 lib/label/label.c             |   15 +++++++--------
 8 files changed, 67 insertions(+), 41 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 7678290..4022ea6 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -1099,6 +1099,7 @@ next:
 }
 
 /* Track the number of outstanding label reads */
+/* FIXME Switch to struct and also track failed */
 static void _process_label_data(int failed, unsigned ioflags, void *context, const void *data)
 {
 	int *nr_labels_outstanding = context;
@@ -1160,6 +1161,7 @@ int lvmcache_label_scan(struct cmd_context *cmd)
 	_destroy_duplicate_device_list(&_found_duplicate_devs);
 
 	while ((dev = dev_iter_get(iter))) {
+		log_debug_io("Scanning device %s", dev_name(dev));
 		nr_labels_outstanding++;
 		if (!label_read_callback(dev, UINT64_C(0), AIO_SUPPORTED_CODE_PATH, _process_label_data, &nr_labels_outstanding))
 			nr_labels_outstanding--;
diff --git a/lib/config/config.c b/lib/config/config.c
index c69ac69..97c5db8 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -609,8 +609,11 @@ int config_file_read_fd(struct dm_pool *mem, struct dm_config_tree *cft, struct
 				goto_out;
 			_process_config_file_buffer(0, ioflags, pcfp, buf);
 			dm_free((void *)buf);
-		} else if (!dev_read_callback(dev, (uint64_t) offset, size, reason, ioflags, _process_config_file_buffer, pcfp))
-			goto_out;
+		} else {
+			dev_read_callback(dev, (uint64_t) offset, size, reason, ioflags, _process_config_file_buffer, pcfp);
+			if (config_file_read_fd_callback)
+				return 1;
+		}
 		r = pcfp->ret;
 	}
 
diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index 460c874..31506e8 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -245,7 +245,8 @@ int dev_async_getevents(void)
 			_release_devbuf(devbuf);
 			if (dev_read_callback_fn)
 				dev_read_callback_fn(1, AIO_SUPPORTED_CODE_PATH, dev_read_callback_context, NULL);
-			r = 0;
+			else
+				r = 0;
 		}
 	}
 
@@ -1080,24 +1081,28 @@ static void _dev_inc_error_count(struct device *dev)
 }
 
 /*
- * Data is returned (read-only) at DEV_DEVBUF_DATA(dev, reason)
+ * Data is returned (read-only) at DEV_DEVBUF_DATA(dev, reason).
+ * If dev_read_callback_fn is supplied, we always return 1 and take
+ * responsibility for calling it exactly once.  This might happen before the
+ * function returns (if there's an error or the I/O is synchronous) or after.
+ * Any error is passed to that function, which must track it if required.
  */
-int dev_read_callback(struct device *dev, uint64_t offset, size_t len, dev_io_reason_t reason,
-		      unsigned ioflags, lvm_callback_fn_t dev_read_callback_fn, void *callback_context)
+static int _dev_read_callback(struct device *dev, uint64_t offset, size_t len, dev_io_reason_t reason,
+			      unsigned ioflags, lvm_callback_fn_t dev_read_callback_fn, void *callback_context)
 {
 	struct device_area where;
 	struct device_buffer *devbuf;
 	uint64_t buf_end;
 	int cached = 0;
-	int ret = 1;
+	int ret = 0;
 
 	if (!dev->open_count) {
 		log_error(INTERNAL_ERROR "Attempt to access device %s while closed.", dev_name(dev));
-		return 0;
+		goto out;
 	}
 
 	if (!_dev_is_valid(dev))
-		return 0;
+		goto_out;
 
 	/*
 	 * Can we satisfy this from data we stored last time we read?
@@ -1110,6 +1115,7 @@ int dev_read_callback(struct device *dev, uint64_t offset, size_t len, dev_io_re
 			devbuf->data_offset = offset - devbuf->where.start;
 			log_debug_io("Cached read for %" PRIu64 " bytes at %" PRIu64 " on %s (for %s)",
 				     (uint64_t) len, (uint64_t) offset, dev_name(dev), _reason_text(reason));
+			ret = 1;
 			goto out;
 		}
 	}
@@ -1126,16 +1132,26 @@ int dev_read_callback(struct device *dev, uint64_t offset, size_t len, dev_io_re
 
 out:
 	/* If we had an error or this was sync I/O, pass the result to any callback fn */
-	if ((!ret || !_aio_ctx || !aio_supported_code_path(ioflags) || cached) && dev_read_callback_fn)
+	if ((!ret || !_aio_ctx || !aio_supported_code_path(ioflags) || cached) && dev_read_callback_fn) {
 		dev_read_callback_fn(!ret, ioflags, callback_context, DEV_DEVBUF_DATA(dev, reason));
+		return 1;
+	}
 
 	return ret;
 }
 
+void dev_read_callback(struct device *dev, uint64_t offset, size_t len, dev_io_reason_t reason,
+		      unsigned ioflags, lvm_callback_fn_t dev_read_callback_fn, void *callback_context)
+{
+	/* Always returns 1 if callback fn is supplied */
+	if (!_dev_read_callback(dev, offset, len, reason, ioflags, dev_read_callback_fn, callback_context))
+		log_error(INTERNAL_ERROR "_dev_read_callback failed");
+}
+
 /* Returns pointer to read-only buffer. Caller does not free it.  */
 const char *dev_read(struct device *dev, uint64_t offset, size_t len, dev_io_reason_t reason)
 {
-	if (!dev_read_callback(dev, offset, len, reason, 0, NULL, NULL))
+	if (!_dev_read_callback(dev, offset, len, reason, 0, NULL, NULL))
 		return_NULL;
 
 	return DEV_DEVBUF_DATA(dev, reason);
@@ -1144,7 +1160,7 @@ const char *dev_read(struct device *dev, uint64_t offset, size_t len, dev_io_rea
 /* Read into supplied retbuf owned by the caller. */
 int dev_read_buf(struct device *dev, uint64_t offset, size_t len, dev_io_reason_t reason, void *retbuf)
 {
-	if (!dev_read_callback(dev, offset, len, reason, 0, NULL, NULL)) {
+	if (!_dev_read_callback(dev, offset, len, reason, 0, NULL, NULL)) {
 		log_error("Read from %s failed", dev_name(dev));
 		return 0;
 	}
diff --git a/lib/device/device.h b/lib/device/device.h
index 9061139..ea71d00 100644
--- a/lib/device/device.h
+++ b/lib/device/device.h
@@ -184,9 +184,9 @@ const char *dev_read(struct device *dev, uint64_t offset, size_t len, dev_io_rea
 const char *dev_read_circular(struct device *dev, uint64_t offset, size_t len,
 			      uint64_t offset2, size_t len2, dev_io_reason_t reason);
 
-/* Passes the data to dev_read_callback_fn */
-int dev_read_callback(struct device *dev, uint64_t offset, size_t len, dev_io_reason_t reason,
-		      unsigned ioflags, lvm_callback_fn_t dev_read_callback_fn, void *callback_context);
+/* Passes the data (or error) to dev_read_callback_fn */
+void dev_read_callback(struct device *dev, uint64_t offset, size_t len, dev_io_reason_t reason,
+		       unsigned ioflags, lvm_callback_fn_t dev_read_callback_fn, void *callback_context);
 
 /* Read data and copy it into a supplied private buffer. */
 /* Only use for tiny reads or on unimportant code paths. */
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 7f63ad6..e1603e7 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -385,8 +385,8 @@ static void _process_raw_mda_header(int failed, unsigned ioflags, void *context,
 bad:
 	prmp->ret = 0;
 out:
-	if (prmp->ret && prmp->mdah_callback_fn)
-		prmp->mdah_callback_fn(0, ioflags, prmp->mdah_callback_context, mdah);
+	if (prmp->mdah_callback_fn)
+		prmp->mdah_callback_fn(!prmp->ret, ioflags, prmp->mdah_callback_context, mdah);
 }
 
 static struct mda_header *_raw_read_mda_header(struct dm_pool *mem, struct device_area *dev_area, int primary_mda,
@@ -417,14 +417,15 @@ static struct mda_header *_raw_read_mda_header(struct dm_pool *mem, struct devic
 	prmp->mdah_callback_context = mdah_callback_context;
 	prmp->ret = 1;
 
-	if (!dev_read_callback(dev_area->dev, dev_area->start, MDA_HEADER_SIZE, MDA_HEADER_REASON(primary_mda),
-			       ioflags, _process_raw_mda_header, prmp))
-		stack;
+	dev_read_callback(dev_area->dev, dev_area->start, MDA_HEADER_SIZE, MDA_HEADER_REASON(primary_mda),
+			  ioflags, _process_raw_mda_header, prmp);
+	if (mdah_callback_fn)
+		return mdah;
 
 	if (!prmp->ret)
 		return_NULL;
-
-	return mdah;
+	else
+		return mdah;
 }
 
 struct mda_header *raw_read_mda_header(struct dm_pool *mem, struct device_area *dev_area, int primary_mda)
@@ -1404,8 +1405,7 @@ static void _vgname_from_mda_process(int failed, unsigned ioflags, void *context
 	}
 
 out:
-	if (vfmp->ret)
-		vfmp->update_vgsummary_fn(0, ioflags, vfmp->update_vgsummary_context, vfmp->vgsummary);
+	vfmp->update_vgsummary_fn(!vfmp->ret, ioflags, vfmp->update_vgsummary_context, vfmp->vgsummary);
 }
 
 static void _vgname_from_mda_validate(int failed, unsigned ioflags, void *context, const void *data)
@@ -1469,7 +1469,8 @@ static void _vgname_from_mda_validate(int failed, unsigned ioflags, void *contex
 	}
 
 out:
-	;
+	if (!vfmp->ret && vfmp->update_vgsummary_fn)
+		vfmp->update_vgsummary_fn(1, ioflags, vfmp->update_vgsummary_context, vfmp->vgsummary);
 }
 
 int vgname_from_mda(const struct format_type *fmt,
@@ -1517,11 +1518,12 @@ int vgname_from_mda(const struct format_type *fmt,
 
 	/* Do quick check for a vgname */
 	/* We cannot read the full metadata here because the name has to be validated before we use the size field */
-	if (!dev_read_callback(dev_area->dev, dev_area->start + rlocn->offset, NAME_LEN, MDA_CONTENT_REASON(primary_mda),
-			       ioflags, _vgname_from_mda_validate, vfmp))
-		return_0;
-
-	return vfmp->ret;
+	dev_read_callback(dev_area->dev, dev_area->start + rlocn->offset, NAME_LEN, MDA_CONTENT_REASON(primary_mda),
+			       ioflags, _vgname_from_mda_validate, vfmp);
+	if (update_vgsummary_fn)
+		return 1;
+	else
+		return vfmp->ret;
 }
 
 static int _scan_raw(const struct format_type *fmt, const char *vgname __attribute__((unused)))
diff --git a/lib/format_text/import.c b/lib/format_text/import.c
index 69af925..0138ddd 100644
--- a/lib/format_text/import.c
+++ b/lib/format_text/import.c
@@ -78,8 +78,8 @@ static void _import_vgsummary(int failed, unsigned ioflags, void *context, const
 out:
 	config_destroy(ivsp->cft);
 
-	if (ivsp->ret && ivsp->process_vgsummary_fn)
-		ivsp->process_vgsummary_fn(0, ioflags, ivsp->process_vgsummary_context, NULL);
+	if (ivsp->process_vgsummary_fn)
+		ivsp->process_vgsummary_fn(!ivsp->ret, ioflags, ivsp->process_vgsummary_context, NULL);
 }
 
 /*
diff --git a/lib/format_text/text_label.c b/lib/format_text/text_label.c
index d3d92f0..45136e9 100644
--- a/lib/format_text/text_label.c
+++ b/lib/format_text/text_label.c
@@ -344,6 +344,7 @@ static void _process_vgsummary(int failed, unsigned ioflags, void *context, cons
 
 	--pmp->umb->nr_outstanding_mdas;
 
+	/* FIXME Need to distinguish genuine errors here */
 	if (failed)
 		goto_out;
 
@@ -446,7 +447,10 @@ static int _update_mda(struct metadata_area *mda, void *baton)
 		return 1;
 	}
 
-	return pmp->ret;
+	if (umb->read_label_callback_fn)
+		return 1;
+	else
+		return pmp->ret;
 }
 
 static int _text_read(struct labeller *l, struct device *dev, void *buf, unsigned ioflags,
diff --git a/lib/label/label.c b/lib/label/label.c
index 0997b96..ae3a2c1 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -155,8 +155,10 @@ out:
 	if (!dev_close(flp->dev))
 		stack;
 
-	if (flp->process_label_data_fn)
+	if (flp->process_label_data_fn) {
+		log_debug_io("Completed label reading for %s", dev_name(flp->dev));
 		flp->process_label_data_fn(!flp->ret, ioflags, flp->process_label_data_context, NULL);
+	}
 }
 
 static void _find_labeller(int failed, unsigned ioflags, void *context, const void *data)
@@ -324,8 +326,10 @@ static int _label_read(struct device *dev, uint64_t scan_sector, struct label **
 		log_debug_devs("Reading label from lvmcache for %s", dev_name(dev));
 		if (result)
 			*result = lvmcache_get_label(info);
-		if (process_label_data_fn)
+		if (process_label_data_fn) {
+			log_debug_io("Completed label reading for %s", dev_name(dev));
 			process_label_data_fn(0, ioflags, process_label_data_context, NULL);
+		}
 		return 1;
 	}
 
@@ -356,12 +360,7 @@ static int _label_read(struct device *dev, uint64_t scan_sector, struct label **
 		return 0;
 	}
 
-	if (!(dev_read_callback(dev, scan_sector << SECTOR_SHIFT, LABEL_SCAN_SIZE, DEV_IO_LABEL, ioflags, _find_labeller, flp))) {
-		log_debug_devs("%s: Failed to read label area", dev_name(dev));
-		_set_label_read_result(1, ioflags, flp, NULL);
-		return 0;
-	}
-
+	dev_read_callback(dev, scan_sector << SECTOR_SHIFT, LABEL_SCAN_SIZE, DEV_IO_LABEL, ioflags, _find_labeller, flp);
 	if (process_label_data_fn)
 		return 1;
 	else


