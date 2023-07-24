From: David Teigland (@teigland) <gitlab@mg.gitlab.com>
Date: Mon, 24 Jul 2023 19:57:47 +0000
Subject: [Git][lvmteam/lvm2][main] lvmdevices: add --delnotfound to delete entries for missing devices
Message-ID: <64bed7bb84dc3_28270bb4158c5@gitlab-sidekiq-low-urgency-cpu-bound-v2-5b8d8547f9-hgrsz.mail>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit



David Teigland pushed to branch main at LVM team / lvm2


Commits:
7cc41413 by David Teigland at 2023-07-24T14:56:32-05:00
lvmdevices: add --delnotfound to delete entries for missing devices

Used with update: lvmdevices --update --delnotfound.
Removes all devices file entries for which no matching device is found.

- - - - -


4 changed files:

- test/shell/devicesfile-edit.sh
- tools/args.h
- tools/command-lines.in
- tools/lvmdevices.c


Changes:

=====================================
test/shell/devicesfile-edit.sh
=====================================
@@ -241,6 +241,16 @@ not grep "$PVID2" $DF
 setup_loop_devs
 rm $DF
 
+# test delnotfound
+lvmdevices --addpvid "$PVID1"
+echo "IDTYPE=sys_wwid IDNAME=naa.123 DEVNAME=/dev/sdx1 PVID=aaa PART=1" >> $DF
+echo "IDTYPE=devname IDNAME=/dev/sdy DEVNAME=/dev/sdy PVID=bbb" >> $DF
+lvmdevices
+lvmdevices --update --delnotfound
+not grep PVID=aaa $DF
+not grep PVID=bbb $DF
+
+
 # TODO: add/rem of partitions of same device
 
 losetup -D


=====================================
tools/args.h
=====================================
@@ -52,6 +52,9 @@ arg(deldev_ARG, '\0', "deldev", string_VAL, 0, 0,
     "When used alone, --deldev specifies a device name.\n"
     "When used with --deviceidtype, --deldev specifies a device id.\n")
 
+arg(delnotfound_ARG, '\0', "delnotfound", 0, 0, 0,
+    "Remove devices file entries with no matching device.\n")
+
 arg(addpvid_ARG, '\0', "addpvid", string_VAL, 0, 0,
     "Find a device with the PVID and add the device to the devices file.\n")
 arg(delpvid_ARG, '\0', "delpvid", string_VAL, 0, 0,


=====================================
tools/command-lines.in
=====================================
@@ -1445,6 +1445,7 @@ ID: lvmdevices_check
 DESC: Check the devices file and report incorrect values.
 
 lvmdevices --update
+OO: --delnotfound
 ID: lvmdevices_update
 DESC: Update the devices file to fix incorrect values.
 


=====================================
tools/lvmdevices.c
=====================================
@@ -293,6 +293,18 @@ int lvmdevices(struct cmd_context *cmd, int argc, char **argv)
 				label_scan_invalidate(du->dev);
 		}
 
+		if (arg_is_set(cmd, delnotfound_ARG)) {
+			dm_list_iterate_items_safe(du, du2, &cmd->use_devices) {
+				if (!du->dev) {
+					log_print("Deleting IDTYPE=%s IDNAME=%s PVID=%s",
+						  idtype_to_str(du->idtype), du->idname ?: ".", du->pvid ?: ".");
+					dm_list_del(&du->list);
+					free_du(du);
+					update_needed++;
+				}
+			}
+		}
+
 		if (arg_is_set(cmd, update_ARG)) {
 			if (update_needed || serial_update_needed || !dm_list_empty(&found_devs)) {
 				if (!device_ids_write(cmd))



View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/commit/7cc414135a5afd5b5536eb3e2b612cdec7be72ab

-- 
View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/commit/7cc414135a5afd5b5536eb3e2b612cdec7be72ab
You're receiving this email because of your account on gitlab.com.


-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20230724/8c8ab404/attachment-0001.htm>
