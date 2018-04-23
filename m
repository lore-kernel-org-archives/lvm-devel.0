From: David Teigland <teigland@sourceware.org>
Date: Mon, 23 Apr 2018 09:52:35 -0400
Subject: master - [device/bcache] bcache_read_bytes should put blocks
Message-ID: <201804231352.w3NDqZI8000868@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=93fc9374294aae679faa23aef0bd631db2e9a31a
Commit:        93fc9374294aae679faa23aef0bd631db2e9a31a
Parent:        7be54bd687ead6aa21e04c8a85a648da369a3d88
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Feb 8 13:44:54 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 20 11:12:50 2018 -0500

[device/bcache] bcache_read_bytes should put blocks

---
 lib/device/bcache.c |   11 ++++++++---
 1 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/lib/device/bcache.c b/lib/device/bcache.c
index 52be947..5141083 100644
--- a/lib/device/bcache.c
+++ b/lib/device/bcache.c
@@ -1009,14 +1009,17 @@ bool bcache_read_bytes(struct bcache *cache, int fd, off_t start, size_t len, vo
 	block_address bb, be, i;
 	unsigned char *udata = data;
 	off_t block_size = cache->block_sectors << SECTOR_SHIFT;
+	int errors = 0;
 
 	byte_range_to_block_range(cache, start, len, &bb, &be);
 	for (i = bb; i < be; i++)
 		bcache_prefetch(cache, fd, i);
 
 	for (i = bb; i < be; i++) {
-		if (!bcache_get(cache, fd, i, 0, &b))
-			return false;
+		if (!bcache_get(cache, fd, i, 0, &b)) {
+			errors++;
+			continue;
+		}
 
 		if (i == bb) {
 			off_t block_offset = start % block_size;
@@ -1030,9 +1033,11 @@ bool bcache_read_bytes(struct bcache *cache, int fd, off_t start, size_t len, vo
 			len -= blen;
 			udata += blen;
 		}
+
+		bcache_put(b);
 	}
 
-	return true;
+	return errors ? false : true;
 }
 
 //----------------------------------------------------------------


