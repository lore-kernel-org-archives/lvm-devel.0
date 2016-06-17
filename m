From: David Teigland <teigland@fedoraproject.org>
Date: Fri, 17 Jun 2016 17:27:40 +0000 (UTC)
Subject: master - lvmlockd: fix dropping PVs in rescanning VG
Message-ID: <20160617172740.7A64261169@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=899a4ca275543425ca60fe361bc13fbc5c90e741
Commit:        899a4ca275543425ca60fe361bc13fbc5c90e741
Parent:        ab7ade40957812b948a63527d1023747f8336e56
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Jun 17 11:45:08 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Jun 17 12:21:09 2016 -0500

lvmlockd: fix dropping PVs in rescanning VG

This fixes a problem in commit ae0a8740c.  The problem
in that commit was that all existing PVs are initially
dropped from lvmetad.  This works if the VG is updated
at the end, which replaces the dropped PVs, but if the
rescan finds that the VG seqno is unchanged, it leaves
the cached VG in place.  So, we should only drop the
existing PVs in lvmetad when the VG is going to be updated.
---
 lib/cache/lvmetad.c |   48 ++++++++++++++++++++++++++++++------------------
 1 files changed, 30 insertions(+), 18 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 0f1f269..0508291 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -1675,8 +1675,9 @@ static struct volume_group *lvmetad_pvscan_vg(struct cmd_context *cmd, struct vo
 	struct dm_config_tree *vgmeta_ret = NULL;
 	struct dm_config_tree *vgmeta;
 	struct pv_list *pvl, *pvl_new;
-	struct device_list *devl, *devl_new;
+	struct device_list *devl, *devl_new, *devlsafe;
 	struct dm_list pvs_scan;
+	struct dm_list pvs_drop;
 	struct dm_list pvs_new;
 	struct lvmcache_info *info;
 	struct format_instance *fid;
@@ -1689,6 +1690,7 @@ static struct volume_group *lvmetad_pvscan_vg(struct cmd_context *cmd, struct vo
 	int found;
 
 	dm_list_init(&pvs_scan);
+	dm_list_init(&pvs_drop);
 	dm_list_init(&pvs_new);
 
 	log_debug_lvmetad("Rescanning VG %s (seqno %u).", vg->name, vg->seqno);
@@ -1713,23 +1715,12 @@ static struct volume_group *lvmetad_pvscan_vg(struct cmd_context *cmd, struct vo
 		dm_list_add(&pvs_scan, &devl->list);
 	}
 
-	/*
-	 * Drop stale info from lvmetad.
-	 */
-	dm_list_iterate_items(devl, &pvs_scan) {
-		if (!devl->dev)
-			continue;
-		log_debug_lvmetad("Rescan VG %s dropping %s.", vg->name, dev_name(devl->dev));
-		if (!lvmetad_pv_gone_by_dev(devl->dev))
-			return_NULL;
-	}
-
 scan_more:
 
 	/*
 	 * Run the equivalent of lvmetad_pvscan_single on each dev in the VG.
 	 */
-	dm_list_iterate_items(devl, &pvs_scan) {
+	dm_list_iterate_items_safe(devl, devlsafe, &pvs_scan) {
 		if (!devl->dev)
 			continue;
 
@@ -1742,6 +1733,7 @@ scan_more:
 			if ((info = lvmcache_info_from_pvid(devl->dev->pvid, NULL, 0)))
 				lvmcache_del(info);
 
+			dm_list_move(&pvs_drop, &devl->list);
 			continue;
 		}
 
@@ -1755,6 +1747,7 @@ scan_more:
 		if (baton.fid->fmt->features & FMT_OBSOLETE) {
 			log_debug_lvmetad("Ignoring obsolete format on PV %s in VG %s.", dev_name(devl->dev), vg->name);
 			lvmcache_fmt(info)->ops->destroy_instance(baton.fid);
+			dm_list_move(&pvs_drop, &devl->list);
 			continue;
 		}
 
@@ -1770,8 +1763,7 @@ scan_more:
 		if (!baton.vg) {
 			log_debug_lvmetad("Rescan VG %s did not find %s.", vg->name, dev_name(devl->dev));
 			lvmcache_fmt(info)->ops->destroy_instance(baton.fid);
-			lvmetad_pv_found(cmd, (const struct id *) &devl->dev->pvid, devl->dev,
-					 lvmcache_fmt(info), label->sector, NULL, NULL, NULL);
+			dm_list_move(&pvs_drop, &devl->list);
 			continue;
 		}
 
@@ -1783,8 +1775,7 @@ scan_more:
 			log_debug_lvmetad("Rescan VG %s found different VG %s on PV %s.",
 					  vg->name, baton.vg->name, dev_name(devl->dev));
 			release_vg(baton.vg);
-			lvmetad_pv_found(cmd, (const struct id *) &devl->dev->pvid, devl->dev,
-					 lvmcache_fmt(info), label->sector, NULL, NULL, NULL);
+			dm_list_move(&pvs_drop, &devl->list);
 			continue;
 		}
 
@@ -1873,9 +1864,19 @@ scan_more:
 	}
 
 	/*
-	 * Change the metadata into a vg struct to return.
+	 * Remove pvs_drop entries from lvmetad.
 	 */
+	dm_list_iterate_items(devl, &pvs_drop) {
+		if (!devl->dev)
+			continue;
+		log_debug_lvmetad("Rescan VG %s dropping %s.", vg->name, dev_name(devl->dev));
+		if (!lvmetad_pv_gone_by_dev(devl->dev))
+			return_NULL;
+	}
 
+	/*
+	 * Update the VG in lvmetad.
+	 */
 	if (vgmeta_ret) {
 		fid = lvmcache_fmt(info)->ops->create_instance(lvmcache_fmt(info), &fic);
 		if (!(vg_ret = import_vg_from_config_tree(vgmeta_ret, fid))) {
@@ -1889,10 +1890,21 @@ scan_more:
 		 * The "precommitted" name is a misnomer in this case,
 		 * but that is the field which lvmetad_vg_update() uses
 		 * to send the metadata cft to lvmetad.
+		 *
+		 * When the seqno is unchanged the cached VG can be left.
 		 */
 		if (save_seqno != vg->seqno) {
+			dm_list_iterate_items(devl, &pvs_scan) {
+				if (!devl->dev)
+					continue;
+				log_debug_lvmetad("Rescan VG %s dropping to replace %s.", vg->name, dev_name(devl->dev));
+				if (!lvmetad_pv_gone_by_dev(devl->dev))
+					return_NULL;
+			}
+
 			log_debug_lvmetad("Rescan VG %s updating lvmetad from seqno %u to seqno %u.",
 					  vg->name, vg->seqno, save_seqno);
+
 			vg_ret->cft_precommitted = vgmeta_ret;
 			if (!lvmetad_vg_update(vg_ret))
 				log_error("Failed to update lvmetad with new VG meta");


