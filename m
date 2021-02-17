From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 17 Feb 2021 10:54:40 +0000 (GMT)
Subject: main - lvconvert: vdo may convert already formated vdo
Message-ID: <20210217105440.2FA4C3857C60@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a915cd5a46dca80bb1ce981a2ee923b8e813d887
Commit:        a915cd5a46dca80bb1ce981a2ee923b8e813d887
Parent:        f87ff95e329fce701ec93888a9bea7e7da7151a1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 16 21:26:35 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Feb 17 11:21:35 2021 +0100

lvconvert: vdo may convert already formated vdo

User use 'lvconvert -Zn --type vdo-pool' to convert an existing
vdo formated volume and skip lvm2 internal formating.
This however requires user is passing proper matching parameters.
For them user can use --profile|--metadataprofile option whos
support has been also enhanced.

TODO: add support to read values directly from formated volume.
---
 lib/metadata/lv_manip.c          |  5 ++++-
 lib/metadata/metadata-exported.h |  3 ++-
 lib/metadata/vdo_manip.c         | 15 +++++++++++----
 tools/command-lines.in           | 10 +++++++---
 tools/lvconvert.c                | 33 +++++++++++++++++++++------------
 tools/lvmcmdline.c               |  1 +
 6 files changed, 46 insertions(+), 21 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 5784e407d..5cad4e07a 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -7469,6 +7469,9 @@ struct logical_volume *insert_layer_for_lv(struct cmd_context *cmd,
 	lv_where->le_count = layer_lv->le_count;
 	lv_where->size = (uint64_t) lv_where->le_count * lv_where->vg->extent_size;
 
+	if (lv_where->vg->fid->fmt->features & FMT_CONFIG_PROFILE)
+		lv_where->profile = lv_where->vg->cmd->profile_params->global_metadata_profile;
+
 	/*
 	 * recuresively rename sub LVs
 	 *   currently supported only for thin data layer
@@ -8693,7 +8696,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 	}
 
 	if (seg_is_vdo_pool(lp)) {
-		if (!convert_vdo_pool_lv(lv, &lp->vdo_params, &lp->virtual_extents)) {
+		if (!convert_vdo_pool_lv(lv, &lp->vdo_params, &lp->virtual_extents, 1)) {
 			stack;
 			goto deactivate_and_revert_new_lv;
 		}
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index ac384497b..874088993 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1355,7 +1355,8 @@ int parse_vdo_pool_status(struct dm_pool *mem, const struct logical_volume *vdo_
 			  const char *params, struct lv_status_vdo *status);
 struct logical_volume *convert_vdo_pool_lv(struct logical_volume *data_lv,
 					   const struct dm_vdo_target_params *vtp,
-					   uint32_t *virtual_extents);
+					   uint32_t *virtual_extents,
+					   int format);
 int set_vdo_write_policy(enum dm_vdo_write_policy *vwp, const char *policy);
 int fill_vdo_target_params(struct cmd_context *cmd,
 			   struct dm_vdo_target_params *vtp,
diff --git a/lib/metadata/vdo_manip.c b/lib/metadata/vdo_manip.c
index 30682449c..7d5a2cb5a 100644
--- a/lib/metadata/vdo_manip.c
+++ b/lib/metadata/vdo_manip.c
@@ -355,7 +355,8 @@ static int _format_vdo_pool_data_lv(struct logical_volume *data_lv,
  */
 struct logical_volume *convert_vdo_pool_lv(struct logical_volume *data_lv,
 					   const struct dm_vdo_target_params *vtp,
-					   uint32_t *virtual_extents)
+					   uint32_t *virtual_extents,
+					   int format)
 {
 	const uint64_t header_size = DEFAULT_VDO_POOL_HEADER_SIZE;
 	const uint32_t extent_size = data_lv->vg->extent_size;
@@ -384,9 +385,15 @@ struct logical_volume *convert_vdo_pool_lv(struct logical_volume *data_lv,
 		return_0;
 
 	/* Format data LV as VDO volume */
-	if (!_format_vdo_pool_data_lv(data_lv, vtp, &vdo_logical_size)) {
-		log_error("Cannot format VDO pool volume %s.", display_lvname(data_lv));
-		return NULL;
+	if (format) {
+		if (!_format_vdo_pool_data_lv(data_lv, vtp, &vdo_logical_size)) {
+			log_error("Cannot format VDO pool volume %s.", display_lvname(data_lv));
+			return NULL;
+		}
+	} else {
+		log_verbose("Skiping VDO formating %s.", display_lvname(data_lv));
+		/* TODO: parse existing VDO data and retrieve vdo_logical_size */
+		vdo_logical_size = data_lv->size;
 	}
 
 	if (!deactivate_lv(data_lv->vg->cmd, data_lv)) {
diff --git a/tools/command-lines.in b/tools/command-lines.in
index 7c7551405..2aadd5f40 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -324,6 +324,10 @@ OO_LVCONVERT_CACHE: --cachemetadataformat CacheMetadataFormat,
 --cachemode CacheMode, --cachepolicy String,
 --cachesettings String, --zero Bool
 
+OO_LVCONVERT_VDO: --metadataprofile String --readahead Readahead,
+--compression Bool, --deduplication Bool
+--zero Bool
+
 OO_LVCONVERT: --alloc Alloc, --background, --force, --noudevsync
 
 ---
@@ -604,15 +608,15 @@ RULE: --poolmetadata not --readahead --stripesize --stripes_long
 ---
 
 lvconvert --type vdo-pool LV_linear_striped_raid_cache
-OO: --name LV_new, --virtualsize SizeMB, --compression Bool, --deduplication Bool, OO_LVCONVERT
+OO: --name LV_new, --virtualsize SizeMB, OO_LVCONVERT_VDO, OO_LVCONVERT
 ID: lvconvert_to_vdopool
 DESC: Convert LV to type vdopool.
 RULE: all and lv_is_visible
 RULE: all not lv_is_locked lv_is_origin lv_is_merging_origin lv_is_external_origin lv_is_virtual lv_is_raid_with_integrity
 
 lvconvert --vdopool LV_linear_striped_raid_cache
-OO: --type vdo-pool, OO_LVCONVERT,
---name LV_new, --virtualsize SizeMB, --compression Bool, --deduplication Bool
+OO: --type vdo-pool, OO_LVCONVERT_VDO, OO_LVCONVERT
+--name LV_new, --virtualsize SizeMB,
 ID: lvconvert_to_vdopool_param
 DESC: Convert LV to type vdopool.
 RULE: all and lv_is_visible
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 8df30ff02..ef31799fa 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -5443,6 +5443,7 @@ static int _lvconvert_to_vdopool_single(struct cmd_context *cmd,
 					struct processing_handle *handle)
 {
 	const char *vg_name = NULL;
+	unsigned int zero_vdopool;
 	struct volume_group *vg = lv->vg;
 	struct logical_volume *vdo_lv;
 	struct dm_vdo_target_params vdo_params; /* vdo */
@@ -5455,7 +5456,7 @@ static int _lvconvert_to_vdopool_single(struct cmd_context *cmd,
 		.permission = LVM_READ | LVM_WRITE,
 		.pool_name = lv->name,
 		.pvh = &vg->pvs,
-		.read_ahead = DM_READ_AHEAD_AUTO,
+		.read_ahead = arg_uint_value(cmd, readahead_ARG, DM_READ_AHEAD_AUTO),
 		.stripes = 1,
 		.lv_name = arg_str_value(cmd, name_ARG, NULL),
 	};
@@ -5477,7 +5478,7 @@ static int _lvconvert_to_vdopool_single(struct cmd_context *cmd,
 		goto out;
 	}
 
-	if (!fill_vdo_target_params(cmd, &vdo_params, NULL))
+	if (!fill_vdo_target_params(cmd, &vdo_params, vg->profile))
 		goto_out;
 
 	if (arg_is_set(cmd, compression_ARG))
@@ -5493,28 +5494,36 @@ static int _lvconvert_to_vdopool_single(struct cmd_context *cmd,
 		goto out;
 	}
 
-	log_warn("WARNING: Converting logical volume %s to VDO pool volume.",
-		 lv->name);
-	log_warn("THIS WILL DESTROY CONTENT OF LOGICAL VOLUME (filesystem etc.)");
+	zero_vdopool = arg_int_value(cmd, zero_ARG, 1);
+
+	log_warn("WARNING: Converting logical volume %s to VDO pool volume %s formating.",
+		 display_lvname(lv), zero_vdopool ? "with" : "WITHOUT");
+
+	if (zero_vdopool)
+		log_warn("THIS WILL DESTROY CONTENT OF LOGICAL VOLUME (filesystem etc.)");
+	else
+		log_warn("WARNING: Using invalid VDO pool data MAY DESTROY YOUR DATA!");
 
 	if (!arg_count(cmd, yes_ARG) &&
 	    yes_no_prompt("Do you really want to convert %s? [y/n]: ",
-			  lv->name) == 'n') {
+			  display_lvname(lv)) == 'n') {
 		log_error("Conversion aborted.");
 		goto out;
 	}
 
-	if (!wipe_lv(lv, (struct wipe_params) { .do_zero = 1, .do_wipe_signatures = 1,
-		     .yes = arg_count(cmd, yes_ARG),
-		     .force = arg_count(cmd, force_ARG)})) {
-		log_error("Aborting. Failed to wipe VDO data store.");
-		goto out;
+	if (zero_vdopool) {
+		if (!wipe_lv(lv, (struct wipe_params) { .do_zero = 1, .do_wipe_signatures = 1,
+			     .yes = arg_count(cmd, yes_ARG),
+			     .force = arg_count(cmd, force_ARG)})) {
+			log_error("Aborting. Failed to wipe VDO data store.");
+			goto out;
+		}
 	}
 
 	if (!archive(vg))
 		goto_out;
 
-	if (!convert_vdo_pool_lv(lv, &vdo_params, &lvc.virtual_extents))
+	if (!convert_vdo_pool_lv(lv, &vdo_params, &lvc.virtual_extents, zero_vdopool))
 		goto_out;
 
 	dm_list_init(&lvc.tags);
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 5b7951f3b..560c78a77 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -2699,6 +2699,7 @@ static int _prepare_profiles(struct cmd_context *cmd)
 		 * The --commandprofile is assumed otherwise.
 		 */
 		if (!strcmp(cmd->command->name, "lvcreate") ||
+		    !strcmp(cmd->command->name, "lvconvert") ||
 		    !strcmp(cmd->command->name, "vgcreate") ||
 		    !strcmp(cmd->command->name, "lvchange") ||
 		    !strcmp(cmd->command->name, "vgchange")) {


