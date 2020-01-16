From: Joe Thornber <thornber@sourceware.org>
Date: Thu, 16 Jan 2020 10:35:02 -0500
Subject: stable-2.02 - [bcache] bcache_invalidate_fd, only remove prefixes on success.
Message-ID: <61537.120011610345800608@us-mta-422.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=019fa6f8eec799ebc7a9b9c5b31354ff1717db12
Commit:        019fa6f8eec799ebc7a9b9c5b31354ff1717db12
Parent:        1e2e12f19c584c3568c255c5d89ed8aadbe61b9c
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Tue Oct 29 15:21:11 2019 +0000
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Thu Jan 16 14:58:56 2020 +0000

[bcache] bcache_invalidate_fd, only remove prefixes on success.

---
 lib/device/bcache.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/lib/device/bcache.c b/lib/device/bcache.c
index 72cc59929..b64707ecc 100644
--- a/lib/device/bcache.c
+++ b/lib/device/bcache.c
@@ -1291,7 +1291,10 @@ bool bcache_invalidate_fd(struct bcache *cache, int fd)
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
 



