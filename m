From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 26 Feb 2013 14:18:14 +0000 (UTC)
Subject: master - pv_header_extension: add support for reading PV header extension (flags & Embedding Area)
Message-ID: <20130226141814.B75D1A0C57@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9dbe25709e3805fbbc8024f0be68de2aae815747
Commit:        9dbe25709e3805fbbc8024f0be68de2aae815747
Parent:        60c5d4c42f904fb018b51364f1b81aa73cac1969
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Feb 14 16:04:35 2013 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Feb 26 11:27:23 2013 +0100

pv_header_extension: add support for reading PV header extension (flags & Embedding Area)

New tools with PV header extension support will read the extension
if it exists and it's not an error if it does not exist (so old PVs
will still work seamlessly with new tools).

Old tools without PV header extension support will just ignore any
extension.

As for the Embedding Area location information (its start and size),
there are actually two places where this is stored:
  - PV header extension
  - VG metadata

The VG metadata contains a copy of what's written in the PV header
extension about the Embedding Area location (NULL value is not copied):

    physical_volumes {
        pv0 {
          id = "AkSSRf-difg-fCCZ-NjAN-qP49-1zzg-S0Fd4T"
          device = "/dev/sda"     # Hint only

          status = ["ALLOCATABLE"]
          flags = []
          dev_size = 262144       # 128 Megabytes
          pe_start = 67584
          pe_count = 23   # 92 Megabytes
          ea_start = 2048
          ea_size = 65536 # 32 Megabytes
        }
    }

The new metadata fields are "ea_start" and "ea_size".
This is mostly useful when restoring the PV by using existing
metadata backups (e.g. pvcreate --restorefile ...).

New tools does not require these two fields to exist in VG metadata,
they're not compulsory. Therefore, reading old VG metadata which doesn't
contain any Embedding Area information will not end up with any kind
of error but only a debug message that the ea_start and ea_size values
were not found.

