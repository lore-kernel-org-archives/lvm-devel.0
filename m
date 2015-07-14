From: Andy Grover <agrover@redhat.com>
Date: Tue, 14 Jul 2015 13:18:09 -0700
Subject: [PATCH] lvmcache: Change info_from_pvid() valid_only param to an enum
Message-ID: <1436905089-4725-1-git-send-email-agrover@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The discussion at the top of lvmetad-core.c assumes that clients wanting
to use stale metadata will be rare (but still something that needs to
be supported.) But, looking at the callers of lvmcache_info_from_pvid(),
29 out of 32 callers set valid_only to 0.

Create an enum with MUST_BE_VALID and INVALID_OK members and replace
valid_only param with it. This has no code effect, but should make it
clearer in callers of info_from_pvid() that they may get stale info.
---
 lib/cache/lvmcache.c          | 18 +++++++++---------
 lib/cache/lvmcache.h          |  7 ++++++-
 lib/cache/lvmetad.c           |  8 ++++----
 lib/format_text/format-text.c |  8 ++++----
 lib/label/label.c             |  8 ++++----
 lib/metadata/metadata.c       | 10 +++++-----
 lib/metadata/pv.c             | 12 ++++++------
 lib/metadata/pv_manip.c       |  2 +-
 8 files changed, 39 insertions(+), 34 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index d44f9d4..7d6d6a5 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -661,7 +661,7 @@ static int _vginfo_is_invalid(struct lvmcache_vginfo *vginfo)
  * If valid_only is set, data will only be returned if the cached data is
  * known still to be valid.
  */
-struct lvmcache_info *lvmcache_info_from_pvid(const char *pvid, int valid_only)
+struct lvmcache_info *lvmcache_info_from_pvid(const char *pvid, enum result_validity validity)
 {
 	struct lvmcache_info *info;
 	char id[ID_LEN + 1] __attribute__((aligned(8)));
@@ -675,7 +675,7 @@ struct lvmcache_info *lvmcache_info_from_pvid(const char *pvid, int valid_only)
 	if (!(info = dm_hash_lookup(_pvid_hash, id)))
 		return NULL;
 
-	if (valid_only && !_info_is_valid(info))
+	if (validity == MUST_BE_VALID && !_info_is_valid(info))
 		return NULL;
 
 	return info;
@@ -698,7 +698,7 @@ char *lvmcache_vgname_from_pvid(struct cmd_context *cmd, const char *pvid)
 		return NULL;
 	}
 
-	info = lvmcache_info_from_pvid(pvid, 0);
+	info = lvmcache_info_from_pvid(pvid, INVALID_OK);
 	if (!info)
 		return_NULL;
 
