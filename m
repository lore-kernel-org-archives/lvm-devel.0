From: David Teigland <teigland@sourceware.org>
Date: Tue, 25 Jan 2022 21:19:56 +0000 (GMT)
Subject: main - lvmdevices: fix checks when adding entries
Message-ID: <20220125211956.4408A385DC2E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8f50c5e79b6ce619a53d51353dded2f84953af00
Commit:        8f50c5e79b6ce619a53d51353dded2f84953af00
Parent:        9e9f02acf04a1dd002709b2239a28ac56dd76aba
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jan 25 11:35:36 2022 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jan 25 15:18:29 2022 -0600

lvmdevices: fix checks when adding entries

Removes some incorrect and unnecessary checks for other entries
when adding a new devices.  The removed checks and corrections were
mostly redundant with what is already done by device id matching.
Other checking is reworked so the warnings are a bit different.
---
 lib/device/device_id.c | 153 ++++++++++++++++---------------------------------
 1 file changed, 48 insertions(+), 105 deletions(-)

diff --git a/lib/device/device_id.c b/lib/device/device_id.c
index ecf89918d..84f9f87ce 100644
--- a/lib/device/device_id.c
+++ b/lib/device/device_id.c
@@ -950,6 +950,10 @@ int device_id_add(struct cmd_context *cmd, struct device *dev, const char *pvid_
 	struct dev_use *du, *update_du = NULL, *du_dev, *du_pvid, *du_devname, *du_devid;
 	struct dev_id *id;
 	int found_id = 0;
+	int part = 0;
+
+	if (!dev_get_partition_number(dev, &part))
+		return_0;
 
 	/*
 	 * When enable_devices_file=0 and pending_devices_file=1 we let
@@ -968,10 +972,6 @@ int device_id_add(struct cmd_context *cmd, struct device *dev, const char *pvid_
 	 */
 	memcpy(&pvid, pvid_arg, ID_LEN);
 
-	du_dev = get_du_for_dev(cmd, dev);
-	du_pvid = get_du_for_pvid(cmd, pvid);
-	du_devname = _get_du_for_devname(cmd, dev_name(dev));
-
 	/*
 	 * Choose the device_id type for the device being added.
 	 *
@@ -1087,6 +1087,9 @@ id_done:
 	idtype = 0;
 
 	/*
+	 * "dev" is the device we are adding.
+	 * "id" is the device_id it's using, set in dev->id.
+	 *
 	 * Update the cmd->use_devices list for the new device.  The
 	 * use_devices list will be used to update the devices file.
 	 *
@@ -1098,23 +1101,57 @@ id_done:
 	 * those other entries to fix any incorrect info.
 	 */
 
+	/* Is there already an entry matched to this device? */
+	du_dev = get_du_for_dev(cmd, dev);
+
+	/* Is there already an entry matched to this device's pvid? */
+	du_pvid = get_du_for_pvid(cmd, pvid);
+
+	/* Is there already an entry using this device's name? */
+	du_devname = _get_du_for_devname(cmd, dev_name(dev));
+
+	/* Is there already an entry using the device_id for this device? */
 	du_devid = _get_du_for_device_id(cmd, id->idtype, id->idname);
 
 	if (du_dev)
-		log_debug("device_id_add %s pvid %s matches du_dev %p dev %s",
+		log_debug("device_id_add %s pvid %s matches entry %p dev %s",
 			  dev_name(dev), pvid, du_dev, dev_name(du_dev->dev));
 	if (du_pvid)
-		log_debug("device_id_add %s pvid %s matches du_pvid %p dev %s pvid %s",
+		log_debug("device_id_add %s pvid %s matches entry %p dev %s with same pvid %s",
 			  dev_name(dev), pvid, du_pvid, du_pvid->dev ? dev_name(du_pvid->dev) : ".",
 			  du_pvid->pvid);
 	if (du_devid)
-		log_debug("device_id_add %s pvid %s matches du_devid %p dev %s pvid %s",
+		log_debug("device_id_add %s pvid %s matches entry %p dev %s with same device_id %d %s",
 			  dev_name(dev), pvid, du_devid, du_devid->dev ? dev_name(du_devid->dev) : ".",
-			  du_devid->pvid);
+			  du_devid->idtype, du_devid->idname);
 	if (du_devname)
-		log_debug("device_id_add %s pvid %s matches du_devname %p dev %s pvid %s",
+		log_debug("device_id_add %s pvid %s matches entry %p dev %s with same devname %s",
 			  dev_name(dev), pvid, du_devname, du_devname->dev ? dev_name(du_devname->dev) : ".",
-			  du_devname->pvid);
+			  du_devname->devname);
+
+	if (du_pvid && (du_pvid->dev != dev))
+		log_warn("WARNING: adding device %s with PVID %s which is already used for %s.",
+			 dev_name(dev), pvid, du_pvid->dev ? dev_name(du_pvid->dev) : "missing device");
+
+	if (du_devid && (du_devid->dev != dev)) {
+		if (!du_devid->dev) {
+			log_warn("WARNING: adding device %s with idname %s which is already used for missing device.",
+				 dev_name(dev), id->idname);
+		} else {
+			int ret1, ret2;
+			dev_t devt1, devt2;
+			/* Check if both entries are partitions of the same device. */
+			ret1 = dev_get_primary_dev(cmd->dev_types, dev, &devt1);
+			ret2 = dev_get_primary_dev(cmd->dev_types, du_devid->dev, &devt2);
+			if ((ret1 == 2) && (ret2 == 2) && (devt1 == devt2)) {
+				log_debug("Using separate entries for partitions of same device %s part %d %s part %d.",
+					  dev_name(dev), part, dev_name(du_devid->dev), du_devid->part);
+			} else {
+				log_warn("WARNING: adding device %s with idname %s which is already used for %s.",
+					 dev_name(dev), id->idname, dev_name(du_devid->dev));
+			}
+		}
+	}
 
 	/*
 	 * If one of the existing entries (du_dev, du_pvid, du_devid, du_devname)
@@ -1127,29 +1164,6 @@ id_done:
 		dm_list_del(&update_du->list);
 		update_matching_kind = "device";
 		update_matching_name = dev_name(dev);
-
-		if (du_devid && (du_devid != du_dev)) {
-			log_warn("WARNING: device %s (%s) and %s (%s) have duplicate device ID.",
-				 dev_name(dev), id->idname,
-				 (du_pvid && du_pvid->dev) ? dev_name(du_pvid->dev) : "none",
-				 du_pvid ? du_pvid->idname : "");
-		}
-
-		if (du_pvid && (du_pvid != du_dev)) {
-			log_warn("WARNING: device %s (%s) and %s (%s) have duplicate PVID %s",
-				 dev_name(dev), id->idname,
-				 du_pvid->dev ? dev_name(du_pvid->dev) : "none", du_pvid->idname,
-				 pvid);
-		}
-
-		if (du_devname && (du_devname != du_dev)) {
-			/* clear devname in another entry with our devname */
-			log_warn("Devices file PVID %s clearing wrong DEVNAME %s.",
-				 du_devname->pvid, du_devname->devname);
-			free(du_devname->devname);
-			du_devname->devname = NULL;
-		}
-
 	} else if (du_pvid) {
 		/*
 		 * If the device_id of the existing entry for PVID is the same
@@ -1169,11 +1183,6 @@ id_done:
 			update_matching_kind = "PVID";
 			update_matching_name = pvid;
 		} else {
-			log_warn("WARNING: device %s (%s) and %s (%s) have duplicate PVID %s",
-				 dev_name(dev), id->idname,
-				 du_pvid->dev ? dev_name(du_pvid->dev) : "none", du_pvid->idname,
-				 pvid);
-
 			if (!cmd->current_settings.yes &&
 			    yes_no_prompt("Add device with duplicate PV to devices file?") == 'n') {
 				log_print("Device not added.");
@@ -1181,21 +1190,6 @@ id_done:
 				return 1;
 			}
 		}
-
-		if (du_devid && (du_devid != du_pvid)) {
-			/* warn about another entry using the same device_id */
-			log_warn("WARNING: duplicate device_id %s for PVIDs %s %s",
-				 du_devid->idname, du_devid->pvid, du_pvid->pvid);
-		}
-
-		if (du_devname && (du_devname != du_pvid)) {
-			/* clear devname in another entry with our devname */
-			log_warn("Devices file PVID %s clearing wrong DEVNAME %s.",
-				 du_devname->pvid, du_devname->devname);
-			free(du_devname->devname);
-			du_devname->devname = NULL;
-		}
-
 	} else if (du_devid) {
 		/*
 		 * Do we create a new du or update the existing du?
@@ -1210,64 +1204,13 @@ id_done:
 		 * the same device_id (create a new du for dev.)
 		 * If not, then update the existing du_devid.
 		 */
-		
-		if (du_devid->dev != dev)
-			check_idname = device_id_system_read(cmd, du_devid->dev, id->idtype);
-
-		if (check_idname && !strcmp(check_idname, id->idname)) {
-			int ret1, ret2;
-			dev_t devt1, devt2;
-
-			/*
-			 * two different devices have the same device_id,
-			 * create a new du for the device being added
-			 */
-
-			/* dev_is_partitioned() the dev open to read it. */
-			if (!label_scan_open(du_devid->dev))
-				log_warn("Cannot open %s", dev_name(du_devid->dev));
-
-			if (dev_is_partitioned(cmd, du_devid->dev)) {
-				/* Check if existing entry is whole device and new entry is a partition of it. */
-				ret1 = dev_get_primary_dev(cmd->dev_types, dev, &devt1);
-				if ((ret1 == 2) && (devt1 == du_devid->dev->dev))
-					log_warn("Remove partitioned device %s from devices file.", dev_name(du_devid->dev));
-			} else {
-				/* Check if both entries are partitions of the same device. */
-				ret1 = dev_get_primary_dev(cmd->dev_types, dev, &devt1);
-				ret2 = dev_get_primary_dev(cmd->dev_types, du_devid->dev, &devt2);
-
-				if ((ret1 == 2) && (ret2 == 2) && (devt1 == devt2)) {
-					log_warn("Partitions %s %s have same device_id %s",
-						 dev_name(dev), dev_name(du_devid->dev), id->idname);
-				} else {
-					log_warn("Duplicate device_id %s %s for %s and %s",
-						 idtype_to_str(id->idtype), check_idname,
-						 dev_name(dev), dev_name(du_devid->dev));
-				}
-			}
-		} else {
+		if (du_devid->dev == dev) {
 			/* update the existing entry with matching devid */
 			update_du = du_devid;
 			dm_list_del(&update_du->list);
 			update_matching_kind = "device_id";
 			update_matching_name = id->idname;
 		}
-
-		if (du_devname && (du_devname != du_devid)) {
-			/* clear devname in another entry with our devname */
-			log_warn("Devices file PVID %s clearing wrong DEVNAME %s",
-				 du_devname->pvid, du_devname->devname);
-			free(du_devname->devname);
-			du_devname->devname = NULL;
-		}
-
-	} else if (du_devname) {
-		/* clear devname in another entry with our devname */
-		log_warn("Devices file PVID %s clearing wrong DEVNAME %s",
-			 du_devname->pvid, du_devname->devname);
-		free(du_devname->devname);
-		du_devname->devname = NULL;
 	}
 
 	free((void *)check_idname);


