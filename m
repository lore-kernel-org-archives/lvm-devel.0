From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 13 Feb 2017 18:10:56 +0000 (UTC)
Subject: master - lvconvert: add command to change region size of a raid LV
Message-ID: <20170213181056.49C6560CD7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=46abc28a480069b3e8b2c5c7c3448ffa25ec17ba
Commit:        46abc28a480069b3e8b2c5c7c3448ffa25ec17ba
Parent:        8152e4a99ee075c84fab9ec46485b798a1a6525d
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Feb 7 11:52:13 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Feb 13 08:21:58 2017 -0600

lvconvert: add command to change region size of a raid LV

---
 lib/metadata/metadata-exported.h        |    2 ++
 lib/metadata/raid_manip.c               |    6 ++++++
 test/shell/lvconvert-raid-regionsize.sh |    2 +-
 tools/command-lines.in                  |    7 +++++++
 tools/lvconvert.c                       |   15 +++++++++++++++
 tools/lvmcmdline.c                      |    1 +
 tools/tools.h                           |    1 +
 7 files changed, 33 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 420893c..573c09d 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1230,6 +1230,8 @@ uint32_t raid_rmeta_extents_delta(struct cmd_context *cmd,
 uint32_t raid_rimage_extents(const struct segment_type *segtype,
 			     uint32_t extents, uint32_t stripes, uint32_t data_copies);
 uint32_t raid_ensure_min_region_size(const struct logical_volume *lv, uint64_t raid_size, uint32_t region_size);
+int lv_raid_change_region_size(struct logical_volume *lv,
+                               int yes, int force, uint32_t new_region_size);
 /* --  metadata/raid_manip.c */
 
 /* ++  metadata/cache_manip.c */
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index eaafd65..cdd7af8 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -4338,6 +4338,12 @@ int lv_raid_convert(struct logical_volume *lv,
 			   region_size, allocate_pvs);
 }
 
+int lv_raid_change_region_size(struct logical_volume *lv,
+		    int yes, int force, uint32_t new_region_size)
+{
+	return _region_size_change_requested(lv, yes, new_region_size);
+}
+
 static int _remove_partial_multi_segment_image(struct logical_volume *lv,
 					       struct dm_list *remove_pvs)
 {
diff --git a/test/shell/lvconvert-raid-regionsize.sh b/test/shell/lvconvert-raid-regionsize.sh
index 7a6c7f0..9baa99a 100644
--- a/test/shell/lvconvert-raid-regionsize.sh
+++ b/test/shell/lvconvert-raid-regionsize.sh
@@ -27,7 +27,7 @@ function _test_regionsize
 	local vg=$4
 	local lv=$5
 
-	lvconvert --type $type --yes -R $regionsize $vg/$lv
+	lvconvert --yes -R $regionsize $vg/$lv
 	[ $? -ne 0 ] && return 1
 	check lv_field $vg/$lv regionsize "$regionsize_str"
 	fsck -fn "$DM_DEV_DIR/$vg/$lv"
diff --git a/tools/command-lines.in b/tools/command-lines.in
index ca5259f..6743b79 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -364,6 +364,13 @@ ID: lvconvert_raid_types
 DESC: Convert LV to raid1 or mirror, or change number of mirror images.
 RULE: all not lv_is_locked lv_is_pvmove
 
+lvconvert --regionsize SizeMB LV_raid
+OO: OO_LVCONVERT
+ID: lvconvert_change_region_size
+DESC: Change the region size of an LV.
+RULE: all not lv_is_locked lv_is_pvmove
+RULE: all not LV_raid0
+
 ---
 
 # lvconvert raid-related utilities
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 75bdcb9..4e86698 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -4397,6 +4397,21 @@ out:
 	return ret;
 }
 
+static int _lvconvert_change_region_size_single(struct cmd_context *cmd, struct logical_volume *lv,
+			     struct processing_handle *handle)
+{
+	if (!lv_raid_change_region_size(lv, arg_is_set(cmd, yes_ARG), arg_count(cmd, force_ARG),
+			                arg_int_value(cmd, regionsize_ARG, 0)))
+		return ECMD_FAILED;
+	return ECMD_PROCESSED;
+}
+
+int lvconvert_change_region_size_cmd(struct cmd_context * cmd, int argc, char **argv)
+{
+	return process_each_lv(cmd, 1, cmd->position_argv, NULL, NULL, READ_FOR_UPDATE,
+			      NULL, &_lvconvert_visible_check, &_lvconvert_change_region_size_single);
+}
+
 /*
  * split mirror images
  */
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 121a9dd..4fda356 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -152,6 +152,7 @@ struct command_function command_functions[CMD_COUNT] = {
 	{ lvconvert_split_mirror_images_CMD,		lvconvert_split_mirror_images_cmd},
 	{ lvconvert_change_mirrorlog_CMD,		lvconvert_change_mirrorlog_cmd },
 	{ lvconvert_merge_mirror_images_CMD,		lvconvert_merge_mirror_images_cmd },
+	{ lvconvert_change_region_size_CMD,		lvconvert_change_region_size_cmd },
 
 	/* redirected to merge_snapshot/merge_thin/merge_mirrors */
 	{ lvconvert_merge_CMD, lvconvert_merge_cmd },
diff --git a/tools/tools.h b/tools/tools.h
index 4e1d87f..00476d1 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -284,6 +284,7 @@ int lvconvert_raid_types_cmd(struct cmd_context * cmd, int argc, char **argv);
 int lvconvert_split_mirror_images_cmd(struct cmd_context * cmd, int argc, char **argv);
 int lvconvert_merge_mirror_images_cmd(struct cmd_context *cmd, int argc, char **argv);
 int lvconvert_change_mirrorlog_cmd(struct cmd_context * cmd, int argc, char **argv);
+int lvconvert_change_region_size_cmd(struct cmd_context * cmd, int argc, char **argv);
 
 int lvconvert_merge_cmd(struct cmd_context *cmd, int argc, char **argv);
 


