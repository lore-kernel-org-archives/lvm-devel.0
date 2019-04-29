From: David Teigland <teigland@sourceware.org>
Date: Mon, 29 Apr 2019 15:31:51 -0400
Subject: master - locking: unify global lock for flock and lockd
Message-ID: <201904291931.x3TJVp6C010998@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8c87dda195ffadcce1e428d3481e8d01080e2b22
Commit:        8c87dda195ffadcce1e428d3481e8d01080e2b22
Parent:        ccd13860708a1538b46c1b82b45d0ab44a26d89e
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Apr 18 15:01:19 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Apr 29 13:01:05 2019 -0500

locking: unify global lock for flock and lockd

There have been two file locks used to protect lvm
"global state": "ORPHANS" and "GLOBAL".

Commands that used the ORPHAN flock in exclusive mode:
  pvcreate, pvremove, vgcreate, vgextend, vgremove,
  vgcfgrestore

Commands that used the ORPHAN flock in shared mode:
  vgimportclone, pvs, pvscan, pvresize, pvmove,
  pvdisplay, pvchange, fullreport

Commands that used the GLOBAL flock in exclusive mode:
  pvchange, pvscan, vgimportclone, vgscan

Commands that used the GLOBAL flock in shared mode:
  pvscan --cache, pvs

The ORPHAN lock covers the important cases of serializing
the use of orphan PVs.  It also partially covers the
reporting of orphan PVs (although not correctly as
explained below.)

The GLOBAL lock doesn't seem to have a clear purpose
(it may have eroded over time.)

Neither lock correctly protects the VG namespace, or
orphan PV properties.

To simplify and correct these issues, the two separate
flocks are combined into the one GLOBAL flock, and this flock
is used from the locking sites that are in place for the
lvmlockd global lock.

The logic behind the lvmlockd (distributed) global lock is
that any command that changes "global state" needs to take
the global lock in ex mode.  Global state in lvm is: the list
of VG names, the set of orphan PVs, and any properties of
orphan PVs.  Reading this global state can use the global lock
in sh mode to ensure it doesn't change while being reported.

The locking of global state now looks like:

lockd_global()
  previously named lockd_gl(), acquires the distributed
  global lock through lvmlockd.  This is unchanged.
  It serializes distributed lvm commands that are changing
  global state.  This is a no-op when lvmlockd is not in use.

lockf_global()
  acquires an flock on a local file.  It serializes local lvm
  commands that are changing global state.

lock_global()
  first calls lockf_global() to acquire the local flock for
  global state, and if this succeeds, it calls lockd_global()
  to acquire the distributed lock for global state.

Replace instances of lockd_gl() with lock_global(), so that the
existing sites for lvmlockd global state locking are now also
used for local file locking of global state.  Remove the previous
file locking calls lock_vol(GLOBAL) and lock_vol(ORPHAN).

The following commands which change global state are now
serialized with the exclusive global flock:

pvchange (of orphan), pvresize (of orphan), pvcreate, pvremove,
vgcreate, vgextend, vgremove, vgreduce, vgrename,
vgcfgrestore, vgimportclone, vgmerge, vgsplit

Commands that use a shared flock to read global state (and will
be serialized against the prior list) are those that use
process_each functions that are based on processing a list of
all VG names, or all PVs.  The list of all VGs or all PVs is
global state and the shared lock prevents those lists from
changing while the command is processing them.

