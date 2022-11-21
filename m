From: David Teigland <teigland@sourceware.org>
Date: Mon, 21 Nov 2022 16:58:15 +0000 (GMT)
Subject: main - tests: devicesfile-vpd-ids add nvme wwid
Message-ID: <20221121165815.F355F384F48F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2da4ca7ce163fe89b3c79b1d6c55aa30eaa6307d
Commit:        2da4ca7ce163fe89b3c79b1d6c55aa30eaa6307d
Parent:        e0ea0706dc884916c36b7fca285b621eafefc2bf
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Nov 21 10:57:30 2022 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Nov 21 10:57:30 2022 -0600

tests: devicesfile-vpd-ids add nvme wwid

---
 test/shell/devicesfile-vpd-ids.sh | 31 ++++++++++++++++++++++++++++---
 1 file changed, 28 insertions(+), 3 deletions(-)

diff --git a/test/shell/devicesfile-vpd-ids.sh b/test/shell/devicesfile-vpd-ids.sh
index 0eca56935..2801310ef 100644
--- a/test/shell/devicesfile-vpd-ids.sh
+++ b/test/shell/devicesfile-vpd-ids.sh
@@ -62,8 +62,8 @@ setup_sysfs() {
 cleanup_sysfs() {
 	rm -f $SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/wwid
 	rm -f $SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/vpd_pg83
-	rmdir $SYS_DIR/dev/block/$MAJOR1:$MINOR1/device
-	rmdir $SYS_DIR/dev/block/$MAJOR1:$MINOR1
+	rmdir $SYS_DIR/dev/block/$MAJOR1:$MINOR1/device || true
+	rmdir $SYS_DIR/dev/block/$MAJOR1:$MINOR1 || true
 }
 
 
@@ -193,9 +193,34 @@ rm $SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/wwid
 pvs "$DEV1"
 cleanup_sysfs
 
+# Test nvme wwid that starts with "nvme" instead of naa/eui/t10
+rm $DF
+aux wipefs_a "$DEV1"
+mkdir -p $SYS_DIR/dev/block/$MAJOR1:$MINOR1/
+echo "nvme.111111111111111111122222222222333333333333333-44444444444444444445555555555556666666666666666662-00000001" > $SYS_DIR/dev/block/$MAJOR1:$MINOR1/wwid
+lvmdevices --adddev "$DEV1"
+cat $DF
+vgcreate $vg "$DEV1"
+lvcreate -l1 -an $vg
+cat $DF
+pvs -o+deviceidtype,deviceid "$DEV1" |tee out
+grep sys_wwid out
+grep nvme.111 out
+grep sys_wwid $DF
+grep nvme.111 $DF
+lvmdevices --deldev "$DEV1"
+not lvmdevices --adddev "$DEV1" --deviceidtype wwid_eui
+lvmdevices --adddev "$DEV1" --deviceidtype sys_wwid
+lvmdevices | grep nvme.111
+lvremove -y $vg
+sleep 1
+lvs $vg
+vgremove $vg
+rm $SYS_DIR/dev/block/$MAJOR1:$MINOR1/wwid
+cleanup_sysfs
 
 # TODO: lvmdevices --adddev <dev> --deviceidtype <type> --deviceid <val>
 # This would let the user specify the second naa wwid.
 
 remove_base
-rmmod scsi_debug
+rmmod scsi_debug || true

