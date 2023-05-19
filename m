From: David Teigland <teigland@sourceware.org>
Date: Fri, 19 May 2023 19:07:25 +0000 (GMT)
Subject: main - device_id: ignore trailing underscores in t10 wwid from devices file
Message-ID: <20230519190725.4F3703858C52@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4cdb178968b44125c41dee6dd28997283c0afefa
Commit:        4cdb178968b44125c41dee6dd28997283c0afefa
Parent:        24e4b6df1182d0d41763176c175e98e5fa6153ab
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri May 19 12:52:48 2023 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri May 19 14:05:10 2023 -0500

device_id: ignore trailing underscores in t10 wwid from devices file

In previous lvm versions, trailing spaces at the end of a t10 wwid would
be replaced with underscores, so the IDNAME string in system.devices
would look something like "t10.123_".  Current versions of lvm ignore
trailing spaces in a t10 wwid, so the IDNAME string used would be
"t10.123".  The different values would cause lvm to not recognize a
device in system.devices with the trailing _.  Fix this by ignoring
trailing underscores in the IDNAME string from system.devices.
---
 lib/device/device_id.c            |  46 +++++++++++++---
 test/shell/devicesfile-vpd-ids.sh | 113 ++++++++++++++++++++++++++++++++++++++
 2 files changed, 152 insertions(+), 7 deletions(-)

diff --git a/lib/device/device_id.c b/lib/device/device_id.c
index 38677d1fe..3e05a40a8 100644
--- a/lib/device/device_id.c
+++ b/lib/device/device_id.c
@@ -1728,7 +1728,8 @@ static int _match_dm_devnames(struct cmd_context *cmd, struct device *dev,
 	return 0;
 }
 
-static void _reduce_underscores(char *in, int in_len, char *out, int out_size)
+/* More than one _ in a row is replaced with one _ */
+static void _reduce_repeating_underscores(char *in, int in_len, char *out, int out_size)
 {
 	int us = 0, i, j = 0;
 
@@ -1750,6 +1751,17 @@ static void _reduce_underscores(char *in, int in_len, char *out, int out_size)
 	}
 }
 
+/* Remove any _ at the end of the string. */
+static void _remove_trailing_underscores(char *buf)
+{
+	char *end;
+
+	end = buf + strlen(buf) - 1;
+	while ((end > buf) && (*end == '_'))
+		end--;
+	end[1] = '\0';
+}
+
 /*
  * du is a devices file entry.  dev is any device on the system.
  * check if du is for dev by comparing the device's ids to du->idname.
@@ -1764,6 +1776,7 @@ static void _reduce_underscores(char *in, int in_len, char *out, int out_size)
 static int _match_du_to_dev(struct cmd_context *cmd, struct dev_use *du, struct device *dev)
 {
 	char du_t10[DEV_WWID_SIZE] = { 0 };
+	char id_t10[DEV_WWID_SIZE];
 	struct dev_id *id;
 	const char *idname;
 	int part;
@@ -1818,10 +1831,17 @@ static int _match_du_to_dev(struct cmd_context *cmd, struct dev_use *du, struct
 	 * for IDNAME were saved in the past with each space replaced
 	 * by one _.  Now we convert multiple spaces to a single _.
 	 * So, convert a df entry with the old style to the new shorter
-	 * style to compare.
+	 * style to compare.  Also, in past versions, trailing spaces
+	 * in the wwid would be replaced by _, but now trailing spaces
+	 * are ignored.  This means devices file entries created by
+	 * past versions may have _ at the end of the IDNAME string.
+	 * So, exclude trailing underscores when comparing a t10 wwid
+	 * from a device with a t10 wwid in the devices file.
 	 */
