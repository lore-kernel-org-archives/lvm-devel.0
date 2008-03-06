From: ccaulfield@sourceware.org <ccaulfield@sourceware.org>
Date: Thu, 06 Mar 2008 08:41:46 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd.c daemons ...
Message-ID: <20080306084106.30653.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	ccaulfield at sourceware.org	2008-03-06 08:41:06

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd.c refresh_clvmd.c 

Log message:
	Include limits.h so it compiles with newer headers.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.799&r2=1.800
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.42&r2=1.43
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/refresh_clvmd.c.diff?cvsroot=lvm2&r1=1.4&r2=1.5

--- LVM2/WHATS_NEW	2008/03/05 18:15:02	1.799
+++ LVM2/WHATS_NEW	2008/03/06 08:41:05	1.800
@@ -1,5 +1,6 @@
 Version 2.02.34 -
 ===================================
+  Include limits.h in clvmd so it compiles with newer headers.
   Add VirtIO disks (vd) to filters.
   Fix resetting of MIRROR_IMAGE and VISIBLE_LV after removal of LV. (2.02.30)
   Fix remove_layer_from_lv to empty the LV before removing it. (2.02.30)
--- LVM2/daemons/clvmd/clvmd.c	2008/02/15 14:12:32	1.42
+++ LVM2/daemons/clvmd/clvmd.c	2008/03/06 08:41:05	1.43
@@ -37,6 +37,7 @@
 #include <getopt.h>
 #include <syslog.h>
 #include <errno.h>
+#include <limits.h>
 #include <libdlm.h>
 
 #include "clvmd-comms.h"
--- LVM2/daemons/clvmd/refresh_clvmd.c	2007/08/17 11:51:23	1.4
+++ LVM2/daemons/clvmd/refresh_clvmd.c	2008/03/06 08:41:05	1.5
@@ -26,6 +26,7 @@
 #include <libdevmapper.h>
 #include <stdint.h>
 #include <stdio.h>
+#include <limits.h>
 
 #include "clvm.h"
 #include "refresh_clvmd.h"


