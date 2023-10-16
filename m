From: David Teigland (@teigland) <gitlab@mg.gitlab.com>
Date: Mon, 16 Oct 2023 20:40:52 +0000
Subject: [Git][lvmteam/lvm2][main] 3 commits: device_id: improve handling of non-standard wwid prefixes
Message-ID: <652d9fd46bbab_2caf2a8405b4@gitlab-sidekiq-low-urgency-cpu-bound-v2-55bc649f89-fhbdx.mail>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit



David Teigland pushed to branch main at LVM team / lvm2


Commits:
d8d4260d by David Teigland at 2023-10-16T15:12:12-05:00
device_id: improve handling of non-standard wwid prefixes

- - - - -
a8368721 by David Teigland at 2023-10-16T15:21:22-05:00
device_id: accept wwids containing QEMU HARDDISK

A wwid may be useful even when it contains the string
&quot;QEMU HARDDISK&quot;, so allow these to be used.

- - - - -
be9a64e6 by David Teigland at 2023-10-16T15:40:11-05:00
device_id: make dmeventd use system.devices by default

When no dmeventd.devices exists, make it use system.devices
rather than no devices file at all.

- - - - -


4 changed files:

- lib/device/dev-cache.c
- lib/device/device_id.c
- man/lvmdevices.8_des
- test/shell/devicesfile-vpd-ids.sh


Changes:

=====================================
lib/device/dev-cache.c
=====================================
@@ -1777,39 +1777,38 @@ static int _setup_devices_list(struct cmd_context *cmd)
 	return 1;
 }
 
+/*
+ * LVs that use dmeventd need to be accessible using system.devices.
+ *
+ * dmeventd will use dmeventd.devices if it exists, otherwise will use
+ * system.devices.  If a VG is covered by dmeventd.devices it should also
+ * be covered by system.devices.  The automated vgchange --monitor and
+ * vgchange -aay commands do not currently consider dmeventd.devices.
+ * dmeventd.devices can be useful to prevent commands run by dmeventd
+ * from reading VGs that do not need the service.
+ *
+ * dmeventd gets events for any applicable dm device in the kernel,
+ * and will attempt to run lvm commands for it.  These commands
+ * will only use dmeventd.devices or system.devices, so if an LV
+ * that dmeventd is watching is not covered by either of these
+ * devices files, the dmeventd-generated command will fail when
+ * it doesn't find the VG.
+ */
+ 
 static int _setup_devices_file_dmeventd(struct cmd_context *cmd)
 {
 	char path[PATH_MAX];
 	struct stat st;
 
-	/*
-	 * When command is run by dmeventd there is no --devicesfile
-	 * option that can enable/disable the use of a devices file.
-	 */
 	if (!find_config_tree_bool(cmd, devices_use_devicesfile_CFG, NULL)) {
 		cmd->enable_devices_file = 0;
 		return 1;
 	}
 
-	/*
-	 * If /etc/lvm/devices/dmeventd.devices exists, then use that.
-	 * The optional dmeventd.devices allows the user to control
-	 * which devices dmeventd will look at and use.
-	 * Otherwise, disable the devices file because dmeventd should
-	 * be able to manage LVs in any VG (i.e. LVs in a non-system
-	 * devices file.)
-	 */
-	if (dm_snprintf(path, sizeof(path), "%s/devices/dmeventd.devices", cmd->system_dir) < 0) {
-		log_warn("Failed to copy devices path");
-		cmd->enable_devices_file = 0;
-		return 1;
-	}
-
-	if (stat(path, &st)) {
-		/* No dmeventd.devices, so do not use a devices file. */
-		cmd->enable_devices_file = 0;
-		return 1;
-	}
+	if (dm_snprintf(path, sizeof(path), "%s/devices/dmeventd.devices", cmd->system_dir) < 0)
+		return_0;
+	if (stat(path, &st))
+		return 0;
 
 	cmd->enable_devices_file = 1;
 	(void) dm_strncpy(cmd->devices_file_path, path, sizeof(cmd->devices_file_path));
@@ -1823,8 +1822,9 @@ int setup_devices_file(struct cmd_context *cmd)
 	struct stat st;
 	int rv;
 
-	if (cmd->run_by_dmeventd)
-		return _setup_devices_file_dmeventd(cmd);
+	/* Use dmeventd.devices if it exists. */
+	if (cmd->run_by_dmeventd && _setup_devices_file_dmeventd(cmd))
+		return 1;
 
 	if (cmd->devicesfile) {
 		/* --devicesfile <filename> or "" has been set which overrides


=====================================
lib/device/device_id.c
=====================================
@@ -427,7 +427,7 @@ static int _wwid_type_num(char *id)
 	else if (!strncmp(id, "t10.", 4))
 		return 1;
 	else
-		return -1;
+		return 0; /* any unrecognized, non-standard prefix */
 }
 
 int wwid_type_to_idtype(int wwid_type)
@@ -436,6 +436,7 @@ int wwid_type_to_idtype(int wwid_type)
 	case 3: return DEV_ID_TYPE_WWID_NAA;
 	case 2: return DEV_ID_TYPE_WWID_EUI;
 	case 1: return DEV_ID_TYPE_WWID_T10;
+	case 0: return DEV_ID_TYPE_SYS_WWID;
 	default: return -1;
 	}
 }
