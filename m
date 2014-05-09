From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  9 May 2014 06:56:20 +0000 (UTC)
Subject: dev-prajnoha-selout - locking: use sigaction signal handling
Message-ID: <20140509065620.6C62A60774@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=04b29a3587737375303f2f37b41a33e181ac8623
Commit:        04b29a3587737375303f2f37b41a33e181ac8623
Parent:        9d64573da135b489e1b3079612e77363526ca44d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri May 2 17:27:51 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed May 7 14:01:13 2014 +0200

locking: use sigaction signal handling

Use sigint_allow/restore function instead of duplicating code
and switch to use only sigactiction based signal handling.
---
 WHATS_NEW                  |    1 +
 lib/locking/file_locking.c |    3 --
 lib/misc/lvm-flock.c       |    9 +++++--
 lib/misc/lvm-signal.c      |   54 --------------------------------------------
 4 files changed, 7 insertions(+), 60 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 37225fe..1cb97d9 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.107 - 
 ==================================
+  Use only sigaction handler and drop duplicate signal handler.
   Separate signal handling and flock code out into lib/misc.
   Don't start dmeventd checking seg_monitor and monitoring is disabled.
   Catch CTRL-c during pvremove prompts.
diff --git a/lib/locking/file_locking.c b/lib/locking/file_locking.c
index d3794db..d79d7a9 100644
--- a/lib/locking/file_locking.c
+++ b/lib/locking/file_locking.c
@@ -160,8 +160,5 @@ int init_file_locking(struct locking_type *locking, struct cmd_context *cmd,
 	if ((access(_lock_dir, R_OK | W_OK | X_OK) == -1) && (errno == EROFS))
 		return 0;
 
-	if (!init_signals(suppress_messages))
-		return_0;
-
 	return 1;
 }
diff --git a/lib/misc/lvm-flock.c b/lib/misc/lvm-flock.c
index ca05e1c..8b70a0c 100644
--- a/lib/misc/lvm-flock.c
+++ b/lib/misc/lvm-flock.c
@@ -111,12 +111,15 @@ static int _do_flock(const char *file, int *fd, int operation, uint32_t nonblock
 		if (nonblock)
 			operation |= LOCK_NB;
 		else
-			install_ctrl_c_handler();
+			sigint_allow();
 
 		r = flock(*fd, operation);
 		old_errno = errno;
-		if (!nonblock)
-			remove_ctrl_c_handler();
+		if (!nonblock) {
+			sigint_restore();
+			if (sigint_caught())
+				log_error("Giving up waiting for lock.");
+		}
 
 		if (r) {
 			errno = old_errno;
diff --git a/lib/misc/lvm-signal.c b/lib/misc/lvm-signal.c
index 690733b..679f089 100644
--- a/lib/misc/lvm-signal.c
+++ b/lib/misc/lvm-signal.c
@@ -18,10 +18,6 @@
 
 #include <signal.h>
 
-static sig_t _oldhandler;
-static sigset_t _fullsigset, _intsigset;
-static volatile sig_atomic_t _handler_installed;
-
 static sigset_t _oldset;
 static int _signals_blocked = 0;
 static volatile sig_atomic_t _sigint_caught = 0;
@@ -29,56 +25,6 @@ static volatile sig_atomic_t _handler_installed2;
 static struct sigaction _oldhandler2;
 static int _oldmasked;
 
-void remove_ctrl_c_handler(void)
-{
-	siginterrupt(SIGINT, 0);
-	if (!_handler_installed)
-		return;
-
-	_handler_installed = 0;
-
-	sigprocmask(SIG_SETMASK, &_fullsigset, NULL);
-	if (signal(SIGINT, _oldhandler) == SIG_ERR)
-		log_sys_error("signal", "_remove_ctrl_c_handler");
-}
-
-static void _trap_ctrl_c(int sig __attribute__((unused)))
-{
-	remove_ctrl_c_handler();
-
-	log_error("CTRL-c detected: giving up waiting for lock");
-}
-
-void install_ctrl_c_handler(void)
-{
-	_handler_installed = 1;
-
-	if ((_oldhandler = signal(SIGINT, _trap_ctrl_c)) == SIG_ERR) {
-		_handler_installed = 0;
-		return;
-	}
-
-	sigprocmask(SIG_SETMASK, &_intsigset, NULL);
-	siginterrupt(SIGINT, 1);
-}
-
-int init_signals(int suppress_messages)
-{
-	if (sigfillset(&_intsigset) || sigfillset(&_fullsigset)) {
-		log_sys_error_suppress(suppress_messages, "sigfillset",
-				       "init_signals");
-		return 0;
-	}
-
-	if (sigdelset(&_intsigset, SIGINT)) {
-		log_sys_error_suppress(suppress_messages, "sigdelset",
-				       "init_signals");
-		return 0;
-	}
-
-	return 1;
-}
-
 static void _catch_sigint(int unused __attribute__((unused)))
 {
 	_sigint_caught = 1;


