From: Peter Rajnoha <prajnoha@redhat.com>
Date: Thu, 18 Nov 2010 22:32:19 +0100
Subject: [PATCH 05/11] Add pv_initialise to format_handler interface.
In-Reply-To: <1290115945-27419-1-git-send-email-prajnoha@redhat.com>
References: <1290115945-27419-1-git-send-email-prajnoha@redhat.com>
Message-ID: <1290115945-27419-6-git-send-email-prajnoha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This is a split-off from the original pv_setup code, a simple refactor.
It makes the code easier to read and cleans up the interface a bit. So
now we will call pv_initialise when we only initialise a PV, creating a
brand new PV.

This patch also adjusts the code reading a PV to fill the mda_slots with
existing mdas so it's prepared for use in new mda add/removal interface.
We allocate the mda_slots based on the value of the maximum allowed
metadata areas for each format which is defined by FMT_<format>_MAX_MDAS_PER_PV.

Signed-off-by: Peter Rajnoha <prajnoha@redhat.com>
---
 lib/format1/disk-rep.c        |    7 +++
 lib/format1/disk-rep.h        |    1 +
 lib/format1/format1.c         |   57 +++++++++++++++++++++-----
 lib/format1/format1.h         |    1 +
 lib/format1/lvm1-label.c      |    5 ++
 lib/format_pool/disk_rep.c    |    4 ++
 lib/format_pool/disk_rep.h    |    1 +
 lib/format_pool/format_pool.c |   13 ++++++
 lib/format_pool/format_pool.h |    1 +
 lib/format_text/format-text.c |   91 +++++++++++++++++++++++++++++++++++++++++
 lib/format_text/format-text.h |    1 -
 lib/format_text/text_label.c  |   26 +++++-------
 lib/metadata/metadata.c       |   14 ++++++
 lib/metadata/metadata.h       |   13 ++++++
 14 files changed, 209 insertions(+), 26 deletions(-)

diff --git a/lib/format1/disk-rep.c b/lib/format1/disk-rep.c
index bc58744..38cb34d 100644
--- a/lib/format1/disk-rep.c
+++ b/lib/format1/disk-rep.c
@@ -337,6 +337,13 @@ static void __update_lvmcache(const struct format_type *fmt,
 
 	info->device_size = xlate32(dl->pvd.pv_size) << SECTOR_SHIFT;
 	dm_list_init(&info->mdas);
+	if (info->mda_slots)
+		dm_free(info->mda_slots);
+	if (!(info->mda_slots = dm_zalloc(FMT_LVM1_MAX_MDAS_PER_PV * sizeof(struct metadata_area *)))) {
+		/* FIXME: Add revert of cache info! */
+		stack;
+		return;
+	}
 	info->status &= ~CACHE_INVALID;
 }
 
diff --git a/lib/format1/disk-rep.h b/lib/format1/disk-rep.h
index 0d54438..65fad1b 100644
--- a/lib/format1/disk-rep.h
+++ b/lib/format1/disk-rep.h
@@ -18,6 +18,7 @@
 
 #include "lvm-types.h"
 #include "metadata.h"
+#include "format1.h"
 #include "toolcontext.h"
 
 #define MAX_PV 256
diff --git a/lib/format1/format1.c b/lib/format1/format1.c
index 0dcec05..4904a59 100644
--- a/lib/format1/format1.c
+++ b/lib/format1/format1.c
@@ -362,17 +362,17 @@ static int _format1_pv_read(const struct format_type *fmt, const char *pv_name,
 	return r;
 }
 
