From: David Teigland <teigland@sourceware.org>
Date: Tue, 21 May 2019 13:21:23 -0400
Subject: master - scan: expand and update label scan comments
Message-ID: <201905211721.x4LHLNd2013684@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=dc1e12dcd423cf912489e1ed380fa6eb1a049f2e
Commit:        dc1e12dcd423cf912489e1ed380fa6eb1a049f2e
Parent:        60bf9c9f331fb0282b1ceca57148aad54cb943a0
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue May 21 12:02:40 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue May 21 12:02:40 2019 -0500

scan: expand and update label scan comments

---
 lib/label/label.c |   89 ++++++++++++++++++++++++++++++++++++----------------
 1 files changed, 61 insertions(+), 28 deletions(-)

diff --git a/lib/label/label.c b/lib/label/label.c
index b999f87..43b05a2 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -847,8 +847,11 @@ static void _free_hints(struct dm_list *hints)
 }
 
 /*
- * Scan and cache lvm data from all devices on the system.
- * The cache should be empty/reset before calling this.
+ * Scan devices on the system to discover which are LVM devices.
+ * Info about the LVM devices (PVs) is saved in lvmcache in a
+ * basic/summary form (info/vginfo structs).  The vg_read phase
+ * uses this summary info to know which PVs to look at for
+ * processing a given VG.
  */
 
 int label_scan(struct cmd_context *cmd)
@@ -860,7 +863,8 @@ int label_scan(struct cmd_context *cmd)
 	struct device_list *devl, *devl2;
 	struct device *dev;
 	uint64_t max_metadata_size_bytes;
-	int newhints = 0;
+	int using_hints;
+	int create_hints = 0; /* NEWHINTS_NONE */
 
 	log_debug_devs("Finding devices to scan");
 
@@ -869,20 +873,37 @@ int label_scan(struct cmd_context *cmd)
 	dm_list_init(&hints_list);
 
 	/*
-	 * Iterate through all the devices in dev-cache (block devs that appear
-	 * under /dev that could possibly hold a PV and are not excluded by
-	 * filters).  Read each to see if it's an lvm device, and if so
-	 * populate lvmcache with some basic info about the device and the VG
-	 * on it.  This info will be used by the vg_read() phase of the
-	 * command.
+	 * dev_cache_scan() creates a list of devices on the system
+	 * (saved in in dev-cache) which we can iterate through to
+	 * search for LVM devs.  The dev cache list either comes from
+	 * looking at dev nodes under /dev, or from udev.
 	 */
 	dev_cache_scan();
 
+	/*
+	 * Set up the iterator that is needed to step through each device in
+	 * dev cache.
+	 */
 	if (!(iter = dev_iter_create(cmd->filter, 0))) {
 		log_error("Scanning failed to get devices.");
 		return 0;
 	}
 
+	log_debug_devs("Filtering devices to scan");
+
+	/*
+	 * Iterate through all devices in dev cache and apply filters
+	 * to exclude devs that we do not need to scan.  Those devs
+	 * that pass the filters are returned by the iterator and
+	 * saved in a list of devs that we will proceed to scan to
+	 * check if they are LVM devs.  IOW this loop is the
+	 * application of filters (those that do not require reading
+	 * the devs) to the list of all devices.  It does that because
+	 * the 'cmd->filter' is used above when setting up the iterator.
+	 * Unfortunately, it's not obvious that this is what's happening
+	 * here.  filters that require reading the device are not applied
+	 * here, but in process_block(), see DEV_FILTER_AFTER_SCAN.
+	 */
 	while ((dev = dev_iter_get(cmd, iter))) {
 		if (!(devl = zalloc(sizeof(*devl))))
 			continue;
@@ -901,13 +922,12 @@ int label_scan(struct cmd_context *cmd)
 		/*
 		 * When md devices exist that use the old superblock at the
 		 * end of the device, then in order to detect and filter out
-		 * the component devices of those md devs, we need to enable
-		 * the full md filter which scans both the start and the end
-		 * of every device.  This doubles the amount of scanning i/o,
-		 * which we want to avoid.  FIXME: it may not be worth the
-		 * cost of double i/o just to avoid displaying md component
-		 * devs in 'pvs', which is a pretty harmless effect from a
-		 * pretty uncommon situation.
+		 * the component devices of those md devs, we enable the full
+		 * md filter which scans both the start and the end of every
+		 * device.  This doubles the amount of scanning i/o, which we
+		 * want to avoid.  FIXME: this forces start+end scanning of
+		 * every device, but it would be more efficient to limit the
+		 * end scan only to PVs.
 		 */
 		if (dev_is_md_with_end_superblock(cmd->dev_types, dev))
 			cmd->use_full_md_check = 1;
@@ -920,7 +940,10 @@ int label_scan(struct cmd_context *cmd)
 	}
 
 	/*
-	 * In some common cases we can avoid scanning all devices.
+	 * In some common cases we can avoid scanning all devices
+	 * by using hints which tell us which devices are PVs, which
+	 * are the only devices we actually need to scan.  Without
+	 * hints we need to scan all devs to find which are PVs.
 	 *
 	 * TODO: if the command is using hints and a single vgname
 	 * arg, we can also take the vg lock here, prior to scanning.
@@ -930,10 +953,12 @@ int label_scan(struct cmd_context *cmd)
 	 * able to avoid rescan in vg_read, but locking early would
 	 * apply to more cases.)
 	 */
-	if (!get_hints(cmd, &hints_list, &newhints, &all_devs, &scan_devs)) {
+	if (!get_hints(cmd, &hints_list, &create_hints, &all_devs, &scan_devs)) {
 		dm_list_splice(&scan_devs, &all_devs);
 		dm_list_init(&hints_list);
-	}
+		using_hints = 0;
+	} else
+		using_hints = 1;
 
 	log_debug("Will scan %d devices skip %d", dm_list_size(&scan_devs), dm_list_size(&all_devs));
 
@@ -979,17 +1004,18 @@ int label_scan(struct cmd_context *cmd)
 
 	dm_list_init(&cmd->hints);
 
-	if (!dm_list_empty(&hints_list)) {
+	/*
+	 * If we're using hints to limit which devs we scanned, verify
+	 * that those hints were valid, and if not we need to scan the
+	 * rest of the devs.
+	 */
+	if (using_hints) {
 		if (!validate_hints(cmd, &hints_list)) {
-			/*
-			 * We scanned a subset of all devices based on hints.
-			 * With the results from the scan we may decide that
-			 * the hints are not valid, so scan all others.
-			 */
 			log_debug("Will scan %d remaining devices", dm_list_size(&all_devs));
 			_scan_list(cmd, cmd->filter, &all_devs, NULL);
 			_free_hints(&hints_list);
-			newhints = 0;
+			using_hints = 0;
+			create_hints = 0;
 		} else {
 			/* The hints may be used by another device iteration. */
 			dm_list_splice(&cmd->hints, &hints_list);
@@ -1006,8 +1032,15 @@ int label_scan(struct cmd_context *cmd)
 		free(devl);
 	}
 
-	if (newhints)
-		write_hint_file(cmd, newhints);
+	/*
+	 * If hints were not available/usable, then we scanned all devs,
+	 * and we now know which are PVs.  Save this list of PVs we've
+	 * identified as hints for the next command to use.
+	 * (create_hints variable has NEWHINTS_X value which indicates
+	 * the reason for creating the new hints.)
+	 */
+	if (create_hints)
+		write_hint_file(cmd, create_hints);
 
 	return 1;
 }


