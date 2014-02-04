From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Tue,  4 Feb 2014 15:58:57 +0000 (UTC)
Subject: master - misc: disambiguate 'update_pool_params'
Message-ID: <20140204155857.2C51A6021E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8ddc7f641ced0a32801d978cd4e8a70883c4897a
Commit:        8ddc7f641ced0a32801d978cd4e8a70883c4897a
Parent:        afe2ba657bfa20fa755e71a039ee9cb9027adb1b
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Tue Feb 4 09:58:35 2014 -0600
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Tue Feb 4 09:58:35 2014 -0600

misc: disambiguate 'update_pool_params'

s/update_pool_params/update_thin_pool_params/ to disambiguate it from
a future 'update_cache_pool_params'.
---
 lib/metadata/metadata-exported.h |   11 ++++++-----
 lib/metadata/thin_manip.c        |   11 ++++++-----
 tools/lvconvert.c                |   26 ++++++++++++++++++--------
 tools/lvcreate.c                 |   16 +++++++++++-----
 4 files changed, 41 insertions(+), 23 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index d8eef2d..8258b24 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -700,11 +700,12 @@ int update_profilable_pool_params(struct cmd_context *cmd, struct profile *profi
 				  int passed_args, int *chunk_size_calc_method,
 				  uint32_t *chunk_size, thin_discards_t *discards,
 				  int *zero);
-int update_pool_params(struct volume_group *vg, unsigned attr, int passed_args,
-		       uint32_t data_extents, uint32_t extent_size,
-		       int *chunk_size_calc_method, uint32_t *chunk_size,
-		       thin_discards_t *discards,
-		       uint64_t *pool_metadata_size, int *zero);
+int update_thin_pool_params(struct volume_group *vg, unsigned attr,
+			    int passed_args,
+			    uint32_t data_extents, uint32_t extent_size,
+			    int *chunk_size_calc_method, uint32_t *chunk_size,
+			    thin_discards_t *discards,
+			    uint64_t *pool_metadata_size, int *zero);
 int get_pool_discards(const char *str, thin_discards_t *discards);
 const char *get_pool_discards_name(thin_discards_t discards);
 struct logical_volume *alloc_pool_metadata(struct logical_volume *pool_lv,
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index 60e93f0..0449b45 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -420,11 +420,12 @@ int update_profilable_pool_params(struct cmd_context *cmd, struct profile *profi
 	return 1;
 }
 
-int update_pool_params(struct volume_group *vg, unsigned attr, int passed_args,
-		       uint32_t data_extents, uint32_t extent_size,
-		       int *chunk_size_calc_method, uint32_t *chunk_size,
-		       thin_discards_t *discards, uint64_t *pool_metadata_size,
-		       int *zero)
+int update_thin_pool_params(struct volume_group *vg, unsigned attr,
+			    int passed_args,
+			    uint32_t data_extents, uint32_t extent_size,
+			    int *chunk_size_calc_method, uint32_t *chunk_size,
+			    thin_discards_t *discards,
+			    uint64_t *pool_metadata_size, int *zero)
 {
 	size_t estimate_chunk_size;
 	struct cmd_context *cmd = vg->cmd;
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 2ab4115..7d28b43 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2645,10 +2645,15 @@ static int _lvconvert_thinpool(struct cmd_context *cmd,
 	}
 
 	if (!lp->pool_metadata_lv_name) {
-		if (!update_pool_params(pool_lv->vg, lp->target_attr, lp->passed_args,
-					pool_lv->le_count, pool_lv->vg->extent_size,
-					&lp->thin_chunk_size_calc_policy, &lp->chunk_size,
-					&lp->discards, &lp->poolmetadata_size, &lp->zero))
+		if (!update_thin_pool_params(pool_lv->vg, lp->target_attr,
+					     lp->passed_args,
+					     pool_lv->le_count,
+					     pool_lv->vg->extent_size,
+					     &lp->thin_chunk_size_calc_policy,
+					     &lp->chunk_size,
+					     &lp->discards,
+					     &lp->poolmetadata_size,
+					     &lp->zero))
 			return_0;
 
 		if (!get_stripe_params(cmd, &lp->stripes, &lp->stripe_size))
@@ -2752,10 +2757,15 @@ static int _lvconvert_thinpool(struct cmd_context *cmd,
 				  display_size(cmd, 2 * DEFAULT_THIN_POOL_MIN_METADATA_SIZE));
 			return 0;
 		}
-		if (!update_pool_params(pool_lv->vg, lp->target_attr, lp->passed_args,
-					pool_lv->le_count, pool_lv->vg->extent_size,
-					&lp->thin_chunk_size_calc_policy, &lp->chunk_size,
-					&lp->discards, &lp->poolmetadata_size, &lp->zero))
+		if (!update_thin_pool_params(pool_lv->vg, lp->target_attr,
+					     lp->passed_args,
+					     pool_lv->le_count,
+					     pool_lv->vg->extent_size,
+					     &lp->thin_chunk_size_calc_policy,
+					     &lp->chunk_size,
+					     &lp->discards,
+					     &lp->poolmetadata_size,
+					     &lp->zero))
 			return_0;
 
 		metadata_lv->status |= LV_TEMPORARY;
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index c8206ca..ba7df2a 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -227,6 +227,16 @@ static int _determine_snapshot_type(struct volume_group *vg,
 	return 1;
 }
 
+static int _lvcreate_update_pool_params(struct volume_group *vg,
+					struct lvcreate_params *lp)
+{
+	return update_thin_pool_params(vg, lp->target_attr, lp->passed_args,
+				       lp->extents, vg->extent_size,
+				       &lp->thin_chunk_size_calc_policy,
+				       &lp->chunk_size, &lp->discards,
+				       &lp->poolmetadatasize, &lp->zero);
+}
+
 /*
  * Update extents parameters based on other parameters which affect the size
  * calculation.
@@ -334,11 +344,7 @@ static int _update_extents_params(struct volume_group *vg,
 	}
 
 	if (lp->create_pool) {
-		if (!update_pool_params(vg, lp->target_attr, lp->passed_args,
-					lp->extents, vg->extent_size,
-					&lp->thin_chunk_size_calc_policy,
-					&lp->chunk_size, &lp->discards,
-					&lp->poolmetadatasize, &lp->zero))
+		if (!_lvcreate_update_pool_params(vg, lp))
 			return_0;
 
 		if (!(lp->poolmetadataextents =


