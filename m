From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri,  2 Oct 2020 20:27:49 +0000 (GMT)
Subject: master - bcache: fix waiting problem for completed IO
Message-ID: <20201002202749.E98E73945C25@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=41f9e372c064c2c254dce0f3657bd1c36f950e7c
Commit:        41f9e372c064c2c254dce0f3657bd1c36f950e7c
Parent:        9885c9b43a6c72ea89852989f4fa4a9a4619014a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 2 17:18:12 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 2 20:53:41 2020 +0200

bcache: fix waiting problem for completed IO

Call _wait_all() which does check whether there is still
some pending IO before sleep. Otherwise it may happen
our submitted IO operations have been already dispatched
and this call then endlessly waits for IO which are all done.
This can be reproduced when device returns quickly errors
on write requests.
---
 WHATS_NEW           | 1 +
 lib/device/bcache.c | 2 +-
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index c7a3207f9..bebd1f5cf 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.11 - 
 ==================================
+  Fix bcache waiting for IO completion with failing disks.
   Configure use own python path name order to prefer using python3.
   Add configure --enable-editline support as an alternative to readline.
   Enhance reporting and error handling when creating thin volumes.
diff --git a/lib/device/bcache.c b/lib/device/bcache.c
index fd18eef6e..33d124229 100644
--- a/lib/device/bcache.c
+++ b/lib/device/bcache.c
@@ -963,7 +963,7 @@ static struct block *_new_block(struct bcache *cache, int di, block_address i, b
 			if (can_wait) {
 				if (dm_list_empty(&cache->io_pending))
 					_writeback(cache, 16);  // FIXME: magic number
-				_wait_io(cache);
+				_wait_all(cache);
 			} else {
 				log_debug("bcache no new blocks for di %d index %u",
 					  di, (uint32_t) i);


