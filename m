From: Joe Thornber <thornber@sourceware.org>
Date: Thu, 7 Jun 2018 11:21:40 -0400
Subject: master - Remove locking infrastructure from activation paths
Message-ID: <201806071521.w57FLeoU013131@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=da30b4a7865b82c05cd2be1a8eb3bca42c39abb3
Commit:        da30b4a7865b82c05cd2be1a8eb3bca42c39abb3
Parent:        616eeba6f2b33640534e26dea43661724edf3a14
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jun 5 16:47:24 2018 -0500
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Thu Jun 7 16:17:04 2018 +0100

Remove locking infrastructure from activation paths

Basic LV functions:

  activate_lv(), deactivate_lv(),
  suspend_lv(), resume_lv()

were routed through the locking infrastruture on the way to:

  lv_activate_with_filter(), lv_deactivate(),
  lv_suspend_if_active(), lv_resume_if_active()

This commit removes the locking infrastructure from the
middle and calls the later functions directly from the former.

There were a couple of ancillary steps that the locking
infrastructure added along the way which are still included:

  - critical section inc/dec during suspend/resume
  - checking for active component LVs during activate

The "activation" file lock (serializing activation) has not
been kept because activation commands have been changed to
take the VG file lock exclusively which makes the activation
lock unused and unnecessary.
---
 lib/activate/activate.c    |  103 ++++++++++++++++++++++++++++++++++++++++----
 lib/activate/activate.h    |    8 +++
 lib/locking/file_locking.c |   48 --------------------
 lib/locking/locking.c      |   65 ++-------------------------
 lib/locking/locking.h      |   76 --------------------------------
 5 files changed, 107 insertions(+), 193 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index c9ead42..a7e5fe3 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -2424,15 +2424,6 @@ static int _lv_activate(struct cmd_context *cmd, const char *lvid_s,
 	if (!activation())
 		return 1;
 
-	if (!laopts->exclusive &&
-	    (lv_is_origin(lv) ||
-	     seg_only_exclusive(first_seg(lv))))  {
-		log_error(INTERNAL_ERROR "Trying non-exlusive activation of %s with "
-			  "a volume type %s requiring exclusive activation.",
-			  display_lvname(lv), lvseg_name(first_seg(lv)));
-		return 0;
-	}
-
 	if (filter && !_passes_activation_filter(cmd, lv)) {
 		log_verbose("Not activating %s since it does not pass "
 			    "activation filter.", display_lvname(lv));
@@ -2765,3 +2756,97 @@ int deactivate_lv_with_sub_lv(const struct logical_volume *lv)
 
 	return 1;
 }
+
+int activate_lv(struct cmd_context *cmd, const struct logical_volume *lv)
+{
+	const struct logical_volume *active_lv;
+	int ret;
+
+	/*
+	 * When trying activating component LV, make sure none of sub component
+	 * LV or LVs that are using it are active.
+	 */
+	if (!lv_is_visible(lv))
+		active_lv = lv_holder_is_active(lv);
+	else
+		active_lv = lv_component_is_active(lv);
+
+	if (active_lv) {
+		log_error("Activation of logical volume %s is prohibited while logical volume %s is active.",
+			  display_lvname(lv), display_lvname(active_lv));
+		ret = 0;
+		goto out;
+	}
+
+	ret = lv_activate_with_filter(cmd, NULL, 0,
+				      (lv->status & LV_NOSCAN) ? 1 : 0,
+				      (lv->status & LV_TEMPORARY) ? 1 : 0,
+				      lv_committed(lv));
+out:
+	return ret;
+}
+
+int deactivate_lv(struct cmd_context *cmd, const struct logical_volume *lv)
+{
+	int ret;
+
+	ret = lv_deactivate(cmd, NULL, lv_committed(lv));
+
+	return ret;
+}
+
+int suspend_lv(struct cmd_context *cmd, const struct logical_volume *lv)
+{
+	int ret;
+
+	critical_section_inc(cmd, "locking for suspend");
+
+	ret = lv_suspend_if_active(cmd, NULL, 0, 0, lv_committed(lv), lv);
+
+	return ret;
+}
+
+int suspend_lv_origin(struct cmd_context *cmd, const struct logical_volume *lv)
+{
+	int ret;
+
+	critical_section_inc(cmd, "locking for suspend");
+
+	ret = lv_suspend_if_active(cmd, NULL, 1, 0, lv_committed(lv), lv);
+
+	return ret;
+}
+
+int resume_lv(struct cmd_context *cmd, const struct logical_volume *lv)
+{
+	int ret;
+
+	ret = lv_resume_if_active(cmd, NULL, 0, 0, 0, lv_committed(lv));
+
+	critical_section_dec(cmd, "unlocking on resume");
+
+	return ret;
+}
+
+int resume_lv_origin(struct cmd_context *cmd, const struct logical_volume *lv)
+{
+	int ret;
+
+	ret = lv_resume_if_active(cmd, NULL, 1, 0, 0, lv_committed(lv));
+
+	critical_section_dec(cmd, "unlocking on resume");
+
+	return ret;
+}
+
+int revert_lv(struct cmd_context *cmd, const struct logical_volume *lv)
+{
+	int ret;
+
+	ret = lv_resume_if_active(cmd, NULL, 0, 0, 1, lv_committed(lv));
+
+	critical_section_dec(cmd, "unlocking on resume");
+
+	return ret;
+}
+
diff --git a/lib/activate/activate.h b/lib/activate/activate.h
index 8b6c4ad..2f0b0a0 100644
--- a/lib/activate/activate.h
+++ b/lib/activate/activate.h
@@ -126,6 +126,14 @@ int lv_mknodes(struct cmd_context *cmd, const struct logical_volume *lv);
 
 int lv_deactivate_any_missing_subdevs(const struct logical_volume *lv);
 
+int activate_lv(struct cmd_context *cmd, const struct logical_volume *lv);
+int deactivate_lv(struct cmd_context *cmd, const struct logical_volume *lv);
+int suspend_lv(struct cmd_context *cmd, const struct logical_volume *lv);
+int suspend_lv_origin(struct cmd_context *cmd, const struct logical_volume *lv);
+int resume_lv(struct cmd_context *cmd, const struct logical_volume *lv);
+int resume_lv_origin(struct cmd_context *cmd, const struct logical_volume *lv);
+int revert_lv(struct cmd_context *cmd, const struct logical_volume *lv);
+
 /*
  * Returns 1 if info structure has been populated, else 0 on failure.
  * When lvinfo* is NULL, it returns 1 if the device is locally active, 0 otherwise.
diff --git a/lib/locking/file_locking.c b/lib/locking/file_locking.c
index d4f47c6..a60a3e5 100644
--- a/lib/locking/file_locking.c
+++ b/lib/locking/file_locking.c
@@ -44,20 +44,8 @@ static int _file_lock_resource(struct cmd_context *cmd, const char *resource,
 			       uint32_t flags, const struct logical_volume *lv)
 {
 	char lockfile[PATH_MAX];
-	unsigned origin_only = (flags & LCK_ORIGIN_ONLY) ? 1 : 0;
-	unsigned revert = (flags & LCK_REVERT) ? 1 : 0;
 
 	switch (flags & LCK_SCOPE_MASK) {
-	case LCK_ACTIVATION:
-		if (dm_snprintf(lockfile, sizeof(lockfile),
-				"%s/A_%s", _lock_dir, resource) < 0) {
-			log_error("Too long locking filename %s/A_%s.", _lock_dir, resource);
-			return 0;
-		}
-
-		if (!lock_file(lockfile, flags))
-			return_0;
-		break;
 	case LCK_VG:
 		if (!strcmp(resource, VG_SYNC_NAMES))
 			fs_unlock();
@@ -84,42 +72,6 @@ static int _file_lock_resource(struct cmd_context *cmd, const char *resource,
 		if (!lock_file(lockfile, flags))
 			return_0;
 		break;
-	case LCK_LV:
-		switch (flags & LCK_TYPE_MASK) {
-		case LCK_UNLOCK:
-			log_very_verbose("Unlocking LV %s%s%s", resource, origin_only ? " without snapshots" : "", revert ? " (reverting)" : "");
-			if (!lv_resume_if_active(cmd, resource, origin_only, 0, revert, lv_committed(lv)))
-				return 0;
-			break;
-		case LCK_NULL:
-			log_very_verbose("Locking LV %s (NL)", resource);
-			if (!lv_deactivate(cmd, resource, lv_committed(lv)))
-				return 0;
-			break;
-		case LCK_READ:
-			log_very_verbose("Locking LV %s (R)", resource);
-			if (!lv_activate_with_filter(cmd, resource, 0, (lv->status & LV_NOSCAN) ? 1 : 0,
-						     (lv->status & LV_TEMPORARY) ? 1 : 0, lv_committed(lv)))
-				return 0;
-			break;
-		case LCK_PREAD:
-			log_very_verbose("Locking LV %s (PR) - ignored", resource);
-			break;
-		case LCK_WRITE:
-			log_very_verbose("Locking LV %s (W)%s", resource, origin_only ? " without snapshots" : "");
-			if (!lv_suspend_if_active(cmd, resource, origin_only, 0, lv_committed(lv), lv))
-				return 0;
-			break;
-		case LCK_EXCL:
-			log_very_verbose("Locking LV %s (EX)", resource);
-			if (!lv_activate_with_filter(cmd, resource, 1, (lv->status & LV_NOSCAN) ? 1 : 0,
-						     (lv->status & LV_TEMPORARY) ? 1 : 0, lv_committed(lv)))
-				return 0;
-			break;
-		default:
-			break;
-		}
-		break;
 	default:
 		log_error("Unrecognised lock scope: %d",
 			  flags & LCK_SCOPE_MASK);
diff --git a/lib/locking/locking.c b/lib/locking/locking.c
index 5e28452..4b7d7eb 100644
--- a/lib/locking/locking.c
+++ b/lib/locking/locking.c
@@ -35,30 +35,6 @@ static int _vg_lock_count = 0;		/* Number of locks held */
 static int _vg_write_lock_held = 0;	/* VG write lock held? */
 static int _blocking_supported = 0;
 
-typedef enum {
-        LV_NOOP,
-        LV_SUSPEND,
-        LV_RESUME
-} lv_operation_t;
-
-static void _lock_memory(struct cmd_context *cmd, lv_operation_t lv_op)
-{
-	if (!(_locking.flags & LCK_PRE_MEMLOCK))
-		return;
-
-	if (lv_op == LV_SUSPEND)
-		critical_section_inc(cmd, "locking for suspend");
-}
-
-static void _unlock_memory(struct cmd_context *cmd, lv_operation_t lv_op)
-{
-	if (!(_locking.flags & LCK_PRE_MEMLOCK))
-		return;
-
-	if (lv_op == LV_RESUME)
-		critical_section_dec(cmd, "unlocking on resume");
-}
-
 static void _unblock_signals(void)
 {
 	/* Don't unblock signals while any locks are held */
@@ -139,16 +115,13 @@ void fin_locking(void)
  * VG locking is by VG name.
  * FIXME This should become VG uuid.
  */
-static int _lock_vol(struct cmd_context *cmd, const char *resource,
-		     uint32_t flags, lv_operation_t lv_op, const struct logical_volume *lv)
+static int _lock_vol(struct cmd_context *cmd, const char *resource, uint32_t flags)
 {
 	uint32_t lck_type = flags & LCK_TYPE_MASK;
 	uint32_t lck_scope = flags & LCK_SCOPE_MASK;
 	int ret = 0;
-	const struct logical_volume *active_lv;
 
 	block_signals(flags);
-	_lock_memory(cmd, lv_op);
 
 	assert(resource);
 
@@ -162,23 +135,13 @@ static int _lock_vol(struct cmd_context *cmd, const char *resource,
 		goto out;
 	}
 
-	/* When trying activating component LV, make sure none of
-	 * sub component LV or  LVs that are using it are active */
-	if (lv && ((lck_type == LCK_READ) || (lck_type == LCK_EXCL)) &&
-	    ((!lv_is_visible(lv) && (active_lv = lv_holder_is_active(lv))) ||
-	     (active_lv = lv_component_is_active(lv)))) {
-		log_error("Activation of logical volume %s is prohibited while logical volume %s is active.",
-			  display_lvname(lv), display_lvname(active_lv));
-		goto out;
-	}
-
 	if (cmd->metadata_read_only && lck_type == LCK_WRITE &&
 	    strcmp(resource, VG_GLOBAL)) {
 		log_error("Operation prohibited while global/metadata_read_only is set.");
 		goto out;
 	}
 
-	if ((ret = _locking.lock_resource(cmd, resource, flags, lv))) {
+	if ((ret = _locking.lock_resource(cmd, resource, flags, NULL))) {
 		if (lck_scope == LCK_VG && !(flags & LCK_CACHE)) {
 			if (lck_type != LCK_UNLOCK)
 				lvmcache_lock_vgname(resource, lck_type == LCK_READ);
@@ -196,7 +159,6 @@ static int _lock_vol(struct cmd_context *cmd, const char *resource,
 			_update_vg_lock_count(resource, flags);
 	}
 out:
-	_unlock_memory(cmd, lv_op);
 	_unblock_signals();
 
 	return ret;
@@ -205,28 +167,14 @@ out:
 int lock_vol(struct cmd_context *cmd, const char *vol, uint32_t flags, const struct logical_volume *lv)
 {
 	char resource[258] __attribute__((aligned(8)));
-	lv_operation_t lv_op;
 	int lck_type = flags & LCK_TYPE_MASK;
 
-	switch (flags & (LCK_SCOPE_MASK | LCK_TYPE_MASK)) {
-		case LCK_LV_SUSPEND:
-				lv_op = LV_SUSPEND;
-				break;
-		case LCK_LV_RESUME:
-				lv_op = LV_RESUME;
-				break;
-		default:	lv_op = LV_NOOP;
-	}
-
-
 	if (flags == LCK_NONE) {
 		log_debug_locking(INTERNAL_ERROR "%s: LCK_NONE lock requested", vol);
 		return 1;
 	}
 
 	switch (flags & LCK_SCOPE_MASK) {
-	case LCK_ACTIVATION:
-		break;
 	case LCK_VG:
 		if (!_blocking_supported)
 			flags |= LCK_NONBLOCK;
@@ -235,10 +183,6 @@ int lock_vol(struct cmd_context *cmd, const char *vol, uint32_t flags, const str
 		if (is_orphan_vg(vol))
 			vol = VG_ORPHANS;
 		break;
-	case LCK_LV:
-		/* All LV locks are non-blocking. */
-		flags |= LCK_NONBLOCK;
-		break;
 	default:
 		log_error("Unrecognised lock scope: %d",
 			  flags & LCK_SCOPE_MASK);
@@ -250,7 +194,7 @@ int lock_vol(struct cmd_context *cmd, const char *vol, uint32_t flags, const str
 		return 0;
 	}
 
-	if (!_lock_vol(cmd, resource, flags, lv_op, lv))
+	if (!_lock_vol(cmd, resource, flags))
 		return_0;
 
 	/*
@@ -261,7 +205,7 @@ int lock_vol(struct cmd_context *cmd, const char *vol, uint32_t flags, const str
 	    (flags & (LCK_CACHE | LCK_HOLD)))
 		return 1;
 
-	if (!_lock_vol(cmd, resource, (flags & ~LCK_TYPE_MASK) | LCK_UNLOCK, lv_op, lv))
+	if (!_lock_vol(cmd, resource, (flags & ~LCK_TYPE_MASK) | LCK_UNLOCK))
 		return_0;
 
 	return 1;
@@ -312,3 +256,4 @@ int sync_dev_names(struct cmd_context* cmd)
 
 	return lock_vol(cmd, VG_SYNC_NAMES, LCK_VG_SYNC, NULL);
 }
+
diff --git a/lib/locking/locking.h b/lib/locking/locking.h
index f3956c2..6d7d8e8 100644
--- a/lib/locking/locking.h
+++ b/lib/locking/locking.h
@@ -94,8 +94,6 @@ int check_lvm1_vg_inactive(struct cmd_context *cmd, const char *vgname);
  */
 #define LCK_SCOPE_MASK	0x00001008U
 #define LCK_VG		0x00000000U	/* Volume Group */
-#define LCK_LV		0x00000008U	/* Logical Volume */
-#define LCK_ACTIVATION  0x00001000U	/* Activation */
 
 /*
  * Lock bits.
@@ -138,9 +136,6 @@ int check_lvm1_vg_inactive(struct cmd_context *cmd, const char *vgname);
  */
 #define LCK_NONE		(LCK_VG | LCK_NULL)
 
-#define LCK_ACTIVATE_LOCK	(LCK_ACTIVATION | LCK_WRITE | LCK_HOLD)
-#define LCK_ACTIVATE_UNLOCK	(LCK_ACTIVATION | LCK_UNLOCK)
-
 #define LCK_VG_READ		(LCK_VG | LCK_READ | LCK_HOLD)
 #define LCK_VG_WRITE		(LCK_VG | LCK_WRITE | LCK_HOLD)
 #define LCK_VG_UNLOCK		(LCK_VG | LCK_UNLOCK)
@@ -155,51 +150,8 @@ int check_lvm1_vg_inactive(struct cmd_context *cmd, const char *vgname);
 #define LCK_VG_SYNC		(LCK_NONE | LCK_CACHE)
 #define LCK_VG_SYNC_LOCAL	(LCK_NONE | LCK_CACHE | LCK_LOCAL)
 
-#define LCK_LV_EXCLUSIVE	(LCK_LV | LCK_EXCL)
-#define LCK_LV_SUSPEND		(LCK_LV | LCK_WRITE)
-#define LCK_LV_RESUME		(LCK_LV | LCK_UNLOCK)
-#define LCK_LV_ACTIVATE		(LCK_LV | LCK_READ)
-#define LCK_LV_DEACTIVATE	(LCK_LV | LCK_NULL)
-
 #define LCK_MASK (LCK_TYPE_MASK | LCK_SCOPE_MASK)
 
-#define lock_lv_vol(cmd, lv, flags) lock_vol(cmd, (lv)->lvid.s, flags, lv) 
-
-/*
- * Activation locks are wrapped around activation commands that have to
- * be processed atomically one-at-a-time.
- * If a VG WRITE lock is held or clustered activation activates simple LV
- * an activation lock is redundant.
- *
- * Some LV types do require taking a lock common for whole group of LVs.
- * TODO: For simplicity reasons ATM take a VG activation global lock and
- *       later more fine-grained component detection algorithm can be added
- */
-
-#define lv_type_requires_activation_lock(lv) ((lv_is_thin_type(lv) || lv_is_cache_type(lv) || lv_is_mirror_type(lv) || lv_is_raid_type(lv) || lv_is_origin(lv) || lv_is_snapshot(lv)) ? 1 : 0)
-
-#define lv_activation_lock_name(lv) (lv_type_requires_activation_lock(lv) ? (lv)->vg->name : (lv)->lvid.s)
-
-#define lv_requires_activation_lock_now(lv) ((!vg_write_lock_held() && (!vg_is_clustered((lv)->vg) || !lv_type_requires_activation_lock(lv))) ? 1 : 0)
-
-#define lock_activation(cmd, lv)	(lv_requires_activation_lock_now(lv) ? lock_vol(cmd, lv_activation_lock_name(lv), LCK_ACTIVATE_LOCK, lv) : 1)
-#define unlock_activation(cmd, lv)	(lv_requires_activation_lock_now(lv) ? lock_vol(cmd, lv_activation_lock_name(lv), LCK_ACTIVATE_UNLOCK, lv) : 1)
-
-/*
- * Place temporary exclusive 'activation' lock around an LV locking operation
- * to serialise it.
- */
-#define lock_lv_vol_serially(cmd, lv, flags) \
-({ \
-	int rr = 0; \
-\
-	if (lock_activation((cmd), (lv))) { \
-		rr = lock_lv_vol((cmd), (lv), (flags)); \
-		unlock_activation((cmd), (lv)); \
-	} \
-	rr; \
-})
-
 #define unlock_vg(cmd, vg, vol)	\
 	do { \
 		if (vg && !lvmetad_vg_update_finish(vg)) \
@@ -215,34 +167,6 @@ int check_lvm1_vg_inactive(struct cmd_context *cmd, const char *vgname);
 		release_vg(vg); \
 	} while (0)
 
-#define resume_lv(cmd, lv)	\
-({ \
-	int rr = lock_lv_vol((cmd), (lv), LCK_LV_RESUME); \
-	unlock_activation((cmd), (lv)); \
-	rr; \
-})
-#define resume_lv_origin(cmd, lv)	lock_lv_vol(cmd, lv, LCK_LV_RESUME | LCK_ORIGIN_ONLY)
-#define revert_lv(cmd, lv)	\
-({ \
-	int rr = lock_lv_vol((cmd), (lv), LCK_LV_RESUME | LCK_REVERT); \
-\
-	unlock_activation((cmd), (lv)); \
-	rr; \
-})
-#define suspend_lv(cmd, lv)	\
-	(lock_activation((cmd), (lv)) ? lock_lv_vol((cmd), (lv), LCK_LV_SUSPEND | LCK_HOLD) : 0)
-
-#define suspend_lv_origin(cmd, lv)	lock_lv_vol(cmd, lv, LCK_LV_SUSPEND | LCK_HOLD | LCK_ORIGIN_ONLY)
-
-#define deactivate_lv(cmd, lv)	lock_lv_vol_serially(cmd, lv, LCK_LV_DEACTIVATE)
-
-#define activate_lv(cmd, lv)	lock_lv_vol_serially(cmd, lv, LCK_LV_ACTIVATE | LCK_HOLD)
-
-struct logical_volume;
-
-#define deactivate_lv_local(cmd, lv)	\
-	lock_lv_vol_serially(cmd, lv, LCK_LV_DEACTIVATE | LCK_LOCAL)
-
 #define drop_cached_metadata(vg)	\
 	lock_vol((vg)->cmd, (vg)->name, LCK_VG_DROP_CACHE, NULL)
 


