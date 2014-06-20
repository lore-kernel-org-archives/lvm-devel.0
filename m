From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 20 Jun 2014 12:28:42 +0000 (UTC)
Subject: master - locking: Introduce LCK_ACTIVATION.
Message-ID: <20140620122842.3E14D60919@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=78533f72d30f6e840f66e0aae89126ef139c1f2c
Commit:        78533f72d30f6e840f66e0aae89126ef139c1f2c
Parent:        f29ae59a4d88ff0f76cfd84a6061222ae178438b
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Jun 20 13:24:02 2014 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Jun 20 13:24:02 2014 +0100

locking: Introduce LCK_ACTIVATION.

Take a local file lock to prevent concurrent activation/deactivation of LVs.
Thin/cache types and an extension for cluster support are excluded for
now.

'lvchange -ay $lv' and 'lvchange -an $lv' should no longer cause trouble
if issued concurrently: the new lock should make sure they
activate/deactivate $lv one-after-the-other, instead of overlapping.

(If anyone wants to experiment with the cluster patch, please get in touch.)
---
 WHATS_NEW                  |    1 +
 lib/locking/file_locking.c |   10 +++++++
 lib/locking/locking.c      |    2 +
 lib/locking/locking.h      |   65 ++++++++++++++++++++++++++++++++++++-------
 lib/locking/no_locking.c   |    2 +
 5 files changed, 69 insertions(+), 11 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 44cef74..c2b443c 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.107 - 
 ==================================
+  Introduce LCK_ACTIVATION to avoid concurrent activation of basic LV types.
   Fix open_count test for lvchange --refresh or mirrors and raids.
   Update pvs,vgs,lvs and lvm man page for selection support.
   Add -S/--select to lvm devtypes for report selection.
