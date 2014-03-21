From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 21 Mar 2014 21:31:50 +0000 (UTC)
Subject: master - cleanup: memlock line indent
Message-ID: <20140321213150.90B4360F05@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1ee8688de097968655d98f0f7f266945a92f20a8
Commit:        1ee8688de097968655d98f0f7f266945a92f20a8
Parent:        46ae028cd34597cfd54048edd99cb0f27ac542eb
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 20 13:44:03 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 21 22:29:25 2014 +0100

cleanup: memlock line indent

---
 lib/mm/memlock.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/mm/memlock.c b/lib/mm/memlock.c
index a83c3ed..70af07e 100644
--- a/lib/mm/memlock.c
+++ b/lib/mm/memlock.c
@@ -445,7 +445,7 @@ void memlock_inc_daemon(struct cmd_context *cmd)
 {
 	++_memlock_count_daemon;
 	if (_memlock_count_daemon == 1 && _critical_section > 0)
-                log_error(INTERNAL_ERROR "_memlock_inc_daemon used in critical section.");
+		log_error(INTERNAL_ERROR "_memlock_inc_daemon used in critical section.");
 	log_debug_mem("memlock_count_daemon inc to %d", _memlock_count_daemon);
 	_lock_mem_if_needed(cmd);
 }


