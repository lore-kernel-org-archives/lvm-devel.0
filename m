From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 10 Feb 2012 13:52:07 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/mm/dbg_malloc.c
Message-ID: <20120210135207.26069.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-10 13:52:06

Modified files:
	.              : WHATS_NEW_DM 
	libdm/mm       : dbg_malloc.c 

Log message:
	Add test for failing allocation
	
	Avoid memcpy to NULL if realloc fails.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.543&r2=1.544
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/mm/dbg_malloc.c.diff?cvsroot=lvm2&r1=1.25&r2=1.26

--- LVM2/WHATS_NEW_DM	2012/02/10 13:49:29	1.543
+++ LVM2/WHATS_NEW_DM	2012/02/10 13:52:05	1.544
@@ -1,5 +1,6 @@
 Version 1.02.70 - 
 ===================================
+  Add missing test for failing allocation in dm_realloc() code.
   Add test for memory allocation failures in regex matcher code.
   Simplify dm_task_set_geometry() and use dm_asprintf().
   Set all parameters to 0 for dm_get_next_target() for NULL return.
--- LVM2/libdm/mm/dbg_malloc.c	2011/10/28 20:37:31	1.25
+++ LVM2/libdm/mm/dbg_malloc.c	2012/02/10 13:52:05	1.26
@@ -192,7 +192,7 @@
 
 	r = dm_malloc_aux_debug(s, file, line);
 
-	if (p) {
+	if (r && p) {
 		memcpy(r, p, mb->length);
 		dm_free_aux(p);
 	}


