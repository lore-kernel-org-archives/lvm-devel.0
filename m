From: David Teigland <teigland@sourceware.org>
Date: Mon, 10 Oct 2022 16:47:54 +0000 (GMT)
Subject: main - device id wwid adjustments
Message-ID: <20221010164754.5A19B3858D37@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=380ab3f45c48f016fcebe4105bb94b8f024bae71
Commit:        380ab3f45c48f016fcebe4105bb94b8f024bae71
Parent:        39e6c4f749e97c0efae116e1fa0dbc25451de80e
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Aug 30 15:10:52 2022 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Oct 10 11:47:29 2022 -0500

device id wwid adjustments

Move the functions handling dev wwids.

Add dev flags indicating that wwids have been read from
sysfs wwid file or sysfs vpd_pg83 file.  This can be
used to avoid rereading these.

Improve filter-mpath search for a device's wwid in
/etc/multipath/wwids, to avoid unnecessary rereading
of wwids from sysfs files.

Type 8 wwids from vpd_pg83 with naa or eui names should be
saved as those types.
---
 lib/device/dev-mpath.c | 156 ++++++++----------------------------
 lib/device/device.h    |  39 +++++----
 lib/device/device_id.c | 209 ++++++++++++++++++++++++++++++++++++++-----------
 lib/device/device_id.h |   6 ++
 lib/device/parse_vpd.c |  26 ++++--
 5 files changed, 244 insertions(+), 192 deletions(-)

diff --git a/lib/device/dev-mpath.c b/lib/device/dev-mpath.c
index 2040edac3..3679e4428 100644
--- a/lib/device/dev-mpath.c
+++ b/lib/device/dev-mpath.c
@@ -601,114 +601,12 @@ static int _dev_is_mpath_component_sysfs(struct cmd_context *cmd, struct device
 	return is_mpath_component;
 }
 
