From: David Teigland (@teigland) <gitlab@mg.gitlab.com>
Date: Tue, 10 Oct 2023 16:54:30 +0000
Subject: [Git][lvmteam/lvm2][main] 2 commits: device_id: refresh devname idnames if any are not found
Message-ID: <652581c65f59_2ba54ec49457@gitlab-sidekiq-low-urgency-cpu-bound-v2-84b89f5ddd-tgf8r.mail>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit



David Teigland pushed to branch main at LVM team / lvm2


Commits:
f20be398 by David Teigland at 2023-10-10T11:46:21-05:00
device_id: refresh devname idnames if any are not found

Search for a PV on other devices if it&#39;s a devname entry
and the name doesn&#39;t exist on the system.  This restores
code that should not have been removed in commit 1901a47df
&quot;device_id: fix conditions for device_ids_refresh&quot;

- - - - -
63b469c1 by David Teigland at 2023-10-10T11:47:29-05:00
device_id: fix hints with device ids

Fix some interactions between device IDs and hints.  Hints
may limit the scanned devices which should not always trigger
a search for the PVs that were intentionally not scanned.
Hints should also be invalidated if they contain a device
that&#39;s become excluded by an internal filter such as the
device_id filter.

- - - - -


6 changed files:

- lib/device/device_id.c
- lib/device/device_id.h
- lib/label/hints.c
- lib/label/label.c
- test/shell/devicesfile-vpd-ids.sh
- tools/lvmdevices.c


Changes:

=====================================
lib/device/device_id.c
=====================================
@@ -2342,7 +2342,7 @@ static void _get_devs_with_serial_numbers(struct cmd_context *cmd, struct dm_lis
  * use_devices entries from the devices file.
  */
 
-void device_ids_validate(struct cmd_context *cmd, struct dm_list *scanned_devs, int noupdate)
+void device_ids_validate(struct cmd_context *cmd, struct dm_list *scanned_devs, int noupdate, int using_hints)
 {
 	struct dm_list wrong_devs;
 	struct device *dev = NULL;
@@ -2721,6 +2721,31 @@ void device_ids_validate(struct cmd_context *cmd, struct dm_list *scanned_devs,
 		}
 	}
 
+	/*
+	 * Set invalid if an entry using IDNAME=devname has not
+	 * been matched to a device.  It's possible that the device
+	 * with the PVID has a new name, different from the IDNAME
+	 * value.  device_ids_refresh needs to search system devs
+	 * for the PVID.  The same applies when the IDNAME field
+	 * has no value.
+	 */
+	dm_list_iterate_items(du, &cmd->use_devices) {
+		if (cmd->device_ids_invalid)
+			break;
+
+		if (!du->idname || (du->idname[0] == '.')) {
+			log_debug("Validate %s %s PVID %s: no idname is invalid.",
+				  idtype_to_str(du->idtype), du->idname ?: ".", du->pvid ?: ".");
+			cmd->device_ids_invalid = 1;
+		}
+
+		if ((du->idtype == DEV_ID_TYPE_DEVNAME) && !du->dev && du->pvid) {
+			log_debug("Validate %s %s PVID %s: no device for idtype devname is invalid.",
+				  idtype_to_str(du->idtype), du->idname ?: ".", du->pvid ?: ".");
+			cmd->device_ids_invalid = 1;
+		}
+	}
+
 	/*
 	 * When a new devname/pvid mismatch is discovered, a new search for the
 	 * pvid should be permitted (searched_devnames may exist to suppress
@@ -2743,6 +2768,28 @@ void device_ids_validate(struct cmd_context *cmd, struct dm_list *scanned_devs,
 	} else {
 		log_debug("Validated device ids: invalid=%d, no update needed.", cmd->device_ids_invalid);
 	}
+
+	/*
+	 * label_scan can use hints to scan only the devs for a specific
+	 * VG as an optimization.  If that limited subset of devs were
+	 * all matched properly in the devices file, then override
+	 * device_ids_invalid which may be set due to other entries
+	 * not being matched, which this command doesn't care about.
+	 */
+	if (using_hints && scanned_devs) {
+		int found_scanned = 1;
+		dm_list_iterate_items(devl, scanned_devs) {
+			du = get_du_for_dev(cmd, devl->dev);
+			if (du && !memcmp(du->pvid, devl->dev->pvid, ID_LEN))
+				continue;
+			found_scanned = 0;
+			break;
+		}
+		if (found_scanned && cmd->device_ids_invalid) {
+			log_debug("Override device_ids_invalid for complete hints.");
+			cmd->device_ids_invalid = 0;
+		}
+	}
 }
 
 /*


=====================================
lib/device/device_id.h
=====================================
@@ -33,7 +33,7 @@ void device_id_pvremove(struct cmd_context *cmd, struct device *dev);
 void device_ids_match(struct cmd_context *cmd);
 int device_ids_match_dev(struct cmd_context *cmd, struct device *dev);
 void device_ids_match_device_list(struct cmd_context *cmd);
-void device_ids_validate(struct cmd_context *cmd, struct dm_list *scanned_devs, int noupdate);
+void device_ids_validate(struct cmd_context *cmd, struct dm_list *scanned_devs, int noupdate, int using_hints);
 int device_ids_version_unchanged(struct cmd_context *cmd);
 void device_ids_check_serial(struct cmd_context *cmd, struct dm_list *scan_devs, int *update_needed, int noupdate);
 void device_ids_refresh(struct cmd_context *cmd, struct dm_list *dev_list, int *search_count, int noupdate);


=====================================
lib/label/hints.c
=====================================
@@ -468,6 +468,7 @@ int validate_hints(struct cmd_context *cmd, struct dm_list *hints)
 	struct hint *hint;
 	struct dev_iter *iter;
 	struct device *dev;
+	int valid_hints = 0;
 	int ret = 1;
 
 	/* No commands are using hints. */
