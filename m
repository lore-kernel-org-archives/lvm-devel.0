From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed,  5 Jun 2013 12:05:53 +0000 (UTC)
Subject: dev-mornfall-lvmcache - lvmcache: Move DA/MDA/EA lists out of lvmcache_info, into label.
Message-ID: <20130605120553.2C2AE60F90@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=57795df3652211a0eb05ad924837006327dde02c
Commit:        57795df3652211a0eb05ad924837006327dde02c
Parent:        0f49180ea7eb6d0464a9a85d58a56b4c7f9273b6
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Sun Feb 3 22:59:28 2013 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Jun 5 12:37:34 2013 +0200

lvmcache: Move DA/MDA/EA lists out of lvmcache_info, into label.

---
 lib/cache/lvmcache.c |   95 ++++++++++++++++++++++++-------------------------
 lib/label/label.h    |    3 ++
 2 files changed, 50 insertions(+), 48 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 6f935db..b457470 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -36,14 +36,11 @@
 /* One per device */
 struct lvmcache_info {
 	struct dm_list list;	/* Join VG members together */
-	struct dm_list mdas;	/* list head for metadata areas */
-	struct dm_list das;	/* list head for data areas */
-	struct dm_list bas;	/* list head for bootloader areas */
 	struct lvmcache_vginfo *vginfo;	/* NULL == unknown */
-	struct label *label;
+	struct label *label; /* move to PV */
 	const struct format_type *fmt;
-	struct device *dev;
-	uint64_t device_size;	/* Bytes */
+	struct device *dev; /* dup'd from PV */
+	uint64_t device_size;	/* move to label */ /* Bytes */
 	uint32_t status;
 };
 
