From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 16 Feb 2023 23:10:48 +0000 (GMT)
Subject: main - debug: missing backtraces
Message-ID: <20230216231048.7B5BA3858C78@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3ef26494f2251dc5376f49128bbf49563560cf6b
Commit:        3ef26494f2251dc5376f49128bbf49563560cf6b
Parent:        7bc5c8ac3d4c6004de24050fd51d3eaa4732822d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Feb 16 13:14:33 2023 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Feb 17 00:00:12 2023 +0100

debug: missing backtraces

---
 tools/lvconvert.c | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 7331f243f..0e928d39c 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -4905,7 +4905,7 @@ static int _lvconvert_merge_thin_single(struct cmd_context *cmd,
 					 struct processing_handle *handle)
 {
 	if (!_lvconvert_merge_thin_snapshot(cmd, lv))
-		return ECMD_FAILED;
+		return_ECMD_FAILED;
 
 	return ECMD_PROCESSED;
 }
@@ -4968,11 +4968,11 @@ static int _lvconvert_split_cache_single(struct cmd_context *cmd,
 
 	/* If LV is inactive here, ensure it's not active elsewhere. */
 	if (!lockd_lv(cmd, lv_main, "ex", 0))
-		return ECMD_FAILED;
+		return_ECMD_FAILED;
 
 	if (lv_is_writecache(lv_main)) {
 		if (!_lvconvert_detach_writecache(cmd, handle, lv_main, lv_fast))
-			return ECMD_FAILED;
+			return_ECMD_FAILED;
 
 		if (cmd->command->command_enum == lvconvert_split_and_remove_cache_CMD) {
 			struct lvconvert_result *lr = (struct lvconvert_result *) handle->custom_handle;
@@ -4985,7 +4985,7 @@ static int _lvconvert_split_cache_single(struct cmd_context *cmd,
 			 */
 			if (!lr->wait_cleaner_writecache) {
 				if (lvremove_single(cmd, lv_fast, NULL) != ECMD_PROCESSED)
-					return ECMD_FAILED;
+					return_ECMD_FAILED;
 			}
 		}
 		ret = 1;
@@ -5255,7 +5255,8 @@ static int _lvconvert_change_region_size_single(struct cmd_context *cmd, struct
 {
 	if (!lv_raid_change_region_size(lv, arg_is_set(cmd, yes_ARG), arg_count(cmd, force_ARG),
 			                arg_int_value(cmd, regionsize_ARG, 0)))
-		return ECMD_FAILED;
+		return_ECMD_FAILED;
+
 	return ECMD_PROCESSED;
 }
 
@@ -5334,7 +5335,7 @@ static int _lvconvert_merge_mirror_images_single(struct cmd_context *cmd,
                                           struct processing_handle *handle)
 {
 	if (!lv_raid_merge(lv))
-		return ECMD_FAILED;
+		return_ECMD_FAILED;
 
 	return ECMD_PROCESSED;
 }

