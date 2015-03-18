From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed, 18 Mar 2015 23:58:21 +0000 (UTC)
Subject: master - cache: Store metadata size and checksum.
Message-ID: <20150318235821.2612860535@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6407d184d1d4ce491035fe4d9e3ebbe6aefaa394
Commit:        6407d184d1d4ce491035fe4d9e3ebbe6aefaa394
Parent:        19c3851d9cd251bdb7eccd47385dd37818161bf7
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Mar 18 23:43:02 2015 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Mar 18 23:43:02 2015 +0000

cache: Store metadata size and checksum.

Refactor the recent metadata-reading optimisation patches.

Remove the recently-added cache fields from struct labeller
and struct format_instance.

Instead, introduce struct lvmcache_vgsummary to wrap the VG information
that lvmcache holds and add the metadata size and checksum to it.

Allow this VG summary information to be looked up by metadata size +
checksum.  Adjust the debug log messages to make it clear when this
shortcut has been successful.

(This changes the optimisation slightly, and might be extendable
further.)

Add struct cached_vg_fmtdata to format-specific vg_read calls to
preserve state alongside the VG across separate calls and indicate
if the details supplied match, avoiding the need to read and
process the VG metadata again.
---
 WHATS_NEW                        |    3 +-
 lib/cache/lvmcache.c             |   78 ++++++++++++++++++++---
 lib/cache/lvmcache.h             |   13 +++-
 lib/cache/lvmetad.c              |    4 +-
 lib/config/config.c              |    6 +-
 lib/format1/format1.c            |    2 +
 lib/format_pool/format_pool.c    |    2 +
 lib/format_text/archiver.c       |    2 +-
 lib/format_text/format-text.c    |  127 ++++++++++++++++++++------------------
 lib/format_text/import-export.h  |   26 ++++----
 lib/format_text/import.c         |   76 ++++++++++++++---------
 lib/format_text/import_vsn1.c    |   23 +++----
 lib/format_text/layout.h         |   12 +---
 lib/format_text/text_label.c     |   12 +---
 lib/label/label.c                |   24 ++++---
 lib/label/label.h                |    8 ---
 lib/metadata/metadata-exported.h |    5 --
 lib/metadata/metadata.c          |   39 +++++++++---
 lib/metadata/metadata.h          |    7 ++-
 19 files changed, 288 insertions(+), 181 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index b182925..c9242fe 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.118 - 
 =================================
+  Store metadata size + checksum in lvmcache and add struct lvmcache_vgsummary.
   Remove inaccessible clustered PVs from 'pvs -a'.
   Don't invalidate cached orphan information while global lock is held.
   Avoid rescan of all devices when requested pvscan for removed device.
@@ -9,7 +10,7 @@ Version 2.02.118 -
   Add After=iscsi-shutdown.service to blk-availability.service systemd unit.
   Disallow vgconvert from changing metadata format when lvmetad is used.
   Don't do a full read of VG when creating a new VG with an existing name.
-  Reduce number of VG metadata parsing when looking for vgname on a PV.
+  Reduce amount of VG metadata parsing when looking for vgname on a PV.
   Avoid reparsing same metadata when reading same metadata from multiple PVs.
   Save extra device open/close when scanning device for size.
   Fix seg_monitor field to report status also for mirrors and thick snapshots.
diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index b8096d7..2b4e2c6 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -56,6 +56,8 @@ struct lvmcache_vginfo {
 	char _padding[7];
 	struct lvmcache_vginfo *next; /* Another VG with same name? */
 	char *creation_host;
+	uint32_t mda_checksum;
+	size_t mda_size;
 	size_t vgmetadata_size;
 	char *vgmetadata;	/* Copy of VG metadata as format_text string */
 	struct dm_config_tree *cft; /* Config tree created from vgmetadata */
@@ -1406,6 +1408,26 @@ static int _lvmcache_update_vgstatus(struct lvmcache_info *info, uint32_t vgstat
 	return 1;
 }
 
+static int _lvmcache_update_vg_mda_info(struct lvmcache_info *info, uint32_t mda_checksum,
+					size_t mda_size)
+{
+	if (!info || !info->vginfo || !mda_size)
+		return 1;
+
+	if (info->vginfo->mda_checksum == mda_checksum || info->vginfo->mda_size == mda_size) 
+		return 1;
+
+	info->vginfo->mda_checksum = mda_checksum;
+	info->vginfo->mda_size = mda_size;
+
+	/* FIXME Add checksum index */
+
+	log_debug_cache("lvmcache: %s: VG %s: Stored metadata checksum %" PRIu32 " with size %" PRIsize_t ".",
+			dev_name(info->dev), info->vginfo->vgname, mda_checksum, mda_size);
+
+	return 1;
+}
+
 int lvmcache_add_orphan_vginfo(const char *vgname, struct format_type *fmt)
 {
 	if (!_lock_hash && !lvmcache_init()) {
@@ -1416,10 +1438,11 @@ int lvmcache_add_orphan_vginfo(const char *vgname, struct format_type *fmt)
 	return _lvmcache_update_vgname(NULL, vgname, vgname, 0, "", fmt);
 }
 
-int lvmcache_update_vgname_and_id(struct lvmcache_info *info,
-				  const char *vgname, const char *vgid,
-				  uint32_t vgstatus, const char *creation_host)
+int lvmcache_update_vgname_and_id(struct lvmcache_info *info, struct lvmcache_vgsummary *vgsummary)
 {
+	const char *vgname = vgsummary->vgname;
+	const char *vgid = (char *)&vgsummary->vgid;
+
 	if (!vgname && !info->vginfo) {
 		log_error(INTERNAL_ERROR "NULL vgname handed to cache");
 		/* FIXME Remove this */
@@ -1447,10 +1470,11 @@ int lvmcache_update_vgname_and_id(struct lvmcache_info *info,
 	if (!is_orphan_vg(vgname))
 		info->status &= ~CACHE_INVALID;
 
-	if (!_lvmcache_update_vgname(info, vgname, vgid, vgstatus,
-				     creation_host, info->fmt) ||
+	if (!_lvmcache_update_vgname(info, vgname, vgid, vgsummary->vgstatus,
+				     vgsummary->creation_host, info->fmt) ||
 	    !_lvmcache_update_vgid(info, info->vginfo, vgid) ||
-	    !_lvmcache_update_vgstatus(info, vgstatus, creation_host))
+	    !_lvmcache_update_vgstatus(info, vgsummary->vgstatus, vgsummary->creation_host) ||
+	    !_lvmcache_update_vg_mda_info(info, vgsummary->mda_checksum, vgsummary->mda_size))
 		return_0;
 
 	return 1;
@@ -1461,6 +1485,11 @@ int lvmcache_update_vg(struct volume_group *vg, unsigned precommitted)
 	struct pv_list *pvl;
 	struct lvmcache_info *info;
 	char pvid_s[ID_LEN + 1] __attribute__((aligned(8)));
+	struct lvmcache_vgsummary vgsummary = {
+		.vgname = vg->name,
+		.vgstatus = vg->status,
+		.vgid = vg->id
+	};
 
 	pvid_s[sizeof(pvid_s) - 1] = '\0';
 
@@ -1468,9 +1497,7 @@ int lvmcache_update_vg(struct volume_group *vg, unsigned precommitted)
 		strncpy(pvid_s, (char *) &pvl->pv->id, sizeof(pvid_s) - 1);
 		/* FIXME Could pvl->pv->dev->pvid ever be different? */
 		if ((info = lvmcache_info_from_pvid(pvid_s, 0)) &&
-		    !lvmcache_update_vgname_and_id(info, vg->name,
-						   (char *) &vg->id,
-						   vg->status, NULL))
+		    !lvmcache_update_vgname_and_id(info, &vgsummary))
 			return_0;
 	}
 
@@ -1512,6 +1539,13 @@ struct lvmcache_info *lvmcache_add(struct labeller *labeller, const char *pvid,
 	struct label *label;
 	struct lvmcache_info *existing, *info;
 	char pvid_s[ID_LEN + 1] __attribute__((aligned(8)));
+	struct lvmcache_vgsummary vgsummary = {
+		.vgname = vgname,
+		.vgstatus = vgstatus,
+	};
+
+	if (vgid)
+		strncpy((char *)&vgsummary.vgid, vgid, sizeof(vgsummary.vgid));
 
 	if (!_vgname_hash && !lvmcache_init()) {
 		log_error("Internal cache initialisation failed");
@@ -1610,7 +1644,7 @@ struct lvmcache_info *lvmcache_add(struct labeller *labeller, const char *pvid,
 		return NULL;
 	}
 
-	if (!lvmcache_update_vgname_and_id(info, vgname, vgid, vgstatus, NULL)) {
+	if (!lvmcache_update_vgname_and_id(info, &vgsummary)) {
 		if (!existing) {
 			dm_hash_remove(_pvid_hash, pvid_s);
 			strcpy(info->dev->pvid, "");
@@ -2019,3 +2053,27 @@ uint64_t lvmcache_smallest_mda_size(struct lvmcache_info *info)
 const struct format_type *lvmcache_fmt(struct lvmcache_info *info) {
 	return info->fmt;
 }
+
+int lvmcache_lookup_mda(struct lvmcache_vgsummary *vgsummary)
+{
+	struct lvmcache_vginfo *vginfo;
+
+	if (!vgsummary->mda_size)
+		return 0;
+
+	/* FIXME Index the checksums */
+	dm_list_iterate_items(vginfo, &_vginfos) {
+		if (vgsummary->mda_checksum == vginfo->mda_checksum &&
+		    vgsummary->mda_size == vginfo->mda_size &&
+		    !is_orphan_vg(vginfo->vgname)) {
+			vgsummary->vgname = vginfo->vgname;
+			vgsummary->creation_host = vginfo->creation_host;
+			vgsummary->vgstatus = vginfo->status;
+			memcpy((char *)&vgsummary->vgid, vginfo->vgid, sizeof(vginfo->vgid));
+
+			return 1;
+		}
+	}
+
+	return 0;
+}
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index 0a7d898..6c4c927 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -39,6 +39,15 @@ struct disk_locn;
 
 struct lvmcache_vginfo;
 
+struct lvmcache_vgsummary {
+	const char *vgname;
+	struct id vgid;
+	uint64_t vgstatus;
+	char *creation_host;
+	uint32_t mda_checksum;
+	size_t mda_size;
+};
+
 int lvmcache_init(void);
 void lvmcache_allow_reads_with_lvmetad(void);
 
@@ -58,8 +67,7 @@ void lvmcache_del(struct lvmcache_info *info);
 
 /* Update things */
 int lvmcache_update_vgname_and_id(struct lvmcache_info *info,
-				  const char *vgname, const char *vgid,
-				  uint32_t vgstatus, const char *hostname);
+				  struct lvmcache_vgsummary *vgsummary);
 int lvmcache_update_vg(struct volume_group *vg, unsigned precommitted);
 
 void lvmcache_lock_vgname(const char *vgname, int read_only);
@@ -68,6 +76,7 @@ int lvmcache_verify_lock_order(const char *vgname);
 
 /* Queries */
 const struct format_type *lvmcache_fmt_from_vgname(struct cmd_context *cmd, const char *vgname, const char *vgid, unsigned revalidate_labels);
+int lvmcache_lookup_mda(struct lvmcache_vgsummary *vgsummary);
 
 /* Decrement and test if there are still vg holders in vginfo. */
 int lvmcache_vginfo_holders_dec_and_test_for_zero(struct lvmcache_vginfo *vginfo);
diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index d878c17..7bb6701 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -897,7 +897,7 @@ static int _lvmetad_pvscan_single(struct metadata_area *mda, void *baton)
 	struct _lvmetad_pvscan_baton *b = baton;
 	struct volume_group *this;
 
-	this = mda_is_ignored(mda) ? NULL : mda->ops->vg_read(b->fid, "", mda, 1);
+	this = mda_is_ignored(mda) ? NULL : mda->ops->vg_read(b->fid, "", mda, NULL, NULL, 1);
 
 	/* FIXME Also ensure contents match etc. */
 	if (!b->vg || this->seqno > b->vg->seqno)
@@ -960,7 +960,7 @@ int lvmetad_pvscan_single(struct cmd_context *cmd, struct device *dev,
 	 * can scan further devices.
 	 */
 	if (!baton.vg && !(baton.fid->fmt->features & FMT_MDAS))
-		baton.vg = ((struct metadata_area *) dm_list_first(&baton.fid->metadata_areas_in_use))->ops->vg_read(baton.fid, lvmcache_vgname_from_info(info), NULL, 1);
+		baton.vg = ((struct metadata_area *) dm_list_first(&baton.fid->metadata_areas_in_use))->ops->vg_read(baton.fid, lvmcache_vgname_from_info(info), NULL, NULL, NULL, 1);
 
 	if (!baton.vg)
 		lvmcache_fmt(info)->ops->destroy_instance(baton.fid);
diff --git a/lib/config/config.c b/lib/config/config.c
index b635654..58eab51 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -482,14 +482,14 @@ int override_config_tree_from_profile(struct cmd_context *cmd,
 }
 
 /*
- * When skip_parse is set, the checksum of buffer is only matched
+ * When checksum_only is set, the checksum of buffer is only matched
  * and function avoids parsing of mda into config tree which
  * remains unmodified and should not be used.
  */
 int config_file_read_fd(struct dm_config_tree *cft, struct device *dev,
 			off_t offset, size_t size, off_t offset2, size_t size2,
 			checksum_fn_t checksum_fn, uint32_t checksum,
-			int skip_parse)
+			int checksum_only)
 {
 	char *fb, *fe;
 	int r = 0;
@@ -538,7 +538,7 @@ int config_file_read_fd(struct dm_config_tree *cft, struct device *dev,
 		goto out;
 	}
 
-	if (!skip_parse) {
+	if (!checksum_only) {
 		fe = fb + size + size2;
 		if (!dm_config_parse(cft, fb, fe))
 			goto_out;
diff --git a/lib/format1/format1.c b/lib/format1/format1.c
index 19df8aa..1b86ef5 100644
--- a/lib/format1/format1.c
+++ b/lib/format1/format1.c
@@ -180,6 +180,8 @@ out:
 static struct volume_group *_format1_vg_read(struct format_instance *fid,
 				     const char *vg_name,
 				     struct metadata_area *mda __attribute__((unused)),
+				     struct cached_vg_fmtdata **vg_fmtdata __attribute__((unused)),
+				     unsigned *use_previous_vg __attribute__((unused)),
 				     int single_device __attribute__((unused)))
 {
 	struct volume_group *vg;
diff --git a/lib/format_pool/format_pool.c b/lib/format_pool/format_pool.c
index 503005a..2a8819d 100644
--- a/lib/format_pool/format_pool.c
+++ b/lib/format_pool/format_pool.c
@@ -101,6 +101,8 @@ static int _check_usp(const char *vgname, struct user_subpool *usp, int sp_count
 static struct volume_group *_pool_vg_read(struct format_instance *fid,
 					  const char *vg_name,
 					  struct metadata_area *mda __attribute__((unused)),
+					  struct cached_vg_fmtdata **vg_fmtdata __attribute__((unused)),
+					  unsigned *use_previous_vg __attribute__((unused)),
 					  int single_device __attribute__((unused)))
 {
 	struct volume_group *vg;
diff --git a/lib/format_text/archiver.c b/lib/format_text/archiver.c
index a2f40f2..e3d3d57 100644
--- a/lib/format_text/archiver.c
+++ b/lib/format_text/archiver.c
@@ -308,7 +308,7 @@ struct volume_group *backup_read_vg(struct cmd_context *cmd,
 	}
 
 	dm_list_iterate_items(mda, &tf->metadata_areas_in_use) {
-		if (!(vg = mda->ops->vg_read(tf, vg_name, mda, 0)))
+		if (!(vg = mda->ops->vg_read(tf, vg_name, mda, NULL, NULL, 0)))
 			stack;
 		break;
 	}
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index d80ebf6..6b09d00 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -412,6 +412,11 @@ static struct raw_locn *_find_vg_rlocn(struct device_area *dev_area,
 	char vgnamebuf[NAME_LEN + 2] __attribute__((aligned(8)));
 	struct raw_locn *rlocn, *rlocn_precommitted;
 	struct lvmcache_info *info;
+	struct lvmcache_vgsummary vgsummary_orphan = {
+		.vgname = FMT_TEXT_ORPHAN_VG_NAME,
+	};
+
+	memcpy(&vgsummary_orphan.vgid, FMT_TEXT_ORPHAN_VG_NAME, sizeof(FMT_TEXT_ORPHAN_VG_NAME));
 
 	rlocn = mdah->raw_locns;	/* Slot 0 */
 	rlocn_precommitted = rlocn + 1;	/* Slot 1 */
@@ -449,8 +454,7 @@ static struct raw_locn *_find_vg_rlocn(struct device_area *dev_area,
 
       bad:
 	if ((info = lvmcache_info_from_pvid(dev_area->dev->pvid, 0)))
-		lvmcache_update_vgname_and_id(info, FMT_TEXT_ORPHAN_VG_NAME,
-					      FMT_TEXT_ORPHAN_VG_NAME, 0, NULL);
+		lvmcache_update_vgname_and_id(info, &vgsummary_orphan);
 
 	return NULL;
 }
@@ -498,6 +502,8 @@ static int _raw_holds_vgname(struct format_instance *fid,
 static struct volume_group *_vg_read_raw_area(struct format_instance *fid,
 					      const char *vgname,
 					      struct device_area *area,
+					      struct cached_vg_fmtdata **vg_fmtdata,
+					      unsigned *use_previous_vg,
 					      int precommitted,
 					      int single_device)
 {
@@ -526,17 +532,24 @@ static struct volume_group *_vg_read_raw_area(struct format_instance *fid,
 	}
 
 	/* FIXME 64-bit */
-	if (!(vg = text_vg_import_fd(fid, NULL, single_device, area->dev, 
+	if (!(vg = text_vg_import_fd(fid, NULL, vg_fmtdata, use_previous_vg, single_device, area->dev, 
 				     (off_t) (area->start + rlocn->offset),
 				     (uint32_t) (rlocn->size - wrap),
 				     (off_t) (area->start + MDA_HEADER_SIZE),
 				     wrap, calc_crc, rlocn->checksum, &when,
-				     &desc)))
+				     &desc)) && (!use_previous_vg || !*use_previous_vg))
 		goto_out;
-	log_debug_metadata("Read %s %smetadata (%u) from %s at %" PRIu64 " size %"
-			   PRIu64, vg->name, precommitted ? "pre-commit " : "",
-			   vg->seqno, dev_name(area->dev),
-			   area->start + rlocn->offset, rlocn->size);
+
+	if (vg)
+		log_debug_metadata("Read %s %smetadata (%u) from %s at %" PRIu64 " size %"
+				   PRIu64, vg->name, precommitted ? "pre-commit " : "",
+				   vg->seqno, dev_name(area->dev),
+				   area->start + rlocn->offset, rlocn->size);
+	else
+		log_debug_metadata("Skipped reading %smetadata from %s at %" PRIu64 " size %"
+				   PRIu64 " with matching checksum.", precommitted ? "pre-commit " : "",
+				   dev_name(area->dev),
+				   area->start + rlocn->offset, rlocn->size);
 
 	if (precommitted)
 		vg->status |= PRECOMMITTED;
@@ -548,6 +561,8 @@ static struct volume_group *_vg_read_raw_area(struct format_instance *fid,
 static struct volume_group *_vg_read_raw(struct format_instance *fid,
 					 const char *vgname,
 					 struct metadata_area *mda,
+					 struct cached_vg_fmtdata **vg_fmtdata,
+					 unsigned *use_previous_vg,
 					 int single_device)
 {
 	struct mda_context *mdac = (struct mda_context *) mda->metadata_locn;
@@ -556,7 +571,7 @@ static struct volume_group *_vg_read_raw(struct format_instance *fid,
 	if (!dev_open_readonly(mdac->area.dev))
 		return_NULL;
 
-	vg = _vg_read_raw_area(fid, vgname, &mdac->area, 0, single_device);
+	vg = _vg_read_raw_area(fid, vgname, &mdac->area, vg_fmtdata, use_previous_vg, 0, single_device);
 
 	if (!dev_close(mdac->area.dev))
 		stack;
@@ -566,7 +581,9 @@ static struct volume_group *_vg_read_raw(struct format_instance *fid,
 
 static struct volume_group *_vg_read_precommit_raw(struct format_instance *fid,
 						   const char *vgname,
-						   struct metadata_area *mda)
+						   struct metadata_area *mda,
+						   struct cached_vg_fmtdata **vg_fmtdata,
+						   unsigned *use_previous_vg)
 {
 	struct mda_context *mdac = (struct mda_context *) mda->metadata_locn;
 	struct volume_group *vg;
@@ -574,7 +591,7 @@ static struct volume_group *_vg_read_precommit_raw(struct format_instance *fid,
 	if (!dev_open_readonly(mdac->area.dev))
 		return_NULL;
 
-	vg = _vg_read_raw_area(fid, vgname, &mdac->area, 1, 0);
+	vg = _vg_read_raw_area(fid, vgname, &mdac->area, vg_fmtdata, use_previous_vg, 1, 0);
 
 	if (!dev_close(mdac->area.dev))
 		stack;
@@ -885,6 +902,8 @@ static struct volume_group *_vg_read_file_name(struct format_instance *fid,
 static struct volume_group *_vg_read_file(struct format_instance *fid,
 					  const char *vgname,
 					  struct metadata_area *mda,
+					  struct cached_vg_fmtdata **vg_fmtdata,
+					  unsigned *use_previous_vg __attribute__((unused)),
 					  int single_device __attribute__((unused)))
 {
 	struct text_context *tc = (struct text_context *) mda->metadata_locn;
@@ -894,7 +913,9 @@ static struct volume_group *_vg_read_file(struct format_instance *fid,
 
 static struct volume_group *_vg_read_precommit_file(struct format_instance *fid,
 						    const char *vgname,
-						    struct metadata_area *mda)
+						    struct metadata_area *mda,
+						    struct cached_vg_fmtdata **vg_fmtdata,
+						    unsigned *use_previous_vg __attribute__((unused)))
 {
 	struct text_context *tc = (struct text_context *) mda->metadata_locn;
 	struct volume_group *vg;
@@ -1123,12 +1144,9 @@ static int _scan_file(const struct format_type *fmt, const char *vgname)
 	return 1;
 }
 
-const char *vgname_from_mda(const struct format_type *fmt,
-			    struct mda_header *mdah, struct device_area *dev_area,
-			    uint32_t *mda_checksum, size_t *mda_size,
-			    const char *vgname, struct id *vgid,
-			    uint64_t *vgstatus, char **creation_host,
-			    uint64_t *mda_free_sectors)
+int vgname_from_mda(const struct format_type *fmt,
+		    struct mda_header *mdah, struct device_area *dev_area,
+		    struct lvmcache_vgsummary *vgsummary, uint64_t *mda_free_sectors)
 {
 	struct raw_locn *rlocn;
 	uint32_t wrap = 0;
@@ -1136,13 +1154,14 @@ const char *vgname_from_mda(const struct format_type *fmt,
 	char buf[NAME_LEN + 1] __attribute__((aligned(8)));
 	char uuid[64] __attribute__((aligned(8)));
 	uint64_t buffer_size, current_usage;
+	unsigned used_cached_metadata = 0;
 
 	if (mda_free_sectors)
 		*mda_free_sectors = ((dev_area->size - MDA_HEADER_SIZE) / 2) >> SECTOR_SHIFT;
 
 	if (!mdah) {
 		log_error(INTERNAL_ERROR "vgname_from_mda called with NULL pointer for mda_header");
-		return NULL;
+		return 0;
 	}
 
 	/* FIXME Cope with returning a list */
@@ -1154,13 +1173,13 @@ const char *vgname_from_mda(const struct format_type *fmt,
 	if (!rlocn->offset) {
 		log_debug("%s: found metadata with offset 0.",
 			  dev_name(dev_area->dev));
-		return NULL;
+		return 0;
 	}
 
 	/* Do quick check for a vgname */
 	if (!dev_read(dev_area->dev, dev_area->start + rlocn->offset,
 		      NAME_LEN, buf))
-		return_NULL;
+		return_0;
 
 	while (buf[len] && !isspace(buf[len]) && buf[len] != '{' &&
 	       len < (NAME_LEN - 1))
@@ -1170,7 +1189,7 @@ const char *vgname_from_mda(const struct format_type *fmt,
 
 	/* Ignore this entry if the characters aren't permissible */
 	if (!validate_name(buf))
-		return_NULL;
+		return_0;
 
 	/* We found a VG - now check the metadata */
 	if (rlocn->offset + rlocn->size > mdah->size)
@@ -1179,37 +1198,39 @@ const char *vgname_from_mda(const struct format_type *fmt,
 	if (wrap > rlocn->offset) {
 		log_error("%s: metadata too large for circular buffer",
 			  dev_name(dev_area->dev));
-		return NULL;
+		return 0;
 	}
 
-	/* Check if it could be the same VG */
-	if ((rlocn->checksum != *mda_checksum) || (rlocn->size != *mda_size))
-		vgname = NULL; /* nope, reset to NULL */
+	/* Did we see this metadata before? */
+	vgsummary->mda_checksum = rlocn->checksum;
+	vgsummary->mda_size = rlocn->size;
+
+	if (lvmcache_lookup_mda(vgsummary))
+		used_cached_metadata = 1;
 
 	/* FIXME 64-bit */
-	if (!(vgname = text_vgname_import(fmt, dev_area->dev,
-					  (off_t) (dev_area->start +
-						   rlocn->offset),
-					  (uint32_t) (rlocn->size - wrap),
-					  (off_t) (dev_area->start +
-						   MDA_HEADER_SIZE),
-					  wrap, calc_crc, rlocn->checksum,
-					  vgname,
-					  vgid, vgstatus, creation_host)))
-		return_NULL;
+	if (!text_vgname_import(fmt, dev_area->dev,
+				(off_t) (dev_area->start + rlocn->offset),
+				(uint32_t) (rlocn->size - wrap),
+				(off_t) (dev_area->start + MDA_HEADER_SIZE),
+				wrap, calc_crc, vgsummary->vgname ? 1 : 0,
+				vgsummary))
+		return_0;
 
 	/* Ignore this entry if the characters aren't permissible */
-	if (!validate_name(vgname))
-		return_NULL;
+	if (!validate_name(vgsummary->vgname))
+		return_0;
 
-	if (!id_write_format(vgid, uuid, sizeof(uuid)))
-		return_NULL;
+	if (!id_write_format((struct id *)&vgsummary->vgid, uuid, sizeof(uuid)))
+		return_0;
 
-	log_debug_metadata("%s: Found metadata at %" PRIu64 " size %" PRIu64
+	log_debug_metadata("%s: %s metadata at %" PRIu64 " size %" PRIu64
 			   " (in area at %" PRIu64 " size %" PRIu64
 			   ") for %s (%s)",
-			   dev_name(dev_area->dev), dev_area->start + rlocn->offset,
-			   rlocn->size, dev_area->start, dev_area->size, vgname, uuid);
+			   dev_name(dev_area->dev),
+			   used_cached_metadata ? "Using cached" : "Found",
+			   dev_area->start + rlocn->offset,
+			   rlocn->size, dev_area->start, dev_area->size, vgsummary->vgname, uuid);
 
 	if (mda_free_sectors) {
 		current_usage = (rlocn->size + SECTOR_SIZE - UINT64_C(1)) -
@@ -1222,24 +1243,17 @@ const char *vgname_from_mda(const struct format_type *fmt,
 			*mda_free_sectors = ((buffer_size - 2 * current_usage) / 2) >> SECTOR_SHIFT;
 	}
 
-	*mda_checksum = rlocn->checksum;
-	*mda_size = rlocn->size;
-
-	return vgname;
+	return 1;
 }
 
 static int _scan_raw(const struct format_type *fmt, const char *vgname __attribute__((unused)))
 {
 	struct raw_list *rl;
 	struct dm_list *raw_list;
-	const char *scanned_vgname;
 	struct volume_group *vg;
 	struct format_instance fid;
-	struct id vgid;
-	uint64_t vgstatus;
+	struct lvmcache_vgsummary vgsummary = { 0 };
 	struct mda_header *mdah;
-	uint32_t mda_checksum = 0;
-	size_t mda_size = 0;
 
 	raw_list = &((struct mda_lists *) fmt->private)->raws;
 
@@ -1260,15 +1274,10 @@ static int _scan_raw(const struct format_type *fmt, const char *vgname __attribu
 		}
 
 		/* TODO: caching as in vgname_from_mda() (trigger this code?) */
-		if ((scanned_vgname = vgname_from_mda(fmt, mdah,
-						      &rl->dev_area,
-						      &mda_checksum, &mda_size, NULL,
-						      &vgid, &vgstatus,
-						      NULL, NULL))) {
-			vg = _vg_read_raw_area(&fid, scanned_vgname, &rl->dev_area, 0, 0);
+		if (vgname_from_mda(fmt, mdah, &rl->dev_area, &vgsummary, NULL)) {
+			vg = _vg_read_raw_area(&fid, vgsummary.vgname, &rl->dev_area, NULL, NULL, 0, 0);
 			if (vg)
 				lvmcache_update_vg(vg, 0);
-
 		}
 	close_dev:
 		if (!dev_close(rl->dev_area.dev))
diff --git a/lib/format_text/import-export.h b/lib/format_text/import-export.h
index 4b2756d..1ee647b 100644
--- a/lib/format_text/import-export.h
+++ b/lib/format_text/import-export.h
@@ -18,6 +18,7 @@
 
 #include "config.h"
 #include "metadata.h"
+#include "lvmcache.h"
 
 #include <stdio.h>
 
@@ -49,10 +50,9 @@ struct text_vg_version_ops {
 					 unsigned use_cached_pvs);
 	void (*read_desc) (struct dm_pool * mem, const struct dm_config_tree *cf,
 			   time_t *when, char **desc);
-	const char *(*read_vgname) (const struct format_type *fmt,
-				    const struct dm_config_tree *cft,
-				    struct id *vgid, uint64_t *vgstatus,
-				    char **creation_host);
+	int (*read_vgname) (const struct format_type *fmt,
+			    const struct dm_config_tree *cft,
+			    struct lvmcache_vgsummary *vgsummary);
 };
 
 struct text_vg_version_ops *text_vg_vsn1_init(void);
@@ -70,6 +70,8 @@ struct volume_group *text_vg_import_file(struct format_instance *fid,
 					 time_t *when, char **desc);
 struct volume_group *text_vg_import_fd(struct format_instance *fid,
 				       const char *file,
+				       struct cached_vg_fmtdata **vg_fmtdata,
+				       unsigned *use_previous_vg,
 				       int single_device,
 				       struct device *dev,
 				       off_t offset, uint32_t size,
@@ -77,13 +79,13 @@ struct volume_group *text_vg_import_fd(struct format_instance *fid,
 				       checksum_fn_t checksum_fn,
 				       uint32_t checksum,
 				       time_t *when, char **desc);
-const char *text_vgname_import(const struct format_type *fmt,
-			       struct device *dev,
-			       off_t offset, uint32_t size,
-			       off_t offset2, uint32_t size2,
-			       checksum_fn_t checksum_fn, uint32_t checksum,
-			       const char *vgname,
-			       struct id *vgid, uint64_t *vgstatus,
-			       char **creation_host);
+
+int text_vgname_import(const struct format_type *fmt,
+		       struct device *dev,
+		       off_t offset, uint32_t size,
+		       off_t offset2, uint32_t size2,
+		       checksum_fn_t checksum_fn,
+		       int checksum_only,
+		       struct lvmcache_vgsummary *vgsummary);
 
 #endif
diff --git a/lib/format_text/import.c b/lib/format_text/import.c
index c8ba5ce..84230cb 100644
--- a/lib/format_text/import.c
+++ b/lib/format_text/import.c
@@ -34,36 +34,38 @@ static void _init_text_import(void)
 
 /*
  * Find out vgname on a given device.
- * If the checksum and metadata size is matching the vgname discovered in last read
- * (multi PVs VG) could be passed back and it may skip parsing of such metadata.
  */
-const char *text_vgname_import(const struct format_type *fmt,
-			       struct device *dev,
-			       off_t offset, uint32_t size,
-			       off_t offset2, uint32_t size2,
-			       checksum_fn_t checksum_fn, uint32_t checksum,
-			       const char *vgname,
-			       struct id *vgid, uint64_t *vgstatus,
-			       char **creation_host)
+int text_vgname_import(const struct format_type *fmt,
+		       struct device *dev,
+		       off_t offset, uint32_t size,
+		       off_t offset2, uint32_t size2,
+		       checksum_fn_t checksum_fn,
+		       int checksum_only,
+		       struct lvmcache_vgsummary *vgsummary)
 {
 	struct dm_config_tree *cft;
 	struct text_vg_version_ops **vsn;
+	int r = 0;
 
 	_init_text_import();
 
 	if (!(cft = config_open(CONFIG_FILE_SPECIAL, NULL, 0)))
-		return_NULL;
+		return_0;
 
 	if ((!dev && !config_file_read(cft)) ||
 	    (dev && !config_file_read_fd(cft, dev, offset, size,
-					 offset2, size2, checksum_fn, checksum,
-					 (vgname != NULL)))) {
+					 offset2, size2, checksum_fn,
+					 vgsummary->mda_checksum,
+					 checksum_only))) {
 		log_error("Couldn't read volume group metadata.");
 		goto out;
 	}
 
-	if (vgname)
-		goto out; /* Everything is matching from the last call */
+	if (checksum_only) {
+		/* Checksum matches already-cached content - no need to reparse. */
+		r = 1;
+		goto out;
+	}
 
 	/*
 	 * Find a set of version functions that can read this file
@@ -72,20 +74,27 @@ const char *text_vgname_import(const struct format_type *fmt,
 		if (!(*vsn)->check_version(cft))
 			continue;
 
-		if (!(vgname = (*vsn)->read_vgname(fmt, cft, vgid, vgstatus,
-						   creation_host)))
+		if (!(*vsn)->read_vgname(fmt, cft, vgsummary))
 			goto_out;
 
+		r = 1;
 		break;
 	}
 
       out:
 	config_destroy(cft);
-	return vgname;
+	return r;
 }
 
+struct cached_vg_fmtdata {
+        uint32_t cached_mda_checksum;
+        size_t cached_mda_size;
+};
+
 struct volume_group *text_vg_import_fd(struct format_instance *fid,
 				       const char *file,
+				       struct cached_vg_fmtdata **vg_fmtdata,
+				       unsigned *use_previous_vg,
 				       int single_device,
 				       struct device *dev,
 				       off_t offset, uint32_t size,
@@ -99,6 +108,12 @@ struct volume_group *text_vg_import_fd(struct format_instance *fid,
 	struct text_vg_version_ops **vsn;
 	int skip_parse;
 
+	if (vg_fmtdata && !*vg_fmtdata &&
+	    !(*vg_fmtdata = dm_pool_zalloc(fid->mem, sizeof(**vg_fmtdata)))) {
+		log_error("Failed to allocate VG fmtdata for text format.");
+		return NULL;
+	}
+
 	_init_text_import();
 
 	*desc = NULL;
@@ -107,8 +122,10 @@ struct volume_group *text_vg_import_fd(struct format_instance *fid,
 	if (!(cft = config_open(CONFIG_FILE_SPECIAL, file, 0)))
 		return_NULL;
 
-	skip_parse = fid->vg && (fid->mda_checksum == checksum) &&
-		(fid->mda_size == (size + size2));
+	/* Does the metadata match the already-cached VG? */
+	skip_parse = vg_fmtdata && 
+		     ((*vg_fmtdata)->cached_mda_checksum == checksum) &&
+		     ((*vg_fmtdata)->cached_mda_size == (size + size2));
 
 	if ((!dev && !config_file_read(cft)) ||
 	    (dev && !config_file_read_fd(cft, dev, offset, size,
@@ -117,7 +134,8 @@ struct volume_group *text_vg_import_fd(struct format_instance *fid,
 		goto_out;
 
 	if (skip_parse) {
-		vg = fid->vg;
+		if (use_previous_vg)
+			*use_previous_vg = 1;
 		goto out;
 	}
 
@@ -135,16 +153,14 @@ struct volume_group *text_vg_import_fd(struct format_instance *fid,
 		break;
 	}
 
-	if (vg && (!fid->vg || (vg->seqno > fid->vg->seqno))) {
-		/*
-		 * Remember vg pointer to newest VG for reuse.
-		 * NOTE: _vg_read() will not release same VG
-		 */
-		fid->vg = vg;
-		fid->mda_size = (size + size2);
-		fid->mda_checksum = checksum;
+	if (vg && vg_fmtdata && *vg_fmtdata) {
+		(*vg_fmtdata)->cached_mda_size = (size + size2);
+		(*vg_fmtdata)->cached_mda_checksum = checksum;
 	}
 
+	if (use_previous_vg)
+		*use_previous_vg = 0;
+
       out:
 	config_destroy(cft);
 	return vg;
@@ -154,7 +170,7 @@ struct volume_group *text_vg_import_file(struct format_instance *fid,
 					 const char *file,
 					 time_t *when, char **desc)
 {
-	return text_vg_import_fd(fid, file, 0, NULL, (off_t)0, 0, (off_t)0, 0, NULL, 0,
+	return text_vg_import_fd(fid, file, NULL, NULL, 0, NULL, (off_t)0, 0, (off_t)0, 0, NULL, 0,
 				 when, desc);
 }
 
diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index 1569aaa..5e8e049 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -941,19 +941,16 @@ static void _read_desc(struct dm_pool *mem,
 	*when = u;
 }
 
-static const char *_read_vgname(const struct format_type *fmt,
-				const struct dm_config_tree *cft, struct id *vgid,
-				uint64_t *vgstatus, char **creation_host)
+static int _read_vgname(const struct format_type *fmt, const struct dm_config_tree *cft, 
+			struct lvmcache_vgsummary *vgsummary)
 {
 	const struct dm_config_node *vgn;
 	struct dm_pool *mem = fmt->cmd->mem;
-	char *vgname;
 	int old_suppress;
 
 	old_suppress = log_suppress(2);
-	*creation_host = dm_pool_strdup(mem,
-					dm_config_find_str_allow_empty(cft->root,
-							"creation_host", ""));
+	vgsummary->creation_host =
+	    dm_pool_strdup(mem, dm_config_find_str_allow_empty(cft->root, "creation_host", ""));
 	log_suppress(old_suppress);
 
 	/* skip any top-level values */
@@ -964,23 +961,23 @@ static const char *_read_vgname(const struct format_type *fmt,
 		return 0;
 	}
 
-	if (!(vgname = dm_pool_strdup(mem, vgn->key)))
+	if (!(vgsummary->vgname = dm_pool_strdup(mem, vgn->key)))
 		return_0;
 
 	vgn = vgn->child;
 
-	if (!_read_id(vgid, vgn, "id")) {
-		log_error("Couldn't read uuid for volume group %s.", vgname);
+	if (!_read_id(&vgsummary->vgid, vgn, "id")) {
+		log_error("Couldn't read uuid for volume group %s.", vgsummary->vgname);
 		return 0;
 	}
 
-	if (!_read_flag_config(vgn, vgstatus, VG_FLAGS)) {
+	if (!_read_flag_config(vgn, &vgsummary->vgstatus, VG_FLAGS)) {
 		log_error("Couldn't find status flags for volume group %s.",
-			  vgname);
+			  vgsummary->vgname);
 		return 0;
 	}
 
-	return vgname;
+	return 1;
 }
 
 static struct text_vg_version_ops _vsn1_ops = {
diff --git a/lib/format_text/layout.h b/lib/format_text/layout.h
index 5f6b549..64fc0e1 100644
--- a/lib/format_text/layout.h
+++ b/lib/format_text/layout.h
@@ -18,6 +18,7 @@
 
 #include "config.h"
 #include "metadata.h"
+#include "lvmcache.h"
 #include "uuid.h"
 
 /* disk_locn and data_area_list are defined in format-text.h */
@@ -97,13 +98,8 @@ struct mda_context {
 #define LVM2_LABEL "LVM2 001"
 #define MDA_SIZE_MIN (8 * (unsigned) lvm_getpagesize())
 
-
-const char *vgname_from_mda(const struct format_type *fmt,
-			    struct mda_header *mdah,
-			    struct device_area *dev_area,
-			    uint32_t *mda_checksum, size_t *mda_size,
-			    const char *vgname, struct id *vgid,
-			    uint64_t *vgstatus, char **creation_host,
-			    uint64_t *mda_free_sectors);
+int vgname_from_mda(const struct format_type *fmt, struct mda_header *mdah,
+		    struct device_area *dev_area, struct lvmcache_vgsummary *vgsummary,
+		    uint64_t *mda_free_sectors);
 
 #endif
diff --git a/lib/format_text/text_label.c b/lib/format_text/text_label.c
index 3a4835c..599be41 100644
--- a/lib/format_text/text_label.c
+++ b/lib/format_text/text_label.c
@@ -319,7 +319,7 @@ static int _update_mda(struct metadata_area *mda, void *baton)
 	const struct format_type *fmt = p->label->labeller->fmt;
 	struct mda_context *mdac = (struct mda_context *) mda->metadata_locn;
 	struct mda_header *mdah;
-	struct labeller *l = p->label->labeller;
+	struct lvmcache_vgsummary vgsummary = { 0 };
 
 	/*
 	 * Using the labeller struct to preserve info about
@@ -350,13 +350,9 @@ static int _update_mda(struct metadata_area *mda, void *baton)
 		return 1;
 	}
 
-	if ((l->vgname = vgname_from_mda(fmt, mdah, &mdac->area,
-					 &l->mda_checksum, &l->mda_size, l->vgname,
-					 &l->vgid, &l->vgstatus, &l->creation_host,
-					 &mdac->free_sectors)) &&
-	    !lvmcache_update_vgname_and_id(p->info, l->vgname,
-					   (char *) &l->vgid, l->vgstatus,
-					   l->creation_host)) {
+	if (vgname_from_mda(fmt, mdah, &mdac->area, &vgsummary,
+			     &mdac->free_sectors) &&
+	    !lvmcache_update_vgname_and_id(p->info, &vgsummary)) {
 		if (!dev_close(mdac->area.dev))
 			stack;
 		return_0;
diff --git a/lib/label/label.c b/lib/label/label.c
index ce59da8..4510400 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -97,6 +97,17 @@ struct labeller *label_get_handler(const char *name)
 	return NULL;
 }
 
+static void _update_lvmcache_orphan(struct lvmcache_info *info)
+{
+	struct lvmcache_vgsummary vgsummary_orphan = {
+		.vgname = lvmcache_fmt(info)->orphan_vg_name,
+	};
+
+        memcpy(&vgsummary_orphan.vgid, lvmcache_fmt(info)->orphan_vg_name, strlen(lvmcache_fmt(info)->orphan_vg_name));
+
+	lvmcache_update_vgname_and_id(info, &vgsummary_orphan);
+}
+
 static struct labeller *_find_labeller(struct device *dev, char *buf,
 				       uint64_t *label_sector,
 				       uint64_t scan_sector)
@@ -173,9 +184,7 @@ static struct labeller *_find_labeller(struct device *dev, char *buf,
       out:
 	if (!found) {
 		if ((info = lvmcache_info_from_pvid(dev->pvid, 0)))
-			lvmcache_update_vgname_and_id(info, lvmcache_fmt(info)->orphan_vg_name,
-						      lvmcache_fmt(info)->orphan_vg_name,
-						      0, NULL);
+			_update_lvmcache_orphan(info);
 		log_very_verbose("%s: No label detected", dev_name(dev));
 	}
 
@@ -271,9 +280,7 @@ int label_read(struct device *dev, struct label **result,
 		stack;
 
 		if ((info = lvmcache_info_from_pvid(dev->pvid, 0)))
-			lvmcache_update_vgname_and_id(info, lvmcache_fmt(info)->orphan_vg_name,
-						      lvmcache_fmt(info)->orphan_vg_name,
-						      0, NULL);
+			_update_lvmcache_orphan(info);
 
 		return r;
 	}
@@ -348,10 +355,7 @@ int label_verify(struct device *dev)
 
 	if (!dev_open_readonly(dev)) {
 		if ((info = lvmcache_info_from_pvid(dev->pvid, 0)))
-			lvmcache_update_vgname_and_id(info, lvmcache_fmt(info)->orphan_vg_name,
-						      lvmcache_fmt(info)->orphan_vg_name,
-						      0, NULL);
-
+			_update_lvmcache_orphan(info);
 		return_0;
 	}
 
diff --git a/lib/label/label.h b/lib/label/label.h
index 831977f..253e1e8 100644
--- a/lib/label/label.h
+++ b/lib/label/label.h
@@ -89,14 +89,6 @@ struct label_ops {
 struct labeller {
 	struct label_ops *ops;
 	const struct format_type *fmt;
-
-	/* Caching info */
-	const char *vgname;
-	struct id vgid;
-	uint64_t vgstatus;
-	char *creation_host;
-	uint32_t mda_checksum;
-	size_t mda_size;
 };
 
 int label_init(void);
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 414216a..1555c87 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -324,11 +324,6 @@ struct format_instance {
 	struct dm_list metadata_areas_ignored;
 	struct dm_hash_table *metadata_areas_index;
 
-	/* Remember last vg to avoid parsing same mda content for multiple PVs */
-	struct volume_group *vg;
-	uint32_t mda_checksum;
-	size_t mda_size;
-
 	void *private;
 };
 
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index ed91948..33ce370 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3248,6 +3248,8 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 	char uuid[64] __attribute__((aligned(8)));
 	unsigned seqno = 0;
 	int reappeared = 0;
+	struct cached_vg_fmtdata *vg_fmtdata = NULL;	/* Additional format-specific data about the vg */
+	unsigned use_previous_vg;
 
 	if (is_orphan_vg(vgname)) {
 		if (use_precommitted) {
@@ -3334,12 +3336,20 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 	/* Ensure contents of all metadata areas match - else do recovery */
 	inconsistent_mda_count=0;
 	dm_list_iterate_items(mda, &fid->metadata_areas_in_use) {
+		use_previous_vg = 0;
 
 		if ((use_precommitted &&
-		     !(vg = mda->ops->vg_read_precommit(fid, vgname, mda))) ||
+		     !(vg = mda->ops->vg_read_precommit(fid, vgname, mda, &vg_fmtdata, &use_previous_vg)) && !use_previous_vg) ||
 		    (!use_precommitted &&
-		     !(vg = mda->ops->vg_read(fid, vgname, mda, 0)))) {
+		     !(vg = mda->ops->vg_read(fid, vgname, mda, &vg_fmtdata, &use_previous_vg, 0)) && !use_previous_vg)) {
 			inconsistent = 1;
+			vg_fmtdata = NULL;
+			continue;
+		}
+
+		/* Use previous VG because checksum matches */
+		if (!vg) {
+			vg = correct_vg;
 			continue;
 		}
 
@@ -3366,9 +3376,10 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 			}
 		}
 
-		if (vg != correct_vg)
-			/* NOTE: tied to fid->vg logic in text_vg_import_fd() */
+		if (vg != correct_vg) {
 			release_vg(vg);
+			vg_fmtdata = NULL;
+		}
 	}
 	fid->ref_count--;
 
@@ -3484,6 +3495,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 		 * but we failed to do so (so there's a dangling fid now).
 		 */
 		_destroy_fid(&fid);
+		vg_fmtdata = NULL;
 
 		inconsistent = 0;
 
@@ -3514,14 +3526,23 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 		/* Ensure contents of all metadata areas match - else recover */
 		inconsistent_mda_count=0;
 		dm_list_iterate_items(mda, &fid->metadata_areas_in_use) {
+			use_previous_vg = 0;
+
 			if ((use_precommitted &&
-			     !(vg = mda->ops->vg_read_precommit(fid, vgname,
-								mda))) ||
+			     !(vg = mda->ops->vg_read_precommit(fid, vgname, mda, &vg_fmtdata, &use_previous_vg)) && !use_previous_vg) ||
 			    (!use_precommitted &&
-			     !(vg = mda->ops->vg_read(fid, vgname, mda, 0)))) {
+			     !(vg = mda->ops->vg_read(fid, vgname, mda, &vg_fmtdata, &use_previous_vg, 0)) && !use_previous_vg)) {
 				inconsistent = 1;
+				vg_fmtdata = NULL;
 				continue;
 			}
+
+			/* Use previous VG because checksum matches */
+			if (!vg) {
+				vg = correct_vg;
+				continue;
+			}
+
 			if (!correct_vg) {
 				correct_vg = vg;
 				if (!_update_pv_list(cmd->mem, &all_pvs, correct_vg)) {
@@ -3564,8 +3585,10 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 				}
 			}
 
-			if (vg != correct_vg)
+			if (vg != correct_vg) {
 				release_vg(vg);
+				vg_fmtdata = NULL;
+			}
 		}
 		fid->ref_count--;
 
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index 75abf63..031d19e 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -72,6 +72,7 @@ struct dm_config_tree;
 struct metadata_area;
 struct alloc_handle;
 struct lvmcache_info;
+struct cached_vg_fmtdata;
 
 /* Per-format per-metadata area operations */
 struct metadata_area_ops {
@@ -79,10 +80,14 @@ struct metadata_area_ops {
 	struct volume_group *(*vg_read) (struct format_instance * fi,
 					 const char *vg_name,
 					 struct metadata_area * mda,
+					 struct cached_vg_fmtdata **vg_fmtdata,
+					 unsigned *use_previous_vg,
 					 int single_device);
 	struct volume_group *(*vg_read_precommit) (struct format_instance * fi,
 					 const char *vg_name,
-					 struct metadata_area * mda);
+					 struct metadata_area * mda,
+					 struct cached_vg_fmtdata **vg_fmtdata,
+					 unsigned *use_previous_vg);
 	/*
 	 * Write out complete VG metadata.  You must ensure internal
 	 * consistency before calling. eg. PEs can't refer to PVs not


