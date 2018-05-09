From: David Teigland <teigland@sourceware.org>
Date: Wed, 9 May 2018 13:56:07 -0400
Subject: master - io: replace dev_set with bcache equivalents
Message-ID: <201805091756.w49Hu7p2003477@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9a5bd01b0cf9526b3eb98c7521c281cbcee52732
Commit:        9a5bd01b0cf9526b3eb98c7521c281cbcee52732
Parent:        3600caa71def68d8f0b1389f0ee3b230ff1bfe56
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed May 9 10:34:28 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed May 9 11:29:52 2018 -0500

io: replace dev_set with bcache equivalents

---
 lib/label/label.c              |   53 +++++++++++++++++++++++++++++++---------
 lib/label/label.h              |    7 +++--
 lib/locking/lvmlockd.c         |   11 ++------
 lib/metadata/lv_manip.c        |   22 ++++++++++-------
 lib/metadata/metadata-liblvm.c |   10 +-------
 5 files changed, 62 insertions(+), 41 deletions(-)

diff --git a/lib/label/label.c b/lib/label/label.c
index d6a5727..8b60780 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -884,7 +884,7 @@ int label_scan_open(struct device *dev)
 	return 1;
 }
 
-bool dev_read_bytes(struct device *dev, off_t start, size_t len, void *data)
+bool dev_read_bytes(struct device *dev, uint64_t start, size_t len, void *data)
 {
 	int ret;
 
@@ -918,7 +918,7 @@ bool dev_read_bytes(struct device *dev, off_t start, size_t len, void *data)
 
 }
 
-bool dev_write_bytes(struct device *dev, off_t start, size_t len, void *data)
+bool dev_write_bytes(struct device *dev, uint64_t start, size_t len, void *data)
 {
 	int ret;
 
@@ -961,7 +961,7 @@ bool dev_write_bytes(struct device *dev, off_t start, size_t len, void *data)
 	return true;
 }
 
