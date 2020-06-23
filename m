From: David Teigland <teigland@sourceware.org>
Date: Tue, 23 Jun 2020 16:43:48 +0000 (GMT)
Subject: stable-2.02 - scanning: optimize by checking text offset and checksum
Message-ID: <20200623164348.8C8C63840C2A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1fb7a9d9e53cbde38250bb9ece72a25191899b78
Commit:        1fb7a9d9e53cbde38250bb9ece72a25191899b78
Parent:        7ea50a47d15dea016f252a5940c6aa5c0d598bb6
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Jun 1 16:22:09 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jun 23 11:32:32 2020 -0500

scanning: optimize by checking text offset and checksum

stable backport of 0c1316cda876849d5d1375d40e8cdc08db37c2b5
which includes a number of extra supporting functions.

In stable, the optimization is only applied to reporting
and display commands, so this change applies only to those
cases.

After the VG lock is taken for vg_read, reread the mda_header
from disk and compare the metadata text offset and checksum
to what was seen during label scan.  If it is unchanged, then
the metadata has not changed since the label scan, and the
metadata does not need to be reread under the lock for command
processing. If it is changed, then reread the metadata from disk.

This fixes a problem with the original optimization where lvm
reuses cached data from the label_scan phase for vg_read. This
works if the mda_header and metadata text are both read from
cache, or both read from disk, but in some cases the mda_header
could have been dropped from the cache and read from disk, while
the metadata blocks remained in the cache and were not read from
disk. If in addition to this, another concurrent command happened
to update the metadata between the label_scan and vg_read, then
the new mda_header from disk would refer to cached blocks that did
not contain the new metadata text. This would cause the lvm command
report an error about invalid metadata.
---
 lib/cache/lvmcache.c          |  24 +++++++++
 lib/cache/lvmcache.h          |   4 ++
 lib/device/bcache-utils.c     |  15 ++++++
 lib/device/bcache.h           |   1 +
 lib/format_text/format-text.c |  16 +++++-
 lib/format_text/layout.h      |   2 +-
 lib/format_text/text_label.c  |   2 +-
 lib/label/label.c             |   5 ++
 lib/label/label.h             |   1 +
 lib/metadata/metadata.c       | 117 +++++++++++++++++++++++++++++++++++++++++-
 lib/metadata/metadata.h       |   4 +-
 11 files changed, 186 insertions(+), 5 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index c12ec2b0c..ed605dc0f 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -3064,3 +3064,27 @@ uint64_t lvmcache_max_metadata_size(void)
 	return _max_metadata_size;
 }
 
+void lvmcache_get_mdas(struct cmd_context *cmd,
+		       const char *vgname, const char *vgid,
+                       struct dm_list *mda_list)
+{
+	struct lvmcache_vginfo *vginfo;
+	struct lvmcache_info *info;
+	struct mda_list *mdal;
+	struct metadata_area *mda, *mda2;
+
+	if (!(vginfo = lvmcache_vginfo_from_vgname(vgname, vgid))) {
+		log_error(INTERNAL_ERROR "lvmcache_get_mdas no vginfo %s", vgname);
+		return;
+	}
+
+	dm_list_iterate_items(info, &vginfo->infos) {
+		dm_list_iterate_items_safe(mda, mda2, &info->mdas) {
+			if (!(mdal = dm_zalloc(sizeof(*mdal))))
+				continue;
+			mdal->mda = mda;
+			dm_list_add(mda_list, &mdal->list);
+		}
+	}
+}
+
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index f43678507..541e8bee5 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -228,4 +228,8 @@ void lvmcache_drop_saved_vgid(const char *vgid);
 uint64_t lvmcache_max_metadata_size(void);
 void lvmcache_save_metadata_size(uint64_t val);
 
+void lvmcache_get_mdas(struct cmd_context *cmd,
+                       const char *vgname, const char *vgid,
+                       struct dm_list *mda_list);
+
 #endif
