From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 9 Jul 2018 09:35:35 -0400
Subject: master - lvconvert: support to convert lv into vdopool
Message-ID: <201807091335.w69DZZ98030843@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7b8aa4af57a8064ea3fa29355283aada2dac0db0
Commit:        7b8aa4af57a8064ea3fa29355283aada2dac0db0
Parent:        6206bd0e790b92c8ec53c340902f74932675836f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Jun 30 23:38:49 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 9 15:29:16 2018 +0200

lvconvert: support to convert lv into vdopool

Support:

lvconvert --type vdo-pool  vg/lv

lvconvert --vdopool  vg/lv   --virtualsize 10G
---
 tools/command-lines.in |   18 ++++++++
 tools/lvconvert.c      |  112 ++++++++++++++++++++++++++++++++++++++++++++++++
 tools/lvmcmdline.c     |    4 ++
 tools/tools.h          |    3 +
 4 files changed, 137 insertions(+), 0 deletions(-)

diff --git a/tools/command-lines.in b/tools/command-lines.in
index 4db1a0a..bf36738 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -555,6 +555,24 @@ RULE: --poolmetadata not --readahead --stripesize --stripes_long
 
 ---
 
+lvconvert --type vdo-pool LV_linear_striped_raid_cache
+OO: --name LV_new, --virtualsize SizeMB, --compression Bool, --deduplication Bool, OO_LVCONVERT
+ID: lvconvert_to_vdopool
+DESC: Convert LV to type vdopool.
+RULE: all and lv_is_visible
+RULE: all not lv_is_locked lv_is_origin lv_is_merging_origin lv_is_external_origin lv_is_virtual
+
+lvconvert --vdopool LV_linear_striped_raid_cache
+OO: --type vdo-pool, OO_LVCONVERT,
+--name LV_new, --virtualsize SizeMB, --compression Bool, --deduplication Bool
+ID: lvconvert_to_vdopool_param
+DESC: Convert LV to type vdopool.
+RULE: all and lv_is_visible
+RULE: all not lv_is_locked lv_is_origin lv_is_merging_origin lv_is_external_origin lv_is_virtual
+FLAGS: SECONDARY_SYNTAX
+
+---
+
 lvconvert --splitcache LV_cachepool_cache_thinpool
 OO: OO_LVCONVERT
 ID: lvconvert_split_and_keep_cachepool
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 11f7cee..0bb1dc9 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -4740,6 +4740,118 @@ int lvconvert_merge_cmd(struct cmd_context *cmd, int argc, char **argv)
 	return ret;
 }
 
