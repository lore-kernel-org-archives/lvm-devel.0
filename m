From: agk@sourceware.org <agk@sourceware.org>
Date: 21 Jul 2010 12:54:22 -0000
Subject: LVM2 configure
Message-ID: <20100721125422.27913.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-07-21 12:54:22

Modified files:
	.              : configure 

Log message:
	update configure

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.135&r2=1.136

--- LVM2/configure	2010/07/13 13:51:01	1.135
+++ LVM2/configure	2010/07/21 12:54:21	1.136
@@ -651,6 +651,7 @@
 UDEV_RULES
 UDEV_PC
 UDEV_LIBS
+TESTING
 STATIC_LINK
 STATICDIR
 SNAPSHOTS
@@ -711,6 +712,8 @@
 MSGFMT
 LVM2CMD_LIB
 LVM2APP_LIB
+VALGRIND
+RUBY19
 GENPNG
 GENHTML
 LCOV
@@ -835,6 +838,7 @@
 enable_debug
 with_optimisation
 enable_profiling
+enable_testing
 enable_devmapper
 enable_udev_sync
 enable_udev_rules
@@ -1531,6 +1535,7 @@
   --enable-cmirrord       enable the cluster mirror log daemon
   --enable-debug          enable debugging
   --enable-profiling      gather gcov profiling data
+  --enable-testing        enable testing targets in the makefile
   --disable-devmapper     disable LVM2 device-mapper interaction
   --enable-udev_sync      enable synchronisation with udev processing
   --enable-udev_rules     install rule files needed for udev synchronisation
@@ -14298,6 +14303,107 @@
 fi
 
 ################################################################################
+{ $as_echo "$as_me:$LINENO: checking whether to enable unit testing" >&5
+$as_echo_n "checking whether to enable unit testing... " >&6; }
+# Check whether --enable-testing was given.
+if test "${enable_testing+set}" = set; then
+  enableval=$enable_testing; TESTING=$enableval
+else
+  TESTING=no
+fi
+
+{ $as_echo "$as_me:$LINENO: result: $TESTING" >&5
+$as_echo "$TESTING" >&6; }
+
+if test "$TESTING" = yes; then
+   # Extract the first word of "ruby1.9", so it can be a program name with args.
+set dummy ruby1.9; ac_word=$2
+{ $as_echo "$as_me:$LINENO: checking for $ac_word" >&5
+$as_echo_n "checking for $ac_word... " >&6; }
+if test "${ac_cv_path_RUBY19+set}" = set; then
+  $as_echo_n "(cached) " >&6
+else
+  case $RUBY19 in
+  [\\/]* | ?:[\\/]*)
+  ac_cv_path_RUBY19="$RUBY19" # Let the user override the test with a path.
+  ;;
+  *)
+  as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
+for as_dir in $PATH
+do
+  IFS=$as_save_IFS
+  test -z "$as_dir" && as_dir=.
+  for ac_exec_ext in '' $ac_executable_extensions; do
+  if { test -f "$as_dir/$ac_word$ac_exec_ext" && $as_test_x "$as_dir/$ac_word$ac_exec_ext"; }; then
+    ac_cv_path_RUBY19="$as_dir/$ac_word$ac_exec_ext"
+    $as_echo "$as_me:$LINENO: found $as_dir/$ac_word$ac_exec_ext" >&5
+    break 2
+  fi
+done
+done
+IFS=$as_save_IFS
+
+  ;;
+esac
+fi
+RUBY19=$ac_cv_path_RUBY19
+if test -n "$RUBY19"; then
+  { $as_echo "$as_me:$LINENO: result: $RUBY19" >&5
+$as_echo "$RUBY19" >&6; }
+else
+  { $as_echo "$as_me:$LINENO: result: no" >&5
+$as_echo "no" >&6; }
+fi
+
+
+   # Extract the first word of "valgrind", so it can be a program name with args.
+set dummy valgrind; ac_word=$2
+{ $as_echo "$as_me:$LINENO: checking for $ac_word" >&5
+$as_echo_n "checking for $ac_word... " >&6; }
+if test "${ac_cv_path_VALGRIND+set}" = set; then
+  $as_echo_n "(cached) " >&6
+else
+  case $VALGRIND in
+  [\\/]* | ?:[\\/]*)
+  ac_cv_path_VALGRIND="$VALGRIND" # Let the user override the test with a path.
+  ;;
+  *)
+  as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
+for as_dir in $PATH
+do
+  IFS=$as_save_IFS
+  test -z "$as_dir" && as_dir=.
+  for ac_exec_ext in '' $ac_executable_extensions; do
+  if { test -f "$as_dir/$ac_word$ac_exec_ext" && $as_test_x "$as_dir/$ac_word$ac_exec_ext"; }; then
+    ac_cv_path_VALGRIND="$as_dir/$ac_word$ac_exec_ext"
+    $as_echo "$as_me:$LINENO: found $as_dir/$ac_word$ac_exec_ext" >&5
+    break 2
+  fi
+done
+done
+IFS=$as_save_IFS
+
+  ;;
+esac
+fi
+VALGRIND=$ac_cv_path_VALGRIND
+if test -n "$VALGRIND"; then
+  { $as_echo "$as_me:$LINENO: result: $VALGRIND" >&5
+$as_echo "$VALGRIND" >&6; }
+else
+  { $as_echo "$as_me:$LINENO: result: no" >&5
+$as_echo "no" >&6; }
+fi
+
+
+   if test -z "$RUBY19" -o -z "$VALGRIND"; then
+       { { $as_echo "$as_me:$LINENO: error: ruby1.9 and valgrind are required for testing" >&5
+$as_echo "$as_me: error: ruby1.9 and valgrind are required for testing" >&2;}
+   { (exit 1); exit 1; }; }
+   fi
+fi
+
+################################################################################
 { $as_echo "$as_me:$LINENO: checking whether to use device-mapper" >&5
 $as_echo_n "checking whether to use device-mapper... " >&6; }
 # Check whether --enable-devmapper was given.
@@ -17919,8 +18025,9 @@
 
 
 
+
 ################################################################################
-ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile doc/Makefile doc/example.conf include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/snapshot/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/lvm2_monitoring_init_red_hat scripts/Makefile test/Makefile test/api/Makefile tools/Makefile udev/Makefile"
+ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile doc/Makefile doc/example.conf include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/snapshot/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/lvm2_monitoring_init_red_hat scripts/Makefile test/Makefile test/api/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile"
 
 cat >confcache <<\_ACEOF
 # This file is a shell script that caches the results of configure
@@ -18556,6 +18663,8 @@
     "test/api/Makefile") CONFIG_FILES="$CONFIG_FILES test/api/Makefile" ;;
     "tools/Makefile") CONFIG_FILES="$CONFIG_FILES tools/Makefile" ;;
     "udev/Makefile") CONFIG_FILES="$CONFIG_FILES udev/Makefile" ;;
+    "unit-tests/datastruct/Makefile") CONFIG_FILES="$CONFIG_FILES unit-tests/datastruct/Makefile" ;;
+    "unit-tests/regex/Makefile") CONFIG_FILES="$CONFIG_FILES unit-tests/regex/Makefile" ;;
 
   *) { { $as_echo "$as_me:$LINENO: error: invalid argument: $ac_config_target" >&5
 $as_echo "$as_me: error: invalid argument: $ac_config_target" >&2;}


