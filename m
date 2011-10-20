From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 20 Oct 2011 13:39:58 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/mm/pool-fast.c
Message-ID: <20111020133958.456.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-20 13:39:57

Modified files:
	.              : WHATS_NEW_DM 
	libdm/mm       : pool-fast.c 

Log message:
	Mark chunk memory for free as defined again for valgrind
	
	When DEBUG_MEM is used, the memory is trashed with extra pattern before real
	free() is called, and as this memory was marked as non accessible when used with
	valgrind, make it again usable.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.515&r2=1.516
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/mm/pool-fast.c.diff?cvsroot=lvm2&r1=1.14&r2=1.15

--- LVM2/WHATS_NEW_DM	2011/10/20 13:36:13	1.515
+++ LVM2/WHATS_NEW_DM	2011/10/20 13:39:57	1.516
@@ -1,5 +1,6 @@
 Version 1.02.68 -
 ==================================
+  Fix valgrind error reports in free of pool chunks with DEBUG_MEM.
   Aling size of structure chunk for fast pool allocator to 8 bytes.
   Simplify some pointer operations in dm_free_aux() debug code.
   Remove unused dbg_malloc.h file from source tree.
--- LVM2/libdm/mm/pool-fast.c	2011/08/11 17:29:05	1.14
+++ LVM2/libdm/mm/pool-fast.c	2011/10/20 13:39:57	1.15
@@ -300,6 +300,12 @@
 
 static void _free_chunk(struct chunk *c)
 {
+#ifdef VALGRIND_POOL
+#  ifdef DEBUG_MEM
+	if (c)
+		VALGRIND_MAKE_MEM_UNDEFINED(c + 1, c->end - (char *) (c + 1));
+#  endif
+#endif
 	dm_free(c);
 }
 


