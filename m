From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 24 Oct 2014 14:40:41 +0000 (UTC)
Subject: master - cleanup: move code for checking vg features
Message-ID: <20141024144041.0863A60CE2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a4788b4994f4cbd5bccd411683704b2badf026d7
Commit:        a4788b4994f4cbd5bccd411683704b2badf026d7
Parent:        b726003b859a5e2f7580855c10fe201f67e1dc06
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 21 11:23:33 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 24 16:39:31 2014 +0200

cleanup: move code for checking vg features

Move code that checks for needed VG features into separate
smaller function.
---
 lib/metadata/lv_manip.c |   89 ++++++++++++++++++++++++++---------------------
 1 files changed, 49 insertions(+), 40 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 3d6bb26..df696e9 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6549,6 +6549,53 @@ static int _should_wipe_lv(struct lvcreate_params *lp,
 	return 0;
 }
 
+/* Check if VG metadata supports needed features */
+static int _vg_check_features(struct volume_group *vg,
+			      struct lvcreate_params *lp)
+{
+	uint32_t features = vg->fid->fmt->features;
+
+	if (vg_max_lv_reached(vg)) {
+		log_error("Maximum number of logical volumes (%u) reached "
+			  "in volume group %s", vg->max_lv, vg->name);
+		return 0;
+	}
+
+	if (!(features & FMT_SEGMENTS) &&
+	    (seg_is_cache(lp) ||
+	     seg_is_cache_pool(lp) ||
+	     seg_is_mirrored(lp) ||
+	     seg_is_raid(lp) ||
+	     seg_is_thin(lp))) {
+		log_error("Metadata does not support %s segments.",
+			  lp->segtype->name);
+		return 0;
+	}
+
+	if (!(features & FMT_TAGS) && !dm_list_empty(&lp->tags)) {
+		log_error("Volume group %s does not support tags.", vg->name);
+		return 0;
+	}
+
+	if ((features & FMT_RESTRICTED_READAHEAD) &&
+	    lp->read_ahead != DM_READ_AHEAD_AUTO &&
+	    lp->read_ahead != DM_READ_AHEAD_NONE &&
+	    (lp->read_ahead < 2 || lp->read_ahead > 120)) {
+		log_error("Metadata only supports readahead values between 2 and 120.");
+		return 0;
+	}
+
+	/* Need to check the vg's format to verify this - the cmd format isn't setup properly yet */
+	if (!(features & FMT_UNLIMITED_STRIPESIZE) &&
+	    (lp->stripes > 1) && (lp->stripe_size > STRIPE_SIZE_MAX)) {
+		log_error("Stripe size may not exceed %s.",
+			  display_size(vg->cmd, (uint64_t) STRIPE_SIZE_MAX));
+		return 0;
+	}
+
+	return 1;
+}
+
 /* Thin notes:
  * If lp->thin OR lp->activate is AY*, activate the pool if not already active.
  * If lp->thin, create thin LV within the pool - as a snapshot if lp->snapshot.
@@ -6573,29 +6620,8 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		return NULL;
 	}
 
-	if (vg_max_lv_reached(vg)) {
-		log_error("Maximum number of logical volumes (%u) reached "
-			  "in volume group %s", vg->max_lv, vg->name);
-		return NULL;
-	}
-
-	if (!(vg->fid->fmt->features & FMT_SEGMENTS) &&
-	    (segtype_is_mirrored(lp->segtype) ||
-	     segtype_is_raid(lp->segtype) ||
-	     segtype_is_thin(lp->segtype) ||
-	     segtype_is_cache(lp->segtype))) {
-		log_error("Metadata does not support %s segments.",
-			  lp->segtype->name);
-		return NULL;
-	}
-
-	if (lp->read_ahead != DM_READ_AHEAD_AUTO &&
-	    lp->read_ahead != DM_READ_AHEAD_NONE &&
-	    (vg->fid->fmt->features & FMT_RESTRICTED_READAHEAD) &&
-	    (lp->read_ahead < 2 || lp->read_ahead > 120)) {
-		log_error("Metadata only supports readahead values between 2 and 120.");
-		return NULL;
-	}
+	if (!_vg_check_features(vg, lp))
+		return_NULL;
 
 	if (!activation()) {
 		if (seg_is_cache(lp) ||
@@ -6644,15 +6670,6 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		lp->stripe_size = vg->extent_size;
 	}
 
-	/* Need to check the vg's format to verify this - the cmd format isn't setup properly yet */
-	if (lp->stripes > 1 &&
-	    !(vg->fid->fmt->features & FMT_UNLIMITED_STRIPESIZE) &&
-	    (lp->stripe_size > STRIPE_SIZE_MAX)) {
-		log_error("Stripe size may not exceed %s",
-			  display_size(cmd, (uint64_t) STRIPE_SIZE_MAX));
-		return NULL;
-	}
-
 	if ((size_rest = lp->extents % lp->stripes)) {
 		log_print_unless_silent("Rounding size (%d extents) up to stripe boundary "
 					"size (%d extents).", lp->extents,
@@ -6798,14 +6815,6 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 	    !(lp->segtype = get_segtype_from_string(cmd, "striped")))
 		return_NULL;
 
-	if (!dm_list_empty(&lp->tags)) {
-		if (!(vg->fid->fmt->features & FMT_TAGS)) {
-			log_error("Volume group %s does not support tags",
-				  vg->name);
-			return NULL;
-		}
-	}
-
 	if (!archive(vg))
 		return_NULL;
 


