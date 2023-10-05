From: David Teigland (@teigland) <gitlab@mg.gitlab.com>
Date: Thu, 05 Oct 2023 20:34:13 +0000
Subject: [Git][lvmteam/lvm2][main] device_id: fix conditions for device_ids_refresh
Message-ID: <651f1dc5a3664_2aa566851195@gitlab-sidekiq-low-urgency-cpu-bound-v2-7b894487c4-7nq7j.mail>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit



David Teigland pushed to branch main at LVM team / lvm2


Commits:
1901a47d by David Teigland at 2023-10-05T15:33:55-05:00
device_id: fix conditions for device_ids_refresh

Fix commit 847f1dd99cb74
&quot;device_id: rewrite validation of devname entries&quot;

which began calling device_ids_refresh() in cases where it
was unnecessary, leading to extra PV searches and warnings.
Specifically, a command like &quot;lvs &lt;vg&gt;&quot; would use the hints
file to scan only devices for the named VG.  This means that
scanning other PVs would be skipped, and device IDs of those
PVs could not be validated because there are no PVID values
to verify.  This missing info would cause messages about
the missing info, and would cause device_ids_refresh to
search for the PVs that had been intentionally skipped.

- - - - -


6 changed files:

- lib/cache/lvmcache.c
- lib/commands/toolcontext.h
- lib/device/device_id.c
- lib/device/device_id.h
- lib/label/label.c
- tools/lvmdevices.c


Changes:

