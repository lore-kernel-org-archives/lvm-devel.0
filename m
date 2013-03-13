From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 13 Mar 2013 14:16:21 +0000 (UTC)
Subject: master - thin: rework lvconvert
Message-ID: <20130313141621.CB57CA0D6D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=562ad293fd52b8f3096b28bcac20e32aa1e8c1b0
Commit:        562ad293fd52b8f3096b28bcac20e32aa1e8c1b0
Parent:        9cf00666b320c67cf717cbba0ab0758ca4adebd3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 11 09:49:10 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 13 15:13:54 2013 +0100

thin: rework lvconvert

Usage of layer was not the best plan here - for proper devices stack
we have to keep correct reference in volume_group structure and
make the new thin pool LV appear as a new volume.
---
 tools/lvconvert.c |   67 +++++++++++++++++++++++++++++-----------------------
 1 files changed, 37 insertions(+), 30 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 9db1093..318ac9b 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1996,14 +1996,14 @@ static int _lvconvert_thinpool(struct cmd_context *cmd,
 			       struct lvconvert_params *lp)
 {
 	int r = 0;
-	char *name;
 	const char *old_name;
-	int len;
+	int len = strlen(pool_lv->name) + 16; /* _tmeta, _tdata */
 	struct lv_segment *seg;
-	struct logical_volume *data_lv;
+	struct logical_volume *data_lv = pool_lv;
 	struct logical_volume *metadata_lv;
 	struct logical_volume *pool_metadata_lv;
 	struct logical_volume *external_lv = NULL;
+	char metadata_name[len], data_name[len];
 
 	if (!lv_is_visible(pool_lv)) {
 		log_error("Can't convert internal LV %s/%s.",
@@ -2037,20 +2037,16 @@ static int _lvconvert_thinpool(struct cmd_context *cmd,
 		return 0;
 	}
 
-	len = strlen(pool_lv->name) + 16;
-	if (!(name = dm_pool_alloc(pool_lv->vg->vgmem, len))) {
-		log_error("Can't allocate new name.");
-		return 0;
-	}
-
-	if (dm_snprintf(name, len, "%s_tmeta", pool_lv->name) < 0) {
-		log_error("Failed to create layer name.");
+	if ((dm_snprintf(metadata_name, sizeof(metadata_name), "%s_tmeta",
+			 pool_lv->name) < 0) ||
+	    (dm_snprintf(data_name, sizeof(data_name), "%s_tdata",
+			 pool_lv->name) < 0)) {
+		log_error("Failed to create lv names.");
 		return 0;
 	}
 
 	if (lp->pool_metadata_lv_name) {
-		metadata_lv = find_lv(pool_lv->vg, lp->pool_metadata_lv_name);
-		if (!metadata_lv) {
+		if (!(metadata_lv = find_lv(pool_lv->vg, lp->pool_metadata_lv_name))) {
 			log_error("Unknown metadata LV %s.", lp->pool_metadata_lv_name);
 			return 0;
 		}
@@ -2129,8 +2125,7 @@ static int _lvconvert_thinpool(struct cmd_context *cmd,
 			return 0;
 		}
 
-		lp->poolmetadata_size =
-			(uint64_t) metadata_lv->le_count * metadata_lv->vg->extent_size;
+		lp->poolmetadata_size = metadata_lv->size;
 		if (lp->poolmetadata_size > (2 * DEFAULT_THIN_POOL_MAX_METADATA_SIZE)) {
 			log_warn("WARNING: Maximum size used by metadata is %s, rest is unused.",
 				 display_size(cmd, 2 * DEFAULT_THIN_POOL_MAX_METADATA_SIZE));
@@ -2156,7 +2151,7 @@ static int _lvconvert_thinpool(struct cmd_context *cmd,
 		if (!get_stripe_params(cmd, &lp->stripes, &lp->stripe_size))
 			return_0;
 
-		if (!(metadata_lv = alloc_pool_metadata(pool_lv, lp->alloc, name,
+		if (!(metadata_lv = alloc_pool_metadata(pool_lv, lp->alloc, metadata_name,
 							lp->pvh, lp->read_ahead,
 							lp->stripes, lp->stripe_size,
 							lp->poolmetadata_size)))
@@ -2169,28 +2164,40 @@ static int _lvconvert_thinpool(struct cmd_context *cmd,
 		return 0;
 	}
 
+	old_name = data_lv->name; /* Use for pool name */
 	/*
-	 * Since we wish to have underlaying dev, to match _tdata
-	 * rename data LV first, also checks for visible LV
+	 * Since we wish to have underlaying devs to match _tdata
+	 * rename data LV to match pool LV subtree first,
+	 * also checks for visible LV.
 	 */
 	/* FIXME: any more types prohibited here? */
-	/* FIXME: revert renamed LVs in fail path? */
+	if (!lv_rename_update(cmd, data_lv, data_name, 0))
+		return_0;
 
-	/* FIXME: common code with metadata/thin_manip.c  extend_pool() */
-	/* Create layer _tdata */
-	if (!(data_lv = insert_layer_for_lv(pool_lv->vg->cmd, pool_lv,
-					    pool_lv->status, "_tdata")))
+	if (!(pool_lv = lv_create_empty(old_name, NULL,
+					THIN_POOL | VISIBLE_LV | LVM_READ | LVM_WRITE,
+					ALLOC_INHERIT, data_lv->vg))) {
+		log_error("Creation of pool LV failed.");
+		return 0;
+	}
+
+	/* Allocate a new linear segment */
+	if (!(seg = alloc_lv_segment(lp->segtype, pool_lv, 0, data_lv->le_count,
+				     pool_lv->status, 0, NULL, NULL, 1, data_lv->le_count,
+				     0, 0, 0, NULL)))
 		return_0;
 
-	seg = first_seg(pool_lv);
-	seg->segtype = lp->segtype;
-	seg->lv->status |= THIN_POOL;
+	/* Add the new segment to the layer LV */
+	dm_list_add(&pool_lv->segments, &seg->list);
+	pool_lv->le_count = data_lv->le_count;
+	pool_lv->size = data_lv->size;
 
-	/* Drop reference as attach_pool_data_lv() takes it again */
-	remove_seg_from_segs_using_this_lv(data_lv, seg);
 	if (!attach_pool_data_lv(seg, data_lv))
 		return_0;
 
+	/* FIXME: revert renamed LVs in fail path? */
+	/* FIXME: any common code with metadata/thin_manip.c  extend_pool() ? */
+
 	seg->low_water_mark = 0;
 	seg->transaction_id = 0;
 
@@ -2201,8 +2208,8 @@ mda_write:
 
 	/* Rename deactivated metadata LV to have _tmeta suffix */
 	/* Implicit checks if metadata_lv is visible */
-	if (strcmp(metadata_lv->name, name) &&
-	    !lv_rename_update(cmd, metadata_lv, name, 0))
+	if (strcmp(metadata_lv->name, metadata_name) &&
+	    !lv_rename_update(cmd, metadata_lv, metadata_name, 0))
 		return_0;
 
 	if (!attach_pool_metadata_lv(seg, metadata_lv))


