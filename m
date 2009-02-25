From: agk@sourceware.org <agk@sourceware.org>
Date: 25 Feb 2009 23:33:30 -0000
Subject: LVM2 configure
Message-ID: <20090225233330.18031.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-02-25 23:33:30

Modified files:
	.              : configure 

Log message:
	autoreconf  (using fedora 10 for this now)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.90&r2=1.91

--- LVM2/configure	2009/02/22 22:11:58	1.90
+++ LVM2/configure	2009/02/25 23:33:30	1.91
@@ -658,7 +658,6 @@
 LVM_MINOR
 LVM_MAJOR
 LVM_VERSION
-CONFDIR
 LVM1_FALLBACK
 LVM1
 LOCALEDIR
@@ -683,6 +682,7 @@
 DEVMAPPER
 DEBUG
 COPTIMISE_FLAG
+CONFDIR
 CMDLIB
 CLVMD
 CLUSTER
@@ -695,6 +695,13 @@
 LVM2CMD_LIB
 GENHTML
 LCOV
+CPG_LIBS
+CPG_CFLAGS
+CONFDB_LIBS
+CONFDB_CFLAGS
+QUORUM_LIBS
+QUORUM_CFLAGS
+PKG_CONFIG
 POW_LIB
 LIBOBJS
 ALLOCA
@@ -816,7 +823,14 @@
 LDFLAGS
 LIBS
 CPPFLAGS
-CPP'
+CPP
+PKG_CONFIG
+QUORUM_CFLAGS
+QUORUM_LIBS
+CONFDB_CFLAGS
+CONFDB_LIBS
+CPG_CFLAGS
+CPG_LIBS'
 
 
 # Initialize some variables set by options.
@@ -1499,6 +1513,15 @@
   CPPFLAGS    C/C++/Objective C preprocessor flags, e.g. -I<include dir> if
               you have headers in a nonstandard directory <include dir>
   CPP         C preprocessor