+static int _lvconvert_to_vdopool_single(struct cmd_context *cmd,
+					struct logical_volume *lv,
+					struct processing_handle *handle)
+{
+	const char *vg_name = NULL;
+	struct volume_group *vg = lv->vg;
+	struct logical_volume *vdo_lv;
+	struct dm_vdo_target_params vdo_params; /* vdo */
+	struct lvcreate_params lvc = {
+		.activate = CHANGE_AEY,
+		.alloc = ALLOC_INHERIT,
+		.major = -1,
+		.minor = -1,
+		.suppress_zero_warn = 1, /* Suppress warning for this VDO */
+		.permission = LVM_READ | LVM_WRITE,
+		.pool_name = lv->name,
+		.pvh = &vg->pvs,
+		.read_ahead = DM_READ_AHEAD_AUTO,
+		.stripes = 1,
+		.lv_name = arg_str_value(cmd, name_ARG, NULL),
+	};
+
+	if (lvc.lv_name &&
+	    !validate_restricted_lvname_param(cmd, &vg_name, &lvc.lv_name))
+		return_0;
+
+	lvc.virtual_extents = extents_from_size(cmd,
+						arg_uint_value(cmd, virtualsize_ARG, 0),
+						vg->extent_size);
+
+	if (!(lvc.segtype = get_segtype_from_string(cmd, SEG_TYPE_NAME_VDO)))
+		return_0;
+
+	if (vg_is_shared(vg)) {
+		/* FIXME: need to swap locks betwen LVs? */
+		log_error("Unable to convert VDO pool in VG with lock_type %s", vg->lock_type);
+		goto out;
+	}
+
+	if (!fill_vdo_target_params(cmd, &vdo_params, NULL))
+		goto_out;
+
+	if (arg_is_set(cmd, compression_ARG))
+		vdo_params.use_compression =
+			arg_int_value(cmd, compression_ARG, 0);
+
+	if (arg_is_set(cmd, deduplication_ARG))
+		vdo_params.use_deduplication =
+			arg_int_value(cmd, deduplication_ARG, 0);
+
+	if (!activate_lv(cmd, lv)) {
+		log_error("Cannot activate %s.", display_lvname(lv));
+		goto out;
+	}
+
+	log_warn("WARNING: Converting logical volume %s to VDO pool volume.",
+		 lv->name);
+	log_warn("THIS WILL DESTROY CONTENT OF LOGICAL VOLUME (filesystem etc.)");
+
+	if (!arg_count(cmd, yes_ARG) &&
+	    yes_no_prompt("Do you really want to convert %s? [y/n]: ",
+			  lv->name) == 'n') {
+		log_error("Conversion aborted.");
+		goto out;
+	}
+
+	if (!wipe_lv(lv, (struct wipe_params) { .do_zero = 1, .do_wipe_signatures = 1 })) {
+		log_error("Aborting. Failed to wipe VDO data store.");
+		goto out;
+	}
+
+	if (!archive(vg))
+		goto_out;
+
+	if (!convert_vdo_pool_lv(lv, &vdo_params, &lvc.virtual_extents))
+		goto_out;
+
+	dm_list_init(&lvc.tags);
+
+	if (!(vdo_lv = lv_create_single(vg, &lvc)))
+		goto_out; /* FIXME: hmmm what to do now */
+
+	log_print_unless_silent("Converted %s to VDO pool volume and created virtual %s VDO volume.",
+				display_lvname(lv), display_lvname(vdo_lv));
+
+	return ECMD_PROCESSED;
+
+ out:
+	return ECMD_FAILED;
+}
+
+int lvconvert_to_vdopool_cmd(struct cmd_context *cmd, int argc, char **argv)
+{
+	return process_each_lv(cmd, 1, cmd->position_argv, NULL, NULL, READ_FOR_UPDATE,
+			       NULL, NULL, &_lvconvert_to_vdopool_single);
+}
+
+int lvconvert_to_vdopool_param_cmd(struct cmd_context *cmd, int argc, char **argv)
+{
+	/* Make the LV the first position arg. */
+	int i, p = cmd->position_argc;
+
+	for (i = 0; i < cmd->position_argc; i++)
+		cmd->position_argv[p] = cmd->position_argv[p-1];
+
+	cmd->position_argv[0] = (char *)arg_str_value(cmd, vdopool_ARG, NULL);
+	cmd->position_argc++;
+
+	return process_each_lv(cmd, 1, cmd->position_argv, NULL, NULL, READ_FOR_UPDATE,
+			       NULL, NULL, &_lvconvert_to_vdopool_single);
+}
+
 /*
  * All lvconvert command defs have their own function,
  * so the generic function name is unused.
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 3e617c1..1146e7c 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -143,6 +143,10 @@ static const struct command_function _command_functions[CMD_COUNT] = {
 	/* redirected to merge_snapshot/merge_thin/merge_mirrors */
 	{ lvconvert_merge_CMD, lvconvert_merge_cmd },
 
+	/* lvconvert VDO pool */
+	{ lvconvert_to_vdopool_CMD, lvconvert_to_vdopool_cmd },
+	{ lvconvert_to_vdopool_param_CMD, lvconvert_to_vdopool_param_cmd },
+
 };
 
 
diff --git a/tools/tools.h b/tools/tools.h
index 508da84..d605768 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -267,4 +267,7 @@ int lvconvert_change_region_size_cmd(struct cmd_context * cmd, int argc, char **
 
 int lvconvert_merge_cmd(struct cmd_context *cmd, int argc, char **argv);
 
+int lvconvert_to_vdopool_cmd(struct cmd_context *cmd, int argc, char **argv);
+int lvconvert_to_vdopool_param_cmd(struct cmd_context *cmd, int argc, char **argv);
+
 #endif


