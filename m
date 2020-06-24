From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 24 Jun 2020 13:02:40 +0000 (GMT)
Subject: master - bcache: support longer writes
Message-ID: <20200624130240.5A56D3938C10@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6eb9eba59bf53101b5148ace3ddaf4140592495f
Commit:        6eb9eba59bf53101b5148ace3ddaf4140592495f
Parent:        04bba5ea421b02275197bfb16b4d1bbf8879b240
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 24 13:37:23 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jun 24 15:01:03 2020 +0200

bcache: support longer writes

When initiated larger write request, it may have happened, bcache
got out of free chunks - fix the loop, that is supposed to wait
until next free chunk becomes avain available.
---
 WHATS_NEW           | 1 +
 lib/device/bcache.c | 2 +-
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index c0267b7a3..c6dad99e2 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.10 - 
 =================================
+  Fix running out of free buffers for async writing for larger writes.
   Add integrity with raid capability.
   Fix support for lvconvert --repair used by foreign apps (i.e. Docker).
 
diff --git a/lib/device/bcache.c b/lib/device/bcache.c
index a7d805526..7e7e18542 100644
--- a/lib/device/bcache.c
+++ b/lib/device/bcache.c
@@ -950,7 +950,7 @@ static struct block *_new_block(struct bcache *cache, int fd, block_address i, b
 	struct block *b;
 
 	b = _alloc_block(cache);
-	while (!b && !dm_list_empty(&cache->clean)) {
+	while (!b) {
 		b = _find_unused_clean_block(cache);
 		if (!b) {
 			if (can_wait) {


