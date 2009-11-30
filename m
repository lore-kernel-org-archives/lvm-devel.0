From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 30 Nov 2009 15:12:35 -0000
Subject: LVM2/test/api Makefile.in
Message-ID: <20091130151235.11121.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2009-11-30 15:12:34

Modified files:
	test/api       : Makefile.in 

Log message:
	Fix test/api to work with srcdir != builddir.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/Makefile.in.diff?cvsroot=lvm2&r1=1.10&r2=1.11

--- LVM2/test/api/Makefile.in	2009/10/02 19:10:38	1.10
+++ LVM2/test/api/Makefile.in	2009/11/30 15:12:34	1.11
@@ -26,17 +26,17 @@
 INCLUDES += -I../../include
 
 LVMLIBS = @LVM2APP_LIB@ -ldevmapper
-DEPLIBS = $(top_srcdir)/liblvm/liblvm2app.so $(top_srcdir)/libdm/libdevmapper.so
+DEPLIBS = $(top_builddir)/liblvm/liblvm2app.so $(top_builddir)/libdm/libdevmapper.so
 
 DEFS += -D_REENTRANT
 
-include $(top_srcdir)/make.tmpl
+include $(top_builddir)/make.tmpl
 
-LDFLAGS = -L$(top_srcdir)/libdm -L$(top_srcdir)/liblvm
+LDFLAGS = -L$(top_builddir)/libdm -L$(top_builddir)/liblvm
 
 ifeq ("@DMEVENTD@", "yes")
 	LVMLIBS += -ldevmapper-event -lpthread
-	LDFLAGS += -L$(top_srcdir)/daemons/dmeventd
+	LDFLAGS += -L$(top_builddir)/daemons/dmeventd
 endif
 
 test_OBJECTS = $(test_SOURCES:.c=.o)