@@ -478,6 +479,8 @@ int validate_hints(struct cmd_context *cmd, struct dm_list *hints)
 	if (!cmd->use_hints && !cmd->pvscan_recreate_hints)
 		return 0;
 
+	log_debug("Validating hints");
+
 	if (lvmcache_has_duplicate_devs()) {
 		log_debug("Hints not used with duplicate pvs");
 		ret = 0;
@@ -504,6 +507,17 @@ int validate_hints(struct cmd_context *cmd, struct dm_list *hints)
 		if (!(hint = _find_hint_name(hints, dev_name(dev))))
 			continue;
 
+		/*
+		 * If this dev is excluded by any filter then hints invalid.
+		 * use cmd->filter->passes_filter(cmd, cmd->filter, dev, "persistent") ?
+		 */
+		if (dev->filtered_flags) {
+			log_debug("Hints invalid for filtered %s: %s",
+				  dev_name(dev), dev_filtered_reason(dev));
+			ret = 0;
+			break;
+		}
+
 		/* The cmd hasn't needed this hint's dev so it's not been scanned. */
 		if (!hint->chosen)
 			continue;
@@ -527,6 +541,8 @@ int validate_hints(struct cmd_context *cmd, struct dm_list *hints)
 				  dev->pvid, hint->pvid);
 			ret = 0;
 		}
+
+		valid_hints++;
 	}
 	dev_iter_destroy(iter);
 
@@ -576,6 +592,14 @@ int validate_hints(struct cmd_context *cmd, struct dm_list *hints)
 		}
 	}
 
