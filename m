From: David Teigland <teigland@sourceware.org>
Date: Fri,  2 Dec 2022 18:25:31 +0000 (GMT)
Subject: main - device_id: fix segfault verifying serial for non-pv
Message-ID: <20221202182531.337EC3858D39@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6613a61d3b5ce4d12a6fef79195eac34f30ef4da
Commit:        6613a61d3b5ce4d12a6fef79195eac34f30ef4da
Parent:        a74468116ea51542e409e4bc393c63dc7ddb20b6
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Dec 2 11:59:09 2022 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Dec 2 12:25:10 2022 -0600

device_id: fix segfault verifying serial for non-pv

The recent change that verifies sys_serial system.devices entries
using the PVID did not exclude non-PV devices from being checked.
The verification code would attempt to use du->pvid which was null
for the non-PVs causing a segfault.
---
 lib/device/device_id.c           |  6 ++-
 test/shell/devicesfile-serial.sh | 79 ++++++++++++++++++++++++++++++++++++++++
 2 files changed, 83 insertions(+), 2 deletions(-)

diff --git a/lib/device/device_id.c b/lib/device/device_id.c
index 1f2ab5ad4..1be6b0787 100644
--- a/lib/device/device_id.c
+++ b/lib/device/device_id.c
@@ -2239,8 +2239,8 @@ void device_ids_validate(struct cmd_context *cmd, struct dm_list *scanned_devs,
 		 * number is correct, since serial numbers may not be unique.
 		 * Search for the PVID on other devs in device_ids_check_serial.
 		 */
-		if ((du->idtype == DEV_ID_TYPE_SYS_SERIAL) &&
-		    (!du->pvid || memcmp(dev->pvid, du->pvid, ID_LEN))) {
+		if ((du->idtype == DEV_ID_TYPE_SYS_SERIAL) && du->pvid &&
+		    memcmp(dev->pvid, du->pvid, ID_LEN)) {
 			log_debug("suspect device id serial %s for %s", du->idname, dev_name(dev));
 			str_list_add(cmd->mem, &cmd->device_ids_check_serial, dm_pool_strdup(cmd->mem, du->idname));
 			*device_ids_invalid = 1;
@@ -2573,6 +2573,8 @@ void device_ids_check_serial(struct cmd_context *cmd, struct dm_list *scan_devs,
 	dm_list_iterate_items(dul, &dus_check) {
 		if (!dul->du->dev)
 			continue;
+		if (!dul->du->pvid)
+			continue;
 		/* save previously matched devs so they can be dropped from
 		   lvmcache at the end if they are no longer used */
 		if (!(dil = dm_pool_zalloc(cmd->mem, sizeof(*dil))))
diff --git a/test/shell/devicesfile-serial.sh b/test/shell/devicesfile-serial.sh
index b7bfce29e..a88c1906a 100644
--- a/test/shell/devicesfile-serial.sh
+++ b/test/shell/devicesfile-serial.sh
@@ -772,6 +772,85 @@ grep $SERIAL1 out2
 grep $dev3 out3
 grep $SERIAL3 out3
 
+# non-PV devices
+
+aux wipefs_a $dev1
+aux wipefs_a $dev2
+aux wipefs_a $dev3
+aux wipefs_a $dev4
+
+echo $SERIAL1 > $SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/serial
+echo $SERIAL2 > $SYS_DIR/dev/block/$MAJOR2:$MINOR2/device/serial
+echo $SERIAL2 > $SYS_DIR/dev/block/$MAJOR3:$MINOR3/device/serial
+echo $SERIAL4 > $SYS_DIR/dev/block/$MAJOR4:$MINOR4/device/serial
+
+rm $DF
+touch $DF
+vgcreate $vg4 $dev4
+lvmdevices --adddev "$dev1"
+lvmdevices --adddev "$dev2"
+lvmdevices --adddev "$dev3"
+cat $DF
+
+grep $dev1 $DF |tee out1
+grep $dev2 $DF |tee out2
+grep $dev3 $DF |tee out3
+grep $dev4 $DF |tee out4
+
+grep $SERIAL1 out1
+grep $SERIAL2 out2
+grep $SERIAL2 out3
+grep $SERIAL4 out4
+
+pvs |tee out
+grep $dev4 out
+not grep $dev1 out
+not grep $dev2 out
+not grep $dev3 out
+
+pvcreate $dev1
+pvs |tee out
+grep $dev1 out
+grep $dev4 out
+not grep $dev2 out
+not grep $dev3 out
+
+pvcreate $dev2
+pvs |tee out
+grep $dev1 out
+grep $dev4 out
+grep $dev2 out
+not grep $dev3 out
+
+pvcreate $dev3
+pvs |tee out
+grep $dev1 out
+grep $dev4 out
+grep $dev2 out
+grep $dev3 out
+
+PVID1=`pvs "$dev1" --noheading -o uuid | tr -d - | awk '{print $1}'`
+PVID2=`pvs "$dev2" --noheading -o uuid | tr -d - | awk '{print $1}'`
+PVID3=`pvs "$dev3" --noheading -o uuid | tr -d - | awk '{print $1}'`
+PVID4=`pvs "$dev4" --noheading -o uuid | tr -d - | awk '{print $1}'`
+OPVID1=`pvs "$dev1" --noheading -o uuid | awk '{print $1}'`
+OPVID2=`pvs "$dev2" --noheading -o uuid | awk '{print $1}'`
+OPVID3=`pvs "$dev3" --noheading -o uuid | awk '{print $1}'`
+OPVID4=`pvs "$dev4" --noheading -o uuid | awk '{print $1}'`
+
+grep $dev1 $DF |tee out1
+grep $dev2 $DF |tee out2
+grep $dev3 $DF |tee out3
+grep $dev4 $DF |tee out4
+
+grep $PVID1 out1
+grep $PVID2 out2
+grep $PVID3 out3
+grep $PVID4 out4
+
+vgcreate $vg2 $dev2 $dev3
+vgs | grep $vg2
+
 remove_base
 rmmod brd
 

