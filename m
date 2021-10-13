From: David Teigland <teigland@sourceware.org>
Date: Wed, 13 Oct 2021 22:30:38 +0000 (GMT)
Subject: main - toollib: remove all devices list from process_each_pv
Message-ID: <20211013223038.F134D3858409@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6fb497ef42a5f8324a90cb93734cd8071ed0dc0b
Commit:        6fb497ef42a5f8324a90cb93734cd8071ed0dc0b
Parent:        272d1ccac8654c0d74ecf255d13de0a6222ff96f
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Oct 13 14:13:54 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Oct 13 17:29:32 2021 -0500

toollib: remove all devices list from process_each_pv

Reporting non-PVs / "all devices" is only done by
pvs -a or pvdisplay -a, so avoid the work managing
a list of all devices in process_each_pv.
In the case when it's needed, use the results of
label_scan which already determines which devs
are not PVs.
---
 lib/device/device.h |   1 +
 lib/label/label.c   |   1 +
 tools/toollib.c     | 253 ++++++++++++++--------------------------------------
 3 files changed, 71 insertions(+), 184 deletions(-)

diff --git a/lib/device/device.h b/lib/device/device.h
index a30a1288b..9e471a9b5 100644
--- a/lib/device/device.h
+++ b/lib/device/device.h
@@ -39,6 +39,7 @@
 #define DEV_IS_MD_COMPONENT	0x00020000	/* device is an md component */
 #define DEV_IS_NVME		0x00040000	/* set if dev is nvme */
 #define DEV_MATCHED_USE_ID	0x00080000	/* matched an entry from cmd->use_devices */
