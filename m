From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 3 Apr 2019 07:29:50 -0400
Subject: master - thin: introduce estimate_thin_pool_metadata_size
Message-ID: <201904031129.x33BTo3f027541@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7c3de2fd935aee428af8d75e774f5dd23a74c409
Commit:        7c3de2fd935aee428af8d75e774f5dd23a74c409
Parent:        bca0a4df9a5c6287bee682b40f4feae6f450729d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 3 12:56:48 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Apr 3 13:27:17 2019 +0200

thin: introduce estimate_thin_pool_metadata_size

Add function for estimation of thin-pool metadata size for given size of
data. Function is using already existing internal API so it can
be reused for resize of thin-pool data.
---
 lib/metadata/metadata.h   |    1 +
 lib/metadata/thin_manip.c |   12 ++++++++++++
 2 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index f578325..8e9c18a 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -490,6 +490,7 @@ int pool_below_threshold(const struct lv_segment *pool_seg);
 int pool_check_overprovisioning(const struct logical_volume *lv);
 int create_pool(struct logical_volume *pool_lv, const struct segment_type *segtype,
 		struct alloc_handle *ah, uint32_t stripes, uint32_t stripe_size);
+uint64_t estimate_thin_pool_metadata_size(uint32_t data_extents, uint32_t extent_size, uint32_t chunk_size);
 
 /*
  * Begin skeleton for external LVM library
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index 79fadc2..b9c01ee 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -908,3 +908,15 @@ int validate_thin_pool_chunk_size(struct cmd_context *cmd, uint32_t chunk_size)
 
 	return r;
 }
+
+uint64_t estimate_thin_pool_metadata_size(uint32_t data_extents, uint32_t extent_size, uint32_t chunk_size)
+{
+	uint64_t sz = _estimate_metadata_size(data_extents, extent_size, chunk_size);
+
+	if (sz > (2 * DEFAULT_THIN_POOL_MAX_METADATA_SIZE))
+		sz = 2 * DEFAULT_THIN_POOL_MAX_METADATA_SIZE;
+	else if (sz < (2 * DEFAULT_THIN_POOL_MIN_METADATA_SIZE))
+		sz = 2 * DEFAULT_THIN_POOL_MIN_METADATA_SIZE;
+
+	return sz;
+}


