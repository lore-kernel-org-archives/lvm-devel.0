From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 21 Nov 2011 10:40:22 -0000
Subject: LVM2 configure configure.in
Message-ID: <20111121104022.21743.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-11-21 10:40:21

Modified files:
	.              : configure configure.in 

Log message:
	Add CUnit testing support
	
	Regenerate configure for unit test support.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.160&r2=1.161
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.175&r2=1.176

--- LVM2/configure	2011/11/14 21:30:35	1.160
+++ LVM2/configure	2011/11/21 10:40:21	1.161
@@ -683,8 +683,6 @@
 LVM2APP_LIB
 UDEV_LIBS
 UDEV_CFLAGS
-VALGRIND
-RUBY19
 GENPNG
 GENHTML
 LCOV
@@ -8427,89 +8425,17 @@
 $as_echo "$TESTING" >&6; }
 
 if test "$TESTING" = yes; then
-   # Extract the first word of "ruby1.9", so it can be a program name with args.
-set dummy ruby1.9; ac_word=$2
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
-$as_echo_n "checking for $ac_word... " >&6; }
-if test "${ac_cv_path_RUBY19+set}" = set; then :
-  $as_echo_n "(cached) " >&6
-else
-  case $RUBY19 in
-  [\\/]* | ?:[\\/]*)
-  ac_cv_path_RUBY19="$RUBY19" # Let the user override the test with a path.
-  ;;
-  *)
-  as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
-for as_dir in $PATH
-do
-  IFS=$as_save_IFS
-  test -z "$as_dir" && as_dir=.
-    for ac_exec_ext in '' $ac_executable_extensions; do
-  if { test -f "$as_dir/$ac_word$ac_exec_ext" && $as_test_x "$as_dir/$ac_word$ac_exec_ext"; }; then
-    ac_cv_path_RUBY19="$as_dir/$ac_word$ac_exec_ext"
-    $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
-    break 2
-  fi
-done
-  done
-IFS=$as_save_IFS
-
-  ;;
-esac
-fi
-RUBY19=$ac_cv_path_RUBY19
-if test -n "$RUBY19"; then
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $RUBY19" >&5
-$as_echo "$RUBY19" >&6; }
-else
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
-fi
-
-
-   # Extract the first word of "valgrind", so it can be a program name with args.
-set dummy valgrind; ac_word=$2
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
-$as_echo_n "checking for $ac_word... " >&6; }
-if test "${ac_cv_path_VALGRIND+set}" = set; then :
-  $as_echo_n "(cached) " >&6
+	ac_fn_c_check_header_mongrel "$LINENO" "CUnit/Basic.h" "ac_cv_header_CUnit_Basic_h" "$ac_includes_default"
+if test "x$ac_cv_header_CUnit_Basic_h" = x""yes; then :
+  have_cunit=yes
 else
-  case $VALGRIND in
-  [\\/]* | ?:[\\/]*)
-  ac_cv_path_VALGRIND="$VALGRIND" # Let the user override the test with a path.
-  ;;
-  *)
-  as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
-for as_dir in $PATH
-do
-  IFS=$as_save_IFS
-  test -z "$as_dir" && as_dir=.
-    for ac_exec_ext in '' $ac_executable_extensions; do
-  if { test -f "$as_dir/$ac_word$ac_exec_ext" && $as_test_x "$as_dir/$ac_word$ac_exec_ext"; }; then
-    ac_cv_path_VALGRIND="$as_dir/$ac_word$ac_exec_ext"
-    $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
-    break 2
-  fi
-done
-  done
-IFS=$as_save_IFS
-
-  ;;
-esac
-fi
-VALGRIND=$ac_cv_path_VALGRIND
-if test -n "$VALGRIND"; then
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $VALGRIND" >&5
-$as_echo "$VALGRIND" >&6; }
-else
-  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
+  have_cunit=no
 fi
 
 
-   if test -z "$RUBY19" -o -z "$VALGRIND"; then
-       as_fn_error $? "ruby1.9 and valgrind are required for testing" "$LINENO" 5
-   fi
+	if test "$have_cunit" = "no"; then
+		as_fn_error $? "CUnit is required for unit testing" "$LINENO" 5
+	fi
 fi
 
 ################################################################################
@@ -10216,7 +10142,7 @@
 
 
 ################################################################################
-ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/common/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/lvmetad/Makefile doc/Makefile doc/example.conf include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/lvm2_monitoring_init_red_hat scripts/dm_event_systemd_red_hat.service scripts/lvm2_monitoring_systemd_red_hat.service scripts!
 /Makefile test/Makefile test/api/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
+ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/common/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/lvmetad/Makefile doc/Makefile doc/example.conf include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/lvm2_monitoring_init_red_hat scripts/dm_event_systemd_red_hat.service scripts/lvm2_monitoring_systemd_red_hat.service scripts!
 /Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
 
 cat >confcache <<\_ACEOF
 # This file is a shell script that caches the results of configure
@@ -10947,6 +10873,7 @@
     "scripts/Makefile") CONFIG_FILES="$CONFIG_FILES scripts/Makefile" ;;
     "test/Makefile") CONFIG_FILES="$CONFIG_FILES test/Makefile" ;;
     "test/api/Makefile") CONFIG_FILES="$CONFIG_FILES test/api/Makefile" ;;
+    "test/unit/Makefile") CONFIG_FILES="$CONFIG_FILES test/unit/Makefile" ;;
     "tools/Makefile") CONFIG_FILES="$CONFIG_FILES tools/Makefile" ;;
     "udev/Makefile") CONFIG_FILES="$CONFIG_FILES udev/Makefile" ;;
     "unit-tests/datastruct/Makefile") CONFIG_FILES="$CONFIG_FILES unit-tests/datastruct/Makefile" ;;
--- LVM2/configure.in	2011/11/20 21:43:20	1.175
+++ LVM2/configure.in	2011/11/21 10:40:21	1.176
@@ -759,11 +759,10 @@
 AC_MSG_RESULT($TESTING)
 
 if test "$TESTING" = yes; then
-   AC_PATH_PROG(RUBY19, ruby1.9)
-   AC_PATH_PROG(VALGRIND, valgrind)
-   if test -z "$RUBY19" -o -z "$VALGRIND"; then
-       AC_MSG_ERROR([ruby1.9 and valgrind are required for testing])
-   fi
+	AC_CHECK_HEADER([CUnit/Basic.h], have_cunit=yes, have_cunit=no)
+	if test "$have_cunit" = "no"; then
+		AC_MSG_ERROR([CUnit is required for unit testing])
+	fi
 fi
 
 ################################################################################


