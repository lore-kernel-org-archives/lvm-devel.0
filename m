From: Alasdair Kergon <agk@sourceware.org>
Date: Wed, 6 Dec 2017 22:49:06 -0500
Subject: master - device: Tag I/O for each mda on a device separately in log messages.
Message-ID: <201712070349.vB73n6Eo026598@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d591d041033ce66f092becb285fc43f6fef63ee8
Commit:        d591d041033ce66f092becb285fc43f6fef63ee8
Parent:        54154dc6f11ae869228cf9f36dc5ae919e861caa
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Dec 7 03:34:59 2017 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Dec 7 03:48:11 2017 +0000

device: Tag I/O for each mda on a device separately in log messages.

Mark the first metadata area on each text format PV as MDA_PRIMARY.
Pass this information down to the device layer so that when
there are two metadata areas on a block device, we can easily
distinguish two independent streams of I/O.
---
 lib/config/config.c             |    6 ++--
 lib/config/config.h             |    4 +-
 lib/device/dev-io.c             |    2 +
 lib/device/device.h             |    2 +
 lib/format_text/format-text.c   |   73 ++++++++++++++++++++-------------------
 lib/format_text/import-export.h |    4 +-
 lib/format_text/import.c        |   10 +++---
 lib/format_text/layout.h        |    4 +-
 lib/format_text/text_label.c    |   20 ++++++++---
 lib/metadata/metadata.h         |    7 ++++
 10 files changed, 77 insertions(+), 55 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index 947cb7b..8fca372 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -494,7 +494,7 @@ int override_config_tree_from_profile(struct cmd_context *cmd,
  * and function avoids parsing of mda into config tree which
  * remains unmodified and should not be used.
  */
-int config_file_read_fd(struct dm_config_tree *cft, struct device *dev,
+int config_file_read_fd(struct dm_config_tree *cft, struct device *dev, dev_io_reason_t reason,
 			off_t offset, size_t size, off_t offset2, size_t size2,
 			checksum_fn_t checksum_fn, uint32_t checksum,
 			int checksum_only, int no_dup_node_check)
@@ -533,7 +533,7 @@ int config_file_read_fd(struct dm_config_tree *cft, struct device *dev,
 			return 0;
 		}
 		if (!dev_read_circular(dev, (uint64_t) offset, size,
-				       (uint64_t) offset2, size2, DEV_IO_MDA_CONTENT, buf)) {
+				       (uint64_t) offset2, size2, reason, buf)) {
 			goto out;
 		}
 		fb = buf;
@@ -601,7 +601,7 @@ int config_file_read(struct dm_config_tree *cft)
 		}
 	}
 