@@ -1023,7 +1023,7 @@ static struct device *_device_from_pvid(const struct id *pvid,
 	struct lvmcache_info *info;
 	struct label *label;
 
-	if ((info = lvmcache_info_from_pvid((const char *) pvid, 0))) {
+	if ((info = lvmcache_info_from_pvid((const char *) pvid, INVALID_OK))) {
 		if (lvmetad_active()) {
 			if (info->label && label_sector)
 				*label_sector = info->label->sector;
@@ -1569,7 +1569,7 @@ int lvmcache_update_vg(struct volume_group *vg, unsigned precommitted)
 	dm_list_iterate_items(pvl, &vg->pvs) {
 		strncpy(pvid_s, (char *) &pvl->pv->id, sizeof(pvid_s) - 1);
 		/* FIXME Could pvl->pv->dev->pvid ever be different? */
-		if ((info = lvmcache_info_from_pvid(pvid_s, 0)) &&
+		if ((info = lvmcache_info_from_pvid(pvid_s, INVALID_OK)) &&
 		    !lvmcache_update_vgname_and_id(info, &vgsummary))
 			return_0;
 	}
@@ -1594,7 +1594,7 @@ void lvmcache_replace_dev(struct cmd_context *cmd, struct physical_volume *pv,
 	strncpy(pvid_s, (char *) &pv->id, sizeof(pvid_s) - 1);
 	pvid_s[sizeof(pvid_s) - 1] = '\0';
 
-	if (!(info = lvmcache_info_from_pvid(pvid_s, 0)))
+	if (!(info = lvmcache_info_from_pvid(pvid_s, INVALID_OK)))
 		return;
 
 	info->dev = dev;
@@ -1687,8 +1687,8 @@ struct lvmcache_info *lvmcache_add(struct labeller *labeller, const char *pvid,
 	strncpy(pvid_s, pvid, sizeof(pvid_s) - 1);
 	pvid_s[sizeof(pvid_s) - 1] = '\0';
 
-	if (!(existing = lvmcache_info_from_pvid(pvid_s, 0)) &&
-	    !(existing = lvmcache_info_from_pvid(dev->pvid, 0))) {
+	if (!(existing = lvmcache_info_from_pvid(pvid_s, INVALID_OK)) &&
+	    !(existing = lvmcache_info_from_pvid(dev->pvid, INVALID_OK))) {
 		if (!(label = label_create(labeller)))
 			return_NULL;
 		if (!(info = dm_zalloc(sizeof(*info)))) {
@@ -1987,7 +1987,7 @@ void lvmcache_destroy(struct cmd_context *cmd, int retain_orphans, int reset)
 
 int lvmcache_pvid_is_locked(const char *pvid) {
 	struct lvmcache_info *info;
-	info = lvmcache_info_from_pvid(pvid, 0);
+	info = lvmcache_info_from_pvid(pvid, INVALID_OK);
 	if (!info || !info->vginfo)
 		return 0;
 
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index 780325a..cd260bc 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -48,6 +48,11 @@ struct lvmcache_vgsummary {
 	size_t mda_size;
 };
 
+enum result_validity {
+	MUST_BE_VALID,
+	INVALID_OK,
+};
+
 int lvmcache_init(void);
 void lvmcache_allow_reads_with_lvmetad(void);
 
@@ -84,7 +89,7 @@ int lvmcache_vginfo_holders_dec_and_test_for_zero(struct lvmcache_vginfo *vginfo
 struct lvmcache_vginfo *lvmcache_vginfo_from_vgname(const char *vgname,
 					   const char *vgid);
 struct lvmcache_vginfo *lvmcache_vginfo_from_vgid(const char *vgid);
-struct lvmcache_info *lvmcache_info_from_pvid(const char *pvid, int valid_only);
+struct lvmcache_info *lvmcache_info_from_pvid(const char *pvid, enum result_validity);
 const char *lvmcache_vgname_from_vgid(struct dm_pool *mem, const char *vgid);
 struct device *lvmcache_device_from_pvid(struct cmd_context *cmd, const struct id *pvid,
 				unsigned *scan_done_once, uint64_t *label_sector);
diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 783a114..0c02ff7 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -404,7 +404,7 @@ static int _pv_populate_lvmcache(struct cmd_context *cmd,
 static int _pv_update_struct_pv(struct physical_volume *pv, struct format_instance *fid)
 {
 	struct lvmcache_info *info;
-	if ((info = lvmcache_info_from_pvid((const char *)&pv->id, 0))) {
+	if ((info = lvmcache_info_from_pvid((const char *)&pv->id, INVALID_OK))) {
 		pv->label_sector = lvmcache_get_label(info)->sector;
 		pv->dev = lvmcache_device(info);
 		if (!pv->dev)
@@ -582,7 +582,7 @@ int lvmetad_vg_update(struct volume_group *vg)
 		if ((num = strchr(mda_id, '_'))) {
 			*num = 0;
 			++num;
-			if ((info = lvmcache_info_from_pvid(mda_id, 0))) {
+			if ((info = lvmcache_info_from_pvid(mda_id, INVALID_OK))) {
 				memset(&baton, 0, sizeof(baton));
 				baton.find = atoi(num);
 				baton.ignore = mda_is_ignored(mda);
@@ -896,7 +896,7 @@ int lvmetad_pv_found(const struct id *pvid, struct device *dev, const struct for
 	if (!pvmeta)
 		return_0;
 
-	info = lvmcache_info_from_pvid((const char *)pvid, 0);
+	info = lvmcache_info_from_pvid((const char *)pvid, INVALID_OK);
 
 	if (!(pvmeta->root = make_config_node(pvmeta, "pv", NULL, NULL))) {
 		dm_config_destroy(pvmeta);
@@ -1051,7 +1051,7 @@ static struct volume_group *lvmetad_pvscan_vg(struct cmd_context *cmd, struct vo
 		if (!pvl->pv->dev)
 			continue;
 
-		info = lvmcache_info_from_pvid((const char *)&pvl->pv->id, 0);
+		info = lvmcache_info_from_pvid((const char *)&pvl->pv->id, INVALID_OK);
 
 		baton.vg = NULL;
 		baton.fid = lvmcache_fmt(info)->ops->create_instance(lvmcache_fmt(info), &fic);
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 1d7dc3c..41b4a66 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -453,7 +453,7 @@ static struct raw_locn *_find_vg_rlocn(struct device_area *dev_area,
 				   "not match expected name %s.", vgname);
 
       bad:
-	if ((info = lvmcache_info_from_pvid(dev_area->dev->pvid, 0)))
+	if ((info = lvmcache_info_from_pvid(dev_area->dev->pvid, INVALID_OK)))
 		lvmcache_update_vgname_and_id(info, &vgsummary_orphan);
 
 	return NULL;
@@ -1485,10 +1485,10 @@ static int _text_pv_read(const struct format_type *fmt, const char *pv_name,
 		return_0;
 
 	if (lvmetad_active()) {
-		info = lvmcache_info_from_pvid(dev->pvid, 0);
+		info = lvmcache_info_from_pvid(dev->pvid, INVALID_OK);
 		if (!info && !lvmetad_pv_lookup_by_dev(fmt->cmd, dev, NULL))
 			return 0;
-		info = lvmcache_info_from_pvid(dev->pvid, 0);
+		info = lvmcache_info_from_pvid(dev->pvid, INVALID_OK);
 	} else {
 		struct label *label;
 		if (!(label_read(dev, &label, UINT64_C(0))))
@@ -1775,7 +1775,7 @@ static int _text_pv_setup(const struct format_type *fmt,
 	 */
 	else {
 		if (!pv->dev ||
-		    !(info = lvmcache_info_from_pvid(pv->dev->pvid, 0))) {
+		    !(info = lvmcache_info_from_pvid(pv->dev->pvid, INVALID_OK))) {
 			log_error("PV %s missing from cache", pv_dev_name(pv));
 			return 0;
 		}
diff --git a/lib/label/label.c b/lib/label/label.c
index 4510400..f97a3a8 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -183,7 +183,7 @@ static struct labeller *_find_labeller(struct device *dev, char *buf,
 
       out:
 	if (!found) {
-		if ((info = lvmcache_info_from_pvid(dev->pvid, 0)))
+		if ((info = lvmcache_info_from_pvid(dev->pvid, INVALID_OK)))
 			_update_lvmcache_orphan(info);
 		log_very_verbose("%s: No label detected", dev_name(dev));
 	}
@@ -270,7 +270,7 @@ int label_read(struct device *dev, struct label **result,
 	struct lvmcache_info *info;
 	int r = 0;
 
-	if ((info = lvmcache_info_from_pvid(dev->pvid, 1))) {
+	if ((info = lvmcache_info_from_pvid(dev->pvid, MUST_BE_VALID))) {
 		log_debug_devs("Using cached label for %s", dev_name(dev));
 		*result = lvmcache_get_label(info);
 		return 1;
@@ -279,7 +279,7 @@ int label_read(struct device *dev, struct label **result,
 	if (!dev_open_readonly(dev)) {
 		stack;
 
-		if ((info = lvmcache_info_from_pvid(dev->pvid, 0)))
+		if ((info = lvmcache_info_from_pvid(dev->pvid, INVALID_OK)))
 			_update_lvmcache_orphan(info);
 
 		return r;
@@ -354,7 +354,7 @@ int label_verify(struct device *dev)
 	int r = 0;
 
 	if (!dev_open_readonly(dev)) {
-		if ((info = lvmcache_info_from_pvid(dev->pvid, 0)))
+		if ((info = lvmcache_info_from_pvid(dev->pvid, INVALID_OK)))
 			_update_lvmcache_orphan(info);
 		return_0;
 	}
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 07ef54e..b65a1c0 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -158,7 +158,7 @@ void del_pvl_from_vgs(struct volume_group *vg, struct pv_list *pvl)
 	dm_list_del(&pvl->list);
 
 	pvl->pv->vg = vg->fid->fmt->orphan_vg; /* orphan */
-	if ((info = lvmcache_info_from_pvid((const char *) &pvl->pv->id, 0)))
+	if ((info = lvmcache_info_from_pvid((const char *) &pvl->pv->id, INVALID_OK)))
 		lvmcache_fid_add_mdas(info, vg->fid->fmt->orphan_vg->fid,
 				      (const char *) &pvl->pv->id, ID_LEN);
 	pv_set_fid(pvl->pv, vg->fid->fmt->orphan_vg->fid);
@@ -3573,7 +3573,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 				 * Check it's an orphan without metadata area
 				 * not ignored.
 				 */
-				if (!(info = lvmcache_info_from_pvid(pvl->pv->dev->pvid, 1)) ||
+				if (!(info = lvmcache_info_from_pvid(pvl->pv->dev->pvid, MUST_BE_VALID)) ||
 				    !lvmcache_is_orphan(info)) {
 					inconsistent_pvs = 1;
 					break;
@@ -4022,7 +4022,7 @@ const char *find_vgname_from_pvid(struct cmd_context *cmd,
 	vgname = lvmcache_vgname_from_pvid(cmd, pvid);
 
 	if (is_orphan_vg(vgname)) {
-		if (!(info = lvmcache_info_from_pvid(pvid, 0))) {
+		if (!(info = lvmcache_info_from_pvid(pvid, INVALID_OK))) {
 			return_NULL;
 		}
 		/*
@@ -4080,7 +4080,7 @@ static struct physical_volume *_pv_read(struct cmd_context *cmd,
 		return_NULL;
 
 	if (lvmetad_active()) {
-		info = lvmcache_info_from_pvid(dev->pvid, 0);
+		info = lvmcache_info_from_pvid(dev->pvid, INVALID_OK);
 		if (!info) {
 			if (!lvmetad_pv_lookup_by_dev(cmd, dev, &found))
 				return_NULL;
@@ -4090,7 +4090,7 @@ static struct physical_volume *_pv_read(struct cmd_context *cmd,
 						  pv_name);
 				return NULL;
 			}
-			if (!(info = lvmcache_info_from_pvid(dev->pvid, 0))) {
+			if (!(info = lvmcache_info_from_pvid(dev->pvid, INVALID_OK))) {
 				if (warn_flags & WARN_PV_READ)
 					log_error("No cache info in lvmetad cache for %s.",
 						  pv_name);
diff --git a/lib/metadata/pv.c b/lib/metadata/pv.c
index 774cedb..42a69d8 100644
--- a/lib/metadata/pv.c
+++ b/lib/metadata/pv.c
@@ -157,7 +157,7 @@ uint32_t pv_mda_count(const struct physical_volume *pv)
 {
 	struct lvmcache_info *info;
 
-	info = lvmcache_info_from_pvid((const char *)&pv->id.uuid, 0);
+	info = lvmcache_info_from_pvid((const char *)&pv->id.uuid, INVALID_OK);
 
 	return info ? lvmcache_mda_count(info) : UINT64_C(0);
 }
@@ -177,7 +177,7 @@ uint32_t pv_mda_used_count(const struct physical_volume *pv)
 	struct lvmcache_info *info;
 	uint32_t used_count=0;
 
-	info = lvmcache_info_from_pvid((const char *)&pv->id.uuid, 0);
+	info = lvmcache_info_from_pvid((const char *)&pv->id.uuid, INVALID_OK);
 	if (!info)
 		return 0;
 	lvmcache_foreach_mda(info, _count_unignored, &used_count);
@@ -231,7 +231,7 @@ uint64_t pv_mda_size(const struct physical_volume *pv)
 	const char *pvid = (const char *)(&pv->id.uuid);
 
 	/* PVs could have 2 mdas of different sizes (rounding effect) */
-	if ((info = lvmcache_info_from_pvid(pvid, 0)))
+	if ((info = lvmcache_info_from_pvid(pvid, INVALID_OK)))
 		min_mda_size = lvmcache_smallest_mda_size(info);
 	return min_mda_size;
 }
@@ -269,7 +269,7 @@ uint64_t pv_mda_free(const struct physical_volume *pv)
 	const char *pvid = (const char *)&pv->id.uuid;
 	struct lvmcache_info *info;
 
-	if ((info = lvmcache_info_from_pvid(pvid, 0)))
+	if ((info = lvmcache_info_from_pvid(pvid, INVALID_OK)))
 		return lvmcache_info_mda_free(info);
 
 	return 0;
@@ -322,7 +322,7 @@ unsigned pv_mda_set_ignored(const struct physical_volume *pv, unsigned mda_ignor
 	struct _pv_mda_set_ignored_baton baton;
 	struct metadata_area *mda;
 
-	if (!(info = lvmcache_info_from_pvid((const char *)&pv->id.uuid, 0)))
+	if (!(info = lvmcache_info_from_pvid((const char *)&pv->id.uuid, INVALID_OK)))
 		return_0;
 
 	baton.mda_ignored = mda_ignored;
@@ -368,7 +368,7 @@ unsigned pv_mda_set_ignored(const struct physical_volume *pv, unsigned mda_ignor
 struct label *pv_label(const struct physical_volume *pv)
 {
 	struct lvmcache_info *info =
-		lvmcache_info_from_pvid((const char *)&pv->id.uuid, 0);
+		lvmcache_info_from_pvid((const char *)&pv->id.uuid, INVALID_OK);
 
 	if (info)
 		return lvmcache_get_label(info);
diff --git a/lib/metadata/pv_manip.c b/lib/metadata/pv_manip.c
index ce7f661..cea9121 100644
--- a/lib/metadata/pv_manip.c
+++ b/lib/metadata/pv_manip.c
@@ -781,7 +781,7 @@ int pvremove_single(struct cmd_context *cmd, const char *pv_name,
 		goto out;
 	}
 
-	info = lvmcache_info_from_pvid(dev->pvid, 1);
+	info = lvmcache_info_from_pvid(dev->pvid, MUST_BE_VALID);
 
 	if (!dev_test_excl(dev)) {
 		/* FIXME Detect whether device-mapper is still using the device */
-- 
2.4.3


