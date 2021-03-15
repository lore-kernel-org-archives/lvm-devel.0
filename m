From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 15 Mar 2021 10:14:20 +0000 (GMT)
Subject: main - cov: void unused result
Message-ID: <20210315101420.9FD8A3858D29@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8a92f7070941172e1671cf6b0fd1296776daefb7
Commit:        8a92f7070941172e1671cf6b0fd1296776daefb7
Parent:        f69ff4b84a559a5795479489cf834fc0c3999e8d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 15 10:49:20 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 15 11:13:24 2021 +0100

cov: void unused result

---
 lib/device/bcache.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/device/bcache.c b/lib/device/bcache.c
index a5f2a5a86..285d92bc7 100644
--- a/lib/device/bcache.c
+++ b/lib/device/bcache.c
@@ -1401,7 +1401,7 @@ bool bcache_invalidate_di(struct bcache *cache, int di)
 	radix_tree_iterate(cache->rtree, k.bytes, k.bytes + sizeof(k.parts.di), &it.it);
 
 	if (it.success)
-		radix_tree_remove_prefix(cache->rtree, k.bytes, k.bytes + sizeof(k.parts.di));
+		(void) radix_tree_remove_prefix(cache->rtree, k.bytes, k.bytes + sizeof(k.parts.di));
 
 	return it.success;
 }
@@ -1436,7 +1436,7 @@ void bcache_abort_di(struct bcache *cache, int di)
 
 	it.visit = _abort_v;
 	radix_tree_iterate(cache->rtree, k.bytes, k.bytes + sizeof(k.parts.di), &it);
-	radix_tree_remove_prefix(cache->rtree, k.bytes, k.bytes + sizeof(k.parts.di));
+	(void) radix_tree_remove_prefix(cache->rtree, k.bytes, k.bytes + sizeof(k.parts.di));
 }
 
 //----------------------------------------------------------------


