From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 25 Oct 2010 10:24:23 +0200
Subject: [PATCH 16/30] Fix void* pointer arithmetic
In-Reply-To: <cover.1287994529.git.zkabelac@redhat.com>
References: <cover.1287994529.git.zkabelac@redhat.com>
Message-ID: <b27d551f464cef87fdbf52580c9b74607e500793.1287994530.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/mm/memlock.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/mm/memlock.c b/lib/mm/memlock.c
index 3de8cc1..1e3065c 100644
--- a/lib/mm/memlock.c
+++ b/lib/mm/memlock.c
@@ -87,8 +87,8 @@ static size_t _mstats; /* statistic for maps locking */
 static void _touch_memory(void *mem, size_t size)
 {
 	size_t pagesize = lvm_getpagesize();
-	void *pos = mem;
-	void *end = mem + size - sizeof(long);
+	char *pos = mem;
+	char *end = pos + size - sizeof(long);
 
 	while (pos < end) {
 		*(long *) pos = 1;
-- 
1.7.3.1


