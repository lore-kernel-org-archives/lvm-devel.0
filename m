From: David Teigland <teigland@sourceware.org>
Date: Mon, 23 Apr 2018 09:55:21 -0400
Subject: master - bcache: do all writes through bcache
Message-ID: <201804231355.w3NDtLRS001690@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=80654920468841251a7f940e410ca61de8383b41
Commit:        80654920468841251a7f940e410ca61de8383b41
Parent:        8b26a007b1b545333b40675b1c425b1ef5e0b653
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Feb 19 15:40:44 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 20 11:22:47 2018 -0500

bcache: do all writes through bcache

---
 lib/device/bcache.c           |   86 ++++++++++++++++++++++++++++++-
 lib/device/bcache.h           |    4 +-
 lib/device/dev-type.c         |    6 ++-
 lib/format_text/archiver.c    |   10 +---
 lib/format_text/format-text.c |   94 +++++++++++++---------------------
 lib/label/label.c             |  112 +++++++++++++++++++----------------------
 lib/label/label.h             |    1 +
 lib/metadata/metadata.c       |   19 +++----
 tools/toollib.c               |   17 ++----
 9 files changed, 193 insertions(+), 156 deletions(-)

diff --git a/lib/device/bcache.c b/lib/device/bcache.c
index 499c6af..272de60 100644
--- a/lib/device/bcache.c
+++ b/lib/device/bcache.c
@@ -897,7 +897,7 @@ bool bcache_get(struct bcache *cache, int fd, block_address index,
 	return false;
 }
 
-void bcache_put(struct block *b)
+static void _put_ref(struct block *b)
 {
 	if (!b->ref_count) {
 		log_warn("ref count on bcache block already zero");
@@ -907,6 +907,11 @@ void bcache_put(struct block *b)
 	b->ref_count--;
 	if (!b->ref_count)
 		b->cache->nr_locked--;
+}
+
+void bcache_put(struct block *b)
+{
+	_put_ref(b);
 
 	if (_test_flags(b, BF_DIRTY))
 		_preemptive_writeback(b->cache);
@@ -925,7 +930,7 @@ bool bcache_flush(struct bcache *cache)
 			// The superblock may well be still locked.
 			continue;
 		}
-
+		
 		_issue_write(b);
 	}
 
@@ -1058,5 +1063,82 @@ bool bcache_read_bytes(struct bcache *cache, int fd, off_t start, size_t len, vo
 	return errors ? false : true;
 }
 
+bool bcache_write_bytes(struct bcache *cache, int fd, off_t start, size_t len, void *data)
+{
+	struct block *b;
+	block_address bb, be, i;
+	unsigned char *udata = data;
+	off_t block_size = cache->block_sectors << SECTOR_SHIFT;
+	int errors = 0;
+
+	byte_range_to_block_range(cache, start, len, &bb, &be);
+	for (i = bb; i < be; i++)
+		bcache_prefetch(cache, fd, i);
+
+	for (i = bb; i < be; i++) {
+		if (!bcache_get(cache, fd, i, 0, &b)) {
+			errors++;
+			break;
+		}
+
+		if (i == bb) {
+			off_t block_offset = start % block_size;
+			size_t blen = _min(block_size - block_offset, len);
+			memcpy(((unsigned char *) b->data) + block_offset, udata, blen);
+			len -= blen;
+			udata += blen;
+		} else {
+			size_t blen = _min(block_size, len);
+			memcpy(b->data, udata, blen);
+			len -= blen;
+			udata += blen;
+		}
+
+		_set_flags(b, BF_DIRTY);
+		_unlink_block(b);
+		_link_block(b);
+		_put_ref(b);
+	}
+
+	if (!bcache_flush(cache))
+		errors++;
+
+	return errors ? false : true;
+}
+
+#define ZERO_BUF_LEN 4096
+
+bool bcache_write_zeros(struct bcache *cache, int fd, off_t start, size_t len)
+{
+	char zerobuf[ZERO_BUF_LEN];
+	size_t plen;
+	size_t poff;
+
+	memset(zerobuf, 0, sizeof(zerobuf));
+
+	if (len <= ZERO_BUF_LEN)
+		return bcache_write_bytes(cache, fd, start, len, &zerobuf);
+
+	poff = 0;
+	plen = ZERO_BUF_LEN;
+
+	while (1) {
+		if (!bcache_write_bytes(cache, fd, start + poff, plen, &zerobuf))
+			return false;
+
+		poff += plen;
+		len -= plen;
+
+		if (!len)
+			break;
+
+		if (len < ZERO_BUF_LEN)
+			plen = len;
+	}
+
+	return true;
+}
+
+
 //----------------------------------------------------------------
 
