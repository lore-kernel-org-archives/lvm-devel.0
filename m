From: agk@sourceware.org <agk@sourceware.org>
Date: 5 Oct 2009 13:46:05 -0000
Subject: LVM2 daemons/clvmd/Makefile.in daemons/cmirror ...
Message-ID: <20091005134605.16426.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-10-05 13:46:03

Modified files:
	daemons/clvmd  : Makefile.in 
	daemons/cmirrord: Makefile.in 
	daemons/dmeventd: Makefile.in 
	daemons/dmeventd/plugins/mirror: Makefile.in 
	daemons/dmeventd/plugins/snapshot: Makefile.in 
	lib            : Makefile.in 
	tools          : Makefile.in 

Log message:
	More makefile cleaning up and fixing.  (gentoo)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/Makefile.in.diff?cvsroot=lvm2&r1=1.31&r2=1.32
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/Makefile.in.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/Makefile.in.diff?cvsroot=lvm2&r1=1.26&r2=1.27
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/mirror/Makefile.in.diff?cvsroot=lvm2&r1=1.10&r2=1.11
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/snapshot/Makefile.in.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/Makefile.in.diff?cvsroot=lvm2&r1=1.93&r2=1.94
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/Makefile.in.diff?cvsroot=lvm2&r1=1.100&r2=1.101

--- LVM2/daemons/clvmd/Makefile.in	2009/10/02 19:10:32	1.31
+++ LVM2/daemons/clvmd/Makefile.in	2009/10/05 13:46:00	1.32
@@ -92,7 +92,7 @@
 	install_clvmd
 
 clvmd: $(OBJECTS) $(top_builddir)/lib/liblvm-internal.a
-	$(CC) -o clvmd $(OBJECTS) $(CFLAGS) $(LDFLAGS) \
+	$(CC) $(CFLAGS) $(LDFLAGS) -o clvmd $(OBJECTS) \
 		$(LVMLIBS) $(LMLIBS) $(LIBS)
 
 .PHONY: install_clvmd
--- LVM2/daemons/cmirrord/Makefile.in	2009/10/02 19:10:32	1.4
+++ LVM2/daemons/cmirrord/Makefile.in	2009/10/05 13:46:01	1.5
@@ -32,7 +32,7 @@
 CFLAGS += $(CPG_CFLAGS) $(SACKPT_CFLAGS)
 
 cmirrord: $(OBJECTS) $(top_builddir)/lib/liblvm-internal.a
-	$(CC) -o cmirrord $(OBJECTS) $(LDFLAGS) \
+	$(CC) $(CFLAGS) $(LDFLAGS) -o cmirrord $(OBJECTS) \
 		$(LVMLIBS) $(LMLIBS) $(LIBS)
 
 install: $(TARGETS)
--- LVM2/daemons/dmeventd/Makefile.in	2009/10/02 19:10:32	1.26
+++ LVM2/daemons/dmeventd/Makefile.in	2009/10/05 13:46:01	1.27
@@ -42,11 +42,10 @@
 all: dmeventd
 device-mapper: dmeventd $(LIB_STATIC)
 
-LDFLAGS += -ldl -ldevmapper -lpthread
-CLDFLAGS += -ldl -ldevmapper -lpthread
+LIBS += -ldl -ldevmapper -lpthread
 
 dmeventd: $(LIB_SHARED) $(VERSIONED_SHLIB) dmeventd.o
-	$(CC) -o $@ dmeventd.o $(CFLAGS) $(LDFLAGS) \
+	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ dmeventd.o \
 	-L. -ldevmapper-event $(LIBS) -rdynamic
 
 .PHONY: install_dynamic install_static install_include \
--- LVM2/daemons/dmeventd/plugins/mirror/Makefile.in	2009/10/02 19:10:33	1.10
+++ LVM2/daemons/dmeventd/plugins/mirror/Makefile.in	2009/10/05 13:46:01	1.11
@@ -18,7 +18,8 @@
 VPATH = @srcdir@
 
 INCLUDES += -I${top_srcdir}/tools
