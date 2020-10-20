From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 20 Oct 2020 21:25:11 +0000 (GMT)
Subject: stable-2.02 - memlock: allocate at most halve of rlimit stack
Message-ID: <20201020212511.1EC3B3950C27@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9690193ce08854c56663bcbbe7da4c720c78be07
Commit:        9690193ce08854c56663bcbbe7da4c720c78be07
Parent:        511cd6adb7756301ca0a2c2b153696a71a3f4423
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 20 22:26:44 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 20 22:49:55 2020 +0200

memlock: allocate at most halve of rlimit stack

Touch of stack allocation validated given size with rlimit
and if the reserved_stack was above rlimit, its been completely
ignored - now we will always touch stack upto rlimit/2 size.
---
 lib/mm/memlock.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/lib/mm/memlock.c b/lib/mm/memlock.c
index 7eee399b4..b1e5eb91b 100644
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


