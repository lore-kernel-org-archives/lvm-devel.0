From: Bryn Reeves <bmr@sourceware.org>
Date: Thu, 9 Mar 2017 16:22:11 -0500
Subject: master - configure: make --enable-dmfilemapd require fiemap.h
Message-ID: <201703092122.v29LMB78004272@int-mx10.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=af7a11bc57b2a3bb103cde47812a876b8d7a2d71
Commit:        af7a11bc57b2a3bb103cde47812a876b8d7a2d71
Parent:        66fff1d7748f8251c8781830fa984f34d1492310
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Thu Mar 9 21:12:53 2017 +0000
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Thu Mar 9 21:20:27 2017 +0000

configure: make --enable-dmfilemapd require fiemap.h

---
 configure    |   12 +++++++++++-
 configure.in |    5 +++++
 2 files changed, 16 insertions(+), 1 deletions(-)

diff --git a/configure b/configure
index f522c98..4798d5e 100755
--- a/configure
+++ b/configure
@@ -12093,6 +12093,17 @@ BUILD_DMFILEMAPD=$DMFILEMAPD
 $as_echo "#define DMFILEMAPD 1" >>confdefs.h
 
 
+if test "$DMFILEMAPD" = yes; then
+   ac_fn_c_check_header_mongrel "$LINENO" "linux/fiemap.h" "ac_cv_header_linux_fiemap_h" "$ac_includes_default"
+if test "x$ac_cv_header_linux_fiemap_h" = xyes; then :
+
+else
+  as_fn_error $? "--enable-dmfilemapd requires fiemap.h" "$LINENO" 5
+fi
+
+
+fi
+
 ################################################################################
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to build notifydbus" >&5
 $as_echo_n "checking whether to build notifydbus... " >&6; }
@@ -15159,7 +15170,6 @@ done
 
 fi
 
-
 ################################################################################
 if test -n "$ac_tool_prefix"; then
   # Extract the first word of "${ac_tool_prefix}modprobe", so it can be a program name with args.
diff --git a/configure.in b/configure.in
index bf7ad97..9dfb836 100644
--- a/configure.in
+++ b/configure.in
@@ -1281,6 +1281,11 @@ AC_MSG_RESULT($DMFILEMAPD)
 BUILD_DMFILEMAPD=$DMFILEMAPD
 AC_DEFINE([DMFILEMAPD], 1, [Define to 1 to enable the device-mapper filemap daemon.])
 
+dnl -- dmfilemapd requires FIEMAP
+if test "$DMFILEMAPD" = yes; then
+   AC_CHECK_HEADER([linux/fiemap.h], , [AC_MSG_ERROR(--enable-dmfilemapd requires fiemap.h)])
+fi
+
 ################################################################################
 dnl -- Build notifydbus
 AC_MSG_CHECKING(whether to build notifydbus)


