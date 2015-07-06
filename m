From: David Teigland <teigland@fedoraproject.org>
Date: Mon,  6 Jul 2015 16:45:03 +0000 (UTC)
Subject: master - config: rename lock_retries lvmlockd_lock_retries
Message-ID: <20150706164503.DDCA66100F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=114744cee1488112f51c49cbe71366ce8bfbd3ea
Commit:        114744cee1488112f51c49cbe71366ce8bfbd3ea
Parent:        dfe3eb12d074eb25063ce62a913825cfbc90a37b
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Jul 6 11:19:17 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Jul 6 11:44:28 2015 -0500

config: rename lock_retries lvmlockd_lock_retries

Because it only applies to lvmlockd requests, but
sounded too general.
---
 lib/config/config_settings.h |    2 +-
 lib/config/defaults.h        |    2 +-
 lib/locking/lvmlockd.c       |    6 +++---
 man/lvmlockd.8.in            |    8 ++++----
 4 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 5d042c9..16fd0bd 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -834,7 +834,7 @@ cfg(global_use_lvmetad_CFG, "use_lvmetad", global_CFG_SECTION, 0, CFG_TYPE_BOOL,
 cfg(global_use_lvmlockd_CFG, "use_lvmlockd", global_CFG_SECTION, 0, CFG_TYPE_BOOL, 0, vsn(2, 2, 124), NULL, 0, NULL,
 	"Use lvmlockd for locking among hosts using LVM on shared storage.\n")
 
-cfg(global_lock_retries_CFG, "lock_retries", global_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_LOCK_RETRIES, vsn(2, 2, 124), NULL, 0, NULL,
+cfg(global_lvmlockd_lock_retries_CFG, "lvmlockd_lock_retries", global_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_LVMLOCKD_LOCK_RETRIES, vsn(2, 2, 124), NULL, 0, NULL,
 	"Retry lvmlockd lock requests this many times.\n")
 
 cfg(global_sanlock_lv_extend_CFG, "sanlock_lv_extend", global_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_SANLOCK_LV_EXTEND_MB, vsn(2, 2, 124), NULL, 0, NULL,
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 6d3fec0..491c64b 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -51,7 +51,7 @@
 #define DEFAULT_FALLBACK_TO_LOCAL_LOCKING 1
 #define DEFAULT_FALLBACK_TO_CLUSTERED_LOCKING 1
 #define DEFAULT_WAIT_FOR_LOCKS 1
-#define DEFAULT_LOCK_RETRIES 3
+#define DEFAULT_LVMLOCKD_LOCK_RETRIES 3
 #define DEFAULT_PRIORITISE_WRITE_LOCKS 1
 #define DEFAULT_USE_MLOCKALL 0
 #define DEFAULT_METADATA_READ_ONLY 0
diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index 5d0cc07..f80ed75 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -1200,7 +1200,7 @@ int lockd_gl_create(struct cmd_context *cmd, const char *def_mode, const char *v
 	}
 
 	if (result == -EAGAIN) {
-		if (retries < find_config_tree_int(cmd, global_lock_retries_CFG, NULL)) {
+		if (retries < find_config_tree_int(cmd, global_lvmlockd_lock_retries_CFG, NULL)) {
 			log_warn("Retrying %s global lock", mode);
 			sleep(1);
 			retries++;
@@ -1467,7 +1467,7 @@ int lockd_gl(struct cmd_context *cmd, const char *def_mode, uint32_t flags)
 	}
 
 	if (result == -EAGAIN) {
-		if (retries < find_config_tree_int(cmd, global_lock_retries_CFG, NULL)) {
+		if (retries < find_config_tree_int(cmd, global_lvmlockd_lock_retries_CFG, NULL)) {
 			log_warn("Retrying %s global lock", mode);
 			sleep(1);
 			retries++;
@@ -1710,7 +1710,7 @@ int lockd_vg(struct cmd_context *cmd, const char *vg_name, const char *def_mode,
 	}
 
 	if (result == -EAGAIN) {
-		if (retries < find_config_tree_int(cmd, global_lock_retries_CFG, NULL)) {
+		if (retries < find_config_tree_int(cmd, global_lvmlockd_lock_retries_CFG, NULL)) {
 			log_warn("Retrying %s lock on VG %s", mode, vg_name);
 			sleep(1);
 			retries++;
diff --git a/man/lvmlockd.8.in b/man/lvmlockd.8.in
index 79a3218..3710df6 100644
--- a/man/lvmlockd.8.in
+++ b/man/lvmlockd.8.in
@@ -442,9 +442,9 @@ only while an LVM command is running.
 If a request for a GL or VG lock fails due to a lock conflict with another
 host, lvmlockd automatically retries for a short time before returning a
 failure to the LVM command.  The LVM command will then retry the entire
-lock request a number of times specified by global/lock_retries before
-failing.  If a request for an LV lock fails due to a lock conflict, the
-command fails immediately.
+lock request a number of times specified by global/lvmlockd_lock_retries
+before failing.  If a request for an LV lock fails due to a lock conflict,
+the command fails immediately.
 
 
 .SS sanlock global lock
@@ -740,7 +740,7 @@ vgchange --lock-stop.
 .IP \[bu] 2
 Long lasting lock contention among hosts may result in a command giving up
 and failing.  The number of lock retries can be adjusted with
-global/lock_retries.
+global/lvmlockd_lock_retries.
 
 .IP \[bu] 2
 The reporting options locktype and lockargs can be used to view lockd VG


