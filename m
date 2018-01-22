From: Alasdair Kergon <agk@sourceware.org>
Date: Mon, 22 Jan 2018 09:55:14 -0500
Subject: master - device: Add ioflags parameter to transfer additional state.
Message-ID: <201801221455.w0MEtEJr002785@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9194610f42901c88a3393b679afabbdca7145268
Commit:        9194610f42901c88a3393b679afabbdca7145268
Parent:        f3c75bb2014e9ae7d212e0c016a94c529ac8a912
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Sun Jan 21 15:41:49 2018 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Sun Jan 21 21:10:23 2018 +0000

device: Add ioflags parameter to transfer additional state.

Flags are set on the initial I/O and passed to any callbacks that
may in turn issue further I/O using the inherited flags.
---
 lib/cache/lvmcache.c            |    4 +-
 lib/cache/lvmetad.c             |    2 +-
 lib/config/config.c             |   16 ++++++------
 lib/config/config.h             |    2 +-
 lib/device/dev-io.c             |   21 ++++++++-------
 lib/device/device.h             |    4 +-
 lib/format1/lvm1-label.c        |    4 +-
 lib/format_pool/format_pool.c   |    2 +-
 lib/format_pool/pool_label.c    |    4 +-
 lib/format_text/archiver.c      |    2 +-
 lib/format_text/format-text.c   |   50 ++++++++++++++++++++------------------
 lib/format_text/import-export.h |    4 +-
 lib/format_text/import.c        |   20 +++++++-------
 lib/format_text/layout.h        |    4 +-
 lib/format_text/text_label.c    |   25 +++++++++++--------
 lib/label/label.c               |   28 +++++++++++-----------
 lib/label/label.h               |    4 +-
 lib/metadata/metadata.c         |    8 +++---
 lib/metadata/metadata.h         |    4 +-
 19 files changed, 107 insertions(+), 101 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index bc74562..65728fd 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -1099,7 +1099,7 @@ next:
 }
 
 /* Track the number of outstanding label reads */
-static void _process_label_data(int failed, void *context, const void *data)
+static void _process_label_data(int failed, unsigned ioflags, void *context, const void *data)
 {
 	int *nr_labels_outstanding = context;
 
@@ -1156,7 +1156,7 @@ int lvmcache_label_scan(struct cmd_context *cmd)
 
 	while ((dev = dev_iter_get(iter))) {
 		nr_labels_outstanding++;
-		if (!label_read_callback(dev, UINT64_C(0), _process_label_data, &nr_labels_outstanding))
+		if (!label_read_callback(dev, UINT64_C(0), 0, _process_label_data, &nr_labels_outstanding))
 			nr_labels_outstanding--;
 		dev_count++;
 	}
diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index e1f829c..b266152 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -1771,7 +1771,7 @@ static int _lvmetad_pvscan_single(struct metadata_area *mda, void *baton)
 	struct volume_group *vg;
 
 	if (mda_is_ignored(mda) ||
-	    !(vg = mda->ops->vg_read(b->fid, "", mda, NULL, NULL, 1)))
+	    !(vg = mda->ops->vg_read(b->fid, "", mda, NULL, NULL, 1, 0)))
 		return 1;
 
 	/* FIXME Also ensure contents match etc. */
diff --git a/lib/config/config.c b/lib/config/config.c
index 44d646e..c69ac69 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -505,7 +505,7 @@ struct process_config_file_params {
 	int ret;
 };
 
-static void _process_config_file_buffer(int failed, void *context, const void *data)
+static void _process_config_file_buffer(int failed, unsigned ioflags, void *context, const void *data)
 {
 	struct process_config_file_params *pcfp = context;
 	const char *fb = data, *fe;
@@ -534,7 +534,7 @@ static void _process_config_file_buffer(int failed, void *context, const void *d
 
 out:
 	if (pcfp->config_file_read_fd_callback)
-		pcfp->config_file_read_fd_callback(!pcfp->ret, pcfp->config_file_read_fd_context, NULL);
+		pcfp->config_file_read_fd_callback(!pcfp->ret, ioflags, pcfp->config_file_read_fd_context, NULL);
 }
 
 /*
@@ -545,7 +545,7 @@ out:
 int config_file_read_fd(struct dm_pool *mem, struct dm_config_tree *cft, struct device *dev, dev_io_reason_t reason,
 			off_t offset, size_t size, off_t offset2, size_t size2,
 			checksum_fn_t checksum_fn, uint32_t checksum,
-			int checksum_only, int no_dup_node_check,
+			int checksum_only, int no_dup_node_check, unsigned ioflags,
 			lvm_callback_fn_t config_file_read_fd_callback, void *config_file_read_fd_context)
 {
 	char *fb;
@@ -596,7 +596,7 @@ int config_file_read_fd(struct dm_pool *mem, struct dm_config_tree *cft, struct
 			log_sys_error("mmap", dev_name(dev));
 			goto bad;
 		}
-		_process_config_file_buffer(0, pcfp, fb + mmap_offset);
+		_process_config_file_buffer(0, ioflags, pcfp, fb + mmap_offset);
 		r = pcfp->ret;
 		/* unmap the file */
 		if (munmap(fb, size + mmap_offset)) {
@@ -607,9 +607,9 @@ int config_file_read_fd(struct dm_pool *mem, struct dm_config_tree *cft, struct
 		if (circular) {
 			if (!(buf = dev_read_circular(dev, (uint64_t) offset, size, (uint64_t) offset2, size2, reason)))
 				goto_out;
-			_process_config_file_buffer(0, pcfp, buf);
+			_process_config_file_buffer(0, ioflags, pcfp, buf);
 			dm_free((void *)buf);
-		} else if (!dev_read_callback(dev, (uint64_t) offset, size, reason, _process_config_file_buffer, pcfp))
+		} else if (!dev_read_callback(dev, (uint64_t) offset, size, reason, ioflags, _process_config_file_buffer, pcfp))
 			goto_out;
 		r = pcfp->ret;
 	}
@@ -619,7 +619,7 @@ out:
 
 bad:
 	if (config_file_read_fd_callback)
-		config_file_read_fd_callback(1, config_file_read_fd_context, NULL);
+		config_file_read_fd_callback(1, ioflags, config_file_read_fd_context, NULL);
 
 	return 0;
 }
