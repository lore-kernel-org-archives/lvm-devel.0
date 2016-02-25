From: Alasdair Kergon <agk@fedoraproject.org>
Date: Thu, 25 Feb 2016 13:59:09 +0000 (UTC)
Subject: master - configure
Message-ID: <20160225135909.4D97D602AD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3ac860334b4502fca2f0c780ee968bd62733a73e
Commit:        3ac860334b4502fca2f0c780ee968bd62733a73e
Parent:        718a695b0c0fe0c9088758499e5daae2cb0652a2
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Feb 25 13:58:48 2016 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Feb 25 13:58:48 2016 +0000

configure

---
 configure |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/configure b/configure
index 1d742ec..75967d7 100755
--- a/configure
+++ b/configure
@@ -11518,12 +11518,12 @@ if test -n "$LOCKD_SANLOCK_CFLAGS"; then
     pkg_cv_LOCKD_SANLOCK_CFLAGS="$LOCKD_SANLOCK_CFLAGS"
  elif test -n "$PKG_CONFIG"; then
     if test -n "$PKG_CONFIG" && \
-    { { $as_echo "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"libsanlock_client\""; } >&5
-  ($PKG_CONFIG --exists --print-errors "libsanlock_client") 2>&5
+    { { $as_echo "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"libsanlock_client >= 3.3.0\""; } >&5
+  ($PKG_CONFIG --exists --print-errors "libsanlock_client >= 3.3.0") 2>&5
   ac_status=$?
   $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; then
-  pkg_cv_LOCKD_SANLOCK_CFLAGS=`$PKG_CONFIG --cflags "libsanlock_client" 2>/dev/null`
+  pkg_cv_LOCKD_SANLOCK_CFLAGS=`$PKG_CONFIG --cflags "libsanlock_client >= 3.3.0" 2>/dev/null`
 		      test "x$?" != "x0" && pkg_failed=yes
 else
   pkg_failed=yes
@@ -11535,12 +11535,12 @@ if test -n "$LOCKD_SANLOCK_LIBS"; then
     pkg_cv_LOCKD_SANLOCK_LIBS="$LOCKD_SANLOCK_LIBS"
  elif test -n "$PKG_CONFIG"; then
     if test -n "$PKG_CONFIG" && \
-    { { $as_echo "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"libsanlock_client\""; } >&5
-  ($PKG_CONFIG --exists --print-errors "libsanlock_client") 2>&5
+    { { $as_echo "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"libsanlock_client >= 3.3.0\""; } >&5
+  ($PKG_CONFIG --exists --print-errors "libsanlock_client >= 3.3.0") 2>&5
   ac_status=$?
   $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; then
-  pkg_cv_LOCKD_SANLOCK_LIBS=`$PKG_CONFIG --libs "libsanlock_client" 2>/dev/null`
+  pkg_cv_LOCKD_SANLOCK_LIBS=`$PKG_CONFIG --libs "libsanlock_client >= 3.3.0" 2>/dev/null`
 		      test "x$?" != "x0" && pkg_failed=yes
 else
   pkg_failed=yes
@@ -11561,9 +11561,9 @@ else
         _pkg_short_errors_supported=no
 fi
         if test $_pkg_short_errors_supported = yes; then
-	        LOCKD_SANLOCK_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors --cflags --libs "libsanlock_client" 2>&1`
+	        LOCKD_SANLOCK_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors --cflags --libs "libsanlock_client >= 3.3.0" 2>&1`
         else
-	        LOCKD_SANLOCK_PKG_ERRORS=`$PKG_CONFIG --print-errors --cflags --libs "libsanlock_client" 2>&1`
+	        LOCKD_SANLOCK_PKG_ERRORS=`$PKG_CONFIG --print-errors --cflags --libs "libsanlock_client >= 3.3.0" 2>&1`
         fi
 	# Put the nasty error message in config.log where it belongs
 	echo "$LOCKD_SANLOCK_PKG_ERRORS" >&5


