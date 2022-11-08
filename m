From: David Teigland <teigland@sourceware.org>
Date: Tue,  8 Nov 2022 14:51:04 +0000 (GMT)
Subject: rhel-8.8.0 - devices file: fix pvcreate --uuid matching pvid entry with no device id
Message-ID: <20221108145104.99CF1385842F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=87904fbbb84c10e6f733db1c5ba447537d1cf08c
Commit:        87904fbbb84c10e6f733db1c5ba447537d1cf08c
Parent:        377ed7d9bac948e1be97e78aa9f9e525e9af470d
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Aug 19 13:31:22 2022 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Nov 2 13:23:52 2022 -0500

devices file: fix pvcreate --uuid matching pvid entry with no device id

pvcreate with --uuid would segfault if a devices file entry matched
the specified pvid, but the devices file entry had no device_id, which
could happen if the entry has a devname idtype.
---
 lib/device/device_id.c            |  7 ++++---
 test/shell/devicesfile-devname.sh | 13 +++++++++++++
 2 files changed, 17 insertions(+), 3 deletions(-)

diff --git a/lib/device/device_id.c b/lib/device/device_id.c
index 4d8fa5c9c..c3816a66c 100644
--- a/lib/device/device_id.c
+++ b/lib/device/device_id.c
@@ -1142,8 +1142,9 @@ id_done:
 			  du_devname->devname);
 
 	if (du_pvid && (du_pvid->dev != dev))
-		log_warn("WARNING: adding device %s with PVID %s which is already used for %s.",
-			 dev_name(dev), pvid, du_pvid->dev ? dev_name(du_pvid->dev) : "missing device");
+		log_warn("WARNING: adding device %s with PVID %s which is already used for %s device_id %s.",
+			 dev_name(dev), pvid, du_pvid->dev ? dev_name(du_pvid->dev) : "missing device",
+			 du_pvid->idname ?: "none");
 
 	if (du_devid && (du_devid->dev != dev)) {
 		if (!du_devid->dev) {
@@ -1189,7 +1190,7 @@ id_done:
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
 

