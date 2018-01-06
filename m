From: Alasdair Kergon <agk@sourceware.org>
Date: Fri, 5 Jan 2018 21:43:29 -0500
Subject: master - device: Introduce dev_read_callback
Message-ID: <201801060243.w062hTWB013322@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5e7d3ad749d3de735ba213ad64637182afec2586
Commit:        5e7d3ad749d3de735ba213ad64637182afec2586
Parent:        946f07af3e8f97b0e48752ce1cd8de87d3456540
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Sat Jan 6 00:33:09 2018 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Sat Jan 6 02:40:12 2018 +0000

device: Introduce dev_read_callback

If it obtains the data, it passes it into the supplied callback function
and returns 1.  Otherwise the callback receives failed = 1.

Updated config_file_read_fd to use this and similarly return the data
via a callback fn of its own.
---
 WHATS_NEW                |    1 +
 lib/config/config.c      |   72 ++++++++++++++++++++++++++--------------------
 lib/config/config.h      |    4 ++-
 lib/device/dev-io.c      |   27 +++++++++++++++++
 lib/device/device.h      |    8 ++++-
 lib/format_text/import.c |   39 +++++++++++++-----------
 6 files changed, 100 insertions(+), 51 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index fa79068..345c472 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.178 - 
 =====================================
+  Refactor metadata reading code to use callback functions.
   Move memory allocation for the key dev_reads into the device layer.
 
 Version 2.02.177 - 18th December 2017
