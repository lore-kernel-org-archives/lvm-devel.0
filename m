From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 18 Jul 2011 14:34:34 -0000
Subject: LVM2/lib datastruct/lvm-types.h uuid/uuid.h
Message-ID: <20110718143434.2685.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-07-18 14:34:34

Modified files:
	lib/datastruct : lvm-types.h 
	lib/uuid       : uuid.h 

Log message:
	Revert the #include changes. Need to fix this at the #include site for now, and
	eventually refactor the way we structure #includes in the all of the library.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/datastruct/lvm-types.h.diff?cvsroot=lvm2&r1=1.17&r2=1.18
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/uuid/uuid.h.diff?cvsroot=lvm2&r1=1.18&r2=1.19

--- LVM2/lib/datastruct/lvm-types.h	2011/07/18 13:24:48	1.17
+++ LVM2/lib/datastruct/lvm-types.h	2011/07/18 14:34:33	1.18
@@ -16,7 +16,6 @@
 #ifndef _LVM_TYPES_H
 #define _LVM_TYPES_H
 
-#include <libdevmapper.h> // dm_list
 #include <sys/types.h>
 #include <inttypes.h>
 
--- LVM2/lib/uuid/uuid.h	2011/07/18 13:24:14	1.18
+++ LVM2/lib/uuid/uuid.h	2011/07/18 14:34:34	1.19
@@ -16,10 +16,6 @@
 #ifndef _LVM_UUID_H
 #define _LVM_UUID_H
 
-#include <stdint.h> /* int8_t */
-#include <malloc.h> /* size_t */
-#include "libdevmapper.h"
-
 #define ID_LEN 32
 #define ID_LEN_S "32"
 