-	r = config_file_read_fd(cft, cf->dev, 0, (size_t) info.st_size, 0, 0,
+	r = config_file_read_fd(cft, cf->dev, DEV_IO_MDA_CONTENT, 0, (size_t) info.st_size, 0, 0,
 				(checksum_fn_t) NULL, 0, 0, 0);
 
 	if (!cf->keep_open) {
diff --git a/lib/config/config.h b/lib/config/config.h
index 901994a..d01306b 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -17,12 +17,12 @@
 #define _LVM_CONFIG_H
 
 #include "libdevmapper.h"
+#include "device.h"
 
 /* 16 bits: 3 bits for major, 4 bits for minor, 9 bits for patchlevel */
 /* FIXME Max LVM version supported: 7.15.511. Extend bits when needed. */
 #define vsn(major, minor, patchlevel) (major << 13 | minor << 9 | patchlevel)
 
-struct device;
 struct cmd_context;
 
 typedef enum {
@@ -239,7 +239,7 @@ config_source_t config_get_source_type(struct dm_config_tree *cft);
 typedef uint32_t (*checksum_fn_t) (uint32_t initial, const uint8_t *buf, uint32_t size);
 
 struct dm_config_tree *config_open(config_source_t source, const char *filename, int keep_open);
-int config_file_read_fd(struct dm_config_tree *cft, struct device *dev,
+int config_file_read_fd(struct dm_config_tree *cft, struct device *dev, dev_io_reason_t reason,
 			off_t offset, size_t size, off_t offset2, size_t size2,
 			checksum_fn_t checksum_fn, uint32_t checksum,
 			int skip_parse, int no_dup_node_check);
diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index f77494f..a9a9aac 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -61,6 +61,8 @@ static const char *_reasons[] = {
 	"PV labels",
 	"VG metadata header",
 	"VG metadata content",
+	"extra VG metadata header",
+	"extra VG metadata content",
 	"LVM1 metadata",
 	"pool metadata",
 	"LV content",
diff --git a/lib/device/device.h b/lib/device/device.h
index 254edfe..503373f 100644
--- a/lib/device/device.h
+++ b/lib/device/device.h
@@ -87,6 +87,8 @@ typedef enum dev_io_reason {
 	DEV_IO_LABEL,		/* LVM PV disk label */
 	DEV_IO_MDA_HEADER,	/* Text format metadata area header */
 	DEV_IO_MDA_CONTENT,	/* Text format metadata area content */
+	DEV_IO_MDA_EXTRA_HEADER,	/* Header of any extra metadata areas on device */
+	DEV_IO_MDA_EXTRA_CONTENT,	/* Content of any extra metadata areas on device */
 	DEV_IO_FMT1,		/* Original LVM1 metadata format */
 	DEV_IO_POOL,		/* Pool metadata format */
 	DEV_IO_LV,		/* Content written to an LV */
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 31d92a5..09ce693 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -190,7 +190,7 @@ static int _pv_analyze_mda_raw (const struct format_type * fmt,
 	if (!dev_open_readonly(area->dev))
 		return_0;
 
-	if (!(mdah = raw_read_mda_header(fmt, area)))
+	if (!(mdah = raw_read_mda_header(fmt, area, mda_is_primary(mda))))
 		goto_out;
 
 	rlocn = mdah->raw_locns;
@@ -230,7 +230,7 @@ static int _pv_analyze_mda_raw (const struct format_type * fmt,
 		if (!(buf = dm_malloc(size + size2)))
 			goto_out;
 
-		if (!dev_read_circular(area->dev, offset, size, offset2, size2, DEV_IO_MDA_CONTENT, buf))
+		if (!dev_read_circular(area->dev, offset, size, offset2, size2, MDA_CONTENT_REASON(mda_is_primary(mda)), buf))
 			goto_out;
 
 		/*
@@ -315,12 +315,12 @@ static void _xlate_mdah(struct mda_header *mdah)
 	}
 }
 
-static int _raw_read_mda_header(struct mda_header *mdah, struct device_area *dev_area)
+static int _raw_read_mda_header(struct mda_header *mdah, struct device_area *dev_area, int primary_mda)
 {
 	if (!dev_open_readonly(dev_area->dev))
 		return_0;
 
-	if (!dev_read(dev_area->dev, dev_area->start, MDA_HEADER_SIZE, DEV_IO_MDA_HEADER, mdah)) {
+	if (!dev_read(dev_area->dev, dev_area->start, MDA_HEADER_SIZE, MDA_HEADER_REASON(primary_mda), mdah)) {
 		if (!dev_close(dev_area->dev))
 			stack;
 		return_0;
@@ -365,7 +365,7 @@ static int _raw_read_mda_header(struct mda_header *mdah, struct device_area *dev
 }
 
 struct mda_header *raw_read_mda_header(const struct format_type *fmt,
-				       struct device_area *dev_area)
+				       struct device_area *dev_area, int primary_mda)
 {
 	struct mda_header *mdah;
 
@@ -374,7 +374,7 @@ struct mda_header *raw_read_mda_header(const struct format_type *fmt,
 		return NULL;
 	}
 
-	if (!_raw_read_mda_header(mdah, dev_area)) {
+	if (!_raw_read_mda_header(mdah, dev_area, primary_mda)) {
 		dm_pool_free(fmt->cmd->mem, mdah);
 		return NULL;
 	}
@@ -383,7 +383,7 @@ struct mda_header *raw_read_mda_header(const struct format_type *fmt,
 }
 
 static int _raw_write_mda_header(const struct format_type *fmt,
-				 struct device *dev,
+				 struct device *dev, int primary_mda,
 				 uint64_t start_byte, struct mda_header *mdah)
 {
 	strncpy((char *)mdah->magic, FMTT_MAGIC, sizeof(mdah->magic));
@@ -395,14 +395,14 @@ static int _raw_write_mda_header(const struct format_type *fmt,
 					     MDA_HEADER_SIZE -
 					     sizeof(mdah->checksum_xl)));
 
-	if (!dev_write(dev, start_byte, MDA_HEADER_SIZE, DEV_IO_MDA_HEADER, mdah))
+	if (!dev_write(dev, start_byte, MDA_HEADER_SIZE, MDA_HEADER_REASON(primary_mda), mdah))
 		return_0;
 
 	return 1;
 }
 
 static struct raw_locn *_find_vg_rlocn(struct device_area *dev_area,
-				       struct mda_header *mdah,
+				       struct mda_header *mdah, int primary_mda,
 				       const char *vgname,
 				       int *precommitted)
 {
@@ -449,7 +449,7 @@ static struct raw_locn *_find_vg_rlocn(struct device_area *dev_area,
 	/* FIXME Loop through rlocns two-at-a-time.  List null-terminated. */
 	/* FIXME Ignore if checksum incorrect!!! */
 	if (!dev_read(dev_area->dev, dev_area->start + rlocn->offset,
-		      sizeof(vgnamebuf), DEV_IO_MDA_CONTENT, vgnamebuf))
+		      sizeof(vgnamebuf), MDA_CONTENT_REASON(primary_mda), vgnamebuf))
 		goto_bad;
 
 	if (!strncmp(vgnamebuf, vgname, len = strlen(vgname)) &&
@@ -497,10 +497,10 @@ static int _raw_holds_vgname(struct format_instance *fid,
 	if (!dev_open_readonly(dev_area->dev))
 		return_0;
 
-	if (!(mdah = raw_read_mda_header(fid->fmt, dev_area)))
+	if (!(mdah = raw_read_mda_header(fid->fmt, dev_area, 0)))
 		return_0;
 
-	if (_find_vg_rlocn(dev_area, mdah, vgname, &noprecommit))
+	if (_find_vg_rlocn(dev_area, mdah, 0, vgname, &noprecommit))
 		r = 1;
 
 	if (!dev_close(dev_area->dev))
@@ -515,7 +515,7 @@ static struct volume_group *_vg_read_raw_area(struct format_instance *fid,
 					      struct cached_vg_fmtdata **vg_fmtdata,
 					      unsigned *use_previous_vg,
 					      int precommitted,
-					      int single_device)
+					      int single_device, int primary_mda)
 {
 	struct volume_group *vg = NULL;
 	struct raw_locn *rlocn;
@@ -524,10 +524,10 @@ static struct volume_group *_vg_read_raw_area(struct format_instance *fid,
 	char *desc;
 	uint32_t wrap = 0;
 
-	if (!(mdah = raw_read_mda_header(fid->fmt, area)))
+	if (!(mdah = raw_read_mda_header(fid->fmt, area, primary_mda)))
 		goto_out;
 
-	if (!(rlocn = _find_vg_rlocn(area, mdah, vgname, &precommitted))) {
+	if (!(rlocn = _find_vg_rlocn(area, mdah, primary_mda, vgname, &precommitted))) {
 		log_debug_metadata("VG %s not found on %s", vgname, dev_name(area->dev));
 		goto out;
 	}
@@ -543,6 +543,7 @@ static struct volume_group *_vg_read_raw_area(struct format_instance *fid,
 
 	/* FIXME 64-bit */
 	if (!(vg = text_vg_import_fd(fid, NULL, vg_fmtdata, use_previous_vg, single_device, area->dev, 
+				     primary_mda,
 				     (off_t) (area->start + rlocn->offset),
 				     (uint32_t) (rlocn->size - wrap),
 				     (off_t) (area->start + MDA_HEADER_SIZE),
@@ -581,7 +582,7 @@ static struct volume_group *_vg_read_raw(struct format_instance *fid,
 	if (!dev_open_readonly(mdac->area.dev))
 		return_NULL;
 
-	vg = _vg_read_raw_area(fid, vgname, &mdac->area, vg_fmtdata, use_previous_vg, 0, single_device);
+	vg = _vg_read_raw_area(fid, vgname, &mdac->area, vg_fmtdata, use_previous_vg, 0, single_device, mda_is_primary(mda));
 
 	if (!dev_close(mdac->area.dev))
 		stack;
@@ -601,7 +602,7 @@ static struct volume_group *_vg_read_precommit_raw(struct format_instance *fid,
 	if (!dev_open_readonly(mdac->area.dev))
 		return_NULL;
 
-	vg = _vg_read_raw_area(fid, vgname, &mdac->area, vg_fmtdata, use_previous_vg, 1, 0);
+	vg = _vg_read_raw_area(fid, vgname, &mdac->area, vg_fmtdata, use_previous_vg, 1, 0, mda_is_primary(mda));
 
 	if (!dev_close(mdac->area.dev))
 		stack;
@@ -639,10 +640,10 @@ static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 	if (!dev_open(mdac->area.dev))
 		return_0;
 
-	if (!(mdah = raw_read_mda_header(fid->fmt, &mdac->area)))
+	if (!(mdah = raw_read_mda_header(fid->fmt, &mdac->area, mda_is_primary(mda))))
 		goto_out;
 
-	rlocn = _find_vg_rlocn(&mdac->area, mdah, old_vg_name ? : vg->name, &noprecommit);
+	rlocn = _find_vg_rlocn(&mdac->area, mdah, mda_is_primary(mda), old_vg_name ? : vg->name, &noprecommit);
 	mdac->rlocn.offset = _next_rlocn_offset(rlocn, mdah);
 
 	if (!fidtc->raw_metadata_buf &&
@@ -677,7 +678,7 @@ static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 
 	/* Write text out, circularly */
 	if (!dev_write(mdac->area.dev, mdac->area.start + mdac->rlocn.offset,
-		       (size_t) (mdac->rlocn.size - new_wrap), DEV_IO_MDA_CONTENT,
+		       (size_t) (mdac->rlocn.size - new_wrap), MDA_CONTENT_REASON(mda_is_primary(mda)),
 		       fidtc->raw_metadata_buf))
 		goto_out;
 
@@ -687,7 +688,7 @@ static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 				  MDA_HEADER_SIZE, new_wrap);
 
 		if (!dev_write(mdac->area.dev, mdac->area.start + MDA_HEADER_SIZE,
-			       (size_t) new_wrap, DEV_IO_MDA_CONTENT,
+			       (size_t) new_wrap, MDA_CONTENT_REASON(mda_is_primary(mda)),
 			       fidtc->raw_metadata_buf + mdac->rlocn.size - new_wrap))
 			goto_out;
 	}
@@ -743,10 +744,10 @@ static int _vg_commit_raw_rlocn(struct format_instance *fid,
 	if (!found)
 		return 1;
 
-	if (!(mdah = raw_read_mda_header(fid->fmt, &mdac->area)))
+	if (!(mdah = raw_read_mda_header(fid->fmt, &mdac->area, mda_is_primary(mda))))
 		goto_out;
 
-	if (!(rlocn = _find_vg_rlocn(&mdac->area, mdah, old_vg_name ? : vg->name, &noprecommit))) {
+	if (!(rlocn = _find_vg_rlocn(&mdac->area, mdah, mda_is_primary(mda), old_vg_name ? : vg->name, &noprecommit))) {
 		mdah->raw_locns[0].offset = 0;
 		mdah->raw_locns[0].size = 0;
 		mdah->raw_locns[0].checksum = 0;
@@ -793,7 +794,7 @@ static int _vg_commit_raw_rlocn(struct format_instance *fid,
 
 	rlocn_set_ignored(mdah->raw_locns, mda_is_ignored(mda));
 
-	if (!_raw_write_mda_header(fid->fmt, mdac->area.dev, mdac->area.start,
+	if (!_raw_write_mda_header(fid->fmt, mdac->area.dev, mda_is_primary(mda), mdac->area.start,
 				   mdah)) {
 		dm_pool_free(fid->fmt->cmd->mem, mdah);
 		log_error("Failed to write metadata area header");
@@ -863,10 +864,10 @@ static int _vg_remove_raw(struct format_instance *fid, struct volume_group *vg,
 	if (!dev_open(mdac->area.dev))
 		return_0;
 
-	if (!(mdah = raw_read_mda_header(fid->fmt, &mdac->area)))
+	if (!(mdah = raw_read_mda_header(fid->fmt, &mdac->area, mda_is_primary(mda))))
 		goto_out;
 
-	if (!(rlocn = _find_vg_rlocn(&mdac->area, mdah, vg->name, &noprecommit))) {
+	if (!(rlocn = _find_vg_rlocn(&mdac->area, mdah, mda_is_primary(mda), vg->name, &noprecommit))) {
 		rlocn = &mdah->raw_locns[0];
 		mdah->raw_locns[1].offset = 0;
 	}
@@ -876,7 +877,7 @@ static int _vg_remove_raw(struct format_instance *fid, struct volume_group *vg,
 	rlocn->checksum = 0;
 	rlocn_set_ignored(mdah->raw_locns, mda_is_ignored(mda));
 
-	if (!_raw_write_mda_header(fid->fmt, mdac->area.dev, mdac->area.start,
+	if (!_raw_write_mda_header(fid->fmt, mdac->area.dev, mda_is_primary(mda), mdac->area.start,
 				   mdah)) {
 		dm_pool_free(fid->fmt->cmd->mem, mdah);
 		log_error("Failed to write metadata area header");
@@ -1172,7 +1173,7 @@ static int _scan_file(const struct format_type *fmt, const char *vgname)
 }
 
 int vgname_from_mda(const struct format_type *fmt,
-		    struct mda_header *mdah, struct device_area *dev_area,
+		    struct mda_header *mdah, int primary_mda, struct device_area *dev_area,
 		    struct lvmcache_vgsummary *vgsummary, uint64_t *mda_free_sectors)
 {
 	struct raw_locn *rlocn;
@@ -1204,7 +1205,7 @@ int vgname_from_mda(const struct format_type *fmt,
 
 	/* Do quick check for a vgname */
 	if (!dev_read(dev_area->dev, dev_area->start + rlocn->offset,
-		      NAME_LEN, DEV_IO_MDA_CONTENT, buf))
+		      NAME_LEN, MDA_CONTENT_REASON(primary_mda), buf))
 		return_0;
 
 	while (buf[len] && !isspace(buf[len]) && buf[len] != '{' &&
@@ -1235,7 +1236,7 @@ int vgname_from_mda(const struct format_type *fmt,
 		used_cached_metadata = 1;
 
 	/* FIXME 64-bit */
-	if (!text_vgsummary_import(fmt, dev_area->dev,
+	if (!text_vgsummary_import(fmt, dev_area->dev, MDA_CONTENT_REASON(primary_mda),
 				(off_t) (dev_area->start + rlocn->offset),
 				(uint32_t) (rlocn->size - wrap),
 				(off_t) (dev_area->start + MDA_HEADER_SIZE),
@@ -1292,14 +1293,14 @@ static int _scan_raw(const struct format_type *fmt, const char *vgname __attribu
 			continue;
 		}
 
-		if (!(mdah = raw_read_mda_header(fmt, &rl->dev_area))) {
+		if (!(mdah = raw_read_mda_header(fmt, &rl->dev_area, 0))) {
 			stack;
 			goto close_dev;
 		}
 
 		/* TODO: caching as in vgname_from_mda() (trigger this code?) */
-		if (vgname_from_mda(fmt, mdah, &rl->dev_area, &vgsummary, NULL)) {
-			vg = _vg_read_raw_area(&fid, vgsummary.vgname, &rl->dev_area, NULL, NULL, 0, 0);
+		if (vgname_from_mda(fmt, mdah, 0, &rl->dev_area, &vgsummary, NULL)) {
+			vg = _vg_read_raw_area(&fid, vgsummary.vgname, &rl->dev_area, NULL, NULL, 0, 0, 0);
 			if (vg)
 				lvmcache_update_vg(vg, 0);
 		}
@@ -1333,7 +1334,7 @@ static int _write_single_mda(struct metadata_area *mda, void *baton)
 	mdah->size = mdac->area.size;
 	rlocn_set_ignored(mdah->raw_locns, mda_is_ignored(mda));
 
-	if (!_raw_write_mda_header(p->fmt, mdac->area.dev,
+	if (!_raw_write_mda_header(p->fmt, mdac->area.dev, mda_is_primary(mda),
 				   mdac->area.start, mdah)) {
 		if (!dev_close(p->pv->dev))
 			stack;
@@ -1772,7 +1773,7 @@ static int _mda_export_text_raw(struct metadata_area *mda,
 	struct mda_context *mdc = (struct mda_context *) mda->metadata_locn;
 	char mdah[MDA_HEADER_SIZE]; /* temporary */
 
-	if (!mdc || !_raw_read_mda_header((struct mda_header *)mdah, &mdc->area))
+	if (!mdc || !_raw_read_mda_header((struct mda_header *)mdah, &mdc->area, mda_is_primary(mda)))
 		return 1; /* pretend the MDA does not exist */
 
 	return config_make_nodes(cft, parent, NULL,
@@ -2314,7 +2315,7 @@ static int _text_pv_add_metadata_area(const struct format_type *fmt,
 		/* Wipe metadata area with zeroes. */
 		if (!dev_set(pv->dev, mda_start,
 			     (size_t) ((mda_size > wipe_size) ?  wipe_size : mda_size),
-			     DEV_IO_MDA_HEADER, 0)) {
+			     MDA_HEADER_REASON(!mda_index), 0)) {
 			log_error("Failed to wipe new metadata area "
 				  "at the %s of the %s",
 				   mda_index ? "end" : "start",
diff --git a/lib/format_text/import-export.h b/lib/format_text/import-export.h
index 2f39e2a..894d881 100644
--- a/lib/format_text/import-export.h
+++ b/lib/format_text/import-export.h
@@ -76,7 +76,7 @@ struct volume_group *text_vg_import_fd(struct format_instance *fid,
 				       struct cached_vg_fmtdata **vg_fmtdata,
 				       unsigned *use_previous_vg,
 				       int single_device,
-				       struct device *dev,
+				       struct device *dev, int primary_mda,
 				       off_t offset, uint32_t size,
 				       off_t offset2, uint32_t size2,
 				       checksum_fn_t checksum_fn,
@@ -84,7 +84,7 @@ struct volume_group *text_vg_import_fd(struct format_instance *fid,
 				       time_t *when, char **desc);
 
 int text_vgsummary_import(const struct format_type *fmt,
-		       struct device *dev,
+		       struct device *dev, dev_io_reason_t reason,
 		       off_t offset, uint32_t size,
 		       off_t offset2, uint32_t size2,
 		       checksum_fn_t checksum_fn,
diff --git a/lib/format_text/import.c b/lib/format_text/import.c
index 62dee8f..da4cefd 100644
--- a/lib/format_text/import.c
+++ b/lib/format_text/import.c
@@ -36,7 +36,7 @@ static void _init_text_import(void)
  * Find out vgname on a given device.
  */
 int text_vgsummary_import(const struct format_type *fmt,
-		       struct device *dev,
+		       struct device *dev, dev_io_reason_t reason,
 		       off_t offset, uint32_t size,
 		       off_t offset2, uint32_t size2,
 		       checksum_fn_t checksum_fn,
@@ -53,7 +53,7 @@ int text_vgsummary_import(const struct format_type *fmt,
 		return_0;
 
 	if ((!dev && !config_file_read(cft)) ||
-	    (dev && !config_file_read_fd(cft, dev, offset, size,
+	    (dev && !config_file_read_fd(cft, dev, reason, offset, size,
 					 offset2, size2, checksum_fn,
 					 vgsummary->mda_checksum,
 					 checksum_only, 1))) {
@@ -96,7 +96,7 @@ struct volume_group *text_vg_import_fd(struct format_instance *fid,
 				       struct cached_vg_fmtdata **vg_fmtdata,
 				       unsigned *use_previous_vg,
 				       int single_device,
-				       struct device *dev,
+				       struct device *dev, int primary_mda,
 				       off_t offset, uint32_t size,
 				       off_t offset2, uint32_t size2,
 				       checksum_fn_t checksum_fn,
@@ -128,7 +128,7 @@ struct volume_group *text_vg_import_fd(struct format_instance *fid,
 		     ((*vg_fmtdata)->cached_mda_size == (size + size2));
 
 	if ((!dev && !config_file_read(cft)) ||
-	    (dev && !config_file_read_fd(cft, dev, offset, size,
+	    (dev && !config_file_read_fd(cft, dev, MDA_CONTENT_REASON(primary_mda), offset, size,
 					 offset2, size2, checksum_fn, checksum,
 					 skip_parse, 1)))
 		goto_out;
@@ -170,7 +170,7 @@ struct volume_group *text_vg_import_file(struct format_instance *fid,
 					 const char *file,
 					 time_t *when, char **desc)
 {
-	return text_vg_import_fd(fid, file, NULL, NULL, 0, NULL, (off_t)0, 0, (off_t)0, 0, NULL, 0,
+	return text_vg_import_fd(fid, file, NULL, NULL, 0, NULL, 0, (off_t)0, 0, (off_t)0, 0, NULL, 0,
 				 when, desc);
 }
 
diff --git a/lib/format_text/layout.h b/lib/format_text/layout.h
index 75a935b..c88812f 100644
--- a/lib/format_text/layout.h
+++ b/lib/format_text/layout.h
@@ -81,7 +81,7 @@ struct mda_header {
 } __attribute__ ((packed));
 
 struct mda_header *raw_read_mda_header(const struct format_type *fmt,
-				       struct device_area *dev_area);
+				       struct device_area *dev_area, int primary_mda);
 
 struct mda_lists {
 	struct dm_list dirs;
@@ -103,7 +103,7 @@ struct mda_context {
 #define LVM2_LABEL "LVM2 001"
 #define MDA_SIZE_MIN (8 * (unsigned) lvm_getpagesize())
 
-int vgname_from_mda(const struct format_type *fmt, struct mda_header *mdah,
+int vgname_from_mda(const struct format_type *fmt, struct mda_header *mdah, int primary_mda, 
 		    struct device_area *dev_area, struct lvmcache_vgsummary *vgsummary,
 		    uint64_t *mda_free_sectors);
 
diff --git a/lib/format_text/text_label.c b/lib/format_text/text_label.c
index 6d9cfbd..c567709 100644
--- a/lib/format_text/text_label.c
+++ b/lib/format_text/text_label.c
@@ -245,9 +245,9 @@ int add_mda(const struct format_type *fmt, struct dm_pool *mem, struct dm_list *
 	    struct device *dev, uint64_t start, uint64_t size, unsigned ignored)
 {
 /* FIXME List size restricted by pv_header SECTOR_SIZE */
-	struct metadata_area *mdal;
+	struct metadata_area *mdal, *mda;
 	struct mda_lists *mda_lists = (struct mda_lists *) fmt->private;
-	struct mda_context *mdac;
+	struct mda_context *mdac, *mdac2;
 
 	if (!mem) {
 		if (!(mdal = dm_malloc(sizeof(struct metadata_area)))) {
@@ -274,13 +274,23 @@ int add_mda(const struct format_type *fmt, struct dm_pool *mem, struct dm_list *
 
 	mdal->ops = mda_lists->raw_ops;
 	mdal->metadata_locn = mdac;
-	mdal->status = 0;
 
 	mdac->area.dev = dev;
 	mdac->area.start = start;
 	mdac->area.size = size;
 	mdac->free_sectors = UINT64_C(0);
 	memset(&mdac->rlocn, 0, sizeof(mdac->rlocn));
+
+	/* Set MDA_PRIMARY only if this is the first metadata area on this device. */
+	mdal->status = MDA_PRIMARY;
+	dm_list_iterate_items(mda, mdas) {
+		mdac2 = mda->metadata_locn;
+		if (mdac2->area.dev == dev) {
+			mdal->status = 0;
+			break;
+		}
+	}
+
 	mda_set_ignored(mdal, ignored);
 
 	dm_list_add(mdas, &mdal->list);
@@ -334,7 +344,7 @@ static int _update_mda(struct metadata_area *mda, void *baton)
 		return 1;
 	}
 
-	if (!(mdah = raw_read_mda_header(fmt, &mdac->area))) {
+	if (!(mdah = raw_read_mda_header(fmt, &mdac->area, mda_is_primary(mda)))) {
 		stack;
 		goto close_dev;
 	}
@@ -350,7 +360,7 @@ static int _update_mda(struct metadata_area *mda, void *baton)
 		return 1;
 	}
 
-	if (vgname_from_mda(fmt, mdah, &mdac->area, &vgsummary,
+	if (vgname_from_mda(fmt, mdah, mda_is_primary(mda), &mdac->area, &vgsummary,
 			     &mdac->free_sectors) &&
 	    !lvmcache_update_vgname_and_id(p->info, &vgsummary)) {
 		if (!dev_close(mdac->area.dev))
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index 0de9ed8..3a4abc3 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -162,6 +162,13 @@ struct metadata_area_ops {
 #define MDA_INCONSISTENT 0x00000002
 #define MDA_FAILED       0x00000004
 
+/* The primary metadata area on a device if the format supports more than one. */
+#define MDA_PRIMARY	 0x00000008
+
+#define mda_is_primary(mda) (((mda->status) & MDA_PRIMARY) ? 1 : 0)
+#define MDA_CONTENT_REASON(primary_mda) ((primary_mda) ? DEV_IO_MDA_CONTENT : DEV_IO_MDA_EXTRA_CONTENT)
+#define MDA_HEADER_REASON(primary_mda)  ((primary_mda) ? DEV_IO_MDA_HEADER : DEV_IO_MDA_EXTRA_HEADER)
+
 struct metadata_area {
 	struct dm_list list;
 	struct metadata_area_ops *ops;


