From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 19 Nov 2014 00:14:05 +0000 (UTC)
Subject: master - cleanup: drop unused var
Message-ID: <20141119001405.F06986033B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=53d2db31c6e68c43c59a47333c16f18658ce9ea4
Commit:        53d2db31c6e68c43c59a47333c16f18658ce9ea4
Parent:        01760967b45a68f1645b797e69b28403a7823ee2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Nov 18 15:52:46 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Nov 18 16:50:49 2014 +0100

cleanup: drop unused var

---
 lib/mm/memlock.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/lib/mm/memlock.c b/lib/mm/memlock.c
index e771075..c5358dc 100644
--- a/lib/mm/memlock.c
+++ b/lib/mm/memlock.c
@@ -134,12 +134,11 @@ static void _touch_memory(void *mem, size_t size)
 static void _allocate_memory(void)
 {
 #ifndef VALGRIND_POOL
-	void *stack_mem, *temp_malloc_mem;
+	void *stack_mem;
 	struct rlimit limit;
 	int i, area = 0, missing = _size_malloc_tmp, max_areas = 32, hblks;
 	char *areas[max_areas];
 
-
 	/* Check if we could preallocate requested stack */
 	if ((getrlimit (RLIMIT_STACK, &limit) == 0) &&
 	    ((_size_stack * 2) < limit.rlim_cur) &&


