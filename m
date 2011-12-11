From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 11 Dec 2011 15:15:58 -0000
Subject: LVM2 test/unit/Makefile.in ./configure.in
Message-ID: <20111211151558.5758.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-12-11 15:15:58

Modified files:
	test/unit      : Makefile.in 
	.              : configure.in 

Log message:
	Use pkg-config to look for CUnit (needed for systems where it's not on the
	standard include path).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/unit/Makefile.in.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.176&r2=1.177

--- LVM2/test/unit/Makefile.in	2011/11/23 12:21:42	1.3
+++ LVM2/test/unit/Makefile.in	2011/12/11 15:15:57	1.4
@@ -19,12 +19,13 @@
 TARGETS = run
 
 include $(top_builddir)/make.tmpl
-LDFLAGS += -ldevmapper -lcunit
-
 ifeq ("$(TESTING)", "yes")
+LDFLAGS += -ldevmapper @CUNIT_LIBS@
+CFLAGS += @CUNIT_CFLAGS@
+
 all: unit
-endif
 
 unit: $(TARGETS)
 	@echo Running unit tests
 	LD_LIBRARY_PATH=$(top_builddir)/libdm ./$(TARGETS)
+endif
--- LVM2/configure.in	2011/11/21 10:40:21	1.176
+++ LVM2/configure.in	2011/12/11 15:15:57	1.177
@@ -759,10 +759,7 @@
 AC_MSG_RESULT($TESTING)
 
 if test "$TESTING" = yes; then
-	AC_CHECK_HEADER([CUnit/Basic.h], have_cunit=yes, have_cunit=no)
-	if test "$have_cunit" = "no"; then
-		AC_MSG_ERROR([CUnit is required for unit testing])
-	fi
+	PKG_CHECK_MODULES(CUNIT, cunit >= 2.0)
 fi
 
 ################################################################################
@@ -1391,6 +1388,8 @@
 AC_SUBST(UDEV_PC)
 AC_SUBST(UDEV_RULES)
 AC_SUBST(UDEV_SYNC)
+AC_SUBST(CUNIT_LIBS)
+AC_SUBST(CUNIT_CFLAGS)
 AC_SUBST(WRITE_INSTALL)
 AC_SUBST(DMEVENTD_PIDFILE)
 AC_SUBST(interface)


