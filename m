From: David Teigland <teigland@sourceware.org>
Date: Mon,  4 Oct 2021 21:55:54 +0000 (GMT)
Subject: main - device_id: update stacked PVs for vgchange uuid
Message-ID: <20211004215554.436D73858402@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8e62cbb18e3206ae5860039c3e1a0d3256e93545
Commit:        8e62cbb18e3206ae5860039c3e1a0d3256e93545
Parent:        939b4bc58719605aa7d348d2b4e0fcf41aad0b17
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Oct 4 15:47:25 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Oct 4 16:54:44 2021 -0500

device_id: update stacked PVs for vgchange uuid

If a VG uuid is changed, update the device_id of any
PVs stacked on LVs in the changed VG.
---
 lib/device/device_id.c          | 62 +++++++++++++++++++++++++++++++++++++++++
 lib/device/device_id.h          |  1 +
 test/shell/devicesfile-basic.sh | 19 +++++++++++++
 tools/vgchange.c                | 18 ++++++++++++
 4 files changed, 100 insertions(+)

diff --git a/lib/device/device_id.c b/lib/device/device_id.c
index 742ce62bd..ce43e61ca 100644
--- a/lib/device/device_id.c
+++ b/lib/device/device_id.c
@@ -856,6 +856,17 @@ int device_ids_use_devname(struct cmd_context *cmd)
 	return 0;
 }
 
+static int _device_ids_use_lvmlv(struct cmd_context *cmd)
+{
+	struct dev_use *du;
+
+	dm_list_iterate_items(du, &cmd->use_devices) {
+		if (du->idtype == DEV_ID_TYPE_LVMLV_UUID)
+			return 1;
+	}
+	return 0;
+}
+
 struct dev_use *get_du_for_dev(struct cmd_context *cmd, struct device *dev)
 {
 	struct dev_use *du;
@@ -1299,6 +1310,57 @@ void device_id_pvremove(struct cmd_context *cmd, struct device *dev)
 	}
 }
 
