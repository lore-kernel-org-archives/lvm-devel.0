From: David Teigland <teigland@sourceware.org>
Date: Mon, 23 Apr 2018 09:49:11 -0400
Subject: master - label_scan: remove extra label scan and read for orphan PVs
Message-ID: <201804231349.w3NDnBSi031594@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=79c4971210a6337563ffa2fca08fb636423d93d4
Commit:        79c4971210a6337563ffa2fca08fb636423d93d4
Parent:        5f138f36040297d092977a3b547cdefffb5ac4e8
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Nov 6 12:09:52 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 20 11:22:45 2018 -0500

label_scan: remove extra label scan and read for orphan PVs

When process_each_pv() calls vg_read() on the orphan VG, the
internal implementation was doing an unnecessary
lvmcache_label_scan() and two unnecessary label_read() calls
on each orphan.  Some of those unnecessary label scans/reads
would sometimes be skipped due to caching, but the code was
always doing at least one unnecessary read on each orphan.

The common format_text case was also unecessarily calling into
the format-specific pv_read() function which actually did nothing.

By analyzing each case in which vg_read() was being called on
the orphan VG, we can say that all of the label scans/reads
in vg_read_orphans are unnecessary:

1. reporting commands: the information saved in lvmcache by
the original label scan can be reported.  There is no advantage
to repeating the label scan on the orphans a second time before
reporting it.

2. pvcreate/vgcreate/vgextend: these all share a common
implementation in pvcreate_each_device().  That function
already rescans labels after acquiring the orphan VG lock,
which ensures that the command is using valid lvmcache
information.
---
 lib/cache/lvmcache.c          |   51 +++-----------
 lib/cache/lvmcache.h          |    4 +-
 lib/format_text/format-text.c |   31 ---------
 lib/metadata/metadata.c       |  150 +++++++++++------------------------------
 lib/metadata/metadata.h       |    6 --
 5 files changed, 54 insertions(+), 188 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 47058cc..8e119b5 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -2454,56 +2454,29 @@ int lvmcache_fid_add_mdas_vg(struct lvmcache_vginfo *vginfo, struct format_insta
 	return 1;
 }
 
