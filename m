From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  9 May 2014 06:56:09 +0000 (UTC)
Subject: dev-prajnoha-selout - signals: Move sigint handling out to lvm-signal.
Message-ID: <20140509065609.E801B60774@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2eed136f0f5d9eaa65d421b2b93b6405fd7c6f08
Commit:        2eed136f0f5d9eaa65d421b2b93b6405fd7c6f08
Parent:        29a3fbf067e1685ae7e202959a414e4b13f547c7
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu May 1 20:07:17 2014 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu May 1 20:07:17 2014 +0100

signals: Move sigint handling out to lvm-signal.

---
 WHATS_NEW               |    1 +
 lib/cache/lvmetad.c     |    1 +
 lib/display/display.c   |    2 +
 lib/locking/locking.c   |  134 +++-------------------------------------------
 lib/locking/locking.h   |    6 --
 lib/metadata/lv_manip.c |    1 +
 lib/metadata/metadata.c |    1 +
 lib/misc/lvm-flock.h    |    6 +-
 lib/misc/lvm-signal.c   |  123 +++++++++++++++++++++++++++++++++++++++++++
 lib/misc/lvm-signal.h   |   12 ++++-
 tools/tools.h           |    1 +
 11 files changed, 153 insertions(+), 135 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 456f132..37225fe 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.107 - 
 ==================================
+  Separate signal handling and flock code out into lib/misc.
   Don't start dmeventd checking seg_monitor and monitoring is disabled.
   Catch CTRL-c during pvremove prompts.
   Show correct availability status for snapshot origin in lvscan.
diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index d0c4a4d..3470c66 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -21,6 +21,7 @@
 #include "lvmetad-client.h"
 #include "format-text.h" // TODO for disk_locn, used as a DA representation
 #include "crc.h"
+#include "lvm-signal.h"
 
 #define SCAN_TIMEOUT_SECONDS	80
 #define MAX_RESCANS		10	/* Maximum number of times to scan all PVs and retry if the daemon returns a token mismatch error */
diff --git a/lib/display/display.c b/lib/display/display.c
index b83bb59..b808f25 100644
--- a/lib/display/display.c
+++ b/lib/display/display.c
@@ -20,6 +20,8 @@
 #include "toolcontext.h"
 #include "segtype.h"
 #include "defaults.h"
+#include "lvm-signal.h"
+
 #include <stdarg.h>
 
 #define SIZE_BUF 128
diff --git a/lib/locking/locking.c b/lib/locking/locking.c
index b5250c1..673713a 100644
--- a/lib/locking/locking.c
+++ b/lib/locking/locking.c
@@ -22,148 +22,25 @@
 #include "memlock.h"
 #include "defaults.h"
 #include "lvmcache.h"
+#include "lvm-signal.h"
 
 #include <assert.h>
-#include <signal.h>
 #include <sys/stat.h>
 #include <limits.h>
 #include <unistd.h>
 
 static struct locking_type _locking;
-static sigset_t _oldset;
 
 static int _vg_lock_count = 0;		/* Number of locks held */
 static int _vg_write_lock_held = 0;	/* VG write lock held? */
-static int _signals_blocked = 0;
 static int _blocking_supported = 0;
 
-static volatile sig_atomic_t _sigint_caught = 0;
-static volatile sig_atomic_t _handler_installed;
-static struct sigaction _oldhandler;
-static int _oldmasked;
-
 typedef enum {
         LV_NOOP,
         LV_SUSPEND,
         LV_RESUME
 } lv_operation_t;
 
