From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 17 Mar 2014 13:33:11 +0000 (UTC)
Subject: master - snapshot: wrap min_chunk test into a lib function
Message-ID: <20140317133311.E885C60EAF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3a82490ee1cf7aec5b2d6648f9bc74d9791eca8e
Commit:        3a82490ee1cf7aec5b2d6648f9bc74d9791eca8e
Parent:        f3b9ee37e9b9672929737dedcd52b46f57d93d23
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 17 13:04:14 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 17 14:31:43 2014 +0100

snapshot: wrap min_chunk test into a lib function

Create a separate function to validation snapshot min chunk value
and relocate code into snapshot_manip file.

This function will be shared with lvconvert then.
---
 lib/metadata/lv_manip.c          |   13 ++-----------
 lib/metadata/metadata-exported.h |    1 +
 lib/metadata/snapshot_manip.c    |   16 ++++++++++++++++
 3 files changed, 19 insertions(+), 11 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 9246920..6e4ba71 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -49,8 +49,6 @@ typedef enum {
 #define A_CAN_SPLIT		0x10
 #define A_AREA_COUNT_MATCHES	0x20	/* Existing lvseg has same number of areas as new segment */
 
-#define SNAPSHOT_MIN_CHUNKS	3       /* Minimum number of chunks in snapshot */
-
 /*
  * Constant parameters during a single allocation attempt.
  */
@@ -6054,15 +6052,8 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 	}
 
 	if (lp->snapshot && !seg_is_thin(lp) &&
-	    (((uint64_t)lp->extents * vg->extent_size) <
-	     (SNAPSHOT_MIN_CHUNKS * lp->chunk_size))) {
-		log_error("Unable to create a snapshot smaller than "
-			  DM_TO_STRING(SNAPSHOT_MIN_CHUNKS) " chunks (%u extents, %s).",
-			  (unsigned) (((uint64_t) SNAPSHOT_MIN_CHUNKS * lp->chunk_size +
-				       vg->extent_size - 1) / vg->extent_size),
-			  display_size(cmd, (uint64_t) SNAPSHOT_MIN_CHUNKS * lp->chunk_size));
-		return NULL;
-	}
+	    !cow_has_min_chunks(vg, lp->extents, lp->chunk_size))
+                return NULL;
 
 	if (!seg_is_virtual(lp) &&
 	    vg->free_count < lp->extents && !lp->approx_alloc) {
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 87e6046..347e080 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -903,6 +903,7 @@ int lv_is_cow(const struct logical_volume *lv);
 int lv_is_merging_origin(const struct logical_volume *origin);
 int lv_is_merging_cow(const struct logical_volume *snapshot);
 uint32_t cow_max_extents(const struct logical_volume *origin, uint32_t chunk_size);
+int cow_has_min_chunks(const struct volume_group *vg, uint32_t cow_extents, uint32_t chunk_size);
 int lv_is_cow_covering_origin(const struct logical_volume *lv);
 
 /* Test if given LV is visible from user's perspective */
diff --git a/lib/metadata/snapshot_manip.c b/lib/metadata/snapshot_manip.c
index 8fcab0c..a0a3e3c 100644
--- a/lib/metadata/snapshot_manip.c
+++ b/lib/metadata/snapshot_manip.c
@@ -21,6 +21,8 @@
 #include "lv_alloc.h"
 #include "activate.h"
 
+#define SNAPSHOT_MIN_CHUNKS	3       /* Minimum number of chunks in snapshot */
+
 int lv_is_origin(const struct logical_volume *lv)
 {
 	return lv->origin_count ? 1 : 0;
@@ -88,6 +90,20 @@ uint32_t cow_max_extents(const struct logical_volume *origin, uint32_t chunk_siz
 	return (uint32_t) (size / extent_size);
 }
 
+int cow_has_min_chunks(const struct volume_group *vg, uint32_t cow_extents, uint32_t chunk_size)
+{
+	if (((uint64_t)vg->extent_size * cow_extents) >= (SNAPSHOT_MIN_CHUNKS * chunk_size))
+		return 1;
+
+	log_error("Snapshot volume cannot be smaller than " DM_TO_STRING(SNAPSHOT_MIN_CHUNKS)
+		  " chunks (%u extents, %s).", (unsigned)
+		  (((uint64_t) SNAPSHOT_MIN_CHUNKS * chunk_size +
+		    vg->extent_size - 1) / vg->extent_size),
+		  display_size(vg->cmd, (uint64_t) SNAPSHOT_MIN_CHUNKS * chunk_size));
+
+	return 0;
+}
+
 int lv_is_cow_covering_origin(const struct logical_volume *lv)
 {
 	return lv_is_cow(lv) &&


