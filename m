From: David Teigland <teigland@sourceware.org>
Date: Tue, 26 Nov 2019 17:52:44 -0500
Subject: master - bcache: add invalidate_bytes function
Message-ID: <54143.119112617524000111@us-mta-377.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=56a295f78c4638e201ad78a8b25fd7874f2d905d
Commit:        56a295f78c4638e201ad78a8b25fd7874f2d905d
Parent:        29db9c6325ac3552b0ba3a0f49682e8e8112cca2
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Nov 26 15:46:49 2019 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Nov 26 16:52:28 2019 -0600

bcache: add invalidate_bytes function

---
 lib/device/bcache-utils.c |   15 +++++++++++++++
 lib/device/bcache.h       |    1 +
 lib/label/label.c         |    5 +++++
 lib/label/label.h         |    1 +
 4 files changed, 22 insertions(+), 0 deletions(-)

diff --git a/lib/device/bcache-utils.c b/lib/device/bcache-utils.c
index 2553554..cf74144 100644
--- a/lib/device/bcache-utils.c
+++ b/lib/device/bcache-utils.c
@@ -79,6 +79,21 @@ bool bcache_read_bytes(struct bcache *cache, int fd, uint64_t start, size_t len,
 	return true;
 }
 
+bool bcache_invalidate_bytes(struct bcache *cache, int fd, uint64_t start, size_t len)
+{
+	block_address bb, be;
+	bool result = true;
+
+	byte_range_to_block_range(cache, start, len, &bb, &be);
+
+	for (; bb != be; bb++) {
+		if (!bcache_invalidate(cache, fd, bb))
+			result = false;
+	}
+
+	return result;
+}
+
 //----------------------------------------------------------------
 
 // Writing bytes and zeroing bytes are very similar, so we factor out
diff --git a/lib/device/bcache.h b/lib/device/bcache.h
index 7622fd3..4ef044c 100644
--- a/lib/device/bcache.h
+++ b/lib/device/bcache.h
@@ -163,6 +163,7 @@ bool bcache_read_bytes(struct bcache *cache, int fd, uint64_t start, size_t len,
 bool bcache_write_bytes(struct bcache *cache, int fd, uint64_t start, size_t len, void *data);
 bool bcache_zero_bytes(struct bcache *cache, int fd, uint64_t start, size_t len);
 bool bcache_set_bytes(struct bcache *cache, int fd, uint64_t start, size_t len, uint8_t val);
+bool bcache_invalidate_bytes(struct bcache *cache, int fd, uint64_t start, size_t len);
 
 void bcache_set_last_byte(struct bcache *cache, int fd, uint64_t offset, int sector_size);
 void bcache_unset_last_byte(struct bcache *cache, int fd);
diff --git a/lib/label/label.c b/lib/label/label.c
index 05986cb..64b7ca0 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -1464,6 +1464,11 @@ bool dev_write_bytes(struct device *dev, uint64_t start, size_t len, void *data)
 	return true;
 }
 
+bool dev_invalidate_bytes(struct device *dev, uint64_t start, size_t len)
+{
+	return bcache_invalidate_bytes(scan_bcache, dev->bcache_fd, start, len);
+}
+
 bool dev_write_zeros(struct device *dev, uint64_t start, size_t len)
 {
 	if (test_mode())
diff --git a/lib/label/label.h b/lib/label/label.h
index f06b7df..33a91fa 100644
--- a/lib/label/label.h
+++ b/lib/label/label.h
@@ -126,6 +126,7 @@ bool dev_read_bytes(struct device *dev, uint64_t start, size_t len, void *data);
 bool dev_write_bytes(struct device *dev, uint64_t start, size_t len, void *data);
 bool dev_write_zeros(struct device *dev, uint64_t start, size_t len);
 bool dev_set_bytes(struct device *dev, uint64_t start, size_t len, uint8_t val);
+bool dev_invalidate_bytes(struct device *dev, uint64_t start, size_t len);
 void dev_set_last_byte(struct device *dev, uint64_t offset);
 void dev_unset_last_byte(struct device *dev);
 



