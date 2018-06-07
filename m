From: Joe Thornber <thornber@sourceware.org>
Date: Thu, 7 Jun 2018 11:21:52 -0400
Subject: master - Remove more clvm code
Message-ID: <201806071521.w57FLqST013152@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e4d9099e19591a7f3ad546c180b59a601e0d03da
Commit:        e4d9099e19591a7f3ad546c180b59a601e0d03da
Parent:        d154dd66382d1bab4c227f6b3aaa12b6ccbb491f
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jun 5 11:39:07 2018 -0500
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Thu Jun 7 16:17:04 2018 +0100

Remove more clvm code

---
 lib/format_text/archiver.c |    4 ----
 lib/locking/locking.h      |   15 +++++----------
 lib/metadata/metadata.c    |    7 -------
 3 files changed, 5 insertions(+), 21 deletions(-)

diff --git a/lib/format_text/archiver.c b/lib/format_text/archiver.c
index 9d7be95..ab80117 100644
--- a/lib/format_text/archiver.c
+++ b/lib/format_text/archiver.c
@@ -275,10 +275,6 @@ int backup(struct volume_group *vg)
 	if (is_orphan_vg(vg->name))
 		return 1;
 
-	if (vg_is_clustered(vg))
-		if (!remote_backup_metadata(vg))
-			stack;
-
 	return backup_locally(vg);
 }
 
diff --git a/lib/locking/locking.h b/lib/locking/locking.h
index 8322bae..8b2bced 100644
--- a/lib/locking/locking.h
+++ b/lib/locking/locking.h
@@ -163,10 +163,7 @@ int check_lvm1_vg_inactive(struct cmd_context *cmd, const char *vgname);
 
 #define LCK_MASK (LCK_TYPE_MASK | LCK_SCOPE_MASK)
 
-#define LCK_LV_CLUSTERED(lv)	\
-	(vg_is_clustered((lv)->vg) ? LCK_CLUSTER_VG : 0)
-
-#define lock_lv_vol(cmd, lv, flags) lock_vol(cmd, (lv)->lvid.s, flags | LCK_LV_CLUSTERED(lv), lv) 
+#define lock_lv_vol(cmd, lv, flags) lock_vol(cmd, (lv)->lvid.s, flags, lv) 
 
 /*
  * Activation locks are wrapped around activation commands that have to
@@ -180,7 +177,9 @@ int check_lvm1_vg_inactive(struct cmd_context *cmd, const char *vgname);
  */
 
 #define lv_type_requires_activation_lock(lv) ((lv_is_thin_type(lv) || lv_is_cache_type(lv) || lv_is_mirror_type(lv) || lv_is_raid_type(lv) || lv_is_origin(lv) || lv_is_snapshot(lv)) ? 1 : 0)
+
 #define lv_activation_lock_name(lv) (lv_type_requires_activation_lock(lv) ? (lv)->vg->name : (lv)->lvid.s)
+
 #define lv_requires_activation_lock_now(lv) ((!vg_write_lock_held() && (!vg_is_clustered((lv)->vg) || !lv_type_requires_activation_lock(lv))) ? 1 : 0)
 
 #define lock_activation(cmd, lv)	(lv_requires_activation_lock_now(lv) ? lock_vol(cmd, lv_activation_lock_name(lv), LCK_ACTIVATE_LOCK, lv) : 1)
@@ -246,16 +245,12 @@ int activate_lv_excl(struct cmd_context *cmd, const struct logical_volume *lv);
 
 #define activate_lv_local(cmd, lv)	\
 	lock_lv_vol_serially(cmd, lv, LCK_LV_ACTIVATE | LCK_HOLD | LCK_LOCAL)
+
 #define deactivate_lv_local(cmd, lv)	\
 	lock_lv_vol_serially(cmd, lv, LCK_LV_DEACTIVATE | LCK_LOCAL)
+
 #define drop_cached_metadata(vg)	\
 	lock_vol((vg)->cmd, (vg)->name, LCK_VG_DROP_CACHE, NULL)
-#define remote_commit_cached_metadata(vg)	\
-	lock_vol((vg)->cmd, (vg)->name, LCK_VG_COMMIT, NULL)
-#define remote_revert_cached_metadata(vg)	\
-	lock_vol((vg)->cmd, (vg)->name, LCK_VG_REVERT, NULL)
-#define remote_backup_metadata(vg)	\
-	lock_vol((vg)->cmd, (vg)->name, LCK_VG_BACKUP, NULL)
 
 int sync_local_dev_names(struct cmd_context* cmd);
 int sync_dev_names(struct cmd_context* cmd);
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 3f177b0..7c41d78 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3130,10 +3130,6 @@ int vg_commit(struct volume_group *vg)
 	set_vg_notify(vg->cmd);
 
 	if (cache_updated) {
-		/* Instruct remote nodes to upgrade cached metadata. */
-		if (!remote_commit_cached_metadata(vg))
-			stack; // FIXME: What should we do?
-
 		/*
 		 * We need to clear old_name after a successful commit.
 		 * The volume_group structure could be reused later.
@@ -3188,9 +3184,6 @@ void vg_revert(struct volume_group *vg)
 	if (!drop_cached_metadata(vg))
 		log_error("Attempt to drop cached metadata failed "
 			  "after reverted update for VG %s.", vg->name);
-
-	if (!remote_revert_cached_metadata(vg))
-		stack; // FIXME: What should we do?
 }
 
 static int _check_mda_in_use(struct metadata_area *mda, void *_in_use)


