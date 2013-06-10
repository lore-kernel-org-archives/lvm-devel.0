From: Petr Rockai <mornfall@fedoraproject.org>
Date: Mon, 10 Jun 2013 20:51:04 +0000 (UTC)
Subject: master - locking: Make it possible to pass down an LV to activation code.
Message-ID: <20130610205104.B56D060F90@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f65dd341a5617aeffe18127ba5bd7ca5ca4d8477
Commit:        f65dd341a5617aeffe18127ba5bd7ca5ca4d8477
Parent:        5d5f2306bd4635cdc7e97a6a875384a00c9be460
Author:        Petr Rockai <me@mornfall.net>
AuthorDate:    Sun Mar 17 21:29:58 2013 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Mon Jun 10 17:26:38 2013 +0200

locking: Make it possible to pass down an LV to activation code.

Previously, we have relied on UUIDs alone, and on lvmcache to make getting a
"new copy" of VG metadata fast. If the code which triggers the activation has
the correct VG metadata at hand (the version which is currently on disk), it can
now hand it to the activation code directly.
---
 daemons/clvmd/lvm-functions.c  |   12 +++---
 lib/activate/activate.c        |   79 +++++++++++++++++++++-------------------
 lib/activate/activate.h        |   14 ++++----
 lib/locking/cluster_locking.c  |    4 +-
 lib/locking/external_locking.c |    2 +-
 lib/locking/file_locking.c     |   12 +++---
 lib/locking/locking.c          |   14 ++++----
 lib/locking/locking.h          |   16 +++++----
 lib/locking/locking_types.h    |    2 +-
 lib/locking/no_locking.c       |   16 ++++----
 lib/metadata/metadata.c        |    8 ++--
 liblvm/lvm_vg.c                |    4 +-
 tools/lvconvert.c              |    2 +-
 tools/pvchange.c               |    2 +-
 tools/pvcreate.c               |    2 +-
 tools/pvremove.c               |    2 +-
 tools/pvresize.c               |    2 +-
 tools/pvscan.c                 |    4 +-
 tools/toollib.c                |    2 +-
 tools/vgcfgrestore.c           |    4 +-
 tools/vgcreate.c               |    2 +-
 tools/vgextend.c               |    2 +-
 tools/vgreduce.c               |    2 +-
 tools/vgscan.c                 |    2 +-
 24 files changed, 108 insertions(+), 103 deletions(-)

diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
index 5e83454..99d2eb3 100644
--- a/daemons/clvmd/lvm-functions.c
+++ b/daemons/clvmd/lvm-functions.c
@@ -356,7 +356,7 @@ static int do_activate_lv(char *resource, unsigned char command, unsigned char l
 	}
 
 	/* Does the config file want us to activate this LV ? */
-	if (!lv_activation_filter(cmd, resource, &activate_lv))
+	if (!lv_activation_filter(cmd, resource, &activate_lv, NULL))
 		return EIO;
 
 	if (!activate_lv)
