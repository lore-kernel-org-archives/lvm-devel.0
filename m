From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 2 Jul 2018 04:26:53 -0400
Subject: master - locking: memory locking ONLY with suspending reason
Message-ID: <201807020826.w628QriZ025656@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0bae9a1bffe34170569ce37bd7effbdfe0603fa1
Commit:        0bae9a1bffe34170569ce37bd7effbdfe0603fa1
Parent:        b55d30956d77afec7a985132225d5b64d072b598
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Jun 30 10:35:08 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 2 10:21:42 2018 +0200

locking: memory locking ONLY with suspending reason

It's important to lock memory beforo running SUSPEND ioctl - but whole
lvm preload runs in memory unlocked environment - as in this phase
memory allocation is allowed and is meant to happen.

Once all targets are preload and ready (confirmed from all targets)
we start suspending tree - and here the memory allocation (or i.e.
opening files) is no longer allowed - as it may cause kernel deadlock.
---
 lib/mm/memlock.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/lib/mm/memlock.c b/lib/mm/memlock.c
index 65f13c4..9ebf96d 100644
--- a/lib/mm/memlock.c
+++ b/lib/mm/memlock.c
@@ -604,8 +604,7 @@ static void _unlock_mem_if_possible(struct cmd_context *cmd)
 void critical_section_inc(struct cmd_context *cmd, const char *reason)
 {
 	if (!_critical_section &&
-	    ((strcmp(reason, "suspending") == 0) ||
-	     (strcmp(reason, "locking for suspend") == 0))) {
+	    (strcmp(reason, "suspending") == 0)) {
 		/*
 		 * Profiles are loaded on-demand so make sure that before
 		 * entering the critical section all needed profiles are


