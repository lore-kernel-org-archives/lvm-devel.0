From: David Teigland <teigland@sourceware.org>
Date: Tue, 26 Nov 2019 17:52:48 -0500
Subject: master - scanning: optimize by checking text offset and checksum
Message-ID: <88661.119112617524400225@us-mta-389.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0c1316cda876849d5d1375d40e8cdc08db37c2b5
Commit:        0c1316cda876849d5d1375d40e8cdc08db37c2b5
Parent:        56a295f78c4638e201ad78a8b25fd7874f2d905d
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Nov 26 11:56:51 2019 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Nov 26 16:52:28 2019 -0600

scanning: optimize by checking text offset and checksum

After the VG lock is taken for vg_read, reread the mda_header
and compare the metadata text offset and checksum to what was
seen during label scan.  If it is unchanged, then the metadata
has not changed since the label scan, and the metadata does not
need to be reread under the lock for command processing.

For commands that do not make changes (e.g. reporting), the
mda_header is reread and checked on one mda to decide if the
full metadata rereading can be skipped.  For other commands
(e.g. modifying the vg) the mda_header is reread and checked
from all PVs.  (These could probably just check one mda also.)
---
 lib/cache/lvmcache.c          |   24 ++++++++
 lib/cache/lvmcache.h          |    4 +
 lib/format_text/format-text.c |   12 ++++
 lib/format_text/layout.h      |    3 +-
 lib/format_text/text_label.c  |    2 +-
 lib/metadata/metadata.c       |  130 ++++++++++++++++++++++++++++++++++++++--
 lib/metadata/metadata.h       |    2 +
 7 files changed, 168 insertions(+), 9 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 6224fe0..2c8c614 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -238,6 +238,30 @@ void lvmcache_get_bad_mdas(struct cmd_context *cmd,
 	}
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
+			if (!(mdal = zalloc(sizeof(*mdal))))
+				continue;
+			mdal->mda = mda;
+			dm_list_add(mda_list, &mdal->list);
+		}
+	}
+}
+
 static void _vginfo_attach_info(struct lvmcache_vginfo *vginfo,
 				struct lvmcache_info *info)
 {
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index d614e54..0c8c789 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -216,4 +216,8 @@ void lvmcache_get_bad_mdas(struct cmd_context *cmd,
                            const char *vgname, const char *vgid,
                            struct dm_list *bad_mda_list);
 
+void lvmcache_get_mdas(struct cmd_context *cmd,
+                       const char *vgname, const char *vgid,
+                       struct dm_list *mda_list);
+
 #endif
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 2c2b7fa..268bd64 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1507,6 +1507,7 @@ static int _vg_remove_file(struct format_instance *fid __attribute__((unused)),
 }
 
 int read_metadata_location_summary(const struct format_type *fmt,
+		    struct metadata_area *mda,
 		    struct mda_header *mdah, int primary_mda, struct device_area *dev_area,
 		    struct lvmcache_vgsummary *vgsummary, uint64_t *mda_free_sectors)
 {
@@ -1565,6 +1566,17 @@ int read_metadata_location_summary(const struct format_type *fmt,
 	}
 
 	/*
+	 * This function is used to read the vg summary during label scan.
+	 * Save the text start location and checksum during scan.  After the VG
+	 * lock is acquired in vg_read, we can reread the mda_header, and
+	 * compare rlocn->offset,checksum to what was saved during scan.  If
+	 * unchanged, it means that the metadata was not changed between scan
+	 * and the read.
+	 */
+	mda->scan_text_offset = rlocn->offset;
+	mda->scan_text_checksum = rlocn->checksum;
+
+	/*
 	 * When the current metadata wraps around the end of the metadata area
 	 * (so some is located at the end and some is located at the
 	 * beginning), then "wrap" is the number of bytes that was written back
diff --git a/lib/format_text/layout.h b/lib/format_text/layout.h
index 7320d9c..7ec699e 100644
--- a/lib/format_text/layout.h
+++ b/lib/format_text/layout.h
@@ -104,7 +104,8 @@ struct mda_context {
 #define MDA_SIZE_MIN (8 * (unsigned) lvm_getpagesize())
 #define MDA_ORIGINAL_ALIGNMENT 512	/* Original alignment used for start of VG metadata content */
 
-int read_metadata_location_summary(const struct format_type *fmt, struct mda_header *mdah, int primary_mda, 
+int read_metadata_location_summary(const struct format_type *fmt,
+		    struct metadata_area *mda, struct mda_header *mdah, int primary_mda, 
 		    struct device_area *dev_area, struct lvmcache_vgsummary *vgsummary,
 		    uint64_t *mda_free_sectors);
 
diff --git a/lib/format_text/text_label.c b/lib/format_text/text_label.c
index cb60c15..9241eca 100644
--- a/lib/format_text/text_label.c
+++ b/lib/format_text/text_label.c
@@ -349,7 +349,7 @@ static int _read_mda_header_and_metadata(const struct format_type *fmt,
 		return 1;
 	}
 
-	if (!read_metadata_location_summary(fmt, mdah, mda_is_primary(mda), &mdac->area,
+	if (!read_metadata_location_summary(fmt, mda, mdah, mda_is_primary(mda), &mdac->area,
 					    vgsummary, &mdac->free_sectors)) {
 		if (vgsummary->zero_offset)
 			return 1;
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index c4f7247..1ac5445 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -4571,6 +4571,118 @@ void vg_write_commit_bad_mdas(struct cmd_context *cmd, struct volume_group *vg)
 	}
 }
 
+/*
+ * Reread an mda_header.  If the text offset is the same as was seen and saved
+ * by label scan, it means the metadata is unchanged and we do not need to
+ * reread metadata.
+ */
+
+static int _scan_text_mismatch(struct cmd_context *cmd, const char *vgname, const char *vgid)
+{
+	struct dm_list mda_list;
+	struct mda_list *mdal, *safe;
+	struct metadata_area *mda;
+	struct mda_context *mdac;
+	struct device_area *area;
+	struct mda_header *mdah;
+	struct raw_locn *rlocn;
+	struct device *dev;
+	uint32_t bad_fields;
+	int ret = 1;
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
+		if (mda->mda_num != 1)
+			continue;
+
+		if (!(dev = mda_get_device(mda))) {
+			log_debug("rescan for text mismatch - no mda dev");
+			ret = 1;
+			goto out;
+		}
+
+		bad_fields = 0;
+
+		mdac = mda->metadata_locn;
+		area = &mdac->area;
+
+		/*
+		 * Invalidate mda_header in bcache so it will be reread from disk.
+		 */
+		if (!dev_invalidate_bytes(dev, 4096, 512)) {
+			log_debug("rescan for text mismatch - cannot invalidate");
+			ret = 1;
+			goto out;
+		}
+
+		if (!(mdah = raw_read_mda_header(cmd->fmt, area, 1, 0, &bad_fields))) {
+			log_debug("rescan for text mismatch - no mda header");
+			ret = 1;
+			goto out;
+		}
+
+		rlocn = mdah->raw_locns;
+
+		if (bad_fields) {
+			log_debug("rescan for text mismatch - bad_fields");
+			ret = 1;
+		} else if (rlocn->checksum != mda->scan_text_checksum) {
+			log_debug("rescan for text checksum mismatch - now %x prev %x",
+				  rlocn->checksum, mda->scan_text_checksum);
+			ret = 1;
+		} else if (rlocn->offset != mda->scan_text_offset) {
+			log_debug("rescan for text offset mismatch - now %llu prev %llu",
+				  (unsigned long long)rlocn->offset,
+				  (unsigned long long)mda->scan_text_offset);
+			ret = 1;
+		} else {
+			ret = 0;
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
+
+	ret = 0;
+
+out:
+	if (!ret)
+		log_debug("rescan skipped - text offset and checksum unchanged");
+
+	dm_list_iterate_items_safe(mdal, safe, &mda_list) {
+		dm_list_del(&mdal->list);
+		free(mdal);
+	}
+
+	return ret;
+}
+
 static struct volume_group *_vg_read(struct cmd_context *cmd,
 				     const char *vgname,
 				     const char *vgid,
@@ -4625,19 +4737,23 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 	 * find the same inconsistency.  The VG repair (mistakenly done by
 	 * vg_read below) is supposed to fix that.
 	 *
-	 * FIXME: sort out the usage of the global lock (which is mixed up
-	 * with the orphan lock), and when we can tell that the global
-	 * lock is taken prior to the label scan, and still held here,
-	 * we can also skip the rescan in that case.
+	 * If the VG was not modified between the time we scanned the PVs
+	 * and now, when we hold the lock, then we don't need to rescan.
+	 * We can read the mda_header, and look at the text offset/checksum,
+	 * and if the current text offset/checksum matches what was seen during
+	 * label scan, we know that metadata is unchanged and doesn't need
+	 * to be rescanned.  For reporting/display commands (CAN_USE_ONE_SCAN/
+	 * can_use_one_scan), we check that the text offset/checksum are unchanged
+	 * in just one mda before deciding to skip rescanning.  For other commands,
+	 * we check that they are unchanged in all mdas.  This added checking is
+	 * probably unnecessary; all commands could likely just check a single mda.
 	 */
-	if (!cmd->can_use_one_scan || lvmcache_scan_mismatch(cmd, vgname, vgid)) {
+	if (lvmcache_scan_mismatch(cmd, vgname, vgid) || _scan_text_mismatch(cmd, vgname, vgid)) {
 		log_debug_metadata("Rescanning devices for %s %s", vgname, writing ? "rw" : "");
 		if (writing)
 			lvmcache_label_rescan_vg_rw(cmd, vgname, vgid);
 		else
 			lvmcache_label_rescan_vg(cmd, vgname, vgid);
-	} else {
-		log_debug_metadata("Skipped rescanning devices for %s", vgname);
 	}
 
 	/* Now determine the correct vgname if none was supplied */
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index ac18879..377a063 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -187,6 +187,8 @@ struct metadata_area {
 	void *metadata_locn;
 	uint32_t status;
 	uint64_t header_start; /* mda_header.start */
+	uint64_t scan_text_offset; /* rlocn->offset seen during scan */
+	uint32_t scan_text_checksum; /* rlocn->checksum seen during scan */
 	int mda_num;
 	uint32_t bad_fields; /* BAD_MDA_ flags are set to indicate errors found when reading */
 	uint32_t ignore_bad_fields; /* BAD_MDA_ flags are set to indicate errors to ignore */



