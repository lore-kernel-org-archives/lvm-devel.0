From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 18 Jul 2016 21:18:53 +0000 (UTC)
Subject: master - lvmetad: use committed metadata to update
Message-ID: <20160718211853.339D860F95@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f8872578e9f40c9259d8a116aa48a794055290bd
Commit:        f8872578e9f40c9259d8a116aa48a794055290bd
Parent:        94207dfd68ca426d7cd4a8a0dc84e5a955d3a6d9
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Jul 18 14:46:08 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Jul 18 16:18:53 2016 -0500

lvmetad: use committed metadata to update

This fixes a regression from commit a7c45ddc5, which moved
the lvmetad VG update from vg_commit() to unlock_vg().

The lvmetad VG update needs to send the version of metadata
that was committed rather than sending the state of struct 'vg'.
The 'vg' may have been partially modified since vg_commit(),
and contain non-committed metadata that shouldn't be sent
to lvmetad.
---
 lib/cache/lvmetad.c |   25 +++++++++++++++++--------
 1 files changed, 17 insertions(+), 8 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index c320b1c..401df7c 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -1199,6 +1199,7 @@ int lvmetad_vg_update_finish(struct volume_group *vg)
 	struct dm_hash_node *n;
 	struct metadata_area *mda;
 	char mda_id[128], *num;
+	struct volume_group *vgc;
 	struct dm_config_tree *vgmeta;
 	struct pv_list *pvl;
 	struct lvmcache_info *info;
@@ -1216,7 +1217,13 @@ int lvmetad_vg_update_finish(struct volume_group *vg)
 	if (!id_write_format(&vg->id, uuid, sizeof(uuid)))
 		return_0;
 
-	if (!(vgmeta = export_vg_to_config_tree(vg))) {
+	/*
+	 * vg->vg_committted is the state of the VG metadata when vg_commit()
+	 * was called.  Since then, vg-> may have been partially modified and
+	 * not committed.  We only want to send committed metadata to lvmetad.
+	 */
+
+	if (!(vgmeta = export_vg_to_config_tree(vg->vg_committed))) {
 		log_error("Failed to export VG to config tree.");
 		return 0;
 	}
@@ -1242,11 +1249,13 @@ int lvmetad_vg_update_finish(struct volume_group *vg)
 
 	daemon_reply_destroy(reply);
 
-	n = (vg->fid && vg->fid->metadata_areas_index) ?
-		dm_hash_get_first(vg->fid->metadata_areas_index) : NULL;
+	vgc = vg->vg_committed;
+
+	n = (vgc->fid && vgc->fid->metadata_areas_index) ?
+		dm_hash_get_first(vgc->fid->metadata_areas_index) : NULL;
 	while (n) {
-		mda = dm_hash_get_data(vg->fid->metadata_areas_index, n);
-		(void) dm_strncpy(mda_id, dm_hash_get_key(vg->fid->metadata_areas_index, n), sizeof(mda_id));
+		mda = dm_hash_get_data(vgc->fid->metadata_areas_index, n);
+		(void) dm_strncpy(mda_id, dm_hash_get_key(vgc->fid->metadata_areas_index, n), sizeof(mda_id));
 		if ((num = strchr(mda_id, '_'))) {
 			*num = 0;
 			++num;
@@ -1257,13 +1266,13 @@ int lvmetad_vg_update_finish(struct volume_group *vg)
 				lvmcache_foreach_mda(info, _fixup_ignored, &baton);
 			}
 		}
-		n = dm_hash_get_next(vg->fid->metadata_areas_index, n);
+		n = dm_hash_get_next(vgc->fid->metadata_areas_index, n);
 	}
 
-	dm_list_iterate_items(pvl, &vg->pvs) {
+	dm_list_iterate_items(pvl, &vgc->pvs) {
 		/* NB. the PV fmt pointer is sometimes wrong during vgconvert */
 		if (pvl->pv->dev && !lvmetad_pv_found(vg->cmd, &pvl->pv->id, pvl->pv->dev,
-						      vg->fid ? vg->fid->fmt : pvl->pv->fmt,
+						      vgc->fid ? vgc->fid->fmt : pvl->pv->fmt,
 						      pvl->pv->label_sector, NULL, NULL, NULL))
 			return 0;
 	}


