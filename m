From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 15 Apr 2010 15:12:24 -0000
Subject: LVM2 ./WHATS_NEW ./make.tmpl.in tools/Makefile.in
Message-ID: <20100415151224.14710.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-04-15 15:12:20

Modified files:
	.              : WHATS_NEW make.tmpl.in 
	tools          : Makefile.in 

Log message:
	Install symbolic .so links with relative paths between usrlibdir and libdir.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1527&r2=1.1528
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/make.tmpl.in.diff?cvsroot=lvm2&r1=1.91&r2=1.92
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/Makefile.in.diff?cvsroot=lvm2&r1=1.116&r2=1.117

--- LVM2/WHATS_NEW	2010/04/15 15:09:35	1.1527
+++ LVM2/WHATS_NEW	2010/04/15 15:12:20	1.1528
@@ -2,6 +2,7 @@
 =================================
   Added awk script relpath.awk to calculate relative paths.
   Fix double DESTDIR usage for infodir and mandir.
+  Install symbolic .so links with relative paths between usrlibdir and libdir.
 
 Version 2.02.63 - 14th April 2010
 =================================
--- LVM2/make.tmpl.in	2010/04/15 15:09:35	1.91
+++ LVM2/make.tmpl.in	2010/04/15 15:12:20	1.92
@@ -62,6 +62,8 @@
 localedir = $(DESTDIR)@LOCALEDIR@
 staticdir = $(DESTDIR)@STATICDIR@
 udevdir = $(DESTDIR)@udevdir@
+USRLIB_RELPATH = $(shell echo $(abspath $(usrlibdir) $(libdir)) | \
+  awk -f $(top_srcdir)/scripts/relpath.awk)
 
 # Setup vpath search paths for some suffixes
 vpath %.c $(srcdir)
@@ -301,7 +303,7 @@
 install_lib_shared: $(LIB_SHARED)
 	$(INSTALL_PROGRAM) -D $< $(libdir)/$(<F).$(LIB_VERSION)
 	$(INSTALL) -d $(usrlibdir)
-	$(LN_S) -f $(libdir)/$(<F).$(LIB_VERSION) $(usrlibdir)/$(<F)
+	$(LN_S) -f $(USRLIB_RELPATH)$(<F).$(LIB_VERSION) $(usrlibdir)/$(<F)
 
 # FIXME: plugins are currently installed with .so suffix only
 install_lib_shared_plugin: $(LIB_SHARED)
--- LVM2/tools/Makefile.in	2010/04/09 21:42:51	1.116
+++ LVM2/tools/Makefile.in	2010/04/15 15:12:20	1.117
@@ -169,7 +169,7 @@
 install_cmdlib_dynamic: liblvm2cmd.$(LIB_SUFFIX)
 	$(INSTALL_PROGRAM) -D $< $(libdir)/$(<F).$(LIB_VERSION)
 	$(INSTALL) -d $(usrlibdir)
-	$(LN_S) -f $(libdir)/$<.$(LIB_VERSION) $(usrlibdir)/$(<F)
+	$(LN_S) -f $(USRLIB_RELPATH)$(<F).$(LIB_VERSION) $(usrlibdir)/$(<F)
 
 install_cmdlib_static: liblvm2cmd-static.a
 	$(INSTALL_DATA) -D $< $(usrlibdir)/liblvm2cmd.a


