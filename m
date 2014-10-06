From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  6 Oct 2014 13:32:47 +0000 (UTC)
Subject: master - thin: better thin snapshot error detection
Message-ID: <20141006133247.28AE7609E5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1a6c892864c409724bcc0fdd48e325ae1674ae8b
Commit:        1a6c892864c409724bcc0fdd48e325ae1674ae8b
Parent:        1ef660be460a6dcd876f8077bac9478aca6df3e5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 6 13:42:59 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 6 15:18:05 2014 +0200

thin: better thin snapshot error detection

While creating thin snapshot, we cannot use size argument.
---
 tools/lvcreate.c |   41 +++++++++++++++++++++++++++--------------
 1 files changed, 27 insertions(+), 14 deletions(-)

diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 9e2c85c..a3f07f3 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -233,37 +233,50 @@ static int _lvcreate_name_params(struct lvcreate_params *lp,
  * Normal snapshot or thinly-provisioned snapshot?
  */
 static int _determine_snapshot_type(struct volume_group *vg,
-				  struct lvcreate_params *lp)
+				    struct lvcreate_params *lp)
 {
-	struct lv_list *lvl;
+	struct logical_volume *lv, *pool_lv = NULL;
 
-	if (!(lvl = find_lv_in_vg(vg, lp->origin))) {
+	if (!(lv = find_lv(vg, lp->origin))) {
 		log_error("Snapshot origin LV %s not found in Volume group %s.",
 			  lp->origin, vg->name);
 		return 0;
 	}
 
-	if (lv_is_cache(lvl->lv)) {
+	if (lv_is_cache(lv)) {
 		log_error("Snapshot of cache LV is not yet supported.");
 		return 0;
 	}
 
-	if (!arg_count(vg->cmd, extents_ARG) && !arg_count(vg->cmd, size_ARG)) {
-		if (seg_is_thin(lp)) {
-			if (!(lp->segtype = get_segtype_from_string(vg->cmd, "thin")))
-				return_0;
-			return 1;
+	if (lp->pool) {
+		if (!(pool_lv = find_lv(vg, lp->pool))) {
+			log_error("Thin pool volume %s not found in Volume group %s.",
+				  lp->pool, vg->name);
+			return 0;
 		}
 
-		if (!lv_is_thin_volume(lvl->lv)) {
-			log_error("Please specify either size or extents with snapshots.");
+		if (!lv_is_thin_pool(pool_lv)) {
+			log_error("Logical volume %s is not a thin pool volume.",
+				  display_lvname(pool_lv));
 			return 0;
 		}
+	}
 
-		if (!(lp->segtype = get_segtype_from_string(vg->cmd, "thin")))
-			return_0;
+	if (!arg_count(vg->cmd, extents_ARG) && !arg_count(vg->cmd, size_ARG)) {
+		if (lv_is_thin_volume(lv) && !lp->pool)
+			lp->pool = first_seg(lv)->pool_lv->name;
 
-		lp->pool = first_seg(lvl->lv)->pool_lv->name;
+		if (seg_is_thin(lp) || lp->pool) {
+			if (!(lp->segtype = get_segtype_from_string(vg->cmd, "thin")))
+				return_0;
+			return 1;
+		}
+
+		log_error("Please specify either size or extents with snapshots.");
+		return 0;
+	} else if (lp->pool) {
+		log_error("Cannot specify size with thin pool snapshot.");
+		return 0;
 	}
 
 	return 1;


