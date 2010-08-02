From: agk@sourceware.org <agk@sourceware.org>
Date: 2 Aug 2010 12:23:12 -0000
Subject: LVM2 ./WHATS_NEW liblvm/lvm2app.h
Message-ID: <20100802122312.4950.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-08-02 12:23:11

Modified files:
	.              : WHATS_NEW 
	liblvm         : lvm2app.h 

Log message:
	Use #include <> not "" in lvm2app.h which gets installed on the system.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1681&r2=1.1682
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm2app.h.diff?cvsroot=lvm2&r1=1.19&r2=1.20

--- LVM2/WHATS_NEW	2010/08/02 12:10:35	1.1681
+++ LVM2/WHATS_NEW	2010/08/02 12:23:01	1.1682
@@ -1,5 +1,6 @@
 Version 2.02.73 - 
 ================================
+  Use #include <> not "" in lvm2app.h which gets installed on the system.
   Make liblvm.device-mapper wait for include file generation.
   Drop explicit 'Base' version from exported symbols.
   Fix configure to supply DEFAULT_RUN_DIR to Makefiles.
--- LVM2/liblvm/lvm2app.h	2010/07/12 18:29:31	1.19
+++ LVM2/liblvm/lvm2app.h	2010/08/02 12:23:06	1.20
@@ -14,7 +14,7 @@
 #ifndef _LIB_LVM2APP_H
 #define _LIB_LVM2APP_H
 
-#include "libdevmapper.h"
+#include <libdevmapper.h>
 
 #include <stdint.h>
 


