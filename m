From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri,  3 Jun 2011 21:13:27 +0200
Subject: [PATCH 09/11] Pool locking code
In-Reply-To: <cover.1307127169.git.zkabelac@redhat.com>
References: <cover.1307127169.git.zkabelac@redhat.com>
Message-ID: <a28f93e0b85bfb216a8d12cfde9f97884713e206.1307127169.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Adding specific functions to lock and unlock memory pool.

To avoid some more rewrites in case this API would still require some
changes - only pool-fast is currently fully updated for this API.

2 ways to debug code:
mprotect - quite fast all the time - but requires more memory and
           currently it is using posix_memalign - this would be
	   later modified to use dm_malloc() and align internally.
           Tool segfault when locked memory is modified.

crc - checksum of locked pool - implemented via quick simple hash.
      But even this gets quite slow when the pool it larger -
      so the check is only made only VG is finaly released and
      it has been used more then once.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 libdm/libdevmapper.h  |    7 +++
 libdm/mm/pool-debug.c |   27 ++++++++++++
 libdm/mm/pool-fast.c  |   70 +++++++++++++++++++++++++++++++-
 libdm/mm/pool.c       |  106 ++++++++++++++++++++++++++++++++++++++++++++++++-
 make.tmpl.in          |    2 +
 5 files changed, 209 insertions(+), 3 deletions(-)

diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 88bddb1..2915860 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -594,6 +594,13 @@ void *dm_pool_alloc_aligned(struct dm_pool *p, size_t s, unsigned alignment);
 void dm_pool_empty(struct dm_pool *p);
 void dm_pool_free(struct dm_pool *p, void *ptr);
 
+/* pool locking routines */
+int dm_pool_locked(struct dm_pool *p);
+int dm_pool_lock(struct dm_pool *p, int crc)
+	__attribute__((__warn_unused_result__));
+int dm_pool_unlock(struct dm_pool *p, int crc)
+	__attribute__((__warn_unused_result__));
+
 /*
  * Object building routines:
  *
diff --git a/libdm/mm/pool-debug.c b/libdm/mm/pool-debug.c
index af1a912..d8c19d4 100644
--- a/libdm/mm/pool-debug.c
+++ b/libdm/mm/pool-debug.c
@@ -33,6 +33,8 @@ struct dm_pool {
 	struct dm_list list;
 	const char *name;
 	void *orig_pool;	/* to pair it with first allocation call */
+	unsigned locked;
+	long crc;
 
 	int begun;
 	struct block *object;
