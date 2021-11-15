From: David Teigland <teigland@sourceware.org>
Date: Mon, 15 Nov 2021 20:57:12 +0000 (GMT)
Subject: main - device_id: match different dm device names
Message-ID: <20211115205712.752753858003@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c5f998aec4b5e42f7f1b6ddeec6c4544dceaa1b5
Commit:        c5f998aec4b5e42f7f1b6ddeec6c4544dceaa1b5
Parent:        4926061d32f855ffe7a38034b2fe2917e63409a0
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Nov 12 16:42:51 2021 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Nov 12 16:42:51 2021 -0600

device_id: match different dm device names

If a devices file entry for a dm device is using the devname
for the device id, then recognize different dm names as matching.
---
 lib/device/device_id.c | 81 ++++++++++++++++++++++++++++++++++++++++++--------
 1 file changed, 69 insertions(+), 12 deletions(-)

diff --git a/lib/device/device_id.c b/lib/device/device_id.c
index 18669630c..749acdf89 100644
--- a/lib/device/device_id.c
+++ b/lib/device/device_id.c
@@ -1359,6 +1359,10 @@ void device_id_update_vg_uuid(struct cmd_context *cmd, struct volume_group *vg,
 
 static int _idtype_compatible_with_major_number(struct cmd_context *cmd, int idtype, int major)
 {
+	/* devname can be used with any kind of device */
+	if (idtype == DEV_ID_TYPE_DEVNAME)
+		return 1;
+
 	if (idtype == DEV_ID_TYPE_MPATH_UUID ||
 	    idtype == DEV_ID_TYPE_CRYPT_UUID ||
 	    idtype == DEV_ID_TYPE_LVMLV_UUID)
@@ -1387,6 +1391,43 @@ static int _idtype_compatible_with_major_number(struct cmd_context *cmd, int idt
 	return 1;
 }
 
+static int _match_dm_devnames(struct cmd_context *cmd, struct device *dev,
+			      struct dev_id *id, struct dev_use *du)
+{
+	struct stat buf;
+
+	if (MAJOR(dev->dev) != cmd->dev_types->device_mapper_major)
+		return 0;
+
+	if (id->idname && du->idname && !strcmp(id->idname, du->idname))
+		return 1;
+
+	if (du->idname && !strcmp(du->idname, dev_name(dev))) {
+		log_debug("Match device_id %s %s to %s: ignoring idname %s",
+			  idtype_to_str(du->idtype), du->idname, dev_name(dev), id->idname ?: ".");
+		return 1;
+	}
+
+	if (!du->idname)
+		return 0;
+
+	/* detect that a du entry is for a dm device */
+
+	if (!strncmp(du->idname, "/dev/dm-", 8) || !strncmp(du->idname, "/dev/mapper/", 12)) {
+		if (stat(du->idname, &buf))
+			return 0;
+
+		if ((MAJOR(buf.st_rdev) == cmd->dev_types->device_mapper_major) &&
+		    (MINOR(buf.st_rdev) == MINOR(dev->dev))) {
+			log_debug("Match device_id %s %s to %s: using other dm name, ignoring %s",
+				  idtype_to_str(du->idtype), du->idname, dev_name(dev), id->idname ?: ".");
+			return 1;
+		}
+	}
+
+	return 0;
+}
+
 /*
  * check for dev->ids entry with du->idtype, if found compare it,
  * if not, system_read of this type and add entry to dev->ids, compare it.
@@ -1407,35 +1448,52 @@ static int _match_du_to_dev(struct cmd_context *cmd, struct dev_use *du, struct
 	 * so we can skip trying to match certain du entries based simply on
 	 * the major number of dev.
 	 */
-	if (!_idtype_compatible_with_major_number(cmd, du->idtype, (int)MAJOR(dev->dev)))
+	if (!_idtype_compatible_with_major_number(cmd, du->idtype, (int)MAJOR(dev->dev))) {
+		/*
+		log_debug("Mismatch device_id %s %s to %s: wrong major",
+			  idtype_to_str(du->idtype), du->idname ?: ".", dev_name(dev));
+		*/
 		return 0;
+	}
 
 	if (!dev_get_partition_number(dev, &part)) {
-		log_debug("compare %s failed to get dev partition", dev_name(dev));
+		/*
+		log_debug("Mismatch device_id %s %s to %s: no partition",
+			  idtype_to_str(du->idtype), du->idname ?: ".", dev_name(dev));
+		*/
 		return 0;
 	}
 	if (part != du->part) {
 		/*
-		log_debug("compare mis %s %s part %d to %s part %d",
-			  idtype_to_str(du->idtype), du->idname ?: ".", du->part, dev_name(dev), part);
+		log_debug("Mismatch device_id %s %s to %s: wrong partition %d vs %d",
+			  idtype_to_str(du->idtype), du->idname ?: ".", dev_name(dev), du->part, part);
 		*/
 		return 0;
 	}
 
 	dm_list_iterate_items(id, &dev->ids) {
 		if (id->idtype == du->idtype) {
-			if (id->idname && !strcmp(id->idname, du->idname)) {
+			if ((id->idtype == DEV_ID_TYPE_DEVNAME) && _match_dm_devnames(cmd, dev, id, du)) {
+				/* dm devs can have differing names that we know still match */
+				du->dev = dev;
+				dev->id = id;
+				dev->flags |= DEV_MATCHED_USE_ID;
+				log_debug("Match device_id %s %s to %s: dm names",
+					  idtype_to_str(du->idtype), du->idname, dev_name(dev));
+				return 1;
+
+			} else if (id->idname && !strcmp(id->idname, du->idname)) {
 				du->dev = dev;
 				dev->id = id;
 				dev->flags |= DEV_MATCHED_USE_ID;
 				log_debug("Match device_id %s %s to %s",
 					  idtype_to_str(du->idtype), du->idname, dev_name(dev));
 				return 1;
+
 			} else {
 				/*
-				log_debug("compare mis %s %s to %s %s",
-			  		  idtype_to_str(du->idtype), du->idname ?: ".", dev_name(dev),
-					  ((id->idtype != DEV_ID_TYPE_DEVNAME) && id->idname) ? id->idname : "");
+				log_debug("Mismatch device_id %s %s to %s: idname %s",
+			  		  idtype_to_str(du->idtype), du->idname ?: ".", dev_name(dev), id->idname ?: ":");
 				*/
 				return 0;
 			}
@@ -1455,7 +1513,7 @@ static int _match_du_to_dev(struct cmd_context *cmd, struct dev_use *du, struct
 		id->dev = dev;
 		dm_list_add(&dev->ids, &id->list);
 		/*
-		log_debug("compare mis %s %s to %s no idtype",
+		log_debug("Mismatch device_id %s %s to %s: no idtype",
 			  idtype_to_str(du->idtype), du->idname ?: ".", dev_name(dev));
 		*/
 		return 0;
@@ -1480,9 +1538,8 @@ static int _match_du_to_dev(struct cmd_context *cmd, struct dev_use *du, struct
 	}
 
 	/*
-	log_debug("compare mis %s %s to %s %s",
-		  idtype_to_str(du->idtype), du->idname ?: ".", dev_name(dev),
-		  ((id->idtype != DEV_ID_TYPE_DEVNAME) && id->idname) ? id->idname : "");
+	log_debug("Mismatch device_id %s %s to %s: idname %s",
+		  idtype_to_str(du->idtype), du->idname ?: ".", dev_name(dev), idname);
 	*/
 	return 0;
 }


