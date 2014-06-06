From: Liuhua Wang <lwang@suse.com>
Date: Fri,  6 Jun 2014 14:49:24 +0800
Subject: [PATCH] clvmd: fix _allocate_memory to avoid segfault on ppc64.
Message-ID: <1402037364-7417-1-git-send-email-lwang@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

From: lhwang <lwang@suse.com>

Under some LIBPTHREAD_VERSION, for example 2.11, when allocates 64K
and thread stacksize is 128K, starting clvmd causes a segfault.

Signed-off-by: Liuhua Wang <lwang@suse.com>
---
 lib/mm/memlock.c | 23 +++++++++++++++++------
 1 file changed, 17 insertions(+), 6 deletions(-)

diff --git a/lib/mm/memlock.c b/lib/mm/memlock.c
index 84b93db..be92a7b 100644
--- a/lib/mm/memlock.c
+++ b/lib/mm/memlock.c
@@ -19,6 +19,7 @@
 #include "config.h"
 #include "toolcontext.h"
 
+#include <pthread.h>
 #include <limits.h>
 #include <fcntl.h>
 #include <unistd.h>
@@ -128,16 +129,26 @@ static void _touch_memory(void *mem, size_t size)
 	}
 }
 
-static void _allocate_memory(void)
+static void _allocate_memory(struct cmd_context *cmd)
 {
 	void *stack_mem, *temp_malloc_mem;
 	struct rlimit limit;
+        pthread_attr_t thread_attr;
+        size_t thread_stacksize;
 
 	/* Check if we could preallocate requested stack */
-	if ((getrlimit (RLIMIT_STACK, &limit) == 0) &&
-	    ((_size_stack * 2) < limit.rlim_cur) &&
-	    ((stack_mem = alloca(_size_stack))))
-		_touch_memory(stack_mem, _size_stack);
+	if (cmd->threaded) {
+		if ((pthread_attr_init(&thread_attr) == 0) &&
+		    (pthread_attr_getstacksize(&thread_attr, &thread_stacksize) == 0) &&
+        	    ((_size_stack * 2) < thread_stacksize) && 
+		    ((stack_mem = alloca(_size_stack))))
+			_touch_memory(stack_mem, _size_stack);        		
+        } else {
+		if ((getrlimit (RLIMIT_STACK, &limit) == 0) &&
+		    ((_size_stack * 2) < limit.rlim_cur) &&
+		    ((stack_mem = alloca(_size_stack))))
+			_touch_memory(stack_mem, _size_stack);
+	}
 	/* FIXME else warn user setting got ignored */
 
 	if ((temp_malloc_mem = malloc(_size_malloc_tmp)))
@@ -317,7 +328,7 @@ static int _memlock_maps(struct cmd_context *cmd, lvmlock_t lock, size_t *mstats
 /* Stop memory getting swapped out */
 static void _lock_mem(struct cmd_context *cmd)
 {
-	_allocate_memory();
+	_allocate_memory(cmd);
 
 	/*
 	 * For daemon we need to use mlockall()
-- 
1.9.0


