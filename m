From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 21 Sep 2021 19:51:06 +0000 (GMT)
Subject: main - cov: check for function result
Message-ID: <20210921195106.313E33858C3A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a13dfcbc77bcfdb4bfcff659fde8e11f73225643
Commit:        a13dfcbc77bcfdb4bfcff659fde8e11f73225643
Parent:        7bd55f8c152041101a27c83a96b794fdbb366460
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 21 18:45:08 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 21 21:03:47 2021 +0200

cov: check for function result

---
 test/unit/radix_tree_t.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/test/unit/radix_tree_t.c b/test/unit/radix_tree_t.c
index be24ce76d..b80e4f8ab 100644
--- a/test/unit/radix_tree_t.c
+++ b/test/unit/radix_tree_t.c
@@ -800,7 +800,7 @@ static void __invalidate(struct radix_tree *rt, int fd)
 
 	k.parts.fd = fd;
 	radix_tree_remove_prefix(rt, k.bytes, k.bytes + sizeof(k.parts.fd));
-	radix_tree_is_well_formed(rt);
+	T_ASSERT(radix_tree_is_well_formed(rt));
 }
 
 static void test_bcache_scenario3(void *fixture)


