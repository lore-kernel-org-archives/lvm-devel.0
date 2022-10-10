From: David Teigland <teigland@sourceware.org>
Date: Mon, 10 Oct 2022 16:47:56 +0000 (GMT)
Subject: main - device id: add new types using values from vpd_pg83
Message-ID: <20221010164756.9C8A13858D37@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=79e67fc5e4f28d19fe4d93e6831a3a60e9760b68
Commit:        79e67fc5e4f28d19fe4d93e6831a3a60e9760b68
Parent:        8de87e0207342b0142778ebe9c51f0d552adfab8
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Aug 31 16:05:07 2022 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Oct 10 11:47:29 2022 -0500

device id: add new types using values from vpd_pg83

The new device_id types are: wwid_naa, wwid_eui, wwid_t10.
The new types use the specific wwid type in their name.
lvm currently gets the values for these types by reading
the device's vpd_pg83 sysfs file (this could change in the
future if better methods become available for reading the
values.)

If a device is added to the devices file using one of these
types, prior versions of lvm will not recognize the types
and will be unable to use the devices.

When adding a new device, lvm continues to first use sys_wwid
from the sysfs wwid file.  If the device has no sysfs wwid file,
lvm now attempts to use one of the new types from vpd_pg83.

If a devices file entry with type sys_wwid does not match a
given device's sysfs wwid file, the sys_wwid value will also
be compared to that device's other wwids from its vpd_pg83 file.
If the kernel changes the wwid type reported from the sysfs
wwid file, e.g. from a device's t10 id to its naa id, then lvm
should still be able to match it correctly using the vpd_pg83
data which will include both ids.
---
 lib/config/config_settings.h |   3 ++
 lib/config/defaults.h        |   2 +
 lib/device/device.h          |   4 ++
 lib/device/device_id.c       | 103 ++++++++++++++++++++++++++++++++++++++++++-
 lib/device/device_id.h       |   2 +
 5 files changed, 112 insertions(+), 2 deletions(-)

diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index b172c7c5f..699b40bd0 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -224,6 +224,9 @@ cfg(devices_dir_CFG, "dir", devices_CFG_SECTION, CFG_DEFAULT_COMMENTED | CFG_ADV
 	"Directory in which to create volume group device nodes.\n"
 	"Commands also accept this as a prefix on volume group names.\n")
 
+cfg(devices_device_id_sysfs_dir_CFG, "device_id_sysfs_dir", devices_CFG_SECTION, CFG_DEFAULT_COMMENTED | CFG_UNSUPPORTED, CFG_TYPE_STRING, DEFAULT_DEVICE_ID_SYSFS_DIR, vsn(2, 3, 17), NULL, 0, NULL,
+	"Location of sysfs for finding device ids (for testing.)\n")
+
 cfg_array(devices_scan_CFG, "scan", devices_CFG_SECTION, CFG_DEFAULT_COMMENTED | CFG_ADVANCED, CFG_TYPE_STRING, "#S/dev", vsn(1, 0, 0), NULL, 0, NULL,
 	"Directories containing device nodes to use with LVM.\n")
 
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 3308b1ea6..571054dc4 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -332,4 +332,6 @@
 #define VGS_ONLINE_DIR DEFAULT_RUN_DIR "/vgs_online"
 #define PVS_LOOKUP_DIR DEFAULT_RUN_DIR "/pvs_lookup"
 
+#define DEFAULT_DEVICE_ID_SYSFS_DIR "/sys/"  /* trailing / to match dm_sysfs_dir() */
+
 #endif				/* _LVM_DEFAULTS_H */
