From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 26 Feb 2013 14:18:11 +0000 (UTC)
Subject: master - pv_header_extension: add supporting infrastructure for PV header extension (flags & Embedding Area)
Message-ID: <20130226141811.918ECA0C57@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=60c5d4c42f904fb018b51364f1b81aa73cac1969
Commit:        60c5d4c42f904fb018b51364f1b81aa73cac1969
Parent:        6d8de3638c3e715a1c0273e3fed9daf71a871685
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Feb 14 15:35:57 2013 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Feb 26 11:25:16 2013 +0100

pv_header_extension: add supporting infrastructure for PV header extension (flags & Embedding Area)

PV header extension comes just beyond the existing PV header base:

PV header base (existing):
 - uuid
 - device size
 - null-terminated list of Data Areas
 - null-terminater list of MetaData Areas

PV header extension:
 - extension version
 - flags
 - null-terminated list of Embedding Areas

This patch also adds "eas" (Embedding Areas) list to lvmcache (lvmcache_info)
and it also adds support for common operations on the list (just like for
already existing "das" - Data Areas list):
 - lvmcache_add_ea
 - lvmcache_update_eas
 - lvmcache_foreach_ea
 - lvmcache_del_eas

Also, add ea_start and ea_size to struct physical_volume for processing
PV Embedding Area location throughout the code (currently only one
Embedding Area is supported, though the definition on disk allows for
more if needed in the future...).

Also, define FMT_EAS format flag to mark that the format actually
supports Embedding Areas (currently format-text only).
---
 lib/cache/lvmcache.c             |   44 ++++++++++++++++++++++++++++++++++++++
 lib/cache/lvmcache.h             |    7 ++++++
 lib/format_text/format-text.c    |    2 +-
 lib/format_text/format-text.h    |    3 ++
 lib/format_text/layout.h         |   12 ++++++++++
 lib/format_text/text_label.c     |   11 +++++++++
 lib/metadata/metadata-exported.h |    1 +
 lib/metadata/pv.h                |    4 +++
 8 files changed, 83 insertions(+), 1 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index acdd1c8..4da8fe4 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -38,6 +38,7 @@ struct lvmcache_info {
 	struct dm_list list;	/* Join VG members together */
 	struct dm_list mdas;	/* list head for metadata areas */
 	struct dm_list das;	/* list head for data areas */
+	struct dm_list eas;	/* list head for embedding areas */
 	struct lvmcache_vginfo *vginfo;	/* NULL == unknown */
 	struct label *label;
 	const struct format_type *fmt;
@@ -1752,6 +1753,13 @@ void lvmcache_del_das(struct lvmcache_info *info)
 	dm_list_init(&info->das);
 }
 
+void lvmcache_del_eas(struct lvmcache_info *info)
+{
+	if (info->eas.n)
+		del_eas(&info->eas);
+	dm_list_init(&info->eas);
+}
+
 int lvmcache_add_mda(struct lvmcache_info *info, struct device *dev,
 		     uint64_t start, uint64_t size, unsigned ignored)
 {
@@ -1763,6 +1771,10 @@ int lvmcache_add_da(struct lvmcache_info *info, uint64_t start, uint64_t size)
 	return add_da(NULL, &info->das, start, size);
 }
 
+int lvmcache_add_ea(struct lvmcache_info *info, uint64_t start, uint64_t size)
+{
+	return add_ea(NULL, &info->eas, start, size);
+}
 
 void lvmcache_update_pv(struct lvmcache_info *info, struct physical_volume *pv,
 			const struct format_type *fmt)
@@ -1788,6 +1800,25 @@ int lvmcache_update_das(struct lvmcache_info *info, struct physical_volume *pv)
 	return 1;
 }
 
