From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 16 Nov 2011 14:22:59 +0100
Subject: [PATCH 12/12] DEBUG Stack detection code
In-Reply-To: <cover.1321449480.git.zkabelac@redhat.com>
References: <cover.1321449480.git.zkabelac@redhat.com>
Message-ID: <f1d356efc5f21d8025bb64d2f375e235009554e3.1321449480.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch is rather just an idea we might deploy into the source
code in some further modifed version.

It prefills allocated stack size with some pattern and check
whether pattern is still present when leaving critical section
and prints the amount of unmodified data.

Final version might probably mark just bottom 32? bytes
and check if they are still there ?
(Something like we are doing for memory locked & unlocked size).

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/mm/memlock.c |   49 ++++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 48 insertions(+), 1 deletions(-)

diff --git a/lib/mm/memlock.c b/lib/mm/memlock.c
index b9fc430..0f705c0 100644
--- a/lib/mm/memlock.c
+++ b/lib/mm/memlock.c
@@ -26,6 +26,10 @@
 #include <sys/time.h>
 #include <sys/resource.h>
 
+#ifdef VALGRIND_POOL
+#include "valgrind/memcheck.h"
+#endif
+
 #ifndef DEVMAPPER_SUPPORT
 
 void memlock_inc_daemon(struct cmd_context *cmd)
@@ -121,12 +125,54 @@ static void _touch_memory(void *mem, size_t size)
 	}
 }
 
+static long *_stack_lowest = 0;
+static void _touch_stack(void *mem, size_t size)
+{
+	long *pos = _stack_lowest = (long *) mem;
+	long *end = (long *) ((char *) pos + size - sizeof(long));
+	while (pos < end) {
+		*pos = (long) pos;
+		pos++;
+	}
+}
+
+static void _test_stack(void)
+{
+	long *pos = NULL;
+	long *end = (long*)&end;
+
+	/* Tets works only for downward growing stack */
+	if (&end > &pos)
+		return;
+
+	if (end <= _stack_lowest)
+		goto bad;
+
+	pos = alloca((end - _stack_lowest) * sizeof(long));
+#ifdef VALGRIND_POOL
+	VALGRIND_MAKE_MEM_DEFINED(pos, (end - _stack_lowest) * sizeof(long));
+#endif
+
+	pos = _stack_lowest;
+
+	while (pos < end && (*pos == (long) pos))
+		pos++;
+
+	log_verbose("Stack has not used %" PRIsize_t " reserved bytes.",
+		    sizeof(long) * (pos - _stack_lowest));
+
+	if ((pos - _stack_lowest) > 0)
+		return;
+bad:
+	log_error(INTERNAL_ERROR "Reserved stack has been too small.");
+}
+
 static void _allocate_memory(void)
 {
 	void *stack_mem, *temp_malloc_mem;
 
 	if ((stack_mem = alloca(_size_stack)))
-		_touch_memory(stack_mem, _size_stack);
+		_touch_stack(stack_mem, _size_stack);
 
 	if ((temp_malloc_mem = malloc(_size_malloc_tmp)))
 		_touch_memory(temp_malloc_mem, _size_malloc_tmp);
@@ -140,6 +186,7 @@ static void _allocate_memory(void)
 static void _release_memory(void)
 {
 	free(_malloc_mem);
+	_test_stack();
 }
 
 /*
-- 
1.7.7.3


