From: Joe Thornber <thornber@sourceware.org>
Date: Thu, 3 May 2018 15:17:39 -0400
Subject: master - bcache: rename bcache_write_zeroes() -> bcache_zero_bytes()
Message-ID: <201805031917.w43JHdmw012445@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2688aafefbc937fc319c59ca1c77cdc24bb2c214
Commit:        2688aafefbc937fc319c59ca1c77cdc24bb2c214
Parent:        8b755f1e042555c5c90cb5766fe90429f143f089
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Thu May 3 10:21:14 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Thu May 3 10:21:14 2018 +0100

bcache: rename bcache_write_zeroes() -> bcache_zero_bytes()

Now matches the other util functions:

bcache_{prefetch,read,write,zero}_bytes()
---
 lib/device/bcache-utils.c |    2 +-
 lib/device/bcache.h       |    2 +-
 lib/label/label.c         |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/lib/device/bcache-utils.c b/lib/device/bcache-utils.c
index fb02a4b..d946cc4 100644
--- a/lib/device/bcache-utils.c
+++ b/lib/device/bcache-utils.c
@@ -151,7 +151,7 @@ static bool _zero_partial(struct bcache *cache, int fd, block_address bb, uint64
 	return true;
 }
 
-bool bcache_write_zeros(struct bcache *cache, int fd, uint64_t start, size_t len)
+bool bcache_zero_bytes(struct bcache *cache, int fd, uint64_t start, size_t len)
 {
 	block_address bb, be;
 	uint64_t block_size = bcache_block_sectors(cache) << SECTOR_SHIFT;
diff --git a/lib/device/bcache.h b/lib/device/bcache.h
index c6b6fb7..c07f012 100644
--- a/lib/device/bcache.h
+++ b/lib/device/bcache.h
@@ -161,7 +161,7 @@ void bcache_prefetch_bytes(struct bcache *cache, int fd, uint64_t start, size_t
 // Reads, writes and zeroes bytes.  Returns false if errors occur.
 bool bcache_read_bytes(struct bcache *cache, int fd, uint64_t start, size_t len, void *data);
 bool bcache_write_bytes(struct bcache *cache, int fd, uint64_t start, size_t len, void *data);
-bool bcache_write_zeros(struct bcache *cache, int fd, uint64_t start, size_t len);
+bool bcache_zero_bytes(struct bcache *cache, int fd, uint64_t start, size_t len);
 
 //----------------------------------------------------------------
 
diff --git a/lib/label/label.c b/lib/label/label.c
index a981809..d6a5727 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -988,7 +988,7 @@ bool dev_write_zeros(struct device *dev, off_t start, size_t len)
 		}
 	}
 
-	if (!bcache_write_zeros(scan_bcache, dev->bcache_fd, start, len)) {
+	if (!bcache_zero_bytes(scan_bcache, dev->bcache_fd, start, len)) {
 		log_error("dev_write_zeros %s at %u bcache write failed invalidate fd %d",
 			  dev_name(dev), (uint32_t)start, dev->bcache_fd);
 		label_scan_invalidate(dev);