diff --git a/lib/device/bcache.h b/lib/device/bcache.h
index e5d98e8..d5f6d0a 100644
--- a/lib/device/bcache.h
+++ b/lib/device/bcache.h
@@ -148,9 +148,11 @@ void bcache_invalidate_fd(struct bcache *cache, int fd);
 void bcache_prefetch_bytes(struct bcache *cache, int fd, off_t start, size_t len);
 
 /*
- * Reads the bytes.
+ * Reads and writes the bytes.  Returns false if errors occur.
  */
 bool bcache_read_bytes(struct bcache *cache, int fd, off_t start, size_t len, void *data);
+bool bcache_write_bytes(struct bcache *cache, int fd, off_t start, size_t len, void *data);
+bool bcache_write_zeros(struct bcache *cache, int fd, off_t start, size_t len);
 
 /*----------------------------------------------------------------*/
 
diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index 9608146..e69f7ca 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -17,6 +17,8 @@
 #include "xlate.h"
 #include "config.h"
 #include "metadata.h"
+#include "bcache.h"
+#include "label.h"
 
 #include <libgen.h>
 #include <ctype.h>
@@ -675,7 +677,7 @@ static int _blkid_wipe(blkid_probe probe, struct device *dev, const char *name,
 	} else
 		log_verbose(_msg_wiping, type, name);
 
