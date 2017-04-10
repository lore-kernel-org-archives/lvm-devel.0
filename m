From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Mon, 10 Apr 2017 12:16:37 -0400
Subject: master - signals: fix SIGINT blocking flaw causing inconsistent metadata
Message-ID: <201704101616.v3AGGbVA026560@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9a689fb8f0a6b1675a4e819f4837bf2e0269832f
Commit:        9a689fb8f0a6b1675a4e819f4837bf2e0269832f
Parent:        ef3e1013aa8d7797fa432e2da219255178b8ede3
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Mon Apr 10 18:16:09 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Mon Apr 10 18:16:09 2017 +0200

signals: fix SIGINT blocking flaw causing inconsistent metadata

SIGINT isn't blocked properly after a sigint_allow(),
sigint_restore() cycle leading to illicit interruptable
metadata updates.  These can leave corrupted metadata behind.

Issues addressed in this commit:

sigint_allow() fails to set _oldmasked[] members properly due
to an offset by one bug on indexing the members of the array.

It bails out prematurely comparing to MAX_SIGINTS causing nesting
depths to be one less than MAX_SIGINTS.  Fix the comparision.

Correct the related comparison flaw in sigint_restore().

Initialize all sig_atomic_t variables consequently.

Resolves: rhbz1440766
---
 lib/misc/lvm-signal.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/lib/misc/lvm-signal.c b/lib/misc/lvm-signal.c
index 7e78407..15d8a6f 100644
--- a/lib/misc/lvm-signal.c
+++ b/lib/misc/lvm-signal.c
@@ -22,7 +22,7 @@
 static sigset_t _oldset;
 static int _signals_blocked = 0;
 static volatile sig_atomic_t _sigint_caught = 0;
-static volatile sig_atomic_t _handler_installed;
+static volatile sig_atomic_t _handler_installed = 0;
 
 /* Support 3 level nesting, increase if needed more */
 #define MAX_SIGINTS 3
@@ -67,7 +67,7 @@ void sigint_allow(void)
 	 * Do not overwrite the backed-up handler data -
 	 * just increase nesting count.
 	 */
-	if (++_handler_installed >= MAX_SIGINTS)
+	if (++_handler_installed > MAX_SIGINTS)
 		return;
 
 	/* Grab old sigaction for SIGINT: shall not fail. */
@@ -85,7 +85,7 @@ void sigint_allow(void)
 	if (sigprocmask(0, NULL, &sigs))
 		log_sys_debug("sigprocmask", "");
 
-	if ((_oldmasked[_handler_installed] = sigismember(&sigs, SIGINT))) {
+	if ((_oldmasked[_handler_installed - 1] = sigismember(&sigs, SIGINT))) {
 		sigdelset(&sigs, SIGINT);
 		if (sigprocmask(SIG_SETMASK, &sigs, NULL))
 			log_sys_debug("sigprocmask", "SIG_SETMASK");
@@ -98,7 +98,7 @@ void sigint_restore(void)
 		return;
 
 	if (!_handler_installed ||
-	    --_handler_installed >= MAX_SIGINTS)
+	    --_handler_installed > MAX_SIGINTS)
 		return;
 
 	/* Nesting count went below MAX_SIGINTS. */


