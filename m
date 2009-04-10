From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 10 Apr 2009 09:56:59 -0000
Subject: LVM2 ./WHATS_NEW libdm/ioctl/libdm-iface.c lib ...
Message-ID: <20090410095659.18696.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-04-10 09:56:59

Modified files:
	.              : WHATS_NEW 
	libdm/ioctl    : libdm-iface.c 
	libdm/mm       : pool-debug.c pool-fast.c pool.c 

Log message:
	Helper function to catch memory pool leaks.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1084&r2=1.1085
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.56&r2=1.57
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/mm/pool-debug.c.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/mm/pool-fast.c.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/mm/pool.c.diff?cvsroot=lvm2&r1=1.4&r2=1.5

--- LVM2/WHATS_NEW	2009/04/10 09:56:00	1.1084
+++ LVM2/WHATS_NEW	2009/04/10 09:56:58	1.1085
@@ -1,5 +1,6 @@
 Version 2.02.46 - 
 ================================
+  Add memory pool leaks detection.
   Use copy of PV structure when manipulating with global PV lists.
   Always return exit error status when locking of volume group fails.
   Fix mirror log convert validation question.
--- LVM2/libdm/ioctl/libdm-iface.c	2009/02/12 20:42:07	1.56
+++ LVM2/libdm/ioctl/libdm-iface.c	2009/04/10 09:56:58	1.57
@@ -1817,12 +1817,15 @@
 	update_devs();
 }
 
+void dm_pools_check_leaks(void);
+
 void dm_lib_exit(void)
 {
 	dm_lib_release();
 	if (_dm_bitset)
 		dm_bitset_destroy(_dm_bitset);
 	_dm_bitset = NULL;
+	dm_pools_check_leaks();
 	dm_dump_memory();
 	_version_ok = 1;
 	_version_checked = 0;
--- LVM2/libdm/mm/pool-debug.c	2009/04/02 15:02:18	1.7
+++ LVM2/libdm/mm/pool-debug.c	2009/04/10 09:56:59	1.8
@@ -30,7 +30,9 @@
 } pool_stats;
 
 struct dm_pool {
+	struct dm_list list;
 	const char *name;
+	void *orig_pool;	/* to pair it with first allocation call */
 
 	int begun;
 	struct block *object;
@@ -65,10 +67,13 @@
 	mem->stats.bytes = 0;
 	mem->stats.maxbytes = 0;
 
+	mem->orig_pool = mem;
+
 #ifdef DEBUG_POOL
 	log_debug("Created mempool %s", name);
 #endif
 
+	dm_list_add(&_dm_pools, &mem->list);
 	return mem;
 }
 
@@ -103,6 +108,7 @@
 {
 	_pool_stats(p, "Destroying");
 	_free_blocks(p, p->blocks);
+	dm_list_del(&p->list);
 	dm_free(p);
 }
 
--- LVM2/libdm/mm/pool-fast.c	2008/11/03 18:59:59	1.6
+++ LVM2/libdm/mm/pool-fast.c	2009/04/10 09:56:59	1.7
@@ -21,6 +21,7 @@
 };
 
 struct dm_pool {
+	struct dm_list list;
 	struct chunk *chunk, *spare_chunk;	/* spare_chunk is a one entry free
 						   list to stop 'bobbling' */
 	size_t chunk_size;
@@ -51,6 +52,7 @@
 	while (new_size < p->chunk_size)
 		new_size <<= 1;
 	p->chunk_size = new_size;
+	dm_list_add(&_dm_pools, &p->list);
 	return p;
 }
 
@@ -65,6 +67,7 @@
 		c = pr;
 	}
 
+	dm_list_del(&p->list);
 	dm_free(p);
 }
 
--- LVM2/libdm/mm/pool.c	2008/11/03 18:59:59	1.4
+++ LVM2/libdm/mm/pool.c	2009/04/10 09:56:59	1.5
@@ -15,6 +15,10 @@
 
 #include "dmlib.h"
 
+/* FIXME: thread unsafe */
+static DM_LIST_INIT(_dm_pools);
+void dm_pools_check_leaks(void);
+
 #ifdef DEBUG_POOL
 #include "pool-debug.c"
 #else
@@ -52,3 +56,22 @@
 
 	return ptr;
 }
+
+void dm_pools_check_leaks(void)
+{
+	struct dm_pool *p;
+
+	if (dm_list_empty(&_dm_pools))
+		return;
+
+	log_error("You have a memory leak (not released memory pool):");
+	dm_list_iterate_items(p, &_dm_pools) {
+#ifdef DEBUG_POOL
+		log_error(" [%p] %s (%u bytes)",
+			  p->orig_pool,
+			  p->name, p->stats.bytes);
+#else
+		log_error(" [%p]", p);
+#endif
+	}
+}


