From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 23 Jun 2016 13:01:57 +0000 (UTC)
Subject: master - lvresize: return 0/1
Message-ID: <20160623130157.E57EA6090A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4de15aa58d2cd25075d3b17c3d3d9ad06b4bb493
Commit:        4de15aa58d2cd25075d3b17c3d3d9ad06b4bb493
Parent:        7092c6ba1084dcc029ffef918c0419ebdd41b5f4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 17 11:29:28 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 23 14:59:29 2016 +0200

lvresize: return 0/1

Returning locking LV is no longer used from here, so return 1/0.
---
 lib/metadata/lv_manip.c |   34 +++++++++++-----------------------
 1 files changed, 11 insertions(+), 23 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 17e44cc..70969e8 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5197,13 +5197,12 @@ static int _lvresize_check_type(const struct logical_volume *lv,
 	return 1;
 }
 
-static struct logical_volume *_lvresize_volume(struct logical_volume *lv,
-					       struct lvresize_params *lp,
-					       struct dm_list *pvh)
+static int _lvresize_volume(struct logical_volume *lv,
+			    struct lvresize_params *lp,
+			    struct dm_list *pvh)
 {
 	struct volume_group *vg = lv->vg;
 	struct cmd_context *cmd = vg->cmd;
-	struct logical_volume *lock_lv = NULL;
 	uint32_t old_extents;
 	int status;
 	alloc_policy_t alloc = lp->alloc ? : lv->alloc;
@@ -5214,14 +5213,14 @@ static struct logical_volume *_lvresize_volume(struct logical_volume *lv,
 	/* Request confirmation before operations that are often mistakes. */
 	if ((lp->resizefs || (lp->resize == LV_REDUCE)) &&
 	    !_request_confirmation(lv, lp))
-		return_NULL;
+		return_0;
 
 	if (lp->resizefs) {
 		if (!lp->nofsck &&
 		    !_fsadm_cmd(FSADM_CMD_CHECK, lv, 0, lp->force, &status)) {
 			if (status != FSADM_CHECK_FAILS_FOR_MOUNTED) {
 				log_error("Filesystem check failed.");
-				return NULL;
+				return 0;
 			}
 			/* some filesystems support online resize */
 		}
@@ -5230,12 +5229,12 @@ static struct logical_volume *_lvresize_volume(struct logical_volume *lv,
 		if ((lp->resize == LV_REDUCE) &&
 		    !_fsadm_cmd(FSADM_CMD_RESIZE, lv, lp->extents, lp->force, NULL)) {
 			log_error("Filesystem resize failed.");
-			return NULL;
+			return 0;
 		}
 	}
 
 	if (!archive(vg))
-		return_NULL;
+		return_0;
 
 	old_extents = lv->le_count;
 	log_verbose("%sing logical volume %s to %s%s",
@@ -5245,18 +5244,18 @@ static struct logical_volume *_lvresize_volume(struct logical_volume *lv,
 
 	if (lp->resize == LV_REDUCE) {
 		if (!lv_reduce(lv, lv->le_count - lp->extents))
-			return_NULL;
+			return_0;
 	} else if ((lp->extents > lv->le_count) && /* Ensure we extend */
 		   !lv_extend(lv, lp->segtype,
 			      lp->stripes, lp->stripe_size,
 			      lp->mirrors, first_seg(lv)->region_size,
 			      lp->extents - lv->le_count,
 			      pvh, alloc, lp->approx_alloc))
-		return_NULL;
+		return_0;
 	/* Check for over provisioning only when lv_extend() passed,
 	 * ATM this check does not fail */
 	else if (!pool_check_overprovisioning(lv))
-		return_NULL;
+		return_0;
 
 	if (old_extents == lv->le_count)
 		log_print_unless_silent("Size of logical volume %s unchanged from %s (%" PRIu32 " extents).",
@@ -5268,18 +5267,7 @@ static struct logical_volume *_lvresize_volume(struct logical_volume *lv,
 					display_size(cmd, (uint64_t) old_extents * vg->extent_size), old_extents,
 					display_size(cmd, (uint64_t) lv->le_count * vg->extent_size), lv->le_count);
 
-	if (lock_lv) {
-	/* If thin metadata, must suspend thin pool */
-	} else if (lv_is_thin_pool_metadata(lv)) {
-		if (!(lock_lv = find_pool_lv(lv)))
-			return_NULL;
-	/* If snapshot, must suspend all associated devices */
-	} else if (lv_is_cow(lv))
-		lock_lv = origin_from_cow(lv);
-	else
-		lock_lv = lv;
-
-	return lock_lv;
+	return 1;
 }
 
 static int _lvresize_prepare(struct logical_volume **lv,


