From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 22 Oct 2015 21:33:22 +0000 (UTC)
Subject: master - tools: do not change signals for memlocked daemons
Message-ID: <20151022213322.6B42760F00@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=075f85dcb518d7d9c2452af4165f44ba991a1258
Commit:        075f85dcb518d7d9c2452af4165f44ba991a1258
Parent:        d2c4ce254bac0f607676b10e38ba2f2ebee709b8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 22 10:45:58 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 22 22:26:30 2015 +0200

tools: do not change signals for memlocked daemons

---
 lib/misc/lvm-signal.c |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/lib/misc/lvm-signal.c b/lib/misc/lvm-signal.c
index 0d61e73..9250560 100644
--- a/lib/misc/lvm-signal.c
+++ b/lib/misc/lvm-signal.c
@@ -15,6 +15,7 @@
 
 #include "lib.h"
 #include "lvm-signal.h"
+#include "memlock.h"
 
 #include <signal.h>
 
@@ -60,6 +61,8 @@ void sigint_allow(void)
 	struct sigaction handler;
 	sigset_t sigs;
 
+	if (memlock_count_daemon())
+		return;
 	/*
 	 * Do not overwrite the backed-up handler data -
 	 * just increase nesting count.
@@ -91,6 +94,9 @@ void sigint_allow(void)
 
 void sigint_restore(void)
 {
+	if (memlock_count_daemon())
+		return;
+
 	if (!_handler_installed ||
 	    --_handler_installed >= MAX_SIGINTS)
 		return;
@@ -112,6 +118,9 @@ void block_signals(uint32_t flags __attribute__((unused)))
 {
 	sigset_t set;
 
+	if (memlock_count_daemon())
+		return;
+
 	if (_signals_blocked)
 		return;
 
@@ -130,6 +139,9 @@ void block_signals(uint32_t flags __attribute__((unused)))
 
 void unblock_signals(void)
 {
+	if (memlock_count_daemon())
+		return;
+
 	/* Don't unblock signals while any locks are held */
 	if (!_signals_blocked)
 		return;


