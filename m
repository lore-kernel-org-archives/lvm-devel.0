From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 22 Mar 2011 22:21:55 +0100
Subject: [PATCH 1/6] Pool locking code
In-Reply-To: <cover.1300828168.git.zkabelac@redhat.com>
References: <cover.1300828168.git.zkabelac@redhat.com>
Message-ID: <d2353d5f9081b6eed91ed788af173ddf88dd4bba.1300828168.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Adding specific functions to lock and unlock pool, to modify
specific uint64_t*, and to revert all modified uint64_t back.

Current API is the result of several iterations I've made.

To avoid some more rewrites in case this API would still require some
changes - only pool-fast are currently fully updated for this API.

2 ways to debug code:
mprotect - quite fast all the time - but requires more memory and
           currently it is using posix_memalign - this would be
	   later modified to use dm_malloc() and align internally.

crc - checksum of locked pool - implemented via quick simple hash.
      But even this gets quite slow when the pool has bigger size -
      thus it's not very effiecient to check with every restore,
      so the check is made only when reused VG is released.

Probably needs some disscusion where to move futher...

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 libdm/libdevmapper.h  |   11 ++
 libdm/mm/pool-debug.c |    9 ++
 libdm/mm/pool-fast.c  |   74 ++++++++++++++-
 libdm/mm/pool.c       |  246 ++++++++++++++++++++++++++++++++++++++++++++++++-
 4 files changed, 337 insertions(+), 3 deletions(-)

diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 88bddb1..a0bed97 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -594,6 +594,17 @@ void *dm_pool_alloc_aligned(struct dm_pool *p, size_t s, unsigned alignment);
 void dm_pool_empty(struct dm_pool *p);
 void dm_pool_free(struct dm_pool *p, void *ptr);
 
+/* prevent modification of pool */
+int dm_pool_locked(struct dm_pool *p);
+int dm_pool_lock(struct dm_pool *p, unsigned count)
+	__attribute__((__warn_unused_result__));
+int dm_pool_unlock(struct dm_pool *p)
+	__attribute__((__warn_unused_result__));
+int dm_pool_set_uint64(struct dm_pool *p, uint64_t *addr, uint64_t new_value)
+	__attribute__((__warn_unused_result__));
+int dm_pool_restore(struct dm_pool *p, int check_crc)
+	__attribute__((__warn_unused_result__));
+
 /*
  * Object building routines:
  *
diff --git a/libdm/mm/pool-debug.c b/libdm/mm/pool-debug.c
index fd931e4..206dd84 100644
--- a/libdm/mm/pool-debug.c
+++ b/libdm/mm/pool-debug.c
@@ -33,6 +33,7 @@ struct dm_pool {
 	struct dm_list list;
 	const char *name;
 	void *orig_pool;	/* to pair it with first allocation call */
+	unsigned locked;
 
 	int begun;
 	struct block *object;
