From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue, 18 Nov 2014 02:18:56 +0000 (UTC)
Subject: master - memlock: Make malloc reserve more robust against glibc tricks.
Message-ID: <20141118021856.7049060279@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cf37c04347c6b6209420764da43127a96445af0e
Commit:        cf37c04347c6b6209420764da43127a96445af0e
Parent:        542b03ee007d50cd8aa6dbd582b79369a38919b0
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Tue Sep 30 10:56:59 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Tue Nov 18 03:17:27 2014 +0100

memlock: Make malloc reserve more robust against glibc tricks.

---
 lib/mm/memlock.c |   48 ++++++++++++++++++++++++++++++++++++++++++++----
 1 files changed, 44 insertions(+), 4 deletions(-)

diff --git a/lib/mm/memlock.c b/lib/mm/memlock.c
index 547fb46..e771075 100644
--- a/lib/mm/memlock.c
+++ b/lib/mm/memlock.c
@@ -25,6 +25,7 @@
 #include <sys/mman.h>
 #include <sys/time.h>
 #include <sys/resource.h>
+#include <malloc.h>
 
 #ifndef DEVMAPPER_SUPPORT
 
@@ -133,9 +134,11 @@ static void _touch_memory(void *mem, size_t size)
 static void _allocate_memory(void)
 {
 #ifndef VALGRIND_POOL
-	/* With Valgrind don't waste time in with preallocating memory */
 	void *stack_mem, *temp_malloc_mem;
 	struct rlimit limit;
+	int i, area = 0, missing = _size_malloc_tmp, max_areas = 32, hblks;
+	char *areas[max_areas];
+
 
 	/* Check if we could preallocate requested stack */
 	if ((getrlimit (RLIMIT_STACK, &limit) == 0) &&
@@ -144,13 +147,50 @@ static void _allocate_memory(void)
 		_touch_memory(stack_mem, _size_stack);
 	/* FIXME else warn user setting got ignored */
 
-	if ((temp_malloc_mem = malloc(_size_malloc_tmp)))
-		_touch_memory(temp_malloc_mem, _size_malloc_tmp);
+        /*
+         *  When a brk() fails due to fragmented address space (which sometimes
+         *  happens when we try to grab 8M or so), glibc will make a new
+         *  arena. In this arena, the rules for using ???direct??? mmap are relaxed,
+         *  circumventing the MAX_MMAPs and MMAP_THRESHOLD settings. We can,
+         *  however, detect when this happens with mallinfo() and try to co-opt
+         *  malloc into using MMAP as a MORECORE substitute instead of returning
+         *  MMAP'd memory directly. Since MMAP-as-MORECORE does not munmap the
+         *  memory on free(), this is good enough for our purposes.
+         */
+	while (missing > 0) {
+		struct mallinfo inf = mallinfo();
+		hblks = inf.hblks;
+
+		if ((areas[area] = malloc(_size_malloc_tmp)))
+			_touch_memory(areas[area], _size_malloc_tmp);
+
+		inf = mallinfo();
+
+		if (hblks < inf.hblks) {
+			/* malloc cheated and used mmap, even though we told it
+			   not to; we try with twice as many areas, each half
+			   the size, to circumvent the faulty logic in glibc */
+			free(areas[area]);
+			_size_malloc_tmp /= 2;
+		} else {
+			++ area;
+			missing -= _size_malloc_tmp;
+		}
+
+		if (area == max_areas && missing > 0) {
+			/* Too bad. Warn the user and proceed, as things are
+			 * most likely going to work out anyway. */
+			log_warn("WARNING: Failed to reserve memory, %d bytes missing.", missing);
+			break;
+		}
+	}
 
 	if ((_malloc_mem = malloc(_size_malloc)))
 		_touch_memory(_malloc_mem, _size_malloc);
 
-	free(temp_malloc_mem);
+	/* free up the reserves so subsequent malloc's can use that memory */
+	for (i = 0; i < area; ++i)
+		free(areas[i]);
 #endif
 }
 


