From: David Teigland <teigland@sourceware.org>
Date: Fri, 7 Jun 2019 17:08:37 -0400
Subject: master - move pv header repairs to vg_write
Message-ID: <201906072108.x57L8bNh005308@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=de3d3b11f493a89ebee2eab7efae70d33face954
Commit:        de3d3b11f493a89ebee2eab7efae70d33face954
Parent:        89914a541f081e1c234a455c17d82269cd90364b
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Feb 6 13:18:45 2019 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Jun 7 15:54:04 2019 -0500

move pv header repairs to vg_write

Correct PV header in-use or version fields
from vg_write instead of vg_read.
---
 lib/format_text/format-text.c |   14 +++-
 lib/metadata/metadata.c       |  168 +++++-----------------------------------
 2 files changed, 34 insertions(+), 148 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 6e224f0..4f0a004 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1600,12 +1600,16 @@ static int _text_pv_needs_rewrite(const struct format_type *fmt, struct physical
 {
 	struct lvmcache_info *info;
 	uint32_t ext_vsn;
+	uint32_t ext_flags;
 
 	*needs_rewrite = 0;
 
 	if (!pv->is_labelled)
 		return 1;
 
+	if (!pv->dev)
+		return 1;
+
 	if (!(info = lvmcache_info_from_pvid((const char *)&pv->id, pv->dev, 0))) {
 		log_error("Failed to find cached info for PV %s.", pv_dev_name(pv));
 		return 0;
@@ -1613,8 +1617,16 @@ static int _text_pv_needs_rewrite(const struct format_type *fmt, struct physical
 
 	ext_vsn = lvmcache_ext_version(info);
 
-	if (ext_vsn < PV_HEADER_EXTENSION_VSN)
+	if (ext_vsn < PV_HEADER_EXTENSION_VSN) {
+		log_debug("PV %s header needs rewrite for new ext version", dev_name(pv->dev));
+		*needs_rewrite = 1;
+	}
+
+	ext_flags = lvmcache_ext_flags(info);
+	if (!(ext_flags & PV_EXT_USED)) {
+		log_debug("PV %s header needs rewrite to set ext used", dev_name(pv->dev));
 		*needs_rewrite = 1;
+	}
 
 	return 1;
 }
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index a13be57..804d0cf 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2810,57 +2810,6 @@ static int _pv_in_pv_list(struct physical_volume *pv, struct dm_list *head)
 	return 0;
 }
 
-/*
- * Check if any of the PVs in VG still contain old PV headers
- * and if yes, schedule them for PV header update.
- */
-static int _vg_update_old_pv_ext_if_needed(struct volume_group *vg)
-{
-	struct pv_list *pvl, *new_pvl;
-	int pv_needs_rewrite;
-
-	if (!(vg->fid->fmt->features & FMT_PV_FLAGS))
-		return 1;
-
-	dm_list_iterate_items(pvl, &vg->pvs) {
-		if (is_missing_pv(pvl->pv) ||
-		    !pvl->pv->fmt->ops->pv_needs_rewrite)
-			continue;
-
-		if (_pv_in_pv_list(pvl->pv, &vg->pv_write_list))
-			continue;
-
-		if (!pvl->pv->fmt->ops->pv_needs_rewrite(pvl->pv->fmt, pvl->pv,
-							 &pv_needs_rewrite))
-			return_0;
-
-		if (pv_needs_rewrite) {
-			/*
-			 * Schedule PV for writing only once!
-			 */
-			if (_pv_in_pv_list(pvl->pv, &vg->pv_write_list))
-				continue;
-
-			if (!(new_pvl = dm_pool_zalloc(vg->vgmem, sizeof(*new_pvl)))) {
-				log_error("pv_to_write allocation for '%s' failed", pv_dev_name(pvl->pv));
-				return 0;
-			}
-			new_pvl->pv = pvl->pv;
-			dm_list_add(&vg->pv_write_list, &new_pvl->list);
-			log_debug("PV %s has old extension header, updating to newest version.",
-				  pv_dev_name(pvl->pv));
-		}
-	}
-
-	if (!dm_list_empty(&vg->pv_write_list) &&
-	    (!vg_write(vg) || !vg_commit(vg))) {
-		log_error("Failed to update old PV extension headers in VG %s.", vg->name);
-		return 0;
-	}
-
-	return 1;
-}
-
 static int _check_historical_lv_is_valid(struct historical_logical_volume *hlv)
 {
 	struct glv_list *glvl;
@@ -2995,7 +2944,7 @@ static void _wipe_outdated_pvs(struct cmd_context *cmd, struct volume_group *vg)
 int vg_write(struct volume_group *vg)
 {
 	struct dm_list *mdah;
-	struct pv_list *pvl, *pvl_safe;
+	struct pv_list *pvl, *pvl_safe, *new_pvl;
 	struct metadata_area *mda;
 	struct lv_list *lvl;
 	int revert = 0, wrote = 0;
@@ -3063,6 +3012,26 @@ int vg_write(struct volume_group *vg)
 	memlock_unlock(vg->cmd);
 	vg->seqno++;
 
+	dm_list_iterate_items(pvl, &vg->pvs) {
+		int update_pv_header = 0;
+
+		if (_pv_in_pv_list(pvl->pv, &vg->pv_write_list))
+			continue;
+
+		if (!pvl->pv->fmt->ops->pv_needs_rewrite(pvl->pv->fmt, pvl->pv, &update_pv_header))
+			continue;
+
+		if (!update_pv_header)
+			continue;
+
+		if (!(new_pvl = dm_pool_zalloc(vg->vgmem, sizeof(*new_pvl))))
+			continue;
+
+		new_pvl->pv = pvl->pv;
+		dm_list_add(&vg->pv_write_list, &new_pvl->list);
+		log_warn("WARNING: updating PV header on %s for VG %s.", pv_dev_name(pvl->pv), vg->name);
+	}
+
 	dm_list_iterate_items_safe(pvl, pvl_safe, &vg->pv_write_list) {
 		if (!pv_write(vg->cmd, pvl->pv, 1))
 			return_0;
@@ -3607,88 +3576,6 @@ static int _repair_inconsistent_vg(struct volume_group *vg, uint32_t lockd_state
 	return 1;
 }
 
-static int _check_or_repair_pv_ext(struct cmd_context *cmd,
-				   struct volume_group *vg,
-				   uint32_t lockd_state,
-				   int repair, int *inconsistent_pvs)
-{
-	char uuid[64] __attribute__((aligned(8)));
-	struct lvmcache_info *info;
-	uint32_t ext_version, ext_flags;
-	struct pv_list *pvl;
-	unsigned pvs_fixed = 0;
-	int r = 0;
-
-	*inconsistent_pvs = 0;
-
-	dm_list_iterate_items(pvl, &vg->pvs) {
-		/* Missing PV - nothing to do. */
-		if (is_missing_pv(pvl->pv))
-			continue;
-
-		if (!pvl->pv->dev) {
-			/* is_missing_pv doesn't catch NULL dev */
-			memset(&uuid, 0, sizeof(uuid));
-			if (!id_write_format(&pvl->pv->id, uuid, sizeof(uuid)))
-				goto_out;
-			log_warn("WARNING: Not repairing PV %s with missing device.", uuid);
-			continue;
-		}
-
-		if (!(info = lvmcache_info_from_pvid(pvl->pv->dev->pvid, pvl->pv->dev, 0))) {
-			log_error("Failed to find cached info for PV %s.", pv_dev_name(pvl->pv));
-			goto out;
-		}
-
-		ext_version = lvmcache_ext_version(info);
-		if (ext_version < 2)
-			continue;
-
-		ext_flags = lvmcache_ext_flags(info);
-		if (!(ext_flags & PV_EXT_USED)) {
-			if (!repair) {
-				*inconsistent_pvs = 1;
-				/* we're not repairing now, so no need to
-				 * check further PVs - inconsistent_pvs is already
-				 * set and that will trigger the repair next time */
-				return 1;
-			}
-
-			if (_is_foreign_vg(vg)) {
-				log_verbose("Skip repair of PV %s that is in foreign "
-					    "VG %s but not marked as used.",
-					    pv_dev_name(pvl->pv), vg->name);
-				*inconsistent_pvs = 1;
-			} else if (vg_is_shared(vg) && !(lockd_state & LDST_EX)) {
-				log_warn("Skip repair of PV %s that is in shared "
-					    "VG %s but not marked as used.",
-					    pv_dev_name(pvl->pv), vg->name);
-				*inconsistent_pvs = 1;
-			} else {
-				log_warn("WARNING: Repairing Physical Volume %s that is "
-					 "in Volume Group %s but not marked as used.",
-					  pv_dev_name(pvl->pv), vg->name);
-
-				/* pv write will set correct ext_flags */
-				if (!pv_write(cmd, pvl->pv, 1)) {
-					*inconsistent_pvs = 1;
-					log_error("Failed to repair physical volume \"%s\".",
-						  pv_dev_name(pvl->pv));
-					goto out;
-				}
-				pvs_fixed++;
-			}
-		}
-	}
-
-	r = 1;
-out:
-	if ((pvs_fixed > 0) && !_repair_inconsistent_vg(vg, lockd_state))
-		return_0;
-
-	return r;
-}
-
 /* Caller sets consistent to 1 if it's safe for vg_read_internal to correct
  * inconsistent metadata on disk (i.e. the VG write lock is held).
  * This guarantees only consistent metadata is returned.
@@ -3724,7 +3611,6 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 	int inconsistent_mdas = 0;
 	int inconsistent_mda_count = 0;
 	int strip_historical_lvs = enable_repair;
-	int update_old_pv_ext = enable_repair;
 	unsigned use_precommitted = precommitted;
 	struct dm_list *pvids;
 	struct pv_list *pvl;
@@ -4258,19 +4144,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 		return NULL;
 	}
 
-	/* We have the VG now finally, check if PV ext info is in sync with VG metadata. */
-	if (!_check_or_repair_pv_ext(cmd, correct_vg, lockd_state, skipped_rescan ? 0 : enable_repair,
-				     &inconsistent_pvs)) {
-		release_vg(correct_vg);
-		return_NULL;
-	}
-
 	if (correct_vg && enable_repair && !skipped_rescan) {
-		if (update_old_pv_ext && !_vg_update_old_pv_ext_if_needed(correct_vg)) {
-			release_vg(correct_vg);
-			return_NULL;
-		}
-
 		if (strip_historical_lvs && !vg_strip_outdated_historical_lvs(correct_vg)) {
 			release_vg(correct_vg);
 			return_NULL;


