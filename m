From: David Teigland <teigland@sourceware.org>
Date: Mon, 23 Apr 2018 09:51:58 -0400
Subject: master - scan: remove lvmcache info for failed devs
Message-ID: <201804231351.w3NDpwYs032686@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=44726ed9cb9559801868ade5440d9e6ea6a61127
Commit:        44726ed9cb9559801868ade5440d9e6ea6a61127
Parent:        1717d4cb178b88dc70bc14a11aba199b34931bb0
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Mar 1 12:40:37 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 20 11:22:47 2018 -0500

scan: remove lvmcache info for failed devs

When scanning a device fails, drop an lvmcache
info struct for it.
---
 lib/label/label.c |   37 +++++++++++++++++++++++++------------
 1 files changed, 25 insertions(+), 12 deletions(-)

diff --git a/lib/label/label.c b/lib/label/label.c
index dd455ec..82d4bf3 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -333,7 +333,6 @@ static int _process_block(struct device *dev, struct block *bb, int *is_lvm_devi
 	char label_buf[LABEL_SIZE] __attribute__((aligned(8)));
 	struct label *label = NULL;
 	struct labeller *labeller;
-	struct lvmcache_info *info;
 	uint64_t sector;
 	int ret = 0;
 
@@ -356,11 +355,7 @@ static int _process_block(struct device *dev, struct block *bb, int *is_lvm_devi
 
 		log_very_verbose("%s: No lvm label detected", dev_name(dev));
 
-		if ((info = lvmcache_info_from_pvid(dev->pvid, dev, 0))) {
-			/* FIXME: if this case is actually happening, fix it. */
-			log_warn("Device %s has no label, removing PV info from lvmcache.", dev_name(dev));
-			lvmcache_del(info);
-		}
+		lvmcache_del_dev(dev); /* FIXME: if this is needed, fix it. */
 
 		*is_lvm_device = 0;
 		goto_out;
@@ -380,6 +375,7 @@ static int _process_block(struct device *dev, struct block *bb, int *is_lvm_devi
 		label->sector = sector;
 	} else {
 		/* FIXME: handle errors */
+		lvmcache_del_dev(dev);
 	}
  out:
 	return ret;
@@ -475,6 +471,7 @@ static int _scan_list(struct dm_list *devs, int *failed)
 	int rem_prefetches;
 	int scan_failed;
 	int is_lvm_device;
+	int ret;
 
 	dm_list_init(&wait_devs);
 	dm_list_init(&done_devs);
@@ -498,7 +495,7 @@ static int _scan_list(struct dm_list *devs, int *failed)
 
 		if (!_in_bcache(devl->dev)) {
 			if (!_scan_dev_open(devl->dev)) {
-				log_debug_devs("%s: Failed to open device.", dev_name(devl->dev));
+				log_debug_devs("Scan failed to open %s.", dev_name(devl->dev));
 				dm_list_del(&devl->list);
 				dm_list_add(&done_devs, &devl->list);
 				scan_failed_count++;
@@ -518,14 +515,24 @@ static int _scan_list(struct dm_list *devs, int *failed)
 		bb = NULL;
 
 		if (!bcache_get(scan_bcache, devl->dev->bcache_fd, 0, 0, &bb)) {
-			log_debug_devs("%s: Failed to scan device.", dev_name(devl->dev));
+			log_error("Scan failed to read %s.", dev_name(devl->dev));
 			scan_failed_count++;
 			scan_failed = 1;
+			lvmcache_del_dev(devl->dev);
 		} else {
 			log_debug_devs("Processing data from device %s fd %d block %p", dev_name(devl->dev), devl->dev->bcache_fd, bb);
-			_process_block(devl->dev, bb, &is_lvm_device);
-			scan_lvm_count++;
-			scan_failed = 0;
+
+			ret = _process_block(devl->dev, bb, &is_lvm_device);
+
+			if (!ret && is_lvm_device) {
+				log_error("Scan failed to process %s", dev_name(devl->dev));
+				scan_failed_count++;
+				scan_failed = 1;
+				lvmcache_del_dev(devl->dev);
+			} else {
+				scan_lvm_count++;
+				scan_failed = 0;
+			}
 		}
 
 		if (bb)
@@ -884,6 +891,8 @@ bool dev_read_bytes(struct device *dev, off_t start, size_t len, void *data)
 	}
 
 	if (!bcache_read_bytes(scan_bcache, dev->bcache_fd, start, len, data)) {
+		log_error("dev_read_bytes %s at %u failed invalidate fd %d",
+			  dev_name(dev), (uint32_t)start, dev->bcache_fd);
 		label_scan_invalidate(dev);
 		return false;
 	}
@@ -913,6 +922,8 @@ bool dev_write_bytes(struct device *dev, off_t start, size_t len, void *data)
 	}
 
 	if (!bcache_write_bytes(scan_bcache, dev->bcache_fd, start, len, data)) {
+		log_error("dev_write_bytes %s at %u failed invalidate fd %d",
+			  dev_name(dev), (uint32_t)start, dev->bcache_fd);
 		label_scan_invalidate(dev);
 		return false;
 	}
@@ -936,11 +947,13 @@ bool dev_write_zeros(struct device *dev, off_t start, size_t len)
 	}
 
 	if (dev->bcache_fd <= 0) {
-		log_error("dev_write_bytes %s with invalid fd %d", dev_name(dev), dev->bcache_fd);
+		log_error("dev_write_zeros %s with invalid fd %d", dev_name(dev), dev->bcache_fd);
 		return false;
 	}
 
 	if (!bcache_write_zeros(scan_bcache, dev->bcache_fd, start, len)) {
+		log_error("dev_write_zeros %s at %u failed invalidate fd %d",
+			  dev_name(dev), (uint32_t)start, dev->bcache_fd);
 		label_scan_invalidate(dev);
 		return false;
 	}