+void device_id_update_vg_uuid(struct cmd_context *cmd, struct volume_group *vg, struct id *old_vg_id)
+{
+	struct dev_use *du;
+	struct lv_list *lvl;
+	char old_vgid[ID_LEN+1] = { 0 };
+	char new_vgid[ID_LEN+1] = { 0 };
+	char old_idname[PATH_MAX];
+	int update = 0;
+
+	if (!cmd->enable_devices_file)
+		goto out;
+
+	/* Without this setting there is no stacking LVs on PVs. */
+	if (!cmd->scan_lvs)
+		goto out;
+
+	/* Check if any devices file entries are stacked on LVs. */
+	if (!_device_ids_use_lvmlv(cmd))
+		goto out;
+
+	memcpy(old_vgid, old_vg_id, ID_LEN);
+	memcpy(new_vgid, &vg->id, ID_LEN);
+
+	/*
+	 * for each LV in VG, if there is a du for that LV (meaning a PV exists
+	 * on the LV), then update the du idname, replacing the old vgid with
+	 * the new vgid.
+	 */
+	dm_list_iterate_items(lvl, &vg->lvs) {
+		memset(old_idname, 0, sizeof(old_idname));
+		memcpy(old_idname, "LVM-", 4);
+		memcpy(old_idname+4, old_vgid, ID_LEN);
+		memcpy(old_idname+4+ID_LEN, &lvl->lv->lvid.id[1], ID_LEN);
+
+		if ((du = _get_du_for_device_id(cmd, DEV_ID_TYPE_LVMLV_UUID, old_idname))) {
+			log_debug("device_id update %s pvid %s vgid %s to %s",
+				  du->devname ?: ".", du->pvid ?: ".", old_vgid, new_vgid);
+			memcpy(du->idname+4, new_vgid, ID_LEN);
+			update = 1;
+
+			if (du->dev && du->dev->id && (du->dev->id->idtype == DEV_ID_TYPE_LVMLV_UUID))
+				memcpy(du->dev->id->idname+4, new_vgid, ID_LEN);
+		}
+	}
+
+	if (update)
+		device_ids_write(cmd);
+ out:
+	unlock_devices_file(cmd);
+}
+
 static int _idtype_compatible_with_major_number(struct cmd_context *cmd, int idtype, int major)
 {
 	if (idtype == DEV_ID_TYPE_MPATH_UUID ||
diff --git a/lib/device/device_id.h b/lib/device/device_id.h
index a1a53f253..939b3a0f4 100644
--- a/lib/device/device_id.h
+++ b/lib/device/device_id.h
@@ -36,6 +36,7 @@ void device_ids_validate(struct cmd_context *cmd, struct dm_list *scanned_devs,
 int device_ids_version_unchanged(struct cmd_context *cmd);
 void device_ids_find_renamed_devs(struct cmd_context *cmd, struct dm_list *dev_list, int *search_count, int noupdate);
 const char *device_id_system_read(struct cmd_context *cmd, struct device *dev, uint16_t idtype);
+void device_id_update_vg_uuid(struct cmd_context *cmd, struct volume_group *vg, struct id *old_vg_id);
 
 struct dev_use *get_du_for_dev(struct cmd_context *cmd, struct device *dev);
 struct dev_use *get_du_for_pvid(struct cmd_context *cmd, const char *pvid);
diff --git a/test/shell/devicesfile-basic.sh b/test/shell/devicesfile-basic.sh
index 53be895e7..7ba9e2c7f 100644
--- a/test/shell/devicesfile-basic.sh
+++ b/test/shell/devicesfile-basic.sh
@@ -608,6 +608,25 @@ rm "$DFDIR/test.devices"
 vgcreate --devicesfile test.devices $vg3 "$dev3"
 grep "$dev3" "$DFDIR/test.devices"
 
+# vgchange uuid handles stacked PVs on VGs
+
+wipe_all
+rm -f "$DF"
+vgcreate $vg1 "$dev1"
+lvcreate -l8 -n $lv1 $vg1
+aux lvmconf 'devices/scan_lvs = 1'
+pvcreate "$DM_DEV_DIR/$vg1/$lv1"
+pvs "$DM_DEV_DIR/$vg1/$lv1"
+grep "$DM_DEV_DIR/$vg1/$lv1" $DF
+vgchange -an $vg1
+vgchange --uuid $vg1
+vgchange -ay $vg1
+pvs "$DM_DEV_DIR/$vg1/$lv1"
+vgchange -an $vg1
+not pvs "$DM_DEV_DIR/$vg1/$lv1"
+aux lvmconf 'devices/scan_lvs = 0'
+vgremove -y $vg1
+
 #
 # verify --devicesfile and --devices are not affected by a filter
 # This is last because it sets lvm.conf filter and
diff --git a/tools/vgchange.c b/tools/vgchange.c
index d2d5f9dd2..e4b57dbd2 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -14,6 +14,7 @@
  */
 
 #include "tools.h"
+#include "lib/device/device_id.h"
 
 struct vgchange_params {
 	int lock_start_count;
@@ -412,12 +413,15 @@ static int _vgchange_uuid(struct cmd_context *cmd __attribute__((unused)),
 			  struct volume_group *vg)
 {
 	struct lv_list *lvl;
+	struct id old_vg_id;
 
 	if (lvs_in_vg_activated(vg)) {
 		log_error("Volume group has active logical volumes");
 		return 0;
 	}
 
+	memcpy(&old_vg_id, &vg->id, ID_LEN);
+
 	if (!id_create(&vg->id)) {
 		log_error("Failed to generate new random UUID for VG %s.",
 			  vg->name);
@@ -428,6 +432,12 @@ static int _vgchange_uuid(struct cmd_context *cmd __attribute__((unused)),
 		memcpy(&lvl->lv->lvid, &vg->id, sizeof(vg->id));
 	}
 
+	/*
+	 * If any LVs in this VG have PVs stacked on them, then
+	 * update the device_id of the stacked PV.
+	 */
+	device_id_update_vg_uuid(cmd, vg, &old_vg_id);
+
 	return 1;
 }
 
@@ -802,6 +812,14 @@ int vgchange(struct cmd_context *cmd, int argc, char **argv)
 	if (noupdate)
 		cmd->ignore_device_name_mismatch = 1;
 
+	/*
+	 * If the devices file includes PVs stacked on LVs, then
+	 * vgchange --uuid may need to update the devices file.
+	 * No PV-on-LV stacked is done without scan_lvs set.
+	 */
+	if (arg_is_set(cmd, uuid_ARG) && cmd->scan_lvs)
+		cmd->edit_devices_file = 1;
+
 	/*
 	 * Include foreign VGs that contain active LVs.
 	 * That shouldn't happen in general, but if it does by some


