From: David Teigland <teigland@sourceware.org>
Date: Wed,  6 Apr 2022 17:51:58 +0000 (GMT)
Subject: main - lvmdevices: --deldev using device id
Message-ID: <20220406175158.88D0E385843E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fb7698b0ce47b965db056022cad712a965554f3a
Commit:        fb7698b0ce47b965db056022cad712a965554f3a
Parent:        151ce8b27672134438d0bc457f49123db96a176c
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Apr 6 12:29:26 2022 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Apr 6 12:51:34 2022 -0500

lvmdevices: --deldev using device id

When used with --deviceidtype, --deldev can specify
a device id to remove.
---
 lib/device/device_id.c         |  6 +++---
 lib/device/device_id.h         |  1 +
 man/lvmdevices.8_des           |  1 +
 test/shell/devicesfile-edit.sh | 21 +++++++++++++++++++
 tools/args.h                   |  8 +++++--
 tools/command-lines.in         |  3 ++-
 tools/lvmdevices.c             | 47 +++++++++++++++++++++++++++++++++++++++++-
 7 files changed, 80 insertions(+), 7 deletions(-)

diff --git a/lib/device/device_id.c b/lib/device/device_id.c
index 0f7c42f79..6c7136d5f 100644
--- a/lib/device/device_id.c
+++ b/lib/device/device_id.c
@@ -935,7 +935,7 @@ struct dev_use *get_du_for_devname(struct cmd_context *cmd, const char *devname)
 	return NULL;
 }
 
