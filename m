From: Joe Thornber <thornber@sourceware.org>
Date: Thu, 26 Apr 2018 08:15:47 -0400
Subject: master - [bcache] get all unit tests passing again
Message-ID: <201804261215.w3QCFlMg014466@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1c97fda42576367e263f8c928c060271787ad1c1
Commit:        1c97fda42576367e263f8c928c060271787ad1c1
Parent:        ea34dad66fe4a46a2f7ec51c4358144f6cb3ed67
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Thu Apr 26 13:13:27 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Thu Apr 26 13:13:27 2018 +0100

[bcache] get all unit tests passing again

---
 lib/device/bcache.c |   33 +++++++++++++--------------------
 1 files changed, 13 insertions(+), 20 deletions(-)

diff --git a/lib/device/bcache.c b/lib/device/bcache.c
index ea8f702..641838f 100644
--- a/lib/device/bcache.c
+++ b/lib/device/bcache.c
@@ -537,29 +537,16 @@ static void _complete_io(void *context, int err)
 	 */
 	dm_list_del(&b->list);
 
-	if (b->error)
-		memset(b->data, 0, cache->block_sectors << SECTOR_SHIFT);
-
 	/* Things don't work with this block of code, but work without it. */
-#if 0
 	if (b->error) {
 		log_warn("bcache io error %d fd %d", b->error, b->fd);
-		if (b->io_dir == DIR_READ) {
-			// We can just forget about this block, since there's
-			// no dirty data to be written back.
-			_hash_remove(b);
-			dm_list_add(&cache->free, &b->list);
 
-		} else
-			dm_list_add(&cache->errored, &b->list);
+		dm_list_add(&cache->errored, &b->list);
 
 	} else {
 		_clear_flags(b, BF_DIRTY);
 		_link_block(b);
 	}
-#endif
-	_clear_flags(b, BF_DIRTY);
-	_link_block(b);
 }
 
 /*
@@ -908,17 +895,23 @@ bool bcache_get(struct bcache *cache, int fd, block_address index,
 
 	b = _lookup_or_read_block(cache, fd, index, flags);
 	if (b) {
+		if (b->error) {
+			if (b->io_dir == DIR_READ) {
+				// Now we know the read failed we can just forget
+				// about this block, since there's no dirty data to
+				// be written back.
+				_hash_remove(b);
+				dm_list_add(&cache->free, &b->list);
+			}
+			*error = b->error;
+			return false;
+		}
+
 		if (!b->ref_count)
 			cache->nr_locked++;
 		b->ref_count++;
 
 		*result = b;
-
-		if (error)
-			*error = b->error;
-
-		if (b->error)
-			return false;
 		return true;
 	}
 


