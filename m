From: Peter Rajnoha <prajnoha@redhat.com>
Date: Mon, 24 Jan 2011 12:03:59 +0100
Subject: [PATCH 08/17] Add pv_remove_metadata_area fn to support removing metadata areas on demand.
In-Reply-To: <1295867048-21558-1-git-send-email-prajnoha@redhat.com>
References: <1295867048-21558-1-git-send-email-prajnoha@redhat.com>
Message-ID: <1295867048-21558-9-git-send-email-prajnoha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The same as for pv_add_metadata_area, but removing...

Signed-off-by: Peter Rajnoha <prajnoha@redhat.com>
---
 lib/format_text/format-text.c |   24 ++++++++++++++++++++++++
 lib/format_text/format-text.h |    2 ++
 lib/metadata/metadata.h       |    7 +++++++
 3 files changed, 33 insertions(+), 0 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index cf18f25..99f691f 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -2275,6 +2275,29 @@ bad:
 	return 0;
 }
 
+int remove_metadata_area_from_pv(struct physical_volume *pv,
+				 unsigned mda_index)
+{
+	if (mda_index >= FMT_TEXT_MAX_MDAS_PER_PV) {
+		log_error(INTERNAL_ERROR "can't remove metadata area with "
+					 "index %u from PV %s. Metadata "
+					 "layou not supported by %s format.",
+					  mda_index, dev_name(pv->dev),
+					  pv->fmt->name);
+		return 0;
+	}
+
+	return fid_remove_mda(pv->fid, NULL, (const char *) &pv->id,
+			      ID_LEN, mda_index);
+}
+
+static int _text_pv_remove_metadata_area(const struct format_type *fmt,
+					 struct physical_volume *pv,
+					 unsigned mda_index)
+{
+	return remove_metadata_area_from_pv(pv, mda_index);
+}
+
 /* NULL vgname means use only the supplied context e.g. an archive file */
 static struct format_instance *_text_create_text_instance(const struct format_type *fmt,
 							  const char *pvid,
@@ -2356,6 +2379,7 @@ static struct format_handler _text_handler = {
 	.pv_read = _text_pv_read,
 	.pv_setup = _text_pv_setup,
 	.pv_add_metadata_area = _text_pv_add_metadata_area,
+	.pv_remove_metadata_area = _text_pv_remove_metadata_area,
 	.pv_write = _text_pv_write,
 	.vg_setup = _text_vg_setup,
 	.lv_setup = _text_lv_setup,
diff --git a/lib/format_text/format-text.h b/lib/format_text/format-text.h
index f65be74..694b5c1 100644
--- a/lib/format_text/format-text.h
+++ b/lib/format_text/format-text.h
@@ -61,6 +61,8 @@ int add_metadata_area_to_pv(struct physical_volume *pv,
 			    uint64_t mda_start,
 			    uint64_t mda_size,
 			    unsigned mda_ignored);
+int remove_metadata_area_from_pv(struct physical_volume *pv,
+				 unsigned mda_index);
 int add_mda(const struct format_type *fmt, struct dm_pool *mem, struct dm_list *mdas,
 	    struct device *dev, uint64_t start, uint64_t size, unsigned ignored);
 void del_mdas(struct dm_list *mdas);
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index 0da8b3d..ed72551 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -266,6 +266,13 @@ struct format_handler {
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
1.7.3.4


