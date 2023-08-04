From: David Teigland (@teigland) <gitlab@mg.gitlab.com>
Date: Fri, 04 Aug 2023 16:46:11 +0000
Subject: [Git][lvmteam/lvm2][main] device_id: rewrite validation of devname entries
Message-ID: <64cd2b53b82d3_28a4844573a@gitlab-sidekiq-low-urgency-cpu-bound-v2-6d5cc6f957-ddz89.mail>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit



David Teigland pushed to branch main at LVM team / lvm2


Commits:
847f1dd9 by David Teigland at 2023-08-04T11:45:40-05:00
device_id: rewrite validation of devname entries

The old approach was too complicated and didn&#39;t work correctly
in some cases.

- - - - -


4 changed files:

- lib/device/dev-cache.c
- lib/device/dev-cache.h
- lib/device/device_id.c
- test/shell/devicesfile-devname.sh


Changes:

=====================================
lib/device/dev-cache.c
=====================================
@@ -1652,6 +1652,23 @@ struct device *dev_cache_get_by_devt(struct cmd_context *cmd, dev_t devt)
 	return NULL;
 }
 
+struct device *dev_cache_get_by_pvid(struct cmd_context *cmd, const char *pvid)
+{
+	struct btree_iter *iter = btree_first(_cache.devices);
+	struct device *dev;
+
+	while (iter) {
+		dev = btree_get_data(iter);
+
+		if (!memcmp(dev->pvid, pvid, ID_LEN))
+			return dev;
+
+		iter = btree_next(iter);
+	}
+
+	return NULL;
+}
+
 struct dev_iter *dev_iter_create(struct dev_filter *f, int unused)
 {
 	struct dev_iter *di = malloc(sizeof(*di));


=====================================
lib/device/dev-cache.h
=====================================
@@ -55,6 +55,7 @@ int dev_cache_add_dir(const char *path);
 struct device *dev_cache_get(struct cmd_context *cmd, const char *name, struct dev_filter *f);
 struct device *dev_cache_get_existing(struct cmd_context *cmd, const char *name, struct dev_filter *f);
 struct device *dev_cache_get_by_devt(struct cmd_context *cmd, dev_t devt);
+struct device *dev_cache_get_by_pvid(struct cmd_context *cmd, const char *pvid);
 void dev_cache_verify_aliases(struct device *dev);
 
 struct device *dev_hash_get(const char *name);


=====================================
lib/device/device_id.c
=====================================
@@ -2288,7 +2288,9 @@ void device_ids_validate(struct cmd_context *cmd, struct dm_list *scanned_devs,
 	struct dm_list wrong_devs;
 	struct device *dev;
 	struct device_list *devl;
-	struct dev_use *du;
+	struct dev_use *du, *du2;
+	struct dev_id *id;
+	const char *devname;
 	char *tmpdup;
 	int checked = 0;
 	int update_file = 0;
@@ -2404,64 +2406,41 @@ void device_ids_validate(struct cmd_context *cmd, struct dm_list *scanned_devs,
 	}
 
 	/*
-	 * Validate entries with unreliable devname id type.
-	 * pvid match overrides devname id match.
+	 * Validate entries with DEVNAME device id type.
+	 * pvid is the authority for pairing du and dev.
 	 */
 	dm_list_iterate_items(du, &cmd->use_devices) {
-		if (!du->dev)
-			continue;
-
 		if (du->idtype != DEV_ID_TYPE_DEVNAME)
 			continue;
 
-		dev = du->dev;
-
-		/*
-		 * scanned_devs are the devices that have been scanned,
-		 * so they are the only devs we can verify PVID for.
-		 */
-		if (scanned_devs && !device_list_find_dev(scanned_devs, dev))
-			continue;
-
-		/*
-		 * The matched device could not be read so we do not have
-		 * the PVID from disk and cannot verify the devices file entry.
-		 */
-		if (dev->flags & DEV_SCAN_NOT_READ)
-			continue;
-
-		if (dm_list_empty(&dev->aliases))
-			continue;
-
-		if (!cmd->filter->passes_filter(cmd, cmd->filter, dev, "persistent")) {
-			log_warn("Devices file %s is excluded: %s.",
-				 dev_name(dev), dev_filtered_reason(dev));
-			/* FIXME: what if this dev is wrongly matched and should be checked below? */
-			continue;
-		}
-
-		if (!du->pvid || du->pvid[0] == '.')
+		if (!du->pvid)
 			continue;
 
 		checked++;
 
-		/*
-		 * A good match based on pvid.
+		/* 
+		 * Correctly matched du and dev.
+		 * The DEVNAME hint could still need an update.
 		 */
-		if (dev->pvid[0] && !memcmp(dev->pvid, du->pvid, ID_LEN)) {
-			const char *devname = dev_name(dev);
+		if (du->dev && !memcmp(du->dev->pvid, du->pvid, ID_LEN)) {
+			devname = dev_name(du->dev);
 
-			if (strcmp(devname, du->idname)) {
-				/* shouldn't happen since this was basis for match */
-				log_error("du for pvid %s unexpected idname %s mismatch dev %s",
-					  du->pvid, du->idname, devname);
+			/* This shouldn't happen since idname was used to match du and dev */
+			if (!du->idname || strcmp(devname, du->idname)) {
+				log_warn("WARNING: fixing devices file IDNAME %s for PVID %s device %s",
+					  du->idname ?: ".", du->pvid, dev_name(dev));
+				if (!(tmpdup = strdup(devname)))
+					continue;
+				free(du->idname);
+				du->idname = tmpdup;
+				update_file = 1;
 				*device_ids_invalid = 1;
-				continue;
 			}
 
+			/* Fix the DEVNAME field if it's outdated, not generally expected */
 			if (!du->devname || strcmp(devname, du->devname)) {
-				log_warn("Device %s has updated name (devices file %s)",
-					 devname, du->devname ?: "none");
+				log_debug("Updating outdated DEVNAME from %s to %s for PVID %s",
+					  du->devname ?: ".", devname, du->pvid);
 				if (!(tmpdup = strdup(devname)))
 					continue;
 				free(du->devname);
@@ -2473,46 +2452,123 @@ void device_ids_validate(struct cmd_context *cmd, struct dm_list *scanned_devs,
 		}
 
 		/*
-		 * An incorrect match, the pvid read from dev does not match
-		 * du->pvid for the du dev was matched to.
-		 * du->idname is wrong, du->devname is probably wrong.
-		 * undo the incorrect match between du and dev
+		 * Incorrectly matched du and dev (or unable to confirm the
+		 * match).  Disassociate the dev from the du.  If wrong_devs
+		 * are not paired to any du at the end, then those devs are
+		 * cleared from lvmcache, since we don't want the command to
+		 * see or use devs not included in the devices file.
 		 */
-
-		if (dev->pvid[0])
-			log_warn("Devices file PVID %s not found on device %s (device PVID %s).",
-				 du->pvid, dev_name(dev), dev->pvid[0] ? dev->pvid : "none");
-		else
-			log_warn("Devices file PVID %s not found on device %s.",
-				 du->pvid, dev_name(dev));
-
-		if ((devl = dm_pool_zalloc(cmd->mem, sizeof(*devl)))) {
-			/* If this dev matches no du, drop it at the end. */
-			devl->dev = dev;
-			dm_list_add(&wrong_devs, &devl->list);
+		if (du->dev) {
+			if ((devl = dm_pool_zalloc(cmd->mem, sizeof(*devl)))) {
+				devl->dev = du->dev;
+				dm_list_add(&wrong_devs, &devl->list);
+			}
+			log_debug("Drop match for %s and %s.", dev_name(du->dev), du->pvid);
+			du->dev->flags &= ~DEV_MATCHED_USE_ID;
+			du->dev->id = NULL;
+			du->dev = NULL;
 		}
 
-		if (du->idname) {
+		/*
+		 * Find a new dev that matches du, using the devs that have
+		 * been scanned for a label so far.  The identity of this du is
+		 * it's pvid, the dev is variable, so if another dev has this
+		 * pvid, then reset all the du values to correspond to the new
+		 * dev.
+		 */
+		if ((dev = dev_cache_get_by_pvid(cmd, du->pvid))) {
+			char *dup_devname1, *dup_devname2, *dup_devname3;
+
+			devname = dev_name(dev);
+
+			log_print("Devices file PVID %s is now on %s.", du->pvid, devname);
+
+			dup_devname1 = strdup(devname);
+			dup_devname2 = strdup(devname);
+			dup_devname3 = strdup(devname);
+			id = zalloc(sizeof(struct dev_id));
+			if (!dup_devname1 || !dup_devname2 || !dup_devname3 || !id) {
+				free(dup_devname1);
+				free(dup_devname2);
+				free(dup_devname3);
+				free(id);
+				stack;
+				continue;
+			}
+
 			free(du->idname);
-			du->idname = NULL;
+			free(du->devname);
+			free_dids(&dev->ids);
+
+			du->idname = dup_devname1;
+			du->devname = dup_devname2;
+			id->idname = dup_devname3;
+			id->dev = dev;
+			du->dev = dev;
+			dev->id = id;
+			dev->flags |= DEV_MATCHED_USE_ID;
+			dm_list_add(&dev->ids, &id->list);
+			dev_get_partition_number(dev, &du->part);
+			update_file = 1;
+			*device_ids_invalid = 1;
+			continue;
 		}
+	}
 
-		/*
-		 * Keep the old devname hint in place to preserve some clue about
-		 * the previous location of the PV which may help the user understand
-		 * what happened.
-		 */
-		/*
-		if (du->devname) {
+	/*
+	 * Each remaining du that's not matched to a dev (no du->dev set) is
+	 * subject to device_ids_find_renamed_devs which will look for
+	 * unmatched pvids on devs that have not been scanned yet.
+	 */
+	dm_list_iterate_items(du, &cmd->use_devices) {
+		if (du->idtype != DEV_ID_TYPE_DEVNAME)
+			continue;
+		if (!du->pvid)
+			continue;
+		if (du->dev)
+			continue;
+		log_debug("Search needed to find device with PVID %s.", du->pvid);
+	}
+
+	/*
+	 * For each du with no matching dev, if du->pvid is being used in
+	 * another entry with a properly matching dev, then clear du->pvid.
+	 */
+	dm_list_iterate_items(du, &cmd->use_devices) {
+		if (du->idtype != DEV_ID_TYPE_DEVNAME)
+			continue;
+		if (!du->pvid)
+			continue;
+		if (du->dev)
+			continue;
+
+		dm_list_iterate_items(du2, &cmd->use_devices) {
+			if (du == du2)
+				continue;
+			if (du2->idtype != DEV_ID_TYPE_DEVNAME)
+				continue;
+			if (!du2->pvid)
+				continue;
+			if (!du2->dev)
+				continue;
+			if (memcmp(du->pvid, du2->pvid, ID_LEN))
+				continue;
+
+			/*
+			 * du2 is correctly matched to a dev using this pvid,
+			 * so drop the pvid from du.
+			 * TOOD: it would make sense to clear IDNAME, but
+			 * can we handle entries with no IDNAME?
+			 */
+			log_debug("Device %s no longer has PVID %s.", dev_name(du->dev), du->pvid);
+			free(du->pvid);
 			free(du->devname);
+			du->pvid = NULL;
 			du->devname = NULL;
+			update_file = 1;
+			*device_ids_invalid = 1;
+			break;
 		}
-		*/
-		dev->flags &= ~DEV_MATCHED_USE_ID;
-		dev->id = NULL;
-		du->dev = NULL;
-		update_file = 1;
-		*device_ids_invalid = 1;
 	}
 
 	/*
@@ -2527,6 +2583,43 @@ void device_ids_validate(struct cmd_context *cmd, struct dm_list *scanned_devs,
 		}
 	}
 
+	/*
+	 * When dev names change and a PVID is found on a new device, there
+	 * could be an another devname entry with the same device name but a
+	 * blank PVID, which we remove here.
+	 */
+	dm_list_iterate_items(du, &cmd->use_devices) {
+		if (du->idtype != DEV_ID_TYPE_DEVNAME)
+			continue;
+		if (!du->idname)
+			continue;
+		if (!du->pvid)
+			continue;
+		if (!du->dev)
+			continue;
+		dm_list_iterate_items(du2, &cmd->use_devices) {
+			if (du == du2)
+				continue;
+			if (du2->idtype != DEV_ID_TYPE_DEVNAME)
+				continue;
+			if (!du2->idname)
+				continue;
+			if (strcmp(du->idname, du2->idname))
+				continue;
+
+			log_debug("Repeated idname %s pvids %s %s",
+				  du->idname, du->pvid ?: ".", du2->pvid ?: ".");
+
+			if (!du2->pvid) {
+				dm_list_del(&du2->list);
+				free_du(du2);
+				update_file = 1;
+				*device_ids_invalid = 1;
+			}
+			break;
+		}
+	}
+
 	/*
 	 * Check for other problems for which we want to set *device_ids_invalid,
 	 * even if we don't have a way to fix them right here.  In particular,
@@ -2894,17 +2987,11 @@ void device_ids_find_renamed_devs(struct cmd_context *cmd, struct dm_list *dev_l
 	search_auto = !strcmp(cmd->search_for_devnames, "auto");
 
 	dm_list_iterate_items(du, &cmd->use_devices) {
-		if (!du->pvid)
-			continue;
 		if (du->idtype != DEV_ID_TYPE_DEVNAME)
 			continue;
-
-		/*
-		 * if the old incorrect devname is now a device that's
-		 * filtered and not scanned, e.g. an mpath component,
-		 * then we want to look for the pvid on a new device.
-		 */
-		if (du->dev && !du->dev->filtered_flags)
+		if (!du->pvid)
+			continue;
+		if (du->dev)
 			continue;
 
 		if (!(dil = dm_pool_zalloc(cmd->mem, sizeof(*dil))))


=====================================
test/shell/devicesfile-devname.sh
=====================================
@@ -552,6 +552,53 @@ vgchange -an $vg2
 vgremove -ff $vg1
 vgremove -ff $vg2
 
+# bz 2225419
+
+touch "$DF"
+vgcreate $vg1 "$dev1"
+vgcreate $vg2 "$dev2"
+
+# PVID with dashes for matching pvs -o+uuid output
+OPVID1=`pvs "$dev1" --noheading -o uuid | awk '{print $1}'`
+OPVID2=`pvs "$dev2" --noheading -o uuid | awk '{print $1}'`
+# PVID without dashes for matching devices file fields
+PVID1=`pvs "$dev1" --noheading -o uuid | tr -d - | awk '{print $1}'`
+PVID2=`pvs "$dev2" --noheading -o uuid | tr -d - | awk '{print $1}'`
+
+NODEV=${dev1}12345
+
+lvmdevices --deldev "$dev1"
+lvmdevices --deldev "$dev2"
+
+# dev1 is correct
+echo "IDTYPE=devname IDNAME=$dev1 DEVNAME=$dev1 PVID=$PVID1" >> "$DF"
+# dev2 has no PVID
+echo "IDTYPE=devname IDNAME=$dev2 DEVNAME=$dev2 PVID=." >> "$DF"
+# Non-existant device has PVID for dev2
+echo "IDTYPE=devname IDNAME=$NODEV DEVNAME=$NODEV PVID=$PVID2" >> "$DF"
+
+cat "$DF"
+
+pvs -o name,uuid |tee out
+
+grep "$dev1" out | tee out1
+grep "$dev2" out | tee out2
+grep "$OPVID1" out1
+grep "$OPVID2" out2
+not grep "$NODEV" out
+
+not grep "$NODEV" "$DF"
+grep "IDNAME=$dev1" "$DF" | tee out1
+grep "IDNAME=$dev2" "$DF" | tee out2
+grep "$PVID1" out1
+grep "$PVID2" out2
+grep "DEVNAME=$dev1" out1
+grep "DEVNAME=$dev2" out2
+
+rm "$DF"
+aux wipefs_a "$dev1" "$dev2"
+
+
 # bz 2119473
 
 aux lvmconf "devices/search_for_devnames = \"none\""



View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/commit/847f1dd99cb74dac37c1379627fa5d2d52250fa6

-- 
View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/commit/847f1dd99cb74dac37c1379627fa5d2d52250fa6
You're receiving this email because of your account on gitlab.com.


-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20230804/04fb93f7/attachment-0001.htm>
