From: David Teigland <teigland@sourceware.org>
Date: Tue, 19 Oct 2021 22:22:43 +0000 (GMT)
Subject: main - pvscan: only add device args to dev cache
Message-ID: <20211019222243.399D23858D39@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=33e47182f773c1a902b533580b63a803906de55d
Commit:        33e47182f773c1a902b533580b63a803906de55d
Parent:        60dc44b707149e31fa766885574484aa5172f498
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Oct 18 16:24:24 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Oct 19 17:13:57 2021 -0500

pvscan: only add device args to dev cache

Optimize the common pvscan --cache command by only adding
the necessary devs to dev-cache.
---
 lib/device/dev-cache.c          | 204 ++++++++++++++++++++++++++++++++++++----
 lib/device/dev-cache.h          |   6 +-
 lib/device/device_id.c          |  27 ++++--
 lib/device/device_id.h          |   1 +
 test/shell/devicesfile-basic.sh |   2 +-
 tools/pvscan.c                  |  58 +++++++-----
 6 files changed, 246 insertions(+), 52 deletions(-)

diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index c6e5f68cf..33b75a9a9 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -1852,7 +1852,7 @@ int setup_devices_file(struct cmd_context *cmd)
  * Add all system devices to dev-cache, and attempt to
  * match all devices_file entries to dev-cache entries.
  */
-static int _setup_devices(struct cmd_context *cmd, int no_file_match)
+int setup_devices(struct cmd_context *cmd)
 {
 	int file_exists;
 	int lock_mode = 0;
@@ -1979,13 +1979,6 @@ static int _setup_devices(struct cmd_context *cmd, int no_file_match)
 	 */
 	dev_cache_scan(cmd);
 
-	/*
-	 * The caller uses "no_file_match" if it wants to match specific devs
-	 * itself, instead of matching everything in device_ids_match.
-	 */
-	if (no_file_match && cmd->enable_devices_file)
-		return 1;
-
 	/*
 	 * Match entries from cmd->use_devices with device structs in dev-cache.
 	 */
@@ -1994,16 +1987,6 @@ static int _setup_devices(struct cmd_context *cmd, int no_file_match)
 	return 1;
 }
 
