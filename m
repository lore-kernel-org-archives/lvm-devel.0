From: David Teigland <teigland@sourceware.org>
Date: Mon, 23 Apr 2018 09:55:09 -0400
Subject: master - bcache: add some error messages for debugging
Message-ID: <201804231355.w3NDt9X3001621@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4331182964e37ad75690007f5f874f2606944a34
Commit:        4331182964e37ad75690007f5f874f2606944a34
Parent:        21057676a1f01c6b1f19b2e879d8385d76adb517
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Feb 27 12:37:25 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 20 11:22:47 2018 -0500

bcache: add some error messages for debugging

---
 lib/device/bcache.c |   21 +++++++++++++++++++--
 1 files changed, 19 insertions(+), 2 deletions(-)

diff --git a/lib/device/bcache.c b/lib/device/bcache.c
index 272de60..94623a8 100644
--- a/lib/device/bcache.c
+++ b/lib/device/bcache.c
@@ -659,8 +659,11 @@ static struct block *_new_block(struct bcache *cache, int fd, block_address inde
 				if (dm_list_empty(&cache->io_pending))
 					_writeback(cache, 16);  // FIXME: magic number
 				_wait_io(cache);
-			} else
+			} else {
+				log_error("bcache no new blocks for fd %d index %u",
+					  fd, (uint32_t)index);
 				return NULL;
+			}
 		}
 	}
 
@@ -676,6 +679,18 @@ static struct block *_new_block(struct bcache *cache, int fd, block_address inde
 		_hash_insert(b);
 	}
 
+	if (!b) {
+		log_error("bcache no new blocks for fd %d index %u "
+			  "clean %u free %u dirty %u pending %u nr_data_blocks %u nr_cache_blocks %u",
+			  fd, (uint32_t)index,
+			  dm_list_size(&cache->clean),
+			  dm_list_size(&cache->free),
+			  dm_list_size(&cache->dirty),
+			  dm_list_size(&cache->io_pending),
+			  (uint32_t)cache->nr_data_blocks,
+			  (uint32_t)cache->nr_cache_blocks);
+	}
+
 	return b;
 }
 
@@ -893,7 +908,7 @@ bool bcache_get(struct bcache *cache, int fd, block_address index,
 	}
 
 	*result = NULL;
-	log_warn("couldn't get block");
+	log_error("bcache failed to get block %u fd %d", (uint32_t)index, fd);
 	return false;
 }
 
@@ -1077,6 +1092,8 @@ bool bcache_write_bytes(struct bcache *cache, int fd, off_t start, size_t len, v
 
 	for (i = bb; i < be; i++) {
 		if (!bcache_get(cache, fd, i, 0, &b)) {
+			log_error("bcache_write failed to get block %u fd %d bb %u be %u",
+				  (uint32_t)i, fd, (uint32_t)bb, (uint32_t)be);
 			errors++;
 			break;
 		}


