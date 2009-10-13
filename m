From: agk@sourceware.org <agk@sourceware.org>
Date: 13 Oct 2009 01:31:11 -0000
Subject: LVM2 daemons/dmeventd/Makefile.in tools/Makefi ...
Message-ID: <20091013013111.23965.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-10-13 01:31:10

Modified files:
	daemons/dmeventd: Makefile.in 
	tools          : Makefile.in 

Log message:
	More build cleanups (linker parameter ordering).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/Makefile.in.diff?cvsroot=lvm2&r1=1.27&r2=1.28
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/Makefile.in.diff?cvsroot=lvm2&r1=1.101&r2=1.102

--- LVM2/daemons/dmeventd/Makefile.in	2009/10/05 13:46:01	1.27
+++ LVM2/daemons/dmeventd/Makefile.in	2009/10/13 01:31:10	1.28
@@ -45,8 +45,8 @@
 LIBS += -ldl -ldevmapper -lpthread
 
 dmeventd: $(LIB_SHARED) $(VERSIONED_SHLIB) dmeventd.o
-	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ dmeventd.o \
-	-L. -ldevmapper-event $(LIBS) -rdynamic
+	$(CC) $(CFLAGS) $(LDFLAGS) -L. -o $@ dmeventd.o \
+	-ldevmapper-event $(LIBS) -rdynamic
 
 .PHONY: install_dynamic install_static install_include \
 	install_pkgconfig install_dmeventd
--- LVM2/tools/Makefile.in	2009/10/05 13:46:03	1.101
+++ LVM2/tools/Makefile.in	2009/10/13 01:31:10	1.102
@@ -112,13 +112,12 @@
 device-mapper: $(TARGETS_DM)
 
 dmsetup: dmsetup.o $(top_builddir)/libdm/libdevmapper.$(LIB_SUFFIX)
-	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ dmsetup.o \
-	      -L$(top_builddir)/libdm -ldevmapper $(LIBS) $(LIB_PTHREAD)
+	$(CC) $(CFLAGS) $(LDFLAGS) -L$(top_builddir)/libdm \
+	      -o $@ dmsetup.o -ldevmapper $(LIBS) $(LIB_PTHREAD)
 
 dmsetup.static: dmsetup.o $(interfacedir)/libdevmapper.a
-	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ dmsetup.o -static \
-	      -L$(interfacedir) -ldevmapper $(LIBS) \
-	      $(LIB_PTHREAD)
+	$(CC) $(CFLAGS) $(LDFLAGS) -static -L$(interfacedir) \
+	      -o $@ dmsetup.o -ldevmapper $(LIBS) $(LIB_PTHREAD)
 
 all: device-mapper
 
@@ -127,8 +126,9 @@
 		$(LVMLIBS) $(LIBS) $(LIB_PTHREAD) -rdynamic
 
 lvm.static: $(OBJECTS) lvm-static.o $(top_builddir)/lib/liblvm-internal.a  $(interfacedir)/libdevmapper.a
-	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJECTS) lvm-static.o -static \
-		-L$(interfacedir) $(LVMLIBS) $(LIBS) $(LIB_PTHREAD) -rdynamic
+	$(CC) $(CFLAGS) $(LDFLAGS) -static -L$(interfacedir) -o $@ \
+	      $(OBJECTS) lvm-static.o $(LVMLIBS) $(LIBS) $(LIB_PTHREAD) \
+	      -rdynamic
 
 liblvm2cmd.a: $(top_builddir)/lib/liblvm-internal.a $(OBJECTS) lvmcmdlib.o lvm2cmd.o
 	cat $(top_builddir)/lib/liblvm-internal.a > $@