=====================================
lib/cache/lvmcache.c
=====================================
@@ -1597,12 +1597,9 @@ int lvmcache_label_scan(struct cmd_context *cmd)
 {
 	struct dm_list del_cache_devs;
 	struct dm_list add_cache_devs;
-	struct dm_list renamed_devs;
 	struct lvmcache_info *info;
 	struct device_list *devl;
 
-	dm_list_init(&renamed_devs);
-
 	log_debug_cache("lvmcache label scan begin");
 
 	/*
@@ -1636,19 +1633,37 @@ int lvmcache_label_scan(struct cmd_context *cmd)
 	}
 
 	/*
-	 * When devnames are used as device ids (which is dispreferred),
-	 * changing/unstable devnames can lead to entries in the devices file
-	 * not being matched to a dev even if the PV is present on the system.
-	 * Or, a devices file entry may have been matched to the wrong device
-	 * (with the previous name) that does not have the PVID specified in
-	 * the entry.  This function detects that problem, scans labels on all
-	 * devs on the system to find the missing PVIDs, and corrects the
-	 * devices file.  We then need to run label scan on these correct
-	 * devices.
+	 * device_ids_invalid is set by device_ids_validate() when there
+	 * are entries in the devices file that need to be corrected,
+	 * i.e. device IDs read from the system and/or PVIDs read from
+	 * disk do not match info in the devices file.  This is usually
+	 * related to incorrect device names which routinely change on
+	 * reboot.  When device names change for entries that use
+	 * IDTYPE=devname, it often means that all devs on the system
+	 * need to be scanned to find the new device for the PVIDs.
+	 * device_ids_validate() will update the devices file to correct
+	 * some info, but to locate new devices for PVIDs, it defers
+	 * to device_ids_refresh() which involves label scanning.
+	 *
+	 * device_ids_refresh_trigger is set by device_ids_read() when
+	 * it sees that the local machine doesn't match the machine
+	 * that wrote the devices file, and device IDs of all types
+	 * may need to be replaced for the PVIDs in the devices file.
+	 * This also means that all devs on the system need to be
+	 * scanned to find the new devices for the PVIDs.
+	 *
+	 * When device_ids_refresh() locates the correct devices
+	 * for the PVs in the devices file, it returns those new
+	 * devices in the refresh_devs list.  Those devs need to
+	 * be passed to label_scan to populate lvmcache info.
 	 */
-	device_ids_refresh(cmd, &renamed_devs, NULL, 0);
-	if (!dm_list_empty(&renamed_devs))
-		label_scan_devs(cmd, cmd->filter, &renamed_devs);
+	if (cmd->device_ids_invalid || cmd->device_ids_refresh_trigger) {
+		struct dm_list refresh_devs;
+		dm_list_init(&refresh_devs);
+		device_ids_refresh(cmd, &refresh_devs, NULL, 0);
+		if (!dm_list_empty(&refresh_devs))
+			label_scan_devs(cmd, cmd->filter, &refresh_devs);
+	}
 
 	/*
 	 * _choose_duplicates() returns:


=====================================
lib/commands/toolcontext.h
=====================================
@@ -213,6 +213,7 @@ struct cmd_context {
 	unsigned device_ids_check_product_uuid:1;
 	unsigned device_ids_check_hostname:1;
 	unsigned device_ids_refresh_trigger:1;
+	unsigned device_ids_invalid:1;
 
 	/*
 	 * Devices and filtering.


=====================================
lib/device/device_id.c
=====================================
@@ -2177,7 +2177,7 @@ void device_ids_match(struct cmd_context *cmd)
 	if (!cmd->enable_devices_file)
 		return;
 
-	log_debug("compare devices file entries to devices");
+	log_debug("Matching devices file entries to devices");
 
 	/*
 	 * We would set cmd->filter_deviceid_skip but we are disabling
@@ -2342,8 +2342,7 @@ static void _get_devs_with_serial_numbers(struct cmd_context *cmd, struct dm_lis
  * use_devices entries from the devices file.
  */
 
-void device_ids_validate(struct cmd_context *cmd, struct dm_list *scanned_devs,
-			 int *device_ids_invalid, int noupdate)
+void device_ids_validate(struct cmd_context *cmd, struct dm_list *scanned_devs, int noupdate)
 {
 	struct dm_list wrong_devs;
 	struct device *dev = NULL;
@@ -2352,11 +2351,12 @@ void device_ids_validate(struct cmd_context *cmd, struct dm_list *scanned_devs,
 	struct dev_id *id;
 	const char *devname;
 	char *tmpdup;
-	int checked = 0;
 	int update_file = 0;
 
 	dm_list_init(&wrong_devs);
 
+	cmd->device_ids_invalid = 0;
+
 	if (!cmd->enable_devices_file)
 		return;
 
@@ -2410,8 +2410,6 @@ void device_ids_validate(struct cmd_context *cmd, struct dm_list *scanned_devs,
 			continue;
 		}
 
-		checked++;
-
 		/*
 		 * If the PVID doesn't match, don't assume that the serial
 		 * number is correct, since serial numbers may not be unique.
@@ -2425,7 +2423,7 @@ void device_ids_validate(struct cmd_context *cmd, struct dm_list *scanned_devs,
 			log_debug("suspect device id serial %s for %s", du->idname, dev_name(dev));
 			if (!str_list_add(cmd->mem, &cmd->device_ids_check_serial, dm_pool_strdup(cmd->mem, du->idname)))
 				stack;
-			*device_ids_invalid = 1;
+			cmd->device_ids_invalid = 1;
 			continue;
 		}
 
@@ -2446,7 +2444,7 @@ void device_ids_validate(struct cmd_context *cmd, struct dm_list *scanned_devs,
 				free(du->pvid);
 				du->pvid = tmpdup;
 				update_file = 1;
-				*device_ids_invalid = 1;
+				cmd->device_ids_invalid = 1;
 			}
 		} else {
 			if (du->pvid && (du->pvid[0] != '.')) {
@@ -2458,7 +2456,7 @@ void device_ids_validate(struct cmd_context *cmd, struct dm_list *scanned_devs,
 				free(du->pvid);
 				du->pvid = NULL;
 				update_file = 1;
-				*device_ids_invalid = 1;
+				cmd->device_ids_invalid = 1;
 			}
 		}
 
@@ -2476,14 +2474,15 @@ void device_ids_validate(struct cmd_context *cmd, struct dm_list *scanned_devs,
 			continue;
 
 		if (!du->devname || strcmp(dev_name(du->dev), du->devname)) {
-			log_warn("Device %s has updated name (devices file %s)",
-				 dev_name(du->dev), du->devname ?: "none");
+			log_debug("Validate %s %s PVID %s on %s: outdated DEVNAME %s",
+				  idtype_to_str(du->idtype), du->idname ?: ".", du->pvid ?: ".",
+				  dev_name(dev), du->devname ?: "none");
 			if (!(tmpdup = strdup(dev_name(du->dev))))
 				continue;
 			free(du->devname);
 			du->devname = tmpdup;
 			update_file = 1;
-			*device_ids_invalid = 1;
+			cmd->device_ids_invalid = 1;
 		}
 	}
 
@@ -2498,15 +2497,17 @@ void device_ids_validate(struct cmd_context *cmd, struct dm_list *scanned_devs,
 		if (!du->pvid)
 			continue;
 
-		checked++;
-
 		/* 
 		 * Correctly matched du and dev.
 		 * The DEVNAME hint could still need an update.
 		 */
 		if (du->dev && !memcmp(du->dev->pvid, du->pvid, ID_LEN)) {
+			dev = du->dev;
 			devname = dev_name(du->dev);
 
+			log_debug("Validate %s %s PVID %s on %s: correct",
+				  idtype_to_str(du->idtype), du->idname ?: ".", du->pvid ?: ".", devname);
+
 			/* This shouldn't happen since idname was used to match du and dev */
 			if (!du->idname || strcmp(devname, du->idname)) {
 				log_warn("WARNING: fixing devices file IDNAME %s for PVID %s device %s",
@@ -2516,7 +2517,7 @@ void device_ids_validate(struct cmd_context *cmd, struct dm_list *scanned_devs,
 				free(du->idname);
 				du->idname = tmpdup;
 				update_file = 1;
-				*device_ids_invalid = 1;
+				cmd->device_ids_invalid = 1;
 			}
 
 			/* Fix the DEVNAME field if it's outdated, not generally expected */
@@ -2528,24 +2529,35 @@ void device_ids_validate(struct cmd_context *cmd, struct dm_list *scanned_devs,
 				free(du->devname);
 				du->devname = tmpdup;
 				update_file = 1;
-				*device_ids_invalid = 1;
+				cmd->device_ids_invalid = 1;
 			}
 			continue;
 		}
 
 		/*
-		 * Incorrectly matched du and dev (or unable to confirm the
-		 * match).  Disassociate the dev from the du.  If wrong_devs
-		 * are not paired to any du at the end, then those devs are
-		 * cleared from lvmcache, since we don't want the command to
-		 * see or use devs not included in the devices file.
+		 * Incorrectly matched du and dev, or unconfirmed match due to
+		 * the dev not being scanned/read (so we don't know the PVID the dev.)
+		 * Disassociate the dev from the du.  If wrong_devs are not paired to
+		 * any du at the end, then those devs are cleared from lvmcache,
+		 * since we don't want the command to see or use devs not included
+		 * in the devices file.
 		 */
 		if (du->dev) {
-			if ((devl = dm_pool_zalloc(cmd->mem, sizeof(*devl)))) {
-				devl->dev = du->dev;
-				dm_list_add(&wrong_devs, &devl->list);
+			dev = du->dev;
+			devname = dev_name(du->dev);
+
+			if (!device_list_find_dev(scanned_devs, du->dev) || (du->dev->flags & DEV_SCAN_NOT_READ)) {
+				log_debug("Validate %s %s PVID %s on %s: not scanned",
+					  idtype_to_str(du->idtype), du->idname ?: ".", du->pvid ?: ".", devname);
+			} else {
+				log_debug("Validate %s %s PVID %s on %s: wrong PVID %s.",
+					idtype_to_str(du->idtype), du->idname ?: ".", du->pvid ?: ".", devname, dev->pvid);
+				if ((devl = dm_pool_zalloc(cmd->mem, sizeof(*devl)))) {
+					devl->dev = du->dev;
+					dm_list_add(&wrong_devs, &devl->list);
+				}
+				cmd->device_ids_invalid = 1;
 			}
-			log_debug("Drop match for %s and %s.", dev_name(du->dev), du->pvid);
 			du->dev->flags &= ~DEV_MATCHED_USE_ID;
 			du->dev->id = NULL;
 			du->dev = NULL;
@@ -2563,7 +2575,7 @@ void device_ids_validate(struct cmd_context *cmd, struct dm_list *scanned_devs,
 
 			devname = dev_name(dev);
 
-			log_debug("Devices file PVID %s is now on %s.", du->pvid, devname);
+			log_debug("New match for devices file PVID %s now on %s.", du->pvid, devname);
 
 			dup_devname1 = strdup(devname);
 			dup_devname2 = strdup(devname);
@@ -2592,7 +2604,7 @@ void device_ids_validate(struct cmd_context *cmd, struct dm_list *scanned_devs,
 			dm_list_add(&dev->ids, &id->list);
 			dev_get_partition_number(dev, &du->part);
 			update_file = 1;
-			*device_ids_invalid = 1;
+			cmd->device_ids_invalid = 1;
 			continue;
 		}
 	}
@@ -2614,7 +2626,7 @@ void device_ids_validate(struct cmd_context *cmd, struct dm_list *scanned_devs,
 			continue;
 		if (du->dev)
 			continue;
-		log_debug("Search needed to locate PVID %s %s %s.",
+		log_debug("No device matched to PVID %s %s %s.",
 			  du->pvid, idtype_to_str(du->idtype), du->idname ?: ".");
 	}
 
@@ -2654,7 +2666,7 @@ void device_ids_validate(struct cmd_context *cmd, struct dm_list *scanned_devs,
 			du->pvid = NULL;
 			du->devname = NULL;
 			update_file = 1;
-			*device_ids_invalid = 1;
+			cmd->device_ids_invalid = 1;
 			break;
 		}
 	}
@@ -2702,39 +2714,18 @@ void device_ids_validate(struct cmd_context *cmd, struct dm_list *scanned_devs,
 				dm_list_del(&du2->list);
 				free_du(du2);
 				update_file = 1;
-				*device_ids_invalid = 1;
+				cmd->device_ids_invalid = 1;
 			}
 			break;
 		}
 	}
 
-	/*
-	 * Check for other problems for which we want to set *device_ids_invalid,
-	 * even if we don't have a way to fix them right here.  In particular,
-	 * issues that may be fixed shortly by device_ids_refresh.
-	 *
-	 * The device_ids_invalid flag is only used to tell the caller not
-	 * to write hints, which could be based on invalid device info.
-	 * (There may be a better way to deal with that then returning
-	 * this flag.)
-	 */
-	dm_list_iterate_items(du, &cmd->use_devices) {
-		if (*device_ids_invalid)
-			break;
-
-		if (!du->idname || (du->idname[0] == '.'))
-			*device_ids_invalid = 1;
-
-		if ((du->idtype == DEV_ID_TYPE_DEVNAME) && !du->dev && du->pvid)
-			*device_ids_invalid = 1;
-	}
-
 	/*
 	 * When a new devname/pvid mismatch is discovered, a new search for the
 	 * pvid should be permitted (searched_devnames may exist to suppress
 	 * searching for other pvids.)
 	 */
-	if (update_file)
+	if (update_file || cmd->device_ids_invalid)
 		unlink_searched_devnames(cmd);
 
 	/* FIXME: for wrong devname cases, wait to write new until device_ids_refresh? */
@@ -2744,12 +2735,12 @@ void device_ids_validate(struct cmd_context *cmd, struct dm_list *scanned_devs,
 	 * be done by a subsequent command if it's not done here.
 	 */
 	if (update_file && noupdate) {
-		log_debug("device ids validate checked %d update disabled.", checked);
+		log_debug("Validated device ids: invalid=%d, update disabled.", cmd->device_ids_invalid);
 	} else if (update_file) {
-		log_debug("device ids validate checked %d trying to update devices file.", checked);
+		log_debug("Validated device ids: invalid=%d, trying to update devices file.", cmd->device_ids_invalid);
 		_device_ids_update_try(cmd);
 	} else {
-		log_debug("device ids validate checked %d found no update is needed.", checked);
+		log_debug("Validated device ids: invalid=%d, no update needed.", cmd->device_ids_invalid);
 	}
 }
 


=====================================
lib/device/device_id.h
=====================================
@@ -33,7 +33,7 @@ void device_id_pvremove(struct cmd_context *cmd, struct device *dev);
 void device_ids_match(struct cmd_context *cmd);
 int device_ids_match_dev(struct cmd_context *cmd, struct device *dev);
 void device_ids_match_device_list(struct cmd_context *cmd);
-void device_ids_validate(struct cmd_context *cmd, struct dm_list *scanned_devs, int *device_ids_invalid, int noupdate);
+void device_ids_validate(struct cmd_context *cmd, struct dm_list *scanned_devs, int noupdate);
 int device_ids_version_unchanged(struct cmd_context *cmd);
 void device_ids_check_serial(struct cmd_context *cmd, struct dm_list *scan_devs, int *update_needed, int noupdate);
 void device_ids_refresh(struct cmd_context *cmd, struct dm_list *dev_list, int *search_count, int noupdate);


=====================================
lib/label/label.c
=====================================
@@ -1256,7 +1256,6 @@ int label_scan(struct cmd_context *cmd)
 	struct device_list *devl, *devl2;
 	struct device *dev;
 	uint64_t max_metadata_size_bytes;
-	int device_ids_invalid = 0;
 	int using_hints;
 	int create_hints = 0; /* NEWHINTS_NONE */
 
@@ -1458,7 +1457,7 @@ int label_scan(struct cmd_context *cmd)
 	 * Check if the devices_file content is up to date and
 	 * if not update it.
 	 */
-	device_ids_validate(cmd, &scan_devs, &device_ids_invalid, 0);
+	device_ids_validate(cmd, &scan_devs, 0);
 
 	dm_list_iterate_items_safe(devl, devl2, &all_devs) {
 		dm_list_del(&devl->list);
@@ -1494,7 +1493,7 @@ int label_scan(struct cmd_context *cmd)
 	 * (create_hints variable has NEWHINTS_X value which indicates
 	 * the reason for creating the new hints.)
 	 */
-	if (create_hints && !device_ids_invalid)
+	if (create_hints && !cmd->device_ids_invalid)
 		write_hint_file(cmd, create_hints);
 
 	return 1;


=====================================
tools/lvmdevices.c
=====================================
@@ -189,7 +189,6 @@ int lvmdevices(struct cmd_context *cmd, int argc, char **argv)
 		int search_count = 0;
 		int update_needed = 0;
 		int serial_update_needed = 0;
-		int invalid = 0;
 
 		unlink_searched_devnames(cmd);
 
@@ -231,8 +230,8 @@ int lvmdevices(struct cmd_context *cmd, int argc, char **argv)
 		 * from use_devices does not pass the filters that have been
 		 * run just above.
 		 */
-		device_ids_validate(cmd, NULL, &invalid, 1);
-		if (invalid)
+		device_ids_validate(cmd, NULL, 1);
+		if (cmd->device_ids_invalid)
 			update_needed = 1;
 
 		/*



View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/commit/1901a47df12ceef65115e5148e425f4b8441081f

-- 
View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/commit/1901a47df12ceef65115e5148e425f4b8441081f
You're receiving this email because of your account on gitlab.com.


-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20231005/d9fcf9f7/attachment-0001.htm>
