From: David Teigland <teigland@sourceware.org>
Date: Mon, 26 Oct 2020 19:35:36 +0000 (GMT)
Subject: master - pvcreate: clean up opening and filtering of args
Message-ID: <20201026193536.1A5763857831@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2c319398274b930a38278e635e9171ce663f2bab
Commit:        2c319398274b930a38278e635e9171ce663f2bab
Parent:        7bafae48bb7b7bf1e7adc420bf83d0c5acaf0aac
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Oct 23 13:53:52 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Oct 26 11:13:27 2020 -0500

pvcreate: clean up opening and filtering of args

The args for pvcreate/pvremove (and vgcreate/vgextend
when applicable) were not efficiently opened, scanned,
and filtered.  This change reorganizes the opening
and filtering in the following steps:

- label scan and filter all devs
  . open ro
  . standard label scan at the start of command

- label scan and filter dev args
  . open ro
  . uses full md component check
  . typically the first scan and filter of pvcreate devs

- close and reopen dev args
  . open rw and excl

- repeat label scan and filter dev args
  . using reopened rw excl fd

- wipe and write new headers
  . using reopened rw excl fd
---
 lib/label/label.c  |  24 ++++++-----
 lib/label/label.h  |   2 +-
 tools/lvmcmdline.c |   9 +---
 tools/toollib.c    | 124 ++++++++++++++++++++++++++++++++++++++++++++---------
 4 files changed, 120 insertions(+), 39 deletions(-)

