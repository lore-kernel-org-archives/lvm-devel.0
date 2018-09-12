From: David Teigland <teigland@sourceware.org>
Date: Wed, 12 Sep 2018 17:31:11 -0400
Subject: master - fix readonly activation override options
Message-ID: <201809122131.w8CLVBST016806@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0aeca60aaa65bde99115ec7ca92a93a885d3afb1
Commit:        0aeca60aaa65bde99115ec7ca92a93a885d3afb1
Parent:        17bd91e33e0d37d8cca03b42cee20251d7fa5e80
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Sep 12 15:59:47 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Sep 12 16:30:50 2018 -0500

fix readonly activation override options

This fixes a problem in commit e6bb780d242, in which the
back compat handling for the old locking_type=4 was
incorrectly translated to mean the same thing as --readonly,
which prevented activation because activation uses an
exclusive vg lock.  Previously, locking_type=4 allowed
activation.

If we see locking_type 4 in an old config, translate it to
the new combination of --readonly and --sysinit, which we
now define to mean the --readonly behavior with an exception
to allow activation.
---
 lib/locking/locking.c  |   35 ++++++++++++++++++++++++++++++-----
 tools/command-lines.in |    4 ++--
 tools/lvmcmdline.c     |   13 +++++++++----
 3 files changed, 41 insertions(+), 11 deletions(-)

diff --git a/lib/locking/locking.c b/lib/locking/locking.c
index 3276283..a23b272 100644
--- a/lib/locking/locking.c
+++ b/lib/locking/locking.c
@@ -86,9 +86,9 @@ static void _update_vg_lock_count(const char *resource, uint32_t flags)
 
 /*
  * A mess of options have been introduced over time to override
- * or tweak the behavior of file locking.  These options are
- * allowed in different but overlapping sets of commands
- * (see command-lines.in)
+ * or tweak the behavior of file locking, and indirectly other
+ * behaviors.  These options are allowed in different but
+ * overlapping sets of commands (see command-lines.in)
  *
  * --nolocking
  *
@@ -98,7 +98,8 @@ static void _update_vg_lock_count(const char *resource, uint32_t flags)
  *
  * Command will grant any read lock request, without trying
  * to acquire an actual file lock.  Command will refuse any
- * write lock request.
+ * write lock request.  (Activation, which uses a write lock,
+ * is not allowed.)
  *
  * --ignorelockingfailure
  *
@@ -111,6 +112,12 @@ static void _update_vg_lock_count(const char *resource, uint32_t flags)
  *
  * The same as ignorelockingfailure.
  *
+ * --sysinit --readonly
+ *
+ * The combination of these two flags acts like --readonly,
+ * refusing write lock requests, but makes an exception to
+ * allow activation.
+ *
  * global/metadata_read_only
  *
  * The command acquires actual read locks and refuses
@@ -214,10 +221,28 @@ int lock_vol(struct cmd_context *cmd, const char *vol, uint32_t flags, const str
 	 * When --readonly is set, grant read lock requests without trying to
 	 * acquire an actual lock, and refuse write lock requests.
 	 */
-	if (_file_locking_readonly) {
+	if (_file_locking_readonly && !_file_locking_sysinit) {
+		if (lck_type != LCK_WRITE)
+			goto out_hold;
+
+		log_error("Operation prohibited while --readonly is set.");
+		goto out_fail;
+	}
+
+	/*
+	 * When --readonly and --sysinit are set, grant read lock requests without
+	 * trying to acquire an actual lock, and refuse write lock requests except
+	 * in the case of activation which is permitted.
+	 */
+	if (_file_locking_readonly && _file_locking_sysinit) {
 		if (lck_type != LCK_WRITE)
 			goto out_hold;
 
+		if (cmd->is_activating) {
+			log_warn("Allowing activation with --readonly --sysinit.");
+			goto out_hold;
+		}
+
 		log_error("Operation prohibited while --readonly is set.");
 		goto out_fail;
 	}
diff --git a/tools/command-lines.in b/tools/command-lines.in
index 1511098..840d771 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -280,7 +280,7 @@ RULE: all not LV_raid0
 
 lvchange --activate Active VG|LV|Tag|Select ...
 OO: --activationmode ActivationMode, --partial, --poll Bool, --monitor Bool,
---ignoreactivationskip, --ignorelockingfailure, --sysinit, OO_LVCHANGE
+--ignoreactivationskip, --ignorelockingfailure, --sysinit, --readonly, OO_LVCHANGE
 IO: --ignoreskippedcluster
 ID: lvchange_activate
 DESC: Activate or deactivate an LV.
@@ -1559,7 +1559,7 @@ DESC: Start or stop processing LV conversions.
 
 vgchange --activate Active
 OO: --activationmode ActivationMode, --ignoreactivationskip, --partial, --sysinit,
---ignorelockingfailure, --monitor Bool, --poll Bool, OO_VGCHANGE
+--readonly, --ignorelockingfailure, --monitor Bool, --poll Bool, OO_VGCHANGE
 OP: VG|Tag|Select ...
 IO: --ignoreskippedcluster
 ID: vgchange_activate
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 84825af..a1097fb 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -2743,6 +2743,7 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 	int locking_type;
 	int nolocking = 0;
 	int readonly = 0;
+	int sysinit = 0;
 	int monitoring;
 	char *arg_new, *arg;
 	int i;
@@ -2921,20 +2922,24 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 		log_warn("WARNING: see lvmlockd(8) for information on using cluster/clvm VGs.");
 
 	if ((locking_type == 0) || (locking_type == 5)) {
-		log_warn("WARNING: locking_type is deprecated, using --nolocking.");
+		log_warn("WARNING: locking_type (%d) is deprecated, using --nolocking.", locking_type);
 		nolocking = 1;
 
 	} else if (locking_type == 4) {
-		log_warn("WARNING: locking_type is deprecated, using --readonly.");
+		log_warn("WARNING: locking_type (%d) is deprecated, using --sysinit --readonly.", locking_type);
+		sysinit = 1;
 		readonly = 1;
 
 	} else if (locking_type != 1) {
-		log_warn("WARNING: locking_type is deprecated, using file locking.");
+		log_warn("WARNING: locking_type (%d) is deprecated, using file locking.", locking_type);
 	}
 
 	if (arg_is_set(cmd, nolocking_ARG) || _cmd_no_meta_proc(cmd))
 		nolocking = 1;
 
+	if (arg_is_set(cmd, sysinit_ARG))
+		sysinit = 1;
+
 	if (arg_is_set(cmd, readonly_ARG))
 		readonly = 1;
 
@@ -2942,7 +2947,7 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 		if (!_cmd_no_meta_proc(cmd))
 			log_warn("WARNING: File locking is disabled.");
 	} else {
-		if (!init_locking(cmd, arg_is_set(cmd, sysinit_ARG), readonly, arg_is_set(cmd, ignorelockingfailure_ARG))) {
+		if (!init_locking(cmd, sysinit, readonly, arg_is_set(cmd, ignorelockingfailure_ARG))) {
 			ret = ECMD_FAILED;
 			goto_out;
 		}


