From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 20 Oct 2011 13:33:41 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/mm/dbg_malloc.c
Message-ID: <20111020133341.7368.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-20 13:33:41

Modified files:
	.              : WHATS_NEW_DM 
	libdm/mm       : dbg_malloc.c 

Log message:
	Simplify some pointer operations

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.513&r2=1.514
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/mm/dbg_malloc.c.diff?cvsroot=lvm2&r1=1.23&r2=1.24

--- LVM2/WHATS_NEW_DM	2011/10/20 13:23:52	1.513
+++ LVM2/WHATS_NEW_DM	2011/10/20 13:33:41	1.514
@@ -1,5 +1,6 @@
 Version 1.02.68 -
 ==================================
+  Simplify some pointer operations in dm_free_aux() debug code..
   Remove unused dbg_malloc.h file from source tree.
   Cleanup backtraces for _create_and_load_v4().
   Fix alignment warning in bitcount calculation for raid segment.
--- LVM2/libdm/mm/dbg_malloc.c	2011/02/08 15:52:00	1.23
+++ LVM2/libdm/mm/dbg_malloc.c	2011/10/20 13:33:41	1.24
@@ -143,9 +143,9 @@
 	assert(mb->magic == p);
 
 	/* check data at the far boundary */
-	ptr = ((char *) mb) + sizeof(struct memblock) + mb->length;
+	ptr = (char *) p + mb->length;
 	for (i = 0; i < sizeof(unsigned long); i++)
-		if (*ptr++ != (char) mb->id)
+		if (ptr[i] != (char) mb->id)
 			assert(!"Damage at far end of block");
 
 	/* have we freed this before ? */
@@ -165,9 +165,9 @@
 	mb->id = 0;
 
 	/* stomp a different pattern across the memory */
-	ptr = ((char *) mb) + sizeof(struct memblock);
+	ptr = p;
 	for (i = 0; i < mb->length; i++)
-		*ptr++ = i & 1 ? (char) 0xde : (char) 0xad;
+		ptr[i] = i & 1 ? (char) 0xde : (char) 0xad;
 
 	assert(_mem_stats.blocks_allocated);
 	_mem_stats.blocks_allocated--;


