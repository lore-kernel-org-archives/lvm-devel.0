From: Alasdair Kergon <agk@sourceware.org>
Date: Mon, 18 Dec 2017 20:50:59 -0500
Subject: master - device: Move dev_read memory allocation into device layer.
Message-ID: <201712190150.vBJ1oxlQ023433@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=17649d4ac8d4c7d10bf58feefa5f1faae89713ca
Commit:        17649d4ac8d4c7d10bf58feefa5f1faae89713ca
Parent:        3f9ae846b89a2963a4ca72cfa0281aab0bedcc02
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Dec 19 01:12:18 2017 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Dec 19 01:31:50 2017 +0000

device: Move dev_read memory allocation into device layer.

Rename dev_read() to dev_read_buf() - the function that reads data
into a supplied buffer.

Introduce a new dev_read() that allocates the buffer it returns and
switch the important users over to this.  No caller may change the
returned data.  (For now, callers are responsible for freeing it after
use, but later the device layer will take full ownership.)

dev_read_buf() should only be used for tiny buffers or unimportant code
(such as the old disk formats).
---
 WHATS_NEW                     |    1 +
 lib/config/config.c           |    6 +----
 lib/device/dev-io.c           |   42 +++++++++++++++++++++++++++++++++++++---
 lib/device/dev-luks.c         |    2 +-
 lib/device/dev-md.c           |    2 +-
 lib/device/dev-swap.c         |    3 +-
 lib/device/dev-type.c         |    2 +-
 lib/device/device.h           |    8 ++++++-
 lib/format1/disk-rep.c        |   10 ++++----
 lib/format_pool/disk_rep.c    |    2 +-
 lib/format_text/format-text.c |   28 +++++++++++++-------------
 lib/label/label.c             |   29 +++++++++++++--------------
 12 files changed, 85 insertions(+), 50 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index e4b04b0..fa79068 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.178 - 
 =====================================
+  Move memory allocation for the key dev_reads into the device layer.
 
 Version 2.02.177 - 18th December 2017
 =====================================
diff --git a/lib/config/config.c b/lib/config/config.c
index fac7e4c..bbbcc3d 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -533,11 +533,7 @@ int config_file_read_fd(struct dm_config_tree *cft, struct device *dev, dev_io_r
 			if (!(buf = dev_read_circular(dev, (uint64_t) offset, size, (uint64_t) offset2, size2, reason)))
 				goto_out;
 		} else {
-			if (!(buf = dm_malloc(size))) {
-				log_error("Failed to allocate buffer for metadata read.");
-				return 0;
-			}
-			if (!dev_read(dev, (uint64_t) offset, size, reason, buf))
+			if (!(buf = dev_read(dev, (uint64_t) offset, size, reason)))
 				goto_out;
 		}
 		fb = buf;
diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index 0545d8c..72d6768 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -722,7 +722,7 @@ static void _dev_inc_error_count(struct device *dev)
 			 dev->max_error_count, dev_name(dev));
 }
 