-int setup_devices(struct cmd_context *cmd)
-{
-	return _setup_devices(cmd, 0);
-}
-
-int setup_devices_no_file_match(struct cmd_context *cmd)
-{
-	return _setup_devices(cmd, 1);
-}
-
 /*
  * The alternative to setup_devices() when the command is interested
  * in using only one PV.
@@ -2072,3 +2055,188 @@ int setup_device(struct cmd_context *cmd, const char *devname)
 	return 1;
 }
 
+/*
+ * pvscan --cache is specialized/optimized to look only at command args,
+ * so this just sets up the devices file, then individual devices are
+ * added to dev-cache and matched with device_ids later in pvscan.
+ */
+
+int setup_devices_for_pvscan_cache(struct cmd_context *cmd)
+{
+	if (cmd->enable_devices_list) {
+		if (!_setup_devices_list(cmd))
+			return_0;
+		return 1;
+	}
+
+	if (!setup_devices_file(cmd))
+		return_0;
+
+	if (!cmd->enable_devices_file)
+		return 1;
+
+	if (!devices_file_exists(cmd)) {
+		log_debug("Devices file not found, ignoring.");
+		cmd->enable_devices_file = 0;
+		return 1;
+	}
+
+	if (!lock_devices_file(cmd, LOCK_SH)) {
+		log_error("Failed to lock the devices file to read.");
+		return 0;
+	}
+
+	if (!device_ids_read(cmd)) {
+		log_error("Failed to read the devices file.");
+		unlock_devices_file(cmd);
+		return 0;
+	}
+
+	unlock_devices_file(cmd);
+	return 1;
+}
+
+
+/* Get a device name from a devno. */
+
+static char *_get_devname_from_devno(struct cmd_context *cmd, dev_t devno)
+{
+	char path[PATH_MAX];
+	char devname[PATH_MAX];
+	char namebuf[NAME_LEN];
+	char line[1024];
+	int major = MAJOR(devno);
+	int minor = MINOR(devno);
+	int line_major;
+	int line_minor;
+	uint64_t line_blocks;
+	DIR *dir;
+	struct dirent *dirent;
+	FILE *fp;
+
+	/*
+	 * $ ls /sys/dev/block/8:0/device/block/
+	 * sda
+	 */
+	if (major_is_scsi_device(cmd->dev_types, major)) {
+		if (dm_snprintf(path, sizeof(path), "%sdev/block/%d:%d/device/block",
+				dm_sysfs_dir(), major, minor) < 0) {
+			return NULL;
+		}
+
+		if (!(dir = opendir(path)))
+			return NULL;
+
+		while ((dirent = readdir(dir))) {
+			if (dirent->d_name[0] == '.')
+				continue;
+			if (dm_snprintf(devname, sizeof(devname), "/dev/%s", dirent->d_name) < 0) {
+				devname[0] = '\0';
+				stack;
+			}
+			break;
+		}
+		closedir(dir);
+
+		if (devname[0]) {
+			log_debug("Found %s for %d:%d from sys", devname, major, minor);
+			return _strdup(devname);
+		}
+		return NULL;
+	}
+
+	/*
+	 * $ cat /sys/dev/block/253:3/dm/name
+	 * mpatha
+	 */
+	if (major == cmd->dev_types->device_mapper_major) {
+		if (dm_snprintf(path, sizeof(path), "%sdev/block/%d:%d/dm/name",
+				dm_sysfs_dir(), major, minor) < 0) {
+			return NULL;
+		}
+
+		if (!get_sysfs_value(path, namebuf, sizeof(namebuf), 0))
+			return NULL;
+
+		if (dm_snprintf(devname, sizeof(devname), "/dev/mapper/%s", namebuf) < 0) {
+			devname[0] = '\0';
+			stack;
+		}
+
+		if (devname[0]) {
+			log_debug("Found %s for %d:%d from sys", devname, major, minor);
+			return _strdup(devname);
+		}
+		return NULL;
+	}
+
+	/*
+	 * /proc/partitions lists
+	 * major minor #blocks name
+	 */
+
+	if (!(fp = fopen("/proc/partitions", "r")))
+		return NULL;
+
+	while (fgets(line, sizeof(line), fp)) {
+		if (sscanf(line, "%u %u %llu %s", &line_major, &line_minor, (unsigned long long *)&line_blocks, namebuf) != 4)
+			continue;
+		if (line_major != major)
+			continue;
+		if (line_minor != minor)
+			continue;
+
+		if (dm_snprintf(devname, sizeof(devname), "/dev/%s", namebuf) < 0) {
+			devname[0] = '\0';
+			stack;
+		}
+		break;
+	}
+	fclose(fp);
+
+	if (devname[0]) {
+		log_debug("Found %s for %d:%d from proc", devname, major, minor);
+		return _strdup(devname);
+	}
+
+	/*
+	 * If necessary, this could continue searching by stat'ing /dev entries.
+	 */
+
+	return NULL;
+}
+
+int setup_devname_in_dev_cache(struct cmd_context *cmd, const char *devname)
+{
+	struct stat buf;
+	struct device *dev;
+
+	if (stat(devname, &buf) < 0) {
+		log_error("Cannot access device %s.", devname);
+		return 0;
+	}
+
+	if (!S_ISBLK(buf.st_mode)) {
+		log_error("Invaild device type %s.", devname);
+		return 0;
+	}
+
+	if (!_insert_dev(devname, buf.st_rdev))
+		return_0;
+
+	if (!(dev = (struct device *) dm_hash_lookup(_cache.names, devname)))
+		return_0;
+
+	return 1;
+}
+
+int setup_devno_in_dev_cache(struct cmd_context *cmd, dev_t devno)
+{
+	const char *devname;
+
+	if (!(devname = _get_devname_from_devno(cmd, devno)))
+		return_0;
+
+	return setup_devname_in_dev_cache(cmd, devname);
+}
+
diff --git a/lib/device/dev-cache.h b/lib/device/dev-cache.h
index 635dc4fc9..143848d6d 100644
--- a/lib/device/dev-cache.h
+++ b/lib/device/dev-cache.h
@@ -77,7 +77,11 @@ int get_dm_uuid_from_sysfs(char *buf, size_t buf_size, int major, int minor);
 
 int setup_devices_file(struct cmd_context *cmd);
 int setup_devices(struct cmd_context *cmd);
-int setup_devices_no_file_match(struct cmd_context *cmd);
 int setup_device(struct cmd_context *cmd, const char *devname);
 
