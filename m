From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 13 Feb 2017 18:10:16 +0000 (UTC)
Subject: master - lvconvert: use command defs for mergemirrors
Message-ID: <20170213181016.1ED2A6039D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=86d8ab493bbfbc0130a2bbe7717557ecc7fa33fd
Commit:        86d8ab493bbfbc0130a2bbe7717557ecc7fa33fd
Parent:        95e38607ecf44fece40dd4a1b078582554c93da1
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Dec 9 14:39:57 2016 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Feb 13 08:20:10 2017 -0600

lvconvert: use command defs for mergemirrors

and route the generic --merge to one of the
specific merge functions
---
 tools/args.h           |    1 +
 tools/command-lines.in |   54 ++++++++++++++---------------------
 tools/lvconvert.c      |   72 ++++++++++++++++++++++++++++++++++++++++++++++++
 tools/lvmcmdline.c     |   20 ++++++++-----
 tools/tools.h          |    4 ++
 5 files changed, 111 insertions(+), 40 deletions(-)

diff --git a/tools/args.h b/tools/args.h
index c904609..559bf16 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -60,6 +60,7 @@ arg(locktype_ARG, '\0', "locktype", locktype_VAL, 0, 0)
 arg(logonly_ARG, '\0', "logonly", 0, 0, 0)
 arg(maxrecoveryrate_ARG, '\0', "maxrecoveryrate", sizekb_VAL, 0, 0)
 arg(merge_ARG, '\0', "merge", 0, 0, 0)
+arg(mergemirrors_ARG, '\0', "mergemirrors", 0, 0, 0)
 arg(mergesnapshot_ARG, '\0', "mergesnapshot", 0, 0, 0)
 arg(mergethin_ARG, '\0', "mergethin", 0, 0, 0)
 arg(mergedconfig_ARG, '\0', "mergedconfig", 0, 0, 0)
diff --git a/tools/command-lines.in b/tools/command-lines.in
index 5804723..a529685 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -373,6 +373,12 @@ OP: PV ...
 ID: lvconvert_split_mirror_images
 DESC: Split images from a raid1 LV and track changes to origin.
 
+lvconvert --mergemirrors LV_linear_raid|VG|Tag ...
+OO: OO_LVCONVERT
+ID: lvconvert_merge_mirror_images
+DESC: Merge LV images that were split from a raid1 LV.
+RULE: all not lv_is_locked lv_is_pvmove lv_is_merging_origin lv_is_virtual_origin lv_is_external_origin lv_is_merging_cow
+
 lvconvert --mirrorlog MirrorLog LV_mirror
 OO: OO_LVCONVERT
 OP: PV ...
@@ -486,37 +492,30 @@ DESC: Swap metadata LV in a thin pool or cache pool (for repair only).
 
 ---
 
-# FIXME: lvconvert --merge is an extremely ambiguous command.
+# lvconvert --merge is an extremely ambiguous command.
 # It can do very different operations, but which one depends
 # on knowing the LV type.  So, the command doesn't know what
 # it's actually doing until quite late, when processing a
-# single LV.
-#
-# Use different option names for different merge operations
-# so that we can have different command definitions,
-# different behaviors, different optional options, etc:
-#
-# lvconvert --merge-mirror LV_linear_striped_raid ...
-# DESC: Merge LV that was previously split from a mirror.
-#
-# lvconvert --merge-thin LV_thin
-# DESC: Merge thin LV into its origin LV.
-#
-# lvconvert --merge-snapshot LV_snapshot
-# DESC: Merge COW snapshot LV into its origin.
-#
-# Then we could add VG|Tag to --merge-mirror arg pos 1, because
-# "lvconvert --merge VG|Tag" is a terrible command.  It will do
-# different operations on each LV it finds, depending on the
-# current LV type.
+# single LV.  When passed a VG or tag, it will do different
+# operations on each LV it finds, depending on the current LV type.
 
 lvconvert --merge LV_linear_striped_raid_thin_snapshot|VG|Tag ...
 OO: --background, --interval Number, OO_LVCONVERT
 ID: lvconvert_merge
