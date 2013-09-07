From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat,  7 Sep 2013 07:19:55 +0000 (UTC)
Subject: master - thin: fix resize of stacked thin pool volume
Message-ID: <20130907071956.0156B610C9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4c001a78544d29688f6609b1ceafe123af280323
Commit:        4c001a78544d29688f6609b1ceafe123af280323
Parent:        fe6b19a6a3deb707243a5728842fff17e52258e0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 6 10:54:50 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Sep 7 03:24:48 2013 +0200

thin: fix resize of stacked thin pool volume

When the pool is created from non-linear target the more complex rules
have to be used and stacking needs to properly decode args for _tdata
LV. Also proper allocation policies are being used according to those
set in lvm2 metadata for data and metadata LVs.

Also properly check for active pool and extra code to active it
temporarily.

With this fix it's now possible to use:

lvcreate -L20 -m2 -n pool vg  --alloc anywhere
lvcreate -L10 -m2 -n poolm vg --alloc anywhere
lvconvert --thinpool vg/pool --poolmetadata vg/poolm

lvresize -L+10 vg/pool
---
 WHATS_NEW                        |    1 +
 lib/metadata/lv_manip.c          |  160 +++++++++++++++++++++++++-------------
 lib/metadata/metadata-exported.h |    1 +
 3 files changed, 107 insertions(+), 55 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 212f4bb..11f31aa 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.101 - 
 ===================================
