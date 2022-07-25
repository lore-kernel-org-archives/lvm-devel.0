From: David Teigland <teigland@sourceware.org>
Date: Mon, 25 Jul 2022 18:56:16 +0000 (GMT)
Subject: main - apply multipath_component_detection=0 to duplicate PV handling
Message-ID: <20220725185616.D878D3858413@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=99ce09ae778c2cc4aa2611e425bba5287b8b9513
Commit:        99ce09ae778c2cc4aa2611e425bba5287b8b9513
Parent:        c0f8e6675c62332263acdc7c3c2f61eca20bd60f
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Jul 25 13:50:43 2022 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Jul 25 13:50:43 2022 -0500

apply multipath_component_detection=0 to duplicate PV handling

multipath_component_detection=0 has always applied to the filter-based
component detection.  Also apply this setting to the duplicate-PV
handling which also eliminates multipath components (based on duplicate
PVs having the same wwid.)
---
 lib/cache/lvmcache.c                  |  3 +++
 test/shell/duplicate-pvs-multipath.sh | 10 +++++++---
 2 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index a1c4a61c8..00916885c 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -652,6 +652,9 @@ static int _all_multipath_components(struct cmd_context *cmd, struct lvmcache_in
 
 	*dev_mpath = NULL;
 
+	if (!find_config_tree_bool(cmd, devices_multipath_component_detection_CFG, NULL))
+		return 0;
+
 	/* This function only makes sense with more than one dev. */
 	if ((info && dm_list_empty(altdevs)) || (!info && (dm_list_size(altdevs) == 1))) {
 		log_debug("Skip multipath component checks with single device for PVID %s", pvid);
diff --git a/test/shell/duplicate-pvs-multipath.sh b/test/shell/duplicate-pvs-multipath.sh
index 59c15b0d4..bc98d2d5a 100644
--- a/test/shell/duplicate-pvs-multipath.sh
+++ b/test/shell/duplicate-pvs-multipath.sh
@@ -24,9 +24,13 @@ modprobe --dry-run scsi_debug || skip
 multipath -l || skip
 multipath -l | grep scsi_debug && skip
 
-# Turn off multipath_component_detection so that the duplicate
-# resolution of mpath components is used.
-aux lvmconf 'devices/multipath_component_detection = 0'
+# FIXME: setting multipath_component_detection=0 now also disables
+# the wwid-based mpath component detection, so this test will need
+# to find another way to disable only the filter-mpath code (using
+# sysfs and multipath/wwids) while keeping the code enabled that
+# eliminates duplicates based on their matching wwids which this
+# tries to test.
+
 # Prevent wwids from being used for filtering.
 aux lvmconf 'devices/multipath_wwids_file = "/dev/null"'
 # Need to use /dev/mapper/mpath

