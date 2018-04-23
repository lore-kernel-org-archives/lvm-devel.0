From: David Teigland <teigland@sourceware.org>
Date: Mon, 23 Apr 2018 09:55:58 -0400
Subject: master - scan: improve io error checking and reporting
Message-ID: <201804231355.w3NDtw2k001875@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=45e5e702c1d488df4898a41db0c00ead63c5f6ee
Commit:        45e5e702c1d488df4898a41db0c00ead63c5f6ee
Parent:        6d05859862cebe79981557fe1a1005a530302f70
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Apr 6 13:12:26 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 20 11:22:48 2018 -0500

scan: improve io error checking and reporting

---
 lib/label/label.c |   30 +++++++++++++++++++-----------
 1 files changed, 19 insertions(+), 11 deletions(-)

diff --git a/lib/label/label.c b/lib/label/label.c
index 14a7e90..6c3be05 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -466,17 +466,20 @@ static int _scan_list(struct dm_list *devs, int *failed)
 	struct dm_list done_devs;
 	struct device_list *devl, *devl2;
 	struct block *bb;
+	int scan_open_errors = 0;
+	int scan_read_errors = 0;
+	int scan_process_errors = 0;
 	int scan_failed_count = 0;
-	int scan_lvm_count = 0;
 	int rem_prefetches;
 	int scan_failed;
 	int is_lvm_device;
+	int error;
 	int ret;
 
 	dm_list_init(&wait_devs);
 	dm_list_init(&done_devs);
 
-	log_debug_devs("Scanning %d devices.", dm_list_size(devs));
+	log_debug_devs("Scanning %d devices for VG info", dm_list_size(devs));
 
  scan_more:
 	rem_prefetches = bcache_max_prefetches(scan_bcache);
@@ -498,6 +501,7 @@ static int _scan_list(struct dm_list *devs, int *failed)
 				log_debug_devs("Scan failed to open %s.", dev_name(devl->dev));
 				dm_list_del(&devl->list);
 				dm_list_add(&done_devs, &devl->list);
+				scan_open_errors++;
 				scan_failed_count++;
 				continue;
 			}
@@ -513,11 +517,15 @@ static int _scan_list(struct dm_list *devs, int *failed)
 
 	dm_list_iterate_items_safe(devl, devl2, &wait_devs) {
 		bb = NULL;
+		error = 0;
+		scan_failed = 0;
+		is_lvm_device = 0;
 
-		if (!bcache_get(scan_bcache, devl->dev->bcache_fd, 0, 0, &bb)) {
-			log_debug_devs("Scan failed to read %s.", dev_name(devl->dev));
-			scan_failed_count++;
+		if (!bcache_get(scan_bcache, devl->dev->bcache_fd, 0, 0, &bb, &error)) {
+			log_debug_devs("Scan failed to read %s error %d.", dev_name(devl->dev), error);
 			scan_failed = 1;
+			scan_read_errors++;
+			scan_failed_count++;
 			lvmcache_del_dev(devl->dev);
 		} else {
 			log_debug_devs("Processing data from device %s fd %d block %p", dev_name(devl->dev), devl->dev->bcache_fd, bb);
@@ -526,12 +534,10 @@ static int _scan_list(struct dm_list *devs, int *failed)
 
 			if (!ret && is_lvm_device) {
 				log_debug_devs("Scan failed to process %s", dev_name(devl->dev));
-				scan_failed_count++;
 				scan_failed = 1;
+				scan_process_errors++;
+				scan_failed_count++;
 				lvmcache_del_dev(devl->dev);
-			} else {
-				scan_lvm_count++;
-				scan_failed = 0;
 			}
 		}
 
@@ -556,8 +562,8 @@ static int _scan_list(struct dm_list *devs, int *failed)
 	if (!dm_list_empty(devs))
 		goto scan_more;
 
-	log_debug_devs("Scanned devices: %d lvm, %d failed.",
-			scan_lvm_count, scan_failed_count);
+	log_debug_devs("Scanned devices: open errors %d read errors %d process errors %d",
+			scan_open_errors, scan_read_errors, scan_process_errors);
 
 	if (failed)
 		*failed = scan_failed_count;
@@ -649,6 +655,8 @@ int label_scan(struct cmd_context *cmd)
 	};
 	dev_iter_destroy(iter);
 
+	log_debug_devs("Found %d devices to scan", dm_list_size(&all_devs));
+
 	if (!scan_bcache) {
 		/*
 		 * FIXME: there should probably be some max number of


