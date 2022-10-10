From: David Teigland <teigland@sourceware.org>
Date: Mon, 10 Oct 2022 16:47:58 +0000 (GMT)
Subject: main - lvmdevices: use deviceidtype option strictly
Message-ID: <20221010164758.DE06A3858288@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=13c63f0cfa22a0bc89b8d528b8e2301c49fc7b0d
Commit:        13c63f0cfa22a0bc89b8d528b8e2301c49fc7b0d
Parent:        c4e6d675de5b0df5a711971b7828933f07b0efd0
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Sep 15 09:45:21 2022 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Oct 10 11:47:29 2022 -0500

lvmdevices: use deviceidtype option strictly

Only use the device id type specified by --deviceidtype,
and fail if that type is not available for the device.
---
 lib/device/device_id.c  | 15 ++++++++++++---
 lib/device/device_id.h  |  2 +-
 tools/lvmdevices.c      |  6 +++---
 tools/toollib.c         |  4 ++--
 tools/vgimportclone.c   |  2 +-
 tools/vgimportdevices.c |  2 +-
 6 files changed, 20 insertions(+), 11 deletions(-)

diff --git a/lib/device/device_id.c b/lib/device/device_id.c
index 6383f69fb..252654861 100644
--- a/lib/device/device_id.c
+++ b/lib/device/device_id.c
@@ -1140,7 +1140,7 @@ struct dev_use *get_du_for_device_id(struct cmd_context *cmd, uint16_t idtype, c
  * . add or update entry in cmd->use_devices
  */
 int device_id_add(struct cmd_context *cmd, struct device *dev, const char *pvid_arg,
-		  const char *idtype_arg, const char *id_arg)
+		  const char *idtype_arg, const char *id_arg, int use_idtype_only)
 {
 	char pvid[ID_LEN+1] = { 0 };
 	uint16_t idtype = 0;
@@ -1194,9 +1194,13 @@ int device_id_add(struct cmd_context *cmd, struct device *dev, const char *pvid_
 	 */
 
 	if (idtype_arg) {
-		if (!(idtype = idtype_from_str(idtype_arg)))
+		if (!(idtype = idtype_from_str(idtype_arg))) {
+			if (use_idtype_only) {
+				log_error("The specified --deviceidtype %s is unknown.", idtype_arg);
+				return 0;
+			}
 			log_warn("WARNING: ignoring unknown device_id type %s.", idtype_arg);
-		else {
+		} else {
 			if (id_arg) {
 				if ((idname = strdup(id_arg)))
 					goto id_done;
@@ -1206,6 +1210,11 @@ int device_id_add(struct cmd_context *cmd, struct device *dev, const char *pvid_
 			if ((idname = device_id_system_read(cmd, dev, idtype)))
 				goto id_done;
 
+			if (use_idtype_only) {
+				log_error("The specified --deviceidtype %s is not available for %s.", idtype_arg, dev_name(dev));
+				return 0;
+			}
+
 			log_warn("WARNING: ignoring deviceidtype %s which is not available for device.", idtype_arg);
 			idtype = 0;
 		}
diff --git a/lib/device/device_id.h b/lib/device/device_id.h
index 6962925df..700176bb5 100644
--- a/lib/device/device_id.h
+++ b/lib/device/device_id.h
@@ -28,7 +28,7 @@ int device_ids_use_devname(struct cmd_context *cmd);
 int device_ids_read(struct cmd_context *cmd);
 int device_ids_write(struct cmd_context *cmd);
 int device_id_add(struct cmd_context *cmd, struct device *dev, const char *pvid,
-                  const char *idtype_arg, const char *id_arg);
+                  const char *idtype_arg, const char *id_arg, int use_idtype_only);
 void device_id_pvremove(struct cmd_context *cmd, struct device *dev);
 void device_ids_match(struct cmd_context *cmd);
 int device_ids_match_dev(struct cmd_context *cmd, struct device *dev);
diff --git a/tools/lvmdevices.c b/tools/lvmdevices.c
index 04f707519..5d9c0c7b7 100644
--- a/tools/lvmdevices.c
+++ b/tools/lvmdevices.c
@@ -264,7 +264,7 @@ int lvmdevices(struct cmd_context *cmd, int argc, char **argv)
 				if (update_set) {
 					log_print("Adding multipath device %s for multipath component %s.",
 						  dev_name(mpath_dev), dev_name(du->dev));
-					if (!device_id_add(cmd, mpath_dev, dev->pvid, NULL, NULL))
+					if (!device_id_add(cmd, mpath_dev, dev->pvid, NULL, NULL, 0))
 						stack;
 				} else {
 					log_print("Missing multipath device %s for multipath component %s.",
@@ -360,7 +360,7 @@ int lvmdevices(struct cmd_context *cmd, int argc, char **argv)
 		/* also allow deviceid_ARG ? */
 		deviceidtype = arg_str_value(cmd, deviceidtype_ARG, NULL);
 
-		if (!device_id_add(cmd, dev, dev->pvid, deviceidtype, NULL))
+		if (!device_id_add(cmd, dev, dev->pvid, deviceidtype, NULL, 1))
 			goto_bad;
 		if (!device_ids_write(cmd))
 			goto_bad;
@@ -408,7 +408,7 @@ int lvmdevices(struct cmd_context *cmd, int argc, char **argv)
 		}
 		dm_list_iterate_items(devl, &found_devs) {
 			deviceidtype = arg_str_value(cmd, deviceidtype_ARG, NULL);
-			if (!device_id_add(cmd, devl->dev, devl->dev->pvid, deviceidtype, NULL))
+			if (!device_id_add(cmd, devl->dev, devl->dev->pvid, deviceidtype, NULL, 1))
 				goto_bad;
 		}
 		if (!device_ids_write(cmd))
diff --git a/tools/toollib.c b/tools/toollib.c
index 91eda84dd..e45afb6ee 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -5833,7 +5833,7 @@ do_command:
 
 				/* allow deviceidtype_ARG/deviceid_ARG ? */
 				memcpy(pvid, &pvl->pv->id.uuid, ID_LEN);
-				device_id_add(cmd, pd->dev, pvid, NULL, NULL);
+				device_id_add(cmd, pd->dev, pvid, NULL, NULL, 0);
 
 			} else {
 				log_error("Failed to find PV %s", pd->name);
@@ -5873,7 +5873,7 @@ do_command:
 
 		/* allow deviceidtype_ARG/deviceid_ARG ? */
 		memcpy(pvid, &pv->id.uuid, ID_LEN);
-		device_id_add(cmd, pd->dev, pvid, NULL, NULL);
+		device_id_add(cmd, pd->dev, pvid, NULL, NULL, 0);
 
 		log_verbose("Set up physical volume for \"%s\" with %" PRIu64
 			    " available sectors.", pv_name, pv_size(pv));
diff --git a/tools/vgimportclone.c b/tools/vgimportclone.c
index cab501619..9e426c942 100644
--- a/tools/vgimportclone.c
+++ b/tools/vgimportclone.c
@@ -162,7 +162,7 @@ static int _update_vg(struct cmd_context *cmd, struct volume_group *vg,
 	 */
 	if (vp->import_devices || cmd->enable_devices_file) {
 		dm_list_iterate_items(devl, &vp->new_devs) {
-			if (!device_id_add(cmd, devl->dev, devl->dev->pvid, NULL, NULL)) {
+			if (!device_id_add(cmd, devl->dev, devl->dev->pvid, NULL, NULL, 0)) {
 				log_error("Failed to add device id for %s.", dev_name(devl->dev));
 				goto bad;
 			}
diff --git a/tools/vgimportdevices.c b/tools/vgimportdevices.c
index 23c2718ff..ab359d31c 100644
--- a/tools/vgimportdevices.c
+++ b/tools/vgimportdevices.c
@@ -60,7 +60,7 @@ static int _vgimportdevices_single(struct cmd_context *cmd,
 		idtypestr = pv->device_id_type;
 
 		memcpy(pvid, &pvl->pv->id.uuid, ID_LEN);
-		device_id_add(cmd, pv->dev, pvid, idtypestr, NULL);
+		device_id_add(cmd, pv->dev, pvid, idtypestr, NULL, 0);
 		vp->added_devices++;
 
 		/* We could skip update if the device_id has not changed. */

