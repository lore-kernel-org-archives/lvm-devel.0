From: David Teigland <teigland@sourceware.org>
Date: Mon, 23 Apr 2018 09:52:51 -0400
Subject: master - lvmetad: use new label_scan for update from lvmlockd
Message-ID: <201804231352.w3NDqp1B000981@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9c71fa02144619a67993920cee2146fed820f49c
Commit:        9c71fa02144619a67993920cee2146fed820f49c
Parent:        098c843c50cdcc2e4f4162037e1ff5975624f3e2
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Oct 26 10:58:23 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 20 11:21:41 2018 -0500

lvmetad: use new label_scan for update from lvmlockd

When lvmlockd indicates that the lvmetad cache is out of
date because of changes by another node, lvmetad_pvscan_vg()
rescans the devices in the VG to update lvmetad.  Use the
new label_scan in this function to use the common code and
take advantage of the new aio and reduced reads.
---
 lib/cache/lvmetad.c |  435 +++++++++++++++++++++++++++++++++++----------------
 1 files changed, 298 insertions(+), 137 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 4b7410c..552dbf0 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -39,7 +39,7 @@ static int64_t _lvmetad_update_timeout;
 
 static int _found_lvm1_metadata = 0;
 
-static struct volume_group *_lvmetad_pvscan_vg(struct cmd_context *cmd, struct volume_group *vg);
+static struct volume_group *_lvmetad_pvscan_vg(struct cmd_context *cmd, struct volume_group *vg, const char *vgid, struct format_type *fmt);
 
 static uint64_t _monotonic_seconds(void)
 {
@@ -1093,14 +1093,17 @@ struct volume_group *lvmetad_vg_lookup(struct cmd_context *cmd, const char *vgna
 		 * invalidated the cached vg.
 		 */
 		if (rescan) {
-			if (!(vg2 = _lvmetad_pvscan_vg(cmd, vg))) {
+			if (!(vg2 = _lvmetad_pvscan_vg(cmd, vg, vgid, fmt))) {
 				log_debug_lvmetad("VG %s from lvmetad not found during rescan.", vgname);
 				fid = NULL;
 				release_vg(vg);
 				vg = NULL;
 				goto out;
 			}
+			fid->ref_count++;
 			release_vg(vg);
+			fid->ref_count--;
+			fmt->ops->destroy_instance(fid);
 			vg = vg2;
 			fid = vg2->fid;
 		}
@@ -1108,14 +1111,14 @@ struct volume_group *lvmetad_vg_lookup(struct cmd_context *cmd, const char *vgna
 		dm_list_iterate_items(pvl, &vg->pvs) {
 			if (!_pv_update_struct_pv(pvl->pv, fid)) {
 				vg = NULL;
-				goto_out;	/* FIXME error path */
+				goto_out;	/* FIXME: use an error path that disables lvmetad */
 			}
 		}
 
 		dm_list_iterate_items(pvl, &vg->pvs_outdated) {
 			if (!_pv_update_struct_pv(pvl->pv, fid)) {
 				vg = NULL;
-				goto_out;	/* FIXME error path */
+				goto_out;	/* FIXME: use an error path that disables lvmetad */
 			}
 		}
 
@@ -1761,6 +1764,7 @@ int lvmetad_pv_gone_by_dev(struct device *dev)
  */
 
 struct _lvmetad_pvscan_baton {
+	struct cmd_context *cmd;
 	struct volume_group *vg;
 	struct format_instance *fid;
 };
@@ -1771,7 +1775,7 @@ static int _lvmetad_pvscan_single(struct metadata_area *mda, void *baton)
 	struct volume_group *vg;
 
 	if (mda_is_ignored(mda) ||
-	    !(vg = mda->ops->vg_read(b->fid, "", mda, NULL, NULL, 1)))
+	    !(vg = mda->ops->vg_read(b->fid, "", mda, NULL, NULL)))
 		return 1;
 
 	/* FIXME Also ensure contents match etc. */
@@ -1784,6 +1788,33 @@ static int _lvmetad_pvscan_single(struct metadata_area *mda, void *baton)
 }
 
 /*
+ * FIXME: handle errors and do proper comparison of metadata from each area
+ * like vg_read and fall back to real vg_read from disk if there's any problem.
+ */
+
+static int _lvmetad_pvscan_vg_single(struct metadata_area *mda, void *baton)
+{
+	struct _lvmetad_pvscan_baton *b = baton;
+	struct volume_group *vg = NULL;
+
+	if (mda_is_ignored(mda))
+		return 1;
+
+	if (!(vg = mda->ops->vg_read(b->fid, "", mda, NULL, NULL)))
+		return 1;
+
+	if (!b->vg)
+		b->vg = vg;
+	else if (vg->seqno > b->vg->seqno) {
+		release_vg(b->vg);
+		b->vg = vg;
+	} else
+		release_vg(vg);
+
+	return 1;
+}
+
+/*
  * The lock manager may detect that the vg cached in lvmetad is out of date,
  * due to something like an lvcreate from another host.
  * This is limited to changes that only affect the vg (not global state like
@@ -1792,41 +1823,41 @@ static int _lvmetad_pvscan_single(struct metadata_area *mda, void *baton)
  * the VG, and that PV may have been reused for another VG.
  */
 
-static struct volume_group *_lvmetad_pvscan_vg(struct cmd_context *cmd, struct volume_group *vg)
+static struct volume_group *_lvmetad_pvscan_vg(struct cmd_context *cmd, struct volume_group *vg,
+					      const char *vgid, struct format_type *fmt)
 {
 	char pvid_s[ID_LEN + 1] __attribute__((aligned(8)));
 	char uuid[64] __attribute__((aligned(8)));
-	struct label *label;
-	struct volume_group *vg_ret = NULL;
-	struct dm_config_tree *vgmeta_ret = NULL;
 	struct dm_config_tree *vgmeta;
 	struct pv_list *pvl, *pvl_new;
-	struct device_list *devl, *devl_new, *devlsafe;
+	struct device_list *devl, *devlsafe;
 	struct dm_list pvs_scan;
 	struct dm_list pvs_drop;
-	struct dm_list pvs_new;
+	struct lvmcache_vginfo *vginfo = NULL;
 	struct lvmcache_info *info = NULL;
 	struct format_instance *fid;
 	struct format_instance_ctx fic = { .type = 0 };
 	struct _lvmetad_pvscan_baton baton;
+	struct volume_group *save_vg;
+	struct dm_config_tree *save_meta;
 	struct device *save_dev = NULL;
 	uint32_t save_seqno = 0;
-	int missing_devs = 0;
-	int check_new_pvs = 0;
+	int found_new_pvs = 0;
+	int retried_reads = 0;
 	int found;
 
+	save_vg = NULL;
+	save_meta = NULL;
+	save_dev = NULL;
+	save_seqno = 0;
+
 	dm_list_init(&pvs_scan);
 	dm_list_init(&pvs_drop);
-	dm_list_init(&pvs_new);
 
-	log_debug_lvmetad("Rescanning VG %s (seqno %u).", vg->name, vg->seqno);
+	log_debug_lvmetad("Rescan VG %s to update lvmetad (seqno %u).", vg->name, vg->seqno);
 
 	/*
-	 * Another host may have added a PV to the VG, and some
-	 * commands do not always populate their lvmcache with
-	 * all devs from lvmetad, so they would fail to find
-	 * the new PV when scanning the VG.  So make sure this
-	 * command knows about all PVs from lvmetad.
+	 * Make sure this command knows about all PVs from lvmetad.
 	 */
 	lvmcache_seed_infos_from_lvmetad(cmd);
 
@@ -1841,54 +1872,111 @@ static struct volume_group *_lvmetad_pvscan_vg(struct cmd_context *cmd, struct v
 		dm_list_add(&pvs_scan, &devl->list);
 	}
 
-scan_more:
+	/*
+	 * Rescan labels/metadata only from devs that we previously
+	 * saw in the VG.  If we find below that there are new PVs
+	 * in the VG, we'll have to rescan all devices to find which
+	 * device(s) are now being used.
+	 */
+	log_debug_lvmetad("Rescan VG %s scanning data from devs in previous metadata.", vg->name);
+
+	label_scan_devs(cmd, &pvs_scan);
 
 	/*
-	 * Run the equivalent of lvmetad_pvscan_single on each dev in the VG.
+	 * Check if any pvs_scan entries are no longer PVs.
+	 * In that case, label_read/_find_label_header will have
+	 * found no label_header, and would have dropped the
+	 * info struct for the device from lvmcache.  So, if
+	 * we look up the info struct here and don't find it,
+	 * we can infer it's no longer a PV.
+	 *
+	 * FIXME: we should record specific results from the
+	 * label_read and then check specifically for whatever
+	 * result means "no label was found", rather than going
+	 * about this indirectly via the lvmcache side effects.
 	 */
 	dm_list_iterate_items_safe(devl, devlsafe, &pvs_scan) {
-		if (!devl->dev)
-			continue;
+		if (!(info = lvmcache_info_from_pvid(devl->dev->pvid, devl->dev, 0))) {
+			/* Another host removed this PV from the VG. */
+			log_debug_lvmetad("Rescan VG %s from %s dropping dev (no label).",
+					  vg->name, dev_name(devl->dev));
+			dm_list_move(&pvs_drop, &devl->list);
+		}
+	}
 
-		log_debug_lvmetad("Rescan VG %s scanning %s.", vg->name, dev_name(devl->dev));
+	fic.type = FMT_INSTANCE_MDAS | FMT_INSTANCE_AUX_MDAS;
+	fic.context.vg_ref.vg_name = vg->name;
+	fic.context.vg_ref.vg_id = vgid;
 
-		if (!label_read(devl->dev, &label, 0)) {
-			/* Another host removed this PV from the VG. */
-			log_debug_lvmetad("Rescan VG %s found %s was removed.", vg->name, dev_name(devl->dev));
+ retry_reads:
 
-			if ((info = lvmcache_info_from_pvid(devl->dev->pvid, NULL, 0)))
-				lvmcache_del(info);
+	if (!(fid = fmt->ops->create_instance(fmt, &fic))) {
+		/* FIXME: are there only internal reasons for failures here? */
+		log_error("Reading VG %s failed to create format instance.", vg->name);
+		return NULL;
+	}
 
-			dm_list_move(&pvs_drop, &devl->list);
-			continue;
-		}
+	/* FIXME: not sure if this is necessary */
+	fid->ref_count++;
 
-		info = (struct lvmcache_info *) label->info;
+	baton.fid = fid;
+	baton.cmd = cmd;
 
-		baton.vg = NULL;
-		baton.fid = lvmcache_fmt(info)->ops->create_instance(lvmcache_fmt(info), &fic);
-		if (!baton.fid)
-			return_NULL;
+	/*
+	 * FIXME: this vg_read path does not have the ability to repair
+	 * any problems with the VG, e.g. VG on one dev has an older
+	 * seqno.  When vg_read() is reworked, we need to fall back
+	 * to using that from here (and vg_read's from lvmetad) when
+	 * there is a problem.  Perhaps by disabling lvmetad when a
+	 * VG problem is detected, causing commands to fully fall
+	 * back to disk, which will repair the VG.  Then lvmetad can
+	 * be repopulated and re-enabled (possibly automatically.)
+	 */
 
-		if (baton.fid->fmt->features & FMT_OBSOLETE) {
-			log_debug_lvmetad("Ignoring obsolete format on PV %s in VG %s.", dev_name(devl->dev), vg->name);
-			lvmcache_fmt(info)->ops->destroy_instance(baton.fid);
+	/*
+	 * Do a low level vg_read on each dev, verify the vg returned
+	 * from metadata on each device is for the VG being read
+	 * (the PV may have been removed from the VG being read and
+	 * added to a different one), and return this vg to the caller
+	 * as the current vg to use.
+	 *
+	 * The label scan above will have saved in lvmcache which
+	 * vg each device is used in, so we could figure that part
+	 * out without doing the vg_read.
+	 */
+	dm_list_iterate_items_safe(devl, devlsafe, &pvs_scan) {
+		if (!devl->dev)
+			continue;
+
+		log_debug_lvmetad("Rescan VG %s getting metadata from %s.",
+				  vg->name, dev_name(devl->dev));
+
+		/*
+		 * The info struct for this dev knows what and where
+		 * the mdas are for this dev (the label scan saved
+		 * the mda locations for this dev on the lvmcache info struct).
+		 */
+		if (!(info = lvmcache_info_from_pvid(devl->dev->pvid, devl->dev, 0))) {
+			log_debug_lvmetad("Rescan VG %s from %s dropping dev (no info).",
+					  vg->name, dev_name(devl->dev));
 			dm_list_move(&pvs_drop, &devl->list);
 			continue;
 		}
 
+		baton.vg = NULL;
+
 		/*
 		 * Read VG metadata from this dev's mdas.
 		 */
-		lvmcache_foreach_mda(info, _lvmetad_pvscan_single, &baton);
+		lvmcache_foreach_mda(info, _lvmetad_pvscan_vg_single, &baton);
 
 		/*
 		 * The PV may have been removed from the VG by another host
 		 * since we last read the VG.
 		 */
 		if (!baton.vg) {
-			log_debug_lvmetad("Rescan VG %s did not find %s.", vg->name, dev_name(devl->dev));
-			lvmcache_fmt(info)->ops->destroy_instance(baton.fid);
+			log_debug_lvmetad("Rescan VG %s from %s dropping dev (no metadata).",
+					  vg->name, dev_name(devl->dev));
 			dm_list_move(&pvs_drop, &devl->list);
 			continue;
 		}
@@ -1898,10 +1986,15 @@ scan_more:
 		 * different VG since we last read the VG.
 		 */
 		if (strcmp(baton.vg->name, vg->name)) {
-			log_debug_lvmetad("Rescan VG %s found different VG %s on PV %s.",
-					  vg->name, baton.vg->name, dev_name(devl->dev));
+			log_debug_lvmetad("Rescan VG %s from %s dropping dev (other VG %s).",
+					  vg->name, dev_name(devl->dev), baton.vg->name);
+			release_vg(baton.vg);
+			continue;
+		}
+
+		if (!(vgmeta = export_vg_to_config_tree(baton.vg))) {
+			log_error("VG export to config tree failed");
 			release_vg(baton.vg);
-			dm_list_move(&pvs_drop, &devl->list);
 			continue;
 		}
 
@@ -1911,20 +2004,35 @@ scan_more:
 		 * read from each other dev.
 		 */
 
-		if (!save_seqno)
-			save_seqno = baton.vg->seqno;
-
-		if (!(vgmeta = export_vg_to_config_tree(baton.vg))) {
-			log_error("VG export to config tree failed");
-			release_vg(baton.vg);
-			return NULL;
+		if (save_vg && (save_seqno != baton.vg->seqno)) {
+			/* FIXME: fall back to vg_read to correct this. */
+			log_warn("WARNING: inconsistent metadata for VG %s on devices %s seqno %u and %s seqno %u.",
+				 vg->name, dev_name(save_dev), save_seqno,
+				 dev_name(devl->dev), baton.vg->seqno);
+			log_warn("WARNING: temporarily disable lvmetad to repair metadata.");
+
+			/* Use the most recent */
+			if (save_seqno < baton.vg->seqno) {
+				release_vg(save_vg);
+				dm_config_destroy(save_meta);
+				save_vg = baton.vg;
+				save_meta = vgmeta;
+				save_seqno = baton.vg->seqno;
+				save_dev = devl->dev;
+			} else {
+				release_vg(baton.vg);
+				dm_config_destroy(vgmeta);
+			}
+			continue;
 		}
 
-		if (!vgmeta_ret) {
-			vgmeta_ret = vgmeta;
+		if (!save_vg) {
+			save_vg = baton.vg;
+			save_meta = vgmeta;
+			save_seqno = baton.vg->seqno;
 			save_dev = devl->dev;
 		} else {
-			struct dm_config_node *meta1 = vgmeta_ret->root;
+			struct dm_config_node *meta1 = save_meta->root;
 			struct dm_config_node *meta2 = vgmeta->root;
 			struct dm_config_node *sib1 = meta1->sib;
 			struct dm_config_node *sib2 = meta2->sib;
@@ -1949,73 +2057,128 @@ scan_more:
 			meta2->sib = NULL;
 
 			if (compare_config(meta1, meta2)) {
+				/* FIXME: fall back to vg_read to correct this. */
+				log_warn("WARNING: inconsistent metadata for VG %s on devices %s seqno %u and %s seqno %u.",
+					 vg->name, dev_name(save_dev), save_seqno,
+					 dev_name(devl->dev), baton.vg->seqno);
+				log_warn("WARNING: temporarily disable lvmetad to repair metadata.");
 				log_error("VG %s metadata comparison failed for device %s vs %s",
 					  vg->name, dev_name(devl->dev), save_dev ? dev_name(save_dev) : "none");
-				_log_debug_inequality(vg->name, vgmeta_ret->root, vgmeta->root);
+				_log_debug_inequality(vg->name, save_meta->root, vgmeta->root);
 
 				meta1->sib = sib1;
 				meta2->sib = sib2;
-				dm_config_destroy(vgmeta);
-				dm_config_destroy(vgmeta_ret);
+
+				/* no right choice, just use the previous copy */
 				release_vg(baton.vg);
-				return NULL;
+				dm_config_destroy(vgmeta);
 			}
 			meta1->sib = sib1;
 			meta2->sib = sib2;
+			release_vg(baton.vg);
 			dm_config_destroy(vgmeta);
 		}
+	}
 
-		/*
-		 * Look for any new PVs in the VG metadata that were not in our
-		 * previous version of the VG.  Add them to pvs_new to be
-		 * scanned in this loop just like the old PVs.
-		 */
-		if (!check_new_pvs) {
-			check_new_pvs = 1;
-			dm_list_iterate_items(pvl_new, &baton.vg->pvs) {
-				found = 0;
-				dm_list_iterate_items(pvl, &vg->pvs) {
-					if (pvl_new->pv->dev != pvl->pv->dev)
-						continue;
-					found = 1;
-					break;
-				}
-				if (found)
-					continue;
-				if (!pvl_new->pv->dev) {
-					strncpy(pvid_s, (char *) &pvl_new->pv->id, sizeof(pvid_s) - 1);
-					if (!id_write_format((const struct id *)&pvid_s, uuid, sizeof(uuid)))
-						stack;
-					log_error("Device not found for PV %s in VG %s", uuid, vg->name);
-					missing_devs++;
+	/* FIXME: see above */
+	fid->ref_count--;
+
+	/*
+	 * Look for any new PVs in the VG metadata that were not in our
+	 * previous version of the VG.
+	 *
+	 * (Don't look for new PVs after a rescan and retry.)
+	 */
+	found_new_pvs = 0;
+
+	if (save_vg && !retried_reads) {
+		dm_list_iterate_items(pvl_new, &save_vg->pvs) {
+			found = 0;
+			dm_list_iterate_items(pvl, &vg->pvs) {
+				if (pvl_new->pv->dev != pvl->pv->dev)
 					continue;
-				}
-				if (!(devl_new = dm_pool_zalloc(cmd->mem, sizeof(*devl_new))))
-					return_NULL;
-				devl_new->dev = pvl_new->pv->dev;
-				dm_list_add(&pvs_new, &devl_new->list);
-				log_debug_lvmetad("Rescan VG %s found %s was added.", vg->name, dev_name(devl_new->dev));
+				found = 1;
+				break;
+			}
+
+			/*
+			 * PV in new VG metadata not found in old VG metadata.
+			 * There's a good chance we don't know about this new
+			 * PV or what device it's on; a label scan is needed
+			 * of all devices so we know which device the VG is
+			 * now using.
+			 */
+			if (!found) {
+				found_new_pvs++;
+				strncpy(pvid_s, (char *) &pvl_new->pv->id, sizeof(pvid_s) - 1);
+				if (!id_write_format((const struct id *)&pvid_s, uuid, sizeof(uuid)))
+					stack;
+				log_debug_lvmetad("Rescan VG %s found new PV %s.", vg->name, uuid);
 			}
 		}
+	}
 
-		release_vg(baton.vg);
+	if (!save_vg && retried_reads) {
+		log_error("VG %s not found after rescanning devices.", vg->name);
+		goto out;
 	}
 
 	/*
-	 * Do the same scanning above for any new PVs.
+	 * Do a full rescan of devices, then look up which devices the
+	 * scan found for this VG name, and select those devices to
+	 * read metadata from in the loop above (rather than the list
+	 * of devices we created from our last copy of the vg metadata.)
+	 *
+	 * Case 1: VG we knew is no longer on any of the devices we knew it
+	 * to be on (save_vg is NULL, which means the metadata wasn't found
+	 * when reading mdas on each of the initial pvs_scan devices).
+	 * Rescan all devs and then retry reading metadata from the devs that
+	 * the scan finds associated with this VG.
+	 *
+	 * Case 2: VG has new PVs but we don't know what devices they are
+	 * so rescan all devs and then retry reading metadata from the devs
+	 * that the scan finds associated with this VG.
+	 *
+	 * (N.B. after a retry, we don't check for found_new_pvs.)
 	 */
-	if (!dm_list_empty(&pvs_new)) {
+	if (!save_vg || found_new_pvs) {
+		if (!save_vg)
+			log_debug_lvmetad("Rescan VG %s did not find VG on previous devs.", vg->name);
+		if (found_new_pvs)
+			log_debug_lvmetad("Rescan VG %s scanning all devs to find new PVs.", vg->name);
+
+		label_scan(cmd);
+
+		if (!(vginfo = lvmcache_vginfo_from_vgname(vg->name, NULL))) {
+			log_error("VG %s vg info not found after rescanning devices.", vg->name);
+			goto out;
+		}
+
+		/*
+		 * Set pvs_scan to devs that the label scan found
+		 * in the VG and retry the metadata reading loop.
+		 */
 		dm_list_init(&pvs_scan);
-		dm_list_splice(&pvs_scan, &pvs_new);
-		dm_list_init(&pvs_new);
-		log_debug_lvmetad("Rescan VG %s found new PVs to scan.", vg->name);
-		goto scan_more;
-	}
 
-	if (missing_devs) {
-		if (vgmeta_ret)
-			dm_config_destroy(vgmeta_ret);
-		return_NULL;
+		if (!lvmcache_get_vg_devs(cmd, vginfo, &pvs_scan)) {
+			log_error("VG %s info devs not found after rescanning devices.", vg->name);
+			goto out;
+		}
+
+		log_debug_lvmetad("Rescan VG %s has %d PVs after label scan.",
+				  vg->name, dm_list_size(&pvs_scan));
+
+		if (save_vg)
+			release_vg(save_vg);
+		if (save_meta)
+			dm_config_destroy(save_meta);
+		save_vg = NULL;
+		save_meta = NULL;
+		save_dev = NULL;
+		save_seqno = 0;
+		found_new_pvs = 0;
+		retried_reads = 1;
+		goto retry_reads;
 	}
 
 	/*
@@ -2024,52 +2187,50 @@ scan_more:
 	dm_list_iterate_items(devl, &pvs_drop) {
 		if (!devl->dev)
 			continue;
-		log_debug_lvmetad("Rescan VG %s dropping %s.", vg->name, dev_name(devl->dev));
-		if (!lvmetad_pv_gone_by_dev(devl->dev))
-			return_NULL;
+		log_debug_lvmetad("Rescan VG %s removing %s from lvmetad.", vg->name, dev_name(devl->dev));
+		if (!lvmetad_pv_gone_by_dev(devl->dev)) {
+			/* FIXME: use an error path that disables lvmetad */
+			log_error("Failed to remove %s from lvmetad.", dev_name(devl->dev));
+		}
 	}
 
 	/*
-	 * Update the VG in lvmetad.
+	 * Update lvmetad with the newly read version of the VG.
+	 * When the seqno is unchanged the cached VG can be left.
 	 */
-	if (vgmeta_ret) {
-		fid = lvmcache_fmt(info)->ops->create_instance(lvmcache_fmt(info), &fic);
-		if (!(vg_ret = import_vg_from_config_tree(vgmeta_ret, fid))) {
-			log_error("VG import from config tree failed");
-			lvmcache_fmt(info)->ops->destroy_instance(fid);
-			goto out;
+	if (save_vg && (save_seqno != vg->seqno)) {
+		dm_list_iterate_items(devl, &pvs_scan) {
+			if (!devl->dev)
+				continue;
+			log_debug_lvmetad("Rescan VG %s removing %s from lvmetad to replace.",
+					  vg->name, dev_name(devl->dev));
+			if (!lvmetad_pv_gone_by_dev(devl->dev)) {
+				/* FIXME: use an error path that disables lvmetad */
+				log_error("Failed to remove %s from lvmetad.", dev_name(devl->dev));
+			}
 		}
 
+		log_debug_lvmetad("Rescan VG %s updating lvmetad from seqno %u to seqno %u.",
+				  vg->name, vg->seqno, save_seqno);
+
 		/*
-		 * Update lvmetad with the newly read version of the VG.
-		 * When the seqno is unchanged the cached VG can be left.
+		 * If this vg_update fails the cached metadata in
+		 * lvmetad will remain invalid.
 		 */
-		if (save_seqno != vg->seqno) {
-			dm_list_iterate_items(devl, &pvs_scan) {
-				if (!devl->dev)
-					continue;
-				log_debug_lvmetad("Rescan VG %s dropping to replace %s.", vg->name, dev_name(devl->dev));
-				if (!lvmetad_pv_gone_by_dev(devl->dev))
-					return_NULL;
-			}
-
-			log_debug_lvmetad("Rescan VG %s updating lvmetad from seqno %u to seqno %u.",
-					  vg->name, vg->seqno, save_seqno);
-
-			/*
-			 * If this vg_update fails the cached metadata in
-			 * lvmetad will remain invalid.
-			 */
-			vg_ret->lvmetad_update_pending = 1;
-			if (!lvmetad_vg_update_finish(vg_ret))
-				log_error("Failed to update lvmetad with new VG meta");
+		save_vg->lvmetad_update_pending = 1;
+		if (!lvmetad_vg_update_finish(save_vg)) {
+			/* FIXME: use an error path that disables lvmetad */
+			log_error("Failed to update lvmetad with new VG meta");
 		}
-		dm_config_destroy(vgmeta_ret);
 	}
 out:
-	if (vg_ret)
-		log_debug_lvmetad("Rescan VG %s done (seqno %u).", vg_ret->name, vg_ret->seqno);
-	return vg_ret;
+	if (!save_vg && fid)
+		fmt->ops->destroy_instance(fid);
+	if (save_meta)
+		dm_config_destroy(save_meta);
+	if (save_vg)
+		log_debug_lvmetad("Rescan VG %s done (new seqno %u).", save_vg->name, save_vg->seqno);
+	return save_vg;
 }
 
 int lvmetad_pvscan_single(struct cmd_context *cmd, struct device *dev,