-DESC: Merge LV that was previously split from a mirror.
+DESC: Merge LV that was split from a mirror (variant, use --mergemirrors).
+DESC: Merge thin LV into its origin LV (variant, use --mergethin).
+DESC: Merge COW snapshot LV into its origin (variant, use --mergesnapshot).
+RULE: all not lv_is_locked lv_is_pvmove lv_is_merging_origin lv_is_virtual_origin lv_is_external_origin lv_is_merging_cow
+FLAGS: SECONDARY_SYNTAX
+
+---
+
+lvconvert --mergethin LV_thin ...
+OO: OO_LVCONVERT
+ID: lvconvert_merge_thin
 DESC: Merge thin LV into its origin LV.
-DESC: Merge COW snapshot LV into its origin.
 RULE: all not lv_is_locked lv_is_pvmove lv_is_merging_origin lv_is_virtual_origin lv_is_external_origin lv_is_merging_cow
+RULE: all and lv_is_visible
 
 ---
 
@@ -526,7 +525,7 @@ RULE: all not lv_is_locked lv_is_pvmove lv_is_merging_origin lv_is_virtual_origi
 lvconvert --mergesnapshot LV_snapshot ...
 OO: --background, --interval Number, OO_LVCONVERT
 ID: lvconvert_merge_snapshot
-DESC: Merge LV that was previously split from a mirror.
+DESC: Merge COW snapshot LV into its origin.
 RULE: all not lv_is_locked lv_is_pvmove lv_is_merging_origin lv_is_virtual_origin lv_is_external_origin lv_is_merging_cow
 RULE: all and lv_is_visible
 
@@ -889,15 +888,6 @@ DESC: (infers --type thin).
 
 ---
 
-lvconvert --mergethin LV_thin ...
-OO: --background, --interval Number, OO_LVCONVERT
-ID: lvconvert_merge_thin
-DESC: Merge thin LV into its origin LV.
-RULE: all not lv_is_locked lv_is_pvmove lv_is_merging_origin lv_is_virtual_origin lv_is_external_origin lv_is_merging_cow
-RULE: all and lv_is_visible
-
----
-
 # stripes option is not intuitive when creating a thin LV,
 # but here it applies to creating the new thin pool that
 # is used for the thin LV
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index da70cbd..296d4e2 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -6399,3 +6399,75 @@ int lvconvert_split_cachepool_cmd(struct cmd_context *cmd, int argc, char **argv
 			       NULL, NULL, &_lvconvert_split_cachepool_single);
 }
 
