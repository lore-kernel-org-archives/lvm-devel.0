From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 25 Oct 2010 10:24:36 +0200
Subject: [PATCH 29/30] Add some __attribute__ instrumentation
In-Reply-To: <cover.1287994529.git.zkabelac@redhat.com>
References: <cover.1287994529.git.zkabelac@redhat.com>
Message-ID: <f5e7e192d1da549614124cc96a5669a80feb1680.1287994530.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add some malloc intrumentation and warning attributes.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 libdm/libdevmapper.h |   26 +++++++++++++-------------
 1 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index e2f2673..9ae8bbd 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -510,13 +510,13 @@ uint32_t dm_tree_get_cookie(struct dm_tree_node *node);
  * Memory management
  *******************/
 
-void *dm_malloc_aux(size_t s, const char *file, int line);
-void *dm_malloc_aux_debug(size_t s, const char *file, int line);
-void *dm_zalloc_aux(size_t s, const char *file, int line);
-void *dm_zalloc_aux_debug(size_t s, const char *file, int line);
-char *dm_strdup_aux(const char *str, const char *file, int line);
+void *dm_malloc_aux(size_t s, const char *file, int line) __attribute__((malloc)) __attribute__((__warn_unused_result__));
+void *dm_malloc_aux_debug(size_t s, const char *file, int line) __attribute__((__warn_unused_result__));
+void *dm_zalloc_aux(size_t s, const char *file, int line)  __attribute__((malloc)) __attribute__((__warn_unused_result__));
+void *dm_zalloc_aux_debug(size_t s, const char *file, int line) __attribute__((__warn_unused_result__));
+char *dm_strdup_aux(const char *str, const char *file, int line) __attribute__((malloc)) __attribute__((__warn_unused_result__));
 void dm_free_aux(void *p);
-void *dm_realloc_aux(void *p, unsigned int s, const char *file, int line);
+void *dm_realloc_aux(void *p, unsigned int s, const char *file, int line) __attribute__((__warn_unused_result__));
 int dm_dump_memory_debug(void);
 void dm_bounds_check_debug(void);
 
@@ -579,12 +579,12 @@ void dm_bounds_check_debug(void);
 struct dm_pool;
 
 /* constructor and destructor */
-struct dm_pool *dm_pool_create(const char *name, size_t chunk_hint);
+struct dm_pool *dm_pool_create(const char *name, size_t chunk_hint) __attribute__((__warn_unused_result__));
 void dm_pool_destroy(struct dm_pool *p);
 
 /* simple allocation/free routines */
-void *dm_pool_alloc(struct dm_pool *p, size_t s);
-void *dm_pool_alloc_aligned(struct dm_pool *p, size_t s, unsigned alignment);
+void *dm_pool_alloc(struct dm_pool *p, size_t s) __attribute__((__warn_unused_result__));
+void *dm_pool_alloc_aligned(struct dm_pool *p, size_t s, unsigned alignment) __attribute__((__warn_unused_result__));
 void dm_pool_empty(struct dm_pool *p);
 void dm_pool_free(struct dm_pool *p, void *ptr);
 
@@ -639,9 +639,9 @@ void *dm_pool_end_object(struct dm_pool *p);
 void dm_pool_abandon_object(struct dm_pool *p);
 
 /* utilities */
-char *dm_pool_strdup(struct dm_pool *p, const char *str);
-char *dm_pool_strndup(struct dm_pool *p, const char *str, size_t n);
-void *dm_pool_zalloc(struct dm_pool *p, size_t s);
+char *dm_pool_strdup(struct dm_pool *p, const char *str) __attribute__((__warn_unused_result__));
+char *dm_pool_strndup(struct dm_pool *p, const char *str, size_t n) __attribute__((__warn_unused_result__));
+void *dm_pool_zalloc(struct dm_pool *p, size_t s) __attribute__((__warn_unused_result__));
 
 /******************
  * bitset functions
@@ -699,7 +699,7 @@ struct dm_hash_node;
 
 typedef void (*dm_hash_iterate_fn) (void *data);
 
-struct dm_hash_table *dm_hash_create(unsigned size_hint);
+struct dm_hash_table *dm_hash_create(unsigned size_hint) __attribute__((__warn_unused_result__));
 void dm_hash_destroy(struct dm_hash_table *t);
 void dm_hash_wipe(struct dm_hash_table *t);
 
-- 
1.7.3.1


