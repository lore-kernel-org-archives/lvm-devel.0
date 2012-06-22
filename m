From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 22 Jun 2012 11:51:24 +0000 (UTC)
Subject: master - fix: limit preallocate stack size
Message-ID: <20120622115124.4B18C1688@lists.fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2539769356cd73ffe6ff7abd9f9c3208ff24ee8b
Commit:        2539769356cd73ffe6ff7abd9f9c3208ff24ee8b
Parent:        192fa11dab177027ad349363b39ff6435524b23d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 22 11:15:14 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 22 13:48:04 2012 +0200

fix: limit preallocate stack size

If the user would set bigger reserved stack size then what
is allowed in resources (ulimit -s), then he would get coredump
So avoid coredump and ignore creation of such large stack size
(lvm should work properly, with just 64KB, so the option could
be eliminated).
---
 lib/mm/memlock.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/lib/mm/memlock.c b/lib/mm/memlock.c
index 17dee1c..dfc0d42 100644
--- a/lib/mm/memlock.c
+++ b/lib/mm/memlock.c
@@ -124,8 +124,12 @@ static void _touch_memory(void *mem, size_t size)
 static void _allocate_memory(void)
 {
 	void *stack_mem, *temp_malloc_mem;
+	struct rlimit limit;
 
-	if ((stack_mem = alloca(_size_stack)))
+	/* Check if we could preallocate requested stack */
+	if ((getrlimit (RLIMIT_STACK, &limit) == 0) &&
+	    ((_size_stack * 2) < limit.rlim_cur) &&
+	    ((stack_mem = alloca(_size_stack))))
 		_touch_memory(stack_mem, _size_stack);
 
 	if ((temp_malloc_mem = malloc(_size_malloc_tmp)))


