From: David Teigland <teigland@fedoraproject.org>
Date: Tue,  7 Jun 2016 20:22:54 +0000 (UTC)
Subject: master - lvmcache: add optional dev arg to lvmcache_info_from_pvid
Message-ID: <20160607202254.6DF6160CE6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=01156de6f70ba5b1c8e2ae23c655ccd36ac59441
Commit:        01156de6f70ba5b1c8e2ae23c655ccd36ac59441
Parent:        ed6ffc7a342149dab60086bcabd5fbd2d12ceeb7
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Jun 6 14:04:17 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jun 7 15:15:47 2016 -0500

lvmcache: add optional dev arg to lvmcache_info_from_pvid

A number of places are working on a specific dev when they
call lvmcache_info_from_pvid() to look up an info struct
based on a pvid.  In those cases, pass the dev being used
to lvmcache_info_from_pvid().  When a dev is specified,
lvmcache_info_from_pvid() will verify that the cached
info it's using matches the dev being processed before
returning the info.  Calling code will not mistakenly
get info for the wrong dev when duplicate devs exist.

This confusion was happening when scanning labels when
duplicate devs existed.  label_read for the first dev
would add an info struct to lvmcache for that dev/pvid.
label_read for the second dev would see the pvid in
lvmcache from first dev, and mistakenly conclude that
the label_read from the second dev can be skipped
because it's already been done.  By verifying that the
dev for the cached pvid matches the dev being read,
this mismatch is avoided and the label is actually read
from the second duplicate.
---
 lib/cache/lvmcache.c          |   33 ++++++++++++++++++++++++---------
 lib/cache/lvmcache.h          |    2 +-
 lib/cache/lvmetad.c           |    8 ++++----
 lib/format_text/archiver.c    |    2 +-
 lib/format_text/format-text.c |   10 +++++-----
 lib/label/label.c             |   12 +++++++-----
 lib/metadata/metadata.c       |   12 ++++++------
 lib/metadata/pv.c             |   14 +++++++-------
 lib/metadata/pv_manip.c       |    2 +-
 tools/toollib.c               |    8 ++++++--
 10 files changed, 62 insertions(+), 41 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 9e232f6..1af6363 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -690,8 +690,11 @@ static int _vginfo_is_invalid(struct lvmcache_vginfo *vginfo)
 /*
  * If valid_only is set, data will only be returned if the cached data is
  * known still to be valid.
+ *
+ * When the device being worked with is known, pass that dev as the second arg.
+ * This ensures that when duplicates exist, the wrong dev isn't used.
  */
-struct lvmcache_info *lvmcache_info_from_pvid(const char *pvid, int valid_only)
+struct lvmcache_info *lvmcache_info_from_pvid(const char *pvid, struct device *dev, int valid_only)
 {
 	struct lvmcache_info *info;
 	char id[ID_LEN + 1] __attribute__((aligned(8)));
@@ -705,6 +708,15 @@ struct lvmcache_info *lvmcache_info_from_pvid(const char *pvid, int valid_only)
 	if (!(info = dm_hash_lookup(_pvid_hash, id)))
 		return NULL;
 
+	/*
+	 * When handling duplicate PVs, more than one device can have this pvid.
+	 */
+	if (dev && info->dev && (info->dev != dev)) {
+		log_debug_cache("Ignoring lvmcache info for dev %s because dev %s was requested for PVID %s.",
+				dev_name(info->dev), dev_name(dev), id);
+		return NULL;
+	}
+
 	if (valid_only && !_info_is_valid(info))
 		return NULL;
 
@@ -733,7 +745,7 @@ char *lvmcache_vgname_from_pvid(struct cmd_context *cmd, const char *pvid)
 		return NULL;
 	}
 
-	info = lvmcache_info_from_pvid(pvid, 0);
+	info = lvmcache_info_from_pvid(pvid, NULL, 0);
 	if (!info)
 		return_NULL;
 
