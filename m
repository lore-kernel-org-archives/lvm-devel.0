From: David Teigland <teigland@sourceware.org>
Date: Thu, 14 Sep 2017 13:29:09 -0400
Subject: master - lvcreate: use cmd defs to deny unspported lockd cases
Message-ID: <201709141729.v8EHT9bx011388@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8e8755319c8a8848b8bcd830a6341eccf750f798
Commit:        8e8755319c8a8848b8bcd830a6341eccf750f798
Parent:        d93a2bb74177397430ec21d6062987cb7da91217
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Sep 14 12:20:29 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Sep 14 12:28:48 2017 -0500

lvcreate: use cmd defs to deny unspported lockd cases

In a shared VG, lvconvert must be used to create thin pools
and cache pools, not the lvcreate variants of those commands.
Deny these cases early in lvcreate using the new command defs.
Denying these cases deeper in the code was missing some
cleanup of the partially completed command.
---
 lib/locking/lvmlockd.c |    7 +++++++
 tools/lvcreate.c       |   12 +++++++++++-
 2 files changed, 18 insertions(+), 1 deletions(-)

diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index f4047d9..058d4b5 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -2385,6 +2385,10 @@ int lockd_init_lv(struct cmd_context *cmd, struct volume_group *vg, struct logic
 		return 1;
 
 	} else if (seg_is_cache(lp) || seg_is_cache_pool(lp)) {
+		/*
+		 * This should not happen because the command defs are
+		 * checked and excluded for shared VGs early in lvcreate.
+		 */
 		log_error("Use lvconvert for cache with lock type %s", vg->lock_type);
 		return 0;
 
@@ -2440,6 +2444,9 @@ int lockd_init_lv(struct cmd_context *cmd, struct volume_group *vg, struct logic
 			/*
 			 * Creating a thin pool and a thin lv in it.  We could
 			 * probably make this work.
+			 *
+			 * This should not happen because the command defs are
+			 * checked and excluded for shared VGs early in lvcreate.
 			 */
 			log_error("Create thin pool and thin LV separately with lock type %s",
 				  vg->lock_type);
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index d2199f5..8aa16f2 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -1634,8 +1634,18 @@ static int _lvcreate_single(struct cmd_context *cmd, const char *vg_name,
 			    lp->snapshot ? " as snapshot of " : "",
 			    lp->snapshot ? lp->origin_name : "", lp->segtype->name);
 
-	if (is_lockd_type(vg->lock_type))
+	if (is_lockd_type(vg->lock_type)) {
+		if (cmd->command->command_enum == lvcreate_thin_vol_and_thinpool_CMD ||
+		    cmd->command->command_enum == lvcreate_cachepool_CMD ||
+		    cmd->command->command_enum == lvcreate_cache_vol_with_new_origin_CMD ||
+		    cmd->command->command_enum == lvcreate_thin_vol_with_thinpool_or_sparse_snapshot_CMD ||
+		    cmd->command->command_enum == lvcreate_cache_vol_with_new_origin_or_convert_to_cache_vol_with_cachepool_CMD) {
+			log_error("Use lvconvert to create thin pools and cache pools in a shared VG.");
+			goto out;
+		}
+
 		lp->needs_lockd_init = 1;
+	}
 
 	if (!lv_create_single(vg, lp))
 		goto_out;


