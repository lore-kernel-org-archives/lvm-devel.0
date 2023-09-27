From: David Teigland (@teigland) <gitlab@mg.gitlab.com>
Date: Wed, 27 Sep 2023 20:23:20 +0000
Subject: [Git][lvmteam/lvm2][main] devices: refresh device ids if the system changes
Message-ID: <65148f38ec5e_28a50646185@gitlab-sidekiq-low-urgency-cpu-bound-v2-5788fdc574-txbwc.mail>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit



David Teigland pushed to branch main at LVM team / lvm2


Commits:
88aa285a by David Teigland at 2023-09-27T15:22:11-05:00
devices: refresh device ids if the system changes

If the system changes, locate PVs that appear on different devices,
and update the device IDs in the devices file.  A system change is
detected by saving the DMI product_uuid or hostname in the devices
file, and comparing it to the current system value.  If a root PV
is restored or copied to a new system with different devices, then
the product_uuid or hostname should change, and trigger lvm to
locate PVIDs from system.devices on new devices.

- - - - -


14 changed files:

- lib/cache/lvmcache.c
- lib/commands/toolcontext.c
- lib/commands/toolcontext.h
- lib/config/config_settings.h
- lib/device/device_id.c
- lib/device/device_id.h
- lib/label/label.c
- lib/report/report.c
- man/lvmdevices.8_des
- test/shell/devicesfile-devname.sh
- + test/shell/devicesfile-refresh.sh
- test/shell/udev-pvscan-vgchange.sh
- tools/lvmdevices.c
- tools/pvscan.c


Changes:

=====================================
lib/cache/lvmcache.c
=====================================
@@ -1646,7 +1646,7 @@ int lvmcache_label_scan(struct cmd_context *cmd)
 	 * devices file.  We then need to run label scan on these correct
 	 * devices.
 	 */
-	device_ids_find_renamed_devs(cmd, &renamed_devs, NULL, 0);
+	device_ids_refresh(cmd, &renamed_devs, NULL, 0);
 	if (!dm_list_empty(&renamed_devs))
 		label_scan_devs(cmd, cmd->filter, &renamed_devs);
 


=====================================
lib/commands/toolcontext.c
=====================================
@@ -608,6 +608,50 @@ static int _init_system_id(struct cmd_context *cmd)
 	return 1;
 }
 
+static void _init_device_ids_refresh(struct cmd_context *cmd)
+{
+	const struct dm_config_node *cn;
+	const struct dm_config_value *cv;
+	int check_product_uuid = 0;
+	int check_hostname = 0;
+	char path[PATH_MAX];
+	char uuid[128] = { 0 };
+
+	cmd->device_ids_check_product_uuid = 0;
+	cmd->device_ids_check_hostname = 0;
+
+	if (!find_config_tree_bool(cmd, devices_device_ids_refresh_CFG, NULL))
+		return;
+	if (!(cn = find_config_tree_array(cmd, devices_device_ids_refresh_checks_CFG, NULL)))
+		return;
+
+	for (cv = cn->v; cv; cv = cv->next) {
+		if (cv->type != DM_CFG_STRING)
+			continue;
+		if (!strcmp(cv->v.str, "product_uuid"))
+			check_product_uuid = 1;
+		if (!strcmp(cv->v.str, "hostname"))
+			check_hostname = 1;
+	}
+
+	/* product_uuid is preferred */
+
+	if (check_product_uuid) {
+		const char *sysfs_dir = cmd->device_id_sysfs_dir ?: dm_sysfs_dir();
+		if (dm_snprintf(path, sizeof(path), "%sdevices/virtual/dmi/id/product_uuid", sysfs_dir) < 0)
+			return;
+		if (get_sysfs_value(path, uuid, sizeof(uuid), 0) && uuid[0])
+			cmd->product_uuid = dm_pool_strdup(cmd->libmem, uuid);;
+		if (cmd->product_uuid) {
+			cmd->device_ids_check_product_uuid = 1;
+			return;
+		}
+	}
+
+	if (check_hostname && cmd->hostname)
+		cmd->device_ids_check_hostname = 1;
+}
+
 static int _process_config(struct cmd_context *cmd)
 {
 	mode_t old_umask;
@@ -779,6 +823,8 @@ static int _process_config(struct cmd_context *cmd)
 	if (!_init_system_id(cmd))
 		return_0;
 
+	_init_device_ids_refresh(cmd);
+
 	init_io_memory_size(find_config_tree_int(cmd, global_io_memory_size_CFG, NULL));
 
 	return 1;


=====================================
lib/commands/toolcontext.h
=====================================
@@ -120,6 +120,7 @@ struct cmd_context {
 	 * Machine and system identification.
 	 */
 	const char *system_id;
+	const char *product_uuid;
 	const char *hostname;
 	const char *kernel_vsn;
 
@@ -209,6 +210,9 @@ struct cmd_context {
 	unsigned online_vg_file_removed:1;
 	unsigned disable_dm_devs:1;		/* temporarily disable use of dm devs cache */
 	unsigned filter_regex_set_preferred_name_disable:1; /* prevent dev_set_preferred_name */
+	unsigned device_ids_check_product_uuid:1;
+	unsigned device_ids_check_hostname:1;
+	unsigned device_ids_refresh_trigger:1;
 
 	/*
 	 * Devices and filtering.


=====================================
lib/config/config_settings.h
=====================================
@@ -306,6 +306,22 @@ cfg(devices_search_for_devnames_CFG, "search_for_devnames", devices_CFG_SECTION,
 	"at other devices, but only those that are likely to have the PV.\n"
 	"If \"all\", lvm will look at all devices on the system.\n")
 
+cfg(devices_device_ids_refresh_CFG, "device_ids_refresh", devices_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, 1, vsn(2, 3, 23), NULL, 0, NULL,
+	"Find PVs on new devices and update the device IDs in the devices file.\n"
+	"If PVs are restored or moved to a new system with new devices, but\n"
+	"an old system.devices remains with old device IDs, then search for\n"
+	"the PVIDs on new devices and update the device IDs in system.devices.\n"
+	"The original device IDs must also not be found on the new system.\n"
+	"See device_ids_refresh_check for conditions that trigger the refresh.\n")
+
+cfg_array(devices_device_ids_refresh_checks_CFG, "device_ids_refresh_checks", devices_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, "#Sproduct_uuid#Shostname", vsn(2, 3, 23), NULL, 0, NULL,
+	"Conditions that trigger device_ids_refresh to locate PVIDs on new devices.\n"
+	"product_uuid: refresh if /sys/devices/virtual/dmi/id/product_uuid does not\n"
+	"match the value saved in system.devices.\n"
+	"hostname: refresh if hostname does not match the value saved in system.devices.\n"
+	"(hostname is used if product_uuid is not available.)\n"
+	"Remove values from this list to prevent lvm from using them.\n")
+
 cfg_array(devices_filter_CFG, "filter", devices_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, "#Sa|.*|", vsn(1, 0, 0), NULL, 0, NULL,
 	"Limit the block devices that are used by LVM commands.\n"
 	"This is a list of regular expressions used to accept or reject block\n"


=====================================
lib/device/device_id.c
=====================================
@@ -41,7 +41,6 @@ static int _devices_fd = -1;
 static int _using_devices_file;
 static int _devices_file_locked;
 static char _devices_lockfile[PATH_MAX];
-static char _devices_file_systemid[PATH_MAX];
 static char _devices_file_version[VERSION_LINE_MAX];
 static const char *_searched_file = DEFAULT_RUN_DIR "/searched_devnames";
 
@@ -96,6 +95,30 @@ static int _searched_devnames_exists(struct cmd_context *cmd)
 	return 0;
 }
 
+/*
+ * Check if the device_id saved in the VG metadata matches the actual device_id
+ * on the device used for the PV.
+ */
+int pv_device_id_is_stale(const struct physical_volume *pv)
+{
+	struct dev_use *du;
+
+	if (!pv->vg || !pv->vg->cmd)
+		return 0;
+	if (!pv->device_id || !pv->device_id_type)
+		return 0;
+	if (!(du = get_du_for_dev(pv->vg->cmd, pv->dev)))
+		return 0;
+	if (!du->idname)
+		return 0;
+
+	if (du->idtype != idtype_from_str(pv->device_id_type))
+		return 1;
+	if (strcmp(du->idname, pv->device_id))
+		return 1;
+	return 0;
+}
+
 /*
  * How the devices file and device IDs are used by an ordinary command:
  *
@@ -717,6 +740,82 @@ const char *device_id_system_read(struct cmd_context *cmd, struct device *dev, u
 	return NULL;
 }
 
+static int device_id_system_read_preferred(struct cmd_context *cmd, struct device *dev,
+					   uint16_t *new_idtype, const char **new_idname)
+{
+	const char *idname = NULL;
+	uint16_t idtype;
+
+	if (MAJOR(dev->dev) == cmd->dev_types->device_mapper_major) {
+		if (dev_has_mpath_uuid(cmd, dev, &idname)) {
+			idtype = DEV_ID_TYPE_MPATH_UUID;
+			goto id_done;
+		}
+
+		if (_dev_has_crypt_uuid(cmd, dev, &idname)) {
+			idtype = DEV_ID_TYPE_CRYPT_UUID;
+			goto id_done;
+		}
+
+		if (_dev_has_lvmlv_uuid(cmd, dev, &idname)) {
+			idtype = DEV_ID_TYPE_LVMLV_UUID;
+			goto id_done;
+		}
+	}
+
+	/* TODO: kpartx partitions on loop devs. */
+	if (MAJOR(dev->dev) == cmd->dev_types->loop_major) {
+		idtype = DEV_ID_TYPE_LOOP_FILE;
+		if ((idname = device_id_system_read(cmd, dev, idtype)))
+			goto id_done;
+		goto id_last;
+	}
+
+	if (MAJOR(dev->dev) == cmd->dev_types->md_major) {
+		idtype = DEV_ID_TYPE_MD_UUID;
+		if ((idname = device_id_system_read(cmd, dev, idtype)))
+			goto id_done;
+		goto id_last;
+	}
+
+	if (MAJOR(dev->dev) == cmd->dev_types->drbd_major) {
+		/* TODO */
+		log_warn("Missing support for DRBD idtype");
+		goto id_last;
+	}
+
+	idtype = DEV_ID_TYPE_SYS_WWID;
+	if ((idname = device_id_system_read(cmd, dev, idtype)))
+		goto id_done;
+
+	idtype = DEV_ID_TYPE_WWID_NAA;
+	if ((idname = device_id_system_read(cmd, dev, idtype)))
+		goto id_done;
+
+	idtype = DEV_ID_TYPE_WWID_EUI;
+	if ((idname = device_id_system_read(cmd, dev, idtype)))
+		goto id_done;
+
+	idtype = DEV_ID_TYPE_WWID_T10;
+	if ((idname = device_id_system_read(cmd, dev, idtype)))
+		goto id_done;
+
+	idtype = DEV_ID_TYPE_SYS_SERIAL;
+	if ((idname = device_id_system_read(cmd, dev, idtype)))
+		goto id_done;
+id_last:
+	idtype = DEV_ID_TYPE_DEVNAME;
+	if ((idname = device_id_system_read(cmd, dev, idtype)))
+		goto id_done;
+
+	return 0;
+
+id_done:
+	*new_idtype = idtype;
+	*new_idname = idname;
+	return 1;
+}
+
 /*
  * Check if this dev would use a stable idtype or if it
  * would use DEV_ID_TYPE_DEVNAME.
@@ -921,10 +1020,13 @@ int device_ids_read(struct cmd_context *cmd)
 {
 	char line[PATH_MAX];
 	char buf[PATH_MAX];
+	char check_id[PATH_MAX]; 
 	char *idtype, *idname, *devname, *pvid, *part;
 	struct dev_use *du;
 	FILE *fp;
 	int line_error;
+	int product_uuid_found = 0;
+	int hostname_found = 0;
 	int ret = 1;
 
 	if (!cmd->enable_devices_file)
@@ -953,16 +1055,39 @@ int device_ids_read(struct cmd_context *cmd)
 		if (line[0] == '#')
 			continue;
 
-		if (!strncmp(line, "SYSTEMID", 8)) {
-			_copy_idline_str(line, _devices_file_systemid, sizeof(_devices_file_systemid));
-			log_debug("read devices file systemid %s", _devices_file_systemid);
-			if ((!cmd->system_id && _devices_file_systemid[0]) ||
-			    (cmd->system_id && strcmp(cmd->system_id, _devices_file_systemid))) {
-				log_warn("WARNING: devices file has unmatching system id %s vs local %s.",
-					  _devices_file_systemid[0] ? _devices_file_systemid : "none", cmd->system_id ?: "none");
+		/* Old version wrote this but it's not used. */
+		if (!strncmp(line, "SYSTEMID", 8))
+			continue;
+
+		if (!strncmp(line, "HOSTNAME", 8)) {
+			if (!cmd->device_ids_check_hostname)
+				continue;
+			hostname_found = 1;
+			_copy_idline_str(line, check_id, sizeof(check_id));
+			log_debug("read devices file hostname %s", check_id);
+			if (cmd->hostname && strcmp(cmd->hostname, check_id)) {
+				log_debug("Devices file hostname %s vs local %s.",
+					  check_id[0] ? check_id : "none", cmd->hostname ?: "none");
+				cmd->device_ids_refresh_trigger = 1;
+			}
+			continue;
+		}
+
+		if (!strncmp(line, "PRODUCT_UUID", 12)) {
+			if (!cmd->device_ids_check_product_uuid)
+				continue;
+			product_uuid_found = 1;
+			_copy_idline_str(line, check_id, sizeof(check_id));
+			log_debug("read devices file product_uuid %s", check_id);
+			if ((!cmd->product_uuid && check_id[0]) ||
+			    (cmd->product_uuid && strcmp(cmd->product_uuid, check_id))) {
+				log_debug("Devices file product_uuid %s vs local %s.",
+					  check_id[0] ? check_id : "none", cmd->product_uuid ?: "none");
+				cmd->device_ids_refresh_trigger = 1;
 			}
 			continue;
 		}
+
 		if (!strncmp(line, "VERSION", 7)) {
 			_copy_idline_str(line, _devices_file_version, sizeof(_devices_file_version));
 			log_debug("read devices file version %s", _devices_file_version);
@@ -1027,6 +1152,12 @@ int device_ids_read(struct cmd_context *cmd)
 	}
 	if (fclose(fp))
 		stack;
+	
+	if (!product_uuid_found && !hostname_found &&
+	    (cmd->device_ids_check_product_uuid || cmd->device_ids_check_hostname)) {
+		cmd->device_ids_refresh_trigger = 1;
+		log_debug("Devices file refresh due to no product_uuid or hostname.");
+	}
 
 	return ret;
 }
@@ -1078,11 +1209,11 @@ int device_ids_write(struct cmd_context *cmd)
 	    (!strncmp(cmd->name, "pvcreate", 8) || !strncmp(cmd->name, "vgcreate", 8))) {
 		/* If any PVs were seen during scan then don't create a new devices file. */
 		if (lvmcache_vg_info_count()) {
-			log_warn("Not creating system devices file due to existing VGs.");
+			log_print_unless_silent("Not creating system devices file due to existing VGs.");
 			free_dus(&cmd->use_devices);
 			return 1;
 		}
-		log_warn("Creating devices file %s", cmd->devices_file_path);
+		log_print_unless_silent("Creating devices file %s", cmd->devices_file_path);
 		cmd->enable_devices_file = 1;
 	}
 
