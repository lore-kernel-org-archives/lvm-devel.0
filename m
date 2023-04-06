From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu,  6 Apr 2023 11:47:34 +0000 (GMT)
Subject: main - configure: update
Message-ID: <20230406114734.2DD693857700@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a7cf55c6a19a0a70dab7f2b8a406d52e24d5e3cd
Commit:        a7cf55c6a19a0a70dab7f2b8a406d52e24d5e3cd
Parent:        0f2c48a10e6085d483d560277b9d582835582ec4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 1 09:40:53 2023 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Apr 6 11:06:04 2023 +0200

configure: update

autoreconf
---
 aclocal.m4 |  34 ++---
 configure  | 442 +++++++++++++++++++++++++++++--------------------------------
 2 files changed, 226 insertions(+), 250 deletions(-)

diff --git a/aclocal.m4 b/aclocal.m4
index 56c51c7a5..a1ba0f473 100644
--- a/aclocal.m4
+++ b/aclocal.m4
@@ -69,8 +69,8 @@ AC_DEFUN([AX_PYTHON_MODULE],[
     fi
 ])
 
-# pkg.m4 - Macros to locate and utilise pkg-config.   -*- Autoconf -*-
-# serial 11 (pkg-config-0.29.1)
+# pkg.m4 - Macros to locate and use pkg-config.   -*- Autoconf -*-
+# serial 12 (pkg-config-0.29.2)
 
 dnl Copyright ?? 2004 Scott James Remnant <scott@netsplit.com>.
 dnl Copyright ?? 2012-2015 Dan Nicholson <dbn.lists@gmail.com>
@@ -112,7 +112,7 @@ dnl
 dnl See the "Since" comment for each macro you use to see what version
 dnl of the macros you require.
 m4_defun([PKG_PREREQ],
-[m4_define([PKG_MACROS_VERSION], [0.29.1])
+[m4_define([PKG_MACROS_VERSION], [0.29.2])
 m4_if(m4_version_compare(PKG_MACROS_VERSION, [$1]), -1,
     [m4_fatal([pkg.m4 version $1 or higher is required but ]PKG_MACROS_VERSION[ found])])
 ])dnl PKG_PREREQ
@@ -157,7 +157,7 @@ dnl Check to see whether a particular set of modules exists. Similar to
 dnl PKG_CHECK_MODULES(), but does not set variables or print errors.
 dnl
 dnl Please remember that m4 expands AC_REQUIRE([PKG_PROG_PKG_CONFIG])
-dnl only at the first occurence in configure.ac, so if the first place
+dnl only at the first occurrence in configure.ac, so if the first place
 dnl it's called might be skipped (such as if it is within an "if", you
 dnl have to call PKG_CHECK_EXISTS manually
 AC_DEFUN([PKG_CHECK_EXISTS],
@@ -213,7 +213,7 @@ AC_ARG_VAR([$1][_CFLAGS], [C compiler flags for $1, overriding pkg-config])dnl
 AC_ARG_VAR([$1][_LIBS], [linker flags for $1, overriding pkg-config])dnl
 
 pkg_failed=no
-AC_MSG_CHECKING([for $1])
+AC_MSG_CHECKING([for $2])
 
 _PKG_CONFIG([$1][_CFLAGS], [cflags], [$2])
 _PKG_CONFIG([$1][_LIBS], [libs], [$2])
@@ -223,17 +223,17 @@ and $1[]_LIBS to avoid the need to call pkg-config.
 See the pkg-config man page for more details.])
 
 if test $pkg_failed = yes; then
-   	AC_MSG_RESULT([no])
+        AC_MSG_RESULT([no])
         _PKG_SHORT_ERRORS_SUPPORTED
         if test $_pkg_short_errors_supported = yes; then
-	        $1[]_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors --cflags --libs "$2" 2>&1`
-        else 
-	        $1[]_PKG_ERRORS=`$PKG_CONFIG --print-errors --cflags --libs "$2" 2>&1`
+                $1[]_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors --cflags --libs "$2" 2>&1`
+        else
+                $1[]_PKG_ERRORS=`$PKG_CONFIG --print-errors --cflags --libs "$2" 2>&1`
         fi
-	# Put the nasty error message in config.log where it belongs
-	echo "$$1[]_PKG_ERRORS" >&AS_MESSAGE_LOG_FD
+        # Put the nasty error message in config.log where it belongs
+        echo "$$1[]_PKG_ERRORS" >&AS_MESSAGE_LOG_FD
 