diff --git a/lib/device/device.h b/lib/device/device.h
index 89173a840..ca46490ce 100644
--- a/lib/device/device.h
+++ b/lib/device/device.h
@@ -67,7 +67,11 @@ struct dev_ext {
 #define DEV_ID_TYPE_CRYPT_UUID 6
 #define DEV_ID_TYPE_LVMLV_UUID 7
 #define DEV_ID_TYPE_DEVNAME    8
+#define DEV_ID_TYPE_WWID_NAA   9
+#define DEV_ID_TYPE_WWID_EUI  10
+#define DEV_ID_TYPE_WWID_T10  11
 
+/* Max length of WWID_NAA, WWID_EUI, WWID_T10 */
 #define DEV_WWID_SIZE 128
 
 /*
diff --git a/lib/device/device_id.c b/lib/device/device_id.c
index 5481bb6b0..6383f69fb 100644
--- a/lib/device/device_id.c
+++ b/lib/device/device_id.c
@@ -188,13 +188,17 @@ static int _read_sys_block(struct cmd_context *cmd, struct device *dev,
 			   int binary, int *retlen)
 {
 	char path[PATH_MAX];
+	const char *sysfs_dir;
 	dev_t devt = dev->dev;
 	dev_t prim = 0;
 	int ret;
 
+	if (!(sysfs_dir = find_config_tree_str(cmd, devices_device_id_sysfs_dir_CFG, NULL)))
+		sysfs_dir = dm_sysfs_dir();
+
  retry:
 	if (dm_snprintf(path, sizeof(path), "%sdev/block/%d:%d/%s",
-			dm_sysfs_dir(), (int)MAJOR(devt), (int)MINOR(devt), suffix) < 0) {
+			sysfs_dir, (int)MAJOR(devt), (int)MINOR(devt), suffix) < 0) {
 		log_error("Failed to create sysfs path for %s", dev_name(dev));
 		return 0;
 	}
@@ -338,6 +342,26 @@ static int _wwid_type_num(char *id)
 		return -1;
 }
 
+int wwid_type_to_idtype(int wwid_type)
+{
+	switch (wwid_type) {
+	case 3: return DEV_ID_TYPE_WWID_NAA;
+	case 2: return DEV_ID_TYPE_WWID_EUI;
+	case 1: return DEV_ID_TYPE_WWID_T10;
+	default: return -1;
+	}
+}
+
+int idtype_to_wwid_type(int idtype)
+{
+	switch (idtype) {
+	case DEV_ID_TYPE_WWID_NAA: return 3;
+	case DEV_ID_TYPE_WWID_EUI: return 2;
+	case DEV_ID_TYPE_WWID_T10: return 1;
+	default: return -1;
+	}
+}
+
 void free_wwids(struct dm_list *ids)
 {
 	struct dev_wwid *dw, *safe;
@@ -436,6 +460,7 @@ const char *device_id_system_read(struct cmd_context *cmd, struct device *dev, u
 {
 	char sysbuf[PATH_MAX] = { 0 };
 	const char *idname = NULL;
+	struct dev_wwid *dw;
 	int i;
 
 	if (idtype == DEV_ID_TYPE_SYS_WWID) {
@@ -485,6 +510,18 @@ const char *device_id_system_read(struct cmd_context *cmd, struct device *dev, u
 		return idname;
 	}
 
+	else if (idtype == DEV_ID_TYPE_WWID_NAA ||
+		 idtype == DEV_ID_TYPE_WWID_EUI ||
+		 idtype == DEV_ID_TYPE_WWID_T10) {
+		if (!(dev->flags & DEV_ADDED_VPD_WWIDS))
+			dev_read_vpd_wwids(cmd, dev);
+		dm_list_iterate_items(dw, &dev->wwids) {
+			if (idtype_to_wwid_type(idtype) == dw->type)
+				return strdup(dw->id);
+		}
+		return NULL;
+	}
+
 	/* wwids are already munged if needed */
 	if (idtype != DEV_ID_TYPE_SYS_WWID) {
 		for (i = 0; i < strlen(sysbuf); i++) {
@@ -591,6 +628,12 @@ const char *idtype_to_str(uint16_t idtype)
 		return "md_uuid";
 	if (idtype == DEV_ID_TYPE_LOOP_FILE)
 		return "loop_file";
+	if (idtype == DEV_ID_TYPE_WWID_NAA)
+		return "wwid_naa";
+	if (idtype == DEV_ID_TYPE_WWID_EUI)
+		return "wwid_eui";
+	if (idtype == DEV_ID_TYPE_WWID_T10)
+		return "wwid_t10";
 	return "unknown";
 }
 
@@ -612,6 +655,12 @@ uint16_t idtype_from_str(const char *str)
 		return DEV_ID_TYPE_MD_UUID;
 	if (!strcmp(str, "loop_file"))
 		return DEV_ID_TYPE_LOOP_FILE;
+	if (!strcmp(str, "wwid_naa"))
+		return DEV_ID_TYPE_WWID_NAA;
+	if (!strcmp(str, "wwid_eui"))
+		return DEV_ID_TYPE_WWID_EUI;
+	if (!strcmp(str, "wwid_t10"))
+		return DEV_ID_TYPE_WWID_T10;
 	return 0;
 }
 
@@ -1202,13 +1251,26 @@ int device_id_add(struct cmd_context *cmd, struct device *dev, const char *pvid_
 
 	/*
 	 * No device-specific, existing, or user-specified idtypes,
-	 * so use first available of sys_wwid / sys_serial / devname.
+	 * so use first available of sys_wwid, wwid_naa, wwid_eui,
+	 * wwid_t10, sys_serial, devname.
 	 */
 
 	idtype = DEV_ID_TYPE_SYS_WWID;
 	if ((idname = device_id_system_read(cmd, dev, idtype)))
 		goto id_done;
 
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
 	idtype = DEV_ID_TYPE_SYS_SERIAL;
 	if ((idname = device_id_system_read(cmd, dev, idtype)))
 		goto id_done;
@@ -1731,6 +1793,43 @@ static int _match_du_to_dev(struct cmd_context *cmd, struct dev_use *du, struct
 		  idtype_to_str(du->idtype), du->idname ?: ".", dev_name(dev), idname ?: ".");
 	*/
 
+	/*
+	 * Make the du match this device if the dev has a vpd_pg83 wwid
+	 * that matches du->idname, even if the sysfs wwid for dev did
+	 * not match the du->idname.  This could happen if sysfs changes
+	 * which wwid it reports (there are often multiple), or if lvm in
+	 * the future selects a sys_wwid value from vpd_pg83 data rather
+	 * than from the sysfs wwid.
+	 *
+	 * TODO: update the df entry IDTYPE somewhere?
+	 */
+	if (du->idtype == DEV_ID_TYPE_SYS_WWID) {
+		struct dev_wwid *dw;
+
+	       	if (!(dev->flags & DEV_ADDED_VPD_WWIDS))
+			dev_read_vpd_wwids(cmd, dev);
+
+		dm_list_iterate_items(dw, &dev->wwids) {
+			if (!strcmp(dw->id, du->idname)) {
+				if (!(id = zalloc(sizeof(struct dev_id))))
+					return_0;
+				/* wwid types are 1,2,3 and idtypes are DEV_ID_TYPE_ */
+				id->idtype = wwid_type_to_idtype(dw->type);
+				id->idname = strdup(dw->id);
+				id->dev = dev;
+				dm_list_add(&dev->ids, &id->list);
+				du->dev = dev;
+				dev->id = id;
+				dev->flags |= DEV_MATCHED_USE_ID;
+				log_print("Match device_id %s %s to vpd_pg83 %s %s",
+					  idtype_to_str(du->idtype), du->idname,
+					  idtype_to_str(id->idtype), dev_name(dev));
+				du->idtype = id->idtype;
+				return 1;
+			}
+		}
+	}
+
 	return 0;
 }
 
diff --git a/lib/device/device_id.h b/lib/device/device_id.h
index 46ab33784..6962925df 100644
--- a/lib/device/device_id.h
+++ b/lib/device/device_id.h
@@ -63,6 +63,8 @@ int read_sys_block_binary(struct cmd_context *cmd, struct device *dev,
 
 int dev_has_mpath_uuid(struct cmd_context *cmd, struct device *dev, const char **idname_out);
 
+int wwid_type_to_idtype(int wwid_type);
+int idtype_to_wwid_type(int idtype);
 void free_wwids(struct dm_list *ids);
 struct dev_wwid *dev_add_wwid(char *id, int id_type, struct dm_list *ids);
 int dev_read_vpd_wwids(struct cmd_context *cmd, struct device *dev);

