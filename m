From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 20 Jun 2012 12:49:15 +0000 (UTC)
Subject: master - headers: add some __attribute__ instrumentation
Message-ID: <20120620124915.6BF641684@lists.fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ac8a931889d796cf1e74b7c38ee6fb201ae2963b
Commit:        ac8a931889d796cf1e74b7c38ee6fb201ae2963b
Parent:        ba222c6e35dd08d7e3665b187eacdd61e6f678d4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 25 09:39:36 2010 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jun 20 14:48:11 2012 +0200

headers: add some __attribute__ instrumentation

Use some malloc and strdup instrumentation and warning attributes
and standard systems headers.
---
 libdm/libdevmapper.h |   39 ++++++++++++++++++++++++++-------------
 1 files changed, 26 insertions(+), 13 deletions(-)

diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 1f780a3..a8bf885 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -713,13 +713,19 @@ uint32_t dm_tree_get_cookie(struct dm_tree_node *node);
  * Memory management
  *******************/
 
-void *dm_malloc_aux(size_t s, const char *file, int line);
-void *dm_malloc_aux_debug(size_t s, const char *file, int line);
-void *dm_zalloc_aux(size_t s, const char *file, int line);
-void *dm_zalloc_aux_debug(size_t s, const char *file, int line);
-char *dm_strdup_aux(const char *str, const char *file, int line);
+void *dm_malloc_aux(size_t s, const char *file, int line)
+	__attribute__((malloc)) __attribute__((__warn_unused_result__));
+void *dm_malloc_aux_debug(size_t s, const char *file, int line)
+	__attribute__((__warn_unused_result__));
+void *dm_zalloc_aux(size_t s, const char *file, int line)
+	__attribute__((malloc)) __attribute__((__warn_unused_result__));
+void *dm_zalloc_aux_debug(size_t s, const char *file, int line)
+	__attribute__((__warn_unused_result__));
+char *dm_strdup_aux(const char *str, const char *file, int line)
+	__attribute__((malloc)) __attribute__((__warn_unused_result__));
 void dm_free_aux(void *p);
-void *dm_realloc_aux(void *p, unsigned int s, const char *file, int line);
+void *dm_realloc_aux(void *p, unsigned int s, const char *file, int line)
+	__attribute__((__warn_unused_result__));
 int dm_dump_memory_debug(void);
 void dm_bounds_check_debug(void);
 
@@ -782,12 +788,15 @@ void dm_bounds_check_debug(void);
 struct dm_pool;
 
 /* constructor and destructor */
-struct dm_pool *dm_pool_create(const char *name, size_t chunk_hint);
+struct dm_pool *dm_pool_create(const char *name, size_t chunk_hint)
+	__attribute__((__warn_unused_result__));
 void dm_pool_destroy(struct dm_pool *p);
 
 /* simple allocation/free routines */
-void *dm_pool_alloc(struct dm_pool *p, size_t s);
-void *dm_pool_alloc_aligned(struct dm_pool *p, size_t s, unsigned alignment);
+void *dm_pool_alloc(struct dm_pool *p, size_t s)
+	__attribute__((__warn_unused_result__));
+void *dm_pool_alloc_aligned(struct dm_pool *p, size_t s, unsigned alignment)
+	__attribute__((__warn_unused_result__));
 void dm_pool_empty(struct dm_pool *p);
 void dm_pool_free(struct dm_pool *p, void *ptr);
 
@@ -858,9 +867,12 @@ void *dm_pool_end_object(struct dm_pool *p);
 void dm_pool_abandon_object(struct dm_pool *p);
 
 /* utilities */
-char *dm_pool_strdup(struct dm_pool *p, const char *str);
-char *dm_pool_strndup(struct dm_pool *p, const char *str, size_t n);
-void *dm_pool_zalloc(struct dm_pool *p, size_t s);
+char *dm_pool_strdup(struct dm_pool *p, const char *str)
+	__attribute__((__warn_unused_result__));
+char *dm_pool_strndup(struct dm_pool *p, const char *str, size_t n)
+	__attribute__((__warn_unused_result__));
+void *dm_pool_zalloc(struct dm_pool *p, size_t s)
+	__attribute__((__warn_unused_result__));
 
 /******************
  * bitset functions
@@ -918,7 +930,8 @@ struct dm_hash_node;
 
 typedef void (*dm_hash_iterate_fn) (void *data);
 
-struct dm_hash_table *dm_hash_create(unsigned size_hint);
+struct dm_hash_table *dm_hash_create(unsigned size_hint)
+	__attribute__((__warn_unused_result__));
 void dm_hash_destroy(struct dm_hash_table *t);
 void dm_hash_wipe(struct dm_hash_table *t);
 


