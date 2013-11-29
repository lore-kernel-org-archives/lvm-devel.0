From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 29 Nov 2013 15:39:26 +0000 (UTC)
Subject: master - configure: require libblkid >= 2.24 for blkid wiping
Message-ID: <20131129153926.859F060D67@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d2d5c24a68285a2f056977f877ab1a19e61b992f
Commit:        d2d5c24a68285a2f056977f877ab1a19e61b992f
Parent:        75628f341ad38b68aae33eae0b5700be2a6e5769
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Nov 29 16:37:09 2013 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Nov 29 16:38:53 2013 +0100

configure: require libblkid >= 2.24 for blkid wiping

Some symbols/identifiers were defined even later than 2.22, like BLKID_SUBLKS_BADCSUM.
---
 configure    |   20 ++++++++++----------
 configure.in |    4 ++--
 2 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/configure b/configure
index 5d81dac..564d322 100755
--- a/configure
+++ b/configure
@@ -9211,12 +9211,12 @@ if test -n "$BLKID_CFLAGS"; then
     pkg_cv_BLKID_CFLAGS="$BLKID_CFLAGS"
  elif test -n "$PKG_CONFIG"; then
     if test -n "$PKG_CONFIG" && \
-    { { $as_echo "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"blkid >= 2.22\""; } >&5
-  ($PKG_CONFIG --exists --print-errors "blkid >= 2.22") 2>&5
+    { { $as_echo "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"blkid >= 2.24\""; } >&5
+  ($PKG_CONFIG --exists --print-errors "blkid >= 2.24") 2>&5
   ac_status=$?
   $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; then
-  pkg_cv_BLKID_CFLAGS=`$PKG_CONFIG --cflags "blkid >= 2.22" 2>/dev/null`
+  pkg_cv_BLKID_CFLAGS=`$PKG_CONFIG --cflags "blkid >= 2.24" 2>/dev/null`
 else
   pkg_failed=yes
 fi
@@ -9227,12 +9227,12 @@ if test -n "$BLKID_LIBS"; then
     pkg_cv_BLKID_LIBS="$BLKID_LIBS"
  elif test -n "$PKG_CONFIG"; then
     if test -n "$PKG_CONFIG" && \
-    { { $as_echo "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"blkid >= 2.22\""; } >&5
-  ($PKG_CONFIG --exists --print-errors "blkid >= 2.22") 2>&5
+    { { $as_echo "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"blkid >= 2.24\""; } >&5
+  ($PKG_CONFIG --exists --print-errors "blkid >= 2.24") 2>&5
   ac_status=$?
   $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; then
-  pkg_cv_BLKID_LIBS=`$PKG_CONFIG --libs "blkid >= 2.22" 2>/dev/null`
+  pkg_cv_BLKID_LIBS=`$PKG_CONFIG --libs "blkid >= 2.24" 2>/dev/null`
 else
   pkg_failed=yes
 fi
@@ -9252,9 +9252,9 @@ else
         _pkg_short_errors_supported=no
 fi
         if test $_pkg_short_errors_supported = yes; then
-	        BLKID_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors "blkid >= 2.22" 2>&1`
+	        BLKID_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors "blkid >= 2.24" 2>&1`
         else
-	        BLKID_PKG_ERRORS=`$PKG_CONFIG --print-errors "blkid >= 2.22" 2>&1`
+	        BLKID_PKG_ERRORS=`$PKG_CONFIG --print-errors "blkid >= 2.24" 2>&1`
         fi
 	# Put the nasty error message in config.log where it belongs
 	echo "$BLKID_PKG_ERRORS" >&5
@@ -9262,7 +9262,7 @@ fi
 	if test x$BLKID_WIPING = xmaybe; then
 					BLKID_WIPING=no
 				 else
-					as_fn_error $? "bailing out... blkid library >= 2.22 is required" "$LINENO" 5
+					as_fn_error $? "bailing out... blkid library >= 2.24 is required" "$LINENO" 5
 				 fi
 
 elif test $pkg_failed = untried; then
@@ -9271,7 +9271,7 @@ $as_echo "no" >&6; }
 	if test x$BLKID_WIPING = xmaybe; then
 					BLKID_WIPING=no
 				 else
-					as_fn_error $? "bailing out... blkid library >= 2.22 is required" "$LINENO" 5
+					as_fn_error $? "bailing out... blkid library >= 2.24 is required" "$LINENO" 5
 				 fi
 
 else
diff --git a/configure.in b/configure.in
index b4a407a..e4d0014 100644
--- a/configure.in
+++ b/configure.in
@@ -959,14 +959,14 @@ if test x$BLKID_WIPING != xno; then
 	if test x$PKGCONFIG_INIT != x1; then
 		pkg_config_init
 	fi
-	PKG_CHECK_MODULES(BLKID, blkid >= 2.22,
+	PKG_CHECK_MODULES(BLKID, blkid >= 2.24,
 				[if test x$BLKID_WIPING = xmaybe; then
 					BLKID_WIPING=yes
 				 fi],
 				[if test x$BLKID_WIPING = xmaybe; then
 					BLKID_WIPING=no
 				 else
-					AC_MSG_ERROR([bailing out... blkid library >= 2.22 is required])
+					AC_MSG_ERROR([bailing out... blkid library >= 2.24 is required])
 				 fi
 				])
 	if test x$BLKID_WIPING = xyes; then


