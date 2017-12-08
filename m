From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 8 Dec 2017 07:22:06 -0500
Subject: master - activation: keep priority till memlock_unlock
Message-ID: <201712081222.vB8CM6pA007351@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=455b26b8dbdd05ec773a84da2ef64b669c80e194
Commit:        455b26b8dbdd05ec773a84da2ef64b669c80e194
Parent:        4e8af1d3aa136eae8dbb66186bfc331b0b2887e6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Dec 8 13:11:35 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Dec 8 13:21:15 2017 +0100

activation: keep priority till memlock_unlock

Although it doesn't look like it can be a measurable problem
and costs some time to flip priorities outside of activation window.

So just like with memory locking preserve priority until call
memlock_unlock() appears.

(addition to commit c086dfadc389551b9a2d7b4c26931e5e74ada8d6).
---
 lib/mm/memlock.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/lib/mm/memlock.c b/lib/mm/memlock.c
index f72b86c..897bf10 100644
--- a/lib/mm/memlock.c
+++ b/lib/mm/memlock.c
@@ -627,8 +627,6 @@ void critical_section_dec(struct cmd_context *cmd, const char *reason)
 		log_debug_activation("Leaving critical section (%s).", reason);
 	} else
 		log_debug_activation("Leaving section (%s).", reason);
-
-	_restore_priority_if_possible(cmd);
 }
 
 int critical_section(void)
@@ -683,6 +681,7 @@ void memlock_reset(void)
 void memlock_unlock(struct cmd_context *cmd)
 {
 	_unlock_mem_if_possible(cmd);
+	_restore_priority_if_possible(cmd);
 }
 
 int memlock_count_daemon(void)