@@ -1132,15 +1263,10 @@ int device_ids_write(struct cmd_context *cmd)
 	fprintf(fp, "# LVM uses devices listed in this file.\n");
 	fprintf(fp, "# Created by LVM command %s pid %d at %s", cmd->name, getpid(), ctime(&t));
 
-	/*
-	 * It's useful to ensure that this devices file is associated to a
-	 * single system because this file can be used to control access to
-	 * shared devices.  If this file is copied/cloned to another system,
-	 * that new system should not automatically gain access to the devices
-	 * that the original system is using.
-	 */
-	if (cmd->system_id)
-		fprintf(fp, "SYSTEMID=%s\n", cmd->system_id);
+	if (cmd->product_uuid && cmd->device_ids_check_product_uuid)
+		fprintf(fp, "PRODUCT_UUID=%s\n", cmd->product_uuid);
+	if (cmd->hostname && cmd->device_ids_check_hostname)
+		fprintf(fp, "HOSTNAME=%s\n", cmd->hostname);
 
 	if (dm_snprintf(version_buf, VERSION_LINE_MAX, "VERSION=%u.%u.%u", DEVICES_FILE_MAJOR, DEVICES_FILE_MINOR, df_counter+1) < 0)
 		stack;
@@ -1425,77 +1551,11 @@ int device_id_add(struct cmd_context *cmd, struct device *dev, const char *pvid_
 		}
 	}
 
-	if (MAJOR(dev->dev) == cmd->dev_types->device_mapper_major) {
-		if (dev_has_mpath_uuid(cmd, dev, &idname)) {
-			idtype = DEV_ID_TYPE_MPATH_UUID;
-			goto id_done;
-		}
-
-		if (_dev_has_crypt_uuid(cmd, dev, &idname)) {
-			idtype = DEV_ID_TYPE_CRYPT_UUID;
-			goto id_done;
-		}
-
-		if (_dev_has_lvmlv_uuid(cmd, dev, &idname)) {
-			idtype = DEV_ID_TYPE_LVMLV_UUID;
-			goto id_done;
-		}
-	}
-
-	/* TODO: kpartx partitions on loop devs. */
-	if (MAJOR(dev->dev) == cmd->dev_types->loop_major) {
-		idtype = DEV_ID_TYPE_LOOP_FILE;
-		if ((idname = device_id_system_read(cmd, dev, idtype)))
-			goto id_done;
-		goto id_last;
-	}
-
-	if (MAJOR(dev->dev) == cmd->dev_types->md_major) {
-		idtype = DEV_ID_TYPE_MD_UUID;
-		if ((idname = device_id_system_read(cmd, dev, idtype)))
-			goto id_done;
-		goto id_last;
-	}
-
-	if (MAJOR(dev->dev) == cmd->dev_types->drbd_major) {
-		/* TODO */
-		log_warn("Missing support for DRBD idtype");
-		goto id_last;
-	}
-
-	/*
-	 * No device-specific, existing, or user-specified idtypes,
-	 * so use first available of sys_wwid, wwid_naa, wwid_eui,
-	 * wwid_t10, sys_serial, devname.
-	 */
-
-	idtype = DEV_ID_TYPE_SYS_WWID;
-	if ((idname = device_id_system_read(cmd, dev, idtype)))
-		goto id_done;
-
-	idtype = DEV_ID_TYPE_WWID_NAA;
-	if ((idname = device_id_system_read(cmd, dev, idtype)))
-		goto id_done;
-
-	idtype = DEV_ID_TYPE_WWID_EUI;
-	if ((idname = device_id_system_read(cmd, dev, idtype)))
-		goto id_done;
-
-	idtype = DEV_ID_TYPE_WWID_T10;
-	if ((idname = device_id_system_read(cmd, dev, idtype)))
-		goto id_done;
-
-	idtype = DEV_ID_TYPE_SYS_SERIAL;
-	if ((idname = device_id_system_read(cmd, dev, idtype)))
-		goto id_done;
-id_last:
-	idtype = DEV_ID_TYPE_DEVNAME;
-	if ((idname = device_id_system_read(cmd, dev, idtype)))
-		goto id_done;
-
-id_done:
+	if (!device_id_system_read_preferred(cmd, dev, &idtype, &idname))
+		return_0;
 	if (!idname)
 		return_0;
