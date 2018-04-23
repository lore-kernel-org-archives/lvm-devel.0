From: David Teigland <teigland@sourceware.org>
Date: Mon, 23 Apr 2018 09:55:41 -0400
Subject: master - bcache: use wrappers for bcache read write in lvm
Message-ID: <201804231355.w3NDtf4t001791@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e49b114f7e437666caefa04aada31f32820e286e
Commit:        e49b114f7e437666caefa04aada31f32820e286e
Parent:        80654920468841251a7f940e410ca61de8383b41
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Feb 27 11:26:04 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 20 11:22:47 2018 -0500

bcache: use wrappers for bcache read write in lvm

Using a wrapper makes it easier to disable bcache if needed.
---
 lib/config/config.c           |    4 +-
 lib/device/dev-type.c         |    4 +-
 lib/format_text/archiver.c    |    2 +-
 lib/format_text/format-text.c |   19 ++++-----
 lib/label/label.c             |   82 +++++++++++++++++++++++++++++++++++++---
 lib/label/label.h             |    8 ++++
 lib/metadata/metadata.c       |    2 +-
 tools/toollib.c               |    2 +-
 8 files changed, 99 insertions(+), 24 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index 0711b8c..d07c173 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -534,11 +534,11 @@ int config_file_read_fd(struct dm_config_tree *cft, struct device *dev, dev_io_r
 			return 0;
 		}
 
-		if (!bcache_read_bytes(scan_bcache, dev->bcache_fd, offset, size, buf))
+		if (!dev_read_bytes(dev, offset, size, buf))
 			goto out;
 
 		if (size2) {
-			if (!bcache_read_bytes(scan_bcache, dev->bcache_fd, offset2, size2, buf + size))
+			if (!dev_read_bytes(dev, offset2, size2, buf + size))
 				goto out;
 		}
 
diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index e69f7ca..9923943 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -677,7 +677,7 @@ static int _blkid_wipe(blkid_probe probe, struct device *dev, const char *name,
 	} else
 		log_verbose(_msg_wiping, type, name);
 
