From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon,  8 Jul 2013 17:19:15 +0200
Subject: [PATCH 3/4] locking: support stacking
In-Reply-To: <cover.1373296602.git.zkabelac@redhat.com>
References: <cover.1373296602.git.zkabelac@redhat.com>
Message-ID: <3ef48cd166c23785a654e1d88f7523583bf03fa1.1373296602.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Support 2 levels of nesting signal blocking.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/locking/locking.c | 49 +++++++++++++++++++++++++------------------------
 1 file changed, 25 insertions(+), 24 deletions(-)

diff --git a/lib/locking/locking.c b/lib/locking/locking.c
index 9183ee6..377d8a4 100644
--- a/lib/locking/locking.c
+++ b/lib/locking/locking.c
@@ -39,8 +39,11 @@ static int _blocking_supported = 0;
 
 static volatile sig_atomic_t _sigint_caught = 0;
 static volatile sig_atomic_t _handler_installed;
-static struct sigaction _oldhandler;
-static int _oldmasked;
+
+/* Support 2 level nesting, increase if needed more */
+#define MAX_SIGINTS 2
+static struct sigaction _oldhandler[MAX_SIGINTS];
+static int _oldmasked[MAX_SIGINTS];
 
 typedef enum {
         LV_NOOP,
@@ -84,50 +87,48 @@ void sigint_allow(void)
 	 * Do not overwrite the backed-up handler data -
 	 * just increase nesting count.
 	 */
-	if (_handler_installed) {
-		_handler_installed++;
+	if (++_handler_installed > MAX_SIGINTS)
 		return;
-	}
 
 	/* Grab old sigaction for SIGINT: shall not fail. */
-	sigaction(SIGINT, NULL, &handler);
+	if (sigaction(SIGINT, NULL, &handler))
+		log_sys_error("sigaction", "SIGINT");
 	handler.sa_flags &= ~SA_RESTART; /* Clear restart flag */
 	handler.sa_handler = _catch_sigint;
 
-	_handler_installed = 1;
-
 	/* Override the signal handler: shall not fail. */
-	sigaction(SIGINT, &handler, &_oldhandler);
+	if (sigaction(SIGINT, &handler, &_oldhandler[_handler_installed - 1]))
+		log_sys_error("sigaction", "SIGINT");
 
 	/* Unmask SIGINT.  Remember to mask it again on restore. */
-	sigprocmask(0, NULL, &sigs);
-	if ((_oldmasked = sigismember(&sigs, SIGINT))) {
+	if (sigprocmask(0, NULL, &sigs))
+		log_sys_error("sigprocmask", "");
+
+	if ((_oldmasked[_handler_installed] = sigismember(&sigs, SIGINT))) {
 		sigdelset(&sigs, SIGINT);
-		sigprocmask(SIG_SETMASK, &sigs, NULL);
+		if (sigprocmask(SIG_SETMASK, &sigs, NULL))
+			log_sys_error("sigprocmask", "SIG_SETMASK");
 	}
 }
 
 void sigint_restore(void)
 {
-	if (!_handler_installed)
-		return;
+	sigset_t sigs;
 
-	if (_handler_installed > 1) {
-		_handler_installed--;
+	if (!_handler_installed ||
+	    _handler_installed-- > MAX_SIGINTS)
 		return;
-	}
-
-	/* Nesting count went down to 0. */
-	_handler_installed = 0;
 
-	if (_oldmasked) {
-		sigset_t sigs;
+	/* Nesting count went bellow 2. */
+	if (_oldmasked[_handler_installed]) {
 		sigprocmask(0, NULL, &sigs);
 		sigaddset(&sigs, SIGINT);
-		sigprocmask(SIG_SETMASK, &sigs, NULL);
+		if (sigprocmask(SIG_SETMASK, &sigs, NULL))
+			log_sys_error("sigprocmask", "SIG_SETMASK");
 	}
 
-	sigaction(SIGINT, &_oldhandler, NULL);
+	if (sigaction(SIGINT, &_oldhandler[_handler_installed], NULL))
+		log_sys_error("sigaction", "SIGINT restore");
 }
 
 static void _block_signals(uint32_t flags __attribute__((unused)))
-- 
1.8.3.1


