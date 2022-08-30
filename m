From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 30 Aug 2022 11:57:43 +0000 (GMT)
Subject: main - mm: preallocate memory only with glibc
Message-ID: <20220830115743.69AC73854801@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8370d117d7ef8a472c95315a3cd085696c90b3be
Commit:        8370d117d7ef8a472c95315a3cd085696c90b3be
Parent:        5aa8683e8693f405d560b93a1bd8de809dc985ef
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Aug 19 16:15:17 2022 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Aug 30 13:55:52 2022 +0200

mm: preallocate memory only with glibc

Use mallinfo() only with glibc.
---
 lib/mm/memlock.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/lib/mm/memlock.c b/lib/mm/memlock.c
index f43bacdcd..4a202866a 100644
--- a/lib/mm/memlock.c
+++ b/lib/mm/memlock.c
@@ -159,7 +159,12 @@ static void _touch_memory(void *mem, size_t size)
 
 static void _allocate_memory(void)
 {
-#ifndef VALGRIND_POOL
+#if defined(__GLIBC__) && !defined(VALGRIND_POOL)
+	/* Memory allocation is currently only tested with glibc
+	 * for different C libraries, some other mechanisms might be needed
+	 * meanwhile let users use lvm2 code without memory preallocation.
+	 * Compilation for VALGRIND tracing also goes without preallocation.
+	 */
 	void *stack_mem;
 	struct rlimit limit;
 	int i, area = 0, missing = _size_malloc_tmp, max_areas = 32, hblks;

