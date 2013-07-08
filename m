From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon,  8 Jul 2013 17:19:13 +0200
Subject: [PATCH 1/4] locking: use sigint functions
In-Reply-To: <cover.1373296602.git.zkabelac@redhat.com>
References: <cover.1373296602.git.zkabelac@redhat.com>
Message-ID: <fd9d5ede4068235c72c24e1763bb857fe816c980.1373296602.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Use sigint_allow/restore function instead of duplicating code.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/locking/file_locking.c | 57 +++++-----------------------------------------
 1 file changed, 6 insertions(+), 51 deletions(-)

diff --git a/lib/locking/file_locking.c b/lib/locking/file_locking.c
index 5e49bc4..ee15156 100644
--- a/lib/locking/file_locking.c
+++ b/lib/locking/file_locking.c
@@ -40,10 +40,6 @@ static struct dm_list _lock_list;
 static char _lock_dir[NAME_LEN];
 static int _prioritise_write_locks;
 
-static sig_t _oldhandler;
-static sigset_t _fullsigset, _intsigset;
-static volatile sig_atomic_t _handler_installed;
-
 static void _undo_flock(const char *file, int fd)
 {
 	struct stat buf1, buf2;
@@ -99,38 +95,6 @@ static void _reset_file_locking(void)
 	_release_lock(NULL, 0);
 }
 
-static void _remove_ctrl_c_handler(void)
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
-	_remove_ctrl_c_handler();
-	log_error("CTRL-c detected: giving up waiting for lock");
-}
-
-static void _install_ctrl_c_handler(void)
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
 static int _do_flock(const char *file, int *fd, int operation, uint32_t nonblock)
 {
 	int r = 1;
@@ -151,12 +115,15 @@ static int _do_flock(const char *file, int *fd, int operation, uint32_t nonblock
 		if (nonblock)
 			operation |= LOCK_NB;
 		else
-			_install_ctrl_c_handler();
+			sigint_allow();
 
 		r = flock(*fd, operation);
 		old_errno = errno;
-		if (!nonblock)
-			_remove_ctrl_c_handler();
+		if (!nonblock) {
+			sigint_restore();
+			if (sigint_caught())
+				log_error("Giving up waiting for lock.");
+		}
 
 		if (r) {
 			errno = old_errno;
@@ -370,17 +337,5 @@ int init_file_locking(struct locking_type *locking, struct cmd_context *cmd,
 
 	dm_list_init(&_lock_list);
 
-	if (sigfillset(&_intsigset) || sigfillset(&_fullsigset)) {
-		log_sys_error_suppress(suppress_messages, "sigfillset",
-				       "init_file_locking");
-		return 0;
-	}
-
-	if (sigdelset(&_intsigset, SIGINT)) {
-		log_sys_error_suppress(suppress_messages, "sigdelset",
-				       "init_file_locking");
-		return 0;
-	}
-
 	return 1;
 }
-- 
1.8.3.1


