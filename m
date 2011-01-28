From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 28 Jan 2011 16:01:32 -0000
Subject: LVM2/libdm/mm dbg_malloc.c
Message-ID: <20110128160132.23140.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-01-28 16:01:32

Modified files:
	libdm/mm       : dbg_malloc.c 

Log message:
	Compile code for memory debuging only with DEBUG_MEM
	
	When it's not in use - do not compile this code.
	Improves lcov code coverage results for this code a lot :)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/mm/dbg_malloc.c.diff?cvsroot=lvm2&r1=1.21&r2=1.22

--- LVM2/libdm/mm/dbg_malloc.c	2010/09/30 21:06:52	1.21
+++ LVM2/libdm/mm/dbg_malloc.c	2011/01/28 16:01:32	1.22
@@ -15,6 +15,8 @@
 
 #include "dmlib.h"
 
+#ifdef DEBUG_MEM
+
 #include <assert.h>
 #include <stdarg.h>
 
@@ -249,6 +251,8 @@
 	}
 }
 
+#endif
+
 void *dm_malloc_aux(size_t s, const char *file __attribute__((unused)),
 		    int line __attribute__((unused)))
 {


