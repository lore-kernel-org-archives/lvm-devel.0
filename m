From: David Teigland <teigland@sourceware.org>
Date: Fri, 19 Aug 2022 18:32:15 +0000 (GMT)
Subject: main - devices file: fix pvcreate --uuid matching pvid entry with no device id
Message-ID: <20220819183215.1741E3858C52@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8c3cfc75c72696ae8b620555fcc4f815b0c1d6b6
Commit:        8c3cfc75c72696ae8b620555fcc4f815b0c1d6b6
Parent:        1a981e9b6efb0bbc0881f5ed1f17900e9c669f48
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Aug 19 13:31:22 2022 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Aug 19 13:34:36 2022 -0500

devices file: fix pvcreate --uuid matching pvid entry with no device id

pvcreate with --uuid would segfault if a devices file entry matched
the specified pvid, but the devices file entry had no device_id, which
could happen if the entry has a devname idtype.
---
 lib/device/device_id.c            |  7 ++++---
 test/shell/devicesfile-devname.sh | 13 +++++++++++++
 2 files changed, 17 insertions(+), 3 deletions(-)

diff --git a/lib/device/device_id.c b/lib/device/device_id.c
index 9dec9f884..6c70f110c 100644
--- a/lib/device/device_id.c
+++ b/lib/device/device_id.c
@@ -1168,8 +1168,9 @@ id_done:
 			  du_devname->devname);
 
 	if (du_pvid && (du_pvid->dev != dev))
-		log_warn("WARNING: adding device %s with PVID %s which is already used for %s.",
-			 dev_name(dev), pvid, du_pvid->dev ? dev_name(du_pvid->dev) : "missing device");
+		log_warn("WARNING: adding device %s with PVID %s which is already used for %s device_id %s.",
+			 dev_name(dev), pvid, du_pvid->dev ? dev_name(du_pvid->dev) : "missing device",
+			 du_pvid->idname ?: "none");
 
 	if (du_devid && (du_devid->dev != dev)) {
 		if (!du_devid->dev) {
@@ -1215,7 +1216,7 @@ id_done:
 		else
 			check_idname = device_id_system_read(cmd, dev, du_pvid->idtype);
 
-		if (check_idname && !strcmp(check_idname, du_pvid->idname)) {
+		if (!du_pvid->idname || (check_idname && !strcmp(check_idname, du_pvid->idname))) {
 			update_du = du_pvid;
 			dm_list_del(&update_du->list);
 			update_matching_kind = "PVID";
diff --git a/test/shell/devicesfile-devname.sh b/test/shell/devicesfile-devname.sh
index 338637275..211f4dbed 100644
--- a/test/shell/devicesfile-devname.sh
+++ b/test/shell/devicesfile-devname.sh
@@ -550,6 +550,19 @@ vgchange -an $vg2
 vgremove -ff $vg1
 vgremove -ff $vg2
 
+# bz 2119473
+
+aux lvmconf "devices/search_for_devnames = \"none\""
+sed -e "s|DEVNAME=$dev1|DEVNAME=.|" "$ORIG" > tmp1.devices
+sed -e "s|IDNAME=$dev1|IDNAME=.|" tmp1.devices > "$DF"
+pvs
+lvmdevices
+pvcreate -ff --yes --uuid "$PVID1" --norestorefile $dev1
+grep "$PVID1" "$DF" |tee out
+grep "DEVNAME=$dev1" out
+grep "IDNAME=$dev1" out
+aux lvmconf "devices/search_for_devnames = \"auto\""
+
 # devnames change so the new devname now refers to a filtered device,
 # e.g. an mpath or md component, which is not scanned
 

