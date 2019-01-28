From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 28 Jan 2019 16:40:41 -0500
Subject: master - thin: select chunk size as power of 2
Message-ID: <201901282140.x0SLefwh002419@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=78dd9d820da44c6b9907b481231745590e94613d
Commit:        78dd9d820da44c6b9907b481231745590e94613d
Parent:        58ad831c72b024233d91980f2269d0a26101ff99
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jan 28 19:50:41 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jan 28 22:17:25 2019 +0100

thin: select chunk size as power of 2

Whenever thin-pool chunk size is unspecified and left for lvm calculation
try to select the size as nearest highest power-of-2 instead of
just being a multiple of 64KiB.
---
 WHATS_NEW                 |    1 +
 lib/metadata/thin_manip.c |   17 +++--------------
 2 files changed, 4 insertions(+), 14 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 90739c9..29ade99 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.02 - 
 ===================================
+  Thin-pool selects power-of-2 chunk size by default.
   Cache selects power-of-2 chunk size by default.
   Support reszing for VDOPoolLV and VDOLV.
   Improve -lXXX%VG modifier which improves cache segment estimation.
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index 6b2b1e7..e1b3179 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -580,20 +580,9 @@ static uint32_t _estimate_chunk_size(uint32_t data_extents, uint32_t extent_size
 {
 	uint32_t chunk_size = _estimate_size(data_extents, extent_size, metadata_size);
 
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
+	/* Always round up to nearest power of 2 of 32-bit,
+	 * even when pool supports multiple of 64KiB */
+	chunk_size = 1 << (32 - clz(chunk_size - 1));
 
 	if (chunk_size < DM_THIN_MIN_DATA_BLOCK_SIZE)
 		chunk_size = DM_THIN_MIN_DATA_BLOCK_SIZE;


