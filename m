From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 11 Aug 2011 17:29:06 -0000
Subject: LVM2 ./WHATS_NEW_DM ./make.tmpl.in libdm/libde ...
Message-ID: <20110811172906.25294.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-08-11 17:29:05

Modified files:
	.              : WHATS_NEW_DM make.tmpl.in 
	libdm          : libdevmapper.h 
	libdm/mm       : pool-debug.c pool-fast.c pool.c 

Log message:
	Add memory pool locking functions
	
	Adding debuging functionality to lock and unlock memory pool.
	
	2 ways to debug code:
	crc - is default checksum/hash of the locked pool.
	It gets slower when the pool is larger - so the check is only
	made when VG is finaly released and it has been used more then
	once.Thus the result is rather informative.
	
	mprotect - quite fast all the time - but requires more memory and
	currently it is using posix_memalign() - this could be
	later modified to use dm_malloc() and align internally.
	Tool segfaults when locked memory is modified and core
	could be examined for faulty code section (backtrace).
	
	Only fast memory pools could use mprotect for now -
	so such debug builds cannot be combined with DEBUG_POOL.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.488&r2=1.489
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/make.tmpl.in.diff?cvsroot=lvm2&r1=1.118&r2=1.119
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.140&r2=1.141
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/mm/pool-debug.c.diff?cvsroot=lvm2&r1=1.12&r2=1.13
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/mm/pool-fast.c.diff?cvsroot=lvm2&r1=1.13&r2=1.14
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/mm/pool.c.diff?cvsroot=lvm2&r1=1.7&r2=1.8

--- LVM2/WHATS_NEW_DM	2011/08/11 17:06:24	1.488
+++ LVM2/WHATS_NEW_DM	2011/08/11 17:29:04	1.489
@@ -1,5 +1,6 @@
 Version 1.02.66 - 
 ===============================
+  Add memory pool locking functions to aid debuging of shared VG structs.
   Remove dev name prefix from dmsetup line output if major and minor is used.
   Remove support for the original version 1 dm ioctls.
   Add missing check for allocation failure _create_dir_recursive().
--- LVM2/make.tmpl.in	2011/07/28 12:57:26	1.118
+++ LVM2/make.tmpl.in	2011/08/11 17:29:04	1.119
@@ -149,7 +149,11 @@
   DEFS += -DDM_IOCTLS
 endif
 
+# Combination of DEBUG_POOL and DEBUG_ENFORCE_POOL_LOCKING is not suppored.
 #DEFS += -DDEBUG_POOL
+# Default pool locking is using the crc checksum. With mprotect memory
+# enforcing compilation faulty memory write could be easily found.
+#DEFS += -DDEBUG_ENFORCE_POOL_LOCKING
 #DEFS += -DBOUNDS_CHECK
 
 #CFLAGS += -pg
--- LVM2/libdm/libdevmapper.h	2011/08/02 22:07:23	1.140
+++ LVM2/libdm/libdevmapper.h	2011/08/11 17:29:04	1.141
@@ -614,6 +614,22 @@
 void dm_pool_free(struct dm_pool *p, void *ptr);
 
 /*
+ * To aid debugging, a pool can be locked. Any modifications made
+ * to the content of the pool while it is locked can be detected.
+ * Default compilation is using a crc checksum to notice modifications.
+ * The pool locking is using the mprotect with the compilation flag
+ * DEBUG_ENFORCE_POOL_LOCKING to enforce the memory protection.
+ */
+/* query pool lock status */
+int dm_pool_locked(struct dm_pool *p);
+/* mark pool as locked */
+int dm_pool_lock(struct dm_pool *p, int crc)
+	__attribute__((__warn_unused_result__));
+/* mark pool as unlocked */
+int dm_pool_unlock(struct dm_pool *p, int crc)
+	__attribute__((__warn_unused_result__));
+
+/*
  * Object building routines:
  *
  * These allow you to 'grow' an object, useful for
--- LVM2/libdm/mm/pool-debug.c	2011/03/30 12:57:03	1.12
+++ LVM2/libdm/mm/pool-debug.c	2011/08/11 17:29:04	1.13
@@ -33,6 +33,8 @@
 	struct dm_list list;
 	const char *name;
 	void *orig_pool;	/* to pair it with first allocation call */
+	unsigned locked;
+	long crc;
 
 	int begun;
 	struct block *object;
