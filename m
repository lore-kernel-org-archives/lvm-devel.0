From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 20 Oct 2020 20:34:17 +0000 (GMT)
Subject: master - memlock: allocate at most halve of rlimit stack
Message-ID: <20201020203417.1BC393861893@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fdec4cd3e6fef08b76b410136156dbd487dad8d0
Commit:        fdec4cd3e6fef08b76b410136156dbd487dad8d0
Parent:        bd272e3bcea38a12b2b9789cfb9b7d4a9a3d3574
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 20 22:26:44 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 20 22:26:44 2020 +0200

memlock: allocate at most halve of rlimit stack

Touch of stack allocation validated given size with rlimit
and if the reserved_stack was above rlimit, its been completely
ignored - now we will always touch stack upto rlimit/2 size.
---
 lib/mm/memlock.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/lib/mm/memlock.c b/lib/mm/memlock.c
index 883795d28..0c05038fe 100644
--- a/lib/mm/memlock.c
+++ b/lib/mm/memlock.c
@@ -167,10 +167,13 @@ static void _allocate_memory(void)
 	char *areas[max_areas];
 
 	/* Check if we could preallocate requested stack */
-	if ((getrlimit (RLIMIT_STACK, &limit) == 0) &&
-	    ((_size_stack * 2) < limit.rlim_cur) &&
-	    ((stack_mem = alloca(_size_stack))))
-		_touch_memory(stack_mem, _size_stack);
+	if (getrlimit(RLIMIT_STACK, &limit) == 0) {
+		limit.rlim_cur /= 2;
+		if (_size_stack > limit.rlim_cur)
+			_size_stack = limit.rlim_cur;
+		if ((stack_mem = alloca(_size_stack)))
+			_touch_memory(stack_mem, _size_stack);
+	}
 	/* FIXME else warn user setting got ignored */
 
         /*


