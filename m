From: David Teigland <teigland@fedoraproject.org>
Date: Thu, 16 Jul 2015 20:42:29 +0000 (UTC)
Subject: master - lockd: fix error cases when built without lvmlockd
Message-ID: <20150716204229.60F4D611CF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=268f53ed0de087b0d42429a8b18c191f12a331cb
Commit:        268f53ed0de087b0d42429a8b18c191f12a331cb
Parent:        b93b85378d119e8396b0469574770cd097a988f0
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Jul 16 15:12:07 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Jul 16 15:22:06 2015 -0500

lockd: fix error cases when built without lvmlockd

When lvm is built without lvmlockd support, vgcreate using a
shared lock type would succeed and create a local VG (the
--shared option was effectively ignored).  Make it fail.

Fix the same issue when using vgchange to change a VG to a
shared lock type.

Make the error messages consistent.
---
 lib/locking/lvmlockd.h |    9 +++++++++
 tools/toollib.c        |    8 ++++----
 tools/vgchange.c       |   10 ++++++++++
 3 files changed, 23 insertions(+), 4 deletions(-)

diff --git a/lib/locking/lvmlockd.h b/lib/locking/lvmlockd.h
index 2bd2fcc..ffd6a99 100644
--- a/lib/locking/lvmlockd.h
+++ b/lib/locking/lvmlockd.h
@@ -167,6 +167,14 @@ static inline int lockd_start_wait(struct cmd_context *cmd)
 
 static inline int lockd_gl_create(struct cmd_context *cmd, const char *def_mode, const char *vg_lock_type)
 {
+	/*
+	 * When lvm is built without lvmlockd support, creating a VG with
+	 * a shared lock type should fail.
+	 */
+	if (is_lockd_type(vg_lock_type)) {
+		log_error("Using a shared lock type requires lvmlockd.");
+		return 0;
+	}
 	return 1;
 }
 
@@ -220,6 +228,7 @@ static inline int lockd_free_lv(struct cmd_context *cmd, struct volume_group *vg
 
 static inline const char *lockd_running_lock_type(struct cmd_context *cmd)
 {
+	log_error("Using a shared lock type requires lvmlockd.");
 	return NULL;
 }
 
diff --git a/tools/toollib.c b/tools/toollib.c
index 7bbe897..5d5e4d6 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -927,7 +927,7 @@ int vgcreate_params_set_from_args(struct cmd_context *cmd,
 	} else if (arg_is_set(cmd, shared_ARG)) {
 		if (use_lvmlockd) {
 			if (!(lock_type = lockd_running_lock_type(cmd))) {
-				log_error("Failed to detect a running lock manager to select lock_type.");
+				log_error("Failed to detect a running lock manager to select lock type.");
 				return 0;
 			}
 
@@ -936,7 +936,7 @@ int vgcreate_params_set_from_args(struct cmd_context *cmd,
 			return 0;
 
 		} else {
-			log_error("The --shared option requires lvmlockd (use_lvmlockd=1).");
+			log_error("Using a shared lock type requires lvmlockd.");
 			return 0;
 		}
 
@@ -961,13 +961,13 @@ int vgcreate_params_set_from_args(struct cmd_context *cmd,
 	case LOCK_TYPE_SANLOCK:
 	case LOCK_TYPE_DLM:
 		if (!use_lvmlockd) {
-			log_error("lock_type %s requires use_lvmlockd configuration setting", lock_type);
+			log_error("Using a shared lock type requires lvmlockd.");
 			return 0;
 		}
 		break;
 	case LOCK_TYPE_CLVM:
 		if (!use_clvmd) {
-			log_error("lock_type clvm requires locking_type 3 configuration setting");
+			log_error("Using clvm requires locking_type 3.");
 			return 0;
 		}
 		break;
diff --git a/tools/vgchange.c b/tools/vgchange.c
index 72a5c1e..9612222 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -1007,6 +1007,16 @@ static int _lockd_vgchange(struct cmd_context *cmd, int argc, char **argv)
 {
 	/* The default vg lock mode is ex, but these options only need sh. */
 
+	if (!lvmlockd_use() && arg_is_set(cmd, locktype_ARG)) {
+		log_error("Using lock type requires lvmlockd.");
+		return 0;
+	}
+
+	if (!lvmlockd_use() && (arg_is_set(cmd, lockstart_ARG) || arg_is_set(cmd, lockstop_ARG))) {
+		log_error("Using lock start and lock stop requires lvmlockd.");
+		return 0;
+	}
+
 	if (arg_is_set(cmd, activate_ARG) || arg_is_set(cmd, refresh_ARG))
 		cmd->lockd_vg_default_sh = 1;
 