diff --git a/lib/label/label.c b/lib/label/label.c
index 36eab19f3..e067a6bed 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -669,7 +669,7 @@ static void _invalidate_di(struct bcache *cache, int di)
  */
 
 static int _scan_list(struct cmd_context *cmd, struct dev_filter *f,
-		      struct dm_list *devs, int *failed)
+		      struct dm_list *devs, int want_other_devs, int *failed)
 {
 	struct dm_list wait_devs;
 	struct dm_list done_devs;
@@ -759,9 +759,11 @@ static int _scan_list(struct cmd_context *cmd, struct dev_filter *f,
 		 * Keep the bcache block of lvm devices we have processed so
 		 * that the vg_read phase can reuse it.  If bcache failed to
 		 * read the block, or the device does not belong to lvm, then
-		 * drop it from bcache.
+		 * drop it from bcache.  When "want_other_devs" is set, it
+		 * means the caller wants to scan and keep open non-lvm devs,
+		 * e.g. to pvcreate them.
 		 */
-		if (!is_lvm_device) {
+		if (!is_lvm_device && !want_other_devs) {
 			_invalidate_di(scan_bcache, devl->dev->bcache_di);
 			_scan_dev_close(devl->dev);
 		}
@@ -1146,7 +1148,7 @@ int label_scan(struct cmd_context *cmd)
 	/*
 	 * Do the main scan.
 	 */
-	_scan_list(cmd, cmd->filter, &scan_devs, NULL);
+	_scan_list(cmd, cmd->filter, &scan_devs, 0, NULL);
 
 	/*
 	 * Metadata could be larger than total size of bcache, and bcache
@@ -1193,7 +1195,7 @@ int label_scan(struct cmd_context *cmd)
 	if (using_hints) {
 		if (!validate_hints(cmd, &hints_list)) {
 			log_debug("Will scan %d remaining devices", dm_list_size(&all_devs));
-			_scan_list(cmd, cmd->filter, &all_devs, NULL);
+			_scan_list(cmd, cmd->filter, &all_devs, 0, NULL);
 			free_hints(&hints_list);
 			using_hints = 0;
 			create_hints = 0;
@@ -1312,7 +1314,7 @@ int label_scan_devs_cached(struct cmd_context *cmd, struct dev_filter *f, struct
 	if (!scan_bcache)
 		return 0;
 
-	_scan_list(cmd, f, devs, NULL);
+	_scan_list(cmd, f, devs, 0, NULL);
 
 	return 1;
 }
@@ -1339,7 +1341,7 @@ int label_scan_devs(struct cmd_context *cmd, struct dev_filter *f, struct dm_lis
 			_invalidate_di(scan_bcache, devl->dev->bcache_di);
 	}
 
-	_scan_list(cmd, f, devs, NULL);
+	_scan_list(cmd, f, devs, 0, NULL);
 
 	return 1;
 }
@@ -1359,12 +1361,12 @@ int label_scan_devs_rw(struct cmd_context *cmd, struct dev_filter *f, struct dm_
 		devl->dev->flags |= DEV_BCACHE_WRITE;
 	}
 
-	_scan_list(cmd, f, devs, NULL);
+	_scan_list(cmd, f, devs, 0, NULL);
 
 	return 1;
 }
 
-int label_scan_devs_excl(struct dm_list *devs)
+int label_scan_devs_excl(struct cmd_context *cmd, struct dev_filter *f, struct dm_list *devs)
 {
 	struct device_list *devl;
 	int failed = 0;
@@ -1379,7 +1381,7 @@ int label_scan_devs_excl(struct dm_list *devs)
 		devl->dev->flags |= DEV_BCACHE_WRITE;
 	}
 
-	_scan_list(NULL, NULL, devs, &failed);
+	_scan_list(cmd, f, devs, 1, &failed);
 
 	if (failed)
 		return 0;
@@ -1472,7 +1474,7 @@ int label_scan_dev(struct device *dev)
 
 	label_scan_invalidate(dev);
 
-	_scan_list(NULL, NULL, &one_dev, &failed);
+	_scan_list(NULL, NULL, &one_dev, 0, &failed);
 
 	free(devl);
 
diff --git a/lib/label/label.h b/lib/label/label.h
index a98ba32e3..78724c1ce 100644
--- a/lib/label/label.h
+++ b/lib/label/label.h
@@ -106,7 +106,7 @@ int label_scan(struct cmd_context *cmd);
 int label_scan_devs(struct cmd_context *cmd, struct dev_filter *f, struct dm_list *devs);
 int label_scan_devs_cached(struct cmd_context *cmd, struct dev_filter *f, struct dm_list *devs);
 int label_scan_devs_rw(struct cmd_context *cmd, struct dev_filter *f, struct dm_list *devs);
-int label_scan_devs_excl(struct dm_list *devs);
+int label_scan_devs_excl(struct cmd_context *cmd, struct dev_filter *f, struct dm_list *devs);
 int label_scan_dev(struct device *dev);
 void label_scan_invalidate(struct device *dev);
 void label_scan_invalidate_lv(struct cmd_context *cmd, struct logical_volume *lv);
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 3a2ce93b5..b84a9a014 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -2900,13 +2900,8 @@ static void _init_md_checks(struct cmd_context *cmd)
 
 	if (!strcmp(cmd->md_component_checks, "full"))
 		cmd->use_full_md_check = 1;
-	else if (!strcmp(cmd->md_component_checks, "auto")) {
-		/* use_full_md_check can also be set later */
-		if (!strcmp(cmd->name, "pvcreate") ||
-		    !strcmp(cmd->name, "vgcreate") ||
-		    !strcmp(cmd->name, "vgextend"))
-			cmd->use_full_md_check = 1;
-	}
+
+	/* use_full_md_check can also be set later */
 
 	log_debug("Using md_component_checks %s use_full_md_check %d",
 		  cmd->md_component_checks, cmd->use_full_md_check);
diff --git a/tools/toollib.c b/tools/toollib.c
index 0fbb0b6ec..d9295bb82 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -4884,16 +4884,6 @@ static int _pvcreate_check_used(struct cmd_context *cmd,
 	log_debug("Checking %s for pvcreate %.32s.",
 		  dev_name(pd->dev), pd->dev->pvid[0] ? pd->dev->pvid : "");
 
-	/*
-	 * Since the device is likely not a PV yet, it was probably not
-	 * scanned by label_scan at the start of the command, so that
-	 * needs to be done first to find if there's a PV label or metadata
-	 * on it.  If there's a PV label, it sets dev->pvid.
-	 * If a VG is using the dev, it adds basic VG info for it to
-	 * lvmcache.
-	 */
-	label_scan_dev(pd->dev);
-
 	if (!pd->dev->pvid[0]) {
 		log_debug("Check pvcreate arg %s no PVID found", dev_name(pd->dev));
 		pd->is_not_pv = 1;
@@ -5189,6 +5179,31 @@ fail:
  * This function returns 1 (success) if the caller requires all specified
  * devices to be created, and all are created, or if the caller does not
  * require all specified devices to be created and one or more were created.
+ *
+ * Process of opening, scanning and filtering:
+ *
+ * - label scan and filter all devs
+ *   . open ro
+ *   . standard label scan at the start of command
+ *   . done prior to this function
+ *
+ * - label scan and filter dev args
+ *   . label_scan_devs(&scan_devs) in this function
+ *   . open ro
+ *   . uses full md component check
+ *   . typically the first scan and filter of pvcreate devs
+ *
+ * - close and reopen dev args
+ *   . open rw and excl
+ *   . done by label_scan_devs_excl
+ *
+ * - repeat label scan and filter dev args
+ *   . using reopened rw excl fd
+ *   . since something could have used dev
+ *     in the small window between close and reopen
+ *
+ * - wipe and write new headers
+ *   . using reopened rw excl fd
  */
 
 int pvcreate_each_device(struct cmd_context *cmd,
@@ -5201,6 +5216,7 @@ int pvcreate_each_device(struct cmd_context *cmd,
 	struct volume_group *orphan_vg;
 	struct dm_list remove_duplicates;
 	struct dm_list arg_sort;
+	struct dm_list scan_devs;
 	struct dm_list rescan_devs;
 	struct pv_list *pvl;
 	struct pv_list *vgpvl;
@@ -5217,6 +5233,7 @@ int pvcreate_each_device(struct cmd_context *cmd,
 
 	dm_list_init(&remove_duplicates);
 	dm_list_init(&arg_sort);
+	dm_list_init(&scan_devs);
 	dm_list_init(&rescan_devs);
 
 	handle->custom_handle = pp;
@@ -5244,10 +5261,60 @@ int pvcreate_each_device(struct cmd_context *cmd,
 
 	/*
 	 * Translate arg names into struct device's.
+	 *
+	 * lvmcache_label_scan has already been run by the caller.
+	 * It has likely found and filtered pvremove args, but often
+	 * not pvcreate args, since pvcreate args are not typically PVs
+	 * yet (but may be.)
+	 *
+	 * We call label_scan_devs on the args, using the full
+	 * md filter (the previous scan likely did not use the
+	 * full md filter - we really only need to check the
+	 * command args to ensure they are not md components.)
 	 */
+
 	dm_list_iterate_items_safe(pd, pd2, &pp->arg_devices) {
-		pd->dev = dev_cache_get(cmd, pd->name, cmd->filter);
-		if (!pd->dev) {
+		struct device *dev;
+
+		/* No filter used here */
+		if (!(dev = dev_cache_get(cmd, pd->name, NULL))) {
+			log_error("No device found for %s.", pd->name);
+			dm_list_del(&pd->list);
+			dm_list_add(&pp->arg_fail, &pd->list);
+			continue;
+		}
+
+		if (!(devl = dm_pool_zalloc(cmd->mem, sizeof(*devl))))
+			goto bad;
+
+		devl->dev = dev;
+		pd->dev = dev;
+
+		dm_list_add(&scan_devs, &devl->list);
+	}
+
+	if (dm_list_empty(&pp->arg_devices))
+		goto_bad;
+
+	/*
+	 * Clear the filtering results from lvmcache_label_scan because we are
+	 * going to rerun the filters and don't want to get the results saved
+	 * by the prior filtering.  The filtering in label scan will use full
+	 * md filter.
+	 */
+	dm_list_iterate_items(devl, &scan_devs)
+		cmd->filter->wipe(cmd, cmd->filter, devl->dev, NULL);
+
+	cmd->use_full_md_check = 1;
+
+	log_debug("Scanning and filtering device args.");
+	label_scan_devs(cmd, cmd->filter, &scan_devs);
+
+	/*
+	 * Check if the filtering done by label scan excluded any devices.
+	 */
+	dm_list_iterate_items_safe(pd, pd2, &pp->arg_devices) {
+		if (!cmd->filter->passes_filter(cmd, cmd->filter, pd->dev, NULL)) {
 			log_error("Cannot use %s: %s", pd->name, devname_error_reason(pd->name));
 			dm_list_del(&pd->list);
 			dm_list_add(&pp->arg_fail, &pd->list);
@@ -5455,12 +5522,35 @@ do_command:
 		dm_list_add(&rescan_devs, &devl->list);
 	}
 
-	log_debug("Rescanning devices with exclusive open");
-	if (!label_scan_devs_excl(&rescan_devs)) {
+	/*
+	 * We want label_scan excl to repeat the filter check in case something
+	 * changed to filter out a dev before we were able to get exclusive.
+	 */
+	dm_list_iterate_items(devl, &rescan_devs)
+		cmd->filter->wipe(cmd, cmd->filter, devl->dev, NULL);
+
+	log_debug("Rescanning and filtering device args with exclusive open");
+	if (!label_scan_devs_excl(cmd, cmd->filter, &rescan_devs)) {
 		log_debug("Failed to rescan devs excl");
 		goto bad;
 	}
 
+	dm_list_iterate_items_safe(pd, pd2, &pp->arg_process) {
+		if (!cmd->filter->passes_filter(cmd, cmd->filter, pd->dev, NULL)) {
+			log_error("Cannot use %s: %s", pd->name, devname_error_reason(pd->name));
+			dm_list_del(&pd->list);
+			dm_list_add(&pp->arg_fail, &pd->list);
+		}
+	}
+
+	if (dm_list_empty(&pp->arg_process) && dm_list_empty(&remove_duplicates)) {
+		log_debug("No devices to process.");
+		goto bad;
+	}
+
+	if (!dm_list_empty(&pp->arg_fail) && must_use_all)
+		goto_bad;
+
 	/*
 	 * If the global lock was unlocked to wait for prompts, then
 	 * devs could have changed while unlocked, so confirm that
@@ -5498,9 +5588,6 @@ do_command:
 	 * Wipe signatures on devices being created.
 	 */
 	dm_list_iterate_items_safe(pd, pd2, &pp->arg_create) {
-		/* FIXME: won't all already be open excl from label_scan_devs_excl above? */
-		label_scan_open_excl(pd->dev);
-
 		log_verbose("Wiping signatures on new PV %s.", pd->name);
 
 		if (!wipe_known_signatures(cmd, pd->dev, pd->name, TYPE_LVM1_MEMBER | TYPE_LVM2_MEMBER,
@@ -5578,9 +5665,6 @@ do_command:
 
 		pv_name = pd->name;
 
-		/* FIXME: won't all already be open excl from label_scan_devs_excl above? */
-		label_scan_open_excl(pd->dev);
-
 		log_debug("Creating a new PV on %s.", pv_name);
 
 		if (!(pv = pv_create(cmd, pd->dev, &pp->pva))) {


