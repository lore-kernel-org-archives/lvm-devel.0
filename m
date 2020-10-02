From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri,  2 Oct 2020 20:27:51 +0000 (GMT)
Subject: master - bcache: fix busy loop with too many errors
Message-ID: <20201002202751.150F2398E493@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0fe58fc54fb17707ba5ff04bcf7c8a5174784bec
Commit:        0fe58fc54fb17707ba5ff04bcf7c8a5174784bec
Parent:        41f9e372c064c2c254dce0f3657bd1c36f950e7c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 2 17:42:50 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 2 20:56:55 2020 +0200

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
index bebd1f5cf..1d38a7360 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.11 - 
 ==================================
+  Fix bcache when device has too many failing writes.
   Fix bcache waiting for IO completion with failing disks.
   Configure use own python path name order to prefer using python3.
   Add configure --enable-editline support as an alternative to readline.
diff --git a/lib/device/bcache.c b/lib/device/bcache.c
index 33d124229..3fb6a0e80 100644
--- a/lib/device/bcache.c
+++ b/lib/device/bcache.c
@@ -964,6 +964,11 @@ static struct block *_new_block(struct bcache *cache, int di, block_address i, b
 				if (dm_list_empty(&cache->io_pending))
 					_writeback(cache, 16);  // FIXME: magic number
 				_wait_all(cache);
+				if (dm_list_size(&cache->errored) >= cache->max_io) {
+					log_debug("bcache no new blocks for di %d index %u with >%d errors.",
+						  di, (uint32_t) i, cache->max_io);
+					return NULL;
+				}
 			} else {
 				log_debug("bcache no new blocks for di %d index %u",
 					  di, (uint32_t) i);


