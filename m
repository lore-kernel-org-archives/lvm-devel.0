From: David Teigland <teigland@sourceware.org>
Date: Mon, 23 Apr 2018 09:48:28 -0400
Subject: master - scan: use bcache for label scan and vg read
Message-ID: <201804231348.w3NDmSu1031463@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a7cb76ae94a90c89b86a810ceb4b6a91bab3441e
Commit:        a7cb76ae94a90c89b86a810ceb4b6a91bab3441e
Parent:        697fa7aa1dbcc2ed8e141d9d13118cb38d609161
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Feb 6 15:18:11 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 20 11:19:24 2018 -0500

scan: use bcache for label scan and vg read

New label_scan function populates bcache for each device
on the system.

The two read paths are updated to get data from bcache.

The bcache is not yet used for writing.  bcache blocks
for a device are invalidated when the device is written.
---
 lib/commands/toolcontext.c       |    2 +
 lib/config/config.c              |   10 +-
 lib/device/bcache.c              |    6 +-
 lib/device/device.h              |    1 +
 lib/format_text/archive.c        |    2 +-
 lib/format_text/archiver.c       |    2 +-
 lib/format_text/format-text.c    |  217 ++++++++------
 lib/format_text/import-export.h  |    8 +-
 lib/format_text/import.c         |   70 ++++--
 lib/format_text/import_vsn1.c    |   51 +---
 lib/format_text/layout.h         |    2 +-
 lib/format_text/text_label.c     |   15 +-
 lib/label/label.c                |  583 +++++++++++++++++++++++++++++---------
 lib/label/label.h                |   15 +-
 lib/metadata/metadata-exported.h |   13 +
 lib/metadata/metadata.c          |   12 +-
 lib/metadata/metadata.h          |    8 +-
 17 files changed, 713 insertions(+), 304 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index c998495..fe6b8a3 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -2124,6 +2124,7 @@ int refresh_toolcontext(struct cmd_context *cmd)
 
 	activation_release();
 	lvmcache_destroy(cmd, 0, 0);
+	label_scan_destroy(cmd);
 	label_exit();
 	_destroy_segtypes(&cmd->segtypes);
 	_destroy_formats(cmd, &cmd->formats);
@@ -2243,6 +2244,7 @@ void destroy_toolcontext(struct cmd_context *cmd)
 	archive_exit(cmd);
 	backup_exit(cmd);
 	lvmcache_destroy(cmd, 0, 0);
+	label_scan_destroy(cmd);
 	label_exit();
 	_destroy_segtypes(&cmd->segtypes);
 	_destroy_formats(cmd, &cmd->formats);
diff --git a/lib/config/config.c b/lib/config/config.c
index 8fca372..2d7db69 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -23,6 +23,7 @@
 #include "toolcontext.h"
 #include "lvm-file.h"
 #include "memlock.h"
+#include "label.h"
 
 #include <sys/stat.h>
 #include <sys/mman.h>
@@ -532,10 +533,15 @@ int config_file_read_fd(struct dm_config_tree *cft, struct device *dev, dev_io_r
 			log_error("Failed to allocate circular buffer.");
 			return 0;
 		}
-		if (!dev_read_circular(dev, (uint64_t) offset, size,
-				       (uint64_t) offset2, size2, reason, buf)) {
+
+		if (!bcache_read_bytes(scan_bcache, dev->fd, offset, size, buf))
 			goto out;
+
+		if (size2) {
+			if (!bcache_read_bytes(scan_bcache, dev->fd, offset2, size2, buf + size))
+				goto out;
 		}
+
 		fb = buf;
 	}
 
diff --git a/lib/device/bcache.c b/lib/device/bcache.c
index 5141083..38c909c 100644
--- a/lib/device/bcache.c
+++ b/lib/device/bcache.c
@@ -223,7 +223,11 @@ static bool _async_wait(struct io_engine *ioe, io_complete_fn fn)
 		else if ((int) ev->res < 0)
 			fn(cb->context, (int) ev->res);
 
