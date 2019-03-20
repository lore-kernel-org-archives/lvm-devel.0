From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 20 Mar 2019 09:39:47 -0400
Subject: master - thin: max thin
Message-ID: <201903201339.x2KDdlPv012453@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1cc690e911f3caa1252cac6e19488345a0a1a4bc
Commit:        1cc690e911f3caa1252cac6e19488345a0a1a4bc
Parent:        74b5f228383d29ff84293a3691ecc02f023512ad
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jan 29 18:45:52 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 20 14:37:44 2019 +0100

thin: max thin

---
 lib/config/defaults.h     |    2 ++
 lib/metadata/thin_manip.c |   11 ++++++++---
 2 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 3b8d341..fac5b75 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -124,6 +124,8 @@
 #define DEFAULT_THIN_POOL_CHUNK_SIZE_POLICY "generic"
 #define DEFAULT_THIN_POOL_CHUNK_SIZE	    64	  /* KB */
 #define DEFAULT_THIN_POOL_CHUNK_SIZE_PERFORMANCE 512 /* KB */
+/* Chunk size big enough it no longer needs jump by power-of-2 */
+#define DEFAULT_THIN_POOL_CHUNK_SIZE_ALIGNED 1024 /* KB */
 #define DEFAULT_THIN_POOL_DISCARDS "passdown"
 #define DEFAULT_THIN_POOL_ZERO 1
 #define DEFAULT_POOL_METADATA_SPARE 1 /* thin + cache */
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index 5e52889..79fadc2 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -577,10 +577,15 @@ static uint32_t _estimate_chunk_size(uint32_t data_extents, uint32_t extent_size
 				     uint64_t metadata_size, int attr)
 {
 	uint32_t chunk_size = _estimate_size(data_extents, extent_size, metadata_size);
+	const uint32_t BIG_CHUNK =  2 * DEFAULT_THIN_POOL_CHUNK_SIZE_ALIGNED - 1;
 
-	/* Always round up to nearest power of 2 of 32-bit,
-	 * even when pool supports multiple of 64KiB */
-	chunk_size = 1 << (32 - clz(chunk_size - 1));
+	if ((attr & THIN_FEATURE_BLOCK_SIZE) &&
+	    (chunk_size > BIG_CHUNK) &&
+	    (chunk_size < (UINT32_MAX - BIG_CHUNK)))
+		chunk_size = (chunk_size + BIG_CHUNK) & ~BIG_CHUNK;
+	else
+		/* Round up to nearest power of 2 of 32-bit */
+		chunk_size = 1 << (32 - clz(chunk_size - 1));
 
 	if (chunk_size < DM_THIN_MIN_DATA_BLOCK_SIZE)
 		chunk_size = DM_THIN_MIN_DATA_BLOCK_SIZE;


