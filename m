From: David Teigland <teigland@fedoraproject.org>
Date: Wed, 20 Jul 2016 15:25:27 +0000 (UTC)
Subject: master - lvmetad: fix use committed metadata to update
Message-ID: <20160720152527.88C666109A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6ea250e2d05aeb55c883aafa0a98e97660dfd633
Commit:        6ea250e2d05aeb55c883aafa0a98e97660dfd633
Parent:        7eb79091937d01eec51fc6a034879a6fe607231d
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jul 20 10:18:58 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jul 20 10:25:26 2016 -0500

lvmetad: fix use committed metadata to update

In some cases, the command will update VG metadata
in lvmetad without writing it.  In these cases there
is no vg->vg_committed and it should use 'vg' directly.
This happens when the command finds that the lvmetad
VG has been invalidated, rereads the metadata from disk,
then updates lvmetad with that metadata.  This happens
often with lvmlockd or foreign VGs, and can happen without
lvmlockd if a previous command fails after invalidating
the VG in lvmetad.
---
 lib/cache/lvmetad.c |   30 ++++++++++++++++++------------
 1 files changed, 18 insertions(+), 12 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 401df7c..0503d91 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -1199,7 +1199,7 @@ int lvmetad_vg_update_finish(struct volume_group *vg)
 	struct dm_hash_node *n;
 	struct metadata_area *mda;
 	char mda_id[128], *num;
-	struct volume_group *vgc;
+	struct volume_group *vgu;
 	struct dm_config_tree *vgmeta;
 	struct pv_list *pvl;
 	struct lvmcache_info *info;
@@ -1219,11 +1219,19 @@ int lvmetad_vg_update_finish(struct volume_group *vg)
 
 	/*
 	 * vg->vg_committted is the state of the VG metadata when vg_commit()
-	 * was called.  Since then, vg-> may have been partially modified and
+	 * was called.  Since then, 'vg' may have been partially modified and
 	 * not committed.  We only want to send committed metadata to lvmetad.
+	 *
+	 * lvmetad is sometimes updated in cases where the VG is not written
+	 * (no vg_committed).  In those cases 'vg' has just been read from
+	 * disk, and we can send 'vg' to lvmetad.  This happens when the
+	 * command finds the lvmetad cache invalid, so the VG has been read
+	 * from disk and is then sent to lvmetad.
 	 */
 
-	if (!(vgmeta = export_vg_to_config_tree(vg->vg_committed))) {
+	vgu = vg->vg_committed ? vg->vg_committed : vg;
+
+	if (!(vgmeta = export_vg_to_config_tree(vgu))) {
 		log_error("Failed to export VG to config tree.");
 		return 0;
 	}
@@ -1249,13 +1257,11 @@ int lvmetad_vg_update_finish(struct volume_group *vg)
 
 	daemon_reply_destroy(reply);
 
-	vgc = vg->vg_committed;
-
-	n = (vgc->fid && vgc->fid->metadata_areas_index) ?
-		dm_hash_get_first(vgc->fid->metadata_areas_index) : NULL;
+	n = (vgu->fid && vgu->fid->metadata_areas_index) ?
+		dm_hash_get_first(vgu->fid->metadata_areas_index) : NULL;
 	while (n) {
-		mda = dm_hash_get_data(vgc->fid->metadata_areas_index, n);
-		(void) dm_strncpy(mda_id, dm_hash_get_key(vgc->fid->metadata_areas_index, n), sizeof(mda_id));
+		mda = dm_hash_get_data(vgu->fid->metadata_areas_index, n);
+		(void) dm_strncpy(mda_id, dm_hash_get_key(vgu->fid->metadata_areas_index, n), sizeof(mda_id));
 		if ((num = strchr(mda_id, '_'))) {
 			*num = 0;
 			++num;
@@ -1266,13 +1272,13 @@ int lvmetad_vg_update_finish(struct volume_group *vg)
 				lvmcache_foreach_mda(info, _fixup_ignored, &baton);
 			}
 		}
-		n = dm_hash_get_next(vgc->fid->metadata_areas_index, n);
+		n = dm_hash_get_next(vgu->fid->metadata_areas_index, n);
 	}
 
-	dm_list_iterate_items(pvl, &vgc->pvs) {
+	dm_list_iterate_items(pvl, &vgu->pvs) {
 		/* NB. the PV fmt pointer is sometimes wrong during vgconvert */
 		if (pvl->pv->dev && !lvmetad_pv_found(vg->cmd, &pvl->pv->id, pvl->pv->dev,
-						      vgc->fid ? vgc->fid->fmt : pvl->pv->fmt,
+						      vgu->fid ? vgu->fid->fmt : pvl->pv->fmt,
 						      pvl->pv->label_sector, NULL, NULL, NULL))
 			return 0;
 	}


