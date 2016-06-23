From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 23 Jun 2016 13:02:02 +0000 (UTC)
Subject: master - cleanup: remove unused code
Message-ID: <20160623130202.29C046090A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e5b7ebcddabb885dd8a2f4cb5b5a0a32af834076
Commit:        e5b7ebcddabb885dd8a2f4cb5b5a0a32af834076
Parent:        5a919e48053079670e6318fe862783e720dd2aea
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 17 15:22:27 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 23 14:59:29 2016 +0200

cleanup: remove unused code

---
 lib/metadata/lv_manip.c          |   83 --------------------------------------
 lib/metadata/metadata-exported.h |    1 -
 2 files changed, 0 insertions(+), 84 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 46815e3..8f07267 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4549,89 +4549,6 @@ static uint32_t lvseg_get_stripes(struct lv_segment *seg, uint32_t *stripesize)
 	return 0;
 }
 
-static int _lvresize_poolmetadata_prepare(struct logical_volume *pool_lv,
-					  struct lvresize_params *lp)
-{
-	uint32_t extents;
-	struct logical_volume *lv = first_seg(pool_lv)->metadata_lv;
-	struct volume_group *vg = pool_lv->vg;
-
-	lp->poolmetadataextents = 0;
-
-	if (!thin_pool_feature_supported(pool_lv, THIN_FEATURE_METADATA_RESIZE)) {
-		log_error("Support for online metadata resize not detected.");
-		return 0;
-	}
-
-	if (lp->poolmetadata_size % vg->extent_size) {
-		lp->poolmetadata_size += vg->extent_size -
-			(lp->poolmetadata_size % vg->extent_size);
-		log_print_unless_silent("Rounding pool metadata size to boundary between physical extents: %s",
-					display_size(vg->cmd, lp->poolmetadata_size));
-	}
-
-	if (!(extents = extents_from_size(vg->cmd, lp->poolmetadata_size,
-					  vg->extent_size)))
-		return_0;
-
-	if (lp->poolmetadata_sign == SIGN_PLUS) {
-		if (extents >= (MAX_EXTENT_COUNT - lv->le_count)) {
-			log_error("Unable to extend %s by %u extents, exceeds limit (%u).",
-				  lv->name, lv->le_count, MAX_EXTENT_COUNT);
-			return 0;
-		}
-		extents += lv->le_count;
-	}
-
-	if ((uint64_t)extents * vg->extent_size > DM_THIN_MAX_METADATA_SIZE) {
-		log_print_unless_silent("Rounding size to maximum supported size 16GiB "
-					"for metadata volume %s.", lv->name);
-		extents = (DM_THIN_MAX_METADATA_SIZE + vg->extent_size - 1) /
-			vg->extent_size;
-	}
-
-	/* FIXME Split here and move validation code earlier alongside rest of validation code */
-	if (extents == lv->le_count) {
-		log_print_unless_silent("Metadata volume %s has already %s.",
-					display_lvname(lv), display_size(vg->cmd, lv->size));
-		return 2;
-	}
-
-	lp->poolmetadataextents = extents;
-
-	return 1;
-}
-
-static int _lvresize_poolmetadata(struct logical_volume *pool_lv,
-				  struct lvresize_params *lp,
-				  struct dm_list *pvh)
-{
-	struct logical_volume *lv = first_seg(pool_lv)->metadata_lv;
-	struct volume_group *vg = lv->vg;
-	alloc_policy_t alloc = lp->alloc ? : lv->alloc;
-	struct lv_segment *mseg = last_seg(lv);
-	uint32_t seg_mirrors = lv_mirror_count(lv);
-
-	if (!archive(vg))
-		return_0;
-
-	log_print_unless_silent("Extending logical volume %s to %s.",
-				display_lvname(lv),
-				display_size(vg->cmd, (uint64_t) lp->poolmetadataextents *
-					     vg->extent_size));
-	if (!lv_extend(lv,
-		       mseg->segtype,
-		       mseg->area_count / seg_mirrors,
-		       mseg->stripe_size,
-		       seg_mirrors,
-		       mseg->region_size,
-		       lp->poolmetadataextents - lv->le_count,
-		       pvh, alloc, 0))
-		return_0;
-
-	return 1;
-}
-
 static int _lvresize_check(struct logical_volume *lv,
 			   struct lvresize_params *lp)
 {
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index b8275d6..f47fa1d 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -609,7 +609,6 @@ struct lvresize_params {
 
 	uint64_t poolmetadata_size;
 	sign_t poolmetadata_sign;
-	uint32_t poolmetadataextents;
 
 	/* Per LV applied parameters */
 


