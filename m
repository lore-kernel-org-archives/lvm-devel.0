From: David Teigland <teigland@fedoraproject.org>
Date: Wed, 15 Jun 2016 16:38:08 +0000 (UTC)
Subject: master - lvmlockd: fix rescanning VG
Message-ID: <20160615163808.E14D560EA8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ae0a8740c5899520ec4c94fbf080623167d8ecba
Commit:        ae0a8740c5899520ec4c94fbf080623167d8ecba
Parent:        49a8d1a85eb035a0dfb1febd76e3ae4fa5e976d5
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jun 14 14:51:03 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jun 15 11:36:30 2016 -0500

lvmlockd: fix rescanning VG

Previously, new PVs that were added to the VG were not scanned.
---
 lib/cache/lvmetad.c |  165 +++++++++++++++++++++++++++++++++++++++++++++------
 tools/lvmcmdline.c  |    1 +
 2 files changed, 147 insertions(+), 19 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 70adbb4..0f1f269 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -1085,6 +1085,8 @@ struct volume_group *lvmetad_vg_lookup(struct cmd_context *cmd, const char *vgna
 			if (!(vg2 = lvmetad_pvscan_vg(cmd, vg))) {
 				log_debug_lvmetad("VG %s from lvmetad not found during rescan.", vgname);
 				fid = NULL;
+				release_vg(vg);
+				vg = NULL;
 				goto out;
 			}
 			release_vg(vg);
@@ -1666,41 +1668,99 @@ static int _lvmetad_pvscan_single(struct metadata_area *mda, void *baton)
 
 static struct volume_group *lvmetad_pvscan_vg(struct cmd_context *cmd, struct volume_group *vg)
 {
+	char pvid_s[ID_LEN + 1] __attribute__((aligned(8)));
+	char uuid[64] __attribute__((aligned(8)));
+	struct label *label;
 	struct volume_group *vg_ret = NULL;
 	struct dm_config_tree *vgmeta_ret = NULL;
 	struct dm_config_tree *vgmeta;
-	struct pv_list *pvl;
+	struct pv_list *pvl, *pvl_new;
+	struct device_list *devl, *devl_new;
+	struct dm_list pvs_scan;
+	struct dm_list pvs_new;
 	struct lvmcache_info *info;
 	struct format_instance *fid;
 	struct format_instance_ctx fic = { .type = 0 };
 	struct _lvmetad_pvscan_baton baton;
 	struct device *save_dev = NULL;
 	uint32_t save_seqno = 0;
+	int missing_devs = 0;
+	int check_new_pvs = 0;
+	int found;
+
+	dm_list_init(&pvs_scan);
+	dm_list_init(&pvs_new);
+
+	log_debug_lvmetad("Rescanning VG %s (seqno %u).", vg->name, vg->seqno);
+
+	/*
+	 * Another host may have added a PV to the VG, and some
+	 * commands do not always populate their lvmcache with
+	 * all devs from lvmetad, so they would fail to find
+	 * the new PV when scanning the VG.  So make sure this
+	 * command knows about all PVs from lvmetad.
+	 */
+	lvmcache_seed_infos_from_lvmetad(cmd);
 
+	/*
+	 * Start with the list of PVs that we last saw in the VG.
+	 * Some may now be gone, and some new PVs may have been added.
+	 */
 	dm_list_iterate_items(pvl, &vg->pvs) {
-		/* missing pv */
-		if (!pvl->pv->dev)
+		if (!(devl = dm_pool_zalloc(cmd->mem, sizeof(*devl))))
+			return_NULL;
+		devl->dev = pvl->pv->dev;
+		dm_list_add(&pvs_scan, &devl->list);
+	}
+
+	/*
+	 * Drop stale info from lvmetad.
+	 */
+	dm_list_iterate_items(devl, &pvs_scan) {
+		if (!devl->dev)
 			continue;
+		log_debug_lvmetad("Rescan VG %s dropping %s.", vg->name, dev_name(devl->dev));
+		if (!lvmetad_pv_gone_by_dev(devl->dev))
+			return_NULL;
+	}
 
-		if (!(info = lvmcache_info_from_pvid((const char *)&pvl->pv->id, pvl->pv->dev, 0))) {
-			log_error("Failed to find cached info for PV %s.", pv_dev_name(pvl->pv));
-			return NULL;
+scan_more:
+
+	/*
+	 * Run the equivalent of lvmetad_pvscan_single on each dev in the VG.
+	 */
+	dm_list_iterate_items(devl, &pvs_scan) {
+		if (!devl->dev)
+			continue;
+
+		log_debug_lvmetad("Rescan VG %s scanning %s.", vg->name, dev_name(devl->dev));
+
+		if (!label_read(devl->dev, &label, 0)) {
+			/* Another host removed this PV from the VG. */
+			log_debug_lvmetad("Rescan VG %s found %s was removed.", vg->name, dev_name(devl->dev));
+
+			if ((info = lvmcache_info_from_pvid(devl->dev->pvid, NULL, 0)))
+				lvmcache_del(info);
+
+			continue;
 		}
 
+		info = (struct lvmcache_info *) label->info;
+
 		baton.vg = NULL;
 		baton.fid = lvmcache_fmt(info)->ops->create_instance(lvmcache_fmt(info), &fic);
-
 		if (!baton.fid)
-			return NULL;
+			return_NULL;
 
 		if (baton.fid->fmt->features & FMT_OBSOLETE) {
+			log_debug_lvmetad("Ignoring obsolete format on PV %s in VG %s.", dev_name(devl->dev), vg->name);
 			lvmcache_fmt(info)->ops->destroy_instance(baton.fid);
-			log_warn("WARNING: Disabling lvmetad cache which does not support obsolete (lvm1) metadata.");
-			lvmetad_set_disabled(cmd, LVMETAD_DISABLE_REASON_LVM1);
-			_found_lvm1_metadata = 1;
-			return NULL;
+			continue;
 		}
 
+		/*
+		 * Read VG metadata from this dev's mdas.
+		 */
 		lvmcache_foreach_mda(info, _lvmetad_pvscan_single, &baton);
 
 		/*
@@ -1708,8 +1768,10 @@ static struct volume_group *lvmetad_pvscan_vg(struct cmd_context *cmd, struct vo
 		 * since we last read the VG.
 		 */
 		if (!baton.vg) {
-			log_debug_lvmetad("Did not find VG %s in scan of PV %s", vg->name, dev_name(pvl->pv->dev));
+			log_debug_lvmetad("Rescan VG %s did not find %s.", vg->name, dev_name(devl->dev));
 			lvmcache_fmt(info)->ops->destroy_instance(baton.fid);
+			lvmetad_pv_found(cmd, (const struct id *) &devl->dev->pvid, devl->dev,
+					 lvmcache_fmt(info), label->sector, NULL, NULL, NULL);
 			continue;
 		}
 
@@ -1718,12 +1780,20 @@ static struct volume_group *lvmetad_pvscan_vg(struct cmd_context *cmd, struct vo
 		 * different VG since we last read the VG.
 		 */
 		if (strcmp(baton.vg->name, vg->name)) {
-			log_debug_lvmetad("Did not find VG %s in scan of PV %s which is now VG %s",
-					  vg->name, dev_name(pvl->pv->dev), baton.vg->name);
+			log_debug_lvmetad("Rescan VG %s found different VG %s on PV %s.",
+					  vg->name, baton.vg->name, dev_name(devl->dev));
 			release_vg(baton.vg);
+			lvmetad_pv_found(cmd, (const struct id *) &devl->dev->pvid, devl->dev,
+					 lvmcache_fmt(info), label->sector, NULL, NULL, NULL);
 			continue;
 		}
 
+		/*
+		 * The VG metadata read from each dev should match.  Save the
+		 * metadata from the first dev, and compare it to the metadata
+		 * read from each other dev.
+		 */
+
 		if (!save_seqno)
 			save_seqno = baton.vg->seqno;
 
@@ -1735,11 +1805,11 @@ static struct volume_group *lvmetad_pvscan_vg(struct cmd_context *cmd, struct vo
 
 		if (!vgmeta_ret) {
 			vgmeta_ret = vgmeta;
-			save_dev = pvl->pv->dev;
+			save_dev = devl->dev;
 		} else {
 			if (compare_config(vgmeta_ret->root, vgmeta->root)) {
 				log_error("VG %s metadata comparison failed for device %s vs %s",
-					  vg->name, dev_name(pvl->pv->dev), save_dev ? dev_name(save_dev) : "none");
+					  vg->name, dev_name(devl->dev), save_dev ? dev_name(save_dev) : "none");
 				_log_debug_inequality(vg->name, vgmeta_ret->root, vgmeta->root);
 				dm_config_destroy(vgmeta);
 				dm_config_destroy(vgmeta_ret);
@@ -1749,9 +1819,63 @@ static struct volume_group *lvmetad_pvscan_vg(struct cmd_context *cmd, struct vo
 			dm_config_destroy(vgmeta);
 		}
 
+		/*
+		 * Look for any new PVs in the VG metadata that were not in our
+		 * previous version of the VG.  Add them to pvs_new to be
+		 * scanned in this loop just like the old PVs.
+		 */
+		if (!check_new_pvs) {
+			check_new_pvs = 1;
+			dm_list_iterate_items(pvl_new, &baton.vg->pvs) {
+				found = 0;
+				dm_list_iterate_items(pvl, &vg->pvs) {
+					if (pvl_new->pv->dev != pvl->pv->dev)
+						continue;
+					found = 1;
+					break;
+				}
+				if (found)
+					continue;
+				if (!pvl_new->pv->dev) {
+					strncpy(pvid_s, (char *) &pvl_new->pv->id, sizeof(pvid_s) - 1);
+					if (!id_write_format((const struct id *)&pvid_s, uuid, sizeof(uuid)))
+						stack;
+					log_error("Device not found for PV %s in VG %s", uuid, vg->name);
+					missing_devs++;
+					continue;
+				}
+				if (!(devl_new = dm_pool_zalloc(cmd->mem, sizeof(*devl_new))))
+					return_NULL;
+				devl_new->dev = pvl_new->pv->dev;
+				dm_list_add(&pvs_new, &devl_new->list);
+				log_debug_lvmetad("Rescan VG %s found %s was added.", vg->name, dev_name(devl_new->dev));
+			}
+		}
+
 		release_vg(baton.vg);
 	}
 
+	/*
+	 * Do the same scanning above for any new PVs.
+	 */
+	if (!dm_list_empty(&pvs_new)) {
+		dm_list_init(&pvs_scan);
+		dm_list_splice(&pvs_scan, &pvs_new);
+		dm_list_init(&pvs_new);
+		log_debug_lvmetad("Rescan VG %s found new PVs to scan.", vg->name);
+		goto scan_more;
+	}
+
+	if (missing_devs) {
+		if (vgmeta_ret)
+			dm_config_destroy(vgmeta_ret);
+		return_NULL;
+	}
+
+	/*
+	 * Change the metadata into a vg struct to return.
+	 */
+
 	if (vgmeta_ret) {
 		fid = lvmcache_fmt(info)->ops->create_instance(lvmcache_fmt(info), &fic);
 		if (!(vg_ret = import_vg_from_config_tree(vgmeta_ret, fid))) {
@@ -1767,8 +1891,8 @@ static struct volume_group *lvmetad_pvscan_vg(struct cmd_context *cmd, struct vo
 		 * to send the metadata cft to lvmetad.
 		 */
 		if (save_seqno != vg->seqno) {
-			log_debug_lvmetad("Update lvmetad from seqno %u to seqno %u for VG %s",
-					  vg->seqno, save_seqno, vg->name);
+			log_debug_lvmetad("Rescan VG %s updating lvmetad from seqno %u to seqno %u.",
+					  vg->name, vg->seqno, save_seqno);
 			vg_ret->cft_precommitted = vgmeta_ret;
 			if (!lvmetad_vg_update(vg_ret))
 				log_error("Failed to update lvmetad with new VG meta");
@@ -1777,6 +1901,7 @@ static struct volume_group *lvmetad_pvscan_vg(struct cmd_context *cmd, struct vo
 		dm_config_destroy(vgmeta_ret);
 	}
 out:
+	log_debug_lvmetad("Rescan VG %s done (seqno %u).", vg_ret->name, vg_ret->seqno);
 	return vg_ret;
 }
 
@@ -2330,6 +2455,8 @@ void lvmetad_validate_global_cache(struct cmd_context *cmd, int force)
 		_lvmetad_get_pv_cache_list(cmd, &pvc_after);
 		_update_changed_pvs_in_udev(cmd, &pvc_before, &pvc_after);
 	}
+
+	log_debug_lvmetad("Validating global lvmetad cache finished");
 }
 
 int lvmetad_vg_is_foreign(struct cmd_context *cmd, const char *vgname, const char *vgid)
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index be6821b..452e6aa 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1599,6 +1599,7 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 	init_dmeventd_monitor(monitoring);
 
 	log_debug("Processing: %s", cmd->cmd_line);
+	log_debug("Command pid: %d", getpid());
 	log_debug("system ID: %s", cmd->system_id ? : "");
 
 #ifdef O_DIRECT_SUPPORT