+	/*
+	 * hints considered invalid if none are used.
+	 */
+	if (!valid_hints) {
+		log_debug("Invalid hints: none used.");
+		ret = 0;
+	}
+
 out:
 	if (!ret) {
 		/*


=====================================
lib/label/label.c
=====================================
@@ -1457,7 +1457,7 @@ int label_scan(struct cmd_context *cmd)
 	 * Check if the devices_file content is up to date and
 	 * if not update it.
 	 */
-	device_ids_validate(cmd, &scan_devs, 0);
+	device_ids_validate(cmd, &scan_devs, 0, using_hints);
 
 	dm_list_iterate_items_safe(devl, devl2, &all_devs) {
 		dm_list_del(&devl->list);


=====================================
test/shell/devicesfile-vpd-ids.sh
=====================================
@@ -435,7 +435,69 @@ vgremove $vg
 rm "$SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/wwid"
 cleanup_sysfs
 
+#
+# Simply rename a device using IDNAME=devname
+# use a new device name where a device exists
+# on the system with that name so that there
+# will be an initial, incorrect match of the
+# devices file entry with IDNAME=/dev/sdb to
+# the /dev/sdb that exists on the system.
+#
+# FIXME: this assumes that /dev/sdb exists on the system
+# and is not the same as DEV1.  To do this correctly
+# we need to find the name of some device on the
+# system other than DEV1.
+#
+
+rm "$DF"
+aux wipefs_a "$DEV1"
+touch "$DF"
+pvcreate "$DEV1"
+vgcreate $vg1 "$DEV1"
+cat "$DF"
+grep "IDTYPE=devname" "$DF" | tee out
+grep "IDNAME=$DEV1" out
+mkdir -p "$SYS_DIR/dev/block/$MAJOR1:$MINOR1/device"
+pvs -o+uuid,deviceidtype,deviceid "$DEV1"
+# Rename device, simulating reboot
+sed -e "s|IDNAME=$DEV1|IDNAME=/dev/sdb|" "$DF" > tmpdf
+sed -e "s|DEVNAME=$DEV1|DEVNAME=/dev/sdb|" tmpdf > "$DF"
+cat "$DF"
+# pvs will find PV on DEV1 and fix IDNAME
+pvs -o+uuid,deviceidtype,deviceid | tee out
+grep "$DEV1" out
+grep "IDTYPE=devname" "$DF" | tee out
+grep "IDNAME=$DEV1" out
+cleanup_sysfs
 
+#
+# Simply rename a device using IDNAME=devname
+# use a new device name where a device does not
+# exist on the system with that name
+#
+# This assumes that /dev/sdxx does not exist on the system.
+#
+
+rm "$DF"
+aux wipefs_a "$DEV1"
+touch "$DF"
+pvcreate "$DEV1"
+vgcreate $vg1 "$DEV1"
+cat "$DF"
+grep "IDTYPE=devname" "$DF" | tee out
+grep "IDNAME=$DEV1" out
+mkdir -p "$SYS_DIR/dev/block/$MAJOR1:$MINOR1/device"
+pvs -o+uuid,deviceidtype,deviceid "$DEV1"
+# Rename device, simulating reboot
+sed -e "s|IDNAME=$DEV1|IDNAME=/dev/sdxx|" "$DF" > tmpdf
+sed -e "s|DEVNAME=$DEV1|DEVNAME=/dev/sdxx|" tmpdf > "$DF"
+cat "$DF"
+# pvs will find PV on DEV1 and fix IDNAME
+pvs -o+uuid,deviceidtype,deviceid | tee out
+grep "$DEV1" out
+grep "IDTYPE=devname" "$DF" | tee out
+grep "IDNAME=$DEV1" out
+cleanup_sysfs
 
 
 # TODO: lvmdevices --adddev <dev> --deviceidtype <type> --deviceid <val>


=====================================
tools/lvmdevices.c
=====================================
@@ -230,7 +230,7 @@ int lvmdevices(struct cmd_context *cmd, int argc, char **argv)
 		 * from use_devices does not pass the filters that have been
 		 * run just above.
 		 */
-		device_ids_validate(cmd, NULL, 1);
+		device_ids_validate(cmd, NULL, 1, 0);
 		if (cmd->device_ids_invalid)
 			update_needed = 1;
 



View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/compare/25a87ea16aba335b5f33621cd5ac6ff651f0bbb1...63b469c1609fe5d3395b7757eebaf35a4a77ea7a

-- 
View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/compare/25a87ea16aba335b5f33621cd5ac6ff651f0bbb1...63b469c1609fe5d3395b7757eebaf35a4a77ea7a
You're receiving this email because of your account on gitlab.com.


-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20231010/6eeed80b/attachment-0001.htm>