@@ -81,6 +82,8 @@ static void _free_blocks(struct dm_pool *p, struct block *b)
 {
 	struct block *n;
 
+	assert(!p->locked);
+
 	while (b) {
 		p->stats.bytes -= b->size;
 		p->stats.blocks_allocated--;
@@ -94,6 +97,8 @@ static void _free_blocks(struct dm_pool *p, struct block *b)
 
 static void _pool_stats(struct dm_pool *p, const char *action)
 {
+	assert(!p->locked);
+
 #ifdef DEBUG_POOL
 	log_debug("%s mempool %s: %u/%u bytes, %u/%u blocks, "
 		  "%u allocations)", action, p->name, p->stats.bytes,
@@ -119,6 +124,8 @@ void *dm_pool_alloc(struct dm_pool *p, size_t s)
 
 static void _append_block(struct dm_pool *p, struct block *b)
 {
+	assert(!p->locked);
+
 	if (p->tail) {
 		p->tail->next = b;
 		p->tail = b;
@@ -226,6 +233,8 @@ int dm_pool_grow_object(struct dm_pool *p, const void *extra, size_t delta)
 	struct block *new;
 	size_t new_size;
 
+	assert(!p->locked);
+
 	if (!delta)
 		delta = strlen(extra);
 
diff --git a/libdm/mm/pool-fast.c b/libdm/mm/pool-fast.c
index 29d61a4..5d2643f 100644
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
@@ -18,6 +18,8 @@
 #endif
 
 #include "dmlib.h"
+#include <sys/mman.h>
+#include <malloc.h>
 
 struct chunk {
 	char *begin, *end;
@@ -32,6 +34,10 @@ struct dm_pool {
 	size_t chunk_size;
 	size_t object_len;
 	unsigned object_alignment;
+	int locked;
+	long crc;
+	uint64_t *volatile_mem;
+	unsigned volatile_count;
 };
 
 static void _align_chunk(struct chunk *c, unsigned alignment);
@@ -74,6 +80,7 @@ void dm_pool_destroy(struct dm_pool *p)
 	}
 
 	dm_list_del(&p->list);
+	dm_free(p->volatile_mem);
 	dm_free(p);
 }
 
@@ -254,17 +261,37 @@ static struct chunk *_new_chunk(struct dm_pool *p, size_t s)
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
+		/* mem for internals */
+		if (!aligned_malloc(s)) {
+#undef aligned_malloc
 			log_error("Out of memory.  Requested %" PRIsize_t
 				  " bytes.", s);
 			return NULL;
 		}
+		//log_error("RESET  %p  %p %d  a:%d", c, c + s, (int)s, (int)ALIGN_ON_PAGE(s));
 
 		c->begin = (char *) (c + 1);
 		c->end = (char *) c + s;
@@ -283,3 +310,46 @@ static void _free_chunk(struct chunk *c)
 {
 	dm_free(c);
 }
+
+/*
+ * Calc hash from pool memory chunks with internal pointers
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
+		//log_error("protecting %d %p  0x%x", prot, c, (int) ((char*)c->end - (char*)c) - 1);
+		if (mprotect(c, (size_t) ((c->end - (char *) c) - 1), prot) != 0) {
+			log_sys_error("mprotect", "");
+			return 0;
+		}
+	}
+#endif
+	return 1;
+}
diff --git a/libdm/mm/pool.c b/libdm/mm/pool.c
index 608826b..9f036a8 100644
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
@@ -15,10 +15,33 @@
 
 #include "dmlib.h"
 
+/*
+ * Use mprotect system call to ensure all locked pages are not writeable
+ * Generates segmentation fault with write access to locked pool.
+ *
+ * 1. Implementation is using posix_memalign() to get page aligned
+ *    memory blocks (could be implemented also through malloc)
+ *
+ * 2. Only pool-fast is properly handle for now
+ *
+ * 3. As all pools could be locked now - using this aligned malloc for
+ *    each pool - this is not memory effiecient
+ *
+ * 4. Checksum is quite slow compared to mprotect if it would be performed
+ *    with every restore operation.
+ */
+#define DEBUG_USE_MPROTECT 1
+
 /* FIXME: thread unsafe */
 static DM_LIST_INIT(_dm_pools);
 void dm_pools_check_leaks(void);
 
+#ifdef DEBUG_USE_MPROTECT
+static size_t pagesize = 0;
+static size_t pagesize_mask = 0;
+#define ALIGN_ON_PAGE(size) (((size) + (pagesize_mask)) & ~(pagesize_mask))
+#endif
+
 #ifdef DEBUG_POOL
 #include "pool-debug.c"
 #else
@@ -75,3 +98,224 @@ void dm_pools_check_leaks(void)
 #endif
 	}
 }
+
+/**
+ * Status of locked pool.
+ *
+ * \param p
+ * Pool to be locked.
+ *
+ * \return
+ * 1 (success) when the pool is locked, 0 otherwise.
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
+ * \param count
+ * Specifies the amount of 64bit pairs to be placed in
+ * volatile exception store. When count is 0, pool is
+ * locked without reallocation of exception store and
+ * crc recomputation. This is useful for temporal pool
+ * unlocking and locking.
+ *
+ * \return
+ * 1 (success) when the pool was preperly locked, 0 otherwise.
+ */
+int dm_pool_lock(struct dm_pool *p, unsigned count)
+{
+	if (p->locked) {
+		log_error(INTERNAL_ERROR "Pool is already locked.");
+		return 0;
+	}
+
+	if (count) {
+		if (count != p->volatile_count) {
+			dm_free(p->volatile_mem);
+
+			if (!(p->volatile_mem = dm_malloc(2 * sizeof(uint64_t) * (count + 1)))) {
+				log_error("Failed to allocate exception store for pool.");
+				return 0;
+			}
+
+			p->volatile_count = count;
+		}
+
+		p->volatile_mem[0] = 0; /* Reset volatile buffer */
+		p->crc = _pool_crc(p);  /* Get crc for pool */
+	} else if (!p->volatile_count) {
+		log_error(INTERNAL_ERROR "Pool locking without exception store specified.");
+		return 0;
+	}
+
+	if (!_pool_protect(p, PROT_READ)) {
+		_pool_protect(p, PROT_READ | PROT_WRITE);
+		return_0;
+	}
+
+	p->locked = 1;
+
+	log_debug("Pool %p locked.", p);
+
+	return 1;
+}
+
+/**
+ * Unlock memory pool.
+ *
+ * \param p
+ * Pool to be unlocked
+ *
+ * \return
+ * 1 (success) when the pool was properly locked, 0 otherwise.
+ */
+int dm_pool_unlock(struct dm_pool *p)
+{
+	if (!p->locked) {
+		log_error(INTERNAL_ERROR "Pool is already unlocked.");
+		return 0;
+	}
+
+	p->locked = 0;
+
+	if (!_pool_protect(p, PROT_READ | PROT_WRITE))
+		return_0;
+
+	log_debug("Pool %p unlocked.", p);
+
+	return 1;
+}
+
+static int _mprotect_addr(uint64_t *addr, int prot)
+{
+#ifdef DEBUG_USE_MPROTECT
+	int bounds = (((long) addr & (pagesize_mask)) < (pagesize - 8))
+		? pagesize_mask : pagesize_mask + pagesize;
+
+	if (mprotect((void *) ((long) addr & ~pagesize_mask), bounds, prot)
+		    != 0) {
+		log_sys_error("mprotect", (prot == PROT_READ) ? "READ" : "WRITE");
+		return 0;
+	}
+#endif
+	return 1;
+}
+
+/**
+ * Modify uint64_t value in pool
+ *
+ * \param p
+ * Pool which constains modified address.
+ *
+ * \param addr
+ * Address of the modified value. Original content is saved in exception store.
+ *
+ * \param d
+ * New value to be set.
+ *
+ * \return
+ * 1 (success) if the value was updated, 0 otherwise.
+ *
+ * TODO:
+ *  More advanced algorithm would be needed if the exception
+ *  area size grows to so large number of pairs.
+ *  Currently it also appears to be enough to handle just 64bit pairs.
+ */
+int dm_pool_set_uint64(struct dm_pool *p, uint64_t *addr, uint64_t d)
+{
+	unsigned i;
+
+	if (!p->locked) {
+		*addr = d;
+		return 1;
+	}
+
+	for (i = 0; p->volatile_mem[i] != (uint64_t) addr; i += 2)
+		if (!p->volatile_mem[i]) {
+			/* Add new address and original value to exception store */
+			if ((i + 2) >= (p->volatile_count * 2)) {
+				log_error(INTERNAL_ERROR
+					  "Exception store with %u size is full.",
+					  (unsigned) p->volatile_count);
+				return 0;
+			}
+
+			log_debug("Saving protected %u: %p %" PRIu64
+				  "  -> %" PRIu64 ".", (unsigned) i / 2,
+				  addr, *addr, d);
+			p->volatile_mem[i] = (uint64_t) addr;
+			p->volatile_mem[i + 1] = *addr;
+			p->volatile_mem[i + 2] = 0;
+			break;
+		}
+
+	if (!_mprotect_addr(addr, PROT_READ | PROT_WRITE))
+		return_0;
+
+	log_debug("Changing protected: %p %" PRIu64 "  -> %" PRIu64 ".",
+		  addr, *addr, d);
+	*addr = d;
+
+	if (!_mprotect_addr(addr, PROT_READ))
+		return_0;
+
+	return 1;
+}
+
+/**
+ * Restore original content in pool and checks whether
+ * it is matching the crc calculated at pool lock.
+ *
+ * \param p
+ * Locked pool to be restored.
+ *
+ * \param check_crc
+ * Boolean whether to check crc after restore.
+ * Checksum of larger pool size is slow.
+ *
+ * \return
+ * 1 (success) if the restore was successful, 0 otherwise.
+ */
+int dm_pool_restore(struct dm_pool *p, int check_crc)
+{
+	unsigned i;
+
+	if (!p->locked) {
+		log_error(INTERNAL_ERROR "Restore of unlocked pool.");
+		return 0;
+	}
+
+	/* Unlock all pages for modified addresses */
+	for (i = 0; p->volatile_mem[i]; i += 2)
+		if (!_mprotect_addr((uint64_t *)(long)p->volatile_mem[i],
+				    PROT_READ | PROT_WRITE))
+			return_0;
+
+	/* Restore saved values from exception store */
+	for (i = 0; p->volatile_mem[i]; i += 2) {
+		log_debug("Restoring %u 0x%" PRIx64 " = %" PRIu64 ".", i / 2,
+			  p->volatile_mem[i], p->volatile_mem[i + 1]);
+		((uint64_t *)(long)p->volatile_mem[i])[0] = p->volatile_mem[i + 1];
+	}
+
+	/* Lock again modified pages */
+	for (i = 0; p->volatile_mem[i]; i += 2)
+		if (!_mprotect_addr((uint64_t *)p->volatile_mem[i], PROT_READ))
+			return_0;
+
+	p->volatile_mem[0] = 0;
+
+	if (check_crc && p->crc != _pool_crc(p)) {
+		log_error(INTERNAL_ERROR "Pool content was modified.");
+		return 0;
+	}
+
+	return 1;
+}
-- 
1.7.4.1


