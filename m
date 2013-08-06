From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue,  6 Aug 2013 09:43:33 +0000 (UTC)
Subject: master - thin: apply VG profile if creating a new thin pool
Message-ID: <20130806094333.267C161289@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e195b5227e624cb125b070b4a10e24efdab16d53
Commit:        e195b5227e624cb125b070b4a10e24efdab16d53
Parent:        1cdd563b6cb238d63f3f9a7f2448ef3c4d1368ae
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Aug 6 11:42:40 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Aug 6 11:42:40 2013 +0200

thin: apply VG profile if creating a new thin pool

When creating a new thin pool and there's no profile requested
via "lvcreate --profile ...", inherit any VG profile if it's attached.

Currently this applies to these settings:
  allocation/thin_pool_chunk_size
  allocation/thin_pool_discards
  allocation/thin_pool_zero
---
 WHATS_NEW                        |    1 +
 lib/metadata/metadata-exported.h |    7 +++++--
 lib/metadata/thin_manip.c        |   38 ++++++++++++++++++++++++++++++++++++--
 tools/lvconvert.c                |    8 ++++----
 tools/lvcreate.c                 |    4 ++--
 tools/toollib.c                  |   16 ++++++----------
 6 files changed, 54 insertions(+), 20 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 69a8275..b289bf2 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.100 -
 ================================
+  Inherit and apply any profile attached to a VG if creating new thin pool.
   Add initial support thin pool lvconvert --repair.
   Add --with-thin-repair and --with-thin-dump configure options.
   Add lvm.conf thin_repair/dump_executable and thin_repair_options.
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 67dc7f7..d214fd2 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -656,10 +656,13 @@ struct logical_volume *find_pool_lv(struct logical_volume *lv);
 int pool_is_active(const struct logical_volume *pool_lv);
 int pool_can_resize_metadata(const struct logical_volume *pool_lv);
 int update_pool_lv(struct logical_volume *lv, int activate);
-int update_pool_params(struct cmd_context *cmd, unsigned attr, int passed_args,
+int update_profilable_pool_params(struct cmd_context *cmd, struct profile *profile,
+				  int passed_args, uint32_t *chunk_size,
+				  thin_discards_t *discards, int *zero);
+int update_pool_params(struct volume_group *vg, unsigned attr, int passed_args,
 		       uint32_t data_extents, uint32_t extent_size,
 		       uint32_t *chunk_size, thin_discards_t *discards,
-		       uint64_t *pool_metadata_size);
+		       uint64_t *pool_metadata_size, int *zero);
 int get_pool_discards(const char *str, thin_discards_t *discards);
 const char *get_pool_discards_name(thin_discards_t discards);
 struct logical_volume *alloc_pool_metadata(struct logical_volume *pool_lv,
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index 6851b3f..36cd6c4 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -569,12 +569,46 @@ int update_pool_lv(struct logical_volume *lv, int activate)
 	return 1;
 }
 