Old tools just ignore these extra fields in VG metadata.
---
 lib/cache/lvmcache.c          |   13 +++++++++++++
 lib/cache/lvmetad.c           |   40 +++++++++++++++++++++++++++++++---------
 lib/format1/format1.c         |    1 +
 lib/format_text/import_vsn1.c |   17 ++++++++++++++++-
 lib/format_text/layout.h      |    2 +-
 lib/format_text/text_label.c  |   26 ++++++++++++++++++++++++++
 lib/metadata/pv.c             |   10 ++++++++++
 lib/metadata/pv.h             |    2 ++
 tools/pvcreate.c              |    1 +
 9 files changed, 101 insertions(+), 11 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 4da8fe4..13a722f 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -1479,6 +1479,7 @@ struct lvmcache_info *lvmcache_add(struct labeller *labeller, const char *pvid,
 
 		lvmcache_del_mdas(info);
 		lvmcache_del_das(info);
+		lvmcache_del_eas(info);
 	} else {
 		if (existing->dev != dev) {
 			/* Is the existing entry a duplicate pvid e.g. md ? */
@@ -1723,9 +1724,21 @@ int lvmcache_populate_pv_fields(struct lvmcache_info *info,
 		return 0;
 	}
 
+	/* Currently only support one embedding area at most */
+	if (dm_list_size(&info->eas) > 1) {
+		log_error("Must be at most one embedding area (found %d) on PV %s",
+			  dm_list_size(&info->eas), dev_name(info->dev));
+		return 0;
+	}
+
 	dm_list_iterate_items(da, &info->das)
 		pv->pe_start = da->disk_locn.offset >> SECTOR_SHIFT;
 
+	dm_list_iterate_items(da, &info->eas) {
+		pv->ea_start = da->disk_locn.offset >> SECTOR_SHIFT;
+		pv->ea_size = da->disk_locn.size >> SECTOR_SHIFT;
+	}
+
 	return 1;
 }
 
diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 886f163..2f9ffea 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -280,6 +280,7 @@ static struct lvmcache_info *_pv_populate_lvmcache(
 	lvmcache_set_device_size(info, devsize);
 	lvmcache_del_das(info);
 	lvmcache_del_mdas(info);
+	lvmcache_del_eas(info);
 
 	do {
 		sprintf(mda_id, "mda%d", i);
@@ -301,6 +302,15 @@ static struct lvmcache_info *_pv_populate_lvmcache(
 		++i;
 	} while (da);
 
+	i = 0;
+	do {
+		sprintf(da_id, "ea%d", i);
+		da = dm_config_find_node(cn->child, da_id);
+		if (!dm_config_get_uint64(da->child, "offset", &offset)) return_0;
+		if (!dm_config_get_uint64(da->child, "size", &size)) return_0;
+		lvmcache_add_ea(info, offset, size);
+	} while (da);
+
 	return info;
 }
 
@@ -629,7 +639,7 @@ int lvmetad_vg_list_to_lvmcache(struct cmd_context *cmd)
 	return 1;
 }
 
-struct _extract_mda_baton {
+struct _extract_dl_baton {
 	int i;
 	struct dm_config_tree *cft;
 	struct dm_config_node *pre_sib;
@@ -637,7 +647,7 @@ struct _extract_mda_baton {
 
 static int _extract_mda(struct metadata_area *mda, void *baton)
 {
-	struct _extract_mda_baton *b = baton;
+	struct _extract_dl_baton *b = baton;
 	struct dm_config_node *cn;
 	char id[32];
 
@@ -656,21 +666,21 @@ static int _extract_mda(struct metadata_area *mda, void *baton)
 	return 1;
 }
 
-static int _extract_da(struct disk_locn *da, void *baton)
+static int _extract_disk_location(const char *name, struct disk_locn *dl, void *baton)
 {
-	struct _extract_mda_baton *b = baton;
+	struct _extract_dl_baton *b = baton;
 	struct dm_config_node *cn;
 	char id[32];
 
-	if (!da)
+	if (!dl)
 		return 1;
 
-	(void) dm_snprintf(id, 32, "da%d", b->i);
+	(void) dm_snprintf(id, 32, "name%d", b->i);
 	if (!(cn = make_config_node(b->cft, id, b->cft->root, b->pre_sib)))
 		return 0;
 	if (!config_make_nodes(b->cft, cn, NULL,
-			       "offset = %"PRId64, (int64_t) da->offset,
-			       "size = %"PRId64, (int64_t) da->size,
+			       "offset = %"PRId64, (int64_t) dl->offset,
+			       "size = %"PRId64, (int64_t) dl->size,
 			       NULL))
 		return 0;
 
@@ -680,16 +690,28 @@ static int _extract_da(struct disk_locn *da, void *baton)
 	return 1;
 }
 
+static int _extract_da(struct disk_locn *da, void *baton)
+{
+	return _extract_disk_location("da", da, baton);
+}
+
+static int _extract_ea(struct disk_locn *ea, void *baton)
+{
+	return _extract_disk_location("ea", ea, baton);
+}
+
 static int _extract_mdas(struct lvmcache_info *info, struct dm_config_tree *cft,
 			 struct dm_config_node *pre_sib)
 {
-	struct _extract_mda_baton baton = { .i = 0, .cft = cft, .pre_sib = NULL };
+	struct _extract_dl_baton baton = { .i = 0, .cft = cft, .pre_sib = NULL };
 
 	if (!lvmcache_foreach_mda(info, &_extract_mda, &baton))
 		return 0;
 	baton.i = 0;
 	if (!lvmcache_foreach_da(info, &_extract_da, &baton))
 		return 0;
+	if (!lvmcache_foreach_ea(info, &_extract_ea, &baton))
+		return 0;
 
 	return 1;
 }
diff --git a/lib/format1/format1.c b/lib/format1/format1.c
index 335a7e2..c90c266 100644
--- a/lib/format1/format1.c
+++ b/lib/format1/format1.c
@@ -423,6 +423,7 @@ static int _format1_pv_write(const struct format_type *fmt, struct physical_volu
 	lvmcache_update_pv(info, pv, fmt);
 	lvmcache_del_mdas(info);
 	lvmcache_del_das(info);
+	lvmcache_del_eas(info);
 
 	dm_list_init(&pvs);
 
diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index 33ad37d..d5b5a73 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -165,7 +165,7 @@ static int _read_pv(struct format_instance *fid,
 	struct physical_volume *pv;
 	struct pv_list *pvl;
 	const struct dm_config_value *cv;
-	uint64_t size;
+	uint64_t size, ea_start;
 
 	if (!(pvl = dm_pool_zalloc(mem, sizeof(*pvl))) ||
 	    !(pvl->pv = dm_pool_zalloc(mem, sizeof(*pvl->pv))))
@@ -246,6 +246,21 @@ static int _read_pv(struct format_instance *fid,
 		return 0;
 	}
 
+	/* Embedding area is not compulsory - just log_debug if not found. */
+	ea_start = size = 0;
+	if (!_read_uint64(pvn, "ea_start", &ea_start))
+		log_debug("PV Embedding Area start value (ea_start) not found.");
+	if (!_read_uint64(pvn, "ea_size", &size))
+		log_debug("PV Embedding Area size (ea_size) not found.");
+	if ((!ea_start && size) || (ea_start && !size)) {
+		log_error("Incomplete embedding area specification for "
+			  "physical volume.");
+		return 0;
+	} else {
+		pv->ea_start = ea_start;
+		pv->ea_size = size;
+	}
+
 	dm_list_init(&pv->tags);
 	dm_list_init(&pv->segments);
 
diff --git a/lib/format_text/layout.h b/lib/format_text/layout.h
index 6bd3fe4..92dc582 100644
--- a/lib/format_text/layout.h
+++ b/lib/format_text/layout.h
@@ -29,7 +29,7 @@ struct pv_header_extension {
 	uint32_t version;
 	uint32_t flags;
 	/* NULL-terminated list of embedding areas */
-	struct disk_locn embedding_area_xl[0];
+	struct disk_locn embedding_areas_xl[0];
 } __attribute__ ((packed));
 
 /* Fields with the suffix _xl should be xlate'd wherever they appear */
diff --git a/lib/format_text/text_label.c b/lib/format_text/text_label.c
index be28f11..7ee9022 100644
--- a/lib/format_text/text_label.c
+++ b/lib/format_text/text_label.c
@@ -336,11 +336,16 @@ static int _text_read(struct labeller *l, struct device *dev, void *buf,
 {
 	struct label_header *lh = (struct label_header *) buf;
 	struct pv_header *pvhdr;
+	struct pv_header_extension *pvhdr_ext;
 	struct lvmcache_info *info;
 	struct disk_locn *dlocn_xl;
 	uint64_t offset;
+	uint32_t ext_version;
 	struct _update_mda_baton baton;
 
+	/*
+	 * PV header base
+	 */
 	pvhdr = (struct pv_header *) ((char *) buf + xlate32(lh->offset_xl));
 
 	if (!(info = lvmcache_add(l, (char *)pvhdr->pv_uuid, dev,
@@ -354,6 +359,7 @@ static int _text_read(struct labeller *l, struct device *dev, void *buf,
 
 	lvmcache_del_das(info);
 	lvmcache_del_mdas(info);
+	lvmcache_del_eas(info);
 
 	/* Data areas holding the PEs */
 	dlocn_xl = pvhdr->disk_areas_xl;
@@ -369,6 +375,25 @@ static int _text_read(struct labeller *l, struct device *dev, void *buf,
 		dlocn_xl++;
 	}
 
+	dlocn_xl++;
+
+	/*
+	 * PV header extension
+	 */
+	pvhdr_ext = (struct pv_header_extension *) ((char *) dlocn_xl);
+	if (!(ext_version = xlate32(pvhdr_ext->version)))
+		goto out;
+
+	log_debug("%s: PV header extension version %" PRIu32 " found",
+		  dev_name(dev), ext_version);
+
+	/* Embedding areas */
+	dlocn_xl = pvhdr_ext->embedding_areas_xl;
+	while ((offset = xlate64(dlocn_xl->offset))) {
+		lvmcache_add_ea(info, offset, xlate64(dlocn_xl->size));
+		dlocn_xl++;
+	}
+out:
 	baton.info = info;
 	baton.label = *label;
 
@@ -385,6 +410,7 @@ static void _text_destroy_label(struct labeller *l __attribute__((unused)),
 
 	lvmcache_del_mdas(info);
 	lvmcache_del_das(info);
+	lvmcache_del_eas(info);
 }
 
 static void _fmt_text_destroy(struct labeller *l)
diff --git a/lib/metadata/pv.c b/lib/metadata/pv.c
index 3cd06aa..6c165a8 100644
--- a/lib/metadata/pv.c
+++ b/lib/metadata/pv.c
@@ -124,6 +124,16 @@ uint32_t pv_pe_size(const struct physical_volume *pv)
 	return pv_field(pv, pe_size);
 }
 
+uint64_t pv_ea_start(const struct physical_volume *pv)
+{
+	return pv_field(pv, ea_start);
+}
+
+uint64_t pv_ea_size(const struct physical_volume *pv)
+{
+	return pv_field(pv, ea_size);
+}
+
 uint64_t pv_pe_start(const struct physical_volume *pv)
 {
 	return pv_field(pv, pe_start);
diff --git a/lib/metadata/pv.h b/lib/metadata/pv.h
index 69d4868..6db9d87 100644
--- a/lib/metadata/pv.h
+++ b/lib/metadata/pv.h
@@ -80,6 +80,8 @@ uint64_t pv_free(const struct physical_volume *pv);
 uint64_t pv_status(const struct physical_volume *pv);
 uint32_t pv_pe_size(const struct physical_volume *pv);
 uint64_t pv_pe_start(const struct physical_volume *pv);
+uint64_t pv_ea_start(const struct physical_volume *pv);
+uint64_t pv_ea_size(const struct physical_volume *pv);
 uint32_t pv_pe_count(const struct physical_volume *pv);
 uint32_t pv_pe_alloc_count(const struct physical_volume *pv);
 uint64_t pv_mda_size(const struct physical_volume *pv);
diff --git a/tools/pvcreate.c b/tools/pvcreate.c
index d7e7e52..eb2fb5e 100644
--- a/tools/pvcreate.c
+++ b/tools/pvcreate.c
@@ -76,6 +76,7 @@ static int pvcreate_restore_params_validate(struct cmd_context *cmd,
 		pp->rp.pe_start = pv_pe_start(existing_pvl->pv);
 		pp->rp.extent_size = pv_pe_size(existing_pvl->pv);
 		pp->rp.extent_count = pv_pe_count(existing_pvl->pv);
+
 		release_vg(vg);
 	}
 


