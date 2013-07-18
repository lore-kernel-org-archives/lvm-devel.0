From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 18 Jul 2013 16:26:37 +0000 (UTC)
Subject: master - lv_manip: move some validation code before archiving
Message-ID: <20130718162637.7543360E48@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1d3f7953bda1826fb5eb957ae6dcefc9285454a1
Commit:        1d3f7953bda1826fb5eb957ae6dcefc9285454a1
Parent:        7b4b97b731053ab2780d5ffdce5fc1c3e0626c2a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jul 17 14:52:21 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jul 18 18:22:43 2013 +0200

lv_manip: move some validation code before archiving

Make as much test we can, before actualy modifying metadata.
Avoids also unnecessary archiving.
---
 lib/metadata/lv_manip.c |   65 ++++++++++++++++++++++++-----------------------
 1 files changed, 33 insertions(+), 32 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 2e34a49..a5c0d73 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5355,6 +5355,21 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg, struct l
 		return NULL;
 	}
 
+	if (vg_is_clustered(vg) && segtype_is_raid(lp->segtype)) {
+		/*
+		 * FIXME:
+		 * We could allow a RAID LV to be created as long as it
+		 * is activated exclusively.  Any subsequent activations
+		 * would have to be enforced as exclusive also.
+		 *
+		 * For now, we disallow the existence of RAID LVs in a
+		 * cluster VG
+		 */
+		log_error("Unable to create a %s logical volume in a cluster.",
+			  lp->segtype->name);
+		return NULL;
+	}
+
 	if ((segtype_is_mirrored(lp->segtype) ||
 	     segtype_is_raid(lp->segtype) || segtype_is_thin(lp->segtype)) &&
 	    !(vg->fid->fmt->features & FMT_SEGMENTS)) {
@@ -5540,9 +5555,6 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg, struct l
 	    !(lp->segtype = get_segtype_from_string(cmd, "striped")))
 		return_NULL;
 
-	if (!archive(vg))
-		return_NULL;
-
 	if (!dm_list_empty(&lp->tags)) {
 		if (!(vg->fid->fmt->features & FMT_TAGS)) {
 			log_error("Volume group %s does not support tags",
@@ -5551,6 +5563,9 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg, struct l
 		}
 	}
 
+	if (!archive(vg))
+		return_NULL;
+
 	if (seg_is_thin_volume(lp)) {
 		/* Ensure all stacked messages are submitted */
 		if (!(lvl = find_lv_in_vg(vg, lp->pool))) {
@@ -5558,25 +5573,26 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg, struct l
 				  lp->pool, vg->name);
 			return NULL;
 		}
+
+		if (lv_is_active_locally(lvl->lv) &&
+		    !pool_below_threshold(first_seg(lvl->lv))) {
+			log_error("Cannot create thin volume. Pool \"%s/%s\" "
+				  "is filled over the autoextend threshold.",
+				  lvl->lv->vg->name, lvl->lv->name);
+			return NULL;
+		}
+
 		if (lv_is_active(lvl->lv) ||
 		    ((lp->activate != CHANGE_AN) && (lp->activate != CHANGE_ALN)))
 			if (!update_pool_lv(lvl->lv, 1))
 				return_NULL;
-	}
 
-	if (vg_is_clustered(vg) && segtype_is_raid(lp->segtype)) {
-		/*
-		 * FIXME:
-		 * We could allow a RAID LV to be created as long as it
-		 * is activated exclusively.  Any subsequent activations
-		 * would have to be enforced as exclusive also.
-		 *
-		 * For now, we disallow the existence of RAID LVs in a
-		 * cluster VG
-		 */
-		log_error("Unable to create a %s logical volume in a cluster.",
-			  lp->segtype->name);
-		return NULL;
+		/* For thin snapshot we must have matching pool */
+		if (org && lv_is_thin_volume(org) && (!lp->pool ||
+		    (strcmp(first_seg(org)->pool_lv->name, lp->pool) == 0)))
+			thin_name = org->name;
+		else
+			thin_name = lp->pool;
 	}
 
 	if (segtype_is_mirrored(lp->segtype) || segtype_is_raid(lp->segtype)) {
@@ -5613,15 +5629,6 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg, struct l
 
 	dm_list_splice(&lv->tags, &lp->tags);
 
-	if (seg_is_thin_volume(lp)) {
-		/* For thin snapshot we must have matching pool */
-		if (org && lv_is_thin_volume(org) && (!lp->pool ||
-		    (strcmp(first_seg(org)->pool_lv->name, lp->pool) == 0)))
-			thin_name = org->name;
-		else
-			thin_name = lp->pool;
-	}
-
 	if (!lv_extend(lv, lp->segtype,
 		       lp->stripes, lp->stripe_size,
 		       lp->mirrors,
@@ -5714,12 +5721,6 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg, struct l
 	if (seg_is_thin(lp)) {
 		/* For snapshot, suspend active thin origin first */
 		if (org && lv_is_active(org) && lv_is_thin_volume(org)) {
-			if (!pool_below_threshold(first_seg(first_seg(org)->pool_lv))) {
-				log_error("Cannot create thin snapshot. Pool %s/%s is filled "
-					  "over the autoextend threshold.",
-					  org->vg->name, first_seg(org)->pool_lv->name);
-				goto revert_new_lv;
-			}
 			if (!suspend_lv_origin(cmd, org)) {
 				log_error("Failed to suspend thin snapshot origin %s/%s.",
 					  org->vg->name, org->name);


