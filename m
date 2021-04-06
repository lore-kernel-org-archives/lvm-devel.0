From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  6 Apr 2021 20:07:25 +0000 (GMT)
Subject: main - signals: support also SIGTERM for breaking command
Message-ID: <20210406200725.164893857823@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fe4f83171d43ed764b2342f2081db8d9e8ce9343
Commit:        fe4f83171d43ed764b2342f2081db8d9e8ce9343
Parent:        287565fd5dd5f49f1a51c6cd9ebdc9c20ebc7730
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 1 11:32:29 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 6 21:26:57 2021 +0200

signals: support also SIGTERM for breaking command

If we are signaled with SIGTERM it should be at least as good
as with SIGINT - as the command should stop ASAP.
So when lvm2 command allows signal handling we also
enable SIGTERM handling. If there are some other signals
we should handle equally -  we could just extend array.
---
 lib/misc/lvm-signal.c | 76 +++++++++++++++++++++++++++++++++------------------
 1 file changed, 49 insertions(+), 27 deletions(-)

diff --git a/lib/misc/lvm-signal.c b/lib/misc/lvm-signal.c
index b1653a85c..67012af86 100644
--- a/lib/misc/lvm-signal.c
+++ b/lib/misc/lvm-signal.c
@@ -26,8 +26,19 @@ static volatile sig_atomic_t _handler_installed = 0;
 
 /* Support 3 level nesting, increase if needed more */
 #define MAX_SIGINTS 3
-static struct sigaction _oldhandler[MAX_SIGINTS];
-static int _oldmasked[MAX_SIGINTS];
+
+struct ar_sigs {
+	int sig;
+	const char *name;
+	int oldmasked[MAX_SIGINTS];
+	struct sigaction oldhandler[MAX_SIGINTS];
+};
+
+/* List of signals we want to allow/restore */
+static struct ar_sigs _ar_sigs[] = {
+	{ SIGINT, "SIGINT" },
+	{ SIGTERM, "SIGTERM" },
+};
 
 static void _catch_sigint(int unused __attribute__((unused)))
 {
@@ -58,6 +69,7 @@ void sigint_clear(void)
 
 void sigint_allow(void)
 {
+	int i, mask = 0;
 	struct sigaction handler;
 	sigset_t sigs;
 
@@ -70,30 +82,37 @@ void sigint_allow(void)
 	if (++_handler_installed > MAX_SIGINTS)
 		return;
 
-	/* Grab old sigaction for SIGINT: shall not fail. */
-	if (sigaction(SIGINT, NULL, &handler))
-		log_sys_debug("sigaction", "SIGINT");
+	/* Unmask signals. Remember to mask it again on restore. */
+	if (sigprocmask(0, NULL, &sigs))
+		log_sys_debug("sigprocmask", "");
 
-	handler.sa_flags &= ~SA_RESTART; /* Clear restart flag */
-	handler.sa_handler = _catch_sigint;
+	for (i = 0; i < DM_ARRAY_SIZE(_ar_sigs); ++i) {
+		/* Grab old sigaction for SIGNAL: shall not fail. */
+		if (sigaction(_ar_sigs[i].sig, NULL, &handler))
+			log_sys_debug("sigaction", _ar_sigs[i].name);
 
-	/* Override the signal handler: shall not fail. */
-	if (sigaction(SIGINT, &handler, &_oldhandler[_handler_installed  - 1]))
-		log_sys_debug("sigaction", "SIGINT");
+		handler.sa_flags &= ~SA_RESTART; /* Clear restart flag */
+		handler.sa_handler = _catch_sigint;
 
-	/* Unmask SIGINT.  Remember to mask it again on restore. */
-	if (sigprocmask(0, NULL, &sigs))
-		log_sys_debug("sigprocmask", "");
+		/* Override the signal handler: shall not fail. */
+		if (sigaction(_ar_sigs[i].sig, &handler, &_ar_sigs[i].oldhandler[_handler_installed  - 1]))
+			log_sys_debug("sigaction", _ar_sigs[i].name);
 
-	if ((_oldmasked[_handler_installed - 1] = sigismember(&sigs, SIGINT))) {
-		sigdelset(&sigs, SIGINT);
-		if (sigprocmask(SIG_SETMASK, &sigs, NULL))
-			log_sys_debug("sigprocmask", "SIG_SETMASK");
+		if ((_ar_sigs[i].oldmasked[_handler_installed - 1] = sigismember(&sigs, _ar_sigs[i].sig))) {
+			sigdelset(&sigs, _ar_sigs[i].sig);
+			mask = 1;
+		}
 	}
+
+	if (mask && sigprocmask(SIG_SETMASK, &sigs, NULL))
+		log_sys_debug("sigprocmask", "SIG_SETMASK");
 }
 
 void sigint_restore(void)
 {
+	int i, mask = 0;
+	sigset_t sigs;
+
 	if (memlock_count_daemon())
 		return;
 
@@ -102,16 +121,19 @@ void sigint_restore(void)
 		return;
 
 	/* Nesting count went below MAX_SIGINTS. */
-	if (_oldmasked[_handler_installed]) {
-		sigset_t sigs;
-		sigprocmask(0, NULL, &sigs);
-		sigaddset(&sigs, SIGINT);
-		if (sigprocmask(SIG_SETMASK, &sigs, NULL))
-			log_sys_debug("sigprocmask", "SIG_SETMASK");
-	}
-
-	if (sigaction(SIGINT, &_oldhandler[_handler_installed], NULL))
-		log_sys_debug("sigaction", "SIGINT restore");
+	sigprocmask(0, NULL, &sigs);
+	for (i = 0; i < DM_ARRAY_SIZE(_ar_sigs); ++i)
+		if (_ar_sigs[i].oldmasked[_handler_installed]) {
+			sigaddset(&sigs, _ar_sigs[i].sig);
+			mask = 1;
+		}
+
+	if (mask && sigprocmask(SIG_SETMASK, &sigs, NULL))
+		log_sys_debug("sigprocmask", "SIG_SETMASK");
+
+	for (i = 0; i < DM_ARRAY_SIZE(_ar_sigs); ++i)
+		if (sigaction(_ar_sigs[i].sig, &_ar_sigs[i].oldhandler[_handler_installed], NULL))
+			log_sys_debug("sigaction", _ar_sigs[i].name);
 }
 
 void block_signals(uint32_t flags __attribute__((unused)))


