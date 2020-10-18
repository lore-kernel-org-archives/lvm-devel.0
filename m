From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sun, 18 Oct 2020 21:02:39 +0000 (GMT)
Subject: stable-2.02 - label: cleanup set_byte error exit
Message-ID: <20201018210239.8CD43385041B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e94e0cd0206044780bdde19b833d818da8f3f651
Commit:        e94e0cd0206044780bdde19b833d818da8f3f651
Parent:        35104f7ba5c5318b059ed0fd76f47fdd1c04285b
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Sep 16 13:54:16 2020 -0500
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Oct 18 21:28:13 2020 +0200

label: cleanup set_byte error exit

---
 lib/label/label.c | 25 ++++++++++++++++---------
 1 file changed, 16 insertions(+), 9 deletions(-)

diff --git a/lib/label/label.c b/lib/label/label.c
index 065da1282..e05b18a9e 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -1414,6 +1414,8 @@ bool dev_write_zeros(struct device *dev, uint64_t start, size_t len)
 
 bool dev_set_bytes(struct device *dev, uint64_t start, size_t len, uint8_t val)
 {
+	bool rv;
+
 	if (test_mode())
 		return true;
 
@@ -1444,25 +1446,30 @@ bool dev_set_bytes(struct device *dev, uint64_t start, size_t len, uint8_t val)
 
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


