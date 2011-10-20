From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 20 Oct 2011 14:43:34 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/mm/pool-fast.c
Message-ID: <20111020144334.2715.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-20 14:43:33

Modified files:
	.              : WHATS_NEW_DM 
	libdm/mm       : pool-fast.c 

Log message:
	Aling structure chunk on default aling size
	
	Since we use 8 bytes by default for the pool allocation,
	keep the structure aligned with this size.
	(Somehow it was not applied in previous commit.)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.516&r2=1.517
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/mm/pool-fast.c.diff?cvsroot=lvm2&r1=1.15&r2=1.16

--- LVM2/WHATS_NEW_DM	2011/10/20 13:39:57	1.516
+++ LVM2/WHATS_NEW_DM	2011/10/20 14:43:33	1.517
@@ -1,7 +1,7 @@
 Version 1.02.68 -
 ==================================
   Fix valgrind error reports in free of pool chunks with DEBUG_MEM.
-  Aling size of structure chunk for fast pool allocator to 8 bytes.
+  Align size of structure chunk for fast pool allocator to 8 bytes.
   Simplify some pointer operations in dm_free_aux() debug code.
   Remove unused dbg_malloc.h file from source tree.
   Cleanup backtraces for _create_and_load_v4().
--- LVM2/libdm/mm/pool-fast.c	2011/10/20 13:39:57	1.15
+++ LVM2/libdm/mm/pool-fast.c	2011/10/20 14:43:33	1.16
@@ -23,7 +23,7 @@
 struct chunk {
 	char *begin, *end;
 	struct chunk *prev;
-};
+} __attribute__((aligned(8)));
 
 struct dm_pool {
 	struct dm_list list;