@@ -71,6 +73,8 @@ static void _free_blocks(struct dm_pool *p, struct block *b)
 {
 	struct block *n;
 
+	assert(!p->locked);
+
 	while (b) {
 		p->stats.bytes -= b->size;
 		p->stats.blocks_allocated--;
@@ -84,6 +88,8 @@ static void _free_blocks(struct dm_pool *p, struct block *b)
 
 static void _pool_stats(struct dm_pool *p, const char *action)
 {
+	assert(!p->locked);
+
 #ifdef DEBUG_POOL
 	log_debug("%s mempool %s: %u/%u bytes, %u/%u blocks, "
 		  "%u allocations)", action, p->name, p->stats.bytes,
@@ -99,6 +105,7 @@ void dm_pool_destroy(struct dm_pool *p)
 	_pool_stats(p, "Destroying");
 	_free_blocks(p, p->blocks);
 	dm_list_del(&p->list);
+	dm_free(p->volatile_mem);
 	dm_free(p);
 }
 
@@ -109,6 +116,8 @@ void *dm_pool_alloc(struct dm_pool *p, size_t s)
 
 static void _append_block(struct dm_pool *p, struct block *b)
 {
+	assert(!p->locked);
+
 	if (p->tail) {
 		p->tail->next = b;
 		p->tail = b;
@@ -216,6 +225,8 @@ int dm_pool_grow_object(struct dm_pool *p, const void *extra, size_t delta)
 	struct block *new;
 	size_t new_size;
 
+	assert(!p->locked);
+
 	if (!delta)
 		delta = strlen(extra);
 
@@ -260,3 +271,19 @@ void dm_pool_abandon_object(struct dm_pool *p)
 	p->begun = 0;
 	p->object = NULL;
 }
+
+static long _pool_crc(const struct dm_pool *p)
+{
+#ifndef DEBUG_USE_MPROTECT
+#warning pool crc not implemented with pool debug
+#endif
+	return 0;
+}
+
+static int _pool_protect(struct dm_pool *p, int prot)
+{
+#ifdef DEBUG_USE_MPROTECT
+#warning pool mprotect not implemented with pool debug
+#endif
+	return 1;
+}
diff --git a/libdm/mm/pool-fast.c b/libdm/mm/pool-fast.c
index 29d61a4..75d7f24 100644
--- a/libdm/mm/pool-fast.c
+++ b/libdm/mm/pool-fast.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2010 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
  *
  * This file is part of the device-mapper userspace tools.
  *
@@ -18,6 +18,7 @@
 #endif
 
 #include "dmlib.h"
+#include <malloc.h>
 
 struct chunk {
 	char *begin, *end;
@@ -32,6 +33,8 @@ struct dm_pool {
 	size_t chunk_size;
 	size_t object_len;
 	unsigned object_alignment;
+	int locked;
+	long crc;
 };
 
 static void _align_chunk(struct chunk *c, unsigned alignment);
@@ -254,17 +257,36 @@ static struct chunk *_new_chunk(struct dm_pool *p, size_t s)
 {
 	struct chunk *c;
 
+#ifdef DEBUG_USE_MPROTECT
+	if (!pagesize) {
+		pagesize = getpagesize(); // lvm_pagesize();
+		pagesize_mask = pagesize - 1;
+	}
+#endif
 	if (p->spare_chunk &&
 	    ((p->spare_chunk->end - p->spare_chunk->begin) >= s)) {
 		/* reuse old chunk */
 		c = p->spare_chunk;
 		p->spare_chunk = 0;
 	} else {
-		if (!(c = dm_malloc(s))) {
+#ifdef DEBUG_USE_MPROTECT
+		/*
+		 * Allocate page aligned size so malloc could work.
+		 * Otherwise page fault would happen from pool unrelated
+		 * memory writes of internal malloc pointers.
+                 */
+#define aligned_malloc(s)   (posix_memalign((void**)&c, pagesize, \
+					    ALIGN_ON_PAGE(s)) == 0)
+#else
+#define aligned_malloc(s)   (c = dm_malloc(s))
+#endif
+		if (!aligned_malloc(s)) {
+#undef aligned_malloc
 			log_error("Out of memory.  Requested %" PRIsize_t
 				  " bytes.", s);
 			return NULL;
 		}
+		//log_debug("RESET  %p  %p %d  a:%d", c, c + s, (int)s, (int)ALIGN_ON_PAGE(s));
 
 		c->begin = (char *) (c + 1);
 		c->end = (char *) c + s;
@@ -283,3 +305,47 @@ static void _free_chunk(struct chunk *c)
 {
 	dm_free(c);
 }
+
+
+/**
+ * Calc crc/hash from pools' memory chunks with internal pointers
+ */
+static long _pool_crc(const struct dm_pool *p)
+{
+	long crc_hash = 0;
+#ifndef DEBUG_USE_MPROTECT
+	const struct chunk *c;
+	const long *ptr, *end;
+
+	for (c = p->chunk; c; c = c->prev) {
+		end = (const long *) (c->begin < c->end ? (long) c->begin & ~7: (long) c->end);
+		ptr = (const long *) c;
+#ifdef VALGRIND_POOL
+		VALGRIND_MAKE_MEM_DEFINED(ptr, (end - ptr) * sizeof(*end));
+#endif
+		while (ptr < end) {
+			crc_hash += *ptr++;
+			crc_hash += (crc_hash << 10);
+			crc_hash ^= (crc_hash >> 6);
+		}
+	}
+#endif
+
+	return crc_hash;
+}
+
+static int _pool_protect(struct dm_pool *p, int prot)
+{
+#ifdef DEBUG_USE_MPROTECT
+	struct chunk *c;
+
+	for (c = p->chunk; c; c = c->prev) {
+		//log_debug("protecting %d %p  0x%x", prot, c, (int) ((char*)c->end - (char*)c) - 1);
+		if (mprotect(c, (size_t) ((c->end - (char *) c) - 1), prot) != 0) {
+			log_sys_error("mprotect", "");
+			return 0;
+		}
+	}
+#endif
+	return 1;
+}
diff --git a/libdm/mm/pool.c b/libdm/mm/pool.c
index 3df6071..48740bc 100644
--- a/libdm/mm/pool.c
+++ b/libdm/mm/pool.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004-2005 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
  *
  * This file is part of the device-mapper userspace tools.
  *
@@ -14,11 +14,30 @@
  */
 
 #include "dmlib.h"
+#include <sys/mman.h>
 
 /* FIXME: thread unsafe */
 static DM_LIST_INIT(_dm_pools);
 void dm_pools_check_leaks(void);
 
+#ifdef DEBUG_USE_MPROTECT
+/*
+ * Use mprotect system call to ensure all locked pages are not writeable
+ * Generates segmentation fault with write access to the locked pool.
+ *
+ * - Implementation is using posix_memalign() to get page aligned
+ *   memory blocks (could be implemented also through malloc).
+ * - Only pool-fast is properly handled for now.
+ * - As all pools could be locked now - using this aligned malloc for
+ *   each pool - this is not memory efficient.
+ * - Checksum is quite slow compared to mprotect.
+ */
+
+static size_t pagesize = 0;
+static size_t pagesize_mask = 0;
+#define ALIGN_ON_PAGE(size) (((size) + (pagesize_mask)) & ~(pagesize_mask))
+#endif
+
 #ifdef DEBUG_POOL
 #include "pool-debug.c"
 #else
@@ -76,3 +95,88 @@ void dm_pools_check_leaks(void)
 	}
 	log_error(INTERNAL_ERROR "Unreleased memory pool(s) found.");
 }
+
+/**
+ * Status of locked pool.
+ *
+ * \param p
+ * Pool to be tested for lock status.
+ *
+ * \return
+ * 1 when the pool is locked, 0 otherwise.
+ */
+int dm_pool_locked(struct dm_pool *p)
+{
+	return p->locked;
+}
+
+/**
+ * Lock memory pool.
+ *
+ * \param p
+ * Pool to be locked.
+ *
+ * \param crc
+ * Specifies whether to save crc/hash checksum.
+ *
+ * \return
+ * 1 (success) when the pool was preperly locked, 0 otherwise.
+ */
+int dm_pool_lock(struct dm_pool *p, int crc)
+{
+	if (p->locked) {
+		log_error(INTERNAL_ERROR "Pool %s is already locked.",
+			  p->name);
+		return 0;
+	}
+
+	if (crc)
+		p->crc = _pool_crc(p);  /* Get crc for pool */
+
+	if (!_pool_protect(p, PROT_READ)) {
+		_pool_protect(p, PROT_READ | PROT_WRITE);
+		return_0;
+	}
+
+	p->locked = 1;
+
+	log_debug("Pool %s locked.", p->name);
+
+	return 1;
+}
+
+/**
+ * Unlock memory pool.
+ *
+ * \param p
+ * Pool to be unlocked.
+ *
+ * \param crc
+ * Compare crc/hash with saved value. If there is mismatch,
+ * pool is not properly unlocked.
+ *
+ * \return
+ * 1 (success) when the pool was properly unlocked, 0 otherwise.
+ */
+int dm_pool_unlock(struct dm_pool *p, int crc)
+{
+	if (!p->locked) {
+		log_error(INTERNAL_ERROR "Pool %s is already unlocked.",
+			  p->name);
+		return 0;
+	}
+
+	p->locked = 0;
+
+	if (!_pool_protect(p, PROT_READ | PROT_WRITE))
+		return_0;
+
+	log_debug("Pool %s is unlocked.", p->name);
+
+	if (crc && (p->crc != _pool_crc(p))) {
+		log_error(INTERNAL_ERROR "Pool %s crc mismatch.", p->name);
+		return 0;
+	}
+
+	return 1;
+}
diff --git a/make.tmpl.in b/make.tmpl.in
index cd8ae35..d52f7ca 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -149,6 +149,8 @@ ifeq ("@DM_IOCTLS@", "yes")
 endif
 
 #DEFS += -DDEBUG_POOL
+# do not use DEBUG_POOL and DEBUG_USE_MPROTECT at the same time
+#DEFS += -DDEBUG_USE_MPROTECT
 #DEFS += -DBOUNDS_CHECK
 
 #CFLAGS += -pg
-- 
1.7.5.2


