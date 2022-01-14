From: David Teigland <teigland@sourceware.org>
Date: Fri, 14 Jan 2022 21:53:51 +0000 (GMT)
Subject: stable-2.03.14 - lvmdevices check: error exit if update is needed
Message-ID: <20220114215351.141193858C39@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bb477d63e336a10e5959962a9f26a028ea9e55eb
Commit:        bb477d63e336a10e5959962a9f26a028ea9e55eb
Parent:        a5c37afdca97d6565ea02bc4bc7d52f360823cd3
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Jan 13 14:52:54 2022 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Jan 14 15:53:13 2022 -0600

lvmdevices check: error exit if update is needed

. error exit means that lvmdevices --update would make a change.

. remove check of PART field from --check because it isn't used.

. unlink searched_devnames file to ensure check|update will search
---
 lib/device/device_id.c             |  3 ++-
 test/shell/devicesfile-realdevs.sh |  8 ++++----
 tools/args.h                       |  3 ++-
 tools/lvmdevices.c                 | 37 ++++++++++++++++---------------------
 4 files changed, 24 insertions(+), 27 deletions(-)

diff --git a/lib/device/device_id.c b/lib/device/device_id.c
index 0621bc858..a33dcebe0 100644
--- a/lib/device/device_id.c
+++ b/lib/device/device_id.c
@@ -2271,7 +2271,8 @@ void device_ids_find_renamed_devs(struct cmd_context *cmd, struct dm_list *dev_l
 			continue;
 		}
 
-		log_warn("Devices file PVID %s updating IDNAME to %s.", dev->pvid, devname);
+		if (!noupdate)
+			log_warn("Devices file PVID %s updating IDNAME to %s.", dev->pvid, devname);
 
 		free(du->idname);
 		free(du->devname);
diff --git a/test/shell/devicesfile-realdevs.sh b/test/shell/devicesfile-realdevs.sh
index 8d4aa3e67..23d4bedb4 100644
--- a/test/shell/devicesfile-realdevs.sh
+++ b/test/shell/devicesfile-realdevs.sh
@@ -423,7 +423,7 @@ sed "s/$pvid1/badpvid/" "$DF.orig" |tee $DF
 not grep $pvid1 $DF
 grep $did1 $DF
 
-lvmdevices --check 2>&1|tee out
+not lvmdevices --check 2>&1|tee out
 grep $dev1 out
 grep badpvid out
 grep $pvid1 out
@@ -493,7 +493,7 @@ rm $DF
 d1=$(basename $dev1)
 d3=$(basename $dev3)
 sed "s/$d1/$d3/" "$DF.orig" |tee $DF
-lvmdevices --check 2>&1 |tee out
+not lvmdevices --check 2>&1 |tee out
 grep $dev1 out
 
 lvmdevices --update
@@ -515,7 +515,7 @@ sed "s/$d1/tmp/" "$DF.orig" |tee ${DF}_1
 sed "s/$d2/$d1/" "${DF}_1" |tee ${DF}_2
 sed "s/tmp/$d2/" "${DF}_2" |tee $DF
 rm ${DF}_1 ${DF}_2
-lvmdevices --check 2>&1 |tee out
+not lvmdevices --check 2>&1 |tee out
 grep $dev1 out
 grep $dev2 out
 
@@ -536,7 +536,7 @@ rm $DF
 d1=$(basename $dev1)
 d3=$(basename $dev3)
 sed "s/$d1/$d3/" "$DF.orig" |tee $DF
-lvmdevices --check 2>&1 |tee out
+not lvmdevices --check 2>&1 |tee out
 grep $dev1 out
 
 pvs -o+uuid,deviceid | grep $vg |tee out
diff --git a/tools/args.h b/tools/args.h
index 774ce33f4..9a7bf81b2 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -153,7 +153,8 @@ arg(cachesize_ARG, '\0', "cachesize", sizemb_VAL, 0, 0,
     "The size of cache to use.\n")
 
 arg(check_ARG, '\0', "check", 0, 0, 0,
-    "Check the content of the devices file.\n")
+    "Checks the content of the devices file.\n"
+    "Reports incorrect device names or PVIDs for entries.\n")
 
 arg(commandprofile_ARG, '\0', "commandprofile", string_VAL, 0, 0,
     "The command profile to use for command configuration.\n"
diff --git a/tools/lvmdevices.c b/tools/lvmdevices.c
index 3f104f7de..c50c09f90 100644
--- a/tools/lvmdevices.c
+++ b/tools/lvmdevices.c
@@ -128,7 +128,6 @@ int lvmdevices(struct cmd_context *cmd, int argc, char **argv)
 	struct device *dev;
 	struct dev_use *du, *du2;
 	const char *deviceidtype;
-	int changes = 0;
 
 	dm_list_init(&search_pvids);
 	dm_list_init(&found_devs);
@@ -184,8 +183,11 @@ int lvmdevices(struct cmd_context *cmd, int argc, char **argv)
 
 	if (arg_is_set(cmd, check_ARG) || arg_is_set(cmd, update_ARG)) {
 		int search_count = 0;
+		int update_needed = 0;
 		int invalid = 0;
 
+		unlink_searched_devnames(cmd);
+
 		label_scan_setup_bcache();
 
 		dm_list_iterate_items(du, &cmd->use_devices) {
@@ -225,6 +227,8 @@ int lvmdevices(struct cmd_context *cmd, int argc, char **argv)
 		 * run just above.
 		 */
 		device_ids_validate(cmd, NULL, &invalid, 1);
+		if (invalid)
+			update_needed = 1;
 
 		/*
 		 * Find and fix any devname entries that have moved to a
@@ -240,33 +244,24 @@ int lvmdevices(struct cmd_context *cmd, int argc, char **argv)
 				label_scan_invalidate(du->dev);
 		}
 
-		/*
-		 * check du->part
-		 */
-		dm_list_iterate_items(du, &cmd->use_devices) {
-			int part = 0;
-			if (!du->dev)
-				continue;
-			dev = du->dev;
-
-			dev_get_partition_number(dev, &part);
-
-			if (part != du->part) {
-				log_warn("Device %s partition %u has incorrect PART in devices file (%u)",
-					 dev_name(dev), part, du->part);
-				du->part = part;
-				changes++;
-			}
-		}
-
 		if (arg_is_set(cmd, update_ARG)) {
-			if (invalid || !dm_list_empty(&found_devs)) {
+			if (update_needed || !dm_list_empty(&found_devs)) {
 				if (!device_ids_write(cmd))
 					goto_bad;
 				log_print("Updated devices file to version %s", devices_file_version());
 			} else {
 				log_print("No update for devices file is needed.");
 			}
+		} else {
+			/*
+			 * --check exits with an error if the devices file
+			 * needs updates, i.e. running --update would make
+			 * changes.
+			 */
+			if (update_needed) {
+				log_error("Updates needed for devices file.");
+				goto bad;
+			}
 		}
 		goto out;
 	}