@@ -653,7 +653,7 @@ int config_file_read(struct dm_pool *mem, struct dm_config_tree *cft)
 	}
 
 	r = config_file_read_fd(mem, cft, cf->dev, DEV_IO_MDA_CONTENT, 0, (size_t) info.st_size, 0, 0,
-				(checksum_fn_t) NULL, 0, 0, 0, NULL, NULL);
+				(checksum_fn_t) NULL, 0, 0, 0, 0, NULL, NULL);
 
 	if (!cf->keep_open) {
 		if (!dev_close(cf->dev))
diff --git a/lib/config/config.h b/lib/config/config.h
index 9901003..4517cb7 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -242,7 +242,7 @@ struct dm_config_tree *config_open(config_source_t source, const char *filename,
 int config_file_read_fd(struct dm_pool *mem, struct dm_config_tree *cft, struct device *dev, dev_io_reason_t reason,
 			off_t offset, size_t size, off_t offset2, size_t size2,
 			checksum_fn_t checksum_fn, uint32_t checksum,
-			int skip_parse, int no_dup_node_check,
+			int skip_parse, int no_dup_node_check, unsigned ioflags,
 			lvm_callback_fn_t config_file_read_fd_callback, void *config_file_read_fd_context);
 
 int config_file_read(struct dm_pool *mem, struct dm_config_tree *cft);
diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index 2150b0d..0137d5d 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -142,7 +142,7 @@ static int _io_sync(struct device_buffer *devbuf)
 	return (total == (size_t) where->size);
 }
 
-static int _io(struct device_buffer *devbuf)
+static int _io(struct device_buffer *devbuf, unsigned ioflags)
 {
 	struct device_area *where = &devbuf->where;
 	int fd = dev_fd(where->dev);
@@ -269,7 +269,8 @@ static void _widen_region(unsigned int block_size, struct device_area *region,
 }
 
 static int _aligned_io(struct device_area *where, char *write_buffer,
-		       int should_write, dev_io_reason_t reason)
+		       int should_write, dev_io_reason_t reason,
+		       unsigned ioflags)
 {
 	unsigned int physical_block_size = 0;
 	unsigned int block_size = 0;
@@ -338,7 +339,7 @@ static int _aligned_io(struct device_area *where, char *write_buffer,
 	devbuf->write = 0;
 
 	/* Do we need to read into the bounce buffer? */
-	if ((!should_write || buffer_was_widened) && !_io(devbuf)) {
+	if ((!should_write || buffer_was_widened) && !_io(devbuf, ioflags)) {
 		if (!should_write)
 			goto_bad;
 		/* FIXME Handle errors properly! */
@@ -359,7 +360,7 @@ static int _aligned_io(struct device_area *where, char *write_buffer,
 
 	/* ... then we write */
 	devbuf->write = 1;
-	if (!(r = _io(devbuf)))
+	if (!(r = _io(devbuf, 0)))
 		goto_bad;
 
 	_release_devbuf(devbuf);
@@ -797,7 +798,7 @@ static void _dev_inc_error_count(struct device *dev)
  * Data is returned (read-only) at DEV_DEVBUF_DATA(dev, reason)
  */
 int dev_read_callback(struct device *dev, uint64_t offset, size_t len, dev_io_reason_t reason,
-		      lvm_callback_fn_t dev_read_callback_fn, void *callback_context)
+		      unsigned ioflags, lvm_callback_fn_t dev_read_callback_fn, void *callback_context)
 {
 	struct device_area where;
 	struct device_buffer *devbuf;
@@ -836,7 +837,7 @@ int dev_read_callback(struct device *dev, uint64_t offset, size_t len, dev_io_re
 	where.start = offset;
 	where.size = len;
 
-	ret = _aligned_io(&where, NULL, 0, reason);
+	ret = _aligned_io(&where, NULL, 0, reason, ioflags);
 	if (!ret) {
 		log_error("Read from %s failed.", dev_name(dev));
 		_dev_inc_error_count(dev);
@@ -844,7 +845,7 @@ int dev_read_callback(struct device *dev, uint64_t offset, size_t len, dev_io_re
 
 out:
 	if (dev_read_callback_fn)
-		dev_read_callback_fn(!ret, callback_context, DEV_DEVBUF_DATA(dev, reason));
+		dev_read_callback_fn(!ret, ioflags, callback_context, DEV_DEVBUF_DATA(dev, reason));
 
 	return ret;
 }
@@ -852,7 +853,7 @@ out:
 /* Returns pointer to read-only buffer. Caller does not free it.  */
 const char *dev_read(struct device *dev, uint64_t offset, size_t len, dev_io_reason_t reason)
 {
-	if (!dev_read_callback(dev, offset, len, reason, NULL, NULL))
+	if (!dev_read_callback(dev, offset, len, reason, 0, NULL, NULL))
 		return_NULL;
 
 	return DEV_DEVBUF_DATA(dev, reason);
@@ -861,7 +862,7 @@ const char *dev_read(struct device *dev, uint64_t offset, size_t len, dev_io_rea
 /* Read into supplied retbuf owned by the caller. */
 int dev_read_buf(struct device *dev, uint64_t offset, size_t len, dev_io_reason_t reason, void *retbuf)
 {
-	if (!dev_read_callback(dev, offset, len, reason, NULL, NULL))
+	if (!dev_read_callback(dev, offset, len, reason, 0, NULL, NULL))
 		return_0;
 	
 	memcpy(retbuf, DEV_DEVBUF_DATA(dev, reason), len);
@@ -941,7 +942,7 @@ int dev_write(struct device *dev, uint64_t offset, size_t len, dev_io_reason_t r
 
 	dev->flags |= DEV_ACCESSED_W;
 
-	ret = _aligned_io(&where, buffer, 1, reason);
+	ret = _aligned_io(&where, buffer, 1, reason, 0);
 	if (!ret)
 		_dev_inc_error_count(dev);
 
diff --git a/lib/device/device.h b/lib/device/device.h
index d70d3aa..d5b076f 100644
--- a/lib/device/device.h
+++ b/lib/device/device.h
@@ -37,7 +37,7 @@
  * When provided, callback functions are called exactly once.
  * If failed is set, data cannot be accessed.
  */
-typedef void (*lvm_callback_fn_t)(int failed, void *context, const void *data);
+typedef void (*lvm_callback_fn_t)(int failed, unsigned ioflags, void *context, const void *data);
 
 /*
  * Support for external device info.
@@ -177,7 +177,7 @@ const char *dev_read_circular(struct device *dev, uint64_t offset, size_t len,
 
 /* Passes the data to dev_read_callback_fn */
 int dev_read_callback(struct device *dev, uint64_t offset, size_t len, dev_io_reason_t reason,
-		      lvm_callback_fn_t dev_read_callback_fn, void *callback_context);
+		      unsigned ioflags, lvm_callback_fn_t dev_read_callback_fn, void *callback_context);
 
 /* Read data and copy it into a supplied private buffer. */
 /* Only use for tiny reads or on unimportant code paths. */
diff --git a/lib/format1/lvm1-label.c b/lib/format1/lvm1-label.c
index 77dab1e..5419d92 100644
--- a/lib/format1/lvm1-label.c
+++ b/lib/format1/lvm1-label.c
@@ -54,7 +54,7 @@ static int _lvm1_write(struct label *label __attribute__((unused)), void *buf __
 	return 0;
 }
 
-static int _lvm1_read(struct labeller *l, struct device *dev, void *buf,
+static int _lvm1_read(struct labeller *l, struct device *dev, void *buf, unsigned ioflags,
 		      lvm_callback_fn_t read_label_callback_fn, void *read_label_callback_context)
 {
 	struct pv_disk *pvd = (struct pv_disk *) buf;
@@ -93,7 +93,7 @@ static int _lvm1_read(struct labeller *l, struct device *dev, void *buf,
 
 out:
 	if (read_label_callback_fn)
-		read_label_callback_fn(!r, read_label_callback_context, label);
+		read_label_callback_fn(!r, 0, read_label_callback_context, label);
 
 	return r;
 }
diff --git a/lib/format_pool/format_pool.c b/lib/format_pool/format_pool.c
index f6e5e01..1f257a2 100644
--- a/lib/format_pool/format_pool.c
+++ b/lib/format_pool/format_pool.c
@@ -103,7 +103,7 @@ static struct volume_group *_pool_vg_read(struct format_instance *fid,
 					  struct metadata_area *mda __attribute__((unused)),
 					  struct cached_vg_fmtdata **vg_fmtdata __attribute__((unused)),
 					  unsigned *use_previous_vg __attribute__((unused)),
-					  int single_device __attribute__((unused)))
+					  int single_device __attribute__((unused)), int ioflags)
 {
 	struct volume_group *vg;
 	struct user_subpool *usp;
diff --git a/lib/format_pool/pool_label.c b/lib/format_pool/pool_label.c
index 320cef2..888a2eb 100644
--- a/lib/format_pool/pool_label.c
+++ b/lib/format_pool/pool_label.c
@@ -55,7 +55,7 @@ static int _pool_write(struct label *label __attribute__((unused)), void *buf __
 	return 0;
 }
 
-static int _pool_read(struct labeller *l, struct device *dev, void *buf,
+static int _pool_read(struct labeller *l, struct device *dev, void *buf, unsigned ioflags,
 		      lvm_callback_fn_t read_label_callback_fn, void *read_label_callback_context)
 {
 	struct pool_list pl;
@@ -65,7 +65,7 @@ static int _pool_read(struct labeller *l, struct device *dev, void *buf,
 	r = read_pool_label(&pl, l, dev, buf, &label);
 
 	if (read_label_callback_fn)
-		read_label_callback_fn(!r, read_label_callback_context, label);
+		read_label_callback_fn(!r, 0, read_label_callback_context, label);
 
 	return r;
 }
diff --git a/lib/format_text/archiver.c b/lib/format_text/archiver.c
index 1eb6654..2c8e751 100644
--- a/lib/format_text/archiver.c
+++ b/lib/format_text/archiver.c
@@ -320,7 +320,7 @@ struct volume_group *backup_read_vg(struct cmd_context *cmd,
 	}
 
 	dm_list_iterate_items(mda, &tf->metadata_areas_in_use) {
-		if (!(vg = mda->ops->vg_read(tf, vg_name, mda, NULL, NULL, 0)))
+		if (!(vg = mda->ops->vg_read(tf, vg_name, mda, NULL, NULL, 0, 0)))
 			stack;
 		break;
 	}
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 866f65f..7f63ad6 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -334,7 +334,7 @@ struct process_raw_mda_header_params {
 	int ret;
 };
 
-static void _process_raw_mda_header(int failed, void *context, const void *data)
+static void _process_raw_mda_header(int failed, unsigned ioflags, void *context, const void *data)
 {
 	struct process_raw_mda_header_params *prmp = context;
 	struct mda_header *mdah = prmp->mdah;
@@ -386,11 +386,11 @@ bad:
 	prmp->ret = 0;
 out:
 	if (prmp->ret && prmp->mdah_callback_fn)
-		prmp->mdah_callback_fn(0, prmp->mdah_callback_context, mdah);
+		prmp->mdah_callback_fn(0, ioflags, prmp->mdah_callback_context, mdah);
 }
 
 static struct mda_header *_raw_read_mda_header(struct dm_pool *mem, struct device_area *dev_area, int primary_mda,
-					       lvm_callback_fn_t mdah_callback_fn, void *mdah_callback_context)
+					       unsigned ioflags, lvm_callback_fn_t mdah_callback_fn, void *mdah_callback_context)
 {
 	struct mda_header *mdah;
 	struct process_raw_mda_header_params *prmp;
@@ -418,7 +418,7 @@ static struct mda_header *_raw_read_mda_header(struct dm_pool *mem, struct devic
 	prmp->ret = 1;
 
 	if (!dev_read_callback(dev_area->dev, dev_area->start, MDA_HEADER_SIZE, MDA_HEADER_REASON(primary_mda),
-			       _process_raw_mda_header, prmp))
+			       ioflags, _process_raw_mda_header, prmp))
 		stack;
 
 	if (!prmp->ret)
@@ -429,13 +429,13 @@ static struct mda_header *_raw_read_mda_header(struct dm_pool *mem, struct devic
 
 struct mda_header *raw_read_mda_header(struct dm_pool *mem, struct device_area *dev_area, int primary_mda)
 {
-	return _raw_read_mda_header(mem, dev_area, primary_mda, NULL, NULL);
+	return _raw_read_mda_header(mem, dev_area, primary_mda, 0, NULL, NULL);
 }
 
 int raw_read_mda_header_callback(struct dm_pool *mem, struct device_area *dev_area, int primary_mda,
-				 lvm_callback_fn_t mdah_callback_fn, void *mdah_callback_context)
+				 unsigned ioflags, lvm_callback_fn_t mdah_callback_fn, void *mdah_callback_context)
 {
-	if (!_raw_read_mda_header(mem, dev_area, primary_mda, mdah_callback_fn, mdah_callback_context))
+	if (!_raw_read_mda_header(mem, dev_area, primary_mda, ioflags, mdah_callback_fn, mdah_callback_context))
 		return_0;
 
 	return 1;
@@ -599,7 +599,7 @@ static struct volume_group *_vg_read_raw_area(struct format_instance *fid,
 					      struct device_area *area,
 					      struct cached_vg_fmtdata **vg_fmtdata,
 					      unsigned *use_previous_vg,
-					      int precommitted,
+					      int precommitted, unsigned ioflags,
 					      int single_device, int primary_mda)
 {
 	struct volume_group *vg = NULL;
@@ -632,7 +632,7 @@ static struct volume_group *_vg_read_raw_area(struct format_instance *fid,
 				     (off_t) (area->start + rlocn->offset),
 				     (uint32_t) (rlocn->size - wrap),
 				     (off_t) (area->start + MDA_HEADER_SIZE),
-				     wrap, calc_crc, rlocn->checksum, &when,
+				     wrap, calc_crc, rlocn->checksum, ioflags, &when,
 				     &desc)) && (!use_previous_vg || !*use_previous_vg))
 		goto_out;
 
@@ -659,7 +659,7 @@ static struct volume_group *_vg_read_raw(struct format_instance *fid,
 					 struct metadata_area *mda,
 					 struct cached_vg_fmtdata **vg_fmtdata,
 					 unsigned *use_previous_vg,
-					 int single_device)
+					 int single_device, unsigned ioflags)
 {
 	struct mda_context *mdac = (struct mda_context *) mda->metadata_locn;
 	struct volume_group *vg;
@@ -667,7 +667,7 @@ static struct volume_group *_vg_read_raw(struct format_instance *fid,
 	if (!dev_open_readonly(mdac->area.dev))
 		return_NULL;
 
-	vg = _vg_read_raw_area(fid, vgname, &mdac->area, vg_fmtdata, use_previous_vg, 0, single_device, mda_is_primary(mda));
+	vg = _vg_read_raw_area(fid, vgname, &mdac->area, vg_fmtdata, use_previous_vg, 0, ioflags, single_device, mda_is_primary(mda));
 
 	if (!dev_close(mdac->area.dev))
 		stack;
@@ -679,7 +679,7 @@ static struct volume_group *_vg_read_precommit_raw(struct format_instance *fid,
 						   const char *vgname,
 						   struct metadata_area *mda,
 						   struct cached_vg_fmtdata **vg_fmtdata,
-						   unsigned *use_previous_vg)
+						   unsigned *use_previous_vg, unsigned ioflags)
 {
 	struct mda_context *mdac = (struct mda_context *) mda->metadata_locn;
 	struct volume_group *vg;
@@ -687,7 +687,7 @@ static struct volume_group *_vg_read_precommit_raw(struct format_instance *fid,
 	if (!dev_open_readonly(mdac->area.dev))
 		return_NULL;
 
-	vg = _vg_read_raw_area(fid, vgname, &mdac->area, vg_fmtdata, use_previous_vg, 1, 0, mda_is_primary(mda));
+	vg = _vg_read_raw_area(fid, vgname, &mdac->area, vg_fmtdata, use_previous_vg, 1, ioflags, 0, mda_is_primary(mda));
 
 	if (!dev_close(mdac->area.dev))
 		stack;
@@ -1101,7 +1101,8 @@ static struct volume_group *_vg_read_file(struct format_instance *fid,
 					  struct metadata_area *mda,
 					  struct cached_vg_fmtdata **vg_fmtdata,
 					  unsigned *use_previous_vg __attribute__((unused)),
-					  int single_device __attribute__((unused)))
+					  int single_device __attribute__((unused)),
+					  unsigned ioflags __attribute__((unused)))
 {
 	struct text_context *tc = (struct text_context *) mda->metadata_locn;
 
@@ -1112,7 +1113,8 @@ static struct volume_group *_vg_read_precommit_file(struct format_instance *fid,
 						    const char *vgname,
 						    struct metadata_area *mda,
 						    struct cached_vg_fmtdata **vg_fmtdata,
-						    unsigned *use_previous_vg __attribute__((unused)))
+						    unsigned *use_previous_vg __attribute__((unused)),
+						    unsigned ioflags __attribute__((unused)))
 {
 	struct text_context *tc = (struct text_context *) mda->metadata_locn;
 	struct volume_group *vg;
@@ -1360,7 +1362,7 @@ struct vgname_from_mda_params{
 	int ret;
 };
 
-static void _vgname_from_mda_process(int failed, void *context, const void *data)
+static void _vgname_from_mda_process(int failed, unsigned ioflags, void *context, const void *data)
 {
 	struct vgname_from_mda_params *vfmp = context;
 	const struct mda_header *mdah = vfmp->mdah;
@@ -1403,10 +1405,10 @@ static void _vgname_from_mda_process(int failed, void *context, const void *data
 
 out:
 	if (vfmp->ret)
-		vfmp->update_vgsummary_fn(0, vfmp->update_vgsummary_context, vfmp->vgsummary);
+		vfmp->update_vgsummary_fn(0, ioflags, vfmp->update_vgsummary_context, vfmp->vgsummary);
 }
 
-static void _vgname_from_mda_validate(int failed, void *context, const void *data)
+static void _vgname_from_mda_validate(int failed, unsigned ioflags, void *context, const void *data)
 {
 	struct vgname_from_mda_params *vfmp = context;
 	const char *buffer = data;
@@ -1460,7 +1462,7 @@ static void _vgname_from_mda_validate(int failed, void *context, const void *dat
 				(off_t) (dev_area->start + rlocn->offset),
 				(uint32_t) (rlocn->size - vfmp->wrap),
 				(off_t) (dev_area->start + MDA_HEADER_SIZE),
-				vfmp->wrap, calc_crc, vgsummary->vgname ? 1 : 0,
+				vfmp->wrap, calc_crc, vgsummary->vgname ? 1 : 0, ioflags,
 				vgsummary, _vgname_from_mda_process, vfmp)) {
 		vfmp->ret = 0;
 		goto_out;
@@ -1472,7 +1474,7 @@ out:
 
 int vgname_from_mda(const struct format_type *fmt,
 		    const struct mda_header *mdah, int primary_mda, struct device_area *dev_area,
-		    struct lvmcache_vgsummary *vgsummary, uint64_t *mda_free_sectors,
+		    struct lvmcache_vgsummary *vgsummary, uint64_t *mda_free_sectors, unsigned ioflags,
 		    lvm_callback_fn_t update_vgsummary_fn, void *update_vgsummary_context)
 {
 	const struct raw_locn *rlocn;
@@ -1516,7 +1518,7 @@ int vgname_from_mda(const struct format_type *fmt,
 	/* Do quick check for a vgname */
 	/* We cannot read the full metadata here because the name has to be validated before we use the size field */
 	if (!dev_read_callback(dev_area->dev, dev_area->start + rlocn->offset, NAME_LEN, MDA_CONTENT_REASON(primary_mda),
-			       _vgname_from_mda_validate, vfmp))
+			       ioflags, _vgname_from_mda_validate, vfmp))
 		return_0;
 
 	return vfmp->ret;
@@ -1550,8 +1552,8 @@ static int _scan_raw(const struct format_type *fmt, const char *vgname __attribu
 		}
 
 		/* TODO: caching as in vgname_from_mda() (trigger this code?) */
-		if (vgname_from_mda(fmt, mdah, 0, &rl->dev_area, &vgsummary, NULL, NULL, NULL)) {
-			vg = _vg_read_raw_area(&fid, vgsummary.vgname, &rl->dev_area, NULL, NULL, 0, 0, 0);
+		if (vgname_from_mda(fmt, mdah, 0, &rl->dev_area, &vgsummary, NULL, 0, NULL, NULL)) {
+			vg = _vg_read_raw_area(&fid, vgsummary.vgname, &rl->dev_area, NULL, NULL, 0, 0, 0, 0);
 			if (vg)
 				lvmcache_update_vg(vg, 0);
 		}
@@ -2023,7 +2025,7 @@ static int _mda_export_text_raw(struct metadata_area *mda,
 {
 	struct mda_context *mdc = (struct mda_context *) mda->metadata_locn;
 
-	if (!mdc || !_raw_read_mda_header(cft->mem, &mdc->area, mda_is_primary(mda), NULL, NULL))
+	if (!mdc || !_raw_read_mda_header(cft->mem, &mdc->area, mda_is_primary(mda), 0, NULL, NULL))
 		return 1; /* pretend the MDA does not exist */
 
 	return config_make_nodes(cft, parent, NULL,
diff --git a/lib/format_text/import-export.h b/lib/format_text/import-export.h
index da6d2ab..2c329d0 100644
--- a/lib/format_text/import-export.h
+++ b/lib/format_text/import-export.h
@@ -80,7 +80,7 @@ struct volume_group *text_vg_import_fd(struct format_instance *fid,
 				       off_t offset, uint32_t size,
 				       off_t offset2, uint32_t size2,
 				       checksum_fn_t checksum_fn,
-				       uint32_t checksum,
+				       uint32_t checksum, unsigned ioflags,
 				       time_t *when, char **desc);
 
 int text_vgsummary_import(const struct format_type *fmt,
@@ -88,7 +88,7 @@ int text_vgsummary_import(const struct format_type *fmt,
 		       off_t offset, uint32_t size,
 		       off_t offset2, uint32_t size2,
 		       checksum_fn_t checksum_fn,
-		       int checksum_only,
+		       int checksum_only, unsigned ioflags,
 		       struct lvmcache_vgsummary *vgsummary,
 		       lvm_callback_fn_t process_vgsummary_fn,
 		       void *process_vgsummary_context);
diff --git a/lib/format_text/import.c b/lib/format_text/import.c
index a6310c9..69af925 100644
--- a/lib/format_text/import.c
+++ b/lib/format_text/import.c
@@ -43,7 +43,7 @@ struct import_vgsummary_params {
 	int ret;
 };
 
-static void _import_vgsummary(int failed, void *context, const void *data)
+static void _import_vgsummary(int failed, unsigned ioflags, void *context, const void *data)
 {
 	struct import_vgsummary_params *ivsp = context;
 	struct text_vg_version_ops **vsn;
@@ -79,7 +79,7 @@ out:
 	config_destroy(ivsp->cft);
 
 	if (ivsp->ret && ivsp->process_vgsummary_fn)
-		ivsp->process_vgsummary_fn(0, ivsp->process_vgsummary_context, NULL);
+		ivsp->process_vgsummary_fn(0, ioflags, ivsp->process_vgsummary_context, NULL);
 }
 
 /*
@@ -90,7 +90,7 @@ int text_vgsummary_import(const struct format_type *fmt,
 		       off_t offset, uint32_t size,
 		       off_t offset2, uint32_t size2,
 		       checksum_fn_t checksum_fn,
-		       int checksum_only,
+		       int checksum_only, unsigned ioflags,
 		       struct lvmcache_vgsummary *vgsummary,
 		       lvm_callback_fn_t process_vgsummary_fn,
 		       void *process_vgsummary_context)
@@ -119,11 +119,11 @@ int text_vgsummary_import(const struct format_type *fmt,
 			log_error("Couldn't read volume group metadata.");
 			ivsp->ret = 0;
 		}
-		_import_vgsummary(!ivsp->ret, ivsp, NULL);
+		_import_vgsummary(!ivsp->ret, ioflags, ivsp, NULL);
 	} else if (!config_file_read_fd(fmt->cmd->mem, ivsp->cft, dev, reason, offset, size,
 					offset2, size2, checksum_fn,
 					vgsummary->mda_checksum,
-					checksum_only, 1, &_import_vgsummary, ivsp)) {
+					checksum_only, 1, ioflags, &_import_vgsummary, ivsp)) {
 		log_error("Couldn't read volume group metadata.");
 		return 0;
 	}
@@ -150,7 +150,7 @@ struct import_vg_params {
 	char **desc;
 };
 
-static void _import_vg(int failed, void *context, const void *data)
+static void _import_vg(int failed, unsigned ioflags, void *context, const void *data)
 {
 	struct import_vg_params *ivp = context;
 	struct text_vg_version_ops **vsn;
@@ -198,7 +198,7 @@ struct volume_group *text_vg_import_fd(struct format_instance *fid,
 				       off_t offset, uint32_t size,
 				       off_t offset2, uint32_t size2,
 				       checksum_fn_t checksum_fn,
-				       uint32_t checksum,
+				       uint32_t checksum, unsigned ioflags,
 				       time_t *when, char **desc)
 {
 	struct import_vg_params *ivp;
@@ -243,12 +243,12 @@ struct volume_group *text_vg_import_fd(struct format_instance *fid,
 	if (dev) {
 		if (!config_file_read_fd(fid->mem, ivp->cft, dev, MDA_CONTENT_REASON(primary_mda), offset, size,
 					offset2, size2, checksum_fn, checksum,
-					ivp->skip_parse, 1, &_import_vg, ivp)) {
+					ivp->skip_parse, 1, ioflags, &_import_vg, ivp)) {
 			config_destroy(ivp->cft);
 			return_NULL;
 		}
 	} else
-		_import_vg(0, ivp, NULL);
+		_import_vg(0, 0, ivp, NULL);
 
 	return ivp->vg;
 }
@@ -258,7 +258,7 @@ struct volume_group *text_vg_import_file(struct format_instance *fid,
 					 time_t *when, char **desc)
 {
 	return text_vg_import_fd(fid, file, NULL, NULL, 0, NULL, 0, (off_t)0, 0, (off_t)0, 0, NULL, 0,
-				 when, desc);
+				 0, when, desc);
 }
 
 static struct volume_group *_import_vg_from_config_tree(const struct dm_config_tree *cft,
diff --git a/lib/format_text/layout.h b/lib/format_text/layout.h
index f99a6f8..98a0b36 100644
--- a/lib/format_text/layout.h
+++ b/lib/format_text/layout.h
@@ -83,7 +83,7 @@ struct mda_header {
 
 struct mda_header *raw_read_mda_header(struct dm_pool *mem, struct device_area *dev_area, int primary_mda);
 int raw_read_mda_header_callback(struct dm_pool *mem, struct device_area *dev_area, int primary_mda,
-				 lvm_callback_fn_t mdah_callback_fn, void *mdah_callback_context);
+				 unsigned ioflags, lvm_callback_fn_t mdah_callback_fn, void *mdah_callback_context);
 
 struct mda_lists {
 	struct dm_list dirs;
@@ -109,7 +109,7 @@ struct mda_context {
 
 int vgname_from_mda(const struct format_type *fmt, const struct mda_header *mdah, int primary_mda, 
 		    struct device_area *dev_area, struct lvmcache_vgsummary *vgsummary,
-		    uint64_t *mda_free_sectors,
+		    uint64_t *mda_free_sectors, unsigned ioflags,
 		    lvm_callback_fn_t update_vgsummary_callback_fn, void *update_vgsummary_callback_context);
 
 #endif
diff --git a/lib/format_text/text_label.c b/lib/format_text/text_label.c
index be797b2..49f4015 100644
--- a/lib/format_text/text_label.c
+++ b/lib/format_text/text_label.c
@@ -323,6 +323,7 @@ struct update_mda_baton {
 	struct lvmcache_info *info;
 	struct label *label;
 	int nr_outstanding_mdas;
+	unsigned ioflags;
 	lvm_callback_fn_t read_label_callback_fn;
 	void *read_label_callback_context;
 	int ret;
@@ -336,7 +337,7 @@ struct process_mda_header_params {
 	int ret;
 };
 
-static void _process_vgsummary(int failed, void *context, const void *data)
+static void _process_vgsummary(int failed, unsigned ioflags, void *context, const void *data)
 {
 	struct process_mda_header_params *pmp = context;
 	const struct lvmcache_vgsummary *vgsummary = data;
@@ -359,10 +360,10 @@ out:
 		stack;
 
 	if (!pmp->umb->nr_outstanding_mdas && pmp->umb->read_label_callback_fn)
-		pmp->umb->read_label_callback_fn(!pmp->umb->ret, pmp->umb->read_label_callback_context, pmp->umb->label);
+		pmp->umb->read_label_callback_fn(!pmp->umb->ret, ioflags, pmp->umb->read_label_callback_context, pmp->umb->label);
 }
 
-static void _process_mda_header(int failed, void *context, const void *data)
+static void _process_mda_header(int failed, unsigned ioflags, void *context, const void *data)
 {
 	struct process_mda_header_params *pmp = context;
 	const struct mda_header *mdah = data;
@@ -383,7 +384,7 @@ static void _process_mda_header(int failed, void *context, const void *data)
 		goto bad;
 	}
 
-	if (!vgname_from_mda(fmt, mdah, mda_is_primary(mda), &mdac->area, &pmp->vgsummary, &mdac->free_sectors, _process_vgsummary, pmp)) {
+	if (!vgname_from_mda(fmt, mdah, mda_is_primary(mda), &mdac->area, &pmp->vgsummary, &mdac->free_sectors, ioflags, _process_vgsummary, pmp)) {
 		/* FIXME Separate fatal and non-fatal error cases? */
 		goto_bad;
 	}
@@ -391,7 +392,7 @@ static void _process_mda_header(int failed, void *context, const void *data)
 	return;
 
 bad:
-	_process_vgsummary(1, pmp, NULL);
+	_process_vgsummary(1, ioflags, pmp, NULL);
 	return;
 }
 
@@ -411,6 +412,7 @@ static int _update_mda(struct metadata_area *mda, void *baton)
 	const struct format_type *fmt = umb->label->labeller->fmt;
 	struct dm_pool *mem = umb->label->labeller->fmt->cmd->mem;
 	struct mda_context *mdac = (struct mda_context *) mda->metadata_locn;
+	unsigned ioflags = umb->ioflags;
 
 	if (!(pmp = dm_pool_zalloc(mem, sizeof(*pmp)))) {
 		log_error("struct process_mda_header_params allocation failed");
@@ -432,14 +434,14 @@ static int _update_mda(struct metadata_area *mda, void *baton)
 		mda_set_ignored(mda, 1);
 		stack;
 		if (!--umb->nr_outstanding_mdas && umb->read_label_callback_fn)
-			umb->read_label_callback_fn(!umb->ret, umb->read_label_callback_context, umb->label);
+			umb->read_label_callback_fn(!umb->ret, ioflags, umb->read_label_callback_context, umb->label);
 		return 1;
 	}
 
 	pmp->ret = 1;
 
-	if (!raw_read_mda_header_callback(fmt->cmd->mem, &mdac->area, mda_is_primary(mda), _process_mda_header, pmp)) {
-		_process_vgsummary(1, pmp, NULL);
+	if (!raw_read_mda_header_callback(fmt->cmd->mem, &mdac->area, mda_is_primary(mda), ioflags, _process_mda_header, pmp)) {
+		_process_vgsummary(1, ioflags, pmp, NULL);
 		stack;
 		return 1;
 	}
@@ -447,7 +449,7 @@ static int _update_mda(struct metadata_area *mda, void *baton)
 	return pmp->ret;
 }
 
-static int _text_read(struct labeller *l, struct device *dev, void *buf, 
+static int _text_read(struct labeller *l, struct device *dev, void *buf, unsigned ioflags,
 		      lvm_callback_fn_t read_label_callback_fn, void *read_label_callback_context)
 {
 	struct label_header *lh = (struct label_header *) buf;
@@ -526,6 +528,7 @@ out:
 
 	umb->info = info;
 	umb->label = label;
+	umb->ioflags = ioflags;
 	umb->read_label_callback_fn = read_label_callback_fn;
 	umb->read_label_callback_context = read_label_callback_context;
 
@@ -537,7 +540,7 @@ out:
 	if (!umb->nr_outstanding_mdas) {
 		lvmcache_make_valid(info);
 		if (read_label_callback_fn)
-			read_label_callback_fn(0, read_label_callback_context, label);
+			read_label_callback_fn(0, ioflags, read_label_callback_context, label);
 		return 1;
 	}
 
@@ -548,7 +551,7 @@ out:
 
 bad:
 	if (read_label_callback_fn)
-		read_label_callback_fn(1, read_label_callback_context, label);
+		read_label_callback_fn(1, ioflags, read_label_callback_context, label);
 
 	return 0;
 }
diff --git a/lib/label/label.c b/lib/label/label.c
index be05285..d293caf 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -131,7 +131,7 @@ struct find_labeller_params {
 	int ret;
 };
 
-static void _set_label_read_result(int failed, void *context, const void *data)
+static void _set_label_read_result(int failed, unsigned ioflags, void *context, const void *data)
 {
 	struct find_labeller_params *flp = context;
 	struct label **result = flp->result;
@@ -155,11 +155,11 @@ out:
 	if (!dev_close(flp->dev))
 		stack;
 
-	if (flp->ret && flp->process_label_data_fn)
-		flp->process_label_data_fn(0, flp->process_label_data_context, NULL);
+	if (flp->process_label_data_fn)
+		flp->process_label_data_fn(0, ioflags, flp->process_label_data_context, NULL);
 }
 
-static void _find_labeller(int failed, void *context, const void *data)
+static void _find_labeller(int failed, unsigned ioflags, void *context, const void *data)
 {
 	struct find_labeller_params *flp = context;
 	const char *readbuf = data;
@@ -174,7 +174,7 @@ static void _find_labeller(int failed, void *context, const void *data)
 
 	if (failed) {
 		log_debug_devs("%s: Failed to read label area", dev_name(dev));
-		_set_label_read_result(1, flp, NULL);
+		_set_label_read_result(1, ioflags, flp, NULL);
 		return;
 	}
 
@@ -235,9 +235,9 @@ static void _find_labeller(int failed, void *context, const void *data)
 			_update_lvmcache_orphan(info);
 		log_very_verbose("%s: No label detected", dev_name(dev));
 		flp->ret = 0;
-		_set_label_read_result(1, flp, NULL);
+		_set_label_read_result(1, ioflags, flp, NULL);
 	} else
-		(void) (l->ops->read)(l, dev, labelbuf, &_set_label_read_result, flp);
+		(void) (l->ops->read)(l, dev, labelbuf, ioflags, &_set_label_read_result, flp);
 }
 
 /* FIXME Also wipe associated metadata area headers? */
@@ -315,7 +315,7 @@ int label_remove(struct device *dev)
 }
 
 static int _label_read(struct device *dev, uint64_t scan_sector, struct label **result,
-		       lvm_callback_fn_t process_label_data_fn, void *process_label_data_context)
+		       unsigned ioflags, lvm_callback_fn_t process_label_data_fn, void *process_label_data_context)
 {
 	struct lvmcache_info *info;
 	struct find_labeller_params *flp;
@@ -325,7 +325,7 @@ static int _label_read(struct device *dev, uint64_t scan_sector, struct label **
 		if (result)
 			*result = lvmcache_get_label(info);
 		if (process_label_data_fn)
-			process_label_data_fn(0, process_label_data_context, NULL);
+			process_label_data_fn(0, ioflags, process_label_data_context, NULL);
 		return 1;
 	}
 
@@ -356,9 +356,9 @@ static int _label_read(struct device *dev, uint64_t scan_sector, struct label **
 		return 0;
 	}
 
-	if (!(dev_read_callback(dev, scan_sector << SECTOR_SHIFT, LABEL_SCAN_SIZE, DEV_IO_LABEL, _find_labeller, flp))) {
+	if (!(dev_read_callback(dev, scan_sector << SECTOR_SHIFT, LABEL_SCAN_SIZE, DEV_IO_LABEL, ioflags, _find_labeller, flp))) {
 		log_debug_devs("%s: Failed to read label area", dev_name(dev));
-		_set_label_read_result(1, flp, NULL);
+		_set_label_read_result(1, ioflags, flp, NULL);
 		return 0;
 	}
 
@@ -368,13 +368,13 @@ static int _label_read(struct device *dev, uint64_t scan_sector, struct label **
 /* result may be NULL if caller doesn't need it */
 int label_read(struct device *dev, struct label **result, uint64_t scan_sector)
 {
-	return _label_read(dev, scan_sector, result, NULL, NULL);
+	return _label_read(dev, scan_sector, result, 0, NULL, NULL);
 }
 
-int label_read_callback(struct device *dev, uint64_t scan_sector,
+int label_read_callback(struct device *dev, uint64_t scan_sector, unsigned ioflags,
 		       lvm_callback_fn_t process_label_data_fn, void *process_label_data_context)
 {
-	return _label_read(dev, scan_sector, NULL, process_label_data_fn, process_label_data_context);
+	return _label_read(dev, scan_sector, NULL, ioflags, process_label_data_fn, process_label_data_context);
 }
 
 /* Caller may need to use label_get_handler to create label struct! */
diff --git a/lib/label/label.h b/lib/label/label.h
index c566870..6d31eb0 100644
--- a/lib/label/label.h
+++ b/lib/label/label.h
@@ -63,7 +63,7 @@ struct label_ops {
 	 * Read a label from a volume.
 	 */
 	int (*read) (struct labeller *l, struct device *dev, void *buf,
-		     lvm_callback_fn_t label_read_callback_fn, void *label_read_callback_context);
+		     unsigned ioflags, lvm_callback_fn_t label_read_callback_fn, void *label_read_callback_context);
 
 	/*
 	 * Populate label_type etc.
@@ -97,7 +97,7 @@ int label_remove(struct device *dev);
 int label_read(struct device *dev, struct label **result,
 		uint64_t scan_sector);
 int label_read_callback(struct device *dev, uint64_t scan_sector,
-			lvm_callback_fn_t process_label_data_fn, void *process_label_data_context);
+			unsigned ioflags, lvm_callback_fn_t process_label_data_fn, void *process_label_data_context);
 int label_write(struct device *dev, struct label *label);
 struct label *label_create(struct labeller *labeller);
 void label_destroy(struct label *label);
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 6c55d89..c529abf 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3912,9 +3912,9 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 		use_previous_vg = 0;
 
 		if ((use_precommitted &&
-		     !(vg = mda->ops->vg_read_precommit(fid, vgname, mda, &vg_fmtdata, &use_previous_vg)) && !use_previous_vg) ||
+		     !(vg = mda->ops->vg_read_precommit(fid, vgname, mda, &vg_fmtdata, &use_previous_vg, 0)) && !use_previous_vg) ||
 		    (!use_precommitted &&
-		     !(vg = mda->ops->vg_read(fid, vgname, mda, &vg_fmtdata, &use_previous_vg, 0)) && !use_previous_vg)) {
+		     !(vg = mda->ops->vg_read(fid, vgname, mda, &vg_fmtdata, &use_previous_vg, 0, 0)) && !use_previous_vg)) {
 			inconsistent = 1;
 			vg_fmtdata = NULL;
 			continue;
@@ -4104,9 +4104,9 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 			use_previous_vg = 0;
 
 			if ((use_precommitted &&
-			     !(vg = mda->ops->vg_read_precommit(fid, vgname, mda, &vg_fmtdata, &use_previous_vg)) && !use_previous_vg) ||
+			     !(vg = mda->ops->vg_read_precommit(fid, vgname, mda, &vg_fmtdata, &use_previous_vg, 0)) && !use_previous_vg) ||
 			    (!use_precommitted &&
-			     !(vg = mda->ops->vg_read(fid, vgname, mda, &vg_fmtdata, &use_previous_vg, 0)) && !use_previous_vg)) {
+			     !(vg = mda->ops->vg_read(fid, vgname, mda, &vg_fmtdata, &use_previous_vg, 0, 0)) && !use_previous_vg)) {
 				inconsistent = 1;
 				vg_fmtdata = NULL;
 				continue;
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index f15080a..df660a7 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -80,12 +80,12 @@ struct metadata_area_ops {
 					 struct metadata_area * mda,
 					 struct cached_vg_fmtdata **vg_fmtdata,
 					 unsigned *use_previous_vg,
-					 int single_device);
+					 int single_device, unsigned ioflags);
 	struct volume_group *(*vg_read_precommit) (struct format_instance * fi,
 					 const char *vg_name,
 					 struct metadata_area * mda,
 					 struct cached_vg_fmtdata **vg_fmtdata,
-					 unsigned *use_previous_vg);
+					 unsigned *use_previous_vg, unsigned ioflags);
 	/*
 	 * Write out complete VG metadata.  You must ensure internal
 	 * consistency before calling. eg. PEs can't refer to PVs not


