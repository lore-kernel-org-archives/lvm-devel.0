From: Joe Thornber <thornber@sourceware.org>
Date: Thu, 3 May 2018 15:17:13 -0400
Subject: master - bcache: add a comment
Message-ID: <201805031917.w43JHDA1012391@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=65912ce44dcf8d8b3d9d17a88363f913160a338a
Commit:        65912ce44dcf8d8b3d9d17a88363f913160a338a
Parent:        90d0ff66362f3f21f79b5204bcc072c12185883b
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Thu May 3 09:14:59 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Thu May 3 09:21:10 2018 +0100

bcache: add a comment

---
 lib/device/bcache.h |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/lib/device/bcache.h b/lib/device/bcache.h
index 2b0d965..6a18d33 100644
--- a/lib/device/bcache.h
+++ b/lib/device/bcache.h
@@ -150,18 +150,18 @@ bool bcache_invalidate(struct bcache *cache, int fd, block_address index);
  */
 bool bcache_invalidate_fd(struct bcache *cache, int fd);
 
-/*
- * Prefetches the blocks neccessary to satisfy a byte range.
- */
+
+//----------------------------------------------------------------
+// The next four functions are utilities written in terms of the above api.
+ 
+// Prefetches the blocks neccessary to satisfy a byte range.
 void bcache_prefetch_bytes(struct bcache *cache, int fd, off_t start, size_t len);
 
-/*
- * Reads and writes the bytes.  Returns false if errors occur.
- */
+// Reads, writes and zeroes bytes.  Returns false if errors occur.
 bool bcache_read_bytes(struct bcache *cache, int fd, off_t start, size_t len, void *data);
 bool bcache_write_bytes(struct bcache *cache, int fd, off_t start, size_t len, void *data);
 bool bcache_write_zeros(struct bcache *cache, int fd, off_t start, size_t len);
 
-/*----------------------------------------------------------------*/
+//----------------------------------------------------------------
 
 #endif


