From: David Teigland <teigland@sourceware.org>
Date: Thu, 7 Jun 2018 17:49:56 -0400
Subject: master - Rework lock-override options and locking_type settings
Message-ID: <201806072149.w57Lnu3j007369@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e6bb780d24246666fa05948ec449a8137280b443
Commit:        e6bb780d24246666fa05948ec449a8137280b443
Parent:        c7c7017f0c12ebab4e1aef9d9a9fabd4ec2adfe3
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Jun 7 15:33:02 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Jun 7 16:47:15 2018 -0500

Rework lock-override options and locking_type settings

The last commit related to this was incomplete:
  "Implement lock-override options without locking type"

This is further reworking and reduction of the locking.[ch]
layer which handled all clustering, but is now only used
for file locking.  The "locking types" that this layer
implemented were removed previously, leaving only the
standard file locking.  (Some cluster-related artifacts
remain to be cleared out later.)

Command options to override or modify locking behavior
are reimplemented here without using the locking types.
Also, deprecated locking_type values are recognized,
and implemented as if one of the equivalent override
options was set.

Options that override file locking are:

. --nolocking disables all file locking.

. --readonly grants read lock requests without actually
  taking a file lock, and refuses write lock requests.

. --ignorelockingfailure tries to set up file locks and
  uses them normally if possible.  When not possible, it
  behaves like --readonly, but allows activation.

. --sysinit is the same as ignorelockingfailure.

. global/metadata_read_only acquires actual read file
  locks, and refuses write lock requests.

(Some of these options could probably be deprecated
because they were added as workarounds to various
locking_type behaviors that are now deprecated.)

The locking_type setting now has one valid value: 1 which
refers to standard file locking.  Configs that contain
deprecated values are recognized and still work in
largely the same way:

. 0 disabled all locking, now implemented like --nolocking
  is set.  Allow the nolocking option in all commands.

. 1 is the normal file locking setting and is unchanged.

. 2 was for external locking which was not used, and
  reverts to normal file locking.

. 3 was for cluster/clvm.  This reverts to normal file
  locking, and prints messages about lvmlockd.

. 4 was equivalent to readonly, now implemented like
  --readonly is set.

. 5 disabled all locking, now implemented like
  --nolocking is set.
---
 lib/commands/toolcontext.h   |    1 +
 lib/config/config_settings.h |   43 +--------
 lib/locking/locking.c        |  216 ++++++++++++++++++++++++------------------
 lib/locking/locking.h        |    2 +-
 lib/misc/lvm-globals.c       |   11 --
 lib/misc/lvm-globals.h       |    4 -
 lib/misc/sharedlib.c         |    2 +-
 tools/command-lines.in       |    4 +-
 tools/lvmcmdline.c           |   53 ++++++-----
 9 files changed, 163 insertions(+), 173 deletions(-)

diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index b46e301..fee35d4 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -172,6 +172,7 @@ struct cmd_context {
 	unsigned can_use_one_scan:1;
 	unsigned is_clvmd:1;
 	unsigned use_full_md_check:1;
+	unsigned is_activating:1;
 
 	/*
 	 * Filtering.
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 6cc7b15..32a6476 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -785,51 +785,16 @@ cfg(global_etc_CFG, "etc", global_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_ETC_D
 	"Location of /etc system configuration directory.\n")
 
 cfg(global_locking_type_CFG, "locking_type", global_CFG_SECTION, 0, CFG_TYPE_INT, 1, vsn(1, 0, 0), NULL, 0, NULL,
-	"Type of locking to use.\n"
-	"#\n"
-	"Accepted values:\n"
-	"  0\n"
-	"    Turns off locking. Warning: this risks metadata corruption if\n"
-	"    commands run concurrently.\n"
-	"  1\n"
-	"    LVM uses local file-based locking, the standard mode.\n"
-	"  2\n"
-	"    LVM uses the external shared library locking_library.\n"
-	"  3\n"
-	"    LVM uses built-in clustered locking with clvmd.\n"
-	"    This is incompatible with lvmetad. If use_lvmetad is enabled,\n"
-	"    LVM prints a warning and disables lvmetad use.\n"
-	"  4\n"
-	"    LVM uses read-only locking which forbids any operations that\n"
-	"    might change metadata.\n"
-	"  5\n"
-	"    Offers dummy locking for tools that do not need any locks.\n"
-	"    You should not need to set this directly; the tools will select\n"
-	"    when to use it instead of the configured locking_type.\n"
-	"    Do not use lvmetad or the kernel device-mapper driver with this\n"
-	"    locking type. It is used by the --readonly option that offers\n"
-	"    read-only access to Volume Group metadata that cannot be locked\n"
-	"    safely because it belongs to an inaccessible domain and might be\n"
-	"    in use, for example a virtual machine image or a disk that is\n"
-	"    shared by a clustered machine.\n"
-	"#\n")
+	"This setting is no longer used.")
 
 cfg(global_wait_for_locks_CFG, "wait_for_locks", global_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_WAIT_FOR_LOCKS, vsn(2, 2, 50), NULL, 0, NULL,
 	"When disabled, fail if a lock request would block.\n")
 
 cfg(global_fallback_to_clustered_locking_CFG, "fallback_to_clustered_locking", global_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_FALLBACK_TO_CLUSTERED_LOCKING, vsn(2, 2, 42), NULL, 0, NULL,
-	"Attempt to use built-in cluster locking if locking_type 2 fails.\n"
-	"If using external locking (type 2) and initialisation fails, with\n"
-	"this enabled, an attempt will be made to use the built-in clustered\n"
-	"locking. Disable this if using a customised locking_library.\n")
+	"This setting is no longer used.\n")
 
 cfg(global_fallback_to_local_locking_CFG, "fallback_to_local_locking", global_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_FALLBACK_TO_LOCAL_LOCKING, vsn(2, 2, 42), NULL, 0, NULL,
-	"Use locking_type 1 (local) if locking_type 2 or 3 fail.\n"
-	"If an attempt to initialise type 2 or type 3 locking failed, perhaps\n"
-	"because cluster components such as clvmd are not running, with this\n"
-	"enabled, an attempt will be made to use local file-based locking\n"
-	"(type 1). If this succeeds, only commands against local VGs will\n"
-	"proceed. VGs marked as clustered will be ignored.\n")
+	"This setting is no longer used.\n")
 
 cfg(global_locking_dir_CFG, "locking_dir", global_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_LOCK_DIR, vsn(1, 0, 0), "@DEFAULT_LOCK_DIR@", 0, NULL,
 	"Directory to use for LVM command file locks.\n"
@@ -849,7 +814,7 @@ cfg(global_library_dir_CFG, "library_dir", global_CFG_SECTION, CFG_DEFAULT_UNDEF
 	"Search this directory first for shared libraries.\n")
 
 cfg(global_locking_library_CFG, "locking_library", global_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_LOCKING_LIB, vsn(1, 0, 0), NULL, 0, NULL,
-	"The external locking library to use for locking_type 2.\n")
+	"This setting is no longer used.\n")
 
 cfg(global_abort_on_internal_errors_CFG, "abort_on_internal_errors", global_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_ABORT_ON_INTERNAL_ERRORS, vsn(2, 2, 57), NULL, 0, NULL,
 	"Abort a command that encounters an internal error.\n"
diff --git a/lib/locking/locking.c b/lib/locking/locking.c
index 4c27a81..7e499bb 100644
--- a/lib/locking/locking.c
+++ b/lib/locking/locking.c
@@ -36,6 +36,8 @@ static int _vg_write_lock_held = 0;	/* VG write lock held? */
 static int _blocking_supported = 0;
 static int _file_locking_readonly = 0;
 static int _file_locking_sysinit = 0;
+static int _file_locking_ignorefail = 0;
+static int _file_locking_failed = 0;
 
 static void _unblock_signals(void)
 {
@@ -85,27 +87,65 @@ static void _update_vg_lock_count(const char *resource, uint32_t flags)
 }
 
 /*
- * Select a locking type
- * type: locking type; if < 0, then read config tree value
+ * A mess of options have been introduced over time to override
+ * or tweak the behavior of file locking.  These options are
+ * allowed in different but overlapping sets of commands
+ * (see command-lines.in)
+ *
+ * --nolocking
+ *
+ * Command won't try to set up or use file locks@all.
+ *
+ * --readonly
+ *
+ * Command will grant any read lock request, without trying
+ * to acquire an actual file lock.  Command will refuse any
+ * write lock request.
+ *
+ * --ignorelockingfailure
+ *
+ * Command tries to set up file locks and will use them
+ * (both read and write) if successful.  If command fails
+ * to set up file locks it falls back to readonly behavior
+ * above, while allowing activation.
+ *
+ * --sysinit
+ *
+ * The same as ignorelockingfailure.
+ *
+ * global/metadata_read_only
+ *
+ * The command acquires actual read locks and refuses
+ * write lock requests.
  */
-int init_locking(struct cmd_context *cmd, int file_locking_sysinit, int file_locking_readonly)
+
+int init_locking(struct cmd_context *cmd,
+		 int file_locking_sysinit, int file_locking_readonly, int file_locking_ignorefail)
 {
 	int suppress_messages = 0;
 
-	if (getenv("LVM_SUPPRESS_LOCKING_FAILURE_MESSAGES"))
-		suppress_messages = 1;
-
-	if (file_locking_sysinit)
+	if (file_locking_sysinit || getenv("LVM_SUPPRESS_LOCKING_FAILURE_MESSAGES"))
 		suppress_messages = 1;
 
 	_blocking_supported = find_config_tree_bool(cmd, global_wait_for_locks_CFG, NULL);
 	_file_locking_readonly = file_locking_readonly;
 	_file_locking_sysinit = file_locking_sysinit;
+	_file_locking_ignorefail = file_locking_ignorefail;
+
+	log_debug("File locking settings: readonly:%d sysinit:%d ignorelockingfailure:%d global/metadata_read_only:%d global/wait_for_locks:%d.",
+		  _file_locking_readonly, _file_locking_sysinit, _file_locking_ignorefail,
+		  cmd->metadata_read_only, _blocking_supported);
+
+	if (!init_file_locking(&_locking, cmd, suppress_messages)) {
+		log_error_suppress(suppress_messages, "File locking initialisation failed.");
+
+		_file_locking_failed = 1;
 
-	log_very_verbose("%sFile-based locking selected.", _blocking_supported ? "" : "Non-blocking ");
+		if (file_locking_sysinit || file_locking_ignorefail)
+			return 1;
 
-	if (!init_file_locking(&_locking, cmd, suppress_messages))
-		log_error_suppress(suppress_messages, "File-based locking initialisation failed.");
+		return 0;
+	}
 
 	return 1;
 }
@@ -125,68 +165,12 @@ void fin_locking(void)
  */
 static int _lock_vol(struct cmd_context *cmd, const char *resource, uint32_t flags)
 {
-	uint32_t lck_type = flags & LCK_TYPE_MASK;
-	uint32_t lck_scope = flags & LCK_SCOPE_MASK;
 	int ret = 0;
 
 	block_signals(flags);
 
-	assert(resource);
+	ret = _locking.lock_resource(cmd, resource, flags, NULL);
 
-	if (!*resource) {
-		log_error(INTERNAL_ERROR "Use of P_orphans is deprecated.");
-		goto out;
-	}
-
-	if ((is_orphan_vg(resource) || is_global_vg(resource)) && (flags & LCK_CACHE)) {
-		log_error(INTERNAL_ERROR "P_%s referenced.", resource);
-		goto out;
-	}
-
-	if ((lck_type == LCK_WRITE) && (lck_scope == LCK_VG) && !(flags & LCK_CACHE) &&
-	    strcmp(resource, VG_GLOBAL)) {
-
-		/* read only locking set in lvm.conf metadata_read_only */
-
-		if (cmd->metadata_read_only) {
-			log_error("Operation prohibited while global/metadata_read_only is set.");
-			goto out;
-		}
-
-		/* read only locking set with option --readonly */
-
-		if (_file_locking_readonly) {
-			log_error("Read-only locking specified. Write locks are prohibited.");
-			goto out;
-		}
-
-		/* read only locking (except activation) set with option --sysinit */
-		/* FIXME: sysinit is intended to allow activation, add that exception here */
-
-		if (_file_locking_sysinit) {
-			log_error("Read-only sysinit locking specified. Write locks are prohibited.");
-			goto out;
-		}
-	}
-
-	if ((ret = _locking.lock_resource(cmd, resource, flags, NULL))) {
-		if (lck_scope == LCK_VG && !(flags & LCK_CACHE)) {
-			if (lck_type != LCK_UNLOCK)
-				lvmcache_lock_vgname(resource, lck_type == LCK_READ);
-			dev_reset_error_count(cmd);
-		}
-
-		_update_vg_lock_count(resource, flags);
-	} else
-		stack;
-
-	/* If unlocking, always remove lock from lvmcache even if operation failed. */
-	if (lck_scope == LCK_VG && !(flags & LCK_CACHE) && lck_type == LCK_UNLOCK) {
-		lvmcache_unlock_vgname(resource);
-		if (!ret)
-			_update_vg_lock_count(resource, flags);
-	}
-out:
 	_unblock_signals();
 
 	return ret;
@@ -195,52 +179,102 @@ out:
 int lock_vol(struct cmd_context *cmd, const char *vol, uint32_t flags, const struct logical_volume *lv)
 {
 	char resource[258] __attribute__((aligned(8)));
-	int lck_type = flags & LCK_TYPE_MASK;
+	uint32_t lck_type = flags & LCK_TYPE_MASK;
+	uint32_t lck_scope = flags & LCK_SCOPE_MASK;
 
-	/* file locking disabled */
+	if (!_blocking_supported)
+		flags |= LCK_NONBLOCK;
+
+	if (is_orphan_vg(vol))
+		vol = VG_ORPHANS;
+
+	if (!dm_strncpy(resource, vol, sizeof(resource))) {
+		log_error(INTERNAL_ERROR "Resource name %s is too long.", vol);
+		return 0;
+	}
+
+	/*
+	 * File locking is disabled by --nolocking.
+	 */
 	if (!_locking.flags)
-		return 1;
+		goto out_hold;
+
+	/*
+	 * When file locking could not be initialized, --ignorelockingfailure
+	 * and --sysinit behave like --readonly, but allow activation.
+	 */
+	if (_file_locking_failed && (_file_locking_sysinit || _file_locking_ignorefail)) {
+		if (lck_type != LCK_WRITE)
+			goto out_hold;
+
+		if (cmd->is_activating && (lck_scope == LCK_VG) && !(flags & LCK_CACHE) && strcmp(vol, VG_GLOBAL))
+			goto out_hold;
 
-	if (flags == LCK_NONE) {
-		log_debug_locking(INTERNAL_ERROR "%s: LCK_NONE lock requested", vol);
-		return 1;
+		goto out_fail;
 	}
 
-	switch (flags & LCK_SCOPE_MASK) {
-	case LCK_VG:
-		if (!_blocking_supported)
-			flags |= LCK_NONBLOCK;
-
-		/* Global VG_ORPHANS lock covers all orphan formats. */
-		if (is_orphan_vg(vol))
-			vol = VG_ORPHANS;
-		break;
-	default:
-		log_error("Unrecognised lock scope: %d",
-			  flags & LCK_SCOPE_MASK);
-		return 0;
+	/*
+	 * When --readonly is set, grant read lock requests without trying to
+	 * acquire an actual lock, and refuse write lock requests.
+	 */
+	if (_file_locking_readonly) {
+		if (lck_type != LCK_WRITE)
+			goto out_hold;
+
+		log_error("Operation prohibited while --readonly is set.");
+		goto out_fail;
 	}
 
-	if (!dm_strncpy(resource, vol, sizeof(resource))) {
-		log_error(INTERNAL_ERROR "Resource name %s is too long.", vol);
-		return 0;
+	/*
+	 * When global/metadata_read_only is set, acquire actual read locks and
+	 * refuse write lock requests.
+	 */
+	if (cmd->metadata_read_only) {
+		if ((lck_type == LCK_WRITE) && (lck_scope == LCK_VG) && !(flags & LCK_CACHE) && strcmp(vol, VG_GLOBAL)) {
+			log_error("Operation prohibited while global/metadata_read_only is set.");
+			goto out_fail;
+		}
+
+		/* continue and acquire a read file lock */
 	}
 
 	if (!_lock_vol(cmd, resource, flags))
-		return_0;
+		goto out_fail;
 
 	/*
+	 * FIXME: I don't think we need this any more.
 	 * If a real lock was acquired (i.e. not LCK_CACHE),
 	 * perform an immediate unlock unless LCK_HOLD was requested.
 	 */
+
 	if ((lck_type == LCK_NULL) || (lck_type == LCK_UNLOCK) ||
 	    (flags & (LCK_CACHE | LCK_HOLD)))
-		return 1;
+		goto out_hold;
 
 	if (!_lock_vol(cmd, resource, (flags & ~LCK_TYPE_MASK) | LCK_UNLOCK))
 		return_0;
+	return 1;
+
+
+out_hold:
+	/*
+	 * FIXME: other parts of the code want to check if a VG is
+	 * locked by looking in lvmcache.  They shouldn't need to
+	 * do that, and we should be able to remove this.
+	 */
+	if ((lck_scope == LCK_VG) && !(flags & LCK_CACHE) && (lck_type != LCK_UNLOCK))
+		lvmcache_lock_vgname(resource, lck_type == LCK_READ);
+	else if ((lck_scope == LCK_VG) && !(flags & LCK_CACHE) && (lck_type == LCK_UNLOCK))
+		lvmcache_unlock_vgname(resource);
 
+	/* FIXME: we shouldn't need to keep track of this either. */
+	_update_vg_lock_count(resource, flags);
 	return 1;
+
+out_fail:
+	if (lck_type == LCK_UNLOCK)
+		_update_vg_lock_count(resource, flags);
+	return 0;
 }
 
 /* Lock a list of LVs */
diff --git a/lib/locking/locking.h b/lib/locking/locking.h
index 422f1d8..96f7d86 100644
--- a/lib/locking/locking.h
+++ b/lib/locking/locking.h
@@ -21,7 +21,7 @@
 
 struct logical_volume;
 
-int init_locking(struct cmd_context *cmd, int suppress_messages, int only_read_locks);
+int init_locking(struct cmd_context *cmd, int file_locking_sysinit, int file_locking_readonly, int file_locking_ignorefail);
 void fin_locking(void);
 void reset_locking(void);
 int vg_write_lock_held(void);
diff --git a/lib/misc/lvm-globals.c b/lib/misc/lvm-globals.c
index b76ddb9..9377588 100644
--- a/lib/misc/lvm-globals.c
+++ b/lib/misc/lvm-globals.c
@@ -34,7 +34,6 @@ static int _trust_cache = 0; /* Don't scan when incomplete VGs encountered */
 static int _debug_level = 0;
 static int _debug_classes_logged = 0;
 static int _log_cmd_name = 0;
-static int _ignorelockingfailure = 0;
 static int _security_level = SECURITY_LEVEL;
 static char _cmd_name[30] = "";
 static int _mirror_in_sync = 0;
@@ -106,11 +105,6 @@ void init_trust_cache(int trustcache)
 	_trust_cache = trustcache;
 }
 
-void init_ignorelockingfailure(int level)
-{
-	_ignorelockingfailure = level;
-}
-
 void init_security_level(int level)
 {
 	_security_level = level;
@@ -267,11 +261,6 @@ int background_polling(void)
 	return _background_polling;
 }
 
-int ignorelockingfailure(void)
-{
-	return _ignorelockingfailure;
-}
-
 int security_level(void)
 {
 	return _security_level;
diff --git a/lib/misc/lvm-globals.h b/lib/misc/lvm-globals.h
index b383891..55a9399 100644
--- a/lib/misc/lvm-globals.h
+++ b/lib/misc/lvm-globals.h
@@ -35,8 +35,6 @@ void init_trust_cache(int trustcache);
 void init_debug(int level);
 void init_debug_classes_logged(int classes);
 void init_cmd_name(int status);
-void init_ignorelockingfailure(int level);
-void init_lockingfailed(int level);
 void init_security_level(int level);
 void init_mirror_in_sync(int in_sync);
 void init_dmeventd_monitor(int reg);
@@ -69,8 +67,6 @@ int verbose_level(void);
 int silent_mode(void);
 int debug_level(void);
 int debug_class_is_logged(int class);
-int ignorelockingfailure(void);
-int lockingfailed(void);
 int security_level(void);
 int mirror_in_sync(void);
 int background_polling(void);
diff --git a/lib/misc/sharedlib.c b/lib/misc/sharedlib.c
index d594470..4c2d5d9 100644
--- a/lib/misc/sharedlib.c
+++ b/lib/misc/sharedlib.c
@@ -58,7 +58,7 @@ void *load_shared_library(struct cmd_context *cmd, const char *libname,
 	log_very_verbose("Opening shared %s library %s", desc, path);
 
 	if (!(library = dlopen(path, RTLD_LAZY | RTLD_GLOBAL))) {
-		if (silent && ignorelockingfailure())
+		if (silent)
 			log_verbose("Unable to open external %s library %s: %s",
 				    desc, path, dlerror());
 		else
diff --git a/tools/command-lines.in b/tools/command-lines.in
index 409f01c..ad710a4 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -187,7 +187,7 @@
 # OO_ALL is included in every command automatically.
 #
 OO_ALL: --commandprofile String, --config String, --debug,
---driverloaded Bool, --help, --lockopt String, --longhelp, --profile String, --quiet,
+--driverloaded Bool, --help, --nolocking, --lockopt String, --longhelp, --profile String, --quiet,
 --verbose, --version, --yes, --test
 
 #
@@ -195,7 +195,7 @@ OO_ALL: --commandprofile String, --config String, --debug,
 #
 OO_REPORT: --aligned, --all, --binary, --configreport ConfigReport, --foreign,
 --ignorelockingfailure, --ignoreskippedcluster, --logonly,
---nameprefixes, --noheadings, --nolocking, --nosuffix,
+--nameprefixes, --noheadings, --nosuffix,
 --options String, --readonly, --reportformat ReportFmt, --rows,
 --select String, --separator String, --shared, --sort String,
 --trustcache, --unbuffered, --units Units, --unquoted
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 788f007..2578113 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -2323,11 +2323,6 @@ static int _get_current_settings(struct cmd_context *cmd)
 		return EINVALID_CMD_LINE;
 	}
 
-	if (arg_is_set(cmd, ignorelockingfailure_ARG) || arg_is_set(cmd, sysinit_ARG))
-		init_ignorelockingfailure(1);
-	else
-		init_ignorelockingfailure(0);
-
 	cmd->ignore_clustered_vgs = arg_is_set(cmd, ignoreskippedcluster_ARG);
 	cmd->include_foreign_vgs = arg_is_set(cmd, foreign_ARG) ? 1 : 0;
 	cmd->include_shared_vgs = arg_is_set(cmd, shared_ARG) ? 1 : 0;
@@ -2734,9 +2729,8 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 	const char *reason = NULL;
 	int ret = 0;
 	int locking_type;
-	int file_locking_disable = 0;
-	int file_locking_sysinit = 0;
-	int file_locking_readonly = 0;
+	int nolocking = 0;
+	int readonly = 0;
 	int monitoring;
 	char *arg_new, *arg;
 	int i;
@@ -2865,6 +2859,10 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 	if (arg_is_set(cmd, readonly_ARG))
 		cmd->metadata_read_only = 1;
 
+	if ((cmd->command->command_enum == vgchange_activate_CMD) ||
+	    (cmd->command->command_enum == lvchange_activate_CMD))
+		cmd->is_activating = 1;
+
 	/*
 	 * Now that all configs, profiles and command lines args are available,
 	 * freshly calculate and apply all settings.  Specific command line
@@ -2911,28 +2909,35 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 		goto out;
 	}
 
-	if (arg_is_set(cmd, nolocking_ARG) || _cmd_no_meta_proc(cmd))
-		file_locking_disable = 1;
-
-	else if (arg_is_set(cmd, sysinit_ARG))
-		file_locking_sysinit = 1;
-
-	else if (arg_is_set(cmd, readonly_ARG))
-		file_locking_readonly = 1;
-
+	/* Defaults to 1 if not set. */
 	locking_type = find_config_tree_int(cmd, global_locking_type_CFG, NULL);
 
 	if (locking_type == 3)
-		log_warn("WARNING: See lvmlockd(8) for information on using cluster/clvm VGs.");
+		log_warn("WARNING: see lvmlockd(8) for information on using cluster/clvm VGs.");
 
-	if (locking_type != 1) {
-		log_warn("WARNING: locking_type deprecated, using file locking.");
-		locking_type = 1;
+	if ((locking_type == 0) || (locking_type == 5)) {
+		log_warn("WARNING: locking_type is deprecated, using --nolocking.");
+		nolocking = 1;
+
+	} else if (locking_type == 4) {
+		log_warn("WARNING: locking_type is deprecated, using --readonly.");
+		readonly = 1;
+
+	} else if (locking_type != 1) {
+		log_warn("WARNING: locking_type is deprecated, using file locking.");
 	}
 
-	if (!file_locking_disable) {
-		/* Set up file locking */
-		if (!init_locking(cmd, file_locking_sysinit, file_locking_readonly)) {
+	if (arg_is_set(cmd, nolocking_ARG) || _cmd_no_meta_proc(cmd))
+		nolocking = 1;
+
+	if (arg_is_set(cmd, readonly_ARG))
+		readonly = 1;
+
+	if (nolocking) {
+		if (!_cmd_no_meta_proc(cmd))
+			log_warn("WARNING: File locking is disabled.");
+	} else {
+		if (!init_locking(cmd, arg_is_set(cmd, sysinit_ARG), readonly, arg_is_set(cmd, ignorelockingfailure_ARG))) {
 			ret = ECMD_FAILED;
 			goto_out;
 		}