+int lvmcache_update_eas(struct lvmcache_info *info, struct physical_volume *pv)
+{
+	struct data_area_list *ea;
+	if (info->eas.n) {
+		if (!pv->ea_start && !pv->ea_size)
+			dm_list_iterate_items(ea, &info->eas) {
+				pv->ea_start = ea->disk_locn.offset >> SECTOR_SHIFT;
+				pv->ea_size = ea->disk_locn.size >> SECTOR_SHIFT;
+			}
+		del_das(&info->eas);
+	} else
+		dm_list_init(&info->eas);
+
+	if (!add_ea(NULL, &info->eas, pv->ea_start << SECTOR_SHIFT, pv->ea_size << SECTOR_SHIFT))
+		return_0;
+
+	return 1;
+}
+
 int lvmcache_foreach_pv(struct lvmcache_vginfo *vginfo,
 			int (*fun)(struct lvmcache_info *, void *),
 			void *baton)
@@ -1832,6 +1863,19 @@ int lvmcache_foreach_da(struct lvmcache_info *info,
 	return 1;
 }
 
+int lvmcache_foreach_ea(struct lvmcache_info *info,
+			 int (*fun)(struct disk_locn *, void *),
+			 void *baton)
+{
+	struct data_area_list *ea;
+	dm_list_iterate_items(ea, &info->eas) {
+		if (!fun(&ea->disk_locn, baton))
+			return_0;
+	}
+
+	return 1;
+}
+
 /*
  * The lifetime of the label returned is tied to the lifetime of the
  * lvmcache_info which is the same as lvmcache itself.
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index 768cd4c..9ceec19 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -118,9 +118,11 @@ int lvmcache_populate_pv_fields(struct lvmcache_info *info,
 int lvmcache_check_format(struct lvmcache_info *info, const struct format_type *fmt);
 void lvmcache_del_mdas(struct lvmcache_info *info);
 void lvmcache_del_das(struct lvmcache_info *info);
+void lvmcache_del_eas(struct lvmcache_info *info);
 int lvmcache_add_mda(struct lvmcache_info *info, struct device *dev,
 		     uint64_t start, uint64_t size, unsigned ignored);
 int lvmcache_add_da(struct lvmcache_info *info, uint64_t start, uint64_t size);
+int lvmcache_add_ea(struct lvmcache_info *info, uint64_t start, uint64_t size);
 
 const struct format_type *lvmcache_fmt(struct lvmcache_info *info);
 struct label *lvmcache_get_label(struct lvmcache_info *info);
@@ -128,6 +130,7 @@ struct label *lvmcache_get_label(struct lvmcache_info *info);
 void lvmcache_update_pv(struct lvmcache_info *info, struct physical_volume *pv,
 			const struct format_type *fmt);
 int lvmcache_update_das(struct lvmcache_info *info, struct physical_volume *pv);
+int lvmcache_update_eas(struct lvmcache_info *info, struct physical_volume *pv);
 int lvmcache_foreach_mda(struct lvmcache_info *info,
 			 int (*fun)(struct metadata_area *, void *),
 			 void *baton);
@@ -136,6 +139,10 @@ int lvmcache_foreach_da(struct lvmcache_info *info,
 			int (*fun)(struct disk_locn *, void *),
 			void *baton);
 
+int lvmcache_foreach_ea(struct lvmcache_info *info,
+			int (*fun)(struct disk_locn *, void *),
+			void *baton);
+
 int lvmcache_foreach_pv(struct lvmcache_vginfo *vg,
 			int (*fun)(struct lvmcache_info *, void *), void * baton);
 
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index a769daf..e1fbf99 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -2349,7 +2349,7 @@ struct format_type *create_text_format(struct cmd_context *cmd)
 	fmt->orphan_vg_name = ORPHAN_VG_NAME(FMT_TEXT_NAME);
 	fmt->features = FMT_SEGMENTS | FMT_MDAS | FMT_TAGS | FMT_PRECOMMIT |
 			FMT_UNLIMITED_VOLS | FMT_RESIZE_PV |
-			FMT_UNLIMITED_STRIPESIZE;
+			FMT_UNLIMITED_STRIPESIZE | FMT_EAS;
 
 	if (!(mda_lists = dm_malloc(sizeof(struct mda_lists)))) {
 		log_error("Failed to allocate dir_list");
diff --git a/lib/format_text/format-text.h b/lib/format_text/format-text.h
index d8ec255..4706313 100644
--- a/lib/format_text/format-text.h
+++ b/lib/format_text/format-text.h
@@ -58,6 +58,9 @@ int pvhdr_read(struct device *dev, char *buf);
 int add_da(struct dm_pool *mem, struct dm_list *das,
 	   uint64_t start, uint64_t size);
 void del_das(struct dm_list *das);
+int add_ea(struct dm_pool *mem, struct dm_list *eas,
+	   uint64_t start, uint64_t size);
+void del_eas(struct dm_list *eas);
 int add_mda(const struct format_type *fmt, struct dm_pool *mem, struct dm_list *mdas,
 	    struct device *dev, uint64_t start, uint64_t size, unsigned ignored);
 void del_mdas(struct dm_list *mdas);
diff --git a/lib/format_text/layout.h b/lib/format_text/layout.h
index 1a9856d..6bd3fe4 100644
--- a/lib/format_text/layout.h
+++ b/lib/format_text/layout.h
@@ -23,6 +23,15 @@
 
 /* disk_locn and data_area_list are defined in format-text.h */
 
