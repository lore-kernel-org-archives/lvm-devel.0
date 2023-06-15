From: David Teigland <teigland@sourceware.org>
Date: Thu, 15 Jun 2023 20:17:32 +0000 (GMT)
Subject: main - device_id: ignore leading and trailing spaces for sys_wwid and sys_serial
Message-ID: <20230615201732.5A299385771A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=228a8e8c1fd8e82a2e31a6060614dc3dd2f8bc51
Commit:        228a8e8c1fd8e82a2e31a6060614dc3dd2f8bc51
Parent:        f0b48a23d9d8b5d858be1772ea5c9083d235b3b3
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Jun 15 13:58:48 2023 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Jun 15 15:17:14 2023 -0500

device_id: ignore leading and trailing spaces for sys_wwid and sys_serial

Leading and trailing underscores are also ignored to handle device ids
written by previous versions which replaced all spaces with underscores.
---
 lib/device/device.h               |   1 +
 lib/device/device_id.c            | 280 ++++++++++++++++++++++++--------------
 lib/device/parse_vpd.c            |  50 +++++++
 test/shell/devicesfile-vpd-ids.sh | 101 ++++++++++++--
 4 files changed, 313 insertions(+), 119 deletions(-)

diff --git a/lib/device/device.h b/lib/device/device.h
index 446104218..84d87232b 100644
--- a/lib/device/device.h
+++ b/lib/device/device.h
@@ -239,6 +239,7 @@ int dev_mpath_init(const char *config_wwids_file);
 void dev_mpath_exit(void);
 int parse_vpd_ids(const unsigned char *vpd_data, int vpd_datalen, struct dm_list *ids);
 int format_t10_id(const unsigned char *in, int in_bytes, unsigned char *out, int out_bytes);
+int format_general_id(const char *in, int in_bytes, unsigned char *out, int out_bytes);
 int parse_vpd_serial(const unsigned char *in, char *out, int outsize);
 
 /* dev_util */
diff --git a/lib/device/device_id.c b/lib/device/device_id.c
index 9a8716500..87fcf32ba 100644
--- a/lib/device/device_id.c
+++ b/lib/device/device_id.c
@@ -185,6 +185,71 @@ void free_dids(struct dm_list *ids)
 	}
 }
 
+/* More than one _ in a row is replaced with one _ */
+static void _reduce_repeating_underscores(char *buf, int bufsize)
+{
+	char *tmpbuf;
+	int us = 0, i, j = 0;
+
+	if (!(tmpbuf = strndup(buf, bufsize-1)))
+		return;
+
+	memset(buf, 0, bufsize);
+
+	for (i = 0; i < strlen(tmpbuf); i++) {
+		if (tmpbuf[i] == '_')
+			us++;
+		else
+			us = 0;
+
+		if (us == 1)
+			buf[j++] = '_';
+		else if (us > 1)
+			continue;
+		else
+			buf[j++] = tmpbuf[i];
+
+		if (j == bufsize)
+			break;
+	}
+	buf[bufsize-1] = '\0';
+	free(tmpbuf);
+}
+
+static void _remove_leading_underscores(char *buf, int bufsize)
+{
+	char *tmpbuf;
+	int i, j = 0;
+
+	if (buf[0] != '_')
+		return;
+
+	if (!(tmpbuf = strndup(buf, bufsize-1)))
+		return;
+
+	memset(buf, 0, bufsize);
+
+	for (i = 0; i < strlen(tmpbuf); i++) {
+		if (!j && tmpbuf[i] == '_')
+			continue;
+		buf[j++] = tmpbuf[i];
+
+		if (j == bufsize)
+			break;
+	}
+	free(tmpbuf);
+}
+
+static void _remove_trailing_underscores(char *buf, int bufsize)
+{
+	char *end;
+
+	end = buf + strlen(buf) - 1;
+	while ((end > buf) && (*end == '_'))
+		end--;
+	end[1] = '\0';
+}
+
 static int _read_sys_block(struct cmd_context *cmd, struct device *dev,
 			   const char *suffix, char *sysbuf, int sysbufsize,
 			   int binary, int *retlen)