-bool dev_write_zeros(struct device *dev, off_t start, size_t len)
+bool dev_write_zeros(struct device *dev, uint64_t start, size_t len)
 {
 	int ret;
 
@@ -969,15 +969,8 @@ bool dev_write_zeros(struct device *dev, off_t start, size_t len)
 		return true;
 
 	if (!scan_bcache) {
-		if (!dev_open(dev))
-			return false;
-
-		ret = dev_set(dev, start, len, 0, 0);
-
-		if (!dev_close(dev))
-			stack;
-
-		return ret ? true : false;
+		log_error("dev_write_zeros %s bcache not set up", dev_name(dev));
+		return false;
 	}
 
 	if (dev->bcache_fd <= 0) {
@@ -1004,3 +997,39 @@ bool dev_write_zeros(struct device *dev, off_t start, size_t len)
 	return true;
 }
 
+bool dev_set_bytes(struct device *dev, uint64_t start, size_t len, uint8_t val)
+{
+	int ret;
+
+	if (test_mode())
+		return true;
+
+	if (!scan_bcache) {
+		log_error("dev_set_bytes %s bcache not set up", dev_name(dev));
+		return false;
+	}
+
+	if (dev->bcache_fd <= 0) {
+		/* This is not often needed, perhaps only with lvmetad. */
+		if (!label_scan_open(dev)) {
+			log_error("dev_set_bytes %s cannot open dev", dev_name(dev));
+			return false;
+		}
+	}
+
+	if (!bcache_set_bytes(scan_bcache, dev->bcache_fd, start, len, val)) {
+		log_error("dev_set_bytes %s at %u bcache write failed invalidate fd %d",
+			  dev_name(dev), (uint32_t)start, dev->bcache_fd);
+		label_scan_invalidate(dev);
+		return false;
+	}
+
+	if (!bcache_flush(scan_bcache)) {
+		log_error("dev_set_bytes %s at %u bcache flush failed invalidate fd %d",
+			  dev_name(dev), (uint32_t)start, dev->bcache_fd);
+		label_scan_invalidate(dev);
+		return false;
+	}
+	return true;
+}
+
diff --git a/lib/label/label.h b/lib/label/label.h
index 55e92e8..bccf777 100644
--- a/lib/label/label.h
+++ b/lib/label/label.h
@@ -119,8 +119,9 @@ int label_scan_open(struct device *dev);
  * Wrappers around bcache equivalents.
  * (these make it easier to disable bcache and revert to direct rw if needed)
  */
-bool dev_read_bytes(struct device *dev, off_t start, size_t len, void *data);
-bool dev_write_bytes(struct device *dev, off_t start, size_t len, void *data);
-bool dev_write_zeros(struct device *dev, off_t start, size_t len);
+bool dev_read_bytes(struct device *dev, uint64_t start, size_t len, void *data);
+bool dev_write_bytes(struct device *dev, uint64_t start, size_t len, void *data);
+bool dev_write_zeros(struct device *dev, uint64_t start, size_t len);
+bool dev_set_bytes(struct device *dev, uint64_t start, size_t len, uint8_t val);
 
 #endif
diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index 0521ede..d78b35c 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -403,22 +403,17 @@ static int _extend_sanlock_lv(struct cmd_context *cmd, struct volume_group *vg,
 		return 0;
 	}
 
-	if (!dev_open_quiet(dev)) {
+	if (!label_scan_open(dev)) {
 		log_error("Extend sanlock LV %s cannot open device.", display_lvname(lv));
 		return 0;
 	}
 
-	if (!dev_set(dev, old_size_bytes, new_size_bytes - old_size_bytes, DEV_IO_LV, 0)) {
+	if (!dev_write_zeros(dev, old_size_bytes, new_size_bytes - old_size_bytes)) {
 		log_error("Extend sanlock LV %s cannot zero device.", display_lvname(lv));
-		dev_close_immediate(dev);
 		return 0;
 	}
 
-	dev_flush(dev);
-
-	if (!dev_close_immediate(dev))
-		stack;
-
+	label_scan_invalidate(dev);
 	return 1;
 }
 
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 8bf9379..84953bb 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -7155,8 +7155,10 @@ int wipe_lv(struct logical_volume *lv, struct wipe_params wp)
 		return 0;
 	}
 
-	if (!dev_open_quiet(dev))
-		return_0;
+	if (!label_scan_open(dev)) {
+		log_error("Failed to open %s/%s for wiping and zeroing.", lv->vg->name, lv->name);
+		goto out;
+	}
 
 	if (wp.do_wipe_signatures) {
 		log_verbose("Wiping known signatures on logical volume \"%s/%s\"",
@@ -7177,15 +7179,17 @@ int wipe_lv(struct logical_volume *lv, struct wipe_params wp)
 			    display_size(lv->vg->cmd, zero_sectors),
 			    lv->vg->name, lv->name, wp.zero_value);
 
-		if (!dev_set(dev, UINT64_C(0), (size_t) zero_sectors << SECTOR_SHIFT, DEV_IO_LV, wp.zero_value))
-			stack;
+		if (!wp.zero_value) {
+			if (!dev_write_zeros(dev, UINT64_C(0), (size_t) zero_sectors << SECTOR_SHIFT))
+				stack;
+		} else {
+			if (!dev_set_bytes(dev, UINT64_C(0), (size_t) zero_sectors << SECTOR_SHIFT, (uint8_t)wp.zero_value))
+				stack;
+		}
 	}
 
-	dev_flush(dev);
-
-	if (!dev_close_immediate(dev))
-		stack;
-
+	label_scan_invalidate(dev);
+out:
 	lv->status &= ~LV_NOSCAN;
 
 	return 1;
diff --git a/lib/metadata/metadata-liblvm.c b/lib/metadata/metadata-liblvm.c
index 2dc3757..f7a07a5 100644
--- a/lib/metadata/metadata-liblvm.c
+++ b/lib/metadata/metadata-liblvm.c
@@ -66,19 +66,11 @@ static int _pvcreate_write(struct cmd_context *cmd, struct pv_to_write *pvw)
 
 		if (pvw->pp->zero) {
 			log_verbose("Zeroing start of device %s", pv_name);
-			if (!dev_open_quiet(dev)) {
-				log_error("%s not opened: device not zeroed", pv_name);
-				return 0;
-			}
 
-			if (!dev_set(dev, UINT64_C(0), (size_t) 2048, DEV_IO_LABEL, 0)) {
+			if (!dev_write_zeros(dev, UINT64_C(0), (size_t) 2048)) {
 				log_error("%s not wiped: aborting", pv_name);
-				if (!dev_close(dev))
-					stack;
 				return 0;
 			}
-			if (!dev_close(dev))
-				stack;
 		}
 	}
 