-static struct dev_use *_get_du_for_device_id(struct cmd_context *cmd, uint16_t idtype, const char *idname)
+struct dev_use *get_du_for_device_id(struct cmd_context *cmd, uint16_t idtype, const char *idname)
 {
 	struct dev_use *du;
 
@@ -1128,7 +1128,7 @@ id_done:
 	du_devname = get_du_for_devname(cmd, dev_name(dev));
 
 	/* Is there already an entry using the device_id for this device? */
-	du_devid = _get_du_for_device_id(cmd, id->idtype, id->idname);
+	du_devid = get_du_for_device_id(cmd, id->idtype, id->idname);
 
 	if (du_dev)
 		log_debug("device_id_add %s pvid %s matches entry %p dev %s",
@@ -1322,7 +1322,7 @@ void device_id_update_vg_uuid(struct cmd_context *cmd, struct volume_group *vg,
 		memcpy(old_idname+4, old_vgid, ID_LEN);
 		memcpy(old_idname+4+ID_LEN, &lvl->lv->lvid.id[1], ID_LEN);
 
-		if ((du = _get_du_for_device_id(cmd, DEV_ID_TYPE_LVMLV_UUID, old_idname))) {
+		if ((du = get_du_for_device_id(cmd, DEV_ID_TYPE_LVMLV_UUID, old_idname))) {
 			log_debug("device_id update %s pvid %s vgid %s to %s",
 				  du->devname ?: ".", du->pvid ?: ".", old_vgid, new_vgid);
 			memcpy(du->idname+4, new_vgid, ID_LEN);
diff --git a/lib/device/device_id.h b/lib/device/device_id.h
index 03c3ecaec..94773a65e 100644
--- a/lib/device/device_id.h
+++ b/lib/device/device_id.h
@@ -43,6 +43,7 @@ struct dev_use *get_du_for_devno(struct cmd_context *cmd, dev_t devno);
 struct dev_use *get_du_for_dev(struct cmd_context *cmd, struct device *dev);
 struct dev_use *get_du_for_pvid(struct cmd_context *cmd, const char *pvid);
 struct dev_use *get_du_for_devname(struct cmd_context *cmd, const char *devname);
+struct dev_use *get_du_for_device_id(struct cmd_context *cmd, uint16_t idtype, const char *idname);
 
 char *devices_file_version(void);
 int devices_file_exists(struct cmd_context *cmd);
diff --git a/man/lvmdevices.8_des b/man/lvmdevices.8_des
index 2335456ad..289aad466 100644
--- a/man/lvmdevices.8_des
+++ b/man/lvmdevices.8_des
@@ -85,6 +85,7 @@ is used for dm crypt devices, reported by sysfs.
 .IP \[bu] 2
 .B md_uuid
 is used for md devices, reported by sysfs.
+.IP \[bu] 2
 .B lvmlv_uuid
 is used if a PV is placed on top of an lvm LV, reported by sysfs.
 .IP \[bu] 2
diff --git a/test/shell/devicesfile-edit.sh b/test/shell/devicesfile-edit.sh
index 1675cb732..2a046e213 100644
--- a/test/shell/devicesfile-edit.sh
+++ b/test/shell/devicesfile-edit.sh
@@ -135,6 +135,24 @@ lvmdevices --deldev "$LOOP1"
 not grep "$LOOP1" $DF
 lvmdevices --deldev "$LOOP2"
 not grep "$LOOP2" $DF
+rm $DF
+
+# deldev using idname
+lvmdevices --adddev "$LOOP1"
+lvmdevices --adddev "$LOOP2"
+vgcreate $vg "$LOOP1" "$LOOP2"
+IDNAME1=`pvs "$LOOP1" --noheading -o deviceid | tr -d - | awk '{print $1}'`
+IDNAME2=`pvs "$LOOP2" --noheading -o deviceid | tr -d - | awk '{print $1}'`
+lvmdevices --deldev "$IDNAME2" --deviceidtype loop_file
+not grep "$IDNAME2" $DF
+not grep "$LOOP2" $DF
+lvmdevices --deldev "$IDNAME1" --deviceidtype loop_file
+not grep "$IDNAME1" $DF
+not grep "$LOOP1" $DF
+lvmdevices --adddev "$LOOP1"
+lvmdevices --adddev "$LOOP2"
+vgremove $vg
+rm $DF
 
 # add/delpvid with default idtype loop_file
 lvmdevices --addpvid "$PVID1"
@@ -151,6 +169,7 @@ not grep "$PVID1" $DF
 lvmdevices --delpvid "$PVID2"
 not grep "$LOOP2" $DF
 not grep "$PVID2" $DF
+rm $DF
 
 # add/deldev with non-default idtype devname
 lvmdevices --adddev "$LOOP1" --deviceidtype devname
@@ -165,6 +184,7 @@ lvmdevices --deldev "$LOOP1"
 not grep "$LOOP1" $DF
 lvmdevices --deldev "$LOOP2"
 not grep "$LOOP2" $DF
+rm $DF
 
 # add/delpvid with non-default idtype devname
 lvmdevices --addpvid "$PVID1" --deviceidtype devname
@@ -179,6 +199,7 @@ lvmdevices --deldev "$LOOP1"
 not grep "$LOOP1" $DF
 lvmdevices --deldev "$LOOP2"
 not grep "$LOOP2" $DF
+rm $DF
 
 # add/deldev when dev is missing, using default idtype
 lvmdevices --adddev "$LOOP1"
diff --git a/tools/args.h b/tools/args.h
index 03fe24556..c4d8fe7ff 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -46,8 +46,12 @@ arg(addtag_ARG, '\0', "addtag", tag_VAL, ARG_GROUPABLE, 0,
 
 arg(adddev_ARG, '\0', "adddev", pv_VAL, 0, 0,
     "Add a device to the devices file.\n")
-arg(deldev_ARG, '\0', "deldev", pv_VAL, 0, 0,
-    "Remove a device from the devices file.\n")
+
+arg(deldev_ARG, '\0', "deldev", string_VAL, 0, 0,
+    "Remove a device from the devices file.\n"
+    "When used alone, --deldev specifies a device name.\n"
+    "When used with --deviceidtype, --deldev specifies a device id.\n")
+
 arg(addpvid_ARG, '\0', "addpvid", string_VAL, 0, 0,
     "Find a device with the PVID and add the device to the devices file.\n")
 arg(delpvid_ARG, '\0', "delpvid", string_VAL, 0, 0,
diff --git a/tools/command-lines.in b/tools/command-lines.in
index 6f431e233..ce350e95c 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -1434,7 +1434,8 @@ OO: --deviceidtype String
 ID: lvmdevices_edit
 DESC: Add a device to the devices file.
 
-lvmdevices --deldev PV
+lvmdevices --deldev PV|String
+OO: --deviceidtype String
 ID: lvmdevices_edit
 DESC: Remove a device from the devices file.
 
diff --git a/tools/lvmdevices.c b/tools/lvmdevices.c
index b03411b8b..04f707519 100644
--- a/tools/lvmdevices.c
+++ b/tools/lvmdevices.c
@@ -416,12 +416,15 @@ int lvmdevices(struct cmd_context *cmd, int argc, char **argv)
 		goto out;
 	}
 
-	if (arg_is_set(cmd, deldev_ARG)) {
+	if (arg_is_set(cmd, deldev_ARG) && !arg_is_set(cmd, deviceidtype_ARG)) {
 		const char *devname;
 
 		if (!(devname = arg_str_value(cmd, deldev_ARG, NULL)))
 			goto_bad;
 
+		if (strncmp(devname, "/dev/", 5))
+			log_warn("WARNING: to remove a device by device id, include --deviceidtype.");
+
 		/*
 		 * No filter because we always want to allow removing a device
 		 * by name from the devices file.
@@ -453,6 +456,48 @@ int lvmdevices(struct cmd_context *cmd, int argc, char **argv)
 		goto out;
 	}
 
+	/*
+	 * By itself, --deldev <devname> specifies a device name to remove.
+	 * With an id type specified, --deldev specifies a device id to remove:
+	 * --deldev <idname> --deviceidtype <idtype>
+	 */
+	if (arg_is_set(cmd, deldev_ARG) && arg_is_set(cmd, deviceidtype_ARG)) {
+		const char *idtype_str = arg_str_value(cmd, deviceidtype_ARG, NULL);
+		const char *idname = arg_str_value(cmd, deldev_ARG, NULL);
+		int idtype;
+
+		if (!idtype_str || !idname || !strlen(idname) || !strlen(idtype_str))
+			goto_bad;
+
+		if (!(idtype = idtype_from_str(idtype_str))) {
+			log_error("Unknown device_id type.");
+			goto_bad;
+		}
+
+		if (!strncmp(idname, "/dev/", 5))
+			log_warn("WARNING: to remove a device by name, do not include --deviceidtype.");
+
+		if (!(du = get_du_for_device_id(cmd, idtype, idname))) {
+			log_error("No devices file entry with device id %s %s.", idtype_str, idname);
+			goto_bad;
+		}
+
+		dev = du->dev;
+
+		if (dev && dev_is_used_by_active_lv(cmd, dev, NULL, NULL, NULL, NULL)) {
+			if (!arg_count(cmd, yes_ARG) &&
+			    yes_no_prompt("Device %s is used by an active LV, continue to remove? ", dev_name(dev)) == 'n') {
+				log_error("Device not removed.");
+				goto bad;
+			}
+		}
+
+		dm_list_del(&du->list);
+		free_du(du);
+		device_ids_write(cmd);
+		goto out;
+	}
+
 	if (arg_is_set(cmd, delpvid_ARG)) {
 		struct id id;
 		char pvid[ID_LEN+1] = { 0 };

