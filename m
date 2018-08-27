From: David Teigland <teigland@sourceware.org>
Date: Mon, 27 Aug 2018 15:41:59 -0400
Subject: 2018-06-01-stable - lvmetad: improve scan for pvscan all
Message-ID: <201808271941.w7RJfxoN025429@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c527a0cbfc391645d30407d2dc4a30275c6472f1
Commit:        c527a0cbfc391645d30407d2dc4a30275c6472f1
Parent:        63d49838900cbd6d2f937d5ce75e70b32cf009a2
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Aug 27 11:15:35 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Aug 27 14:39:49 2018 -0500

lvmetad: improve scan for pvscan all

For 'pvscan --cache' avoid using dev_iter in the loop
after the label_scan by passing the necessary devs back
from the label_scan for the continued pvscan.
The dev_iter functions reapply the filters which will
trigger more io when we don't need or want it.  With
many devs, incidental opens from the filters (not controlled
by the label scan) can lead to too many open files.
---
 lib/cache/lvmetad.c |   34 ++++++++++++------------
 lib/label/label.c   |   73 +++++++++++++++++++++++++++++++++++++++++++++++++++
 lib/label/label.h   |    1 +
 3 files changed, 91 insertions(+), 17 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index a1ab41a..acbb52e 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -2322,8 +2322,8 @@ bad:
 
 int lvmetad_pvscan_all_devs(struct cmd_context *cmd, int do_wait)
 {
-	struct dev_iter *iter;
-	struct device *dev;
+	struct device_list *devl, *devl2;
+	struct dm_list scan_devs;
 	daemon_reply reply;
 	char *future_token;
 	const char *reason;
@@ -2339,6 +2339,8 @@ int lvmetad_pvscan_all_devs(struct cmd_context *cmd, int do_wait)
 	}
 
  retry:
