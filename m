From: David Teigland <teigland@sourceware.org>
Date: Mon, 23 Aug 2021 20:54:57 +0000 (GMT)
Subject: main - devices: restrict device id types to specific major numbers
Message-ID: <20210823205457.761383858C2C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0969e90d45932d2903d2822701b32edfb2cf31cf
Commit:        0969e90d45932d2903d2822701b32edfb2cf31cf
Parent:        a6a8443a07f891246fa68bda9cc8e3937b6ddbb6
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Aug 23 15:01:26 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Aug 23 15:54:41 2021 -0500

devices: restrict device id types to specific major numbers

Some device id types can only be used with specific device major
numbers, so use this restriction to avoid some comparisions.
This is more efficient, and can avoid some incorrect matches.
---
 lib/device/device_id.c  | 53 +++++++++++++++++++++++++++++++++++++++++++++----
 test/shell/lvm-on-md.sh | 21 +++++++++++++++-----
 2 files changed, 65 insertions(+), 9 deletions(-)

diff --git a/lib/device/device_id.c b/lib/device/device_id.c
index 391309ccd..649c4bba9 100644
--- a/lib/device/device_id.c
+++ b/lib/device/device_id.c
@@ -321,17 +321,24 @@ const char *device_id_system_read(struct cmd_context *cmd, struct device *dev, u
 	else if (idtype == DEV_ID_TYPE_SYS_SERIAL)
 		read_sys_block(cmd, dev, "device/serial", sysbuf, sizeof(sysbuf));
 
-	else if (idtype == DEV_ID_TYPE_MPATH_UUID)
+	else if (idtype == DEV_ID_TYPE_MPATH_UUID) {
 		read_sys_block(cmd, dev, "dm/uuid", sysbuf, sizeof(sysbuf));
+		/* if (strncmp(sysbuf, "mpath", 5)) sysbuf[0] = '\0'; */
+	}
 
-	else if (idtype == DEV_ID_TYPE_CRYPT_UUID)
+	else if (idtype == DEV_ID_TYPE_CRYPT_UUID) {
 		read_sys_block(cmd, dev, "dm/uuid", sysbuf, sizeof(sysbuf));
+		/* if (strncmp(sysbuf, "CRYPT", 5)) sysbuf[0] = '\0'; */
+	}
 
-	else if (idtype == DEV_ID_TYPE_LVMLV_UUID)
+	else if (idtype == DEV_ID_TYPE_LVMLV_UUID) {
 		read_sys_block(cmd, dev, "dm/uuid", sysbuf, sizeof(sysbuf));
+		/* if (strncmp(sysbuf, "LVM", 3)) sysbuf[0] = '\0'; */
+	}
 
-	else if (idtype == DEV_ID_TYPE_MD_UUID)
+	else if (idtype == DEV_ID_TYPE_MD_UUID) {
 		read_sys_block(cmd, dev, "md/uuid", sysbuf, sizeof(sysbuf));
+	}
 
 	else if (idtype == DEV_ID_TYPE_LOOP_FILE) {
 		read_sys_block(cmd, dev, "loop/backing_file", sysbuf, sizeof(sysbuf));
@@ -1292,6 +1299,36 @@ void device_id_pvremove(struct cmd_context *cmd, struct device *dev)
 	}
 }
 