+/* Normal device setup functions are split up for pvscan optimization. */
+int setup_devices_for_pvscan_cache(struct cmd_context *cmd);
+int setup_devname_in_dev_cache(struct cmd_context *cmd, const char *devname);
+int setup_devno_in_dev_cache(struct cmd_context *cmd, dev_t devno);
+
 #endif
diff --git a/lib/device/device_id.c b/lib/device/device_id.c
index eb06109ff..167bf661b 100644
--- a/lib/device/device_id.c
+++ b/lib/device/device_id.c
@@ -1534,6 +1534,22 @@ int device_ids_match_dev(struct cmd_context *cmd, struct device *dev)
  * passes the filter.
  */
 
+void device_ids_match_device_list(struct cmd_context *cmd)
+{
+	struct dev_use *du;
+
+	dm_list_iterate_items(du, &cmd->use_devices) {
+		if (du->dev)
+			continue;
+		if (!(du->dev = dev_cache_get(cmd, du->devname, NULL))) {
+			log_warn("Device not found for %s.", du->devname);
+		} else {
+			/* Should we set dev->id?  Which idtype?  Use --deviceidtype? */
+			du->dev->flags |= DEV_MATCHED_USE_ID;
+		}
+	}
+}
+
 void device_ids_match(struct cmd_context *cmd)
 {
 	struct dev_iter *iter;
@@ -1541,16 +1557,7 @@ void device_ids_match(struct cmd_context *cmd)
 	struct device *dev;
 
 	if (cmd->enable_devices_list) {
-		dm_list_iterate_items(du, &cmd->use_devices) {
-			if (du->dev)
-				continue;
-			if (!(du->dev = dev_cache_get(cmd, du->devname, NULL))) {
-				log_warn("Device not found for %s.", du->devname);
-			} else {
-				/* Should we set dev->id?  Which idtype?  Use --deviceidtype? */
-				du->dev->flags |= DEV_MATCHED_USE_ID;
-			}
-		}
+		device_ids_match_device_list(cmd);
 		return;
 	}
 
diff --git a/lib/device/device_id.h b/lib/device/device_id.h
index 939b3a0f4..0ada35c94 100644
--- a/lib/device/device_id.h
+++ b/lib/device/device_id.h
@@ -32,6 +32,7 @@ int device_id_add(struct cmd_context *cmd, struct device *dev, const char *pvid,
 void device_id_pvremove(struct cmd_context *cmd, struct device *dev);
 void device_ids_match(struct cmd_context *cmd);
 int device_ids_match_dev(struct cmd_context *cmd, struct device *dev);
+void device_ids_match_device_list(struct cmd_context *cmd);
 void device_ids_validate(struct cmd_context *cmd, struct dm_list *scanned_devs, int *device_ids_invalid, int noupdate);
 int device_ids_version_unchanged(struct cmd_context *cmd);
 void device_ids_find_renamed_devs(struct cmd_context *cmd, struct dm_list *dev_list, int *search_count, int noupdate);
diff --git a/test/shell/devicesfile-basic.sh b/test/shell/devicesfile-basic.sh
index 7ba9e2c7f..9c3455c76 100644
--- a/test/shell/devicesfile-basic.sh
+++ b/test/shell/devicesfile-basic.sh
@@ -283,7 +283,7 @@ not ls "$RUNDIR/lvm/pvs_online/$PVID3"
 # arg in devices list
 _clear_online_files
 pvscan --devices "$dev3" --cache -aay "$dev3"
-pvscan --devices "$dev4" --cache -aay "$dev4"
+pvscan --devices "$dev4","$dev3" --cache -aay "$dev4"
 check lv_field $vg2/$lv2 lv_active "active"
 vgchange -an $vg2
 
diff --git a/tools/pvscan.c b/tools/pvscan.c
index 8e2611361..95d593d57 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -857,11 +857,21 @@ static int _get_devs_from_saved_vg(struct cmd_context *cmd, const char *vgname,
 
 		devno = MKDEV(file_major, file_minor);
 
+		if (!setup_devno_in_dev_cache(cmd, devno)) {
+			log_error_pvscan(cmd, "No device set up for %d:%d PVID %s", file_major, file_minor, pvid);
+			goto bad;
+		}
+
 		if (!(dev = dev_cache_get_by_devt(cmd, devno, NULL, NULL))) {
 			log_error_pvscan(cmd, "No device found for %d:%d PVID %s", file_major, file_minor, pvid);
 			goto bad;
 		}
 
+		/*
+		 * Do not need to match device_id here, see comment after
+		 * get_devs_from_saved_vg about relying on pvid online file.
+		 */
+
 		name1 = dev_name(dev);
 		name2 = pvl->pv->device_hint;
 
@@ -1099,17 +1109,11 @@ static int _pvscan_aa(struct cmd_context *cmd, struct pvscan_aa_params *pp,
 		 * PROCESS_SKIP_SCAN: we have already done lvmcache_label_scan
 		 * so tell process_each to skip it.
 		 */
-		if (do_all)
-			read_flags |= PROCESS_SKIP_SCAN;
 
-		/*
-		 * When the command is processing specific devs (not all), it
-		 * has done setup_devices_no_file_match() to avoid matching ids
-		 * fo all devs unnecessarily, but now that we're falling back
-		 * to process_each_vg() we need to complete the id matching.
-		 */
 		if (!do_all)
-			device_ids_match(cmd);
+			lvmcache_label_scan(cmd);
+
+		read_flags |= PROCESS_SKIP_SCAN;
 
 		ret = process_each_vg(cmd, 0, NULL, NULL, vgnames, read_flags, 0, handle, _pvscan_aa_single);
 	}
@@ -1192,11 +1196,15 @@ static int _get_args_devs(struct cmd_context *cmd, struct dm_list *pvscan_args,
 	/* in common usage, no dev will be found for a devno */
 
 	dm_list_iterate_items(arg, pvscan_args) {
-		if (arg->devname)
+		if (arg->devname) {
+			if (!setup_devname_in_dev_cache(cmd, arg->devname))
+				log_error_pvscan(cmd, "No device set up for name arg %s", arg->devname);
 			arg->dev = dev_cache_get(cmd, arg->devname, NULL);
-		else if (arg->devno)
+		} else if (arg->devno) {
+			if (!setup_devno_in_dev_cache(cmd, arg->devno))
+				log_error_pvscan(cmd, "No device set up for devno arg %d", (int)arg->devno);
 			arg->dev = dev_cache_get_by_devt(cmd, arg->devno, NULL, NULL);
-		else
+		} else
 			return_0;
 	}
 
@@ -1672,11 +1680,13 @@ static int _pvscan_cache_args(struct cmd_context *cmd, int argc, char **argv,
 	cmd->pvscan_cache_single = 1;
 
 	/*
-	 * "no_file_match" means that when the devices file is used,
-	 * setup_devices will skip matching devs to devices file entries.
-	 * Specific devs must be matched later with device_ids_match_dev().
+	 * Special pvscan-specific setup steps to avoid looking
+	 * at any devices except for device args.
+	 * Read devices file and determine if devices file will be used.
+	 * Does not do dev_cache_scan (adds nothing to dev-cache), and
+	 * does not do any device id matching.
 	 */
-	if (!setup_devices_no_file_match(cmd)) {
+	if (!setup_devices_for_pvscan_cache(cmd)) {
 		log_error_pvscan(cmd, "Failed to set up devices.");
 		return 0;
 	}
@@ -1735,17 +1745,21 @@ static int _pvscan_cache_args(struct cmd_context *cmd, int argc, char **argv,
 	log_debug("pvscan_cache_args: filter devs nodata");
 
 	/*
-	 * Match dev args with the devices file because
-	 * setup_devices_no_file_match() was used above which skipped checking
-	 * the devices file.  If a match fails here do not exclude it, that
-	 * will be done below by passes_filter() which runs filter-deviceid.
-	 * The relax_deviceid_filter case needs to be able to work around
+	 * Match dev args with the devices file because special/optimized
+	 * device setup was used above which does not check the devices file.
+	 * If a match fails here do not exclude it, that will be done below by
+	 * passes_filter() which runs filter-deviceid. The
+	 * relax_deviceid_filter case needs to be able to work around
 	 * unmatching devs.
 	 */
+
 	if (cmd->enable_devices_file) {
-		dm_list_iterate_items_safe(devl, devl2, &pvscan_devs)
+		dm_list_iterate_items(devl, &pvscan_devs)
 			device_ids_match_dev(cmd, devl->dev);
+
 	}
+	if (cmd->enable_devices_list)
+		device_ids_match_device_list(cmd);
 
 	if (cmd->enable_devices_file && device_ids_use_devname(cmd)) {
 		relax_deviceid_filter = 1;


