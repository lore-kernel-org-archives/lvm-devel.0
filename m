From: Marian Csontos <mcsontos@sourceware.org>
Date: Mon, 11 Dec 2017 09:22:49 -0500
Subject: master - configure: Fix deprecation warning for lvmapp
Message-ID: <201712111422.vBBEMn0u016440@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=75d4d8e9a42a4709ed40348395b1e75dff4197e8
Commit:        75d4d8e9a42a4709ed40348395b1e75dff4197e8
Parent:        2aedc98242cefd29a5eccabb600be6f37e756fda
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Mon Dec 11 15:20:48 2017 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Mon Dec 11 15:20:48 2017 +0100

configure: Fix deprecation warning for lvmapp

* and properly regenerate configure script
---
 configure    |    6 +++---
 configure.in |    2 +-
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/configure b/configure
index 903ad6e..7e2969a 100755
--- a/configure
+++ b/configure
@@ -12777,8 +12777,8 @@ test "$APPLIB" = yes \
   && LVM2APP_LIB=-llvm2app \
   || LVM2APP_LIB=
 if test "$APPLIB"; then :
-  { $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: Python bindings are deprecated. Use D-Bus API" >&5
-$as_echo "$as_me: WARNING: Python bindings are deprecated. Use D-Bus API" >&2;}
+  { $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: liblvm2app is deprecated. Use D-Bus API" >&5
+$as_echo "$as_me: WARNING: liblvm2app is deprecated. Use D-Bus API" >&2;}
 fi
 
 ################################################################################
@@ -13791,7 +13791,7 @@ fi
 	PYTHON3_INCDIRS=`"$PYTHON3_CONFIG" --includes`
 	PYTHON3_LIBDIRS=`"$PYTHON3_CONFIG" --libs`
 	PYTHON3DIR=$pythondir
-	PYTHON_BINDINGS=yes
+	test "$PYTHON3_BINDINGS" = yes && PYTHON_BINDINGS=yes
 fi
 
 if test "$BUILD_LVMDBUSD" = yes; then
diff --git a/configure.in b/configure.in
index 85ddce0..88ee5ad 100644
--- a/configure.in
+++ b/configure.in
@@ -1455,7 +1455,7 @@ test "$APPLIB" = yes \
   && LVM2APP_LIB=-llvm2app \
   || LVM2APP_LIB=
 AS_IF([test "$APPLIB"],
-      [AC_MSG_WARN([Python bindings are deprecated. Use D-Bus API])])
+      [AC_MSG_WARN([liblvm2app is deprecated. Use D-Bus API])])
 
 ################################################################################
 dnl -- Enable cmdlib