diff --git a/lib/device/bcache-utils.c b/lib/device/bcache-utils.c
index a533a66ee..2f0b01d13 100644
--- a/lib/device/bcache-utils.c
+++ b/lib/device/bcache-utils.c
@@ -79,6 +79,21 @@ bool bcache_read_bytes(struct bcache *cache, int fd, uint64_t start, size_t len,
 	return true;
 }
 
+bool bcache_invalidate_bytes(struct bcache *cache, int fd, uint64_t start, size_t len)
+{
+	block_address bb, be;
+	bool result = true;
+
+	byte_range_to_block_range(cache, start, len, &bb, &be);
+
+	for (; bb != be; bb++) {
+		if (!bcache_invalidate(cache, fd, bb))
+			result = false;
+	}
+
+	return result;
+}
+
 //----------------------------------------------------------------
 
 // Writing bytes and zeroing bytes are very similar, so we factor out
diff --git a/lib/device/bcache.h b/lib/device/bcache.h
index c5e6da1ad..e22755ed5 100644
--- a/lib/device/bcache.h
+++ b/lib/device/bcache.h
@@ -163,6 +163,7 @@ bool bcache_read_bytes(struct bcache *cache, int fd, uint64_t start, size_t len,
 bool bcache_write_bytes(struct bcache *cache, int fd, uint64_t start, size_t len, void *data);
 bool bcache_zero_bytes(struct bcache *cache, int fd, uint64_t start, size_t len);
 bool bcache_set_bytes(struct bcache *cache, int fd, uint64_t start, size_t len, uint8_t val);
+bool bcache_invalidate_bytes(struct bcache *cache, int fd, uint64_t start, size_t len);
 
 void bcache_set_last_byte(struct bcache *cache, int fd, uint64_t offset, int sector_size);
 void bcache_unset_last_byte(struct bcache *cache, int fd);
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 026f93a13..225d6424c 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1199,6 +1199,7 @@ static int _scan_file(const struct format_type *fmt, const char *vgname)
 }
 
 int read_metadata_location_summary(const struct format_type *fmt,
+		    struct metadata_area *mda,
 		    struct mda_header *mdah, int primary_mda, struct device_area *dev_area,
 		    struct lvmcache_vgsummary *vgsummary, uint64_t *mda_free_sectors)
 {
@@ -1251,6 +1252,19 @@ int read_metadata_location_summary(const struct format_type *fmt,
 		return 0;
 	}
 
+	/*
+	 * This function is used to read the vg summary during label scan.
+	 * Save the text start location and checksum during scan.  After the VG
+	 * lock is acquired in vg_read, we can reread the mda_header, and
+	 * compare rlocn->offset,checksum to what was saved during scan.  If
+	 * unchanged, it means that the metadata was not changed between scan
+	 * and the read.
+	 */
+	if (mda) {
+		mda->scan_text_offset = rlocn->offset;
+		mda->scan_text_checksum = rlocn->checksum;
+	}
+
 	/* We found a VG - now check the metadata */
 	if (rlocn->offset + rlocn->size > mdah->size)
 		wrap = (uint32_t) ((rlocn->offset + rlocn->size) - mdah->size);
@@ -1374,7 +1388,7 @@ static int _scan_raw(const struct format_type *fmt, const char *vgname __attribu
 			continue;
 		}
 
-		if (read_metadata_location_summary(fmt, mdah, 0, &rl->dev_area, &vgsummary, NULL)) {
+		if (read_metadata_location_summary(fmt, NULL, mdah, 0, &rl->dev_area, &vgsummary, NULL)) {
 			vg = _vg_read_raw_area(&fid, vgsummary.vgname, &rl->dev_area, NULL, NULL, 0, 0);
 			if (vg) {
 				lvmcache_update_vg(vg, 0);
diff --git a/lib/format_text/layout.h b/lib/format_text/layout.h
index 2671bbf02..460195276 100644
--- a/lib/format_text/layout.h
+++ b/lib/format_text/layout.h
@@ -104,7 +104,7 @@ struct mda_context {
 #define MDA_SIZE_MIN (8 * (unsigned) lvm_getpagesize())
 #define MDA_ORIGINAL_ALIGNMENT 512	/* Original alignment used for start of VG metadata content */
 
-int read_metadata_location_summary(const struct format_type *fmt, struct mda_header *mdah, int primary_mda, 
+int read_metadata_location_summary(const struct format_type *fmt, struct metadata_area *mda, struct mda_header *mdah, int primary_mda, 
 		    struct device_area *dev_area, struct lvmcache_vgsummary *vgsummary,
 		    uint64_t *mda_free_sectors);
 
diff --git a/lib/format_text/text_label.c b/lib/format_text/text_label.c
index 7d10e065b..fc8294e3f 100644
--- a/lib/format_text/text_label.c
+++ b/lib/format_text/text_label.c
@@ -345,7 +345,7 @@ static int _read_mda_header_and_metadata(struct metadata_area *mda, void *baton)
 		return 1;
 	}
 
-	if (!read_metadata_location_summary(fmt, mdah, mda_is_primary(mda), &mdac->area,
+	if (!read_metadata_location_summary(fmt, mda, mdah, mda_is_primary(mda), &mdac->area,
 					    &vgsummary, &mdac->free_sectors)) {
 		if (vgsummary.zero_offset)
 			return 1;
diff --git a/lib/label/label.c b/lib/label/label.c
index 70b793441..8a4b66246 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -1418,6 +1418,11 @@ bool dev_write_bytes(struct device *dev, uint64_t start, size_t len, void *data)
 	return true;
 }
 
+bool dev_invalidate_bytes(struct device *dev, uint64_t start, size_t len)
+{
+	return bcache_invalidate_bytes(scan_bcache, dev->bcache_fd, start, len);
+}
+
 bool dev_write_zeros(struct device *dev, uint64_t start, size_t len)
 {
 	if (test_mode())
diff --git a/lib/label/label.h b/lib/label/label.h
index 42c9946cb..ea29c84ee 100644
--- a/lib/label/label.h
+++ b/lib/label/label.h
@@ -128,6 +128,7 @@ bool dev_read_bytes(struct device *dev, uint64_t start, size_t len, void *data);
 bool dev_write_bytes(struct device *dev, uint64_t start, size_t len, void *data);
 bool dev_write_zeros(struct device *dev, uint64_t start, size_t len);
 bool dev_set_bytes(struct device *dev, uint64_t start, size_t len, uint8_t val);
+bool dev_invalidate_bytes(struct device *dev, uint64_t start, size_t len);
 void dev_set_last_byte(struct device *dev, uint64_t offset);
 void dev_unset_last_byte(struct device *dev);
 
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 666ad7823..0bdbda69b 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -33,6 +33,8 @@
 #include "lvmlockd.h"
 #include "time.h"
 #include "lvmnotify.h"
+#include "format_text/format-text.h"
+#include "format_text/layout.h"
 
 #include <math.h>
 #include <sys/param.h>
@@ -3758,6 +3760,118 @@ out:
 	return r;
 }
 
+/*
+ * Reread an mda_header.  If the text offset is the same as was seen and saved
+ * by label scan, it means the metadata is unchanged and we do not need to
+ * reread metadata.
+ *
+ * This is used to ensure that the metadata seen during scan still matches
+ * what's on disk.  If the scan data still matches what's on disk we don't
+ * need to reread the metadata from disk.  When we read the metadata from
+ * bcache it may come from the cache or from disk again if the cache has
+ * dropped it.
+ */
+
+static bool _scan_text_mismatch(struct cmd_context *cmd, const char *vgname, const char *vgid)
+{
+	struct dm_list mda_list;
+	struct mda_list *mdal, *safe;
+	struct metadata_area *mda;
+	struct mda_context *mdac;
+	struct device_area *area;
+	struct mda_header *mdah;
+	struct raw_locn *rlocn;
+	struct device *dev;
+	bool ret = true;
+
+	/*
+	 * if cmd->can_use_one_scan, check one mda_header is unchanged,
+	 * else check that all mda_headers are unchanged.
+	 */
+
+	dm_list_init(&mda_list);
+
+	lvmcache_get_mdas(cmd, vgname, vgid, &mda_list);
+
+	dm_list_iterate_items(mdal, &mda_list) {
+		mda = mdal->mda;
+
+		if (!mda->scan_text_offset)
+			continue;
+
+		if (!mda_is_primary(mda))
+			continue;
+
+		if (!(dev = mda_get_device(mda))) {
+			log_debug("rescan for text mismatch - no mda dev");
+			goto out;
+		}
+
+		mdac = mda->metadata_locn;
+		area = &mdac->area;
+
+		/*
+		 * Invalidate mda_header in bcache so it will be reread from disk.
+		 */
+		if (!dev_invalidate_bytes(dev, 4096, 512)) {
+			log_debug("rescan for text mismatch - cannot invalidate");
+			goto out;
+		}
+
+		if (!(mdah = raw_read_mda_header(cmd->fmt, area, 1))) {
+			log_debug("rescan for text mismatch - no mda header");
+			goto out;
+		}
+
+		rlocn = mdah->raw_locns;
+
+		if (rlocn->checksum != mda->scan_text_checksum) {
+			log_debug("rescan for text checksum mismatch on %s - now %x prev %x offset now %llu prev %llu",
+				  dev_name(dev),
+				  rlocn->checksum, mda->scan_text_checksum,
+				  (unsigned long long)rlocn->offset,
+				  (unsigned long long)mda->scan_text_offset);
+		} else if (rlocn->offset != mda->scan_text_offset) {
+			log_debug("rescan for text offset mismatch on %s - now %llu prev %llu checksum %x",
+				  dev_name(dev),
+				  (unsigned long long)rlocn->offset,
+				  (unsigned long long)mda->scan_text_offset,
+				  rlocn->checksum);
+		} else {
+			/* the common case where fields match and no rescan needed */
+			ret = false;
+		}
+
+		dm_pool_free(cmd->mem, mdah);
+
+		/* For can_use_one_scan commands, return result from checking one mda. */
+		if (cmd->can_use_one_scan)
+			goto out;
+
+		/* For other commands, return mismatch immediately. */
+		if (ret)
+			goto_out;
+	}
+
+	if (ret) {
+		/* shouldn't happen */
+		log_debug("rescan for text mismatch - no mdas");
+		goto out;
+	}
+out:
+	if (!ret)
+		log_debug("rescan skipped - unchanged offset %llu checksum %x",
+			  (unsigned long long)mda->scan_text_offset,
+			  mda->scan_text_checksum);
+
+	dm_list_iterate_items_safe(mdal, safe, &mda_list) {
+		dm_list_del(&mdal->list);
+		free(mdal);
+	}
+
+	return ret;
+}
+
 /* Caller sets consistent to 1 if it's safe for vg_read_internal to correct
  * inconsistent metadata on disk (i.e. the VG write lock is held).
  * This guarantees only consistent metadata is returned.
@@ -3902,7 +4016,8 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 	 * lock is taken prior to the label scan, and still held here,
 	 * we can also skip the rescan in that case.
 	 */
-	if (!cmd->can_use_one_scan || lvmcache_scan_mismatch(cmd, vgname, vgid)) {
+	if (!cmd->can_use_one_scan ||
+	    lvmcache_scan_mismatch(cmd, vgname, vgid) || _scan_text_mismatch(cmd, vgname, vgid)) {
 		/* the skip rescan special case is for clvmd vg_read_by_vgid */
 		/* FIXME: this is not a warn flag, pass this differently */
 		if (warn_flags & SKIP_RESCAN)
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index f8083e5a8..96bbb5690 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -173,6 +173,8 @@ struct metadata_area {
 	struct metadata_area_ops *ops;
 	void *metadata_locn;
 	uint32_t status;
+	uint64_t scan_text_offset; /* rlocn->offset seen during scan */
+	uint32_t scan_text_checksum; /* rlocn->checksum seen during scan */
 };
 struct metadata_area *mda_copy(struct dm_pool *mem,
 			       struct metadata_area *mda);
@@ -234,7 +236,7 @@ struct name_list {
 
 struct mda_list {
 	struct dm_list list;
-	struct device_area mda;
+	struct metadata_area *mda;
 };
 
 struct peg_list {


