From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Oct 2020 19:12:03 +0000 (GMT)
Subject: stable-2.02 - bcache: fix busy loop with too many errors
Message-ID: <20201016191203.8FF67396EC8C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5e64aa222b106ef3bd091346ebba807e10dc449e
Commit:        5e64aa222b106ef3bd091346ebba807e10dc449e
Parent:        d32ee355c75d1adcc01e4d14c06c4ddcfab16fc6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 2 17:42:50 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 16 18:09:55 2020 +0200

bcache: fix busy loop with too many errors

When bcache tries to write data to a faulty device,
it may get out of caching blocks and then just busy-loops
on a CPU - so this check protects this by checking
if there is already max_io (~64) errored blocks.
---
 WHATS_NEW           | 1 +
 lib/device/bcache.c | 5 +++++
 2 files changed, 6 insertions(+)

diff --git a/WHATS_NEW b/WHATS_NEW
index 7dae2ec5e..2cfb79ba0 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.188 - 
 ==================================
+  Fix bcache when device has too many failing writes.
   Fix bcache waiting for IO completion with failing disks.
   Configure use own python path name order to prefer using python3.
   Enhance reporting and error handling when creating thin volumes.
diff --git a/lib/device/bcache.c b/lib/device/bcache.c
index 9d4ef90a9..e173129fe 100644
--- a/lib/device/bcache.c
+++ b/lib/device/bcache.c
@@ -957,6 +957,11 @@ static struct block *_new_block(struct bcache *cache, int fd, block_address i, b
 				if (dm_list_empty(&cache->io_pending))
 					_writeback(cache, 16);  // FIXME: magic number
 				_wait_all(cache);
+				if (dm_list_size(&cache->errored) >= cache->max_io) {
+					log_debug("bcache no new blocks for di %d index %u with >%d errors.",
+						  fd, (uint32_t) i, cache->max_io);
+					return NULL;
+				}
 			} else {
 				log_error("bcache no new blocks for fd %d index %u",
 					  fd, (uint32_t) i);


