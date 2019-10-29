From: Joe Thornber <thornber@sourceware.org>
Date: Tue, 29 Oct 2019 11:22:17 -0400
Subject: master - [bcache] bcache_invalidate_fd, only remove prefixes on success.
Message-ID: <201910291522.x9TFMH5W018741@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=25e7bf021a4e7c5ad5f925b86605bf025ff1a949
Commit:        25e7bf021a4e7c5ad5f925b86605bf025ff1a949
Parent:        7e8296f4788d6a83863a268582280587ade2e26c
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Tue Oct 29 15:21:11 2019 +0000
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Tue Oct 29 15:21:11 2019 +0000

[bcache] bcache_invalidate_fd, only remove prefixes on success.

---
 lib/device/bcache.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/lib/device/bcache.c b/lib/device/bcache.c
index b0edf28..04d49f1 100644
--- a/lib/device/bcache.c
+++ b/lib/device/bcache.c
@@ -1376,7 +1376,10 @@ bool bcache_invalidate_fd(struct bcache *cache, int fd)
 	it.success = true;
 	it.it.visit = _invalidate_v;
 	radix_tree_iterate(cache->rtree, k.bytes, k.bytes + sizeof(k.parts.fd), &it.it);
-	radix_tree_remove_prefix(cache->rtree, k.bytes, k.bytes + sizeof(k.parts.fd));
+
+	if (it.success)
+		radix_tree_remove_prefix(cache->rtree, k.bytes, k.bytes + sizeof(k.parts.fd));
+
 	return it.success;
 }
 


