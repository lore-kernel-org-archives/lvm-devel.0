From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 29 Jul 2009 18:38:28 -0000
Subject: LVM2/liblvm lvm2app.h lvm_base.c
Message-ID: <20090729183828.31831.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-29 18:38:27

Modified files:
	liblvm         : lvm2app.h lvm_base.c 

Log message:
	Don't include lvm-version.h in exported liblvm file!
	
	Move include of lvm-version.h into lvm_base.c where it belongs.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm2app.h.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_base.c.diff?cvsroot=lvm2&r1=1.12&r2=1.13

--- LVM2/liblvm/lvm2app.h	2009/07/29 13:26:01	1.1
+++ LVM2/liblvm/lvm2app.h	2009/07/29 18:38:27	1.2
@@ -14,7 +14,6 @@
 #ifndef _LIB_LVM2APP_H
 #define _LIB_LVM2APP_H
 
-#include "lvm-version.h"
 #include "libdevmapper.h"
 
 #include <stdint.h>
--- LVM2/liblvm/lvm_base.c	2009/07/29 13:26:01	1.12
+++ LVM2/liblvm/lvm_base.c	2009/07/29 18:38:27	1.13
@@ -16,6 +16,7 @@
 #include "lvm2app.h"
 #include "toolcontext.h"
 #include "locking.h"
+#include "lvm-version.h"
 
 const char *lvm_library_get_version(void)
 {


