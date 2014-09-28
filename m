From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 28 Sep 2014 11:56:50 +0000 (UTC)
Subject: master - valgrind: don't eat mem with valgrind
Message-ID: <20140928115650.DB5A360041@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d1be66ba3708c23a20c2062ff63b0240531caa31
Commit:        d1be66ba3708c23a20c2062ff63b0240531caa31
Parent:        f3e9ff7179303cb23ee78819a0c24fc1ccc5394f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Sep 27 16:27:34 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Sep 28 13:49:01 2014 +0200

valgrind: don't eat mem with valgrind

When compiled with valgrind pool support - don't waste time
with preallocation of memory - it just waste of CPU cycles to
trace access to this memory.

We also may get slightly better estimation about real memory usage
during command processing.
---
 lib/mm/memlock.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/lib/mm/memlock.c b/lib/mm/memlock.c
index 37d9457..547fb46 100644
--- a/lib/mm/memlock.c
+++ b/lib/mm/memlock.c
@@ -132,6 +132,8 @@ static void _touch_memory(void *mem, size_t size)
 
 static void _allocate_memory(void)
 {
+#ifndef VALGRIND_POOL
+	/* With Valgrind don't waste time in with preallocating memory */
 	void *stack_mem, *temp_malloc_mem;
 	struct rlimit limit;
 
@@ -149,6 +151,7 @@ static void _allocate_memory(void)
 		_touch_memory(_malloc_mem, _size_malloc);
 
 	free(temp_malloc_mem);
+#endif
 }
 
 static void _release_memory(void)