diff --git a/lib/locking/file_locking.c b/lib/locking/file_locking.c
index d332101..e6def3f 100644
--- a/lib/locking/file_locking.c
+++ b/lib/locking/file_locking.c
@@ -49,6 +49,16 @@ static int _file_lock_resource(struct cmd_context *cmd, const char *resource,
 	unsigned revert = (flags & LCK_REVERT) ? 1 : 0;
 
 	switch (flags & LCK_SCOPE_MASK) {
+	case LCK_ACTIVATION:
+		if (dm_snprintf(lockfile, sizeof(lockfile),
+				"%s/A_%s", _lock_dir, resource + 1) < 0) {
+			log_error("Too long locking filename %s/A_%s.", _lock_dir, resource + 1);
+			return 0;
+		}
+
+		if (!lock_file(lockfile, flags))
+			return_0;
+		break;
 	case LCK_VG:
 		/* Skip cache refresh for VG_GLOBAL - the caller handles it */
 		if (strcmp(resource, VG_GLOBAL))
diff --git a/lib/locking/locking.c b/lib/locking/locking.c
index 673713a..9432f84 100644
--- a/lib/locking/locking.c
+++ b/lib/locking/locking.c
@@ -318,6 +318,8 @@ int lock_vol(struct cmd_context *cmd, const char *vol, uint32_t flags, struct lo
 	}
 
 	switch (flags & LCK_SCOPE_MASK) {
+	case LCK_ACTIVATION:
+		break;
 	case LCK_VG:
 		if (!_blocking_supported)
 			flags |= LCK_NONBLOCK;
diff --git a/lib/locking/locking.h b/lib/locking/locking.h
index 0945aa0..284ce7a 100644
--- a/lib/locking/locking.h
+++ b/lib/locking/locking.h
@@ -86,9 +86,10 @@ int check_lvm1_vg_inactive(struct cmd_context *cmd, const char *vgname);
 /*
  * Lock scope
  */
-#define LCK_SCOPE_MASK	0x00000008U
-#define LCK_VG		0x00000000U
-#define LCK_LV		0x00000008U
+#define LCK_SCOPE_MASK	0x00001008U
+#define LCK_VG		0x00000000U	/* Volume Group */
+#define LCK_LV		0x00000008U	/* Logical Volume */
+#define LCK_ACTIVATION  0x00001000U	/* Activation */
 
 /*
  * Lock bits.
@@ -131,6 +132,9 @@ int check_lvm1_vg_inactive(struct cmd_context *cmd, const char *vgname);
  */
 #define LCK_NONE		(LCK_VG | LCK_NULL)
 
+#define LCK_ACTIVATE_LOCK	(LCK_ACTIVATION | LCK_WRITE | LCK_HOLD)
+#define LCK_ACTIVATE_UNLOCK	(LCK_ACTIVATION | LCK_UNLOCK)
+
 #define LCK_VG_READ		(LCK_VG | LCK_READ | LCK_HOLD)
 #define LCK_VG_WRITE		(LCK_VG | LCK_WRITE | LCK_HOLD)
 #define LCK_VG_UNLOCK		(LCK_VG | LCK_UNLOCK)
@@ -161,6 +165,33 @@ int check_lvm1_vg_inactive(struct cmd_context *cmd, const char *vgname);
 		 lock_vol(cmd, (lv)->lvid.s, flags | LCK_LV_CLUSTERED(lv), lv) :	\
 		0)
 
+/*
+ * Activation locks are wrapped around activation commands that have to
+ * be processed atomically one-at-a-time.
+ * If a VG WRITE lock is held, an activation lock is redundant.
+ *
+ * FIXME Test and support this for thin and cache types.
+ * FIXME Add cluster support.
+ */
+#define lv_supports_activation_locking(lv) (!vg_is_clustered((lv)->vg) && !lv_is_thin_type(lv) && !lv_is_cache_type(lv))
+#define lock_activation(cmd, lv)	(vg_write_lock_held() && lv_supports_activation_locking(lv) ? 1 : lock_vol(cmd, (lv)->lvid.s, LCK_ACTIVATE_LOCK, lv))
+#define unlock_activation(cmd, lv)	(vg_write_lock_held() && lv_supports_activation_locking(lv) ? 1 : lock_vol(cmd, (lv)->lvid.s, LCK_ACTIVATE_UNLOCK, lv))
+
+/*
+ * Place temporary exclusive 'activation' lock around an LV locking operation
+ * to serialise it.
+ */
+#define lock_lv_vol_serially(cmd, lv, flags) \
+({ \
+	int rr = 0; \
+\
+	if (lock_activation((cmd), (lv))) { \
+		rr = lock_lv_vol((cmd), (lv), (flags)); \
+		unlock_activation((cmd), (lv)); \
+	} \
+	rr; \
+})
+
 #define unlock_vg(cmd, vol)	\
 	do { \
 		if (is_real_vg(vol)) \
@@ -173,16 +204,28 @@ int check_lvm1_vg_inactive(struct cmd_context *cmd, const char *vgname);
 		release_vg(vg); \
 	} while (0)
 
-#define resume_lv(cmd, lv)	lock_lv_vol(cmd, lv, LCK_LV_RESUME)
+#define resume_lv(cmd, lv)	\
+({ \
+	int rr = lock_lv_vol((cmd), (lv), LCK_LV_RESUME); \
+	unlock_activation((cmd), (lv)); \
+	rr; \
+})
 #define resume_lv_origin(cmd, lv)	lock_lv_vol(cmd, lv, LCK_LV_RESUME | LCK_ORIGIN_ONLY)
-#define revert_lv(cmd, lv)	lock_lv_vol(cmd, lv, LCK_LV_RESUME | LCK_REVERT)
-#define suspend_lv(cmd, lv)	lock_lv_vol(cmd, lv, LCK_LV_SUSPEND | LCK_HOLD)
+#define revert_lv(cmd, lv)	\
+({ \
+	int rr = lock_lv_vol((cmd), (lv), LCK_LV_RESUME | LCK_REVERT); \
+\
+	unlock_activation((cmd), (lv)); \
+	rr; \
+})
+#define suspend_lv(cmd, lv)	\
+	(lock_activation((cmd), (lv)) ? lock_lv_vol((cmd), (lv), LCK_LV_SUSPEND | LCK_HOLD) : 0)
 #define suspend_lv_origin(cmd, lv)	lock_lv_vol(cmd, lv, LCK_LV_SUSPEND | LCK_HOLD | LCK_ORIGIN_ONLY)
-#define deactivate_lv(cmd, lv)	lock_lv_vol(cmd, lv, LCK_LV_DEACTIVATE)
+#define deactivate_lv(cmd, lv)	lock_lv_vol_serially(cmd, lv, LCK_LV_DEACTIVATE)
 
-#define activate_lv(cmd, lv)	lock_lv_vol(cmd, lv, LCK_LV_ACTIVATE | LCK_HOLD)
+#define activate_lv(cmd, lv)	lock_lv_vol_serially(cmd, lv, LCK_LV_ACTIVATE | LCK_HOLD)
 #define activate_lv_excl_local(cmd, lv)	\
-				lock_lv_vol(cmd, lv, LCK_LV_EXCLUSIVE | LCK_HOLD | LCK_LOCAL)
+				lock_lv_vol_serially(cmd, lv, LCK_LV_EXCLUSIVE | LCK_HOLD | LCK_LOCAL)
 #define activate_lv_excl_remote(cmd, lv)	\
 				lock_lv_vol(cmd, lv, LCK_LV_EXCLUSIVE | LCK_HOLD | LCK_REMOTE)
 
@@ -190,9 +233,9 @@ struct logical_volume;
 int activate_lv_excl(struct cmd_context *cmd, struct logical_volume *lv);
 
 #define activate_lv_local(cmd, lv)	\
-	lock_lv_vol(cmd, lv, LCK_LV_ACTIVATE | LCK_HOLD | LCK_LOCAL)
+	lock_lv_vol_serially(cmd, lv, LCK_LV_ACTIVATE | LCK_HOLD | LCK_LOCAL)
 #define deactivate_lv_local(cmd, lv)	\
-	lock_lv_vol(cmd, lv, LCK_LV_DEACTIVATE | LCK_LOCAL)
+	lock_lv_vol_serially(cmd, lv, LCK_LV_DEACTIVATE | LCK_LOCAL)
 #define drop_cached_metadata(vg)	\
 	lock_vol((vg)->cmd, (vg)->name, LCK_VG_DROP_CACHE, NULL)
 #define remote_commit_cached_metadata(vg)	\
diff --git a/lib/locking/no_locking.c b/lib/locking/no_locking.c
index f7718be..ab95933 100644
--- a/lib/locking/no_locking.c
+++ b/lib/locking/no_locking.c
@@ -37,6 +37,8 @@ static int _no_lock_resource(struct cmd_context *cmd, const char *resource,
 			     uint32_t flags, struct logical_volume *lv)
 {
 	switch (flags & LCK_SCOPE_MASK) {
+	case LCK_ACTIVATION:
+		break;
 	case LCK_VG:
 		if (!strcmp(resource, VG_SYNC_NAMES))
 			fs_unlock();


