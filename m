From: agk@sourceware.org <agk@sourceware.org>
Date: 21 May 2009 11:11:30 -0000
Subject: LVM2 tools/Makefile.in ./WHATS_NEW
Message-ID: <20090521111130.18729.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-05-21 11:11:30

Modified files:
	tools          : Makefile.in 
	.              : WHATS_NEW 

Log message:
	Reinstate version in liblvm2cmd.so soname. (2.02.44)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/Makefile.in.diff?cvsroot=lvm2&r1=1.97&r2=1.98
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1121&r2=1.1122

--- LVM2/tools/Makefile.in	2009/05/11 10:28:46	1.97
+++ LVM2/tools/Makefile.in	2009/05/21 11:11:29	1.98
@@ -81,6 +81,7 @@
 endif
 
 LVMLIBS = -llvm-internal
+LIB_VERSION = $(LIB_VERSION_LVM)
 
 CLEAN_TARGETS = liblvm2cmd.$(LIB_SUFFIX) liblvm2cmd.a liblvm2cmd-static.a lvm lvm.o \
 		lvm2cmd.o lvm2cmd-static.o lvm2cmdlib.o lvm.static \
@@ -160,15 +161,15 @@
 
 install_cmdlib_dynamic: liblvm2cmd.$(LIB_SUFFIX)
 	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) liblvm2cmd.$(LIB_SUFFIX) \
-		$(libdir)/liblvm2cmd.$(LIB_SUFFIX).$(LIB_VERSION_LVM)
-	$(LN_S) -f liblvm2cmd.$(LIB_SUFFIX).$(LIB_VERSION_LVM) $(libdir)/liblvm2cmd.$(LIB_SUFFIX)
+		$(libdir)/liblvm2cmd.$(LIB_SUFFIX).$(LIB_VERSION)
+	$(LN_S) -f liblvm2cmd.$(LIB_SUFFIX).$(LIB_VERSION) $(libdir)/liblvm2cmd.$(LIB_SUFFIX)
 	$(INSTALL) -D $(OWNER) $(GROUP) -m 444 lvm2cmd.h \
 		$(includedir)/lvm2cmd.h
 
 install_cmdlib_static: liblvm2cmd-static.a
 	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) liblvm2cmd-static.a \
-		$(libdir)/liblvm2cmd.a.$(LIB_VERSION_LVM)
-	$(LN_S) -f liblvm2cmd.a.$(LIB_VERSION_LVM) $(libdir)/liblvm2cmd.a
+		$(libdir)/liblvm2cmd.a.$(LIB_VERSION)
+	$(LN_S) -f liblvm2cmd.a.$(LIB_VERSION) $(libdir)/liblvm2cmd.a
 	$(INSTALL) -D $(OWNER) $(GROUP) -m 444 lvm2cmd.h \
 		$(includedir)/lvm2cmd.h
 
--- LVM2/WHATS_NEW	2009/05/21 03:04:52	1.1121
+++ LVM2/WHATS_NEW	2009/05/21 11:11:30	1.1122
@@ -1,3 +1,7 @@
+Version 2.02.47 - 21st May 2009
+===============================
+  Reinstate version in liblvm2cmd.so soname. (2.02.44)
+
 Version 2.02.46 - 21st May 2009
 ===============================
   Inherit readahead setting from underlying devices during activation.