+#define PV_HEADER_EXTENSION_VSN 1
+
+struct pv_header_extension {
+	uint32_t version;
+	uint32_t flags;
+	/* NULL-terminated list of embedding areas */
+	struct disk_locn embedding_area_xl[0];
+} __attribute__ ((packed));
+
 /* Fields with the suffix _xl should be xlate'd wherever they appear */
 /* On disk */
 struct pv_header {
@@ -34,6 +43,9 @@ struct pv_header {
 	/* NULL-terminated list of data areas followed by */
 	/* NULL-terminated list of metadata area headers */
 	struct disk_locn disk_areas_xl[0];	/* Two lists */
+
+	/* PV header extension */
+	struct pv_header_extension ext;
 } __attribute__ ((packed));
 
 /*
diff --git a/lib/format_text/text_label.c b/lib/format_text/text_label.c
index 9d50334..be28f11 100644
--- a/lib/format_text/text_label.c
+++ b/lib/format_text/text_label.c
@@ -196,6 +196,17 @@ void del_das(struct dm_list *das)
 	}
 }
 
+int add_ea(struct dm_pool *mem, struct dm_list *eas,
+	   uint64_t start, uint64_t size)
+{
+	return add_da(mem, eas, start, size);
+}
+
+void del_eas(struct dm_list *eas)
+{
+	del_das(eas);
+}
+
 /* FIXME: refactor this function with other mda constructor code */
 int add_mda(const struct format_type *fmt, struct dm_pool *mem, struct dm_list *mdas,
 	    struct device *dev, uint64_t start, uint64_t size, unsigned ignored)
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 5c8a6df..6624a40 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -107,6 +107,7 @@
 #define FMT_RESIZE_PV		0x00000080U	/* Supports pvresize? */
 #define FMT_UNLIMITED_STRIPESIZE 0x00000100U	/* Unlimited stripe size? */
 #define FMT_RESTRICTED_READAHEAD 0x00000200U	/* Readahead restricted to 2-120? */
+#define FMT_EAS			0x000000400U	/* Supports embedding areas? */
 
 /* Mirror conversion type flags */
 #define MIRROR_BY_SEG		0x00000001U	/* segment-by-segment mirror */
diff --git a/lib/metadata/pv.h b/lib/metadata/pv.h
index b80472a..69d4868 100644
--- a/lib/metadata/pv.h
+++ b/lib/metadata/pv.h
@@ -43,6 +43,10 @@ struct physical_volume {
 	uint64_t status;
 	uint64_t size;
 
+	/* embedding area */
+	uint64_t ea_start;
+	uint64_t ea_size;
+
 	/* physical extents */
 	uint32_t pe_size;
 	uint64_t pe_start;