@@ -71,6 +73,10 @@
 {
 	struct block *n;
 
+	if (p->locked)
+		log_error(INTERNAL_ERROR "_free_blocks from locked pool %s",
+			  p->name);
+
 	while (b) {
 		p->stats.bytes -= b->size;
 		p->stats.blocks_allocated--;
@@ -109,6 +115,10 @@
 
 static void _append_block(struct dm_pool *p, struct block *b)
 {
+	if (p->locked)
+		log_error(INTERNAL_ERROR "_append_blocks to locked pool %s",
+			  p->name);
+
 	if (p->tail) {
 		p->tail->next = b;
 		p->tail = b;
@@ -216,6 +226,10 @@
 	struct block *new;
 	size_t new_size;
 
+	if (p->locked)
+		log_error(INTERNAL_ERROR "Grow objects in locked pool %s",
+			  p->name);
+
 	if (!delta)
 		delta = strlen(extra);
 
@@ -260,3 +274,19 @@
 	p->begun = 0;
 	p->object = NULL;
 }
+
+static long _pool_crc(const struct dm_pool *p)
+{
+#ifndef DEBUG_ENFORCE_POOL_LOCKING
+#warning pool crc not implemented with pool debug
+#endif
+	return 0;
+}
+
+static int _pool_protect(struct dm_pool *p, int prot)
+{
+#ifdef DEBUG_ENFORCE_POOL_LOCKING
+#warning pool mprotect not implemented with pool debug
+#endif
+	return 1;
+}
--- LVM2/libdm/mm/pool-fast.c	2011/03/30 12:43:33	1.13
+++ LVM2/libdm/mm/pool-fast.c	2011/08/11 17:29:05	1.14
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
@@ -32,6 +33,8 @@
 	size_t chunk_size;
 	size_t object_len;
 	unsigned object_alignment;
+	int locked;
+	long crc;
 };
 
 static void _align_chunk(struct chunk *c, unsigned alignment);
@@ -260,7 +263,23 @@
 		c = p->spare_chunk;
 		p->spare_chunk = 0;
 	} else {
-		if (!(c = dm_malloc(s))) {
+#ifdef DEBUG_ENFORCE_POOL_LOCKING
+		if (!pagesize) {
+			pagesize = getpagesize(); /* lvm_pagesize(); */
+			pagesize_mask = pagesize - 1;
+		}
+		/*
+		 * Allocate page aligned size so malloc could work.
+		 * Otherwise page fault would happen from pool unrelated
+		 * memory writes of internal malloc pointers.
+		 */
+#  define aligned_malloc(s)	(posix_memalign((void**)&c, pagesize, \
+						ALIGN_ON_PAGE(s)) == 0)
+#else
+#  define aligned_malloc(s)	(c = dm_malloc(s))
+#endif /* DEBUG_ENFORCE_POOL_LOCKING */
+		if (!aligned_malloc(s)) {
+#undef aligned_malloc
 			log_error("Out of memory.  Requested %" PRIsize_t
 				  " bytes.", s);
 			return NULL;
@@ -283,3 +302,46 @@
 {
 	dm_free(c);
 }
+
+
+/**
+ * Calc crc/hash from pool's memory chunks with internal pointers
+ */
+static long _pool_crc(const struct dm_pool *p)
+{
+	long crc_hash = 0;
+#ifndef DEBUG_ENFORCE_POOL_LOCKING
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
+#endif /* DEBUG_ENFORCE_POOL_LOCKING */
+
+	return crc_hash;
+}
+
+static int _pool_protect(struct dm_pool *p, int prot)
+{
+#ifdef DEBUG_ENFORCE_POOL_LOCKING
+	struct chunk *c;
+
+	for (c = p->chunk; c; c = c->prev) {
+		if (mprotect(c, (size_t) ((c->end - (char *) c) - 1), prot) != 0) {
+			log_sys_error("mprotect", "");
+			return 0;
+		}
+	}
+#endif
+	return 1;
+}
--- LVM2/libdm/mm/pool.c	2011/03/30 12:57:03	1.7
+++ LVM2/libdm/mm/pool.c	2011/08/11 17:29:05	1.8
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004-2005 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
  *
  * This file is part of the device-mapper userspace tools.
  *
@@ -14,11 +14,31 @@
  */
 
 #include "dmlib.h"
+#include <sys/mman.h>
 
 /* FIXME: thread unsafe */
 static DM_LIST_INIT(_dm_pools);
 void dm_pools_check_leaks(void);
 
+#ifdef DEBUG_ENFORCE_POOL_LOCKING
+#ifdef DEBUG_POOL
+#error Do not use DEBUG_POOL with DEBUG_ENFORCE_POOL_LOCKING
+#endif
+
+/*
+ * Use mprotect system call to ensure all locked pages are not writable.
+ * Generates segmentation fault with write access to the locked pool.
+ *
+ * - Implementation is using posix_memalign() to get page aligned
+ *   memory blocks (could be implemented also through malloc).
+ * - Only pool-fast is properly handled for now.
+ * - Checksum is slower compared to mprotect.
+ */
+static size_t pagesize = 0;
+static size_t pagesize_mask = 0;
+#define ALIGN_ON_PAGE(size) (((size) + (pagesize_mask)) & ~(pagesize_mask))
+#endif
+
 #ifdef DEBUG_POOL
 #include "pool-debug.c"
 #else
@@ -75,3 +95,88 @@
 #endif
 	}
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
+ * Bool specifies whether to store the pool crc/hash checksum.
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
+	log_debug("Pool %s is locked.", p->name);
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
+ * Bool enables compare of the pool crc/hash with the stored value
+ * at pool lock. The pool is not properly unlocked if there is a mismatch.
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


