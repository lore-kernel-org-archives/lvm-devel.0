From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Oct 2020 19:12:02 +0000 (GMT)
Subject: stable-2.02 - bcache: fix waiting problem for completed IO
Message-ID: <20201016191202.6BB32396EC96@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d32ee355c75d1adcc01e4d14c06c4ddcfab16fc6
Commit:        d32ee355c75d1adcc01e4d14c06c4ddcfab16fc6
Parent:        1ed9cfad0954cb2e7c4445fd7ff2105aa044ccf1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 2 17:18:12 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 16 18:09:55 2020 +0200

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
index 3112105d7..7dae2ec5e 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.188 - 
 ==================================
+  Fix bcache waiting for IO completion with failing disks.
   Configure use own python path name order to prefer using python3.
   Enhance reporting and error handling when creating thin volumes.
   Use revert_lv() on reload error path after vg_revert().
diff --git a/lib/device/bcache.c b/lib/device/bcache.c
index e4e72b6fb..9d4ef90a9 100644
--- a/lib/device/bcache.c
+++ b/lib/device/bcache.c
@@ -956,7 +956,7 @@ static struct block *_new_block(struct bcache *cache, int fd, block_address i, b
 			if (can_wait) {
 				if (dm_list_empty(&cache->io_pending))
 					_writeback(cache, 16);  // FIXME: magic number
-				_wait_io(cache);
+				_wait_all(cache);
 			} else {
 				log_error("bcache no new blocks for fd %d index %u",
 					  fd, (uint32_t) i);


