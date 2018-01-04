From: Alasdair Kergon <agk@sourceware.org>
Date: Thu, 4 Jan 2018 16:26:01 -0500
Subject: master - format_text: Split vgname_from_mda into three pieces.
Message-ID: <201801042126.w04LQ16w020429@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c70c9f65659df846dbc590053569a80935e09d2f
Commit:        c70c9f65659df846dbc590053569a80935e09d2f
Parent:        d61b1369d0764841522494ef3ba0ef4b5e89c723
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Jan 4 21:13:44 2018 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Jan 4 21:13:44 2018 +0000

format_text: Split vgname_from_mda into three pieces.

---
 lib/format_text/format-text.c |  165 +++++++++++++++++++++++++++--------------
 1 files changed, 110 insertions(+), 55 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 4404c04..798fd66 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1328,41 +1328,68 @@ static int _scan_file(const struct format_type *fmt, const char *vgname)
 	return 1;
 }
 
-int vgname_from_mda(const struct format_type *fmt,
-		    struct mda_header *mdah, int primary_mda, struct device_area *dev_area,
-		    struct lvmcache_vgsummary *vgsummary, uint64_t *mda_free_sectors)
+struct vgname_from_mda_params{
+	const struct format_type *fmt;
+	struct mda_header *mdah;
+	struct device_area *dev_area;
+	int primary_mda;
+	struct lvmcache_vgsummary *vgsummary;
+	uint64_t *mda_free_sectors;
+	uint32_t wrap;
+	unsigned used_cached_metadata;
+};
+
+static int _vgname_from_mda_process(struct vgname_from_mda_params *vfmp)
 {
-	struct raw_locn *rlocn;
-	uint32_t wrap = 0;
-	unsigned int len = 0;
-	char buf[NAME_LEN + 1] __attribute__((aligned(8)));
+	struct mda_header *mdah = vfmp->mdah;
+	struct device_area *dev_area = vfmp->dev_area;
+	struct lvmcache_vgsummary *vgsummary = vfmp->vgsummary;
+	uint64_t *mda_free_sectors = vfmp->mda_free_sectors;
+	struct raw_locn *rlocn = mdah->raw_locns;
 	uint64_t buffer_size, current_usage;
-	unsigned used_cached_metadata = 0;
+	int r = 0;
 
-	if (mda_free_sectors)
-		*mda_free_sectors = ((dev_area->size - MDA_HEADER_SIZE) / 2) >> SECTOR_SHIFT;
+	/* Ignore this entry if the characters aren't permissible */
+	if (!validate_name(vgsummary->vgname))
+		goto_out;
 
-	if (!mdah) {
-		log_error(INTERNAL_ERROR "vgname_from_mda called with NULL pointer for mda_header");
-		return 0;
-	}
+	log_debug_metadata("%s: %s metadata at " FMTu64 " size " FMTu64 " with wrap " FMTu32
+			   " (in area at " FMTu64 " size " FMTu64
+			   ") for %s (" FMTVGID ")",
+			   dev_name(dev_area->dev),
+			   vfmp->used_cached_metadata ? "Using cached" : "Found",
+			   dev_area->start + rlocn->offset,
+			   rlocn->size, vfmp->wrap, dev_area->start, dev_area->size, vgsummary->vgname,
+			   (char *)&vgsummary->vgid);
 
-	/* FIXME Cope with returning a list */
-	rlocn = mdah->raw_locns;
+	if (mda_free_sectors) {
+		current_usage = ALIGN_ABSOLUTE(rlocn->size, dev_area->start + rlocn->offset, MDA_ALIGNMENT);
 
-	/*
-	 * If no valid offset, do not try to search for vgname
-	 */
-	if (!rlocn->offset) {
-		log_debug("%s: found metadata with offset 0.",
-			  dev_name(dev_area->dev));
-		return 0;
+		buffer_size = mdah->size - MDA_HEADER_SIZE;
+
+		if (current_usage * 2 >= buffer_size)
+			*mda_free_sectors = UINT64_C(0);
+		else
+			*mda_free_sectors = ((buffer_size - 2 * current_usage) / 2) >> SECTOR_SHIFT;
 	}
 
-	/* Do quick check for a vgname */
-	if (!dev_read_buf(dev_area->dev, dev_area->start + rlocn->offset,
-			  NAME_LEN, MDA_CONTENT_REASON(primary_mda), buf))
-		return_0;
+	r = 1;
+
+out:
+	return r;
+}
+
+static int _vgname_from_mda_validate(struct vgname_from_mda_params *vfmp, char *buffer)
+{
+	const struct format_type *fmt = vfmp->fmt;
+	struct mda_header *mdah = vfmp->mdah;
+	struct device_area *dev_area = vfmp->dev_area;
+	struct lvmcache_vgsummary *vgsummary = vfmp->vgsummary;
+	struct raw_locn *rlocn = mdah->raw_locns;
+	unsigned len = 0;
+	char buf[NAME_LEN + 1] __attribute__((aligned(8)));
+
+	memcpy(buf, buffer, NAME_LEN + 1);
 
 	while (buf[len] && !isspace(buf[len]) && buf[len] != '{' &&
 	       len < (NAME_LEN - 1))
@@ -1372,16 +1399,16 @@ int vgname_from_mda(const struct format_type *fmt,
 
 	/* Ignore this entry if the characters aren't permissible */
 	if (!validate_name(buf))
-		return_0;
+		goto_out;
 
 	/* We found a VG - now check the metadata */
 	if (rlocn->offset + rlocn->size > mdah->size)
-		wrap = (uint32_t) ((rlocn->offset + rlocn->size) - mdah->size);
+		vfmp->wrap = (uint32_t) ((rlocn->offset + rlocn->size) - mdah->size);
 
-	if (wrap > rlocn->offset) {
+	if (vfmp->wrap > rlocn->offset) {
 		log_error("%s: metadata (" FMTu64 " bytes) too large for circular buffer (" FMTu64 " bytes)",
 			  dev_name(dev_area->dev), rlocn->size, mdah->size - MDA_HEADER_SIZE);
-		return 0;
+		goto out;
 	}
 
 	/* Did we see this metadata before? */
@@ -1389,42 +1416,70 @@ int vgname_from_mda(const struct format_type *fmt,
 	vgsummary->mda_size = rlocn->size;
 
 	if (lvmcache_lookup_mda(vgsummary))
-		used_cached_metadata = 1;
+		vfmp->used_cached_metadata = 1;
 
 	/* FIXME 64-bit */
-	if (!text_vgsummary_import(fmt, dev_area->dev, MDA_CONTENT_REASON(primary_mda),
+	if (!text_vgsummary_import(fmt, dev_area->dev, MDA_CONTENT_REASON(vfmp->primary_mda),
 				(off_t) (dev_area->start + rlocn->offset),
-				(uint32_t) (rlocn->size - wrap),
+				(uint32_t) (rlocn->size - vfmp->wrap),
 				(off_t) (dev_area->start + MDA_HEADER_SIZE),
-				wrap, calc_crc, vgsummary->vgname ? 1 : 0,
+				vfmp->wrap, calc_crc, vgsummary->vgname ? 1 : 0,
 				vgsummary))
-		return_0;
+		goto_out;
 
-	/* Ignore this entry if the characters aren't permissible */
-	if (!validate_name(vgsummary->vgname))
-		return_0;
+	return _vgname_from_mda_process(vfmp);
 
-	log_debug_metadata("%s: %s metadata at " FMTu64 " size " FMTu64 " with wrap " FMTu32
-			   " (in area at " FMTu64 " size " FMTu64
-			   ") for %s (" FMTVGID ")",
-			   dev_name(dev_area->dev),
-			   used_cached_metadata ? "Using cached" : "Found",
-			   dev_area->start + rlocn->offset,
-			   rlocn->size, wrap, dev_area->start, dev_area->size, vgsummary->vgname,
-			   (char *)&vgsummary->vgid);
+out:
+	return 0;
+}
 
-	if (mda_free_sectors) {
-		current_usage = ALIGN_ABSOLUTE(rlocn->size, dev_area->start + rlocn->offset, MDA_ALIGNMENT);
+int vgname_from_mda(const struct format_type *fmt,
+		    struct mda_header *mdah, int primary_mda, struct device_area *dev_area,
+		    struct lvmcache_vgsummary *vgsummary, uint64_t *mda_free_sectors)
+{
+	struct raw_locn *rlocn;
+	char buf[NAME_LEN + 1] __attribute__((aligned(8)));
+	struct vgname_from_mda_params *vfmp;
 
-		buffer_size = mdah->size - MDA_HEADER_SIZE;
+	if (mda_free_sectors)
+		*mda_free_sectors = ((dev_area->size - MDA_HEADER_SIZE) / 2) >> SECTOR_SHIFT;
 
-		if (current_usage * 2 >= buffer_size)
-			*mda_free_sectors = UINT64_C(0);
-		else
-			*mda_free_sectors = ((buffer_size - 2 * current_usage) / 2) >> SECTOR_SHIFT;
+	if (!mdah) {
+		log_error(INTERNAL_ERROR "vgname_from_mda called with NULL pointer for mda_header");
+		return 0;
 	}
 
-	return 1;
+	/* FIXME Cope with returning a list */
+	rlocn = mdah->raw_locns;
+
+	/*
+	 * If no valid offset, do not try to search for vgname
+	 */
+	if (!rlocn->offset) {
+		log_debug("%s: found metadata with offset 0.",
+			  dev_name(dev_area->dev));
+		return 0;
+	}
+
+	if (!(vfmp = dm_pool_zalloc(fmt->cmd->mem, sizeof(*vfmp)))) {
+		log_error("vgname_from_mda_params allocation failed");
+		return 0;
+	}
+
+	vfmp->fmt = fmt;
+	vfmp->mdah = mdah;
+	vfmp->dev_area = dev_area;
+	vfmp->vgsummary = vgsummary;
+	vfmp->primary_mda = primary_mda;
+	vfmp->mda_free_sectors = mda_free_sectors;
+
+	/* Do quick check for a vgname */
+	/* We cannot read the full metadata here because the name has to be validated before we use the size field */
+	if (!dev_read_buf(dev_area->dev, dev_area->start + rlocn->offset,
+			  NAME_LEN, MDA_CONTENT_REASON(primary_mda), buf))
+		return_0;
+
+	return _vgname_from_mda_validate(vfmp, buf);
 }
 
 static int _scan_raw(const struct format_type *fmt, const char *vgname __attribute__((unused)))