-static int _read_sys_wwid(struct cmd_context *cmd, struct device *dev,
-			  char *idbuf, int idbufsize)
-{
-	char idtmp[DEV_WWID_SIZE];
-
-	if (!read_sys_block(cmd, dev, "device/wwid", idbuf, idbufsize)) {
-		/* the wwid file is not under device for nvme devs */
-		if (!read_sys_block(cmd, dev, "wwid", idbuf, idbufsize))
-			return 0;
-	}
-	if (!idbuf[0])
-		return 0;
-
-	/* in t10 id, replace series of spaces with one _ like multipath */
-	if (!strncmp(idbuf, "t10.", 4) && strchr(idbuf, ' ')) {
-		if (idbufsize < DEV_WWID_SIZE)
-			return 0;
-		memcpy(idtmp, idbuf, DEV_WWID_SIZE);
-		memset(idbuf, 0, idbufsize);
-		format_t10_id((const unsigned char *)idtmp, DEV_WWID_SIZE, (unsigned char *)idbuf, idbufsize);
-	}
-	return 1;
-}
-
-#define VPD_SIZE 4096
-
-static int _read_sys_vpd_wwids(struct cmd_context *cmd, struct device *dev,
-			       struct dm_list *ids)
-{
-	unsigned char vpd_data[VPD_SIZE] = { 0 };
-	int vpd_datalen = 0;
-
-	if (!read_sys_block_binary(cmd, dev, "device/vpd_pg83", (char *)vpd_data, VPD_SIZE, &vpd_datalen))
-		return 0;
-	if (!vpd_datalen)
-		return 0;
-
-	/* adds dev_wwid entry to dev->wwids for each id in vpd data */
-	parse_vpd_ids(vpd_data, vpd_datalen, ids);
-	return 1;
-}
-
-void free_wwids(struct dm_list *ids)
-{
-	struct dev_wwid *dw, *safe;
-
-	dm_list_iterate_items_safe(dw, safe, ids) {
-		dm_list_del(&dw->list);
-		free(dw);
-	}
-}
-
-static int _wwid_type_num(char *id)
-{
-	if (!strncmp(id, "naa.", 4))
-		return 3;
-	else if (!strncmp(id, "eui.", 4))
-		return 2;
-	else if (!strncmp(id, "t10.", 4))
-		return 1;
-	else
-		return -1;
-}
-
-/*
- * TODO: if each of the different wwid types (naa/eui/t10) were
- * represented by different DEV_ID_TYPE_FOO values, and used
- * as device_id types, then we could drop struct dev_wwid and
- * drop dev->wwids, and just use dev->ids for each of the
- * different wwids found in vpd_pg83.  This would also require
- * the ability to handle both the original method of replacing
- * every space in the id string with _ and the new/multipath
- * format_t10_id replacing series of spaces with one _.
- */
-struct dev_wwid *add_wwid(char *id, int id_type, struct dm_list *ids)
-{
-	struct dev_wwid *dw;
-	int len;
-
-	if (!id_type) {
-		id_type = _wwid_type_num(id);
-		if (id_type == -1)
-			log_debug("unknown wwid type %s", id);
-	}
-
-	if (!(dw = zalloc(sizeof(struct dev_wwid))))
-		return NULL;
-	len = strlen(id);
-	if (len >= DEV_WWID_SIZE)
-		len = DEV_WWID_SIZE - 1;
-	memcpy(dw->id, id, len);
-	dw->type = id_type;
-	dm_list_add(ids, &dw->list);
-	return dw;
-}
-
-/*
- * we save ids with format: naa.<value>, eui.<value>, t10.<value>.
- * multipath wwids file uses format: 3<value>, 2<value>, 1<value>.
- * The values are saved in wwid_hash_tab without the type prefix.
- */
-
 static int _dev_in_wwid_file(struct cmd_context *cmd, struct device *dev,
 			     int primary_result, dev_t primary_dev)
 {
 	char idbuf[DEV_WWID_SIZE] = { 0 };
 	struct dev_wwid *dw;
-	char *wwid;
+	char *wwid, *full_wwid;
 
 	if (!_wwid_hash_tab)
 		return 0;
@@ -724,42 +622,54 @@ static int _dev_in_wwid_file(struct cmd_context *cmd, struct device *dev,
 	}
 
 	/*
-	 * This function may be called multiple times for the same device, in
-	 * particular if partitioned for each partition.
+	 * sysfs wwid uses format: naa.<value>, eui.<value>, t10.<value>.
+	 * multipath wwids file uses format: 3<value>, 2<value>, 1<value>.
+	 *
+	 * We omit the type prefix before looking up.  The multipath/wwids
+	 * values in the wwid_hash_tab have the initial character removed.
+	 *
+	 * There's no type prefix for "scsi name string" type 8 ids.
+	 *
+	 * First try looking up any wwids that have already been read.
 	 */
-	if (!dm_list_empty(&dev->wwids))
-		goto lookup;
+lookup:
+	dm_list_iterate_items(dw, &dev->wwids) {
+		if (dw->type == 1 || dw->type == 2 || dw->type == 3)
+			wwid = &dw->id[4];
+		else
+			wwid = dw->id;
 
-	/*
-	 * Get all the ids for the device from vpd_pg83 and check if any of
-	 * those are in /etc/multipath/wwids.  These ids should include the
-	 * value printed from the sysfs wwid file.
-	 */
-	_read_sys_vpd_wwids(cmd, dev, &dev->wwids);
-	if (!dm_list_empty(&dev->wwids))
-		goto lookup;
+		if (dm_hash_lookup_binary(_wwid_hash_tab, wwid, strlen(wwid))) {
+			full_wwid = dw->id;
+			goto found;
+		}
+	}
 
 	/*
-	 * This will read the sysfs wwid file, nvme devices in particular have
-	 * a wwid file but not a vpd_pg83 file.
+	 * The id from sysfs wwid may not be the id used by multipath,
+	 * or a device may not have a vpd_pg83 file (e.g. nvme).
 	 */
-	if (_read_sys_wwid(cmd, dev, idbuf, sizeof(idbuf)))
-		add_wwid(idbuf, 0, &dev->wwids);
 
- lookup:
-	dm_list_iterate_items(dw, &dev->wwids) {
+	if (!(dev->flags & DEV_ADDED_VPD_WWIDS) && dev_read_vpd_wwids(cmd, dev))
+		goto lookup;
+
+	if (!(dev->flags & DEV_ADDED_SYS_WWID) && dev_read_sys_wwid(cmd, dev, idbuf, sizeof(idbuf), &dw)) {
 		if (dw->type == 1 || dw->type == 2 || dw->type == 3)
 			wwid = &dw->id[4];
 		else
 			wwid = dw->id;
 
 		if (dm_hash_lookup_binary(_wwid_hash_tab, wwid, strlen(wwid))) {
-			log_debug_devs("dev_is_mpath_component %s %s in wwids file", dev_name(dev), dw->id);
-			return 1;
+			full_wwid = dw->id;
+			goto found;
 		}
 	}
 
 	return 0;
+
+ found:
+	log_debug_devs("dev_is_mpath_component %s %s in wwids file", dev_name(dev), full_wwid);
+	return 1;
 }
 
 int dev_is_mpath_component(struct cmd_context *cmd, struct device *dev, dev_t *holder_devno)
diff --git a/lib/device/device.h b/lib/device/device.h
index 06440f44b..89173a840 100644
--- a/lib/device/device.h
+++ b/lib/device/device.h
@@ -32,8 +32,8 @@
 #define DEV_NOT_O_NOATIME	0x00000400	/* Don't use O_NOATIME */
 #define DEV_IN_BCACHE		0x00000800      /* dev fd is open and used in bcache */
 #define DEV_BCACHE_EXCL		0x00001000      /* bcache_fd should be open EXCL */
-/* unused                       0x00002000      */
-/* unused			0x00004000	*/
+#define DEV_ADDED_SYS_WWID	0x00002000      /* wwid has been added from sysfs wwid file */
+#define DEV_ADDED_VPD_WWIDS	0x00004000	/* wwids have been added from vpd_pg83 */
 #define DEV_BCACHE_WRITE	0x00008000      /* bcache_fd is open with RDWR */
 #define DEV_SCAN_FOUND_LABEL	0x00010000      /* label scan read dev and found label */
 #define DEV_IS_MD_COMPONENT	0x00020000	/* device is an md component */
@@ -59,23 +59,30 @@ struct dev_ext {
 	void *handle;
 };
 
+#define DEV_ID_TYPE_SYS_WWID   1
+#define DEV_ID_TYPE_SYS_SERIAL 2
+#define DEV_ID_TYPE_MPATH_UUID 3
+#define DEV_ID_TYPE_MD_UUID    4
+#define DEV_ID_TYPE_LOOP_FILE  5
+#define DEV_ID_TYPE_CRYPT_UUID 6
+#define DEV_ID_TYPE_LVMLV_UUID 7
+#define DEV_ID_TYPE_DEVNAME    8
+
 #define DEV_WWID_SIZE 128
 
+/*
+ * A wwid read from:
+ * /sys/dev/block/%d:%d/device/wwid
+ * /sys/dev/block/%d:%d/wwid
+ * /sys/dev/block/%d:%d/device/vpd_pg83
+ */
+
 struct dev_wwid {
-	struct dm_list list;
-	int type;
-	char id[DEV_WWID_SIZE];
+	struct dm_list list;     /* dev->wwids */
+	int type;                /* 1,2,3 for NAA,EUI,T10 */
+	char id[DEV_WWID_SIZE];  /* includes prefix naa.,eui.,t10. */
 };
 
-#define DEV_ID_TYPE_SYS_WWID   0x0001
-#define DEV_ID_TYPE_SYS_SERIAL 0x0002
-#define DEV_ID_TYPE_MPATH_UUID 0x0003
-#define DEV_ID_TYPE_MD_UUID    0x0004
-#define DEV_ID_TYPE_LOOP_FILE  0x0005
-#define DEV_ID_TYPE_CRYPT_UUID 0x0006
-#define DEV_ID_TYPE_LVMLV_UUID 0x0007
-#define DEV_ID_TYPE_DEVNAME    0x0008
-
 /*
  * A device ID of a certain type for a device.
  * A struct device may have multiple dev_id structs on dev->ids.
@@ -83,7 +90,7 @@ struct dev_wwid {
  */
 
 struct dev_id {
-	struct dm_list list;
+	struct dm_list list;    /* dev->ids */
 	struct device *dev;
 	uint16_t idtype;	/* DEV_ID_TYPE_ */
 	char *idname;		/* id string determined by idtype */
@@ -215,8 +222,6 @@ void dev_destroy_file(struct device *dev);
 
 int dev_mpath_init(const char *config_wwids_file);
 void dev_mpath_exit(void);
-struct dev_wwid *add_wwid(char *id, int id_type, struct dm_list *ids);
-void free_wwids(struct dm_list *ids);
 int parse_vpd_ids(const unsigned char *vpd_data, int vpd_datalen, struct dm_list *ids);
 int format_t10_id(const unsigned char *in, int in_bytes, unsigned char *out, int out_bytes);
 
diff --git a/lib/device/device_id.c b/lib/device/device_id.c
index a0a626533..3dd428df8 100644
--- a/lib/device/device_id.c
+++ b/lib/device/device_id.c
@@ -168,7 +168,8 @@ void free_dus(struct dm_list *dus)
 
 void free_did(struct dev_id *id)
 {
-	free(id->idname);
+	if (strlen(id->idname))
+		free(id->idname); /* idname = "" when id type doesn't exist */
 	free(id);
 }
 
@@ -321,6 +322,106 @@ static int _dev_has_lvmlv_uuid(struct cmd_context *cmd, struct device *dev, cons
 	return 1;
 }
 
+/*
+ * The numbers 1,2,3 for NAA,EUI,T10 are part of the standard
+ * and are used in the vpd data.
+ */
+static int _wwid_type_num(char *id)
+{
+	if (!strncmp(id, "naa.", 4))
+		return 3;
+	else if (!strncmp(id, "eui.", 4))
+		return 2;
+	else if (!strncmp(id, "t10.", 4))
+		return 1;
+	else
+		return -1;
+}
+
+void free_wwids(struct dm_list *ids)
+{
+	struct dev_wwid *dw, *safe;
+
+	dm_list_iterate_items_safe(dw, safe, ids) {
+		dm_list_del(&dw->list);
+		free(dw);
+	}
+}
+
+/*
+ * wwid type 8 "scsi name string" (which includes "iqn" names) is
+ * included in vpd_pg83, but we currently do not use these for
+ * device ids (maybe in the future.)
+ * They can still be checked by dev-mpath when looking for a device
+ * in /etc/multipath/wwids.
+ */
+
+struct dev_wwid *dev_add_wwid(char *id, int id_type, struct dm_list *ids)
+{
+	struct dev_wwid *dw;
+	int len;
+
+	if (!id_type) {
+		id_type = _wwid_type_num(id);
+		if (id_type == -1)
+			log_debug("unknown wwid type %s", id);
+	}
+
+	if (!(dw = zalloc(sizeof(struct dev_wwid))))
+		return NULL;
+	len = strlen(id);
+	if (len >= DEV_WWID_SIZE)
+		len = DEV_WWID_SIZE - 1;
+	memcpy(dw->id, id, len);
+	dw->type = id_type;
+	dm_list_add(ids, &dw->list);
+	return dw;
+}
+
+#define VPD_SIZE 4096
+
+int dev_read_vpd_wwids(struct cmd_context *cmd, struct device *dev)
+{
+	unsigned char vpd_data[VPD_SIZE] = { 0 };
+	int vpd_datalen = 0;
+
+	dev->flags |= DEV_ADDED_VPD_WWIDS;
+
+	if (!read_sys_block_binary(cmd, dev, "device/vpd_pg83", (char *)vpd_data, VPD_SIZE, &vpd_datalen))
+		return 0;
+	if (!vpd_datalen)
+		return 0;
+
+	/* adds dev_wwid entry to dev->wwids for each id in vpd data */
+	parse_vpd_ids(vpd_data, vpd_datalen, &dev->wwids);
+	return 1;
+}
+
+int dev_read_sys_wwid(struct cmd_context *cmd, struct device *dev,
+		      char *buf, int bufsize, struct dev_wwid **dw_out)
+{
+	struct dev_wwid *dw;
+	int ret;
+
+	dev->flags |= DEV_ADDED_SYS_WWID;
+
+	ret = read_sys_block(cmd, dev, "device/wwid", buf, bufsize);
+	if (!ret || !buf[0]) {
+		/* the wwid file is not under device for nvme devs */
+		ret = read_sys_block(cmd, dev, "wwid", buf, bufsize);
+	}
+	if (!ret || !buf[0])
+		return 0;
+
+	/* Note, if wwids are also read from vpd, this same wwid will be added again. */
+
+	if (!(dw = dev_add_wwid(buf, 0, &dev->wwids)))
+		return_0;
+	if (dw_out)
+		*dw_out = dw;
+	return 1;
+}
+
 const char *device_id_system_read(struct cmd_context *cmd, struct device *dev, uint16_t idtype)
 {
 	char sysbuf[PATH_MAX] = { 0 };
@@ -328,10 +429,9 @@ const char *device_id_system_read(struct cmd_context *cmd, struct device *dev, u
 	int i;
 
 	if (idtype == DEV_ID_TYPE_SYS_WWID) {
-		read_sys_block(cmd, dev, "device/wwid", sysbuf, sizeof(sysbuf));
+		dev_read_sys_wwid(cmd, dev, sysbuf, sizeof(sysbuf), NULL);
 
-		if (!sysbuf[0])
-			read_sys_block(cmd, dev, "wwid", sysbuf, sizeof(sysbuf));
+		/* FIXME: enable these QEMU t10 wwids */
 
 		/* qemu wwid begins "t10.ATA     QEMU HARDDISK ..." */
 		if (strstr(sysbuf, "QEMU HARDDISK"))
@@ -450,6 +550,11 @@ static int _dev_has_stable_id(struct cmd_context *cmd, struct device *dev)
 	    read_sys_block(cmd, dev, "md/uuid", sysbuf, sizeof(sysbuf)))
 		return 1;
 
+	if (!(dev->flags & DEV_ADDED_VPD_WWIDS))
+		dev_read_vpd_wwids(cmd, dev);
+	if (!dm_list_empty(&dev->wwids))
+		return 1;
+
  out:
 	/* DEV_ID_TYPE_DEVNAME would be used for this dev. */
 	return 0;
@@ -1012,14 +1117,18 @@ int device_id_add(struct cmd_context *cmd, struct device *dev, const char *pvid_
 
 	/*
 	 * Choose the device_id type for the device being added.
-	 *
-	 * 0. use an idtype specified by the user
-	 * 1. use an idtype specific to a special/virtual device type
-	 *    e.g. loop, mpath, crypt, lvmlv, md, etc.
-	 * 2. use an idtype specified by user option.
-	 * 3. use sys_wwid, if it exists.
-	 * 4. use sys_serial, if it exists.
-	 * 5. use devname as the last resort.
+	 * possible breakage:
+	 * . if the kernel changes what it prints from sys/wwid (e.g. from
+	 *   the t10 value to the naa value for the dev), this would break
+	 *   matching du to dev unless lvm tries to match all of the dev's
+	 *   different wwids from vpd_pg83 against sys_wwid entries.
+	 * . adding a new device_id type into the devices file breaks prior
+	 *   lvm versions that attempt to use the devices file from the new
+	 *   lvm version.
+	 * . using a value for sys_wwid that comes from vpd_pg83 and not
+	 *   sys/wwid (e.g. taking a naa wwid from vpd_pg83 when sys/wwid
+	 *   is printing the t10 wwid) would break prior lvm versions that
+	 *   only match a du against the sys/wwid values.
 	 */
 
 	if (idtype_arg) {
@@ -1060,36 +1169,44 @@ int device_id_add(struct cmd_context *cmd, struct device *dev, const char *pvid_
 	/* TODO: kpartx partitions on loop devs. */
 	if (MAJOR(dev->dev) == cmd->dev_types->loop_major) {
 		idtype = DEV_ID_TYPE_LOOP_FILE;
-		goto id_name;
+		if ((idname = device_id_system_read(cmd, dev, idtype)))
+			goto id_done;
+		goto id_last;
 	}
 
 	if (MAJOR(dev->dev) == cmd->dev_types->md_major) {
 		idtype = DEV_ID_TYPE_MD_UUID;
-		goto id_name;
+		if ((idname = device_id_system_read(cmd, dev, idtype)))
+			goto id_done;
+		goto id_last;
 	}
 
 	if (MAJOR(dev->dev) == cmd->dev_types->drbd_major) {
 		/* TODO */
 		log_warn("Missing support for DRBD idtype");
+		goto id_last;
 	}
 
 	/*
 	 * No device-specific, existing, or user-specified idtypes,
 	 * so use first available of sys_wwid / sys_serial / devname.
 	 */
+
 	idtype = DEV_ID_TYPE_SYS_WWID;
+	if ((idname = device_id_system_read(cmd, dev, idtype)))
+		goto id_done;
 
-id_name:
-	if (!(idname = device_id_system_read(cmd, dev, idtype))) {
-		if (idtype == DEV_ID_TYPE_SYS_WWID) {
-			idtype = DEV_ID_TYPE_SYS_SERIAL;
-			goto id_name;
-		}
-		idtype = DEV_ID_TYPE_DEVNAME;
-		goto id_name;
-	}
+	idtype = DEV_ID_TYPE_SYS_SERIAL;
+	if ((idname = device_id_system_read(cmd, dev, idtype)))
+		goto id_done;
+id_last:
+	idtype = DEV_ID_TYPE_DEVNAME;
+	if ((idname = device_id_system_read(cmd, dev, idtype)))
+		goto id_done;
 
 id_done:
+	if (!idname)
+		return_0;
 
 	/*
 	 * Create a dev_id struct for the new idtype on dev->ids.
@@ -1101,7 +1218,9 @@ id_done:
 		}
 	}
 
-	if (found_id && idname && strcmp(id->idname, idname)) {
+	if (found_id && idname && (!id->idname || strcmp(id->idname, idname))) {
+		log_debug("Replacing device id %s old %s new %s",
+			  idtype_to_str(id->idtype), id->idname ?: ".", idname);
 		dm_list_del(&id->list);
 		free_did(id);
 		found_id = 0;
@@ -1433,8 +1552,13 @@ static int _match_dm_devnames(struct cmd_context *cmd, struct device *dev,
 }
 
 /*
- * check for dev->ids entry with du->idtype, if found compare it,
- * if not, system_read of this type and add entry to dev->ids, compare it.
+ * du is a devices file entry.  dev is any device on the system.
+ * check if du is for dev by comparing the device's ids to du->idname.
+ *
+ * check for a dev->ids entry with du->idtype, if found compare it,
+ * if not, system_read idtype for the dev, add entry to dev->ids,
+ * compare it to du to check if it matches.
+ *
  * When a match is found, set up links among du/id/dev.
  */
 
@@ -1489,6 +1613,10 @@ static int _match_du_to_dev(struct cmd_context *cmd, struct dev_use *du, struct
 		return 0;
 	}
 
+	/*
+	 * Try to match du with ids that have already been read for the dev
+	 * (and saved on dev->ids to avoid rereading.)
+	 */
 	dm_list_iterate_items(id, &dev->ids) {
 		if (id->idtype == du->idtype) {
 			if ((id->idtype == DEV_ID_TYPE_DEVNAME) && _match_dm_devnames(cmd, dev, id, du)) {
@@ -1521,32 +1649,20 @@ static int _match_du_to_dev(struct cmd_context *cmd, struct dev_use *du, struct
 	if (!(id = zalloc(sizeof(struct dev_id))))
 		return_0;
 
-	if (!(idname = device_id_system_read(cmd, dev, du->idtype))) {
-		/*
-		 * Save a new id in dev->ids for this type to indicate no match
-		 * to avoid repeated system_read, since this called many times.
-		 * Setting idtype and NULL idname means no id of this type.
-		 */
-		id->idtype = du->idtype;
-		id->dev = dev;
-		dm_list_add(&dev->ids, &id->list);
-		/*
-		log_debug("Mismatch device_id %s %s to %s: no idtype",
-			  idtype_to_str(du->idtype), du->idname ?: ".", dev_name(dev));
-		*/
-		return 0;
-	}
+	idname = device_id_system_read(cmd, dev, du->idtype);
 
 	/*
-	 * Save this id for the device (so it can be quickly checked again), even
-	 * if it's not the idtype used to identify the dev in device_id_file.
+	 * Save this id for the dev, even if it doesn't exist (NULL)
+	 * or doesn't match du.  This avoids system_read of this idtype
+	 * repeatedly, and the saved id will be found in the loop
+	 * over dev->ids above.
 	 */
 	id->idtype = du->idtype;
-	id->idname = (char *)idname;
+	id->idname = (char *)idname ?: (char *)"";
 	id->dev = dev;
 	dm_list_add(&dev->ids, &id->list);
 
-	if (!strcmp(idname, du->idname)) {
+	if (idname && !strcmp(idname, du->idname)) {
 		du->dev = dev;
 		dev->id = id;
 		dev->flags |= DEV_MATCHED_USE_ID;
@@ -1557,8 +1673,9 @@ static int _match_du_to_dev(struct cmd_context *cmd, struct dev_use *du, struct
 
 	/*
 	log_debug("Mismatch device_id %s %s to %s: idname %s",
-		  idtype_to_str(du->idtype), du->idname ?: ".", dev_name(dev), idname);
+		  idtype_to_str(du->idtype), du->idname ?: ".", dev_name(dev), idname ?: ".");
 	*/
+
 	return 0;
 }
 
diff --git a/lib/device/device_id.h b/lib/device/device_id.h
index 9b9c9ce03..46ab33784 100644
--- a/lib/device/device_id.h
+++ b/lib/device/device_id.h
@@ -63,4 +63,10 @@ int read_sys_block_binary(struct cmd_context *cmd, struct device *dev,
 
 int dev_has_mpath_uuid(struct cmd_context *cmd, struct device *dev, const char **idname_out);
 
+void free_wwids(struct dm_list *ids);
+struct dev_wwid *dev_add_wwid(char *id, int id_type, struct dm_list *ids);
+int dev_read_vpd_wwids(struct cmd_context *cmd, struct device *dev);
+int dev_read_sys_wwid(struct cmd_context *cmd, struct device *dev,
+		      char *buf, int bufsize, struct dev_wwid **dw_out);
+
 #endif
diff --git a/lib/device/parse_vpd.c b/lib/device/parse_vpd.c
index 4bafa7b9e..99e8c0ec2 100644
--- a/lib/device/parse_vpd.c
+++ b/lib/device/parse_vpd.c
@@ -14,7 +14,9 @@
 
 #include "base/memory/zalloc.h"
 #include "lib/misc/lib.h"
+#include "lib/commands/toolcontext.h"
 #include "lib/device/device.h"
+#include "lib/device/device_id.h"
 
 #include <stdio.h>
 #include <unistd.h>
@@ -98,6 +100,7 @@ int parse_vpd_ids(const unsigned char *vpd_data, int vpd_datalen, struct dm_list
 	const unsigned char *d, *cur_id_str;
 	size_t id_len = ID_BUFSIZE;
 	int id_size = -1;
+	int type;
 	uint8_t cur_id_size = 0;
 
 	memset(id, 0, ID_BUFSIZE);
@@ -119,7 +122,7 @@ int parse_vpd_ids(const unsigned char *vpd_data, int vpd_datalen, struct dm_list
 				break;
 			if (id_size >= ID_BUFSIZE)
 				id_size = ID_BUFSIZE - 1;
-			add_wwid(id, 1, ids);
+			dev_add_wwid(id, 1, ids);
 			break;
 		case 0x2:
 			/* EUI-64 */
@@ -145,7 +148,7 @@ int parse_vpd_ids(const unsigned char *vpd_data, int vpd_datalen, struct dm_list
 				break;
 			if (id_size >= ID_BUFSIZE)
 				id_size = ID_BUFSIZE - 1;
-			add_wwid(id, 2, ids);
+			dev_add_wwid(id, 2, ids);
 			break;
 		case 0x3:
 			/* NAA */
@@ -167,7 +170,7 @@ int parse_vpd_ids(const unsigned char *vpd_data, int vpd_datalen, struct dm_list
 				break;
 			if (id_size >= ID_BUFSIZE)
 				id_size = ID_BUFSIZE - 1;
-			add_wwid(id, 3, ids);
+			dev_add_wwid(id, 3, ids);
 			break;
 		case 0x8:
 			/* SCSI name string */
@@ -178,17 +181,28 @@ int parse_vpd_ids(const unsigned char *vpd_data, int vpd_datalen, struct dm_list
 			memcpy(id, cur_id_str, cur_id_size);
 			id_size = cur_id_size;
 
+			/*
+			 * if naa or eui ids are provided as scsi names,
+			 * consider them to be naa/eui types.
+			 */
+			if (!memcmp(id, "eui.", 4))
+				type = 2;
+			else if (!memcmp(id, "naa.", 4))
+				type = 3;
+			else
+				type = 8;
+
 			/*
 			 * Not in the kernel version, copying multipath code,
 			 * which checks if this string begins with naa or eui
 			 * and if so does tolower() on the chars.
 			 */
-			if (!strncmp(id, "naa.", 4) || !strncmp(id, "eui.", 4)) {
+			if ((type == 2) || (type == 3)) {
 				int i;
-				for (i = 0; i < id_size; i++)
+				for (i = 0; i < strlen(id); i++)
 					id[i] = tolower(id[i]);
 			}
-			add_wwid(id, 8, ids);
+			dev_add_wwid(id, type, ids);
 			break;
 		default:
 			break;

