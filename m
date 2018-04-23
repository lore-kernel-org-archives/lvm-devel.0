From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 23 Apr 2018 16:43:28 -0400
Subject: master - gcc: remove duplicate typedef
Message-ID: <201804232043.w3NKhSKv005009@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fcdac700f9aac079761ad302e06413a5eb2178b9
Commit:        fcdac700f9aac079761ad302e06413a5eb2178b9
Parent:        1409c4a1c20319845171b91edb6310e25ae81792
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Apr 23 22:28:47 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 23 22:42:18 2018 +0200

gcc: remove duplicate typedef

---
 lib/device/bcache.h |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/lib/device/bcache.h b/lib/device/bcache.h
index 999223a..4ce137a 100644
--- a/lib/device/bcache.h
+++ b/lib/device/bcache.h
@@ -97,8 +97,6 @@ enum bcache_get_flags {
 	GF_DIRTY = (1 << 1)
 };
 
-typedef uint64_t block_address;
-
 unsigned bcache_nr_cache_blocks(struct bcache *cache);
 unsigned bcache_max_prefetches(struct bcache *cache);
 