-CLDFLAGS += -L${top_builddir}/tools -ldevmapper @LVM2CMD_LIB@
+CLDFLAGS += -L${top_builddir}/tools
+LIBS += -ldevmapper @LIB_PTHREAD@ @LVM2CMD_LIB@
 
 SOURCES = dmeventd_mirror.c
 
--- LVM2/daemons/dmeventd/plugins/snapshot/Makefile.in	2009/10/02 19:10:33	1.6
+++ LVM2/daemons/dmeventd/plugins/snapshot/Makefile.in	2009/10/05 13:46:02	1.7
@@ -18,7 +18,8 @@
 VPATH = @srcdir@
 
 INCLUDES += -I${top_srcdir}/tools
-CLDFLAGS += -L${top_builddir}/tools -ldevmapper @LVM2CMD_LIB@
+CLDFLAGS += -L${top_builddir}/tools
+LIBS += -ldevmapper @LIB_PTHREAD@ @LVM2CMD_LIB@
 
 SOURCES = dmeventd_snapshot.c
 
--- LVM2/lib/Makefile.in	2009/10/02 19:10:34	1.93
+++ LVM2/lib/Makefile.in	2009/10/05 13:46:02	1.94
@@ -138,7 +138,8 @@
 endif
 
 ifeq ("@DMEVENTD@", "yes")
-  CLDFLAGS += -ldevmapper-event
+  CLDFLAGS += -L../daemons/dmeventd
+  LIBS += -ldevmapper-event
 endif
 
 LIB_NAME = liblvm-internal
--- LVM2/tools/Makefile.in	2009/10/02 19:10:38	1.100
+++ LVM2/tools/Makefile.in	2009/10/05 13:46:03	1.101
@@ -17,6 +17,8 @@
 top_builddir = @top_builddir@
 VPATH = @srcdir@
 
+LIB_PTHREAD = @LIB_PTHREAD@
+
 SOURCES =\
 	dumpconfig.c \
 	formats.c \
@@ -110,24 +112,23 @@
 device-mapper: $(TARGETS_DM)
 
 dmsetup: dmsetup.o $(top_builddir)/libdm/libdevmapper.$(LIB_SUFFIX)
-	$(CC) -o $@ dmsetup.o $(CFLAGS) $(LDFLAGS) \
-	      -L$(top_builddir)/libdm -ldevmapper $(LIBS)
+	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ dmsetup.o \
+	      -L$(top_builddir)/libdm -ldevmapper $(LIBS) $(LIB_PTHREAD)
 
 dmsetup.static: dmsetup.o $(interfacedir)/libdevmapper.a
-	$(CC) -o $@ dmsetup.o $(CFLAGS) $(LDFLAGS) -static \
+	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ dmsetup.o -static \
 	      -L$(interfacedir) -ldevmapper $(LIBS) \
 	      $(LIB_PTHREAD)
 
 all: device-mapper
 
 lvm: $(OBJECTS) lvm.o $(top_builddir)/lib/liblvm-internal.a
-	$(CC) -o $@ $(CFLAGS) $(OBJECTS) lvm.o \
-		$(LDFLAGS) $(LVMLIBS) $(LIBS) -rdynamic
+	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJECTS) lvm.o \
+		$(LVMLIBS) $(LIBS) $(LIB_PTHREAD) -rdynamic
 
-LIB_PTHREAD = @LIB_PTHREAD@
 lvm.static: $(OBJECTS) lvm-static.o $(top_builddir)/lib/liblvm-internal.a  $(interfacedir)/libdevmapper.a
-	$(CC) -o $@ $(CFLAGS) $(OBJECTS) lvm-static.o -static \
-		-L$(interfacedir) $(LDFLAGS) $(LVMLIBS) $(LIBS) $(LIB_PTHREAD) -rdynamic
+	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJECTS) lvm-static.o -static \
+		-L$(interfacedir) $(LVMLIBS) $(LIBS) $(LIB_PTHREAD) -rdynamic
 
 liblvm2cmd.a: $(top_builddir)/lib/liblvm-internal.a $(OBJECTS) lvmcmdlib.o lvm2cmd.o
 	cat $(top_builddir)/lib/liblvm-internal.a > $@


