From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 18 Jul 2011 13:24:49 -0000
Subject: LVM2/lib/datastruct lvm-types.h
Message-ID: <20110718132449.2456.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-07-18 13:24:48

Modified files:
	lib/datastruct : lvm-types.h 

Log message:
	Add a missing libdevmapper.h #include to lvm-types.h (for dm_list).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/datastruct/lvm-types.h.diff?cvsroot=lvm2&r1=1.16&r2=1.17

--- LVM2/lib/datastruct/lvm-types.h	2008/11/04 14:57:06	1.16
+++ LVM2/lib/datastruct/lvm-types.h	2011/07/18 13:24:48	1.17
@@ -16,6 +16,7 @@
 #ifndef _LVM_TYPES_H
 #define _LVM_TYPES_H
 
+#include <libdevmapper.h> // dm_list
 #include <sys/types.h>
 #include <inttypes.h>
 


