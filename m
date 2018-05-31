From: David Teigland <teigland@sourceware.org>
Date: Thu, 31 May 2018 10:16:09 -0400
Subject: master - lvmlockd: enable lvcreate of new LV plus existing cache pool
Message-ID: <201805311416.w4VEG9KC031436@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c516321325f41f6b1f9d9342e2b0d0507b5a30fd
Commit:        c516321325f41f6b1f9d9342e2b0d0507b5a30fd
Parent:        27495a355536360404c8b8ee254ccaebb054debc
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed May 30 15:24:24 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed May 30 15:24:24 2018 -0500

lvmlockd: enable lvcreate of new LV plus existing cache pool

In this command, lvcreate creates a new LV and then combines
it with an existing cache pool, producing a cache LV.  This
command was previously not allowed in in a shared VG.
---
 lib/locking/lvmlockd.c  |    8 --------
 lib/metadata/lv_manip.c |   14 ++++++++++++--
 tools/lvcreate.c        |    3 +--
 3 files changed, 13 insertions(+), 12 deletions(-)

diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index be37dc2..0af2b38 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -2454,14 +2454,6 @@ int lockd_init_lv(struct cmd_context *cmd, struct volume_group *vg, struct logic
 		lv->lock_args = NULL;
 		return 1;
 
-	} else if (seg_is_cache(lp)) {
-		/*
-		 * This should not happen because the command defs are
-		 * checked and excluded for shared VGs early in lvcreate.
-		 */
-		log_error("Use lvconvert for cache with lock type %s", vg->lock_type);
-		return 0;
-
 	} else if (!seg_is_thin_volume(lp) && lp->snapshot) {
 		struct logical_volume *origin_lv;
 
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 4aefea0..c1bba03 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -7801,10 +7801,20 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		lv->status |= LV_TEMPORARY;
 
 	if (seg_is_cache(lp)) {
+		if (is_lockd_type(lv->vg->lock_type)) {
+			if (is_change_activating(lp->activate)) {
+				if (!lv_active_change(cmd, lv, CHANGE_AEY, 0)) {
+					log_error("Aborting. Failed to activate LV %s.",
+						  display_lvname(lv));
+					goto revert_new_lv;
+				}
+			}
+		}
+
 		/* FIXME Support remote exclusive activation? */
 		/* Not yet 'cache' LV, it is stripe volume for wiping */
-		if (is_change_activating(lp->activate) &&
-		    !activate_lv_excl_local(cmd, lv)) {
+
+		else if (is_change_activating(lp->activate) && !activate_lv_excl_local(cmd, lv)) {
 			log_error("Aborting. Failed to activate LV %s locally exclusively.",
 				  display_lvname(lv));
 			goto revert_new_lv;
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index ee6df02..7f97ebd 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -1638,8 +1638,7 @@ static int _lvcreate_single(struct cmd_context *cmd, const char *vg_name,
 			    lp->snapshot ? lp->origin_name : "", lp->segtype->name);
 
 	if (is_lockd_type(vg->lock_type)) {
-		if (cmd->command->command_enum == lvcreate_cache_vol_with_new_origin_CMD ||
-		    cmd->command->command_enum == lvcreate_thin_vol_with_thinpool_or_sparse_snapshot_CMD ||
+		if (cmd->command->command_enum == lvcreate_thin_vol_with_thinpool_or_sparse_snapshot_CMD ||
 		    cmd->command->command_enum == lvcreate_cache_vol_with_new_origin_or_convert_to_cache_vol_with_cachepool_CMD) {
 			log_error("Use lvconvert to create thin pools and cache pools in a shared VG.");
 			goto out;


