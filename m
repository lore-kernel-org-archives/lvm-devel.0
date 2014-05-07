From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  7 May 2014 12:18:52 +0000 (UTC)
Subject: master - debug: add more debug message for signal handling
Message-ID: <20140507121852.4BB4B60268@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=31ac200a374e101ddfb60fbef0591efee58b478a
Commit:        31ac200a374e101ddfb60fbef0591efee58b478a
Parent:        04b29a3587737375303f2f37b41a33e181ac8623
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri May 2 17:34:22 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed May 7 14:07:13 2014 +0200

debug: add more debug message for signal handling

Adding log_sys_debug for eventual logging of system errors.
(Using debug level, since currently signal handling functions
do not fail when any error is encoutered).
---
 lib/misc/lvm-signal.c |   20 ++++++++++++++------
 1 files changed, 14 insertions(+), 6 deletions(-)

diff --git a/lib/misc/lvm-signal.c b/lib/misc/lvm-signal.c
index 679f089..8aeb192 100644
--- a/lib/misc/lvm-signal.c
+++ b/lib/misc/lvm-signal.c
@@ -67,20 +67,26 @@ void sigint_allow(void)
 	}
 
 	/* Grab old sigaction for SIGINT: shall not fail. */
-	sigaction(SIGINT, NULL, &handler);
+	if (sigaction(SIGINT, NULL, &handler))
+		log_sys_debug("sigaction", "SIGINT");
+
 	handler.sa_flags &= ~SA_RESTART; /* Clear restart flag */
 	handler.sa_handler = _catch_sigint;
 
 	_handler_installed2 = 1;
 
 	/* Override the signal handler: shall not fail. */
-	sigaction(SIGINT, &handler, &_oldhandler2);
+	if (sigaction(SIGINT, &handler, &_oldhandler2))
+		log_sys_debug("sigaction", "SIGINT");
 
 	/* Unmask SIGINT.  Remember to mask it again on restore. */
-	sigprocmask(0, NULL, &sigs);
+	if (sigprocmask(0, NULL, &sigs))
+		log_sys_debug("sigprocmask", "");
+
 	if ((_oldmasked = sigismember(&sigs, SIGINT))) {
 		sigdelset(&sigs, SIGINT);
-		sigprocmask(SIG_SETMASK, &sigs, NULL);
+		if (sigprocmask(SIG_SETMASK, &sigs, NULL))
+			log_sys_debug("sigprocmask", "SIG_SETMASK");
 	}
 }
 
@@ -101,10 +107,12 @@ void sigint_restore(void)
 		sigset_t sigs;
 		sigprocmask(0, NULL, &sigs);
 		sigaddset(&sigs, SIGINT);
-		sigprocmask(SIG_SETMASK, &sigs, NULL);
+		if (sigprocmask(SIG_SETMASK, &sigs, NULL))
+			log_sys_debug("sigprocmask", "SIG_SETMASK");
 	}
 
-	sigaction(SIGINT, &_oldhandler2, NULL);
+	if (sigaction(SIGINT, &_oldhandler2, NULL))
+		log_sys_debug("sigaction", "SIGINT restore");
 }
 
 void block_signals(uint32_t flags __attribute__((unused)))