@@ -394,14 +394,14 @@ static int do_activate_lv(char *resource, unsigned char command, unsigned char l
 
 	if (lvi.suspended) {
 		critical_section_inc(cmd, "resuming");
-		if (!lv_resume(cmd, resource, 0)) {
+		if (!lv_resume(cmd, resource, 0, NULL)) {
 			critical_section_dec(cmd, "resumed");
 			goto error;
 		}
 	}
 
 	/* Now activate it */
-	if (!lv_activate(cmd, resource, exclusive))
+	if (!lv_activate(cmd, resource, exclusive, NULL))
 		goto error;
 
 	return 0;
@@ -427,7 +427,7 @@ static int do_resume_lv(char *resource, unsigned char command, unsigned char loc
 	exclusive = (oldmode == LCK_EXCL) ? 1 : 0;
 	revert = (lock_flags & LCK_REVERT_MODE) ? 1 : 0;
 
-	if (!lv_resume_if_active(cmd, resource, origin_only, exclusive, revert))
+	if (!lv_resume_if_active(cmd, resource, origin_only, exclusive, revert, NULL))
 		return EIO;
 
 	return 0;
@@ -450,7 +450,7 @@ static int do_suspend_lv(char *resource, unsigned char command, unsigned char lo
 	exclusive = (oldmode == LCK_EXCL) ? 1 : 0;
 
 	/* Always call lv_suspend to read commited and precommited data */
-	if (!lv_suspend_if_active(cmd, resource, origin_only, exclusive))
+	if (!lv_suspend_if_active(cmd, resource, origin_only, exclusive, NULL))
 		return EIO;
 
 	return 0;
@@ -468,7 +468,7 @@ static int do_deactivate_lv(char *resource, unsigned char command, unsigned char
 		return 0;	/* We don't need to do anything */
 	}
 
-	if (!lv_deactivate(cmd, resource))
+	if (!lv_deactivate(cmd, resource, NULL))
 		return EIO;
 
 	if (command & LCK_CLUSTER_VG) {
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 7f3d7c6..15e684a 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1615,9 +1615,10 @@ static int _preload_detached_lv(struct cmd_context *cmd, struct logical_volume *
 }
 
 static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
-		       struct lv_activate_opts *laopts, int error_if_not_suspended)
+		       struct lv_activate_opts *laopts, int error_if_not_suspended,
+	               struct logical_volume *lv)
 {
-	struct logical_volume *lv = NULL, *lv_pre = NULL, *pvmove_lv = NULL;
+	struct logical_volume *lv_pre = NULL, *pvmove_lv = NULL, *lv_to_free = NULL;
 	struct lv_list *lvl_pre;
 	struct seg_list *sl;
         struct lv_segment *snap_seg;
@@ -1628,7 +1629,7 @@ static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
 	if (!activation())
 		return 1;
 
-	if (!(lv = lv_from_lvid(cmd, lvid_s, 0)))
+	if (!lv && !(lv_to_free = lv = lv_from_lvid(cmd, lvid_s, 0)))
 		goto_out;
 
 	/* Use precommitted metadata if present */
@@ -1769,9 +1770,9 @@ static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
 out:
 	if (lv_pre)
 		release_vg(lv_pre->vg);
-	if (lv) {
-		lv_release_replicator_vgs(lv);
-		release_vg(lv->vg);
+	if (lv_to_free) {
+		lv_release_replicator_vgs(lv_to_free);
+		release_vg(lv_to_free->vg);
 	}
 
 	return r;
@@ -1783,14 +1784,14 @@ out:
  *
  * Returns success if the device is not active
  */
-int lv_suspend_if_active(struct cmd_context *cmd, const char *lvid_s, unsigned origin_only, unsigned exclusive)
+int lv_suspend_if_active(struct cmd_context *cmd, const char *lvid_s, unsigned origin_only, unsigned exclusive, struct logical_volume *lv)
 {
 	struct lv_activate_opts laopts = {
 		.origin_only = origin_only,
 		.exclusive = exclusive
 	};
 
-	return _lv_suspend(cmd, lvid_s, &laopts, 0);
+	return _lv_suspend(cmd, lvid_s, &laopts, 0, lv);
 }
 
 /* No longer used */
@@ -1802,9 +1803,10 @@ int lv_suspend(struct cmd_context *cmd, const char *lvid_s)
 ***********/
 
 static int _lv_resume(struct cmd_context *cmd, const char *lvid_s,
-		      struct lv_activate_opts *laopts, int error_if_not_active)
+		      struct lv_activate_opts *laopts, int error_if_not_active,
+	              struct logical_volume *lv)
 {
-	struct logical_volume *lv;
+	struct logical_volume *lv_to_free = NULL;
 	struct lvinfo info;
 	int r = 0;
 	int messages_only = 0;
@@ -1812,7 +1814,7 @@ static int _lv_resume(struct cmd_context *cmd, const char *lvid_s,
 	if (!activation())
 		return 1;
 
-	if (!(lv = lv_from_lvid(cmd, lvid_s, 0)))
+	if (!lv && !(lv_to_free = lv = lv_from_lvid(cmd, lvid_s, 0)))
 		goto_out;
 
 	if (lv_is_thin_pool(lv) && laopts->origin_only)
@@ -1857,8 +1859,8 @@ static int _lv_resume(struct cmd_context *cmd, const char *lvid_s,
 
 	r = 1;
 out:
-	if (lv)
-		release_vg(lv->vg);
+	if (lv_to_free)
+		release_vg(lv_to_free->vg);
 
 	return r;
 }
@@ -1875,7 +1877,7 @@ out:
  */
 int lv_resume_if_active(struct cmd_context *cmd, const char *lvid_s,
 			unsigned origin_only, unsigned exclusive,
-			unsigned revert)
+			unsigned revert, struct logical_volume *lv)
 {
 	struct lv_activate_opts laopts = {
 		.origin_only = origin_only,
@@ -1883,14 +1885,14 @@ int lv_resume_if_active(struct cmd_context *cmd, const char *lvid_s,
 		.revert = revert
 	};
 
-	return _lv_resume(cmd, lvid_s, &laopts, 0);
+	return _lv_resume(cmd, lvid_s, &laopts, 0, lv);
 }
 
-int lv_resume(struct cmd_context *cmd, const char *lvid_s, unsigned origin_only)
+int lv_resume(struct cmd_context *cmd, const char *lvid_s, unsigned origin_only, struct logical_volume *lv)
 {
 	struct lv_activate_opts laopts = { .origin_only = origin_only, };
 
-	return _lv_resume(cmd, lvid_s, &laopts, 1);
+	return _lv_resume(cmd, lvid_s, &laopts, 1, lv);
 }
 
 static int _lv_has_open_snapshots(struct logical_volume *lv)
@@ -1916,16 +1918,16 @@ static int _lv_has_open_snapshots(struct logical_volume *lv)
 	return r;
 }
 
-int lv_deactivate(struct cmd_context *cmd, const char *lvid_s)
+int lv_deactivate(struct cmd_context *cmd, const char *lvid_s, struct logical_volume *lv)
 {
-	struct logical_volume *lv;
+	struct logical_volume *lv_to_free = NULL;
 	struct lvinfo info;
 	int r = 0;
 
 	if (!activation())
 		return 1;
 
-	if (!(lv = lv_from_lvid(cmd, lvid_s, 0)))
+	if (!lv && !(lv_to_free = lv = lv_from_lvid(cmd, lvid_s, 0)))
 		goto out;
 
 	if (test_mode()) {
@@ -1967,9 +1969,9 @@ int lv_deactivate(struct cmd_context *cmd, const char *lvid_s)
 	if (!lv_info(cmd, lv, 0, &info, 0, 0) || info.exists)
 		r = 0;
 out:
-	if (lv) {
-		lv_release_replicator_vgs(lv);
-		release_vg(lv->vg);
+	if (lv_to_free) {
+		lv_release_replicator_vgs(lv_to_free);
+		release_vg(lv_to_free->vg);
 	}
 
 	return r;
@@ -1977,9 +1979,9 @@ out:
 
 /* Test if LV passes filter */
 int lv_activation_filter(struct cmd_context *cmd, const char *lvid_s,
-			 int *activate_lv)
+			 int *activate_lv, struct logical_volume *lv)
 {
-	struct logical_volume *lv;
+	struct logical_volume *lv_to_free = NULL;
 	int r = 0;
 
 	if (!activation()) {
@@ -1987,7 +1989,7 @@ int lv_activation_filter(struct cmd_context *cmd, const char *lvid_s,
 		return 1;
 	}
 
-	if (!(lv = lv_from_lvid(cmd, lvid_s, 0)))
+	if (!lv && !(lv_to_free = lv = lv_from_lvid(cmd, lvid_s, 0)))
 		goto out;
 
 	if (!_passes_activation_filter(cmd, lv)) {
@@ -1998,23 +2000,24 @@ int lv_activation_filter(struct cmd_context *cmd, const char *lvid_s,
 		*activate_lv = 1;
 	r = 1;
 out:
-	if (lv)
-		release_vg(lv->vg);
+	if (lv_to_free)
+		release_vg(lv_to_free->vg);
 
 	return r;
 }
 
 static int _lv_activate(struct cmd_context *cmd, const char *lvid_s,
-			struct lv_activate_opts *laopts, int filter)
+			struct lv_activate_opts *laopts, int filter,
+	                struct logical_volume *lv)
 {
-	struct logical_volume *lv;
+	struct logical_volume *lv_to_free = NULL;
 	struct lvinfo info;
 	int r = 0;
 
 	if (!activation())
 		return 1;
 
-	if (!(lv = lv_from_lvid(cmd, lvid_s, 0)))
+	if (!lv && !(lv_to_free = lv = lv_from_lvid(cmd, lvid_s, 0)))
 		goto out;
 
 	if (filter && !_passes_activation_filter(cmd, lv)) {
@@ -2074,31 +2077,31 @@ static int _lv_activate(struct cmd_context *cmd, const char *lvid_s,
 		stack;
 
 out:
-	if (lv) {
-		lv_release_replicator_vgs(lv);
-		release_vg(lv->vg);
+	if (lv_to_free) {
+		lv_release_replicator_vgs(lv_to_free);
+		release_vg(lv_to_free->vg);
 	}
 
 	return r;
 }
 
 /* Activate LV */
-int lv_activate(struct cmd_context *cmd, const char *lvid_s, int exclusive)
+int lv_activate(struct cmd_context *cmd, const char *lvid_s, int exclusive, struct logical_volume *lv)
 {
 	struct lv_activate_opts laopts = { .exclusive = exclusive };
 
-	if (!_lv_activate(cmd, lvid_s, &laopts, 0))
+	if (!_lv_activate(cmd, lvid_s, &laopts, 0, lv))
 		return_0;
 
 	return 1;
 }
 
 /* Activate LV only if it passes filter */
-int lv_activate_with_filter(struct cmd_context *cmd, const char *lvid_s, int exclusive)
+int lv_activate_with_filter(struct cmd_context *cmd, const char *lvid_s, int exclusive, struct logical_volume *lv)
 {
 	struct lv_activate_opts laopts = { .exclusive = exclusive };
 
-	if (!_lv_activate(cmd, lvid_s, &laopts, 1))
+	if (!_lv_activate(cmd, lvid_s, &laopts, 1, lv))
 		return_0;
 
 	return 1;
diff --git a/lib/activate/activate.h b/lib/activate/activate.h
index e80115a..7446bec 100644
--- a/lib/activate/activate.h
+++ b/lib/activate/activate.h
@@ -75,14 +75,14 @@ void activation_release(void);
 void activation_exit(void);
 
 /* int lv_suspend(struct cmd_context *cmd, const char *lvid_s); */
-int lv_suspend_if_active(struct cmd_context *cmd, const char *lvid_s, unsigned origin_only, unsigned exclusive);
-int lv_resume(struct cmd_context *cmd, const char *lvid_s, unsigned origin_only);
+int lv_suspend_if_active(struct cmd_context *cmd, const char *lvid_s, unsigned origin_only, unsigned exclusive, struct logical_volume *lv);
+int lv_resume(struct cmd_context *cmd, const char *lvid_s, unsigned origin_only, struct logical_volume *lv);
 int lv_resume_if_active(struct cmd_context *cmd, const char *lvid_s,
-			unsigned origin_only, unsigned exclusive, unsigned revert);
-int lv_activate(struct cmd_context *cmd, const char *lvid_s, int exclusive);
+			unsigned origin_only, unsigned exclusive, unsigned revert, struct logical_volume *lv);
+int lv_activate(struct cmd_context *cmd, const char *lvid_s, int exclusive, struct logical_volume *lv);
 int lv_activate_with_filter(struct cmd_context *cmd, const char *lvid_s,
-			    int exclusive);
-int lv_deactivate(struct cmd_context *cmd, const char *lvid_s);
+			    int exclusive, struct logical_volume *lv);
+int lv_deactivate(struct cmd_context *cmd, const char *lvid_s, struct logical_volume *lv);
 
 int lv_mknodes(struct cmd_context *cmd, const struct logical_volume *lv);
 
@@ -101,7 +101,7 @@ int lv_check_not_in_use(struct cmd_context *cmd, struct logical_volume *lv,
  * Returns 1 if activate_lv has been set: 1 = activate; 0 = don't.
  */
 int lv_activation_filter(struct cmd_context *cmd, const char *lvid_s,
-			 int *activate_lv);
+			 int *activate_lv, struct logical_volume *lv);
 /*
  * Checks against the auto_activation_volume_list and
  * returns 1 if the LV should be activated, 0 otherwise.
diff --git a/lib/locking/cluster_locking.c b/lib/locking/cluster_locking.c
index 3169f0d..1350d18 100644
--- a/lib/locking/cluster_locking.c
+++ b/lib/locking/cluster_locking.c
@@ -403,9 +403,9 @@ static int _lock_for_cluster(struct cmd_context *cmd, unsigned char clvmd_cmd,
 /* API entry point for LVM */
 #ifdef CLUSTER_LOCKING_INTERNAL
 static int _lock_resource(struct cmd_context *cmd, const char *resource,
-			  uint32_t flags)
+			  uint32_t flags, struct logical_volume *lv __attribute__((unused)))
 #else
-int lock_resource(struct cmd_context *cmd, const char *resource, uint32_t flags)
+	int lock_resource(struct cmd_context *cmd, const char *resource, uint32_t flags, struct logical_volume *lv __attribute__((unused)))
 #endif
 {
 	char lockname[PATH_MAX];
diff --git a/lib/locking/external_locking.c b/lib/locking/external_locking.c
index 1076174..d5c39d7 100644
--- a/lib/locking/external_locking.c
+++ b/lib/locking/external_locking.c
@@ -31,7 +31,7 @@ static int (*_init_fn) (int type, struct dm_config_tree * cft,
 static int (*_lock_query_fn) (const char *resource, int *mode) = NULL;
 
 static int _lock_resource(struct cmd_context *cmd, const char *resource,
-			  uint32_t flags)
+			  uint32_t flags, struct logical_volume *lv __attribute__((unused)))
 {
 	if (!_lock_fn)
 		return 0;
diff --git a/lib/locking/file_locking.c b/lib/locking/file_locking.c
index 4711fa2..1f2468d 100644
--- a/lib/locking/file_locking.c
+++ b/lib/locking/file_locking.c
@@ -254,7 +254,7 @@ static int _lock_file(const char *file, uint32_t flags)
 }
 
 static int _file_lock_resource(struct cmd_context *cmd, const char *resource,
-			       uint32_t flags)
+			       uint32_t flags, struct logical_volume *lv)
 {
 	char lockfile[PATH_MAX];
 	unsigned origin_only = (flags & LCK_ORIGIN_ONLY) ? 1 : 0;
@@ -295,17 +295,17 @@ static int _file_lock_resource(struct cmd_context *cmd, const char *resource,
 		switch (flags & LCK_TYPE_MASK) {
 		case LCK_UNLOCK:
 			log_very_verbose("Unlocking LV %s%s%s", resource, origin_only ? " without snapshots" : "", revert ? " (reverting)" : "");
-			if (!lv_resume_if_active(cmd, resource, origin_only, 0, revert))
+			if (!lv_resume_if_active(cmd, resource, origin_only, 0, revert, NULL))
 				return 0;
 			break;
 		case LCK_NULL:
 			log_very_verbose("Locking LV %s (NL)", resource);
-			if (!lv_deactivate(cmd, resource))
+			if (!lv_deactivate(cmd, resource, NULL))
 				return 0;
 			break;
 		case LCK_READ:
 			log_very_verbose("Locking LV %s (R)", resource);
-			if (!lv_activate_with_filter(cmd, resource, 0))
+			if (!lv_activate_with_filter(cmd, resource, 0, NULL))
 				return 0;
 			break;
 		case LCK_PREAD:
@@ -313,12 +313,12 @@ static int _file_lock_resource(struct cmd_context *cmd, const char *resource,
 			break;
 		case LCK_WRITE:
 			log_very_verbose("Locking LV %s (W)%s", resource, origin_only ? " without snapshots" : "");
-			if (!lv_suspend_if_active(cmd, resource, origin_only, 0))
+			if (!lv_suspend_if_active(cmd, resource, origin_only, 0, NULL))
 				return 0;
 			break;
 		case LCK_EXCL:
 			log_very_verbose("Locking LV %s (EX)", resource);
-			if (!lv_activate_with_filter(cmd, resource, 1))
+			if (!lv_activate_with_filter(cmd, resource, 1, NULL))
 				return 0;
 			break;
 		default:
diff --git a/lib/locking/locking.c b/lib/locking/locking.c
index 63f946f..044570f 100644
--- a/lib/locking/locking.c
+++ b/lib/locking/locking.c
@@ -352,7 +352,7 @@ int check_lvm1_vg_inactive(struct cmd_context *cmd, const char *vgname)
  * FIXME This should become VG uuid.
  */
 static int _lock_vol(struct cmd_context *cmd, const char *resource,
-		     uint32_t flags, lv_operation_t lv_op)
+		     uint32_t flags, lv_operation_t lv_op, struct logical_volume *lv)
 {
 	uint32_t lck_type = flags & LCK_TYPE_MASK;
 	uint32_t lck_scope = flags & LCK_SCOPE_MASK;
@@ -379,7 +379,7 @@ static int _lock_vol(struct cmd_context *cmd, const char *resource,
 		return 0;
 	}
 
-	if ((ret = _locking.lock_resource(cmd, resource, flags))) {
+	if ((ret = _locking.lock_resource(cmd, resource, flags, lv))) {
 		if (lck_scope == LCK_VG && !(flags & LCK_CACHE)) {
 			if (lck_type != LCK_UNLOCK)
 				lvmcache_lock_vgname(resource, lck_type == LCK_READ);
@@ -403,7 +403,7 @@ static int _lock_vol(struct cmd_context *cmd, const char *resource,
 	return ret;
 }
 
-int lock_vol(struct cmd_context *cmd, const char *vol, uint32_t flags)
+int lock_vol(struct cmd_context *cmd, const char *vol, uint32_t flags, struct logical_volume *lv)
 {
 	char resource[258] __attribute__((aligned(8)));
 	lv_operation_t lv_op;
@@ -457,7 +457,7 @@ int lock_vol(struct cmd_context *cmd, const char *vol, uint32_t flags)
 	strncpy(resource, vol, sizeof(resource) - 1);
 	resource[sizeof(resource) - 1] = '\0';
 
-	if (!_lock_vol(cmd, resource, flags, lv_op))
+	if (!_lock_vol(cmd, resource, flags, lv_op, lv))
 		return_0;
 
 	/*
@@ -468,7 +468,7 @@ int lock_vol(struct cmd_context *cmd, const char *vol, uint32_t flags)
 	    (flags & (LCK_CACHE | LCK_HOLD)))
 		return 1;
 
-	if (!_lock_vol(cmd, resource, (flags & ~LCK_TYPE_MASK) | LCK_UNLOCK, lv_op))
+	if (!_lock_vol(cmd, resource, (flags & ~LCK_TYPE_MASK) | LCK_UNLOCK, lv_op, lv))
 		return_0;
 
 	return 1;
@@ -626,12 +626,12 @@ int sync_local_dev_names(struct cmd_context* cmd)
 {
 	memlock_unlock(cmd);
 
-	return lock_vol(cmd, VG_SYNC_NAMES, LCK_VG_SYNC_LOCAL);
+	return lock_vol(cmd, VG_SYNC_NAMES, LCK_VG_SYNC_LOCAL, NULL);
 }
 
 int sync_dev_names(struct cmd_context* cmd)
 {
 	memlock_unlock(cmd);
 
-	return lock_vol(cmd, VG_SYNC_NAMES, LCK_VG_SYNC);
+	return lock_vol(cmd, VG_SYNC_NAMES, LCK_VG_SYNC, NULL);
 }
diff --git a/lib/locking/locking.h b/lib/locking/locking.h
index 23c312d..aa42138 100644
--- a/lib/locking/locking.h
+++ b/lib/locking/locking.h
@@ -19,6 +19,8 @@
 #include "uuid.h"
 #include "config.h"
 
+struct logical_volume;
+
 int init_locking(int type, struct cmd_context *cmd, int suppress_messages);
 void fin_locking(void);
 void reset_locking(void);
@@ -46,7 +48,7 @@ int remote_lock_held(const char *vol, int *exclusive);
  *   Lock/unlock an individual logical volume
  *   char *vol holds lvid
  */
-int lock_vol(struct cmd_context *cmd, const char *vol, uint32_t flags);
+int lock_vol(struct cmd_context *cmd, const char *vol, uint32_t flags, struct logical_volume *lv);
 
 /*
  * Internal locking representation.
@@ -156,14 +158,14 @@ int check_lvm1_vg_inactive(struct cmd_context *cmd, const char *vgname);
 
 #define lock_lv_vol(cmd, lv, flags)	\
 	(find_replicator_vgs((lv)) ? \
-		lock_vol(cmd, (lv)->lvid.s, flags | LCK_LV_CLUSTERED(lv)) : \
+		 lock_vol(cmd, (lv)->lvid.s, flags | LCK_LV_CLUSTERED(lv), lv) :	\
 		0)
 
 #define unlock_vg(cmd, vol)	\
 	do { \
 		if (is_real_vg(vol)) \
 			sync_dev_names(cmd); \
-		(void) lock_vol(cmd, vol, LCK_VG_UNLOCK); \
+		(void) lock_vol(cmd, vol, LCK_VG_UNLOCK, NULL);	\
 	} while (0)
 #define unlock_and_release_vg(cmd, vg, vol) \
 	do { \
@@ -192,13 +194,13 @@ int activate_lv_excl(struct cmd_context *cmd, struct logical_volume *lv);
 #define deactivate_lv_local(cmd, lv)	\
 	lock_lv_vol(cmd, lv, LCK_LV_DEACTIVATE | LCK_LOCAL)
 #define drop_cached_metadata(vg)	\
-	lock_vol((vg)->cmd, (vg)->name, LCK_VG_DROP_CACHE)
+	lock_vol((vg)->cmd, (vg)->name, LCK_VG_DROP_CACHE, NULL)
 #define remote_commit_cached_metadata(vg)	\
-	lock_vol((vg)->cmd, (vg)->name, LCK_VG_COMMIT)
+	lock_vol((vg)->cmd, (vg)->name, LCK_VG_COMMIT, NULL)
 #define remote_revert_cached_metadata(vg)	\
-	lock_vol((vg)->cmd, (vg)->name, LCK_VG_REVERT)
+	lock_vol((vg)->cmd, (vg)->name, LCK_VG_REVERT, NULL)
 #define remote_backup_metadata(vg)	\
-	lock_vol((vg)->cmd, (vg)->name, LCK_VG_BACKUP)
+	lock_vol((vg)->cmd, (vg)->name, LCK_VG_BACKUP, NULL)
 
 int sync_local_dev_names(struct cmd_context* cmd);
 int sync_dev_names(struct cmd_context* cmd);
diff --git a/lib/locking/locking_types.h b/lib/locking/locking_types.h
index 53c7016..3009490 100644
--- a/lib/locking/locking_types.h
+++ b/lib/locking/locking_types.h
@@ -17,7 +17,7 @@
 #include "config.h"
 
 typedef int (*lock_resource_fn) (struct cmd_context * cmd, const char *resource,
-				 uint32_t flags);
+				 uint32_t flags, struct logical_volume *lv);
 typedef int (*query_resource_fn) (const char *resource, int *mode);
 
 typedef void (*fin_lock_fn) (void);
diff --git a/lib/locking/no_locking.c b/lib/locking/no_locking.c
index 53a5948..715cc10 100644
--- a/lib/locking/no_locking.c
+++ b/lib/locking/no_locking.c
@@ -34,7 +34,7 @@ static void _no_reset_locking(void)
 }
 
 static int _no_lock_resource(struct cmd_context *cmd, const char *resource,
-			     uint32_t flags)
+			     uint32_t flags, struct logical_volume *lv)
 {
 	switch (flags & LCK_SCOPE_MASK) {
 	case LCK_VG:
@@ -44,15 +44,15 @@ static int _no_lock_resource(struct cmd_context *cmd, const char *resource,
 	case LCK_LV:
 		switch (flags & LCK_TYPE_MASK) {
 		case LCK_NULL:
-			return lv_deactivate(cmd, resource);
+			return lv_deactivate(cmd, resource, lv);
 		case LCK_UNLOCK:
-			return lv_resume_if_active(cmd, resource, (flags & LCK_ORIGIN_ONLY) ? 1: 0, 0, (flags & LCK_REVERT) ? 1 : 0);
+			return lv_resume_if_active(cmd, resource, (flags & LCK_ORIGIN_ONLY) ? 1: 0, 0, (flags & LCK_REVERT) ? 1 : 0, NULL);
 		case LCK_READ:
-			return lv_activate_with_filter(cmd, resource, 0);
+			return lv_activate_with_filter(cmd, resource, 0, NULL);
 		case LCK_WRITE:
-			return lv_suspend_if_active(cmd, resource, (flags & LCK_ORIGIN_ONLY) ? 1 : 0, 0);
+			return lv_suspend_if_active(cmd, resource, (flags & LCK_ORIGIN_ONLY) ? 1 : 0, 0, lv);
 		case LCK_EXCL:
-			return lv_activate_with_filter(cmd, resource, 1);
+			return lv_activate_with_filter(cmd, resource, 1, NULL);
 		default:
 			break;
 		}
@@ -68,7 +68,7 @@ static int _no_lock_resource(struct cmd_context *cmd, const char *resource,
 
 static int _readonly_lock_resource(struct cmd_context *cmd,
 				   const char *resource,
-				   uint32_t flags)
+				   uint32_t flags, struct logical_volume *lv)
 {
 	if ((flags & LCK_TYPE_MASK) == LCK_WRITE &&
 	    (flags & LCK_SCOPE_MASK) == LCK_VG &&
@@ -79,7 +79,7 @@ static int _readonly_lock_resource(struct cmd_context *cmd,
 		return 0;
 	}
 
-	return _no_lock_resource(cmd, resource, flags);
+	return _no_lock_resource(cmd, resource, flags, lv);
 }
 
 int init_no_locking(struct locking_type *locking, struct cmd_context *cmd __attribute__((unused)),
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 6cee8d5..922e82e 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -562,7 +562,7 @@ int vg_remove(struct volume_group *vg)
 	struct pv_list *pvl;
 	int ret = 1;
 
-	if (!lock_vol(vg->cmd, VG_ORPHANS, LCK_VG_WRITE)) {
+	if (!lock_vol(vg->cmd, VG_ORPHANS, LCK_VG_WRITE, NULL)) {
 		log_error("Can't get lock for orphan PVs");
 		return 0;
 	}
@@ -3971,7 +3971,7 @@ static struct volume_group *_recover_vg(struct cmd_context *cmd,
 
 	dev_close_all();
 
-	if (!lock_vol(cmd, vg_name, LCK_VG_WRITE))
+	if (!lock_vol(cmd, vg_name, LCK_VG_WRITE, NULL))
 		return_NULL;
 
 	if (!(vg = vg_read_internal(cmd, vg_name, vgid, 1, &consistent)))
@@ -4018,7 +4018,7 @@ static struct volume_group *_vg_lock_and_read(struct cmd_context *cmd, const cha
 	already_locked = lvmcache_vgname_is_locked(vg_name);
 
 	if (!already_locked && !(misc_flags & READ_WITHOUT_LOCK) &&
-	    !lock_vol(cmd, vg_name, lock_flags)) {
+	    !lock_vol(cmd, vg_name, lock_flags, NULL)) {
 		log_error("Can't get lock for %s", vg_name);
 		return _vg_make_handle(cmd, vg, FAILED_LOCKING);
 	}
@@ -4173,7 +4173,7 @@ uint32_t vg_read_error(struct volume_group *vg_handle)
  */
 uint32_t vg_lock_newname(struct cmd_context *cmd, const char *vgname)
 {
-	if (!lock_vol(cmd, vgname, LCK_VG_WRITE)) {
+	if (!lock_vol(cmd, vgname, LCK_VG_WRITE, NULL)) {
 		return FAILED_LOCKING;
 	}
 
diff --git a/liblvm/lvm_vg.c b/liblvm/lvm_vg.c
index 405a91a..b090b84 100644
--- a/liblvm/lvm_vg.c
+++ b/liblvm/lvm_vg.c
@@ -73,7 +73,7 @@ int lvm_vg_extend(vg_t vg, const char *device)
 	if (!vg_check_write_mode(vg))
 		return -1;
 
-	if (!lock_vol(vg->cmd, VG_ORPHANS, LCK_VG_WRITE)) {
+	if (!lock_vol(vg->cmd, VG_ORPHANS, LCK_VG_WRITE, NULL)) {
 		log_error("Can't get lock for orphan PVs");
 		return -1;
 	}
@@ -131,7 +131,7 @@ int lvm_vg_write(vg_t vg)
 	}
 
 	if (! dm_list_empty(&vg->removed_pvs)) {
-		if (!lock_vol(vg->cmd, VG_ORPHANS, LCK_VG_WRITE)) {
+		if (!lock_vol(vg->cmd, VG_ORPHANS, LCK_VG_WRITE, NULL)) {
 			log_error("Can't get lock for orphan PVs");
 			return 0;
 		}
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 718f49c..46f996a 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2503,7 +2503,7 @@ static int lvconvert_merge_single(struct cmd_context *cmd, struct logical_volume
 					  lp->wait_completion);
 
 		/* use LCK_VG_WRITE to match lvconvert()'s READ_FOR_UPDATE */
-		if (!lock_vol(cmd, vg_name, LCK_VG_WRITE)) {
+		if (!lock_vol(cmd, vg_name, LCK_VG_WRITE, NULL)) {
 			log_error("ABORTING: Can't relock VG for %s "
 				  "after polling finished", vg_name);
 			ret = ECMD_FAILED;
diff --git a/tools/pvchange.c b/tools/pvchange.c
index 1458e92..d2a3d9b 100644
--- a/tools/pvchange.c
+++ b/tools/pvchange.c
@@ -219,7 +219,7 @@ int pvchange(struct cmd_context *cmd, int argc, char **argv)
 		 * take the lock here, pvs with 0 mdas in a non-orphan VG will
 		 * be processed twice.
 		 */
-		if (!lock_vol(cmd, VG_GLOBAL, LCK_VG_WRITE)) {
+		if (!lock_vol(cmd, VG_GLOBAL, LCK_VG_WRITE, NULL)) {
 			log_error("Unable to obtain global lock.");
 			return ECMD_FAILED;
 		}
diff --git a/tools/pvcreate.c b/tools/pvcreate.c
index 91562d2..d3703b4 100644
--- a/tools/pvcreate.c
+++ b/tools/pvcreate.c
@@ -108,7 +108,7 @@ int pvcreate(struct cmd_context *cmd, int argc, char **argv)
 	}
 
 	for (i = 0; i < argc; i++) {
-		if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE)) {
+		if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE, NULL)) {
 			log_error("Can't get lock for orphan PVs");
 			return ECMD_FAILED;
 		}
diff --git a/tools/pvremove.c b/tools/pvremove.c
index 823c069..cbbf6e2 100644
--- a/tools/pvremove.c
+++ b/tools/pvremove.c
@@ -101,7 +101,7 @@ static int pvremove_single(struct cmd_context *cmd, const char *pv_name,
 	struct device *dev;
 	int ret = ECMD_FAILED;
 
-	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE)) {
+	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE, NULL)) {
 		log_error("Can't get lock for orphan PVs");
 		return ECMD_FAILED;
 	}
diff --git a/tools/pvresize.c b/tools/pvresize.c
index 2f0693a..26959e8 100644
--- a/tools/pvresize.c
+++ b/tools/pvresize.c
@@ -38,7 +38,7 @@ static int _pv_resize_single(struct cmd_context *cmd,
 	int vg_needs_pv_write = 0;
 
 	if (is_orphan_vg(vg_name)) {
-		if (!lock_vol(cmd, vg_name, LCK_VG_WRITE)) {
+		if (!lock_vol(cmd, vg_name, LCK_VG_WRITE, NULL)) {
 			log_error("Can't get lock for orphans");
 			return 0;
 		}
diff --git a/tools/pvscan.c b/tools/pvscan.c
index 7c55faa..12b9a2d 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -170,7 +170,7 @@ static int _pvscan_lvmetad(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 	
-	if (!lock_vol(cmd, VG_GLOBAL, LCK_VG_READ)) {
+	if (!lock_vol(cmd, VG_GLOBAL, LCK_VG_READ, NULL)) {
 		log_error("Unable to obtain global lock.");
 		return ECMD_FAILED;
 	}
@@ -288,7 +288,7 @@ int pvscan(struct cmd_context *cmd, int argc, char **argv)
 			  arg_count(cmd, exported_ARG) ?
 			  "of exported volume group(s)" : "in no volume group");
 
-	if (!lock_vol(cmd, VG_GLOBAL, LCK_VG_WRITE)) {
+	if (!lock_vol(cmd, VG_GLOBAL, LCK_VG_WRITE, NULL)) {
 		log_error("Unable to obtain global lock.");
 		return ECMD_FAILED;
 	}
diff --git a/tools/toollib.c b/tools/toollib.c
index 6e004f3..b238a61 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -712,7 +712,7 @@ int process_each_pv(struct cmd_context *cmd, int argc, char **argv,
 
 	dm_list_init(&tags);
 
-	if (lock_global && !lock_vol(cmd, VG_GLOBAL, LCK_VG_READ)) {
+	if (lock_global && !lock_vol(cmd, VG_GLOBAL, LCK_VG_READ, NULL)) {
 		log_error("Unable to obtain global lock.");
 		return ECMD_FAILED;
 	}
diff --git a/tools/vgcfgrestore.c b/tools/vgcfgrestore.c
index 20ca16b..618fa7e 100644
--- a/tools/vgcfgrestore.c
+++ b/tools/vgcfgrestore.c
@@ -47,12 +47,12 @@ int vgcfgrestore(struct cmd_context *cmd, int argc, char **argv)
 
 	lvmcache_seed_infos_from_lvmetad(cmd);
 
-	if (!lock_vol(cmd, vg_name, LCK_VG_WRITE)) {
+	if (!lock_vol(cmd, vg_name, LCK_VG_WRITE, NULL)) {
 		log_error("Unable to lock volume group %s", vg_name);
 		return ECMD_FAILED;
 	}
 
-	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE)) {
+	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE, NULL)) {
 		log_error("Unable to lock orphans");
 		unlock_vg(cmd, vg_name);
 		return ECMD_FAILED;
diff --git a/tools/vgcreate.c b/tools/vgcreate.c
index 8ce7803..9be9416 100644
--- a/tools/vgcreate.c
+++ b/tools/vgcreate.c
@@ -70,7 +70,7 @@ int vgcreate(struct cmd_context *cmd, int argc, char **argv)
 	    !vg_set_mda_copies(vg, vp_new.vgmetadatacopies))
 		goto bad_orphan;
 
-	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE)) {
+	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE, NULL)) {
 		log_error("Can't get lock for orphan PVs");
 		goto bad_orphan;
 	}
diff --git a/tools/vgextend.c b/tools/vgextend.c
index 93d55a0..1f482b4 100644
--- a/tools/vgextend.c
+++ b/tools/vgextend.c
@@ -95,7 +95,7 @@ int vgextend(struct cmd_context *cmd, int argc, char **argv)
 			goto bad;
 		}
 	} else { /* no --restore, normal vgextend */
-		if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE)) {
+		if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE, NULL)) {
 			log_error("Can't get lock for orphan PVs");
 			unlock_and_release_vg(cmd, vg, vg_name);
 			return ECMD_FAILED;
diff --git a/tools/vgreduce.c b/tools/vgreduce.c
index c068b26..8803899 100644
--- a/tools/vgreduce.c
+++ b/tools/vgreduce.c
@@ -146,7 +146,7 @@ static int _vgreduce_single(struct cmd_context *cmd, struct volume_group *vg,
 		return ECMD_FAILED;
 	}
 
-	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE)) {
+	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE, NULL)) {
 		log_error("Can't get lock for orphan PVs");
 		return ECMD_FAILED;
 	}
diff --git a/tools/vgscan.c b/tools/vgscan.c
index 99124ef..baf25b0 100644
--- a/tools/vgscan.c
+++ b/tools/vgscan.c
@@ -37,7 +37,7 @@ int vgscan(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
-	if (!lock_vol(cmd, VG_GLOBAL, LCK_VG_WRITE)) {
+	if (!lock_vol(cmd, VG_GLOBAL, LCK_VG_WRITE, NULL)) {
 		log_error("Unable to obtain global lock.");
 		return ECMD_FAILED;
 	}


