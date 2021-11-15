From: David Teigland <teigland@sourceware.org>
Date: Mon, 15 Nov 2021 20:57:13 +0000 (GMT)
Subject: main - vgchange autoactivation: error path cleanup
Message-ID: <20211115205713.954353857C4A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=89c54db16cfca284d78dd3be5316dc9bca67e8ef
Commit:        89c54db16cfca284d78dd3be5316dc9bca67e8ef
Parent:        c5f998aec4b5e42f7f1b6ddeec6c4544dceaa1b5
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Nov 12 16:46:39 2021 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Nov 15 11:07:11 2021 -0600

vgchange autoactivation: error path cleanup

If the optimized label scan fails (using online files),
then clear the device state prior to falling back to the
standard label_scan.  This avoids printing output about
unexpected state.
---
 lib/label/label.c | 63 ++++++++++++++++++++++++++++++++++++++++++++++++++++---
 tools/vgchange.c  | 36 +++++++++++++++++--------------
 2 files changed, 80 insertions(+), 19 deletions(-)

diff --git a/lib/label/label.c b/lib/label/label.c
index d506b81e3..5c77a6923 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -1021,6 +1021,35 @@ int label_scan_for_pvid(struct cmd_context *cmd, char *pvid, struct device **dev
 	return ret;
 }
 
+/*
+ * Clear state that label_scan_vg_online() created so it will not
+ * confuse the standard label_scan() that the caller falls back to.
+ * the results of filtering (call filter->wipe)
+ * the results of matching device_id (reset dev and du)
+ * the results of scanning in lvmcache
+ */
+static void _clear_scan_state(struct cmd_context *cmd, struct dm_list *devs)
+{
+	struct device_list *devl;
+	struct device *dev;
+	struct dev_use *du;
+
+	dm_list_iterate_items(devl, devs) {
+		dev = devl->dev;
+
+		cmd->filter->wipe(cmd, cmd->filter, dev, NULL);
+		dev->flags &= ~DEV_MATCHED_USE_ID;
+		dev->id = NULL;
+
+		if ((du = get_du_for_dev(cmd, dev)))
+			du->dev = NULL;
+
+		lvmcache_del_dev(dev);
+
+		memset(dev->pvid, 0, ID_LEN);
+	}
+}
+
 /*
  * Use files under /run/lvm/, created by pvscan --cache autoactivation,
  * to optimize device setup/scanning.  autoactivation happens during
@@ -1033,6 +1062,7 @@ int label_scan_vg_online(struct cmd_context *cmd, const char *vgname,
 {
 	struct dm_list pvs_online;
 	struct dm_list devs;
+	struct dm_list devs_drop;
 	struct pv_online *po;
 	struct device_list *devl, *devl2;
 	int relax_deviceid_filter = 0;
@@ -1041,6 +1071,7 @@ int label_scan_vg_online(struct cmd_context *cmd, const char *vgname,
 
 	dm_list_init(&pvs_online);
 	dm_list_init(&devs);
+	dm_list_init(&devs_drop);
 
 	log_debug_devs("Finding online devices to scan");
 
@@ -1116,6 +1147,15 @@ int label_scan_vg_online(struct cmd_context *cmd, const char *vgname,
 	 * factor code common to pvscan_cache_args
 	 */
 
