From: Peter Rajnoha <prajnoha@redhat.com>
Date: Thu, 18 Nov 2010 22:32:18 +0100
Subject: [PATCH 04/11] Add pv_remove_metadata_area to format_handler interface.
In-Reply-To: <1290115945-27419-1-git-send-email-prajnoha@redhat.com>
References: <1290115945-27419-1-git-send-email-prajnoha@redhat.com>
Message-ID: <1290115945-27419-5-git-send-email-prajnoha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The same as for pv_add_metadata_area, but removing...

Signed-off-by: Peter Rajnoha <prajnoha@redhat.com>
---
 lib/format_text/format-text.c |   50 +++++++++++++++++++++++++++++++++++++++++
 lib/format_text/format-text.h |    3 ++
 lib/metadata/metadata.h       |    7 +++++
 3 files changed, 60 insertions(+), 0 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 0c1c4c7..db39c80 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -2157,6 +2157,55 @@ bad:
 	return 0;
 }
 
+int remove_metadata_area_from_cache(struct lvmcache_info *info,
+					    unsigned mda_index)
+{
+	struct metadata_area *mda;
+
+	if (mda_index >= FMT_TEXT_MAX_MDAS_PER_PV) {
+		log_error(INTERNAL_ERROR "can't remove metadata with index %u "
+					 "from cache for PV %s. Metadata layout "
+					 "not supported by %s format.",
+					  mda_index, dev_name(info->dev),
+					  info->fmt->name);
+		return 0;
+	}
+
+	mda = info->mda_slots[mda_index];
+
+	dm_list_del(&mda->list);
+	info->mda_slots[mda_index] = NULL;
+	dm_free(mda->metadata_locn);
+	dm_free(mda);
+
+	return 1;
+}
+
+static int _text_pv_remove_metadata_area(const struct format_type *fmt,
+					 struct physical_volume *pv,
+					 unsigned mda_index)
+{
+	struct lvmcache_info *info;
+
+	if (mda_index >= FMT_TEXT_MAX_MDAS_PER_PV) {
+		log_error(INTERNAL_ERROR "invalid index of value %u used "
+			   "while trying to remove metadata area on PV %s. "
+			   "Metadata layout not supported by %s format.",
+			    mda_index, pv_dev_name(pv), fmt->name);
+		return 0;
+	}
+
+	if (!(info = info_from_pvid(pv->dev->pvid, 0)))
+		return_0;
+
+	/* FIXME: Also wipe the mda area with zeroes? */
+
+	if (!remove_metadata_area_from_cache(info, mda_index))
+		return_0;
+
+	return 1;
+}
+
 /* NULL vgname means use only the supplied context e.g. an archive file */
 static struct format_instance *_text_create_text_instance(const struct format_type
 						     *fmt, const char *vgname,
@@ -2298,6 +2347,7 @@ static struct format_handler _text_handler = {
 	.pv_read = _text_pv_read,
 	.pv_setup = _text_pv_setup,
 	.pv_add_metadata_area = _text_pv_add_metadata_area,
+	.pv_remove_metadata_area = _text_pv_remove_metadata_area,
 	.pv_write = _text_pv_write,
 	.vg_setup = _text_vg_setup,
 	.lv_setup = _text_lv_setup,
diff --git a/lib/format_text/format-text.h b/lib/format_text/format-text.h
index 75d69bf..e172e3b 100644
--- a/lib/format_text/format-text.h
+++ b/lib/format_text/format-text.h
@@ -62,6 +62,9 @@ int add_metadata_area_to_cache(struct lvmcache_info *info,
 			       uint64_t mda_size,
 			       unsigned mda_ignored);
 
+int remove_metadata_area_from_cache(struct lvmcache_info *info,
+				    unsigned mda_index);
+
 int add_mda(const struct format_type *fmt, struct dm_pool *mem, struct dm_list *mdas,
 	    struct device *dev, uint64_t start, uint64_t size, unsigned ignored);
 void del_mdas(struct dm_list *mdas);
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index ca2ec0b..a78f3a2 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -259,6 +259,13 @@ struct format_handler {
 				     unsigned metadata_ignored);
 
 	/*
+	 * Remove metadata area from a PV. Changes will take effect on pv_write.
+	 */
+	int (*pv_remove_metadata_area) (const struct format_type *fmt,
+					struct physical_volume *pv,
+					unsigned metadata_index);
+
+	/*
 	 * Write a PV structure to disk. Fails if the PV is in a VG ie
 	 * pv->vg_name must be a valid orphan VG name
 	 */
-- 
1.7.3.2