-	m4_default([$4], [AC_MSG_ERROR(
+        m4_default([$4], [AC_MSG_ERROR(
 [Package requirements ($2) were not met:
 
 $$1_PKG_ERRORS
@@ -244,8 +244,8 @@ installed software in a non-standard prefix.
 _PKG_TEXT])[]dnl
         ])
 elif test $pkg_failed = untried; then
-     	AC_MSG_RESULT([no])
-	m4_default([$4], [AC_MSG_FAILURE(
+        AC_MSG_RESULT([no])
+        m4_default([$4], [AC_MSG_FAILURE(
 [The pkg-config script could not be found or is too old.  Make sure it
 is in your PATH or set the PKG_CONFIG environment variable to the full
 path to pkg-config.
@@ -255,10 +255,10 @@ _PKG_TEXT
 To get pkg-config, see <http://pkg-config.freedesktop.org/>.])[]dnl
         ])
 else
-	$1[]_CFLAGS=$pkg_cv_[]$1[]_CFLAGS
-	$1[]_LIBS=$pkg_cv_[]$1[]_LIBS
+        $1[]_CFLAGS=$pkg_cv_[]$1[]_CFLAGS
+        $1[]_LIBS=$pkg_cv_[]$1[]_LIBS
         AC_MSG_RESULT([yes])
-	$3
+        $3
 fi[]dnl
 ])dnl PKG_CHECK_MODULES
 
diff --git a/configure b/configure
index 7f50d6fe3..75ceade03 100755
--- a/configure
+++ b/configure
@@ -967,7 +967,6 @@ enable_use_lvmlockd
 with_lvmlockd_pidfile
 enable_use_lvmpolld
 with_lvmpolld_pidfile
-enable_dmfilemapd
 enable_notify_dbus
 enable_systemd_journal
 enable_app_machineid
@@ -990,6 +989,7 @@ enable_fsadm
 enable_lvmimportvdo
 enable_blkdeactivate
 enable_dmeventd
+enable_dmfilemapd
 enable_selinux
 enable_blkzeroout
 enable_nls
@@ -1706,7 +1706,6 @@ Optional Features:
   --enable-lvmlockd-idm   enable the LVM lock daemon using idm
   --disable-use-lvmlockd  disable usage of LVM lock daemon
   --disable-use-lvmpolld  disable usage of LVM Poll Daemon
-  --enable-dmfilemapd     enable the dmstats filemap daemon
   --enable-notify-dbus    enable LVM notification using dbus
   --disable-systemd-journal
                           disable LVM systemd journaling
@@ -1729,6 +1728,7 @@ Optional Features:
   --disable-lvmimportvdo  disable lvm_import_vdo
   --disable-blkdeactivate disable blkdeactivate
   --enable-dmeventd       enable the device-mapper event daemon
+  --enable-dmfilemapd     enable the dmstats filemap daemon
   --disable-selinux       disable selinux support
   --disable-blkzeroout    do not use BLKZEROOUT for device zeroing
   --enable-nls            enable Native Language Support
@@ -11206,8 +11206,8 @@ then :
 
 
 pkg_failed=no
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for CPG" >&5
-printf %s "checking for CPG... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for libcpg" >&5
+printf %s "checking for libcpg... " >&6; }
 
 if test -n "$CPG_CFLAGS"; then
     pkg_cv_CPG_CFLAGS="$CPG_CFLAGS"
@@ -11247,7 +11247,7 @@ fi
 
 
 if test $pkg_failed = yes; then
-   	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+        { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
 printf "%s\n" "no" >&6; }
 
 if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
@@ -11256,14 +11256,14 @@ else
         _pkg_short_errors_supported=no
 fi
         if test $_pkg_short_errors_supported = yes; then
-	        CPG_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors --cflags --libs "libcpg" 2>&1`
+                CPG_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors --cflags --libs "libcpg" 2>&1`
         else
-	        CPG_PKG_ERRORS=`$PKG_CONFIG --print-errors --cflags --libs "libcpg" 2>&1`
+                CPG_PKG_ERRORS=`$PKG_CONFIG --print-errors --cflags --libs "libcpg" 2>&1`
         fi
-	# Put the nasty error message in config.log where it belongs
-	echo "$CPG_PKG_ERRORS" >&5
+        # Put the nasty error message in config.log where it belongs
+        echo "$CPG_PKG_ERRORS" >&5
 
-	as_fn_error $? "Package requirements (libcpg) were not met:
+        as_fn_error $? "Package requirements (libcpg) were not met:
 
 $CPG_PKG_ERRORS
 
@@ -11274,9 +11274,9 @@ Alternatively, you may set the environment variables CPG_CFLAGS
 and CPG_LIBS to avoid the need to call pkg-config.
 See the pkg-config man page for more details." "$LINENO" 5
 elif test $pkg_failed = untried; then
-     	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+        { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
 printf "%s\n" "no" >&6; }
-	{ { printf "%s\n" "$as_me:${as_lineno-$LINENO}: error: in \`$ac_pwd':" >&5
+        { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: error: in \`$ac_pwd':" >&5
 printf "%s\n" "$as_me: error: in \`$ac_pwd':" >&2;}
 as_fn_error $? "The pkg-config script could not be found or is too old.  Make sure it
 is in your PATH or set the PKG_CONFIG environment variable to the full
@@ -11289,8 +11289,8 @@ See the pkg-config man page for more details.
 To get pkg-config, see <http://pkg-config.freedesktop.org/>.
 See \`config.log' for more details" "$LINENO" 5; }
 else
-	CPG_CFLAGS=$pkg_cv_CPG_CFLAGS
-	CPG_LIBS=$pkg_cv_CPG_LIBS
+        CPG_CFLAGS=$pkg_cv_CPG_CFLAGS
+        CPG_LIBS=$pkg_cv_CPG_LIBS
         { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: yes" >&5
 printf "%s\n" "yes" >&6; }
 
@@ -11888,8 +11888,8 @@ printf "%s\n" "$VALGRIND_POOL" >&6; }
 
 
 pkg_failed=no
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for VALGRIND" >&5
-printf %s "checking for VALGRIND... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for valgrind" >&5
+printf %s "checking for valgrind... " >&6; }
 
 if test -n "$VALGRIND_CFLAGS"; then
     pkg_cv_VALGRIND_CFLAGS="$VALGRIND_CFLAGS"
@@ -11929,7 +11929,7 @@ fi
 
 
 if test $pkg_failed = yes; then
-   	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+        { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
 printf "%s\n" "no" >&6; }
 
 if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
@@ -11938,12 +11938,12 @@ else
         _pkg_short_errors_supported=no
 fi
         if test $_pkg_short_errors_supported = yes; then
-	        VALGRIND_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors --cflags --libs "valgrind" 2>&1`
+                VALGRIND_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors --cflags --libs "valgrind" 2>&1`
         else
-	        VALGRIND_PKG_ERRORS=`$PKG_CONFIG --print-errors --cflags --libs "valgrind" 2>&1`
+                VALGRIND_PKG_ERRORS=`$PKG_CONFIG --print-errors --cflags --libs "valgrind" 2>&1`
         fi
-	# Put the nasty error message in config.log where it belongs
-	echo "$VALGRIND_PKG_ERRORS" >&5
+        # Put the nasty error message in config.log where it belongs
+        echo "$VALGRIND_PKG_ERRORS" >&5
 
 
   if test "$VALGRIND_POOL" = "yes"
@@ -11952,7 +11952,7 @@ then :
 fi
 
 elif test $pkg_failed = untried; then
-     	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+        { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
 printf "%s\n" "no" >&6; }
 
   if test "$VALGRIND_POOL" = "yes"
@@ -11961,11 +11961,11 @@ then :
 fi
 
 else
-	VALGRIND_CFLAGS=$pkg_cv_VALGRIND_CFLAGS
-	VALGRIND_LIBS=$pkg_cv_VALGRIND_LIBS
+        VALGRIND_CFLAGS=$pkg_cv_VALGRIND_CFLAGS
+        VALGRIND_LIBS=$pkg_cv_VALGRIND_LIBS
         { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: yes" >&5
 printf "%s\n" "yes" >&6; }
-	HAVE_VALGRIND="yes"
+        HAVE_VALGRIND="yes"
 fi
 
 
@@ -12043,8 +12043,8 @@ then :
 
 
 pkg_failed=no
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for LIBSANLOCKCLIENT" >&5
-printf %s "checking for LIBSANLOCKCLIENT... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for libsanlock_client >= 3.3.0" >&5
+printf %s "checking for libsanlock_client >= 3.3.0... " >&6; }
 
 if test -n "$LIBSANLOCKCLIENT_CFLAGS"; then
     pkg_cv_LIBSANLOCKCLIENT_CFLAGS="$LIBSANLOCKCLIENT_CFLAGS"
@@ -12084,7 +12084,7 @@ fi
 
 
 if test $pkg_failed = yes; then
-   	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+        { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
 printf "%s\n" "no" >&6; }
 
 if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
@@ -12093,14 +12093,14 @@ else
         _pkg_short_errors_supported=no
 fi
         if test $_pkg_short_errors_supported = yes; then
-	        LIBSANLOCKCLIENT_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors --cflags --libs "libsanlock_client >= 3.3.0" 2>&1`
+                LIBSANLOCKCLIENT_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors --cflags --libs "libsanlock_client >= 3.3.0" 2>&1`
         else
-	        LIBSANLOCKCLIENT_PKG_ERRORS=`$PKG_CONFIG --print-errors --cflags --libs "libsanlock_client >= 3.3.0" 2>&1`
+                LIBSANLOCKCLIENT_PKG_ERRORS=`$PKG_CONFIG --print-errors --cflags --libs "libsanlock_client >= 3.3.0" 2>&1`
         fi
-	# Put the nasty error message in config.log where it belongs
-	echo "$LIBSANLOCKCLIENT_PKG_ERRORS" >&5
+        # Put the nasty error message in config.log where it belongs
+        echo "$LIBSANLOCKCLIENT_PKG_ERRORS" >&5
 
-	as_fn_error $? "Package requirements (libsanlock_client >= 3.3.0) were not met:
+        as_fn_error $? "Package requirements (libsanlock_client >= 3.3.0) were not met:
 
 $LIBSANLOCKCLIENT_PKG_ERRORS
 
@@ -12111,9 +12111,9 @@ Alternatively, you may set the environment variables LIBSANLOCKCLIENT_CFLAGS
 and LIBSANLOCKCLIENT_LIBS to avoid the need to call pkg-config.
 See the pkg-config man page for more details." "$LINENO" 5
 elif test $pkg_failed = untried; then
-     	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+        { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
 printf "%s\n" "no" >&6; }
-	{ { printf "%s\n" "$as_me:${as_lineno-$LINENO}: error: in \`$ac_pwd':" >&5
+        { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: error: in \`$ac_pwd':" >&5
 printf "%s\n" "$as_me: error: in \`$ac_pwd':" >&2;}
 as_fn_error $? "The pkg-config script could not be found or is too old.  Make sure it
 is in your PATH or set the PKG_CONFIG environment variable to the full
@@ -12126,11 +12126,11 @@ See the pkg-config man page for more details.
 To get pkg-config, see <http://pkg-config.freedesktop.org/>.
 See \`config.log' for more details" "$LINENO" 5; }
 else
-	LIBSANLOCKCLIENT_CFLAGS=$pkg_cv_LIBSANLOCKCLIENT_CFLAGS
-	LIBSANLOCKCLIENT_LIBS=$pkg_cv_LIBSANLOCKCLIENT_LIBS
+        LIBSANLOCKCLIENT_CFLAGS=$pkg_cv_LIBSANLOCKCLIENT_CFLAGS
+        LIBSANLOCKCLIENT_LIBS=$pkg_cv_LIBSANLOCKCLIENT_LIBS
         { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: yes" >&5
 printf "%s\n" "yes" >&6; }
-	BUILD_LVMLOCKD="yes"
+        BUILD_LVMLOCKD="yes"
 fi
 
 printf "%s\n" "#define LOCKDSANLOCK_SUPPORT 1" >>confdefs.h
@@ -12157,8 +12157,8 @@ then :
 
 
 pkg_failed=no
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for LIBDLM" >&5
-printf %s "checking for LIBDLM... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for libdlm_lt" >&5
+printf %s "checking for libdlm_lt... " >&6; }
 
 if test -n "$LIBDLM_CFLAGS"; then
     pkg_cv_LIBDLM_CFLAGS="$LIBDLM_CFLAGS"
@@ -12198,7 +12198,7 @@ fi
 
 
 if test $pkg_failed = yes; then
-   	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+        { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
 printf "%s\n" "no" >&6; }
 
 if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
@@ -12207,14 +12207,14 @@ else
         _pkg_short_errors_supported=no
 fi
         if test $_pkg_short_errors_supported = yes; then
-	        LIBDLM_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors --cflags --libs "libdlm_lt" 2>&1`
+                LIBDLM_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors --cflags --libs "libdlm_lt" 2>&1`
         else
-	        LIBDLM_PKG_ERRORS=`$PKG_CONFIG --print-errors --cflags --libs "libdlm_lt" 2>&1`
+                LIBDLM_PKG_ERRORS=`$PKG_CONFIG --print-errors --cflags --libs "libdlm_lt" 2>&1`
         fi
-	# Put the nasty error message in config.log where it belongs
-	echo "$LIBDLM_PKG_ERRORS" >&5
+        # Put the nasty error message in config.log where it belongs
+        echo "$LIBDLM_PKG_ERRORS" >&5
 
-	as_fn_error $? "Package requirements (libdlm_lt) were not met:
+        as_fn_error $? "Package requirements (libdlm_lt) were not met:
 
 $LIBDLM_PKG_ERRORS
 
@@ -12225,9 +12225,9 @@ Alternatively, you may set the environment variables LIBDLM_CFLAGS
 and LIBDLM_LIBS to avoid the need to call pkg-config.
 See the pkg-config man page for more details." "$LINENO" 5
 elif test $pkg_failed = untried; then
-     	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+        { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
 printf "%s\n" "no" >&6; }
-	{ { printf "%s\n" "$as_me:${as_lineno-$LINENO}: error: in \`$ac_pwd':" >&5
+        { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: error: in \`$ac_pwd':" >&5
 printf "%s\n" "$as_me: error: in \`$ac_pwd':" >&2;}
 as_fn_error $? "The pkg-config script could not be found or is too old.  Make sure it
 is in your PATH or set the PKG_CONFIG environment variable to the full
@@ -12240,11 +12240,11 @@ See the pkg-config man page for more details.
 To get pkg-config, see <http://pkg-config.freedesktop.org/>.
 See \`config.log' for more details" "$LINENO" 5; }
 else
-	LIBDLM_CFLAGS=$pkg_cv_LIBDLM_CFLAGS
-	LIBDLM_LIBS=$pkg_cv_LIBDLM_LIBS
+        LIBDLM_CFLAGS=$pkg_cv_LIBDLM_CFLAGS
+        LIBDLM_LIBS=$pkg_cv_LIBDLM_LIBS
         { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: yes" >&5
 printf "%s\n" "yes" >&6; }
-	BUILD_LVMLOCKD="yes"
+        BUILD_LVMLOCKD="yes"
 fi
 
 printf "%s\n" "#define LOCKDDLM_SUPPORT 1" >>confdefs.h
@@ -12280,8 +12280,8 @@ then :
 
 
 pkg_failed=no
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for LIBDLMCONTROL" >&5
-printf %s "checking for LIBDLMCONTROL... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for libdlmcontrol >= 3.2" >&5
+printf %s "checking for libdlmcontrol >= 3.2... " >&6; }
 
 if test -n "$LIBDLMCONTROL_CFLAGS"; then
     pkg_cv_LIBDLMCONTROL_CFLAGS="$LIBDLMCONTROL_CFLAGS"
@@ -12321,7 +12321,7 @@ fi
 
 
 if test $pkg_failed = yes; then
-   	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+        { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
 printf "%s\n" "no" >&6; }
 
 if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
@@ -12330,14 +12330,14 @@ else
         _pkg_short_errors_supported=no
 fi
         if test $_pkg_short_errors_supported = yes; then
-	        LIBDLMCONTROL_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors --cflags --libs "libdlmcontrol >= 3.2" 2>&1`
+                LIBDLMCONTROL_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors --cflags --libs "libdlmcontrol >= 3.2" 2>&1`
         else
-	        LIBDLMCONTROL_PKG_ERRORS=`$PKG_CONFIG --print-errors --cflags --libs "libdlmcontrol >= 3.2" 2>&1`
+                LIBDLMCONTROL_PKG_ERRORS=`$PKG_CONFIG --print-errors --cflags --libs "libdlmcontrol >= 3.2" 2>&1`
         fi
-	# Put the nasty error message in config.log where it belongs
-	echo "$LIBDLMCONTROL_PKG_ERRORS" >&5
+        # Put the nasty error message in config.log where it belongs
+        echo "$LIBDLMCONTROL_PKG_ERRORS" >&5
 
-	as_fn_error $? "Package requirements (libdlmcontrol >= 3.2) were not met:
+        as_fn_error $? "Package requirements (libdlmcontrol >= 3.2) were not met:
 
 $LIBDLMCONTROL_PKG_ERRORS
 
@@ -12348,9 +12348,9 @@ Alternatively, you may set the environment variables LIBDLMCONTROL_CFLAGS
 and LIBDLMCONTROL_LIBS to avoid the need to call pkg-config.
 See the pkg-config man page for more details." "$LINENO" 5
 elif test $pkg_failed = untried; then
-     	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+        { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
 printf "%s\n" "no" >&6; }
-	{ { printf "%s\n" "$as_me:${as_lineno-$LINENO}: error: in \`$ac_pwd':" >&5
+        { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: error: in \`$ac_pwd':" >&5
 printf "%s\n" "$as_me: error: in \`$ac_pwd':" >&2;}
 as_fn_error $? "The pkg-config script could not be found or is too old.  Make sure it
 is in your PATH or set the PKG_CONFIG environment variable to the full
@@ -12363,11 +12363,11 @@ See the pkg-config man page for more details.
 To get pkg-config, see <http://pkg-config.freedesktop.org/>.
 See \`config.log' for more details" "$LINENO" 5; }
 else
-	LIBDLMCONTROL_CFLAGS=$pkg_cv_LIBDLMCONTROL_CFLAGS
-	LIBDLMCONTROL_LIBS=$pkg_cv_LIBDLMCONTROL_LIBS
+        LIBDLMCONTROL_CFLAGS=$pkg_cv_LIBDLMCONTROL_CFLAGS
+        LIBDLMCONTROL_LIBS=$pkg_cv_LIBDLMCONTROL_LIBS
         { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: yes" >&5
 printf "%s\n" "yes" >&6; }
-	BUILD_LVMLOCKD="yes"
+        BUILD_LVMLOCKD="yes"
 fi
 
 printf "%s\n" "#define LOCKDDLM_CONTROL_SUPPORT 1" >>confdefs.h
@@ -12401,8 +12401,8 @@ then :
 
 
 pkg_failed=no
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for LIBSEAGATEILM" >&5
-printf %s "checking for LIBSEAGATEILM... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for libseagate_ilm >= 0.1.0" >&5
+printf %s "checking for libseagate_ilm >= 0.1.0... " >&6; }
 
 if test -n "$LIBSEAGATEILM_CFLAGS"; then
     pkg_cv_LIBSEAGATEILM_CFLAGS="$LIBSEAGATEILM_CFLAGS"
@@ -12442,7 +12442,7 @@ fi
 
 
 if test $pkg_failed = yes; then
-   	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+        { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
 printf "%s\n" "no" >&6; }
 
 if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
@@ -12451,14 +12451,14 @@ else
         _pkg_short_errors_supported=no
 fi
         if test $_pkg_short_errors_supported = yes; then
-	        LIBSEAGATEILM_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors --cflags --libs "libseagate_ilm >= 0.1.0" 2>&1`
+                LIBSEAGATEILM_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors --cflags --libs "libseagate_ilm >= 0.1.0" 2>&1`
         else
-	        LIBSEAGATEILM_PKG_ERRORS=`$PKG_CONFIG --print-errors --cflags --libs "libseagate_ilm >= 0.1.0" 2>&1`
+                LIBSEAGATEILM_PKG_ERRORS=`$PKG_CONFIG --print-errors --cflags --libs "libseagate_ilm >= 0.1.0" 2>&1`
         fi
-	# Put the nasty error message in config.log where it belongs
-	echo "$LIBSEAGATEILM_PKG_ERRORS" >&5
+        # Put the nasty error message in config.log where it belongs
+        echo "$LIBSEAGATEILM_PKG_ERRORS" >&5
 
-	as_fn_error $? "Package requirements (libseagate_ilm >= 0.1.0) were not met:
+        as_fn_error $? "Package requirements (libseagate_ilm >= 0.1.0) were not met:
 
 $LIBSEAGATEILM_PKG_ERRORS
 
@@ -12469,9 +12469,9 @@ Alternatively, you may set the environment variables LIBSEAGATEILM_CFLAGS
 and LIBSEAGATEILM_LIBS to avoid the need to call pkg-config.
 See the pkg-config man page for more details." "$LINENO" 5
 elif test $pkg_failed = untried; then
-     	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+        { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
 printf "%s\n" "no" >&6; }
-	{ { printf "%s\n" "$as_me:${as_lineno-$LINENO}: error: in \`$ac_pwd':" >&5
+        { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: error: in \`$ac_pwd':" >&5
 printf "%s\n" "$as_me: error: in \`$ac_pwd':" >&2;}
 as_fn_error $? "The pkg-config script could not be found or is too old.  Make sure it
 is in your PATH or set the PKG_CONFIG environment variable to the full
@@ -12484,11 +12484,11 @@ See the pkg-config man page for more details.
 To get pkg-config, see <http://pkg-config.freedesktop.org/>.
 See \`config.log' for more details" "$LINENO" 5; }
 else
-	LIBSEAGATEILM_CFLAGS=$pkg_cv_LIBSEAGATEILM_CFLAGS
-	LIBSEAGATEILM_LIBS=$pkg_cv_LIBSEAGATEILM_LIBS
+        LIBSEAGATEILM_CFLAGS=$pkg_cv_LIBSEAGATEILM_CFLAGS
+        LIBSEAGATEILM_LIBS=$pkg_cv_LIBSEAGATEILM_LIBS
         { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: yes" >&5
 printf "%s\n" "yes" >&6; }
-	BUILD_LVMLOCKD="yes"
+        BUILD_LVMLOCKD="yes"
 fi
 
 printf "%s\n" "#define LOCKDIDM_SUPPORT 1" >>confdefs.h
@@ -12510,6 +12510,7 @@ printf %s "checking whether to build lvmlockd... " >&6; }
 { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $BUILD_LVMLOCKD" >&5
 printf "%s\n" "$BUILD_LVMLOCKD" >&6; }
 
+DEFAULT_USE_LVMLOCKD=0
 if test "$BUILD_LVMLOCKD" = "yes"
 then :
 
@@ -12527,16 +12528,15 @@ printf %s "checking defaults for use_lvmlockd... " >&6; }
 	# Check whether --enable-use_lvmlockd was given.
 if test ${enable_use_lvmlockd+y}
 then :
-  enableval=$enable_use_lvmlockd; if test "$enableval" = "yes"
-then :
-  DEFAULT_USE_LVMLOCKD=1
+  enableval=$enable_use_lvmlockd; use_lvmlockd=$enableval
 else $as_nop
-  DEFAULT_USE_LVMLOCKD=0
+  use_lvmlockd="yes"
 fi
-else $as_nop
+
+	if test "$use_lvmlockd" = "yes"
+then :
   DEFAULT_USE_LVMLOCKD=1
 fi
-
 	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $DEFAULT_USE_LVMLOCKD" >&5
 printf "%s\n" "$DEFAULT_USE_LVMLOCKD" >&6; }
 
@@ -12556,16 +12556,13 @@ fi
 printf "%s\n" "#define LVMLOCKD_PIDFILE \"$LVMLOCKD_PIDFILE\"" >>confdefs.h
 
 
-else $as_nop
-
-	DEFAULT_USE_LVMLOCKD=0
-
 fi
 
 printf "%s\n" "#define DEFAULT_USE_LVMLOCKD $DEFAULT_USE_LVMLOCKD" >>confdefs.h
 
 
 ################################################################################
+DEFAULT_USE_LVMPOLLD=0
 if test "$BUILD_LVMPOLLD" = "yes"
 then :
 
@@ -12574,16 +12571,15 @@ printf %s "checking defaults for use_lvmpolld... " >&6; }
 	# Check whether --enable-use_lvmpolld was given.
 if test ${enable_use_lvmpolld+y}
 then :
-  enableval=$enable_use_lvmpolld; if test "$enableval" = "yes"
-then :
-  DEFAULT_USE_LVMPOLLD=1
+  enableval=$enable_use_lvmpolld; use_lvmpolld=$enableval
 else $as_nop
-  DEFAULT_USE_LVMPOLLD=0
+  use_lvmpolld="yes"
 fi
-else $as_nop
+
+	if test "$use_lvmpolld" = "yes"
+then :
   DEFAULT_USE_LVMPOLLD=1
 fi
-
 	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $DEFAULT_USE_LVMPOLLD" >&5
 printf "%s\n" "$DEFAULT_USE_LVMPOLLD" >&6; }
 
@@ -12603,79 +12599,45 @@ fi
 printf "%s\n" "#define LVMPOLLD_PIDFILE \"$LVMPOLLD_PIDFILE\"" >>confdefs.h
 
 
-else $as_nop
-
-	DEFAULT_USE_LVMPOLLD=0
-
 fi
 
 printf "%s\n" "#define DEFAULT_USE_LVMPOLLD $DEFAULT_USE_LVMPOLLD" >>confdefs.h
 
 
-################################################################################
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether to build dmfilemapd" >&5
-printf %s "checking whether to build dmfilemapd... " >&6; }
-# Check whether --enable-dmfilemapd was given.
-if test ${enable_dmfilemapd+y}
-then :
-  enableval=$enable_dmfilemapd; BUILD_DMFILEMAPD=$enableval
-else $as_nop
-  BUILD_DMFILEMAPD="no"
-fi
-
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $BUILD_DMFILEMAPD" >&5
-printf "%s\n" "$BUILD_DMFILEMAPD" >&6; }
-
-printf "%s\n" "#define DMFILEMAPD \$BUILD_DMFILEMAPD" >>confdefs.h
-
-
-if test "$BUILD_DMFILEMAPD" = "yes"
-then :
-
-   ac_fn_c_check_header_compile "$LINENO" "linux/fiemap.h" "ac_cv_header_linux_fiemap_h" "$ac_includes_default"
-if test "x$ac_cv_header_linux_fiemap_h" = xyes
-then :
-
-else $as_nop
-  as_fn_error $? "--enable-dmfilemapd requires fiemap.h" "$LINENO" 5
-fi
-
-
-fi
 
 SYSTEMD_MIN_VERSION=0
 if test -n "$PKG_CONFIG" && \
-    { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"systemd >= 205\""; } >&5
-  ($PKG_CONFIG --exists --print-errors "systemd >= 205") 2>&5
+    { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"systemd >= 221\""; } >&5
+  ($PKG_CONFIG --exists --print-errors "systemd >= 221") 2>&5
   ac_status=$?
   printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; then
-  SYSTEMD_MIN_VERSION=205
+  SYSTEMD_MIN_VERSION=221
 fi
-
-################################################################################
 if test -n "$PKG_CONFIG" && \
-    { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"systemd >= 221\""; } >&5
-  ($PKG_CONFIG --exists --print-errors "systemd >= 221") 2>&5
+    { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"systemd >= 234\""; } >&5
+  ($PKG_CONFIG --exists --print-errors "systemd >= 234") 2>&5
   ac_status=$?
   printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; then
-  SYSTEMD_MIN_VERSION=221
+  SYSTEMD_MIN_VERSION=234
 fi
+
+################################################################################
 { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether to build notifydbus" >&5
 printf %s "checking whether to build notifydbus... " >&6; }
 # Check whether --enable-notify-dbus was given.
 if test ${enable_notify_dbus+y}
 then :
-  enableval=$enable_notify_dbus; if test "$enableval" = "yes" && test "$SYSTEMD_MIN_VERSION" -lt 221
-then :
-  as_fn_error $? "Enabling notify-dbus requires systemd >= 221" "$LINENO" 5
-fi
-	      NOTIFYDBUS_SUPPORT=$enableval
+  enableval=$enable_notify_dbus; NOTIFYDBUS_SUPPORT=$enableval
 else $as_nop
   NOTIFYDBUS_SUPPORT="no"
 fi
 
+if test "$NOTIFYDBUS_SUPPORT" = "yes" && test "$SYSTEMD_MIN_VERSION" -lt 221
+then :
+  as_fn_error $? "Enabling notify-dbus requires systemd >= 221" "$LINENO" 5
+fi
 { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $NOTIFYDBUS_SUPPORT" >&5
 printf "%s\n" "$NOTIFYDBUS_SUPPORT" >&6; }
 
@@ -12727,14 +12689,10 @@ printf "%s\n" "#define SYSTEMD_JOURNAL_SUPPORT 1" >>confdefs.h
 fi
 
 ################################################################################
-if test -n "$PKG_CONFIG" && \
-    { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"systemd >= 234\""; } >&5
-  ($PKG_CONFIG --exists --print-errors "systemd >= 234") 2>&5
-  ac_status=$?
-  printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
-  test $ac_status = 0; }; then
-  SYSTEMD_MIN_VERSION=234  APP_MACHINEID_SUPPORT="maybe"
-else
+if test "$SYSTEMD_MIN_VERSION" -ge 234
+then :
+  APP_MACHINEID_SUPPORT="maybe"
+else $as_nop
   APP_MACHINEID_SUPPORT="no"
 fi
 ac_fn_c_check_header_compile "$LINENO" "systemd/sd-id128.h" "ac_cv_header_systemd_sd_id128_h" "$ac_includes_default"
@@ -12775,8 +12733,8 @@ then :
 
 
 pkg_failed=no
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for LIBSYSTEMD" >&5
-printf %s "checking for LIBSYSTEMD... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for libsystemd" >&5
+printf %s "checking for libsystemd... " >&6; }
 
 if test -n "$LIBSYSTEMD_CFLAGS"; then
     pkg_cv_LIBSYSTEMD_CFLAGS="$LIBSYSTEMD_CFLAGS"
@@ -12816,7 +12774,7 @@ fi
 
 
 if test $pkg_failed = yes; then
-   	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+        { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
 printf "%s\n" "no" >&6; }
 
 if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
@@ -12825,14 +12783,14 @@ else
         _pkg_short_errors_supported=no
 fi
         if test $_pkg_short_errors_supported = yes; then
-	        LIBSYSTEMD_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors --cflags --libs "libsystemd" 2>&1`
+                LIBSYSTEMD_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors --cflags --libs "libsystemd" 2>&1`
         else
-	        LIBSYSTEMD_PKG_ERRORS=`$PKG_CONFIG --print-errors --cflags --libs "libsystemd" 2>&1`
+                LIBSYSTEMD_PKG_ERRORS=`$PKG_CONFIG --print-errors --cflags --libs "libsystemd" 2>&1`
         fi
-	# Put the nasty error message in config.log where it belongs
-	echo "$LIBSYSTEMD_PKG_ERRORS" >&5
+        # Put the nasty error message in config.log where it belongs
+        echo "$LIBSYSTEMD_PKG_ERRORS" >&5
 
-	as_fn_error $? "Package requirements (libsystemd) were not met:
+        as_fn_error $? "Package requirements (libsystemd) were not met:
 
 $LIBSYSTEMD_PKG_ERRORS
 
@@ -12843,9 +12801,9 @@ Alternatively, you may set the environment variables LIBSYSTEMD_CFLAGS
 and LIBSYSTEMD_LIBS to avoid the need to call pkg-config.
 See the pkg-config man page for more details." "$LINENO" 5
 elif test $pkg_failed = untried; then
-     	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+        { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
 printf "%s\n" "no" >&6; }
-	{ { printf "%s\n" "$as_me:${as_lineno-$LINENO}: error: in \`$ac_pwd':" >&5
+        { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: error: in \`$ac_pwd':" >&5
 printf "%s\n" "$as_me: error: in \`$ac_pwd':" >&2;}
 as_fn_error $? "The pkg-config script could not be found or is too old.  Make sure it
 is in your PATH or set the PKG_CONFIG environment variable to the full
@@ -12858,8 +12816,8 @@ See the pkg-config man page for more details.
 To get pkg-config, see <http://pkg-config.freedesktop.org/>.
 See \`config.log' for more details" "$LINENO" 5; }
 else
-	LIBSYSTEMD_CFLAGS=$pkg_cv_LIBSYSTEMD_CFLAGS
-	LIBSYSTEMD_LIBS=$pkg_cv_LIBSYSTEMD_LIBS
+        LIBSYSTEMD_CFLAGS=$pkg_cv_LIBSYSTEMD_CFLAGS
+        LIBSYSTEMD_LIBS=$pkg_cv_LIBSYSTEMD_LIBS
         { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: yes" >&5
 printf "%s\n" "yes" >&6; }
 
@@ -12877,7 +12835,6 @@ else $as_nop
   SYSTEMD_RUN_CMD="autodetect"
 fi
 
-
 if test "$SYSTEMD_RUN_CMD" = "autodetect"
 then :
   if test -n "$ac_tool_prefix"; then
@@ -12988,16 +12945,15 @@ else
   SYSTEMD_RUN_CMD="$ac_cv_path_SYSTEMD_RUN_CMD"
 fi
 
-       if test -z "$SYSTEMD_RUN_CMD"
+fi
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for app running udev background service" >&5
+printf %s "checking for app running udev background service... " >&6; }
+if test -z "$SYSTEMD_RUN_CMD"
 then :
   SYSTEMD_RUN_CMD="/usr/bin/systemd-run"
 fi
-else $as_nop
-  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for defined systemd-run" >&5
-printf %s "checking for defined systemd-run... " >&6; }
-       { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $SYSTEMD_RUN_CMD" >&5
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $SYSTEMD_RUN_CMD" >&5
 printf "%s\n" "$SYSTEMD_RUN_CMD" >&6; }
-fi
 
 ################################################################################
 
@@ -13030,8 +12986,8 @@ then :
 
 
 pkg_failed=no
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for BLKID" >&5
-printf %s "checking for BLKID... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for blkid >= 2.24" >&5
+printf %s "checking for blkid >= 2.24... " >&6; }
 
 if test -n "$BLKID_CFLAGS"; then
     pkg_cv_BLKID_CFLAGS="$BLKID_CFLAGS"
@@ -13071,7 +13027,7 @@ fi
 
 
 if test $pkg_failed = yes; then
-   	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+        { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
 printf "%s\n" "no" >&6; }
 
 if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
@@ -13080,14 +13036,14 @@ else
         _pkg_short_errors_supported=no
 fi
         if test $_pkg_short_errors_supported = yes; then
-	        BLKID_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors --cflags --libs "blkid >= 2.24" 2>&1`
+                BLKID_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors --cflags --libs "blkid >= 2.24" 2>&1`
         else
-	        BLKID_PKG_ERRORS=`$PKG_CONFIG --print-errors --cflags --libs "blkid >= 2.24" 2>&1`
+                BLKID_PKG_ERRORS=`$PKG_CONFIG --print-errors --cflags --libs "blkid >= 2.24" 2>&1`
         fi
-	# Put the nasty error message in config.log where it belongs
-	echo "$BLKID_PKG_ERRORS" >&5
+        # Put the nasty error message in config.log where it belongs
+        echo "$BLKID_PKG_ERRORS" >&5
 
-	as_fn_error $? "Package requirements (blkid >= 2.24) were not met:
+        as_fn_error $? "Package requirements (blkid >= 2.24) were not met:
 
 $BLKID_PKG_ERRORS
 
@@ -13098,9 +13054,9 @@ Alternatively, you may set the environment variables BLKID_CFLAGS
 and BLKID_LIBS to avoid the need to call pkg-config.
 See the pkg-config man page for more details." "$LINENO" 5
 elif test $pkg_failed = untried; then
-     	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+        { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
 printf "%s\n" "no" >&6; }
-	{ { printf "%s\n" "$as_me:${as_lineno-$LINENO}: error: in \`$ac_pwd':" >&5
+        { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: error: in \`$ac_pwd':" >&5
 printf "%s\n" "$as_me: error: in \`$ac_pwd':" >&2;}
 as_fn_error $? "The pkg-config script could not be found or is too old.  Make sure it
 is in your PATH or set the PKG_CONFIG environment variable to the full
@@ -13113,8 +13069,8 @@ See the pkg-config man page for more details.
 To get pkg-config, see <http://pkg-config.freedesktop.org/>.
 See \`config.log' for more details" "$LINENO" 5; }
 else
-	BLKID_CFLAGS=$pkg_cv_BLKID_CFLAGS
-	BLKID_LIBS=$pkg_cv_BLKID_LIBS
+        BLKID_CFLAGS=$pkg_cv_BLKID_CFLAGS
+        BLKID_LIBS=$pkg_cv_BLKID_LIBS
         { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: yes" >&5
 printf "%s\n" "yes" >&6; }
 
@@ -13218,8 +13174,8 @@ then :
 
 
 pkg_failed=no
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for UDEV" >&5
-printf %s "checking for UDEV... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for libudev >= 143" >&5
+printf %s "checking for libudev >= 143... " >&6; }
 
 if test -n "$UDEV_CFLAGS"; then
     pkg_cv_UDEV_CFLAGS="$UDEV_CFLAGS"
@@ -13259,7 +13215,7 @@ fi
 
 
 if test $pkg_failed = yes; then
-   	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+        { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
 printf "%s\n" "no" >&6; }
 
 if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
@@ -13268,14 +13224,14 @@ else
         _pkg_short_errors_supported=no
 fi
         if test $_pkg_short_errors_supported = yes; then
-	        UDEV_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors --cflags --libs "libudev >= 143" 2>&1`
+                UDEV_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors --cflags --libs "libudev >= 143" 2>&1`
         else
-	        UDEV_PKG_ERRORS=`$PKG_CONFIG --print-errors --cflags --libs "libudev >= 143" 2>&1`
+                UDEV_PKG_ERRORS=`$PKG_CONFIG --print-errors --cflags --libs "libudev >= 143" 2>&1`
         fi
-	# Put the nasty error message in config.log where it belongs
-	echo "$UDEV_PKG_ERRORS" >&5
+        # Put the nasty error message in config.log where it belongs
+        echo "$UDEV_PKG_ERRORS" >&5
 
-	as_fn_error $? "Package requirements (libudev >= 143) were not met:
+        as_fn_error $? "Package requirements (libudev >= 143) were not met:
 
 $UDEV_PKG_ERRORS
 
@@ -13286,9 +13242,9 @@ Alternatively, you may set the environment variables UDEV_CFLAGS
 and UDEV_LIBS to avoid the need to call pkg-config.
 See the pkg-config man page for more details." "$LINENO" 5
 elif test $pkg_failed = untried; then
-     	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+        { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
 printf "%s\n" "no" >&6; }
-	{ { printf "%s\n" "$as_me:${as_lineno-$LINENO}: error: in \`$ac_pwd':" >&5
+        { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: error: in \`$ac_pwd':" >&5
 printf "%s\n" "$as_me: error: in \`$ac_pwd':" >&2;}
 as_fn_error $? "The pkg-config script could not be found or is too old.  Make sure it
 is in your PATH or set the PKG_CONFIG environment variable to the full
@@ -13301,11 +13257,11 @@ See the pkg-config man page for more details.
 To get pkg-config, see <http://pkg-config.freedesktop.org/>.
 See \`config.log' for more details" "$LINENO" 5; }
 else
-	UDEV_CFLAGS=$pkg_cv_UDEV_CFLAGS
-	UDEV_LIBS=$pkg_cv_UDEV_LIBS
+        UDEV_CFLAGS=$pkg_cv_UDEV_CFLAGS
+        UDEV_LIBS=$pkg_cv_UDEV_LIBS
         { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: yes" >&5
 printf "%s\n" "yes" >&6; }
-	UDEV_PC="libudev"
+        UDEV_PC="libudev"
 fi
 	UDEV_STATIC_LIBS=$("$PKG_CONFIG" --static --libs libudev)
 
@@ -14191,6 +14147,34 @@ fi
 printf "%s\n" "#define DMEVENTD 1" >>confdefs.h
 
 
+fi
+
+################################################################################
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether to build dmfilemapd" >&5
+printf %s "checking whether to build dmfilemapd... " >&6; }
+# Check whether --enable-dmfilemapd was given.
+if test ${enable_dmfilemapd+y}
+then :
+  enableval=$enable_dmfilemapd; BUILD_DMFILEMAPD=$enableval
+else $as_nop
+  BUILD_DMFILEMAPD="no"
+fi
+
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $BUILD_DMFILEMAPD" >&5
+printf "%s\n" "$BUILD_DMFILEMAPD" >&6; }
+
+if test "$BUILD_DMFILEMAPD" = "yes"
+then :
+  ac_fn_c_check_header_compile "$LINENO" "linux/fiemap.h" "ac_cv_header_linux_fiemap_h" "as_fn_error $? "--enable-dmfilemapd requires fiemap.h" "$LINENO" 5
+"
+if test "x$ac_cv_header_linux_fiemap_h" = xyes
+then :
+
+fi
+
+
+printf "%s\n" "#define DMFILEMAPD 1" >>confdefs.h
+
 fi
 
 ################################################################################
@@ -14497,8 +14481,8 @@ fi
   test $ac_status = 0; }; then
 
 pkg_failed=no
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for SELINUX" >&5
-printf %s "checking for SELINUX... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for libselinux" >&5
+printf %s "checking for libselinux... " >&6; }
 
 if test -n "$SELINUX_CFLAGS"; then
     pkg_cv_SELINUX_CFLAGS="$SELINUX_CFLAGS"
@@ -14538,7 +14522,7 @@ fi
 
 
 if test $pkg_failed = yes; then
-   	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+        { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
 printf "%s\n" "no" >&6; }
 
 if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
@@ -14547,14 +14531,14 @@ else
         _pkg_short_errors_supported=no
 fi
         if test $_pkg_short_errors_supported = yes; then
-	        SELINUX_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors --cflags --libs "libselinux" 2>&1`
+                SELINUX_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors --cflags --libs "libselinux" 2>&1`
         else
-	        SELINUX_PKG_ERRORS=`$PKG_CONFIG --print-errors --cflags --libs "libselinux" 2>&1`
+                SELINUX_PKG_ERRORS=`$PKG_CONFIG --print-errors --cflags --libs "libselinux" 2>&1`
         fi
-	# Put the nasty error message in config.log where it belongs
-	echo "$SELINUX_PKG_ERRORS" >&5
+        # Put the nasty error message in config.log where it belongs
+        echo "$SELINUX_PKG_ERRORS" >&5
 
-	as_fn_error $? "Package requirements (libselinux) were not met:
+        as_fn_error $? "Package requirements (libselinux) were not met:
 
 $SELINUX_PKG_ERRORS
 
@@ -14565,9 +14549,9 @@ Alternatively, you may set the environment variables SELINUX_CFLAGS
 and SELINUX_LIBS to avoid the need to call pkg-config.
 See the pkg-config man page for more details." "$LINENO" 5
 elif test $pkg_failed = untried; then
-     	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+        { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
 printf "%s\n" "no" >&6; }
-	{ { printf "%s\n" "$as_me:${as_lineno-$LINENO}: error: in \`$ac_pwd':" >&5
+        { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: error: in \`$ac_pwd':" >&5
 printf "%s\n" "$as_me: error: in \`$ac_pwd':" >&2;}
 as_fn_error $? "The pkg-config script could not be found or is too old.  Make sure it
 is in your PATH or set the PKG_CONFIG environment variable to the full
@@ -14580,11 +14564,11 @@ See the pkg-config man page for more details.
 To get pkg-config, see <http://pkg-config.freedesktop.org/>.
 See \`config.log' for more details" "$LINENO" 5; }
 else
-	SELINUX_CFLAGS=$pkg_cv_SELINUX_CFLAGS
-	SELINUX_LIBS=$pkg_cv_SELINUX_LIBS
+        SELINUX_CFLAGS=$pkg_cv_SELINUX_CFLAGS
+        SELINUX_LIBS=$pkg_cv_SELINUX_LIBS
         { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: yes" >&5
 printf "%s\n" "yes" >&6; }
-	SELINUX_STATIC_LIBS=$("$PKG_CONFIG" --static --libs libselinux)
+        SELINUX_STATIC_LIBS=$("$PKG_CONFIG" --static --libs libselinux)
 fi
 fi
 
@@ -14863,8 +14847,8 @@ then :
 
 
 pkg_failed=no
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for EDITLINE" >&5
-printf %s "checking for EDITLINE... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for libedit" >&5
+printf %s "checking for libedit... " >&6; }
 
 if test -n "$EDITLINE_CFLAGS"; then
     pkg_cv_EDITLINE_CFLAGS="$EDITLINE_CFLAGS"
@@ -14904,7 +14888,7 @@ fi
 
 
 if test $pkg_failed = yes; then
-   	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+        { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
 printf "%s\n" "no" >&6; }
 
 if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
@@ -14913,23 +14897,23 @@ else
         _pkg_short_errors_supported=no
 fi
         if test $_pkg_short_errors_supported = yes; then
-	        EDITLINE_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors --cflags --libs "libedit" 2>&1`
+                EDITLINE_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors --cflags --libs "libedit" 2>&1`
         else
-	        EDITLINE_PKG_ERRORS=`$PKG_CONFIG --print-errors --cflags --libs "libedit" 2>&1`
+                EDITLINE_PKG_ERRORS=`$PKG_CONFIG --print-errors --cflags --libs "libedit" 2>&1`
         fi
-	# Put the nasty error message in config.log where it belongs
-	echo "$EDITLINE_PKG_ERRORS" >&5
+        # Put the nasty error message in config.log where it belongs
+        echo "$EDITLINE_PKG_ERRORS" >&5
 
-	as_fn_error $? "libedit could not be found which is required for the --enable-editline option." "$LINENO" 5
+        as_fn_error $? "libedit could not be found which is required for the --enable-editline option." "$LINENO" 5
 
 elif test $pkg_failed = untried; then
-     	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+        { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
 printf "%s\n" "no" >&6; }
-	as_fn_error $? "libedit could not be found which is required for the --enable-editline option." "$LINENO" 5
+        as_fn_error $? "libedit could not be found which is required for the --enable-editline option." "$LINENO" 5
 
 else
-	EDITLINE_CFLAGS=$pkg_cv_EDITLINE_CFLAGS
-	EDITLINE_LIBS=$pkg_cv_EDITLINE_LIBS
+        EDITLINE_CFLAGS=$pkg_cv_EDITLINE_CFLAGS
+        EDITLINE_LIBS=$pkg_cv_EDITLINE_LIBS
         { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: yes" >&5
 printf "%s\n" "yes" >&6; }
 
@@ -15377,7 +15361,6 @@ fi
 if test -z "$with_systemdsystemunitdir"
 then :
 
-
 if test -n "$systemdsystemunitdir"; then
     pkg_cv_systemdsystemunitdir="$systemdsystemunitdir"
  elif test -n "$PKG_CONFIG"; then
@@ -15399,15 +15382,10 @@ systemdsystemunitdir=$pkg_cv_systemdsystemunitdir
 
 if test "x$systemdsystemunitdir" = x""
 then :
-
-		systemdsystemunitdir='${exec_prefix}/lib/systemd/system'
-
+  systemdsystemunitdir='${exec_prefix}/lib/systemd/system'
 fi
-
 else $as_nop
-
-	systemdsystemunitdir="$with_systemdsystemunitdir"
-
+  systemdsystemunitdir="$with_systemdsystemunitdir"
 fi
 
 
@@ -15432,9 +15410,7 @@ systemdutildir=$pkg_cv_systemdutildir
 
 if test "x$systemdutildir" = x""
 then :
-
-	systemdutildir='${exec_prefix}/lib/systemd'
-
+  systemdutildir='${exec_prefix}/lib/systemd'
 fi
 
 ################################################################################
@@ -16045,19 +16021,19 @@ DEFAULT_SYS_LOCK_DIR="$RUN_DIR/lock"
 test -d "$DEFAULT_SYS_LOCK_DIR" || DEFAULT_SYS_LOCK_DIR="/var/lock"
 
 # Support configurable locking subdir for lvm
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for default lock directory" >&5
+printf %s "checking for default lock directory... " >&6; }
 
 # Check whether --with-default-locking-dir was given.
 if test ${with_default_locking_dir+y}
 then :
   withval=$with_default_locking_dir; DEFAULT_LOCK_DIR=$withval
 else $as_nop
-  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for default lock directory" >&5
-printf %s "checking for default lock directory... " >&6; }
-	     DEFAULT_LOCK_DIR="$DEFAULT_SYS_LOCK_DIR/lvm"
-	     { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $DEFAULT_LOCK_DIR" >&5
-printf "%s\n" "$DEFAULT_LOCK_DIR" >&6; }
+  DEFAULT_LOCK_DIR="$DEFAULT_SYS_LOCK_DIR/lvm"
 fi
 
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $DEFAULT_LOCK_DIR" >&5
+printf "%s\n" "$DEFAULT_LOCK_DIR" >&6; }
 
 printf "%s\n" "#define DEFAULT_LOCK_DIR \"$DEFAULT_LOCK_DIR\"" >>confdefs.h
 