+  PKG_CONFIG  path to pkg-config utility
+  QUORUM_CFLAGS
+              C compiler flags for QUORUM, overriding pkg-config
+  QUORUM_LIBS linker flags for QUORUM, overriding pkg-config
+  CONFDB_CFLAGS
+              C compiler flags for CONFDB, overriding pkg-config
+  CONFDB_LIBS linker flags for CONFDB, overriding pkg-config
+  CPG_CFLAGS  C compiler flags for CPG, overriding pkg-config
+  CPG_LIBS    linker flags for CPG, overriding pkg-config
 
 Use these variables to override the choices made by `configure' or to help
 it to find libraries and programs with nonstandard names/locations.
@@ -9161,6 +9184,338 @@
 	CLUSTER=internal
 fi
 
+if [ "x$CLVMD" = xcorosync -o "x$CLVMD" = xall ]; then
+
+
+if test "x$ac_cv_env_PKG_CONFIG_set" != "xset"; then
+	if test -n "$ac_tool_prefix"; then
+  # Extract the first word of "${ac_tool_prefix}pkg-config", so it can be a program name with args.
+set dummy ${ac_tool_prefix}pkg-config; ac_word=$2
+{ $as_echo "$as_me:$LINENO: checking for $ac_word" >&5
+$as_echo_n "checking for $ac_word... " >&6; }
+if test "${ac_cv_path_PKG_CONFIG+set}" = set; then
+  $as_echo_n "(cached) " >&6
+else
+  case $PKG_CONFIG in
+  [\\/]* | ?:[\\/]*)
+  ac_cv_path_PKG_CONFIG="$PKG_CONFIG" # Let the user override the test with a path.
+  ;;
+  *)
+  as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
+for as_dir in $PATH
+do
+  IFS=$as_save_IFS
+  test -z "$as_dir" && as_dir=.
+  for ac_exec_ext in '' $ac_executable_extensions; do
+  if { test -f "$as_dir/$ac_word$ac_exec_ext" && $as_test_x "$as_dir/$ac_word$ac_exec_ext"; }; then
+    ac_cv_path_PKG_CONFIG="$as_dir/$ac_word$ac_exec_ext"
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
+PKG_CONFIG=$ac_cv_path_PKG_CONFIG
+if test -n "$PKG_CONFIG"; then
+  { $as_echo "$as_me:$LINENO: result: $PKG_CONFIG" >&5
+$as_echo "$PKG_CONFIG" >&6; }
+else
+  { $as_echo "$as_me:$LINENO: result: no" >&5
+$as_echo "no" >&6; }
+fi
+
+
+fi
+if test -z "$ac_cv_path_PKG_CONFIG"; then
+  ac_pt_PKG_CONFIG=$PKG_CONFIG
+  # Extract the first word of "pkg-config", so it can be a program name with args.
+set dummy pkg-config; ac_word=$2
+{ $as_echo "$as_me:$LINENO: checking for $ac_word" >&5
+$as_echo_n "checking for $ac_word... " >&6; }
+if test "${ac_cv_path_ac_pt_PKG_CONFIG+set}" = set; then
+  $as_echo_n "(cached) " >&6
+else
+  case $ac_pt_PKG_CONFIG in
+  [\\/]* | ?:[\\/]*)
+  ac_cv_path_ac_pt_PKG_CONFIG="$ac_pt_PKG_CONFIG" # Let the user override the test with a path.
+  ;;
+  *)
+  as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
+for as_dir in $PATH
+do
+  IFS=$as_save_IFS
+  test -z "$as_dir" && as_dir=.
+  for ac_exec_ext in '' $ac_executable_extensions; do
+  if { test -f "$as_dir/$ac_word$ac_exec_ext" && $as_test_x "$as_dir/$ac_word$ac_exec_ext"; }; then
+    ac_cv_path_ac_pt_PKG_CONFIG="$as_dir/$ac_word$ac_exec_ext"
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
+ac_pt_PKG_CONFIG=$ac_cv_path_ac_pt_PKG_CONFIG
+if test -n "$ac_pt_PKG_CONFIG"; then
+  { $as_echo "$as_me:$LINENO: result: $ac_pt_PKG_CONFIG" >&5
+$as_echo "$ac_pt_PKG_CONFIG" >&6; }
+else
+  { $as_echo "$as_me:$LINENO: result: no" >&5
+$as_echo "no" >&6; }
+fi
+
+  if test "x$ac_pt_PKG_CONFIG" = x; then
+    PKG_CONFIG=""
+  else
+    case $cross_compiling:$ac_tool_warned in
+yes:)
+{ $as_echo "$as_me:$LINENO: WARNING: using cross tools not prefixed with host triplet" >&5
+$as_echo "$as_me: WARNING: using cross tools not prefixed with host triplet" >&2;}
+ac_tool_warned=yes ;;
+esac
+    PKG_CONFIG=$ac_pt_PKG_CONFIG
+  fi
+else
+  PKG_CONFIG="$ac_cv_path_PKG_CONFIG"
+fi
+
+fi
+if test -n "$PKG_CONFIG"; then
+	_pkg_min_version=0.9.0
+	{ $as_echo "$as_me:$LINENO: checking pkg-config is at least version $_pkg_min_version" >&5
+$as_echo_n "checking pkg-config is at least version $_pkg_min_version... " >&6; }
+	if $PKG_CONFIG --atleast-pkgconfig-version $_pkg_min_version; then
+		{ $as_echo "$as_me:$LINENO: result: yes" >&5
+$as_echo "yes" >&6; }
+	else
+		{ $as_echo "$as_me:$LINENO: result: no" >&5
+$as_echo "no" >&6; }
+		PKG_CONFIG=""
+	fi
+
+fi
+
+pkg_failed=no
+{ $as_echo "$as_me:$LINENO: checking for QUORUM" >&5
+$as_echo_n "checking for QUORUM... " >&6; }
+
+if test -n "$QUORUM_CFLAGS"; then
+    pkg_cv_QUORUM_CFLAGS="$QUORUM_CFLAGS"
+ elif test -n "$PKG_CONFIG"; then
+    if test -n "$PKG_CONFIG" && \
+    { ($as_echo "$as_me:$LINENO: \$PKG_CONFIG --exists --print-errors \"libquorum\"") >&5
+  ($PKG_CONFIG --exists --print-errors "libquorum") 2>&5
+  ac_status=$?
+  $as_echo "$as_me:$LINENO: \$? = $ac_status" >&5
+  (exit $ac_status); }; then
+  pkg_cv_QUORUM_CFLAGS=`$PKG_CONFIG --cflags "libquorum" 2>/dev/null`
+else
+  pkg_failed=yes
+fi
+ else
+    pkg_failed=untried
+fi
+if test -n "$QUORUM_LIBS"; then
+    pkg_cv_QUORUM_LIBS="$QUORUM_LIBS"
+ elif test -n "$PKG_CONFIG"; then
+    if test -n "$PKG_CONFIG" && \
+    { ($as_echo "$as_me:$LINENO: \$PKG_CONFIG --exists --print-errors \"libquorum\"") >&5
+  ($PKG_CONFIG --exists --print-errors "libquorum") 2>&5
+  ac_status=$?
+  $as_echo "$as_me:$LINENO: \$? = $ac_status" >&5
+  (exit $ac_status); }; then
+  pkg_cv_QUORUM_LIBS=`$PKG_CONFIG --libs "libquorum" 2>/dev/null`
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
+
+if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
+        _pkg_short_errors_supported=yes
+else
+        _pkg_short_errors_supported=no
+fi
+        if test $_pkg_short_errors_supported = yes; then
+	        QUORUM_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors "libquorum" 2>&1`
+        else
+	        QUORUM_PKG_ERRORS=`$PKG_CONFIG --print-errors "libquorum" 2>&1`
+        fi
+	# Put the nasty error message in config.log where it belongs
+	echo "$QUORUM_PKG_ERRORS" >&5
+
+	{ $as_echo "$as_me:$LINENO: result: no" >&5
+$as_echo "no" >&6; }
+                { $as_echo "$as_me:$LINENO: result: no pkg for quorum library, using -lquorum" >&5
+$as_echo "no pkg for quorum library, using -lquorum" >&6; };
+		QUORUM_LIBS="-lquorum"
+elif test $pkg_failed = untried; then
+	{ $as_echo "$as_me:$LINENO: result: no pkg for quorum library, using -lquorum" >&5
+$as_echo "no pkg for quorum library, using -lquorum" >&6; };
+		QUORUM_LIBS="-lquorum"
+else
+	QUORUM_CFLAGS=$pkg_cv_QUORUM_CFLAGS
+	QUORUM_LIBS=$pkg_cv_QUORUM_LIBS
+        { $as_echo "$as_me:$LINENO: result: yes" >&5
+$as_echo "yes" >&6; }
+	:
+fi
+
+pkg_failed=no
+{ $as_echo "$as_me:$LINENO: checking for CONFDB" >&5
+$as_echo_n "checking for CONFDB... " >&6; }
+
+if test -n "$CONFDB_CFLAGS"; then
+    pkg_cv_CONFDB_CFLAGS="$CONFDB_CFLAGS"
+ elif test -n "$PKG_CONFIG"; then
+    if test -n "$PKG_CONFIG" && \
+    { ($as_echo "$as_me:$LINENO: \$PKG_CONFIG --exists --print-errors \"libconfdb\"") >&5
+  ($PKG_CONFIG --exists --print-errors "libconfdb") 2>&5
+  ac_status=$?
+  $as_echo "$as_me:$LINENO: \$? = $ac_status" >&5
+  (exit $ac_status); }; then
+  pkg_cv_CONFDB_CFLAGS=`$PKG_CONFIG --cflags "libconfdb" 2>/dev/null`
+else
+  pkg_failed=yes
+fi
+ else
+    pkg_failed=untried
+fi
+if test -n "$CONFDB_LIBS"; then
+    pkg_cv_CONFDB_LIBS="$CONFDB_LIBS"
+ elif test -n "$PKG_CONFIG"; then
+    if test -n "$PKG_CONFIG" && \
+    { ($as_echo "$as_me:$LINENO: \$PKG_CONFIG --exists --print-errors \"libconfdb\"") >&5
+  ($PKG_CONFIG --exists --print-errors "libconfdb") 2>&5
+  ac_status=$?
+  $as_echo "$as_me:$LINENO: \$? = $ac_status" >&5
+  (exit $ac_status); }; then
+  pkg_cv_CONFDB_LIBS=`$PKG_CONFIG --libs "libconfdb" 2>/dev/null`
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
+
+if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
+        _pkg_short_errors_supported=yes
+else
+        _pkg_short_errors_supported=no
+fi
+        if test $_pkg_short_errors_supported = yes; then
+	        CONFDB_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors "libconfdb" 2>&1`
+        else
+	        CONFDB_PKG_ERRORS=`$PKG_CONFIG --print-errors "libconfdb" 2>&1`
+        fi
+	# Put the nasty error message in config.log where it belongs
+	echo "$CONFDB_PKG_ERRORS" >&5
+
+	{ $as_echo "$as_me:$LINENO: result: no" >&5
+$as_echo "no" >&6; }
+                { $as_echo "$as_me:$LINENO: result: no pkg for confdb library, using -lconfdb" >&5
+$as_echo "no pkg for confdb library, using -lconfdb" >&6; };
+		CONFDB_LIBS="-lconfdb"
+elif test $pkg_failed = untried; then
+	{ $as_echo "$as_me:$LINENO: result: no pkg for confdb library, using -lconfdb" >&5
+$as_echo "no pkg for confdb library, using -lconfdb" >&6; };
+		CONFDB_LIBS="-lconfdb"
+else
+	CONFDB_CFLAGS=$pkg_cv_CONFDB_CFLAGS
+	CONFDB_LIBS=$pkg_cv_CONFDB_LIBS
+        { $as_echo "$as_me:$LINENO: result: yes" >&5
+$as_echo "yes" >&6; }
+	:
+fi
+
+pkg_failed=no
+{ $as_echo "$as_me:$LINENO: checking for CPG" >&5
+$as_echo_n "checking for CPG... " >&6; }
+
+if test -n "$CPG_CFLAGS"; then
+    pkg_cv_CPG_CFLAGS="$CPG_CFLAGS"
+ elif test -n "$PKG_CONFIG"; then
+    if test -n "$PKG_CONFIG" && \
+    { ($as_echo "$as_me:$LINENO: \$PKG_CONFIG --exists --print-errors \"libcpg\"") >&5
+  ($PKG_CONFIG --exists --print-errors "libcpg") 2>&5
+  ac_status=$?
+  $as_echo "$as_me:$LINENO: \$? = $ac_status" >&5
+  (exit $ac_status); }; then
+  pkg_cv_CPG_CFLAGS=`$PKG_CONFIG --cflags "libcpg" 2>/dev/null`
+else
+  pkg_failed=yes
+fi
+ else
+    pkg_failed=untried
+fi
+if test -n "$CPG_LIBS"; then
+    pkg_cv_CPG_LIBS="$CPG_LIBS"
+ elif test -n "$PKG_CONFIG"; then
+    if test -n "$PKG_CONFIG" && \
+    { ($as_echo "$as_me:$LINENO: \$PKG_CONFIG --exists --print-errors \"libcpg\"") >&5
+  ($PKG_CONFIG --exists --print-errors "libcpg") 2>&5
+  ac_status=$?
+  $as_echo "$as_me:$LINENO: \$? = $ac_status" >&5
+  (exit $ac_status); }; then
+  pkg_cv_CPG_LIBS=`$PKG_CONFIG --libs "libcpg" 2>/dev/null`
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
+
+if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
+        _pkg_short_errors_supported=yes
+else
+        _pkg_short_errors_supported=no
+fi
+        if test $_pkg_short_errors_supported = yes; then
+	        CPG_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors "libcpg" 2>&1`
+        else
+	        CPG_PKG_ERRORS=`$PKG_CONFIG --print-errors "libcpg" 2>&1`
+        fi
+	# Put the nasty error message in config.log where it belongs
+	echo "$CPG_PKG_ERRORS" >&5
+
+	{ $as_echo "$as_me:$LINENO: result: no" >&5
+$as_echo "no" >&6; }
+                { $as_echo "$as_me:$LINENO: result: no pkg for libcpg library, using -lcpg" >&5
+$as_echo "no pkg for libcpg library, using -lcpg" >&6; };
+		CPG_LIBS="-lcpg"
+elif test $pkg_failed = untried; then
+	{ $as_echo "$as_me:$LINENO: result: no pkg for libcpg library, using -lcpg" >&5
+$as_echo "no pkg for libcpg library, using -lcpg" >&6; };
+		CPG_LIBS="-lcpg"
+else
+	CPG_CFLAGS=$pkg_cv_CPG_CFLAGS
+	CPG_LIBS=$pkg_cv_CPG_LIBS
+        { $as_echo "$as_me:$LINENO: result: yes" >&5
+$as_echo "yes" >&6; }
+	:
+fi
+fi
+
 ################################################################################
 { $as_echo "$as_me:$LINENO: checking whether to enable debugging" >&5
 $as_echo_n "checking whether to enable debugging... " >&6; }
@@ -12297,6 +12652,12 @@
 
 
 
+
+
+
+
+
+
 ################################################################################
 ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile doc/Makefile include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/misc/lvm-version.h lib/snapshot/Makefile libdm/Makefile libdm/libdevmapper.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/Makefile test/Makefile test/api/Makefile tools/Makefile"
 


