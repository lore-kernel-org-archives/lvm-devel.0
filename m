From: Leo Yan <leo.yan@linaro.org>
Date: Sun, 25 Apr 2021 10:22:41 +0800
Subject: [LVM2 RFCv1 5/5] tools: Add support for "idm" lock type
In-Reply-To: <20210425022241.5055-1-leo.yan@linaro.org>
References: <20210425022241.5055-1-leo.yan@linaro.org>
Message-ID: <20210425022241.5055-6-leo.yan@linaro.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch is to update the comment and code to support "idm" lock type
which is used for LVM toolkit.

Signed-off-by: Leo Yan <leo.yan@linaro.org>
---
 tools/lvconvert.c |  2 ++
 tools/toollib.c   | 11 ++++++-----
 2 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 4c159b01e..1f2178ce5 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -3415,6 +3415,8 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 				pool_lv->lock_args = "pending";
 			else if (!strcmp(vg->lock_type, "dlm"))
 				pool_lv->lock_args = "dlm";
+			else if (!strcmp(vg->lock_type, "idm"))
+				pool_lv->lock_args = "idm";
 			/* The lock_args will be set in vg_write(). */
 		}
 	}
diff --git a/tools/toollib.c b/tools/toollib.c
index 67fbbdaa0..cda6d74f3 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -591,15 +591,15 @@ int vgcreate_params_set_from_args(struct cmd_context *cmd,
 	 * new VG, and is it compatible with current lvm.conf settings.
 	 *
 	 * The end result is to set vp_new->lock_type to:
-	 * none | clvm | dlm | sanlock.
+	 * none | clvm | dlm | sanlock | idm.
 	 *
 	 * If 'vgcreate --lock-type <arg>' is set, the answer is given
-	 * directly by <arg> which is one of none|clvm|dlm|sanlock.
+	 * directly by <arg> which is one of none|clvm|dlm|sanlock|idm.
 	 *
 	 * 'vgcreate --clustered y' is the way to create clvm VGs.
 	 *
 	 * 'vgcreate --shared' is the way to create lockd VGs.
-	 * lock_type of sanlock or dlm is selected based on
+	 * lock_type of sanlock, dlm or idm is selected based on
 	 * which lock manager is running.
 	 *
 	 *
@@ -646,7 +646,7 @@ int vgcreate_params_set_from_args(struct cmd_context *cmd,
 	 * - lvmlockd is used
 	 * - VGs with CLUSTERED set are ignored (requires clvmd)
 	 * - VGs with lockd type can be used
-	 * - vgcreate can create new VGs with lock_type sanlock or dlm
+	 * - vgcreate can create new VGs with lock_type sanlock, dlm or idm
 	 * - 'vgcreate --clustered y' fails
 	 * - 'vgcreate --shared' works
 	 * - 'vgcreate' (neither option) creates a local VG
@@ -658,7 +658,7 @@ int vgcreate_params_set_from_args(struct cmd_context *cmd,
 		lock_type = arg_str_value(cmd, locktype_ARG, "");
 
 		if (arg_is_set(cmd, shared_ARG) && !is_lockd_type(lock_type)) {
-			log_error("The --shared option requires lock type sanlock or dlm.");
+			log_error("The --shared option requires lock type sanlock, dlm or idm.");
 			return 0;
 		}
 
@@ -697,6 +697,7 @@ int vgcreate_params_set_from_args(struct cmd_context *cmd,
 
 	case LOCK_TYPE_SANLOCK:
 	case LOCK_TYPE_DLM:
+	case LOCK_TYPE_IDM:
 		if (!use_lvmlockd) {
 			log_error("Using a shared lock type requires lvmlockd.");
 			return 0;
-- 
2.25.1


