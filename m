From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 26 Mar 2009 09:25:19 -0000
Subject: LVM2 lib/config/config.c lib/metadata/lv_manip ...
Message-ID: <20090326092519.22739.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-03-26 09:25:19

Modified files:
	lib/config     : config.c 
	lib/metadata   : lv_manip.c 
	libdm/mm       : pool-debug.c 

Log message:
	fix some issues when compiling with -D DEBUG_POOL
	
	- fix compilation issues
	- fix wrong pool object maipulation (lvm dumpconfig triggers assert)
	- second iteration in loop _log_parallel_areas operates on non-existing object

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/config.c.diff?cvsroot=lvm2&r1=1.72&r2=1.73
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.163&r2=1.164
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/mm/pool-debug.c.diff?cvsroot=lvm2&r1=1.5&r2=1.6

--- LVM2/lib/config/config.c	2008/11/03 22:14:27	1.72
+++ LVM2/lib/config/config.c	2009/03/26 09:25:18	1.73
@@ -457,9 +457,9 @@
 			line_append(" {");
 			if (!_line_end(outline))
 				return_0;
+			_write_config(n->child, 0, outline, level + 1);
 			if (!_line_start(outline))
 				return_0;
-			_write_config(n->child, 0, outline, level + 1);
 			line_append("%s}", space);
 		} else {
 			/* it's a value */
--- LVM2/lib/metadata/lv_manip.c	2009/01/06 17:24:21	1.163
+++ LVM2/lib/metadata/lv_manip.c	2009/03/26 09:25:18	1.164
@@ -611,12 +611,12 @@
 	if (!parallel_areas)
 		return 1;
 
-	if (!dm_pool_begin_object(mem, 256)) {
-		log_error("dm_pool_begin_object failed");
-		return 0;
-	}
-
 	dm_list_iterate_items(spvs, parallel_areas) {
+		if (!dm_pool_begin_object(mem, 256)) {
+			log_error("dm_pool_begin_object failed");
+			return 0;
+		}
+
 		dm_list_iterate_items(pvl, &spvs->pvs) {
 			if (!dm_pool_grow_object(mem, pv_dev_name(pvl->pv), strlen(pv_dev_name(pvl->pv)))) {
 				log_error("dm_pool_grow_object failed");
--- LVM2/libdm/mm/pool-debug.c	2008/11/03 18:59:59	1.5
+++ LVM2/libdm/mm/pool-debug.c	2009/03/26 09:25:18	1.6
@@ -14,6 +14,7 @@
  */
 
 #include "dmlib.h"
+#include <assert.h>
 
 struct block {
 	struct block *next;
@@ -43,7 +44,7 @@
 /* by default things come out aligned for doubles */
 #define DEFAULT_ALIGNMENT __alignof__ (double)
 
-struct pool *dm_pool_create(const char *name, size_t chunk_hint)
+struct dm_pool *dm_pool_create(const char *name, size_t chunk_hint)
 {
 	struct dm_pool *mem = dm_malloc(sizeof(*mem));
 
@@ -130,8 +131,6 @@
 
 static struct block *_new_block(size_t s, unsigned alignment)
 {
-	static const char *_oom = "Out of memory";
-
 	/* FIXME: I'm currently ignoring the alignment arg. */
 	size_t len = sizeof(struct block) + s;
 	struct block *b = dm_malloc(len);
@@ -144,12 +143,12 @@
 	assert(alignment == DEFAULT_ALIGNMENT);
 
 	if (!b) {
-		log_err(_oom);
+		log_err("Out of memory");
 		return NULL;
 	}
 
 	if (!(b->data = dm_malloc(s))) {
-		log_err(_oom);
+		log_err("Out of memory");
 		dm_free(b);
 		return NULL;
 	}


