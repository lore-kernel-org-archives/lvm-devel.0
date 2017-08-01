From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 1 Aug 2017 06:01:20 -0400
Subject: master - makefiles: RT_LIB
Message-ID: <201708011001.v71A1KLX011507@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=57727bb4ebffb30cf21b151cc2f66bfd7d924a81
Commit:        57727bb4ebffb30cf21b151cc2f66bfd7d924a81
Parent:        2593777f65da806e24d9b1a2c9cab25ff59c5351
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jul 31 23:56:58 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Aug 1 11:53:13 2017 +0200

makefiles: RT_LIB

Link -lrt directly only with  libdevmapper.
All other users get dependency transiently.
---
 configure         |    2 +-
 configure.in      |    2 +-
 libdm/Makefile.in |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/configure b/configure
index e1ae0e8..8396e3e 100755
--- a/configure
+++ b/configure
@@ -3170,6 +3170,7 @@ fi
 case "$host_os" in
 	linux*)
 		CLDFLAGS="$CLDFLAGS -Wl,--version-script,.export.sym"
+		# equivalent to -rdynamic
 		ELDFLAGS="-Wl,--export-dynamic"
 		# FIXME Generate list and use --dynamic-list=.dlopen.sym
 		CLDWHOLEARCHIVE="-Wl,-whole-archive"
@@ -14363,7 +14364,6 @@ fi
 
 $as_echo "#define HAVE_REALTIME 1" >>confdefs.h
 
-		LIBS="-lrt $LIBS"
 		RT_LIB="-lrt"
 	else
 		{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: Disabling realtime clock" >&5
diff --git a/configure.in b/configure.in
index 2e5e015..4e13679 100644
--- a/configure.in
+++ b/configure.in
@@ -31,6 +31,7 @@ AS_IF([test -z "$CFLAGS"], [COPTIMISE_FLAG="-O2"])
 case "$host_os" in
 	linux*)
 		CLDFLAGS="$CLDFLAGS -Wl,--version-script,.export.sym"
+		# equivalent to -rdynamic
 		ELDFLAGS="-Wl,--export-dynamic"
 		# FIXME Generate list and use --dynamic-list=.dlopen.sym
 		CLDWHOLEARCHIVE="-Wl,-whole-archive"
@@ -1675,7 +1676,6 @@ if test "$REALTIME" = yes; then
 
 	if test "$HAVE_REALTIME" = yes; then
 		AC_DEFINE([HAVE_REALTIME], 1, [Define to 1 to include support for realtime clock.])
-		LIBS="-lrt $LIBS"
 		RT_LIB="-lrt"
 	else
 		AC_MSG_WARN(Disabling realtime clock)
diff --git a/libdm/Makefile.in b/libdm/Makefile.in
index 3c9a4ce..5adf992 100644
--- a/libdm/Makefile.in
+++ b/libdm/Makefile.in
@@ -56,7 +56,7 @@ include $(top_builddir)/make.tmpl
 
 CFLAGS += $(UDEV_CFLAGS) $(VALGRIND_CFLAGS)
 
-LIBS += $(SELINUX_LIBS) $(UDEV_LIBS) $(PTHREAD_LIBS) $(M_LIBS)
+LIBS += $(RT_LIB) $(SELINUX_LIBS) $(UDEV_LIBS) $(PTHREAD_LIBS) $(M_LIBS)
 
 device-mapper: all
 


