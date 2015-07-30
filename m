From: David Teigland <teigland@fedoraproject.org>
Date: Thu, 30 Jul 2015 17:07:18 +0000 (UTC)
Subject: master - lvmlockd: create sanlock lv large enough for existing lvs
Message-ID: <20150730170718.7C28560DF8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b40ccdd57cc0d57a71e584600c1025e649dc6d8a
Commit:        b40ccdd57cc0d57a71e584600c1025e649dc6d8a
Parent:        78135c24b419d070a238f1660408c843707c7cbb
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Jul 30 12:04:31 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Jul 30 12:04:31 2015 -0500

lvmlockd: create sanlock lv large enough for existing lvs

When changing an existing VG to lock_type sanlock,
make the sanlock lv large enough to hold all the
locks needed for existing LVs.
---
 lib/locking/lvmlockd.c |   20 ++++++++++++++------
 lib/locking/lvmlockd.h |    4 ++--
 tools/vgchange.c       |   17 ++++++++++++-----
 tools/vgcreate.c       |    2 +-
 4 files changed, 29 insertions(+), 14 deletions(-)

diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index 66c6615..15abd54 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -320,9 +320,6 @@ static int _lockd_request(struct cmd_context *cmd,
 
 /*
  * Eventually add an option to specify which pv the lvmlock lv should be placed on.
- * FIXME: when converting a VG from lock_type none to sanlock, we need to count
- * the number of existing LVs to ensure that the new sanlock_lv is large enough
- * for all of them that need locks.
  */
 
 static int _create_sanlock_lv(struct cmd_context *cmd, struct volume_group *vg,
@@ -559,7 +556,7 @@ out:
 	return ret;
 }
 
-static int _init_vg_sanlock(struct cmd_context *cmd, struct volume_group *vg)
+static int _init_vg_sanlock(struct cmd_context *cmd, struct volume_group *vg, int lv_lock_count)
 {
 	daemon_reply reply;
 	const char *reply_str;
@@ -588,7 +585,18 @@ static int _init_vg_sanlock(struct cmd_context *cmd, struct volume_group *vg)
 	 * LV, then activates the lvmlock LV.  The lvmlock LV must be active
 	 * before we ask lvmlockd to initialize the VG because sanlock needs
 	 * to initialize leases on the lvmlock LV.
+	 *
+	 * When converting an existing VG to sanlock, the sanlock lv needs to
+	 * be large enough to hold leases for all existing lvs needing locks.
+	 * One sanlock lease uses 1MB/8MB for 512/4K sector size devices, so
+	 * increase the initial size by 1MB/8MB for each existing lv.
+	 * FIXME: we don't know what sector size the pv will have, so we
+	 * multiply by 8 (MB) unnecessarily when the sector size is 512.
 	 */
+
+	if (lv_lock_count)
+		extend_mb += (lv_lock_count * 8);
+
 	if (!_create_sanlock_lv(cmd, vg, LOCKD_SANLOCK_LV_NAME, extend_mb)) {
 		log_error("Failed to create internal lv.");
 		return 0;
@@ -816,7 +824,7 @@ static void _forget_vg_name(struct cmd_context *cmd, struct volume_group *vg)
 /* vgcreate */
 
 int lockd_init_vg(struct cmd_context *cmd, struct volume_group *vg,
-		  const char *lock_type)
+		  const char *lock_type, int lv_lock_count)
 {
 	switch (get_lock_type_from_string(lock_type)) {
 	case LOCK_TYPE_NONE:
@@ -827,7 +835,7 @@ int lockd_init_vg(struct cmd_context *cmd, struct volume_group *vg,
 	case LOCK_TYPE_DLM:
 		return _init_vg_dlm(cmd, vg);
 	case LOCK_TYPE_SANLOCK:
-		return _init_vg_sanlock(cmd, vg);
+		return _init_vg_sanlock(cmd, vg, lv_lock_count);
 	default:
 		log_error("Unknown lock_type.");
 		return 0;
diff --git a/lib/locking/lvmlockd.h b/lib/locking/lvmlockd.h
index f141635..b0edeae 100644
--- a/lib/locking/lvmlockd.h
+++ b/lib/locking/lvmlockd.h
@@ -54,7 +54,7 @@ void lvmlockd_disconnect(void);
 
 /* vgcreate/vgremove use init/free */
 
-int lockd_init_vg(struct cmd_context *cmd, struct volume_group *vg, const char *lock_type);
+int lockd_init_vg(struct cmd_context *cmd, struct volume_group *vg, const char *lock_type, int lv_lock_count);
 int lockd_free_vg_before(struct cmd_context *cmd, struct volume_group *vg);
 void lockd_free_vg_final(struct cmd_context *cmd, struct volume_group *vg);
 
@@ -125,7 +125,7 @@ static inline int lvmlockd_use(void)
 	return 0;
 }
 
-static inline int lockd_init_vg(struct cmd_context *cmd, struct volume_group *vg, const char *lock_type)
+static inline int lockd_init_vg(struct cmd_context *cmd, struct volume_group *vg, const char *lock_type, int lv_lock_count)
 {
 	return 1;
 }
diff --git a/tools/vgchange.c b/tools/vgchange.c
index 824fd91..a163cf5 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -526,6 +526,7 @@ static int _vgchange_locktype(struct cmd_context *cmd,
 	const char *lock_type = arg_str_value(cmd, locktype_ARG, NULL);
 	struct lv_list *lvl;
 	struct logical_volume *lv;
+	int lv_lock_count = 0;
 
 	/*
 	 * This is a special/forced exception to change the lock type to none.
@@ -654,11 +655,17 @@ static int _vgchange_locktype(struct cmd_context *cmd,
 		 * For lock_type dlm, lockd_init_vg() will do a single
 		 * vg_write() that sets lock_type, sets lock_args, clears
 		 * system_id, and sets all LV lock_args to dlm.
+		 * For lock_type sanlock, lockd_init_vg() needs to know
+		 * how many LV locks are needed so that it can make the
+		 * sanlock lv large enough.
 		 */
-		if (!strcmp(lock_type, "dlm")) {
-			dm_list_iterate_items(lvl, &vg->lvs) {
-				lv = lvl->lv;
-				if (lockd_lv_uses_lock(lv))
+		dm_list_iterate_items(lvl, &vg->lvs) {
+			lv = lvl->lv;
+
+			if (lockd_lv_uses_lock(lv)) {
+				lv_lock_count++;
+
+				if (!strcmp(lock_type, "dlm"))
 					lv->lock_args = "dlm";
 			}
 		}
@@ -673,7 +680,7 @@ static int _vgchange_locktype(struct cmd_context *cmd,
 
 		vg->system_id = NULL;
 
-		if (!lockd_init_vg(cmd, vg, lock_type)) {
+		if (!lockd_init_vg(cmd, vg, lock_type, lv_lock_count)) {
 			log_error("Failed to initialize lock args for lock type %s", lock_type);
 			return 0;
 		}
diff --git a/tools/vgcreate.c b/tools/vgcreate.c
index 20ba4aa..67b593d 100644
--- a/tools/vgcreate.c
+++ b/tools/vgcreate.c
@@ -131,7 +131,7 @@ int vgcreate(struct cmd_context *cmd, int argc, char **argv)
 	 * a local VG.  lockd_init_vg() then writes the VG a second time with
 	 * both lock_type and lock_args set.
 	 */
-	if (!lockd_init_vg(cmd, vg, vp_new.lock_type)) {
+	if (!lockd_init_vg(cmd, vg, vp_new.lock_type, 0)) {
 		log_error("Failed to initialize lock args for lock type %s",
 			  vp_new.lock_type);
 		vg_remove_pvs(vg);


