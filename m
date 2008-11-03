From: agk@sourceware.org <agk@sourceware.org>
Date: 3 Nov 2008 23:01:22 -0000
Subject: LVM2 ./Makefile.in daemons/Makefile.in daemons ...
Message-ID: <20081103230122.17509.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-11-03 23:01:21

Modified files:
	.              : Makefile.in 
	daemons        : Makefile.in 
	daemons/dmeventd: Makefile.in dmeventd.c libdevmapper-event.c 

Log message:
	more tweaks for dmeventd - not finished yet

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/Makefile.in.diff?cvsroot=lvm2&r1=1.26&r2=1.27
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/Makefile.in.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/Makefile.in.diff?cvsroot=lvm2&r1=1.20&r2=1.21
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/dmeventd.c.diff?cvsroot=lvm2&r1=1.52&r2=1.53
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/libdevmapper-event.c.diff?cvsroot=lvm2&r1=1.26&r2=1.27

--- LVM2/Makefile.in	2008/11/03 22:14:26	1.26
+++ LVM2/Makefile.in	2008/11/03 23:01:21	1.27
@@ -47,8 +47,9 @@
 po: tools daemons
 
 libdm.device-mapper: include.device-mapper
+daemons.device-mapper: libdm.device-mapper
 tools.device-mapper: libdm.device-mapper
-device-mapper: tools.device-mapper
+device-mapper: tools.device-mapper daemons.device-mapper
 
 ifeq ("@INTL@", "yes")
 lib.pofile: include.pofile
--- LVM2/daemons/Makefile.in	2008/10/31 22:29:44	1.4
+++ LVM2/daemons/Makefile.in	2008/11/03 23:01:21	1.5
@@ -20,8 +20,10 @@
 endif
 
 ifeq ("@DMEVENTD@", "yes")
-  SUBDIRS += dmeventd/plugins
+  SUBDIRS += dmeventd
 endif
 
+device-mapper: dmeventd
+
 include $(top_srcdir)/make.tmpl
 
--- LVM2/daemons/dmeventd/Makefile.in	2008/06/27 15:36:51	1.20
+++ LVM2/daemons/dmeventd/Makefile.in	2008/11/03 23:01:21	1.21
@@ -18,6 +18,7 @@
 SOURCES = libdevmapper-event.c
 
 LIB_STATIC = libdevmapper-event.a
+LIB_VERSION = $(LIB_VERSION_DM)
 
 ifeq ("@LIB_SUFFIX@","dylib")
   LIB_SHARED = libdevmapper-event.dylib
@@ -29,7 +30,13 @@
 TARGETS = dmeventd
 CLEAN_TARGETS = dmeventd.o
 
-include ../make.tmpl
+ifneq ($(MAKECMDGOALS),device-mapper)
+  SUBDIRS+=plugins
+endif
+
+include $(top_srcdir)/make.tmpl
+
+all: dmeventd
 
 LDFLAGS += -ldl -ldevmapper -lpthread
 CLDFLAGS += -ldl -ldevmapper -lpthread
--- LVM2/daemons/dmeventd/dmeventd.c	2008/11/03 22:14:26	1.52
+++ LVM2/daemons/dmeventd/dmeventd.c	2008/11/03 23:01:21	1.53
@@ -25,7 +25,7 @@
 #include "list.h"
 #include "dmeventd.h"
 //#include "libmultilog.h"
-#include "log.h"
+#include "dm-logging.h"
 
 #include <dlfcn.h>
 #include <errno.h>
--- LVM2/daemons/dmeventd/libdevmapper-event.c	2007/11/27 12:26:06	1.26
+++ LVM2/daemons/dmeventd/libdevmapper-event.c	2008/11/03 23:01:21	1.27
@@ -12,7 +12,7 @@
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
 
-#include "lib.h"
+#include "dmlib.h"
 #include "libdevmapper-event.h"
 //#include "libmultilog.h"
 #include "dmeventd.h"


