From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 23 Oct 2011 15:38:03 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/mm/pool-fast.c
Message-ID: <20111023153803.22574.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-23 15:38:03

Modified files:
	.              : WHATS_NEW_DM 
	libdm/mm       : pool-fast.c 

Log message:
	Fix usage of DEBUG_ENFORCE_POOL_LOCKING with DEBUG_MEM
	
	Since DEBUG_MEM is storing own extra structure within returned memory chunk,
	glibc free must be used directly for posix_memaling() allocated block.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.517&r2=1.518
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/mm/pool-fast.c.diff?cvsroot=lvm2&r1=1.16&r2=1.17

--- LVM2/WHATS_NEW_DM	2011/10/20 14:43:33	1.517
+++ LVM2/WHATS_NEW_DM	2011/10/23 15:38:02	1.518
@@ -1,5 +1,6 @@
 Version 1.02.68 -
 ==================================
+  Fix compile-time pool memory locking with DEBUG_MEM.
   Fix valgrind error reports in free of pool chunks with DEBUG_MEM.
   Align size of structure chunk for fast pool allocator to 8 bytes.
   Simplify some pointer operations in dm_free_aux() debug code.
--- LVM2/libdm/mm/pool-fast.c	2011/10/20 14:43:33	1.16
+++ LVM2/libdm/mm/pool-fast.c	2011/10/23 15:38:03	1.17
@@ -306,7 +306,12 @@
 		VALGRIND_MAKE_MEM_UNDEFINED(c + 1, c->end - (char *) (c + 1));
 #  endif
 #endif
+#ifdef DEBUG_ENFORCE_POOL_LOCKING
+	/* since DEBUG_MEM is using own memory list */
+	free(c); /* for posix_memalign() */
+#else
 	dm_free(c);
+#endif
 }
 
 


