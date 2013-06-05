From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed,  5 Jun 2013 12:05:55 +0000 (UTC)
Subject: dev-mornfall-lvmcache - lvmcache: Split off lock cache into a separate unit.
Message-ID: <20130605120555.4369D60F90@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=94d9562bea6d0fa5bc7e919cb34090ffe6b45fd9
Commit:        94d9562bea6d0fa5bc7e919cb34090ffe6b45fd9
Parent:        57795df3652211a0eb05ad924837006327dde02c
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon Feb 18 15:31:50 2013 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Jun 5 12:37:36 2013 +0200

lvmcache: Split off lock cache into a separate unit.

---
 include/.symlinks.in    |    1 +
 lib/Makefile.in         |    1 +
 lib/cache/lvmcache.c    |  162 ++++-------------------------------------------
 lib/cache/lvmcache.h    |    7 +--
 lib/locking/lockcache.c |  156 +++++++++++++++++++++++++++++++++++++++++++++
 lib/locking/lockcache.h |   13 ++++
 lib/locking/locking.c   |   12 +++-
 lib/metadata/metadata.c |    5 +-
 8 files changed, 195 insertions(+), 162 deletions(-)

diff --git a/include/.symlinks.in b/include/.symlinks.in
index 1c883ae..043ce15 100644
--- a/include/.symlinks.in
+++ b/include/.symlinks.in
@@ -32,6 +32,7 @@
 @top_srcdir@/lib/format_text/text_import.h
 @top_srcdir@/lib/label/label.h
 @top_srcdir@/lib/locking/locking.h
+ at top_srcdir@/lib/locking/lockcache.h
 @top_srcdir@/lib/log/log.h
 @top_srcdir@/lib/log/lvm-logging.h
 @top_srcdir@/lib/metadata/lv.h
diff --git a/lib/Makefile.in b/lib/Makefile.in
index 82f700b..8c1dca7 100644
--- a/lib/Makefile.in
+++ b/lib/Makefile.in
@@ -81,6 +81,7 @@ SOURCES =\
 	locking/file_locking.c \
 	locking/locking.c \
 	locking/no_locking.c \
+	locking/lockcache.c \
 	log/log.c \
 	metadata/lv.c \
 	metadata/lv_manip.c \
diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index b457470..d4e6f03 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -18,6 +18,7 @@
 #include "toolcontext.h"
 #include "dev-cache.h"
 #include "locking.h"
+#include "lockcache.h"
 #include "metadata.h"
 #include "filter.h"
 #include "filter-persistent.h"
