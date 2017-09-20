From: Marian Csontos <mcsontos@sourceware.org>
Date: Wed, 20 Sep 2017 07:08:58 -0400
Subject: master - configure: Add warning for D-Bus w/o notifications
Message-ID: <201709201108.v8KB8w1f017024@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=03bcd29481e879eb890278997e7f7214757de952
Commit:        03bcd29481e879eb890278997e7f7214757de952
Parent:        0c46f9cf0cf712e96dd2078b9121df1078b11e2a
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Wed Sep 20 10:25:29 2017 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Wed Sep 20 13:07:06 2017 +0200

configure: Add warning for D-Bus w/o notifications

Building D-Bus support without notifications is not recommended.
---
 configure    |    4 ++++
 configure.in |    2 ++
 2 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/configure b/configure
index 78c738d..9f2f744 100755
--- a/configure
+++ b/configure
@@ -12825,6 +12825,10 @@ fi
 
 { $as_echo "$as_me:${as_lineno-$LINENO}: result: $BUILD_LVMDBUSD" >&5
 $as_echo "$BUILD_LVMDBUSD" >&6; }
+if test "$NOTIFYDBUS_SUPPORT" = yes && test "BUILD_LVMDBUSD" = yes; then :
+  { $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: Building D-Bus support without D-Bus notifications." >&5
+$as_echo "$as_me: WARNING: Building D-Bus support without D-Bus notifications." >&2;}
+fi
 
 ################################################################################
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to build Python wrapper for liblvm2app.so" >&5
diff --git a/configure.in b/configure.in
index e2f448e..00e70aa 100644
--- a/configure.in
+++ b/configure.in
@@ -1486,6 +1486,8 @@ AC_ARG_ENABLE(dbus-service,
 	      AC_HELP_STRING([--enable-dbus-service], [install D-Bus support]),
 	      BUILD_LVMDBUSD=$enableval, BUILD_LVMDBUSD=no)
 AC_MSG_RESULT($BUILD_LVMDBUSD)
+AS_IF([test "$NOTIFYDBUS_SUPPORT" = yes && test "BUILD_LVMDBUSD" = yes],
+      [AC_MSG_WARN([Building D-Bus support without D-Bus notifications.])])
 
 ################################################################################
 dnl -- Enable Python liblvm2app bindings


