From: David Teigland <teigland@sourceware.org>
Date: Wed, 6 Jun 2018 17:37:14 -0400
Subject: master - Implement lock-override options without locking type
Message-ID: <201806062137.w56LbEkZ023071@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f2ff06d6756bb31779d16915c64361393054cfe7
Commit:        f2ff06d6756bb31779d16915c64361393054cfe7
Parent:        55521be2cbe28b0580fafafff6151cf4b6a219ea
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jun 6 16:31:59 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jun 6 16:31:59 2018 -0500

Implement lock-override options without locking type

The options: --nolocking, --readonly, --sysinit
override, or make exceptions to, the normal file locking
behavior.  Implement these by just checking for the
options in the file locking path instead of using
special locking types.
---
 lib/locking/file_locking.c  |    2 +-
 lib/locking/locking.c       |   58 +++++++++++++++++++++++++++++++++---------
 lib/locking/locking.h       |    2 +-
 lib/locking/locking_types.h |   18 +------------
 tools/lvmcmdline.c          |   52 +++++++++++++++++++-------------------
 5 files changed, 75 insertions(+), 57 deletions(-)

diff --git a/lib/locking/file_locking.c b/lib/locking/file_locking.c
index a60a3e5..0bded0e 100644
--- a/lib/locking/file_locking.c
+++ b/lib/locking/file_locking.c
@@ -92,7 +92,7 @@ int init_file_locking(struct locking_type *locking, struct cmd_context *cmd,
 	locking->lock_resource = _file_lock_resource;
 	locking->reset_locking = _reset_file_locking;
 	locking->fin_locking = _fin_file_locking;
-	locking->flags = 0;
+	locking->flags = LCK_FLOCK;
 
 	/* Get lockfile directory from config file */
 	locking_dir = find_config_tree_str(cmd, global_locking_dir_CFG, NULL);
diff --git a/lib/locking/locking.c b/lib/locking/locking.c
index 4b7d7eb..4c27a81 100644
--- a/lib/locking/locking.c
+++ b/lib/locking/locking.c
@@ -34,6 +34,8 @@ static struct locking_type _locking;
 static int _vg_lock_count = 0;		/* Number of locks held */
 static int _vg_write_lock_held = 0;	/* VG write lock held? */
 static int _blocking_supported = 0;
+static int _file_locking_readonly = 0;
+static int _file_locking_sysinit = 0;
 
 static void _unblock_signals(void)
 {
@@ -46,6 +48,10 @@ void reset_locking(void)
 {
 	int was_locked = _vg_lock_count;
 
+	/* file locking disabled */
+	if (!_locking.flags)
+		return;
+
 	_vg_lock_count = 0;
 	_vg_write_lock_held = 0;
 
@@ -82,21 +88,19 @@ static void _update_vg_lock_count(const char *resource, uint32_t flags)
  * Select a locking type
  * type: locking type; if < 0, then read config tree value
  */
-int init_locking(int type, struct cmd_context *cmd, int suppress_messages)
+int init_locking(struct cmd_context *cmd, int file_locking_sysinit, int file_locking_readonly)
 {
+	int suppress_messages = 0;
+
 	if (getenv("LVM_SUPPRESS_LOCKING_FAILURE_MESSAGES"))
 		suppress_messages = 1;
 
-	if (type < 0)
-		type = find_config_tree_int(cmd, global_locking_type_CFG, NULL);
+	if (file_locking_sysinit)
+		suppress_messages = 1;
 
 	_blocking_supported = find_config_tree_bool(cmd, global_wait_for_locks_CFG, NULL);
-
-	if (type != 1)
-		log_warn("WARNING: locking_type deprecated, using file locking.");
-
-	if (type == 3)
-		log_warn("WARNING: See lvmlockd(8) for information on using cluster/clvm VGs.");
+	_file_locking_readonly = file_locking_readonly;
+	_file_locking_sysinit = file_locking_sysinit;
 
 	log_very_verbose("%sFile-based locking selected.", _blocking_supported ? "" : "Non-blocking ");
 
@@ -108,6 +112,10 @@ int init_locking(int type, struct cmd_context *cmd, int suppress_messages)
 
 void fin_locking(void)
 {
+	/* file locking disabled */
+	if (!_locking.flags)
+		return;
+
 	_locking.fin_locking();
 }
 
@@ -135,10 +143,30 @@ static int _lock_vol(struct cmd_context *cmd, const char *resource, uint32_t fla
 		goto out;
 	}
 
-	if (cmd->metadata_read_only && lck_type == LCK_WRITE &&
+	if ((lck_type == LCK_WRITE) && (lck_scope == LCK_VG) && !(flags & LCK_CACHE) &&
 	    strcmp(resource, VG_GLOBAL)) {
-		log_error("Operation prohibited while global/metadata_read_only is set.");
-		goto out;
+
+		/* read only locking set in lvm.conf metadata_read_only */
+
+		if (cmd->metadata_read_only) {
+			log_error("Operation prohibited while global/metadata_read_only is set.");
+			goto out;
+		}
+
+		/* read only locking set with option --readonly */
+
+		if (_file_locking_readonly) {
+			log_error("Read-only locking specified. Write locks are prohibited.");
+			goto out;
+		}
+
+		/* read only locking (except activation) set with option --sysinit */
+		/* FIXME: sysinit is intended to allow activation, add that exception here */
+
+		if (_file_locking_sysinit) {
+			log_error("Read-only sysinit locking specified. Write locks are prohibited.");
+			goto out;
+		}
 	}
 
 	if ((ret = _locking.lock_resource(cmd, resource, flags, NULL))) {
@@ -169,6 +197,10 @@ int lock_vol(struct cmd_context *cmd, const char *vol, uint32_t flags, const str
 	char resource[258] __attribute__((aligned(8)));
 	int lck_type = flags & LCK_TYPE_MASK;
 
+	/* file locking disabled */
+	if (!_locking.flags)
+		return 1;
+
 	if (flags == LCK_NONE) {
 		log_debug_locking(INTERNAL_ERROR "%s: LCK_NONE lock requested", vol);
 		return 1;
@@ -240,7 +272,7 @@ int vg_write_lock_held(void)
 
 int locking_is_clustered(void)
 {
-	return (_locking.flags & LCK_CLUSTERED) ? 1 : 0;
+	return 0;
 }
 
 int sync_local_dev_names(struct cmd_context* cmd)
diff --git a/lib/locking/locking.h b/lib/locking/locking.h
index 6d7d8e8..422f1d8 100644
--- a/lib/locking/locking.h
+++ b/lib/locking/locking.h
@@ -21,7 +21,7 @@
 
 struct logical_volume;
 
-int init_locking(int type, struct cmd_context *cmd, int suppress_messages);
+int init_locking(struct cmd_context *cmd, int suppress_messages, int only_read_locks);
 void fin_locking(void);
 void reset_locking(void);
 int vg_write_lock_held(void);
diff --git a/lib/locking/locking_types.h b/lib/locking/locking_types.h
index 99aa964..5bb4fe4 100644
--- a/lib/locking/locking_types.h
+++ b/lib/locking/locking_types.h
@@ -23,12 +23,10 @@ typedef int (*query_resource_fn) (const char *resource, const char *node, int *m
 typedef void (*fin_lock_fn) (void);
 typedef void (*reset_lock_fn) (void);
 
-#define LCK_PRE_MEMLOCK			0x00000001	/* Is memlock() needed before calls? */
-#define LCK_CLUSTERED			0x00000002
-#define LCK_SUPPORTS_REMOTE_QUERIES	0x00000004
+#define LCK_FLOCK			0x00000001
 
 struct locking_type {
-	uint32_t flags;
+	uint32_t flags;   /* 0 means file locking is disabled */
 	lock_resource_fn lock_resource;
 	query_resource_fn query_resource;
 
@@ -36,17 +34,5 @@ struct locking_type {
 	fin_lock_fn fin_locking;
 };
 
-/*
- * Locking types
- */
-void init_no_locking(struct locking_type *locking, struct cmd_context *cmd,
-		     int suppress_messages);
-
-void init_dummy_locking(struct locking_type *locking, struct cmd_context *cmd,
-			int suppress_messages);
-
-int init_readonly_locking(struct locking_type *locking, struct cmd_context *cmd,
-			  int suppress_messages);
-
 int init_file_locking(struct locking_type *locking, struct cmd_context *cmd,
 		      int suppress_messages);
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 4f4e917..788f007 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -2734,6 +2734,9 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 	const char *reason = NULL;
 	int ret = 0;
 	int locking_type;
+	int file_locking_disable = 0;
+	int file_locking_sysinit = 0;
+	int file_locking_readonly = 0;
 	int monitoring;
 	char *arg_new, *arg;
 	int i;
@@ -2908,34 +2911,31 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 		goto out;
 	}
 
-	if (_cmd_no_meta_proc(cmd))
-		locking_type = 0;
-	else if (arg_is_set(cmd, readonly_ARG)) {
-		if (find_config_tree_bool(cmd, global_use_lvmlockd_CFG, NULL)) {
-			/*
-			 * FIXME: we could use locking_type 5 here if that didn't
-			 * cause CLUSTERED to be set, which conflicts with using lvmlockd.
-			 */
-			locking_type = 1;
-			cmd->lockd_gl_disable = 1;
-			cmd->lockd_vg_disable = 1;
-			cmd->lockd_lv_disable = 1;
-		} else {
-			locking_type = 5;
-		}
+	if (arg_is_set(cmd, nolocking_ARG) || _cmd_no_meta_proc(cmd))
+		file_locking_disable = 1;
 
-		if (lvmetad_used()) {
-			lvmetad_make_unused(cmd);
-			log_verbose("Not using lvmetad because read-only is set.");
-		}
-	} else if (arg_is_set(cmd, nolocking_ARG))
-		locking_type = 0;
-	else
-		locking_type = -1;
+	else if (arg_is_set(cmd, sysinit_ARG))
+		file_locking_sysinit = 1;
 
-	if (!init_locking(locking_type, cmd, _cmd_no_meta_proc(cmd) || arg_is_set(cmd, sysinit_ARG))) {
-		ret = ECMD_FAILED;
-		goto_out;
+	else if (arg_is_set(cmd, readonly_ARG))
+		file_locking_readonly = 1;
+
+	locking_type = find_config_tree_int(cmd, global_locking_type_CFG, NULL);
+
+	if (locking_type == 3)
+		log_warn("WARNING: See lvmlockd(8) for information on using cluster/clvm VGs.");
+
+	if (locking_type != 1) {
+		log_warn("WARNING: locking_type deprecated, using file locking.");
+		locking_type = 1;
+	}
+
+	if (!file_locking_disable) {
+		/* Set up file locking */
+		if (!init_locking(cmd, file_locking_sysinit, file_locking_readonly)) {
+			ret = ECMD_FAILED;
+			goto_out;
+		}
 	}
 
 	if (!_cmd_no_meta_proc(cmd) && !_init_lvmlockd(cmd)) {


