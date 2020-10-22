From: David Teigland <teigland@sourceware.org>
Date: Thu, 22 Oct 2020 20:43:13 +0000 (GMT)
Subject: master - scanning: improve filtering control
Message-ID: <20201022204313.4E4BC385783D@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2c9bb676048fda86867df165aa297f7078dffc4b
Commit:        2c9bb676048fda86867df165aa297f7078dffc4b
Parent:        c74ccd5201d4566a77487d1aa89e72c254ea443d
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Oct 20 15:10:08 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Oct 21 16:24:16 2020 -0500

scanning: improve filtering control

Filtering in label_scan was controlled indirectly by
the fact that bcache was not yet set up when label_scan
first ran.  The result is that filters that needed data
would not run and would return -EAGAIN, which would
result in the dev flag FILTER_AFTER_SCAN being set.
After the dev header was read for checking the label,
filters would be rechecked because of FILTER_AFTER_SCAN.
All filters would be checked this time because bcache
was now set up, and the filters needing data would
largely use data already scanned for reading the label.
This design worked but is hard to adjust for future
cases where bcache is already set up.

Replace this method (based on setting up bcache, or not)
with a new cmd flag filter_nodata_only.  When this flag
is set filters that need data will not run.  This allows
the same label_scan behavior when bcache has been set up.
There are no expected changes in behavior.
---
 lib/label/label.c | 118 ++++++++++++++++++++++++++++++++----------------------
 1 file changed, 70 insertions(+), 48 deletions(-)

