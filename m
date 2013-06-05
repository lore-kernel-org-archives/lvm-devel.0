From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed,  5 Jun 2013 12:04:12 +0000 (UTC)
Subject: dev-mornfall-lvmcache - refactor: rename embedding area -> bootloader area
Message-ID: <20130605120412.B46DE60F7E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=732859d21f3b41bdb188f92b60f25d5c94dcee8a
Commit:        732859d21f3b41bdb188f92b60f25d5c94dcee8a
Parent:        9966842810b9044d0a59eebbf05856a3a10102b4
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue May 28 12:37:22 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue May 28 12:37:22 2013 +0200

refactor: rename embedding area -> bootloader area

---
 WHATS_NEW                        |    6 ++--
 lib/cache/lvmcache.c             |   58 +++++++++++++++++-----------------
 lib/cache/lvmcache.h             |    8 ++--
 lib/cache/lvmetad.c              |   10 +++---
 lib/format1/format1.c            |    6 ++--
 lib/format_text/export.c         |    6 ++--
 lib/format_text/format-text.c    |   64 +++++++++++++++++++-------------------
 lib/format_text/format-text.h    |    4 +-
 lib/format_text/import_vsn1.c    |   22 ++++++------
 lib/format_text/layout.h         |    4 +-
 lib/format_text/text_label.c     |   48 ++++++++++++++--------------
 lib/metadata/metadata-exported.h |    6 ++--
 lib/metadata/metadata.c          |    4 +-
 lib/metadata/pv.c                |    8 ++--
 lib/metadata/pv.h                |   10 +++---
 lib/report/columns.h             |    4 +-
 lib/report/properties.c          |    8 ++--
 man/pvcreate.8.in                |   18 +++++-----
 man/vgconvert.8.in               |    2 +-
 tools/args.h                     |    2 +-
 tools/commands.h                 |    8 ++--
 tools/pvcreate.c                 |    4 +-
 tools/toollib.c                  |   12 +++---
 tools/vgconvert.c                |   14 ++++----
 24 files changed, 168 insertions(+), 168 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 3b88732..977519c 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -38,9 +38,9 @@ Version 2.02.99 -
   Add --withcomments and --withversions switch to lvm dumpconfig.
   Add --type {current|default|missing|new} and --atversion to lvm dumpconfig.
   Support automatic config validation and add 'config' section to lvm.conf.
-  Add pvs -o ea_start,ea_size to report embedding area start and size.
-  Add --embeddingareasize to pvcreate and vgconvert to create an embedding area.
-  Add PV header extension: extension version, flags and embedding areas.
+  Add pvs -o ea_start,ea_size to report bootloader area start and size.
+  Add --bootloaderareasize to pvcreate and vgconvert to create a bootloader area.
+  Add PV header extension: extension version, flags and bootloader areas.
   Initial support for lvconvert of thin external origin.
   Add _lv_remove_segs_using_this_lv() for removal of dependent lvs.
   Improve activation code for better support of stacked devices.
diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 13a722f..174c133 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -38,7 +38,7 @@ struct lvmcache_info {
 	struct dm_list list;	/* Join VG members together */
 	struct dm_list mdas;	/* list head for metadata areas */
 	struct dm_list das;	/* list head for data areas */
-	struct dm_list eas;	/* list head for embedding areas */
+	struct dm_list bas;	/* list head for bootloader areas */
 	struct lvmcache_vginfo *vginfo;	/* NULL == unknown */
 	struct label *label;
 	const struct format_type *fmt;
@@ -1479,7 +1479,7 @@ struct lvmcache_info *lvmcache_add(struct labeller *labeller, const char *pvid,
 
 		lvmcache_del_mdas(info);
 		lvmcache_del_das(info);
-		lvmcache_del_eas(info);
+		lvmcache_del_bas(info);
 	} else {
 		if (existing->dev != dev) {
 			/* Is the existing entry a duplicate pvid e.g. md ? */
@@ -1724,19 +1724,19 @@ int lvmcache_populate_pv_fields(struct lvmcache_info *info,
 		return 0;
 	}
 
-	/* Currently only support one embedding area at most */
-	if (dm_list_size(&info->eas) > 1) {
-		log_error("Must be at most one embedding area (found %d) on PV %s",
-			  dm_list_size(&info->eas), dev_name(info->dev));
+	/* Currently only support one bootloader area at most */
+	if (dm_list_size(&info->bas) > 1) {
+		log_error("Must be at most one bootloader area (found %d) on PV %s",
+			  dm_list_size(&info->bas), dev_name(info->dev));
 		return 0;
 	}
 
 	dm_list_iterate_items(da, &info->das)
 		pv->pe_start = da->disk_locn.offset >> SECTOR_SHIFT;
 
-	dm_list_iterate_items(da, &info->eas) {
-		pv->ea_start = da->disk_locn.offset >> SECTOR_SHIFT;
-		pv->ea_size = da->disk_locn.size >> SECTOR_SHIFT;
+	dm_list_iterate_items(da, &info->bas) {
+		pv->ba_start = da->disk_locn.offset >> SECTOR_SHIFT;
+		pv->ba_size = da->disk_locn.size >> SECTOR_SHIFT;
 	}
 
 	return 1;
@@ -1766,11 +1766,11 @@ void lvmcache_del_das(struct lvmcache_info *info)
 	dm_list_init(&info->das);
 }
 
-void lvmcache_del_eas(struct lvmcache_info *info)
+void lvmcache_del_bas(struct lvmcache_info *info)
 {
-	if (info->eas.n)
-		del_eas(&info->eas);
-	dm_list_init(&info->eas);
+	if (info->bas.n)
+		del_bas(&info->bas);
+	dm_list_init(&info->bas);
 }
 
 int lvmcache_add_mda(struct lvmcache_info *info, struct device *dev,
@@ -1784,9 +1784,9 @@ int lvmcache_add_da(struct lvmcache_info *info, uint64_t start, uint64_t size)
 	return add_da(NULL, &info->das, start, size);
 }
 
-int lvmcache_add_ea(struct lvmcache_info *info, uint64_t start, uint64_t size)
+int lvmcache_add_ba(struct lvmcache_info *info, uint64_t start, uint64_t size)
 {
-	return add_ea(NULL, &info->eas, start, size);
+	return add_ba(NULL, &info->bas, start, size);
 }
 
 void lvmcache_update_pv(struct lvmcache_info *info, struct physical_volume *pv,
@@ -1813,20 +1813,20 @@ int lvmcache_update_das(struct lvmcache_info *info, struct physical_volume *pv)
 	return 1;
 }
 
-int lvmcache_update_eas(struct lvmcache_info *info, struct physical_volume *pv)
+int lvmcache_update_bas(struct lvmcache_info *info, struct physical_volume *pv)
 {
-	struct data_area_list *ea;
-	if (info->eas.n) {
-		if (!pv->ea_start && !pv->ea_size)
-			dm_list_iterate_items(ea, &info->eas) {
-				pv->ea_start = ea->disk_locn.offset >> SECTOR_SHIFT;
-				pv->ea_size = ea->disk_locn.size >> SECTOR_SHIFT;
+	struct data_area_list *ba;
+	if (info->bas.n) {
+		if (!pv->ba_start && !pv->ba_size)
+			dm_list_iterate_items(ba, &info->bas) {
+				pv->ba_start = ba->disk_locn.offset >> SECTOR_SHIFT;
+				pv->ba_size = ba->disk_locn.size >> SECTOR_SHIFT;
 			}
-		del_das(&info->eas);
+		del_das(&info->bas);
 	} else
-		dm_list_init(&info->eas);
+		dm_list_init(&info->bas);
 
-	if (!add_ea(NULL, &info->eas, pv->ea_start << SECTOR_SHIFT, pv->ea_size << SECTOR_SHIFT))
+	if (!add_ba(NULL, &info->bas, pv->ba_start << SECTOR_SHIFT, pv->ba_size << SECTOR_SHIFT))
 		return_0;
 
 	return 1;
@@ -1876,13 +1876,13 @@ int lvmcache_foreach_da(struct lvmcache_info *info,
 	return 1;
 }
 
-int lvmcache_foreach_ea(struct lvmcache_info *info,
+int lvmcache_foreach_ba(struct lvmcache_info *info,
 			 int (*fun)(struct disk_locn *, void *),
 			 void *baton)
 {
-	struct data_area_list *ea;
-	dm_list_iterate_items(ea, &info->eas) {
-		if (!fun(&ea->disk_locn, baton))
+	struct data_area_list *ba;
+	dm_list_iterate_items(ba, &info->bas) {
+		if (!fun(&ba->disk_locn, baton))
 			return_0;
 	}
 
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index 9ceec19..119b411 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -118,11 +118,11 @@ int lvmcache_populate_pv_fields(struct lvmcache_info *info,
 int lvmcache_check_format(struct lvmcache_info *info, const struct format_type *fmt);
 void lvmcache_del_mdas(struct lvmcache_info *info);
 void lvmcache_del_das(struct lvmcache_info *info);
-void lvmcache_del_eas(struct lvmcache_info *info);
+void lvmcache_del_bas(struct lvmcache_info *info);
 int lvmcache_add_mda(struct lvmcache_info *info, struct device *dev,
 		     uint64_t start, uint64_t size, unsigned ignored);
 int lvmcache_add_da(struct lvmcache_info *info, uint64_t start, uint64_t size);
-int lvmcache_add_ea(struct lvmcache_info *info, uint64_t start, uint64_t size);
+int lvmcache_add_ba(struct lvmcache_info *info, uint64_t start, uint64_t size);
 
 const struct format_type *lvmcache_fmt(struct lvmcache_info *info);
 struct label *lvmcache_get_label(struct lvmcache_info *info);
@@ -130,7 +130,7 @@ struct label *lvmcache_get_label(struct lvmcache_info *info);
 void lvmcache_update_pv(struct lvmcache_info *info, struct physical_volume *pv,
 			const struct format_type *fmt);
 int lvmcache_update_das(struct lvmcache_info *info, struct physical_volume *pv);
-int lvmcache_update_eas(struct lvmcache_info *info, struct physical_volume *pv);
+int lvmcache_update_bas(struct lvmcache_info *info, struct physical_volume *pv);
 int lvmcache_foreach_mda(struct lvmcache_info *info,
 			 int (*fun)(struct metadata_area *, void *),
 			 void *baton);
@@ -139,7 +139,7 @@ int lvmcache_foreach_da(struct lvmcache_info *info,
 			int (*fun)(struct disk_locn *, void *),
 			void *baton);
 
-int lvmcache_foreach_ea(struct lvmcache_info *info,
+int lvmcache_foreach_ba(struct lvmcache_info *info,
 			int (*fun)(struct disk_locn *, void *),
 			void *baton);
 
diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 348827d..7aa8641 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -280,7 +280,7 @@ static struct lvmcache_info *_pv_populate_lvmcache(
 	lvmcache_set_device_size(info, devsize);
 	lvmcache_del_das(info);
 	lvmcache_del_mdas(info);
-	lvmcache_del_eas(info);
+	lvmcache_del_bas(info);
 
 	do {
 		sprintf(mda_id, "mda%d", i);
@@ -309,7 +309,7 @@ static struct lvmcache_info *_pv_populate_lvmcache(
 		if (da) {
 			if (!dm_config_get_uint64(da->child, "offset", &offset)) return_0;
 			if (!dm_config_get_uint64(da->child, "size", &size)) return_0;
-			lvmcache_add_ea(info, offset, size);
+			lvmcache_add_ba(info, offset, size);
 		}
 		++i;
 	} while (da);
@@ -706,9 +706,9 @@ static int _extract_da(struct disk_locn *da, void *baton)
 	return _extract_disk_location("da", da, baton);
 }
 
-static int _extract_ea(struct disk_locn *ea, void *baton)
+static int _extract_ba(struct disk_locn *ba, void *baton)
 {
-	return _extract_disk_location("ea", ea, baton);
+	return _extract_disk_location("ba", ba, baton);
 }
 
 static int _extract_mdas(struct lvmcache_info *info, struct dm_config_tree *cft,
@@ -722,7 +722,7 @@ static int _extract_mdas(struct lvmcache_info *info, struct dm_config_tree *cft,
 	if (!lvmcache_foreach_da(info, &_extract_da, &baton))
 		return 0;
 	baton.i = 0;
-	if (!lvmcache_foreach_ea(info, &_extract_ea, &baton))
+	if (!lvmcache_foreach_ba(info, &_extract_ba, &baton))
 		return 0;
 
 	return 1;
diff --git a/lib/format1/format1.c b/lib/format1/format1.c
index 115f8d1..7014a35 100644
--- a/lib/format1/format1.c
+++ b/lib/format1/format1.c
@@ -384,8 +384,8 @@ static int _format1_pv_setup(const struct format_type *fmt,
 	struct pvcreate_restorable_params rp = {.restorefile = NULL,
 						.id = {{0}},
 						.idp = NULL,
-						.ea_start = 0,
-						.ea_size = 0,
+						.ba_start = 0,
+						.ba_size = 0,
 						.pe_start = 0,
 						.extent_count = 0,
 						.extent_size = vg->extent_size};
@@ -430,7 +430,7 @@ static int _format1_pv_write(const struct format_type *fmt, struct physical_volu
 	lvmcache_update_pv(info, pv, fmt);
 	lvmcache_del_mdas(info);
 	lvmcache_del_das(info);
-	lvmcache_del_eas(info);
+	lvmcache_del_bas(info);
 
 	dm_list_init(&pvs);
 
diff --git a/lib/format_text/export.c b/lib/format_text/export.c
index 6d83106..73b5a3a 100644
--- a/lib/format_text/export.c
+++ b/lib/format_text/export.c
@@ -490,9 +490,9 @@ static int _print_pvs(struct formatter *f, struct volume_group *vg)
 		outsize(f, vg->extent_size * (uint64_t) pv->pe_count,
 			"pe_count = %u", pv->pe_count);
 
-		if (pv->ea_start && pv->ea_size) {
-			outf(f, "ea_start = %" PRIu64, pv->ea_start);
-			outsize(f, pv->ea_size, "ea_size = %" PRIu64, pv->ea_size);
+		if (pv->ba_start && pv->ba_size) {
+			outf(f, "ba_start = %" PRIu64, pv->ba_start);
+			outsize(f, pv->ba_size, "ba_size = %" PRIu64, pv->ba_size);
 		}
 
 		_dec_indent(f);
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 951ec76..1a16134 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1331,7 +1331,7 @@ static int _text_pv_write(const struct format_type *fmt, struct physical_volume
 				 mdac->area.start, mdac->area.size, mda_is_ignored(mda));
 	}
 
-	if (!lvmcache_update_eas(info, pv))
+	if (!lvmcache_update_bas(info, pv))
 		return_0;
 
 	/*
@@ -1510,15 +1510,15 @@ static int _text_pv_initialise(const struct format_type *fmt,
 		return 0;
 	}
 
-	if (pv->size < final_alignment + rp->ea_size) {
-		log_error("%s: Embedding area with data-aligned start must "
+	if (pv->size < final_alignment + rp->ba_size) {
+		log_error("%s: Bootloader area with data-aligned start must "
 			  "not exceed device size.", pv_dev_name(pv));
 		return 0;
 	}
 
 	if (rp->pe_start == PV_PE_START_CALC) {
 		/*
-		 * Calculate new PE start and embedding area start value.
+		 * Calculate new PE start and bootloader area start value.
 		 * Make sure both are properly aligned!
 		 * If PE start can't be aligned because EA is taking
 		 * the whole space, make PE start equal to the PV size
@@ -1526,14 +1526,14 @@ static int _text_pv_initialise(const struct format_type *fmt,
 		 * This needs to be done as we can't have a PV without any DA.
 		 * But we still want to support a PV with EA only!
 		 */
-		if (rp->ea_size) {
-			pv->ea_start = final_alignment;
-			pv->ea_size = rp->ea_size;
-			if ((adjustment = rp->ea_size % pv->pe_align))
-				pv->ea_size += pv->pe_align - adjustment;
-			if (pv->size < pv->ea_start + pv->ea_size)
-				pv->ea_size = pv->size - pv->ea_start;
-			pv->pe_start = pv->ea_start + pv->ea_size;
+		if (rp->ba_size) {
+			pv->ba_start = final_alignment;
+			pv->ba_size = rp->ba_size;
+			if ((adjustment = rp->ba_size % pv->pe_align))
+				pv->ba_size += pv->pe_align - adjustment;
+			if (pv->size < pv->ba_start + pv->ba_size)
+				pv->ba_size = pv->size - pv->ba_start;
+			pv->pe_start = pv->ba_start + pv->ba_size;
 		} else
 			pv->pe_start = final_alignment;
 	} else {
@@ -1548,16 +1548,16 @@ static int _text_pv_initialise(const struct format_type *fmt,
 		 *       in MDA then!
 		 */
 		pv->pe_start = rp->pe_start;
-		if (rp->ea_size) {
-			if ((rp->ea_start && rp->ea_start + rp->ea_size > rp->pe_start) ||
+		if (rp->ba_size) {
+			if ((rp->ba_start && rp->ba_start + rp->ba_size > rp->pe_start) ||
 			    (rp->pe_start <= final_alignment) ||
-			    (rp->pe_start - final_alignment < rp->ea_size)) {
-				log_error("%s: Embedding area would overlap "
+			    (rp->pe_start - final_alignment < rp->ba_size)) {
+				log_error("%s: Bootloader area would overlap "
 					  "data area.", pv_dev_name(pv));
 				return 0;
 			} else {
-				pv->ea_start = rp->ea_start ? : final_alignment;
-				pv->ea_size = rp->ea_size;
+				pv->ba_start = rp->ba_start ? : final_alignment;
+				pv->ba_size = rp->ba_size;
 			}
 		}
 	}
@@ -1985,7 +1985,7 @@ static int _text_pv_add_metadata_area(const struct format_type *fmt,
 {
 	struct format_instance *fid = pv->fid;
 	const char *pvid = (const char *) (*pv->old_id.uuid ? &pv->old_id : &pv->id);
-	uint64_t ea_size, pe_start, pe_end;
+	uint64_t ba_size, pe_start, pe_end;
 	uint64_t alignment, alignment_offset;
 	uint64_t disk_size;
 	uint64_t mda_start;
@@ -2006,7 +2006,7 @@ static int _text_pv_add_metadata_area(const struct format_type *fmt,
 	}
 
 	pe_start = pv->pe_start << SECTOR_SHIFT;
-	ea_size = pv->ea_size << SECTOR_SHIFT;
+	ba_size = pv->ba_size << SECTOR_SHIFT;
 	alignment = pv->pe_align << SECTOR_SHIFT;
 	alignment_offset = pv->pe_align_offset << SECTOR_SHIFT;
 	disk_size = pv->size << SECTOR_SHIFT;
@@ -2042,10 +2042,10 @@ static int _text_pv_add_metadata_area(const struct format_type *fmt,
 			limit_name = "disk size";
 		}
 
-		/* Adjust limits for embedding area if present. */
-		if (ea_size) {
-			limit -= ea_size;
-			limit_name = "ea_start";
+		/* Adjust limits for bootloader area if present. */
+		if (ba_size) {
+			limit -= ba_size;
+			limit_name = "ba_start";
 		}
 
 		if (limit > disk_size)
@@ -2107,9 +2107,9 @@ static int _text_pv_add_metadata_area(const struct format_type *fmt,
 		 * start of the area that follows the MDA0 we've just calculated.
 		 */
 		if (!pe_start_locked) {
-			if (ea_size) {
-				pv->ea_start = (mda_start + mda_size) >> SECTOR_SHIFT;
-				pv->pe_start = pv->ea_start + pv->ea_size;
+			if (ba_size) {
+				pv->ba_start = (mda_start + mda_size) >> SECTOR_SHIFT;
+				pv->pe_start = pv->ba_start + pv->ba_size;
 			} else
 				pv->pe_start = (mda_start + mda_size) >> SECTOR_SHIFT;
 		}
@@ -2140,10 +2140,10 @@ static int _text_pv_add_metadata_area(const struct format_type *fmt,
 				limit_name = "label scan size";
 			}
 
-			/* Adjust limits for embedding area if present. */
-			if (ea_size) {
-				limit += ea_size;
-				limit_name = "ea_end";
+			/* Adjust limits for bootloader area if present. */
+			if (ba_size) {
+				limit += ba_size;
+				limit_name = "ba_end";
 			}
 		}
 
@@ -2413,7 +2413,7 @@ struct format_type *create_text_format(struct cmd_context *cmd)
 	fmt->orphan_vg_name = ORPHAN_VG_NAME(FMT_TEXT_NAME);
 	fmt->features = FMT_SEGMENTS | FMT_MDAS | FMT_TAGS | FMT_PRECOMMIT |
 			FMT_UNLIMITED_VOLS | FMT_RESIZE_PV |
-			FMT_UNLIMITED_STRIPESIZE | FMT_EAS;
+			FMT_UNLIMITED_STRIPESIZE | FMT_BAS;
 
 	if (!(mda_lists = dm_malloc(sizeof(struct mda_lists)))) {
 		log_error("Failed to allocate dir_list");
diff --git a/lib/format_text/format-text.h b/lib/format_text/format-text.h
index 4706313..7d2543d 100644
--- a/lib/format_text/format-text.h
+++ b/lib/format_text/format-text.h
@@ -58,9 +58,9 @@ int pvhdr_read(struct device *dev, char *buf);
 int add_da(struct dm_pool *mem, struct dm_list *das,
 	   uint64_t start, uint64_t size);
 void del_das(struct dm_list *das);
-int add_ea(struct dm_pool *mem, struct dm_list *eas,
+int add_ba(struct dm_pool *mem, struct dm_list *eas,
 	   uint64_t start, uint64_t size);
-void del_eas(struct dm_list *eas);
+void del_bas(struct dm_list *eas);
 int add_mda(const struct format_type *fmt, struct dm_pool *mem, struct dm_list *mdas,
 	    struct device *dev, uint64_t start, uint64_t size, unsigned ignored);
 void del_mdas(struct dm_list *mdas);
diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index d5b5a73..852f2c5 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -165,7 +165,7 @@ static int _read_pv(struct format_instance *fid,
 	struct physical_volume *pv;
 	struct pv_list *pvl;
 	const struct dm_config_value *cv;
-	uint64_t size, ea_start;
+	uint64_t size, ba_start;
 
 	if (!(pvl = dm_pool_zalloc(mem, sizeof(*pvl))) ||
 	    !(pvl->pv = dm_pool_zalloc(mem, sizeof(*pvl->pv))))
@@ -246,19 +246,19 @@ static int _read_pv(struct format_instance *fid,
 		return 0;
 	}
 
-	/* Embedding area is not compulsory - just log_debug if not found. */
-	ea_start = size = 0;
-	if (!_read_uint64(pvn, "ea_start", &ea_start))
-		log_debug("PV Embedding Area start value (ea_start) not found.");
-	if (!_read_uint64(pvn, "ea_size", &size))
-		log_debug("PV Embedding Area size (ea_size) not found.");
-	if ((!ea_start && size) || (ea_start && !size)) {
-		log_error("Incomplete embedding area specification for "
+	/* Bootloader area is not compulsory - just log_debug if not found. */
+	ba_start = size = 0;
+	if (!_read_uint64(pvn, "ba_start", &ba_start))
+		log_debug("PV Bootloader Area start value (ba_start) not found.");
+	if (!_read_uint64(pvn, "ba_size", &size))
+		log_debug("PV Bootloader Area size (ba_size) not found.");
+	if ((!ba_start && size) || (ba_start && !size)) {
+		log_error("Incomplete bootloader area specification for "
 			  "physical volume.");
 		return 0;
 	} else {
-		pv->ea_start = ea_start;
-		pv->ea_size = size;
+		pv->ba_start = ba_start;
+		pv->ba_size = size;
 	}
 
 	dm_list_init(&pv->tags);
diff --git a/lib/format_text/layout.h b/lib/format_text/layout.h
index 14f9930..6fb3e49 100644
--- a/lib/format_text/layout.h
+++ b/lib/format_text/layout.h
@@ -28,8 +28,8 @@
 struct pv_header_extension {
 	uint32_t version;
 	uint32_t flags;
-	/* NULL-terminated list of embedding areas */
-	struct disk_locn embedding_areas_xl[0];
+	/* NULL-terminated list of bootloader areas */
+	struct disk_locn bootloader_areas_xl[0];
 } __attribute__ ((packed));
 
 /* Fields with the suffix _xl should be xlate'd wherever they appear */
diff --git a/lib/format_text/text_label.c b/lib/format_text/text_label.c
index 32f3347..3408590 100644
--- a/lib/format_text/text_label.c
+++ b/lib/format_text/text_label.c
@@ -49,9 +49,9 @@ static int _da_setup(struct disk_locn *da, void *baton)
 	return 1;
 }
 
-static int _ea_setup(struct disk_locn *ea, void *baton)
+static int _ba_setup(struct disk_locn *ba, void *baton)
 {
-	return _da_setup(ea, baton);
+	return _da_setup(ba, baton);
 }
 
 static int _mda_setup(struct metadata_area *mda, void *baton)
@@ -88,7 +88,7 @@ static int _text_write(struct label *label, void *buf)
 	struct lvmcache_info *info;
 	struct _dl_setup_baton baton;
 	char buffer[64] __attribute__((aligned(8)));
-	int ea1, da1, mda1, mda2;
+	int ba1, da1, mda1, mda2;
 
 	/*
 	 * PV header base
@@ -126,14 +126,14 @@ static int _text_write(struct label *label, void *buf)
 	pvhdr_ext->version = xlate32(PV_HEADER_EXTENSION_VSN);
 	pvhdr_ext->flags = 0; /* no flags yet */
 
-	/* List of embedding area locations */
-	baton.pvh_dlocn_xl = &pvhdr_ext->embedding_areas_xl[0];
-	lvmcache_foreach_ea(info, _ea_setup, &baton);
+	/* List of bootloader area locations */
+	baton.pvh_dlocn_xl = &pvhdr_ext->bootloader_areas_xl[0];
+	lvmcache_foreach_ba(info, _ba_setup, &baton);
 	_dl_null_termination(&baton);
 
-	/* Create debug message with ea, da and mda locations */
-	ea1 = (xlate64(pvhdr_ext->embedding_areas_xl[0].offset) ||
-	       xlate64(pvhdr_ext->embedding_areas_xl[0].size)) ? 0 : -1;
+	/* Create debug message with ba, da and mda locations */
+	ba1 = (xlate64(pvhdr_ext->bootloader_areas_xl[0].offset) ||
+	       xlate64(pvhdr_ext->bootloader_areas_xl[0].size)) ? 0 : -1;
 
 	da1 = (xlate64(pvhdr->disk_areas_xl[0].offset) ||
 	       xlate64(pvhdr->disk_areas_xl[0].size)) ? 0 : -1;
@@ -154,13 +154,13 @@ static int _text_write(struct label *label, void *buf)
 			   "%s%.*" PRIu64 "%s%.*" PRIu64 "%s"
 			   "%s%.*" PRIu64 "%s%.*" PRIu64 "%s",
 			   dev_name(lvmcache_device(info)), buffer, lvmcache_device_size(info),
-			   (ea1 > -1) ? " ea1 (" : "",
-			   (ea1 > -1) ? 1 : 0,
-			   (ea1 > -1) ? xlate64(pvhdr_ext->embedding_areas_xl[ea1].offset) >> SECTOR_SHIFT : 0,
-			   (ea1 > -1) ? "s, " : "",
-			   (ea1 > -1) ? 1 : 0,
-			   (ea1 > -1) ? xlate64(pvhdr_ext->embedding_areas_xl[ea1].size) >> SECTOR_SHIFT : 0,
-			   (ea1 > -1) ? "s)" : "",
+			   (ba1 > -1) ? " ba1 (" : "",
+			   (ba1 > -1) ? 1 : 0,
+			   (ba1 > -1) ? xlate64(pvhdr_ext->bootloader_areas_xl[ba1].offset) >> SECTOR_SHIFT : 0,
+			   (ba1 > -1) ? "s, " : "",
+			   (ba1 > -1) ? 1 : 0,
+			   (ba1 > -1) ? xlate64(pvhdr_ext->bootloader_areas_xl[ba1].size) >> SECTOR_SHIFT : 0,
+			   (ba1 > -1) ? "s)" : "",
 			   (da1 > -1) ? " da1 (" : "",
 			   (da1 > -1) ? 1 : 0,
 			   (da1 > -1) ? xlate64(pvhdr->disk_areas_xl[da1].offset) >> SECTOR_SHIFT : 0,
@@ -229,15 +229,15 @@ void del_das(struct dm_list *das)
 	}
 }
 
-int add_ea(struct dm_pool *mem, struct dm_list *eas,
+int add_ba(struct dm_pool *mem, struct dm_list *eas,
 	   uint64_t start, uint64_t size)
 {
 	return add_da(mem, eas, start, size);
 }
 
-void del_eas(struct dm_list *eas)
+void del_bas(struct dm_list *bas)
 {
-	del_das(eas);
+	del_das(bas);
 }
 
 /* FIXME: refactor this function with other mda constructor code */
@@ -392,7 +392,7 @@ static int _text_read(struct labeller *l, struct device *dev, void *buf,
 
 	lvmcache_del_das(info);
 	lvmcache_del_mdas(info);
-	lvmcache_del_eas(info);
+	lvmcache_del_bas(info);
 
 	/* Data areas holding the PEs */
 	dlocn_xl = pvhdr->disk_areas_xl;
@@ -420,10 +420,10 @@ static int _text_read(struct labeller *l, struct device *dev, void *buf,
 	log_debug("%s: PV header extension version %" PRIu32 " found",
 		  dev_name(dev), ext_version);
 
-	/* Embedding areas */
-	dlocn_xl = pvhdr_ext->embedding_areas_xl;
+	/* Bootloader areas */
+	dlocn_xl = pvhdr_ext->bootloader_areas_xl;
 	while ((offset = xlate64(dlocn_xl->offset))) {
-		lvmcache_add_ea(info, offset, xlate64(dlocn_xl->size));
+		lvmcache_add_ba(info, offset, xlate64(dlocn_xl->size));
 		dlocn_xl++;
 	}
 out:
@@ -443,7 +443,7 @@ static void _text_destroy_label(struct labeller *l __attribute__((unused)),
 
 	lvmcache_del_mdas(info);
 	lvmcache_del_das(info);
-	lvmcache_del_eas(info);
+	lvmcache_del_bas(info);
 }
 
 static void _fmt_text_destroy(struct labeller *l)
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index cd82368..f698b33 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -109,7 +109,7 @@
 #define FMT_RESIZE_PV		0x00000080U	/* Supports pvresize? */
 #define FMT_UNLIMITED_STRIPESIZE 0x00000100U	/* Unlimited stripe size? */
 #define FMT_RESTRICTED_READAHEAD 0x00000200U	/* Readahead restricted to 2-120? */
-#define FMT_EAS			0x000000400U	/* Supports embedding areas? */
+#define FMT_BAS			0x000000400U	/* Supports bootloader areas? */
 
 /* Mirror conversion type flags */
 #define MIRROR_BY_SEG		0x00000001U	/* segment-by-segment mirror */
@@ -401,8 +401,8 @@ struct pvcreate_restorable_params {
 	const char *restorefile; /* 0 if no --restorefile option */
 	struct id id; /* FIXME: redundant */
 	struct id *idp; /* 0 if no --uuid option */
-	uint64_t ea_start;
-	uint64_t ea_size;
+	uint64_t ba_start;
+	uint64_t ba_size;
 	uint64_t pe_start;
 	uint32_t extent_count;
 	uint32_t extent_size;
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 78841c3..351d157 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1414,8 +1414,8 @@ void pvcreate_params_set_defaults(struct pvcreate_params *pp)
 	pp->metadataignore = DEFAULT_PVMETADATAIGNORE;
 	pp->rp.restorefile = 0;
 	pp->rp.idp = 0;
-	pp->rp.ea_start = 0;
-	pp->rp.ea_size = 0;
+	pp->rp.ba_start = 0;
+	pp->rp.ba_size = 0;
 	pp->rp.pe_start = PV_PE_START_CALC;
 	pp->rp.extent_count = 0;
 	pp->rp.extent_size = 0;
diff --git a/lib/metadata/pv.c b/lib/metadata/pv.c
index 6c165a8..dad747c 100644
--- a/lib/metadata/pv.c
+++ b/lib/metadata/pv.c
@@ -124,14 +124,14 @@ uint32_t pv_pe_size(const struct physical_volume *pv)
 	return pv_field(pv, pe_size);
 }
 
-uint64_t pv_ea_start(const struct physical_volume *pv)
+uint64_t pv_ba_start(const struct physical_volume *pv)
 {
-	return pv_field(pv, ea_start);
+	return pv_field(pv, ba_start);
 }
 
-uint64_t pv_ea_size(const struct physical_volume *pv)
+uint64_t pv_ba_size(const struct physical_volume *pv)
 {
-	return pv_field(pv, ea_size);
+	return pv_field(pv, ba_size);
 }
 
 uint64_t pv_pe_start(const struct physical_volume *pv)
diff --git a/lib/metadata/pv.h b/lib/metadata/pv.h
index 6db9d87..c018f38 100644
--- a/lib/metadata/pv.h
+++ b/lib/metadata/pv.h
@@ -43,9 +43,9 @@ struct physical_volume {
 	uint64_t status;
 	uint64_t size;
 
-	/* embedding area */
-	uint64_t ea_start;
-	uint64_t ea_size;
+	/* bootloader area */
+	uint64_t ba_start;
+	uint64_t ba_size;
 
 	/* physical extents */
 	uint32_t pe_size;
@@ -80,8 +80,8 @@ uint64_t pv_free(const struct physical_volume *pv);
 uint64_t pv_status(const struct physical_volume *pv);
 uint32_t pv_pe_size(const struct physical_volume *pv);
 uint64_t pv_pe_start(const struct physical_volume *pv);
-uint64_t pv_ea_start(const struct physical_volume *pv);
-uint64_t pv_ea_size(const struct physical_volume *pv);
+uint64_t pv_ba_start(const struct physical_volume *pv);
+uint64_t pv_ba_size(const struct physical_volume *pv);
 uint32_t pv_pe_count(const struct physical_volume *pv);
 uint32_t pv_pe_alloc_count(const struct physical_volume *pv);
 uint64_t pv_mda_size(const struct physical_volume *pv);
diff --git a/lib/report/columns.h b/lib/report/columns.h
index 201b3c4..6754e6e 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -112,8 +112,8 @@ FIELD(PVS, pv, NUM, "Alloc", pe_alloc_count, 5, uint32, pv_pe_alloc_count, "Tota
 FIELD(PVS, pv, STR, "PV Tags", tags, 7, tags, pv_tags, "Tags, if any.", 0)
 FIELD(PVS, pv, NUM, "#PMda", id, 5, pvmdas, pv_mda_count, "Number of metadata areas on this device.", 0)
 FIELD(PVS, pv, NUM, "#PMdaUse", id, 8, pvmdasused, pv_mda_used_count, "Number of metadata areas in use on this device.", 0)
-FIELD(PVS, pv, NUM, "EA start", ea_start, 8, size64, ea_start, "Offset to the start of Embedding Area on the underlying device.", 0)
-FIELD(PVS, pv, NUM, "EA size", ea_size, 7, size64, ea_size, "Size of Embedding Area in current units.", 0)
+FIELD(PVS, pv, NUM, "BA start", ba_start, 8, size64, ba_start, "Offset to the start of PV Bootloader Area on the underlying device.", 0)
+FIELD(PVS, pv, NUM, "BA size", ba_size, 7, size64, ba_size, "Size of PV Bootloader Area in current units.", 0)
 
 FIELD(VGS, vg, STR, "Fmt", cmd, 3, vgfmt, vg_fmt, "Type of metadata.", 0)
 FIELD(VGS, vg, STR, "VG UUID", id, 38, uuid, vg_uuid, "Unique identifier.", 0)
diff --git a/lib/report/properties.c b/lib/report/properties.c
index 03ebc6f..3073d2a 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -175,10 +175,10 @@ GET_PV_NUM_PROPERTY_FN(pv_mda_count, pv_mda_count(pv))
 #define _pv_mda_count_set _not_implemented_set
 GET_PV_NUM_PROPERTY_FN(pv_mda_used_count, pv_mda_used_count(pv))
 #define _pv_mda_used_count_set _not_implemented_set
-GET_PV_NUM_PROPERTY_FN(ea_start, SECTOR_SIZE * pv->ea_start)
-#define _ea_start_set _not_implemented_set
-GET_PV_NUM_PROPERTY_FN(ea_size, SECTOR_SIZE * pv->ea_size)
-#define _ea_size_set _not_implemented_set
+GET_PV_NUM_PROPERTY_FN(ba_start, SECTOR_SIZE * pv->ba_start)
+#define _ba_start_set _not_implemented_set
+GET_PV_NUM_PROPERTY_FN(ba_size, SECTOR_SIZE * pv->ba_size)
+#define _ba_size_set _not_implemented_set
 
 /* LV */
 GET_LV_STR_PROPERTY_FN(lv_uuid, lv_uuid_dup(lv))
diff --git a/man/pvcreate.8.in b/man/pvcreate.8.in
index 1fda0ad..c3a652c 100644
--- a/man/pvcreate.8.in
+++ b/man/pvcreate.8.in
@@ -12,7 +12,7 @@ pvcreate \- initialize a disk or partition for use by LVM
 .RB [ \-\-force ]]
 .RB [ \-y | \-\-yes ]
 .RB [ \-\-labelsector ]
-.RB [ \-\-embeddingareasize
+.RB [ \-\-bootloaderareasize
 .IR size ]
 .RB [ \-M | \-\-metadatatype
 .IR type ]
@@ -165,15 +165,15 @@ sector (sector 1).  This lets you use a different sector near the
 start of the disk (between 0 and 3 inclusive - see LABEL_SCAN_SECTORS
 in the source).  Use with care.
 .TP
-.B \-\-embeddingareasize \fIsize
-Create a separate embedding area of specified size besides PV's data
-area. The embedding area is an area of reserved space on the PV from
-which LVM2 will not allocate any extents and it's kept untouched for
-use with external tools to embed their own data or metadata. The start
-of the embedding area is always aligned, see also \fB--dataalignment\fP
-and \fB--dataalignmentoffset\fP. The embedding area size may eventually
+.B \-\-bootloaderareasize \fIsize
+Create a separate bootloader area of specified size besides PV's data
+area. The bootloader area is an area of reserved space on the PV from
+which LVM2 will not allocate any extents and it's kept untouched. This is
+primarily aimed for use with bootloaders to embed their own data or metadata.
+The start of the bootloader area is always aligned, see also \fB--dataalignment\fP
+and \fB--dataalignmentoffset\fP. The bootloader area size may eventually
 end up increased due to the alignment, but it's never less than the
-size that is requested. To see the embedding area start and size of
+size that is requested. To see the bootloader area start and size of
 an existing Physical Volume use \fBpvs -o +ea_start,ea_size\fP.
 .TP
 .B \-\-setphysicalvolumesize \fIsize
diff --git a/man/vgconvert.8.in b/man/vgconvert.8.in
index 6567a9e..1e182b6 100644
--- a/man/vgconvert.8.in
+++ b/man/vgconvert.8.in
@@ -8,7 +8,7 @@ vgconvert \- convert volume group metadata format
 .RB [ \-t | \-\-test ]
 .RB [ \-v | \-\-verbose ]
 .RB [ \-\-labelsector ]
-.RB [ \-\-embeddingareasize
+.RB [ \-\-bootloaderareasize
 .IR size ]
 .RB [ \-M | \-\-metadatatype
 .IR type ]
diff --git a/tools/args.h b/tools/args.h
index bfcc5b9..cdc4b3b 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -26,7 +26,7 @@ arg(vgmetadatacopies_ARG, '\0', "vgmetadatacopies", metadatacopies_arg, 0)
 arg(metadatacopies_ARG, '\0', "metadatacopies", metadatacopies_arg, 0)
 arg(metadatasize_ARG, '\0', "metadatasize", size_mb_arg, 0)
 arg(metadataignore_ARG, '\0', "metadataignore", yes_no_arg, 0)
-arg(embeddingareasize_ARG, '\0', "embeddingareasize", size_mb_arg, 0)
+arg(bootloaderareasize_ARG, '\0', "bootloaderareasize", size_mb_arg, 0)
 arg(norestorefile_ARG, '\0', "norestorefile", NULL, 0)
 arg(restorefile_ARG, '\0', "restorefile", string_arg, 0)
 arg(labelsector_ARG, '\0', "labelsector", int_arg, 0)
diff --git a/tools/commands.h b/tools/commands.h
index 8950243..24f6512 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -552,7 +552,7 @@ xx(pvcreate,
    "\t[-M|--metadatatype 1|2]" "\n"
    "\t[--pvmetadatacopies #copies]" "\n"
    "\t[--metadatasize MetadataSize[bBsSkKmMgGtTpPeE]]" "\n"
-   "\t[--embeddingareasize EmbeddingAreaSize[bBsSkKmMgGtTpPeE]]" "\n"
+   "\t[--bootloaderareasize BootLoaderAreaSize[bBsSkKmMgGtTpPeE]]" "\n"
    "\t[--dataalignment Alignment[bBsSkKmMgGtTpPeE]]" "\n"
    "\t[--dataalignmentoffset AlignmentOffset[bBsSkKmMgGtTpPeE]]" "\n"
    "\t[--setphysicalvolumesize PhysicalVolumeSize[bBsSkKmMgGtTpPeE]" "\n"
@@ -564,7 +564,7 @@ xx(pvcreate,
    "\t[--version] " "\n"
    "\tPhysicalVolume [PhysicalVolume...]\n",
 
-   dataalignment_ARG, dataalignmentoffset_ARG, embeddingareasize_ARG,
+   dataalignment_ARG, dataalignmentoffset_ARG, bootloaderareasize_ARG,
    force_ARG, test_ARG, labelsector_ARG, metadatatype_ARG,
    metadatacopies_ARG, metadatasize_ARG, metadataignore_ARG,
    norestorefile_ARG, physicalvolumesize_ARG, pvmetadatacopies_ARG,
@@ -810,13 +810,13 @@ xx(vgconvert,
    "\t[-M|--metadatatype 1|2]" "\n"
    "\t[--pvmetadatacopies #copies]" "\n"
    "\t[--metadatasize MetadataSize[bBsSkKmMgGtTpPeE]]" "\n"
-   "\t[--embeddingareasize EmbeddingAreaSize[bBsSkKmMgGtTpPeE]]" "\n"
+   "\t[--bootloaderareasize BootLoaderAreaSize[bBsSkKmMgGtTpPeE]]" "\n"
    "\t[-t|--test] " "\n"
    "\t[-v|--verbose] " "\n"
    "\t[--version] " "\n"
    "\tVolumeGroupName [VolumeGroupName...]\n",
 
-   force_ARG, test_ARG, labelsector_ARG, embeddingareasize_ARG,
+   force_ARG, test_ARG, labelsector_ARG, bootloaderareasize_ARG,
    metadatatype_ARG, metadatacopies_ARG, pvmetadatacopies_ARG,
    metadatasize_ARG )
 
diff --git a/tools/pvcreate.c b/tools/pvcreate.c
index da51eec..91562d2 100644
--- a/tools/pvcreate.c
+++ b/tools/pvcreate.c
@@ -71,8 +71,8 @@ static int pvcreate_restore_params_validate(struct cmd_context *cmd,
 				  uuid, pp->rp.restorefile);
 			return 0;
 		}
-		pp->rp.ea_start = pv_ea_start(existing_pvl->pv);
-		pp->rp.ea_size = pv_ea_size(existing_pvl->pv);
+		pp->rp.ba_start = pv_ba_start(existing_pvl->pv);
+		pp->rp.ba_size = pv_ba_size(existing_pvl->pv);
 		pp->rp.pe_start = pv_pe_start(existing_pvl->pv);
 		pp->rp.extent_size = pv_pe_size(existing_pvl->pv);
 		pp->rp.extent_count = pv_pe_count(existing_pvl->pv);
diff --git a/tools/toollib.c b/tools/toollib.c
index e9be968..6e004f3 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1427,9 +1427,9 @@ int pvcreate_params_validate(struct cmd_context *cmd,
 		return 0;
 	}
 
-	if (!(cmd->fmt->features & FMT_EAS) &&
-	    arg_count(cmd, embeddingareasize_ARG)) {
-		log_error("Embedding area parameters only "
+	if (!(cmd->fmt->features & FMT_BAS) &&
+	    arg_count(cmd, bootloaderareasize_ARG)) {
+		log_error("Bootloader area parameters only "
 			  "apply to text format.");
 		return 0;
 	}
@@ -1498,8 +1498,8 @@ int pvcreate_params_validate(struct cmd_context *cmd,
 		return 0;
 	}
 
-	if (arg_sign_value(cmd, embeddingareasize_ARG, SIGN_NONE) == SIGN_MINUS) {
-		log_error("Embedding area size may not be negative");
+	if (arg_sign_value(cmd, bootloaderareasize_ARG, SIGN_NONE) == SIGN_MINUS) {
+		log_error("Bootloader area size may not be negative");
 		return 0;
 	}
 
@@ -1511,7 +1511,7 @@ int pvcreate_params_validate(struct cmd_context *cmd,
 	if (pp->pvmetadatacopies < 0)
 		pp->pvmetadatacopies = find_config_tree_int(cmd, metadata_pvmetadatacopies_CFG);
 
-	pp->rp.ea_size = arg_uint64_value(cmd, embeddingareasize_ARG, pp->rp.ea_size);
+	pp->rp.ba_size = arg_uint64_value(cmd, bootloaderareasize_ARG, pp->rp.ba_size);
 
 	return 1;
 }
diff --git a/tools/vgconvert.c b/tools/vgconvert.c
index cdadd9a..b06fe34 100644
--- a/tools/vgconvert.c
+++ b/tools/vgconvert.c
@@ -59,13 +59,13 @@ static int vgconvert_single(struct cmd_context *cmd, const char *vg_name,
 			    find_config_tree_int(cmd, metadata_pvmetadatacopies_CFG);
 	}
 
-	if (cmd->fmt->features & FMT_EAS) {
-		if (arg_sign_value(cmd, embeddingareasize_ARG, SIGN_NONE) == SIGN_MINUS) {
-			log_error("Embedding area size may not be negative");
+	if (cmd->fmt->features & FMT_BAS) {
+		if (arg_sign_value(cmd, bootloaderareasize_ARG, SIGN_NONE) == SIGN_MINUS) {
+			log_error("Bootloader area size may not be negative");
 			return EINVALID_CMD_LINE;
 		}
 
-		rp.ea_size = arg_uint64_value(cmd, embeddingareasize_ARG, UINT64_C(0));
+		rp.ba_size = arg_uint64_value(cmd, bootloaderareasize_ARG, UINT64_C(0));
 	}
 
 	if (!archive(vg)) {
@@ -232,9 +232,9 @@ int vgconvert(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
-	if (!(cmd->fmt->features & FMT_EAS) &&
-		arg_count(cmd, embeddingareasize_ARG)) {
-		log_error("Embedding area parameters only apply to text format");
+	if (!(cmd->fmt->features & FMT_BAS) &&
+		arg_count(cmd, bootloaderareasize_ARG)) {
+		log_error("Bootloader area parameters only apply to text format");
 		return EINVALID_CMD_LINE;
 	}
 


