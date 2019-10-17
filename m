From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 17 Oct 2019 07:04:47 -0400
Subject: master - cache: add more comments for min meta size
Message-ID: <201910171104.x9HB4lkf023573@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=af8cfa90d9c4cdcb14c1cf69715405e22ac68432
Commit:        af8cfa90d9c4cdcb14c1cf69715405e22ac68432
Parent:        2a08d6d1d4945024be5e686de0df02fc66ad8d8d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Oct 16 18:46:03 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 17 13:03:49 2019 +0200

cache: add more comments for min meta size

Enhance source code with better explanation how the minimal
metadata size is evaluated from data size and chunk size.
---
 lib/metadata/cache_manip.c |   22 +++++++++++++---------
 1 files changed, 13 insertions(+), 9 deletions(-)

diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index 3b51ea0..febd82a 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -178,18 +178,22 @@ void cache_check_for_warns(const struct lv_segment *seg)
 }
 
 /*
- * Returns minimum size of cache metadata volume for give  data and chunk size
- * (all values in sector)
- * Default meta size is: (Overhead + mapping size + hint size)
+ * Returns the minimum size of cache metadata volume for given cache data size and
+ * and cache chunk size (all in/out values in sectors)
+ * Default metadata size is: (Overhead + mapping size + hint size)
  */
 static uint64_t _cache_min_metadata_size(uint64_t data_size, uint32_t chunk_size)
 {
-	uint64_t min_meta_size;
-
-	min_meta_size = data_size / chunk_size;		/* nr_chunks */
-	min_meta_size *= (DM_BYTES_PER_BLOCK + DM_MAX_HINT_WIDTH + DM_HINT_OVERHEAD_PER_BLOCK);
-	min_meta_size = (min_meta_size + (SECTOR_SIZE - 1)) >> SECTOR_SHIFT;	/* in sectors */
-	min_meta_size += DM_TRANSACTION_OVERHEAD * (1024 >> SECTOR_SHIFT);
+	/* Used space for mapping and hints for each cached chunk in bytes
+	 * (matching thin-tools cache_metadata_size.cc) */
+	const uint64_t chunk_overhead = (DM_BYTES_PER_BLOCK + DM_MAX_HINT_WIDTH + DM_HINT_OVERHEAD_PER_BLOCK);
+	const uint64_t transaction_overhead = DM_TRANSACTION_OVERHEAD * 1024; /* 4MiB */
+
+	/* Number of cache chunks we have in caching volume */
+	uint64_t nr_chunks = data_size / chunk_size;
+	/* Minimal size of metadata volume converted back to sectors */
+	uint64_t min_meta_size = (transaction_overhead + nr_chunks * chunk_overhead +
+				  (SECTOR_SIZE - 1)) >> SECTOR_SHIFT;
 
 	return min_meta_size;
 }


