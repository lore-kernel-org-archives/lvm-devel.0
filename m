From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 21 Mar 2014 21:31:27 +0000 (UTC)
Subject: master - memlock: drop locked mem in critical section
Message-ID: <20140321213127.A15CD611DB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=486b15d36ce672f78a35143ce6bb12c48552fbf8
Commit:        486b15d36ce672f78a35143ce6bb12c48552fbf8
Parent:        0ca16c694668ded9b33c22dc54316dd4bd77151b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 20 13:53:39 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 21 22:29:22 2014 +0100

memlock: drop locked mem in critical section

When daemon releases memory and it is still in critical
section, issue an error message and drop memory.

We cannot do anything better for now and we at least
release allocated resource.

FIXME:

This code is triggered when i.e. clvmd is killed while
some LVs are suspend - in this case suspended devices leak,
so if this happens during i.e. clvmd upgrade we have
unresolved problem - even locked rootfs...
---
 lib/mm/memlock.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/lib/mm/memlock.c b/lib/mm/memlock.c
index f32424a2..a83c3ed 100644
--- a/lib/mm/memlock.c
+++ b/lib/mm/memlock.c
@@ -456,6 +456,11 @@ void memlock_dec_daemon(struct cmd_context *cmd)
 		log_error(INTERNAL_ERROR "_memlock_count_daemon has dropped below 0.");
 	--_memlock_count_daemon;
 	log_debug_mem("memlock_count_daemon dec to %d", _memlock_count_daemon);
+	if (!_memlock_count_daemon && _critical_section && _mem_locked) {
+		log_error("Unlocking daemon memory in critical section.");
+		_unlock_mem(cmd);
+		_mem_locked = 0;
+	}
 	_unlock_mem_if_possible(cmd);
 }
 