-static void _catch_sigint(int unused __attribute__((unused)))
-{
-	_sigint_caught = 1;
-}
-
-int sigint_caught(void) {
-	if (_sigint_caught)
-		log_error("Interrupted...");
-
-	return _sigint_caught;
-}
-
-void sigint_clear(void)
-{
-	_sigint_caught = 0;
-}
-
-/*
- * Temporarily allow keyboard interrupts to be intercepted and noted;
- * saves interrupt handler state for sigint_restore().  Users should
- * use the sigint_caught() predicate to check whether interrupt was
- * requested and act appropriately.  Interrupt flags are never
- * cleared automatically by this code, but the tools clear the flag
- * before running each command in lvm_run_command().  All other places
- * where the flag needs to be cleared need to call sigint_clear().
- */
-
-void sigint_allow(void)
-{
-	struct sigaction handler;
-	sigset_t sigs;
-
-	/*
-	 * Do not overwrite the backed-up handler data -
-	 * just increase nesting count.
-	 */
-	if (_handler_installed) {
-		_handler_installed++;
-		return;
-	}
-
-	/* Grab old sigaction for SIGINT: shall not fail. */
-	sigaction(SIGINT, NULL, &handler);
-	handler.sa_flags &= ~SA_RESTART; /* Clear restart flag */
-	handler.sa_handler = _catch_sigint;
-
-	_handler_installed = 1;
-
-	/* Override the signal handler: shall not fail. */
-	sigaction(SIGINT, &handler, &_oldhandler);
-
-	/* Unmask SIGINT.  Remember to mask it again on restore. */
-	sigprocmask(0, NULL, &sigs);
-	if ((_oldmasked = sigismember(&sigs, SIGINT))) {
-		sigdelset(&sigs, SIGINT);
-		sigprocmask(SIG_SETMASK, &sigs, NULL);
-	}
-}
-
-void sigint_restore(void)
-{
-	if (!_handler_installed)
-		return;
-
-	if (_handler_installed > 1) {
-		_handler_installed--;
-		return;
-	}
-
-	/* Nesting count went down to 0. */
-	_handler_installed = 0;
-
-	if (_oldmasked) {
-		sigset_t sigs;
-		sigprocmask(0, NULL, &sigs);
-		sigaddset(&sigs, SIGINT);
-		sigprocmask(SIG_SETMASK, &sigs, NULL);
-	}
-
-	sigaction(SIGINT, &_oldhandler, NULL);
-}
-
-static void _block_signals(uint32_t flags __attribute__((unused)))
-{
-	sigset_t set;
-
-	if (_signals_blocked)
-		return;
-
-	if (sigfillset(&set)) {
-		log_sys_error("sigfillset", "_block_signals");
-		return;
-	}
-
-	if (sigprocmask(SIG_SETMASK, &set, &_oldset)) {
-		log_sys_error("sigprocmask", "_block_signals");
-		return;
-	}
-
-	_signals_blocked = 1;
-}
-
-static void _unblock_signals(void)
-{
-	/* Don't unblock signals while any locks are held */
-	if (!_signals_blocked || _vg_lock_count)
-		return;
-
-	if (sigprocmask(SIG_SETMASK, &_oldset, NULL)) {
-		log_sys_error("sigprocmask", "_block_signals");
-		return;
-	}
-
-	_signals_blocked = 0;
-}
-
 static void _lock_memory(struct cmd_context *cmd, lv_operation_t lv_op)
 {
 	if (!(_locking.flags & LCK_PRE_MEMLOCK))
@@ -182,6 +59,13 @@ static void _unlock_memory(struct cmd_context *cmd, lv_operation_t lv_op)
 		critical_section_dec(cmd, "unlocking on resume");
 }
 
