From: David Teigland <teigland@sourceware.org>
Date: Mon, 22 Nov 2021 21:17:23 +0000 (GMT)
Subject: main - devices: exclude md components when duplicate pvs are seen
Message-ID: <20211122211723.09D5E385840E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=01bf8e174774359a5c65e7e712d208ff7194310b
Commit:        01bf8e174774359a5c65e7e712d208ff7194310b
Parent:        114e1cfee532eac7d594549f68f21e9f6ee67dc5
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Nov 22 15:10:43 2021 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Nov 22 15:10:43 2021 -0600

devices: exclude md components when duplicate pvs are seen

Improve handling of md components that get through the
filter, like the previous improvement for multipath.
If md components get through the filter and trigger
duplicate PV code, then eliminate any devs entirely
that are not an md device.
---
 lib/cache/lvmcache.c | 168 +++++++++++++++++++++++++++++++++++++++++++++------
 1 file changed, 149 insertions(+), 19 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index b3a4b5a71..c5359f3c5 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -683,7 +683,7 @@ static int _all_multipath_components(struct cmd_context *cmd, struct lvmcache_in
 			wwid = device_id_system_read(cmd, dev, DEV_ID_TYPE_SYS_WWID);
 
 		if (!wwid && wwid1) {
-			log_print("Different wwids for duplicate PVs %s %s %s none",
+			log_debug("Different wwids for duplicate PVs %s %s %s none",
 				  dev_name(dev1), wwid1, dev_name(dev));
 			diff_wwid++;
 			continue;
@@ -700,7 +700,7 @@ static int _all_multipath_components(struct cmd_context *cmd, struct lvmcache_in
 
 		/* Different wwids indicates these are not multipath components. */
 		if (strcmp(wwid1, wwid)) {
-			log_print("Different wwids for duplicate PVs %s %s %s %s",
+			log_debug("Different wwids for duplicate PVs %s %s %s %s",
 				  dev_name(dev1), wwid1, dev_name(dev), wwid);
 			diff_wwid++;
 			continue;
@@ -731,6 +731,52 @@ static int _all_multipath_components(struct cmd_context *cmd, struct lvmcache_in
 	return 1;
 }
 
+static int _all_md_components(struct cmd_context *cmd, struct lvmcache_info *info, const char *pvid,
+			      struct dm_list *altdevs, struct device **dev_md_out)
+{
+	struct device_list *devl;
+	struct device *dev_md = NULL;
+	struct device *dev;
+	int real_dup = 0;
+ 
+	*dev_md_out = NULL;
+
+	/* There will often be no info struct because of the extra_md_checks function. */
+ 
+	if (info && (cmd->dev_types->md_major == MAJOR(info->dev->dev)))
+		dev_md = info->dev;
+ 
+	dm_list_iterate_items(devl, altdevs) {
+		dev = devl->dev;
+ 
+		if (cmd->dev_types->md_major == MAJOR(dev->dev)) {
+			if (dev_md) {
+				/* md devs themselves are dups */
+				log_debug("Found multiple md devices for PVID %s: %s %s",
+					  pvid, dev_name(dev_md), dev_name(dev));
+				real_dup = 1;
+				break;
+			} else
+				dev_md = dev;
+		} else {
+			if (!dev_is_md_component(cmd, dev, NULL, 1)) {
+				/* md dev copied to another device */
+				real_dup = 1;
+				break;
+			}
+		}
+	}
+ 
+	if (real_dup)
+		return 0;
+ 
+	if (dev_md)
+		log_debug("Found md device %s for PVID %s.", dev_name(dev_md), pvid);
+ 
+	*dev_md_out = dev_md;
+	return 1;
+}
+
 /*
  * If we've found devices with the same PVID, decide which one
  * to use.
@@ -786,7 +832,7 @@ static void _choose_duplicates(struct cmd_context *cmd,
 	struct device_list *devl, *devl_safe, *devl_add, *devl_del;
 	struct lvmcache_info *info;
 	struct device *dev1, *dev2;
-	struct device *dev_mpath;
+	struct device *dev_mpath, *dev_md;
 	struct device *dev_drop;
 	const char *device_id = NULL, *device_id_type = NULL;
 	const char *idname1 = NULL, *idname2 = NULL;
@@ -811,6 +857,7 @@ next:
 	dm_list_init(&altdevs);
 	pvid = NULL;
 	dev_mpath = NULL;
+	dev_md = NULL;
 
 	dm_list_iterate_items_safe(devl, devl_safe, &_initial_duplicates) {
 		if (!pvid) {
@@ -839,6 +886,11 @@ next:
 	 * the md/mpath device gives us a last chance to drop the component.
 	 * An md/mpath component device is completely ignored, as if it had
 	 * been filtered, and not kept in the list unused duplicates.
+	 *
+	 * One issue related to eliminating mpath/md duplicate PVs here is
+	 * that it occurs after label_scan, and hints are created based
+	 * on what label_scan finds, so hints are disabled due to duplicate
+	 * PVs that are later resolved here.
 	 */
 
 	/*
@@ -908,24 +960,89 @@ next:
 
 	/*
 	 * Get rid of any md components.
-	 * FIXME: use a function like _all_multipath_components to pick the actual md device.
 	 */
-	if (info && dev_is_md_component(cmd, info->dev, NULL, 1)) {
-		/* does not go in del_cache_devs which become unused_duplicates */
-		log_debug("Ignoring md component %s with PVID %s (dropping info)", dev_name(info->dev), pvid);
-		lvmcache_del(info);
-		info = NULL;
-	}
+	if (_all_md_components(cmd, info, pvid, &altdevs, &dev_md)) {
+		if (info && dev_md && (info->dev != dev_md)) {
+			/*
+			 * info should be dropped from lvmcache and info->dev
+			 * should be treated as if it had been excluded by a filter.
+			 * dev_md should be added to lvmcache by the caller.
+			 * Often this info struct has been removed by
+			 * lvmcache_extra_md_component_checks.
+			 */
+			dev_drop = info->dev;
 
-	dm_list_iterate_items_safe(devl, devl_safe, &altdevs) {
-		if (dev_is_md_component(cmd, devl->dev, NULL, 1)) {
-			log_debug("Ignoring md component %s with PVID %s (dropping duplicate)", dev_name(devl->dev), pvid);
-			dm_list_del(&devl->list);
+			/* Have caller add dev_md to lvmcache. */
+			log_debug("Using md device %s for PVID %s.", dev_name(dev_md), pvid);
+			if ((devl_add = zalloc(sizeof(*devl_add)))) {
+				devl_add->dev = dev_md;
+				dm_list_add(add_cache_devs, &devl_add->list);
+			}
+
+			/* Remove dev_md from altdevs. */
+			if ((devl = _get_devl_in_device_list(dev_md, &altdevs)))
+				dm_list_del(&devl->list);
+
+			/* Remove info from lvmcache that came from the component dev. */
+			log_debug("Ignoring md component %s with PVID %s (dropping info)", dev_name(dev_drop), pvid);
+			lvmcache_del(info);
+			info = NULL;
+
+			/* Make the component dev look like it was filtered. */
+			cmd->filter->wipe(cmd, cmd->filter, dev_drop, NULL);
+			dev_drop->flags &= ~DEV_SCAN_FOUND_LABEL;
 		}
-	}
 
-	if (dm_list_empty(&altdevs))
+		if (!info && dev_md) {
+			/*
+			 * The info struct was from a component and was dropped
+			 * and the actual md dev was found on initial_duplicates
+			 * and the caller should add it to lvmcache.
+			 */
+
+			/* Have caller add dev_md to lvmcache. */
+			log_debug("Using md device %s for PVID %s.", dev_name(dev_md), pvid);
+			if ((devl_add = zalloc(sizeof(*devl_add)))) {
+				devl_add->dev = dev_md;
+				dm_list_add(add_cache_devs, &devl_add->list);
+			}
+
+			/* Remove dev_md from altdevs. */
+			if ((devl = _get_devl_in_device_list(dev_md, &altdevs)))
+				dm_list_del(&devl->list);
+		}
+
+		if (info && !dev_md) {
+			/*
+			 * Only md component devs were found and no actual
+			 * md dev, so drop the component from lvmcache.
+			 */
+			dev_drop = info->dev;
+
+			log_debug("Ignoring md component %s with PVID %s (dropping info)", dev_name(dev_drop), pvid);
+			lvmcache_del(info);
+			info = NULL;
+
+			/* Make the component dev look like it was filtered. */
+			cmd->filter->wipe(cmd, cmd->filter, dev_drop, NULL);
+			dev_drop->flags &= ~DEV_SCAN_FOUND_LABEL;
+		}
+
+		dm_list_iterate_items_safe(devl, devl_safe, &altdevs) {
+			/*
+			 * The altdevs are all md components that should look
+			 * like they were filtered, they are not in lvmcache.
+			 */
+			dev_drop = devl->dev;
+
+			log_debug("Ignoring md component %s with PVID %s (dropping duplicate)", dev_name(dev_drop), pvid);
+			dm_list_del(&devl->list);
+
+			cmd->filter->wipe(cmd, cmd->filter, dev_drop, NULL);
+			dev_drop->flags &= ~DEV_SCAN_FOUND_LABEL;
+		}
 		goto next;
+	}
 
 	/*
 	 * Find the device for the pvid that's currently in lvmcache.
@@ -1331,6 +1448,18 @@ int lvmcache_label_reopen_vg_rw(struct cmd_context *cmd, const char *vgname, con
  * times it can be a clue that label_scan mistakenly read the pv from an md
  * component device instead of from the md device itself.  So for unmatching
  * sizes, we do a full md component check on the device.
+ *
+ * It might be nice to do this checking in the filter (when passes_filter is
+ * called after the initial read), but that doesn't work because passes_filter
+ * is called before _text_read so metadata/pvsummary info is not yet available
+ * which this function uses.
+ *
+ * The unique value of this function is that it can eliminate md components
+ * without there being duplicate PVs.  But, there will often be duplicate PVs,
+ * handled by _all_md_components(), where other devs with the same pvid will be
+ * in _initial_duplicates.  One could be the md device itself which will be
+ * added to lvmcache by choose_duplicates, and other duplicates that are
+ * components will be dropped.
  */
 
 void lvmcache_extra_md_component_checks(struct cmd_context *cmd)
@@ -1392,7 +1521,8 @@ void lvmcache_extra_md_component_checks(struct cmd_context *cmd)
 			 */
 			if (pvsize && devsize && (pvsize != devsize))
 				do_check_size = 1;
-			if (device_hint && !strncmp(device_hint, "/dev/md", 7))
+			if (device_hint && !strncmp(device_hint, "/dev/md", 7) &&
+			    (MAJOR(info->dev->dev) != cmd->dev_types->md_major))
 				do_check_name = 1;
 
 			if (!do_check_size && !do_check_name)
@@ -1422,11 +1552,11 @@ void lvmcache_extra_md_component_checks(struct cmd_context *cmd)
 				  device_hint ?: "none", dev_name(dev));
 
 			if (dev_is_md_component(cmd, dev, NULL, 1)) {
-				log_debug("dropping PV from md component %s", dev_name(dev));
+				log_debug("Ignoring PV from md component %s with PVID %s (metadata %s %llu)",
+					  dev_name(dev), dev->pvid, device_hint ?: "none", (unsigned long long)pvsize);
 				dev->flags &= ~DEV_SCAN_FOUND_LABEL;
 				/* lvmcache_del will also delete vginfo if info was last one */
 				lvmcache_del(info);
-				lvmcache_del_dev_from_duplicates(dev);
 				cmd->filter->wipe(cmd, cmd->filter, dev, NULL);
 			}
 		}


