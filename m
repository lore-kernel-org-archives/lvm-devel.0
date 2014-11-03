From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  3 Nov 2014 13:23:42 +0000 (UTC)
Subject: master - cleanup: rename virtual_extents
Message-ID: <20141103132342.AF7A560243@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cb931eed72e8618cfeefacaa3be1a4a2d5679d99
Commit:        cb931eed72e8618cfeefacaa3be1a4a2d5679d99
Parent:        913f025d3e481fc4ffe6ab7b29f7e7b27c0f1b19
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 31 11:33:19 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 3 14:19:33 2014 +0100

cleanup: rename virtual_extents

Use standard 'virtual_extents' naming.
Move virtual_size into  'lcp' struct out of lvcreate_params.
---
 lib/metadata/lv_manip.c          |   12 ++++++------
 lib/metadata/metadata-exported.h |    3 +--
 liblvm/lvm_lv.c                  |   35 ++++++++++++++++-------------------
 tools/lvconvert.c                |    3 +--
 tools/lvcreate.c                 |    7 ++++---
 5 files changed, 28 insertions(+), 32 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index e5b36df..a42a7f5 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6745,7 +6745,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 				return NULL;
 			}
 
-			lp->voriginextents = origin_lv->le_count;
+			lp->virtual_extents = origin_lv->le_count;
 
 			/*
 			 * Check if using 'external origin' or the 'normal' snapshot
@@ -6765,7 +6765,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 			}
 		}
 	} else if (lp->snapshot) {
-		if (!lp->voriginsize) {
+		if (!lp->virtual_extents) {
 			if (!origin_lv) {
 				log_error("Couldn't find origin volume '%s'.",
 					  lp->origin_name);
@@ -6868,7 +6868,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		       lp->stripes, lp->stripe_size,
 		       lp->mirrors,
 		       seg_is_pool(lp) ? lp->pool_metadata_extents : lp->region_size,
-		       seg_is_thin_volume(lp) ? lp->voriginextents : lp->extents,
+		       seg_is_thin_volume(lp) ? lp->virtual_extents : lp->extents,
 		       lp->pvh, lp->alloc, lp->approx_alloc))
 		return_NULL;
 
@@ -7080,7 +7080,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		 * if origin is real (not virtual) inactive device.
 		 */
 		if ((vg_is_clustered(vg) ||
-		     (!lp->voriginsize && !lv_is_active(origin_lv))) &&
+		     (!lp->virtual_extents && !lv_is_active(origin_lv))) &&
 		    !deactivate_lv(cmd, lv)) {
 			log_error("Aborting. Couldn't deactivate snapshot COW area. "
 				  "Manual intervention required.");
@@ -7088,10 +7088,10 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		}
 
 		/* A virtual origin must be activated explicitly. */
