From: David Teigland <teigland@sourceware.org>
Date: Wed, 10 Jun 2020 21:10:21 +0000 (GMT)
Subject: master - writecache: activate to check block size
Message-ID: <20200610211021.A462C3870855@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ba27b9ee2a67d189a56827774001436556cae8a5
Commit:        ba27b9ee2a67d189a56827774001436556cae8a5
Parent:        38eaa1035b13ba1633d0002fa53071d5b7098ef9
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jun 10 15:58:25 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jun 10 15:58:25 2020 -0500

writecache: activate to check block size

backport fixes from later commit
---
 tools/lvconvert.c | 34 +++++++++++++++++++++++++++++-----
 1 file changed, 29 insertions(+), 5 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index b25fa1704..94ea70fa5 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -5352,7 +5352,7 @@ static int _lvconvert_detach_writecache(struct cmd_context *cmd,
 
 	backup(lv->vg);
 
-	log_print_unless_silent("Logical volume %s write cache has been detached.",
+	log_print_unless_silent("Logical volume %s writecache has been detached.",
 				display_lvname(lv));
 	return 1;
 }
@@ -5499,14 +5499,17 @@ static int _set_writecache_block_size(struct cmd_context *cmd,
 		goto_bad;
 	}
 
-	if (dm_snprintf(pathname, sizeof(pathname), "%s%s/%s", cmd->dev_dir,
+	if (dm_snprintf(pathname, sizeof(pathname), "%s/%s/%s", cmd->dev_dir,
 			lv->vg->name, lv->name) < 0) {
 		log_error("Path name too long to get LV block size %s", display_lvname(lv));
 		goto_bad;
 	}
 
+	if (!sync_local_dev_names(cmd))
+		stack;
+
 	if (!(fs_dev = dev_cache_get(cmd, pathname, NULL))) {
-		log_error("Device for LV not found to check block size %s", display_lvname(lv));
+		log_error("Device for LV not found to check block size %s", pathname);
 		goto_bad;
 	}
 
@@ -5608,6 +5611,7 @@ static int _lvconvert_writecache_attach_single(struct cmd_context *cmd,
 	char *lockd_fast_name = NULL;
 	struct id lockd_fast_id;
 	char cvol_name[NAME_LEN];
+	int is_active;
 
 	fast_name = arg_str_value(cmd, cachevol_ARG, "");
 
@@ -5637,6 +5641,8 @@ static int _lvconvert_writecache_attach_single(struct cmd_context *cmd,
 		goto bad;
 	}
 
+	is_active = lv_is_active(lv);
+
 	memset(&settings, 0, sizeof(settings));
 
 	if (!get_writecache_settings(cmd, &settings, &block_size_sectors)) {
@@ -5644,8 +5650,26 @@ static int _lvconvert_writecache_attach_single(struct cmd_context *cmd,
 		goto bad;
 	}
 
-	if (!_set_writecache_block_size(cmd, lv, &block_size_sectors))
+	if (!is_active) {
+		/* checking block size of fs on the lv requires the lv to be active */
+		if (!activate_lv(cmd, lv)) {
+			log_error("Failed to activate LV to check block size %s", display_lvname(lv));
+			goto bad;
+		}
+	}
+
+	if (!_set_writecache_block_size(cmd, lv, &block_size_sectors)) {
+		if (!is_active && !deactivate_lv(cmd, lv))
+			stack;
 		goto_bad;
+	}
+
+	if (!is_active) {
+		if (!deactivate_lv(cmd, lv)) {
+			log_error("Failed to deactivate LV after checking block size %s", display_lvname(lv));
+			goto bad;
+		}
+	}
 
 	if (!arg_is_set(cmd, yes_ARG) &&
 	    yes_no_prompt("Erase all existing data on %s? [y/n]: ", display_lvname(lv_fast)) == 'n') {
@@ -5723,7 +5747,7 @@ static int _lvconvert_writecache_attach_single(struct cmd_context *cmd,
 			log_error("Failed to unlock fast LV %s/%s", vg->name, lockd_fast_name);
 	}
 
-	log_print_unless_silent("Logical volume %s now has write cache.",
+	log_print_unless_silent("Logical volume %s now has writecache.",
 				display_lvname(lv));
 	return ECMD_PROCESSED;
 bad:


