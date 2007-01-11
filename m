From: agk@sourceware.org <agk@sourceware.org>
Date: 11 Jan 2007 17:12:28 -0000
Subject: LVM2 ./WHATS_NEW ./make.tmpl.in daemons/clvmd/ ...
Message-ID: <20070111171228.18295.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-01-11 17:12:27

Modified files:
	.              : WHATS_NEW make.tmpl.in 
	daemons/clvmd  : Makefile.in 
	tools          : Makefile.in 
	tools/fsadm    : Makefile.in 

Log message:
	Use CFLAGS when linking so mixed sparc builds can supply -m64

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.534&r2=1.535
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/make.tmpl.in.diff?cvsroot=lvm2&r1=1.46&r2=1.47
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/Makefile.in.diff?cvsroot=lvm2&r1=1.16&r2=1.17
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/Makefile.in.diff?cvsroot=lvm2&r1=1.77&r2=1.78
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/fsadm/Makefile.in.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/WHATS_NEW	2007/01/10 19:56:38	1.534
+++ LVM2/WHATS_NEW	2007/01/11 17:12:26	1.535
@@ -1,5 +1,6 @@
 Version 2.02.18 -
 ====================================
+  Use CFLAGS when linking so mixed sparc builds can supply -m64.
   Prevent permission changes on active mirrors.
   Print warning instead of error message if lvconvert cannot zero volume.
   Add snapshot options to lvconvert man page.
--- LVM2/make.tmpl.in	2007/01/09 20:31:08	1.46
+++ LVM2/make.tmpl.in	2007/01/11 17:12:26	1.47
@@ -75,6 +75,9 @@
 
 ifneq ("@DMDIR@", "")
   LDFLAGS += -L at DMDIR@/lib/ioctl
+  ifeq ("@DMEVENTD@", "yes")
+    LDFLAGS += -L at DMDIR@/dmeventd
+  endif
 endif
 
 LDFLAGS += -L$(top_srcdir)/lib -L$(libdir)
@@ -170,18 +173,19 @@
 ifeq ("@LIB_SUFFIX@","so")
 $(LIB_SHARED): $(OBJECTS) $(LDDEPS)
 	$(CC) -shared -Wl,-soname,$(notdir $@).$(LIB_VERSION) \
-	$(CLDFLAGS) $(OBJECTS) $(LIBS) -o $@
+	$(CFLAGS) $(CLDFLAGS) $(OBJECTS) $(LIBS) -o $@
 endif
 
 ifeq ("@LIB_SUFFIX@","dylib")
 $(LIB_SHARED): $(OBJECTS) $(LDDEPS)
 	$(CC) -dynamiclib -dylib_current_version,$(LIB_VERSION) \
-	$(CLDFLAGS) $(OBJECTS) $(LIBS) -o $@
+	$(CFLAGS) $(CLDFLAGS) $(OBJECTS) $(LIBS) -o $@
 endif
 
 %.so: %.a
 	$(CC) -shared -Wl,-soname,$(notdir $@).$(LIB_VERSION) \
-	$(CLDFLAGS) $(LIBS) -o $@ @CLDWHOLEARCHIVE@ $< @CLDNOWHOLEARCHIVE@
+	$(CFLAGS) $(CLDFLAGS) $(LIBS) -o $@ \
+	@CLDWHOLEARCHIVE@ $< @CLDNOWHOLEARCHIVE@
 
 $(LIB_STATIC): $(OBJECTS)
 	$(RM) $@
--- LVM2/daemons/clvmd/Makefile.in	2006/10/04 08:22:16	1.16
+++ LVM2/daemons/clvmd/Makefile.in	2007/01/11 17:12:27	1.17
@@ -71,7 +71,8 @@
 	install_clvmd
 
 clvmd: $(OBJECTS) $(top_srcdir)/lib/liblvm.a
-	$(CC) -o clvmd $(OBJECTS) $(LDFLAGS) $(LVMLIBS) $(LMLIBS) $(LIBS)
+	$(CC) -o clvmd $(OBJECTS) $(CFLAGS) $(LDFLAGS) \
+		$(LVMLIBS) $(LMLIBS) $(LIBS)
 
 .PHONY: install_clvmd
 
--- LVM2/tools/Makefile.in	2006/10/26 20:37:13	1.77
+++ LVM2/tools/Makefile.in	2007/01/11 17:12:27	1.78
@@ -101,11 +101,12 @@
 include $(top_srcdir)/make.tmpl
 
 lvm: $(OBJECTS) lvm.o $(top_srcdir)/lib/liblvm.a
-	$(CC) -o $@ $(OBJECTS) lvm.o $(LDFLAGS) $(LVMLIBS) $(LIBS) -rdynamic
+	$(CC) -o $@ $(CFLAGS) $(OBJECTS) lvm.o \
+		$(LDFLAGS) $(LVMLIBS) $(LIBS) -rdynamic
 
 lvm.static: $(OBJECTS) lvm-static.o $(top_srcdir)/lib/liblvm.a
-	$(CC) -o $@ $(OBJECTS) lvm-static.o -static $(LDFLAGS) $(LVMLIBS) \
-		$(LIBS) -rdynamic
+	$(CC) -o $@ $(CFLAGS) $(OBJECTS) lvm-static.o -static \
+		$(LDFLAGS) $(LVMLIBS) $(LIBS) -rdynamic
 
 liblvm2cmd.a: $(top_srcdir)/lib/liblvm.a $(OBJECTS) lvmcmdlib.o lvm2cmd.o
 	cat $(top_srcdir)/lib/liblvm.a > $@
--- LVM2/tools/fsadm/Makefile.in	2004/06/15 17:29:20	1.1
+++ LVM2/tools/fsadm/Makefile.in	2007/01/11 17:12:27	1.2
@@ -23,7 +23,7 @@
 include $(top_srcdir)/make.tmpl
 
 fsadm: $(OBJECTS)
-	$(CC) -o $@ $(OBJECTS) -rdynamic
+	$(CC) -o $@ $(CFLAGS) $(OBJECTS) -rdynamic
 
 install: fsadm
 	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) fsadm \


