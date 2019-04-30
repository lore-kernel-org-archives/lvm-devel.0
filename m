From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 30 Apr 2019 07:31:01 -0400
Subject: stable-2.02 - thin: select chunk size as power of 2
Message-ID: <201904301131.x3UBV1OG020488@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4729b4af0bee2e742ed4f765dd6dc8d72f808521
Commit:        4729b4af0bee2e742ed4f765dd6dc8d72f808521
Parent:        f3be66c002b6dd5b6d1eabc395e10e97d49a1e99
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jan 29 18:45:52 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 30 12:11:50 2019 +0200

thin: select chunk size as power of 2

Whenever thin-pool chunk size is unspecified and left for lvm calculation
try to select the size as nearest highest power-of-2 instead of
just being a multiple of 64KiB. When multiple is bigger then 1MiB,
keep using 1MiB multiple.
---
 lib/config/defaults.h     |    2 ++
 lib/metadata/thin_manip.c |   22 ++++++++--------------
 2 files changed, 10 insertions(+), 14 deletions(-)

diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 9e398d7..6d3c37c 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -111,6 +111,8 @@
 #define DEFAULT_THIN_POOL_CHUNK_SIZE_POLICY "generic"
 #define DEFAULT_THIN_POOL_CHUNK_SIZE	    64	  /* KB */
 #define DEFAULT_THIN_POOL_CHUNK_SIZE_PERFORMANCE 512 /* KB */
+/* Chunk size big enough it no longer needs jump by power-of-2 */
+#define DEFAULT_THIN_POOL_CHUNK_SIZE_ALIGNED 1024 /* KB */
 #define DEFAULT_THIN_POOL_DISCARDS "passdown"
 #define DEFAULT_THIN_POOL_ZERO 1
 #define DEFAULT_POOL_METADATA_SPARE 1 /* thin + cache */
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index 313ef1b..2216927 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -579,21 +579,15 @@ static uint32_t _estimate_chunk_size(uint32_t data_extents, uint32_t extent_size
 				     uint64_t metadata_size, int attr)
 {
 	uint32_t chunk_size = _estimate_size(data_extents, extent_size, metadata_size);
+	const uint32_t BIG_CHUNK =  2 * DEFAULT_THIN_POOL_CHUNK_SIZE_ALIGNED - 1;
 
-	if (attr & THIN_FEATURE_BLOCK_SIZE) {
-		/* Round up to 64KB */
-		chunk_size += DM_THIN_MIN_DATA_BLOCK_SIZE - 1;
-		chunk_size &= ~(uint32_t)(DM_THIN_MIN_DATA_BLOCK_SIZE - 1);
-	} else {
-		/* Round up to nearest power of 2 */
-		chunk_size--;
-		chunk_size |= chunk_size >> 1;
-		chunk_size |= chunk_size >> 2;
-		chunk_size |= chunk_size >> 4;
-		chunk_size |= chunk_size >> 8;
-		chunk_size |= chunk_size >> 16;
-		chunk_size++;
-	}
+	if ((attr & THIN_FEATURE_BLOCK_SIZE) &&
+	    (chunk_size > BIG_CHUNK) &&
+	    (chunk_size < (UINT32_MAX - BIG_CHUNK)))
+		chunk_size = (chunk_size + BIG_CHUNK) & ~BIG_CHUNK;
+	else
+		/* Round up to nearest power of 2 of 32-bit */
+		chunk_size = 1 << (32 - clz(chunk_size - 1));
 
 	if (chunk_size < DM_THIN_MIN_DATA_BLOCK_SIZE)
 		chunk_size = DM_THIN_MIN_DATA_BLOCK_SIZE;


