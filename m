From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed,  5 Jun 2013 12:04:37 +0000 (UTC)
Subject: dev-mornfall-lvmcache - snapshot: add cow_max_extents
Message-ID: <20130605120437.A7FDB6101E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=eb7e206a73a4fae5b93ffcdf96640675f7a72a73
Commit:        eb7e206a73a4fae5b93ffcdf96640675f7a72a73
Parent:        59962d8d3e1c402da02f7bf1b09978f570fd09d5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed May 29 12:44:54 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu May 30 17:30:15 2013 +0200

snapshot: add cow_max_extents

Add more precise calculation of the maximum usable snapshot size.
Using only percentage fails for small size of snapshot and extents.
---
 WHATS_NEW                        |    1 +
 lib/metadata/metadata-exported.h |    1 +
 lib/metadata/snapshot_manip.c    |   40 +++++++++++++++++++++++++++++++++++--
 3 files changed, 39 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 256adec..c7eb82a 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Add cow_max_extents() to calc extents for 100% origin coverage.
   For creation of snapshot require size for at least 3 chunks.
   Fix lvresize --use-policies of VALID but 100% full snapshot.
   Do not accept size parameters bigger then 16EiB.
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index f698b33..7ef4220 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -717,6 +717,7 @@ int lv_is_virtual_origin(const struct logical_volume *lv);
 int lv_is_cow(const struct logical_volume *lv);
 int lv_is_merging_origin(const struct logical_volume *origin);
 int lv_is_merging_cow(const struct logical_volume *snapshot);
+uint32_t cow_max_extents(const struct logical_volume *origin, uint32_t chunk_size);
 int lv_is_cow_covering_origin(const struct logical_volume *lv);
 
 /* Test if given LV is visible from user's perspective */
diff --git a/lib/metadata/snapshot_manip.c b/lib/metadata/snapshot_manip.c
index a7f57a6..c3d1112 100644
--- a/lib/metadata/snapshot_manip.c
+++ b/lib/metadata/snapshot_manip.c
@@ -31,11 +31,45 @@ int lv_is_cow(const struct logical_volume *lv)
 	return (!lv_is_origin(lv) && lv->snapshot) ? 1 : 0;
 }
 
+static uint64_t _cow_max_size(uint64_t origin_size, uint32_t chunk_size)
+{
+	/* Snapshot disk layout:
+	 *    COW is divided into chunks
+	 *        1st. chunk is reserved for header
+	 *        2nd. chunk is the 1st. metadata chunk
+	 *        3rd. chunk is the 1st. data chunk
+	 */
+
+	/* Size of metadata for snapshot in sectors */
+	uint64_t mdata_size = ((origin_size + chunk_size - 1) / chunk_size * 16 + 511) >> SECTOR_SHIFT;
+
+	/* Sum all chunks - header + metadata size + origin size (aligned on chunk boundary) */
+	uint64_t size = chunk_size +
+		((mdata_size + chunk_size - 1) & ~(uint64_t)(chunk_size - 1)) +
+		((origin_size + chunk_size - 1) & ~(uint64_t)(chunk_size - 1));
+
+	/* Does not overflow since size is in sectors (9 bits) */
+	return size;
+}
+
+uint32_t cow_max_extents(const struct logical_volume *origin, uint32_t chunk_size)
+{
+	uint64_t size = _cow_max_size(origin->size, chunk_size);
+	uint32_t extent_size = origin->vg->extent_size;
+
+	if (size % extent_size)
+		size += extent_size - size % extent_size;
+
+	if (size > UINT32_MAX)
+		size = UINT32_MAX; /* Origin is too big for 100% snapshot anyway */
+
+	return (uint32_t) (size / extent_size);
+}
+
 int lv_is_cow_covering_origin(const struct logical_volume *lv)
 {
-	/* TODO: we need less then 1% of origin size, depends on chunk size */
-	return lv_is_cow(lv) ?
-		(origin_from_cow(lv)->size * UINT64_C(101) <= lv->size * UINT64_C(100)) : 0;
+	return lv_is_cow(lv) &&
+		(lv->size >= _cow_max_size(origin_from_cow(lv)->size, find_cow(lv)->chunk_size));
 }
 
 int lv_is_visible(const struct logical_volume *lv)


