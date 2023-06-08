From: David Teigland <teigland@sourceware.org>
Date: Thu,  8 Jun 2023 17:27:05 +0000 (GMT)
Subject: main - device_id: fix handling of non-PV with duplicate serial number
Message-ID: <20230608172705.EC32E3858C62@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=74feebdab723c1ea46d4316f8a581750c1d8cda3
Commit:        74feebdab723c1ea46d4316f8a581750c1d8cda3
Parent:        8e53b3bc14a03c243d10fc6bd9a7a8dc43d0a4d4
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Jun 8 12:24:05 2023 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Jun 8 12:24:05 2023 -0500

device_id: fix handling of non-PV with duplicate serial number

Fix in the code that matches devices to system.devices entries when
the devices have the same serial number.  A non-PV device in
system.devices has no pvid value, and the code was segfaulting
when checking the null pvid value.
---
 lib/device/device_id.c           |  2 ++
 test/shell/devicesfile-serial.sh | 38 ++++++++++++++++++++++++++++++++++++++
 2 files changed, 40 insertions(+)

diff --git a/lib/device/device_id.c b/lib/device/device_id.c
index 3e05a40a8..9a8716500 100644
--- a/lib/device/device_id.c
+++ b/lib/device/device_id.c
@@ -2625,6 +2625,8 @@ void device_ids_check_serial(struct cmd_context *cmd, struct dm_list *scan_devs,
 	 * Match du to a dev based on PVID.
 	 */
 	dm_list_iterate_items(dul, &dus_check) {
+		if (!dul->du->pvid)
+			continue;
 		log_debug("Matching suspect serial device id %s PVID %s prev %s",
 			  dul->du->idname, dul->du->pvid, dul->du->devname);
 		found = 0;
diff --git a/test/shell/devicesfile-serial.sh b/test/shell/devicesfile-serial.sh
index 94ce3d74a..014f97e8e 100644
--- a/test/shell/devicesfile-serial.sh
+++ b/test/shell/devicesfile-serial.sh
@@ -853,6 +853,44 @@ grep $PVID4 out4
 vgcreate $vg2 $dev2 $dev3
 vgs | grep $vg2
 
+# 3 devs with duplicate serial, 2 pvs with stale devnames, 1 non-pv device
+
+aux wipefs_a $dev1
+aux wipefs_a $dev2
+aux wipefs_a $dev3
+
+echo $SERIAL1 > $SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/serial
+echo $SERIAL1 > $SYS_DIR/dev/block/$MAJOR2:$MINOR2/device/serial
+echo $SERIAL1 > $SYS_DIR/dev/block/$MAJOR3:$MINOR3/device/serial
+
+rm $DF
+touch $DF
+vgcreate $vg1 $dev1 $dev2
+lvmdevices --adddev $dev3
+cat $DF
+cp $DF $ORIG
+
+PVID1=`pvs "$dev1" --noheading -o uuid | tr -d - | awk '{print $1}'`
+PVID2=`pvs "$dev2" --noheading -o uuid | tr -d - | awk '{print $1}'`
+OPVID1=`pvs "$dev1" --noheading -o uuid | awk '{print $1}'`
+OPVID2=`pvs "$dev2" --noheading -o uuid | awk '{print $1}'`
+
+pvs -o+uuid,deviceid
+
+sed -e "s|DEVNAME=$dev1|DEVNAME=tmp|" $ORIG > tmp1
+sed -e "s|DEVNAME=$dev2|DEVNAME=$dev1|" tmp1 > tmp2
+sed -e "s|DEVNAME=tmp|DEVNAME=$dev2|" tmp2 > $DF
+cat $DF
+
+# pvs should report the correct info and fix the DF
+pvs -o+uuid,deviceid |tee out
+grep $dev1 out |tee out1
+grep $dev2 out |tee out2
+grep $OPVID1 out1
+grep $OPVID2 out2
+grep $SERIAL1 out1
+grep $SERIAL1 out2
+
 remove_base
 rmmod brd
 