-int update_pool_params(struct cmd_context *cmd, unsigned attr, int passed_args,
+int update_profilable_pool_params(struct cmd_context *cmd, struct profile *profile,
+				  int passed_args, uint32_t *chunk_size,
+				  thin_discards_t *discards, int *zero)
+{
+	const char *dstr;
+
+	if (!(passed_args & PASS_ARG_CHUNK_SIZE)) {
+		*chunk_size = find_config_tree_int(cmd, allocation_thin_pool_chunk_size_CFG, profile) * 2;
+		if ((*chunk_size < DM_THIN_MIN_DATA_BLOCK_SIZE) ||
+		    (*chunk_size > DM_THIN_MAX_DATA_BLOCK_SIZE)) {
+			log_error("Chunk size must be in the range %s to %s.",
+				  display_size(cmd, DM_THIN_MIN_DATA_BLOCK_SIZE),
+				  display_size(cmd, DM_THIN_MAX_DATA_BLOCK_SIZE));
+			return 0;
+		}
+	}
+
+	if (!(passed_args & PASS_ARG_DISCARDS)) {
+		dstr = find_config_tree_str(cmd, allocation_thin_pool_discards_CFG, profile);
+		if (!get_pool_discards(dstr, discards))
+			return_0;
+	}
+
+	if (!(passed_args & PASS_ARG_ZERO))
+		*zero = find_config_tree_bool(cmd, allocation_thin_pool_zero_CFG, profile);
+
+	return 1;
+}
+
+int update_pool_params(struct volume_group *vg, unsigned attr, int passed_args,
 		       uint32_t data_extents, uint32_t extent_size,
 		       uint32_t *chunk_size, thin_discards_t *discards,
-		       uint64_t *pool_metadata_size)
+		       uint64_t *pool_metadata_size, int *zero)
 {
 	size_t estimate_chunk_size;
+	struct cmd_context *cmd = vg->cmd;
+
+	if (!update_profilable_pool_params(cmd, vg->profile, passed_args,
+					   chunk_size, discards, zero))
+		return_0;
 
 	if (!(attr & THIN_FEATURE_BLOCK_SIZE) &&
 	    (*chunk_size & (*chunk_size - 1))) {
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 88e0119..f008954 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2293,10 +2293,10 @@ static int _lvconvert_thinpool(struct cmd_context *cmd,
 	}
 
 	if (!lp->pool_metadata_lv_name) {
-		if (!update_pool_params(cmd, lp->target_attr, lp->passed_args,
+		if (!update_pool_params(pool_lv->vg, lp->target_attr, lp->passed_args,
 					pool_lv->le_count, pool_lv->vg->extent_size,
 					&lp->chunk_size, &lp->discards,
-					&lp->poolmetadata_size))
+					&lp->poolmetadata_size, &lp->zero))
 			return_0;
 
 		if (!get_stripe_params(cmd, &lp->stripes, &lp->stripe_size))
@@ -2399,10 +2399,10 @@ static int _lvconvert_thinpool(struct cmd_context *cmd,
 				  display_size(cmd, 2 * DEFAULT_THIN_POOL_MIN_METADATA_SIZE));
 			return 0;
 		}
-		if (!update_pool_params(cmd, lp->target_attr, lp->passed_args,
+		if (!update_pool_params(pool_lv->vg, lp->target_attr, lp->passed_args,
 					pool_lv->le_count, pool_lv->vg->extent_size,
 					&lp->chunk_size, &lp->discards,
-					&lp->poolmetadata_size))
+					&lp->poolmetadata_size, &lp->zero))
 			return_0;
 	}
 
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 8564613..095adbb 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -334,10 +334,10 @@ static int _update_extents_params(struct volume_group *vg,
 	}
 
 	if (lp->create_thin_pool) {
-		if (!update_pool_params(vg->cmd, lp->target_attr, lp->passed_args,
+		if (!update_pool_params(vg, lp->target_attr, lp->passed_args,
 					lp->extents, vg->extent_size,
 					&lp->chunk_size, &lp->discards,
-					&lp->poolmetadatasize))
+					&lp->poolmetadatasize, &lp->zero))
 			return_0;
 
 		if (!(lp->poolmetadataextents =
diff --git a/tools/toollib.c b/tools/toollib.c
index ce449e7..7944d23 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1547,25 +1547,18 @@ int get_pool_params(struct cmd_context *cmd,
 		    uint64_t *pool_metadata_size,
 		    int *zero)
 {
-	const char *dstr;
-
 	*passed_args = 0;
 	if (arg_count(cmd, zero_ARG)) {
 		*passed_args |= PASS_ARG_ZERO;
 		*zero = strcmp(arg_str_value(cmd, zero_ARG, "y"), "n");
 		log_very_verbose("Setting pool zeroing: %u", *zero);
-	} else
-		*zero = find_config_tree_bool(cmd, allocation_thin_pool_zero_CFG, profile);
+	}
 
 	if (arg_count(cmd, discards_ARG)) {
 		*passed_args |= PASS_ARG_DISCARDS;
 		*discards = (thin_discards_t) arg_uint_value(cmd, discards_ARG, 0);
 		log_very_verbose("Setting pool discards: %s",
 				 get_pool_discards_name(*discards));
-	} else {
-		dstr = find_config_tree_str(cmd, allocation_thin_pool_discards_CFG, profile);
-		if (!get_pool_discards(dstr, discards))
-			return_0;
 	}
 
 	if (arg_count(cmd, chunksize_ARG)) {
@@ -1578,8 +1571,11 @@ int get_pool_params(struct cmd_context *cmd,
 					     DM_THIN_MIN_DATA_BLOCK_SIZE);
 		log_very_verbose("Setting pool chunk size: %s",
 				 display_size(cmd, *chunk_size));
-	} else
-		*chunk_size = find_config_tree_int(cmd, allocation_thin_pool_chunk_size_CFG, profile) * 2;
+	}
+
+	if (!update_profilable_pool_params(cmd, profile, *passed_args,
+					   chunk_size, discards, zero))
+		return_0;
 
 	if ((*chunk_size < DM_THIN_MIN_DATA_BLOCK_SIZE) ||
 	    (*chunk_size > DM_THIN_MAX_DATA_BLOCK_SIZE)) {


