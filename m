From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Oct 2020 19:10:40 +0000 (GMT)
Subject: stable-2.02 - bcache: support longer writes
Message-ID: <20201016191040.42EB438618E8@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e397423c419ec5db4137dc671d366ba650be6dde
Commit:        e397423c419ec5db4137dc671d366ba650be6dde
Parent:        3388779570924154e5e4f657889e121a4bd10e87
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 24 13:37:23 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 16 16:02:05 2020 +0200

bcache: support longer writes

When initiated larger write request, it may have happened, bcache
got out of free chunks - fix the loop, that is supposed to wait
until next free chunk becomes avain available.
---
 WHATS_NEW           | 1 +
 lib/device/bcache.c | 2 +-
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 3db623d6c..7f5fad9ae 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.188 - 
 ==================================
+  Fix running out of free buffers for async writing for larger writes.
   Fix conversion to raid from striped lagging type.
   Fix conversion to 'mirrored' mirror log with larger regionsize.
   Fix support for lvconvert --repair used by foreign apps (i.e. Docker).
diff --git a/lib/device/bcache.c b/lib/device/bcache.c
index a74b6b315..03779a519 100644
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