diff --git a/lib/label/label.c b/lib/label/label.c
index ec774dc6e..b06aaae00 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -362,34 +362,33 @@ static int _process_block(struct cmd_context *cmd, struct dev_filter *f,
 	uint64_t sector = 0;
 	int is_duplicate = 0;
 	int ret = 0;
-	int pass;
 
 	dev->flags &= ~DEV_SCAN_FOUND_LABEL;
 
 	/*
-	 * The device may have signatures that exclude it from being processed.
-	 * If filters were applied before bcache data was available, some
-	 * filters may have deferred their check until the point where bcache
-	 * data had been read (here).  They set this flag to indicate that the
-	 * filters should be retested now that data from the device is ready.
+	 * The device may have signatures that exclude it from being processed,
+	 * even if it might look like a PV.  Now that the device has been read
+	 * and data is available in bcache for it, recheck filters, including
+	 * those that use data.  The device needs to be excluded before it
+	 * begins to be processed as a PV.
 	 */
-	if (f && (dev->flags & DEV_FILTER_AFTER_SCAN)) {
-		dev->flags &= ~DEV_FILTER_AFTER_SCAN;
-
-		log_debug_devs("Scan filtering %s", dev_name(dev));
-		
-		pass = f->passes_filter(cmd, f, dev, NULL);
-
-		if ((pass == -EAGAIN) || (dev->flags & DEV_FILTER_AFTER_SCAN)) {
-			/* Shouldn't happen */
-			dev->flags &= ~DEV_FILTER_OUT_SCAN;
-			log_debug_devs("Scan filter should not be deferred %s", dev_name(dev));
-			pass = 1;
-		}
+	if (f) {
+		if (!f->passes_filter(cmd, f, dev, NULL)) {
+			/*
+			 * If this device was previously scanned (not common)
+			 * and if it passed filters at that point, lvmcache
+			 * info may have been saved for it.  Now the same
+			 * device is being scanned again, and it may fail
+			 * filters this time.  If the caller did not clear
+			 * lvmcache info for this dev before rescanning, do
+			 * that now.  It's unlikely this is actually needed.
+			 */
+			if (dev->pvid[0]) {
+				log_print("Clear pvid and info for filtered dev %s", dev_name(dev));
+				lvmcache_del_dev(dev);
+				memset(dev->pvid, 0, sizeof(dev->pvid));
+			}
 
-		if (!pass) {
-			log_very_verbose("%s: Not processing filtered", dev_name(dev));
-			dev->flags |= DEV_FILTER_OUT_SCAN;
 			*is_lvm_device = 0;
 			goto_out;
 		}
@@ -414,7 +413,12 @@ static int _process_block(struct cmd_context *cmd, struct dev_filter *f,
 
 		log_very_verbose("%s: No lvm label detected", dev_name(dev));
 
-		lvmcache_del_dev(dev); /* FIXME: if this is needed, fix it. */
+		/* See comment above */
+		if (dev->pvid[0]) {
+			log_print("Clear pvid and info for no lvm header %s", dev_name(dev));
+			lvmcache_del_dev(dev);
+			memset(dev->pvid, 0, sizeof(dev->pvid));
+		}
 
 		*is_lvm_device = 0;
 		goto out;
@@ -1009,6 +1013,7 @@ int label_scan_for_pvid(struct cmd_context *cmd, char *pvid, struct device **dev
 int label_scan(struct cmd_context *cmd)
 {
 	struct dm_list all_devs;
+	struct dm_list filtered_devs;
 	struct dm_list scan_devs;
 	struct dm_list hints_list;
 	struct dev_iter *iter;
@@ -1021,9 +1026,15 @@ int label_scan(struct cmd_context *cmd)
 	log_debug_devs("Finding devices to scan");
 
 	dm_list_init(&all_devs);
+	dm_list_init(&filtered_devs);
 	dm_list_init(&scan_devs);
 	dm_list_init(&hints_list);
 
+	if (!scan_bcache) {
+		if (!_setup_bcache())
+			return_0;
+	}
+
 	/*
 	 * dev_cache_scan() creates a list of devices on the system
 	 * (saved in in dev-cache) which we can iterate through to
@@ -1047,29 +1058,15 @@ int label_scan(struct cmd_context *cmd)
 	}
 
 	/*
-	 * Set up the iterator that is needed to step through each device in
-	 * dev cache.
+	 * Create a list of all devices in dev-cache (all found on the system.)
+	 * Do not apply filters and do not read any (the filter arg is NULL).
+	 * Invalidate bcache data for all devs (there will usually be no bcache
+	 * data to invalidate.)
 	 */
-	if (!(iter = dev_iter_create(cmd->filter, 0))) {
+	if (!(iter = dev_iter_create(NULL, 0))) {
 		log_error("Scanning failed to get devices.");
 		return 0;
 	}
-
-	log_debug_devs("Filtering devices to scan");
-
-	/*
-	 * Iterate through all devices in dev cache and apply filters
-	 * to exclude devs that we do not need to scan.  Those devs
-	 * that pass the filters are returned by the iterator and
-	 * saved in a list of devs that we will proceed to scan to
-	 * check if they are LVM devs.  IOW this loop is the
-	 * application of filters (those that do not require reading
-	 * the devs) to the list of all devices.  It does that because
-	 * the 'cmd->filter' is used above when setting up the iterator.
-	 * Unfortunately, it's not obvious that this is what's happening
-	 * here.  filters that require reading the device are not applied
-	 * here, but in process_block(), see DEV_FILTER_AFTER_SCAN.
-	 */
 	while ((dev = dev_iter_get(cmd, iter))) {
 		if (!(devl = zalloc(sizeof(*devl))))
 			continue;
@@ -1078,16 +1075,43 @@ int label_scan(struct cmd_context *cmd)
 
 		/*
 		 * label_scan should not generally be called a second time,
-		 * so this will usually not be true.
+		 * so this will usually do nothing.
 		 */
 		label_scan_invalidate(dev);
 	};
 	dev_iter_destroy(iter);
 
-	if (!scan_bcache) {
-		if (!_setup_bcache())
-			return 0;
+	/*
+	 * Exclude devices that fail nodata filters. (Those filters that can be
+	 * checked without reading data from the device.)
+	 *
+	 * The result of checking nodata filters is saved by the "persistent
+	 * filter", and this result needs to be cleared (wiped) so that the
+	 * complete set of filters (including those that require data) can be
+	 * checked in _process_block, where headers have been read.
+	 */
+	log_debug_devs("Filtering devices to scan (nodata)");
+
+	cmd->filter_nodata_only = 1;
+	dm_list_iterate_items_safe(devl, devl2, &all_devs) {
+		dev = devl->dev;
+		if (!cmd->filter->passes_filter(cmd, cmd->filter, dev, NULL)) {
+			dm_list_del(&devl->list);
+			dm_list_add(&filtered_devs, &devl->list);
+
+			if (dev->pvid[0]) {
+				log_print("Clear pvid and info for filtered dev %s", dev_name(dev));
+				lvmcache_del_dev(dev);
+				memset(dev->pvid, 0, sizeof(dev->pvid));
+			}
+		}
 	}
+	cmd->filter_nodata_only = 0;
+
+	dm_list_iterate_items(devl, &all_devs)
+		cmd->filter->wipe(cmd, cmd->filter, devl->dev, NULL);
+	dm_list_iterate_items(devl, &filtered_devs)
+		cmd->filter->wipe(cmd, cmd->filter, devl->dev, NULL);
 
 	/*
 	 * In some common cases we can avoid scanning all devices
@@ -1110,8 +1134,6 @@ int label_scan(struct cmd_context *cmd)
 	} else
 		using_hints = 1;
 
-	log_debug("Will scan %d devices skip %d", dm_list_size(&scan_devs), dm_list_size(&all_devs));
-
 	/*
 	 * If the total number of devices exceeds the soft open file
 	 * limit, then increase the soft limit to the hard/max limit


