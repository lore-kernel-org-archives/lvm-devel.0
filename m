From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 25 Mar 2011 22:57:47 +0100
Subject: [PATCH 3/3] Valgrind updates
In-Reply-To: <cover.1301089240.git.zkabelac@redhat.com>
References: <cover.1301089240.git.zkabelac@redhat.com>
Message-ID: <89689aabdf5f6a7f446b4fe4522e76e159499725.1301089240.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Avoid locking sum with valgrind compilation.

Make memory unaccessible in valgrind for dm_pool_abadon_object.

Valgrind hinting should not be needed in _free_chunk for dm_free.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/mm/memlock.c     |    3 +++
 libdm/mm/pool-fast.c |   11 ++++-------
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/lib/mm/memlock.c b/lib/mm/memlock.c
index 3e472bd..0e8f585 100644
--- a/lib/mm/memlock.c
+++ b/lib/mm/memlock.c
@@ -195,6 +195,9 @@ static int _maps_line(const struct config_node *cn, lvmlock_t lock,
 		}
 	}
 
+#ifdef VALGRIND_POOL
+	sz -= sz;  /* memory sum doesn't work with valgrind */
+#endif
 	*mstats += sz;
 	log_debug("%s %10ldKiB %12lx - %12lx %c%c%c%c%s",
 		  (lock == LVM_MLOCK) ? "mlock" : "munlock",
diff --git a/libdm/mm/pool-fast.c b/libdm/mm/pool-fast.c
index 377ad99..b651449 100644
--- a/libdm/mm/pool-fast.c
+++ b/libdm/mm/pool-fast.c
@@ -238,6 +238,9 @@ void *dm_pool_end_object(struct dm_pool *p)
 
 void dm_pool_abandon_object(struct dm_pool *p)
 {
+#ifdef VALGRIND_POOL
+	VALGRIND_MAKE_MEM_NOACCESS(p->chunk, p->object_len);
+#endif
 	p->object_len = 0;
 	p->object_alignment = DEFAULT_ALIGNMENT;
 }
@@ -278,11 +281,5 @@ static struct chunk *_new_chunk(struct dm_pool *p, size_t s)
 
 static void _free_chunk(struct chunk *c)
 {
-	if (c) {
-#ifdef VALGRIND_POOL
-		VALGRIND_MAKE_MEM_UNDEFINED(c, c->end - (char *) c);
-#endif
-
-		dm_free(c);
-	}
+	dm_free(c);
 }
-- 
1.7.4.1


