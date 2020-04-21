From: David Teigland <teigland@sourceware.org>
Date: Tue, 21 Apr 2020 19:51:05 +0000 (GMT)
Subject: master - pass cmd struct through more functions
Message-ID: <20200421195105.A24FA386F02B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=cc4051eec051aef8912279a598c2cb491e68b508
Commit:        cc4051eec051aef8912279a598c2cb491e68b508
Parent:        3854931aea09b1ccd56a79ea53521be1287ff3a9
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jan 28 10:33:15 2020 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Apr 21 10:58:05 2020 -0500

pass cmd struct through more functions

no functional change
---
 lib/cache/lvmcache.c          | 10 +++++-----
 lib/cache/lvmcache.h          |  4 ++--
 lib/format_text/archiver.c    |  2 +-
 lib/format_text/format-text.c | 28 ++++++++++++++++------------
 lib/format_text/text_label.c  |  8 ++++----
 lib/label/label.c             |  2 +-
 lib/label/label.h             |  2 +-
 lib/metadata/metadata.c       |  6 +++---
 lib/metadata/metadata.h       |  8 +++++---
 tools/pvscan.c                |  2 +-
 10 files changed, 39 insertions(+), 33 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 2a52230b5..f7af4c28d 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -1532,7 +1532,7 @@ static void _lvmcache_update_pvsummaries(struct lvmcache_vginfo *vginfo, struct
  * Returning 0 causes the caller to remove the info struct for this
  * device from lvmcache, which will make it look like a missing device.
  */
-int lvmcache_update_vgname_and_id(struct lvmcache_info *info, struct lvmcache_vgsummary *vgsummary)
+int lvmcache_update_vgname_and_id(struct cmd_context *cmd, struct lvmcache_info *info, struct lvmcache_vgsummary *vgsummary)
 {
 	const char *vgname = vgsummary->vgname;
 	const char *vgid = (char *)&vgsummary->vgid;
@@ -1735,7 +1735,7 @@ int lvmcache_update_vg_from_write(struct volume_group *vg)
 		(void) dm_strncpy(pvid_s, (char *) &pvl->pv->id, sizeof(pvid_s));
 		/* FIXME Could pvl->pv->dev->pvid ever be different? */
 		if ((info = lvmcache_info_from_pvid(pvid_s, pvl->pv->dev, 0)) &&
-		    !lvmcache_update_vgname_and_id(info, &vgsummary))
+		    !lvmcache_update_vgname_and_id(vg->cmd, info, &vgsummary))
 			return_0;
 	}
 
@@ -1819,7 +1819,7 @@ int lvmcache_update_vg_from_read(struct volume_group *vg, unsigned precommitted)
 		 * info's for PVs without metadata were not connected to the
 		 * vginfo by label_scan, so do it here.
 		 */
