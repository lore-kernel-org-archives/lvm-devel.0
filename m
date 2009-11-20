From: Milan Broz <mbroz@redhat.com>
Date: Fri, 20 Nov 2009 18:49:21 +0100
Subject: [PATCH] Fix memory lock imbalance in locking code.
Message-ID: <1258739361-17361-1-git-send-email-mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

(This affects only cluster locking because only cluster
locking module set LCK_PRE_MEMLOCK.)

With currect code you get
# vgchange -a n
  Internal error: _memlock_count has dropped below 0.
when using cluster locking.

It is caused by _unlock_memory calls here

  if ((flags & (LCK_SCOPE_MASK | LCK_TYPE_MASK)) == LCK_LV_RESUME)
	memlock_dec();

Unfortunately it is also (wrongly) called in immediate unlock
(when LCK_HOLD is not set) from lock_vol
(LCK_UNLOCK is misinterpreted as LCK_LV_RESUME).

Simply avoid this by adding flag for memory locking.
This expects that suspend is always called with LCK_HOLD.

(Any better idea welcomed;-)

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/locking/locking.c |   13 ++++++++-----
 1 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/lib/locking/locking.c b/lib/locking/locking.c
index 9d86433..c8a90fb 100644
--- a/lib/locking/locking.c
+++ b/lib/locking/locking.c
@@ -336,12 +336,14 @@ int check_lvm1_vg_inactive(struct cmd_context *cmd, const char *vgname)
  * VG locking is by VG name.
  * FIXME This should become VG uuid.
  */
-static int _lock_vol(struct cmd_context *cmd, const char *resource, uint32_t flags)
+static int _lock_vol(struct cmd_context *cmd, const char *resource,
+		     uint32_t flags, int lock_memory)
 {
 	int ret = 0;
 
 	_block_signals(flags);
-	_lock_memory(flags);
+	if (lock_memory)
+		_lock_memory(flags);
 
 	assert(resource);
 
@@ -368,7 +370,8 @@ static int _lock_vol(struct cmd_context *cmd, const char *resource, uint32_t fla
 		_update_vg_lock_count(resource, flags);
 	}
 
-	_unlock_memory(flags);
+	if (lock_memory)
+		_unlock_memory(flags);
 	_unblock_signals();
 
 	return ret;
@@ -416,7 +419,7 @@ int lock_vol(struct cmd_context *cmd, const char *vol, uint32_t flags)
 
 	strncpy(resource, vol, sizeof(resource));
 
-	if (!_lock_vol(cmd, resource, flags))
+	if (!_lock_vol(cmd, resource, flags, 1))
 		return 0;
 
 	/*
@@ -426,7 +429,7 @@ int lock_vol(struct cmd_context *cmd, const char *vol, uint32_t flags)
 	if (!(flags & LCK_CACHE) && !(flags & LCK_HOLD) &&
 	    ((flags & LCK_TYPE_MASK) != LCK_UNLOCK)) {
 		if (!_lock_vol(cmd, resource,
-			       (flags & ~LCK_TYPE_MASK) | LCK_UNLOCK))
+			       (flags & ~LCK_TYPE_MASK) | LCK_UNLOCK, 0))
 			return 0;
 	}
 
-- 
1.6.5.3


