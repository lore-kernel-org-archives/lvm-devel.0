From: agk@sourceware.org <agk@sourceware.org>
Date: 14 Nov 2008 20:59:57 -0000
Subject: LVM2 libdm/Makefile.in tools/Makefile.in
Message-ID: <20081114205957.22260.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-11-14 20:59:57

Modified files:
	libdm          : Makefile.in 
	tools          : Makefile.in 

Log message:
	some makefile fixes for liblvm2cmd & remove some hardcoded .so

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/Makefile.in.diff?cvsroot=lvm2&r1=1.42&r2=1.43
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/Makefile.in.diff?cvsroot=lvm2&r1=1.89&r2=1.90

--- LVM2/libdm/Makefile.in	2008/11/04 17:25:32	1.42
+++ LVM2/libdm/Makefile.in	2008/11/14 20:59:56	1.43
@@ -95,8 +95,8 @@
 $(VERSIONED_SHLIB): %.$(LIB_SUFFIX).$(LIB_VERSION_DM): $(interface)/%.$(LIB_SUFFIX)
 	rm -f $@
 	$(LN_S) $< $@
-	rm -f libdevmapper.so
-	$(LN_S) $< libdevmapper.so
+	rm -f libdevmapper.$(LIB_SUFFIX)
+	$(LN_S) $< libdevmapper.$(LIB_SUFFIX)
 
 .PHONY: distclean_lib distclean
 
--- LVM2/tools/Makefile.in	2008/11/10 13:41:43	1.89
+++ LVM2/tools/Makefile.in	2008/11/14 20:59:57	1.90
@@ -79,13 +79,13 @@
 
 LVMLIBS = -llvm
 
-CLEAN_TARGETS = liblvm2cmd.so liblvm2cmd.a liblvm2cmd-static.a lvm lvm.o \
+CLEAN_TARGETS = liblvm2cmd.$(LIB_SUFFIX) liblvm2cmd.a liblvm2cmd-static.a lvm lvm.o \
 		lvm2cmd.o lvm2cmd-static.o lvm2cmdlib.o lvm.static \
 		lvm.cflow lvm.xref lvm.tree lvm.rxref lvm.rtree \
 		lvmcmdlib.o lvm-static.o dmsetup.o
 
 ifeq ("@CMDLIB@", "yes")
-	TARGETS += liblvm2cmd.so
+	TARGETS += liblvm2cmd.$(LIB_SUFFIX)
 	INSTALL_LVM_TARGETS += $(INSTALL_CMDLIB_TARGETS)
 endif
 
@@ -129,7 +129,7 @@
 	cat $(top_srcdir)/lib/liblvm.a > $@
 	$(AR) rs $@ $(OBJECTS) lvmcmdlib.o lvm2cmd-static.o
 
-liblvm2cmd.so: liblvm2cmd.a $(LDDEPS)
+liblvm2cmd.$(LIB_SUFFIX): liblvm2cmd.a $(LDDEPS)
 
 .commands: commands.h cmdnames.h Makefile
 	$(CC) -E -P cmdnames.h 2> /dev/null | \
@@ -155,17 +155,17 @@
 cflow: lvm.cflow lvm.xref lvm.tree lvm.rtree lvm.rxref
 endif
 
-install_cmdlib_dynamic: liblvm2cmd.so
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) liblvm2cmd.so \
-		$(libdir)/liblvm2cmd.so.$(LIB_VERSION)
-	$(LN_S) -f liblvm2cmd.so.$(LIB_VERSION) $(libdir)/liblvm2cmd.so
+install_cmdlib_dynamic: liblvm2cmd.$(LIB_SUFFIX)
+	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) liblvm2cmd.$(LIB_SUFFIX) \
+		$(libdir)/liblvm2cmd.$(LIB_SUFFIX).$(LIB_VERSION_LVM)
+	$(LN_S) -f liblvm2cmd.$(LIB_SUFFIX).$(LIB_VERSION_LVM) $(libdir)/liblvm2cmd.$(LIB_SUFFIX)
 	$(INSTALL) -D $(OWNER) $(GROUP) -m 444 lvm2cmd.h \
 		$(includedir)/lvm2cmd.h
 
 install_cmdlib_static: liblvm2cmd-static.a
 	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) liblvm2cmd-static.a \
-		$(libdir)/liblvm2cmd.a.$(LIB_VERSION)
-	$(LN_S) -f liblvm2cmd.a.$(LIB_VERSION) $(libdir)/liblvm2cmd.a
+		$(libdir)/liblvm2cmd.a.$(LIB_VERSION_LVM)
+	$(LN_S) -f liblvm2cmd.a.$(LIB_VERSION_LVM) $(libdir)/liblvm2cmd.a
 	$(INSTALL) -D $(OWNER) $(GROUP) -m 444 lvm2cmd.h \
 		$(includedir)/lvm2cmd.h
 