@@ -68,20 +69,14 @@ struct lvmcache_vginfo {
 static struct dm_hash_table *_pvid_hash = NULL;
 static struct dm_hash_table *_vgid_hash = NULL;
 static struct dm_hash_table *_vgname_hash = NULL;
-static struct dm_hash_table *_lock_hash = NULL;
 static DM_LIST_INIT(_vginfos);
 static int _scanning_in_progress = 0;
 static int _has_scanned = 0;
-static int _vgs_locked = 0;
-static int _vg_global_lock_held = 0;	/* Global lock held when cache wiped? */
 
 int lvmcache_init(void)
 {
-	/*
-	 * FIXME add a proper lvmcache_locking_reset() that
-	 * resets the cache so no previous locks are locked
-	 */
-	_vgs_locked = 0;
+	int vg_global_lock_held = lockcache_vgname_is_locked(VG_GLOBAL);
+	lockcache_destroy();
 
 	dm_list_init(&_vginfos);
 
@@ -94,18 +89,13 @@ int lvmcache_init(void)
 	if (!(_pvid_hash = dm_hash_create(128)))
 		return 0;
 
-	if (!(_lock_hash = dm_hash_create(128)))
-		return 0;
-
 	/*
 	 * Reinitialising the cache clears the internal record of
 	 * which locks are held.  The global lock can be held during
 	 * this operation so its state must be restored afterwards.
 	 */
-	if (_vg_global_lock_held) {
-		lvmcache_lock_vgname(VG_GLOBAL, 0);
-		_vg_global_lock_held = 0;
-	}
+	if (vg_global_lock_held)
+		lockcache_lock_vgname(VG_GLOBAL, 0);
 
 	return 1;
 }
@@ -197,7 +187,7 @@ static void _update_cache_info_lock_state(struct lvmcache_info *info,
 	 * Cache becomes invalid whenever lock state changes unless
 	 * exclusive VG_GLOBAL is held (i.e. while scanning).
 	 */
-	if (!lvmcache_vgname_is_locked(VG_GLOBAL) && (was_locked != locked)) {
+	if (!lockcache_vgname_is_locked(VG_GLOBAL) && (was_locked != locked)) {
 		info->status |= CACHE_INVALID;
 		*cached_vgmetadata_valid = 0;
 	}
@@ -222,7 +212,7 @@ static void _update_cache_vginfo_lock_state(struct lvmcache_vginfo *vginfo,
 		_free_cached_vgmetadata(vginfo);
 }
 
-static void _update_cache_lock_state(const char *vgname, int locked)
+void lvmcache_update_lock_state(const char *vgname, int locked)
 {
 	struct lvmcache_vginfo *vginfo;
 
@@ -290,115 +280,10 @@ void lvmcache_drop_metadata(const char *vgname, int drop_precommitted)
 
 		/* Indicate that PVs could now be missing from the cache */
 		init_full_scan_done(0);
-	} else if (!lvmcache_vgname_is_locked(VG_GLOBAL))
+	} else if (!lockcache_vgname_is_locked(VG_GLOBAL))
 		_drop_metadata(vgname, drop_precommitted);
 }
 
-/*
- * Ensure vgname2 comes after vgname1 alphabetically.
- * Orphan locks come last.
- * VG_GLOBAL comes first.
- */
-static int _vgname_order_correct(const char *vgname1, const char *vgname2)
-{
-	if (is_global_vg(vgname1))
-		return 1;
-
-	if (is_global_vg(vgname2))
-		return 0;
-
-	if (is_orphan_vg(vgname1))
-		return 0;
-
-	if (is_orphan_vg(vgname2))
-		return 1;
-
-	if (strcmp(vgname1, vgname2) < 0)
-		return 1;
-
-	return 0;
-}
-
-/*
- * Ensure VG locks are acquired in alphabetical order.
- */
-int lvmcache_verify_lock_order(const char *vgname)
-{
-	struct dm_hash_node *n;
-	const char *vgname2;
-
-	if (!_lock_hash)
-		return_0;
-
-	dm_hash_iterate(n, _lock_hash) {
-		if (!dm_hash_get_data(_lock_hash, n))
-			return_0;
-
-		if (!(vgname2 = dm_hash_get_key(_lock_hash, n))) {
-			log_error(INTERNAL_ERROR "VG lock %s hits NULL.",
-				 vgname);
-			return 0;
-		}
-
-		if (!_vgname_order_correct(vgname2, vgname)) {
-			log_errno(EDEADLK, INTERNAL_ERROR "VG lock %s must "
-				  "be requested before %s, not after.",
-				  vgname, vgname2);
-			return 0;
-		}
-	}
-
-	return 1;
-}
-
-void lvmcache_lock_vgname(const char *vgname, int read_only __attribute__((unused)))
-{
-	if (!_lock_hash && !lvmcache_init()) {
-		log_error("Internal cache initialisation failed");
-		return;
-	}
-
-	if (dm_hash_lookup(_lock_hash, vgname))
-		log_error(INTERNAL_ERROR "Nested locking attempted on VG %s.",
-			  vgname);
-
-	if (!dm_hash_insert(_lock_hash, vgname, (void *) 1))
-		log_error("Cache locking failure for %s", vgname);
-
-	_update_cache_lock_state(vgname, 1);
-
-	if (strcmp(vgname, VG_GLOBAL))
-		_vgs_locked++;
-}
-
-int lvmcache_vgname_is_locked(const char *vgname)
-{
-	if (!_lock_hash)
-		return 0;
-
-	return dm_hash_lookup(_lock_hash, is_orphan_vg(vgname) ? VG_ORPHANS : vgname) ? 1 : 0;
-}
-
-void lvmcache_unlock_vgname(const char *vgname)
-{
-	if (!dm_hash_lookup(_lock_hash, vgname))
-		log_error(INTERNAL_ERROR "Attempt to unlock unlocked VG %s.",
-			  vgname);
-
-	_update_cache_lock_state(vgname, 0);
-
-	dm_hash_remove(_lock_hash, vgname);
-
-	/* FIXME Do this per-VG */
-	if (strcmp(vgname, VG_GLOBAL) && !--_vgs_locked)
-		dev_close_all();
-}
-
-int lvmcache_vgs_locked(void)
-{
-	return _vgs_locked;
-}
-
 static void _vginfo_attach_info(struct lvmcache_vginfo *vginfo,
 				struct lvmcache_info *info)
 {
@@ -551,7 +436,7 @@ static int _info_is_valid(struct lvmcache_info *info)
 	 * So if the VG appears to be unlocked here, it should be safe
 	 * to use the cached value.
 	 */
-	if (info->vginfo && !lvmcache_vgname_is_locked(info->vginfo->vgname))
+	if (info->vginfo && !lockcache_vgname_is_locked(info->vginfo->vgname))
 		return 1;
 
 	if (!(info->status & CACHE_LOCKED))
@@ -1319,7 +1204,7 @@ static int _lvmcache_update_vgname(struct lvmcache_info *info,
 	else if (!_lvmcache_update_vgid(NULL, vginfo, vgid)) /* Orphans */
 		return_0;
 
-	_update_cache_vginfo_lock_state(vginfo, lvmcache_vgname_is_locked(vgname));
+	_update_cache_vginfo_lock_state(vginfo, lockcache_vgname_is_locked(vgname));
 
 	/* FIXME Check consistency of list! */
 	vginfo->fmt = fmt;
@@ -1377,7 +1262,7 @@ static int _lvmcache_update_vgstatus(struct lvmcache_info *info, uint32_t vgstat
 
 int lvmcache_add_orphan_vginfo(const char *vgname, struct format_type *fmt)
 {
-	if (!_lock_hash && !lvmcache_init()) {
+	if (!_vgid_hash && !lvmcache_init()) {
 		log_error("Internal cache initialisation failed");
 		return 0;
 	}
@@ -1582,22 +1467,6 @@ static void _lvmcache_destroy_vgnamelist(struct lvmcache_vginfo *vginfo)
 	} while ((vginfo = next));
 }
 
-static void _lvmcache_destroy_lockname(struct dm_hash_node *n)
-{
-	char *vgname;
-
-	if (!dm_hash_get_data(_lock_hash, n))
-		return;
-
-	vgname = dm_hash_get_key(_lock_hash, n);
-
-	if (!strcmp(vgname, VG_GLOBAL))
-		_vg_global_lock_held = 1;
-	else
-		log_error(INTERNAL_ERROR "Volume Group %s was not unlocked",
-			  dm_hash_get_key(_lock_hash, n));
-}
-
 void lvmcache_destroy(struct cmd_context *cmd, int retain_orphans)
 {
 	struct dm_hash_node *n;
@@ -1623,13 +1492,6 @@ void lvmcache_destroy(struct cmd_context *cmd, int retain_orphans)
 		_vgname_hash = NULL;
 	}
 
-	if (_lock_hash) {
-		dm_hash_iterate(n, _lock_hash)
-			_lvmcache_destroy_lockname(n);
-		dm_hash_destroy(_lock_hash);
-		_lock_hash = NULL;
-	}
-
 	if (!dm_list_empty(&_vginfos))
 		log_error(INTERNAL_ERROR "_vginfos list should be empty");
 	dm_list_init(&_vginfos);
@@ -1645,7 +1507,7 @@ int lvmcache_pvid_is_locked(const char *pvid) {
 	if (!info || !info->vginfo)
 		return 0;
 
-	return lvmcache_vgname_is_locked(info->vginfo->vgname);
+	return lockcache_vgname_is_locked(info->vginfo->vgname);
 }
 
 int lvmcache_fid_add_mdas(struct lvmcache_info *info, struct format_instance *fid,
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index 119b411..3a31d20 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -60,10 +60,7 @@ int lvmcache_update_vgname_and_id(struct lvmcache_info *info,
 				  const char *vgname, const char *vgid,
 				  uint32_t vgstatus, const char *hostname);
 int lvmcache_update_vg(struct volume_group *vg, unsigned precommitted);
-
-void lvmcache_lock_vgname(const char *vgname, int read_only);
-void lvmcache_unlock_vgname(const char *vgname);
-int lvmcache_verify_lock_order(const char *vgname);
+void lvmcache_update_lock_state(const char *vgname, int locked);
 
 /* Queries */
 const struct format_type *lvmcache_fmt_from_vgname(struct cmd_context *cmd, const char *vgname, const char *vgid, unsigned revalidate_labels);
@@ -82,8 +79,6 @@ const char *lvmcache_pvid_from_devname(struct cmd_context *cmd,
 			      const char *dev_name);
 char *lvmcache_vgname_from_pvid(struct cmd_context *cmd, const char *pvid);
 const char *lvmcache_vgname_from_info(struct lvmcache_info *info);
-int lvmcache_vgs_locked(void);
-int lvmcache_vgname_is_locked(const char *vgname);
 
 void lvmcache_seed_infos_from_lvmetad(struct cmd_context *cmd);
 
diff --git a/lib/locking/lockcache.c b/lib/locking/lockcache.c
new file mode 100644
index 0000000..cb1a4d9
--- /dev/null
+++ b/lib/locking/lockcache.c
@@ -0,0 +1,156 @@
+#include "lib.h"
+#include "lockcache.h"
+#include "device.h"
+#include "metadata-exported.h"
+
+static struct dm_hash_table *_lock_hash = NULL;
+static int _vgs_locked = 0;
+
+static void _lockcache_destroy_lockname(struct dm_hash_node *n)
+{
+	char *vgname;
+
+	if (!dm_hash_get_data(_lock_hash, n))
+		return;
+
+	vgname = dm_hash_get_key(_lock_hash, n);
+
+	if (strcmp(vgname, VG_GLOBAL))
+		log_error(INTERNAL_ERROR "Volume Group %s was not unlocked",
+			  dm_hash_get_key(_lock_hash, n));
+}
+
+static int _lockcache_init(void)
+{
+	if (_lock_hash)
+		return 1;
+
+	/*
+	 * FIXME add a proper lockcache_reset() that resets the cache so no
+	 * previous locks are locked
+	 */
+
+	_vgs_locked = 0;
+
+	if (!(_lock_hash = dm_hash_create(128)))
+		return 0;
+	return 1;
+
+}
+
+void lockcache_destroy(void) {
+	struct dm_hash_node *n;
+	if (_lock_hash) {
+		dm_hash_iterate(n, _lock_hash)
+			_lockcache_destroy_lockname(n);
+		dm_hash_destroy(_lock_hash);
+		_lock_hash = NULL;
+	}
+}
+
+int lockcache_vgname_is_locked(const char *vgname)
+{
+	if (!_lock_hash)
+		return 0;
+
+	return dm_hash_lookup(_lock_hash, is_orphan_vg(vgname) ? VG_ORPHANS : vgname) ? 1 : 0;
+}
+
+void lockcache_lock_vgname(const char *vgname, int read_only __attribute__((unused)))
+{
+	if (!_lockcache_init()) {
+		log_error("Internal cache initialisation failed");
+		return;
+	}
+
+	if (dm_hash_lookup(_lock_hash, vgname))
+		log_error(INTERNAL_ERROR "Nested locking attempted on VG %s.",
+			  vgname);
+
+	if (!dm_hash_insert(_lock_hash, vgname, (void *) 1))
+		log_error("Cache locking failure for %s", vgname);
+
+	if (strcmp(vgname, VG_GLOBAL))
+		_vgs_locked++;
+}
+
+
+void lockcache_unlock_vgname(const char *vgname)
+{
+	if (!_lockcache_init()) {
+		log_error("Internal cache initialisation failed");
+		return;
+	}
+
+	if (!dm_hash_lookup(_lock_hash, vgname))
+		log_error(INTERNAL_ERROR "Attempt to unlock unlocked VG %s.",
+			  vgname);
+
+	dm_hash_remove(_lock_hash, vgname);
+
+	/* FIXME Do this per-VG */
+	if (strcmp(vgname, VG_GLOBAL) && !--_vgs_locked)
+		dev_close_all();
+}
+
+int lockcache_vgs_locked(void)
+{
+	return _vgs_locked;
+}
+
+/*
+ * Ensure vgname2 comes after vgname1 alphabetically.
+ * Orphan locks come last.
+ * VG_GLOBAL comes first.
+ */
+static int _vgname_order_correct(const char *vgname1, const char *vgname2)
+{
+	if (is_global_vg(vgname1))
+		return 1;
+
+	if (is_global_vg(vgname2))
+		return 0;
+
+	if (is_orphan_vg(vgname1))
+		return 0;
+
+	if (is_orphan_vg(vgname2))
+		return 1;
+
+	if (strcmp(vgname1, vgname2) < 0)
+		return 1;
+
+	return 0;
+}
+
+/*
+ * Ensure VG locks are acquired in alphabetical order.
+ */
+int lockcache_verify_lock_order(const char *vgname)
+{
+	struct dm_hash_node *n;
+	const char *vgname2;
+
+	if (!_lockcache_init())
+		return_0;
+
+	dm_hash_iterate(n, _lock_hash) {
+		if (!dm_hash_get_data(_lock_hash, n))
+			return_0;
+
+		if (!(vgname2 = dm_hash_get_key(_lock_hash, n))) {
+			log_error(INTERNAL_ERROR "VG lock %s hits NULL.",
+				 vgname);
+			return 0;
+		}
+
+		if (!_vgname_order_correct(vgname2, vgname)) {
+			log_errno(EDEADLK, INTERNAL_ERROR "VG lock %s must "
+				  "be requested before %s, not after.",
+				  vgname, vgname2);
+			return 0;
+		}
+	}
+
+	return 1;
+}
diff --git a/lib/locking/lockcache.h b/lib/locking/lockcache.h
new file mode 100644
index 0000000..80c10f7
--- /dev/null
+++ b/lib/locking/lockcache.h
@@ -0,0 +1,13 @@
+#ifndef _LVM_LOCKCACHE_H
+#define _LVM_LOCKCACHE_H
+
+#include "locking.h"
+
+int lockcache_vgname_is_locked(const char *vgname);
+void lockcache_lock_vgname(const char *vgname, int read_only);
+void lockcache_unlock_vgname(const char *vgname);
+int lockcache_vgs_locked(void);
+int lockcache_verify_lock_order(const char *vgname);
+void lockcache_destroy(void);
+
+#endif
diff --git a/lib/locking/locking.c b/lib/locking/locking.c
index 63f946f..70f15ab 100644
--- a/lib/locking/locking.c
+++ b/lib/locking/locking.c
@@ -22,6 +22,7 @@
 #include "memlock.h"
 #include "defaults.h"
 #include "lvmcache.h"
+#include "lockcache.h"
 
 #include <assert.h>
 #include <signal.h>
@@ -381,8 +382,10 @@ static int _lock_vol(struct cmd_context *cmd, const char *resource,
 
 	if ((ret = _locking.lock_resource(cmd, resource, flags))) {
 		if (lck_scope == LCK_VG && !(flags & LCK_CACHE)) {
-			if (lck_type != LCK_UNLOCK)
-				lvmcache_lock_vgname(resource, lck_type == LCK_READ);
+			if (lck_type != LCK_UNLOCK) {
+				lockcache_lock_vgname(resource, lck_type == LCK_READ);
+				lvmcache_update_lock_state(resource, 1);
+			}
 			dev_reset_error_count(cmd);
 		}
 
@@ -392,7 +395,8 @@ static int _lock_vol(struct cmd_context *cmd, const char *resource,
 
 	/* If unlocking, always remove lock from lvmcache even if operation failed. */
 	if (lck_scope == LCK_VG && !(flags & LCK_CACHE) && lck_type == LCK_UNLOCK) {
-		lvmcache_unlock_vgname(resource);
+		lockcache_unlock_vgname(resource);
+		lvmcache_update_lock_state(resource, 0);
 		if (!ret)
 			_update_vg_lock_count(resource, flags);
 	}
@@ -436,7 +440,7 @@ int lock_vol(struct cmd_context *cmd, const char *vol, uint32_t flags)
 		/* VG locks alphabetical, ORPHAN lock last */
 		if ((lck_type != LCK_UNLOCK) &&
 		    !(flags & LCK_CACHE) &&
-		    !lvmcache_verify_lock_order(vol))
+		    !lockcache_verify_lock_order(vol))
 			return_0;
 
 		/* Lock VG to change on-disk metadata. */
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index aea593a..2fe795c 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -28,6 +28,7 @@
 #include "activate.h"
 #include "display.h"
 #include "locking.h"
+#include "lockcache.h"
 #include "archiver.h"
 #include "defaults.h"
 
@@ -2669,7 +2670,7 @@ int vg_commit(struct volume_group *vg)
 {
 	int cache_updated = 0;
 
-	if (!lvmcache_vgname_is_locked(vg->name)) {
+	if (!lockcache_vgname_is_locked(vg->name)) {
 		log_error(INTERNAL_ERROR "Attempt to write new VG metadata "
 			  "without locking %s", vg->name);
 		return cache_updated;
@@ -3990,7 +3991,7 @@ static struct volume_group *_vg_lock_and_read(struct cmd_context *cmd, const cha
 		return NULL;
 	}
 
-	already_locked = lvmcache_vgname_is_locked(vg_name);
+	already_locked = lockcache_vgname_is_locked(vg_name);
 
 	if (!already_locked && !(misc_flags & READ_WITHOUT_LOCK) &&
 	    !lock_vol(cmd, vg_name, lock_flags)) {


