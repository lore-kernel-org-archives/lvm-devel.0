From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 30 Mar 2011 12:43:34 -0000
Subject: LVM2 ./WHATS_NEW lib/mm/memlock.c libdm/mm/poo ...
Message-ID: <20110330124334.25182.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-03-30 12:43:33

Modified files:
	.              : WHATS_NEW 
	lib/mm         : memlock.c 
	libdm/mm       : pool-fast.c 

Log message:
	Valgrind updates
	
	Avoid locking sum testing with valgrind compilation.
	
	Make memory unaccessible in the valgrind for dm_pool_abadon_object.
	
	Valgrind hinting should not be needed in _free_chunk for dm_free.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1964&r2=1.1965
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mm/memlock.c.diff?cvsroot=lvm2&r1=1.37&r2=1.38
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/mm/pool-fast.c.diff?cvsroot=lvm2&r1=1.12&r2=1.13

--- LVM2/WHATS_NEW	2011/03/30 12:36:19	1.1964
+++ LVM2/WHATS_NEW	2011/03/30 12:43:32	1.1965
@@ -1,5 +1,6 @@
 Version 2.02.85 - 
 ===================================
+  Enhance usability with the valgrind memcheck tool.
   Support regular quit of the lvm_thread_fn function in clvmd.
   Fix reading of unallocated memory in lvm1 format import function.
   Replace several strncmp() calls with id_equal().
--- LVM2/lib/mm/memlock.c	2011/03/06 17:52:07	1.37
+++ LVM2/lib/mm/memlock.c	2011/03/30 12:43:32	1.38
@@ -195,6 +195,14 @@
 		}
 	}
 
+#ifdef VALGRIND_POOL
+	/*
+	 * Valgrind is continually eating memory while executing code
+	 * so we need to deactivate check of locked memory size
+         */
+	sz -= sz; /* = 0, but avoids getting warning about dead assigment */
+
+#endif
 	*mstats += sz;
 	log_debug("%s %10ldKiB %12lx - %12lx %c%c%c%c%s",
 		  (lock == LVM_MLOCK) ? "mlock" : "munlock",
--- LVM2/libdm/mm/pool-fast.c	2011/03/10 14:49:01	1.12
+++ LVM2/libdm/mm/pool-fast.c	2011/03/30 12:43:33	1.13
@@ -238,6 +238,9 @@
 
 void dm_pool_abandon_object(struct dm_pool *p)
 {
+#ifdef VALGRIND_POOL
+	VALGRIND_MAKE_MEM_NOACCESS(p->chunk, p->object_len);
+#endif
 	p->object_len = 0;
 	p->object_alignment = DEFAULT_ALIGNMENT;
 }
@@ -278,11 +281,5 @@
 
 static void _free_chunk(struct chunk *c)
 {
-	if (c) {
-#ifdef VALGRIND_POOL
-		VALGRIND_MAKE_MEM_UNDEFINED(c, c->end - (char *) c);
-#endif
-
-		dm_free(c);
-	}
+	dm_free(c);
 }


