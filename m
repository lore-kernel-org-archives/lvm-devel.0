From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 28 Oct 2011 20:37:31 -0000
Subject: LVM2/libdm/mm dbg_malloc.c
Message-ID: <20111028203731.4077.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-28 20:37:31

Modified files:
	libdm/mm       : dbg_malloc.c 

Log message:
	Improve valgrind support when compiled with DEBUG_MEM

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/mm/dbg_malloc.c.diff?cvsroot=lvm2&r1=1.24&r2=1.25

--- LVM2/libdm/mm/dbg_malloc.c	2011/10/20 13:33:41	1.24
+++ LVM2/libdm/mm/dbg_malloc.c	2011/10/28 20:37:31	1.25
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
  *
  * This file is part of the device-mapper userspace tools.
  *
@@ -15,6 +15,10 @@
 
 #include "dmlib.h"
 
+#ifdef VALGRIND_POOL
+#include "valgrind/memcheck.h"
+#endif
+
 #include <assert.h>
 #include <stdarg.h>
 
@@ -115,7 +119,9 @@
 
 	/* log_debug("Allocated: %u %u %u", nb->id, _mem_stats.blocks_allocated,
 		  _mem_stats.bytes); */
-
+#ifdef VALGRIND_POOL
+	VALGRIND_MAKE_MEM_UNDEFINED(nb + 1, s);
+#endif
 	return nb + 1;
 }
 
@@ -141,7 +147,9 @@
 
 	/* sanity check */
 	assert(mb->magic == p);
-
+#ifdef VALGRIND_POOL
+	VALGRIND_MAKE_MEM_DEFINED(p, mb->length);
+#endif
 	/* check data at the far boundary */
 	ptr = (char *) p + mb->length;
 	for (i = 0; i < sizeof(unsigned long); i++)


