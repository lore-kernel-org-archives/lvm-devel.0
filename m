From: David Teigland <teigland@sourceware.org>
Date: Fri, 8 Jun 2018 15:52:49 -0400
Subject: master - Remove locking for non-vgs
Message-ID: <201806081952.w58JqnC2010908@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ebd147ff244abd7d308ffb3ea8a2121b5f4bc7a3
Commit:        ebd147ff244abd7d308ffb3ea8a2121b5f4bc7a3
Parent:        4ce9579099a08e4d3cb0c0805517d3352b487b86
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Jun 8 14:34:50 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Jun 8 14:34:50 2018 -0500

Remove locking for non-vgs

Locks for VGs are the only thing that locking.[ch]
now handles, so references to other variations
can be removed.
---
 lib/locking/file_locking.c |   39 ++++++++++++++-------------------------
 lib/locking/locking.c      |   26 +++++---------------------
 lib/locking/locking.h      |   41 ++++++-----------------------------------
 3 files changed, 25 insertions(+), 81 deletions(-)

diff --git a/lib/locking/file_locking.c b/lib/locking/file_locking.c
index a0a4f02..8e08b08 100644
--- a/lib/locking/file_locking.c
+++ b/lib/locking/file_locking.c
@@ -45,31 +45,20 @@ static int _file_lock_resource(struct cmd_context *cmd, const char *resource,
 {
 	char lockfile[PATH_MAX];
 
-	switch (flags & LCK_SCOPE_MASK) {
-	case LCK_VG:
-		if (is_orphan_vg(resource) || is_global_vg(resource)) {
-			if (dm_snprintf(lockfile, sizeof(lockfile),
-					"%s/P_%s", _lock_dir, resource + 1) < 0) {
-				log_error("Too long locking filename %s/P_%s.",
-					  _lock_dir, resource + 1);
-				return 0;
-			}
-		} else
-			if (dm_snprintf(lockfile, sizeof(lockfile),
-					"%s/V_%s", _lock_dir, resource) < 0) {
-				log_error("Too long locking filename %s/V_%s.",
-					  _lock_dir, resource);
-				return 0;
-			}
-
-		if (!lock_file(lockfile, flags))
-			return_0;
-		break;
-	default:
-		log_error("Unrecognised lock scope: %d",
-			  flags & LCK_SCOPE_MASK);
-		return 0;
-	}
+	if (is_orphan_vg(resource) || is_global_vg(resource)) {
+		if (dm_snprintf(lockfile, sizeof(lockfile),
+				"%s/P_%s", _lock_dir, resource + 1) < 0) {
+			log_error("Too long locking filename %s/P_%s.", _lock_dir, resource + 1);
+			return 0;
+		}
+	} else
+		if (dm_snprintf(lockfile, sizeof(lockfile), "%s/V_%s", _lock_dir, resource) < 0) {
+			log_error("Too long locking filename %s/V_%s.", _lock_dir, resource);
+			return 0;
+		}
+
+	if (!lock_file(lockfile, flags))
+		return_0;
 
 	return 1;
 }
diff --git a/lib/locking/locking.c b/lib/locking/locking.c
index c9298af..3276283 100644
--- a/lib/locking/locking.c
+++ b/lib/locking/locking.c
@@ -69,8 +69,7 @@ void reset_locking(void)
 static void _update_vg_lock_count(const char *resource, uint32_t flags)
 {
 	/* Ignore locks not associated with updating VG metadata */
-	if ((flags & LCK_SCOPE_MASK) != LCK_VG ||
-	    !strcmp(resource, VG_GLOBAL))
+	if (!strcmp(resource, VG_GLOBAL))
 		return;
 
 	if ((flags & LCK_TYPE_MASK) == LCK_UNLOCK)
@@ -179,7 +178,6 @@ int lock_vol(struct cmd_context *cmd, const char *vol, uint32_t flags, const str
 {
 	char resource[258] __attribute__((aligned(8)));
 	uint32_t lck_type = flags & LCK_TYPE_MASK;
-	uint32_t lck_scope = flags & LCK_SCOPE_MASK;
 
 	if (!_blocking_supported)
 		flags |= LCK_NONBLOCK;
@@ -206,7 +204,7 @@ int lock_vol(struct cmd_context *cmd, const char *vol, uint32_t flags, const str
 		if (lck_type != LCK_WRITE)
 			goto out_hold;
 
-		if (cmd->is_activating && (lck_scope == LCK_VG) && strcmp(vol, VG_GLOBAL))
+		if (cmd->is_activating && strcmp(vol, VG_GLOBAL))
 			goto out_hold;
 
 		goto out_fail;
@@ -229,7 +227,7 @@ int lock_vol(struct cmd_context *cmd, const char *vol, uint32_t flags, const str
 	 * refuse write lock requests.
 	 */
 	if (cmd->metadata_read_only) {
-		if ((lck_type == LCK_WRITE) && (lck_scope == LCK_VG) && strcmp(vol, VG_GLOBAL)) {
+		if ((lck_type == LCK_WRITE) && strcmp(vol, VG_GLOBAL)) {
 			log_error("Operation prohibited while global/metadata_read_only is set.");
 			goto out_fail;
 		}
@@ -240,29 +238,15 @@ int lock_vol(struct cmd_context *cmd, const char *vol, uint32_t flags, const str
 	if (!_lock_vol(cmd, resource, flags))
 		goto out_fail;
 
-	/*
-	 * FIXME: I don't think we need this any more.
-	 * If a real lock was acquired
-	 * perform an immediate unlock unless LCK_HOLD was requested.
-	 */
-
-	if ((lck_type == LCK_UNLOCK) || (flags & LCK_HOLD))
-		goto out_hold;
-
-	if (!_lock_vol(cmd, resource, (flags & ~LCK_TYPE_MASK) | LCK_UNLOCK))
-		return_0;
-	return 1;
-
-
 out_hold:
 	/*
 	 * FIXME: other parts of the code want to check if a VG is
 	 * locked by looking in lvmcache.  They shouldn't need to
 	 * do that, and we should be able to remove this.
 	 */
-	if ((lck_scope == LCK_VG) && (lck_type != LCK_UNLOCK))
+	if (lck_type != LCK_UNLOCK)
 		lvmcache_lock_vgname(resource, lck_type == LCK_READ);
-	else if ((lck_scope == LCK_VG) && (lck_type == LCK_UNLOCK))
+	else if (lck_type == LCK_UNLOCK)
 		lvmcache_unlock_vgname(resource);
 
 	/* FIXME: we shouldn't need to keep track of this either. */
diff --git a/lib/locking/locking.h b/lib/locking/locking.h
index bbd7dfe..b2b69b8 100644
--- a/lib/locking/locking.h
+++ b/lib/locking/locking.h
@@ -27,7 +27,6 @@ void reset_locking(void);
 int vg_write_lock_held(void);
 
 /*
- * LCK_VG:
  *   Lock/unlock on-disk volume group data.
  *   Use VG_ORPHANS to lock all orphan PVs.
  *   Use VG_GLOBAL as a global lock and to wipe the internal cache.
@@ -35,42 +34,19 @@ int vg_write_lock_held(void);
  *   If more than one lock needs to be held simultaneously, they must be
  *   acquired in alphabetical order of 'vol' (to avoid deadlocks), with
  *   VG_ORPHANS last.
- *
- *   Use VG_SYNC_NAMES to ensure /dev is up-to-date for example, with udev,
- *   by waiting for any asynchronous events issued to have completed.
- *
- * LCK_LV:
- *   Lock/unlock an individual logical volume
- *   char *vol holds lvid
  */
 int lock_vol(struct cmd_context *cmd, const char *vol, uint32_t flags, const struct logical_volume *lv);
 
-/*
- * Internal locking representation.
- *   LCK_VG: Uses prefix V_ unless the vol begins with # (i.e. #global or #orphans)
- */
-
-/*
- * Lock type - these numbers are the same as VMS and the IBM DLM
- */
 #define LCK_TYPE_MASK	0x00000007U
-
-#define LCK_READ	0x00000001U	/* LCK$_CRMODE (Activate) */
-#define LCK_WRITE	0x00000004U	/* LCK$_PWMODE (Suspend) */
-#define LCK_UNLOCK      0x00000006U	/* This is ours (Resume) */
-
-/*
- * Lock scope
- */
-#define LCK_SCOPE_MASK	0x00001008U
-#define LCK_VG		0x00000000U	/* Volume Group */
+#define LCK_READ	0x00000001U
+#define LCK_WRITE	0x00000004U
+#define LCK_UNLOCK      0x00000006U
 
 /*
  * Lock bits.
  * Bottom 8 bits except LCK_LOCAL form args[0] in cluster comms.
  */
 #define LCK_NONBLOCK	0x00000010U	/* Don't block waiting for lock? */
-#define LCK_HOLD	0x00000020U	/* Hold lock when lock_vol returns? */
 
 /*
  * Special cases of VG locks.
@@ -78,14 +54,9 @@ int lock_vol(struct cmd_context *cmd, const char *vol, uint32_t flags, const str
 #define VG_ORPHANS	"#orphans"
 #define VG_GLOBAL	"#global"
 
-/*
- * Common combinations
- */
-#define LCK_VG_READ		(LCK_VG | LCK_READ | LCK_HOLD)
-#define LCK_VG_WRITE		(LCK_VG | LCK_WRITE | LCK_HOLD)
-#define LCK_VG_UNLOCK		(LCK_VG | LCK_UNLOCK)
-
-#define LCK_MASK (LCK_TYPE_MASK | LCK_SCOPE_MASK)
+#define LCK_VG_READ		LCK_READ
+#define LCK_VG_WRITE		LCK_WRITE
+#define LCK_VG_UNLOCK		LCK_UNLOCK
 
 #define unlock_vg(cmd, vg, vol)	\
 	do { \


