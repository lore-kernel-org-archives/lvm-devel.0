From: David Teigland <teigland@sourceware.org>
Date: Thu,  5 Aug 2021 18:21:26 +0000 (GMT)
Subject: main - pvscan: only match devices file for command args
Message-ID: <20210805182126.4D5053858436@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d0ab5bf7f98da83cd5d7ec393554dff309482cf4
Commit:        d0ab5bf7f98da83cd5d7ec393554dff309482cf4
Parent:        87714a1384def2ea107d7dbc264eff44c2025865
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Aug 4 12:04:03 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Aug 5 13:20:26 2021 -0500

pvscan: only match devices file for command args

Avoid matching all devices with the devices file to
avoid delays during startup.
---
 lib/device/dev-cache.c | 19 ++++++++++++++++++-
 lib/device/dev-cache.h |  1 +
 lib/device/device_id.c |  4 ++--
 tools/pvscan.c         | 46 ++++++++++++++++++++++++++++++++++++++++++++--
 4 files changed, 65 insertions(+), 5 deletions(-)

diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index b1d477ebb..4727ea652 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -1829,7 +1829,7 @@ int setup_devices_file(struct cmd_context *cmd)
  * Add all system devices to dev-cache, and attempt to
  * match all devices_file entries to dev-cache entries.
  */
-int setup_devices(struct cmd_context *cmd)
+static int _setup_devices(struct cmd_context *cmd, int no_file_match)
 {
 	int file_exists;
 	int lock_mode = 0;
@@ -1956,6 +1956,13 @@ int setup_devices(struct cmd_context *cmd)
 	 */
 	dev_cache_scan(cmd);
 
+	/*
+	 * The caller uses "no_file_match" if it wants to match specific devs
+	 * itself, instead of matching everything in device_ids_match.
+	 */
+	if (no_file_match && cmd->enable_devices_file)
+		return 1;
+
 	/*
 	 * Match entries from cmd->use_devices with device structs in dev-cache.
 	 */
@@ -1964,6 +1971,16 @@ int setup_devices(struct cmd_context *cmd)
 	return 1;
 }
 
+int setup_devices(struct cmd_context *cmd)
+{
+	return _setup_devices(cmd, 0);
+}
+
+int setup_devices_no_file_match(struct cmd_context *cmd)
+{
+	return _setup_devices(cmd, 1);
+}
+
 /*
  * The alternative to setup_devices() when the command is interested
  * in using only one PV.
diff --git a/lib/device/dev-cache.h b/lib/device/dev-cache.h
index 30ef1cdbe..635dc4fc9 100644
--- a/lib/device/dev-cache.h
+++ b/lib/device/dev-cache.h
@@ -77,6 +77,7 @@ int get_dm_uuid_from_sysfs(char *buf, size_t buf_size, int major, int minor);
 
 int setup_devices_file(struct cmd_context *cmd);
 int setup_devices(struct cmd_context *cmd);
+int setup_devices_no_file_match(struct cmd_context *cmd);
 int setup_device(struct cmd_context *cmd, const char *devname);
 
 #endif
diff --git a/lib/device/device_id.c b/lib/device/device_id.c
index 6f61cf3f1..429164062 100644
--- a/lib/device/device_id.c
+++ b/lib/device/device_id.c
@@ -1324,7 +1324,7 @@ static int _match_du_to_dev(struct cmd_context *cmd, struct dev_use *du, struct
 				du->dev = dev;
 				dev->id = id;
 				dev->flags |= DEV_MATCHED_USE_ID;
-				log_debug("compare match %s %s to %s",
+				log_debug("Match device_id %s %s to %s",
 					  idtype_to_str(du->idtype), du->idname, dev_name(dev));
 				return 1;
 			} else {
@@ -1370,7 +1370,7 @@ static int _match_du_to_dev(struct cmd_context *cmd, struct dev_use *du, struct
 		du->dev = dev;
 		dev->id = id;
 		dev->flags |= DEV_MATCHED_USE_ID;
-		log_debug("compare match %s %s to %s",
+		log_debug("Match device_id %s %s to %s",
 			  idtype_to_str(du->idtype), du->idname, dev_name(dev));
 		return 1;
 	}
diff --git a/tools/pvscan.c b/tools/pvscan.c
index 1c84b8407..229989051 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -926,6 +926,14 @@ static int _pvscan_aa_quick(struct cmd_context *cmd, struct pvscan_aa_params *pp
 		return ECMD_FAILED;
 	}
 
+	/*
+	 * The list of devs do not need to be filtered or checked
+	 * against the devices file because a dev is only returned
+	 * that has a pv online file, and a dev will only have a
+	 * pv online file if it's been processed by a previous
+	 * pvscan, which did the filtering and devices file check.
+	 */
+
 	/*
 	 * Lock the VG before scanning so we don't need to
 	 * rescan in _vg_read.  (The lock_vol and the
@@ -1060,9 +1068,25 @@ static int _pvscan_aa(struct cmd_context *cmd, struct pvscan_aa_params *pp,
 	 */
 	if (!saved_vg || (dm_list_size(vgnames) > 1) || no_quick) {
 		uint32_t read_flags = READ_FOR_ACTIVATE;
+
+		log_debug("autoactivate slow");
+
+		/*
+		 * PROCESS_SKIP_SCAN: we have already done lvmcache_label_scan
+		 * so tell process_each to skip it.
+		 */
 		if (do_all)
 			read_flags |= PROCESS_SKIP_SCAN;
-		log_debug("autoactivate slow");
+
+		/*
+		 * When the command is processing specific devs (not all), it
+		 * has done setup_devices_no_file_match() to avoid matching ids
+		 * fo all devs unnecessarily, but now that we're falling back
+		 * to process_each_vg() we need to complete the id matching.
+		 */
+		if (!do_all)
+			device_ids_match(cmd);
+
 		ret = process_each_vg(cmd, 0, NULL, NULL, vgnames, read_flags, 0, handle, _pvscan_aa_single);
 	}
 
@@ -1442,7 +1466,12 @@ static int _pvscan_cache_args(struct cmd_context *cmd, int argc, char **argv,
 
 	cmd->pvscan_cache_single = 1;
 
-	if (!setup_devices(cmd)) {
+	/*
+	 * "no_file_match" means that when the devices file is used,
+	 * setup_devices will skip matching devs to devices file entries.
+	 * Specific devs must be matched later with device_ids_match_dev().
+	 */
+	if (!setup_devices_no_file_match(cmd)) {
 		log_error("Failed to set up devices.");
 		return 0;
 	}
@@ -1500,6 +1529,19 @@ static int _pvscan_cache_args(struct cmd_context *cmd, int argc, char **argv,
 	 
 	log_debug("pvscan_cache_args: filter devs nodata");
 
+	/*
+	 * Match dev args with the devices file because
+	 * setup_devices_no_file_match() was used above which skipped checking
+	 * the devices file.  If a match fails here do not exclude it, that
+	 * will be done below by passes_filter() which runs filter-deviceid.
+	 * The relax_deviceid_filter case needs to be able to work around
+	 * unmatching devs.
+	 */
+	if (cmd->enable_devices_file) {
+		dm_list_iterate_items_safe(devl, devl2, &pvscan_devs)
+			device_ids_match_dev(cmd, devl->dev);
+	}
+
 	if (cmd->enable_devices_file && device_ids_use_devname(cmd)) {
 		relax_deviceid_filter = 1;
 		cmd->filter_deviceid_skip = 1;


