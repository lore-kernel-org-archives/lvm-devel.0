From: David Teigland <teigland@sourceware.org>
Date: Mon, 23 Apr 2018 09:52:07 -0400
Subject: master - bcache: fix error handling
Message-ID: <201804231352.w3NDq7lg000314@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=570c6239eebf18e6884d350654274d3bc8f1c4f1
Commit:        570c6239eebf18e6884d350654274d3bc8f1c4f1
Parent:        217f3f8741c1f516ab1f039b8725ac3ce638e302
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Mar 1 10:17:32 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 20 11:22:47 2018 -0500

bcache: fix error handling

The error handling code wasn't working, but it
appears that just removing it is what we need.
The doesn't really need any different behavior
related to bcache blocks on an io error, it just
wants to know if there was an error.
---
 lib/device/bcache.c |   16 +++++++++++++++-
 1 files changed, 15 insertions(+), 1 deletions(-)

diff --git a/lib/device/bcache.c b/lib/device/bcache.c
index 94623a8..9034776 100644
--- a/lib/device/bcache.c
+++ b/lib/device/bcache.c
@@ -539,6 +539,14 @@ static void _complete_io(void *context, int err)
 	dm_list_del(&b->list);
 
 	if (b->error) {
+		log_warn("bcache io error %d fd %d", b->error, b->fd);
+		memset(b->data, 0, cache->block_sectors << SECTOR_SHIFT);
+	}
+
+	/* Things don't work with this block of code, but work without it. */
+#if 0
+	if (b->error) {
+		log_warn("bcache io error %d fd %d", b->error, b->fd);
 		if (b->io_dir == DIR_READ) {
 			// We can just forget about this block, since there's
 			// no dirty data to be written back.
@@ -552,6 +560,9 @@ static void _complete_io(void *context, int err)
 		_clear_flags(b, BF_DIRTY);
 		_link_block(b);
 	}
+#endif
+	_clear_flags(b, BF_DIRTY);
+	_link_block(b);
 }
 
 /*
@@ -768,7 +779,7 @@ static struct block *_lookup_or_read_block(struct bcache *cache,
 		}
 	}
 
-	if (b && !b->error) {
+	if (b) {
 		if (flags & (GF_DIRTY | GF_ZERO))
 			_set_flags(b, BF_DIRTY);
 
@@ -904,6 +915,9 @@ bool bcache_get(struct bcache *cache, int fd, block_address index,
 		b->ref_count++;
 
 		*result = b;
+
+		if (b->error)
+			return false;
 		return true;
 	}
 


