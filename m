From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 10 Mar 2009 15:38:47 -0000
Subject: LVM2/liblvm lvm_base.c
Message-ID: <20090310153847.18253.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-03-10 15:38:47

Modified files:
	liblvm         : lvm_base.c 

Log message:
	Remove unnecessary includes in lvm_base.c.
	
	We would like to declare our handles pv_t, vg_t, and lv_t in
	the external library header lvm.h.  However, these are already
	defined in metadata-exported.h for the use of some of the
	in-progress liblvm APIs.  Thus, we cannot both define
	them in lvm.h and include metadata-exported.h in the external
	library C files.  We could use preprocessor tricks (#ifndef)
	but for now we just avoid the include.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_base.c.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/liblvm/lvm_base.c	2009/03/06 16:19:53	1.1
+++ LVM2/liblvm/lvm_base.c	2009/03/10 15:38:46	1.2
@@ -16,8 +16,6 @@
 #include "lvm.h"
 #include "toolcontext.h"
 #include "locking.h"
-#include "metadata-exported.h"
-#include "report.h"
 
 lvm_t lvm_create(const char *system_dir)
 {


