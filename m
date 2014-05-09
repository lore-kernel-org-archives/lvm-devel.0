From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  9 May 2014 06:56:24 +0000 (UTC)
Subject: dev-prajnoha-selout - signals: better nesting support
Message-ID: <20140509065624.A16FF60774@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e585a6bbcf8416f5eeb6b57e0b02ca5e52f23f96
Commit:        e585a6bbcf8416f5eeb6b57e0b02ca5e52f23f96
Parent:        31ac200a374e101ddfb60fbef0591efee58b478a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri May 2 17:30:27 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed May 7 14:09:33 2014 +0200

signals: better nesting support

Support upto 3 levels os nesting signal blocking.
As of today - code blocks signals immediatelly when it opens
VG in read-write mode - this however makes current prompt usage
then partially unusable since user may not 'break' command
during prompt (something most user would expect).

Until a better fix for prompting is implemented, put in support
for signal nesting - thus when prompt enables signal acceptance,
make it possible to really break command at this point.
---
 WHATS_NEW             |    1 +
 lib/misc/lvm-signal.c |   35 ++++++++++++++---------------------
 2 files changed, 15 insertions(+), 21 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 1cb97d9..f0c36cb 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.107 - 
 ==================================
+  Better support for nesting of blocking signals.
   Use only sigaction handler and drop duplicate signal handler.
   Separate signal handling and flock code out into lib/misc.
   Don't start dmeventd checking seg_monitor and monitoring is disabled.
diff --git a/lib/misc/lvm-signal.c b/lib/misc/lvm-signal.c
index 8aeb192..d5dac6f 100644
--- a/lib/misc/lvm-signal.c
+++ b/lib/misc/lvm-signal.c
@@ -21,9 +21,12 @@
 static sigset_t _oldset;
 static int _signals_blocked = 0;
 static volatile sig_atomic_t _sigint_caught = 0;
-static volatile sig_atomic_t _handler_installed2;
-static struct sigaction _oldhandler2;
-static int _oldmasked;
+static volatile sig_atomic_t _handler_installed;
+
+/* Support 3 level nesting, increase if needed more */
+#define MAX_SIGINTS 3
+static struct sigaction _oldhandler[MAX_SIGINTS];
+static int _oldmasked[MAX_SIGINTS];
 
 static void _catch_sigint(int unused __attribute__((unused)))
 {
@@ -61,10 +64,8 @@ void sigint_allow(void)
 	 * Do not overwrite the backed-up handler data -
 	 * just increase nesting count.
 	 */
-	if (_handler_installed2) {
-		_handler_installed2++;
+	if (++_handler_installed >= MAX_SIGINTS)
 		return;
-	}
 
 	/* Grab old sigaction for SIGINT: shall not fail. */
 	if (sigaction(SIGINT, NULL, &handler))
@@ -73,17 +74,15 @@ void sigint_allow(void)
 	handler.sa_flags &= ~SA_RESTART; /* Clear restart flag */
 	handler.sa_handler = _catch_sigint;
 
-	_handler_installed2 = 1;
-
 	/* Override the signal handler: shall not fail. */
-	if (sigaction(SIGINT, &handler, &_oldhandler2))
+	if (sigaction(SIGINT, &handler, &_oldhandler[_handler_installed  - 1]))
 		log_sys_debug("sigaction", "SIGINT");
 
 	/* Unmask SIGINT.  Remember to mask it again on restore. */
 	if (sigprocmask(0, NULL, &sigs))
 		log_sys_debug("sigprocmask", "");
 
-	if ((_oldmasked = sigismember(&sigs, SIGINT))) {
+	if ((_oldmasked[_handler_installed] = sigismember(&sigs, SIGINT))) {
 		sigdelset(&sigs, SIGINT);
 		if (sigprocmask(SIG_SETMASK, &sigs, NULL))
 			log_sys_debug("sigprocmask", "SIG_SETMASK");
@@ -92,18 +91,12 @@ void sigint_allow(void)
 
 void sigint_restore(void)
 {
-	if (!_handler_installed2)
+	if (!_handler_installed ||
+	    --_handler_installed >= MAX_SIGINTS)
 		return;
 
-	if (_handler_installed2 > 1) {
-		_handler_installed2--;
-		return;
-	}
-
-	/* Nesting count went down to 0. */
-	_handler_installed2 = 0;
-
-	if (_oldmasked) {
+	/* Nesting count went bellow MAX_SIGINTS. */
+	if (_oldmasked[_handler_installed]) {
 		sigset_t sigs;
 		sigprocmask(0, NULL, &sigs);
 		sigaddset(&sigs, SIGINT);
@@ -111,7 +104,7 @@ void sigint_restore(void)
 			log_sys_debug("sigprocmask", "SIG_SETMASK");
 	}
 
-	if (sigaction(SIGINT, &_oldhandler2, NULL))
+	if (sigaction(SIGINT, &_oldhandler[_handler_installed], NULL))
 		log_sys_debug("sigaction", "SIGINT restore");
 }
 