@@ -406,7 +471,7 @@ struct dev_wwid *dev_add_wwid(char *id, int id_type, struct dm_list *ids)
 
 int dev_read_vpd_wwids(struct cmd_context *cmd, struct device *dev)
 {
-	unsigned char vpd_data[VPD_SIZE] = { 0 };
+	char vpd_data[VPD_SIZE] = { 0 };
 	int vpd_datalen = 0;
 
 	dev->flags |= DEV_ADDED_VPD_WWIDS;
@@ -417,36 +482,47 @@ int dev_read_vpd_wwids(struct cmd_context *cmd, struct device *dev)
 		return 0;
 
 	/* adds dev_wwid entry to dev->wwids for each id in vpd data */
-	parse_vpd_ids(vpd_data, vpd_datalen, &dev->wwids);
+	parse_vpd_ids((const unsigned char *)vpd_data, vpd_datalen, &dev->wwids);
 	return 1;
 }
 
 int dev_read_sys_wwid(struct cmd_context *cmd, struct device *dev,
-		      char *buf, int bufsize, struct dev_wwid **dw_out)
+		      char *outbuf, int outbufsize, struct dev_wwid **dw_out)
 {
-	char tmpbuf[DEV_WWID_SIZE];
+	char buf[DEV_WWID_SIZE] = { 0 };
 	struct dev_wwid *dw;
-	int ret;
+	int is_t10 = 0;
+	int i, ret;
 
 	dev->flags |= DEV_ADDED_SYS_WWID;
 
-	ret = read_sys_block(cmd, dev, "device/wwid", buf, bufsize);
+	ret = read_sys_block(cmd, dev, "device/wwid", buf, sizeof(buf));
 	if (!ret || !buf[0]) {
 		/* the wwid file is not under device for nvme devs */
-		ret = read_sys_block(cmd, dev, "wwid", buf, bufsize);
+		ret = read_sys_block(cmd, dev, "wwid", buf, sizeof(buf));
 	}
 	if (!ret || !buf[0])
 		return 0;
 
-	/* in t10 id, replace characters like space and quote */
-	if (!strncmp(buf, "t10.", 4)) {
-		if (bufsize < DEV_WWID_SIZE)
-			return 0;
-		memcpy(tmpbuf, buf, DEV_WWID_SIZE);
-		memset(buf, 0, bufsize);
-		format_t10_id((const unsigned char *)tmpbuf, DEV_WWID_SIZE, (unsigned char *)buf, bufsize);
+	for (i = 0; i < sizeof(buf) - 4; i++) {
+		if (buf[i] == ' ')
+			continue;
+		if (!strncmp(&buf[i], "t10", 3))
+			is_t10 = 1;
+		break;
 	}
 
+	/*
+	 * Remove leading and trailing spaces.
+	 * Replace internal spaces with underscores.
+	 * t10 wwids have multiple sequential spaces
+	 * replaced by a single underscore.
+	 */
+	if (is_t10)
+		format_t10_id((const unsigned char *)buf, sizeof(buf), (unsigned char *)outbuf, outbufsize);
+	else
+		format_general_id((const char *)buf, sizeof(buf), (unsigned char *)outbuf, outbufsize);
+
 	/* Note, if wwids are also read from vpd, this same wwid will be added again. */
 
 	if (!(dw = dev_add_wwid(buf, 0, &dev->wwids)))
@@ -457,9 +533,9 @@ int dev_read_sys_wwid(struct cmd_context *cmd, struct device *dev,
 }
 
 static int _dev_read_sys_serial(struct cmd_context *cmd, struct device *dev,
-				char *buf, int bufsize)
+				char *outbuf, int outbufsize)
 {
-	unsigned char vpd_data[VPD_SIZE] = { 0 };
+	char buf[VPD_SIZE] = { 0 };
 	const char *devname;
 	int vpd_datalen = 0;
 
@@ -471,13 +547,16 @@ static int _dev_read_sys_serial(struct cmd_context *cmd, struct device *dev,
 	 * (Only virtio disks /dev/vdx are known to use /sys/class/block/vdx/serial.)
 	 */
 
-	read_sys_block(cmd, dev, "device/serial", buf, bufsize);
-	if (buf[0])
-		return 1;
+	read_sys_block(cmd, dev, "device/serial", buf, sizeof(buf));
+	if (buf[0]) {
+		format_general_id((const char *)buf, sizeof(buf), (unsigned char *)outbuf, outbufsize);
+		if (outbuf[0])
+			return 1;
+	}
 
-	if (read_sys_block_binary(cmd, dev, "device/vpd_pg80", (char *)vpd_data, VPD_SIZE, &vpd_datalen) && vpd_datalen) {
-		parse_vpd_serial(vpd_data, buf, bufsize);
-		if (buf[0])
+	if (read_sys_block_binary(cmd, dev, "device/vpd_pg80", buf, VPD_SIZE, &vpd_datalen) && vpd_datalen) {
+		parse_vpd_serial((const unsigned char *)buf, outbuf, outbufsize);
+		if (outbuf[0])
 			return 1;
 	}
 	
@@ -505,12 +584,13 @@ static int _dev_read_sys_serial(struct cmd_context *cmd, struct device *dev,
 		if (dm_snprintf(path, sizeof(path), "%s/class/block/%s/serial", sysfs_dir, vdx) < 0)
 			return 0;
 
-		ret = get_sysfs_value(path, buf, bufsize, 0);
+		ret = get_sysfs_value(path, buf, sizeof(buf), 0);
 		if (ret && !buf[0])
 			ret = 0;
 		if (ret) {
-			buf[bufsize - 1] = '\0';
-			return 1;
+			format_general_id((const char *)buf, sizeof(buf), (unsigned char *)outbuf, outbufsize);
+			if (buf[0])
+				return 1;
 		}
 	}
 
@@ -520,6 +600,7 @@ static int _dev_read_sys_serial(struct cmd_context *cmd, struct device *dev,
 const char *device_id_system_read(struct cmd_context *cmd, struct device *dev, uint16_t idtype)
 {
 	char sysbuf[PATH_MAX] = { 0 };
+	char sysbuf2[PATH_MAX] = { 0 };
 	const char *idname = NULL;
 	struct dev_wwid *dw;
 	int i;
@@ -584,16 +665,45 @@ const char *device_id_system_read(struct cmd_context *cmd, struct device *dev, u
 		return NULL;
 	}
 
-	/* wwids are already munged if needed */
-	if (idtype != DEV_ID_TYPE_SYS_WWID) {
+	/*
+	 * Replace all spaces, quotes, control chars with underscores.
+	 * sys_wwid, sys_serial, and wwid_* have already been handled,
+	 * and with slightly different replacement (see format_t10_id,
+	 * format_general_id.)
+	 */
+	if ((idtype != DEV_ID_TYPE_SYS_WWID) &&
+	    (idtype != DEV_ID_TYPE_SYS_SERIAL) &&
+	    (idtype != DEV_ID_TYPE_WWID_NAA) &&
+	    (idtype != DEV_ID_TYPE_WWID_EUI) &&
+	    (idtype != DEV_ID_TYPE_WWID_T10)) {
 		for (i = 0; i < strlen(sysbuf); i++) {
-			if (sysbuf[i] == '"')
-				continue;
-			if (isblank(sysbuf[i]) || isspace(sysbuf[i]) || iscntrl(sysbuf[i]))
+			if ((sysbuf[i] == '"') ||
+			    isblank(sysbuf[i]) ||
+			    isspace(sysbuf[i]) ||
+			    iscntrl(sysbuf[i]))
 				sysbuf[i] = '_';
 		}
 	}
 
+	/*
+	 * Reduce actual leading and trailing underscores for sys_wwid
+	 * and sys_serial, since underscores were previously used as
+	 * replacements for leading/trailing spaces which are now ignored.
+	 * Also reduce any actual repeated underscores in t10 wwid since
+	 * multiple repeated spaces were also once replaced by underscores.
+	 */
+	if ((idtype == DEV_ID_TYPE_SYS_WWID) ||
+	    (idtype == DEV_ID_TYPE_SYS_SERIAL)) {
+		memcpy(sysbuf2, sysbuf, sizeof(sysbuf2));
+		_remove_leading_underscores(sysbuf2, sizeof(sysbuf2));
+		_remove_trailing_underscores(sysbuf2, sizeof(sysbuf2));
+		if (idtype == DEV_ID_TYPE_SYS_WWID && !strncmp(sysbuf2, "t10", 3) && strstr(sysbuf2, "__"))
+			_reduce_repeating_underscores(sysbuf2, sizeof(sysbuf2));
+		if (memcmp(sysbuf, sysbuf2, sizeof(sysbuf)))
+			log_debug("device_id_system_read reduced underscores %s to %s", sysbuf, sysbuf2);
+		memcpy(sysbuf, sysbuf2, sizeof(sysbuf));
+	}
+
 	if (!sysbuf[0])
 		goto bad;
 
@@ -1728,40 +1838,6 @@ static int _match_dm_devnames(struct cmd_context *cmd, struct device *dev,
 	return 0;
 }
 
-/* More than one _ in a row is replaced with one _ */
-static void _reduce_repeating_underscores(char *in, int in_len, char *out, int out_size)
-{
-	int us = 0, i, j = 0;
-
-	for (i = 0; i < in_len; i++) {
-		if (in[i] == '_')
-			us++;
-		else
-			us = 0;
-
-		if (us == 1)
-			out[j++] = '_';
-		else if (us > 1)
-			continue;
-		else
-			out[j++] = in[i];
-
-		if (j == out_size)
-			break;
-	}
-}
-
-/* Remove any _ at the end of the string. */
-static void _remove_trailing_underscores(char *buf)
-{
-	char *end;
-
-	end = buf + strlen(buf) - 1;
-	while ((end > buf) && (*end == '_'))
-		end--;
-	end[1] = '\0';
-}
-
 /*
  * du is a devices file entry.  dev is any device on the system.
  * check if du is for dev by comparing the device's ids to du->idname.
@@ -1775,8 +1851,7 @@ static void _remove_trailing_underscores(char *buf)
 
 static int _match_du_to_dev(struct cmd_context *cmd, struct dev_use *du, struct device *dev)
 {
-	char du_t10[DEV_WWID_SIZE] = { 0 };
-	char id_t10[DEV_WWID_SIZE];
+	char du_idname[PATH_MAX];
 	struct dev_id *id;
 	const char *idname;
 	int part;
@@ -1827,20 +1902,30 @@ static int _match_du_to_dev(struct cmd_context *cmd, struct dev_use *du, struct
 	}
 
 	/*
-	 * Devices file entries with IDTYPE=sys_wwid and a T10 WWID
-	 * for IDNAME were saved in the past with each space replaced
-	 * by one _.  Now we convert multiple spaces to a single _.
-	 * So, convert a df entry with the old style to the new shorter
-	 * style to compare.  Also, in past versions, trailing spaces
-	 * in the wwid would be replaced by _, but now trailing spaces
-	 * are ignored.  This means devices file entries created by
-	 * past versions may have _ at the end of the IDNAME string.
-	 * So, exclude trailing underscores when comparing a t10 wwid
-	 * from a device with a t10 wwid in the devices file.
+	 * sys_wwid and sys_serial were saved in the past with leading and
+	 * trailing spaces replaced with underscores, and t10 wwids also had
+	 * repeated internal spaces replaced with one underscore each.  Now we
+	 * ignore leading and trailing spaces and replace multiple repeated
+	 * spaces with one underscore in t10 wwids.  In order to handle
+	 * system.devices entries created by older versions, modify the IDNAME
+	 * value that's read (du->idname) to remove leading and trailing
+	 * underscores, and reduce repeated underscores to one in t10 wwids.
+	 *
+	 * Example: wwid is reported as "  t10.123  456  " (without quotes)
+	 * Previous versions would save this in system.devices as: __t10.123__456__
+	 * Current versions will save this in system.devices as: t10.123_456
+	 * device_id_system_read() now returns: t10.123_456
+	 * When this code reads __t10.123__456__ from system.devices, that
+	 * string is modified to t10.123_456 so that it will match the value
+	 * returned from device_id_system_read().
 	 */
-	if (du->idtype == DEV_ID_TYPE_SYS_WWID && !strncmp(du->idname, "t10", 3) && strchr(du->idname, '_')) {
-		_reduce_repeating_underscores(du->idname, strlen(du->idname), du_t10, sizeof(du_t10) - 1);
-		_remove_trailing_underscores(du_t10);
+	strncpy(du_idname, du->idname, PATH_MAX-1);
+	if (((du->idtype == DEV_ID_TYPE_SYS_WWID) || (du->idtype == DEV_ID_TYPE_SYS_SERIAL)) &&
+	    strchr(du_idname, '_')) {
+		_remove_leading_underscores(du_idname, sizeof(du_idname));
+		_remove_trailing_underscores(du_idname, sizeof(du_idname));
+		if (du->idtype == DEV_ID_TYPE_SYS_WWID && !strncmp(du_idname, "t10", 3) && strstr(du_idname, "__"))
+			_reduce_repeating_underscores(du_idname, sizeof(du_idname));
 	}
 
 	/*
@@ -1848,21 +1933,14 @@ static int _match_du_to_dev(struct cmd_context *cmd, struct dev_use *du, struct
 	 * (and saved on dev->ids to avoid rereading.)
 	 */
 	dm_list_iterate_items(id, &dev->ids) {
-		if (id->idtype == du->idtype) {
+		if (!id->idname)
+			continue;
 
+		if (id->idtype == du->idtype) {
 			/*
-			 * For t10 wwids, remove actual trailing underscores from the dev wwid
-			 * (in id->idname), because all trailing underscores were removed from
-			 * the du->idname read from the devices file. i.e. no trailing _ are
-			 * used in t10 wwid comparisons.
+			 * dm names can have different forms, so matching names
+			 * is not always a direct comparison.
 			 */
-			if ((id->idtype == DEV_ID_TYPE_SYS_WWID) &&
-			    id->idname && !strncmp(id->idname, "t10", 3) && du_t10[0]) {
-				memset(id_t10, 0, sizeof(id_t10));
-				strncpy(id_t10, id->idname, DEV_WWID_SIZE-1);
-				_remove_trailing_underscores(id_t10);
-			}
-
 			if ((id->idtype == DEV_ID_TYPE_DEVNAME) && _match_dm_devnames(cmd, dev, id, du)) {
 				/* dm devs can have differing names that we know still match */
 				du->dev = dev;
@@ -1871,22 +1949,16 @@ static int _match_du_to_dev(struct cmd_context *cmd, struct dev_use *du, struct
 				log_debug("Match device_id %s %s to %s: dm names",
 					  idtype_to_str(du->idtype), du->idname, dev_name(dev));
 				return 1;
+			}
 
-			} else if (id->idname && !strcmp(id->idname, du->idname)) {
+			if (!strcmp(id->idname, du_idname)) {
 				du->dev = dev;
 				dev->id = id;
 				dev->flags |= DEV_MATCHED_USE_ID;
 				log_debug("Match device_id %s %s to %s",
-					  idtype_to_str(du->idtype), du->idname, dev_name(dev));
+					  idtype_to_str(du->idtype), du_idname, dev_name(dev));
 				return 1;
 
-			} else if ((id->idtype == DEV_ID_TYPE_SYS_WWID) && du_t10[0] && id_t10[0] && !strcmp(id_t10, du_t10)) {
-				du->dev = dev;
-				dev->id = id;
-				dev->flags |= DEV_MATCHED_USE_ID;
-				log_debug("Match device_id %s %s to %s",
-					  idtype_to_str(du->idtype), du->idname, dev_name(dev));
-				return 1;
 			} else {
 				/*
 				log_debug("Mismatch device_id %s %s to %s: idname %s",
@@ -1913,12 +1985,12 @@ static int _match_du_to_dev(struct cmd_context *cmd, struct dev_use *du, struct
 	id->dev = dev;
 	dm_list_add(&dev->ids, &id->list);
 
-	if (idname && !strcmp(idname, du->idname)) {
+	if (idname && !strcmp(idname, du_idname)) {
 		du->dev = dev;
 		dev->id = id;
 		dev->flags |= DEV_MATCHED_USE_ID;
 		log_debug("Match device_id %s %s to %s",
-			  idtype_to_str(du->idtype), du->idname, dev_name(dev));
+			  idtype_to_str(du->idtype), idname, dev_name(dev));
 		return 1;
 	}
 
@@ -1944,7 +2016,7 @@ static int _match_du_to_dev(struct cmd_context *cmd, struct dev_use *du, struct
 			dev_read_vpd_wwids(cmd, dev);
 
 		dm_list_iterate_items(dw, &dev->wwids) {
-			if (!strcmp(dw->id, du->idname)) {
+			if (!strcmp(dw->id, du_idname)) {
 				if (!(id = zalloc(sizeof(struct dev_id))))
 					return_0;
 				/* wwid types are 1,2,3 and idtypes are DEV_ID_TYPE_ */
@@ -1956,7 +2028,7 @@ static int _match_du_to_dev(struct cmd_context *cmd, struct dev_use *du, struct
 				dev->id = id;
 				dev->flags |= DEV_MATCHED_USE_ID;
 				log_print_unless_silent("Match device_id %s %s to vpd_pg83 %s %s.",
-							idtype_to_str(du->idtype), du->idname,
+							idtype_to_str(du->idtype), du_idname,
 							idtype_to_str(id->idtype), dev_name(dev));
 				du->idtype = id->idtype;
 				return 1;
diff --git a/lib/device/parse_vpd.c b/lib/device/parse_vpd.c
index c1ac974fd..938277e38 100644
--- a/lib/device/parse_vpd.c
+++ b/lib/device/parse_vpd.c
@@ -36,7 +36,57 @@
 #include <assert.h>
 
 /*
+ * Remove leading spaces.
+ * Remove trailing spaces.
+ * Replace each space with underscore.
+ * Skip quotes, non-ascii, non-printable.
+ */
+int format_general_id(const char *in, int in_bytes, unsigned char *out, int out_bytes)
+{
+	const char *end;
+	int end_bytes = strlen(in);
+	int retlen = 0;
+	int j = 0;
+	int i;
+
+	if (!end_bytes)
+		return 0;
+
+	end = in + end_bytes - 1;
+	while ((end > in) && (*end == ' ')) {
+		end--;
+		end_bytes--;
+	}
+
+	for (i = 0; i < end_bytes; i++) {
+		if (!in[i])
+			break;
+		if (j >= (out_bytes - 2))
+			break;
+		/* skip leading spaces */
+		if (!retlen && (in[i] == ' '))
+			continue;
+		/* skip non-ascii non-printable characters */
+		if (!isascii(in[i]) || !isprint(in[i]))
+			continue;
+		/* skip quote */
+		if (in[i] == '"')
+			continue;
+		/* replace each space with _ */
+		if (in[i] == ' ')
+			out[j++] = '_';
+		else
+			out[j++] = in[i];
+		retlen++;
+	}
+	return retlen;
+}
+
+/*
+ * Remove leading spaces.
+ * Remove trailing spaces.
  * Replace series of spaces with a single _.
+ * Skip quotes, non-ascii, non-printable.
  */
 int format_t10_id(const unsigned char *in, int in_bytes, unsigned char *out, int out_bytes)
 {
diff --git a/test/shell/devicesfile-vpd-ids.sh b/test/shell/devicesfile-vpd-ids.sh
index 52805737b..04dbae7d0 100644
--- a/test/shell/devicesfile-vpd-ids.sh
+++ b/test/shell/devicesfile-vpd-ids.sh
@@ -223,8 +223,8 @@ cleanup_sysfs
 # Test t10 wwid containing quote
 rm $DF
 aux wipefs_a "$DEV1"
-mkdir -p $SYS_DIR/dev/block/$MAJOR1:$MINOR1/
-echo "t10.ATA_2.5\"_SATA_SSD_1112-A___111111111111" > $SYS_DIR/dev/block/$MAJOR1:$MINOR1/wwid
+mkdir -p $SYS_DIR/dev/block/$MAJOR1:$MINOR1/device
+echo "t10.ATA_2.5\"_SATA_SSD_1112-A___111111111111" > $SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/wwid
 lvmdevices --adddev "$DEV1"
 cat $DF
 vgcreate $vg "$DEV1"
@@ -241,19 +241,19 @@ grep sys_wwid $DF
 grep 2.5_SATA_SSD $DF
 lvremove -y $vg
 vgremove $vg
-rm $SYS_DIR/dev/block/$MAJOR1:$MINOR1/wwid
+rm $SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/wwid
 cleanup_sysfs
 
 # Test t10 wwid with trailing space and line feed at the end
 rm $DF
 aux wipefs_a "$DEV1"
-mkdir -p $SYS_DIR/dev/block/$MAJOR1:$MINOR1/
+mkdir -p $SYS_DIR/dev/block/$MAJOR1:$MINOR1/device
 echo -n "7431 302e 4154 4120 2020 2020 5642 4f58 \
 2048 4152 4444 4953 4b20 2020 2020 2020 \
 2020 2020 2020 2020 2020 2020 2020 2020 \
 2020 2020 5642 3963 3130 6433 3138 2d31 \
-3838 6439 6562 6320 0a" | xxd -r -p > $SYS_DIR/dev/block/$MAJOR1:$MINOR1/wwid
-cat $SYS_DIR/dev/block/$MAJOR1:$MINOR1/wwid
+3838 6439 6562 6320 0a" | xxd -r -p > $SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/wwid
+cat $SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/wwid
 lvmdevices --adddev "$DEV1"
 cat $DF
 vgcreate $vg "$DEV1"
@@ -266,19 +266,19 @@ grep sys_wwid out
 grep sys_wwid $DF
 lvremove -y $vg
 vgremove $vg
-rm $SYS_DIR/dev/block/$MAJOR1:$MINOR1/wwid
+rm $SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/wwid
 cleanup_sysfs
 
 # Test t10 wwid with trailing space at the end that was created by 9.0/9.1
 rm $DF
 aux wipefs_a "$DEV1"
-mkdir -p $SYS_DIR/dev/block/$MAJOR1:$MINOR1/
+mkdir -p $SYS_DIR/dev/block/$MAJOR1:$MINOR1/device
 echo -n "7431 302e 4154 4120 2020 2020 5642 4f58 \
 2048 4152 4444 4953 4b20 2020 2020 2020 \
 2020 2020 2020 2020 2020 2020 2020 2020 \
 2020 2020 5642 3963 3130 6433 3138 2d31 \
-3838 6439 6562 6320 0a" | xxd -r -p > $SYS_DIR/dev/block/$MAJOR1:$MINOR1/wwid
-cat $SYS_DIR/dev/block/$MAJOR1:$MINOR1/wwid
+3838 6439 6562 6320 0a" | xxd -r -p > $SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/wwid
+cat $SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/wwid
 lvmdevices --adddev "$DEV1"
 cat $DF
 vgcreate $vg "$DEV1"
@@ -311,20 +311,20 @@ pvs
 pvs -o+deviceidtype,deviceid "$DEV1"
 lvremove -y $vg
 vgremove $vg
-rm $SYS_DIR/dev/block/$MAJOR1:$MINOR1/wwid
+rm $SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/wwid
 cleanup_sysfs
 
 # test a t10 wwid that has actual trailing underscore which
 # is followed by a trailing space.
 rm $DF
 aux wipefs_a "$DEV1"
-mkdir -p $SYS_DIR/dev/block/$MAJOR1:$MINOR1/
+mkdir -p $SYS_DIR/dev/block/$MAJOR1:$MINOR1/device
 echo -n "7431 302e 4154 4120 2020 2020 5642 4f58 \
 2048 4152 4444 4953 4b20 2020 2020 2020 \
 2020 2020 2020 2020 2020 2020 2020 2020 \
 2020 2020 5642 3963 3130 6433 3138 2d31 \
-3838 6439 6562 5f20 0a" | xxd -r -p > $SYS_DIR/dev/block/$MAJOR1:$MINOR1/wwid
-cat $SYS_DIR/dev/block/$MAJOR1:$MINOR1/wwid
+3838 6439 6562 5f20 0a" | xxd -r -p > $SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/wwid
+cat $SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/wwid
 # The wwid has an actual underscore char (5f) followed by a space char (20)
 # 9.1 converts the trailing space to an underscore
 T10_WWID_RHEL91="t10.ATA_____VBOX_HARDDISK___________________________VB9c10d318-188d9eb__"
@@ -352,9 +352,80 @@ pvs
 pvs -o+deviceidtype,deviceid "$DEV1"
 lvremove -y $vg
 vgremove $vg
-rm $SYS_DIR/dev/block/$MAJOR1:$MINOR1/wwid
+rm $SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/wwid
+cleanup_sysfs
+
+#
+# Test trailing/leading/center spaces in sys_wwid and sys_serial device
+# ids, and that old system.devices files that have trailing/leading
+# underscores are understood.
+#
+
+rm $DF
+aux wipefs_a "$DEV1"
+mkdir -p $SYS_DIR/dev/block/$MAJOR1:$MINOR1/device
+echo -n "  s123  456  " > $SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/serial
+lvmdevices --adddev "$DEV1"
+cat $DF
+grep "IDNAME=s123__456 DEVNAME" $DF
+vgcreate $vg "$DEV1"
+PVID1=`pvs "$DEV1" --noheading -o uuid | tr -d - | awk '{print $1}'`
+cat $DF | grep -v IDNAME > $DFTMP
+cat $DFTMP
+echo "IDTYPE=sys_serial IDNAME=__s123__456__ DEVNAME=${DEV1} PVID=${PVID1}" >> $DFTMP
+cp $DFTMP $DF
+cat $DF
+vgs
+pvs -o+deviceidtype,deviceid "$DEV1"
+lvremove -y $vg
+vgremove $vg
+rm $SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/serial
 cleanup_sysfs
 
+rm $DF
+aux wipefs_a "$DEV1"
+mkdir -p $SYS_DIR/dev/block/$MAJOR1:$MINOR1/device
+echo -n "  t10.123  456  " > $SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/wwid
+lvmdevices --adddev "$DEV1"
+cat $DF
+grep "IDNAME=t10.123_456 DEVNAME" $DF
+vgcreate $vg "$DEV1"
+PVID1=`pvs "$DEV1" --noheading -o uuid | tr -d - | awk '{print $1}'`
+cat $DF | grep -v IDNAME > $DFTMP
+cat $DFTMP
+echo "IDTYPE=sys_wwid IDNAME=__t10.123__456__ DEVNAME=${DEV1} PVID=${PVID1}" >> $DFTMP
+cp $DFTMP $DF
+cat $DF
+vgs
+pvs -o+deviceidtype,deviceid "$DEV1"
+lvremove -y $vg
+vgremove $vg
+rm $SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/wwid
+cleanup_sysfs
+
+rm $DF
+aux wipefs_a "$DEV1"
+mkdir -p $SYS_DIR/dev/block/$MAJOR1:$MINOR1/device
+echo -n "  naa.123  456  " > $SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/wwid
+lvmdevices --adddev "$DEV1"
+cat $DF
+grep "IDNAME=naa.123__456 DEVNAME" $DF
+vgcreate $vg "$DEV1"
+PVID1=`pvs "$DEV1" --noheading -o uuid | tr -d - | awk '{print $1}'`
+cat $DF | grep -v IDNAME > $DFTMP
+cat $DFTMP
+echo "IDTYPE=sys_wwid IDNAME=__naa.123__456__ DEVNAME=${DEV1} PVID=${PVID1}" >> $DFTMP
+cp $DFTMP $DF
+cat $DF
+vgs
+pvs -o+deviceidtype,deviceid "$DEV1"
+lvremove -y $vg
+vgremove $vg
+rm $SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/wwid
+cleanup_sysfs
+
+
+
 
 # TODO: lvmdevices --adddev <dev> --deviceidtype <type> --deviceid <val>
 # This would let the user specify the second naa wwid.

