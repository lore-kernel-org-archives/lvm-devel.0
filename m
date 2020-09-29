From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 29 Sep 2020 08:45:17 +0000 (GMT)
Subject: master - configure: editline updates
Message-ID: <20200929084517.3C510384B010@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=655342427da621174f04506fb7002f54af832e07
Commit:        655342427da621174f04506fb7002f54af832e07
Parent:        168e2ffbcd8c8cf20711be36059bfcf999a95012
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 29 10:15:45 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 29 10:43:45 2020 +0200

configure: editline updates

Update configure file.
---
 WHATS_NEW |   1 +
 configure | 123 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 123 insertions(+), 1 deletion(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index d50ba762a..a8639ff65 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.11 - 
 ==================================
+  Add configure --enable-editline support as an alternative to readline.
   Enhance reporting and error handling when creating thin volumes.
   Enable vgsplit for VDO volumes.
   Lvextend of vdo pool volumes ensure at least 1 new VDO slab is added.
diff --git a/configure b/configure
index f7b681cad..d39ce1b98 100755
--- a/configure
+++ b/configure
@@ -753,6 +753,8 @@ BUILD_CMIRRORD
 BLKID_PC
 MODPROBE_CMD
 MSGFMT
+EDITLINE_LIBS
+EDITLINE_CFLAGS
 PYTHON3_CONFIG
 pkgpyexecdir
 pyexecdir
@@ -920,6 +922,7 @@ with_vdo_format
 with_writecache
 with_integrity
 enable_readline
+enable_editline
 enable_realtime
 enable_ocf
 with_ocfdir
@@ -1015,7 +1018,9 @@ SYSTEMD_CFLAGS
 SYSTEMD_LIBS
 UDEV_CFLAGS
 UDEV_LIBS
-PYTHON'
+PYTHON
+EDITLINE_CFLAGS
+EDITLINE_LIBS'
 
 
 # Initialize some variables set by options.
@@ -1638,6 +1643,7 @@ Optional Features:
   --disable-cache_check_needs_check
                           required if cache_check version is < 0.5
   --disable-readline      disable readline support
+  --enable-editline       enable editline support
   --disable-realtime      disable realtime clock support
   --enable-ocf            enable Open Cluster Framework (OCF) compliant
                           resource agents
@@ -1816,6 +1822,10 @@ Some influential environment variables:
   UDEV_CFLAGS C compiler flags for UDEV, overriding pkg-config
   UDEV_LIBS   linker flags for UDEV, overriding pkg-config
   PYTHON      the Python interpreter
+  EDITLINE_CFLAGS
+              C compiler flags for EDITLINE, overriding pkg-config
+  EDITLINE_LIBS
+              linker flags for EDITLINE, overriding pkg-config
 
 Use these variables to override the choices made by `configure' or to help
 it to find libraries and programs with nonstandard names/locations.
@@ -9797,6 +9807,15 @@ else
 fi
 
 
+################################################################################
+# Check whether --enable-editline was given.
+if test "${enable_editline+set}" = set; then :
+  enableval=$enable_editline; EDITLINE=$enableval
+else
+  EDITLINE=no
+fi
+
+
 ################################################################################
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to enable realtime support" >&5
 $as_echo_n "checking whether to enable realtime support... " >&6; }
@@ -12808,6 +12827,86 @@ fi
 done
 
 
+################################################################################
+if test "$EDITLINE" == yes; then
+
+pkg_failed=no
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for EDITLINE" >&5
+$as_echo_n "checking for EDITLINE... " >&6; }
+
+if test -n "$EDITLINE_CFLAGS"; then
+    pkg_cv_EDITLINE_CFLAGS="$EDITLINE_CFLAGS"
+ elif test -n "$PKG_CONFIG"; then
+    if test -n "$PKG_CONFIG" && \
+    { { $as_echo "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"libedit\""; } >&5
+  ($PKG_CONFIG --exists --print-errors "libedit") 2>&5
+  ac_status=$?
+  $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
+  test $ac_status = 0; }; then
+  pkg_cv_EDITLINE_CFLAGS=`$PKG_CONFIG --cflags "libedit" 2>/dev/null`
+		      test "x$?" != "x0" && pkg_failed=yes
+else
+  pkg_failed=yes
+fi
+ else
+    pkg_failed=untried
+fi
+if test -n "$EDITLINE_LIBS"; then
+    pkg_cv_EDITLINE_LIBS="$EDITLINE_LIBS"
+ elif test -n "$PKG_CONFIG"; then
+    if test -n "$PKG_CONFIG" && \
+    { { $as_echo "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"libedit\""; } >&5
+  ($PKG_CONFIG --exists --print-errors "libedit") 2>&5
+  ac_status=$?
+  $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
+  test $ac_status = 0; }; then
+  pkg_cv_EDITLINE_LIBS=`$PKG_CONFIG --libs "libedit" 2>/dev/null`
+		      test "x$?" != "x0" && pkg_failed=yes
+else
+  pkg_failed=yes
+fi
+ else
+    pkg_failed=untried
+fi
+
+
+
+if test $pkg_failed = yes; then
+   	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+$as_echo "no" >&6; }
+
+if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
+        _pkg_short_errors_supported=yes
+else
+        _pkg_short_errors_supported=no
+fi
+        if test $_pkg_short_errors_supported = yes; then
+	        EDITLINE_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors --cflags --libs "libedit" 2>&1`
+        else
+	        EDITLINE_PKG_ERRORS=`$PKG_CONFIG --print-errors --cflags --libs "libedit" 2>&1`
+        fi
+	# Put the nasty error message in config.log where it belongs
+	echo "$EDITLINE_PKG_ERRORS" >&5
+
+	as_fn_error $? "libedit could not be found which is required for the --enable-readline option." "$LINENO" 5
+
+elif test $pkg_failed = untried; then
+     	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+$as_echo "no" >&6; }
+	as_fn_error $? "libedit could not be found which is required for the --enable-readline option." "$LINENO" 5
+
+else
+	EDITLINE_CFLAGS=$pkg_cv_EDITLINE_CFLAGS
+	EDITLINE_LIBS=$pkg_cv_EDITLINE_LIBS
+        { $as_echo "$as_me:${as_lineno-$LINENO}: result: yes" >&5
+$as_echo "yes" >&6; }
+
+
+$as_echo "#define EDITLINE_SUPPORT 1" >>confdefs.h
+
+fi
+fi
+
 ################################################################################
 if test "$READLINE" != no; then
 	lvm_saved_libs=$LIBS
@@ -13246,6 +13345,28 @@ $as_echo_n "checking whether to enable readline... " >&6; }
 { $as_echo "$as_me:${as_lineno-$LINENO}: result: $READLINE" >&5
 $as_echo "$READLINE" >&6; }
 
+if test "$EDITLINE" = yes; then
+	for ac_header in editline/readline.h editline/history.h
+do :
+  as_ac_Header=`$as_echo "ac_cv_header_$ac_header" | $as_tr_sh`
+ac_fn_c_check_header_mongrel "$LINENO" "$ac_header" "$as_ac_Header" "$ac_includes_default"
+if eval test \"x\$"$as_ac_Header"\" = x"yes"; then :
+  cat >>confdefs.h <<_ACEOF
+#define `$as_echo "HAVE_$ac_header" | $as_tr_cpp` 1
+_ACEOF
+
+else
+  hard_bailout
+fi
+
+done
+
+fi
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to enable editline" >&5
+$as_echo_n "checking whether to enable editline... " >&6; }
+{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $EDITLINE" >&5
+$as_echo "$EDITLINE" >&6; }
+
 if test "$BUILD_CMIRRORD" = yes; then
 	for ac_func in atexit
 do :