@@ -868,7 +880,7 @@ next:
 	 * Find the device for the pvid that's currently in lvmcache.
 	 */
 
-	if (!(info = lvmcache_info_from_pvid(alt->dev->pvid, 0))) {
+	if (!(info = lvmcache_info_from_pvid(alt->dev->pvid, NULL, 0))) {
 		/* This shouldn't happen */
 		log_warn("WARNING: PV %s on duplicate device %s not found in cache.",
 			 alt->dev->pvid, dev_name(alt->dev));
@@ -1110,7 +1122,7 @@ int lvmcache_label_scan(struct cmd_context *cmd)
 
 		dm_list_iterate_items(devl, &del_cache_devs) {
 			log_debug_cache("Drop duplicate device %s in lvmcache", dev_name(devl->dev));
-			if ((info = lvmcache_info_from_pvid(devl->dev->pvid, 0)))
+			if ((info = lvmcache_info_from_pvid(devl->dev->pvid, NULL, 0)))
 				lvmcache_del(info);
 		}
 
@@ -1381,7 +1393,7 @@ static struct device *_device_from_pvid(const struct id *pvid,
 	struct lvmcache_info *info;
 	struct label *label;
 
-	if ((info = lvmcache_info_from_pvid((const char *) pvid, 0))) {
+	if ((info = lvmcache_info_from_pvid((const char *) pvid, NULL, 0))) {
 		if (lvmetad_used()) {
 			if (info->label && label_sector)
 				*label_sector = info->label->sector;
@@ -1962,7 +1974,7 @@ int lvmcache_update_vg(struct volume_group *vg, unsigned precommitted)
 	dm_list_iterate_items(pvl, &vg->pvs) {
 		strncpy(pvid_s, (char *) &pvl->pv->id, sizeof(pvid_s) - 1);
 		/* FIXME Could pvl->pv->dev->pvid ever be different? */
-		if ((info = lvmcache_info_from_pvid(pvid_s, 0)) &&
+		if ((info = lvmcache_info_from_pvid(pvid_s, pvl->pv->dev, 0)) &&
 		    !lvmcache_update_vgname_and_id(info, &vgsummary))
 			return_0;
 	}
@@ -2072,12 +2084,15 @@ struct lvmcache_info *lvmcache_add(struct labeller *labeller,
 
 	/*
 	 * Find existing info struct in _pvid_hash or create a new one.
+	 *
+	 * Don't pass the known "dev" as an arg here.  The mismatching
+	 * devs for the duplicate case is checked below.
 	 */
 
-	info = lvmcache_info_from_pvid(pvid_s, 0);
+	info = lvmcache_info_from_pvid(pvid_s, NULL, 0);
 
 	if (!info)
-		info = lvmcache_info_from_pvid(dev->pvid, 0);
+		info = lvmcache_info_from_pvid(dev->pvid, NULL, 0);
 
 	if (!info) {
 		info = _create_info(labeller, dev);
@@ -2262,7 +2277,7 @@ void lvmcache_destroy(struct cmd_context *cmd, int retain_orphans, int reset)
 
 int lvmcache_pvid_is_locked(const char *pvid) {
 	struct lvmcache_info *info;
-	info = lvmcache_info_from_pvid(pvid, 0);
+	info = lvmcache_info_from_pvid(pvid, NULL, 0);
 	if (!info || !info->vginfo)
 		return 0;
 
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index 4fb74db..5f85b03 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -102,7 +102,7 @@ int lvmcache_vginfo_holders_dec_and_test_for_zero(struct lvmcache_vginfo *vginfo
 struct lvmcache_vginfo *lvmcache_vginfo_from_vgname(const char *vgname,
 					   const char *vgid);
 struct lvmcache_vginfo *lvmcache_vginfo_from_vgid(const char *vgid);
-struct lvmcache_info *lvmcache_info_from_pvid(const char *pvid, int valid_only);
+struct lvmcache_info *lvmcache_info_from_pvid(const char *pvid, struct device *dev, int valid_only);
 const char *lvmcache_vgname_from_vgid(struct dm_pool *mem, const char *vgid);
 const char *lvmcache_vgid_from_vgname(struct cmd_context *cmd, const char *vgname);
 struct device *lvmcache_device_from_pvid(struct cmd_context *cmd, const struct id *pvid,
diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 02f0897..70adbb4 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -937,7 +937,7 @@ static int _pv_update_struct_pv(struct physical_volume *pv, struct format_instan
 {
 	struct lvmcache_info *info;
 
-	if ((info = lvmcache_info_from_pvid((const char *)&pv->id, 0))) {
+	if ((info = lvmcache_info_from_pvid((const char *)&pv->id, pv->dev, 0))) {
 		pv->label_sector = lvmcache_get_label(info)->sector;
 		pv->dev = lvmcache_device(info);
 		if (!pv->dev)
@@ -1175,7 +1175,7 @@ int lvmetad_vg_update(struct volume_group *vg)
 		if ((num = strchr(mda_id, '_'))) {
 			*num = 0;
 			++num;
-			if ((info = lvmcache_info_from_pvid(mda_id, 0))) {
+			if ((info = lvmcache_info_from_pvid(mda_id, NULL, 0))) {
 				memset(&baton, 0, sizeof(baton));
 				baton.find = atoi(num);
 				baton.ignore = mda_is_ignored(mda);
@@ -1496,7 +1496,7 @@ int lvmetad_pv_found(struct cmd_context *cmd, const struct id *pvid, struct devi
 	if (!pvmeta)
 		return_0;
 
-	info = lvmcache_info_from_pvid((const char *)pvid, 0);
+	info = lvmcache_info_from_pvid((const char *)pvid, dev, 0);
 
 	if (!(pvmeta->root = make_config_node(pvmeta, "pv", NULL, NULL))) {
 		dm_config_destroy(pvmeta);
@@ -1682,7 +1682,7 @@ static struct volume_group *lvmetad_pvscan_vg(struct cmd_context *cmd, struct vo
 		if (!pvl->pv->dev)
 			continue;
 
-		if (!(info = lvmcache_info_from_pvid((const char *)&pvl->pv->id, 0))) {
+		if (!(info = lvmcache_info_from_pvid((const char *)&pvl->pv->id, pvl->pv->dev, 0))) {
 			log_error("Failed to find cached info for PV %s.", pv_dev_name(pvl->pv));
 			return NULL;
 		}
diff --git a/lib/format_text/archiver.c b/lib/format_text/archiver.c
index 8220c38..4e85e0e 100644
--- a/lib/format_text/archiver.c
+++ b/lib/format_text/archiver.c
@@ -339,7 +339,7 @@ static int _restore_vg_should_write_pv(struct physical_volume *pv, int do_pvcrea
 	if (!(pv->fmt->features & FMT_PV_FLAGS))
 		return 0;
 
-	if (!(info = lvmcache_info_from_pvid(pv->dev->pvid, 0))) {
+	if (!(info = lvmcache_info_from_pvid(pv->dev->pvid, pv->dev, 0))) {
 		log_error("Failed to find cached info for PV %s.", pv_dev_name(pv));
 		return -1;
 	}
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 095ae97..533fece 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -453,7 +453,7 @@ static struct raw_locn *_find_vg_rlocn(struct device_area *dev_area,
 				   "not match expected name %s.", vgname);
 
       bad:
-	if ((info = lvmcache_info_from_pvid(dev_area->dev->pvid, 0)) &&
+	if ((info = lvmcache_info_from_pvid(dev_area->dev->pvid, dev_area->dev, 0)) &&
 	    !lvmcache_update_vgname_and_id(info, &vgsummary_orphan))
 		stack;
 
@@ -1447,7 +1447,7 @@ static int _text_pv_needs_rewrite(const struct format_type *fmt, struct physical
 	if (!pv->is_labelled)
 		return 1;
 
-	if (!(info = lvmcache_info_from_pvid((const char *)&pv->id, 0))) {
+	if (!(info = lvmcache_info_from_pvid((const char *)&pv->id, pv->dev, 0))) {
 		log_error("Failed to find cached info for PV %s.", pv_dev_name(pv));
 		return 0;
 	}
@@ -1526,10 +1526,10 @@ static int _text_pv_read(const struct format_type *fmt, const char *pv_name,
 		return_0;
 
 	if (lvmetad_used()) {
-		info = lvmcache_info_from_pvid(dev->pvid, 0);
+		info = lvmcache_info_from_pvid(dev->pvid, dev, 0);
 		if (!info && !lvmetad_pv_lookup_by_dev(fmt->cmd, dev, NULL))
 			return 0;
-		info = lvmcache_info_from_pvid(dev->pvid, 0);
+		info = lvmcache_info_from_pvid(dev->pvid, dev, 0);
 	} else {
 		struct label *label;
 		if (!(label_read(dev, &label, UINT64_C(0))))
@@ -1815,7 +1815,7 @@ static int _text_pv_setup(const struct format_type *fmt,
 	 */
 	else {
 		if (!pv->dev ||
-		    !(info = lvmcache_info_from_pvid(pv->dev->pvid, 0))) {
+		    !(info = lvmcache_info_from_pvid(pv->dev->pvid, pv->dev, 0))) {
 			log_error("PV %s missing from cache", pv_dev_name(pv));
 			return 0;
 		}
diff --git a/lib/label/label.c b/lib/label/label.c
index b633aa3..b52cb42 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -184,7 +184,7 @@ static struct labeller *_find_labeller(struct device *dev, char *buf,
 
       out:
 	if (!found) {
-		if ((info = lvmcache_info_from_pvid(dev->pvid, 0)))
+		if ((info = lvmcache_info_from_pvid(dev->pvid, dev, 0)))
 			_update_lvmcache_orphan(info);
 		log_very_verbose("%s: No label detected", dev_name(dev));
 	}
@@ -271,16 +271,18 @@ int label_read(struct device *dev, struct label **result,
 	struct lvmcache_info *info;
 	int r = 0;
 
-	if ((info = lvmcache_info_from_pvid(dev->pvid, 1))) {
-		log_debug_devs("Using cached label for %s", dev_name(dev));
+	if ((info = lvmcache_info_from_pvid(dev->pvid, dev, 1))) {
+		log_debug_devs("Reading label from lvmcache for %s", dev_name(dev));
 		*result = lvmcache_get_label(info);
 		return 1;
 	}
 
+	log_debug_devs("Reading label from device %s", dev_name(dev));
+
 	if (!dev_open_readonly(dev)) {
 		stack;
 
-		if ((info = lvmcache_info_from_pvid(dev->pvid, 0)))
+		if ((info = lvmcache_info_from_pvid(dev->pvid, dev, 0)))
 			_update_lvmcache_orphan(info);
 
 		return r;
@@ -355,7 +357,7 @@ int label_verify(struct device *dev)
 	int r = 0;
 
 	if (!dev_open_readonly(dev)) {
-		if ((info = lvmcache_info_from_pvid(dev->pvid, 0)))
+		if ((info = lvmcache_info_from_pvid(dev->pvid, dev, 0)))
 			_update_lvmcache_orphan(info);
 		return_0;
 	}
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index bd97cd2..ea42fb7 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -160,7 +160,7 @@ void del_pvl_from_vgs(struct volume_group *vg, struct pv_list *pvl)
 	dm_list_del(&pvl->list);
 
 	pvl->pv->vg = vg->fid->fmt->orphan_vg; /* orphan */
-	if ((info = lvmcache_info_from_pvid((const char *) &pvl->pv->id, 0)))
+	if ((info = lvmcache_info_from_pvid((const char *) &pvl->pv->id, pvl->pv->dev, 0)))
 		lvmcache_fid_add_mdas(info, vg->fid->fmt->orphan_vg->fid,
 				      (const char *) &pvl->pv->id, ID_LEN);
 	pv_set_fid(pvl->pv, vg->fid->fmt->orphan_vg->fid);
@@ -4035,7 +4035,7 @@ static int _check_or_repair_pv_ext(struct cmd_context *cmd,
 		if (is_missing_pv(pvl->pv))
 			continue;
 
-		if (!(info = lvmcache_info_from_pvid(pvl->pv->dev->pvid, 0))) {
+		if (!(info = lvmcache_info_from_pvid(pvl->pv->dev->pvid, pvl->pv->dev, 0))) {
 			log_error("Failed to find cached info for PV %s.", pv_dev_name(pvl->pv));
 			goto out;
 		}
@@ -4313,7 +4313,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 				 * Check it's an orphan without metadata area
 				 * not ignored.
 				 */
-				if (!(info = lvmcache_info_from_pvid(pvl->pv->dev->pvid, 1)) ||
+				if (!(info = lvmcache_info_from_pvid(pvl->pv->dev->pvid, pvl->pv->dev, 1)) ||
 				    !lvmcache_is_orphan(info)) {
 					inconsistent_pvs = 1;
 					break;
@@ -4917,7 +4917,7 @@ const char *find_vgname_from_pvid(struct cmd_context *cmd,
 	vgname = lvmcache_vgname_from_pvid(cmd, pvid);
 
 	if (is_orphan_vg(vgname)) {
-		if (!(info = lvmcache_info_from_pvid(pvid, 0))) {
+		if (!(info = lvmcache_info_from_pvid(pvid, NULL, 0))) {
 			return_NULL;
 		}
 		/*
@@ -4975,7 +4975,7 @@ static struct physical_volume *_pv_read(struct cmd_context *cmd,
 		return_NULL;
 
 	if (lvmetad_used()) {
-		info = lvmcache_info_from_pvid(dev->pvid, 0);
+		info = lvmcache_info_from_pvid(dev->pvid, dev, 0);
 		if (!info) {
 			if (!lvmetad_pv_lookup_by_dev(cmd, dev, &found))
 				return_NULL;
@@ -4985,7 +4985,7 @@ static struct physical_volume *_pv_read(struct cmd_context *cmd,
 						  pv_name);
 				return NULL;
 			}
-			if (!(info = lvmcache_info_from_pvid(dev->pvid, 0))) {
+			if (!(info = lvmcache_info_from_pvid(dev->pvid, dev, 0))) {
 				if (warn_flags & WARN_PV_READ)
 					log_error("No cache info in lvmetad cache for %s.",
 						  pv_name);
diff --git a/lib/metadata/pv.c b/lib/metadata/pv.c
index 7169f31..9bf6075 100644
--- a/lib/metadata/pv.c
+++ b/lib/metadata/pv.c
@@ -157,7 +157,7 @@ uint32_t pv_mda_count(const struct physical_volume *pv)
 {
 	struct lvmcache_info *info;
 
-	info = lvmcache_info_from_pvid((const char *)&pv->id.uuid, 0);
+	info = lvmcache_info_from_pvid((const char *)&pv->id.uuid, pv->dev, 0);
 
 	return info ? lvmcache_mda_count(info) : UINT64_C(0);
 }
@@ -177,7 +177,7 @@ uint32_t pv_mda_used_count(const struct physical_volume *pv)
 	struct lvmcache_info *info;
 	uint32_t used_count=0;
 
-	info = lvmcache_info_from_pvid((const char *)&pv->id.uuid, 0);
+	info = lvmcache_info_from_pvid((const char *)&pv->id.uuid, pv->dev, 0);
 	if (!info)
 		return 0;
 	lvmcache_foreach_mda(info, _count_unignored, &used_count);
@@ -222,7 +222,7 @@ int is_used_pv(const struct physical_volume *pv)
 	if (!(pv->fmt->features & FMT_PV_FLAGS))
 		return 0;
 
-	if (!(info = lvmcache_info_from_pvid((const char *)&pv->id, 0))) {
+	if (!(info = lvmcache_info_from_pvid((const char *)&pv->id, pv->dev, 0))) {
 		log_error("Failed to find cached info for PV %s.", pv_dev_name(pv));
 		return -1;
 	}
@@ -268,7 +268,7 @@ uint64_t pv_mda_size(const struct physical_volume *pv)
 	const char *pvid = (const char *)(&pv->id.uuid);
 
 	/* PVs could have 2 mdas of different sizes (rounding effect) */
-	if ((info = lvmcache_info_from_pvid(pvid, 0)))
+	if ((info = lvmcache_info_from_pvid(pvid, pv->dev, 0)))
 		min_mda_size = lvmcache_smallest_mda_size(info);
 	return min_mda_size;
 }
@@ -306,7 +306,7 @@ uint64_t pv_mda_free(const struct physical_volume *pv)
 	const char *pvid = (const char *)&pv->id.uuid;
 	struct lvmcache_info *info;
 
-	if ((info = lvmcache_info_from_pvid(pvid, 0)))
+	if ((info = lvmcache_info_from_pvid(pvid, pv->dev, 0)))
 		return lvmcache_info_mda_free(info);
 
 	return 0;
@@ -359,7 +359,7 @@ unsigned pv_mda_set_ignored(const struct physical_volume *pv, unsigned mda_ignor
 	struct _pv_mda_set_ignored_baton baton;
 	struct metadata_area *mda;
 
-	if (!(info = lvmcache_info_from_pvid((const char *)&pv->id.uuid, 0)))
+	if (!(info = lvmcache_info_from_pvid((const char *)&pv->id.uuid, pv->dev, 0)))
 		return_0;
 
 	baton.mda_ignored = mda_ignored;
@@ -405,7 +405,7 @@ unsigned pv_mda_set_ignored(const struct physical_volume *pv, unsigned mda_ignor
 struct label *pv_label(const struct physical_volume *pv)
 {
 	struct lvmcache_info *info =
-		lvmcache_info_from_pvid((const char *)&pv->id.uuid, 0);
+		lvmcache_info_from_pvid((const char *)&pv->id.uuid, pv->dev, 0);
 
 	if (info)
 		return lvmcache_get_label(info);
diff --git a/lib/metadata/pv_manip.c b/lib/metadata/pv_manip.c
index fa18c99..567cede 100644
--- a/lib/metadata/pv_manip.c
+++ b/lib/metadata/pv_manip.c
@@ -792,7 +792,7 @@ int pvremove_single(struct cmd_context *cmd, const char *pv_name,
 		goto out;
 	}
 
-	info = lvmcache_info_from_pvid(dev->pvid, 0);
+	info = lvmcache_info_from_pvid(dev->pvid, dev, 0);
 
 	if (!dev_test_excl(dev)) {
 		/* FIXME Detect whether device-mapper is still using the device */
diff --git a/tools/toollib.c b/tools/toollib.c
index 0563fea..7cde806 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -3104,7 +3104,11 @@ static int _process_duplicate_pvs(struct cmd_context *cmd,
 
 		log_very_verbose("Processing duplicate device %s.", dev_name(devl->dev));
 
-		info = lvmcache_info_from_pvid(devl->dev->pvid, 0);
+		/*
+		 * Don't pass dev to lvmcache_info_from_pvid because we looking
+		 * for the chosen/preferred dev for this pvid.
+		 */
+		info = lvmcache_info_from_pvid(devl->dev->pvid, NULL, 0);
 		if (info)
 			vgname = lvmcache_vgname_from_info(info);
 		if (vgname)
@@ -4643,7 +4647,7 @@ do_command:
 			continue;
 		}
 
-		info = lvmcache_info_from_pvid(pd->pvid, 0);
+		info = lvmcache_info_from_pvid(pd->pvid, pd->dev, 0);
 		if (info)
 			lvmcache_del(info);
 


