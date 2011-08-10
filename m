From: Milan Broz <mbroz@redhat.com>
Date: Wed, 10 Aug 2011 17:37:25 +0200
Subject: [PATCH] Remove lock from cache even if unlock fails.
Message-ID: <1312990645-20977-1-git-send-email-mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

If anything bad happens and unlocking fails
(here clvmd crashed in the middle of operation),
lock is not removed from cache - here is one example:

locking/cluster_locking.c:497       Locking VG V_vg_test UN (VG) (0x6)
locking/cluster_locking.c:113   Error writing data to clvmd: Broken pipe
locking/locking.c:399         <backtrace>
locking/locking.c:461         <backtrace>
  Internal error: Volume Group vg_test was not unlocked

Code should always remove lock info from lvmcache and update counters
on unlock, even if unlock fails.

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/locking/locking.c |   22 +++++++++++++---------
 1 files changed, 13 insertions(+), 9 deletions(-)

diff --git a/lib/locking/locking.c b/lib/locking/locking.c
index 8d709f6..79a6d56 100644
--- a/lib/locking/locking.c
+++ b/lib/locking/locking.c
@@ -359,6 +359,8 @@ int check_lvm1_vg_inactive(struct cmd_context *cmd, const char *vgname)
 static int _lock_vol(struct cmd_context *cmd, const char *resource,
 		     uint32_t flags, lv_operation_t lv_op)
 {
+	uint32_t lck_type = flags & LCK_TYPE_MASK;
+	uint32_t lck_scope = flags & LCK_SCOPE_MASK;
 	int ret = 0;
 
 	_block_signals(flags);
@@ -376,21 +378,16 @@ static int _lock_vol(struct cmd_context *cmd, const char *resource,
 		return 0;
 	}
 
-	if (cmd->metadata_read_only &&
-	    ((flags & LCK_TYPE_MASK) == LCK_WRITE) &&
+	if (cmd->metadata_read_only && lck_type == LCK_WRITE &&
 	    strcmp(resource, VG_GLOBAL)) {
 		log_error("Operation prohibited while global/metadata_read_only is set.");
 		return 0;
 	}
 
 	if ((ret = _locking.lock_resource(cmd, resource, flags))) {
-		if ((flags & LCK_SCOPE_MASK) == LCK_VG &&
-		    !(flags & LCK_CACHE)) {
-			if ((flags & LCK_TYPE_MASK) == LCK_UNLOCK)
-				lvmcache_unlock_vgname(resource);
-			else
-				lvmcache_lock_vgname(resource, (flags & LCK_TYPE_MASK)
-								== LCK_READ);
+		if (lck_scope == LCK_VG && !(flags & LCK_CACHE)) {
+			if (lck_type != LCK_UNLOCK)
+				lvmcache_lock_vgname(resource, lck_type == LCK_READ);
 			dev_reset_error_count(cmd);
 		}
 
@@ -398,6 +395,13 @@ static int _lock_vol(struct cmd_context *cmd, const char *resource,
 	} else
 		stack;
 
+	/* If unlocking, always remove lock from lvmcache even if operation failed. */
+	if (lck_scope == LCK_VG && !(flags & LCK_CACHE) && lck_type == LCK_UNLOCK) {
+		lvmcache_unlock_vgname(resource);
+		if (!ret)
+			_update_vg_lock_count(resource, flags);
+	}
+
 	_unlock_memory(cmd, lv_op);
 	_unblock_signals();
 
-- 
1.7.6


