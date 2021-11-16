From: David Teigland <teigland@sourceware.org>
Date: Tue, 16 Nov 2021 15:34:25 +0000 (GMT)
Subject: main - device_id: fix search on filtered device
Message-ID: <20211116153425.824463857027@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fee39370020424234bee1295cac480afeef72fd6
Commit:        fee39370020424234bee1295cac480afeef72fd6
Parent:        8e61c0ad6ecad5e0bcee09e44029e39396c1b59a
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Nov 16 09:29:24 2021 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Nov 16 09:29:24 2021 -0600

device_id: fix search on filtered device

When devnames are used as device ids and devnames change,
then new devices need to be located for the PVs.  If the old
devname is now used by a filtered device, this was preventing
the code from searching for the new device, so the PV was
reported as missing.
---
 lib/device/device_id.c            | 16 +++++++--
 test/shell/devicesfile-devname.sh | 69 +++++++++++++++++++++++++++++++++++++++
 2 files changed, 83 insertions(+), 2 deletions(-)

diff --git a/lib/device/device_id.c b/lib/device/device_id.c
index 749acdf89..7bcaf3df4 100644
--- a/lib/device/device_id.c
+++ b/lib/device/device_id.c
@@ -2031,12 +2031,19 @@ void device_ids_find_renamed_devs(struct cmd_context *cmd, struct dm_list *dev_l
 	search_auto = !strcmp(cmd->search_for_devnames, "auto");
 
 	dm_list_iterate_items(du, &cmd->use_devices) {
-		if (du->dev)
-			continue;
 		if (!du->pvid)
 			continue;
 		if (du->idtype != DEV_ID_TYPE_DEVNAME)
 			continue;
+
+		/*
+		 * if the old incorrect devname is now a device that's
+		 * filtered and not scanned, e.g. an mpath component,
+		 * then we want to look for the pvid on a new device.
+		 */
+		if (du->dev && !du->dev->filtered_flags)
+			continue;
+
 		if (!(dil = dm_pool_zalloc(cmd->mem, sizeof(*dil))))
 			continue;
 
@@ -2061,6 +2068,11 @@ void device_ids_find_renamed_devs(struct cmd_context *cmd, struct dm_list *dev_l
 	 * the searched file, so a subsequent lvm command will do the search
 	 * again.  In future perhaps we could add a policy to automatically
 	 * remove a devices file entry that's not been found for some time.
+	 *
+	 * TODO: like the hint file, add a hash of all devnames to the searched
+	 * file so it can be ignored and removed if the devs/hash change.
+	 * If hints are enabled, the hints invalidation could also remove the
+	 * searched file.
 	 */
 	if (_searched_devnames_exists(cmd)) {
 		log_debug("Search for PVIDs skipped for %s", _searched_file);
diff --git a/test/shell/devicesfile-devname.sh b/test/shell/devicesfile-devname.sh
index 46f66a073..1b881c1cb 100644
--- a/test/shell/devicesfile-devname.sh
+++ b/test/shell/devicesfile-devname.sh
@@ -568,4 +568,73 @@ grep "$PVID2" "$DF" |tee out
 grep "$dev2" out
 not grep "$dev1" out
 
+vgchange -an $vg1
+vgchange -an $vg2
+vgremove -ff $vg1
+vgremove -ff $vg2
+
+# devnames change so the new devname now refers to a filtered device,
+# e.g. an mpath or md component, which is not scanned
+
+wait_md_create() {
+        local md=$1
+
+        while :; do
+                if ! grep "$(basename $md)" /proc/mdstat; then
+                        echo "$md not ready"
+                        cat /proc/mdstat
+                        sleep 2
+                else
+                        break
+                fi
+        done
+        echo "$md" > WAIT_MD_DEV
+}
+
+aux wipefs_a "$dev1"
+aux wipefs_a "$dev2"
+aux wipefs_a "$dev3"
+aux wipefs_a "$dev4"
+
+mddev="/dev/md33"
+not grep $mddev /proc/mdstat || skip
+
+rm "$DF"
+touch "$DF"
+vgcreate $vg1 "$dev1" "$dev2"
+cat "$DF"
+cp "$DF" "$ORIG"
+
+# PVID with dashes for matching pvs -o+uuid output
+OPVID1=`pvs "$dev1" --noheading -o uuid | awk '{print $1}'`
+OPVID2=`pvs "$dev2" --noheading -o uuid | awk '{print $1}'`
+
+# PVID without dashes for matching devices file fields
+PVID1=`pvs "$dev1" --noheading -o uuid | tr -d - | awk '{print $1}'`
+PVID2=`pvs "$dev2" --noheading -o uuid | tr -d - | awk '{print $1}'`
+
+mdadm --create --metadata=1.0 "$mddev" --level 1 --chunk=64 --raid-devices=2 "$dev3" "$dev4"
+wait_md_create "$mddev"
+
+sed -e "s|DEVNAME=$dev1|DEVNAME=$dev3|" "$ORIG" > tmp1.devices
+sed -e "s|IDNAME=$dev1|IDNAME=$dev3|" tmp1.devices > "$DF"
+cat "$DF"
+pvs -o+uuid |tee out
+grep "$dev1" out
+grep "$dev2" out
+grep "$OPVID1" out
+grep "$OPVID2" out
+not grep "$dev3" out
+not grep "$dev4" out
+
+grep "$dev1" "$DF"
+grep "$dev2" "$DF"
+grep "$PVID1" "$DF"
+grep "$PVID2" "$DF"
+not grep "$dev3" "$DF"
+not grep "$dev4" "$DF"
+
+mdadm --stop "$mddev"
+aux udev_wait
+
 vgremove -ff $vg1