-	if (du->idtype == DEV_ID_TYPE_SYS_WWID && !strncmp(du->idname, "t10", 3) && strstr(du->idname, "__"))
-		_reduce_underscores(du->idname, strlen(du->idname), du_t10, sizeof(du_t10) - 1);
+	if (du->idtype == DEV_ID_TYPE_SYS_WWID && !strncmp(du->idname, "t10", 3) && strchr(du->idname, '_')) {
+		_reduce_repeating_underscores(du->idname, strlen(du->idname), du_t10, sizeof(du_t10) - 1);
+		_remove_trailing_underscores(du_t10);
+	}
 
 	/*
 	 * Try to match du with ids that have already been read for the dev
@@ -1829,6 +1849,20 @@ static int _match_du_to_dev(struct cmd_context *cmd, struct dev_use *du, struct
 	 */
 	dm_list_iterate_items(id, &dev->ids) {
 		if (id->idtype == du->idtype) {
+
+			/*
+			 * For t10 wwids, remove actual trailing underscores from the dev wwid
+			 * (in id->idname), because all trailing underscores were removed from
+			 * the du->idname read from the devices file. i.e. no trailing _ are
+			 * used in t10 wwid comparisons.
+			 */
+			if ((id->idtype == DEV_ID_TYPE_SYS_WWID) &&
+			    id->idname && !strncmp(id->idname, "t10", 3) && du_t10[0]) {
+				memset(id_t10, 0, sizeof(id_t10));
+				strncpy(id_t10, id->idname, DEV_WWID_SIZE-1);
+				_remove_trailing_underscores(id_t10);
+			}
+
 			if ((id->idtype == DEV_ID_TYPE_DEVNAME) && _match_dm_devnames(cmd, dev, id, du)) {
 				/* dm devs can have differing names that we know still match */
 				du->dev = dev;
@@ -1846,9 +1880,7 @@ static int _match_du_to_dev(struct cmd_context *cmd, struct dev_use *du, struct
 					  idtype_to_str(du->idtype), du->idname, dev_name(dev));
 				return 1;
 
-			} else if ((id->idtype == DEV_ID_TYPE_SYS_WWID) && id->idname &&
-				   !strncmp(id->idname, "t10", 3) && du_t10[0] && !strcmp(id->idname, du_t10)) {
-				/* Compare the shorter form du t10 wwid to the dev t10 wwid. */
+			} else if ((id->idtype == DEV_ID_TYPE_SYS_WWID) && du_t10[0] && id_t10[0] && !strcmp(id_t10, du_t10)) {
 				du->dev = dev;
 				dev->id = id;
 				dev->flags |= DEV_MATCHED_USE_ID;
diff --git a/test/shell/devicesfile-vpd-ids.sh b/test/shell/devicesfile-vpd-ids.sh
index b2042fb9a..52805737b 100644
--- a/test/shell/devicesfile-vpd-ids.sh
+++ b/test/shell/devicesfile-vpd-ids.sh
@@ -80,6 +80,7 @@ echo $DEV1
 DFDIR="$LVM_SYSTEM_DIR/devices"
 mkdir -p "$DFDIR" || true
 DF="$DFDIR/system.devices"
+DFTMP="$DFDIR/system.devices_tmp"
 touch $DF
 
 pvcreate "$DEV1"
@@ -243,6 +244,118 @@ vgremove $vg
 rm $SYS_DIR/dev/block/$MAJOR1:$MINOR1/wwid
 cleanup_sysfs
 
+# Test t10 wwid with trailing space and line feed at the end
+rm $DF
+aux wipefs_a "$DEV1"
+mkdir -p $SYS_DIR/dev/block/$MAJOR1:$MINOR1/
+echo -n "7431 302e 4154 4120 2020 2020 5642 4f58 \
+2048 4152 4444 4953 4b20 2020 2020 2020 \
+2020 2020 2020 2020 2020 2020 2020 2020 \
+2020 2020 5642 3963 3130 6433 3138 2d31 \
+3838 6439 6562 6320 0a" | xxd -r -p > $SYS_DIR/dev/block/$MAJOR1:$MINOR1/wwid
+cat $SYS_DIR/dev/block/$MAJOR1:$MINOR1/wwid
+lvmdevices --adddev "$DEV1"
+cat $DF
+vgcreate $vg "$DEV1"
+lvcreate -l1 -an $vg
+cat $DF
+# check wwid string in metadata output
+pvs -o+deviceidtype,deviceid "$DEV1" |tee out
+grep sys_wwid out
+# check wwid string in system.devices
+grep sys_wwid $DF
+lvremove -y $vg
+vgremove $vg
+rm $SYS_DIR/dev/block/$MAJOR1:$MINOR1/wwid
+cleanup_sysfs
+
+# Test t10 wwid with trailing space at the end that was created by 9.0/9.1
+rm $DF
+aux wipefs_a "$DEV1"
+mkdir -p $SYS_DIR/dev/block/$MAJOR1:$MINOR1/
+echo -n "7431 302e 4154 4120 2020 2020 5642 4f58 \
+2048 4152 4444 4953 4b20 2020 2020 2020 \
+2020 2020 2020 2020 2020 2020 2020 2020 \
+2020 2020 5642 3963 3130 6433 3138 2d31 \
+3838 6439 6562 6320 0a" | xxd -r -p > $SYS_DIR/dev/block/$MAJOR1:$MINOR1/wwid
+cat $SYS_DIR/dev/block/$MAJOR1:$MINOR1/wwid
+lvmdevices --adddev "$DEV1"
+cat $DF
+vgcreate $vg "$DEV1"
+PVID1=`pvs "$DEV1" --noheading -o uuid | tr -d - | awk '{print $1}'`
+T10_WWID_RHEL91="t10.ATA_____VBOX_HARDDISK___________________________VB9c10d318-188d9ebc_"
+lvcreate -l1 -an $vg
+cat $DF
+# check wwid string in metadata output
+pvs -o+deviceidtype,deviceid "$DEV1" |tee out
+grep sys_wwid out
+# check wwid string in system.devices
+grep sys_wwid $DF
+# Replace IDNAME with the IDNAME that 9.0/9.1 created from this wwid
+cat $DF | grep -v IDNAME > $DFTMP
+cat $DFTMP
+echo "IDTYPE=sys_wwid IDNAME=t10.ATA_____VBOX_HARDDISK___________________________VB9c10d318-188d9ebc_ DEVNAME=${DEV1} PVID=${PVID1}" >> $DFTMP
+cp $DFTMP $DF
+cat $DF
+vgs
+pvs
+pvs -o+deviceidtype,deviceid "$DEV1"
+# Removing the trailing _ which should then work
+cat $DF | grep -v IDNAME > $DFTMP
+cat $DFTMP
+echo "IDTYPE=sys_wwid IDNAME=t10.ATA_____VBOX_HARDDISK___________________________VB9c10d318-188d9ebc DEVNAME=${DEV1} PVID=${PVID1}" >> $DFTMP
+cp $DFTMP $DF
+cat $DF
+vgs
+pvs
+pvs -o+deviceidtype,deviceid "$DEV1"
+lvremove -y $vg
+vgremove $vg
+rm $SYS_DIR/dev/block/$MAJOR1:$MINOR1/wwid
+cleanup_sysfs
+
+# test a t10 wwid that has actual trailing underscore which
+# is followed by a trailing space.
+rm $DF
+aux wipefs_a "$DEV1"
+mkdir -p $SYS_DIR/dev/block/$MAJOR1:$MINOR1/
+echo -n "7431 302e 4154 4120 2020 2020 5642 4f58 \
+2048 4152 4444 4953 4b20 2020 2020 2020 \
+2020 2020 2020 2020 2020 2020 2020 2020 \
+2020 2020 5642 3963 3130 6433 3138 2d31 \
+3838 6439 6562 5f20 0a" | xxd -r -p > $SYS_DIR/dev/block/$MAJOR1:$MINOR1/wwid
+cat $SYS_DIR/dev/block/$MAJOR1:$MINOR1/wwid
+# The wwid has an actual underscore char (5f) followed by a space char (20)
+# 9.1 converts the trailing space to an underscore
+T10_WWID_RHEL91="t10.ATA_____VBOX_HARDDISK___________________________VB9c10d318-188d9eb__"
+# 9.2 ignores the trailing space
+T10_WWID_RHEL92="t10.ATA_____VBOX_HARDDISK___________________________VB9c10d318-188d9eb_"
+lvmdevices --adddev "$DEV1"
+cat $DF
+vgcreate $vg "$DEV1"
+PVID1=`pvs "$DEV1" --noheading -o uuid | tr -d - | awk '{print $1}'`
+lvcreate -l1 -an $vg
+cat $DF
+# check wwid string in metadata output
+pvs -o+deviceidtype,deviceid "$DEV1" |tee out
+grep sys_wwid out
+# check wwid string in system.devices
+grep sys_wwid $DF
+# Replace IDNAME with the IDNAME that 9.0/9.1 created from this wwid
+cat $DF | grep -v IDNAME > $DFTMP
+cat $DFTMP
+echo "IDTYPE=sys_wwid IDNAME=${T10_WWID_RHEL91} DEVNAME=${DEV1} PVID=${PVID1}" >> $DFTMP
+cp $DFTMP $DF
+cat $DF
+vgs
+pvs
+pvs -o+deviceidtype,deviceid "$DEV1"
+lvremove -y $vg
+vgremove $vg
+rm $SYS_DIR/dev/block/$MAJOR1:$MINOR1/wwid
+cleanup_sysfs
+
+
 # TODO: lvmdevices --adddev <dev> --deviceidtype <type> --deviceid <val>
 # This would let the user specify the second naa wwid.
 