diff --git a/lib/config/config.c b/lib/config/config.c
index bffee06..7217cd9 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -500,16 +500,21 @@ struct process_config_file_params {
 	uint32_t checksum;
 	int checksum_only;
 	int no_dup_node_check;
+	int use_mmap;
+	lvm_callback_fn_t config_file_read_fd_callback;
+	void *config_file_read_fd_context;
 	int ret;
 };
 
 static void _process_config_file_buffer(int failed, void *context, void *data)
 {
 	struct process_config_file_params *pcfp = context;
-	char *buffer = data;
-	char *fb, *fe;
+	char *fb = data, *fe;
 
-	fb = buffer;
+	if (failed) {
+		pcfp->ret = 0;
+		goto_out;
+	}
 
 	if (pcfp->checksum_fn && pcfp->checksum !=
 	    (pcfp->checksum_fn(pcfp->checksum_fn(INITIAL_CRC, (const uint8_t *)fb, pcfp->size),
@@ -529,7 +534,11 @@ static void _process_config_file_buffer(int failed, void *context, void *data)
 	}
 
 out:
-	;
+	if (!failed && !pcfp->use_mmap)
+		dm_free(data);
+
+	if (pcfp->config_file_read_fd_callback)
+		pcfp->config_file_read_fd_callback(!pcfp->ret, pcfp->config_file_read_fd_context, NULL);
 }
 
 /*
@@ -540,11 +549,11 @@ out:
 int config_file_read_fd(struct dm_pool *mem, struct dm_config_tree *cft, struct device *dev, dev_io_reason_t reason,
 			off_t offset, size_t size, off_t offset2, size_t size2,
 			checksum_fn_t checksum_fn, uint32_t checksum,
-			int checksum_only, int no_dup_node_check)
+			int checksum_only, int no_dup_node_check,
+			lvm_callback_fn_t config_file_read_fd_callback, void *config_file_read_fd_context)
 {
 	char *fb;
 	int r = 0;
-	int use_mmap = 1;
 	off_t mmap_offset = 0;
 	char *buf = NULL;
 	unsigned circular = size2 ? 1 : 0;	/* Wrapped around end of disk metadata buffer? */
@@ -555,12 +564,12 @@ int config_file_read_fd(struct dm_pool *mem, struct dm_config_tree *cft, struct
 		log_error(INTERNAL_ERROR "config_file_read_fd: expected file, special file "
 					 "or profile config source, found %s config source.",
 					 _config_source_names[cs->type]);
-		return 0;
+		goto bad;
 	}
 
 	if (!(pcfp = dm_pool_zalloc(mem, sizeof(*pcfp)))) {
 		log_debug("config_file_read_fd: process_config_file_params struct allocation failed");
-		return 0;
+		goto bad;
 	}
 
 	pcfp->cft = cft;
@@ -573,48 +582,49 @@ int config_file_read_fd(struct dm_pool *mem, struct dm_config_tree *cft, struct
 	pcfp->checksum = checksum;
 	pcfp->checksum_only = checksum_only;
 	pcfp->no_dup_node_check = no_dup_node_check;
+	pcfp->config_file_read_fd_callback = config_file_read_fd_callback;
+	pcfp->config_file_read_fd_context = config_file_read_fd_context;
+	pcfp->use_mmap = 1;
 	pcfp->ret = 1;
 
 	/* Only use mmap with regular files */
 	if (!(dev->flags & DEV_REGULAR) || circular)
-		use_mmap = 0;
+		pcfp->use_mmap = 0;
 
-	if (use_mmap) {
+	if (pcfp->use_mmap) {
 		mmap_offset = offset % lvm_getpagesize();
 		/* memory map the file */
 		fb = mmap((caddr_t) 0, size + mmap_offset, PROT_READ,
 			  MAP_PRIVATE, dev_fd(dev), offset - mmap_offset);
 		if (fb == (caddr_t) (-1)) {
 			log_sys_error("mmap", dev_name(dev));
-			goto out;
+			goto bad;
+		}
+		_process_config_file_buffer(0, pcfp, fb + mmap_offset);
+		r = pcfp->ret;
+		/* unmap the file */
+		if (munmap(fb, size + mmap_offset)) {
+			log_sys_error("munmap", dev_name(dev));
+			r = 0;
 		}
-		fb = fb + mmap_offset;
 	} else {
 		if (circular) {
 			if (!(buf = dev_read_circular(dev, (uint64_t) offset, size, (uint64_t) offset2, size2, reason)))
 				goto_out;
-		} else {
-			if (!(buf = dev_read(dev, (uint64_t) offset, size, reason)))
-				goto_out;
-		}
-		fb = buf;
+			_process_config_file_buffer(0, pcfp, buf);
+		} else if (!dev_read_callback(dev, (uint64_t) offset, size, reason, _process_config_file_buffer, pcfp))
+			goto_out;
+		r = pcfp->ret;
 	}
 
-	_process_config_file_buffer(0, pcfp, fb);
-	r = pcfp->ret;
+out:
+	return r;
 
-      out:
-	if (!use_mmap)
-		dm_free(buf);
-	else {
-		/* unmap the file */
-		if (munmap(fb - mmap_offset, size + mmap_offset)) {
-			log_sys_error("munmap", dev_name(dev));
-			r = 0;
-		}
-	}
+bad:
+	if (config_file_read_fd_callback)
+		config_file_read_fd_callback(1, config_file_read_fd_context, NULL);
 
-	return r;
+	return 0;
 }
 
 int config_file_read(struct dm_pool *mem, struct dm_config_tree *cft)
@@ -646,7 +656,7 @@ int config_file_read(struct dm_pool *mem, struct dm_config_tree *cft)
 	}
 
 	r = config_file_read_fd(mem, cft, cf->dev, DEV_IO_MDA_CONTENT, 0, (size_t) info.st_size, 0, 0,
-				(checksum_fn_t) NULL, 0, 0, 0);
+				(checksum_fn_t) NULL, 0, 0, 0, NULL, NULL);
 
 	if (!cf->keep_open) {
 		if (!dev_close(cf->dev))
diff --git a/lib/config/config.h b/lib/config/config.h
index 5c8844a..9901003 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -242,7 +242,9 @@ struct dm_config_tree *config_open(config_source_t source, const char *filename,
 int config_file_read_fd(struct dm_pool *mem, struct dm_config_tree *cft, struct device *dev, dev_io_reason_t reason,
 			off_t offset, size_t size, off_t offset2, size_t size2,
 			checksum_fn_t checksum_fn, uint32_t checksum,
-			int skip_parse, int no_dup_node_check);
+			int skip_parse, int no_dup_node_check,
+			lvm_callback_fn_t config_file_read_fd_callback, void *config_file_read_fd_context);
+
 int config_file_read(struct dm_pool *mem, struct dm_config_tree *cft);
 struct dm_config_tree *config_file_open_and_read(const char *config_file, config_source_t source,
 						 struct cmd_context *cmd);
diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index 72d6768..22a0d4c 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -763,6 +763,33 @@ char *dev_read(struct device *dev, uint64_t offset, size_t len, dev_io_reason_t
 	return buf;
 }
 
+/* Callback fn is responsible for dm_free */
+int dev_read_callback(struct device *dev, uint64_t offset, size_t len, dev_io_reason_t reason,
+		      lvm_callback_fn_t dev_read_callback_fn, void *callback_context)
+{
+	char *buf;
+	int r = 0;
+
+	if (!(buf = dm_malloc(len))) {
+		log_error("Buffer allocation failed for device read.");
+		goto out;
+	}
+
+	if (!_dev_read(dev, offset, len, reason, buf)) {
+		log_error("Read from %s failed", dev_name(dev));
+		dm_free(buf);
+		goto out;
+	}
+
+	r = 1;
+
+out:
+	if (dev_read_callback_fn)
+		dev_read_callback_fn(!r, callback_context, buf);
+
+	return r;
+}
+
 /* Read into supplied retbuf */
 int dev_read_buf(struct device *dev, uint64_t offset, size_t len, dev_io_reason_t reason, void *retbuf)
 {
diff --git a/lib/device/device.h b/lib/device/device.h
index 04117d2..4349222 100644
--- a/lib/device/device.h
+++ b/lib/device/device.h
@@ -33,7 +33,9 @@
 #define DEV_NOT_O_NOATIME	0x00000400	/* Don't use O_NOATIME */
 
 /*
- * Standard format for callback functions
+ * Standard format for callback functions.
+ * When provided, callback functions are called exactly once.
+ * If failed is set, data cannot be accessed.
  */
 typedef void (*lvm_callback_fn_t)(int failed, void *context, void *data);
 
@@ -155,6 +157,10 @@ char *dev_read(struct device *dev, uint64_t offset, size_t len, dev_io_reason_t
 char *dev_read_circular(struct device *dev, uint64_t offset, size_t len,
 			uint64_t offset2, size_t len2, dev_io_reason_t reason);
 
+/* Passes the data to dev_read_callback_fn */
+int dev_read_callback(struct device *dev, uint64_t offset, size_t len, dev_io_reason_t reason,
+		      lvm_callback_fn_t dev_read_callback_fn, void *callback_context);
+
 /* Read data and copy it into a supplied private buffer. */
 /* Only use for tiny reads or on unimportant code paths. */
 int dev_read_buf(struct device *dev, uint64_t offset, size_t len, dev_io_reason_t reason, void *retbuf);
diff --git a/lib/format_text/import.c b/lib/format_text/import.c
index 64ef2be..a295b78 100644
--- a/lib/format_text/import.c
+++ b/lib/format_text/import.c
@@ -46,6 +46,11 @@ static void _import_vgsummary(int failed, void *context, void *data)
 	struct import_vgsummary_params *ivsp = context;
 	struct text_vg_version_ops **vsn;
 
+	if (failed) {
+		ivsp->ret = 0;
+		goto_out;
+	}
+
 	if (ivsp->checksum_only)
 		/* Checksum matches already-cached content - no need to reparse. */
 		goto out;
@@ -100,23 +105,20 @@ int text_vgsummary_import(const struct format_type *fmt,
 	ivsp->vgsummary = vgsummary;
 	ivsp->ret = 1;
 
-	if (!dev && !config_file_read(fmt->cmd->mem, ivsp->cft)) {
-		log_error("Couldn't read volume group metadata.");
-		config_destroy(ivsp->cft);
-		return 0;
-	}
-
-	if (dev && !config_file_read_fd(fmt->cmd->mem, ivsp->cft, dev, reason, offset, size,
+	if (!dev) {
+		if (!config_file_read(fmt->cmd->mem, ivsp->cft)) {
+			log_error("Couldn't read volume group metadata.");
+			ivsp->ret = 0;
+		}
+		_import_vgsummary(!ivsp->ret, ivsp, NULL);
+	} else if (!config_file_read_fd(fmt->cmd->mem, ivsp->cft, dev, reason, offset, size,
 					offset2, size2, checksum_fn,
 					vgsummary->mda_checksum,
-					checksum_only, 1)) {
+					checksum_only, 1, &_import_vgsummary, ivsp)) {
 		log_error("Couldn't read volume group metadata.");
-		config_destroy(ivsp->cft);
 		return 0;
 	}
 
-	_import_vgsummary(0, ivsp, NULL);
-
 	return ivsp->ret;
 }
 
@@ -229,14 +231,15 @@ struct volume_group *text_vg_import_fd(struct format_instance *fid,
 		return_NULL;
 	}
 
-	if (dev && !config_file_read_fd(fid->mem, ivp->cft, dev, MDA_CONTENT_REASON(primary_mda), offset, size,
+	if (dev) {
+		if (!config_file_read_fd(fid->mem, ivp->cft, dev, MDA_CONTENT_REASON(primary_mda), offset, size,
 					offset2, size2, checksum_fn, checksum,
-					ivp->skip_parse, 1)) {
-		config_destroy(ivp->cft);
-		return_NULL;
-	}
-
-	_import_vg(0, ivp, NULL);
+					ivp->skip_parse, 1, &_import_vg, ivp)) {
+			config_destroy(ivp->cft);
+			return_NULL;
+		}
+	} else
+		_import_vg(0, ivp, NULL);
 
 	return ivp->vg;
 }