-		else {
+		else if (ev->res >= (1 << SECTOR_SHIFT)) {
+			/* minimum acceptable read is 1 sector */
+			fn((void *) cb->context, 0);
+
+		} else {
 			log_warn("short io");
 			fn(cb->context, -ENODATA);
 		}
diff --git a/lib/device/device.h b/lib/device/device.h
index 503373f..d5eb00f 100644
--- a/lib/device/device.h
+++ b/lib/device/device.h
@@ -31,6 +31,7 @@
 #define DEV_USED_FOR_LV		0x00000100	/* Is device used for an LV */
 #define DEV_ASSUMED_FOR_LV	0x00000200	/* Is device assumed for an LV */
 #define DEV_NOT_O_NOATIME	0x00000400	/* Don't use O_NOATIME */
+#define DEV_IN_BCACHE		0x00000800      /* dev fd is open and used in bcache */
 
 /*
  * Support for external device info.
diff --git a/lib/format_text/archive.c b/lib/format_text/archive.c
index 72ec40b..690bc74 100644
--- a/lib/format_text/archive.c
+++ b/lib/format_text/archive.c
@@ -320,7 +320,7 @@ static void _display_archive(struct cmd_context *cmd, struct archive_file *af)
 	 * retrieve the archive time and description.
 	 */
 	/* FIXME Use variation on _vg_read */
-	if (!(vg = text_vg_import_file(tf, af->path, &when, &desc))) {
+	if (!(vg = text_read_metadata_file(tf, af->path, &when, &desc))) {
 		log_error("Unable to read archive file.");
 		tf->fmt->ops->destroy_instance(tf);
 		return;
diff --git a/lib/format_text/archiver.c b/lib/format_text/archiver.c
index 1eb6654..81b5da9 100644
--- a/lib/format_text/archiver.c
+++ b/lib/format_text/archiver.c
@@ -320,7 +320,7 @@ struct volume_group *backup_read_vg(struct cmd_context *cmd,
 	}
 
 	dm_list_iterate_items(mda, &tf->metadata_areas_in_use) {
-		if (!(vg = mda->ops->vg_read(tf, vg_name, mda, NULL, NULL, 0)))
+		if (!(vg = mda->ops->vg_read(tf, vg_name, mda, NULL, NULL)))
 			stack;
 		break;
 	}
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index be9a8b9..e9a34e6 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -317,47 +317,42 @@ static void _xlate_mdah(struct mda_header *mdah)
 
 static int _raw_read_mda_header(struct mda_header *mdah, struct device_area *dev_area, int primary_mda)
 {
-	if (!dev_open_readonly(dev_area->dev))
-		return_0;
+	log_debug_metadata("Reading mda header sector from %s at %llu",
+			   dev_name(dev_area->dev), (unsigned long long)dev_area->start);
 
-	if (!dev_read(dev_area->dev, dev_area->start, MDA_HEADER_SIZE, MDA_HEADER_REASON(primary_mda), mdah)) {
-		if (!dev_close(dev_area->dev))
-			stack;
-		return_0;
+	if (!bcache_read_bytes(scan_bcache, dev_area->dev->fd, dev_area->start, MDA_HEADER_SIZE, mdah)) {
+		log_error("Failed to read metadata area header on %s at %llu",
+			  dev_name(dev_area->dev), (unsigned long long)dev_area->start);
+		return 0;
 	}
 
-	if (!dev_close(dev_area->dev))
-		return_0;
-
 	if (mdah->checksum_xl != xlate32(calc_crc(INITIAL_CRC, (uint8_t *)mdah->magic,
 						  MDA_HEADER_SIZE -
 						  sizeof(mdah->checksum_xl)))) {
-		log_error("Incorrect metadata area header checksum on %s"
-			  " at offset " FMTu64, dev_name(dev_area->dev),
-			  dev_area->start);
+		log_error("Incorrect checksum in metadata area header on %s at %llu",
+			  dev_name(dev_area->dev), (unsigned long long)dev_area->start);
 		return 0;
 	}
 
 	_xlate_mdah(mdah);
 
 	if (strncmp((char *)mdah->magic, FMTT_MAGIC, sizeof(mdah->magic))) {
-		log_error("Wrong magic number in metadata area header on %s"
-			  " at offset " FMTu64, dev_name(dev_area->dev),
-			  dev_area->start);
+		log_error("Wrong magic number in metadata area header on %s at %llu",
+			  dev_name(dev_area->dev), (unsigned long long)dev_area->start);
 		return 0;
 	}
 
 	if (mdah->version != FMTT_VERSION) {
-		log_error("Incompatible metadata area header version: %d on %s"
-			  " at offset " FMTu64, mdah->version,
-			  dev_name(dev_area->dev), dev_area->start);
+		log_error("Incompatible version %u metadata area header on %s at %llu",
+			  mdah->version,
+			  dev_name(dev_area->dev), (unsigned long long)dev_area->start);
 		return 0;
 	}
 
 	if (mdah->start != dev_area->start) {
-		log_error("Incorrect start sector in metadata area header: "
-			  FMTu64 " on %s at offset " FMTu64, mdah->start,
-			  dev_name(dev_area->dev), dev_area->start);
+		log_error("Incorrect start sector %llu in metadata area header on %s at %llu",
+			  (unsigned long long)mdah->start,
+			  dev_name(dev_area->dev), (unsigned long long)dev_area->start);
 		return 0;
 	}
 
@@ -390,18 +385,33 @@ static int _raw_write_mda_header(const struct format_type *fmt,
 	mdah->version = FMTT_VERSION;
 	mdah->start = start_byte;
 
+	label_scan_invalidate(dev);
+
+	if (!dev_open(dev))
+		return_0;
+
 	_xlate_mdah(mdah);
 	mdah->checksum_xl = xlate32(calc_crc(INITIAL_CRC, (uint8_t *)mdah->magic,
 					     MDA_HEADER_SIZE -
 					     sizeof(mdah->checksum_xl)));
 
-	if (!dev_write(dev, start_byte, MDA_HEADER_SIZE, MDA_HEADER_REASON(primary_mda), mdah))
+	if (!dev_write(dev, start_byte, MDA_HEADER_SIZE, MDA_HEADER_REASON(primary_mda), mdah)) {
+		dev_close(dev);
 		return_0;
+	}
+
+	if (dev_close(dev))
+		stack;
 
 	return 1;
 }
 
-static struct raw_locn *_find_vg_rlocn(struct device_area *dev_area,
+/*
+ * FIXME: unify this with read_metadata_location() which is used
+ * in the label scanning path.
+ */
+
+static struct raw_locn *_read_metadata_location_vg(struct device_area *dev_area,
 				       struct mda_header *mdah, int primary_mda,
 				       const char *vgname,
 				       int *precommitted)
@@ -446,11 +456,13 @@ static struct raw_locn *_find_vg_rlocn(struct device_area *dev_area,
 	if (rlocn_was_ignored)
 		return rlocn;
 
-	/* FIXME Loop through rlocns two-at-a-time.  List null-terminated. */
-	/* FIXME Ignore if checksum incorrect!!! */
-	if (!dev_read(dev_area->dev, dev_area->start + rlocn->offset,
-		      sizeof(vgnamebuf), MDA_CONTENT_REASON(primary_mda), vgnamebuf))
-		goto_bad;
+	/*
+	 * Verify that the VG metadata pointed to by the rlocn
+	 * begins with a valid vgname.
+	 */
+	memset(vgnamebuf, 0, sizeof(vgnamebuf));
+
+	bcache_read_bytes(scan_bcache, dev_area->dev->fd, dev_area->start + rlocn->offset, NAME_LEN, vgnamebuf);
 
 	if (!strncmp(vgnamebuf, vgname, len = strlen(vgname)) &&
 	    (isspace(vgnamebuf[len]) || vgnamebuf[len] == '{'))
@@ -505,7 +517,7 @@ static int _raw_holds_vgname(struct format_instance *fid,
 	if (!(mdah = raw_read_mda_header(fid->fmt, dev_area, 0)))
 		return_0;
 
-	if (_find_vg_rlocn(dev_area, mdah, 0, vgname, &noprecommit))
+	if (_read_metadata_location_vg(dev_area, mdah, 0, vgname, &noprecommit))
 		r = 1;
 
 	if (!dev_close(dev_area->dev))
@@ -520,7 +532,7 @@ static struct volume_group *_vg_read_raw_area(struct format_instance *fid,
 					      struct cached_vg_fmtdata **vg_fmtdata,
 					      unsigned *use_previous_vg,
 					      int precommitted,
-					      int single_device, int primary_mda)
+					      int primary_mda)
 {
 	struct volume_group *vg = NULL;
 	struct raw_locn *rlocn;
@@ -532,7 +544,7 @@ static struct volume_group *_vg_read_raw_area(struct format_instance *fid,
 	if (!(mdah = raw_read_mda_header(fid->fmt, area, primary_mda)))
 		goto_out;
 
-	if (!(rlocn = _find_vg_rlocn(area, mdah, primary_mda, vgname, &precommitted))) {
+	if (!(rlocn = _read_metadata_location_vg(area, mdah, primary_mda, vgname, &precommitted))) {
 		log_debug_metadata("VG %s not found on %s", vgname, dev_name(area->dev));
 		goto out;
 	}
@@ -546,26 +558,25 @@ static struct volume_group *_vg_read_raw_area(struct format_instance *fid,
 		goto out;
 	}
 
-	/* FIXME 64-bit */
-	if (!(vg = text_vg_import_fd(fid, NULL, vg_fmtdata, use_previous_vg, single_device, area->dev, 
-				     primary_mda,
-				     (off_t) (area->start + rlocn->offset),
-				     (uint32_t) (rlocn->size - wrap),
-				     (off_t) (area->start + MDA_HEADER_SIZE),
-				     wrap, calc_crc, rlocn->checksum, &when,
-				     &desc)) && (!use_previous_vg || !*use_previous_vg))
-		goto_out;
+	vg = text_read_metadata(fid, NULL, vg_fmtdata, use_previous_vg, area->dev, primary_mda,
+				(off_t) (area->start + rlocn->offset),
+				(uint32_t) (rlocn->size - wrap),
+				(off_t) (area->start + MDA_HEADER_SIZE),
+				wrap,
+				calc_crc,
+				rlocn->checksum,
+				&when, &desc);
 
-	if (vg)
-		log_debug_metadata("Read %s %smetadata (%u) from %s at " FMTu64 " size "
-				   FMTu64, vg->name, precommitted ? "pre-commit " : "",
-				   vg->seqno, dev_name(area->dev),
-				   area->start + rlocn->offset, rlocn->size);
-	else
-		log_debug_metadata("Skipped reading %smetadata from %s at " FMTu64 " size "
-				   FMTu64 " with matching checksum.", precommitted ? "pre-commit " : "",
-				   dev_name(area->dev),
-				   area->start + rlocn->offset, rlocn->size);
+	if (!vg) {
+		/* FIXME: detect and handle errors, and distinguish from the optimization
+		   that skips parsing the metadata which also returns NULL. */
+	}
+
+	log_debug_metadata("Found metadata on %s at %"FMTu64" size %"FMTu64" for VG %s",
+			   dev_name(area->dev),
+			   area->start + rlocn->offset,
+			   rlocn->size,
+			   vgname);
 
 	if (vg && precommitted)
 		vg->status |= PRECOMMITTED;
@@ -578,8 +589,7 @@ static struct volume_group *_vg_read_raw(struct format_instance *fid,
 					 const char *vgname,
 					 struct metadata_area *mda,
 					 struct cached_vg_fmtdata **vg_fmtdata,
-					 unsigned *use_previous_vg,
-					 int single_device)
+					 unsigned *use_previous_vg)
 {
 	struct mda_context *mdac = (struct mda_context *) mda->metadata_locn;
 	struct volume_group *vg;
@@ -587,7 +597,7 @@ static struct volume_group *_vg_read_raw(struct format_instance *fid,
 	if (!dev_open_readonly(mdac->area.dev))
 		return_NULL;
 
-	vg = _vg_read_raw_area(fid, vgname, &mdac->area, vg_fmtdata, use_previous_vg, 0, single_device, mda_is_primary(mda));
+	vg = _vg_read_raw_area(fid, vgname, &mdac->area, vg_fmtdata, use_previous_vg, 0, mda_is_primary(mda));
 
 	if (!dev_close(mdac->area.dev))
 		stack;
@@ -607,7 +617,7 @@ static struct volume_group *_vg_read_precommit_raw(struct format_instance *fid,
 	if (!dev_open_readonly(mdac->area.dev))
 		return_NULL;
 
-	vg = _vg_read_raw_area(fid, vgname, &mdac->area, vg_fmtdata, use_previous_vg, 1, 0, mda_is_primary(mda));
+	vg = _vg_read_raw_area(fid, vgname, &mdac->area, vg_fmtdata, use_previous_vg, 1, mda_is_primary(mda));
 
 	if (!dev_close(mdac->area.dev))
 		stack;
@@ -655,7 +665,7 @@ static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 		goto out;
 	}
 
-	rlocn = _find_vg_rlocn(&mdac->area, mdah, mda_is_primary(mda), old_vg_name ? : vg->name, &noprecommit);
+	rlocn = _read_metadata_location_vg(&mdac->area, mdah, mda_is_primary(mda), old_vg_name ? : vg->name, &noprecommit);
 
 	mdac->rlocn.offset = _next_rlocn_offset(rlocn, mdah, mdac->area.start, MDA_ORIGINAL_ALIGNMENT);
 	mdac->rlocn.size = fidtc->raw_metadata_buf_size;
@@ -681,6 +691,8 @@ static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 			    vg->name, dev_name(mdac->area.dev), mdac->area.start +
 			    mdac->rlocn.offset, mdac->rlocn.size - new_wrap, mdac->rlocn.size);
 
+	label_scan_invalidate(mdac->area.dev);
+
 	/* Write text out, circularly */
 	if (!dev_write(mdac->area.dev, mdac->area.start + mdac->rlocn.offset,
 		       (size_t) (mdac->rlocn.size - new_wrap), MDA_CONTENT_REASON(mda_is_primary(mda)),
@@ -752,7 +764,7 @@ static int _vg_commit_raw_rlocn(struct format_instance *fid,
 	if (!(mdah = raw_read_mda_header(fid->fmt, &mdac->area, mda_is_primary(mda))))
 		goto_out;
 
-	if (!(rlocn = _find_vg_rlocn(&mdac->area, mdah, mda_is_primary(mda), old_vg_name ? : vg->name, &noprecommit))) {
+	if (!(rlocn = _read_metadata_location_vg(&mdac->area, mdah, mda_is_primary(mda), old_vg_name ? : vg->name, &noprecommit))) {
 		mdah->raw_locns[0].offset = 0;
 		mdah->raw_locns[0].size = 0;
 		mdah->raw_locns[0].checksum = 0;
@@ -872,7 +884,7 @@ static int _vg_remove_raw(struct format_instance *fid, struct volume_group *vg,
 	if (!(mdah = raw_read_mda_header(fid->fmt, &mdac->area, mda_is_primary(mda))))
 		goto_out;
 
-	if (!(rlocn = _find_vg_rlocn(&mdac->area, mdah, mda_is_primary(mda), vg->name, &noprecommit))) {
+	if (!(rlocn = _read_metadata_location_vg(&mdac->area, mdah, mda_is_primary(mda), vg->name, &noprecommit))) {
 		rlocn = &mdah->raw_locns[0];
 		mdah->raw_locns[1].offset = 0;
 	}
@@ -906,8 +918,10 @@ static struct volume_group *_vg_read_file_name(struct format_instance *fid,
 	time_t when;
 	char *desc;
 
-	if (!(vg = text_vg_import_file(fid, read_path, &when, &desc)))
-		return_NULL;
+	if (!(vg = text_read_metadata_file(fid, read_path, &when, &desc))) {
+		log_error("Failed to read VG %s from %s", vgname, read_path);
+		return NULL;
+	}
 
 	/*
 	 * Currently you can only have a single volume group per
@@ -931,8 +945,7 @@ static struct volume_group *_vg_read_file(struct format_instance *fid,
 					  const char *vgname,
 					  struct metadata_area *mda,
 					  struct cached_vg_fmtdata **vg_fmtdata,
-					  unsigned *use_previous_vg __attribute__((unused)),
-					  int single_device __attribute__((unused)))
+					  unsigned *use_previous_vg __attribute__((unused)))
 {
 	struct text_context *tc = (struct text_context *) mda->metadata_locn;
 
@@ -1175,7 +1188,7 @@ static int _scan_file(const struct format_type *fmt, const char *vgname)
 	return 1;
 }
 
-int vgname_from_mda(const struct format_type *fmt,
+int read_metadata_location_summary(const struct format_type *fmt,
 		    struct mda_header *mdah, int primary_mda, struct device_area *dev_area,
 		    struct lvmcache_vgsummary *vgsummary, uint64_t *mda_free_sectors)
 {
@@ -1184,13 +1197,12 @@ int vgname_from_mda(const struct format_type *fmt,
 	unsigned int len = 0;
 	char buf[NAME_LEN + 1] __attribute__((aligned(8)));
 	uint64_t buffer_size, current_usage;
-	unsigned used_cached_metadata = 0;
 
 	if (mda_free_sectors)
 		*mda_free_sectors = ((dev_area->size - MDA_HEADER_SIZE) / 2) >> SECTOR_SHIFT;
 
 	if (!mdah) {
-		log_error(INTERNAL_ERROR "vgname_from_mda called with NULL pointer for mda_header");
+		log_error(INTERNAL_ERROR "read_metadata_location_summary called with NULL pointer for mda_header");
 		return 0;
 	}
 
@@ -1201,15 +1213,12 @@ int vgname_from_mda(const struct format_type *fmt,
 	 * If no valid offset, do not try to search for vgname
 	 */
 	if (!rlocn->offset) {
-		log_debug("%s: found metadata with offset 0.",
-			  dev_name(dev_area->dev));
+		log_debug_metadata("Metadata location on %s at %"FMTu64" has offset 0.",
+				   dev_name(dev_area->dev), dev_area->start + rlocn->offset);
 		return 0;
 	}
 
-	/* Do quick check for a vgname */
-	if (!dev_read(dev_area->dev, dev_area->start + rlocn->offset,
-		      NAME_LEN, MDA_CONTENT_REASON(primary_mda), buf))
-		return_0;
+	bcache_read_bytes(scan_bcache, dev_area->dev->fd, dev_area->start + rlocn->offset, NAME_LEN, buf);
 
 	while (buf[len] && !isspace(buf[len]) && buf[len] != '{' &&
 	       len < (NAME_LEN - 1))
@@ -1218,47 +1227,66 @@ int vgname_from_mda(const struct format_type *fmt,
 	buf[len] = '\0';
 
 	/* Ignore this entry if the characters aren't permissible */
-	if (!validate_name(buf))
+	if (!validate_name(buf)) {
+		log_error("Metadata location on %s@%"FMTu64" begins with invalid VG name.",
+			  dev_name(dev_area->dev), dev_area->start + rlocn->offset);
 		return_0;
+	}
 
 	/* We found a VG - now check the metadata */
 	if (rlocn->offset + rlocn->size > mdah->size)
 		wrap = (uint32_t) ((rlocn->offset + rlocn->size) - mdah->size);
 
 	if (wrap > rlocn->offset) {
-		log_error("%s: metadata (" FMTu64 " bytes) too large for circular buffer (" FMTu64 " bytes)",
-			  dev_name(dev_area->dev), rlocn->size, mdah->size - MDA_HEADER_SIZE);
+		log_error("Metadata location on %s at %"FMTu64" is too large for circular buffer.",
+			  dev_name(dev_area->dev), dev_area->start + rlocn->offset);
 		return 0;
 	}
 
-	/* Did we see this metadata before? */
+	/*
+	 * Did we see this metadata before?
+	 * Look in lvmcache to see if there is vg info matching
+	 * the checksum/size that we see in the mda_header (rlocn)
+	 * on this device.  If so, then vgsummary->name is is set
+	 * and controls if the "checksum_only" flag passed to
+	 * text_read_metadata_summary() is 1 or 0.
+	 *
+	 * If checksum_only = 1, then text_read_metadata_summary()
+	 * will read the metadata from this device, and run the
+	 * checksum function on it.  If the calculated checksum
+	 * of the metadata matches the checksum in the mda_header,
+	 * which also matches the checksum saved in vginfo from
+	 * another device, then it skips parsing the metadata into
+	 * a config tree, which saves considerable cpu time.
+	 */
+
 	vgsummary->mda_checksum = rlocn->checksum;
 	vgsummary->mda_size = rlocn->size;
+	lvmcache_lookup_mda(vgsummary);
 
-	if (lvmcache_lookup_mda(vgsummary))
-		used_cached_metadata = 1;
-
-	/* FIXME 64-bit */
-	if (!text_vgsummary_import(fmt, dev_area->dev, MDA_CONTENT_REASON(primary_mda),
+	if (!text_read_metadata_summary(fmt, dev_area->dev, MDA_CONTENT_REASON(primary_mda),
 				(off_t) (dev_area->start + rlocn->offset),
 				(uint32_t) (rlocn->size - wrap),
 				(off_t) (dev_area->start + MDA_HEADER_SIZE),
 				wrap, calc_crc, vgsummary->vgname ? 1 : 0,
-				vgsummary))
-		return_0;
+				vgsummary)) {
+		log_error("Metadata location on %s at %"FMTu64" has invalid summary for VG.",
+			  dev_name(dev_area->dev), dev_area->start + rlocn->offset);
+		return 0;
+	}
 
 	/* Ignore this entry if the characters aren't permissible */
-	if (!validate_name(vgsummary->vgname))
-		return_0;
+	if (!validate_name(vgsummary->vgname)) {
+		log_error("Metadata location on %s at %"FMTu64" has invalid VG name.",
+			  dev_name(dev_area->dev), dev_area->start + rlocn->offset);
+		return 0;
+	}
 
-	log_debug_metadata("%s: %s metadata at " FMTu64 " size " FMTu64
-			   " (in area at " FMTu64 " size " FMTu64
-			   ") for %s (" FMTVGID ")",
+	log_debug_metadata("Found metadata summary on %s at %"FMTu64" size %"FMTu64" for VG %s",
 			   dev_name(dev_area->dev),
-			   used_cached_metadata ? "Using cached" : "Found",
 			   dev_area->start + rlocn->offset,
-			   rlocn->size, dev_area->start, dev_area->size, vgsummary->vgname,
-			   (char *)&vgsummary->vgid);
+			   rlocn->size,
+			   vgsummary->vgname);
 
 	if (mda_free_sectors) {
 		current_usage = (rlocn->size + SECTOR_SIZE - UINT64_C(1)) -
@@ -1301,8 +1329,7 @@ static int _scan_raw(const struct format_type *fmt, const char *vgname __attribu
 			goto close_dev;
 		}
 
-		/* TODO: caching as in vgname_from_mda() (trigger this code?) */
-		if (vgname_from_mda(fmt, mdah, 0, &rl->dev_area, &vgsummary, NULL)) {
+		if (read_metadata_location_summary(fmt, mdah, 0, &rl->dev_area, &vgsummary, NULL)) {
 			vg = _vg_read_raw_area(&fid, vgsummary.vgname, &rl->dev_area, NULL, NULL, 0, 0, 0);
 			if (vg)
 				lvmcache_update_vg(vg, 0);
@@ -1776,7 +1803,13 @@ static int _mda_export_text_raw(struct metadata_area *mda,
 	struct mda_context *mdc = (struct mda_context *) mda->metadata_locn;
 	char mdah[MDA_HEADER_SIZE]; /* temporary */
 
-	if (!mdc || !_raw_read_mda_header((struct mda_header *)mdah, &mdc->area, mda_is_primary(mda)))
+	if (!mdc) {
+		log_error(INTERNAL_ERROR "mda_export_text_raw no mdc");
+		return 1; /* pretend the MDA does not exist */
+	}
+
+	/* FIXME: why aren't ignore,start,size,free_sectors available? */
+	if (!_raw_read_mda_header((struct mda_header *)mdah, &mdc->area, mda_is_primary(mda)))
 		return 1; /* pretend the MDA does not exist */
 
 	return config_make_nodes(cft, parent, NULL,
diff --git a/lib/format_text/import-export.h b/lib/format_text/import-export.h
index 894d881..920eb3e 100644
--- a/lib/format_text/import-export.h
+++ b/lib/format_text/import-export.h
@@ -49,7 +49,6 @@ struct text_vg_version_ops {
 	int (*check_version) (const struct dm_config_tree * cf);
 	struct volume_group *(*read_vg) (struct format_instance * fid,
 					 const struct dm_config_tree *cf,
-					 unsigned use_cached_pvs,
 					 unsigned allow_lvmetad_extensions);
 	void (*read_desc) (struct dm_pool * mem, const struct dm_config_tree *cf,
 			   time_t *when, char **desc);
@@ -68,14 +67,13 @@ int read_segtype_lvflags(uint64_t *status, char *segtype_str);
 
 int text_vg_export_file(struct volume_group *vg, const char *desc, FILE *fp);
 size_t text_vg_export_raw(struct volume_group *vg, const char *desc, char **buf);
-struct volume_group *text_vg_import_file(struct format_instance *fid,
+struct volume_group *text_read_metadata_file(struct format_instance *fid,
 					 const char *file,
 					 time_t *when, char **desc);
-struct volume_group *text_vg_import_fd(struct format_instance *fid,
+struct volume_group *text_read_metadata(struct format_instance *fid,
 				       const char *file,
 				       struct cached_vg_fmtdata **vg_fmtdata,
 				       unsigned *use_previous_vg,
-				       int single_device,
 				       struct device *dev, int primary_mda,
 				       off_t offset, uint32_t size,
 				       off_t offset2, uint32_t size2,
@@ -83,7 +81,7 @@ struct volume_group *text_vg_import_fd(struct format_instance *fid,
 				       uint32_t checksum,
 				       time_t *when, char **desc);
 
-int text_vgsummary_import(const struct format_type *fmt,
+int text_read_metadata_summary(const struct format_type *fmt,
 		       struct device *dev, dev_io_reason_t reason,
 		       off_t offset, uint32_t size,
 		       off_t offset2, uint32_t size2,
diff --git a/lib/format_text/import.c b/lib/format_text/import.c
index da4cefd..4b34485 100644
--- a/lib/format_text/import.c
+++ b/lib/format_text/import.c
@@ -35,7 +35,7 @@ static void _init_text_import(void)
 /*
  * Find out vgname on a given device.
  */
-int text_vgsummary_import(const struct format_type *fmt,
+int text_read_metadata_summary(const struct format_type *fmt,
 		       struct device *dev, dev_io_reason_t reason,
 		       off_t offset, uint32_t size,
 		       off_t offset2, uint32_t size2,
@@ -52,17 +52,29 @@ int text_vgsummary_import(const struct format_type *fmt,
 	if (!(cft = config_open(CONFIG_FILE_SPECIAL, NULL, 0)))
 		return_0;
 
-	if ((!dev && !config_file_read(cft)) ||
-	    (dev && !config_file_read_fd(cft, dev, reason, offset, size,
+	if (dev) {
+		log_debug_metadata("Reading metadata summary from %s at %llu size %d (+%d)",
+				   dev_name(dev), (unsigned long long)offset,
+				   size, size2);
+
+		if (!config_file_read_fd(cft, dev, reason, offset, size,
 					 offset2, size2, checksum_fn,
 					 vgsummary->mda_checksum,
-					 checksum_only, 1))) {
-		log_error("Couldn't read volume group metadata.");
-		goto out;
+					 checksum_only, 1)) {
+			/* FIXME: handle errors */
+			log_error("Couldn't read volume group metadata from %s.", dev_name(dev));
+			goto out;
+		}
+	} else {
+		if (!config_file_read(cft)) {
+			log_error("Couldn't read volume group metadata from file.");
+			goto out;
+		}
 	}
 
 	if (checksum_only) {
 		/* Checksum matches already-cached content - no need to reparse. */
+		log_debug_metadata("Skipped parsing metadata on %s", dev_name(dev));
 		r = 1;
 		goto out;
 	}
@@ -91,11 +103,10 @@ struct cached_vg_fmtdata {
         size_t cached_mda_size;
 };
 
-struct volume_group *text_vg_import_fd(struct format_instance *fid,
+struct volume_group *text_read_metadata(struct format_instance *fid,
 				       const char *file,
 				       struct cached_vg_fmtdata **vg_fmtdata,
 				       unsigned *use_previous_vg,
-				       int single_device,
 				       struct device *dev, int primary_mda,
 				       off_t offset, uint32_t size,
 				       off_t offset2, uint32_t size2,
@@ -108,6 +119,15 @@ struct volume_group *text_vg_import_fd(struct format_instance *fid,
 	struct text_vg_version_ops **vsn;
 	int skip_parse;
 
+	/*
+	 * This struct holds the checksum and size of the VG metadata
+	 * that was read from a previous device.  When we read the VG
+	 * metadata from this device, we can skip parsing it into a
+	 * cft (saving time) if the checksum of the metadata buffer
+	 * we read from this device matches the size/checksum saved in
+	 * the mda_header/rlocn struct on this device, and matches the
+	 * size/checksum from the previous device.
+	 */
 	if (vg_fmtdata && !*vg_fmtdata &&
 	    !(*vg_fmtdata = dm_pool_zalloc(fid->mem, sizeof(**vg_fmtdata)))) {
 		log_error("Failed to allocate VG fmtdata for text format.");
@@ -127,15 +147,30 @@ struct volume_group *text_vg_import_fd(struct format_instance *fid,
 		     ((*vg_fmtdata)->cached_mda_checksum == checksum) &&
 		     ((*vg_fmtdata)->cached_mda_size == (size + size2));
 
-	if ((!dev && !config_file_read(cft)) ||
-	    (dev && !config_file_read_fd(cft, dev, MDA_CONTENT_REASON(primary_mda), offset, size,
+
+	if (dev) {
+		log_debug_metadata("Reading metadata from %s at %llu size %d (+%d)",
+				   dev_name(dev), (unsigned long long)offset,
+				   size, size2);
+
+		if (!config_file_read_fd(cft, dev, MDA_CONTENT_REASON(primary_mda), offset, size,
 					 offset2, size2, checksum_fn, checksum,
-					 skip_parse, 1)))
-		goto_out;
+					 skip_parse, 1)) {
+			/* FIXME: handle errors */
+			log_error("Couldn't read volume group metadata from %s.", dev_name(dev));
+			goto out;
+		}
+	} else {
+		if (!config_file_read(cft)) {
+			log_error("Couldn't read volume group metadata from file.");
+			goto out;
+		}
+	}
 
 	if (skip_parse) {
 		if (use_previous_vg)
 			*use_previous_vg = 1;
+		log_debug_metadata("Skipped parsing metadata on %s", dev_name(dev));
 		goto out;
 	}
 
@@ -146,7 +181,7 @@ struct volume_group *text_vg_import_fd(struct format_instance *fid,
 		if (!(*vsn)->check_version(cft))
 			continue;
 
-		if (!(vg = (*vsn)->read_vg(fid, cft, single_device, 0)))
+		if (!(vg = (*vsn)->read_vg(fid, cft, 0)))
 			goto_out;
 
 		(*vsn)->read_desc(vg->vgmem, cft, when, desc);
@@ -166,12 +201,13 @@ struct volume_group *text_vg_import_fd(struct format_instance *fid,
 	return vg;
 }
 
-struct volume_group *text_vg_import_file(struct format_instance *fid,
+struct volume_group *text_read_metadata_file(struct format_instance *fid,
 					 const char *file,
 					 time_t *when, char **desc)
 {
-	return text_vg_import_fd(fid, file, NULL, NULL, 0, NULL, 0, (off_t)0, 0, (off_t)0, 0, NULL, 0,
-				 when, desc);
+	return text_read_metadata(fid, file, NULL, NULL, NULL, 0,
+				  (off_t)0, 0, (off_t)0, 0, NULL, 0,
+				  when, desc);
 }
 
 static struct volume_group *_import_vg_from_config_tree(const struct dm_config_tree *cft,
@@ -191,7 +227,7 @@ static struct volume_group *_import_vg_from_config_tree(const struct dm_config_t
 		 * The only path to this point uses cached vgmetadata,
 		 * so it can use cached PV state too.
 		 */
-		if (!(vg = (*vsn)->read_vg(fid, cft, 1, allow_lvmetad_extensions)))
+		if (!(vg = (*vsn)->read_vg(fid, cft, allow_lvmetad_extensions)))
 			stack;
 		else if ((vg_missing = vg_missing_pv_count(vg))) {
 			log_verbose("There are %d physical volumes missing.",
diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index 9267d45..d51397a 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -32,9 +32,7 @@ typedef int (*section_fn) (struct format_instance * fid,
 			   struct volume_group * vg, const struct dm_config_node * pvn,
 			   const struct dm_config_node * vgn,
 			   struct dm_hash_table * pv_hash,
-			   struct dm_hash_table * lv_hash,
-			   unsigned *scan_done_once,
-			   unsigned report_missing_devices);
+			   struct dm_hash_table * lv_hash);
 
 #define _read_int32(root, path, result) \
 	dm_config_get_uint32(root, path, (uint32_t *) (result))
@@ -180,9 +178,7 @@ static int _read_pv(struct format_instance *fid,
 		    struct volume_group *vg, const struct dm_config_node *pvn,
 		    const struct dm_config_node *vgn __attribute__((unused)),
 		    struct dm_hash_table *pv_hash,
-		    struct dm_hash_table *lv_hash __attribute__((unused)),
-		    unsigned *scan_done_once,
-		    unsigned report_missing_devices)
+		    struct dm_hash_table *lv_hash __attribute__((unused)))
 {
 	struct dm_pool *mem = vg->vgmem;
 	struct physical_volume *pv;
@@ -226,10 +222,7 @@ static int _read_pv(struct format_instance *fid,
 
 		if (!id_write_format(&pv->id, buffer, sizeof(buffer)))
 			buffer[0] = '\0';
-		if (report_missing_devices)
-			log_error_once("Couldn't find device with uuid %s.", buffer);
-		else
-			log_very_verbose("Couldn't find device with uuid %s.", buffer);
+		log_error_once("Couldn't find device with uuid %s.", buffer);
 	}
 
 	if (!(pv->vg_name = dm_pool_strdup(mem, vg->name)))
@@ -574,9 +567,7 @@ static int _read_lvnames(struct format_instance *fid __attribute__((unused)),
 			 struct volume_group *vg, const struct dm_config_node *lvn,
 			 const struct dm_config_node *vgn __attribute__((unused)),
 			 struct dm_hash_table *pv_hash __attribute__((unused)),
-			 struct dm_hash_table *lv_hash,
-			 unsigned *scan_done_once __attribute__((unused)),
-			 unsigned report_missing_devices __attribute__((unused)))
+			 struct dm_hash_table *lv_hash)
 {
 	struct dm_pool *mem = vg->vgmem;
 	struct logical_volume *lv;
@@ -731,9 +722,7 @@ static int _read_historical_lvnames(struct format_instance *fid __attribute__((u
 				     struct volume_group *vg, const struct dm_config_node *hlvn,
 				     const struct dm_config_node *vgn __attribute__((unused)),
 				     struct dm_hash_table *pv_hash __attribute__((unused)),
-				     struct dm_hash_table *lv_hash __attribute__((unused)),
-				     unsigned *scan_done_once __attribute__((unused)),
-				     unsigned report_missing_devices __attribute__((unused)))
+				     struct dm_hash_table *lv_hash __attribute__((unused)))
 {
 	struct dm_pool *mem = vg->vgmem;
 	struct generic_logical_volume *glv;
@@ -802,9 +791,7 @@ static int _read_historical_lvnames_interconnections(struct format_instance *fid
 						 struct volume_group *vg, const struct dm_config_node *hlvn,
 						 const struct dm_config_node *vgn __attribute__((unused)),
 						 struct dm_hash_table *pv_hash __attribute__((unused)),
-						 struct dm_hash_table *lv_hash __attribute__((unused)),
-						 unsigned *scan_done_once __attribute__((unused)),
-						 unsigned report_missing_devices __attribute__((unused)))
+						 struct dm_hash_table *lv_hash __attribute__((unused)))
 {
 	struct dm_pool *mem = vg->vgmem;
 	const char *historical_lv_name, *origin_name = NULL;
@@ -914,9 +901,7 @@ static int _read_lvsegs(struct format_instance *fid,
 			struct volume_group *vg, const struct dm_config_node *lvn,
 			const struct dm_config_node *vgn __attribute__((unused)),
 			struct dm_hash_table *pv_hash,
-			struct dm_hash_table *lv_hash,
-			unsigned *scan_done_once __attribute__((unused)),
-			unsigned report_missing_devices __attribute__((unused)))
+			struct dm_hash_table *lv_hash)
 {
 	struct logical_volume *lv;
 
@@ -977,12 +962,9 @@ static int _read_sections(struct format_instance *fid,
 			  struct volume_group *vg, const struct dm_config_node *vgn,
 			  struct dm_hash_table *pv_hash,
 			  struct dm_hash_table *lv_hash,
-			  int optional,
-			  unsigned *scan_done_once)
+			  int optional)
 {
 	const struct dm_config_node *n;
-	/* Only report missing devices when doing a scan */
-	unsigned report_missing_devices = scan_done_once ? !*scan_done_once : 1;
 
 	if (!dm_config_get_section(vgn, section, &n)) {
 		if (!optional) {
@@ -994,8 +976,7 @@ static int _read_sections(struct format_instance *fid,
 	}
 
 	for (n = n->child; n; n = n->sib) {
-		if (!fn(fid, vg, n, vgn, pv_hash, lv_hash,
-			scan_done_once, report_missing_devices))
+		if (!fn(fid, vg, n, vgn, pv_hash, lv_hash))
 			return_0;
 	}
 
@@ -1004,7 +985,6 @@ static int _read_sections(struct format_instance *fid,
 
 static struct volume_group *_read_vg(struct format_instance *fid,
 				     const struct dm_config_tree *cft,
-				     unsigned use_cached_pvs,
 				     unsigned allow_lvmetad_extensions)
 {
 	const struct dm_config_node *vgn;
@@ -1012,7 +992,6 @@ static struct volume_group *_read_vg(struct format_instance *fid,
 	const char *str, *format_str, *system_id;
 	struct volume_group *vg;
 	struct dm_hash_table *pv_hash = NULL, *lv_hash = NULL;
-	unsigned scan_done_once = use_cached_pvs;
 	uint64_t vgstatus;
 
 	/* skip any top-level values */
@@ -1167,7 +1146,7 @@ static struct volume_group *_read_vg(struct format_instance *fid,
 	}
 
 	if (!_read_sections(fid, "physical_volumes", _read_pv, vg,
-			    vgn, pv_hash, lv_hash, 0, &scan_done_once)) {
+			    vgn, pv_hash, lv_hash, 0)) {
 		log_error("Couldn't find all physical volumes for volume "
 			  "group %s.", vg->name);
 		goto bad;
@@ -1175,7 +1154,7 @@ static struct volume_group *_read_vg(struct format_instance *fid,
 
 	if (allow_lvmetad_extensions)
 		_read_sections(fid, "outdated_pvs", _read_pv, vg,
-			       vgn, pv_hash, lv_hash, 1, &scan_done_once);
+			       vgn, pv_hash, lv_hash, 1);
 	else if (dm_config_has_node(vgn, "outdated_pvs"))
 		log_error(INTERNAL_ERROR "Unexpected outdated_pvs section in metadata of VG %s.", vg->name);
 
@@ -1187,28 +1166,28 @@ static struct volume_group *_read_vg(struct format_instance *fid,
 	}
 
 	if (!_read_sections(fid, "logical_volumes", _read_lvnames, vg,
-			    vgn, pv_hash, lv_hash, 1, NULL)) {
+			    vgn, pv_hash, lv_hash, 1)) {
 		log_error("Couldn't read all logical volume names for volume "
 			  "group %s.", vg->name);
 		goto bad;
 	}
 
 	if (!_read_sections(fid, "historical_logical_volumes", _read_historical_lvnames, vg,
-			    vgn, pv_hash, lv_hash, 1, NULL)) {
+			    vgn, pv_hash, lv_hash, 1)) {
 		log_error("Couldn't read all historical logical volumes for volume "
 			  "group %s.", vg->name);
 		goto bad;
 	}
 
 	if (!_read_sections(fid, "logical_volumes", _read_lvsegs, vg,
-			    vgn, pv_hash, lv_hash, 1, NULL)) {
+			    vgn, pv_hash, lv_hash, 1)) {
 		log_error("Couldn't read all logical volumes for "
 			  "volume group %s.", vg->name);
 		goto bad;
 	}
 
 	if (!_read_sections(fid, "historical_logical_volumes", _read_historical_lvnames_interconnections,
-			    vg, vgn, pv_hash, lv_hash, 1, NULL)) {
+			    vg, vgn, pv_hash, lv_hash, 1)) {
 		log_error("Couldn't read all removed logical volume interconnections "
 			  "for volume group %s.", vg->name);
 		goto bad;
diff --git a/lib/format_text/layout.h b/lib/format_text/layout.h
index 1746b9c..2671bbf 100644
--- a/lib/format_text/layout.h
+++ b/lib/format_text/layout.h
@@ -104,7 +104,7 @@ struct mda_context {
 #define MDA_SIZE_MIN (8 * (unsigned) lvm_getpagesize())
 #define MDA_ORIGINAL_ALIGNMENT 512	/* Original alignment used for start of VG metadata content */
 
-int vgname_from_mda(const struct format_type *fmt, struct mda_header *mdah, int primary_mda, 
+int read_metadata_location_summary(const struct format_type *fmt, struct mda_header *mdah, int primary_mda, 
 		    struct device_area *dev_area, struct lvmcache_vgsummary *vgsummary,
 		    uint64_t *mda_free_sectors);
 
diff --git a/lib/format_text/text_label.c b/lib/format_text/text_label.c
index 7058f70..1c322dd 100644
--- a/lib/format_text/text_label.c
+++ b/lib/format_text/text_label.c
@@ -323,7 +323,7 @@ struct _update_mda_baton {
 	struct label *label;
 };
 
-static int _update_mda(struct metadata_area *mda, void *baton)
+static int _read_mda_header_and_metadata(struct metadata_area *mda, void *baton)
 {
 	struct _update_mda_baton *p = baton;
 	const struct format_type *fmt = p->label->labeller->fmt;
@@ -360,7 +360,7 @@ static int _update_mda(struct metadata_area *mda, void *baton)
 		return 1;
 	}
 
-	if (vgname_from_mda(fmt, mdah, mda_is_primary(mda), &mdac->area, &vgsummary,
+	if (read_metadata_location_summary(fmt, mdah, mda_is_primary(mda), &mdac->area, &vgsummary,
 			     &mdac->free_sectors) &&
 	    !lvmcache_update_vgname_and_id(p->info, &vgsummary)) {
 		if (!dev_close(mdac->area.dev))
@@ -375,10 +375,10 @@ close_dev:
 	return 1;
 }
 
-static int _text_read(struct labeller *l, struct device *dev, void *buf,
-		 struct label **label)
+static int _text_read(struct labeller *l, struct device *dev, void *label_buf,
+		      struct label **label)
 {
-	struct label_header *lh = (struct label_header *) buf;
+	struct label_header *lh = (struct label_header *) label_buf;
 	struct pv_header *pvhdr;
 	struct pv_header_extension *pvhdr_ext;
 	struct lvmcache_info *info;
@@ -390,7 +390,7 @@ static int _text_read(struct labeller *l, struct device *dev, void *buf,
 	/*
 	 * PV header base
 	 */
-	pvhdr = (struct pv_header *) ((char *) buf + xlate32(lh->offset_xl));
+	pvhdr = (struct pv_header *) ((char *) label_buf + xlate32(lh->offset_xl));
 
 	if (!(info = lvmcache_add(l, (char *)pvhdr->pv_uuid, dev,
 				  FMT_TEXT_ORPHAN_VG_NAME,
@@ -447,8 +447,7 @@ out:
 	baton.info = info;
 	baton.label = *label;
 
-	if (!lvmcache_foreach_mda(info, _update_mda, &baton))
-		return_0;
+	lvmcache_foreach_mda(info, _read_mda_header_and_metadata, &baton);
 
 	lvmcache_make_valid(info);
 
diff --git a/lib/label/label.c b/lib/label/label.c
index 46dd667..57d5248 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -18,10 +18,14 @@
 #include "crc.h"
 #include "xlate.h"
 #include "lvmcache.h"
+#include "bcache.h"
+#include "toolcontext.h"
 
 #include <sys/stat.h>
 #include <fcntl.h>
 #include <unistd.h>
+#include <sys/time.h>
+
 
 /* FIXME Allow for larger labels?  Restricted to single sector currently */
 
@@ -96,101 +100,6 @@ struct labeller *label_get_handler(const char *name)
 	return NULL;
 }
 
-static void _update_lvmcache_orphan(struct lvmcache_info *info)
-{
-	struct lvmcache_vgsummary vgsummary_orphan = {
-		.vgname = lvmcache_fmt(info)->orphan_vg_name,
-	};
-
-        memcpy(&vgsummary_orphan.vgid, lvmcache_fmt(info)->orphan_vg_name, strlen(lvmcache_fmt(info)->orphan_vg_name));
-
-	if (!lvmcache_update_vgname_and_id(info, &vgsummary_orphan))
-		stack;
-}
-
-static struct labeller *_find_labeller(struct device *dev, char *buf,
-				       uint64_t *label_sector,
-				       uint64_t scan_sector)
-{
-	struct labeller_i *li;
-	struct labeller *r = NULL;
-	struct label_header *lh;
-	struct lvmcache_info *info;
-	uint64_t sector;
-	int found = 0;
-	char readbuf[LABEL_SCAN_SIZE] __attribute__((aligned(8)));
-
-	if (!dev_read(dev, scan_sector << SECTOR_SHIFT,
-		      LABEL_SCAN_SIZE, DEV_IO_LABEL, readbuf)) {
-		log_debug_devs("%s: Failed to read label area", dev_name(dev));
-		goto out;
-	}
-
-	/* Scan a few sectors for a valid label */
-	for (sector = 0; sector < LABEL_SCAN_SECTORS;
-	     sector += LABEL_SIZE >> SECTOR_SHIFT) {
-		lh = (struct label_header *) (readbuf +
-					      (sector << SECTOR_SHIFT));
-
-		if (!strncmp((char *)lh->id, LABEL_ID, sizeof(lh->id))) {
-			if (found) {
-				log_error("Ignoring additional label on %s at "
-					  "sector %" PRIu64, dev_name(dev),
-					  sector + scan_sector);
-			}
-			if (xlate64(lh->sector_xl) != sector + scan_sector) {
-				log_very_verbose("%s: Label for sector %" PRIu64
-						 " found at sector %" PRIu64
-						 " - ignoring", dev_name(dev),
-						 (uint64_t)xlate64(lh->sector_xl),
-						 sector + scan_sector);
-				continue;
-			}
-			if (calc_crc(INITIAL_CRC, (uint8_t *)&lh->offset_xl, LABEL_SIZE -
-				     ((uint8_t *) &lh->offset_xl - (uint8_t *) lh)) !=
-			    xlate32(lh->crc_xl)) {
-				log_very_verbose("Label checksum incorrect on %s - "
-						 "ignoring", dev_name(dev));
-				continue;
-			}
-			if (found)
-				continue;
-		}
-
-		dm_list_iterate_items(li, &_labellers) {
-			if (li->l->ops->can_handle(li->l, (char *) lh,
-						   sector + scan_sector)) {
-				log_very_verbose("%s: %s label detected at "
-					         "sector %" PRIu64, 
-						 dev_name(dev), li->name,
-						 sector + scan_sector);
-				if (found) {
-					log_error("Ignoring additional label "
-						  "on %s at sector %" PRIu64,
-						  dev_name(dev),
-						  sector + scan_sector);
-					continue;
-				}
-				r = li->l;
-				memcpy(buf, lh, LABEL_SIZE);
-				if (label_sector)
-					*label_sector = sector + scan_sector;
-				found = 1;
-				break;
-			}
-		}
-	}
-
-      out:
-	if (!found) {
-		if ((info = lvmcache_info_from_pvid(dev->pvid, dev, 0)))
-			_update_lvmcache_orphan(info);
-		log_very_verbose("%s: No label detected", dev_name(dev));
-	}
-
-	return r;
-}
-
 /* FIXME Also wipe associated metadata area headers? */
 int label_remove(struct device *dev)
 {
@@ -216,6 +125,8 @@ int label_remove(struct device *dev)
 	 */
 	dev_flush(dev);
 
+	label_scan_invalidate(dev);
+
 	if (!dev_read(dev, UINT64_C(0), LABEL_SCAN_SIZE, DEV_IO_LABEL, readbuf)) {
 		log_debug_devs("%s: Failed to read label area", dev_name(dev));
 		goto out;
@@ -267,44 +178,6 @@ int label_remove(struct device *dev)
 	return r;
 }
 
-int label_read(struct device *dev, struct label **result,
-		uint64_t scan_sector)
-{
-	char buf[LABEL_SIZE] __attribute__((aligned(8)));
-	struct labeller *l;
-	uint64_t sector;
-	struct lvmcache_info *info;
-	int r = 0;
-
-	if ((info = lvmcache_info_from_pvid(dev->pvid, dev, 1))) {
-		log_debug_devs("Reading label from lvmcache for %s", dev_name(dev));
-		*result = lvmcache_get_label(info);
-		return 1;
-	}
-
-	log_debug_devs("Reading label from device %s", dev_name(dev));
-
-	if (!dev_open_readonly(dev)) {
-		stack;
-
-		if ((info = lvmcache_info_from_pvid(dev->pvid, dev, 0)))
-			_update_lvmcache_orphan(info);
-
-		return r;
-	}
-
-	if ((l = _find_labeller(dev, buf, &sector, scan_sector)))
-		if ((r = (l->ops->read)(l, dev, buf, result)) && result && *result) {
-			(*result)->dev = dev;
-			(*result)->sector = sector;
-		}
-
-	if (!dev_close(dev))
-		stack;
-
-	return r;
-}
-
 /* Caller may need to use label_get_handler to create label struct! */
 int label_write(struct device *dev, struct label *label)
 {
@@ -323,6 +196,8 @@ int label_write(struct device *dev, struct label *label)
 		return 0;
 	}
 
+	label_scan_invalidate(dev);
+
 	memset(buf, 0, LABEL_SIZE);
 
 	strncpy((char *)lh->id, LABEL_ID, sizeof(lh->id));
@@ -373,3 +248,445 @@ struct label *label_create(struct labeller *labeller)
 
 	return label;
 }
+
+
+/* global variable for accessing the bcache populated by label scan */
+struct bcache *scan_bcache;
+
+#define BCACHE_BLOCK_SIZE_IN_SECTORS 2048 /* 1MB */
+
+static bool _in_bcache(struct device *dev)
+{
+	return (dev->flags & DEV_IN_BCACHE) ? true : false;
+}
+
+static struct labeller *_find_lvm_header(struct device *dev,
+				   char *scan_buf,
+				   char *label_buf,
+				   uint64_t *label_sector,
+				   uint64_t scan_sector)
+{
+	struct labeller_i *li;
+	struct labeller *labeller_ret = NULL;
+	struct label_header *lh;
+	uint64_t sector;
+	int found = 0;
+
+	/*
+	 * Find which sector in scan_buf starts with a valid label,
+	 * and copy it into label_buf.
+	 */
+
+	for (sector = 0; sector < LABEL_SCAN_SECTORS;
+	     sector += LABEL_SIZE >> SECTOR_SHIFT) {
+		lh = (struct label_header *) (scan_buf + (sector << SECTOR_SHIFT));
+
+		if (!strncmp((char *)lh->id, LABEL_ID, sizeof(lh->id))) {
+			if (found) {
+				log_error("Ignoring additional label on %s at sector %llu",
+					  dev_name(dev), (unsigned long long)(sector + scan_sector));
+			}
+			if (xlate64(lh->sector_xl) != sector + scan_sector) {
+				log_very_verbose("%s: Label for sector %llu found at sector %llu - ignoring.",
+						 dev_name(dev),
+						 (unsigned long long)xlate64(lh->sector_xl),
+						 (unsigned long long)(sector + scan_sector));
+				continue;
+			}
+			if (calc_crc(INITIAL_CRC, (uint8_t *)&lh->offset_xl, LABEL_SIZE -
+				     ((uint8_t *) &lh->offset_xl - (uint8_t *) lh)) !=
+			    xlate32(lh->crc_xl)) {
+				log_very_verbose("Label checksum incorrect on %s - ignoring", dev_name(dev));
+				continue;
+			}
+			if (found)
+				continue;
+		}
+
+		dm_list_iterate_items(li, &_labellers) {
+			if (li->l->ops->can_handle(li->l, (char *) lh, sector + scan_sector)) {
+				log_very_verbose("%s: %s label detected at sector %llu", 
+						 dev_name(dev), li->name,
+						 (unsigned long long)(sector + scan_sector));
+				if (found) {
+					log_error("Ignoring additional label on %s at sector %llu",
+						  dev_name(dev),
+						  (unsigned long long)(sector + scan_sector));
+					continue;
+				}
+
+				labeller_ret = li->l;
+				found = 1;
+
+				memcpy(label_buf, lh, LABEL_SIZE);
+				if (label_sector)
+					*label_sector = sector + scan_sector;
+				break;
+			}
+		}
+	}
+
+	return labeller_ret;
+}
+
+/*
+ * Process/parse the headers from the data read from a device.
+ * Populates lvmcache with device / mda locations / vgname
+ * so that vg_read(vgname) will know which devices/locations
+ * to read metadata from.
+ *
+ * If during processing, headers/metadata are found to be needed
+ * beyond the range of the scanned block, then additional reads
+ * are performed in the processing functions to get that data.
+ */
+static int _process_block(struct device *dev, struct block *bb, int *is_lvm_device)
+{
+	char label_buf[LABEL_SIZE] __attribute__((aligned(8)));
+	struct label *label = NULL;
+	struct labeller *labeller;
+	struct lvmcache_info *info;
+	uint64_t sector;
+	int ret = 0;
+
+	/*
+	 * Finds the data sector containing the label and copies into label_buf.
+	 * label_buf: struct label_header + struct pv_header + struct pv_header_extension
+	 *
+	 * FIXME: we don't need to copy one sector from bb->data into label_buf,
+	 * we can just point label_buf at one sector in ld->buf.
+	 */
+	if (!(labeller = _find_lvm_header(dev, bb->data, label_buf, &sector, 0))) {
+
+		/*
+		 * Non-PVs exit here
+		 *
+		 * FIXME: check for PVs with errors that also exit here!
+		 * i.e. this code cannot distinguish between a non-lvm
+		 * device an an lvm device with errors.
+		 */
+
+		log_very_verbose("%s: No lvm label detected", dev_name(dev));
+
+		if ((info = lvmcache_info_from_pvid(dev->pvid, dev, 0))) {
+			/* FIXME: if this case is actually happening, fix it. */
+			log_warn("Device %s has no label, removing PV info from lvmcache.", dev_name(dev));
+			lvmcache_del(info);
+		}
+
+		*is_lvm_device = 0;
+		goto_out;
+	}
+
+	*is_lvm_device = 1;
+
+	/*
+	 * This is the point where the scanning code dives into the rest of
+	 * lvm.  ops->read() is usually _text_read() which reads the pv_header,
+	 * mda locations, mda contents.  As these bits of data are read, they
+	 * are saved into lvmcache as info/vginfo structs.
+	 */
+
+	if ((ret = (labeller->ops->read)(labeller, dev, label_buf, &label)) && label) {
+		label->dev = dev;
+		label->sector = sector;
+	} else {
+		/* FIXME: handle errors */
+	}
+ out:
+	return ret;
+}
+
+/*
+ * Read or reread label/metadata from selected devs.
+ *
+ * Reads and looks at label_header, pv_header, pv_header_extension,
+ * mda_header, raw_locns, vg metadata from each device.
+ *
+ * Effect is populating lvmcache with latest info/vginfo (PV/VG) data
+ * from the devs.  If a scanned device does not have a label_header,
+ * its info is removed from lvmcache.
+ */
+
+static int _scan_list(struct dm_list *devs)
+{
+	struct dm_list wait_devs;
+	struct dm_list done_devs;
+	struct device_list *devl, *devl2;
+	struct block *bb;
+	int scan_failed_count = 0;
+	int scan_lvm_count = 0;
+	int rem_prefetches;
+	int scan_failed;
+	int is_lvm_device;
+
+	dm_list_init(&wait_devs);
+	dm_list_init(&done_devs);
+
+	log_debug_devs("Scanning %d devices.", dm_list_size(devs));
+
+ scan_more:
+	rem_prefetches = bcache_max_prefetches(scan_bcache);
+
+	dm_list_iterate_items_safe(devl, devl2, devs) {
+
+		/*
+		 * If we prefetch more devs than blocks in the cache, then the
+		 * cache will wait for earlier reads to complete, toss the
+		 * results, and reuse those blocks before we've had a chance to
+		 * use them.  So, prefetch as many as are available, wait for
+		 * and process them, then repeat.
+		 */
+		if (!rem_prefetches)
+			break;
+
+		/*
+		 * The in-bcache flag corresponds with this dev_open.
+		 * Clearing the in-bcache flag should be paired with
+		 * a dev_close.  (This dev may already be in bcache.)
+		 */
+		if (!_in_bcache(devl->dev)) {
+			if (!dev_open_readonly(devl->dev)) {
+				log_debug_devs("%s: Failed to open device.", dev_name(devl->dev));
+				continue;
+			}
+		}
+
+		bcache_prefetch(scan_bcache, devl->dev->fd, 0);
+
+		rem_prefetches--;
+
+		dm_list_del(&devl->list);
+		dm_list_add(&wait_devs, &devl->list);
+	}
+
+	dm_list_iterate_items_safe(devl, devl2, &wait_devs) {
+		bb = NULL;
+
+		if (!bcache_get(scan_bcache, devl->dev->fd, 0, 0, &bb)) {
+			log_debug_devs("%s: Failed to scan device.", dev_name(devl->dev));
+			scan_failed_count++;
+			scan_failed = 1;
+		} else {
+			log_debug_devs("Processing data from device %s fd %d block %p", dev_name(devl->dev), devl->dev->fd, bb);
+			_process_block(devl->dev, bb, &is_lvm_device);
+			scan_lvm_count++;
+			scan_failed = 0;
+		}
+
+		if (bb)
+			bcache_put(bb);
+
+		/*
+		 * Keep the bcache block of lvm devices we have processed so
+		 * that the vg_read phase can reuse it.  If bcache failed to
+		 * read the block, or the device does not belong to lvm, then
+		 * drop it from bcache.
+		 */
+		if (scan_failed || !is_lvm_device) {
+			devl->dev->flags &= ~DEV_IN_BCACHE;
+			bcache_invalidate_fd(scan_bcache, devl->dev->fd);
+			dev_close(devl->dev);
+		} else {
+			/* The device must be kept open while it's in bcache. */
+			devl->dev->flags |= DEV_IN_BCACHE;
+		}
+
+		dm_list_del(&devl->list);
+		dm_list_add(&done_devs, &devl->list);
+	}
+
+	if (!dm_list_empty(devs))
+		goto scan_more;
+
+	/* FIXME: let the caller know if some lvm devices failed to be scanned. */
+
+	log_debug_devs("Scanned %d devices: %d for lvm, %d failed.",
+			dm_list_size(&done_devs), scan_lvm_count, scan_failed_count);
+
+	return 0;
+}
+
+/*
+ * Scan and cache lvm data from all devices on the system.
+ * The cache should be empty/reset before calling this.
+ */
+
+int label_scan(struct cmd_context *cmd)
+{
+	struct dm_list all_devs;
+	struct dev_iter *iter;
+	struct device_list *devl;
+	struct device *dev;
+	struct io_engine *ioe;
+
+	log_debug_devs("Finding devices to scan");
+
+	dm_list_init(&all_devs);
+
+	/*
+	 * Iterate through all the devices in dev-cache (block devs that appear
+	 * under /dev that could possibly hold a PV and are not excluded by
+	 * filters).  Read each to see if it's an lvm device, and if so
+	 * populate lvmcache with some basic info about the device and the VG
+	 * on it.  This info will be used by the vg_read() phase of the
+	 * command.
+	 */
+	dev_cache_full_scan(cmd->full_filter);
+
+	if (!(iter = dev_iter_create(cmd->full_filter, 0))) {
+		log_error("Scanning failed to get devices.");
+		return 0;
+	}
+
+	while ((dev = dev_iter_get(iter))) {
+		if (!(devl = dm_pool_zalloc(cmd->mem, sizeof(*devl))))
+			return 0;
+		devl->dev = dev;
+		dm_list_add(&all_devs, &devl->list);
+
+		/*
+		 * label_scan should not generally be called a second time,
+		 * so this will usually not be true.
+		 */
+		if (_in_bcache(dev))
+			bcache_invalidate_fd(scan_bcache, dev->fd);
+	};
+	dev_iter_destroy(iter);
+
+	if (!scan_bcache) {
+
+		/*
+		 * 100 is arbitrary, it's the max number of concurrent aio's
+		 * possible, i.e, the number of devices that can be read at
+		 * once.  Should this be configurable?
+		 */
+		if (!(ioe = create_async_io_engine(100)))
+			return 0;
+
+		/*
+		 * Configure one cache block for each device on the system.
+		 * We won't generally need to cache that many because some
+		 * of the devs will not be lvm devices, and we don't need
+		 * an entry for those.  We might want to change this.
+		 */
+		if (!(scan_bcache = bcache_create(BCACHE_BLOCK_SIZE_IN_SECTORS, dm_list_size(&all_devs), ioe)))
+			return 0;
+	}
+
+	return _scan_list(&all_devs);
+}
+
+/*
+ * Scan and cache lvm data from the listed devices.  If a device is already
+ * scanned and cached, this replaces the previously cached lvm data for the
+ * device.  This is called when vg_read() wants to guarantee that it is using
+ * the latest data from the devices in the VG (since the scan populated bcache
+ * without a lock.)
+ */
+
+int label_scan_devs(struct cmd_context *cmd, struct dm_list *devs)
+{
+	struct device_list *devl;
+
+	dm_list_iterate_items(devl, devs) {
+		if (_in_bcache(devl->dev))
+			bcache_invalidate_fd(scan_bcache, devl->dev->fd);
+	}
+
+	return _scan_list(devs);
+}
+
+void label_scan_invalidate(struct device *dev)
+{
+	if (_in_bcache(dev)) {
+		dev->flags &= ~DEV_IN_BCACHE;
+		bcache_invalidate_fd(scan_bcache, dev->fd);
+		dev_close(dev);
+	}
+}
+
+/*
+ * Undo label_scan()
+ *
+ * Close devices that are open because bcache is holding blocks for them.
+ * Destroy the bcache.
+ */
+
+void label_scan_destroy(struct cmd_context *cmd)
+{
+	struct dev_iter *iter;
+	struct device *dev;
+
+	if (!scan_bcache)
+		return;
+
+	if (!(iter = dev_iter_create(cmd->full_filter, 0))) {
+		return;
+	}
+
+	while ((dev = dev_iter_get(iter)))
+		label_scan_invalidate(dev);
+	dev_iter_destroy(iter);
+
+	bcache_destroy(scan_bcache);
+	scan_bcache = NULL;
+}
+
+/*
+ * Read (or re-read) and process (or re-process) the data for a device.  This
+ * will reset (clear and repopulate) the bcache and lvmcache info for this
+ * device.  There are only a couple odd places that want to reread a specific
+ * device, this is not a commonly used function.
+ */
+
+/* FIXME: remove unused_sector arg */
+
+int label_read(struct device *dev, struct label **labelp, uint64_t unused_sector)
+{
+	struct dm_list one_dev;
+	struct device_list *devl;
+	int ret;
+
+	/* scanning is done by list, so make a single item list for this dev */
+	if (!(devl = dm_zalloc(sizeof(*devl))))
+		return 0;
+	devl->dev = dev;
+	dm_list_init(&one_dev);
+	dm_list_add(&one_dev, &devl->list);
+
+	if (_in_bcache(dev))
+		bcache_invalidate_fd(scan_bcache, dev->fd);
+
+	ret = _scan_list(&one_dev);
+
+	/*
+	 * FIXME: this ugliness of returning a pointer to the label is
+	 * temporary until the callers can be updated to not use this.
+	 */
+	if (labelp) {
+		struct lvmcache_info *info;
+
+		info = lvmcache_info_from_pvid(dev->pvid, dev, 1);
+		if (info)
+			*labelp = lvmcache_get_label(info);
+	}
+
+	return ret;
+}
+
+/*
+ * Read a label from a specfic, non-zero sector.  This is used in only
+ * one place: pvck -> pv_analyze.
+ */
+
+int label_read_sector(struct device *dev, struct label **labelp, uint64_t scan_sector)
+{
+	if (scan_sector) {
+		/* TODO: not yet implemented */
+		/* When is this done?  When does it make sense?  Is it actually possible? */
+		return 0;
+	}
+
+	return label_read(dev, labelp, 0);
+}
+
diff --git a/lib/label/label.h b/lib/label/label.h
index ea11290..d9e36bc 100644
--- a/lib/label/label.h
+++ b/lib/label/label.h
@@ -18,6 +18,8 @@
 
 #include "uuid.h"
 #include "device.h"
+#include "bcache.h"
+#include "toolcontext.h"
 
 #define LABEL_ID "LABELONE"
 #define LABEL_SIZE SECTOR_SIZE	/* Think very carefully before changing this */
@@ -63,7 +65,7 @@ struct label_ops {
 	 * Read a label from a volume.
 	 */
 	int (*read) (struct labeller * l, struct device * dev,
-		     void *buf, struct label ** label);
+		     void *label_buf, struct label ** label);
 
 	/*
 	 * Populate label_type etc.
@@ -94,10 +96,17 @@ int label_register_handler(struct labeller *handler);
 struct labeller *label_get_handler(const char *name);
 
 int label_remove(struct device *dev);
-int label_read(struct device *dev, struct label **result,
-		uint64_t scan_sector);
 int label_write(struct device *dev, struct label *label);
 struct label *label_create(struct labeller *labeller);
 void label_destroy(struct label *label);
 
+extern struct bcache *scan_bcache;
+
+int label_scan(struct cmd_context *cmd);
+int label_scan_devs(struct cmd_context *cmd, struct dm_list *devs);
+void label_scan_invalidate(struct device *dev);
+void label_scan_destroy(struct cmd_context *cmd);
+int label_read(struct device *dev, struct label **labelp, uint64_t unused_sector);
+int label_read_sector(struct device *dev, struct label **labelp, uint64_t scan_sector);
+
 #endif
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 2bc7927..73041cf 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -377,6 +377,19 @@ struct pv_segment {
  */
 #define FMT_INSTANCE_PRIVATE_MDAS	0x00000008U
 
+/*
+ * Each VG has its own fid struct.  The fid for a VG describes where
+ * the metadata for that VG can be found.  The lists hold mda locations.
+ *
+ * label scan finds the metadata locations (devs and offsets) for a VG,
+ * and saves this info in lvmcache vginfo/info lists.
+ *
+ * vg_read() then creates an fid for a given VG, and the mda locations
+ * from lvmcache are copied onto the fid lists.  Those mda locations
+ * are read again by vg_read() to get VG metadata that is used to
+ * create the 'vg' struct.
+ */
+
 struct format_instance {
 	unsigned ref_count;	/* Refs to this fid from VG and PV structs */
 	struct dm_pool *mem;
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 2249d2f..00b7737 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -719,6 +719,10 @@ int check_pv_dev_sizes(struct volume_group *vg)
  * source file.  All the following and more are only used by liblvm:
  *
  * . get_pvs()
+ * . get_vgids()
+ * . get_vgnames()
+ * . lvmcache_get_vgids()
+ * . lvmcache_get_vgnames()
  * . the vg->pvs_to_write list and pv_to_write struct
  */
 
@@ -3909,12 +3913,16 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 	/* Ensure contents of all metadata areas match - else do recovery */
 	inconsistent_mda_count=0;
 	dm_list_iterate_items(mda, &fid->metadata_areas_in_use) {
+		struct device *mda_dev = mda_get_device(mda);
+
 		use_previous_vg = 0;
 
+		log_debug_metadata("Reading VG %s from %s", vgname, dev_name(mda_dev));
+
 		if ((use_precommitted &&
 		     !(vg = mda->ops->vg_read_precommit(fid, vgname, mda, &vg_fmtdata, &use_previous_vg)) && !use_previous_vg) ||
 		    (!use_precommitted &&
-		     !(vg = mda->ops->vg_read(fid, vgname, mda, &vg_fmtdata, &use_previous_vg, 0)) && !use_previous_vg)) {
+		     !(vg = mda->ops->vg_read(fid, vgname, mda, &vg_fmtdata, &use_previous_vg)) && !use_previous_vg)) {
 			inconsistent = 1;
 			vg_fmtdata = NULL;
 			continue;
@@ -4106,7 +4114,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 			if ((use_precommitted &&
 			     !(vg = mda->ops->vg_read_precommit(fid, vgname, mda, &vg_fmtdata, &use_previous_vg)) && !use_previous_vg) ||
 			    (!use_precommitted &&
-			     !(vg = mda->ops->vg_read(fid, vgname, mda, &vg_fmtdata, &use_previous_vg, 0)) && !use_previous_vg)) {
+			     !(vg = mda->ops->vg_read(fid, vgname, mda, &vg_fmtdata, &use_previous_vg)) && !use_previous_vg)) {
 				inconsistent = 1;
 				vg_fmtdata = NULL;
 				continue;
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index 1fa14e8..5b8d690 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -80,8 +80,7 @@ struct metadata_area_ops {
 					 const char *vg_name,
 					 struct metadata_area * mda,
 					 struct cached_vg_fmtdata **vg_fmtdata,
-					 unsigned *use_previous_vg,
-					 int single_device);
+					 unsigned *use_previous_vg);
 	struct volume_group *(*vg_read_precommit) (struct format_instance * fi,
 					 const char *vg_name,
 					 struct metadata_area * mda,
@@ -183,6 +182,11 @@ void mda_set_ignored(struct metadata_area *mda, unsigned mda_ignored);
 unsigned mda_locns_match(struct metadata_area *mda1, struct metadata_area *mda2);
 struct device *mda_get_device(struct metadata_area *mda);
 
+/*
+ * fic is used to create an fid.  It's used to pass fmt/vgname/vgid args
+ * to create_instance() which creates an fid for the specified vg.
+ */
+
 struct format_instance_ctx {
 	uint32_t type;
 	union {


