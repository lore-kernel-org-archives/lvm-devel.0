From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 20 Dec 2010 13:39:13 -0000
Subject: LVM2/libdm libdevmapper.h
Message-ID: <20101220133913.7994.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-12-20 13:39:13

Modified files:
	libdm          : libdevmapper.h 

Log message:
	Use const char* for offset calculation
	
	As 'const' types are also passed to macro dm_list_struct_base -
	keep offset calculation with const char pointers.
	Fixes several gcc constness warnings.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.130&r2=1.131

--- LVM2/libdm/libdevmapper.h	2010/12/20 13:23:12	1.130
+++ LVM2/libdm/libdevmapper.h	2010/12/20 13:39:12	1.131
@@ -814,7 +814,7 @@
  * contained in a structure of type t, return the containing structure.
  */
 #define dm_list_struct_base(v, t, head) \
-    ((t *)((char*)(v) - (char*)&((t *) 0)->head))
+    ((t *)((const char *)(v) - (const char *)&((t *) 0)->head))
 
 /*
  * Given the address v of an instance of 'struct dm_list list' contained in


