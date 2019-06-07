From: David Teigland <teigland@sourceware.org>
Date: Fri, 7 Jun 2019 17:08:06 -0400
Subject: master - add flags to keep track of bad metadata
Message-ID: <201906072108.x57L86eV005216@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=aeafdc1f45a5963290a5bc3ea1661018b072d817
Commit:        aeafdc1f45a5963290a5bc3ea1661018b072d817
Parent:        db98a6e3629aaf6bf42d0e840273b4328f930c89
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Feb 5 12:08:00 2019 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Jun 7 15:54:04 2019 -0500

add flags to keep track of bad metadata

When reading metadata headers and text, use a new set
of flags to identify specific errors that are seen.
These will be used for more advanced repair in a
subsequent commit.
---
 lib/format_text/format-text.c |   44 +++++++++++++++++++++++++++--------------
 lib/format_text/layout.h      |    4 ++-
 lib/format_text/text_label.c  |    3 +-
 lib/metadata/metadata.h       |   14 +++++++++++++
 4 files changed, 48 insertions(+), 17 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 2831a53..f5e08fa 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -161,7 +161,8 @@ static void _xlate_mdah(struct mda_header *mdah)
 	}
 }
 
-static int _raw_read_mda_header(struct mda_header *mdah, struct device_area *dev_area, int primary_mda)
+static int _raw_read_mda_header(struct mda_header *mdah, struct device_area *dev_area,
+				int primary_mda, uint32_t ignore_bad_fields, uint32_t *bad_fields)
 {
 	log_debug_metadata("Reading mda header sector from %s at %llu",
 			   dev_name(dev_area->dev), (unsigned long long)dev_area->start);
@@ -169,53 +170,62 @@ static int _raw_read_mda_header(struct mda_header *mdah, struct device_area *dev
 	if (!dev_read_bytes(dev_area->dev, dev_area->start, MDA_HEADER_SIZE, mdah)) {
 		log_error("Failed to read metadata area header on %s at %llu",
 			  dev_name(dev_area->dev), (unsigned long long)dev_area->start);
+		*bad_fields |= BAD_MDA_READ;
 		return 0;
 	}
 
 	if (mdah->checksum_xl != xlate32(calc_crc(INITIAL_CRC, (uint8_t *)mdah->magic,
 						  MDA_HEADER_SIZE -
 						  sizeof(mdah->checksum_xl)))) {
-		log_error("Incorrect checksum in metadata area header on %s at %llu",
+		log_warn("WARNING: wrong checksum %x in mda header on %s at %llu",
+			  mdah->checksum_xl,
 			  dev_name(dev_area->dev), (unsigned long long)dev_area->start);
-		return 0;
+		*bad_fields |= BAD_MDA_CHECKSUM;
 	}
 
 	_xlate_mdah(mdah);
 
 	if (memcmp(mdah->magic, FMTT_MAGIC, sizeof(mdah->magic))) {
-		log_error("Wrong magic number in metadata area header on %s at %llu",
+		log_warn("WARNING: wrong magic number in mda header on %s at %llu",
 			  dev_name(dev_area->dev), (unsigned long long)dev_area->start);
-		return 0;
+		*bad_fields |= BAD_MDA_MAGIC;
 	}
 
 	if (mdah->version != FMTT_VERSION) {
-		log_error("Incompatible version %u metadata area header on %s at %llu",
+		log_warn("WARNING: wrong version %u in mda header on %s at %llu",
 			  mdah->version,
 			  dev_name(dev_area->dev), (unsigned long long)dev_area->start);
-		return 0;
+		*bad_fields |= BAD_MDA_VERSION;
 	}
 
 	if (mdah->start != dev_area->start) {
-		log_error("Incorrect start sector %llu in metadata area header on %s at %llu",
+		log_warn("WARNING: wrong start sector %llu in mda header on %s at %llu",
 			  (unsigned long long)mdah->start,
 			  dev_name(dev_area->dev), (unsigned long long)dev_area->start);
-		return 0;
+		*bad_fields |= BAD_MDA_START;
 	}
 
+	*bad_fields &= ~ignore_bad_fields;
+
+	if (*bad_fields)
+		return 0;
+
 	return 1;
 }
 
 struct mda_header *raw_read_mda_header(const struct format_type *fmt,
-				       struct device_area *dev_area, int primary_mda)
+				       struct device_area *dev_area,
+				       int primary_mda, uint32_t ignore_bad_fields, uint32_t *bad_fields)
 {
 	struct mda_header *mdah;
 
 	if (!(mdah = dm_pool_alloc(fmt->cmd->mem, MDA_HEADER_SIZE))) {
 		log_error("struct mda_header allocation failed");
+		*bad_fields |= BAD_MDA_INTERNAL;
 		return NULL;
 	}
 
-	if (!_raw_read_mda_header(mdah, dev_area, primary_mda)) {
+	if (!_raw_read_mda_header(mdah, dev_area, primary_mda, ignore_bad_fields, bad_fields)) {
 		dm_pool_free(fmt->cmd->mem, mdah);
 		return NULL;
 	}
@@ -413,8 +423,9 @@ static struct volume_group *_vg_read_raw_area(struct format_instance *fid,
 	time_t when;
 	char *desc;
 	uint32_t wrap = 0;
+	uint32_t bad_fields = 0;
 
-	if (!(mdah = raw_read_mda_header(fid->fmt, area, primary_mda))) {
+	if (!(mdah = raw_read_mda_header(fid->fmt, area, primary_mda, 0, &bad_fields))) {
 		log_error("Failed to read vg %s from %s", vgname, dev_name(area->dev));
 		goto out;
 	}
@@ -535,6 +546,7 @@ static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 	uint64_t old_start = 0, old_last = 0, old_size = 0, old_wrap = 0;
 	uint64_t new_start = 0, new_last = 0, new_size = 0, new_wrap = 0;
 	uint64_t max_size;
+	uint32_t bad_fields = 0;
 	char *new_buf = NULL;
 	int overlap;
 	int found = 0;
@@ -550,7 +562,7 @@ static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 	if (!found)
 		return 1;
 
-	if (!(mdah = raw_read_mda_header(fid->fmt, &mdac->area, mda_is_primary(mda))))
+	if (!(mdah = raw_read_mda_header(fid->fmt, &mdac->area, mda_is_primary(mda), mda->ignore_bad_fields, &bad_fields)))
 		goto_out;
 
 	/*
@@ -821,6 +833,7 @@ static int _vg_commit_raw_rlocn(struct format_instance *fid,
 	struct raw_locn *rlocn_slot1;
 	struct raw_locn *rlocn_new;
 	struct pv_list *pvl;
+	uint32_t bad_fields = 0;
 	int r = 0;
 	int found = 0;
 
@@ -841,7 +854,7 @@ static int _vg_commit_raw_rlocn(struct format_instance *fid,
 	 * mdah buffer, but the mdah buffer is not modified and mdac->rlocn is
 	 * modified.
 	 */
-	if (!(mdab = raw_read_mda_header(fid->fmt, &mdac->area, mda_is_primary(mda))))
+	if (!(mdab = raw_read_mda_header(fid->fmt, &mdac->area, mda_is_primary(mda), mda->ignore_bad_fields, &bad_fields)))
 		goto_out;
 
 	/*
@@ -1033,6 +1046,7 @@ static int _vg_remove_raw(struct format_instance *fid, struct volume_group *vg,
 	struct mda_header *mdah;
 	struct raw_locn *rlocn_slot0;
 	struct raw_locn *rlocn_slot1;
+	uint32_t bad_fields = 0;
 	int r = 0;
 
 	if (!(mdah = dm_pool_alloc(fid->fmt->cmd->mem, MDA_HEADER_SIZE))) {
@@ -1046,7 +1060,7 @@ static int _vg_remove_raw(struct format_instance *fid, struct volume_group *vg,
 	 * Just to print the warning?
 	 */
 
-	if (!_raw_read_mda_header(mdah, &mdac->area, mda_is_primary(mda)))
+	if (!_raw_read_mda_header(mdah, &mdac->area, mda_is_primary(mda), 0, &bad_fields))
 		log_warn("WARNING: Removing metadata location on %s with bad mda header.",
 			  dev_name(mdac->area.dev));
 
diff --git a/lib/format_text/layout.h b/lib/format_text/layout.h
index e1462f1..7320d9c 100644
--- a/lib/format_text/layout.h
+++ b/lib/format_text/layout.h
@@ -81,7 +81,9 @@ struct mda_header {
 } __attribute__ ((packed));
 
 struct mda_header *raw_read_mda_header(const struct format_type *fmt,
-				       struct device_area *dev_area, int primary_mda);
+				       struct device_area *dev_area, int primary_mda,
+				       uint32_t ignore_bad_fields,
+				       uint32_t *bad_fields);
 
 struct mda_lists {
 	struct metadata_area_ops *file_ops;
diff --git a/lib/format_text/text_label.c b/lib/format_text/text_label.c
index ef2f6c7..6eca3c1 100644
--- a/lib/format_text/text_label.c
+++ b/lib/format_text/text_label.c
@@ -331,8 +331,9 @@ static int _read_mda_header_and_metadata(struct metadata_area *mda, void *baton)
 	struct mda_context *mdac = (struct mda_context *) mda->metadata_locn;
 	struct mda_header *mdah;
 	struct lvmcache_vgsummary vgsummary = { 0 };
+	uint32_t bad_fields = 0;
 
-	if (!(mdah = raw_read_mda_header(fmt, &mdac->area, mda_is_primary(mda)))) {
+	if (!(mdah = raw_read_mda_header(fmt, &mdac->area, mda_is_primary(mda), 0, &bad_fields))) {
 		log_error("Failed to read mda header from %s", dev_name(mdac->area.dev));
 		goto fail;
 	}
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index a140c29..d904aa6 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -168,11 +168,25 @@ struct metadata_area_ops {
 #define MDA_CONTENT_REASON(primary_mda) ((primary_mda) ? DEV_IO_MDA_CONTENT : DEV_IO_MDA_EXTRA_CONTENT)
 #define MDA_HEADER_REASON(primary_mda)  ((primary_mda) ? DEV_IO_MDA_HEADER : DEV_IO_MDA_EXTRA_HEADER)
 
+/*
+ * Flags describing errors found while reading.
+ */
+#define BAD_MDA_INTERNAL	0x00000001 /* internal lvm error */
+#define BAD_MDA_READ		0x00000002 /* read io failed */
+#define BAD_MDA_HEADER		0x00000004 /* general problem with header */
+#define BAD_MDA_TEXT		0x00000008 /* general problem with text */
+#define BAD_MDA_CHECKSUM	0x00000010
+#define BAD_MDA_MAGIC		0x00000020
+#define BAD_MDA_VERSION		0x00000040
+#define BAD_MDA_START		0x00000080
+
 struct metadata_area {
 	struct dm_list list;
 	struct metadata_area_ops *ops;
 	void *metadata_locn;
 	uint32_t status;
+	uint32_t bad_fields; /* BAD_MDA_ flags are set to indicate errors found when reading */
+	uint32_t ignore_bad_fields; /* BAD_MDA_ flags are set to indicate errors to ignore */
 };
 struct metadata_area *mda_copy(struct dm_pool *mem,
 			       struct metadata_area *mda);


