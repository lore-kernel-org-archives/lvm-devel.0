From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 8 Feb 2011 15:52:01 -0000
Subject: LVM2/libdm/mm dbg_malloc.c
Message-ID: <20110208155201.13112.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-02-08 15:52:01

Modified files:
	libdm/mm       : dbg_malloc.c 

Log message:
	Revert DEBUG_MEM cleanup commit
	
	As functions compiled within this define are apparently stil part of the public API,
	(though lvm2 code is never using them unless this define is used for compilation),
	keep functions available in the code for now -> revert.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/mm/dbg_malloc.c.diff?cvsroot=lvm2&r1=1.22&r2=1.23

--- LVM2/libdm/mm/dbg_malloc.c	2011/01/28 16:01:32	1.22
+++ LVM2/libdm/mm/dbg_malloc.c	2011/02/08 15:52:00	1.23
@@ -15,8 +15,6 @@
 
 #include "dmlib.h"
 
-#ifdef DEBUG_MEM
-
 #include <assert.h>
 #include <stdarg.h>
 
@@ -251,8 +249,6 @@
 	}
 }
 
-#endif
-
 void *dm_malloc_aux(size_t s, const char *file __attribute__((unused)),
 		    int line __attribute__((unused)))
 {