The ORPHAN lock previously attempted to produce an accurate
listing of orphan PVs, but it was only acquired at the end of
the command during the fake vg_read of the fake orphan vg.
This is not when orphan PVs were determined; they were
determined by elimination beforehand by processing all real
VGs, and subtracting the PVs in the real VGs from the list
of all PVs that had been identified during the initial scan.
This is fixed by holding the single global lock in shared mode
while processing all VGs to determine the list of orphan PVs.
---
 lib/cache/lvmcache.c             |    5 +-
 lib/commands/toolcontext.h       |    2 +
 lib/label/hints.c                |    8 +--
 lib/locking/file_locking.c       |    2 +-
 lib/locking/locking.c            |  100 ++++++++++++++++++++++++++++++++++++--
 lib/locking/locking.h            |   15 +++---
 lib/locking/lvmlockd.c           |   26 +++++++++-
 lib/locking/lvmlockd.h           |   14 +++---
 lib/metadata/metadata-exported.h |    2 -
 lib/metadata/metadata.c          |   18 +------
 lib/misc/lvm-flock.c             |   30 +++++++++++-
 test/shell/lock-blocking.sh      |   14 +++---
 tools/polldaemon.c               |    1 +
 tools/pvchange.c                 |   20 +-------
 tools/pvcreate.c                 |   11 +---
 tools/pvmove.c                   |    4 +-
 tools/pvremove.c                 |   16 ++-----
 tools/pvresize.c                 |    5 +-
 tools/pvscan.c                   |   12 -----
 tools/reporter.c                 |   15 ------
 tools/toollib.c                  |   47 ++++++-----------
 tools/vgcfgrestore.c             |    7 +--
 tools/vgchange.c                 |    8 ++--
 tools/vgcreate.c                 |   19 ++------
 tools/vgextend.c                 |   16 +------
 tools/vgimportclone.c            |    8 +---
 tools/vgmerge.c                  |    3 +-
 tools/vgreduce.c                 |   14 +-----
 tools/vgremove.c                 |   22 +--------
 tools/vgrename.c                 |    3 +-
 tools/vgscan.c                   |    6 --
 tools/vgsplit.c                  |    3 +-
 32 files changed, 226 insertions(+), 250 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 8aed59b..f0b1d56 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -97,14 +97,13 @@ int lvmcache_init(struct cmd_context *cmd)
 
 void lvmcache_lock_vgname(const char *vgname, int read_only __attribute__((unused)))
 {
-	if (strcmp(vgname, VG_GLOBAL))
-		_vgs_locked++;
+	_vgs_locked++;
 }
 
 void lvmcache_unlock_vgname(const char *vgname)
 {
 	/* FIXME Do this per-VG */
-	if (strcmp(vgname, VG_GLOBAL) && !--_vgs_locked) {
+	if (!--_vgs_locked) {
 		dev_size_seqno_inc(); /* invalidate all cached dev sizes */
 	}
 }
diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index fea0e51..095477c 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -160,6 +160,8 @@ struct cmd_context {
 	unsigned lockd_vg_default_sh:1;
 	unsigned lockd_vg_enforce_sh:1;
 	unsigned lockd_lv_sh_for_ex:1;
+	unsigned lockd_global_ex:1;		/* set while global lock held ex (lockd) */
+	unsigned lockf_global_ex:1;		/* set while global lock held ex (flock) */
 	unsigned vg_notify:1;
 	unsigned lv_notify:1;
 	unsigned pv_notify:1;
diff --git a/lib/label/hints.c b/lib/label/hints.c
index a9e9e07..ecb70ef 100644
--- a/lib/label/hints.c
+++ b/lib/label/hints.c
@@ -979,17 +979,13 @@ int write_hint_file(struct cmd_context *cmd, int newhints)
  * an issue we could easily write the pid in the nohints file, and
  * others could check if the pid is still around before obeying it.)
  *
- * The intention is to call this function after the global ex lock has been
+ * The function is meant to be called after the global ex lock has been
  * taken, which is the official lock serializing commands changing which
  * devs are PVs or not.  This means that a command should never block in
  * this function due to another command that has used this function --
  * they would be serialized by the official global lock first.
  * e.g. two pvcreates should never block each other from the hint lock,
- * but rather from the global lock...
- *
- * Unfortunately, the global(orphan) lock is not used consistently so it's not
- * quite doing its job right and needs some cleanup.  Until that's done,
- * concurrent commands like pvcreate may block each other on the hint lock.
+ * but rather from the global lock.
  */
 
 void clear_hint_file(struct cmd_context *cmd)
diff --git a/lib/locking/file_locking.c b/lib/locking/file_locking.c
index 8f808c8..9dfa06c 100644
--- a/lib/locking/file_locking.c
+++ b/lib/locking/file_locking.c
@@ -44,7 +44,7 @@ static int _file_lock_resource(struct cmd_context *cmd, const char *resource,
 {
 	char lockfile[PATH_MAX];
 
-	if (is_orphan_vg(resource) || is_global_vg(resource)) {
+	if (!strcmp(resource, VG_GLOBAL)) {
 		if (dm_snprintf(lockfile, sizeof(lockfile),
 				"%s/P_%s", _lock_dir, resource + 1) < 0) {
 			log_error("Too long locking filename %s/P_%s.", _lock_dir, resource + 1);
diff --git a/lib/locking/locking.c b/lib/locking/locking.c
index a23b272..fd2b975 100644
--- a/lib/locking/locking.c
+++ b/lib/locking/locking.c
@@ -15,6 +15,7 @@
 
 #include "lib/misc/lib.h"
 #include "lib/locking/locking.h"
+#include "lib/locking/lvmlockd.h"
 #include "locking_types.h"
 #include "lib/misc/lvm-string.h"
 #include "lib/activate/activate.h"
@@ -185,13 +186,14 @@ int lock_vol(struct cmd_context *cmd, const char *vol, uint32_t flags, const str
 {
 	char resource[258] __attribute__((aligned(8)));
 	uint32_t lck_type = flags & LCK_TYPE_MASK;
+	int is_global = !strcmp(vol, VG_GLOBAL);
+
+	if (is_orphan_vg(vol))
+		return 1;
 
 	if (!_blocking_supported)
 		flags |= LCK_NONBLOCK;
 
-	if (is_orphan_vg(vol))
-		vol = VG_ORPHANS;
-
 	if (!dm_strncpy(resource, vol, sizeof(resource))) {
 		log_error(INTERNAL_ERROR "Resource name %s is too long.", vol);
 		return 0;
@@ -211,7 +213,7 @@ int lock_vol(struct cmd_context *cmd, const char *vol, uint32_t flags, const str
 		if (lck_type != LCK_WRITE)
 			goto out_hold;
 
-		if (cmd->is_activating && strcmp(vol, VG_GLOBAL))
+		if (cmd->is_activating && !is_global)
 			goto out_hold;
 
 		goto out_fail;
@@ -252,7 +254,7 @@ int lock_vol(struct cmd_context *cmd, const char *vol, uint32_t flags, const str
 	 * refuse write lock requests.
 	 */
 	if (cmd->metadata_read_only) {
-		if ((lck_type == LCK_WRITE) && strcmp(vol, VG_GLOBAL)) {
+		if (lck_type == LCK_WRITE) {
 			log_error("Operation prohibited while global/metadata_read_only is set.");
 			goto out_fail;
 		}
@@ -264,6 +266,9 @@ int lock_vol(struct cmd_context *cmd, const char *vol, uint32_t flags, const str
 		goto out_fail;
 
 out_hold:
+	if (is_global)
+		return 1;
+
 	/*
 	 * FIXME: other parts of the code want to check if a VG is
 	 * locked by looking in lvmcache.  They shouldn't need to
@@ -279,6 +284,8 @@ out_hold:
 	return 1;
 
 out_fail:
+	if (is_global)
+		return 0;
 	if (lck_type == LCK_UNLOCK)
 		_update_vg_lock_count(resource, flags);
 	return 0;
@@ -318,3 +325,86 @@ int sync_local_dev_names(struct cmd_context* cmd)
 	return 1;
 }
 
+/*
+ * The lockf_global_ex flag is used to prevent changing
+ * an explicitly acquired ex global lock to sh in process_each.
+ */
+
+static int _lockf_global(struct cmd_context *cmd, const char *mode, int convert)
+{
+	uint32_t flags = 0;
+	int ret;
+
+	if (convert)
+		flags |= LCK_CONVERT;
+
+	if (!strcmp(mode, "ex")) {
+		flags |= LCK_WRITE;
+
+		if (cmd->lockf_global_ex) {
+			log_warn("global flock already held ex");
+			return 1;
+		}
+
+		ret = lock_vol(cmd, VG_GLOBAL, flags, NULL);
+		if (ret)
+			cmd->lockf_global_ex = 1;
+
+	} else if (!strcmp(mode, "sh")) {
+		if (cmd->lockf_global_ex)
+			return 1;
+
+		flags |= LCK_READ;
+
+		ret = lock_vol(cmd, VG_GLOBAL, flags, NULL);
+
+	} else if (!strcmp(mode, "un")) {
+		ret = lock_vol(cmd, VG_GLOBAL, LCK_UNLOCK, NULL);
+		cmd->lockf_global_ex = 0;
+	}
+
+	return ret;
+}
+
+int lockf_global(struct cmd_context *cmd, const char *mode)
+{
+	return _lockf_global(cmd, mode, 0);
+}
+
+int lockf_global_convert(struct cmd_context *cmd, const char *mode)
+{
+	return _lockf_global(cmd, mode, 1);
+}
+
+int lock_global(struct cmd_context *cmd, const char *mode)
+{
+	if (!lockf_global(cmd, mode))
+		return 0;
+
+	if (!lockd_global(cmd, mode)) {
+		lockf_global(cmd, "un");
+		return 0;
+	}
+
+	return 1;
+}
+
+/*
+ * The global lock is already held, convert it to another mode.
+ *
+ * Currently only used for sh->ex.
+ *
+ * (The lockf_global_ex flag would need overriding
+ * to handle ex->sh.)
+ */
+
+int lock_global_convert(struct cmd_context *cmd, const char *mode)
+{
+	if (!lockf_global_convert(cmd, mode))
+		return 0;
+
+	if (!lockd_global(cmd, mode))
+		return 0;
+
+	return 1;
+}
diff --git a/lib/locking/locking.h b/lib/locking/locking.h
index 2e2e992..41faf68 100644
--- a/lib/locking/locking.h
+++ b/lib/locking/locking.h
@@ -28,12 +28,10 @@ int vg_write_lock_held(void);
 
 /*
  *   Lock/unlock on-disk volume group data.
- *   Use VG_ORPHANS to lock all orphan PVs.
- *   Use VG_GLOBAL as a global lock and to wipe the internal cache.
+ *   Use VG_GLOBAL as a global lock.
  *   char *vol holds volume group name.
  *   If more than one lock needs to be held simultaneously, they must be
- *   acquired in alphabetical order of 'vol' (to avoid deadlocks), with
- *   VG_ORPHANS last.
+ *   acquired in alphabetical order of 'vol' (to avoid deadlocks).
  */
 int lock_vol(struct cmd_context *cmd, const char *vol, uint32_t flags, const struct logical_volume *lv);
 
@@ -47,10 +45,8 @@ int lock_vol(struct cmd_context *cmd, const char *vol, uint32_t flags, const str
  * Bottom 8 bits except LCK_LOCAL form args[0] in cluster comms.
  */
 #define LCK_NONBLOCK	0x00000010U	/* Don't block waiting for lock? */
+#define LCK_CONVERT	0x00000020U
 
-/*
- * Special cases of VG locks.
- */
 #define VG_ORPHANS	"#orphans"
 #define VG_GLOBAL	"#global"
 
@@ -77,4 +73,9 @@ int sync_local_dev_names(struct cmd_context* cmd);
 struct volume_group;
 int activate_lvs(struct cmd_context *cmd, struct dm_list *lvs, unsigned exclusive);
 
+int lockf_global(struct cmd_context *cmd, const char *mode);
+int lockf_global_convert(struct cmd_context *cmd, const char *mode);
+int lock_global(struct cmd_context *cmd, const char *mode);
+int lock_global_convert(struct cmd_context *cmd, const char *mode);
+
 #endif
diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index 1e3553d..5ef3c94 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -1315,7 +1315,7 @@ int lockd_start_wait(struct cmd_context *cmd)
  *    Future lockd_gl/lockd_gl_create calls will acquire the existing gl.
  */
 
-int lockd_gl_create(struct cmd_context *cmd, const char *def_mode, const char *vg_lock_type)
+int lockd_global_create(struct cmd_context *cmd, const char *def_mode, const char *vg_lock_type)
 {
 	const char *mode = NULL;
 	uint32_t lockd_flags;
@@ -1460,6 +1460,12 @@ int lockd_gl_create(struct cmd_context *cmd, const char *def_mode, const char *v
 	/* --shared with vgcreate does not mean include_shared_vgs */
 	cmd->include_shared_vgs = 0;
 
+	/*
+	 * This is done to prevent converting an explicitly acquired
+	 * ex lock to sh in process_each.
+	 */
+	cmd->lockd_global_ex = 1;
+
 	return 1;
 }
 
@@ -1542,7 +1548,7 @@ int lockd_gl_create(struct cmd_context *cmd, const char *def_mode, const char *v
  * are unprotected.
  */
 
-int lockd_gl(struct cmd_context *cmd, const char *def_mode, uint32_t flags)
+int lockd_global(struct cmd_context *cmd, const char *def_mode)
 {
 	const char *mode = NULL;
 	const char *opts = NULL;
@@ -1572,10 +1578,16 @@ int lockd_gl(struct cmd_context *cmd, const char *def_mode, uint32_t flags)
 	if (!mode)
 		mode = def_mode;
 	if (!mode) {
-		log_error("Unknown lock-gl mode");
+		log_error("Unknown lvmlockd global lock mode");
 		return 0;
 	}
 
+	if (!strcmp(mode, "sh") && cmd->lockd_global_ex)
+		return 1;
+
+	if (!strcmp(mode, "un") && cmd->lockd_global_ex)
+		cmd->lockd_global_ex = 0;
+
  req:
 	log_debug("lockd global mode %s", mode);
 
@@ -1719,6 +1731,14 @@ int lockd_gl(struct cmd_context *cmd, const char *def_mode, uint32_t flags)
 	}
 
  allow:
+
+	/*
+	 * This is done to prevent converting an explicitly acquired
+	 * ex lock to sh in process_each.
+	 */
+	if (!strcmp(mode, "ex"))
+		cmd->lockd_global_ex = 1;
+
 	return 1;
 }
 
diff --git a/lib/locking/lvmlockd.h b/lib/locking/lvmlockd.h
index e11ea15..1738192 100644
--- a/lib/locking/lvmlockd.h
+++ b/lib/locking/lvmlockd.h
@@ -16,9 +16,6 @@
 
 #define LOCKD_SANLOCK_LV_NAME "lvmlock"
 
-/* lockd_gl flags */
-#define LDGL_UPDATE_NAMES         0x00000001
-
 /* lockd_lv flags */
 #define LDLV_MODE_NO_SH           0x00000001
 #define LDLV_PERSISTENT           0x00000002
@@ -43,6 +40,9 @@
 
 #ifdef LVMLOCKD_SUPPORT
 
+struct lvresize_params;
+struct lvcreate_params;
+
 /* lvmlockd connection and communication */
 
 void lvmlockd_set_socket(const char *sock);
@@ -71,8 +71,8 @@ int lockd_start_wait(struct cmd_context *cmd);
 
 /* locking */
 
-int lockd_gl_create(struct cmd_context *cmd, const char *def_mode, const char *vg_lock_type);
-int lockd_gl(struct cmd_context *cmd, const char *def_mode, uint32_t flags);
+int lockd_global_create(struct cmd_context *cmd, const char *def_mode, const char *vg_lock_type);
+int lockd_global(struct cmd_context *cmd, const char *def_mode);
 int lockd_vg(struct cmd_context *cmd, const char *vg_name, const char *def_mode,
 	     uint32_t flags, uint32_t *lockd_state);
 int lockd_vg_update(struct volume_group *vg);
@@ -169,7 +169,7 @@ static inline int lockd_start_wait(struct cmd_context *cmd)
 	return 0;
 }
 
-static inline int lockd_gl_create(struct cmd_context *cmd, const char *def_mode, const char *vg_lock_type)
+static inline int lockd_global_create(struct cmd_context *cmd, const char *def_mode, const char *vg_lock_type)
 {
 	/*
 	 * When lvm is built without lvmlockd support, creating a VG with
@@ -182,7 +182,7 @@ static inline int lockd_gl_create(struct cmd_context *cmd, const char *def_mode,
 	return 1;
 }
 
-static inline int lockd_gl(struct cmd_context *cmd, const char *def_mode, uint32_t flags)
+static inline int lockd_global(struct cmd_context *cmd, const char *def_mode, uint32_t flags)
 {
 	return 1;
 }
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 0683d5f..219c784 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -187,7 +187,6 @@
 #define READ_WARN_INCONSISTENT	0x00080000U
 #define READ_FOR_UPDATE		0x00100000U /* A meta-flag, useful with toollib for_each_* functions. */
 #define PROCESS_SKIP_SCAN	 0x00200000U /* skip lvmcache_label_scan in process_each_pv */
-#define PROCESS_SKIP_ORPHAN_LOCK 0x00400000U /* skip lock_vol(VG_ORPHAN) in vg_read */
 
 /* vg's "read_status" field */
 #define FAILED_INCONSISTENT	0x00000001U
@@ -706,7 +705,6 @@ int move_pv(struct volume_group *vg_from, struct volume_group *vg_to,
 int move_pvs_used_by_lv(struct volume_group *vg_from,
 			struct volume_group *vg_to,
 			const char *lv_name);
-int is_global_vg(const char *vg_name);
 int is_orphan_vg(const char *vg_name);
 int is_real_vg(const char *vg_name);
 int vg_missing_pv_count(const struct volume_group *vg);
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index c50e633..e9d4fa2 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -4572,11 +4572,6 @@ int pv_write_orphan(struct cmd_context *cmd, struct physical_volume *pv)
 	return 1;
 }
 
-int is_global_vg(const char *vg_name)
-{
-	return (vg_name && !strcmp(vg_name, VG_GLOBAL)) ? 1 : 0;
-}
-
 /**
  * is_orphan_vg - Determine whether a vg_name is an orphan
  * @vg_name: pointer to the vg_name
@@ -5005,7 +5000,6 @@ static struct volume_group *_vg_lock_and_read(struct cmd_context *cmd, const cha
 	int mdas_consistent = 1;
 	int enable_repair = 1;
 	int is_shared = 0;
-	int skip_lock = is_orphan_vg(vg_name) && (read_flags & PROCESS_SKIP_ORPHAN_LOCK);
 
 	if ((read_flags & READ_ALLOW_INCONSISTENT) || (lock_flags != LCK_VG_WRITE)) {
 		enable_repair = 0;
@@ -5018,15 +5012,11 @@ static struct volume_group *_vg_lock_and_read(struct cmd_context *cmd, const cha
 		return NULL;
 	}
 
-	if (!skip_lock &&
-	    !lock_vol(cmd, vg_name, lock_flags, NULL)) {
+	if (!lock_vol(cmd, vg_name, lock_flags, NULL)) {
 		log_error("Can't get lock for %s", vg_name);
 		return _vg_make_handle(cmd, vg, FAILED_LOCKING);
 	}
 
-	if (skip_lock)
-		log_very_verbose("Locking %s already done", vg_name);
-
 	if (is_orphan_vg(vg_name))
 		status_flags &= ~LVM_WRITE;
 
@@ -5092,14 +5082,12 @@ static struct volume_group *_vg_lock_and_read(struct cmd_context *cmd, const cha
 		goto_bad;
 
 	if (!(vg = _vg_make_handle(cmd, vg, failure)) || vg_read_error(vg))
-		if (!skip_lock)
-			unlock_vg(cmd, vg, vg_name);
+		unlock_vg(cmd, vg, vg_name);
 
 	return vg;
 
 bad:
-	if (!skip_lock)
-		unlock_vg(cmd, vg, vg_name);
+	unlock_vg(cmd, vg, vg_name);
 
 bad_no_unlock:
 	return _vg_make_handle(cmd, vg, failure);
diff --git a/lib/misc/lvm-flock.c b/lib/misc/lvm-flock.c
index 88ea6c2..d65601d 100644
--- a/lib/misc/lvm-flock.c
+++ b/lib/misc/lvm-flock.c
@@ -56,6 +56,20 @@ static void _undo_flock(const char *file, int fd)
 		log_sys_debug("close", file);
 }
 
+static struct lock_list *_get_lock_list_entry(const char *file)
+{
+	struct lock_list *ll;
+	struct dm_list *llh;
+
+	dm_list_iterate(llh, &_lock_list) {
+		ll = dm_list_item(llh, struct lock_list);
+
+		if (!strcmp(ll->res, file))
+			return ll;
+	}
+	return NULL;
+}
+
 static int _release_lock(const char *file, int unlock)
 {
 	struct lock_list *ll;
@@ -167,8 +181,8 @@ int lock_file(const char *file, uint32_t flags)
 {
 	int operation;
 	uint32_t nonblock = flags & LCK_NONBLOCK;
+	uint32_t convert = flags & LCK_CONVERT;
 	int r;
-
 	struct lock_list *ll;
 	char state;
 
@@ -188,6 +202,20 @@ int lock_file(const char *file, uint32_t flags)
 		return 0;
 	}
 
+	if (convert) {
+		if (nonblock)
+			operation |= LOCK_NB;
+		if (!(ll = _get_lock_list_entry(file)))
+			return 0;
+		log_very_verbose("Locking %s %c%c convert", ll->res, state,
+			 	 nonblock ? ' ' : 'B');
+		r = flock(ll->lf, operation);
+		if (!r)
+			return 1;
+		log_error("Failed to convert flock on %s %d", file, errno);
+		return 0;
+	}
+
 	if (!(ll = malloc(sizeof(struct lock_list))))
 		return_0;
 
diff --git a/test/shell/lock-blocking.sh b/test/shell/lock-blocking.sh
index 5f69a1a..06f1a7a 100644
--- a/test/shell/lock-blocking.sh
+++ b/test/shell/lock-blocking.sh
@@ -21,26 +21,26 @@ aux prepare_devs 3
 pvcreate "$dev1" "$dev2"
 vgcreate $SHARED $vg "$dev1" "$dev2"
 
-# if wait_for_locks set, vgremove should wait for orphan lock
+# if wait_for_locks set, vgremove should wait for global lock
 # flock process should have exited by the time first vgremove completes
-flock -w 5 "$TESTDIR/var/lock/lvm/P_orphans" sleep 10 &
-while ! test -f "$TESTDIR/var/lock/lvm/P_orphans" ; do sleep .1 ; done
+flock -w 5 "$TESTDIR/var/lock/lvm/P_global" sleep 10 &
+while ! test -f "$TESTDIR/var/lock/lvm/P_global" ; do sleep .1 ; done
 
 vgremove --config 'global { wait_for_locks = 1 }' $vg
 not vgremove --config 'global { wait_for_locks = 1 }' $vg
 
-test ! -f "$TESTDIR/var/lock/lvm/P_orphans"
+test ! -f "$TESTDIR/var/lock/lvm/P_global"
 
 # if wait_for_locks not set, vgremove should fail on non-blocking lock
 # we must wait for flock process at the end - vgremove won't wait
 vgcreate $SHARED $vg "$dev1" "$dev2"
-flock -w 5 "$TESTDIR/var/lock/lvm/P_orphans" sleep 10 &
+flock -w 5 "$TESTDIR/var/lock/lvm/P_global" sleep 10 &
 
-while ! test -f "$TESTDIR/var/lock/lvm/P_orphans" ; do sleep .1 ; done
+while ! test -f "$TESTDIR/var/lock/lvm/P_global" ; do sleep .1 ; done
 flock_pid=$(jobs -p)
 
 not vgremove --config 'global { wait_for_locks = 0 }' $vg
-test -f "$TESTDIR/var/lock/lvm/P_orphans" # still running
+test -f "$TESTDIR/var/lock/lvm/P_global" # still running
 kill "$flock_pid"
 
 vgremove -ff $vg
diff --git a/tools/polldaemon.c b/tools/polldaemon.c
index 8772476..528014c 100644
--- a/tools/polldaemon.c
+++ b/tools/polldaemon.c
@@ -376,6 +376,7 @@ static void _poll_for_all_vgs(struct cmd_context *cmd,
 	while (1) {
 		parms->outstanding_count = 0;
 		process_each_vg(cmd, 0, NULL, NULL, NULL, READ_FOR_UPDATE, 0, handle, _poll_vg);
+		lock_global(cmd, "un");
 		if (!parms->outstanding_count)
 			break;
 		_nanosleep(parms->interval, 1);
diff --git a/tools/pvchange.c b/tools/pvchange.c
index 696dab4..f37fd91 100644
--- a/tools/pvchange.c
+++ b/tools/pvchange.c
@@ -122,9 +122,8 @@ static int _pvchange_single(struct cmd_context *cmd, struct volume_group *vg,
 	 * Convert sh to ex.
 	 */
 	if (is_orphan(pv)) {
-		if (!lockd_gl(cmd, "ex", 0))
+		if (!lock_global_convert(cmd, "ex"))
 			return_ECMD_FAILED;
-		cmd->lockd_gl_disable = 1;
 	}
 
 	if (tagargs) {
@@ -236,29 +235,12 @@ int pvchange(struct cmd_context *cmd, int argc, char **argv)
 		goto out;
 	}
 
-	if (!argc) {
-		/*
-		 * Take the global lock here so the lvmcache remains
-		 * consistent across orphan/non-orphan vg locks.  If we don't
-		 * take the lock here, pvs with 0 mdas in a non-orphan VG will
-		 * be processed twice.
-		 */
-		if (!lock_vol(cmd, VG_GLOBAL, LCK_VG_WRITE, NULL)) {
-			log_error("Unable to obtain global lock.");
-			ret = ECMD_FAILED;
-			goto out;
-		}
-	}
-
 	set_pv_notify(cmd);
 
 	clear_hint_file(cmd);
 
 	ret = process_each_pv(cmd, argc, argv, NULL, 0, READ_FOR_UPDATE | READ_ALLOW_EXPORTED, handle, _pvchange_single);
 
-	if (!argc)
-		unlock_vg(cmd, NULL, VG_GLOBAL);
-
 	log_print_unless_silent("%d physical volume%s changed / %d physical volume%s not changed",
 				params.done, params.done == 1 ? "" : "s",
 				params.total - params.done, (params.total - params.done) == 1 ? "" : "s");
diff --git a/tools/pvcreate.c b/tools/pvcreate.c
index c244a1f..10d1a37 100644
--- a/tools/pvcreate.c
+++ b/tools/pvcreate.c
@@ -139,14 +139,9 @@ int pvcreate(struct cmd_context *cmd, int argc, char **argv)
 	/* Check for old md signatures at the end of devices. */
 	cmd->use_full_md_check = 1;
 
-	/*
-	 * Needed to change the set of orphan PVs.
-	 * (disable afterward to prevent process_each_pv from doing
-	 * a shared global lock since it's already acquired it ex.)
-	 */
-	if (!lockd_gl(cmd, "ex", 0))
+	/* Needed to change the set of orphan PVs. */
+	if (!lock_global(cmd, "ex"))
 		return_ECMD_FAILED;
-	cmd->lockd_gl_disable = 1;
 
 	clear_hint_file(cmd);
 
@@ -158,8 +153,6 @@ int pvcreate(struct cmd_context *cmd, int argc, char **argv)
 	if (!pvcreate_each_device(cmd, handle, &pp))
 		ret = ECMD_FAILED;
 	else {
-		/* pvcreate_each_device returns with orphans locked */
-		unlock_vg(cmd, NULL, VG_ORPHANS);
 		ret = ECMD_PROCESSED;
 	}
 
diff --git a/tools/pvmove.c b/tools/pvmove.c
index c5e3929..ebbdb4c 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -913,10 +913,10 @@ int pvmove(struct cmd_context *cmd, int argc, char **argv)
 
 		/*
 		 * The command may sit and report progress for some time,
-		 * and we do not want or need the lockd locks held during
+		 * and we do not want or need the global lock held during
 		 * that time.
 		 */
-		lockd_gl(cmd, "un", 0);
+		lock_global(cmd, "un");
 	}
 
 	return pvmove_poll(cmd, pv_name, lvid ? lvid->s : NULL,
diff --git a/tools/pvremove.c b/tools/pvremove.c
index 5f76de6..4ad1f42 100644
--- a/tools/pvremove.c
+++ b/tools/pvremove.c
@@ -34,19 +34,14 @@ int pvremove(struct cmd_context *cmd, int argc, char **argv)
 	pp.pv_count = argc;
 	pp.pv_names = argv;
 
-	/*
-	 * Needed to change the set of orphan PVs.
-	 * (disable afterward to prevent process_each_pv from doing
-	 * a shared global lock since it's already acquired it ex.)
-	 */
-	if (!lockd_gl(cmd, "ex", 0)) {
+	/* Needed to change the set of orphan PVs. */
+	if (!lock_global(cmd, "ex")) {
 		/* Let pvremove -ff skip locks */
 		if (pp.force == DONT_PROMPT_OVERRIDE)
-			log_warn("WARNING: skipping global lock in lvmlockd for force.");
+			log_warn("WARNING: skipping global lock for force.");
 		else
 			return_ECMD_FAILED;
 	}
-	cmd->lockd_gl_disable = 1;
 
 	clear_hint_file(cmd);
 
@@ -67,11 +62,8 @@ int pvremove(struct cmd_context *cmd, int argc, char **argv)
 
 	if (!pvcreate_each_device(cmd, handle, &pp))
 		ret = ECMD_FAILED;
-	else {
-		/* pvcreate_each_device returns with orphans locked */
-		unlock_vg(cmd, NULL, VG_ORPHANS);
+	else
 		ret = ECMD_PROCESSED;
-	}
 
 	destroy_processing_handle(cmd, handle);
 	return ret;
diff --git a/tools/pvresize.c b/tools/pvresize.c
index e951f11..c7e750d 100644
--- a/tools/pvresize.c
+++ b/tools/pvresize.c
@@ -44,12 +44,11 @@ static int _pvresize_single(struct cmd_context *cmd,
 	/*
 	 * Needed to change a property on an orphan PV.
 	 * i.e. the global lock is only needed for orphans.
-	 * Convert sh to ex.
+	 * Convert sh to ex.  (sh was taken by process_each)
 	 */
 	if (is_orphan(pv)) {
-		if (!lockd_gl(cmd, "ex", 0))
+		if (!lock_global_convert(cmd, "ex"))
 			return_ECMD_FAILED;
-		cmd->lockd_gl_disable = 1;
 	}
 
 	if (!pv_resize_single(cmd, vg, pv, params->new_size, arg_is_set(cmd, yes_ARG)))
diff --git a/tools/pvscan.c b/tools/pvscan.c
index a3786c4..61d9cc8 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -148,11 +148,6 @@ int pvscan_display_cmd(struct cmd_context *cmd, int argc, char **argv)
 			  arg_is_set(cmd, exported_ARG) ?
 			  "of exported volume group(s)" : "in no volume group");
 
-	if (!lock_vol(cmd, VG_GLOBAL, LCK_VG_WRITE, NULL)) {
-		log_error("Unable to obtain global lock.");
-		return ECMD_FAILED;
-	}
-
 	if (!(handle = init_processing_handle(cmd, NULL))) {
 		log_error("Failed to initialize processing handle.");
 		ret = ECMD_FAILED;
@@ -174,7 +169,6 @@ int pvscan_display_cmd(struct cmd_context *cmd, int argc, char **argv)
 					params.new_pvs_found, display_size(cmd, params.size_new));
 
 out:
-	unlock_vg(cmd, NULL, VG_GLOBAL);
 	destroy_processing_handle(cmd, handle);
 
 	return ret;
@@ -937,11 +931,6 @@ int pvscan_cache_cmd(struct cmd_context *cmd, int argc, char **argv)
 		all_devs = 1;
 	}
 
-	if (!lock_vol(cmd, VG_GLOBAL, LCK_VG_READ, NULL)) {
-		log_error("Unable to obtain global lock.");
-		return ECMD_FAILED;
-	}
-
 	_online_dir_setup();
 
 	/* Creates a list of dev names from /dev, sysfs, etc; does not read any. */
@@ -1173,7 +1162,6 @@ activate:
 
 	if (!sync_local_dev_names(cmd))
 		stack;
-	unlock_vg(cmd, NULL, VG_GLOBAL);
 	return ret;
 }
 
diff --git a/tools/reporter.c b/tools/reporter.c
index ee38db3..48050ec 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -1076,7 +1076,6 @@ static int _do_report(struct cmd_context *cmd, struct processing_handle *handle,
 	void *orig_custom_handle = handle->custom_handle;
 	report_type_t report_type = single_args->report_type;
 	void *report_handle = NULL;
-	int lock_global = 0;
 	int lv_info_needed;
 	int lv_segment_status_needed;
 	int report_in_group = 0;
@@ -1100,18 +1099,6 @@ static int _do_report(struct cmd_context *cmd, struct processing_handle *handle,
 		report_in_group = 1;
 	}
 
-	/*
-	 * We lock VG_GLOBAL to enable use of metadata cache.
-	 * This can pause alongide pvscan or vgscan process for a while.
-	 */
-	if (single_args->args_are_pvs && (report_type == PVS || report_type == PVSEGS)) {
-		lock_global = 1;
-		if (!lock_vol(cmd, VG_GLOBAL, LCK_VG_READ, NULL)) {
-			log_error("Unable to obtain global lock.");
-			goto out;
-		}
-	}
-
 	switch (report_type) {
 		case DEVTYPES:
 			r = _process_each_devtype(cmd, args->argc, handle);
@@ -1209,8 +1196,6 @@ static int _do_report(struct cmd_context *cmd, struct processing_handle *handle,
 	if (!(args->log_only && (single_args->report_type != CMDLOG)))
 		dm_report_output(report_handle);
 
-	if (lock_global)
-		unlock_vg(cmd, NULL, VG_GLOBAL);
 out:
 	if (report_handle) {
 		if (report_in_group && !dm_report_group_pop(cmd->cmd_report.report_group))
diff --git a/tools/toollib.c b/tools/toollib.c
index 5206e26..5882675 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -2234,7 +2234,7 @@ int process_each_vg(struct cmd_context *cmd,
 	/*
 	 * Needed for a current listing of the global VG namespace.
 	 */
-	if (process_all_vgs_on_system && !lockd_gl(cmd, "sh", 0)) {
+	if (process_all_vgs_on_system && !lock_global(cmd, "sh")) {
 		ret_max = ECMD_FAILED;
 		goto_out;
 	}
@@ -3772,7 +3772,7 @@ int process_each_lv(struct cmd_context *cmd,
 	/*
 	 * Needed for a current listing of the global VG namespace.
 	 */
-	if (process_all_vgs_on_system && !lockd_gl(cmd, "sh", 0)) {
+	if (process_all_vgs_on_system && !lock_global(cmd, "sh")) {
 		ret_max = ECMD_FAILED;
 		goto_out;
 	}
@@ -4344,7 +4344,6 @@ static int _process_pvs_in_vgs(struct cmd_context *cmd, uint32_t read_flags,
 	int ret;
 	int skip;
 	int notfound;
-	int skip_lock;
 	int do_report_ret_code = 1;
 
 	log_set_report_object_type(LOG_REPORT_OBJECT_TYPE_VG);
@@ -4378,8 +4377,6 @@ static int _process_pvs_in_vgs(struct cmd_context *cmd, uint32_t read_flags,
 
 		log_debug("Processing PVs in VG %s", vg_name);
 
-		skip_lock = is_orphan_vg(vg_name) && (read_flags & PROCESS_SKIP_ORPHAN_LOCK);
-
 		vg = vg_read(cmd, vg_name, vg_uuid, read_flags, lockd_state);
 		if (_ignore_vg(vg, vg_name, NULL, read_flags, &skip, &notfound)) {
 			stack;
@@ -4406,7 +4403,7 @@ static int _process_pvs_in_vgs(struct cmd_context *cmd, uint32_t read_flags,
 		if (ret > ret_max)
 			ret_max = ret;
 
-		if (!skip && !skip_lock)
+		if (!skip)
 			unlock_vg(cmd, vg, vg->name);
 endvg:
 		release_vg(vg);
@@ -4497,7 +4494,7 @@ int process_each_pv(struct cmd_context *cmd,
 	process_all_devices = process_all_pvs && (cmd->cname->flags & ENABLE_ALL_DEVS) && all_is_set;
 
 	/* Needed for a current listing of the global VG namespace. */
-	if (!only_this_vgname && !lockd_gl(cmd, "sh", 0)) {
+	if (!only_this_vgname && !lock_global(cmd, "sh")) {
 		ret_max = ECMD_FAILED;
 		goto_out;
 	}
@@ -4575,9 +4572,11 @@ int process_each_pv(struct cmd_context *cmd,
 
 	/*
 	 * If the orphans lock was held, there shouldn't be missed devices.
+	 *
+	 * FIXME: this case can now be removed with the global lock
+	 * replacing the orphans lock.
 	 */
-	if (read_flags & PROCESS_SKIP_ORPHAN_LOCK)
-		goto skip_missed;
+	goto skip_missed;
 
 	/*
 	 * Some PVs may have been missed by the first search if another command
@@ -5382,9 +5381,6 @@ static int _pvremove_check_single(struct cmd_context *cmd,
  * This function returns 1 (success) if the caller requires all specified
  * devices to be created, and all are created, or if the caller does not
  * require all specified devices to be created and one or more were created.
- *
- * When this function returns 1 (success), it returns to the caller with the
- * VG_ORPHANS write lock held.
  */
 
 int pvcreate_each_device(struct cmd_context *cmd,
@@ -5435,11 +5431,6 @@ int pvcreate_each_device(struct cmd_context *cmd,
 		dm_list_add(&pp->arg_devices, &pd->list);
 	}
 
-	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE, NULL)) {
-		log_error("Can't get lock for orphan PVs.");
-		return 0;
-	}
-
 	/*
 	 * Scan before calling process_each_pv so we can set up the PV args
 	 * first.  We can then skip the scan that would normally occur at the
@@ -5468,7 +5459,7 @@ int pvcreate_each_device(struct cmd_context *cmd,
 	 * If it's added to arg_process but needs a prompt or force option, then
 	 * a corresponding prompt entry is added to pp->prompts.
 	 */
-	process_each_pv(cmd, 0, NULL, NULL, 1, PROCESS_SKIP_SCAN | PROCESS_SKIP_ORPHAN_LOCK,
+	process_each_pv(cmd, 0, NULL, NULL, 1, PROCESS_SKIP_SCAN,
 			handle, pp->is_remove ? _pvremove_check_single : _pvcreate_check_single);
 
 	/*
@@ -5557,7 +5548,8 @@ int pvcreate_each_device(struct cmd_context *cmd,
 	 * from the user, reacquire the lock, verify that the PVs were not used
 	 * during the wait, then do the create steps.
 	 */
-	unlock_vg(cmd, NULL, VG_ORPHANS);
+
+	lockf_global(cmd, "un");
 
 	/*
 	 * Process prompts that require asking the user.  The orphans lock is
@@ -5595,9 +5587,10 @@ int pvcreate_each_device(struct cmd_context *cmd,
 	 * finds them changed, or can't find them any more, then they aren't
 	 * used.
 	 */
-	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE, NULL)) {
-		log_error("Can't get lock for orphan PVs.");
-		goto out;
+
+	if (!lockf_global(cmd, "ex")) {
+		log_error("Failed to reacquire global lock after prompt.");
+		goto_out;
 	}
 
 	lvmcache_label_scan(cmd);
@@ -5616,7 +5609,7 @@ int pvcreate_each_device(struct cmd_context *cmd,
 	 */
 	dm_list_splice(&pp->arg_confirm, &pp->arg_process);
 
-	process_each_pv(cmd, 0, NULL, NULL, 1, PROCESS_SKIP_SCAN | PROCESS_SKIP_ORPHAN_LOCK,
+	process_each_pv(cmd, 0, NULL, NULL, 1, PROCESS_SKIP_SCAN,
 			handle, _pv_confirm_single);
 
 	dm_list_iterate_items(pd, &pp->arg_confirm)
@@ -5834,16 +5827,10 @@ do_command:
 			  cmd->command->name, pd->name);
 
 	if (!dm_list_empty(&pp->arg_fail))
-		goto_bad;
+		goto_out;
 
-	/*
-	 * Returns with VG_ORPHANS write lock held because vgcreate and
-	 * vgextend want to use the newly created PVs.
-	 */
 	return 1;
-
 bad:
-	unlock_vg(cmd, NULL, VG_ORPHANS);
 out:
 	return 0;
 }
diff --git a/tools/vgcfgrestore.c b/tools/vgcfgrestore.c
index 2302f0a..e05c286 100644
--- a/tools/vgcfgrestore.c
+++ b/tools/vgcfgrestore.c
@@ -119,14 +119,11 @@ int vgcfgrestore(struct cmd_context *cmd, int argc, char **argv)
 		}
 	}
 
-	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE, NULL)) {
-		log_error("Unable to lock orphans.");
+	if (!lock_global(cmd, "ex"))
 		return ECMD_FAILED;
-	}
 
 	if (!lock_vol(cmd, vg_name, LCK_VG_WRITE, NULL)) {
 		log_error("Unable to lock volume group %s.", vg_name);
-		unlock_vg(cmd, NULL, VG_ORPHANS);
 		return ECMD_FAILED;
 	}
 
@@ -142,7 +139,6 @@ int vgcfgrestore(struct cmd_context *cmd, int argc, char **argv)
 				       arg_count(cmd, force_long_ARG)) :
 	      backup_restore(cmd, vg_name, arg_count(cmd, force_long_ARG)))) {
 		unlock_vg(cmd, NULL, vg_name);
-		unlock_vg(cmd, NULL, VG_ORPHANS);
 		log_error("Restore failed.");
 		ret = ECMD_FAILED;
 		goto out;
@@ -151,7 +147,6 @@ int vgcfgrestore(struct cmd_context *cmd, int argc, char **argv)
 	ret = ECMD_PROCESSED;
 	log_print_unless_silent("Restored volume group %s.", vg_name);
 
-	unlock_vg(cmd, NULL, VG_ORPHANS);
 	unlock_vg(cmd, NULL, vg_name);
 out:
 	return ret;
diff --git a/tools/vgchange.c b/tools/vgchange.c
index f831fd9..a662be3 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -1075,7 +1075,7 @@ int vgchange_locktype_cmd(struct cmd_context *cmd, int argc, char **argv)
 	 * on other hosts, to cause them to see the new system_id or
 	 * lock_type.
 	 */
-	if (!lockd_gl(cmd, "ex", LDGL_UPDATE_NAMES))
+	if (!lockd_global(cmd, "ex"))
 		return 0;
 
 process:
@@ -1138,7 +1138,7 @@ int vgchange_lock_start_stop_cmd(struct cmd_context *cmd, int argc, char **argv)
 	if (arg_is_set(cmd, lockstart_ARG)) {
 		cmd->lockd_vg_disable = 1;
 
-		if (!lockd_gl(cmd, "sh", 0))
+		if (!lockd_global(cmd, "sh"))
 			log_debug("No global lock for lock start");
 
 		/* Disable the lockd_gl in process_each_vg. */
@@ -1154,7 +1154,7 @@ int vgchange_lock_start_stop_cmd(struct cmd_context *cmd, int argc, char **argv)
 	if (arg_is_set(cmd, lockstart_ARG) && vp.lock_start_count) {
 		const char *start_opt = arg_str_value(cmd, lockopt_ARG, NULL);
 
-		if (!lockd_gl(cmd, "un", 0))
+		if (!lockd_global(cmd, "un"))
 			stack;
 
 		if (!start_opt || !strcmp(start_opt, "auto")) {
@@ -1210,7 +1210,7 @@ int vgchange_systemid_cmd(struct cmd_context *cmd, int argc, char **argv)
 	 * on other hosts, to cause them to see the new system_id or
 	 * lock_type.
 	 */
-	if (!lockd_gl(cmd, "ex", LDGL_UPDATE_NAMES))
+	if (!lockd_global(cmd, "ex"))
 		return 0;
 
 	if (!(handle = init_processing_handle(cmd, NULL))) {
diff --git a/tools/vgcreate.c b/tools/vgcreate.c
index f9bf10e..d62925f 100644
--- a/tools/vgcreate.c
+++ b/tools/vgcreate.c
@@ -56,13 +56,10 @@ int vgcreate(struct cmd_context *cmd, int argc, char **argv)
 	if (!vgcreate_params_validate(cmd, &vp_new))
 		return EINVALID_CMD_LINE;
 
-	/*
-	 * Needed to change the global VG namespace,
-	 * and to change the set of orphan PVs.
-	 */
-	if (!lockd_gl_create(cmd, "ex", vp_new.lock_type))
+	if (!lockf_global(cmd, "ex"))
+		return_ECMD_FAILED;
+	if (!lockd_global_create(cmd, "ex", vp_new.lock_type))
 		return_ECMD_FAILED;
-	cmd->lockd_gl_disable = 1;
 
 	clear_hint_file(cmd);
 
@@ -119,12 +116,6 @@ int vgcreate(struct cmd_context *cmd, int argc, char **argv)
 		return_ECMD_FAILED;
 	}
 
-	/*
-	 * pvcreate_each_device returns with the VG_ORPHANS write lock held,
-	 * which was used to do pvcreate.  Now to create the VG using those
-	 * PVs, the VG lock will be taken (with the orphan lock already held.)
-	 */
-
 	if (!(vg = vg_create(cmd, vp_new.vg_name)))
 		goto_bad;
 
@@ -186,7 +177,6 @@ int vgcreate(struct cmd_context *cmd, int argc, char **argv)
 		goto_bad;
 	}
 
-	unlock_vg(cmd, NULL, VG_ORPHANS);
 	unlock_vg(cmd, vg, vp_new.vg_name);
 
 	backup(vg);
@@ -209,7 +199,7 @@ int vgcreate(struct cmd_context *cmd, int argc, char **argv)
 			goto out;
 		}
 
-		lockd_gl(cmd, "un", 0);
+		lock_global(cmd, "un");
 
 		if (!start_opt || !strcmp(start_opt, "wait")) {
 			/* It is OK if the user does Ctrl-C to cancel the wait. */
@@ -228,7 +218,6 @@ out:
 
 bad:
 	unlock_vg(cmd, vg, vp_new.vg_name);
-	unlock_vg(cmd, NULL, VG_ORPHANS);
 	release_vg(vg);
 	destroy_processing_handle(cmd, handle);
 	return ECMD_FAILED;
diff --git a/tools/vgextend.c b/tools/vgextend.c
index c727d75..02da3a8 100644
--- a/tools/vgextend.c
+++ b/tools/vgextend.c
@@ -157,14 +157,8 @@ int vgextend(struct cmd_context *cmd, int argc, char **argv)
 	/* Check for old md signatures at the end of devices. */
 	cmd->use_full_md_check = 1;
 
-	/*
-	 * Needed to change the set of orphan PVs.
-	 * (disable afterward to prevent process_each_pv from doing
-	 * a shared global lock since it's already acquired it ex.)
-	 */
-	if (!lockd_gl(cmd, "ex", 0))
+	if (!lock_global(cmd, "ex"))
 		return_ECMD_FAILED;
-	cmd->lockd_gl_disable = 1;
 
 	clear_hint_file(cmd);
 
@@ -181,12 +175,6 @@ int vgextend(struct cmd_context *cmd, int argc, char **argv)
 	}
 
 	/*
-	 * pvcreate_each_device returns with the VG_ORPHANS write lock held,
-	 * which was used to do pvcreate.  Now to create the VG using those
-	 * PVs, the VG lock will be taken (with the orphan lock already held.)
-	 */
-
-	/*
 	 * It is always ok to add new PVs to a VG - even if there are
 	 * missing PVs.  No LVs are affected by this operation, but
 	 * repair processes - particularly for RAID segtypes - can
@@ -202,7 +190,5 @@ int vgextend(struct cmd_context *cmd, int argc, char **argv)
 
 	destroy_processing_handle(cmd, handle);
 
-	if (!restoremissing)
-		unlock_vg(cmd, NULL, VG_ORPHANS);
 	return ret;
 }
diff --git a/tools/vgimportclone.c b/tools/vgimportclone.c
index 34c211c..f7b1c0b 100644
--- a/tools/vgimportclone.c
+++ b/tools/vgimportclone.c
@@ -223,16 +223,11 @@ int vgimportclone(struct cmd_context *cmd, int argc, char **argv)
 	}
 	handle->custom_handle = &vp;
 
-	if (!lock_vol(cmd, VG_GLOBAL, LCK_VG_WRITE, NULL)) {
-		log_error("Unable to obtain global lock.");
+	if (!lock_global(cmd, "ex")) {
 		destroy_processing_handle(cmd, handle);
 		return ECMD_FAILED;
 	}
 
-	if (!lockd_gl(cmd, "ex", 0))
-		goto_out;
-	cmd->lockd_gl_disable = 1;
-
 	/*
 	 * Find the devices being imported which are named on the command line.
 	 * They may be in the list of unchosen duplicates.
@@ -351,7 +346,6 @@ retry_name:
 
 	unlock_vg(cmd, NULL, vp.new_vgname);
 out:
-	unlock_vg(cmd, NULL, VG_GLOBAL);
 	internal_filter_clear();
 	init_internal_filtering(0);
 	destroy_processing_handle(cmd, handle);
diff --git a/tools/vgmerge.c b/tools/vgmerge.c
index 8c8f2a2..903504c 100644
--- a/tools/vgmerge.c
+++ b/tools/vgmerge.c
@@ -206,8 +206,7 @@ int vgmerge(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
-	/* Needed change the global VG namespace. */
-	if (!lockd_gl(cmd, "ex", LDGL_UPDATE_NAMES))
+	if (!lock_global(cmd, "ex"))
 		return ECMD_FAILED;
 
 	clear_hint_file(cmd);
diff --git a/tools/vgreduce.c b/tools/vgreduce.c
index 1bca33f..bc1f5b6 100644
--- a/tools/vgreduce.c
+++ b/tools/vgreduce.c
@@ -219,10 +219,8 @@ int vgreduce(struct cmd_context *cmd, int argc, char **argv)
 	argv++;
 	argc--;
 
-	/* Needed to change the set of orphan PVs. */
-	if (!lockd_gl(cmd, "ex", 0))
+	if (!lock_global(cmd, "ex"))
 		return_ECMD_FAILED;
-	cmd->lockd_gl_disable = 1;
 
 	clear_hint_file(cmd);
 
@@ -233,20 +231,12 @@ int vgreduce(struct cmd_context *cmd, int argc, char **argv)
 	handle->custom_handle = &vp;
 
 	if (!repairing) {
-		if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE, NULL)) {
-			log_error("Can't get lock for orphan PVs");
-			ret = ECMD_FAILED;
-			goto out;
-		}
-
 		/* FIXME: Pass private struct through to all these functions */
 		/* and update in batch afterwards? */
 
-		ret = process_each_pv(cmd, argc, argv, vg_name, 0,
-				      READ_FOR_UPDATE | PROCESS_SKIP_ORPHAN_LOCK,
+		ret = process_each_pv(cmd, argc, argv, vg_name, 0, READ_FOR_UPDATE,
 				      handle, _vgreduce_single);
 
-		unlock_vg(cmd, NULL, VG_ORPHANS);
 		goto out;
 	}
 
diff --git a/tools/vgremove.c b/tools/vgremove.c
index 2120858..1aae87d 100644
--- a/tools/vgremove.c
+++ b/tools/vgremove.c
@@ -94,33 +94,15 @@ int vgremove(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
-	/*
-	 * Needed to change the global VG namespace,
-	 * and to change the set of orphan PVs.
-	 */
-	if (!lockd_gl(cmd, "ex", LDGL_UPDATE_NAMES))
-		return ECMD_FAILED;
+	if (!lock_global(cmd, "ex"))
+		return_ECMD_FAILED;
 
 	clear_hint_file(cmd);
 
-	/*
-	 * This is a special case: if vgremove is given a tag, it causes
-	 * process_each_vg to do lockd_gl(sh) when getting a list of all
-	 * VG names.  We don't want the gl converted to sh, so disable it.
-	 */
-	cmd->lockd_gl_disable = 1;
-
-	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE, NULL)) {
-		log_error("Can't get lock for orphan PVs");
-		return ECMD_FAILED;
-	}
-
 	cmd->handles_missing_pvs = 1;
 	ret = process_each_vg(cmd, argc, argv, NULL, NULL,
 			      READ_FOR_UPDATE, 0,
 			      NULL, &_vgremove_single);
 
-	unlock_vg(cmd, NULL, VG_ORPHANS);
-
 	return ret;
 }
diff --git a/tools/vgrename.c b/tools/vgrename.c
index 1286ed9..4735e8b 100644
--- a/tools/vgrename.c
+++ b/tools/vgrename.c
@@ -191,8 +191,7 @@ int vgrename(struct cmd_context *cmd, int argc, char **argv)
 	if (!(vp.vg_name_new = dm_pool_strdup(cmd->mem, vg_name_new)))
 		return_ECMD_FAILED;
 
-	/* Needed change the global VG namespace. */
-	if (!lockd_gl(cmd, "ex", LDGL_UPDATE_NAMES))
+	if (!lock_global(cmd, "ex"))
 		return_ECMD_FAILED;
 
 	clear_hint_file(cmd);
diff --git a/tools/vgscan.c b/tools/vgscan.c
index 6138855..3388c8a 100644
--- a/tools/vgscan.c
+++ b/tools/vgscan.c
@@ -47,11 +47,6 @@ int vgscan(struct cmd_context *cmd, int argc, char **argv)
 		return ECMD_PROCESSED;
 	}
 
-	if (!lock_vol(cmd, VG_GLOBAL, LCK_VG_WRITE, NULL)) {
-		log_error("Unable to obtain global lock.");
-		return ECMD_FAILED;
-	}
-
 	if (arg_is_set(cmd, cache_long_ARG)) {
 		log_warn("Ignoring vgscan --cache command because lvmetad is no longer used.");
 		return ECMD_PROCESSED;
@@ -65,6 +60,5 @@ int vgscan(struct cmd_context *cmd, int argc, char **argv)
 			maxret = ret;
 	}
 
-	unlock_vg(cmd, NULL, VG_GLOBAL);
 	return maxret;
 }
diff --git a/tools/vgsplit.c b/tools/vgsplit.c
index e931a5c..8dd81ad 100644
--- a/tools/vgsplit.c
+++ b/tools/vgsplit.c
@@ -554,8 +554,7 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 		return ECMD_FAILED;
 	}
 
-	/* Needed change the global VG namespace. */
-	if (!lockd_gl(cmd, "ex", LDGL_UPDATE_NAMES))
+	if (!lock_global(cmd, "ex"))
 		return_ECMD_FAILED;
 
 	clear_hint_file(cmd);


