From: agk@sourceware.org <agk@sourceware.org>
Date: 31 Oct 2008 22:33:55 -0000
Subject: LVM2 make.tmpl.in
Message-ID: <20081031223355.28253.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-10-31 22:33:55

Modified files:
	.              : make.tmpl.in 

Log message:
	no DMDIR

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/make.tmpl.in.diff?cvsroot=lvm2&r1=1.57&r2=1.58

--- LVM2/make.tmpl.in	2008/10/08 12:50:13	1.57
+++ LVM2/make.tmpl.in	2008/10/31 22:33:55	1.58
@@ -80,13 +80,6 @@
   DEFS += -DINTL_PACKAGE=\"@INTL_PACKAGE@\" -DLOCALEDIR=\"@LOCALEDIR@\"
 endif
 
-ifneq ("@DMDIR@", "")
-  LDFLAGS += -L at DMDIR@/lib/ioctl
-  ifeq ("@DMEVENTD@", "yes")
-    LDFLAGS += -L at DMDIR@/dmeventd
-  endif
-endif
-
 LDFLAGS += -L$(top_srcdir)/lib -L$(libdir)
 
 #DEFS += -DDEBUG_POOL
@@ -105,10 +98,6 @@
 
 INCLUDES += -I$(top_srcdir)/include
 
-ifneq ("@DMDIR@", "")
-  INCLUDES += -I at DMDIR@/include
-endif
-
 ifdef DESTDIR
   INCLUDES += -I$(DESTDIR)/usr/include
 endif


