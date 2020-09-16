From: David Teigland <teigland@sourceware.org>
Date: Wed, 16 Sep 2020 20:18:29 +0000 (GMT)
Subject: master - label: cleanup set_byte error exit
Message-ID: <20200916201829.7F3E938618BD@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=491eb258327ca07d1fe98e8bb344f63e14d97c0a
Commit:        491eb258327ca07d1fe98e8bb344f63e14d97c0a
Parent:        37bcd7ce840c7c18d41e9e308aba2be7b33e7eec
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Sep 16 13:54:16 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Sep 16 13:54:16 2020 -0500

label: cleanup set_byte error exit

---
 lib/label/label.c | 25 ++++++++++++++++---------
 1 file changed, 16 insertions(+), 9 deletions(-)

diff --git a/lib/label/label.c b/lib/label/label.c
index ba3b1f9c7..3b2011f6e 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -1519,6 +1519,8 @@ bool dev_write_zeros(struct device *dev, uint64_t start, size_t len)
 
 bool dev_set_bytes(struct device *dev, uint64_t start, size_t len, uint8_t val)
 {
+	bool rv;
+
 	if (test_mode())
 		return true;
 
@@ -1547,25 +1549,30 @@ bool dev_set_bytes(struct device *dev, uint64_t start, size_t len, uint8_t val)
 
 	dev_set_last_byte(dev, start + len);
 
-	if ((!val && !bcache_zero_bytes(scan_bcache, dev->bcache_fd, start, len)) ||
-	    !bcache_set_bytes(scan_bcache, dev->bcache_fd, start, len, val)) {
-		log_error("Error writing device %s at %llu length %u.",
+	if (!val)
+		rv = bcache_zero_bytes(scan_bcache, dev->bcache_fd, start, len);
+	else
+		rv = bcache_set_bytes(scan_bcache, dev->bcache_fd, start, len, val);
+
+	if (!rv) {
+		log_error("Error writing device value %s at %llu length %u.",
 			  dev_name(dev), (unsigned long long)start, (uint32_t)len);
-		dev_unset_last_byte(dev);
-		label_scan_invalidate(dev);
-		return false;
+		goto fail;
 	}
 
 	if (!bcache_flush(scan_bcache)) {
 		log_error("Error writing device %s at %llu length %u.",
 			  dev_name(dev), (unsigned long long)start, (uint32_t)len);
-		dev_unset_last_byte(dev);
-		label_scan_invalidate(dev);
-		return false;
+		goto fail;
 	}
 
 	dev_unset_last_byte(dev);
 	return true;
+
+fail:
+	dev_unset_last_byte(dev);
+	label_scan_invalidate(dev);
+	return false;
 }
 
 void dev_set_last_byte(struct device *dev, uint64_t offset)


