From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 14 Jan 2010 10:12:45 -0000
Subject: LVM2/libdm libdevmapper.h
Message-ID: <20100114101245.28409.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-01-14 10:12:44

Modified files:
	libdm          : libdevmapper.h 

Log message:
	Cleanup gcc warning: cast from function call of type 'struct dm_list *'
	to non-matching type 'long unsigned int'
	
	Casting pointer to long and back to pointer could be easily
	handled with just pointer arithmetic.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.106&r2=1.107

--- LVM2/libdm/libdevmapper.h	2010/01/13 01:39:45	1.106
+++ LVM2/libdm/libdevmapper.h	2010/01/14 10:12:44	1.107
@@ -754,7 +754,7 @@
  * contained in a structure of type t, return the containing structure.
  */
 #define dm_list_struct_base(v, t, head) \
-    ((t *)((uintptr_t)(v) - (uintptr_t)&((t *) 0)->head))
+    ((t *)((char*)(v) - (char*)&((t *) 0)->head))
 
 /*
  * Given the address v of an instance of 'struct dm_list list' contained in


