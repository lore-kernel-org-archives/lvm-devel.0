From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 30 Mar 2011 13:06:14 -0000
Subject: LVM2 ./WHATS_NEW lib/mm/memlock.c
Message-ID: <20110330130614.3241.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-03-30 13:06:13

Modified files:
	.              : WHATS_NEW 
	lib/mm         : memlock.c 

Log message:
	Few more files filtered from memory locking
	
	Code located in these files should not be used in critical section.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1965&r2=1.1966
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mm/memlock.c.diff?cvsroot=lvm2&r1=1.38&r2=1.39

--- LVM2/WHATS_NEW	2011/03/30 12:43:32	1.1965
+++ LVM2/WHATS_NEW	2011/03/30 13:06:13	1.1966
@@ -1,5 +1,6 @@
 Version 2.02.85 - 
 ===================================
+  Extend the set of memory regions, that are not locked to memory.
   Enhance usability with the valgrind memcheck tool.
   Support regular quit of the lvm_thread_fn function in clvmd.
   Fix reading of unallocated memory in lvm1 format import function.
--- LVM2/lib/mm/memlock.c	2011/03/30 12:43:32	1.38
+++ LVM2/lib/mm/memlock.c	2011/03/30 13:06:13	1.39
@@ -89,9 +89,11 @@
 /* default blacklist for maps */
 static const char * const _blacklist_maps[] = {
     "locale/locale-archive",
+    "/LC_MESSAGES/",
     "gconv/gconv-modules.cache",
     "/libreadline.so.",	/* not using readline during mlock */
     "/libncurses.so.",	/* not using readline during mlock */
+    "/libtinfo.so.",	/* not using readline during mlock */
     "/libdl-",		/* not using dlopen,dlsym during mlock */
     /* "/libdevmapper-event.so" */
 };