-int dev_read(struct device *dev, uint64_t offset, size_t len, dev_io_reason_t reason, void *buffer)
+static int _dev_read(struct device *dev, uint64_t offset, size_t len, dev_io_reason_t reason, char *buf)
 {
 	struct device_area where;
 	int ret;
@@ -737,13 +737,47 @@ int dev_read(struct device *dev, uint64_t offset, size_t len, dev_io_reason_t re
 	where.start = offset;
 	where.size = len;
 
-	ret = _aligned_io(&where, buffer, 0, reason);
+	ret = _aligned_io(&where, buf, 0, reason);
 	if (!ret)
 		_dev_inc_error_count(dev);
 
 	return ret;
 }
 
+/* Caller is responsible for dm_free */
+char *dev_read(struct device *dev, uint64_t offset, size_t len, dev_io_reason_t reason)
+{
+	char *buf;
+
+	if (!(buf = dm_malloc(len))) {
+		log_error("Buffer allocation failed for device read.");
+		return NULL;
+	}
+
+	if (!_dev_read(dev, offset, len, reason, buf)) {
+		log_error("Read from %s failed", dev_name(dev));
+		dm_free(buf);
+		return NULL;
+	}
+
+	return buf;
+}
+
+/* Read into supplied retbuf */
+int dev_read_buf(struct device *dev, uint64_t offset, size_t len, dev_io_reason_t reason, void *retbuf)
+{
+	char *buf = NULL;
+
+	if (!(buf = dev_read(dev, offset, len, reason)))
+		return_0;
+	
+	memcpy(retbuf, buf, len);
+
+	dm_free(buf);
+
+	return 1;
+}
+
 /*
  * Read from 'dev' in 2 distinct regions, denoted by (offset,len) and (offset2,len2).
  * Caller is responsible for dm_free().
@@ -758,13 +792,13 @@ char *dev_read_circular(struct device *dev, uint64_t offset, size_t len,
 		return NULL;
 	}
 
-	if (!dev_read(dev, offset, len, reason, buf)) {
+	if (!_dev_read(dev, offset, len, reason, buf)) {
 		log_error("Read from %s failed", dev_name(dev));
 		dm_free(buf);
 		return NULL;
 	}
 
-	if (!dev_read(dev, offset2, len2, reason, buf + len)) {
+	if (!_dev_read(dev, offset2, len2, reason, buf + len)) {
 		log_error("Circular read from %s failed", dev_name(dev));
 		dm_free(buf);
 		return NULL;
diff --git a/lib/device/dev-luks.c b/lib/device/dev-luks.c
index 8513e14..f291615 100644
--- a/lib/device/dev-luks.c
+++ b/lib/device/dev-luks.c
@@ -31,7 +31,7 @@ int dev_is_luks(struct device *dev, uint64_t *offset_found)
 	if (offset_found)
 		*offset_found = 0;
 
-	if (!dev_read(dev, 0, LUKS_SIGNATURE_SIZE, DEV_IO_SIGNATURES, buf))
+	if (!dev_read_buf(dev, 0, LUKS_SIGNATURE_SIZE, DEV_IO_SIGNATURES, buf))
 		goto_out;
 
 	ret = memcmp(buf, LUKS_SIGNATURE, LUKS_SIGNATURE_SIZE) ? 0 : 1;
diff --git a/lib/device/dev-md.c b/lib/device/dev-md.c
index 92ee214..1a5d470 100644
--- a/lib/device/dev-md.c
+++ b/lib/device/dev-md.c
@@ -37,7 +37,7 @@ static int _dev_has_md_magic(struct device *dev, uint64_t sb_offset)
 	uint32_t md_magic;
 
 	/* Version 1 is little endian; version 0.90.0 is machine endian */
-	if (dev_read(dev, sb_offset, sizeof(uint32_t), DEV_IO_SIGNATURES, &md_magic) &&
+	if (dev_read_buf(dev, sb_offset, sizeof(uint32_t), DEV_IO_SIGNATURES, &md_magic) &&
 	    ((md_magic == MD_SB_MAGIC) ||
 	     ((MD_SB_MAGIC != xlate32(MD_SB_MAGIC)) && (md_magic == xlate32(MD_SB_MAGIC)))))
 		return 1;
diff --git a/lib/device/dev-swap.c b/lib/device/dev-swap.c
index a7ff10b..094eb05 100644
--- a/lib/device/dev-swap.c
+++ b/lib/device/dev-swap.c
@@ -60,8 +60,7 @@ int dev_is_swap(struct device *dev, uint64_t *offset_found)
 			continue;
 		if (size < (page >> SECTOR_SHIFT))
 			break;
-		if (!dev_read(dev, page - SIGNATURE_SIZE,
-			      SIGNATURE_SIZE, DEV_IO_SIGNATURES, buf)) {
+		if (!dev_read_buf(dev, page - SIGNATURE_SIZE, SIGNATURE_SIZE, DEV_IO_SIGNATURES, buf)) {
 			ret = -1;
 			break;
 		}
diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index 9608146..b9e77f8 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -363,7 +363,7 @@ static int _has_partition_table(struct device *dev)
 		uint16_t magic;
 	} __attribute__((packed)) buf; /* sizeof() == SECTOR_SIZE */
 
-	if (!dev_read(dev, UINT64_C(0), sizeof(buf), DEV_IO_SIGNATURES, &buf))
+	if (!dev_read_buf(dev, UINT64_C(0), sizeof(buf), DEV_IO_SIGNATURES, &buf))
 		return_0;
 
 	/* FIXME Check for other types of partition table too */
diff --git a/lib/device/device.h b/lib/device/device.h
index a369195..dac638c 100644
--- a/lib/device/device.h
+++ b/lib/device/device.h
@@ -145,9 +145,15 @@ int dev_test_excl(struct device *dev);
 int dev_fd(struct device *dev);
 const char *dev_name(const struct device *dev);
 
-int dev_read(struct device *dev, uint64_t offset, size_t len, dev_io_reason_t reason, void *buffer);
+/* Returns a read-only buffer */
+char *dev_read(struct device *dev, uint64_t offset, size_t len, dev_io_reason_t reason);
 char *dev_read_circular(struct device *dev, uint64_t offset, size_t len,
 			uint64_t offset2, size_t len2, dev_io_reason_t reason);
+
+/* Read data and copy it into a supplied private buffer. */
+/* Only use for tiny reads or on unimportant code paths. */
+int dev_read_buf(struct device *dev, uint64_t offset, size_t len, dev_io_reason_t reason, void *retbuf);
+
 int dev_write(struct device *dev, uint64_t offset, size_t len, dev_io_reason_t reason, void *buffer);
 int dev_append(struct device *dev, size_t len, dev_io_reason_t reason, char *buffer);
 int dev_set(struct device *dev, uint64_t offset, size_t len, dev_io_reason_t reason, int value);
diff --git a/lib/format1/disk-rep.c b/lib/format1/disk-rep.c
index 41955af..cf34e91 100644
--- a/lib/format1/disk-rep.c
+++ b/lib/format1/disk-rep.c
@@ -205,7 +205,7 @@ int munge_pvd(struct device *dev, struct pv_disk *pvd)
 
 static int _read_pvd(struct device *dev, struct pv_disk *pvd)
 {
-	if (!dev_read(dev, UINT64_C(0), sizeof(*pvd), DEV_IO_FMT1, pvd)) {
+	if (!dev_read_buf(dev, UINT64_C(0), sizeof(*pvd), DEV_IO_FMT1, pvd)) {
 		log_very_verbose("Failed to read PV data from %s",
 				 dev_name(dev));
 		return 0;
@@ -216,7 +216,7 @@ static int _read_pvd(struct device *dev, struct pv_disk *pvd)
 
 static int _read_lvd(struct device *dev, uint64_t pos, struct lv_disk *disk)
 {
-	if (!dev_read(dev, pos, sizeof(*disk), DEV_IO_FMT1, disk))
+	if (!dev_read_buf(dev, pos, sizeof(*disk), DEV_IO_FMT1, disk))
 		return_0;
 
 	_xlate_lvd(disk);
@@ -228,7 +228,7 @@ int read_vgd(struct device *dev, struct vg_disk *vgd, struct pv_disk *pvd)
 {
 	uint64_t pos = pvd->vg_on_disk.base;
 
-	if (!dev_read(dev, pos, sizeof(*vgd), DEV_IO_FMT1, vgd))
+	if (!dev_read_buf(dev, pos, sizeof(*vgd), DEV_IO_FMT1, vgd))
 		return_0;
 
 	_xlate_vgd(vgd);
@@ -252,7 +252,7 @@ static int _read_uuids(struct disk_list *data)
 	uint64_t end = pos + data->pvd.pv_uuidlist_on_disk.size;
 
 	while (pos < end && num_read < data->vgd.pv_cur) {
-		if (!dev_read(data->dev, pos, sizeof(buffer), DEV_IO_FMT1, buffer))
+		if (!dev_read_buf(data->dev, pos, sizeof(buffer), DEV_IO_FMT1, buffer))
 			return_0;
 
 		if (!(ul = dm_pool_alloc(data->mem, sizeof(*ul))))
@@ -311,7 +311,7 @@ static int _read_extents(struct disk_list *data)
 	if (!extents)
 		return_0;
 
-	if (!dev_read(data->dev, pos, len, DEV_IO_FMT1, extents))
+	if (!dev_read_buf(data->dev, pos, len, DEV_IO_FMT1, extents))
 		return_0;
 
 	_xlate_extents(extents, data->pvd.pe_total);
diff --git a/lib/format_pool/disk_rep.c b/lib/format_pool/disk_rep.c
index 374ff44..4b2e7fb 100644
--- a/lib/format_pool/disk_rep.c
+++ b/lib/format_pool/disk_rep.c
@@ -40,7 +40,7 @@ static int __read_pool_disk(const struct format_type *fmt, struct device *dev,
 	char buf[512] __attribute__((aligned(8)));
 
 	/* FIXME: Need to check the cache here first */
-	if (!dev_read(dev, UINT64_C(0), 512, DEV_IO_POOL, buf)) {
+	if (!dev_read_buf(dev, UINT64_C(0), 512, DEV_IO_POOL, buf)) {
 		log_very_verbose("Failed to read PV data from %s",
 				 dev_name(dev));
 		return 0;
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 79bb9fa..c57ffd2 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -182,7 +182,7 @@ static int _pv_analyze_mda_raw (const struct format_type * fmt,
 	uint64_t offset2;
 	size_t size;
 	size_t size2;
-	char *buf=NULL;
+	char *buf = NULL;
 	struct device_area *area;
 	struct mda_context *mdac;
 	unsigned circular = 0;
@@ -240,12 +240,8 @@ static int _pv_analyze_mda_raw (const struct format_type * fmt,
 		if (circular) {
 			if (!(buf = dev_read_circular(area->dev, offset, size, offset2, size2, MDA_CONTENT_REASON(mda_is_primary(mda)))))
 				goto_out;
-		} else {
-			if (!(buf = dm_malloc(size)))
-				goto_out;
-			if (!dev_read(area->dev, offset, size, MDA_CONTENT_REASON(mda_is_primary(mda)), buf))
+		} else if (!(buf = dev_read(area->dev, offset, size, MDA_CONTENT_REASON(mda_is_primary(mda)))))
 				goto_out;
-		}
 
 		/*
 		 * FIXME: We could add more sophisticated metadata detection
@@ -334,7 +330,7 @@ static int _raw_read_mda_header(struct mda_header *mdah, struct device_area *dev
 	if (!dev_open_readonly(dev_area->dev))
 		return_0;
 
-	if (!dev_read(dev_area->dev, dev_area->start, MDA_HEADER_SIZE, MDA_HEADER_REASON(primary_mda), mdah)) {
+	if (!dev_read_buf(dev_area->dev, dev_area->start, MDA_HEADER_SIZE, MDA_HEADER_REASON(primary_mda), mdah)) {
 		if (!dev_close(dev_area->dev))
 			stack;
 		return_0;
@@ -420,13 +416,13 @@ static struct raw_locn *_find_vg_rlocn(struct device_area *dev_area,
 				       int *precommitted)
 {
 	size_t len;
-	char vgnamebuf[NAME_LEN + 2] __attribute__((aligned(8)));
 	struct raw_locn *rlocn, *rlocn_precommitted;
 	struct lvmcache_info *info;
 	struct lvmcache_vgsummary vgsummary_orphan = {
 		.vgname = FMT_TEXT_ORPHAN_VG_NAME,
 	};
 	int rlocn_was_ignored;
+	char *buf;
 
 	memcpy(&vgsummary_orphan.vgid, FMT_TEXT_ORPHAN_VG_NAME, sizeof(FMT_TEXT_ORPHAN_VG_NAME));
 
@@ -461,13 +457,17 @@ static struct raw_locn *_find_vg_rlocn(struct device_area *dev_area,
 
 	/* FIXME Loop through rlocns two-at-a-time.  List null-terminated. */
 	/* FIXME Ignore if checksum incorrect!!! */
-	if (!dev_read(dev_area->dev, dev_area->start + rlocn->offset,
-		      sizeof(vgnamebuf), MDA_CONTENT_REASON(primary_mda), vgnamebuf))
+	if (!(buf = dev_read(dev_area->dev, dev_area->start + rlocn->offset,
+			     NAME_LEN + 2, MDA_CONTENT_REASON(primary_mda))))
 		goto_bad;
 
-	if (!strncmp(vgnamebuf, vgname, len = strlen(vgname)) &&
-	    (isspace(vgnamebuf[len]) || vgnamebuf[len] == '{'))
+	if (!strncmp(buf, vgname, len = strlen(vgname)) &&
+	    (isspace(*(buf + len)) || *(buf + len) == '{')) {
+		dm_free(buf);
 		return rlocn;
+	}
+
+	dm_free(buf);
 
 	log_debug_metadata("Volume group name found in %smetadata on %s at " FMTu64 " does "
 			   "not match expected name %s.", 
@@ -1332,8 +1332,8 @@ int vgname_from_mda(const struct format_type *fmt,
 	}
 
 	/* Do quick check for a vgname */
-	if (!dev_read(dev_area->dev, dev_area->start + rlocn->offset,
-		      NAME_LEN, MDA_CONTENT_REASON(primary_mda), buf))
+	if (!dev_read_buf(dev_area->dev, dev_area->start + rlocn->offset,
+			  NAME_LEN, MDA_CONTENT_REASON(primary_mda), buf))
 		return_0;
 
 	while (buf[len] && !isspace(buf[len]) && buf[len] != '{' &&
diff --git a/lib/label/label.c b/lib/label/label.c
index 249927b..b90fff3 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -109,7 +109,7 @@ static void _update_lvmcache_orphan(struct lvmcache_info *info)
 		stack;
 }
 
-static struct labeller *_find_labeller(struct device *dev, char *buf,
+static struct labeller *_find_labeller(struct device *dev, char *labelbuf,
 				       uint64_t *label_sector,
 				       uint64_t scan_sector)
 {
@@ -119,10 +119,9 @@ static struct labeller *_find_labeller(struct device *dev, char *buf,
 	struct lvmcache_info *info;
 	uint64_t sector;
 	int found = 0;
-	char readbuf[LABEL_SCAN_SIZE] __attribute__((aligned(8)));
+	char *buf = NULL;
 
-	if (!dev_read(dev, scan_sector << SECTOR_SHIFT,
-		      LABEL_SCAN_SIZE, DEV_IO_LABEL, readbuf)) {
+	if (!(buf = dev_read(dev, scan_sector << SECTOR_SHIFT, LABEL_SCAN_SIZE, DEV_IO_LABEL))) {
 		log_debug_devs("%s: Failed to read label area", dev_name(dev));
 		goto out;
 	}
@@ -130,8 +129,7 @@ static struct labeller *_find_labeller(struct device *dev, char *buf,
 	/* Scan a few sectors for a valid label */
 	for (sector = 0; sector < LABEL_SCAN_SECTORS;
 	     sector += LABEL_SIZE >> SECTOR_SHIFT) {
-		lh = (struct label_header *) (readbuf +
-					      (sector << SECTOR_SHIFT));
+		lh = (struct label_header *) (buf + (sector << SECTOR_SHIFT));
 
 		if (!strncmp((char *)lh->id, LABEL_ID, sizeof(lh->id))) {
 			if (found) {
@@ -173,7 +171,7 @@ static struct labeller *_find_labeller(struct device *dev, char *buf,
 					continue;
 				}
 				r = li->l;
-				memcpy(buf, lh, LABEL_SIZE);
+				memcpy(labelbuf, lh, LABEL_SIZE);
 				if (label_sector)
 					*label_sector = sector + scan_sector;
 				found = 1;
@@ -183,6 +181,8 @@ static struct labeller *_find_labeller(struct device *dev, char *buf,
 	}
 
       out:
+	dm_free(buf);
+
 	if (!found) {
 		if ((info = lvmcache_info_from_pvid(dev->pvid, dev, 0)))
 			_update_lvmcache_orphan(info);
@@ -195,16 +195,16 @@ static struct labeller *_find_labeller(struct device *dev, char *buf,
 /* FIXME Also wipe associated metadata area headers? */
 int label_remove(struct device *dev)
 {
-	char buf[LABEL_SIZE] __attribute__((aligned(8)));
-	char readbuf[LABEL_SCAN_SIZE] __attribute__((aligned(8)));
+	char labelbuf[LABEL_SIZE] __attribute__((aligned(8)));
 	int r = 1;
 	uint64_t sector;
 	int wipe;
 	struct labeller_i *li;
 	struct label_header *lh;
 	struct lvmcache_info *info;
+	char *buf = NULL;
 
-	memset(buf, 0, LABEL_SIZE);
+	memset(labelbuf, 0, LABEL_SIZE);
 
 	log_very_verbose("Scanning for labels to wipe from %s", dev_name(dev));
 
@@ -217,7 +217,7 @@ int label_remove(struct device *dev)
 	 */
 	dev_flush(dev);
 
-	if (!dev_read(dev, UINT64_C(0), LABEL_SCAN_SIZE, DEV_IO_LABEL, readbuf)) {
+	if (!(buf = dev_read(dev, UINT64_C(0), LABEL_SCAN_SIZE, DEV_IO_LABEL))) {
 		log_debug_devs("%s: Failed to read label area", dev_name(dev));
 		goto out;
 	}
@@ -225,8 +225,7 @@ int label_remove(struct device *dev)
 	/* Scan first few sectors for anything looking like a label */
 	for (sector = 0; sector < LABEL_SCAN_SECTORS;
 	     sector += LABEL_SIZE >> SECTOR_SHIFT) {
-		lh = (struct label_header *) (readbuf +
-					      (sector << SECTOR_SHIFT));
+		lh = (struct label_header *) (buf + (sector << SECTOR_SHIFT));
 
 		wipe = 0;
 
@@ -246,8 +245,7 @@ int label_remove(struct device *dev)
 		if (wipe) {
 			log_very_verbose("%s: Wiping label@sector %" PRIu64,
 					 dev_name(dev), sector);
-			if (dev_write(dev, sector << SECTOR_SHIFT, LABEL_SIZE, DEV_IO_LABEL,
-				       buf)) {
+			if (dev_write(dev, sector << SECTOR_SHIFT, LABEL_SIZE, DEV_IO_LABEL, labelbuf)) {
 				/* Also remove the PV record from cache. */
 				info = lvmcache_info_from_pvid(dev->pvid, dev, 0);
 				if (info)
@@ -265,6 +263,7 @@ int label_remove(struct device *dev)
 	if (!dev_close(dev))
 		stack;
 
+	dm_free(buf);
 	return r;
 }
 