+static int _idtype_compatible_with_major_number(struct cmd_context *cmd, int idtype, int major)
+{
+	if (idtype == DEV_ID_TYPE_MPATH_UUID ||
+	    idtype == DEV_ID_TYPE_CRYPT_UUID ||
+	    idtype == DEV_ID_TYPE_LVMLV_UUID)
+		return (major == cmd->dev_types->device_mapper_major);
+
+	if (idtype == DEV_ID_TYPE_MD_UUID)
+		return (major == cmd->dev_types->md_major);
+
+	if (idtype == DEV_ID_TYPE_LOOP_FILE)
+		return (major == cmd->dev_types->loop_major);
+
+	if (major == cmd->dev_types->device_mapper_major)
+		return (idtype == DEV_ID_TYPE_MPATH_UUID ||
+			idtype == DEV_ID_TYPE_CRYPT_UUID ||
+			idtype == DEV_ID_TYPE_LVMLV_UUID ||
+			idtype == DEV_ID_TYPE_DEVNAME);
+
+	if (major == cmd->dev_types->md_major)
+		return (idtype == DEV_ID_TYPE_MD_UUID ||
+			idtype == DEV_ID_TYPE_DEVNAME);
+
+	if (major == cmd->dev_types->loop_major)
+		return (idtype == DEV_ID_TYPE_LOOP_FILE ||
+			idtype == DEV_ID_TYPE_DEVNAME);
+
+	return 1;
+}
+
 /*
  * check for dev->ids entry with du->idtype, if found compare it,
  * if not, system_read of this type and add entry to dev->ids, compare it.
@@ -1307,6 +1344,14 @@ static int _match_du_to_dev(struct cmd_context *cmd, struct dev_use *du, struct
 	if (!du->idname || !du->idtype)
 		return 0;
 
+	/*
+	 * Some idtypes can only match devices with a specific major number,
+	 * so we can skip trying to match certain du entries based simply on
+	 * the major number of dev.
+	 */
+	if (!_idtype_compatible_with_major_number(cmd, du->idtype, (int)MAJOR(dev->dev)))
+		return 0;
+
 	if (!dev_get_partition_number(dev, &part)) {
 		log_debug("compare %s failed to get dev partition", dev_name(dev));
 		return 0;
diff --git a/test/shell/lvm-on-md.sh b/test/shell/lvm-on-md.sh
index d2810b8cf..f932ca623 100644
--- a/test/shell/lvm-on-md.sh
+++ b/test/shell/lvm-on-md.sh
@@ -13,19 +13,23 @@
 SKIP_WITH_LVMPOLLD=1
 SKIP_WITH_LVMLOCKD=1
 
+. lib/inittest
+
 RUNDIR="/run"
 test -d "$RUNDIR" || RUNDIR="/var/run"
 PVS_ONLINE_DIR="$RUNDIR/lvm/pvs_online"
 VGS_ONLINE_DIR="$RUNDIR/lvm/vgs_online"
 HINTS="$RUNDIR/lvm/hints"
 
+DFDIR="$LVM_SYSTEM_DIR/devices"
+DF="$DFDIR/system.devices"
+
 _clear_online_files() {
         # wait till udev is finished
         aux udev_wait
         rm -f "$PVS_ONLINE_DIR"/* "$VGS_ONLINE_DIR"/*
 }
 
-. lib/inittest
 
 # This stops lvm from taking advantage of hints which
 # will have already excluded md components.
@@ -35,7 +39,8 @@ _clear_online_files() {
 # want to rely on that ability in this test.
 aux lvmconf "devices/md_component_detection = 1" \
 	"devices/hints = \"none\"" \
-	"devices/obtain_device_list_from_udev = 0"
+	"devices/obtain_device_list_from_udev = 0" \
+	"devices/search_for_devnames = \"none\""
 
 aux extend_filter_md "a|/dev/md|"
 
@@ -54,6 +59,9 @@ mddev=$(< MD_DEV)
 
 vgcreate $vg "$mddev"
 
+lvmdevices || true
+pvs -o+deviceidtype,deviceid
+
 PVIDMD=$(get pv_field "$mddev" uuid | tr -d - )
 
 lvcreate -n $lv1 -l 2 $vg
@@ -158,7 +166,10 @@ done
 # Repeat tests using the default config settings
 
 aux lvmconf "devices/hints = \"all\"" \
-	"devices/obtain_device_list_from_udev = 1"
+	"devices/obtain_device_list_from_udev = 1" \
+	"devices/search_for_devnames = \"none\""
+
+rm $DF || true
 
 # create 2 disk MD raid0 array
 # by default using metadata format 1.0 with data@the end of device
@@ -216,7 +227,7 @@ aux udev_wait
 # duplicate PVs which are eventually recognized as md components
 # and dropped.
 pvs 2>&1|tee out1
-grep -v WARNING out1 > out2
+grep -v -e WARNING -e "Devices file PVID" out1 > out2
 not grep "Not using device" out2
 not grep "$mddev" out2
 not grep "$dev1" out2
@@ -225,7 +236,7 @@ grep "$dev3" out2
 cat "$HINTS"
 
 pvs 2>&1|tee out1
-grep -v WARNING out1 > out2
+grep -v -e WARNING -e "Devices file PVID" out1 > out2
 not grep "Not using device" out2
 not grep "$mddev" out2
 not grep "$dev1" out2


