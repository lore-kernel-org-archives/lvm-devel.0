From: David Teigland <teigland@sourceware.org>
Date: Thu, 31 May 2018 10:14:20 -0400
Subject: master - lvmlockd: enable creation of cache pool with lvcreate
Message-ID: <201805311414.w4VEEK54031184@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=403c87c1aa7b759c95c0d3e86eb919229b4fc242
Commit:        403c87c1aa7b759c95c0d3e86eb919229b4fc242
Parent:        948f2d997990048ad6759bfb25f042a4ddbb6a83
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri May 25 13:26:16 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed May 30 09:25:45 2018 -0500

lvmlockd: enable creation of cache pool with lvcreate

Previously, cache pools needed to be created with lvconvert.
---
 lib/locking/lvmlockd.c |   16 +++++++++++-----
 tools/lvcreate.c       |    3 +--
 2 files changed, 12 insertions(+), 7 deletions(-)

diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index 7f4fb2e..be37dc2 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -2416,10 +2416,6 @@ int lockd_init_lv_args(struct cmd_context *cmd, struct volume_group *vg,
  * an LV with no lock_args will do nothing (unless the LV type causes the lock
  * request to be directed to another LV with a lock, e.g. to the thin pool LV
  * for thin LVs.)
- *
- * Current limitations:
- * - cache-type LV's in a lockd VG must be created with lvconvert.
- * - creating a thin pool and thin lv in one command is not allowed.
  */
 
 int lockd_init_lv(struct cmd_context *cmd, struct volume_group *vg, struct logical_volume *lv,
@@ -2448,7 +2444,17 @@ int lockd_init_lv(struct cmd_context *cmd, struct volume_group *vg, struct logic
 		/* needs_lock_init is set for LVs that need a lockd lock. */
 		return 1;
 
-	} else if (seg_is_cache(lp) || seg_is_cache_pool(lp)) {
+	} else if (seg_is_cache_pool(lp)) {
+		/*
+		 * A cache pool does not use a lockd lock because it cannot be
+		 * used by itself.  When a cache pool is attached to an actual
+		 * LV, the lockd lock for that LV covers the LV and the cache
+		 * pool attached to it.
+		 */
+		lv->lock_args = NULL;
+		return 1;
+
+	} else if (seg_is_cache(lp)) {
 		/*
 		 * This should not happen because the command defs are
 		 * checked and excluded for shared VGs early in lvcreate.
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 39170dd..ee6df02 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -1638,8 +1638,7 @@ static int _lvcreate_single(struct cmd_context *cmd, const char *vg_name,
 			    lp->snapshot ? lp->origin_name : "", lp->segtype->name);
 
 	if (is_lockd_type(vg->lock_type)) {
-		if (cmd->command->command_enum == lvcreate_cachepool_CMD ||
-		    cmd->command->command_enum == lvcreate_cache_vol_with_new_origin_CMD ||
+		if (cmd->command->command_enum == lvcreate_cache_vol_with_new_origin_CMD ||
 		    cmd->command->command_enum == lvcreate_thin_vol_with_thinpool_or_sparse_snapshot_CMD ||
 		    cmd->command->command_enum == lvcreate_cache_vol_with_new_origin_or_convert_to_cache_vol_with_cachepool_CMD) {
 			log_error("Use lvconvert to create thin pools and cache pools in a shared VG.");