+  Fix lvresize for stacked thin pool volumes (i.e. mirrors).
   Write Completed debug message before reinstating log defaults after command.
   Skip pvmove of RAID, thin, snapshot, origin, or mirror LVs in a cluster.
   Refresh existing VG before autoactivation (event retrigger/device reappeared).
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 9728310..1cccd8c 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -2963,11 +2963,12 @@ int lv_extend(struct logical_volume *lv,
 		return_0;
 
 	if (segtype_is_thin_pool(segtype)) {
-		if (!lv->le_count) {
-			if (!(r = create_pool(lv, segtype, ah, stripes, stripe_size)))
-				stack;
-		} else if (!(r = _lv_extend_layered_lv(ah, lv, extents, 0,
-						       stripes, stripe_size)))
+		if (lv->le_count) {
+			/* lv_resize abstracts properly _tdata */
+			log_error(INTERNAL_ERROR "Cannot lv_extend() the existing thin pool segment.");
+			return 0;
+		}
+		if (!(r = create_pool(lv, segtype, ah, stripes, stripe_size)))
 			stack;
 	} else if (!segtype_is_mirrored(segtype) && !segtype_is_raid(segtype)) {
 		if (!(r = lv_add_segment(ah, 0, ah->area_count, lv, segtype,
@@ -3499,16 +3500,15 @@ static uint32_t lvseg_get_stripes(struct lv_segment *seg, uint32_t *stripesize)
 	return 0;
 }
 
-static int _lvresize_poolmetadata(struct cmd_context *cmd, struct volume_group *vg,
-				  struct lvresize_params *lp,
-				  const struct logical_volume *pool_lv,
-				  struct dm_list *pvh,
-				  alloc_policy_t alloc)
+static int _lvresize_poolmetadata_prepare(struct cmd_context *cmd,
+					  struct lvresize_params *lp,
+					  const struct logical_volume *pool_lv)
 {
-	struct logical_volume *lv;
-	struct lv_segment *mseg;
 	uint32_t extents;
-	uint32_t seg_mirrors;
+	struct logical_volume *lv = first_seg(pool_lv)->metadata_lv;
+	struct volume_group *vg = pool_lv->vg;
+
+	lp->poolmetadataextents = 0;
 
 	if (!pool_can_resize_metadata(pool_lv)) {
 		log_error("Support for online metadata resize not detected.");
@@ -3526,7 +3526,6 @@ static int _lvresize_poolmetadata(struct cmd_context *cmd, struct volume_group *
 					  vg->extent_size)))
 		return_0;
 
-	lv = first_seg(pool_lv)->metadata_lv;
 	if (lp->poolmetadatasign == SIGN_PLUS) {
 		if (extents >= (MAX_EXTENT_COUNT - lv->le_count)) {
 			log_error("Unable to extend %s by %u extents, exceeds limit (%u).",
@@ -3550,21 +3549,35 @@ static int _lvresize_poolmetadata(struct cmd_context *cmd, struct volume_group *
 		return 2;
 	}
 
-	if (!lp->sizeargs && !archive(vg))
+	lp->poolmetadataextents = extents;
+
+	return 1;
+}
+
+static int _lvresize_poolmetadata(struct cmd_context *cmd, struct volume_group *vg,
+				  struct lvresize_params *lp,
+				  const struct logical_volume *pool_lv,
+				  struct dm_list *pvh)
+{
+	struct logical_volume *lv = first_seg(pool_lv)->metadata_lv;
+	alloc_policy_t alloc = lp->ac_alloc ?: lv->alloc;
+	struct lv_segment *mseg = last_seg(lv);
+	uint32_t seg_mirrors = lv_mirror_count(lv);
+
+	if (!archive(vg))
 		return_0;
 
 	log_print_unless_silent("Extending logical volume %s to %s.",
 				lv->name,
-				display_size(cmd, (uint64_t) extents * vg->extent_size));
-	mseg = last_seg(lv);
-	seg_mirrors = lv_mirror_count(lv);
+				display_size(cmd, (uint64_t) lp->poolmetadataextents *
+					     vg->extent_size));
 	if (!lv_extend(lv,
 		       mseg->segtype,
 		       mseg->area_count / seg_mirrors,
 		       mseg->stripe_size,
 		       seg_mirrors,
 		       mseg->region_size,
-		       extents - lv->le_count, NULL,
+		       lp->poolmetadataextents - lv->le_count, NULL,
 		       pvh, alloc))
 		return_0;
 
@@ -3774,6 +3787,10 @@ static int _lvresize_adjust_extents(struct cmd_context *cmd, struct logical_volu
 
 	seg_size = lp->extents - lv->le_count;
 
+	if (lv_is_thin_pool(lv))
+		/* Now prepare args like we would be resizing _tdata layer */
+		lv = seg_lv(first_seg(lv), 0);
+
 	/* Use segment type of last segment */
 	lp->segtype = last_seg(lv)->segtype;
 
@@ -3993,19 +4010,26 @@ static int _lvresize_check_type(struct cmd_context *cmd, const struct logical_vo
 
 static struct logical_volume *_lvresize_volume(struct cmd_context *cmd,
 					       struct logical_volume *lv,
-					       struct lvresize_params *lp, struct dm_list *pvh,
-					       alloc_policy_t alloc)
+					       struct lvresize_params *lp,
+					       struct dm_list *pvh)
 {
 	struct volume_group *vg = lv->vg;
 	struct logical_volume *lock_lv = NULL;
+	struct lv_segment *seg;
 	int status;
+	alloc_policy_t alloc;
 
 	if (lv_is_thin_pool(lv)) {
 		if (lp->resizefs) {
 			log_warn("Thin pool volumes do not have filesystem.");
 			lp->resizefs = 0;
 		}
+		lock_lv = lv;
+		seg = first_seg(lv);
+		/* Switch to layered LV resizing */
+		lv = seg_lv(seg, 0);
 	}
+	alloc = lp->ac_alloc ?: lv->alloc;
 
 	if ((lp->resize == LV_REDUCE) && lp->argc)
 		log_warn("Ignoring PVs on command line when reducing");
@@ -4043,7 +4067,7 @@ static struct logical_volume *_lvresize_volume(struct cmd_context *cmd,
 
 	if (lp->resize == LV_REDUCE) {
 		if (!lv_reduce(lv, lv->le_count - lp->extents))
-			return NULL;
+			return_NULL;
 	} else if ((lp->extents > lv->le_count) && /* Ensure we extend */
 		   !lv_extend(lv, lp->segtype,
 			      lp->stripes, lp->stripe_size,
@@ -4052,8 +4076,14 @@ static struct logical_volume *_lvresize_volume(struct cmd_context *cmd,
 			      pvh, alloc))
 		return_NULL;
 
+	if (lock_lv) {
+		/* Update thin pool segment from the layered LV */
+		seg->area_len = lv->le_count;
+		seg->len = lv->le_count;
+		lock_lv->le_count = lv->le_count;
+		lock_lv->size = lv->size;
 	/* If thin metadata, must suspend thin pool */
-	if (lv_is_thin_pool_metadata(lv)) {
+	} else if (lv_is_thin_pool_metadata(lv)) {
 		if (!(lock_lv = find_pool_lv(lv)))
 			return_NULL;
 	/* If snapshot, must suspend all associated devices */
@@ -4089,6 +4119,10 @@ int lv_resize_prepare(struct cmd_context *cmd, struct logical_volume *lv,
 	if (lp->sizeargs && !_lvresize_check_type(cmd, lv, lp))
 		return_0;
 
+	if (lp->poolmetadatasize &&
+	    !_lvresize_poolmetadata_prepare(cmd, lp, lv))
+			return_0;
+
 	return 1;
 }
 
@@ -4098,68 +4132,76 @@ int lv_resize(struct cmd_context *cmd, struct logical_volume *lv,
 {
 	struct volume_group *vg = lv->vg;
 	struct logical_volume *lock_lv = NULL;
-	alloc_policy_t alloc;
-	int r;
+	int inactive = 0;
 
-	/* FIXME Could pool metadata have different policy? */
-	alloc = lp->ac_alloc ?: lv->alloc;
-
-	if (lp->sizeargs) {
-		if (!(lock_lv = _lvresize_volume(cmd, lv, lp, pvh, alloc)))
-			return_0;
-	}
+	if (lp->sizeargs &&
+	    !(lock_lv = _lvresize_volume(cmd, lv, lp, pvh)))
+		return_0;
 
-	if (lp->poolmetadatasize) {
-		/* FIXME Pull validation / calculcations out of this function and do earlier */
-		if (!(r = _lvresize_poolmetadata(cmd, vg, lp, lv, pvh, alloc)))
+	if (lp->poolmetadataextents) {
+		if (!_lvresize_poolmetadata(cmd, vg, lp, lv, pvh))
 			return_0;
-		else if (r == 1)	/* Metadata needs writing out */
-			lock_lv = lv;
+		lock_lv = lv;
 	}
 
 	if (!lock_lv)
 		return 1; /* Nothing to do */
 
+	if (lv_is_thin_pool(lock_lv) &&
+	    pool_is_active(lock_lv) &&
+	    !lv_is_active(lock_lv)) {
+		/*
+		 * Active 'hidden' -tpool can be waiting for resize, but the
+		 * pool LV itself might be inactive.
+		 * Here plain suspend/resume would not work.
+		 * So active temporarily pool LV (with on disk metadata)
+		 * then use suspend and resume and deactivate pool LV,
+		 * instead of searching for an active thin volume.
+		 */
+		inactive = 1;
+		if (!activate_lv_excl(cmd, lock_lv)) {
+			log_error("Failed to activate %s.", lock_lv->name);
+			return 0;
+		}
+	}
+
 	/* store vg on disk(s) */
 	if (!vg_write(vg))
-		return_0;
+		goto_out;
 
 	if (!suspend_lv(cmd, lock_lv)) {
 		log_error("Failed to suspend %s", lock_lv->name);
 		vg_revert(vg);
-		backup(vg);
-		return 0;
+		goto bad;
 	}
 
 	if (!vg_commit(vg)) {
 		stack;
 		if (!resume_lv(cmd, lock_lv))
 			stack;
-		backup(vg);
-		return 0;
+		goto bad;
 	}
 
 	if (!resume_lv(cmd, lock_lv)) {
 		log_error("Problem reactivating %s", lock_lv->name);
-		backup(vg);
-		return 0;
+		goto bad;
 	}
 
 	if (lv_is_cow_covering_origin(lv))
 		if (!monitor_dev_for_events(cmd, lv, 0, 0))
 			stack;
 
-	/*
-	 * Update lvm pool metadata (drop messages) if the pool has been
-	 * resumed and do a pool active/deactivate in other case.
-	 *
-	 * Note: Active thin pool can be waiting for resize.
-	 *
-	 * FIXME: Activate only when thin volume is active
-	 */
-	if (lv_is_thin_pool(lv) &&
-	    !update_pool_lv(lv, !lv_is_active(lv)))
-		return_0;
+	if (lv_is_thin_pool(lock_lv)) {
+		/* Update lvm pool metadata (drop messages). */
+		if (!update_pool_lv(lock_lv, 0))
+			goto_bad;
+
+		if (inactive && !deactivate_lv(cmd, lock_lv)) {
+			log_error("Problem deactivating %s.", lock_lv->name);
+			backup(vg);
+			return 0;
+		}
+	}
 
 	backup(vg);
 
@@ -4170,6 +4212,14 @@ int lv_resize(struct cmd_context *cmd, struct logical_volume *lv,
 		return_0;
 
 	return 1;
+
+bad:
+	backup(vg);
+out:
+	if (inactive && !deactivate_lv(cmd, lock_lv))
+		log_error("Problem deactivating %s.", lock_lv->name);
+
+	return 0;
 }
 
 char *generate_lv_name(struct volume_group *vg, const char *format,
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 0df710c..f20dfd0 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -455,6 +455,7 @@ struct lvresize_params {
 	sign_t sign;
 	uint64_t poolmetadatasize;
 	sign_t poolmetadatasign;
+	uint32_t poolmetadataextents;
 	percent_type_t percent;
 
 	enum {


