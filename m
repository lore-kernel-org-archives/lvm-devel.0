From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 30 Aug 2022 11:57:44 +0000 (GMT)
Subject: main - mm: use mallinfo2 when available
Message-ID: <20220830115744.8C8BB3854148@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b553bf6fa817a38474f48816fc520d178cb48229
Commit:        b553bf6fa817a38474f48816fc520d178cb48229
Parent:        8370d117d7ef8a472c95315a3cd085696c90b3be
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Aug 30 13:48:18 2022 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Aug 30 13:56:16 2022 +0200

mm: use mallinfo2 when available

Switch to mallinfo2() from a deprecated mallinfo() glibc call
since struct size members where to small for 64b CPUs.
---
 WHATS_NEW        |  1 +
 lib/mm/memlock.c | 13 ++++++++++---
 2 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 9e7cd1f0c..293c034af 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.17 - 
 ===============================
+  Switch to use mallinfo2 and use it only with glibc.
   Error out in lvm shell if using a cmd argument not supported in the shell.
   Fix lvm shell's lastlog command to report previous pre-command failures.
   Extend VDO and VDOPOOL without flushing and locking fs.
diff --git a/lib/mm/memlock.c b/lib/mm/memlock.c
index 4a202866a..ad69f6474 100644
--- a/lib/mm/memlock.c
+++ b/lib/mm/memlock.c
@@ -167,7 +167,8 @@ static void _allocate_memory(void)
 	 */
 	void *stack_mem;
 	struct rlimit limit;
-	int i, area = 0, missing = _size_malloc_tmp, max_areas = 32, hblks;
+	int i, area = 0, missing = _size_malloc_tmp, max_areas = 32;
+	size_t hblks;
 	char *areas[max_areas];
 
 	/* Check if we could preallocate requested stack */
@@ -180,6 +181,12 @@ static void _allocate_memory(void)
 	}
 	/* FIXME else warn user setting got ignored */
 
+#ifdef HAVE_MALLINFO2
+        /* Prefer mallinfo2 call when avaialble with newer glibc */
+#define MALLINFO mallinfo2
+#else
+#define MALLINFO mallinfo
+#endif
         /*
          *  When a brk() fails due to fragmented address space (which sometimes
          *  happens when we try to grab 8M or so), glibc will make a new
@@ -191,13 +198,13 @@ static void _allocate_memory(void)
          *  memory on free(), this is good enough for our purposes.
          */
 	while (missing > 0) {
-		struct mallinfo inf = mallinfo();
+		struct MALLINFO inf = MALLINFO();
 		hblks = inf.hblks;
 
 		if ((areas[area] = malloc(_size_malloc_tmp)))
 			_touch_memory(areas[area], _size_malloc_tmp);
 
-		inf = mallinfo();
+		inf = MALLINFO();
 
 		if (hblks < inf.hblks) {
 			/* malloc cheated and used mmap, even though we told it