@@ -446,6 +447,7 @@ int idtype_to_wwid_type(int idtype)
 	case DEV_ID_TYPE_WWID_NAA: return 3;
 	case DEV_ID_TYPE_WWID_EUI: return 2;
 	case DEV_ID_TYPE_WWID_T10: return 1;
+	case DEV_ID_TYPE_SYS_WWID: return 0;
 	default: return -1;
 	}
 }
@@ -473,11 +475,8 @@ struct dev_wwid *dev_add_wwid(char *id, int id_type, struct dm_list *ids)
 	struct dev_wwid *dw;
 	int len;
 
-	if (!id_type) {
+	if (!id_type)
 		id_type = _wwid_type_num(id);
-		if (id_type == -1)
-			log_debug("unknown wwid type %s", id);
-	}
 
 	if (!(dw = zalloc(sizeof(struct dev_wwid))))
 		return NULL;
@@ -630,19 +629,11 @@ const char *device_id_system_read(struct cmd_context *cmd, struct device *dev, u
 	struct dev_wwid *dw;
 	unsigned i;
 
-	if (idtype == DEV_ID_TYPE_SYS_WWID) {
+	if (idtype == DEV_ID_TYPE_SYS_WWID)
 		dev_read_sys_wwid(cmd, dev, sysbuf, sizeof(sysbuf), NULL);
 
-		/* FIXME: enable these QEMU t10 wwids */
-
-		/* qemu wwid begins "t10.ATA     QEMU HARDDISK ..." */
-		if (strstr(sysbuf, "QEMU HARDDISK"))
-			sysbuf[0] = '\0';
-	}
-
-	else if (idtype == DEV_ID_TYPE_SYS_SERIAL) {
+	else if (idtype == DEV_ID_TYPE_SYS_SERIAL)
 		_dev_read_sys_serial(cmd, dev, sysbuf, sizeof(sysbuf));
-	}
 
 	else if (idtype == DEV_ID_TYPE_MPATH_UUID) {
 		read_sys_block(cmd, dev, "dm/uuid", sysbuf, sizeof(sysbuf));
@@ -834,6 +825,22 @@ static int _dev_has_stable_id(struct cmd_context *cmd, struct device *dev)
 	 * system_read.)
 	 */
 	dm_list_iterate_items(id, &dev->ids) {
+		/*
+		 * An unfortunate special case to work around a previous lvm version
+		 * where wwid's containing "QEMU HARDDISK" were ignored, which would
+		 * generally cause the device to have IDTYPE=devname.  On reboot,
+		 * when the dev name changes, the search for a new device may use
+		 * the search_for_devnames="auto" setting which uses this function
+		 * to decide if a dev should be checked as the renamed device or not.
+		 * It's not if it has a wwid, since the renamed dev we're looking for
+		 * would be using sys_wwid if it had a wwid.  Now that QEMU wwids
+		 * are used, we still have to check devs with a QEMU wwid to see if
+		 * it's the renamed dev.
+		 */
+		if (((id->idtype == DEV_ID_TYPE_SYS_WWID) || (id->idtype == DEV_ID_TYPE_WWID_T10)) &&
+		     id->idname && strstr(id->idname, "QEMU"))
+			continue;
+
 		if ((id->idtype != DEV_ID_TYPE_DEVNAME) && id->idname)
 			return 1;
 	}
@@ -844,8 +851,13 @@ static int _dev_has_stable_id(struct cmd_context *cmd, struct device *dev)
 	 */
 
 	if ((idname = device_id_system_read(cmd, dev, DEV_ID_TYPE_SYS_WWID))) {
+		/* see comment above */
+		if (!strstr(idname, "QEMU")) {
+			free((void*)idname);
+			return 1;
+		}
 		free((void*)idname);
-		return 1;
+		return 0;
 	}
 
 	if ((idname = device_id_system_read(cmd, dev, DEV_ID_TYPE_SYS_SERIAL))) {


=====================================
man/lvmdevices.8_des
=====================================
@@ -108,6 +108,12 @@ The default choice for device ID type can be overridden using lvmdevices
 device it will be used, otherwise the device will be added using the type
 that would otherwise be chosen.
 
+LVM commands run by dmeventd will use the devices file
+\fI#DEFAULT_SYS_DIR#/devices/dmeventd.devices\fP if it exists,
+otherwise system.devices is used.  VGs that require the dmeventd
+service should be included in system.devices, even if they are
+included in dmeventd.devices.
+
 .SS Device ID refresh
 .P
 A machine identifier is saved in the devices file, and is used to detect


=====================================
test/shell/devicesfile-vpd-ids.sh
=====================================
@@ -16,6 +16,10 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
+aux lvmconf 'devices/global_filter = [ "a|.*|" ]' \
+            'devices/filter = [ "a|.*|" ]'
+
+
 SYS_DIR="sys"
 # requires trailing / to match dm
 aux lvmconf "devices/device_id_sysfs_dir = \"$PWD/$SYS_DIR/\"" \
@@ -499,6 +503,75 @@ grep "IDTYPE=devname" "$DF" | tee out
 grep "IDNAME=$DEV1" out
 cleanup_sysfs
 
+#
+# Test wwid containing "QEMU HARDDISK".
+# These wwids were once ignored.  When the qemu wwid
+# was ignored, the dev would likely have used IDTYPE=devname.
+# When that dev is renamed on reboot, it needs to be found
+# on the device with the qemu wwid.
+# The original logic behind search_for_devnames="auto" would
+# have ignored any device with a wwid when searching for the
+# renamed device (since devs with wwids would not use the
+# devname idtype.)  However, in this case, a device with the
+# qemu wwid does use the devname idtype and needs to be checked,
+# so it's a special case in the code to look at devs with
+# any qemu wwid.
+#
+aux lvmconf "devices/search_for_devnames = \"auto\""
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
+echo -n "0QEMU QEMU  HARDDISK  1" > "$SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/wwid"
+pvs -o+uuid,deviceidtype,deviceid "$DEV1"
+# Rename device, simulating reboot
+sed -e "s|IDNAME=$DEV1|IDNAME=/dev/sdx|" "$DF" > tmpdf
+sed -e "s|DEVNAME=$DEV1|DEVNAME=/dev/sdx|" tmpdf > "$DF"
+cat "$DF"
+# pvs will find PV on DEV1 and fix IDNAME
+pvs -o+uuid,deviceidtype,deviceid | tee out
+grep "$DEV1" out
+grep "IDTYPE=devname" "$DF" | tee out
+grep "IDNAME=$DEV1" out
+rm "$SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/wwid"
+cleanup_sysfs
+
+# set search_for_devnames="auto"
+# set wwid with QEMU HARDDISK for the disk
+# add disk to system.devices, should use the wwid
+# pvs should find the disk by wwid
+# rename the DEVNAME field
+# pvs should fix DEVNAME field
+
+rm "$DF"
+aux wipefs_a "$DEV1"
+mkdir -p "$SYS_DIR/dev/block/$MAJOR1:$MINOR1/device"
+echo -n "t10.ATA     QEMU HARDDISK                           QM00002            " > "$SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/wwid"
+touch "$DF"
+pvcreate "$DEV1"
+vgcreate $vg1 "$DEV1"
+cat "$DF"
+grep 'IDTYPE=sys_wwid' "$DF" | tee out
+grep "QEMU_HARDDISK" out
+pvs -o+uuid,deviceidtype,deviceid | tee out
+grep "$DEV1" out
+grep sys_wwid out
+grep "QEMU_HARDDISK" out
+sed -e "s|DEVNAME=$DEV1|DEVNAME=/dev/sdx|" "$DF" > tmpdf
+cp tmpdf "$DF"
+cat "$DF"
+pvs -o+uuid,deviceidtype,deviceid "$DEV1"
+grep "DEVNAME=$DEV1" "$DF"
+rm "$SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/wwid"
+cleanup_sysfs
+
+
 
 # TODO: lvmdevices --adddev <dev> --deviceidtype <type> --deviceid <val>
 # This would let the user specify the second naa wwid.



View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/compare/e6c6713a1baeadb485e2200fd7333edd8f78a71c...be9a64e6542eea544bcaf122e61183f2c3aad682

-- 
View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/compare/e6c6713a1baeadb485e2200fd7333edd8f78a71c...be9a64e6542eea544bcaf122e61183f2c3aad682
You're receiving this email because of your account on gitlab.com.


-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20231016/53d7693d/attachment-0001.htm>