+id_done:
 
 	/*
 	 * Create a dev_id struct for the new idtype on dev->ids.
@@ -2240,7 +2300,7 @@ static void _get_devs_with_serial_numbers(struct cmd_context *cmd, struct dm_lis
 			}
 		}
 
-		/* just copying the no-data filters in similar device_ids_find_renamed_devs */
+		/* just copying the no-data filters in similar device_ids_refresh */
 		if (!cmd->filter->passes_filter(cmd, cmd->filter, dev, "sysfs"))
 			continue;
 		if (!cmd->filter->passes_filter(cmd, cmd->filter, dev, "type"))
@@ -2300,7 +2360,7 @@ void device_ids_validate(struct cmd_context *cmd, struct dm_list *scanned_devs,
 	if (!cmd->enable_devices_file)
 		return;
 
-	log_debug("validating devices file entries");
+	log_debug("Validating devices file entries");
 
 	/*
 	 * Validate entries with proper device id types.
@@ -2320,15 +2380,21 @@ void device_ids_validate(struct cmd_context *cmd, struct dm_list *scanned_devs,
 		 * scanned_devs are the devices that have been scanned,
 		 * so they are the only devs we can verify PVID for.
 		 */
-		if (scanned_devs && !device_list_find_dev(scanned_devs, dev))
+		if (scanned_devs && !device_list_find_dev(scanned_devs, dev)) {
+			log_debug("Validate %s %s PVID %s on %s: not scanned",
+				  idtype_to_str(du->idtype), du->idname ?: ".", du->pvid ?: ".", dev_name(dev));
 			continue;
+		}
 
 		/*
 		 * The matched device could not be read so we do not have
 		 * the PVID from disk and cannot verify the devices file entry.
 		 */
-		if (dev->flags & DEV_SCAN_NOT_READ)
+		if (dev->flags & DEV_SCAN_NOT_READ) {
+			log_debug("Validate %s %s PVID %s on %s: not read",
+				  idtype_to_str(du->idtype), du->idname ?: ".", du->pvid ?: ".", dev_name(dev));
 			continue;
+		}
 
 		/*
 		 * du and dev may have been matched, but the dev could still
@@ -2337,6 +2403,8 @@ void device_ids_validate(struct cmd_context *cmd, struct dm_list *scanned_devs,
 		 * probably wants to do something about it.
 		 */
 		if (!cmd->filter->passes_filter(cmd, cmd->filter, dev, "persistent")) {
+			log_debug("Validate %s %s PVID %s on %s: filtered",
+				  idtype_to_str(du->idtype), du->idname ?: ".", du->pvid ?: ".", dev_name(dev));
 			log_warn("Devices file %s is excluded: %s.",
 				 dev_name(dev), dev_filtered_reason(dev));
 			continue;
@@ -2351,6 +2419,9 @@ void device_ids_validate(struct cmd_context *cmd, struct dm_list *scanned_devs,
 		 */
 		if ((du->idtype == DEV_ID_TYPE_SYS_SERIAL) && du->pvid &&
 		    memcmp(dev->pvid, du->pvid, ID_LEN)) {
+			log_debug("Validate %s %s PVID %s on %s: wrong PVID %s",
+				  idtype_to_str(du->idtype), du->idname ?: ".", du->pvid ?: ".",
+				  dev_name(dev), dev->pvid);
 			log_debug("suspect device id serial %s for %s", du->idname, dev_name(dev));
 			if (!str_list_add(cmd->mem, &cmd->device_ids_check_serial, dm_pool_strdup(cmd->mem, du->idname)))
 				stack;
@@ -2365,6 +2436,9 @@ void device_ids_validate(struct cmd_context *cmd, struct dm_list *scanned_devs,
 		 */
 		if (dev->pvid[0]) {
 			if (!du->pvid || memcmp(dev->pvid, du->pvid, ID_LEN)) {
+				log_debug("Validate %s %s PVID %s on %s: wrong PVID %s",
+					  idtype_to_str(du->idtype), du->idname ?: ".", du->pvid ?: ".",
+					  dev_name(dev), dev->pvid);
 				log_warn("Device %s has PVID %s (devices file %s)",
 					 dev_name(dev), dev->pvid, du->pvid ?: "none");
 				if (!(tmpdup = strdup(dev->pvid)))
@@ -2376,6 +2450,9 @@ void device_ids_validate(struct cmd_context *cmd, struct dm_list *scanned_devs,
 			}
 		} else {
 			if (du->pvid && (du->pvid[0] != '.')) {
+				log_debug("Validate %s %s PVID %s on %s: wrong PVID %s",
+					  idtype_to_str(du->idtype), du->idname ?: ".", du->pvid ?: ".",
+					  dev_name(dev), dev->pvid);
 				log_warn("Device %s has no PVID (devices file %s)",
 					 dev_name(dev), du->pvid);
 				free(du->pvid);
@@ -2385,6 +2462,10 @@ void device_ids_validate(struct cmd_context *cmd, struct dm_list *scanned_devs,
 			}
 		}
 
+		log_debug("Validate %s %s PVID %s on %s: correct",
+			  idtype_to_str(du->idtype), du->idname ?: ".", du->pvid ?: ".",
+			  dev_name(dev));
+
 		/*
 		 * Avoid thrashing changes to the devices file during
 		 * startup due to device names that are still being
@@ -2482,7 +2563,7 @@ void device_ids_validate(struct cmd_context *cmd, struct dm_list *scanned_devs,
 
 			devname = dev_name(dev);
 
-			log_print("Devices file PVID %s is now on %s.", du->pvid, devname);
+			log_debug("Devices file PVID %s is now on %s.", du->pvid, devname);
 
 			dup_devname1 = strdup(devname);
 			dup_devname2 = strdup(devname);
@@ -2518,17 +2599,23 @@ void device_ids_validate(struct cmd_context *cmd, struct dm_list *scanned_devs,
 
 	/*
 	 * Each remaining du that's not matched to a dev (no du->dev set) is
-	 * subject to device_ids_find_renamed_devs which will look for
-	 * unmatched pvids on devs that have not been scanned yet.
+	 * subject to device_ids_refresh which will look for unmatched pvids on
+	 * devs that have not been scanned yet.
 	 */
 	dm_list_iterate_items(du, &cmd->use_devices) {
-		if (du->idtype != DEV_ID_TYPE_DEVNAME)
+		/* 
+		 * Only search for devname type entries unless the refresh
+		 * trigger is set due to a machine change, in which case
+		 * we look for missing PVIDs on new devs with real idtypes.
+		 */
+		if ((du->idtype != DEV_ID_TYPE_DEVNAME) && !cmd->device_ids_refresh_trigger)
 			continue;
 		if (!du->pvid)
 			continue;
 		if (du->dev)
 			continue;
-		log_debug("Search needed to find device with PVID %s.", du->pvid);
+		log_debug("Search needed to locate PVID %s %s %s.",
+			  du->pvid, idtype_to_str(du->idtype), du->idname ?: ".");
 	}
 
 	/*
@@ -2624,7 +2711,7 @@ void device_ids_validate(struct cmd_context *cmd, struct dm_list *scanned_devs,
 	/*
 	 * Check for other problems for which we want to set *device_ids_invalid,
 	 * even if we don't have a way to fix them right here.  In particular,
-	 * issues that may be fixed shortly by device_ids_find_renamed_devs.
+	 * issues that may be fixed shortly by device_ids_refresh.
 	 *
 	 * The device_ids_invalid flag is only used to tell the caller not
 	 * to write hints, which could be based on invalid device info.
@@ -2650,7 +2737,7 @@ void device_ids_validate(struct cmd_context *cmd, struct dm_list *scanned_devs,
 	if (update_file)
 		unlink_searched_devnames(cmd);
 
-	/* FIXME: for wrong devname cases, wait to write new until device_ids_find_renamed_devs? */
+	/* FIXME: for wrong devname cases, wait to write new until device_ids_refresh? */
 
 	/*
 	 * try lock and device_ids_write(), the update is not required and will
@@ -2957,8 +3044,8 @@ void device_ids_check_serial(struct cmd_context *cmd, struct dm_list *scan_devs,
  * is using a non-system devices file?
  */
 
-void device_ids_find_renamed_devs(struct cmd_context *cmd, struct dm_list *dev_list,
-				  int *search_count, int noupdate)
+void device_ids_refresh(struct cmd_context *cmd, struct dm_list *dev_list,
+		        int *search_count, int noupdate)
 {
 	struct device *dev;
 	struct dev_use *du;
@@ -2966,8 +3053,8 @@ void device_ids_find_renamed_devs(struct cmd_context *cmd, struct dm_list *dev_l
 	struct dev_iter *iter;
 	struct device_list *devl;           /* holds struct device */
 	struct device_id_list *dil, *dil2;  /* holds struct device + pvid */
-	struct dm_list search_pvids;        /* list of device_id_list */
-	struct dm_list search_devs ;        /* list of device_list */
+	struct dm_list search_list_pvids;        /* list of device_id_list */
+	struct dm_list search_list_devs ;        /* list of device_list */
 	const char *devname;
 	int update_file = 0;
 	int other_idtype = 0;
@@ -2975,41 +3062,74 @@ void device_ids_find_renamed_devs(struct cmd_context *cmd, struct dm_list *dev_l
 	int no_pvid = 0;
 	int found = 0;
 	int not_found = 0;
-	int search_none;
-	int search_auto;
+	int search_mode_none;
+	int search_mode_auto;
+	int search_mode_all;
 
-	dm_list_init(&search_pvids);
-	dm_list_init(&search_devs);
+	dm_list_init(&search_list_pvids);
+	dm_list_init(&search_list_devs);
 
 	if (!cmd->enable_devices_file)
 		return;
 
-	search_none = !strcmp(cmd->search_for_devnames, "none");
-	search_auto = !strcmp(cmd->search_for_devnames, "auto");
+	if (cmd->device_ids_refresh_trigger) {
+		search_mode_all = 1;
+		search_mode_none = 0;
+		search_mode_auto = 0;
+	} else {
+		search_mode_all = !strcmp(cmd->search_for_devnames, "all");
+		search_mode_none = !strcmp(cmd->search_for_devnames, "none");
+		search_mode_auto = !strcmp(cmd->search_for_devnames, "auto");
+	}
 
+	/*
+	 * Create search_list_pvids which is a list of PVIDs that
+	 * we want to locate on some device.
+	 */
 	dm_list_iterate_items(du, &cmd->use_devices) {
-		if (du->idtype != DEV_ID_TYPE_DEVNAME)
-			continue;
 		if (!du->pvid)
 			continue;
 		if (du->dev)
 			continue;
 
-		if (!(dil = dm_pool_zalloc(cmd->mem, sizeof(*dil))))
+		/*
+		 * When device_ids_refresh_trigger is set, it means
+		 * that a PVID may be shifted to a new device even when
+		 * the entry uses a stable id type, like wwid.
+		 * Otherwise, we assume that only entries using the
+		 * devname id type can move to new devices.
+		 */
+		if (!cmd->device_ids_refresh_trigger &&
+		    (du->idtype != DEV_ID_TYPE_DEVNAME))
 			continue;
 
-		if (!search_none) {
-			memcpy(dil->pvid, du->pvid, ID_LEN);
-			dm_list_add(&search_pvids, &dil->list);
-		}
 		log_debug("Search for PVID %s.", du->pvid);
+
 		if (search_count)
 			(*search_count)++;
+
+		if (search_mode_none)
+			continue;
+
+		if (!(dil = dm_pool_zalloc(cmd->mem, sizeof(*dil))))
+			continue;
+		memcpy(dil->pvid, du->pvid, ID_LEN);
+		dm_list_add(&search_list_pvids, &dil->list);
 	}
 
-	if (dm_list_empty(&search_pvids))
+	/* No unmatched PVIDs to search for, and no system id to update. */
+	if (dm_list_empty(&search_list_pvids) && !cmd->device_ids_refresh_trigger)
 		return;
 
+	log_debug("device ids refresh search_pvids %d trigger %d search all %d auto %d none %d",
+		  dm_list_size(&search_list_pvids), cmd->device_ids_refresh_trigger,
+		  search_mode_all, search_mode_auto, search_mode_none);
+
+	if (dm_list_empty(&search_list_pvids) && cmd->device_ids_refresh_trigger) {
+		update_file = 1;
+		goto out;
+	}
+
 	/*
 	 * A previous command searched for devnames and found nothing, so it
 	 * created the searched file to tell us not to bother.  Without this, a
@@ -3025,7 +3145,7 @@ void device_ids_find_renamed_devs(struct cmd_context *cmd, struct dm_list *dev_l
 	 * If hints are enabled, the hints invalidation could also remove the
 	 * searched file.
 	 */
-	if (_searched_devnames_exists(cmd)) {
+	if (!cmd->device_ids_refresh_trigger && _searched_devnames_exists(cmd)) {
 		log_debug("Search for PVIDs skipped for %s", _searched_file);
 		return;
 	}
@@ -3060,11 +3180,11 @@ void device_ids_find_renamed_devs(struct cmd_context *cmd, struct dm_list *dev_l
 		if (!(devl = dm_pool_zalloc(cmd->mem, sizeof(*devl))))
 			continue;
 		devl->dev = dev;
-		dm_list_add(&search_devs, &devl->list);
+		dm_list_add(&search_list_devs, &devl->list);
 	}
 	dev_iter_destroy(iter);
 
-	log_debug("Search for PVIDs reading labels on %d devs.", dm_list_size(&search_devs));
+	log_debug("Search for PVIDs reading labels on %d devs.", dm_list_size(&search_list_devs));
 
 	/*
 	 * Read the dev to get the pvid, and run the filters that will use the
@@ -3072,7 +3192,7 @@ void device_ids_find_renamed_devs(struct cmd_context *cmd, struct dm_list *dev_l
 	 * to modify the command's existing filter chain or the persistent
 	 * filter values.
 	 */
-	dm_list_iterate_items(devl, &search_devs) {
+	dm_list_iterate_items(devl, &search_list_devs) {
 		int has_pvid;
 		dev = devl->dev;
 
@@ -3081,7 +3201,7 @@ void device_ids_find_renamed_devs(struct cmd_context *cmd, struct dm_list *dev_l
 		 * themselves as alternatives to the missing ID_TYPE_DEVNAME
 		 * entry. i.e. a ID_TYPE_DEVNAME entry would not appear on a
 		 * device that has a wwid and would use ID_TYPE_SYS_WWID.  So,
-		 * if a dev in the search_devs list has a proper/stable device
+		 * if a dev in the search_list_devs list has a proper/stable device
 		 * id (e.g. wwid, serial, loop, mpath), then we don't need to
 		 * read it to check for missing PVIDs.
 		 * 
@@ -3097,7 +3217,7 @@ void device_ids_find_renamed_devs(struct cmd_context *cmd, struct dm_list *dev_l
 		 * user forces a devname id, then they should probably also
 		 * set search_for_devnames=all.
 		 */
-		if (search_auto && _dev_has_stable_id(cmd, dev)) {
+		if (search_mode_auto && _dev_has_stable_id(cmd, dev)) {
 			other_idtype++;
 			continue;
 		}
@@ -3134,12 +3254,12 @@ void device_ids_find_renamed_devs(struct cmd_context *cmd, struct dm_list *dev_l
 			goto next;
 
 		/*
-		 * Check if the the PVID is one we are searching for.
-		 * Loop below looks at search_pvid entries that have dil->dev set.
-		 * This continues checking after all search_pvids entries have been
+		 * Check if the the PVID returned from label_read is one we are looking for.
+		 * The loop below looks at search_list_pvids entries that have dil->dev set.
+		 * This loop continues checking after all search_list_pvids entries have been
 		 * matched in order to check if the PVID is on duplicate devs.
 		 */
-		dm_list_iterate_items_safe(dil, dil2, &search_pvids) {
+		dm_list_iterate_items_safe(dil, dil2, &search_list_pvids) {
 			if (!memcmp(dil->pvid, dev->pvid, ID_LEN)) {
 				if (dil->dev) {
 					log_warn("WARNING: found PVID %s on multiple devices %s %s.",
@@ -3164,15 +3284,16 @@ void device_ids_find_renamed_devs(struct cmd_context *cmd, struct dm_list *dev_l
 	/*
 	 * The use_devices entries (repesenting the devices file) are
 	 * updated for the new devices on which the PVs reside.  The new
-	 * correct devs are set as dil->dev on search_pvids entries.
+	 * correct devs are set as dil->dev on search_list_pvids entries.
 	 *
 	 * The du/dev/id are set up and linked for the new devs.
 	 *
 	 * The command's full filter chain is updated for the new devs now that
 	 * filter-deviceid will pass.
 	 */
-	dm_list_iterate_items(dil, &search_pvids) {
-		char *dup_devname1, *dup_devname2, *dup_devname3;
+	dm_list_iterate_items(dil, &search_list_pvids) {
+		char *new_idname, *new_idname2, *new_devname;
+		uint16_t new_idtype;
 
 		if (!dil->dev || dm_list_empty(&dil->dev->aliases)) {
 			not_found++;
@@ -3187,37 +3308,50 @@ void device_ids_find_renamed_devs(struct cmd_context *cmd, struct dm_list *dev_l
 			/* shouldn't happen */
 			continue;
 		}
-		if (du->idtype != DEV_ID_TYPE_DEVNAME) {
-			/* shouldn't happen */
-			continue;
+
+		new_idtype = 0;
+		new_idname = NULL;
+		new_idname2 = NULL;
+		new_devname = NULL;
+
+		if (cmd->device_ids_refresh_trigger) {
+			if (!device_id_system_read_preferred(cmd, dev, &new_idtype, (const char **)&new_idname))
+				continue;
+			new_idname2 = strdup(new_idname);
+			new_devname = strdup(devname);
+			log_print_unless_silent("Devices file PVID %s has new device ID %s %s from %s.",
+				  du->pvid ?: "", idtype_to_str(new_idtype), new_idname ?: "", devname);
+		} else {
+			/* Use the new device name as the new idname. */
+			new_idtype = DEV_ID_TYPE_DEVNAME;
+			new_idname = strdup(devname);
+			new_idname2 = strdup(devname);
+			new_devname = strdup(devname);
+			log_print_unless_silent("Found new device name %s for PVID %s.", devname, du->pvid ?: "");
 		}
 
-		dup_devname1 = strdup(devname);
-		dup_devname2 = strdup(devname);
-		dup_devname3 = strdup(devname);
 		id = zalloc(sizeof(struct dev_id));
-		if (!dup_devname1 || !dup_devname2 || !dup_devname3 || !id) {
-			free(dup_devname1);
-			free(dup_devname2);
-			free(dup_devname3);
+
+		if (!id || !new_devname || !new_idname || !new_idname2) {
 			free(id);
+			free(new_idname);
+			free(new_idname2);
+			free(new_devname);
 			stack;
 			continue;
 		}
 
-		if (!noupdate)
-			log_warn("Devices file PVID %s updating IDNAME to %s.", dev->pvid, devname);
-
 		free(du->idname);
 		free(du->devname);
 		free_dids(&dev->ids);
 
-		du->idname = dup_devname1;
-		du->devname = dup_devname2;
-		id->idtype = DEV_ID_TYPE_DEVNAME;
-		id->idname = dup_devname3;
-		id->dev = dev;
+		du->idtype = new_idtype;
+		du->idname = new_idname;
+		du->devname = new_devname;
 		du->dev = dev;
+		id->idtype = new_idtype;
+		id->idname = new_idname2;
+		id->dev = dev;
 		dev->id = id;
 		dev->flags |= DEV_MATCHED_USE_ID;
 		dm_list_add(&dev->ids, &id->list);
@@ -3225,7 +3359,7 @@ void device_ids_find_renamed_devs(struct cmd_context *cmd, struct dm_list *dev_l
 		update_file = 1;
 	}
 
-	dm_list_iterate_items(dil, &search_pvids) {
+	dm_list_iterate_items(dil, &search_list_pvids) {
 		if (!dil->dev)
 			continue;
 		dev = dil->dev;
@@ -3242,6 +3376,7 @@ void device_ids_find_renamed_devs(struct cmd_context *cmd, struct dm_list *dev_l
 		}
 	}
 
+ out:
 	/*
 	 * try lock and device_ids_write(), the update is not required and will
 	 * be done by a subsequent command if it's not done here.
@@ -3259,11 +3394,11 @@ void device_ids_find_renamed_devs(struct cmd_context *cmd, struct dm_list *dev_l
 	}
 
 	/*
-	 * The entries in search_pvids with a dev set are the new devs found
+	 * The entries in search_list_pvids with a dev set are the new devs found
 	 * for the PVIDs that we want to return to the caller in a device_list
 	 * format.
 	 */
-	dm_list_iterate_items(dil, &search_pvids) {
+	dm_list_iterate_items(dil, &search_list_pvids) {
 		if (!dil->dev)
 			continue;
 		dev = dil->dev;
@@ -3279,7 +3414,7 @@ void device_ids_find_renamed_devs(struct cmd_context *cmd, struct dm_list *dev_l
 	 * pvids not found were from devices that are permanently detached.
 	 * If a new PV appears, pvscan will run and do unlink_searched_file.
 	 */
-	if (not_found && !found)
+	if (!cmd->device_ids_refresh_trigger && not_found && !found)
 		_touch_searched_devnames(cmd);
 }
 


=====================================
lib/device/device_id.h
=====================================
@@ -36,7 +36,7 @@ void device_ids_match_device_list(struct cmd_context *cmd);
 void device_ids_validate(struct cmd_context *cmd, struct dm_list *scanned_devs, int *device_ids_invalid, int noupdate);
 int device_ids_version_unchanged(struct cmd_context *cmd);
 void device_ids_check_serial(struct cmd_context *cmd, struct dm_list *scan_devs, int *update_needed, int noupdate);
-void device_ids_find_renamed_devs(struct cmd_context *cmd, struct dm_list *dev_list, int *search_count, int noupdate);
+void device_ids_refresh(struct cmd_context *cmd, struct dm_list *dev_list, int *search_count, int noupdate);
 const char *device_id_system_read(struct cmd_context *cmd, struct device *dev, uint16_t idtype);
 void device_id_update_vg_uuid(struct cmd_context *cmd, struct volume_group *vg, struct id *old_vg_id);
 
@@ -72,4 +72,6 @@ int dev_read_vpd_wwids(struct cmd_context *cmd, struct device *dev);
 int dev_read_sys_wwid(struct cmd_context *cmd, struct device *dev,
 		      char *buf, int bufsize, struct dev_wwid **dw_out);
 
+int pv_device_id_is_stale(const struct physical_volume *pv);
+
 #endif


=====================================
lib/label/label.c
=====================================
@@ -1092,11 +1092,12 @@ int label_scan_vg_online(struct cmd_context *cmd, const char *vgname,
 	if (cmd->enable_devices_list)
 		device_ids_match_device_list(cmd);
 
-	if (cmd->enable_devices_file && device_ids_use_devname(cmd)) {
+	if (cmd->enable_devices_file &&
+	    (device_ids_use_devname(cmd) || cmd->device_ids_refresh_trigger)) {
 		relax_deviceid_filter = 1;
 		cmd->filter_deviceid_skip = 1;
 		/* PVIDs read from devs matched to devices file below instead. */
-		log_debug("Skipping device_id filtering due to devname ids.");
+		log_debug("Skipping device_id filtering");
 	}
 
 	/*


=====================================
lib/report/report.c
=====================================
@@ -23,6 +23,7 @@
 #include "lib/metadata/segtype.h"
 #include "lib/cache/lvmcache.h"
 #include "lib/device/device-types.h"
+#include "lib/device/device_id.h"
 #include "lib/datastruct/str_list.h"
 #include "lib/locking/lvmlockd.h"
 
@@ -3571,6 +3572,9 @@ static int _pvdeviceid_disp(struct dm_report *rh, struct dm_pool *mem,
 	if (!pv->device_id)
 		return _field_set_value(field, "", NULL);
 
+	if (pv->dev && pv_device_id_is_stale(pv))
+		return _field_set_value(field, "invalid", NULL);
+
 	if (!(repstr = pv_deviceid_dup(mem, pv))) {
 		log_error("Failed to allocate buffer.");
 		return 0;
@@ -3589,6 +3593,9 @@ static int _pvdeviceidtype_disp(struct dm_report *rh, struct dm_pool *mem,
 	if (!pv->device_id_type)
 		return _field_set_value(field, "", NULL);
 
+	if (pv->dev && pv_device_id_is_stale(pv))
+		return _field_set_value(field, "invalid", NULL);
+
 	if (!(repstr = pv_deviceidtype_dup(mem, pv))) {
 		log_error("Failed to allocate buffer.");
 		return 0;


=====================================
man/lvmdevices.8_des
=====================================
@@ -28,13 +28,13 @@ will scan devices outside the devices file to locate PVs on renamed
 devices.  A config setting search_for_devnames can be used to control the
 scanning for renamed devname entries.
 .P
-Related to the devices file, the new command option --devices <devnames>
+Related to the devices file, the command option --devices <devnames>
 allows a list of devices to be specified for the command to use,
 overriding the devices file.  The listed devices act as a sort of devices
 file in terms of limiting which devices lvm will see and use.  Devices
 that are not listed will appear to be missing to the lvm command.
 .P
-Multiple devices files can be kept \fI#DEFAULT_SYS_DIR#/devices\fP, which
+Multiple devices files can be kept in \fI#DEFAULT_SYS_DIR#/devices\fP, which
 allows lvm to be used with different sets of devices.  For example, system
 devices do not need to be exposed to a specific application, and the
 application can use lvm on its own devices that are not exposed to the
@@ -70,12 +70,20 @@ Possible device ID types are:
 .br
 .IP \[bu] 2
 .B sys_wwid
-uses the wwid reported by sysfs.  This is the first choice for non-virtual
-devices.
+uses the wwid reported by the wwid sysfs file. This is the first choice.
+.IP \[bu] 2
+.B wwid_naa
+uses the naa wwid decoded from the vpd_pg83 sysfs file.
+.IP \[bu] 2
+.B wwid_eui
+uses the eui wwid decoded from the vpd_pg83 sysfs file.
+.IP \[bu] 2
+.B wwid_t10
+uses the t10 wwid decoded from the vpd_pg83 sysfs file.
 .IP \[bu] 2
 .B sys_serial
-uses the serial number reported by sysfs.  This is the second choice for
-non-virtual devices.
+uses the serial number reported by the serial sysfs file or the vpd_pg80
+file. A serial number is used if no wwid is available.
 .IP \[bu] 2
 .B mpath_uuid
 is used for dm multipath devices, reported by sysfs.
@@ -95,8 +103,24 @@ is used for loop devices, the backing file name repored by sysfs.
 .B devname
 the device name is used if no other type applies.
 .P
-
 The default choice for device ID type can be overridden using lvmdevices
 --addev --deviceidtype <type>.  If the specified type is available for the
 device it will be used, otherwise the device will be added using the type
 that would otherwise be chosen.
+
+.SS Device ID refresh
+.P
+A machine identifier is saved in the devices file, and is used to detect
+when the devices file has been created by a different machine. If the
+devices file was created by a different machine, it indicates that PVs may
+have been copied or restored onto new devices on a new machine. In this
+case, lvm will search for the PVs listed in system.devices on new devices.
+If found, the device IDs will be updated in system.devices for the
+existing PVIDs (assuming the original device IDs are also no longer
+found.)
+.P
+The machine identifier used in system.devices will be either the DMI
+product_uuid from /sys/devices/virtual/dmi/id/product_uuid, or the
+hostname from uname(2). See lvm.conf device_ids_refresh_checks to
+configure this.
+


=====================================
test/shell/devicesfile-devname.sh
=====================================
@@ -481,7 +481,7 @@ not grep "$dev1" "$DF"
 ls "$RUNDIR/lvm/pvs_online/$PVID1"
 ls "$RUNDIR/lvm/pvs_online/$PVID2"
 not ls "$RUNDIR/lvm/pvs_online/$PVID3"
-check lv_field $vg1/$lv1 lv_active "active"
+lvs -qq -o active $vg1/$lv1 | grep active
 # pvs updates the DF
 pvs |tee out
 grep "$dev1" out


=====================================
test/shell/devicesfile-refresh.sh
=====================================
@@ -0,0 +1,532 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2020-23 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+test_description='refresh device ids if system changes'
+
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+test -d /sys/block/ram0 && skip "Ramdisk already loaded"
+
+test "$DM_DEV_DIR" = "/dev" || skip "Only works with /dev access -> make check LVM_TEST_DEVDIR=/dev"
+
+# requires trailing / to match dm
+SYS_DIR="$PWD/test/sys"
+aux lvmconf "devices/use_devicesfile = 1" \
+	"devices/device_id_sysfs_dir = \"$SYS_DIR/\""
+
+aux lvmconf 'devices/global_filter = [ "a|.*|" ]'
+
+SERIAL1="S111"
+SERIAL2="S222"
+SERIAL3="S333"
+SERIAL4="S444"
+
+PRODUCT_UUID1="11111111-2222-3333-4444-555555555555"
+PRODUCT_UUID2="11111111-2222-3333-4444-666666666666"
+
+create_sysfs() {
+	mkdir -p "$SYS_DIR/dev/block/$MAJOR1:$MINOR1/device"
+	mkdir -p "$SYS_DIR/dev/block/$MAJOR2:$MINOR2/device"
+	mkdir -p "$SYS_DIR/dev/block/$MAJOR3:$MINOR3/device"
+	mkdir -p "$SYS_DIR/dev/block/$MAJOR4:$MINOR4/device"
+
+	echo "$SERIAL1" > "$SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/serial"
+	echo "$SERIAL2" > "$SYS_DIR/dev/block/$MAJOR2:$MINOR2/device/serial"
+	echo "$SERIAL3" > "$SYS_DIR/dev/block/$MAJOR3:$MINOR3/device/serial"
+	echo "$SERIAL4" > "$SYS_DIR/dev/block/$MAJOR4:$MINOR4/device/serial"
+
+	mkdir -p "$SYS_DIR/devices/virtual/dmi/id/"
+	echo "$PRODUCT_UUID1" > "$SYS_DIR/devices/virtual/dmi/id/product_uuid"
+}
+
+remove_sysfs() {
+	rm -rf "$SYS_DIR"
+}
+
+cleanup_and_teardown()
+{
+	remove_sysfs
+	rmmod brd
+
+	aux teardown
+}
+
+trap 'cleanup_and_teardown' EXIT
+
+modprobe brd rd_nr=4  || skip
+sleep 1
+remove_sysfs
+
+dev1="/dev/ram0"
+dev2="/dev/ram1"
+dev3="/dev/ram2"
+dev4="/dev/ram3"
+
+DFDIR="$LVM_SYSTEM_DIR/devices"
+mkdir -p "$DFDIR" || true
+DF="$DFDIR/system.devices"
+ORIG="$DFDIR/orig.devices"
+touch "$DF"
+
+aux wipefs_a "$dev1"
+aux wipefs_a "$dev2"
+aux wipefs_a "$dev3"
+aux wipefs_a "$dev4"
+
+vgcreate $vg1 "$dev1"
+eval "$(pvs --noheading --nameprefixes -o major,minor,uuid "$dev1")"
+MAJOR1=$LVM2_PV_MAJOR
+MINOR1=$LVM2_PV_MINOR
+OPVID1=$LVM2_PV_UUID
+PVID1=${OPVID1//-/}
+
+vgcreate $vg2 "$dev2"
+eval "$(pvs --noheading --nameprefixes -o major,minor,uuid "$dev2")"
+MAJOR2=$LVM2_PV_MAJOR
+MINOR2=$LVM2_PV_MINOR
+OPVID2=$LVM2_PV_UUID
+PVID2=${OPVID2//-/}
+
+# just using pvcreate/pvs to get MAJOR MINOR
+
+pvcreate "$dev3"
+eval "$(pvs --noheading --nameprefixes -o major,minor,uuid "$dev3")"
+MAJOR3=$LVM2_PV_MAJOR
+MINOR3=$LVM2_PV_MINOR
+
+pvcreate "$dev4"
+eval "$(pvs --noheading --nameprefixes -o major,minor,uuid "$dev4")"
+MAJOR4=$LVM2_PV_MAJOR
+MINOR4=$LVM2_PV_MINOR
+
+pvremove "$dev3"
+pvremove "$dev4"
+aux wipefs_a "$dev3"
+aux wipefs_a "$dev4"
+
+create_sysfs
+
+rm "$DF"
+
+vgimportdevices $vg1
+vgimportdevices $vg2
+
+cat "$DF"
+
+grep $PRODUCT_UUID1 "$DF"
+grep "$dev1" "$DF"
+grep "$dev2" "$DF"
+not grep "$dev3" "$DF"
+not grep "$dev4" "$DF"
+grep $SERIAL1 "$DF"
+grep $SERIAL2 "$DF"
+not grep $SERIAL3 "$DF"
+not grep $SERIAL4 "$DF"
+
+pvs |tee out
+grep "$dev1" out
+grep "$dev2" out
+not grep "$dev3" out
+not grep "$dev4" out
+
+# Prints the deviceid that's saved in metadata.
+pvs -o uuid,deviceid "$dev1" | tee out
+grep $OPVID1 out
+grep $SERIAL1 out
+
+# PV1 moves from dev1 to dev3 (and dev1 goes away)
+# lvm does not find PV1 until the product_uuid changes which
+# triggers the command to look at devs outside the DF.
+
+# PV1 moves to new dev
+dd if="$dev1" of="$dev3" bs=1M count=1
+aux wipefs_a "$dev1"
+rm "$SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/serial"
+
+# PV1 not found
+pvs |tee out
+not grep "$dev1" out
+grep "$dev2" out
+not grep "$dev3" out
+not grep "$dev4" out
+
+# DF unchanged
+grep $PRODUCT_UUID1 "$DF"
+grep "$dev1" "$DF"
+grep "$dev2" "$DF"
+not grep "$dev3" "$DF"
+not grep "$dev4" "$DF"
+grep $SERIAL1 "$DF"
+grep $SERIAL2 "$DF"
+not grep $SERIAL3 "$DF"
+not grep $SERIAL4 "$DF"
+
+# product_uuid changes
+echo "$PRODUCT_UUID2" > "$SYS_DIR/devices/virtual/dmi/id/product_uuid"
+
+# PV1 found on new dev
+pvs |tee out
+not grep "$dev1" out
+grep "$dev2" out
+grep "$dev3" out
+not grep "$dev4" out
+
+# DF updated replacing old dev with new dev
+grep $PRODUCT_UUID2 "$DF"
+not grep "$dev1" "$DF"
+grep "$dev2" "$DF"
+grep "$dev3" "$DF"
+not grep "$dev4" "$DF"
+not grep $SERIAL1 "$DF"
+grep $SERIAL2 "$DF"
+grep $SERIAL3 "$DF"
+not grep $SERIAL4 "$DF"
+
+# PV1 was originally written to dev1 but has not
+# moved to dev3.  The deviceid in the metadata is
+# S111 from dev1, but the PV is now on dev3 which
+# has deviceid S333.  Since the deviceid of the dev
+# doesn't match the deviceid savedin metadata,
+# "invalid" is printed when displaying the outdated
+# deviceid from the metadata.
+pvs -o uuid,deviceid "$dev3" | tee out
+grep $OPVID1 out
+grep invalid out
+
+# bring back dev1
+echo "$SERIAL1" > "$SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/serial"
+
+
+# No product_uuid so hostname is used
+
+rm "$SYS_DIR/devices/virtual/dmi/id/product_uuid"
+
+rm "$DF"
+vgimportdevices $vg1
+vgimportdevices $vg2
+
+grep HOSTNAME "$DF"
+not grep PRODUCT_UUID "$DF"
+
+pvs |tee out
+not grep "$dev1" out
+grep "$dev2" out
+grep "$dev3" out
+not grep "$dev4" out
+
+not grep "$dev1" "$DF"
+grep "$dev2" "$DF"
+grep "$dev3" "$DF"
+not grep "$dev4" "$DF"
+
+# PV1 moves from dev3 back to dev1
+# lvm does not find PV1 until the hostname changes which
+# triggers the command to look at devs outside the DF.
+
+# PV1 moves to new dev
+dd if="$dev3" of="$dev1" bs=1M count=1
+aux wipefs_a "$dev3"
+rm "$SYS_DIR/dev/block/$MAJOR3:$MINOR3/device/serial"
+
+# PV1 not found
+pvs |tee out
+not grep "$dev1" out
+grep "$dev2" out
+not grep "$dev3" out
+not grep "$dev4" out
+
+# we can't change the hostname to trigger lvm refresh,
+# but removing the HOSTNAME line from system.devices
+# will be a trigger.
+sed -e "s|HOSTNAME=.||" "$DF" > tmpdf
+cp tmpdf "$DF"
+
+# PV1 found on new dev
+pvs |tee out
+grep "$dev1" out
+grep "$dev2" out
+not grep "$dev3" out
+not grep "$dev4" out
+
+# DF updated replacing old dev with new dev
+not grep PRODUCT_UUID "$DF"
+grep HOSTNAME "$DF"
+grep "$dev1" "$DF"
+grep "$dev2" "$DF"
+not grep "$dev3" "$DF"
+not grep "$dev4" "$DF"
+grep $SERIAL1 "$DF"
+grep $SERIAL2 "$DF"
+not grep $SERIAL3 "$DF"
+not grep $SERIAL4 "$DF"
+
+# bring back dev3
+echo "$SERIAL3" > "$SYS_DIR/dev/block/$MAJOR3:$MINOR3/device/serial"
+
+# DF has no PRODUCT_UUID or HOSTNAME, lvm command adds one
+
+rm "$DF"
+vgimportdevices $vg1
+vgimportdevices $vg2
+
+sed -e "s|HOSTNAME=.||" "$DF" > tmpdf
+cp tmpdf "$DF"
+sed -e "s|PRODUCT_UUID=.||" "$DF" > tmpdf
+cp tmpdf "$DF"
+
+not grep HOSTNAME "$DF"
+not grep PRODUCT_UUID "$DF"
+
+pvs
+grep HOSTNAME "$DF"
+grep "$dev1" "$DF"
+grep "$dev2" "$DF"
+not grep "$dev3" "$DF"
+not grep "$dev4" "$DF"
+grep $SERIAL1 "$DF"
+grep $SERIAL2 "$DF"
+not grep $SERIAL3 "$DF"
+not grep $SERIAL4 "$DF"
+
+
+# DF has PRODUCT_UUID but system only has hostname,
+# and PV1 moves to different device
+
+echo "$PRODUCT_UUID1" > "$SYS_DIR/devices/virtual/dmi/id/product_uuid"
+rm "$DF"
+vgimportdevices $vg1
+vgimportdevices $vg2
+rm "$SYS_DIR/devices/virtual/dmi/id/product_uuid"
+
+# PV1 moves from dev1 to dev3
+dd if="$dev1" of="$dev3" bs=1M count=1
+aux wipefs_a "$dev1"
+rm "$SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/serial"
+
+pvs
+grep HOSTNAME "$DF"
+not grep "$dev1" "$DF"
+grep "$dev2" "$DF"
+grep "$dev3" "$DF"
+not grep "$dev4" "$DF"
+not grep $SERIAL1 "$DF"
+grep $SERIAL2 "$DF"
+grep $SERIAL3 "$DF"
+not grep $SERIAL4 "$DF"
+
+# bring back dev1
+echo "$SERIAL1" > "$SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/serial"
+
+# DF has HOSTNAME but system has product_uuid, lvm command updates it
+
+rm "$DF"
+vgimportdevices $vg1
+vgimportdevices $vg2
+
+grep HOSTNAME "$DF"
+echo "$PRODUCT_UUID1" > "$SYS_DIR/devices/virtual/dmi/id/product_uuid"
+pvs
+grep "$PRODUCT_UUID1" "$DF"
+not grep HOSTNAME "$DF"
+
+
+# DF has PRODUCT_UUID, system product_uuid changes, lvm command upates it
+
+rm "$DF"
+vgimportdevices $vg1
+vgimportdevices $vg2
+
+grep "$PRODUCT_UUID1" "$DF"
+echo "$PRODUCT_UUID2" > "$SYS_DIR/devices/virtual/dmi/id/product_uuid"
+pvs
+grep "$PRODUCT_UUID2" "$DF"
+
+# PV1 moves from dev3 back to dev1
+dd if="$dev3" of="$dev1" bs=1M count=1
+aux wipefs_a "$dev3"
+
+
+#
+# pvscan --cache and vgchange -aay work when refresh is triggered and
+# the device ids are wrong on the PVs that need to be autoactivated.
+#
+
+RUNDIR="/run"
+test -d "$RUNDIR" || RUNDIR="/var/run"
+PVS_ONLINE_DIR="$RUNDIR/lvm/pvs_online"
+VGS_ONLINE_DIR="$RUNDIR/lvm/vgs_online"
+PVS_LOOKUP_DIR="$RUNDIR/lvm/pvs_lookup"
+
+_clear_online_files() {
+        # wait till udev is finished
+        aux udev_wait
+        rm -f "$PVS_ONLINE_DIR"/*
+        rm -f "$VGS_ONLINE_DIR"/*
+        rm -f "$PVS_LOOKUP_DIR"/*
+}
+
+echo "$PRODUCT_UUID1" > "$SYS_DIR/devices/virtual/dmi/id/product_uuid"
+rm "$DF"
+vgimportdevices $vg1
+vgimportdevices $vg2
+grep "$PRODUCT_UUID1" "$DF"
+grep "$dev1" "$DF"
+grep "$dev2" "$DF"
+grep $SERIAL1 "$DF"
+grep $SERIAL2 "$DF"
+lvcreate -l1 -an -n $lv1 $vg1
+lvcreate -l1 -an -n $lv1 $vg2
+pvs -o+deviceid
+
+# PV1 moves from dev1 to dev3
+dd if="$dev1" of="$dev3" bs=1M count=1
+aux wipefs_a "$dev1"
+rm "$SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/serial"
+
+_clear_online_files
+
+# One PV in VG to autoactivate when system.devices has the wrong device ID
+# PV1 is listed in system.devices as being from dev1 with SERIAL1,
+# but PV1 is actually appearing from dev3 with SERIAL3.  PRODUCT_UUID is
+# wrong, so refresh is triggered and PV1 will be used from dev3.
+
+echo "$PRODUCT_UUID2" > "$SYS_DIR/devices/virtual/dmi/id/product_uuid"
+
+pvscan --cache --listvg --checkcomplete --vgonline --autoactivation event "$dev3"
+ls "$RUNDIR/lvm/pvs_online/$PVID1"
+ls "$RUNDIR/lvm/vgs_online/$vg1"
+vgchange -aay --autoactivation event $vg1
+
+# DF should be unchanged and have old info since the event based pvscan
+# and vgchange are special/optimized for auto activation and don't update DF
+grep "$PRODUCT_UUID1" "$DF"
+grep "$dev1" "$DF"
+grep "$dev2" "$DF"
+not grep "$dev3" "$DF"
+not grep "$dev4" "$DF"
+grep $SERIAL1 "$DF"
+grep $SERIAL2 "$DF"
+not grep $SERIAL3 "$DF"
+not grep $SERIAL4 "$DF"
+
+# check that pvs will update DF PV1 to have SERIAL3
+pvs
+grep "$PRODUCT_UUID2" "$DF"
+not grep "$dev1" "$DF"
+grep "$dev2" "$DF"
+grep "$dev3" "$DF"
+not grep "$dev4" "$DF"
+not grep $SERIAL1 "$DF"
+grep $SERIAL2 "$DF"
+grep $SERIAL3 "$DF"
+not grep $SERIAL4 "$DF"
+
+# check that the vgchange aay above actually activated the LV
+lvs -o active $vg1/$lv1 | grep active
+
+vgchange -an $vg1
+
+# bring back dev1
+echo "$SERIAL1" > "$SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/serial"
+
+# Two PVs in VG to autoactivate when system.devices has the wrong device ID
+
+# PV1 moves from dev3 back to dev1
+dd if="$dev3" of="$dev1" bs=1M count=1
+aux wipefs_a "$dev3"
+
+rm "$DF"
+vgremove -ff $vg1
+vgremove -ff $vg2
+pvs
+
+echo "$PRODUCT_UUID1" > "$SYS_DIR/devices/virtual/dmi/id/product_uuid"
+
+vgcreate $vg1 "$dev1" "$dev2"
+vgimportdevices $vg1
+lvcreate -l1 -n $lv1 $vg1 "$dev1"
+lvcreate -l1 -n $lv2 $vg1 "$dev2"
+lvcreate -l4 -i2 -n $lv3 $vg1 "$dev1" "$dev2"
+vgchange -an $vg1
+
+grep "$PRODUCT_UUID1" "$DF"
+grep "$dev1" "$DF"
+grep "$dev2" "$DF"
+not grep "$dev3" "$DF"
+not grep "$dev4" "$DF"
+grep $SERIAL1 "$DF"
+grep $SERIAL2 "$DF"
+not grep $SERIAL3 "$DF"
+not grep $SERIAL4 "$DF"
+
+# PV1 moves from dev1 to dev3
+dd if="$dev1" of="$dev3" bs=1M count=1
+aux wipefs_a "$dev1"
+rm "$SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/serial"
+
+# PV2 moves from dev2 to dev4
+dd if="$dev2" of="$dev4" bs=1M count=1
+aux wipefs_a "$dev2"
+rm "$SYS_DIR/dev/block/$MAJOR2:$MINOR2/device/serial"
+
+_clear_online_files
+
+# Two PVs in VG to autoactivate when system.devices has the wrong device ID
+# system.devices says PV1 has SERIAL1 and PV2 has SERIAL2, but the new
+# system has PV1 on SERIAL3 and PV2 on SERIAL4.
+# PRODUCT_UUID is wrong, so refresh finds PV1/PV2 on SERIAL3/SERIAL4
+
+echo "$PRODUCT_UUID2" > "$SYS_DIR/devices/virtual/dmi/id/product_uuid"
+
+pvscan --cache --listvg --checkcomplete --vgonline --autoactivation event "$dev3"
+pvscan --cache --listvg --checkcomplete --vgonline --autoactivation event "$dev4"
+ls "$RUNDIR/lvm/pvs_online/$PVID1"
+ls "$RUNDIR/lvm/pvs_online/$PVID2"
+ls "$RUNDIR/lvm/vgs_online/$vg1"
+ls "$RUNDIR/lvm/pvs_lookup/$vg1"
+vgchange -aay --autoactivation event $vg1
+
+# DF not yet updated by pvscan/vgchange
+
+grep "$PRODUCT_UUID1" "$DF"
+grep "$dev1" "$DF"
+grep "$dev2" "$DF"
+not grep "$dev3" "$DF"
+not grep "$dev4" "$DF"
+grep $SERIAL1 "$DF"
+grep $SERIAL2 "$DF"
+not grep $SERIAL3 "$DF"
+not grep $SERIAL4 "$DF"
+
+# check that lvmdevices will update DF
+lvmdevices --update
+grep "$PRODUCT_UUID2" "$DF"
+not grep "$dev1" "$DF"
+not grep "$dev2" "$DF"
+grep "$dev3" "$DF"
+grep "$dev4" "$DF"
+not grep $SERIAL1 "$DF"
+not grep $SERIAL2 "$DF"
+grep $SERIAL3 "$DF"
+grep $SERIAL4 "$DF"
+
+# check that the vgchange actually activated LVs
+lvs $vg1
+lvs -o active $vg1/$lv1 | grep active
+lvs -o active $vg1/$lv2 | grep active
+lvs -o active $vg1/$lv3 | grep active
+
+vgchange -an $vg1
+vgremove -ff $vg1
+


=====================================
test/shell/udev-pvscan-vgchange.sh
=====================================
@@ -81,11 +81,16 @@ wipe_all() {
 wait_lvm_activate() {
 	local vgw=$1
 	local wait=0
+	rm status || true
 
-	while systemctl status lvm-activate-$vgw > /dev/null && test "$wait" -le 30; do
-		sleep .2
-		wait=$(( wait + 1 ))
+	# time for service to be started
+	sleep 1
+
+ 	while systemctl status lvm-activate-$vgw |tee status && test "$wait" -le 30; do
+ 		sleep .2
+ 		wait=$(( wait + 1 ))
 	done
+	cat status || true
 }
 
 # Test requires 3 devs
@@ -179,10 +184,12 @@ udevadm trigger -c add "/sys/block/$BDEV3"
 aux udev_wait
 wait_lvm_activate $vg3
 
+find "$RUNDIR/lvm"
 ls "$RUNDIR/lvm/pvs_online/$PVID1"
 ls "$RUNDIR/lvm/pvs_online/$PVID2"
 ls "$RUNDIR/lvm/pvs_online/$PVID3"
 ls "$RUNDIR/lvm/vgs_online/$vg3"
+
 journalctl -u lvm-activate-$vg3 | tee out || true
 grep "now active" out
 check lv_field $vg3/$lv1 lv_active "active"
@@ -455,3 +462,80 @@ check lv_field $vg10/$lv1 lv_active "active"
 vgchange -an $vg10
 vgremove -y $vg10
 wipe_all
+
+aux lvmconf 'devices/filter = [ "a|.*|" ]'
+aux lvmconf 'devices/global_filter = [ "a|.*|" ]'
+
+#
+# system.devices contains different product_uuid and incorrect device IDs
+#
+
+SYS_DIR="$PWD/test/sys"
+
+aux lvmconf "devices/use_devicesfile = 1" \
+	"devices/device_id_sysfs_dir = \"$SYS_DIR/\""
+
+WWID1="naa.111"
+WWID2="naa.222"
+PRODUCT_UUID1="11111111-2222-3333-4444-555555555555"
+PRODUCT_UUID2="11111111-2222-3333-4444-666666666666"
+
+vgcreate $vg11 "$dev1"
+lvcreate -l1 -an -n $lv1 $vg11 "$dev1"
+
+eval "$(pvs --noheading --nameprefixes -o major,minor,uuid "$dev1")"
+MAJOR1=$LVM2_PV_MAJOR
+MINOR1=$LVM2_PV_MINOR
+OPVID1=$LVM2_PV_UUID
+PVID1=${OPVID1//-/}
+
+mkdir -p "$SYS_DIR/dev/block/$MAJOR1:$MINOR1/device"
+echo "$WWID1" > "$SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/wwid"
+mkdir -p "$SYS_DIR/devices/virtual/dmi/id/"
+echo "$PRODUCT_UUID1" > "$SYS_DIR/devices/virtual/dmi/id/product_uuid"
+
+vgimportdevices $vg11
+
+grep $PRODUCT_UUID1 "$DF"
+grep $PVID1 "$DF"
+grep $WWID1 "$DF"
+grep "$dev1" "$DF"
+
+# change wwid for dev1 and product_uuid for host
+
+echo "$WWID2" > "$SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/wwid"
+echo "$PRODUCT_UUID2" > "$SYS_DIR/devices/virtual/dmi/id/product_uuid"
+
+_clear_online_files
+
+udevadm trigger --settle -c add "/sys/block/$BDEV1"
+
+wait_lvm_activate $vg11
+
+ls "$RUNDIR/lvm/vgs_online/$vg11"
+journalctl -u lvm-activate-$vg11 | tee out || true
+grep "now active" out
+
+# Run ordinary command that will refresh device ID in system.devices
+pvs -o+uuid | tee out
+grep "$dev1" out
+grep "$OPVID1" out
+
+# check new wwid for dev1 and new product_uuid for host
+cat "$DF"
+grep $PRODUCT_UUID2 "$DF"
+not grep $PRODUCT_UUID1 "$DF"
+grep $PVID1 "$DF"
+grep $WWID2 "$DF"
+not grep $WWID1 "$DF"
+grep "$dev1" "$DF"
+
+check lv_field $vg11/$lv1 lv_active "active"
+
+vgchange -an $vg11
+vgremove -y $vg11
+
+rm -rf "$SYS_DIR"
+
+wipe_all
+


=====================================
tools/lvmdevices.c
=====================================
@@ -283,7 +283,7 @@ int lvmdevices(struct cmd_context *cmd, int argc, char **argv)
 		 * Find and fix any devname entries that have moved to a
 		 * renamed device.
 		 */
-		device_ids_find_renamed_devs(cmd, &found_devs, &search_count, 1);
+		device_ids_refresh(cmd, &found_devs, &search_count, 1);
 
 		if (search_count && !strcmp(cmd->search_for_devnames, "none"))
 			log_print("Not searching for missing devnames, search_for_devnames=\"none\".");


=====================================
tools/pvscan.c
=====================================
@@ -1441,18 +1441,20 @@ static int _pvscan_cache_args(struct cmd_context *cmd, int argc, char **argv,
 	 * If a match fails here do not exclude it, that will be done below by
 	 * passes_filter() which runs filter-deviceid. The
 	 * relax_deviceid_filter case needs to be able to work around
-	 * unmatching devs.
+	 * unmatching devs, or unmatching product_uuid/hostname which means
+	 * we can ignore the device ID and use any device with a PVID listed
+	 * in system.devices.
 	 */
 
 	if (cmd->enable_devices_file) {
 		dm_list_iterate_items(devl, &pvscan_devs)
 			device_ids_match_dev(cmd, devl->dev);
-
 	}
 	if (cmd->enable_devices_list)
 		device_ids_match_device_list(cmd);
 
-	if (cmd->enable_devices_file && device_ids_use_devname(cmd)) {
+	if (cmd->enable_devices_file &&
+	    (device_ids_use_devname(cmd) || cmd->device_ids_refresh_trigger)) {
 		relax_deviceid_filter = 1;
 		cmd->filter_deviceid_skip = 1;
 	}



View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/commit/88aa285a792637839c26cd78e1cedf4bd3273fd6

-- 
View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/commit/88aa285a792637839c26cd78e1cedf4bd3273fd6
You're receiving this email because of your account on gitlab.com.


-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20230927/e0a0380e/attachment-0001.htm>
