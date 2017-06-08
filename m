From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 8 Jun 2017 06:03:40 -0400
Subject: master - thin: disallow creation of too big thin pools
Message-ID: <201706081003.v58A3eN1007786@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=48ffb996c5218472996b1b6d557fa51de0f6e9b7
Commit:        48ffb996c5218472996b1b6d557fa51de0f6e9b7
Parent:        ba3d3210d7fb2ad0379b90869c1e38167346091b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 8 10:46:22 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 8 11:58:36 2017 +0200

thin: disallow creation of too big thin pools

When a combination of thin-pool chunk size and thin-pool data size
goes beyond addressable limit, such volume creation is directly
prohibited.

Maximum usable thin-pool size is calculated with use of maximal support
metadata size (even when it's created smaller) and given chunk-size.
If the value data size is found to be too big, the command reports
error and operation fails.

Previously thin-pool was created however lots of thin-pool data LV was
not usable and this space in VG has been wasted.
---
 WHATS_NEW                 |    1 +
 lib/metadata/thin_manip.c |   17 +++++++++++++++++
 2 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index ae704af..fcf3148 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.172 - 
 ===============================
+  Limit maximal size of thin-pool for specific chunk size.
   Print a warning about in-use PVs with no VG using them.
   Disable automatic clearing of PVs that look like in-use orphans.
   Cache format2 flag is now using segment name type field.
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index c2629ac..726b26b 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -563,6 +563,12 @@ static uint64_t _estimate_metadata_size(uint32_t data_extents, uint32_t extent_s
 	return _estimate_size(data_extents, extent_size, chunk_size);
 }
 
+/* Estimate maximal supportable thin pool data size for given chunk_size */
+static uint64_t _estimate_max_data_size(uint32_t chunk_size)
+{
+	return  chunk_size * (DEFAULT_THIN_POOL_MAX_METADATA_SIZE * 2) * SECTOR_SIZE / UINT64_C(64);
+}
+
 /* Estimate thin pool chunk size from data and metadata size (in sector units) */
 static uint32_t _estimate_chunk_size(uint32_t data_extents, uint32_t extent_size,
 				     uint64_t metadata_size, int attr)
@@ -628,6 +634,7 @@ int update_thin_pool_params(struct cmd_context *cmd,
 {
 	uint64_t pool_metadata_size = (uint64_t) *pool_metadata_extents * extent_size;
 	uint32_t estimate_chunk_size;
+	uint64_t max_pool_data_size;
 	const char *str;
 
 	if (!*chunk_size &&
@@ -704,6 +711,16 @@ int update_thin_pool_params(struct cmd_context *cmd,
 		}
 	}
 
+	max_pool_data_size = _estimate_max_data_size(*chunk_size);
+	if ((max_pool_data_size / extent_size) < pool_data_extents) {
+		log_error("Selected chunk size %s cannot address more then %s of thin pool data space.",
+			  display_size(cmd, *chunk_size), display_size(cmd, max_pool_data_size));
+		return 0;
+	}
+
+	log_print_unless_silent("Thin pool data with chunk size %s can address@most %s of data.",
+				display_size(cmd, *chunk_size), display_size(cmd, max_pool_data_size));
+
 	if (!validate_thin_pool_chunk_size(cmd, *chunk_size))
 		return_0;
 