-		if (!lvmcache_update_vgname_and_id(info, &vgsummary)) {
+		if (!lvmcache_update_vgname_and_id(vg->cmd, info, &vgsummary)) {
 			log_debug_cache("lvmcache_update_vg %s failed to update info for %s",
 					vg->name, dev_name(info->dev));
 		}
@@ -1927,7 +1927,7 @@ static struct lvmcache_info * _create_info(struct labeller *labeller, struct dev
 	return info;
 }
 
-struct lvmcache_info *lvmcache_add(struct labeller *labeller,
+struct lvmcache_info *lvmcache_add(struct cmd_context *cmd, struct labeller *labeller,
 				   const char *pvid, struct device *dev, uint64_t label_sector,
 				   const char *vgname, const char *vgid, uint32_t vgstatus,
 				   int *is_duplicate)
@@ -2042,7 +2042,7 @@ update_vginfo:
 	if (vgid)
 		strncpy((char *)&vgsummary.vgid, vgid, sizeof(vgsummary.vgid));
 
-	if (!lvmcache_update_vgname_and_id(info, &vgsummary)) {
+	if (!lvmcache_update_vgname_and_id(cmd, info, &vgsummary)) {
 		if (created) {
 			dm_hash_remove(_pvid_hash, pvid_s);
 			strcpy(info->dev->pvid, "");
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index 2416fe741..3412d2ca9 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -71,7 +71,7 @@ int lvmcache_label_rescan_vg(struct cmd_context *cmd, const char *vgname, const
 int lvmcache_label_rescan_vg_rw(struct cmd_context *cmd, const char *vgname, const char *vgid);
 
 /* Add/delete a device */
-struct lvmcache_info *lvmcache_add(struct labeller *labeller, const char *pvid,
+struct lvmcache_info *lvmcache_add(struct cmd_context *cmd, struct labeller *labeller, const char *pvid,
                                    struct device *dev, uint64_t label_sector,
                                    const char *vgname, const char *vgid,
                                    uint32_t vgstatus, int *is_duplicate);
@@ -80,7 +80,7 @@ void lvmcache_del(struct lvmcache_info *info);
 void lvmcache_del_dev(struct device *dev);
 
 /* Update things */
-int lvmcache_update_vgname_and_id(struct lvmcache_info *info,
+int lvmcache_update_vgname_and_id(struct cmd_context *cmd, struct lvmcache_info *info,
 				  struct lvmcache_vgsummary *vgsummary);
 int lvmcache_update_vg_from_read(struct volume_group *vg, unsigned precommitted);
 int lvmcache_update_vg_from_write(struct volume_group *vg);
diff --git a/lib/format_text/archiver.c b/lib/format_text/archiver.c
index 3a741dae5..733e62be8 100644
--- a/lib/format_text/archiver.c
+++ b/lib/format_text/archiver.c
@@ -315,7 +315,7 @@ struct volume_group *backup_read_vg(struct cmd_context *cmd,
 	}
 
 	dm_list_iterate_items(mda, &tf->metadata_areas_in_use) {
-		if (!(vg = mda->ops->vg_read(tf, vg_name, mda, NULL, NULL)))
+		if (!(vg = mda->ops->vg_read(cmd, tf, vg_name, mda, NULL, NULL)))
 			stack;
 		break;
 	}
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 268bd6471..e44871226 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -290,7 +290,8 @@ static int _raw_write_mda_header(const struct format_type *fmt,
  * in the label scanning path.
  */
 
-static struct raw_locn *_read_metadata_location_vg(struct device_area *dev_area,
+static struct raw_locn *_read_metadata_location_vg(struct cmd_context *cmd,
+				       struct device_area *dev_area,
 				       struct mda_header *mdah, int primary_mda,
 				       const char *vgname,
 				       int *precommitted)
@@ -369,7 +370,7 @@ static struct raw_locn *_read_metadata_location_vg(struct device_area *dev_area,
 		  vgnamebuf, vgname);
 
 	if ((info = lvmcache_info_from_pvid(dev_area->dev->pvid, dev_area->dev, 0)) &&
-	    !lvmcache_update_vgname_and_id(info, &vgsummary_orphan))
+	    !lvmcache_update_vgname_and_id(cmd, info, &vgsummary_orphan))
 		stack;
 
 	return NULL;
@@ -447,7 +448,8 @@ static uint64_t _next_rlocn_offset(struct volume_group *vg, struct raw_locn *rlo
 	return new_start;
 }
 
-static struct volume_group *_vg_read_raw_area(struct format_instance *fid,
+static struct volume_group *_vg_read_raw_area(struct cmd_context *cmd,
+					      struct format_instance *fid,
 					      const char *vgname,
 					      struct device_area *area,
 					      struct cached_vg_fmtdata **vg_fmtdata,
@@ -468,7 +470,7 @@ static struct volume_group *_vg_read_raw_area(struct format_instance *fid,
 		goto out;
 	}
 
-	if (!(rlocn = _read_metadata_location_vg(area, mdah, primary_mda, vgname, &precommitted))) {
+	if (!(rlocn = _read_metadata_location_vg(cmd, area, mdah, primary_mda, vgname, &precommitted))) {
 		log_debug_metadata("VG %s not found on %s", vgname, dev_name(area->dev));
 		goto out;
 	}
@@ -503,7 +505,8 @@ static struct volume_group *_vg_read_raw_area(struct format_instance *fid,
 	return vg;
 }
 
-static struct volume_group *_vg_read_raw(struct format_instance *fid,
+static struct volume_group *_vg_read_raw(struct cmd_context *cmd,
+					 struct format_instance *fid,
 					 const char *vgname,
 					 struct metadata_area *mda,
 					 struct cached_vg_fmtdata **vg_fmtdata,
@@ -512,12 +515,13 @@ static struct volume_group *_vg_read_raw(struct format_instance *fid,
 	struct mda_context *mdac = (struct mda_context *) mda->metadata_locn;
 	struct volume_group *vg;
 
-	vg = _vg_read_raw_area(fid, vgname, &mdac->area, vg_fmtdata, use_previous_vg, 0, mda_is_primary(mda));
+	vg = _vg_read_raw_area(cmd, fid, vgname, &mdac->area, vg_fmtdata, use_previous_vg, 0, mda_is_primary(mda));
 
 	return vg;
 }
 
-static struct volume_group *_vg_read_precommit_raw(struct format_instance *fid,
+static struct volume_group *_vg_read_precommit_raw(struct cmd_context *cmd,
+						   struct format_instance *fid,
 						   const char *vgname,
 						   struct metadata_area *mda,
 						   struct cached_vg_fmtdata **vg_fmtdata,
@@ -526,7 +530,7 @@ static struct volume_group *_vg_read_precommit_raw(struct format_instance *fid,
 	struct mda_context *mdac = (struct mda_context *) mda->metadata_locn;
 	struct volume_group *vg;
 
-	vg = _vg_read_raw_area(fid, vgname, &mdac->area, vg_fmtdata, use_previous_vg, 1, mda_is_primary(mda));
+	vg = _vg_read_raw_area(cmd, fid, vgname, &mdac->area, vg_fmtdata, use_previous_vg, 1, mda_is_primary(mda));
 
 	return vg;
 }
@@ -1321,7 +1325,7 @@ static struct volume_group *_vg_read_file_name(struct format_instance *fid,
 	return vg;
 }
 
-static struct volume_group *_vg_read_file(struct format_instance *fid,
+static struct volume_group *_vg_read_file(struct cmd_context *cmd, struct format_instance *fid,
 					  const char *vgname,
 					  struct metadata_area *mda,
 					  struct cached_vg_fmtdata **vg_fmtdata,
@@ -1332,7 +1336,7 @@ static struct volume_group *_vg_read_file(struct format_instance *fid,
 	return _vg_read_file_name(fid, vgname, tc->path_live);
 }
 
-static struct volume_group *_vg_read_precommit_file(struct format_instance *fid,
+static struct volume_group *_vg_read_precommit_file(struct cmd_context *cmd, struct format_instance *fid,
 						    const char *vgname,
 						    struct metadata_area *mda,
 						    struct cached_vg_fmtdata **vg_fmtdata,
@@ -1713,7 +1717,7 @@ static int _set_ext_flags(struct physical_volume *pv, struct lvmcache_info *info
 }
 
 /* Only for orphans - FIXME That's not true any more */
-static int _text_pv_write(const struct format_type *fmt, struct physical_volume *pv)
+static int _text_pv_write(struct cmd_context *cmd, const struct format_type *fmt, struct physical_volume *pv)
 {
 	struct format_instance *fid = pv->fid;
 	const char *pvid = (const char *) (*pv->old_id.uuid ? &pv->old_id : &pv->id);
@@ -1725,7 +1729,7 @@ static int _text_pv_write(const struct format_type *fmt, struct physical_volume
 	unsigned mda_index;
 
 	/* Add a new cache entry with PV info or update existing one. */
-	if (!(info = lvmcache_add(fmt->labeller, (const char *) &pv->id,
+	if (!(info = lvmcache_add(cmd, fmt->labeller, (const char *) &pv->id,
 				  pv->dev,  pv->label_sector, pv->vg_name,
 				  is_orphan_vg(pv->vg_name) ? pv->vg_name : pv->vg ? (const char *) &pv->vg->id : NULL, 0, NULL)))
 		return_0;
diff --git a/lib/format_text/text_label.c b/lib/format_text/text_label.c
index 9241ecac6..1674126c8 100644
--- a/lib/format_text/text_label.c
+++ b/lib/format_text/text_label.c
@@ -370,7 +370,7 @@ static int _read_mda_header_and_metadata(const struct format_type *fmt,
  * the metadata is at for those PVs.
  */
 
-static int _text_read(struct labeller *labeller, struct device *dev, void *label_buf,
+static int _text_read(struct cmd_context *cmd, struct labeller *labeller, struct device *dev, void *label_buf,
 		      uint64_t label_sector, int *is_duplicate)
 {
 	struct lvmcache_vgsummary vgsummary;
@@ -410,7 +410,7 @@ static int _text_read(struct labeller *labeller, struct device *dev, void *label
 	 *
 	 * Other reasons for lvmcache_add to return NULL are internal errors.
 	 */
-	if (!(info = lvmcache_add(labeller, (char *)pvhdr->pv_uuid, dev, label_sector,
+	if (!(info = lvmcache_add(cmd, labeller, (char *)pvhdr->pv_uuid, dev, label_sector,
 				  FMT_TEXT_ORPHAN_VG_NAME,
 				  FMT_TEXT_ORPHAN_VG_NAME, 0, is_duplicate)))
 		return_0;
@@ -503,7 +503,7 @@ static int _text_read(struct labeller *labeller, struct device *dev, void *label
 		rv1 = _read_mda_header_and_metadata(fmt, mda1, &vgsummary, &bad_fields);
 
 		if (rv1 && !vgsummary.zero_offset && !vgsummary.mda_ignored) {
-			if (!lvmcache_update_vgname_and_id(info, &vgsummary)) {
+			if (!lvmcache_update_vgname_and_id(cmd, info, &vgsummary)) {
 				/* I believe this is only an internal error. */
 
 				dm_list_del(&mda1->list);
@@ -554,7 +554,7 @@ static int _text_read(struct labeller *labeller, struct device *dev, void *label
 		rv2 = _read_mda_header_and_metadata(fmt, mda2, &vgsummary, &bad_fields);
 
 		if (rv2 && !vgsummary.zero_offset && !vgsummary.mda_ignored) {
-			if (!lvmcache_update_vgname_and_id(info, &vgsummary)) {
+			if (!lvmcache_update_vgname_and_id(cmd, info, &vgsummary)) {
 				dm_list_del(&mda2->list);
 
 				/* Are there other cases besides mismatch and internal error? */
diff --git a/lib/label/label.c b/lib/label/label.c
index 045831383..4d37ceff6 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -431,7 +431,7 @@ static int _process_block(struct cmd_context *cmd, struct dev_filter *f,
 	 * info/vginfo structs.  That lvmcache info is used later when the
 	 * command wants to read the VG to do something to it.
 	 */
-	ret = labeller->ops->read(labeller, dev, label_buf, sector, &is_duplicate);
+	ret = labeller->ops->read(cmd, labeller, dev, label_buf, sector, &is_duplicate);
 
 	if (!ret) {
 		if (is_duplicate) {
diff --git a/lib/label/label.h b/lib/label/label.h
index 410890621..9a4b630bb 100644
--- a/lib/label/label.h
+++ b/lib/label/label.h
@@ -64,7 +64,7 @@ struct label_ops {
 	/*
 	 * Read a label from a volume.
 	 */
-	int (*read) (struct labeller * l, struct device * dev,
+	int (*read) (struct cmd_context *cmd, struct labeller * l, struct device * dev,
 		     void *label_buf, uint64_t label_sector, int *is_duplicate);
 
 	/*
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 9c443882c..6c40cd321 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3666,7 +3666,7 @@ int pv_write(struct cmd_context *cmd,
 		return 0;
 	}
 
-	if (!pv->fmt->ops->pv_write(pv->fmt, pv))
+	if (!pv->fmt->ops->pv_write(cmd, pv->fmt, pv))
 		return_0;
 
 	pv->status &= ~UNLABELLED_PV;
@@ -4841,7 +4841,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 			log_debug_metadata("Reading VG %s precommit metadata from %s %llu",
 				 vgname, dev_name(mda_dev), (unsigned long long)mda->header_start);
 
-			vg = mda->ops->vg_read_precommit(fid, vgname, mda, &vg_fmtdata, &use_previous_vg);
+			vg = mda->ops->vg_read_precommit(cmd, fid, vgname, mda, &vg_fmtdata, &use_previous_vg);
 
 			if (!vg && !use_previous_vg) {
 				log_warn("WARNING: Reading VG %s precommit on %s failed.", vgname, dev_name(mda_dev));
@@ -4852,7 +4852,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 			log_debug_metadata("Reading VG %s metadata from %s %llu",
 				 vgname, dev_name(mda_dev), (unsigned long long)mda->header_start);
 
-			vg = mda->ops->vg_read(fid, vgname, mda, &vg_fmtdata, &use_previous_vg);
+			vg = mda->ops->vg_read(cmd, fid, vgname, mda, &vg_fmtdata, &use_previous_vg);
 
 			if (!vg && !use_previous_vg) {
 				log_warn("WARNING: Reading VG %s on %s failed.", vgname, dev_name(mda_dev));
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index f199fc4f5..2c224505a 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -76,12 +76,14 @@ struct cached_vg_fmtdata;
 /* Per-format per-metadata area operations */
 struct metadata_area_ops {
 	struct dm_list list;
-	struct volume_group *(*vg_read) (struct format_instance * fi,
+	struct volume_group *(*vg_read) (struct cmd_context *cmd,
+					 struct format_instance * fi,
 					 const char *vg_name,
 					 struct metadata_area * mda,
 					 struct cached_vg_fmtdata **vg_fmtdata,
 					 unsigned *use_previous_vg);
-	struct volume_group *(*vg_read_precommit) (struct format_instance * fi,
+	struct volume_group *(*vg_read_precommit) (struct cmd_context *cmd,
+					 struct format_instance * fi,
 					 const char *vg_name,
 					 struct metadata_area * mda,
 					 struct cached_vg_fmtdata **vg_fmtdata,
@@ -326,7 +328,7 @@ struct format_handler {
 	 * Write a PV structure to disk. Fails if the PV is in a VG ie
 	 * pv->vg_name must be a valid orphan VG name
 	 */
-	int (*pv_write) (const struct format_type * fmt,
+	int (*pv_write) (struct cmd_context *cmd, const struct format_type * fmt,
 			 struct physical_volume * pv);
 
 	/*
diff --git a/tools/pvscan.c b/tools/pvscan.c
index 1bf543c1e..4d811da55 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -582,7 +582,7 @@ static int _online_pvscan_single(struct metadata_area *mda, void *baton)
 
 	if (mda_is_ignored(mda))
 		return 1;
-	vg = mda->ops->vg_read(b->fid, "", mda, NULL, NULL);
+	vg = mda->ops->vg_read(b->cmd, b->fid, "", mda, NULL, NULL);
 	if (!vg) {
 		/*
 		 * Many or most cases of bad metadata would be found in