+	/*
+	 * Match devs with the devices file because special/optimized
+	 * device setup was used which does not check the devices file.
+	 * If a match fails here do not exclude it, that will be done below by
+	 * passes_filter() which runs filter-deviceid. The
+	 * relax_deviceid_filter case needs to be able to work around
+	 * unmatching devs.
+	 */
+
 	if (cmd->enable_devices_file) {
 		dm_list_iterate_items(devl, &devs)
 			device_ids_match_dev(cmd, devl->dev);
@@ -1127,6 +1167,8 @@ int label_scan_vg_online(struct cmd_context *cmd, const char *vgname,
 	if (cmd->enable_devices_file && device_ids_use_devname(cmd)) {
 		relax_deviceid_filter = 1;
 		cmd->filter_deviceid_skip = 1;
+		/* PVIDs read from devs matched to devices file below instead. */
+		log_debug("Skipping device_id filtering due to devname ids.");
 	}
 
 	cmd->filter_nodata_only = 1;
@@ -1136,6 +1178,7 @@ int label_scan_vg_online(struct cmd_context *cmd, const char *vgname,
 			log_print("%s excluded by filters: %s.",
 				  dev_name(devl->dev), dev_filtered_reason(devl->dev));
 			dm_list_del(&devl->list);
+			dm_list_add(&devs_drop, &devl->list);
 		}
 	}
 
@@ -1160,11 +1203,13 @@ int label_scan_vg_online(struct cmd_context *cmd, const char *vgname,
 	label_scan_setup_bcache();
 
 	dm_list_iterate_items_safe(devl, devl2, &devs) {
+		struct dev_use *du;
 		int has_pvid;
 
 		if (!label_read_pvid(devl->dev, &has_pvid)) {
 			log_print("%s cannot read label.", dev_name(devl->dev));
 			dm_list_del(&devl->list);
+			dm_list_add(&devs_drop, &devl->list);
 			continue;
 		}
 
@@ -1172,6 +1217,7 @@ int label_scan_vg_online(struct cmd_context *cmd, const char *vgname,
 			/* Not an lvm device */
 			log_print("%s not an lvm device.", dev_name(devl->dev));
 			dm_list_del(&devl->list);
+			dm_list_add(&devs_drop, &devl->list);
 			continue;
 		}
 
@@ -1180,11 +1226,16 @@ int label_scan_vg_online(struct cmd_context *cmd, const char *vgname,
 		 * so in place of that check if the pvid is in the devices file.
 		 */
 		if (relax_deviceid_filter) {
-			if (!get_du_for_pvid(cmd, devl->dev->pvid)) {
+			if (!(du = get_du_for_pvid(cmd, devl->dev->pvid))) {
 				log_print("%s excluded by devices file (checking PVID).",
 					  dev_name(devl->dev));
 				dm_list_del(&devl->list);
+				dm_list_add(&devs_drop, &devl->list);
 				continue;
+			} else {
+				/* Special case matching for devname entries based on pvid. */
+				log_debug("Match device_id %s %s to %s: matching PVID",
+					  idtype_to_str(du->idtype), du->idname, dev_name(devl->dev));
 			}
 		}
 
@@ -1193,6 +1244,7 @@ int label_scan_vg_online(struct cmd_context *cmd, const char *vgname,
 			log_print("%s excluded by filters: %s.",
 				  dev_name(devl->dev), dev_filtered_reason(devl->dev));
 			dm_list_del(&devl->list);
+			dm_list_add(&devs_drop, &devl->list);
 		}
 	}
 
@@ -1202,6 +1254,7 @@ int label_scan_vg_online(struct cmd_context *cmd, const char *vgname,
 	free_po_list(&pvs_online);
 
 	if (dm_list_empty(&devs)) {
+		_clear_scan_state(cmd, &devs_drop);
 		*found_none = 1;
 		return 1;
 	}
@@ -1227,6 +1280,8 @@ int label_scan_vg_online(struct cmd_context *cmd, const char *vgname,
 		if (metadata_pv_count > dm_list_size(&devs)) {
 			log_debug("Incomplete PV list from online files %d metadata %d.",
 				  dm_list_size(&devs), metadata_pv_count);
+			_clear_scan_state(cmd, &devs_drop);
+			_clear_scan_state(cmd, &devs);
 			*found_incomplete = 1;
 			return 1;
 		}
@@ -1235,6 +1290,8 @@ int label_scan_vg_online(struct cmd_context *cmd, const char *vgname,
 	*found_all = 1;
 	return 1;
 bad:
+	_clear_scan_state(cmd, &devs_drop);
+	_clear_scan_state(cmd, &devs);
 	free_po_list(&pvs_online);
 	return 0;
 }
@@ -1527,7 +1584,7 @@ int label_read_pvid(struct device *dev, int *has_pvid)
 
 	lh = (struct label_header *)(buf + 512);
 	if (memcmp(lh->id, LABEL_ID, sizeof(lh->id))) {
-		/* Not an lvm deice */
+		/* Not an lvm device */
 		label_scan_invalidate(dev);
 		return 1;
 	}
@@ -1537,7 +1594,7 @@ int label_read_pvid(struct device *dev, int *has_pvid)
 	 * rest of the label_header intact.
 	 */
 	if (memcmp(lh->type, LVM2_LABEL, sizeof(lh->type))) {
-		/* Not an lvm deice */
+		/* Not an lvm device */
 		label_scan_invalidate(dev);
 		return 1;
 	}
diff --git a/tools/vgchange.c b/tools/vgchange.c
index 5eebc9ae9..fc076c1d5 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -802,7 +802,7 @@ static int _vgchange_autoactivation_setup(struct cmd_context *cmd,
 	 */
 	if (!label_scan_vg_online(cmd, vgname, &found_none, &found_all, &found_incomplete)) {
 		log_print("PVs online error%s%s, using all devices.", vgname ? " for VG " : "", vgname ?: "");
-		return 1;
+		goto bad;
 	}
 
 	/*
@@ -815,9 +815,11 @@ static int _vgchange_autoactivation_setup(struct cmd_context *cmd,
 	}
 
 	/*
-	 * The expected and optimal usage, because the udev rule calls
-	 * vgchange -aay --autoactivation event vgname when all PVs
-	 * for vgname are found online.  Only online pvs are used.
+	 * The expected and optimal usage, which is the purpose of
+	 * this function.  We expect online files to be found for
+	 * all PVs because the udev rule calls
+	 * vgchange -aay --autoactivation event <vgname>
+	 * only after all PVs for vgname are found online.
 	 */
 	if (found_all) {
 		*flags |= PROCESS_SKIP_SCAN;
@@ -825,16 +827,6 @@ static int _vgchange_autoactivation_setup(struct cmd_context *cmd,
 		return 1;
 	}
 
-	/*
-	 * The online scanning optimiziation didn't work, so undo the vg
-	 * locking optimization before falling back to normal processing.
-	 */
-	if (vg_locked) {
-		unlock_vg(cmd, NULL, vgname);
-		*flags &= ~READ_WITHOUT_LOCK;
-		cmd->can_use_one_scan = 0;
-	}
-
 	/*
 	 * Not expected usage, no online pvs for the vgname were found.  The
 	 * caller will fall back to process_each doing a full label_scan to
@@ -842,7 +834,7 @@ static int _vgchange_autoactivation_setup(struct cmd_context *cmd,
 	 */
 	if (found_none) {
 		log_print("PVs online not found for VG %s, using all devices.", vgname);
-		return 1;
+		goto bad;
 	}
 
 	/*
@@ -852,7 +844,7 @@ static int _vgchange_autoactivation_setup(struct cmd_context *cmd,
 	 */
 	if (found_incomplete) {
 		log_print("PVs online incomplete for VG %s, using all devicess.", vgname);
-		return 1;
+		goto bad;
 	}
 
 	/*
@@ -860,7 +852,19 @@ static int _vgchange_autoactivation_setup(struct cmd_context *cmd,
 	 * process_each.  (No optimization used.)
 	 */
 	log_print("PVs online unknown for VG %s, using all devices.", vgname);
+
+ bad:
+	/*
+	 * The online scanning optimization didn't work, so undo the vg
+	 * locking optimization before falling back to normal processing.
+	 */
+	if (vg_locked) {
+		unlock_vg(cmd, NULL, vgname);
+		*flags &= ~READ_WITHOUT_LOCK;
+		cmd->can_use_one_scan = 0;
+	}
 	return 1;
+
 }
 
 int vgchange(struct cmd_context *cmd, int argc, char **argv)