-	if (!bcache_write_zeros(scan_bcache, dev->bcache_fd, offset_value, len)) {
+	if (!dev_write_zeros(dev, offset_value, len)) {
 		log_error("Failed to wipe %s signature on %s.", type, name);
 		return 0;
 	}
@@ -774,7 +774,7 @@ static int _wipe_signature(struct device *dev, const char *type, const char *nam
 	}
 
 	log_print_unless_silent("Wiping %s on %s.", type, name);
-	if (!bcache_write_zeros(scan_bcache, dev->bcache_fd, offset_found, wipe_len)) {
+	if (!dev_write_zeros(dev, offset_found, wipe_len)) {
 		log_error("Failed to wipe %s on %s.", type, name);
 		return 0;
 	}
diff --git a/lib/format_text/archiver.c b/lib/format_text/archiver.c
index 43ae4eb..c8aeb47 100644
--- a/lib/format_text/archiver.c
+++ b/lib/format_text/archiver.c
@@ -489,7 +489,7 @@ int backup_restore_vg(struct cmd_context *cmd, struct volume_group *vg,
 
 			log_verbose("Zeroing start of device %s", pv_name);
 
-			if (!bcache_write_zeros(scan_bcache, dev->bcache_fd, 0, 2048)) {
+			if (!dev_write_zeros(dev, 0, 2048)) {
 				log_error("%s not wiped: aborting", pv_name);
 				return 0;
 			}
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 4eef72e..4a9c303 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -227,7 +227,7 @@ static int _pv_analyze_mda_raw (const struct format_type * fmt,
 		if (!(buf = dm_malloc(size + size2)))
 			goto_out;
 
-		if (!bcache_read_bytes(scan_bcache, area->dev->bcache_fd, offset, size, buf)) {
+		if (!dev_read_bytes(area->dev, offset, size, buf)) {
 			log_error("Failed to read dev %s offset %llu size %llu",
 				  dev_name(area->dev),
 				  (unsigned long long)offset,
@@ -236,7 +236,7 @@ static int _pv_analyze_mda_raw (const struct format_type * fmt,
 		}
 
 		if (size2) {
-			if (!bcache_read_bytes(scan_bcache, area->dev->bcache_fd, offset2, size2, buf + size)) {
+			if (!dev_read_bytes(area->dev, offset2, size2, buf + size)) {
 				log_error("Failed to read dev %s offset %llu size %llu",
 				  	  dev_name(area->dev),
 					  (unsigned long long)offset2,
@@ -330,7 +330,7 @@ static int _raw_read_mda_header(struct mda_header *mdah, struct device_area *dev
 	log_debug_metadata("Reading mda header sector from %s at %llu",
 			   dev_name(dev_area->dev), (unsigned long long)dev_area->start);
 
-	if (!bcache_read_bytes(scan_bcache, dev_area->dev->bcache_fd, dev_area->start, MDA_HEADER_SIZE, mdah)) {
+	if (!dev_read_bytes(dev_area->dev, dev_area->start, MDA_HEADER_SIZE, mdah)) {
 		log_error("Failed to read metadata area header on %s at %llu",
 			  dev_name(dev_area->dev), (unsigned long long)dev_area->start);
 		return 0;
@@ -400,7 +400,7 @@ static int _raw_write_mda_header(const struct format_type *fmt,
 					     MDA_HEADER_SIZE -
 					     sizeof(mdah->checksum_xl)));
 
-	if (!bcache_write_bytes(scan_bcache, dev->bcache_fd, start_byte, MDA_HEADER_SIZE, mdah)) {
+	if (!dev_write_bytes(dev, start_byte, MDA_HEADER_SIZE, mdah)) {
 		log_error("Failed to write mda header to %s fd %d", dev_name(dev), dev->bcache_fd);
 		return 0;
 	}
@@ -464,7 +464,7 @@ static struct raw_locn *_read_metadata_location_vg(struct device_area *dev_area,
 	 */
 	memset(vgnamebuf, 0, sizeof(vgnamebuf));
 
-	bcache_read_bytes(scan_bcache, dev_area->dev->bcache_fd, dev_area->start + rlocn->offset, NAME_LEN, vgnamebuf);
+	dev_read_bytes(dev_area->dev, dev_area->start + rlocn->offset, NAME_LEN, vgnamebuf);
 
 	if (!strncmp(vgnamebuf, vgname, len = strlen(vgname)) &&
 	    (isspace(vgnamebuf[len]) || vgnamebuf[len] == '{'))
@@ -675,7 +675,7 @@ static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 			    (unsigned long long)(mdac->rlocn.size - new_wrap),
 			    (unsigned long long)new_wrap);
 
-	if (!bcache_write_bytes(scan_bcache, mdac->area.dev->bcache_fd, mdac->area.start + mdac->rlocn.offset,
+	if (!dev_write_bytes(mdac->area.dev, mdac->area.start + mdac->rlocn.offset,
 		                (size_t) (mdac->rlocn.size - new_wrap),
 		                fidtc->raw_metadata_buf)) {
 		log_error("Failed to write metadata to %s fd %d", dev_name(mdac->area.dev), mdac->area.dev->bcache_fd);
@@ -688,8 +688,7 @@ static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 				   (unsigned long long)(mdac->area.start + MDA_HEADER_SIZE),
 				   (unsigned long long)new_wrap);
 
-		if (!bcache_write_bytes(scan_bcache, mdac->area.dev->bcache_fd,
-			                mdac->area.start + MDA_HEADER_SIZE,
+		if (!dev_write_bytes(mdac->area.dev, mdac->area.start + MDA_HEADER_SIZE,
 			                (size_t) new_wrap,
 			                fidtc->raw_metadata_buf + mdac->rlocn.size - new_wrap)) {
 			log_error("Failed to write metadata wrap to %s fd %d", dev_name(mdac->area.dev), mdac->area.dev->bcache_fd);
@@ -1217,7 +1216,7 @@ int read_metadata_location_summary(const struct format_type *fmt,
 		return 0;
 	}
 
-	bcache_read_bytes(scan_bcache, dev_area->dev->bcache_fd, dev_area->start + rlocn->offset, NAME_LEN, buf);
+	dev_read_bytes(dev_area->dev, dev_area->start + rlocn->offset, NAME_LEN, buf);
 
 	while (buf[len] && !isspace(buf[len]) && buf[len] != '{' &&
 	       len < (NAME_LEN - 1))
@@ -2308,7 +2307,7 @@ static int _text_pv_add_metadata_area(const struct format_type *fmt,
 
 		zero_len = (mda_size > wipe_size) ? wipe_size : mda_size;
 
-		if (!bcache_write_zeros(scan_bcache, pv->dev->bcache_fd, mda_start, zero_len)) {
+		if (!dev_write_zeros(pv->dev, mda_start, zero_len)) {
 			log_error("Failed to wipe new metadata area on %s at %llu len %llu",
 				   pv_dev_name(pv),
 				   (unsigned long long)mda_start,
diff --git a/lib/label/label.c b/lib/label/label.c
index 67d441b..45a3ecf 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -125,8 +125,7 @@ int label_remove(struct device *dev)
 
 		memset(readbuf, 0, sizeof(readbuf));
 
-		if (!bcache_read_bytes(scan_bcache, dev->bcache_fd,
-				       sector << SECTOR_SHIFT, LABEL_SIZE, readbuf)) {
+		if (!dev_read_bytes(dev, sector << SECTOR_SHIFT, LABEL_SIZE, readbuf)) {
 			log_error("Failed to read label from %s sector %llu",
 				  dev_name(dev), (unsigned long long)sector);
 			continue;
@@ -152,8 +151,7 @@ int label_remove(struct device *dev)
 			log_very_verbose("%s: Wiping label@sector %llu",
 					 dev_name(dev), (unsigned long long)sector);
 
-			if (!bcache_write_zeros(scan_bcache, dev->bcache_fd,
-						sector << SECTOR_SHIFT, LABEL_SIZE)) {
+			if (!dev_write_zeros(dev, sector << SECTOR_SHIFT, LABEL_SIZE)) {
 				log_error("Failed to remove label from %s@sector %llu",
 					  dev_name(dev), (unsigned long long)sector);
 				r = 0;
@@ -166,7 +164,6 @@ int label_remove(struct device *dev)
 		}
 	}
 
-      out:
 	return r;
 }
 
@@ -209,8 +206,7 @@ int label_write(struct device *dev, struct label *label)
 		return 0;
 	}
 
-	if (!bcache_write_bytes(scan_bcache, dev->bcache_fd,
-				label->sector << SECTOR_SHIFT, LABEL_SIZE, buf)) {
+	if (!dev_write_bytes(dev, label->sector << SECTOR_SHIFT, LABEL_SIZE, buf)) {
 		log_debug_devs("Failed to write label to %s", dev_name(dev));
 		r = 0;
 	}
@@ -856,3 +852,75 @@ int label_scan_open(struct device *dev)
 	return 1;
 }
 
+bool dev_read_bytes(struct device *dev, off_t start, size_t len, void *data)
+{
+	int ret;
+
+	if (!scan_bcache) {
+		if (!dev_open_readonly(dev))
+			return false;
+
+		ret = dev_read(dev, start, len, 0, data);
+
+		if (!dev_close(dev))
+			stack;
+
+		return ret ? true : false;
+	}
+
+	if (dev->bcache_fd <= 0) {
+		log_error("dev_read_bytes %s with invalid bcache_fd", dev_name(dev));
+		return false;
+	}
+
+	return bcache_read_bytes(scan_bcache, dev->bcache_fd, start, len, data);
+}
+
+bool dev_write_bytes(struct device *dev, off_t start, size_t len, void *data)
+{
+	int ret;
+
+	if (!scan_bcache) {
+		if (!dev_open(dev))
+			return false;
+
+		ret = dev_write(dev, start, len, 0, data);
+
+		if (!dev_close(dev))
+			stack;
+
+		return ret ? true : false;
+	}
+
+	if (dev->bcache_fd <= 0) {
+		log_error("dev_write_bytes %s with invalid bcache_fd", dev_name(dev));
+		return false;
+	}
+
+	return bcache_write_bytes(scan_bcache, dev->bcache_fd, start, len, data);
+}
+
+bool dev_write_zeros(struct device *dev, off_t start, size_t len)
+{
+	int ret;
+
+	if (!scan_bcache) {
+		if (!dev_open(dev))
+			return false;
+
+		ret = dev_set(dev, start, len, 0, 0);
+
+		if (!dev_close(dev))
+			stack;
+
+		return ret ? true : false;
+	}
+
+	if (dev->bcache_fd <= 0) {
+		log_error("dev_write_bytes %s with invalid bcache_fd", dev_name(dev));
+		return false;
+	}
+
+	return bcache_write_zeros(scan_bcache, dev->bcache_fd, start, len);
+}
+
diff --git a/lib/label/label.h b/lib/label/label.h
index 92f3e7b..8ef687b 100644
--- a/lib/label/label.h
+++ b/lib/label/label.h
@@ -114,4 +114,12 @@ void label_scan_confirm(struct device *dev);
 int label_scan_setup_bcache(void);
 int label_scan_open(struct device *dev);
 
+/*
+ * Wrappers around bcache equivalents.
+ * (these make it easier to disable bcache and revert to direct rw if needed)
+ */
+bool dev_read_bytes(struct device *dev, off_t start, size_t len, void *data);
+bool dev_write_bytes(struct device *dev, off_t start, size_t len, void *data);
+bool dev_write_zeros(struct device *dev, off_t start, size_t len);
+
 #endif
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 4cad2a1..b442451 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1429,7 +1429,7 @@ static int _pvcreate_write(struct cmd_context *cmd, struct pv_to_write *pvw)
 
 		if (pvw->pp->zero) {
 			log_verbose("Zeroing start of device %s", pv_name);
-			if (!bcache_write_zeros(scan_bcache, dev->bcache_fd, 0, 2048)) {
+			if (!dev_write_zeros(dev, 0, 2048)) {
 				log_error("%s not wiped: aborting", pv_name);
 				return 0;
 			}
diff --git a/tools/toollib.c b/tools/toollib.c
index b0c0e8e..b029a0d 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -5830,7 +5830,7 @@ do_command:
 		if (pp->zero) {
 			log_verbose("Zeroing start of device %s.", pv_name);
 
-			if (!bcache_write_zeros(scan_bcache, pv->dev->bcache_fd, 0, 2048)) {
+			if (!dev_write_zeros(pv->dev, 0, 2048)) {
 				log_error("%s not wiped: aborting.", pv_name);
 				dm_list_move(&pp->arg_fail, &pd->list);
 				continue;