-	if (!dev_set(dev, offset_value, len, DEV_IO_SIGNATURES, 0)) {
+	if (!bcache_write_zeros(scan_bcache, dev->bcache_fd, offset_value, len)) {
 		log_error("Failed to wipe %s signature on %s.", type, name);
 		return 0;
 	}
@@ -772,7 +774,7 @@ static int _wipe_signature(struct device *dev, const char *type, const char *nam
 	}
 
 	log_print_unless_silent("Wiping %s on %s.", type, name);
-	if (!dev_set(dev, offset_found, wipe_len, DEV_IO_SIGNATURES, 0)) {
+	if (!bcache_write_zeros(scan_bcache, dev->bcache_fd, offset_found, wipe_len)) {
 		log_error("Failed to wipe %s on %s.", type, name);
 		return 0;
 	}
diff --git a/lib/format_text/archiver.c b/lib/format_text/archiver.c
index 81b5da9..43ae4eb 100644
--- a/lib/format_text/archiver.c
+++ b/lib/format_text/archiver.c
@@ -488,19 +488,11 @@ int backup_restore_vg(struct cmd_context *cmd, struct volume_group *vg,
 			}
 
 			log_verbose("Zeroing start of device %s", pv_name);
-			if (!dev_open_quiet(dev)) {
-				log_error("%s not opened: device not zeroed", pv_name);
-				return 0;
-			}
 
-			if (!dev_set(dev, UINT64_C(0), (size_t) 2048, DEV_IO_LABEL, 0)) {
+			if (!bcache_write_zeros(scan_bcache, dev->bcache_fd, 0, 2048)) {
 				log_error("%s not wiped: aborting", pv_name);
-				if (!dev_close(dev))
-					stack;
 				return 0;
 			}
-			if (!dev_close(dev))
-				stack;
 		}
 	}
 
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index ef59f07..4eef72e 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -330,8 +330,6 @@ static int _raw_read_mda_header(struct mda_header *mdah, struct device_area *dev
 	log_debug_metadata("Reading mda header sector from %s at %llu",
 			   dev_name(dev_area->dev), (unsigned long long)dev_area->start);
 
-	label_scan_confirm(dev_area->dev);  /* FIXME: remove this, ensures dev is in bcache */
-
 	if (!bcache_read_bytes(scan_bcache, dev_area->dev->bcache_fd, dev_area->start, MDA_HEADER_SIZE, mdah)) {
 		log_error("Failed to read metadata area header on %s at %llu",
 			  dev_name(dev_area->dev), (unsigned long long)dev_area->start);
@@ -397,24 +395,16 @@ static int _raw_write_mda_header(const struct format_type *fmt,
 	mdah->version = FMTT_VERSION;
 	mdah->start = start_byte;
 
-	label_scan_invalidate(dev);
-
-	if (!dev_open(dev))
-		return_0;
-
 	_xlate_mdah(mdah);
 	mdah->checksum_xl = xlate32(calc_crc(INITIAL_CRC, (uint8_t *)mdah->magic,
 					     MDA_HEADER_SIZE -
 					     sizeof(mdah->checksum_xl)));
 
-	if (!dev_write(dev, start_byte, MDA_HEADER_SIZE, MDA_HEADER_REASON(primary_mda), mdah)) {
-		dev_close(dev);
-		return_0;
+	if (!bcache_write_bytes(scan_bcache, dev->bcache_fd, start_byte, MDA_HEADER_SIZE, mdah)) {
+		log_error("Failed to write mda header to %s fd %d", dev_name(dev), dev->bcache_fd);
+		return 0;
 	}
 
-	if (dev_close(dev))
-		stack;
-
 	return 1;
 }
 
@@ -474,8 +464,6 @@ static struct raw_locn *_read_metadata_location_vg(struct device_area *dev_area,
 	 */
 	memset(vgnamebuf, 0, sizeof(vgnamebuf));
 
-	label_scan_confirm(dev_area->dev);  /* FIXME: remove this, ensures dev is in bcache */
-
 	bcache_read_bytes(scan_bcache, dev_area->dev->bcache_fd, dev_area->start + rlocn->offset, NAME_LEN, vgnamebuf);
 
 	if (!strncmp(vgnamebuf, vgname, len = strlen(vgname)) &&
@@ -681,30 +669,32 @@ static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 		goto out;
 	}
 
-	log_debug_metadata("Writing %s metadata to %s at " FMTu64 " len " FMTu64 " of " FMTu64,
-			    vg->name, dev_name(mdac->area.dev), mdac->area.start +
-			    mdac->rlocn.offset, mdac->rlocn.size - new_wrap, mdac->rlocn.size);
-
-	label_scan_invalidate(mdac->area.dev);
-
-	if (!dev_open(mdac->area.dev))
-		return_0;
+	log_debug_metadata("Writing metadata for VG %s to %s at %llu len %llu (wrap %llu)", 
+			    vg->name, dev_name(mdac->area.dev),
+			    (unsigned long long)(mdac->area.start + mdac->rlocn.offset),
+			    (unsigned long long)(mdac->rlocn.size - new_wrap),
+			    (unsigned long long)new_wrap);
 
-	/* Write text out, circularly */
-	if (!dev_write(mdac->area.dev, mdac->area.start + mdac->rlocn.offset,
-		       (size_t) (mdac->rlocn.size - new_wrap), MDA_CONTENT_REASON(mda_is_primary(mda)),
-		       fidtc->raw_metadata_buf))
-		goto_out;
+	if (!bcache_write_bytes(scan_bcache, mdac->area.dev->bcache_fd, mdac->area.start + mdac->rlocn.offset,
+		                (size_t) (mdac->rlocn.size - new_wrap),
+		                fidtc->raw_metadata_buf)) {
+		log_error("Failed to write metadata to %s fd %d", dev_name(mdac->area.dev), mdac->area.dev->bcache_fd);
+		goto out;
+	}
 
 	if (new_wrap) {
-		log_debug_metadata("Writing wrapped metadata to %s at " FMTu64 " len " FMTu64 " of " FMTu64,
-				  dev_name(mdac->area.dev), mdac->area.start +
-				  MDA_HEADER_SIZE, new_wrap, mdac->rlocn.size);
-
-		if (!dev_write(mdac->area.dev, mdac->area.start + MDA_HEADER_SIZE,
-			       (size_t) new_wrap, MDA_CONTENT_REASON(mda_is_primary(mda)),
-			       fidtc->raw_metadata_buf + mdac->rlocn.size - new_wrap))
-			goto_out;
+		log_debug_metadata("Writing metadata for VG %s to %s at %llu len %llu (wrapped)",
+				   vg->name, dev_name(mdac->area.dev),
+				   (unsigned long long)(mdac->area.start + MDA_HEADER_SIZE),
+				   (unsigned long long)new_wrap);
+
+		if (!bcache_write_bytes(scan_bcache, mdac->area.dev->bcache_fd,
+			                mdac->area.start + MDA_HEADER_SIZE,
+			                (size_t) new_wrap,
+			                fidtc->raw_metadata_buf + mdac->rlocn.size - new_wrap)) {
+			log_error("Failed to write metadata wrap to %s fd %d", dev_name(mdac->area.dev), mdac->area.dev->bcache_fd);
+			goto out;
+		}
 	}
 
 	mdac->rlocn.checksum = calc_crc(INITIAL_CRC, (uint8_t *)fidtc->raw_metadata_buf,
@@ -720,9 +710,6 @@ static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 
       out:
 	if (!r) {
-		if (!dev_close(mdac->area.dev))
-			stack;
-
 		dm_free(fidtc->raw_metadata_buf);
 		fidtc->raw_metadata_buf = NULL;
 	}
@@ -819,9 +806,6 @@ static int _vg_commit_raw_rlocn(struct format_instance *fid,
 
       out:
 	if (!precommit) {
-		if (!dev_close(mdac->area.dev))
-			stack;
-
 		dm_free(fidtc->raw_metadata_buf);
 		fidtc->raw_metadata_buf = NULL;
 	}
@@ -904,9 +888,6 @@ static int _vg_remove_raw(struct format_instance *fid, struct volume_group *vg,
 	rlocn->checksum = 0;
 	rlocn_set_ignored(mdah->raw_locns, mda_is_ignored(mda));
 
-	if (!dev_open(mdac->area.dev))
-		return_0;
-
 	if (!_raw_write_mda_header(fid->fmt, mdac->area.dev, mda_is_primary(mda), mdac->area.start,
 				   mdah)) {
 		dm_pool_free(fid->fmt->cmd->mem, mdah);
@@ -917,9 +898,6 @@ static int _vg_remove_raw(struct format_instance *fid, struct volume_group *vg,
 	r = 1;
 
       out:
-	if (!dev_close(mdac->area.dev))
-		stack;
-
 	return r;
 }
 
@@ -1239,8 +1217,6 @@ int read_metadata_location_summary(const struct format_type *fmt,
 		return 0;
 	}
 
-	label_scan_confirm(dev_area->dev);  /* FIXME: remove this, ensures dev is in bcache */
-
 	bcache_read_bytes(scan_bcache, dev_area->dev->bcache_fd, dev_area->start + rlocn->offset, NAME_LEN, buf);
 
 	while (buf[len] && !isspace(buf[len]) && buf[len] != '{' &&
@@ -1397,8 +1373,6 @@ static int _write_single_mda(struct metadata_area *mda, void *baton)
 
 	if (!_raw_write_mda_header(p->fmt, mdac->area.dev, mda_is_primary(mda),
 				   mdac->area.start, mdah)) {
-		if (!dev_close(p->pv->dev))
-			stack;
 		return_0;
 	}
 	return 1;
@@ -2123,6 +2097,7 @@ static int _text_pv_add_metadata_area(const struct format_type *fmt,
 	uint64_t mda_start;
 	uint64_t adjustment, limit, tmp_mda_size;
 	uint64_t wipe_size = 8 << SECTOR_SHIFT;
+	uint64_t zero_len;
 	size_t page_size = lvm_getpagesize();
 	struct metadata_area *mda;
 	struct mda_context *mdac;
@@ -2330,13 +2305,14 @@ static int _text_pv_add_metadata_area(const struct format_type *fmt,
 		}
 
 		/* Wipe metadata area with zeroes. */
-		if (!dev_set(pv->dev, mda_start,
-			     (size_t) ((mda_size > wipe_size) ?  wipe_size : mda_size),
-			     MDA_HEADER_REASON(!mda_index), 0)) {
-			log_error("Failed to wipe new metadata area "
-				  "at the %s of the %s",
-				   mda_index ? "end" : "start",
-				   pv_dev_name(pv));
+
+		zero_len = (mda_size > wipe_size) ? wipe_size : mda_size;
+
+		if (!bcache_write_zeros(scan_bcache, pv->dev->bcache_fd, mda_start, zero_len)) {
+			log_error("Failed to wipe new metadata area on %s at %llu len %llu",
+				   pv_dev_name(pv),
+				   (unsigned long long)mda_start,
+				   (unsigned long long)zero_len);
 			return 0;
 		}
 
diff --git a/lib/label/label.c b/lib/label/label.c
index 278f26a..67d441b 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -104,8 +104,7 @@ struct labeller *label_get_handler(const char *name)
 /* FIXME Also wipe associated metadata area headers? */
 int label_remove(struct device *dev)
 {
-	char buf[LABEL_SIZE] __attribute__((aligned(8)));
-	char readbuf[LABEL_SCAN_SIZE] __attribute__((aligned(8)));
+	char readbuf[LABEL_SIZE] __attribute__((aligned(8)));
 	int r = 1;
 	uint64_t sector;
 	int wipe;
@@ -113,31 +112,27 @@ int label_remove(struct device *dev)
 	struct label_header *lh;
 	struct lvmcache_info *info;
 
-	memset(buf, 0, LABEL_SIZE);
-
 	log_very_verbose("Scanning for labels to wipe from %s", dev_name(dev));
 
-	label_scan_invalidate(dev);
-
-	if (!dev_open(dev))
-		return_0;
-
-	/*
-	 * We flush the device just in case someone is stupid
-	 * enough to be trying to import an open pv into lvm.
-	 */
-	dev_flush(dev);
-
-	if (!dev_read(dev, UINT64_C(0), LABEL_SCAN_SIZE, DEV_IO_LABEL, readbuf)) {
-		log_debug_devs("%s: Failed to read label area", dev_name(dev));
-		goto out;
+	if (!label_scan_open(dev)) {
+		log_error("Failed to open device %s", dev_name(dev));
+		return 0;
 	}
 
 	/* Scan first few sectors for anything looking like a label */
 	for (sector = 0; sector < LABEL_SCAN_SECTORS;
 	     sector += LABEL_SIZE >> SECTOR_SHIFT) {
-		lh = (struct label_header *) (readbuf +
-					      (sector << SECTOR_SHIFT));
+
+		memset(readbuf, 0, sizeof(readbuf));
+
+		if (!bcache_read_bytes(scan_bcache, dev->bcache_fd,
+				       sector << SECTOR_SHIFT, LABEL_SIZE, readbuf)) {
+			log_error("Failed to read label from %s sector %llu",
+				  dev_name(dev), (unsigned long long)sector);
+			continue;
+		}
+
+		lh = (struct label_header *)readbuf;
 
 		wipe = 0;
 
@@ -146,8 +141,7 @@ int label_remove(struct device *dev)
 				wipe = 1;
 		} else {
 			dm_list_iterate_items(li, &_labellers) {
-				if (li->l->ops->can_handle(li->l, (char *) lh,
-							   sector)) {
+				if (li->l->ops->can_handle(li->l, (char *)lh, sector)) {
 					wipe = 1;
 					break;
 				}
@@ -155,27 +149,24 @@ int label_remove(struct device *dev)
 		}
 
 		if (wipe) {
-			log_very_verbose("%s: Wiping label at sector %" PRIu64,
-					 dev_name(dev), sector);
-			if (dev_write(dev, sector << SECTOR_SHIFT, LABEL_SIZE, DEV_IO_LABEL,
-				       buf)) {
+			log_very_verbose("%s: Wiping label@sector %llu",
+					 dev_name(dev), (unsigned long long)sector);
+
+			if (!bcache_write_zeros(scan_bcache, dev->bcache_fd,
+						sector << SECTOR_SHIFT, LABEL_SIZE)) {
+				log_error("Failed to remove label from %s@sector %llu",
+					  dev_name(dev), (unsigned long long)sector);
+				r = 0;
+			} else {
 				/* Also remove the PV record from cache. */
 				info = lvmcache_info_from_pvid(dev->pvid, dev, 0);
 				if (info)
 					lvmcache_del(info);
-			} else {
-				log_error("Failed to remove label from %s at "
-					  "sector %" PRIu64, dev_name(dev),
-					  sector);
-				r = 0;
 			}
 		}
 	}
 
       out:
-	if (!dev_close(dev))
-		stack;
-
 	return r;
 }
 
@@ -197,8 +188,6 @@ int label_write(struct device *dev, struct label *label)
 		return 0;
 	}
 
-	label_scan_invalidate(dev);
-
 	memset(buf, 0, LABEL_SIZE);
 
 	strncpy((char *)lh->id, LABEL_ID, sizeof(lh->id));
@@ -211,20 +200,21 @@ int label_write(struct device *dev, struct label *label)
 	lh->crc_xl = xlate32(calc_crc(INITIAL_CRC, (uint8_t *)&lh->offset_xl, LABEL_SIZE -
 				      ((uint8_t *) &lh->offset_xl - (uint8_t *) lh)));
 
-	if (!dev_open(dev))
-		return_0;
-
 	log_very_verbose("%s: Writing label to sector %" PRIu64 " with stored offset %"
 			 PRIu32 ".", dev_name(dev), label->sector,
 			 xlate32(lh->offset_xl));
-	if (!dev_write(dev, label->sector << SECTOR_SHIFT, LABEL_SIZE, DEV_IO_LABEL, buf)) {
+
+	if (!label_scan_open(dev)) {
+		log_error("Failed to open device %s", dev_name(dev));
+		return 0;
+	}
+
+	if (!bcache_write_bytes(scan_bcache, dev->bcache_fd,
+				label->sector << SECTOR_SHIFT, LABEL_SIZE, buf)) {
 		log_debug_devs("Failed to write label to %s", dev_name(dev));
 		r = 0;
 	}
 
-	if (!dev_close(dev))
-		stack;
-
 	return r;
 }
 
@@ -763,8 +753,10 @@ void label_scan_destroy(struct cmd_context *cmd)
 		return;
 	}
 
-	while ((dev = dev_iter_get(iter)))
-		label_scan_invalidate(dev);
+	while ((dev = dev_iter_get(iter))) {
+		if (_in_bcache(dev))
+			_scan_dev_close(dev);
+	}
 	dev_iter_destroy(iter);
 
 	bcache_destroy(scan_bcache);
@@ -834,22 +826,6 @@ int label_read_sector(struct device *dev, struct label **labelp, uint64_t scan_s
 }
 
 /*
- * FIXME: remove this.  It should not be needed once writes are going through
- * bcache.  As it is now, the write path involves multiple writes to a device,
- * and later writes want to read previous writes from disk.  They do these
- * reads using the standard read paths which require the devs to be in bcache,
- * but the bcache reads do not find the dev because the writes have gone around
- * bcache.  To work around this for now, check if each dev is in bcache before
- * reading it, and if not add it first.
- */
-
-void label_scan_confirm(struct device *dev)
-{
-	if (!_in_bcache(dev))
-		label_read(dev, NULL, 0);
-}
-
-/*
  * This is only needed when commands are using lvmetad, in which case they
  * don't do an initial label_scan, but may later need to rescan certain devs
  * from disk and call this function.  FIXME: is there some better number to
@@ -866,3 +842,17 @@ int label_scan_setup_bcache(void)
 	return 1;
 }
 
+/*
+ * This is needed to write to a new non-lvm device.
+ * Scanning that dev would not keep it open or in
+ * bcache, but to use bcache_write we need the dev
+ * to be open so we can use dev->bcache_fd to write.
+ */
+
+int label_scan_open(struct device *dev)
+{
+	if (!_in_bcache(dev))
+		return _scan_dev_open(dev);
+	return 1;
+}
+
diff --git a/lib/label/label.h b/lib/label/label.h
index bf6e926..92f3e7b 100644
--- a/lib/label/label.h
+++ b/lib/label/label.h
@@ -112,5 +112,6 @@ int label_read(struct device *dev, struct label **labelp, uint64_t unused_sector
 int label_read_sector(struct device *dev, struct label **labelp, uint64_t scan_sector);
 void label_scan_confirm(struct device *dev);
 int label_scan_setup_bcache(void);
+int label_scan_open(struct device *dev);
 
 #endif
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index b588a04..4cad2a1 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -692,6 +692,7 @@ int check_pv_dev_sizes(struct volume_group *vg)
  * . lvmcache_get_vgids()
  * . lvmcache_get_vgnames()
  * . the vg->pvs_to_write list and pv_to_write struct
+ * . _pvcreate_write()
  */
 
 int vg_extend_each_pv(struct volume_group *vg, struct pvcreate_params *pp)
@@ -1414,28 +1415,24 @@ static int _pvcreate_write(struct cmd_context *cmd, struct pv_to_write *pvw)
 	struct device *dev = pv->dev;
 	const char *pv_name = dev_name(dev);
 
+	if (!label_scan_open(dev)) {
+		log_error("%s not opened: device not written", pv_name);
+		return 0;
+	}
+
 	if (pvw->new_pv) {
 		/* Wipe existing label first */
-		if (!label_remove(pv_dev(pv))) {
+		if (!label_remove(dev)) {
 			log_error("Failed to wipe existing label on %s", pv_name);
 			return 0;
 		}
 
 		if (pvw->pp->zero) {
 			log_verbose("Zeroing start of device %s", pv_name);
-			if (!dev_open_quiet(dev)) {
-				log_error("%s not opened: device not zeroed", pv_name);
-				return 0;
-			}
-
-			if (!dev_set(dev, UINT64_C(0), (size_t) 2048, DEV_IO_LABEL, 0)) {
+			if (!bcache_write_zeros(scan_bcache, dev->bcache_fd, 0, 2048)) {
 				log_error("%s not wiped: aborting", pv_name);
-				if (!dev_close(dev))
-					stack;
 				return 0;
 			}
-			if (!dev_close(dev))
-				stack;
 		}
 	}
 
diff --git a/tools/toollib.c b/tools/toollib.c
index 623bfbb..b0c0e8e 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -5728,6 +5728,8 @@ do_command:
 	 * Wipe signatures on devices being created.
 	 */
 	dm_list_iterate_items_safe(pd, pd2, &pp->arg_create) {
+		label_scan_open(pd->dev);
+
 		log_verbose("Wiping signatures on new PV %s.", pd->name);
 
 		if (!wipe_known_signatures(cmd, pd->dev, pd->name, TYPE_LVM1_MEMBER | TYPE_LVM2_MEMBER,
@@ -5805,6 +5807,8 @@ do_command:
 
 		pv_name = pd->name;
 
+		label_scan_open(pd->dev);
+
 		log_debug("Creating a new PV on %s.", pv_name);
 
 		if (!(pv = pv_create(cmd, pd->dev, &pp->pva))) {
@@ -5816,6 +5820,7 @@ do_command:
 		log_verbose("Set up physical volume for \"%s\" with %" PRIu64
 			    " available sectors.", pv_name, pv_size(pv));
 
+
 		if (!label_remove(pv->dev)) {
 			log_error("Failed to wipe existing label on %s.", pv_name);
 			dm_list_move(&pp->arg_fail, &pd->list);
@@ -5825,21 +5830,11 @@ do_command:
 		if (pp->zero) {
 			log_verbose("Zeroing start of device %s.", pv_name);
 
-			if (!dev_open_quiet(pv->dev)) {
-				log_error("%s not opened: device not zeroed.", pv_name);
-				dm_list_move(&pp->arg_fail, &pd->list);
-				continue;
-			}
-
-			if (!dev_set(pv->dev, UINT64_C(0), (size_t) 2048, DEV_IO_LABEL, 0)) {
+			if (!bcache_write_zeros(scan_bcache, pv->dev->bcache_fd, 0, 2048)) {
 				log_error("%s not wiped: aborting.", pv_name);
-				if (!dev_close(pv->dev))
-					stack;
 				dm_list_move(&pp->arg_fail, &pd->list);
 				continue;
 			}
-			if (!dev_close(pv->dev))
-				stack;
 		}
 
 		log_verbose("Writing physical volume data to disk \"%s\".", pv_name);


