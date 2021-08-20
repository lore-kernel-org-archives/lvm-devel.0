From: David Teigland <teigland@sourceware.org>
Date: Fri, 20 Aug 2021 20:08:26 +0000 (GMT)
Subject: main - vgimportclone: fix when duplicates are both in the devices file
Message-ID: <20210820200826.83FBF3857C65@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=72af1cb0857afffd56f71847fcb9504d491c13e4
Commit:        72af1cb0857afffd56f71847fcb9504d491c13e4
Parent:        8b723139363a6b55e57ba4e9d599ff2efbae7d23
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Aug 20 15:06:33 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Aug 20 15:06:33 2021 -0500

vgimportclone: fix when duplicates are both in the devices file

Fix case where duplicate PVs are created (e.g. with dd) from
devices that are both already in the devices file.
---
 test/shell/vgimportclone.sh | 21 +++++++++++++++++++++
 tools/vgimportclone.c       |  4 ++--
 2 files changed, 23 insertions(+), 2 deletions(-)

diff --git a/test/shell/vgimportclone.sh b/test/shell/vgimportclone.sh
index 2245d65eb..97d146b9e 100644
--- a/test/shell/vgimportclone.sh
+++ b/test/shell/vgimportclone.sh
@@ -43,9 +43,23 @@ vgimport $vg1
 fail vgimport $vg1
 vgchange -ay $vg1
 
+# Since the devices file is using devnames as ids,
+# it will not automatically know that dev2 is a
+# duplicate after the dd, so we need to remove dev2
+# from df, then add it again after the dd.
+if lvmdevices; then
+	lvmdevices --deldev "$dev2"
+fi
+
 # Clone the LUN
 dd if="$dev1" of="$dev2" bs=256K count=1
 
+# Requires -y to confirm prompt about adding
+# a duplicate pvid.
+if lvmdevices; then
+	lvmdevices -y --adddev "$dev2"
+fi
+
 # Verify pvs works on each device to give us vgname
 aux hide_dev "$dev2"
 check pv_field "$dev1" vg_name $vg1
@@ -55,9 +69,16 @@ aux hide_dev "$dev1"
 check pv_field "$dev2" vg_name $vg1
 aux unhide_dev "$dev1"
 
+lvmdevices || true
+pvs -a -o+uuid
+
 # Import the cloned PV to a new VG
 vgimportclone --basevgname $vg2 "$dev2"
 
+lvmdevices || true
+pvs -a -o+uuid
+vgs
+
 # Verify we can activate / deactivate the LV from both VGs
 lvchange -ay $vg1/$lv1 $vg2/$lv1
 vgchange -an $vg1 $vg2
diff --git a/tools/vgimportclone.c b/tools/vgimportclone.c
index 55a2deb4d..8aa0dbba9 100644
--- a/tools/vgimportclone.c
+++ b/tools/vgimportclone.c
@@ -160,7 +160,7 @@ static int _update_vg(struct cmd_context *cmd, struct volume_group *vg,
 	 * will be included in the metadata.  The device file is written
 	 * (with these additions) at the end of the command.
 	 */
-	if (vp->import_devices) {
+	if (vp->import_devices || cmd->enable_devices_file) {
 		dm_list_iterate_items(devl, &vp->new_devs) {
 			if (!device_id_add(cmd, devl->dev, devl->dev->pvid, NULL, NULL)) {
 				log_error("Failed to add device id for %s.", dev_name(devl->dev));
@@ -506,7 +506,7 @@ retry_name:
 	 * Should we be using device_ids_validate to check/fix other
 	 * devs in the devices file?
 	 */
-	if (vp.import_devices) {
+	if (vp.import_devices || cmd->enable_devices_file) {
 		if (!device_ids_write(cmd)) {
 			log_error("Failed to write devices file.");
 			goto out;


