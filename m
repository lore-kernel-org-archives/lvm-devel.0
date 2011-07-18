From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 18 Jul 2011 13:24:15 -0000
Subject: LVM2/lib/uuid uuid.h
Message-ID: <20110718132415.2290.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-07-18 13:24:14

Modified files:
	lib/uuid       : uuid.h 

Log message:
	Add a couple missing #includes in uuid.h.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/uuid/uuid.h.diff?cvsroot=lvm2&r1=1.17&r2=1.18

--- LVM2/lib/uuid/uuid.h	2010/09/30 14:07:33	1.17
+++ LVM2/lib/uuid/uuid.h	2011/07/18 13:24:14	1.18
@@ -16,6 +16,10 @@
 #ifndef _LVM_UUID_H
 #define _LVM_UUID_H
 
+#include <stdint.h> /* int8_t */
+#include <malloc.h> /* size_t */
+#include "libdevmapper.h"
+
 #define ID_LEN 32
 #define ID_LEN_S "32"
 


