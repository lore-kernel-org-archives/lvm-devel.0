From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 4 Feb 2020 11:22:55 -0500
Subject: master - cov: widen before calculating min_chunk_size
Message-ID: <72103.120020411223600973@us-mta-285.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d6ac039b65a371caeabb1bf2a191e609ed2cd9f8
Commit:        d6ac039b65a371caeabb1bf2a191e609ed2cd9f8
Parent:        de43527f94c172223d25f849411f435ad359ce77
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jan 30 12:43:53 2020 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 4 17:22:06 2020 +0100

cov: widen before calculating min_chunk_size

Although we expect min_chunk_size to be 32bit value, for
large size of caches it might be useful to do calcs 64bit.
So to avoid doing shift as signed 32bit - use unsigned 64bit
from the start.
---
 lib/metadata/cache_manip.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index 5613a22..49b3850 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -222,7 +222,7 @@ int update_cache_pool_params(struct cmd_context *cmd,
 			*chunk_size = get_default_allocation_cache_pool_chunk_size_CFG(cmd,
 										       profile);
 			/* Use power-of-2 for min chunk size when unspecified */
-			min_chunk_size = 1 << (32 - clz(min_chunk_size - 1));
+			min_chunk_size = UINT64_C(1) << (32 - clz(min_chunk_size - 1));
 		}
 		if (*chunk_size < min_chunk_size) {
 			/*



