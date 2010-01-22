From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 22 Jan 2010 08:25:32 -0500
Subject: [PATCH 2/5] Add mda_is_disabled and mda_set_disabled to metadata_area_ops.
In-Reply-To: <1264166735-32697-2-git-send-email-dwysocha@redhat.com>
References: <1264166735-32697-1-git-send-email-dwysocha@redhat.com>
	<1264166735-32697-2-git-send-email-dwysocha@redhat.com>
Message-ID: <1264166735-32697-3-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Implementing metadata balancing requires we have a way to enable/disable
metadata areas, so we add these functions to metadata_area_ops.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 include/.symlinks.in          |    1 +
 lib/format_text/format-text.c |   42 +++++++++++++++++++++++++++++++++++++++-
 lib/format_text/format-text.h |    2 +
 lib/format_text/layout.h      |    7 ++++++
 lib/format_text/text_label.c  |    4 ++-
 lib/metadata/metadata.h       |    2 +
 6 files changed, 55 insertions(+), 3 deletions(-)

diff --git a/include/.symlinks.in b/include/.symlinks.in
index 5a7e556..415bf82 100644
--- a/include/.symlinks.in
+++ b/include/.symlinks.in
@@ -26,6 +26,7 @@
 @top_srcdir@/lib/format_text/format-text.h
 @top_srcdir@/lib/format_text/text_export.h
 @top_srcdir@/lib/format_text/text_import.h
+ at top_srcdir@/lib/format_text/layout.h
 @top_srcdir@/lib/label/label.h
 @top_srcdir@/lib/locking/locking.h
 @top_srcdir@/lib/log/log.h
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 2c75054..9b0c7d9 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -66,6 +66,19 @@ struct text_context {
 	char *desc;		/* Description placed inside file */
 };
 
+static int _mdac_is_disabled(const struct mda_context *mdac)
+{
+	return mdac->rlocn.flags & RAW_LOCN_FLAG_DISABLE;
+}
+
+static void _mdac_set_disabled(struct mda_context *mdac, int value)
+{
+	if (value)
+		mdac->rlocn.flags |= RAW_LOCN_FLAG_DISABLE;
+	else
+		mdac->rlocn.flags &= ~RAW_LOCN_FLAG_DISABLE;
+}
+
 /*
  * NOTE: Currently there can be only one vg per text file.
  */
@@ -111,6 +124,21 @@ static int _mda_in_vg_raw(struct format_instance *fid __attribute((unused)),
 	return 0;
 }
 
+static int _mda_is_disabled_raw(const struct metadata_area *mda)
+{
+	struct mda_context *mdac = (struct mda_context *) mda->metadata_locn;
+
+	return _mdac_is_disabled(mdac);
+}
+
+static void _mda_set_disabled_raw(const struct metadata_area *mda,
+				 int value)
+{
+	struct mda_context *mdac = (struct mda_context *) mda->metadata_locn;
+
+	_mdac_set_disabled(mdac, value);
+}
+
 /*
  * For circular region between region_start and region_start + region_size,
  * back up one SECTOR_SIZE from 'region_ptr' and return the value.
@@ -1036,6 +1064,7 @@ static int _scan_file(const struct format_type *fmt)
 }
 
 const char *vgname_from_mda(const struct format_type *fmt,
+			    struct mda_context *mdac,
 			    struct device_area *dev_area, struct id *vgid,
 			    uint64_t *vgstatus, char **creation_host,
 			    uint64_t *mda_free_sectors)
@@ -1061,6 +1090,11 @@ const char *vgname_from_mda(const struct format_type *fmt,
 	/* FIXME Cope with returning a list */
 	rlocn = mdah->raw_locns;
 
+	/* Copy on-disk rlocn - needed to capture 'flags' field */
+	if (mdac)
+		mdac->rlocn = *rlocn;
+	/* FIXME: Check for mda disable flag, and return here if set */
+
 	/*
 	 * If no valid offset, do not try to search for vgname
 	 */