+static int _lvconvert_merge_mirror_images_single(struct cmd_context *cmd,
+					  struct logical_volume *lv,
+					  struct processing_handle *handle)
+{
+	if (!lv_raid_merge(lv))
+		return ECMD_FAILED;
+
+	return ECMD_PROCESSED;
+}
+
+int lvconvert_merge_mirror_images_cmd(struct cmd_context *cmd, int argc, char **argv)
+{
+	cmd->command->flags &= ~GET_VGNAME_FROM_OPTIONS;
+
+	return process_each_lv(cmd, cmd->position_argc, cmd->position_argv, NULL, NULL, READ_FOR_UPDATE,
+			       NULL, NULL, &_lvconvert_merge_mirror_images_single);
+}
+
+static int _lvconvert_merge_generic_single(struct cmd_context *cmd,
+					 struct logical_volume *lv,
+					 struct processing_handle *handle)
+{
+	int ret;
+
+	if (lv_is_cow(lv))
+		ret = _lvconvert_merge_snapshot_single(cmd, lv, handle);
+
+	else if (lv_is_thin_volume(lv))
+		ret = _lvconvert_merge_thin_single(cmd, lv, handle);
+
+	else
+		ret = _lvconvert_merge_mirror_images_single(cmd, lv, handle);
+
+	return ret;
+}
+
+int lvconvert_merge_cmd(struct cmd_context *cmd, int argc, char **argv)
+{
+	struct processing_handle *handle;
+	struct lvconvert_result lr = { 0 };
+	struct convert_poll_id_list *idl;
+	int ret, poll_ret;
+
+	dm_list_init(&lr.poll_idls);
+
+	if (!(handle = init_processing_handle(cmd, NULL))) {
+		log_error("Failed to initialize processing handle.");
+		return ECMD_FAILED;
+	}
+
+	handle->custom_handle = &lr;
+
+	cmd->command->flags &= ~GET_VGNAME_FROM_OPTIONS;
+
+	ret = process_each_lv(cmd, cmd->position_argc, cmd->position_argv, NULL, NULL, READ_FOR_UPDATE,
+			      handle, NULL, &_lvconvert_merge_generic_single);
+
+	/* polling is only used by merge_snapshot */
+	if (lr.need_polling) {
+		dm_list_iterate_items(idl, &lr.poll_idls) {
+			poll_ret = _lvconvert_poll_by_id(cmd, idl->id,
+						arg_is_set(cmd, background_ARG), 1, 0);
+			if (poll_ret > ret)
+				ret = poll_ret;
+		}
+	}
+
+	destroy_processing_handle(cmd, handle);
+
+	return ret;
+}
+
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 85fd1b8..c100311 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -146,19 +146,23 @@ struct command_function command_functions[COMMAND_ID_COUNT] = {
 	{ lvconvert_merge_thin_CMD,			lvconvert_merge_thin_cmd },
 	{ lvconvert_split_and_keep_cachepool_CMD,	lvconvert_split_cachepool_cmd },
 	{ lvconvert_split_and_remove_cachepool_CMD,	lvconvert_split_cachepool_cmd },
-};
 
+	/* lvconvert utilities for raid/mirror */
+	{ lvconvert_merge_mirror_images_CMD,		lvconvert_merge_mirror_images_cmd },
 #if 0
-	/* all raid-related type conversions */
-	{ lvconvert_raid_types_CMD,			lvconvert_raid_types_fn },
+	{ lvconvert_split_mirror_images_CMD,		lvconvert_split_mirror_images_cmd },
+	{ lvconvert_change_mirrorlog_CMD,		lvconvert_change_mirrorlog_cmd },
+#endif
 
-	/* raid-related utilities (move into lvconvert_raid_types?) */
-	{ lvconvert_split_mirror_images_CMD,		lvconvert_split_mirror_images_fn },
-	{ lvconvert_change_mirrorlog_CMD,		lvconvert_change_mirrorlog_fn },
+	/* redirected to merge_snapshot/merge_thin/merge_mirrors */
+	{ lvconvert_merge_CMD, lvconvert_merge_cmd },
 
-	/* directed to one of the other merges (snap,thin,mirror) when all are implemented */
-	{ lvconvert_merge_CMD,				lvconvert_merge_fn },
+#if 0
+	/* all raid-related type conversions */
+	{ lvconvert_raid_types_CMD,			lvconvert_raid_types_cmd },
 #endif
+};
+
 
 /* Command line args */
 unsigned arg_count(const struct cmd_context *cmd, int a)
diff --git a/tools/tools.h b/tools/tools.h
index 2deded9..4bba46c 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -271,4 +271,8 @@ int lvconvert_swap_pool_metadata_cmd(struct cmd_context *cmd, int argc, char **a
 int lvconvert_merge_thin_cmd(struct cmd_context *cmd, int argc, char **argv);
 int lvconvert_split_cachepool_cmd(struct cmd_context *cmd, int argc, char **argv);
 
+int lvconvert_merge_mirror_images_cmd(struct cmd_context *cmd, int argc, char **argv);
+
+int lvconvert_merge_cmd(struct cmd_context *cmd, int argc, char **argv);
+
 #endif


