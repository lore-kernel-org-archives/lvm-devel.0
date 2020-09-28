From: David Teigland <teigland@sourceware.org>
Date: Mon, 28 Sep 2020 18:29:28 +0000 (GMT)
Subject: master - scanning: keep open an lvm device with scanning problem
Message-ID: <20200928182928.939AC388703D@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=da14cf68cb62e1bf2e9718358158dde48a1acd20
Commit:        da14cf68cb62e1bf2e9718358158dde48a1acd20
Parent:        890c7ef451809a498978651a1802f65606a7c16b
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Sep 25 11:52:55 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Sep 28 13:25:57 2020 -0500

scanning: keep open an lvm device with scanning problem

The command may want to update it.
---
 lib/label/label.c | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/lib/label/label.c b/lib/label/label.c
index 27d06d783..de01e4532 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -678,7 +678,6 @@ static int _scan_list(struct cmd_context *cmd, struct dev_filter *f,
 	int scan_failed_count = 0;
 	int rem_prefetches;
 	int submit_count;
-	int scan_failed;
 	int is_lvm_device;
 	int ret;
 
@@ -726,12 +725,10 @@ static int _scan_list(struct cmd_context *cmd, struct dev_filter *f,
 
 	dm_list_iterate_items_safe(devl, devl2, &wait_devs) {
 		bb = NULL;
-		scan_failed = 0;
 		is_lvm_device = 0;
 
 		if (!bcache_get(scan_bcache, devl->dev->bcache_di, 0, 0, &bb)) {
 			log_debug_devs("Scan failed to read %s.", dev_name(devl->dev));
-			scan_failed = 1;
 			scan_read_errors++;
 			scan_failed_count++;
 			lvmcache_del_dev(devl->dev);
@@ -746,7 +743,6 @@ static int _scan_list(struct cmd_context *cmd, struct dev_filter *f,
 
 			if (!ret && is_lvm_device) {
 				log_debug_devs("Scan failed to process %s", dev_name(devl->dev));
-				scan_failed = 1;
 				scan_process_errors++;
 				scan_failed_count++;
 			}
@@ -761,7 +757,7 @@ static int _scan_list(struct cmd_context *cmd, struct dev_filter *f,
 		 * read the block, or the device does not belong to lvm, then
 		 * drop it from bcache.
 		 */
-		if (scan_failed || !is_lvm_device) {
+		if (!is_lvm_device) {
 			_invalidate_di(scan_bcache, devl->dev->bcache_di);
 			_scan_dev_close(devl->dev);
 		}


