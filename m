From: David Teigland <teigland@sourceware.org>
Date: Mon, 8 Apr 2019 11:39:30 -0400
Subject: master - pvscan: reorganize code
Message-ID: <201904081539.x38FdUub022987@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=417724efe260723889ca4013dd7fff80bb5375c3
Commit:        417724efe260723889ca4013dd7fff80bb5375c3
Parent:        6f408f68d2094490ad28df2844889d4e9c1d1dbc
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Feb 26 16:35:16 2019 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 5 12:46:39 2019 -0500

pvscan: reorganize code

to simplify and prepare for subsequent change.
Should be no change in behavior.
---
 tools/pvscan.c |  285 +++++++++++++++++++++++++++++---------------------------
 1 files changed, 148 insertions(+), 137 deletions(-)

diff --git a/tools/pvscan.c b/tools/pvscan.c
index d69d919..f0944cd 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -860,7 +860,8 @@ static int _pvscan_aa(struct cmd_context *cmd, struct pvscan_aa_params *pp,
 int pvscan_cache_cmd(struct cmd_context *cmd, int argc, char **argv)
 {
 	struct pvscan_aa_params pp = { 0 };
-	struct dm_list single_devs;
+	struct dm_list add_devs;
+	struct dm_list rem_devs;
 	struct dm_list vgnames;
 	struct dm_list *complete_vgnames = NULL;
 	struct device *dev;
@@ -870,6 +871,7 @@ int pvscan_cache_cmd(struct cmd_context *cmd, int argc, char **argv)
 	int32_t major = -1;
 	int32_t minor = -1;
 	int devno_args = 0;
+	int all_devs;
 	struct arg_value_group_list *current_group;
 	dev_t devno;
 	int do_activate = arg_is_set(cmd, activate_ARG);
@@ -877,7 +879,8 @@ int pvscan_cache_cmd(struct cmd_context *cmd, int argc, char **argv)
 	int add_single_count = 0;
 	int ret = ECMD_PROCESSED;
 
-	dm_list_init(&single_devs);
+	dm_list_init(&add_devs);
+	dm_list_init(&rem_devs);
 	dm_list_init(&vgnames);
 
 	if (do_activate)
@@ -891,89 +894,36 @@ int pvscan_cache_cmd(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
-	_online_dir_setup();
-	_online_file_setup();
-	
+	if (argc || devno_args) {
+		log_verbose("pvscan devices on command line.");
+		cmd->pvscan_cache_single = 1;
+		all_devs = 0;
+	} else {
+		all_devs = 1;
+	}
+
 	if (!lock_vol(cmd, VG_GLOBAL, LCK_VG_READ, NULL)) {
 		log_error("Unable to obtain global lock.");
 		return ECMD_FAILED;
 	}
 
-	/*
-	 * Scan all devices when no args are given.
-	 */
-	if (!argc && !devno_args) {
-		/*
-		 * pvscan --cache removes existing hints and recreates new ones.
-		 * We begin by clearing hints at the start of the command.
-		 * The pvscan_recreate_hints flag is used to enable the
-		 * special case hint recreation in label_scan.
-		 */
-		cmd->pvscan_recreate_hints = 1;
-		pvscan_recreate_hints_begin(cmd);
-
-		_lock_online(LOCK_EX, 0);
-		log_verbose("pvscan all devices for requested refresh.");
-		_online_files_remove(_pvs_online_dir);
-		_online_files_remove(_vgs_online_dir);
-		_online_pvscan_all_devs(cmd, complete_vgnames, NULL);
-		_unlock_online();
+	_online_dir_setup();
+	_online_file_setup();
 
-		cmd->pvscan_recreate_hints = 0;
-		cmd->use_hints = 0;
-		goto activate;
-	}
+	/* Creates a list of dev names from /dev, sysfs, etc; does not read any. */
+	dev_cache_scan();
 
 	/*
-	 * Initialization case:
-	 * lock_online ex
-	 * if empty
-	 * pvscan all
-	 * create pvid files
-	 * identify complete vgs
-	 * unlock_online
-	 * activate complete vgs
-	 *
-	 * Non-initialization case:
-	 * lock_online ex
-	 * if not empty
-	 * unlock_unlock
-	 * pvscan devs
-	 * create pvid files
-	 * identify complete vgs
-	 * activate complete vgs
-	 *
-	 * In the non-init case, a VG with two PVs, where both PVs appear at once,
-	 * two parallel pvscans for each PV create the pvid files for each PV in
-	 * parallel, then both pvscans see the vg has completed, and both pvscans
-	 * activate the VG in parallel.  The first pvscan to create the vgname
-	 * file in vgs_online will do the activation, any others will skip it.
+	 * For each device command arg (from either position or --major/--minor),
+	 * decide if that device is being added to the system (a dev node exists
+	 * for it in /dev), or being removed from the system (no dev node exists
+	 * for it in /dev).  Create entries in add_devs/rem_devs for each arg
+	 * accordingly.
 	 */
 
-	_lock_online(LOCK_EX, 0);
-
-	if (_online_pvid_files_missing()) {
-		log_verbose("pvscan all devices to initialize available PVs.");
-		_online_files_remove(_pvs_online_dir);
-		_online_files_remove(_vgs_online_dir);
-		cmd->pvscan_cache_single = 1;
-		_online_pvscan_all_devs(cmd, complete_vgnames, NULL);
-		_unlock_online();
-		goto activate;
-	} else {
-		log_verbose("pvscan only specific devices.");
-		_unlock_online();
-	}
+	while (argc) {
+		argc--;
 
-	if (argc || devno_args) {
-		log_verbose("pvscan devices on command line.");
-		cmd->pvscan_cache_single = 1;
-	}
-
-	/* Creates a list of dev names from /dev, sysfs, etc; does not read any. */
-	dev_cache_scan();
-
-	while (argc--) {
 		pv_name = *argv++;
 		if (pv_name[0] == '/') {
 			if (!(dev = dev_cache_get(cmd, pv_name, cmd->filter))) {
@@ -994,7 +944,7 @@ int pvscan_cache_cmd(struct cmd_context *cmd, int argc, char **argv)
 				if (!(devl = dm_pool_zalloc(cmd->mem, sizeof(*devl))))
 					return_0;
 				devl->dev = dev;
-				dm_list_add(&single_devs, &devl->list);
+				dm_list_add(&add_devs, &devl->list);
 			}
 		} else {
 			if (sscanf(pv_name, "%d:%d", &major, &minor) != 2) {
@@ -1005,7 +955,13 @@ int pvscan_cache_cmd(struct cmd_context *cmd, int argc, char **argv)
 
 			if (!(dev = dev_cache_get_by_devt(cmd, devno, cmd->filter))) {
 				log_debug("pvscan arg %d:%d not found.", major, minor);
-				_online_pvid_file_remove_devno(major, minor);
+				if (!(dev = dm_pool_zalloc(cmd->mem, sizeof(struct device))))
+					return_0;
+				if (!(devl = dm_pool_zalloc(cmd->mem, sizeof(*devl))))
+					return_0;
+				dev->dev = devno;
+				devl->dev = dev;
+				dm_list_add(&rem_devs, &devl->list);
 			} else {
 				/*
 				 * Scan device.  This dev could still be removed
@@ -1016,41 +972,11 @@ int pvscan_cache_cmd(struct cmd_context *cmd, int argc, char **argv)
 				if (!(devl = dm_pool_zalloc(cmd->mem, sizeof(*devl))))
 					return_0;
 				devl->dev = dev;
-				dm_list_add(&single_devs, &devl->list);
+				dm_list_add(&add_devs, &devl->list);
 			}
 		}
-
-		if (sigint_caught()) {
-			ret = ECMD_FAILED;
-			goto_out;
-		}
 	}
 
-	if (!dm_list_empty(&single_devs)) {
-		label_scan_devs(cmd, cmd->filter, &single_devs);
-
-		dm_list_iterate_items(devl, &single_devs) {
-			dev = devl->dev;
-
-			if (dev->flags & DEV_FILTER_OUT_SCAN)
-				continue;
-
-			add_single_count++;
-
-			/*
-			 * Devices that exist and pass the lvmetad filter
-			 * are online.
-			 */
-			if (!_online_pvscan_one(cmd, dev, NULL, complete_vgnames, 0, &pvid_without_metadata))
-				add_errors++;
-		}
-	}
-
-	if (!devno_args)
-		goto activate;
-
-	dm_list_init(&single_devs);
-
 	/* Process any grouped --major --minor args */
 	dm_list_iterate_items(current_group, &cmd->arg_value_groups) {
 		major = grouped_arg_int_value(current_group->arg_values, major_ARG, major);
@@ -1063,26 +989,114 @@ int pvscan_cache_cmd(struct cmd_context *cmd, int argc, char **argv)
 
 		if (!(dev = dev_cache_get_by_devt(cmd, devno, cmd->filter))) {
 			log_debug("pvscan arg %d:%d not found.", major, minor);
-			_online_pvid_file_remove_devno(major, minor);
+			if (!(dev = dm_pool_zalloc(cmd->mem, sizeof(struct device))))
+				return_0;
+			if (!(devl = dm_pool_zalloc(cmd->mem, sizeof(*devl))))
+				return_0;
+			dev->dev = devno;
+			devl->dev = dev;
+			dm_list_add(&rem_devs, &devl->list);
 		} else {
 			log_debug("pvscan arg %d:%d found.", major, minor);
 
 			if (!(devl = dm_pool_zalloc(cmd->mem, sizeof(*devl))))
 				return_0;
 			devl->dev = dev;
-			dm_list_add(&single_devs, &devl->list);
+			dm_list_add(&add_devs, &devl->list);
 		}
+	}
 
-		if (sigint_caught()) {
-			ret = ECMD_FAILED;
-			goto_out;
-		}
+	/*
+	 * No device args means rescan/regenerate/[reactivate] everything.
+	 * Scan all devices when no args are given; clear all pvid
+	 * files on recreate pvid files for existing devices.
+	 * When -aay is set, any complete vg is activated
+	 * (even if it's already active.)
+	 */
+
+	if (all_devs) {
+		/*
+		 * pvscan --cache removes existing hints and recreates new ones.
+		 * We begin by clearing hints at the start of the command.
+		 * The pvscan_recreate_hints flag is used to enable the
+		 * special case hint recreation in label_scan.
+		 */
+		cmd->pvscan_recreate_hints = 1;
+		pvscan_recreate_hints_begin(cmd);
+
+		_lock_online(LOCK_EX, 0);
+		log_verbose("pvscan all devices for requested refresh.");
+		_online_files_remove(_pvs_online_dir);
+		_online_files_remove(_vgs_online_dir);
+		_online_pvscan_all_devs(cmd, complete_vgnames, NULL);
+		_unlock_online();
+
+		cmd->pvscan_recreate_hints = 0;
+		cmd->use_hints = 0;
+		goto activate;
 	}
 
-	if (!dm_list_empty(&single_devs)) {
-		label_scan_devs(cmd, cmd->filter, &single_devs);
+	/*
+	 * Initialization case:
+	 * lock_online ex
+	 * if empty
+	 * pvscan all
+	 * create pvid files
+	 * identify complete vgs
+	 * unlock_online
+	 * activate complete vgs
+	 *
+	 * Non-initialization case:
+	 * lock_online ex
+	 * if not empty
+	 * unlock_unlock
+	 * pvscan devs
+	 * create pvid files
+	 * identify complete vgs
+	 * activate complete vgs
+	 *
+	 * In the non-init case, a VG with two PVs, where both PVs appear at once,
+	 * two parallel pvscans for each PV create the pvid files for each PV in
+	 * parallel, then both pvscans see the vg has completed, and both pvscans
+	 * activate the VG in parallel.  The first pvscan to create the vgname
+	 * file in vgs_online will do the activation, any others will skip it.
+	 */
+
+	_lock_online(LOCK_EX, 0);
+
+	if (_online_pvid_files_missing()) {
+		log_verbose("pvscan all devices to initialize available PVs.");
+		_online_files_remove(_pvs_online_dir);
+		_online_files_remove(_vgs_online_dir);
+		_online_pvscan_all_devs(cmd, complete_vgnames, NULL);
+		_unlock_online();
+		goto activate;
+	}
+
+	_unlock_online();
+	log_verbose("pvscan only specific devices add %d rem %d.",
+		    dm_list_size(&add_devs), dm_list_size(&rem_devs));
+
+	/*
+	 * Unlink online files for devices that no longer have a device node.
+	 * When unlinking a pvid file for dev, we don't need to scan the dev
+	 * (we can't since it's gone), but we know which pvid file it is
+	 * because the major:minor are saved in the pvid files which we can
+	 * read to find the correct one.
+	 */
+	dm_list_iterate_items(devl, &rem_devs)
+		_online_pvid_file_remove_devno((int)MAJOR(devl->dev->dev), (int)MINOR(devl->dev->dev));
+
+	/*
+	 * Create online files for devices that exist and pass the filter.
+	 * When creating a pvid file for a dev, we have to scan it first
+	 * to know that it's ours and what its pvid is (and which vg it
+	 * belongs to if we want to do autoactivation.)
+	 */
+	if (!dm_list_empty(&add_devs)) {
+		label_scan_devs(cmd, cmd->filter, &add_devs);
 
-		dm_list_iterate_items(devl, &single_devs) {
+		dm_list_iterate_items(devl, &add_devs) {
 			dev = devl->dev;
 
 			if (dev->flags & DEV_FILTER_OUT_SCAN)
@@ -1090,16 +1104,27 @@ int pvscan_cache_cmd(struct cmd_context *cmd, int argc, char **argv)
 
 			add_single_count++;
 
-			/*
-			 * Devices that exist and pass the lvmetad filter
-			 * are online.
-			 */
-			if (!_online_pvscan_one(cmd, devl->dev, NULL, complete_vgnames, 0, &pvid_without_metadata))
+			if (!_online_pvscan_one(cmd, dev, NULL, complete_vgnames, 0, &pvid_without_metadata))
 				add_errors++;
 		}
 	}
 
-activate:
+	/*
+	 * After scanning only specific devs to add a device, there is a
+	 * special case that requires us to then scan all devs.  That is when
+	 * the dev scanned has no VG metadata, and it's the final device to
+	 * complete the VG.  In this case we want to autoactivate the VG, but
+	 * the scanned device does not know what VG it's in or whether that VG
+	 * is now complete.  In this case we need to scan all devs and pick out
+	 * the complete VG holding this device so we can then autoactivate that
+	 * VG.
+	 */
+	if (!dm_list_empty(&add_devs) && complete_vgnames && dm_list_empty(complete_vgnames) &&
+	    pvid_without_metadata && do_activate) {
+		log_verbose("pvscan all devices for PV without metadata: %s.", pvid_without_metadata);
+		_online_pvscan_all_devs(cmd, complete_vgnames, &add_devs);
+	}
+
 	/*
 	 * When a new PV appears, the system runs pvscan --cache dev.
 	 * This also means that existing hints are invalid, and
@@ -1110,20 +1135,7 @@ activate:
 	if (add_single_count)
 		invalidate_hints(cmd);
 
-	/*
-	 * Special case: pvscan --cache -aay dev 
-	 * where dev has no VG metadata, and it's the final device to
-	 * complete the VG.  In this case we want to autoactivate the
-	 * VG, but the scanned device does not know what VG it's in or
-	 * whether that VG is now complete.  In this case we need to
-	 * scan all devs and pick out the complete VG holding this
-	 * device so we can then autoactivate that VG.
-	 */
-	if (!dm_list_empty(&single_devs) && complete_vgnames && dm_list_empty(complete_vgnames) &&
-	    pvid_without_metadata && do_activate) {
-		log_verbose("pvscan all devices for PV without metadata: %s.", pvid_without_metadata);
-		_online_pvscan_all_devs(cmd, complete_vgnames, &single_devs);
-	}
+activate:
 
 	/*
 	 * Step 2: when the PV was recorded online, we check if all the
@@ -1133,7 +1145,6 @@ activate:
 	if (do_activate)
 		ret = _pvscan_aa(cmd, &pp, complete_vgnames);
 
-out:
 	if (add_errors || pp.activate_errors)
 		ret = ECMD_FAILED;
 


