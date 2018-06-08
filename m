From: David Teigland <teigland@sourceware.org>
Date: Fri, 8 Jun 2018 13:19:44 -0400
Subject: master - Removing locking layer from sync_local_dev_names
Message-ID: <201806081719.w58HJiPD020951@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5e672df6aefd5b61129636994d8b5cdc05f651ea
Commit:        5e672df6aefd5b61129636994d8b5cdc05f651ea
Parent:        8266b7e951427de997b5b89d8ac8af8bf011c52e
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Jun 8 12:15:22 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Jun 8 12:18:57 2018 -0500

Removing locking layer from sync_local_dev_names

the indirection is not needed without clvm
---
 lib/locking/file_locking.c |    3 ---
 lib/locking/locking.c      |   11 ++---------
 lib/locking/locking.h      |    7 +------
 3 files changed, 3 insertions(+), 18 deletions(-)

diff --git a/lib/locking/file_locking.c b/lib/locking/file_locking.c
index 0bded0e..6b295e9 100644
--- a/lib/locking/file_locking.c
+++ b/lib/locking/file_locking.c
@@ -47,9 +47,6 @@ static int _file_lock_resource(struct cmd_context *cmd, const char *resource,
 
 	switch (flags & LCK_SCOPE_MASK) {
 	case LCK_VG:
-		if (!strcmp(resource, VG_SYNC_NAMES))
-			fs_unlock();
-
 		/* LCK_CACHE does not require a real lock */
 		if (flags & LCK_CACHE)
 			break;
diff --git a/lib/locking/locking.c b/lib/locking/locking.c
index 7e499bb..b6bd8d8 100644
--- a/lib/locking/locking.c
+++ b/lib/locking/locking.c
@@ -312,14 +312,7 @@ int locking_is_clustered(void)
 int sync_local_dev_names(struct cmd_context* cmd)
 {
 	memlock_unlock(cmd);
-
-	return lock_vol(cmd, VG_SYNC_NAMES, LCK_VG_SYNC_LOCAL, NULL);
-}
-
-int sync_dev_names(struct cmd_context* cmd)
-{
-	memlock_unlock(cmd);
-
-	return lock_vol(cmd, VG_SYNC_NAMES, LCK_VG_SYNC, NULL);
+	fs_unlock();
+	return 1;
 }
 
diff --git a/lib/locking/locking.h b/lib/locking/locking.h
index 96f7d86..f6a3859 100644
--- a/lib/locking/locking.h
+++ b/lib/locking/locking.h
@@ -129,7 +129,6 @@ int check_lvm1_vg_inactive(struct cmd_context *cmd, const char *vgname);
  */
 #define VG_ORPHANS	"#orphans"
 #define VG_GLOBAL	"#global"
-#define VG_SYNC_NAMES	"#sync_names"
 
 /*
  * Common combinations
@@ -147,16 +146,13 @@ int check_lvm1_vg_inactive(struct cmd_context *cmd, const char *vgname);
 
 #define LCK_VG_BACKUP		(LCK_VG | LCK_CACHE)
 
-#define LCK_VG_SYNC		(LCK_NONE | LCK_CACHE)
-#define LCK_VG_SYNC_LOCAL	(LCK_NONE | LCK_CACHE | LCK_LOCAL)
-
 #define LCK_MASK (LCK_TYPE_MASK | LCK_SCOPE_MASK)
 
 #define unlock_vg(cmd, vg, vol)	\
 	do { \
 		if (vg && !lvmetad_vg_update_finish(vg)) \
 			stack; \
-		if (is_real_vg(vol) && !sync_dev_names(cmd)) \
+		if (is_real_vg(vol) && !sync_local_dev_names(cmd)) \
 			stack; \
 		if (!lock_vol(cmd, vol, LCK_VG_UNLOCK, NULL)) \
 			stack;	\
@@ -171,7 +167,6 @@ int check_lvm1_vg_inactive(struct cmd_context *cmd, const char *vgname);
 	lock_vol((vg)->cmd, (vg)->name, LCK_VG_DROP_CACHE, NULL)
 
 int sync_local_dev_names(struct cmd_context* cmd);
-int sync_dev_names(struct cmd_context* cmd);
 
 /* Process list of LVs */
 struct volume_group;


