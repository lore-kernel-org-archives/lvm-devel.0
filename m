From: David Teigland <teigland@fedoraproject.org>
Date: Thu,  8 Oct 2015 15:42:28 +0000 (UTC)
Subject: master - vgcreate: improve error message for multiple lock managers
Message-ID: <20151008154228.1D90E6026A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d99dd4086da5ab2ed7bf02a8711d4a4998fe2b31
Commit:        d99dd4086da5ab2ed7bf02a8711d4a4998fe2b31
Parent:        09981afc1c03e1d79109c483b3d19ae1c207e158
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Oct 8 10:38:35 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Oct 8 10:41:13 2015 -0500

vgcreate: improve error message for multiple lock managers

If 'vgcreate --shared' finds both sanlock and dlm are running,
print a more accurate error message:
"Found multiple lock managers, select one with --lock-type."

When neither is running, we still print:
"Failed to detect a running lock manager to select lock type."
---
 lib/locking/lvmlockd.c |    5 ++---
 lib/locking/lvmlockd.h |    4 ++--
 tools/toollib.c        |    9 +++++++--
 3 files changed, 11 insertions(+), 7 deletions(-)

diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index f741940..2bc34c8 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -2561,7 +2561,7 @@ int lockd_rename_vg_final(struct cmd_context *cmd, struct volume_group *vg, int
 	return 1;
 }
 
-const char *lockd_running_lock_type(struct cmd_context *cmd)
+const char *lockd_running_lock_type(struct cmd_context *cmd, int *found_multiple)
 {
 	daemon_reply reply;
 	const char *lock_type = NULL;
@@ -2583,10 +2583,9 @@ const char *lockd_running_lock_type(struct cmd_context *cmd)
 
 	switch (result) {
 	case -EXFULL:
-		log_error("lvmlockd found multiple lock managers, use --lock-type to select one.");
+		*found_multiple = 1;
 		break;
 	case -ENOLCK:
-		log_error("lvmlockd found no lock manager running.");
 		break;
 	case LOCK_TYPE_SANLOCK:
 		log_debug("lvmlockd found sanlock");
diff --git a/lib/locking/lvmlockd.h b/lib/locking/lvmlockd.h
index 7e6505d..8b282d8 100644
--- a/lib/locking/lvmlockd.h
+++ b/lib/locking/lvmlockd.h
@@ -89,7 +89,7 @@ int lockd_init_lv_args(struct cmd_context *cmd, struct volume_group *vg,
 int lockd_free_lv(struct cmd_context *cmd, struct volume_group *vg,
 		  const char *lv_name, struct id *lv_id, const char *lock_args);
 
-const char *lockd_running_lock_type(struct cmd_context *cmd);
+const char *lockd_running_lock_type(struct cmd_context *cmd, int *found_multiple);
 
 int handle_sanlock_lv(struct cmd_context *cmd, struct volume_group *vg);
 
@@ -223,7 +223,7 @@ static inline int lockd_free_lv(struct cmd_context *cmd, struct volume_group *vg
 	return 1;
 }
 
-static inline const char *lockd_running_lock_type(struct cmd_context *cmd)
+static inline const char *lockd_running_lock_type(struct cmd_context *cmd, int *found_multiple)
 {
 	log_error("Using a shared lock type requires lvmlockd.");
 	return NULL;
diff --git a/tools/toollib.c b/tools/toollib.c
index cf5e236..dfb2b87 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -931,9 +931,14 @@ int vgcreate_params_set_from_args(struct cmd_context *cmd,
 		}
 
 	} else if (arg_is_set(cmd, shared_ARG)) {
+		int found_multiple = 0;
+
 		if (use_lvmlockd) {
-			if (!(lock_type = lockd_running_lock_type(cmd))) {
-				log_error("Failed to detect a running lock manager to select lock type.");
+			if (!(lock_type = lockd_running_lock_type(cmd, &found_multiple))) {
+				if (found_multiple)
+					log_error("Found multiple lock managers, select one with --lock-type.");
+				else
+					log_error("Failed to detect a running lock manager to select lock type.");
 				return 0;
 			}
 