@@ -1155,7 +1189,8 @@ static int _scan_raw(const struct format_type *fmt)
 
 	dm_list_iterate_items(rl, raw_list) {
 		/* FIXME We're reading mdah twice here... */
-		if ((vgname = vgname_from_mda(fmt, &rl->dev_area, &vgid, &vgstatus,
+		if ((vgname = vgname_from_mda(fmt, NULL,
+					      &rl->dev_area, &vgid, &vgstatus,
 					      NULL, NULL))) {
 			if ((vg = _vg_read_raw_area(&fid, vgname,
 						    &rl->dev_area, 0)))
@@ -1457,6 +1492,7 @@ static int _text_pv_write(const struct format_type *fmt, struct physical_volume
 		mdac = mda->metadata_locn;
 		memset(&buf, 0, sizeof(buf));
 		mdah->size = mdac->area.size;
+		mdah->raw_locns[0].flags = mdac->rlocn.flags;
 		if (!_raw_write_mda_header(fmt, mdac->area.dev,
 					   mdac->area.start, mdah)) {
 			if (!dev_close(pv->dev))
@@ -1652,7 +1688,9 @@ static struct metadata_area_ops _metadata_text_raw_ops = {
 	.mda_free_sectors = _mda_free_sectors_raw,
 	.mda_total_sectors = _mda_total_sectors_raw,
 	.mda_in_vg = _mda_in_vg_raw,
-	.pv_analyze_mda = _pv_analyze_mda_raw,
+	.mda_is_disabled = _mda_is_disabled_raw,
+	.mda_set_disabled = _mda_set_disabled_raw,
+	.pv_analyze_mda = _pv_analyze_mda_raw
 };
 
 /* pvmetadatasize in sectors */
diff --git a/lib/format_text/format-text.h b/lib/format_text/format-text.h
index 9750ffa..adcebc5 100644
--- a/lib/format_text/format-text.h
+++ b/lib/format_text/format-text.h
@@ -17,6 +17,7 @@
 #define _LVM_FORMAT_TEXT_H
 
 #include "lvm-types.h"
+#include "layout.h"
 #include "metadata.h"
 
 #define FMT_TEXT_NAME "lvm2"
@@ -60,6 +61,7 @@ int add_mda(const struct format_type *fmt, struct dm_pool *mem, struct dm_list *
 void del_mdas(struct dm_list *mdas);
 
 const char *vgname_from_mda(const struct format_type *fmt,
+			    struct mda_context *mdac,
 			    struct device_area *dev_area, struct id *vgid,
 			    uint64_t *vgstatus, char **creation_host,
 			    uint64_t *mda_free_sectors);
diff --git a/lib/format_text/layout.h b/lib/format_text/layout.h
index 444a500..eff6553 100644
--- a/lib/format_text/layout.h
+++ b/lib/format_text/layout.h
@@ -46,6 +46,13 @@ struct pv_header {
 	struct disk_locn disk_areas_xl[0];	/* Two lists */
 } __attribute__ ((packed));
 
+/*
+ * Disable this raw location.  This allows us to enable/disable
+ * metadata easily, and thus balance metadata across VGs with
+ * many PVs.
+ */
+#define RAW_LOCN_FLAG_DISABLE 0x00000001
+
 /* On disk */
 struct raw_locn {
 	uint64_t offset;	/* Offset in bytes to start sector */
diff --git a/lib/format_text/text_label.c b/lib/format_text/text_label.c
index 7f02fc6..e6303a9 100644
--- a/lib/format_text/text_label.c
+++ b/lib/format_text/text_label.c
@@ -291,6 +291,7 @@ static int _text_read(struct labeller *l, struct device *dev, void *buf,
 	/* Metadata area headers */
 	dlocn_xl++;
 	while ((offset = xlate64(dlocn_xl->offset))) {
+		/* NOTE: mda header not read from disk until later */
 		add_mda(info->fmt, NULL, &info->mdas, dev, offset,
 			xlate64(dlocn_xl->size));
 		dlocn_xl++;
@@ -298,7 +299,8 @@ static int _text_read(struct labeller *l, struct device *dev, void *buf,
 
 	dm_list_iterate_items(mda, &info->mdas) {
 		mdac = (struct mda_context *) mda->metadata_locn;
-		if ((vgname = vgname_from_mda(info->fmt, &mdac->area,
+		if ((vgname = vgname_from_mda(info->fmt, mdac,
+					      &mdac->area,
 					      &vgid, &vgstatus, &creation_host,
 					      &mdac->free_sectors)) &&
 		    !lvmcache_update_vgname_and_id(info, vgname,
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index 391734b..3bf290f 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -156,6 +156,8 @@ struct metadata_area_ops {
 	int (*pv_analyze_mda) (const struct format_type * fmt,
 			       struct metadata_area *mda);
 
+	int (*mda_is_disabled) (const struct metadata_area *mda);
+	void (*mda_set_disabled) (const struct metadata_area *mda, int value);
 };
 
 struct metadata_area {
-- 
1.6.0.6