+static void _unblock_signals(void)
+{
+	/* Don't unblock signals while any locks are held */
+	if (!_vg_lock_count)
+		unblock_signals();
+}
+
 void reset_locking(void)
 {
 	int was_locked = _vg_lock_count;
@@ -366,7 +250,7 @@ static int _lock_vol(struct cmd_context *cmd, const char *resource,
 	uint32_t lck_scope = flags & LCK_SCOPE_MASK;
 	int ret = 0;
 
-	_block_signals(flags);
+	block_signals(flags);
 	_lock_memory(cmd, lv_op);
 
 	assert(resource);
diff --git a/lib/locking/locking.h b/lib/locking/locking.h
index aa42138..0945aa0 100644
--- a/lib/locking/locking.h
+++ b/lib/locking/locking.h
@@ -213,10 +213,4 @@ int resume_lvs(struct cmd_context *cmd, struct dm_list *lvs);
 int revert_lvs(struct cmd_context *cmd, struct dm_list *lvs);
 int activate_lvs(struct cmd_context *cmd, struct dm_list *lvs, unsigned exclusive);
 
-/* Interrupt handling */
-void sigint_clear(void);
-void sigint_allow(void);
-void sigint_restore(void);
-int sigint_caught(void);
-
 #endif
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 85f7a39..6817831 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -28,6 +28,7 @@
 #include "str_list.h"
 #include "defaults.h"
 #include "lvm-exec.h"
+#include "lvm-signal.h"
 
 typedef enum {
 	PREFERRED,
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index e2abba7..4791c10 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -19,6 +19,7 @@
 #include "toolcontext.h"
 #include "lvm-string.h"
 #include "lvm-file.h"
+#include "lvm-signal.h"
 #include "lvmcache.h"
 #include "lvmetad.h"
 #include "memlock.h"
diff --git a/lib/misc/lvm-flock.h b/lib/misc/lvm-flock.h
index 5e8aefd..3fed73e 100644
--- a/lib/misc/lvm-flock.h
+++ b/lib/misc/lvm-flock.h
@@ -12,11 +12,11 @@
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
 
-#ifndef _LVM_SIGNAL_H
-#  define _LVM_SIGNAL_H
+#ifndef _LVM_FLOCK_H
+#define _LVM_FLOCK_H
 
 void init_flock(struct cmd_context *cmd);
 int lock_file(const char *file, uint32_t flags);
 void release_flocks(int unlock);
 
-#endif /* _LVM_SIGNAL_H */
+#endif /* _LVM_FLOCK_H */
diff --git a/lib/misc/lvm-signal.c b/lib/misc/lvm-signal.c
index 927e839..f2d6d3b 100644
--- a/lib/misc/lvm-signal.c
+++ b/lib/misc/lvm-signal.c
@@ -22,6 +22,13 @@ static sig_t _oldhandler;
 static sigset_t _fullsigset, _intsigset;
 static volatile sig_atomic_t _handler_installed;
 
+static sigset_t _oldset;
+static int _signals_blocked = 0;
+static volatile sig_atomic_t _sigint_caught = 0;
+static volatile sig_atomic_t _handler_installed2;
+static struct sigaction _oldhandler2;
+static int _oldmasked;
+
 void remove_ctrl_c_handler(void)
 {
 	siginterrupt(SIGINT, 0);
@@ -54,3 +61,119 @@ void install_ctrl_c_handler(void)
 	sigprocmask(SIG_SETMASK, &_intsigset, NULL);
 	siginterrupt(SIGINT, 1);
 }
+
+static void _catch_sigint(int unused __attribute__((unused)))
+{
+	_sigint_caught = 1;
+}
+
+int sigint_caught(void) {
+	if (_sigint_caught)
+		log_error("Interrupted...");
+
+	return _sigint_caught;
+}
+
+void sigint_clear(void)
+{
+	_sigint_caught = 0;
+}
+
+/*
+ * Temporarily allow keyboard interrupts to be intercepted and noted;
+ * saves interrupt handler state for sigint_restore().  Users should
+ * use the sigint_caught() predicate to check whether interrupt was
+ * requested and act appropriately.  Interrupt flags are never
+ * cleared automatically by this code, but the tools clear the flag
+ * before running each command in lvm_run_command().  All other places
+ * where the flag needs to be cleared need to call sigint_clear().
+ */
+
+void sigint_allow(void)
+{
+	struct sigaction handler;
+	sigset_t sigs;
+
+	/*
+	 * Do not overwrite the backed-up handler data -
+	 * just increase nesting count.
+	 */
+	if (_handler_installed2) {
+		_handler_installed2++;
+		return;
+	}
+
+	/* Grab old sigaction for SIGINT: shall not fail. */
+	sigaction(SIGINT, NULL, &handler);
+	handler.sa_flags &= ~SA_RESTART; /* Clear restart flag */
+	handler.sa_handler = _catch_sigint;
+
+	_handler_installed2 = 1;
+
+	/* Override the signal handler: shall not fail. */
+	sigaction(SIGINT, &handler, &_oldhandler2);
+
+	/* Unmask SIGINT.  Remember to mask it again on restore. */
+	sigprocmask(0, NULL, &sigs);
+	if ((_oldmasked = sigismember(&sigs, SIGINT))) {
+		sigdelset(&sigs, SIGINT);
+		sigprocmask(SIG_SETMASK, &sigs, NULL);
+	}
+}
+
+void sigint_restore(void)
+{
+	if (!_handler_installed2)
+		return;
+
+	if (_handler_installed2 > 1) {
+		_handler_installed2--;
+		return;
+	}
+
+	/* Nesting count went down to 0. */
+	_handler_installed2 = 0;
+
+	if (_oldmasked) {
+		sigset_t sigs;
+		sigprocmask(0, NULL, &sigs);
+		sigaddset(&sigs, SIGINT);
+		sigprocmask(SIG_SETMASK, &sigs, NULL);
+	}
+
+	sigaction(SIGINT, &_oldhandler2, NULL);
+}
+
+void block_signals(uint32_t flags __attribute__((unused)))
+{
+	sigset_t set;
+
+	if (_signals_blocked)
+		return;
+
+	if (sigfillset(&set)) {
+		log_sys_error("sigfillset", "_block_signals");
+		return;
+	}
+
+	if (sigprocmask(SIG_SETMASK, &set, &_oldset)) {
+		log_sys_error("sigprocmask", "_block_signals");
+		return;
+	}
+
+	_signals_blocked = 1;
+}
+
+void unblock_signals(void)
+{
+	/* Don't unblock signals while any locks are held */
+	if (!_signals_blocked)
+		return;
+
+	if (sigprocmask(SIG_SETMASK, &_oldset, NULL)) {
+		log_sys_error("sigprocmask", "_block_signals");
+		return;
+	}
+
+	_signals_blocked = 0;
+}
diff --git a/lib/misc/lvm-signal.h b/lib/misc/lvm-signal.h
index ce9d2e9..f2e6141 100644
--- a/lib/misc/lvm-signal.h
+++ b/lib/misc/lvm-signal.h
@@ -14,7 +14,17 @@
  */
 
 #ifndef _LVM_SIGNAL_H
-#  define _LVM_SIGNAL_H
+#define _LVM_SIGNAL_H
+
 void remove_ctrl_c_handler(void);
 void install_ctrl_c_handler(void);
+
+void sigint_allow(void);
+int sigint_caught(void);
+void sigint_restore(void);
+void sigint_clear(void);
+
+void block_signals(uint32_t flags);
+void unblock_signals(void);
+
 #endif
diff --git a/tools/tools.h b/tools/tools.h
index a2bfe0d..11111cb 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -40,6 +40,7 @@
 #include "locking.h"
 #include "lvm-exec.h"
 #include "lvm-file.h"
+#include "lvm-signal.h"
 #include "lvm-string.h"
 #include "segtype.h"
 #include "str_list.h"


