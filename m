From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 20 Sep 2021 13:30:07 +0000 (GMT)
Subject: main - cov: ensure data is not derefenced
Message-ID: <20210920133007.98D813858C60@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bfc6fe2bac8ac262075271c2f6649b28cd04f883
Commit:        bfc6fe2bac8ac262075271c2f6649b28cd04f883
Parent:        3e7e9cc5e6abc4ddb1777e7c7b9d7bc42a7f57a7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 20 01:46:43 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 20 14:26:09 2021 +0200

cov: ensure data is not derefenced

Ensure all hypothetical paths cannot dereference NULL *(u->data).
---
 lib/device/bcache-utils.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/lib/device/bcache-utils.c b/lib/device/bcache-utils.c
index 85ec07aa6..82adb89a9 100644
--- a/lib/device/bcache-utils.c
+++ b/lib/device/bcache-utils.c
@@ -164,8 +164,10 @@ static bool _write_partial(struct updater *u, int di, block_address bb,
 	if (!bcache_get(u->cache, di, bb, GF_DIRTY, &b))
 		return false;
 
-	memcpy(((unsigned char *) b->data) + offset, u->data, len);
-	u->data = ((unsigned char *) u->data) + len;
+	if (u->data) {
+		memcpy(((unsigned char *) b->data) + offset, u->data, len);
+		u->data = ((unsigned char *) u->data) + len;
+	}
 
 	bcache_put(b);
 	return true;
@@ -246,7 +248,7 @@ bool bcache_zero_bytes(struct bcache *cache, int di, uint64_t start, size_t len)
 static bool _set_partial(struct updater *u, int di, block_address bb, uint64_t offset, size_t len)
 {
 	struct block *b;
-	uint8_t val = *((uint8_t *) u->data);
+	uint8_t val = (u->data) ? *((uint8_t *) u->data) : 0;
 
 	if (!bcache_get(u->cache, di, bb, GF_DIRTY, &b))
 		return false;
@@ -260,7 +262,7 @@ static bool _set_partial(struct updater *u, int di, block_address bb, uint64_t o
 static bool _set_whole(struct updater *u, int di, block_address bb, block_address be)
 {
 	struct block *b;
-	uint8_t val = *((uint8_t *) u->data);
+	uint8_t val = (u->data) ? *((uint8_t *) u->data) : 0;
         uint64_t len = bcache_block_sectors(u->cache) * 512;
 
 	for (; bb != be; bb++) {


