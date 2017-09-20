From: Marian Csontos <mcsontos@sourceware.org>
Date: Wed, 20 Sep 2017 07:08:49 -0400
Subject: master - liblvm: Add deprecation warning to configure
Message-ID: <201709201108.v8KB8nGc017008@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8493df8eddc5a05a2af9a9c4d8e11192f07ec79a
Commit:        8493df8eddc5a05a2af9a9c4d8e11192f07ec79a
Parent:        4cbacf6bac47227ec3460da1619ab29557f2c89b
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Wed Sep 20 10:00:59 2017 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Wed Sep 20 13:07:06 2017 +0200

liblvm: Add deprecation warning to configure

---
 configure.in |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/configure.in b/configure.in
index 43e8652..e2f448e 100644
--- a/configure.in
+++ b/configure.in
@@ -1464,6 +1464,8 @@ AC_SUBST([LVM2APP_LIB])
 test "$APPLIB" = yes \
   && LVM2APP_LIB=-llvm2app \
   || LVM2APP_LIB=
+AS_IF([test "$APPLIB"],
+      [AC_MSG_WARN([Python bindings are deprecated. Use D-Bus API])])
 
 ################################################################################
 dnl -- Enable cmdlib
@@ -1546,6 +1548,7 @@ if test "$BUILD_LVMDBUSD" = yes; then
 fi
 
 if test "$PYTHON_BINDINGS" = yes -o "$PYTHON2_BINDINGS" = yes -o "$PYTHON3_BINDINGS" = yes; then
+	AC_MSG_WARN([Python bindings are deprecated. Use D-Bus API])
 	test "$APPLIB" != yes && AC_MSG_ERROR([Python_bindings require --enable-applib])
 fi
 


