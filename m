From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 26 Oct 2014 17:37:49 +0000 (UTC)
Subject: master - cache: apply chunk rounding also for cache creation.
Message-ID: <20141026173749.BACD360282@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=52dfa6dd4491fd6f584b83d0924b82bea3bc1092
Commit:        52dfa6dd4491fd6f584b83d0924b82bea3bc1092
Parent:        25307e4add1e3f25cf5ae00d942df61afa46fe60
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Oct 26 18:17:59 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Oct 26 18:37:13 2014 +0100

cache: apply chunk rounding also for cache creation.

When we create volumes with chunk size bigger then extent size
we try to round up to some nearest chunk boundary.
Until now we did this for thins - use same logic for
cache volumes.
---
 lib/metadata/lv_manip.c |   26 ++++++++++++++------------
 1 files changed, 14 insertions(+), 12 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 8523b58..b12af6c 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -3017,7 +3017,6 @@ int lv_add_virtual_segment(struct logical_volume *lv, uint64_t status,
 	struct lv_segment *seg;
 	struct logical_volume *thin_pool_lv = NULL;
 	struct lv_list *lvl;
-	uint32_t size;
 
 	if (thin_pool_name) {
 		if (!(lvl = find_lv_in_vg(lv->vg, thin_pool_name))) {
@@ -3026,17 +3025,6 @@ int lv_add_virtual_segment(struct logical_volume *lv, uint64_t status,
 			return 0;
 		}
 		thin_pool_lv = lvl->lv;
-		size = first_seg(thin_pool_lv)->chunk_size;
-		if (lv->vg->extent_size < size) {
-			/* Align extents on chunk boundary size */
-			size = ((uint64_t)lv->vg->extent_size * extents + size - 1) /
-				size * size / lv->vg->extent_size;
-			if (size != extents) {
-				log_print_unless_silent("Rounding size (%d extents) up to chunk boundary "
-							"size (%d extents).", extents, size);
-				extents = size;
-			}
-		}
 	}
 
 	if (!dm_list_empty(&lv->segments) &&
@@ -6722,6 +6710,20 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 				  display_lvname(pool_lv));
 			return NULL;
 		}
+
+		/* Validate volume size to to aling on chunk for small extents */
+		/* Cache chunk size is always set */
+		size = seg_is_cache(lp) ? lp->chunk_size : first_seg(pool_lv)->chunk_size;
+		if (size > vg->extent_size) {
+			/* Align extents on chunk boundary size */
+			size = ((uint64_t)vg->extent_size * lp->extents + size - 1) /
+				size * size / vg->extent_size;
+			if (size != lp->extents) {
+				log_print_unless_silent("Rounding size (%d extents) up to chunk boundary "
+							"size (%d extents).", lp->extents, size);
+				lp->extents = size;
+			}
+		}
 	}
 
 	/* Resolve origin volume */