+#define DEV_SCAN_FOUND_NOLABEL	0x00100000	/* label_scan read, passed filters, but no lvm label */
 
 /*
  * Support for external device info.
diff --git a/lib/label/label.c b/lib/label/label.c
index b5804c738..b8f0dc84d 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -403,6 +403,7 @@ static int _process_block(struct cmd_context *cmd, struct dev_filter *f,
 			memset(dev->pvid, 0, sizeof(dev->pvid));
 		}
 
+		dev->flags |= DEV_SCAN_FOUND_NOLABEL;
 		*is_lvm_device = 0;
 		goto out;
 	}
diff --git a/tools/toollib.c b/tools/toollib.c
index 3682dfa0a..c05a973d5 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -3882,63 +3882,6 @@ static int _get_arg_devices(struct cmd_context *cmd,
 	return ret_max;
 }
 
-static int _get_all_devices(struct cmd_context *cmd,
-			    int process_all_devices,
-			    struct dm_list *all_devices)
-{
-	struct dev_iter *iter;
-	struct device *dev;
-	struct device_id_list *dil;
-	struct hint *hint;
-	int r = ECMD_FAILED;
-
-	/*
-	 * If command is using hints and is only looking for PVs
-	 * (not all devices), then we can use only devs from hints.
-	 */
-	if (!process_all_devices && !dm_list_empty(&cmd->hints)) {
-		log_debug("Getting list of all devices from hints");
-
-		dm_list_iterate_items(hint, &cmd->hints) {
-			if (!(dev = dev_cache_get(cmd, hint->name, NULL)))
-				continue;
-
-			if (!(dil = dm_pool_zalloc(cmd->mem, sizeof(*dil)))) {
-				log_error("device_id_list alloc failed.");
-				return ECMD_FAILED;
-			}
-
-			memcpy(dil->pvid, hint->pvid, ID_LEN);
-			dil->dev = dev;
-			dm_list_add(all_devices, &dil->list);
-		}
-		return ECMD_PROCESSED;
-	}
-
-	log_debug("Getting list of all devices from system");
-
-	if (!(iter = dev_iter_create(cmd->filter, 1))) {
-		log_error("dev_iter creation failed.");
-		return ECMD_FAILED;
-	}
-
-	while ((dev = dev_iter_get(cmd, iter))) {
-		if (!(dil = dm_pool_zalloc(cmd->mem, sizeof(*dil)))) {
-			log_error("device_id_list alloc failed.");
-			goto out;
-		}
-
-		memcpy(dil->pvid, dev->pvid, ID_LEN);
-		dil->dev = dev;
-		dm_list_add(all_devices, &dil->list);
-	}
-
-	r = ECMD_PROCESSED;
-out:
-	dev_iter_destroy(iter);
-	return r;
-}
-
 static int _device_list_remove(struct dm_list *devices, struct device *dev)
 {
 	struct device_id_list *dil;
@@ -3965,47 +3908,66 @@ static struct device_id_list *_device_list_find_dev(struct dm_list *devices, str
 	return NULL;
 }
 
-static int _process_device_list(struct cmd_context *cmd, struct dm_list *all_devices,
+/* Process devices that are not PVs. */
+
+static int _process_other_devices(struct cmd_context *cmd,
 				struct processing_handle *handle,
 				process_single_pv_fn_t process_single_pv)
 {
+	struct dev_iter *iter;
 	struct physical_volume pv_dummy;
 	struct physical_volume *pv;
-	struct device_id_list *dil;
-	int ret_max = ECMD_PROCESSED;
-	int ret = 0;
+	struct device *dev;
+	int failed = 0;
+	int ret;
 
 	log_debug("Processing devices that are not PVs");
 
 	/*
-	 * Pretend that each device is a PV with dummy values.
-	 * FIXME Formalise this extension or find an alternative.
+	 * We want devices here that passed filters during
+	 * label_scan but were found to not be PVs.
+	 *
+	 * No filtering used in iter, DEV_SCAN_FOUND_NOLABEL
+	 * was set by label_scan which did filtering.
 	 */
-	dm_list_iterate_items(dil, all_devices) {
-		if (sigint_caught())
-			return_ECMD_FAILED;
+
+	if (!(iter = dev_iter_create(NULL, 0)))
+		return_0;
+
+	while ((dev = dev_iter_get(cmd, iter))) {
+		if (sigint_caught()) {
+			failed = 1;
+			break;
+		}
+
+		if (!(dev->flags & DEV_SCAN_FOUND_NOLABEL))
+			continue;
+
+		/*
+		 * Pretend that each device is a PV with dummy values.
+		 * FIXME Formalise this extension or find an alternative.
+		 */
 
 		memset(&pv_dummy, 0, sizeof(pv_dummy));
 		dm_list_init(&pv_dummy.tags);
 		dm_list_init(&pv_dummy.segments);
-		pv_dummy.dev = dil->dev;
+		pv_dummy.dev = dev;
 		pv = &pv_dummy;
 
-		log_very_verbose("Processing device %s.", dev_name(dil->dev));
+		log_very_verbose("Processing device %s.", dev_name(dev));
 
 		ret = process_single_pv(cmd, NULL, pv, handle);
-
-		if (ret > ret_max)
-			ret_max = ret;
+		if (ret != ECMD_PROCESSED)
+			failed = 1;
 	}
+	dev_iter_destroy(iter);
 
-	return ECMD_PROCESSED;
+	return failed ? 0 : 1;
 }
 
 static int _process_duplicate_pvs(struct cmd_context *cmd,
-				  struct dm_list *all_devices,
 				  struct dm_list *arg_devices,
-				  int process_all_devices,
+				  int process_other_devices,
 				  struct processing_handle *handle,
 				  process_single_pv_fn_t process_single_pv)
 {
@@ -4015,8 +3977,8 @@ static int _process_duplicate_pvs(struct cmd_context *cmd,
 	struct lvmcache_info *info;
 	const char *vgname;
 	const char *vgid;
-	int ret_max = ECMD_PROCESSED;
-	int ret = 0;
+	int failed = 0;
+	int ret;
 
 	struct physical_volume dummy_pv = {
 		.pe_size = 1,
@@ -4045,20 +4007,15 @@ static int _process_duplicate_pvs(struct cmd_context *cmd,
 	dm_list_init(&unused_duplicate_devs);
 
 	if (!lvmcache_get_unused_duplicates(cmd, &unused_duplicate_devs))
-		return_ECMD_FAILED;
+		return_0;
 
 	dm_list_iterate_items(devl, &unused_duplicate_devs) {
 		/* Duplicates are displayed if -a is used or the dev is named as an arg. */
 
-		_device_list_remove(all_devices, devl->dev);
-
-		if (!process_all_devices && dm_list_empty(arg_devices))
-			continue;
-
 		if ((dil = _device_list_find_dev(arg_devices, devl->dev)))
 			_device_list_remove(arg_devices, devl->dev);
 
-		if (!process_all_devices && !dil)
+		if (!process_other_devices && !dil)
 			continue;
 
 		if (!(cmd->cname->flags & ENABLE_DUPLICATE_DEVS))
@@ -4087,7 +4044,7 @@ static int _process_duplicate_pvs(struct cmd_context *cmd,
 		 */
 		if (!(info = lvmcache_info_from_pvid(devl->dev->pvid, NULL, 0))) {
 			log_error(INTERNAL_ERROR "No info for pvid");
-			return ECMD_FAILED;
+			return 0;
 		}
 
 		vgname = lvmcache_vgname_from_info(info);
@@ -4103,47 +4060,39 @@ static int _process_duplicate_pvs(struct cmd_context *cmd,
 			memset(&dummy_vg.id, 0, sizeof(dummy_vg.id));
 
 		ret = process_single_pv(cmd, &dummy_vg, &dummy_pv, handle);
-
-		if (ret > ret_max)
-			ret_max = ret;
+		if (ret != ECMD_PROCESSED)
+			failed = 1;
 
 		if (sigint_caught())
-			return_ECMD_FAILED;
+			return_0;
 	}
 
-	return ECMD_PROCESSED;
+	return failed ? 0 : 1;
 }
 
 static int _process_pvs_in_vg(struct cmd_context *cmd,
 			      struct volume_group *vg,
-			      struct dm_list *all_devices,
 			      struct dm_list *arg_devices,
 			      struct dm_list *arg_tags,
 			      int process_all_pvs,
-			      int process_all_devices,
 			      int skip,
 			      uint32_t error_flags,
 			      struct processing_handle *handle,
 			      process_single_pv_fn_t process_single_pv)
 {
 	log_report_t saved_log_report_state = log_get_report_state();
-	char vgid[ID_LEN + 1] __attribute__((aligned(8))) = { 0 };
 	char pv_uuid[64] __attribute__((aligned(8)));
 	char vg_uuid[64] __attribute__((aligned(8)));
 	int handle_supplied = handle != NULL;
 	struct physical_volume *pv;
 	struct pv_list *pvl;
 	struct device_id_list *dil;
-	struct device_list *devl;
-	struct dm_list outdated_devs;
 	const char *pv_name;
 	int process_pv;
 	int do_report_ret_code = 1;
 	int ret_max = ECMD_PROCESSED;
 	int ret = 0;
 
-	dm_list_init(&outdated_devs);
-
 	log_set_report_object_type(LOG_REPORT_OBJECT_TYPE_PV);
 
 	vg_uuid[0] = '\0';
@@ -4221,18 +4170,6 @@ static int _process_pvs_in_vg(struct cmd_context *cmd,
 			else
 				log_very_verbose("Processing PV %s in VG %s.", pv_name, vg->name);
 
-			_device_list_remove(all_devices, pv->dev);
-
-			/*
-			 * pv->dev should be found in all_devices unless it's a
-			 * case of a "missing device".  Previously there have
-			 * been cases where we needed to skip processing the PV
-			 * if pv->dev was not found in all_devices to avoid
-			 * processing a PV twice, i.e. when the PV had no MDAs
-			 * it would be seen once in its real VG and again
-			 * wrongly in the orphan VG.  This no longer happens.
-			 */
-
 			if (!skip) {
 				ret = process_single_pv(cmd, vg, pv, handle);
 				if (ret != ECMD_PROCESSED)
@@ -4252,13 +4189,6 @@ static int _process_pvs_in_vg(struct cmd_context *cmd,
 		log_set_report_object_name_and_id(NULL, NULL);
 	}
 
-	if (!is_orphan_vg(vg->name)) {
-		memcpy(vgid, &vg->id, ID_LEN);
-		lvmcache_get_outdated_devs(cmd, vg->name, vgid, &outdated_devs);
-	}
-	dm_list_iterate_items(devl, &outdated_devs)
-		_device_list_remove(all_devices, devl->dev);
-
 	do_report_ret_code = 0;
 out:
 	if (do_report_ret_code)
@@ -4278,18 +4208,15 @@ out:
  * arg_devices and arg_tags are empty, then process all PVs.
  * No PV should be processed more than once.
  *
- * Each PV is removed from arg_devices and all_devices when it is
- * processed.  Any names remaining in arg_devices were not found, and
- * should produce an error.  Any devices remaining in all_devices were
- * not found and should be processed by process_device_list().
+ * Each PV is removed from arg_devices when it is processed.
+ * Any names remaining in arg_devices were not found, and
+ * should produce an error.
  */
 static int _process_pvs_in_vgs(struct cmd_context *cmd, uint32_t read_flags,
 			       struct dm_list *all_vgnameids,
-			       struct dm_list *all_devices,
 			       struct dm_list *arg_devices,
 			       struct dm_list *arg_tags,
 			       int process_all_pvs,
-			       int process_all_devices,
 			       struct processing_handle *handle,
 			       process_single_pv_fn_t process_single_pv)
 {
@@ -4358,8 +4285,8 @@ static int _process_pvs_in_vgs(struct cmd_context *cmd, uint32_t read_flags,
 		 * error_vg->pvs entries from devices list.
 		 */
 		
-		ret = _process_pvs_in_vg(cmd, vg ? vg : error_vg, all_devices, arg_devices, arg_tags,
-					 process_all_pvs, process_all_devices, skip, error_flags,
+		ret = _process_pvs_in_vg(cmd, vg ? vg : error_vg, arg_devices, arg_tags,
+					 process_all_pvs, skip, error_flags,
 					 handle, process_single_pv);
 		if (ret != ECMD_PROCESSED)
 			stack;
@@ -4405,10 +4332,9 @@ int process_each_pv(struct cmd_context *cmd,
 	struct dm_list arg_pvnames;	/* str_list */
 	struct dm_list arg_devices;	/* device_id_list */
 	struct dm_list all_vgnameids;	/* vgnameid_list */
-	struct dm_list all_devices;	/* device_id_list */
 	struct device_id_list *dil;
 	int process_all_pvs;
-	int process_all_devices;
+	int process_other_devices;
 	int ret_max = ECMD_PROCESSED;
 	int ret;
 
@@ -4435,7 +4361,6 @@ int process_each_pv(struct cmd_context *cmd,
 	dm_list_init(&arg_pvnames);
 	dm_list_init(&arg_devices);
 	dm_list_init(&all_vgnameids);
-	dm_list_init(&all_devices);
 
 	/*
 	 * Create two lists from argv:
@@ -4457,7 +4382,7 @@ int process_each_pv(struct cmd_context *cmd,
 
 	process_all_pvs = dm_list_empty(&arg_pvnames) && dm_list_empty(&arg_tags);
 
-	process_all_devices = process_all_pvs && (cmd->cname->flags & ENABLE_ALL_DEVS) && all_is_set;
+	process_other_devices = process_all_pvs && (cmd->cname->flags & ENABLE_ALL_DEVS) && all_is_set;
 
 	/* Needed for a current listing of the global VG namespace. */
 	if (!only_this_vgname && !lock_global(cmd, "sh")) {
@@ -4473,16 +4398,6 @@ int process_each_pv(struct cmd_context *cmd,
 		goto_out;
 	}
 
-	/*
-	 * If the caller wants to process all devices (not just PVs), then all PVs
-	 * from all VGs are processed first, removing them from all_devices.  Then
-	 * any devs remaining in all_devices are processed.
-	 */
-	if ((ret = _get_all_devices(cmd, process_all_devices, &all_devices)) != ECMD_PROCESSED) {
-		ret_max = ret;
-		goto_out;
-	}
-
 	if ((ret = _get_arg_devices(cmd, &arg_pvnames, &arg_devices)) != ECMD_PROCESSED) {
 		/* get_arg_devices reports EINIT_FAILED for any PV names not found. */
 		ret_max = ret;
@@ -4491,9 +4406,8 @@ int process_each_pv(struct cmd_context *cmd,
 		ret_max = ECMD_FAILED; /* but ATM we've returned FAILED for all cases */
 	}
 
-	ret = _process_pvs_in_vgs(cmd, read_flags, &all_vgnameids, &all_devices,
-				  &arg_devices, &arg_tags,
-				  process_all_pvs, process_all_devices,
+	ret = _process_pvs_in_vgs(cmd, read_flags, &all_vgnameids,
+				  &arg_devices, &arg_tags, process_all_pvs,
 				  handle, process_single_pv);
 	if (ret != ECMD_PROCESSED)
 		stack;
@@ -4501,58 +4415,29 @@ int process_each_pv(struct cmd_context *cmd,
 		ret_max = ret;
 
 	/*
-	 * Process the list of unused duplicate devs so they can be shown by
-	 * report/display commands.  These are the devices that were not chosen
-	 * to be used in lvmcache because another device with the same PVID was
-	 * preferred.  The unused duplicate devs are not seen by
-	 * _process_pvs_in_vgs, which only sees the preferred device for the
-	 * PVID.
-	 *
-	 * The main purpose in reporting/displaying the unused duplicate PVs
-	 * here is so that they do not appear to be unused/free devices or
-	 * orphans.
-	 *
-	 * We do not allow modifying the unused duplicate PVs.  To modify a
-	 * non-preferred duplicate PV, e.g. pvchange -u, a filter needs to be
-	 * used with the command to exclude the other devices with the same
-	 * PVID.  This results in the command seeing only the one device with
-	 * the PVID and allows it to be changed.  (If the duplicates actually
-	 * represent the same underlying storage, these precautions are
-	 * unnecessary, but lvm can't tell when the duplicates are different
-	 * paths to the same storage or different underlying storage.)
-	 *
-	 * Even the preferred duplicate PV in lvmcache is limitted from being
-	 * modified (by allow_changes_with_duplicate_pvs setting), because lvm
-	 * cannot be sure that the preferred duplicate device is the correct one,
-	 * e.g. if a VG has two PVs, and both PVs are cloned, lvm might prefer
-	 * one of the original PVs and one of the cloned PVs, pairing them
-	 * together as the VG.  Any changes on the VG or PVs in that state would
-	 * end up changing one of the original PVs and one of the cloned PVs.
-	 *
-	 * vgimportclone of the two cloned PVs changes their PV UUIDs and gives
-	 * them a new VG name.
+	 * Process the list of unused duplicate devs to display duplicate PVs
+	 * in two cases: 1. pvs -a (which has traditionally included duplicate
+	 * PVs in addition to the expected non-PV devices), 2. pvs <devname>
+	 * (duplicate dev is named on the command line.)
 	 */
-
-	ret = _process_duplicate_pvs(cmd, &all_devices, &arg_devices, process_all_devices,
-				     handle, process_single_pv);
-	if (ret != ECMD_PROCESSED)
-		stack;
-	if (ret > ret_max)
-		ret_max = ret;
+	if (process_other_devices || !dm_list_empty(&arg_devices)) {
+		if (!_process_duplicate_pvs(cmd, &arg_devices, process_other_devices, handle, process_single_pv))
+			ret_max = ECMD_FAILED;
+	}
 
 	dm_list_iterate_items(dil, &arg_devices) {
 		log_error("Failed to find physical volume \"%s\".", dev_name(dil->dev));
 		ret_max = ECMD_FAILED;
 	}
 
-	if (!process_all_devices)
-		goto out;
+	/*
+	 * pvs -a and pvdisplay -a want to show devices that are not PVs.
+	 */
+	if (process_other_devices) {
+		if (!_process_other_devices(cmd, handle, process_single_pv))
+			ret_max = ECMD_FAILED;
+	}
 
-	ret = _process_device_list(cmd, &all_devices, handle, process_single_pv);
-	if (ret != ECMD_PROCESSED)
-		stack;
-	if (ret > ret_max)
-		ret_max = ret;
 out:
 	log_restore_report_state(saved_log_report_state);
 	return ret_max;