-		if (lp->voriginsize) {
+		if (lp->virtual_extents) {
 			if (!(origin_lv = _create_virtual_origin(cmd, vg, lv->name,
 								 lp->permission,
-								 lp->voriginextents))) {
+								 lp->virtual_extents))) {
 				stack;
 				goto deactivate_and_revert_new_lv;
 			}
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index ecab56e..39d91a1 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -857,12 +857,11 @@ struct lvcreate_params {
 
 	/* size */
 	uint32_t extents; /* all */
-	uint32_t voriginextents; /* snapshot */
-	uint64_t voriginsize; /* snapshot */
 	uint32_t pool_metadata_extents; /* pools */
 	uint64_t pool_metadata_size; /* pools */
 	uint32_t pool_data_extents; /* pools */
 	uint64_t pool_data_size; /* pools */
+	uint32_t virtual_extents; /* snapshots, thins */
 	struct dm_list *pvh; /* all */
 
 	uint64_t permission; /* all */
diff --git a/liblvm/lvm_lv.c b/liblvm/lvm_lv.c
index 49737d5..33af348 100644
--- a/liblvm/lvm_lv.c
+++ b/liblvm/lvm_lv.c
@@ -498,6 +498,8 @@ static int _lv_set_pool_params(struct lvcreate_params *lp,
 				vg_t vg, const char *pool_name,
 				uint64_t extents, uint64_t meta_size)
 {
+	uint64_t pool_metadata_size;
+
 	_lv_set_default_params(lp, vg, pool_name, extents);
 
 	lp->create_pool = 1;
@@ -505,23 +507,23 @@ static int _lv_set_pool_params(struct lvcreate_params *lp,
 	lp->stripes = 1;
 
 	if (!meta_size) {
-		lp->pool_metadata_size = extents * vg->extent_size /
+		pool_metadata_size = extents * vg->extent_size /
 			(lp->chunk_size * (SECTOR_SIZE / 64));
-		while ((lp->pool_metadata_size >
+		while ((pool_metadata_size >
 			(2 * DEFAULT_THIN_POOL_OPTIMAL_SIZE / SECTOR_SIZE)) &&
 		       lp->chunk_size < DM_THIN_MAX_DATA_BLOCK_SIZE) {
 			lp->chunk_size <<= 1;
-			lp->pool_metadata_size >>= 1;
+			pool_metadata_size >>= 1;
 	         }
 	} else
-		lp->pool_metadata_size = meta_size;
+		pool_metadata_size = meta_size;
 
-	if (lp->pool_metadata_size % vg->extent_size)
-		lp->pool_metadata_size +=
-			vg->extent_size - lp->pool_metadata_size % vg->extent_size;
+	if (pool_metadata_size % vg->extent_size)
+		pool_metadata_size +=
+			vg->extent_size - pool_metadata_size % vg->extent_size;
 
 	if (!(lp->pool_metadata_extents =
-	      extents_from_size(vg->cmd, lp->pool_metadata_size / SECTOR_SIZE,
+	      extents_from_size(vg->cmd, pool_metadata_size / SECTOR_SIZE,
 				vg->extent_size)))
 		return_0;
 
@@ -602,20 +604,15 @@ lv_create_params_t lvm_lv_params_create_thin_pool(vg_t vg,
 
 /* Set defaults for thin LV specific parameters */
 static int _lv_set_thin_params(struct lvcreate_params *lp,
-				vg_t vg, const char *pool_name,
-				const char *lvname,
-				uint64_t extents)
+			       vg_t vg, const char *pool_name,
+			       const char *lvname,
+			       uint32_t extents)
 {
-	_lv_set_default_params(lp, vg, lvname, extents);
+	_lv_set_default_params(lp, vg, lvname, 0);
 
 	lp->pool_name = pool_name;
 	lp->segtype = get_segtype_from_string(vg->cmd, "thin");
-
-	lp->voriginsize = extents * vg->extent_size;
-	if (!(lp->voriginextents = extents_from_size(vg->cmd, lp->voriginsize,
-						     vg->extent_size)))
-		return_0;
-
+	lp->virtual_extents = extents;
 	lp->stripes = 1;
 
 	return 1;
@@ -698,7 +695,7 @@ static lv_create_params_t _lvm_lv_params_create_thin(const vg_t vg,
 									const char *lvname, uint64_t size)
 {
 	struct lvm_lv_create_params *lvcp = NULL;
-	uint64_t extents = 0;
+	uint32_t extents = 0;
 
 	/* precondition checks */
 	if (vg_read_error(vg))
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index fbd8b04..f2eb5f5 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2640,8 +2640,7 @@ static int _lvconvert_thin(struct cmd_context *cmd,
 		.pvh = &vg->pvs,
 		.read_ahead = DM_READ_AHEAD_AUTO,
 		.stripes = 1,
-		.voriginextents = lv->le_count,
-		.voriginsize = lv->size,
+		.virtual_extents = lv->le_count,
 	};
 
 	if (lv == pool_lv) {
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 2e01561..2cbfbe5 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -20,6 +20,7 @@
 struct lvcreate_cmdline_params {
 	percent_type_t percent;
 	uint64_t size;
+	uint64_t virtual_size; /* snapshot, thin */
 	char **pvs;
 	uint32_t pv_count;
 };
@@ -251,8 +252,8 @@ static int _update_extents_params(struct volume_group *vg,
 					       vg->extent_size)))
 		return_0;
 
-	if (lp->voriginsize &&
-	    !(lp->voriginextents = extents_from_size(vg->cmd, lp->voriginsize,
+	if (lcp->virtual_size &&
+	    !(lp->virtual_extents = extents_from_size(vg->cmd, lcp->virtual_size,
 						      vg->extent_size)))
 		return_0;
 
@@ -406,7 +407,7 @@ static int _read_size_params(struct cmd_context *cmd,
 				  -1))
 		return_0;
 
-	lp->voriginsize = arg_uint64_value(cmd, virtualsize_ARG, UINT64_C(0));
+	lcp->virtual_size = arg_uint64_value(cmd, virtualsize_ARG, UINT64_C(0));
 
 	if (arg_count(cmd, extents_ARG)) {
 		if (arg_count(cmd, size_ARG)) {


