From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:43:19 +0000 (UTC)
Subject: master - configure: Look for valgrind.h independently of VALGRIND_POOLS.
Message-ID: <20150205134319.3CED060E22@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d571eab3b2bbb9be80e75e633bf2e30834975552
Commit:        d571eab3b2bbb9be80e75e633bf2e30834975552
Parent:        5d833fd4587ce30eb1fb4e20363ede07c40bc2f0
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Oct 1 08:16:27 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:50:34 2015 +0100

configure: Look for valgrind.h independently of VALGRIND_POOLS.

---
 configure.in      |   14 ++++++++++----
 lib/Makefile.in   |    2 +-
 libdm/Makefile.in |    5 +----
 make.tmpl.in      |    1 +
 4 files changed, 13 insertions(+), 9 deletions(-)

diff --git a/configure.in b/configure.in
index add6653..18e1c17 100644
--- a/configure.in
+++ b/configure.in
@@ -1023,12 +1023,18 @@ AC_ARG_ENABLE(valgrind_pool,
 	      VALGRIND_POOL=$enableval, VALGRIND_POOL=no)
 AC_MSG_RESULT($VALGRIND_POOL)
 
-if test "$VALGRIND_POOL" = yes; then
-	pkg_config_init
-	PKG_CHECK_MODULES(VALGRIND, valgrind, [], [AC_MSG_ERROR(bailing out)])
+pkg_config_init
+PKG_CHECK_MODULES(VALGRIND, valgrind, [HAVE_VALGRIND=yes], [if test x$VALGRIND_POOL = xyes; then AC_MSG_ERROR(bailing out); fi])
+AC_SUBST(VALGRIND_CFLAGS)
+
+if test x$HAVE_VALGRIND = xyes; then
+	AC_DEFINE([HAVE_VALGRIND], 1, [valgrind.h found])
+	AC_SUBST(HAVE_VALGRIND)
+fi
+
+if test x$VALGRIND_POOL = xyes; then
 	AC_DEFINE([VALGRIND_POOL], 1, [Enable a valgrind aware build of pool])
 	AC_SUBST(VALGRIND_POOL)
-	AC_SUBST(VALGRIND_CFLAGS)
 fi
 
 ################################################################################
diff --git a/lib/Makefile.in b/lib/Makefile.in
index 62600d5..749342d 100644
--- a/lib/Makefile.in
+++ b/lib/Makefile.in
@@ -222,7 +222,7 @@ CFLOW_LIST_TARGET = $(LIB_NAME).cflow
 
 include $(top_builddir)/make.tmpl
 
-CFLAGS += $(BLKID_CFLAGS) $(UDEV_CFLAGS)
+CFLAGS += $(BLKID_CFLAGS) $(UDEV_CFLAGS) $(VALGRIND_CFLAGS)
 
 $(SUBDIRS): $(LIB_STATIC)
 
diff --git a/libdm/Makefile.in b/libdm/Makefile.in
index e50b174..8e057c3 100644
--- a/libdm/Makefile.in
+++ b/libdm/Makefile.in
@@ -34,10 +34,7 @@ SOURCES =\
 	$(interface)/libdm-iface.c
 
 INCLUDES = -I$(srcdir)/$(interface) -I$(srcdir)
-ifeq ("@VALGRIND_POOL@", "yes")
-INCLUDES += @VALGRIND_CFLAGS@
-endif
-CFLAGS += $(UDEV_CFLAGS)
+CFLAGS += $(UDEV_CFLAGS) $(VALGRIND_CFLAGS)
 
 ifeq ("@STATIC_LINK@", "yes")
 LIB_STATIC = $(interface)/libdevmapper.a
diff --git a/make.tmpl.in b/make.tmpl.in
index 3a82731..cfa065c 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -61,6 +61,7 @@ UDEV_CFLAGS = @UDEV_CFLAGS@
 UDEV_LIBS = @UDEV_LIBS@
 BLKID_CFLAGS = @BLKID_CFLAGS@
 BLKID_LIBS = @BLKID_LIBS@
+VALGRIND_CFLAGS = @VALGRIND_CFLAGS@
 TESTING = @TESTING@
 
 # Setup directory variables