-static int _get_pv_if_in_vg(struct lvmcache_info *info,
-			    struct physical_volume *pv)
-{
-	char vgname[NAME_LEN + 1];
-	char vgid[ID_LEN + 1];
-
-	if (info->vginfo && info->vginfo->vgname &&
-	    !is_orphan_vg(info->vginfo->vgname)) {
-		/*
-		 * get_pv_from_vg_by_id() may call
-		 * lvmcache_label_scan() and drop cached
-		 * vginfo so make a local copy of string.
-		 */
-		(void) dm_strncpy(vgname, info->vginfo->vgname, sizeof(vgname));
-		memcpy(vgid, info->vginfo->vgid, sizeof(vgid));
-
-		if (get_pv_from_vg_by_id(info->fmt, vgname, vgid,
-					 info->dev->pvid, pv))
-			return 1;
-	}
-
-	return 0;
-}
-
 int lvmcache_populate_pv_fields(struct lvmcache_info *info,
-				struct physical_volume *pv,
-				int scan_label_only)
+				struct volume_group *vg,
+				struct physical_volume *pv)
 {
 	struct data_area_list *da;
-
-	/* Have we already cached vgname? */
-	if (!scan_label_only && _get_pv_if_in_vg(info, pv))
-		return 1;
-
-	/* Perform full scan (just the first time) and try again */
-	if (!scan_label_only && !critical_section() && !full_scan_done()) {
-		lvmcache_force_next_label_scan();
-		lvmcache_label_scan(info->fmt->cmd);
-
-		if (_get_pv_if_in_vg(info, pv))
-			return 1;
+	
+	if (!info->label) {
+		log_error("No cached label for orphan PV %s", pv_dev_name(pv));
+		return 0;
 	}
 
-	/* Orphan */
+	pv->label_sector = info->label->sector;
 	pv->dev = info->dev;
 	pv->fmt = info->fmt;
 	pv->size = info->device_size >> SECTOR_SHIFT;
 	pv->vg_name = FMT_TEXT_ORPHAN_VG_NAME;
 	memcpy(&pv->id, &info->dev->pvid, sizeof(pv->id));
 
+	if (!pv->size) {
+		log_error("PV %s size is zero.", dev_name(info->dev));
+		return 0;
+	}
+
 	/* Currently only support exactly one data area */
 	if (dm_list_size(&info->das) != 1) {
 		log_error("Must be exactly one data area (found %d) on PV %s",
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index 826e91e..1b5379c 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -145,8 +145,8 @@ int lvmcache_fid_add_mdas(struct lvmcache_info *info, struct format_instance *fi
 int lvmcache_fid_add_mdas_pv(struct lvmcache_info *info, struct format_instance *fid);
 int lvmcache_fid_add_mdas_vg(struct lvmcache_vginfo *vginfo, struct format_instance *fid);
 int lvmcache_populate_pv_fields(struct lvmcache_info *info,
-				struct physical_volume *pv,
-				int scan_label_only);
+				struct volume_group *vg,
+				struct physical_volume *pv);
 int lvmcache_check_format(struct lvmcache_info *info, const struct format_type *fmt);
 void lvmcache_del_mdas(struct lvmcache_info *info);
 void lvmcache_del_das(struct lvmcache_info *info);
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 9538080..ee1f11d 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1593,36 +1593,6 @@ static uint64_t _metadata_locn_offset_raw(void *metadata_locn)
 	return mdac->area.start;
 }
 
-static int _text_pv_read(const struct format_type *fmt, const char *pv_name,
-		    struct physical_volume *pv, int scan_label_only)
-{
-	struct lvmcache_info *info;
-	struct device *dev;
-
-	if (!(dev = dev_cache_get(pv_name, fmt->cmd->filter)))
-		return_0;
-
-	if (lvmetad_used()) {
-		info = lvmcache_info_from_pvid(dev->pvid, dev, 0);
-		if (!info && !lvmetad_pv_lookup_by_dev(fmt->cmd, dev, NULL))
-			return 0;
-		info = lvmcache_info_from_pvid(dev->pvid, dev, 0);
-	} else {
-		struct label *label;
-		if (!(label_read(dev, &label, UINT64_C(0))))
-			return_0;
-		info = label->info;
-	}
-
-	if (!info)
-		return_0;
-
-	if (!lvmcache_populate_pv_fields(info, pv, scan_label_only))
-		return 0;
-
-	return 1;
-}
-
 static int _text_pv_initialise(const struct format_type *fmt,
 			       struct pv_create_args *pva,
 			       struct physical_volume *pv)
@@ -2471,7 +2441,6 @@ static struct format_instance *_text_create_text_instance(const struct format_ty
 
 static struct format_handler _text_handler = {
 	.scan = _text_scan,
-	.pv_read = _text_pv_read,
 	.pv_initialise = _text_pv_initialise,
 	.pv_setup = _text_pv_setup,
 	.pv_add_metadata_area = _text_pv_add_metadata_area,
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index b4ee204..570cbe6 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -38,10 +38,9 @@
 #include <sys/param.h>
 
 static struct physical_volume *_pv_read(struct cmd_context *cmd,
-					struct dm_pool *pvmem,
-					const char *pv_name,
-					struct format_instance *fid,
-					uint32_t warn_flags, int scan_label_only);
+					const struct format_type *fmt,
+					struct volume_group *vg,
+					struct lvmcache_info *info);
 
 static int _alignment_overrides_default(unsigned long data_alignment,
 					unsigned long default_pe_align)
@@ -330,37 +329,6 @@ bad:
 	return NULL;
 }
 
-int get_pv_from_vg_by_id(const struct format_type *fmt, const char *vg_name,
-			 const char *vgid, const char *pvid,
-			 struct physical_volume *pv)
-{
-	struct volume_group *vg;
-	struct pv_list *pvl;
-	uint32_t warn_flags = WARN_PV_READ | WARN_INCONSISTENT;
-	int r = 0, consistent = 0;
-
-	if (!(vg = vg_read_internal(fmt->cmd, vg_name, vgid, warn_flags, &consistent))) {
-		log_error("get_pv_from_vg_by_id: vg_read_internal failed to read VG %s",
-			  vg_name);
-		return 0;
-	}
-
-	dm_list_iterate_items(pvl, &vg->pvs) {
-		if (id_equal(&pvl->pv->id, (const struct id *) pvid)) {
-			if (!_copy_pv(fmt->cmd->mem, pv, pvl->pv)) {
-				log_error("internal PV duplication failed");
-				r = 0;
-				goto out;
-			}
-			r = 1;
-			goto out;
-		}
-	}
-out:
-	release_vg(vg);
-	return r;
-}
-
 static int _move_pv(struct volume_group *vg_from, struct volume_group *vg_to,
 		    const char *pv_name, int enforce_pv_from_source)
 {
@@ -3246,9 +3214,7 @@ static int _check_mda_in_use(struct metadata_area *mda, void *_in_use)
 struct _vg_read_orphan_baton {
 	struct cmd_context *cmd;
 	struct volume_group *vg;
-	uint32_t warn_flags;
-	int consistent;
-	int repair;
+	const struct format_type *fmt;
 };
 
 /*
@@ -3345,8 +3311,7 @@ static int _vg_read_orphan_pv(struct lvmcache_info *info, void *baton)
 	uint32_t ext_version;
 	uint32_t ext_flags;
 
-	if (!(pv = _pv_read(b->vg->cmd, b->vg->vgmem, dev_name(lvmcache_device(info)),
-			    b->vg->fid, b->warn_flags, 0))) {
+	if (!(pv = _pv_read(b->cmd, b->fmt, b->vg, info))) {
 		stack;
 		return 1;
 	}
@@ -3453,10 +3418,22 @@ static struct volume_group *_vg_read_orphans(struct cmd_context *cmd,
 	vg->free_count = 0;
 
 	baton.cmd = cmd;
-	baton.warn_flags = warn_flags;
+	baton.fmt = fmt;
 	baton.vg = vg;
-	baton.consistent = 1;
-	baton.repair = *consistent;
+
+	/*
+	 * vg_read for a normal VG will rescan labels for all the devices
+	 * in the VG, in case something changed on disk between the initial
+	 * label scan and acquiring the VG lock.  We don't rescan labels
+	 * here because this is only called in two ways:
+	 *
+	 * 1. for reporting, in which case it doesn't matter if something
+	 *    changed between the label scan and printing the PVs here
+	 *
+	 * 2. pvcreate_each_device() for pvcreate//vgcreate/vgextend,
+	 *    which already does the label rescan after taking the
+	 *    orphan lock.
+	 */
 
 	while ((pvl = (struct pv_list *) dm_list_first(&head.list))) {
 		dm_list_del(&pvl->list);
@@ -3468,7 +3445,6 @@ static struct volume_group *_vg_read_orphans(struct cmd_context *cmd,
 	if (!lvmcache_foreach_pv(vginfo, _vg_read_orphan_pv, &baton))
 		return_NULL;
 
-	*consistent = baton.consistent;
 	return vg;
 }
 
@@ -4686,86 +4662,40 @@ const char *find_vgname_from_pvname(struct cmd_context *cmd,
 	return find_vgname_from_pvid(cmd, pvid);
 }
 
-/* FIXME Use label functions instead of PV functions */
 static struct physical_volume *_pv_read(struct cmd_context *cmd,
-					struct dm_pool *pvmem,
-					const char *pv_name,
-					struct format_instance *fid,
-					uint32_t warn_flags, int scan_label_only)
+					const struct format_type *fmt,
+					struct volume_group *vg,
+					struct lvmcache_info *info)
 {
 	struct physical_volume *pv;
-	struct label *label;
-	struct lvmcache_info *info;
-	struct device *dev;
-	const struct format_type *fmt;
-	int found;
-
-	if (!(dev = dev_cache_get(pv_name, cmd->filter)))
-		return_NULL;
-
-	if (lvmetad_used()) {
-		info = lvmcache_info_from_pvid(dev->pvid, dev, 0);
-		if (!info) {
-			if (!lvmetad_pv_lookup_by_dev(cmd, dev, &found))
-				return_NULL;
-			if (!found) {
-				if (warn_flags & WARN_PV_READ)
-					log_error("No physical volume found in lvmetad cache for %s",
-						  pv_name);
-				return NULL;
-			}
-			if (!(info = lvmcache_info_from_pvid(dev->pvid, dev, 0))) {
-				if (warn_flags & WARN_PV_READ)
-					log_error("No cache info in lvmetad cache for %s.",
-						  pv_name);
-				return NULL;
-			}
-		}
-		label = lvmcache_get_label(info);
-	} else {
-		if (!(label_read(dev, &label, UINT64_C(0)))) {
-			if (warn_flags & WARN_PV_READ)
-				log_error("No physical volume label read from %s",
-					  pv_name);
-			return NULL;
-		}
-		info = (struct lvmcache_info *) label->info;
-	}
+	struct device *dev = lvmcache_device(info);
 
-	fmt = lvmcache_fmt(info);
-
-	pv = _alloc_pv(pvmem, dev);
-	if (!pv) {
-		log_error("pv allocation for '%s' failed", pv_name);
+	if (!(pv = _alloc_pv(vg->vgmem, NULL))) {
+		log_error("pv allocation failed");
 		return NULL;
 	}
 
-	pv->label_sector = label->sector;
-
-	/* FIXME Move more common code up here */
-	if (!(lvmcache_fmt(info)->ops->pv_read(lvmcache_fmt(info), pv_name, pv, scan_label_only))) {
-		log_error("Failed to read existing physical volume '%s'",
-			  pv_name);
-		goto bad;
+	if (fmt->ops->pv_read) {
+		/* format1 and pool */
+		if (!(fmt->ops->pv_read(fmt, dev_name(dev), pv, 0))) {
+			log_error("Failed to read existing physical volume '%s'", dev_name(dev));
+			goto bad;
+		}
+	} else {
+		/* format text */
+		if (!lvmcache_populate_pv_fields(info, vg, pv))
+			goto_bad;
 	}
 
-	if (!pv->size)
-		goto bad;
-
-	if (!alloc_pv_segment_whole_pv(pvmem, pv))
+	if (!alloc_pv_segment_whole_pv(vg->vgmem, pv))
 		goto_bad;
 
-	if (fid)
-		lvmcache_fid_add_mdas(info, fid, (const char *) &pv->id, ID_LEN);
-	else {
-		lvmcache_fid_add_mdas(info, fmt->orphan_vg->fid, (const char *) &pv->id, ID_LEN);
-		pv_set_fid(pv, fmt->orphan_vg->fid);
-	}
-
+	lvmcache_fid_add_mdas(info, vg->fid, (const char *) &pv->id, ID_LEN);
+	pv_set_fid(pv, vg->fid);
 	return pv;
 bad:
 	free_pv_fid(pv);
-	dm_pool_free(pvmem, pv);
+	dm_pool_free(vg->vgmem, pv);
 	return NULL;
 }
 
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index 5b8d690..83983b4 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -371,12 +371,6 @@ uint32_t vg_bad_status_bits(const struct volume_group *vg, uint64_t status);
 int add_pv_to_vg(struct volume_group *vg, const char *pv_name,
 		 struct physical_volume *pv, int new_pv);
 
-
-/* Find a PV within a given VG */
-int get_pv_from_vg_by_id(const struct format_type *fmt, const char *vg_name,
-			 const char *vgid, const char *pvid,
-			 struct physical_volume *pv);
-
 struct logical_volume *find_lv_in_vg_by_lvid(struct volume_group *vg,
 					     const union lvid *lvid);
 