-static int _format1_pv_setup(const struct format_type *fmt,
-			     uint64_t pe_start, uint32_t extent_count,
-			     uint32_t extent_size,
-			     unsigned long data_alignment __attribute__((unused)),
-			     unsigned long data_alignment_offset __attribute__((unused)),
-			     int pvmetadatacopies __attribute__((unused)),
-			     uint64_t pvmetadatasize __attribute__((unused)),
-			     unsigned metadataignore __attribute__((unused)),
-			     struct dm_list *mdas __attribute__((unused)),
-			     struct physical_volume *pv, struct volume_group *vg __attribute__((unused)))
+static int _format1_pv_initialise(const struct format_type * fmt,
+				  int64_t label_sector,
+				  uint64_t pe_start,
+				  uint32_t extent_count,
+				  uint32_t extent_size,
+				  unsigned long data_alignment __attribute__((unused)),
+				  unsigned long data_alignment_offset __attribute__((unused)),
+				  struct physical_volume * pv)
 {
+	struct lvmcache_info *info;
+
 	if (pv->size > MAX_PV_SIZE)
 		pv->size--;
 	if (pv->size > MAX_PV_SIZE) {
@@ -398,9 +398,45 @@ static int _format1_pv_setup(const struct format_type *fmt,
 		return 0;
 	}
 
+	/* Add newly initialised PV to cache. */
+        if (!(info = lvmcache_add(fmt->labeller, (char *) &pv->id, pv->dev,
+                                        fmt->orphan_vg_name, NULL, 0)))
+                return_0;
+
+        if (label_sector != -1)
+                info->label->sector = label_sector;
+
+        info->device_size = pv->size << SECTOR_SHIFT;
+        info->fmt = fmt;
+
+        if (info->mdas.n)
+                del_mdas(&info->mdas);
+        else
+                dm_list_init(&info->mdas);
+
+	dm_free(info->mda_slots);
+	if (!(info->mda_slots = dm_zalloc(FMT_LVM1_MAX_MDAS_PER_PV * sizeof(struct metadata_area *)))) {
+		/* FIXME: Add revert of cache info! */
+		return 0;
+	}
+
 	return 1;
 }
 
+static int _format1_pv_setup(const struct format_type *fmt,
+			     uint64_t pe_start, uint32_t extent_count,
+			     uint32_t extent_size,
+			     unsigned long data_alignment __attribute__((unused)),
+			     unsigned long data_alignment_offset __attribute__((unused)),
+			     int pvmetadatacopies __attribute__((unused)),
+			     uint64_t pvmetadatasize __attribute__((unused)),
+			     unsigned metadataignore __attribute__((unused)),
+			     struct dm_list *mdas __attribute__((unused)),
+			     struct physical_volume *pv, struct volume_group *vg __attribute__((unused)))
+{
+	return _format1_pv_initialise(fmt, -1, 0, 0, vg->extent_size, 0, 0, pv);
+}
+
 static int _format1_lv_setup(struct format_instance *fid, struct logical_volume *lv)
 {
 	uint64_t max_size = UINT_MAX;
@@ -562,6 +598,7 @@ static void _format1_destroy(const struct format_type *fmt)
 
 static struct format_handler _format1_ops = {
 	.pv_read = _format1_pv_read,
+	.pv_initialise = _format1_pv_initialise,
 	.pv_setup = _format1_pv_setup,
 	.pv_write = _format1_pv_write,
 	.lv_setup = _format1_lv_setup,
diff --git a/lib/format1/format1.h b/lib/format1/format1.h
index c76ba62..ab7b571 100644
--- a/lib/format1/format1.h
+++ b/lib/format1/format1.h
@@ -21,6 +21,7 @@
 
 #define FMT_LVM1_NAME "lvm1"
 #define FMT_LVM1_ORPHAN_VG_NAME ORPHAN_VG_NAME(FMT_LVM1_NAME)
+#define FMT_LVM1_MAX_MDAS_PER_PV 1
 
 #ifdef LVM1_INTERNAL
 struct format_type *init_lvm1_format(struct cmd_context *cmd);
diff --git a/lib/format1/lvm1-label.c b/lib/format1/lvm1-label.c
index 07596a5..dbab874 100644
--- a/lib/format1/lvm1-label.c
+++ b/lib/format1/lvm1-label.c
@@ -82,6 +82,11 @@ static int _lvm1_read(struct labeller *l, struct device *dev, void *buf,
 	info->device_size = xlate32(pvd->pv_size) << SECTOR_SHIFT;
 	dm_list_init(&info->mdas);
 
+	if (!(info->mda_slots = dm_zalloc(FMT_LVM1_MAX_MDAS_PER_PV * sizeof(struct metadata_area *)))) {
+		/* FIXME: Add revert of cache info! */
+		return 0;
+	}
+
 	info->status &= ~CACHE_INVALID;
 
 	return 1;
diff --git a/lib/format_pool/disk_rep.c b/lib/format_pool/disk_rep.c
index 2c16f50..9bd8604 100644
--- a/lib/format_pool/disk_rep.c
+++ b/lib/format_pool/disk_rep.c
@@ -105,6 +105,10 @@ int read_pool_label(struct pool_list *pl, struct labeller *l,
 
 	info->device_size = xlate32_be(pd->pl_blocks) << SECTOR_SHIFT;
 	dm_list_init(&info->mdas);
+	if (!(info->mda_slots = dm_zalloc(FMT_POOL_MAX_MDAS_PER_PV * sizeof(struct metadata_area *)))) {
+		/* FIXME: Add revert of cache info! */
+		return 0;
+	}
 
 	info->status &= ~CACHE_INVALID;
 
diff --git a/lib/format_pool/disk_rep.h b/lib/format_pool/disk_rep.h
index fff7343..af620c9 100644
--- a/lib/format_pool/disk_rep.h
+++ b/lib/format_pool/disk_rep.h
@@ -18,6 +18,7 @@
 
 #include "label.h"
 #include "metadata.h"
+#include "format_pool.h"
 
 #define MINOR_OFFSET 65536
 
diff --git a/lib/format_pool/format_pool.c b/lib/format_pool/format_pool.c
index 04b5611..dbb73dd 100644
--- a/lib/format_pool/format_pool.c
+++ b/lib/format_pool/format_pool.c
@@ -188,6 +188,18 @@ out:
 	return NULL;
 }
 
+static int _pool_pv_initialise(const struct format_type *fmt __attribute__((unused)),
+			       int64_t label_sector __attribute__((unused)),
+			       uint64_t pe_start __attribute__((unused)),
+			       uint32_t extent_count __attribute__((unused)),
+			       uint32_t extent_size __attribute__((unused)),
+			       unsigned long data_alignment __attribute__((unused)),
+			       unsigned long data_alignment_offset __attribute__((unused)),
+			       struct physical_volume *pv __attribute__((unused)))
+{
+	return 1;
+}
+
 static int _pool_pv_setup(const struct format_type *fmt __attribute__((unused)),
 			  uint64_t pe_start __attribute__((unused)),
 			  uint32_t extent_count __attribute__((unused)),
@@ -294,6 +306,7 @@ static void _pool_destroy(const struct format_type *fmt)
 /* *INDENT-OFF* */
 static struct format_handler _format_pool_ops = {
 	.pv_read = _pool_pv_read,
+	.pv_initialise = _pool_pv_initialise,
 	.pv_setup = _pool_pv_setup,
 	.create_instance = _pool_create_instance,
 	.destroy_instance = _pool_destroy_instance,
diff --git a/lib/format_pool/format_pool.h b/lib/format_pool/format_pool.h
index 0d4b973..afe90cc 100644
--- a/lib/format_pool/format_pool.h
+++ b/lib/format_pool/format_pool.h
@@ -20,6 +20,7 @@
 
 #define FMT_POOL_NAME "pool"
 #define FMT_POOL_ORPHAN_VG_NAME ORPHAN_VG_NAME(FMT_POOL_NAME)
+#define FMT_POOL_MAX_MDAS_PER_PV 1
 
 #ifdef POOL_INTERNAL
 struct format_type *init_pool_format(struct cmd_context *cmd);
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index db39c80..e47cb81 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1691,6 +1691,96 @@ static int _text_pv_read(const struct format_type *fmt, const char *pv_name,
 	return 1;
 }
 
+static int _text_pv_initialise(const struct format_type *fmt,
+			       const int64_t label_sector,
+			       uint64_t pe_start,
+			       uint32_t extent_count,
+			       uint32_t extent_size,
+			       unsigned long data_alignment,
+			       unsigned long data_alignment_offset,
+			       struct physical_volume *pv)
+{
+	struct lvmcache_info *info;
+
+	pv->fmt = fmt;
+	pv->vg_name = fmt->orphan_vg_name;
+
+	/*
+	 * Try to keep the value of PE start set to a firm value if requested.
+	 * This is usefull when restoring existing PE start value (backups etc.).
+	 */
+	if (pe_start) {
+		pv->pe_start_locked = 1;
+		pv->pe_start = pe_start;
+	}
+
+	if (!data_alignment)
+		data_alignment = find_config_tree_int(pv->fmt->cmd,
+					      "devices/data_alignment",
+					      0) * 2;
+
+	if (set_pe_align(pv, data_alignment) != data_alignment &&
+	    data_alignment) {
+		log_error("%s: invalid data alignment of "
+			  "%lu sectors (requested %lu sectors)",
+			  pv_dev_name(pv), pv->pe_align, data_alignment);
+		return 0;
+	}
+
+	if (set_pe_align_offset(pv, data_alignment_offset) != data_alignment_offset &&
+	    data_alignment_offset) {
+		log_error("%s: invalid data alignment offset of "
+			  "%lu sectors (requested %lu sectors)",
+			  pv_dev_name(pv), pv->pe_align_offset, data_alignment_offset);
+		return 0;
+	}
+
+	if (pv->pe_align < pv->pe_align_offset) {
+		log_error("%s: pe_align (%lu sectors) must not be less "
+			  "than pe_align_offset (%lu sectors)",
+			  pv_dev_name(pv), pv->pe_align, pv->pe_align_offset);
+		return 0;
+	}
+
+	if (!pv->pe_start_locked && pv->pe_start < pv->pe_align)
+		pv->pe_start = pv->pe_align;
+
+	if (extent_size)
+		pv->pe_size = extent_size;
+
+	if (extent_count)
+		pv->pe_count = extent_count;
+
+	if ((pv->pe_start + pv->pe_count * pv->pe_size - 1) > (pv->size << SECTOR_SHIFT)) {
+		log_error("Physical extents end beyond end of device %s.",
+			   pv_dev_name(pv));
+		return 0;
+	}
+
+	/* Add newly initialised PV to cache. */
+	if (!(info = lvmcache_add(fmt->labeller, (char *) &pv->id, pv->dev,
+					fmt->orphan_vg_name, NULL, 0)))
+		return_0;
+
+	if (label_sector != -1)
+		info->label->sector = label_sector;
+
+	info->device_size = pv->size << SECTOR_SHIFT;
+	info->fmt = fmt;
+
+	if (info->mdas.n)
+		del_mdas(&info->mdas);
+	else
+		dm_list_init(&info->mdas);
+
+	if (!(info->mda_slots = dm_zalloc(FMT_TEXT_MAX_MDAS_PER_PV * sizeof(struct metadata_area *)))) {
+		/* FIXME: Add revert of cache info! */
+		return 0;
+	}
+
+	return 1;
+}
+
 static void _text_destroy_instance(struct format_instance *fid __attribute__((unused)))
 {
 }
@@ -2345,6 +2435,7 @@ void *create_text_context(struct cmd_context *cmd, const char *path,
 static struct format_handler _text_handler = {
 	.scan = _text_scan,
 	.pv_read = _text_pv_read,
+	.pv_initialise = _text_pv_initialise,
 	.pv_setup = _text_pv_setup,
 	.pv_add_metadata_area = _text_pv_add_metadata_area,
 	.pv_remove_metadata_area = _text_pv_remove_metadata_area,
diff --git a/lib/format_text/format-text.h b/lib/format_text/format-text.h
index e172e3b..7459c0e 100644
--- a/lib/format_text/format-text.h
+++ b/lib/format_text/format-text.h
@@ -67,6 +67,5 @@ int remove_metadata_area_from_cache(struct lvmcache_info *info,
 
 int add_mda(const struct format_type *fmt, struct dm_pool *mem, struct dm_list *mdas,
 	    struct device *dev, uint64_t start, uint64_t size, unsigned ignored);
-void del_mdas(struct dm_list *mdas);
 
 #endif
diff --git a/lib/format_text/text_label.c b/lib/format_text/text_label.c
index e459cde..192b702 100644
--- a/lib/format_text/text_label.c
+++ b/lib/format_text/text_label.c
@@ -229,19 +229,6 @@ int add_mda(const struct format_type *fmt, struct dm_pool *mem, struct dm_list *
 	return 1;
 }
 
-void del_mdas(struct dm_list *mdas)
-{
-	struct dm_list *mdah, *tmp;
-	struct metadata_area *mda;
-
-	dm_list_iterate_safe(mdah, tmp, mdas) {
-		mda = dm_list_item(mdah, struct metadata_area);
-		dm_free(mda->metadata_locn);
-		dm_list_del(&mda->list);
-		dm_free(mda);
-	}
-}
-
 static int _text_initialise_label(struct labeller *l __attribute__((unused)),
 				  struct label *label)
 {
@@ -257,6 +244,7 @@ static int _text_read(struct labeller *l, struct device *dev, void *buf,
 	struct pv_header *pvhdr;
 	struct lvmcache_info *info;
 	struct disk_locn *dlocn_xl;
+	unsigned dlocn_index = 0;
 	uint64_t offset;
 	struct metadata_area *mda;
 	struct id vgid;
@@ -284,6 +272,11 @@ static int _text_read(struct labeller *l, struct device *dev, void *buf,
 		del_mdas(&info->mdas);
 	dm_list_init(&info->mdas);
 
+	if (!(info->mda_slots = dm_zalloc(FMT_TEXT_MAX_MDAS_PER_PV * sizeof(struct metadata_area *)))) {
+		/* FIXME: Add revert of cache info! */
+		return 0;
+	}
+
 	/* Data areas holding the PEs */
 	dlocn_xl = pvhdr->disk_areas_xl;
 	while ((offset = xlate64(dlocn_xl->offset))) {
@@ -295,9 +288,12 @@ static int _text_read(struct labeller *l, struct device *dev, void *buf,
 	/* Metadata area headers */
 	dlocn_xl++;
 	while ((offset = xlate64(dlocn_xl->offset))) {
-		add_mda(info->fmt, NULL, &info->mdas, dev, offset,
-			xlate64(dlocn_xl->size), 0);
+		/* FIXME: Check order! We could possibly have mda at the end only! */
+		/* 	  E.g. check relative position to data area etc. */
+		add_metadata_area_to_cache(info, dlocn_index, offset,
+					   xlate64(dlocn_xl->size), 0);
 		dlocn_xl++;
+		dlocn_index++;
 	}
 
 	dm_list_iterate_items(mda, &info->mdas) {
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 61b4600..9ff9607 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3855,6 +3855,20 @@ struct metadata_area *mda_copy(struct dm_pool *mem,
 
 	return mda_new;
 }
+
+void del_mdas(struct dm_list *mdas)
+{
+	struct dm_list *mdah, *tmp;
+	struct metadata_area *mda;
+
+	dm_list_iterate_safe(mdah, tmp, mdas) {
+		mda = dm_list_item(mdah, struct metadata_area);
+		dm_free(mda->metadata_locn);
+		dm_list_del(&mda->list);
+		dm_free(mda);
+	}
+}
+
 /*
  * This function provides a way to answer the question on a format specific
  * basis - does the format specfic context of these two metadata areas
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index a78f3a2..b69c9ee 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -187,6 +187,7 @@ struct metadata_area {
 };
 struct metadata_area *mda_copy(struct dm_pool *mem,
 			       struct metadata_area *mda);
+void del_mdas(struct dm_list *mdas);
 
 unsigned mda_is_ignored(struct metadata_area *mda);
 void mda_set_ignored(struct metadata_area *mda, unsigned ignored);
@@ -238,6 +239,18 @@ struct format_handler {
 			int scan_label_only);
 
 	/*
+	 * Initialise a new PV.
+	 */
+	int (*pv_initialise) (const struct format_type * fmt,
+			      int64_t label_sector,
+			      uint64_t pe_start,
+			      uint32_t extent_count,
+			      uint32_t extent_size,
+			      unsigned long data_alignment,
+			      unsigned long data_alignment_offset,
+			      struct physical_volume * pv);
+
+	/*
 	 * Tweak an already filled out a pv ready for importing into a
 	 * vg.  eg. pe_count is format specific.
 	 */
-- 
1.7.3.2