@@ -1285,9 +1282,9 @@ static int _lvmcache_update_vgname(struct lvmcache_info *info,
 			dm_list_iterate_items_safe(info2, info3, &primary_vginfo->infos) {
 				_vginfo_detach_info(info2);
 				_vginfo_attach_info(orphan_vginfo, info2);
-				if (info2->mdas.n)
+				if (info2->label->mdas.n)
 					sprintf(mdabuf, " with %u mdas",
-						dm_list_size(&info2->mdas));
+						dm_list_size(&info2->label->mdas));
 				else
 					mdabuf[0] = '\0';
 				log_debug_cache("lvmcache: %s: now in VG %s%s%s%s%s",
@@ -1328,8 +1325,8 @@ static int _lvmcache_update_vgname(struct lvmcache_info *info,
 	vginfo->fmt = fmt;
 
 	if (info) {
-		if (info->mdas.n)
-			sprintf(mdabuf, " with %u mdas", dm_list_size(&info->mdas));
+		if (info->label->mdas.n)
+			sprintf(mdabuf, " with %u mdas", dm_list_size(&info->label->mdas));
 		else
 			mdabuf[0] = '\0';
 		log_debug_cache("lvmcache: %s: now in VG %s%s%s%s%s",
@@ -1405,7 +1402,7 @@ int lvmcache_update_vgname_and_id(struct lvmcache_info *info,
 
 	/* If PV without mdas is already in a real VG, don't make it orphan */
 	if (is_orphan_vg(vgname) && info->vginfo &&
-	    mdas_empty_or_ignored(&info->mdas) &&
+	    mdas_empty_or_ignored(&info->label->mdas) &&
 	    !is_orphan_vg(info->vginfo->vgname) && critical_section())
 		return 1;
 
@@ -1536,6 +1533,8 @@ struct lvmcache_info *lvmcache_add(struct labeller *labeller, const char *pvid,
 				/* FIXME leaves info without label! */
 				return_NULL;
 			info->label->info = info;
+			lvmcache_del_mdas(info);
+			lvmcache_del_das(info);
 		}
 		label = info->label;
 	}
@@ -1652,7 +1651,7 @@ int lvmcache_pvid_is_locked(const char *pvid) {
 int lvmcache_fid_add_mdas(struct lvmcache_info *info, struct format_instance *fid,
 			  const char *id, int id_len)
 {
-	return fid_add_mdas(fid, &info->mdas, id, id_len);
+	return fid_add_mdas(fid, &info->label->mdas, id, id_len);
 }
 
 int lvmcache_fid_add_mdas_pv(struct lvmcache_info *info, struct format_instance *fid)
@@ -1720,23 +1719,23 @@ int lvmcache_populate_pv_fields(struct lvmcache_info *info,
 	memcpy(&pv->id, &info->dev->pvid, sizeof(pv->id));
 
 	/* Currently only support exactly one data area */
-	if (dm_list_size(&info->das) != 1) {
+	if (dm_list_size(&info->label->das) != 1) {
 		log_error("Must be exactly one data area (found %d) on PV %s",
-			  dm_list_size(&info->das), dev_name(info->dev));
+			  dm_list_size(&info->label->das), dev_name(info->dev));
 		return 0;
 	}
 
-	/* Currently only support one bootloader area at most */
-	if (dm_list_size(&info->bas) > 1) {
-		log_error("Must be at most one bootloader area (found %d) on PV %s",
-			  dm_list_size(&info->bas), dev_name(info->dev));
+	/* Currently only support one embedding area at most */
+	if (dm_list_size(&info->label->bas) > 1) {
+		log_error("Must be at most one embedding area (found %d) on PV %s",
+			  dm_list_size(&info->label->bas), dev_name(info->dev));
 		return 0;
 	}
 
-	dm_list_iterate_items(da, &info->das)
+	dm_list_iterate_items(da, &info->label->das)
 		pv->pe_start = da->disk_locn.offset >> SECTOR_SHIFT;
 
-	dm_list_iterate_items(da, &info->bas) {
+	dm_list_iterate_items(da, &info->label->bas) {
 		pv->ba_start = da->disk_locn.offset >> SECTOR_SHIFT;
 		pv->ba_size = da->disk_locn.size >> SECTOR_SHIFT;
 	}
@@ -1756,39 +1755,39 @@ int lvmcache_check_format(struct lvmcache_info *info, const struct format_type *
 
 void lvmcache_del_mdas(struct lvmcache_info *info)
 {
-	if (info->mdas.n)
-		del_mdas(&info->mdas);
-	dm_list_init(&info->mdas);
+	if (info->label->mdas.n)
+		del_mdas(&info->label->mdas);
+	dm_list_init(&info->label->mdas);
 }
 
 void lvmcache_del_das(struct lvmcache_info *info)
 {
-	if (info->das.n)
-		del_das(&info->das);
-	dm_list_init(&info->das);
+	if (info->label->das.n)
+		del_das(&info->label->das);
+	dm_list_init(&info->label->das);
 }
 
 void lvmcache_del_bas(struct lvmcache_info *info)
 {
-	if (info->bas.n)
-		del_bas(&info->bas);
-	dm_list_init(&info->bas);
+	if (info->label->bas.n)
+		del_bas(&info->label->bas);
+	dm_list_init(&info->label->bas);
 }
 
 int lvmcache_add_mda(struct lvmcache_info *info, struct device *dev,
 		     uint64_t start, uint64_t size, unsigned ignored)
 {
-	return add_mda(info->fmt, NULL, &info->mdas, dev, start, size, ignored);
+	return add_mda(info->fmt, NULL, &info->label->mdas, dev, start, size, ignored);
 }
 
 int lvmcache_add_da(struct lvmcache_info *info, uint64_t start, uint64_t size)
 {
-	return add_da(NULL, &info->das, start, size);
+	return add_da(NULL, &info->label->das, start, size);
 }
 
 int lvmcache_add_ba(struct lvmcache_info *info, uint64_t start, uint64_t size)
 {
-	return add_ba(NULL, &info->bas, start, size);
+	return add_ba(NULL, &info->label->bas, start, size);
 }
 
 void lvmcache_update_pv(struct lvmcache_info *info, struct physical_volume *pv,
@@ -1801,15 +1800,15 @@ void lvmcache_update_pv(struct lvmcache_info *info, struct physical_volume *pv,
 int lvmcache_update_das(struct lvmcache_info *info, struct physical_volume *pv)
 {
 	struct data_area_list *da;
-	if (info->das.n) {
+	if (info->label->das.n) {
 		if (!pv->pe_start)
-			dm_list_iterate_items(da, &info->das)
+			dm_list_iterate_items(da, &info->label->das)
 				pv->pe_start = da->disk_locn.offset >> SECTOR_SHIFT;
-		del_das(&info->das);
+		del_das(&info->label->das);
 	} else
-		dm_list_init(&info->das);
+		dm_list_init(&info->label->das);
 
-	if (!add_da(NULL, &info->das, pv->pe_start << SECTOR_SHIFT, 0 /*pv->size << SECTOR_SHIFT*/))
+	if (!add_da(NULL, &info->label->das, pv->pe_start << SECTOR_SHIFT, 0 /*pv->size << SECTOR_SHIFT*/))
 		return_0;
 
 	return 1;
@@ -1818,17 +1817,17 @@ int lvmcache_update_das(struct lvmcache_info *info, struct physical_volume *pv)
 int lvmcache_update_bas(struct lvmcache_info *info, struct physical_volume *pv)
 {
 	struct data_area_list *ba;
-	if (info->bas.n) {
+	if (info->label->bas.n) {
 		if (!pv->ba_start && !pv->ba_size)
-			dm_list_iterate_items(ba, &info->bas) {
+			dm_list_iterate_items(ba, &info->label->bas) {
 				pv->ba_start = ba->disk_locn.offset >> SECTOR_SHIFT;
 				pv->ba_size = ba->disk_locn.size >> SECTOR_SHIFT;
 			}
-		del_das(&info->bas);
+		del_das(&info->label->bas);
 	} else
-		dm_list_init(&info->bas);
+		dm_list_init(&info->label->bas);
 
-	if (!add_ba(NULL, &info->bas, pv->ba_start << SECTOR_SHIFT, pv->ba_size << SECTOR_SHIFT))
+	if (!add_ba(NULL, &info->label->bas, pv->ba_start << SECTOR_SHIFT, pv->ba_size << SECTOR_SHIFT))
 		return_0;
 
 	return 1;
@@ -1852,7 +1851,7 @@ int lvmcache_foreach_mda(struct lvmcache_info *info,
 			 void *baton)
 {
 	struct metadata_area *mda;
-	dm_list_iterate_items(mda, &info->mdas) {
+	dm_list_iterate_items(mda, &info->label->mdas) {
 		if (!fun(mda, baton))
 			return_0;
 	}
@@ -1862,7 +1861,7 @@ int lvmcache_foreach_mda(struct lvmcache_info *info,
 
 unsigned lvmcache_mda_count(struct lvmcache_info *info)
 {
-	return dm_list_size(&info->mdas);
+	return dm_list_size(&info->label->mdas);
 }
 
 int lvmcache_foreach_da(struct lvmcache_info *info,
@@ -1870,7 +1869,7 @@ int lvmcache_foreach_da(struct lvmcache_info *info,
 			void *baton)
 {
 	struct data_area_list *da;
-	dm_list_iterate_items(da, &info->das) {
+	dm_list_iterate_items(da, &info->label->das) {
 		if (!fun(&da->disk_locn, baton))
 			return_0;
 	}
@@ -1883,7 +1882,7 @@ int lvmcache_foreach_ba(struct lvmcache_info *info,
 			 void *baton)
 {
 	struct data_area_list *ba;
-	dm_list_iterate_items(ba, &info->bas) {
+	dm_list_iterate_items(ba, &info->label->bas) {
 		if (!fun(&ba->disk_locn, baton))
 			return_0;
 	}
@@ -1943,12 +1942,12 @@ int lvmcache_vgid_is_cached(const char *vgid) {
  * PV in question is or is not an orphan.
  */
 int lvmcache_uncertain_ownership(struct lvmcache_info *info) {
-	return mdas_empty_or_ignored(&info->mdas);
+	return mdas_empty_or_ignored(&info->label->mdas);
 }
 
 uint64_t lvmcache_smallest_mda_size(struct lvmcache_info *info)
 {
-	return find_min_mda_size(&info->mdas);
+	return find_min_mda_size(&info->label->mdas);
 }
 
 const struct format_type *lvmcache_fmt(struct lvmcache_info *info) {
diff --git a/lib/label/label.h b/lib/label/label.h
index f3268bb..60dd176 100644
--- a/lib/label/label.h
+++ b/lib/label/label.h
@@ -43,6 +43,9 @@ struct label {
 	uint64_t sector;
 	struct labeller *labeller;
 	void *info;
+	struct dm_list mdas;	/* list head for metadata areas */
+	struct dm_list das;	/* list head for data areas */
+	struct dm_list bas;	/* list head for embedding areas */
 };
 
 struct labeller;


