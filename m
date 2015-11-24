From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 24 Nov 2015 10:33:19 +0000 (UTC)
Subject: master - cleanup: move towards using direct LV pointers
Message-ID: <20151124103319.5CBA861437@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6d6c233768e2a9c3bd9fd13e113e2a890c18b2cf
Commit:        6d6c233768e2a9c3bd9fd13e113e2a890c18b2cf
Parent:        94c9453659e9e2ec0389b8ea3e9ed18718d61d6a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Nov 21 23:31:44 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 23 23:42:59 2015 +0100

cleanup: move towards using direct LV pointers

We do not won't to 'expose'  internals of VG struct.
ATM we use lists to keep all LVs - we may want to switch
to better struct for quicker 'search'.

Since we do not need 'lists' but always actual LV,
switch find_lv_in_vg_by_lvid() to return LV,
and replaces some use case of  find_lv_in_vg()
with 'better' working find_lv() which already
returns LV.
---
 lib/activate/activate.c |   38 +++++++++++++++++++-------------------
 lib/metadata/metadata.c |   18 +++++++++---------
 lib/metadata/metadata.h |    4 ++--
 3 files changed, 30 insertions(+), 30 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 7d2adf1..6a6a952 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1763,25 +1763,25 @@ struct detached_lv_data {
 static int _preload_detached_lv(struct logical_volume *lv, void *data)
 {
 	struct detached_lv_data *detached = data;
-	struct lv_list *lvl_pre;
+	struct logical_volume *lv_pre;
 
 	/* Check and preload removed raid image leg or metadata */
 	if (lv_is_raid_image(lv)) {
-		if ((lvl_pre = find_lv_in_vg_by_lvid(detached->lv_pre->vg, &lv->lvid)) &&
-		    !lv_is_raid_image(lvl_pre->lv) && lv_is_active(lv) &&
-		    !_lv_preload(lvl_pre->lv, detached->laopts, detached->flush_required))
+		if ((lv_pre = find_lv_in_vg_by_lvid(detached->lv_pre->vg, &lv->lvid)) &&
+		    !lv_is_raid_image(lv_pre) && lv_is_active(lv) &&
+		    !_lv_preload(lv_pre, detached->laopts, detached->flush_required))
 			return_0;
 	} else if (lv_is_raid_metadata(lv)) {
-		if ((lvl_pre = find_lv_in_vg_by_lvid(detached->lv_pre->vg, &lv->lvid)) &&
-		    !lv_is_raid_metadata(lvl_pre->lv) && lv_is_active(lv) &&
-		    !_lv_preload(lvl_pre->lv, detached->laopts, detached->flush_required))
+		if ((lv_pre = find_lv_in_vg_by_lvid(detached->lv_pre->vg, &lv->lvid)) &&
+		    !lv_is_raid_metadata(lv_pre) && lv_is_active(lv) &&
+		    !_lv_preload(lv_pre, detached->laopts, detached->flush_required))
 			return_0;
 	}
 
-	if ((lvl_pre = find_lv_in_vg(detached->lv_pre->vg, lv->name))) {
-		if (lv_is_visible(lvl_pre->lv) && lv_is_active(lv) &&
-		    (!lv_is_cow(lv) || !lv_is_cow(lvl_pre->lv)) &&
-		    !_lv_preload(lvl_pre->lv, detached->laopts, detached->flush_required))
+	if ((lv_pre = find_lv(detached->lv_pre->vg, lv->name))) {
+		if (lv_is_visible(lv_pre) && lv_is_active(lv) &&
+		    (!lv_is_cow(lv) || !lv_is_cow(lv_pre)) &&
+		    !_lv_preload(lv_pre, detached->laopts, detached->flush_required))
 			return_0;
 	}
 
@@ -1795,7 +1795,7 @@ static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
 	const struct logical_volume *pvmove_lv = NULL;
 	const struct logical_volume *ondisk_lv_to_free = NULL;
 	const struct logical_volume *incore_lv_to_free = NULL;
-	struct lv_list *lvl_pre;
+	struct logical_volume *lv_pre;
 	struct seg_list *sl;
         struct lv_segment *snap_seg;
 	struct lvinfo info;
@@ -1854,19 +1854,19 @@ static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
 	    (pvmove_lv = find_pvmove_lv_in_lv(ondisk_lv))) {
 		/* Preload all the LVs above the PVMOVE LV */
 		dm_list_iterate_items(sl, &pvmove_lv->segs_using_this_lv) {
-			if (!(lvl_pre = find_lv_in_vg(incore_lv->vg, sl->seg->lv->name))) {
+			if (!(lv_pre = find_lv(incore_lv->vg, sl->seg->lv->name))) {
 				log_error(INTERNAL_ERROR "LV %s missing from preload metadata", sl->seg->lv->name);
 				goto out;
 			}
-			if (!_lv_preload(lvl_pre->lv, laopts, &flush_required))
+			if (!_lv_preload(lv_pre, laopts, &flush_required))
 				goto_out;
 		}
 		/* Now preload the PVMOVE LV itself */
-		if (!(lvl_pre = find_lv_in_vg(incore_lv->vg, pvmove_lv->name))) {
+		if (!(lv_pre = find_lv(incore_lv->vg, pvmove_lv->name))) {
 			log_error(INTERNAL_ERROR "LV %s missing from preload metadata", pvmove_lv->name);
 			goto out;
 		}
-		if (!_lv_preload(lvl_pre->lv, laopts, &flush_required))
+		if (!_lv_preload(lv_pre, laopts, &flush_required))
 			goto_out;
 	} else {
 		if (!_lv_preload(incore_lv, laopts, &flush_required))
@@ -1888,13 +1888,13 @@ static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
 		 */
 		if (!laopts->origin_only && lv_is_origin(ondisk_lv)) {
         		dm_list_iterate_items_gen(snap_seg, &ondisk_lv->snapshot_segs, origin_list) {
-				if (!(lvl_pre = find_lv_in_vg_by_lvid(incore_lv->vg, &snap_seg->cow->lvid))) {
+				if (!(lv_pre = find_lv_in_vg_by_lvid(incore_lv->vg, &snap_seg->cow->lvid))) {
 					log_error(INTERNAL_ERROR "LV %s (%s) missing from preload metadata",
 						  snap_seg->cow->name, snap_seg->cow->lvid.id[1].uuid);
 					goto out;
 				}
-				if (!lv_is_cow(lvl_pre->lv) &&
-				    !_lv_preload(lvl_pre->lv, laopts, &flush_required))
+				if (!lv_is_cow(lv_pre) &&
+				    !_lv_preload(lv_pre, laopts, &flush_required))
 					goto_out;
 			}
 		}
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 77bbeab..b1ddb34 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1975,14 +1975,14 @@ struct lv_list *find_lv_in_lv_list(const struct dm_list *ll,
 	return NULL;
 }
 
-struct lv_list *find_lv_in_vg_by_lvid(struct volume_group *vg,
-				      const union lvid *lvid)
+struct logical_volume *find_lv_in_vg_by_lvid(struct volume_group *vg,
+					     const union lvid *lvid)
 {
 	struct lv_list *lvl;
 
 	dm_list_iterate_items(lvl, &vg->lvs)
 		if (!strncmp(lvl->lv->lvid.s, lvid->s, sizeof(*lvid)))
-			return lvl;
+			return lvl->lv;
 
 	return NULL;
 }
@@ -4134,7 +4134,7 @@ static struct volume_group *_vg_read_by_vgid(struct cmd_context *cmd,
 struct logical_volume *lv_from_lvid(struct cmd_context *cmd, const char *lvid_s,
 				    unsigned precommitted)
 {
-	struct lv_list *lvl;
+	struct logical_volume *lv;
 	struct volume_group *vg;
 	const union lvid *lvid;
 
@@ -4151,12 +4151,12 @@ struct logical_volume *lv_from_lvid(struct cmd_context *cmd, const char *lvid_s,
 		log_error("Volume group \"%s\" is exported", vg->name);
 		goto out;
 	}
-	if (!(lvl = find_lv_in_vg_by_lvid(vg, lvid))) {
+	if (!(lv = find_lv_in_vg_by_lvid(vg, lvid))) {
 		log_very_verbose("Can't find logical volume id %s", lvid_s);
 		goto out;
 	}
 
-	return lvl->lv;
+	return lv;
 out:
 	release_vg(vg);
 	return NULL;
@@ -5534,7 +5534,7 @@ char *tags_format_and_copy(struct dm_pool *mem, const struct dm_list *tagsl)
 const struct logical_volume *lv_ondisk(const struct logical_volume *lv)
 {
 	struct volume_group *vg;
-	struct lv_list *lvl;
+	struct logical_volume *found_lv;
 
 	if (!lv)
 		return NULL;
@@ -5544,13 +5544,13 @@ const struct logical_volume *lv_ondisk(const struct logical_volume *lv)
 
 	vg = lv->vg->vg_ondisk;
 
-	if (!(lvl = find_lv_in_vg_by_lvid(vg, &lv->lvid))) {
+	if (!(found_lv = find_lv_in_vg_by_lvid(vg, &lv->lvid))) {
 		log_error(INTERNAL_ERROR "LV %s (UUID %s) not found in ondisk metadata.",
 			  display_lvname(lv), lv->lvid.s);
 		return NULL;
 	}
 
-	return lvl->lv;
+	return found_lv;
 }
 
 /*
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index 1a5306b..e19bd16 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -364,8 +364,8 @@ int get_pv_from_vg_by_id(const struct format_type *fmt, const char *vg_name,
 			 const char *vgid, const char *pvid,
 			 struct physical_volume *pv);
 
-struct lv_list *find_lv_in_vg_by_lvid(struct volume_group *vg,
-				      const union lvid *lvid);
+struct logical_volume *find_lv_in_vg_by_lvid(struct volume_group *vg,
+					     const union lvid *lvid);
 
 struct lv_list *find_lv_in_lv_list(const struct dm_list *ll,
 				   const struct logical_volume *lv);


