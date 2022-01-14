From: David Teigland <teigland@sourceware.org>
Date: Fri, 14 Jan 2022 20:26:17 +0000 (GMT)
Subject: main - pvcreate: overwrite partition header with -f
Message-ID: <20220114202617.10F5C3858403@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d5a950ca67c106403054ecb847e226e8b5a7c30e
Commit:        d5a950ca67c106403054ecb847e226e8b5a7c30e
Parent:        0c80ea88477b3511562036748d3bf837bf7b3e8b
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Sep 8 16:30:11 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Jan 14 13:57:20 2022 -0600

pvcreate: overwrite partition header with -f

$ pvcreate /dev/sdc
  Cannot use /dev/sdc: device is partitioned
$ pvcreate -f /dev/sdc
  Physical volume "/dev/sdc" successfully created.
---
 lib/commands/toolcontext.h       |  1 +
 lib/filters/filter-partitioned.c |  3 +++
 man/pvcreate.8_des               |  7 ++++---
 test/shell/test-partition.sh     | 12 ++++++++++--
 tools/toollib.c                  | 10 ++++++++++
 5 files changed, 28 insertions(+), 5 deletions(-)

diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index f16322d4e..9c24559a6 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -204,6 +204,7 @@ struct cmd_context {
 	unsigned udevoutput:1;
 	unsigned online_vg_file_removed:1;
 	unsigned disable_dm_devs:1;		/* temporarily disable use of dm devs cache */
+	unsigned filter_partitioned_skip:1;	/* don't use filter-partitioned */
 
 	/*
 	 * Devices and filtering.
diff --git a/lib/filters/filter-partitioned.c b/lib/filters/filter-partitioned.c
index 642553ef2..8f468a567 100644
--- a/lib/filters/filter-partitioned.c
+++ b/lib/filters/filter-partitioned.c
@@ -27,6 +27,9 @@ static int _passes_partitioned_filter(struct cmd_context *cmd, struct dev_filter
 	if (cmd->filter_nodata_only)
 		return 1;
 
+	if (cmd->filter_partitioned_skip)
+		return 1;
+
 	dev->filtered_flags &= ~DEV_FILTERED_PARTITIONED;
 
 	ret = dev_is_partitioned(cmd, dev);
diff --git a/man/pvcreate.8_des b/man/pvcreate.8_des
index 69bd133aa..4048eb71c 100644
--- a/man/pvcreate.8_des
+++ b/man/pvcreate.8_des
@@ -7,9 +7,10 @@ Use \fBvgcreate\fP(8) to create a new VG on the PV, or \fBvgextend\fP(8)
 to add the PV to an existing VG.  Use \fBpvremove\fP(8) to remove the LVM
 disk label from the device.
 .P
-The force option will create a PV without confirmation.  Repeating the
-force option (\fB-ff\fP) will forcibly create a PV, overriding checks that
-normally prevent it, e.g. if the PV is already in a VG.
+The force option will create a PV without confirmation, and will overwrite
+partition headers.  Repeating the force option (\fB-ff\fP) will override other
+checks that would normally prevent a pvcreate, e.g. if the PV is already in a
+VG.
 .P
 .B Metadata location, size, and alignment
 .P
diff --git a/test/shell/test-partition.sh b/test/shell/test-partition.sh
index 0e92f00db..3a45f9089 100644
--- a/test/shell/test-partition.sh
+++ b/test/shell/test-partition.sh
@@ -16,7 +16,6 @@
 #
 
 
-
 SKIP_WITH_LVMPOLLD=1
 
 LVM_TEST_CONFIG_DEVICES="types = [\"device-mapper\", 142]"
@@ -25,7 +24,7 @@ LVM_TEST_CONFIG_DEVICES="types = [\"device-mapper\", 142]"
 
 which sfdisk || skip
 
-aux prepare_pvs 1 30
+aux prepare_pvs 2 30
 
 pvs "$dev1"
 
@@ -33,3 +32,12 @@ pvs "$dev1"
 echo "1 2" | sfdisk --force "$dev1"
 
 not pvs "$dev1"
+
+wipefs -a "$dev2"
+echo "1 2" | sfdisk --force "$dev2"
+partprobe
+not pvcreate "$dev2"
+pvcreate -f "$dev2"
+pvs "$dev2"
+pvremove "$dev2"
+
diff --git a/tools/toollib.c b/tools/toollib.c
index f95c98f51..9b193bd2d 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -5248,6 +5248,10 @@ int pvcreate_each_device(struct cmd_context *cmd,
 	if (cmd->enable_devices_file && !pp->is_remove)
 		cmd->filter_deviceid_skip = 1;
 
+	/* pvcreate -f overwrites partitions */
+	if (pp->force && !pp->is_remove)
+		cmd->filter_partitioned_skip = 1;
+
 	log_debug("Scanning and filtering device args (%u).", dm_list_size(&scan_devs));
 	label_scan_devs(cmd, cmd->filter, &scan_devs);
 
@@ -5262,6 +5266,7 @@ int pvcreate_each_device(struct cmd_context *cmd,
 		}
 	}
 	cmd->filter_deviceid_skip = 0;
+	cmd->filter_partitioned_skip = 0;
 
 	/*
 	 * Can the command continue if some specified devices were not found?
@@ -5474,6 +5479,9 @@ do_command:
 	if (cmd->enable_devices_file && !pp->is_remove)
 		cmd->filter_deviceid_skip = 1;
 
+	if (pp->force && !pp->is_remove)
+		cmd->filter_partitioned_skip = 1;
+
 	log_debug("Rescanning and filtering device args with exclusive open");
 	if (!label_scan_devs_excl(cmd, cmd->filter, &rescan_devs)) {
 		log_debug("Failed to rescan devs excl");
@@ -5487,7 +5495,9 @@ do_command:
 			dm_list_add(&pp->arg_fail, &pd->list);
 		}
 	}
+
 	cmd->filter_deviceid_skip = 0;
+	cmd->filter_partitioned_skip = 0;
 
 	if (dm_list_empty(&pp->arg_process) && dm_list_empty(&remove_duplicates)) {
 		log_debug("No devices to process.");


