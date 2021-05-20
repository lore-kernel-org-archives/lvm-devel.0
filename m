From: David Teigland <teigland@sourceware.org>
Date: Thu, 20 May 2021 21:42:02 +0000 (GMT)
Subject: main - tools: Add support for "idm" lock type
Message-ID: <20210520214202.07FA93987C21@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8b904dc71143f4dc7553026f783aa1c0b1d4b954
Commit:        8b904dc71143f4dc7553026f783aa1c0b1d4b954
Parent:        affe1af148d5d939ffad7bde2ad51b0f386a44b7
Author:        Leo Yan <leo.yan@linaro.org>
AuthorDate:    Fri May 7 10:25:16 2021 +0800
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu May 20 16:01:05 2021 -0500

tools: Add support for "idm" lock type

This patch is to update the comment and code to support "idm" lock type
which is used for LVM toolkit.

Signed-off-by: Leo Yan <leo.yan@linaro.org>
---
 tools/lvconvert.c |  2 ++
 tools/toollib.c   | 11 ++++++-----
 2 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 8dd8a15c4..71f7a7627 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -3416,6 +3416,8 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 				pool_lv->lock_args = "pending";
 			else if (!strcmp(vg->lock_type, "dlm"))
 				pool_lv->lock_args = "dlm";
+			else if (!strcmp(vg->lock_type, "idm"))
+				pool_lv->lock_args = "idm";
 			/* The lock_args will be set in vg_write(). */
 		}
 	}
diff --git a/tools/toollib.c b/tools/toollib.c
index 07f065322..f337f9fcf 100644
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