+	dm_list_init(&scan_devs);
+
 	/*
 	 * If another update is in progress, delay to allow it to finish,
 	 * rather than interrupting it with our own update.
@@ -2348,7 +2350,7 @@ int lvmetad_pvscan_all_devs(struct cmd_context *cmd, int do_wait)
 		replacing_other_update = 1;
 	}
 
-	label_scan(cmd);
+	label_scan_pvscan_all(cmd, &scan_devs);
 
 	lvmcache_pvscan_duplicate_check(cmd);
 
@@ -2357,19 +2359,14 @@ int lvmetad_pvscan_all_devs(struct cmd_context *cmd, int do_wait)
 		return 0;
 	}
 
-	log_verbose("Scanning all devices to update lvmetad.");
-
-	if (!(iter = dev_iter_create(cmd->lvmetad_filter, 1))) {
-		log_error("dev_iter creation failed");
-		return 0;
-	}
+	log_verbose("Scanning metadata from %d devices to update lvmetad.",
+		    dm_list_size(&scan_devs));
 
 	future_token = _lvmetad_token;
 	_lvmetad_token = (char *) LVMETAD_TOKEN_UPDATE_IN_PROGRESS;
 
 	if (!_token_update(&replaced_update)) {
 		log_error("Failed to update lvmetad which had an update in progress.");
-		dev_iter_destroy(iter);
 		_lvmetad_token = future_token;
 		return 0;
 	}
@@ -2385,12 +2382,10 @@ int lvmetad_pvscan_all_devs(struct cmd_context *cmd, int do_wait)
 		if (do_wait && !retries) {
 			retries = 1;
 			log_warn("WARNING: lvmetad update in progress, retrying update.");
-			dev_iter_destroy(iter);
 			_lvmetad_token = future_token;
 			goto retry;
 		}
 		log_warn("WARNING: lvmetad update in progress, skipping update.");
-		dev_iter_destroy(iter);
 		_lvmetad_token = future_token;
 		return 0;
 	}
@@ -2404,15 +2399,22 @@ int lvmetad_pvscan_all_devs(struct cmd_context *cmd, int do_wait)
 	was_silent = silent_mode();
 	init_silent(1);
 
-	while ((dev = dev_iter_get(iter))) {
+	dm_list_iterate_items_safe(devl, devl2, &scan_devs) {
 		if (sigint_caught()) {
 			ret = 0;
 			stack;
 			break;
 		}
 
-		if (!lvmetad_pvscan_single(cmd, dev, NULL, NULL)) {
-			ret = 0;
+		dm_list_del(&devl->list);
+
+		ret = lvmetad_pvscan_single(cmd, devl->dev, NULL, NULL);
+
+		label_scan_invalidate(devl->dev);
+
+		dm_free(devl);
+
+		if (!ret) {
 			stack;
 			break;
 		}
@@ -2420,8 +2422,6 @@ int lvmetad_pvscan_all_devs(struct cmd_context *cmd, int do_wait)
 
 	init_silent(was_silent);
 
-	dev_iter_destroy(iter);
-
 	_lvmetad_token = future_token;
 
 	/*
diff --git a/lib/label/label.c b/lib/label/label.c
index bafa543..837033c 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -876,6 +876,79 @@ int label_scan(struct cmd_context *cmd)
 	return 1;
 }
 
+int label_scan_pvscan_all(struct cmd_context *cmd, struct dm_list *scan_devs)
+{
+	struct dm_list all_devs;
+	struct dev_iter *iter;
+	struct device_list *devl, *devl2;
+	struct device *dev;
+
+	log_debug_devs("Finding devices to scan");
+
+	dm_list_init(&all_devs);
+
+	/*
+	 * Iterate through all the devices in dev-cache (block devs that appear
+	 * under /dev that could possibly hold a PV and are not excluded by
+	 * filters).  Read each to see if it's an lvm device, and if so
+	 * populate lvmcache with some basic info about the device and the VG
+	 * on it.  This info will be used by the vg_read() phase of the
+	 * command.
+	 */
+	dev_cache_scan();
+
+	if (!(iter = dev_iter_create(cmd->lvmetad_filter, 0))) {
+		log_error("Scanning failed to get devices.");
+		return 0;
+	}
+
+	while ((dev = dev_iter_get(iter))) {
+		if (!(devl = dm_zalloc(sizeof(*devl))))
+			return 0;
+		devl->dev = dev;
+		dm_list_add(&all_devs, &devl->list);
+
+		/*
+		 * label_scan should not generally be called a second time,
+		 * so this will usually not be true.
+		 */
+		if (_in_bcache(dev)) {
+			bcache_invalidate_fd(scan_bcache, dev->bcache_fd);
+			_scan_dev_close(dev);
+		}
+	};
+	dev_iter_destroy(iter);
+
+	log_debug_devs("Found %d devices to scan", dm_list_size(&all_devs));
+
+	if (!scan_bcache) {
+		if (!_setup_bcache(dm_list_size(&all_devs)))
+			return 0;
+	}
+
+	_scan_list(cmd, cmd->lvmetad_filter, &all_devs, NULL);
+
+	dm_list_iterate_items_safe(devl, devl2, &all_devs) {
+		dm_list_del(&devl->list);
+
+		/*
+		 * If this device is lvm's then, return it to pvscan
+		 * to do the further pvscan.  (We could have _scan_list
+		 * just set a result in devl indicating the result, but
+		 * instead we're just checking indirectly if _scan_list
+		 * saved lvmcache info for the dev which also means it's
+		 * an lvm device.)
+		 */
+
+		if (lvmcache_has_dev_info(devl->dev))
+			dm_list_add(scan_devs, &devl->list);
+		else
+			dm_free(devl);
+	}
+
+	return 1;
+}
+
 /*
  * Scan and cache lvm data from the listed devices.  If a device is already
  * scanned and cached, this replaces the previously cached lvm data for the
diff --git a/lib/label/label.h b/lib/label/label.h
index 5ed8bc8..5b83bc7 100644
--- a/lib/label/label.h
+++ b/lib/label/label.h
@@ -116,6 +116,7 @@ void label_scan_confirm(struct device *dev);
 int label_scan_setup_bcache(void);
 int label_scan_open(struct device *dev);
 int label_scan_open_excl(struct device *dev);
+int label_scan_pvscan_all(struct cmd_context *cmd, struct dm_list *scan_devs);
 
 /*
  * Wrappers around bcache equivalents.


